From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 4/6] rxrpc: Once packet posted in data_ready,
 don't retry posting
Date: Tue, 09 Aug 2016 17:33:39 +0100
Message-ID: <147076041981.13232.459867114059191535.stgit@warthog.procyon.org.uk>
References: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932392AbcHIQdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2016 12:33:46 -0400
In-Reply-To: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once a packet has been posted to a connection in the data_ready handler, we
mustn't try reposting if we then find that the connection is dying as the
refcount has been given over to the dying connection and the packet might
no longer exist.

Losing the packet isn't a problem as the peer will retransmit.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 9e0f58edcd01..04afdc09557b 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -567,13 +567,13 @@ done:
  * post connection-level events to the connection
  * - this includes challenges, responses and some aborts
  */
-static bool rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
+static void rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
 				      struct sk_buff *skb)
 {
 	_enter("%p,%p", conn, skb);
 
 	skb_queue_tail(&conn->rx_queue, skb);
-	return rxrpc_queue_conn(conn);
+	rxrpc_queue_conn(conn);
 }
 
 /*
@@ -694,7 +694,6 @@ void rxrpc_data_ready(struct sock *sk)
 
 	rcu_read_lock();
 
-retry_find_conn:
 	conn = rxrpc_find_connection_rcu(local, skb);
 	if (!conn)
 		goto cant_route_call;
@@ -702,8 +701,7 @@ retry_find_conn:
 	if (sp->hdr.callNumber == 0) {
 		/* Connection-level packet */
 		_debug("CONN %p {%d}", conn, conn->debug_id);
-		if (!rxrpc_post_packet_to_conn(conn, skb))
-			goto retry_find_conn;
+		rxrpc_post_packet_to_conn(conn, skb);
 	} else {
 		/* Call-bound packets are routed by connection channel. */
 		unsigned int channel = sp->hdr.cid & RXRPC_CHANNELMASK;
