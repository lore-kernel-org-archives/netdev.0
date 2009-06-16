From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/2] RxRPC: Don't attempt to reuse aborted connections
Date: Tue, 16 Jun 2009 21:36:44 +0100
Message-ID: <20090616203644.4447.24960.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, David Howells <dhowells@redhat.com>
To: torvalds@osdl.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59427 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752885AbZFPUh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 16:37:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Connections that have seen a connection-level abort should not be reused as the
far end will just abort them again; instead a new connection should be made.

Connection-level aborts occur due to such things as authentication failures.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-connection.c |   10 ++++++++++
 net/rxrpc/ar-connevent.c  |    7 ++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)


diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 67e38a0..9f1ce84 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -444,6 +444,11 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 			conn = list_entry(bundle->avail_conns.next,
 					  struct rxrpc_connection,
 					  bundle_link);
+			if (conn->state >= RXRPC_CONN_REMOTELY_ABORTED) {
+				list_del_init(&conn->bundle_link);
+				bundle->num_conns--;
+				continue;
+			}
 			if (--conn->avail_calls == 0)
 				list_move(&conn->bundle_link,
 					  &bundle->busy_conns);
@@ -461,6 +466,11 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 			conn = list_entry(bundle->unused_conns.next,
 					  struct rxrpc_connection,
 					  bundle_link);
+			if (conn->state >= RXRPC_CONN_REMOTELY_ABORTED) {
+				list_del_init(&conn->bundle_link);
+				bundle->num_conns--;
+				continue;
+			}
 			ASSERTCMP(conn->avail_calls, ==, RXRPC_MAXCALLS);
 			conn->avail_calls = RXRPC_MAXCALLS - 1;
 			ASSERT(conn->channels[0] == NULL &&
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index dc5cb1e..0505cdc 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -150,11 +150,15 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 	u32 serial;
 	int loop, ret;
 
-	if (conn->state >= RXRPC_CONN_REMOTELY_ABORTED)
+	if (conn->state >= RXRPC_CONN_REMOTELY_ABORTED) {
+		kleave(" = -ECONNABORTED [%u]", conn->state);
 		return -ECONNABORTED;
+	}
 
 	serial = ntohl(sp->hdr.serial);
 
+	_enter("{%d},{%u,%%%u},", conn->debug_id, sp->hdr.type, serial);
+
 	switch (sp->hdr.type) {
 	case RXRPC_PACKET_TYPE_ABORT:
 		if (skb_copy_bits(skb, 0, &tmp, sizeof(tmp)) < 0)
@@ -199,6 +203,7 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		return 0;
 
 	default:
+		_leave(" = -EPROTO [%u]", sp->hdr.type);
 		return -EPROTO;
 	}
 }

