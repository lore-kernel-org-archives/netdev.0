From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/8] rxrpc: Pass the connection pointer to
 rxrpc_post_packet_to_call()
Date: Wed, 07 Sep 2016 16:23:08 +0100
Message-ID: <147326178889.26593.7011516971866063286.stgit@warthog.procyon.org.uk>
References: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pass the connection pointer to rxrpc_post_packet_to_call() as the call
might get disconnected whilst we're looking at it, but the connection
pointer determined by rxrpc_data_read() is guaranteed by RCU for the
duration of the call.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 9242fefd7f40..52da4373131f 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -497,7 +497,8 @@ protocol_error:
  * post an incoming packet to the appropriate call/socket to deal with
  * - must get rid of the sk_buff, either by freeing it or by queuing it
  */
-static void rxrpc_post_packet_to_call(struct rxrpc_call *call,
+static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
+				      struct rxrpc_call *call,
 				      struct sk_buff *skb)
 {
 	struct rxrpc_skb_priv *sp;
@@ -558,7 +559,7 @@ resend_final_ack:
 dead_call:
 	if (sp->hdr.type != RXRPC_PACKET_TYPE_ABORT) {
 		skb->priority = RX_CALL_DEAD;
-		rxrpc_reject_packet(call->conn->params.local, skb);
+		rxrpc_reject_packet(conn->params.local, skb);
 		goto unlock;
 	}
 free_unlock:
@@ -754,7 +755,7 @@ void rxrpc_data_ready(struct sock *sk)
 			goto cant_route_call;
 
 		rxrpc_see_call(call);
-		rxrpc_post_packet_to_call(call, skb);
+		rxrpc_post_packet_to_call(conn, call, skb);
 		goto out_unlock;
 	}
 
