From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: don't send FIN message from connectionless socket
Date: Thu, 22 Dec 2016 07:22:29 -0500
Message-ID: <1482409349-17081-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        parthasarathy.bhuvaragan@ericsson.com, ying.xue@windriver.com,
        maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
        Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.biz.mail.bf1.yahoo.com ([98.139.221.61]:44139 "EHLO
        smtp102.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754427AbcLVMWi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 07:22:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 6f00089c7372 ("tipc: remove SS_DISCONNECTING state") the
check for socket type is in the wrong place, causing a closing socket
to always send out a FIN message even when the socket was never
connected. This is normally harmless, since the destination node for
such messages most often is zero, and the message will be dropped, but
it is still a wrong and confusing behavior.

We fix this in this commit.

Reviewed-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 333c5da..800caaa 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -441,15 +441,19 @@ static void __tipc_shutdown(struct socket *sock, int error)
 	while ((skb = __skb_dequeue(&sk->sk_receive_queue)) != NULL) {
 		if (TIPC_SKB_CB(skb)->bytes_read) {
 			kfree_skb(skb);
-		} else {
-			if (!tipc_sk_type_connectionless(sk) &&
-			    sk->sk_state != TIPC_DISCONNECTING) {
-				tipc_set_sk_state(sk, TIPC_DISCONNECTING);
-				tipc_node_remove_conn(net, dnode, tsk->portid);
-			}
-			tipc_sk_respond(sk, skb, error);
+			continue;
+		}
+		if (!tipc_sk_type_connectionless(sk) &&
+		    sk->sk_state != TIPC_DISCONNECTING) {
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
+			tipc_node_remove_conn(net, dnode, tsk->portid);
 		}
+		tipc_sk_respond(sk, skb, error);
 	}
+
+	if (tipc_sk_type_connectionless(sk))
+		return;
+
 	if (sk->sk_state != TIPC_DISCONNECTING) {
 		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
 				      TIPC_CONN_MSG, SHORT_H_SIZE, 0, dnode,
@@ -457,10 +461,8 @@ static void __tipc_shutdown(struct socket *sock, int error)
 				      tsk->portid, error);
 		if (skb)
 			tipc_node_xmit_skb(net, skb, dnode, tsk->portid);
-		if (!tipc_sk_type_connectionless(sk)) {
-			tipc_node_remove_conn(net, dnode, tsk->portid);
-			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
-		}
+		tipc_node_remove_conn(net, dnode, tsk->portid);
+		tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 	}
 }
 
-- 
2.7.4
