import 'dart:async';
import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:clipboard/clipboard.dart';

class BadgeGenerator extends StatefulWidget {
  @override
  _BadgeGeneratorState createState() => _BadgeGeneratorState();
}

class _BadgeGeneratorState extends State<BadgeGenerator> {
  late WebViewController _controller;
  late String _link;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Badge Generator'),
          backgroundColor: Colors.grey[700],
          elevation: 0,
          centerTitle: true,
        ),
        body: WebView(
          initialUrl: 'https://readmebadgegenerator.vercel.app/',
          // initialUrl: 'http://192.168.1.10:8080/app',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
          },
          javascriptChannels: <JavascriptChannel>{
            // Set Javascript Channel to WebView
            _extractDataJSChannel(context),
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            // In the final result page we check the url to make sure  it is the last page.
            _controller.runJavascript(
                "(function(){document.getElementById('appbar').style.display='none'})();");
            _controller.runJavascript(
                "(function(){Site.postMessage(window.document.getElementById('linkBadge'))})();");
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.copy_all,
            size: 32,
          ),
          backgroundColor: Colors.grey[700],
          onPressed: () => {
            _controller.runJavascript(
                "(function(){Site.postMessage(window.document.getElementById('linkBadge').innerText)})();"),
            FlutterClipboard.copy(_link),
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              message: "Badge Copiada!",
              duration: Duration(seconds: 3),
              margin: EdgeInsets.only(top: 10,left: 8, right: 8),
              padding: EdgeInsets.all(20),
              backgroundColor: Color(0xff21ba45),
              borderRadius: BorderRadius.circular(8),
            )..show(context),
          },
        ));
  }

  JavascriptChannel _extractDataJSChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Site',
      onMessageReceived: (JavascriptMessage message) {
        String pageBody = message.message;
        _link = pageBody;
        // print('------------------------ RESULT: $pageBody');
      },
    );
  }
}
