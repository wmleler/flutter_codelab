import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
      home: const MyHomePage(title: 'Baby Name Votes'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      key: ValueKey(document.documentID),
      title: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x80000000)),
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Text(document['name']),
            ),
            Text(
              document['votes'].toString(),
            ),
          ],
        ),
      ),
      onTap: () => Firestore.instance.runTransaction((transaction) async {
            DocumentSnapshot freshSnap =
                await transaction.get(document.reference);
            await transaction
                .update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder(
          // TODO: change to snapshots()
          stream: Firestore.instance.collection('baby').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            return ListView.builder(
              // key: ObjectKey(snapshot),
              itemCount: snapshot.data.documents.length,
              padding: const EdgeInsets.only(top: 10.0),
//                itemExtent: 25.0,
//                itemBuilder: (context, index) {
//                  DocumentSnapshot ds = snapshot.data.documents[index];
//                  return Text(" ${ds['name']} ${ds['votes']}");
//                },

              itemExtent: 55.0,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          }),
    );
  }
}
