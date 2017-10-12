From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 05/18] tipc: add new function for sending multiple small messages
Date: Thu, 12 Oct 2017 16:02:26 +0200
Message-ID: <1507816959-31787-6-git-send-email-jon.maloy@ericsson.com>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:51926 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdJLOCx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:02:53 -0400
In-Reply-To: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We see an increasing need to send multiple single-buffer messages
of TIPC_SYSTEM_IMPORTANCE to different individual destination nodes.
Instead of looping over the send queue and sending each buffer
individually, as we do now, we add a new help function
tipc_node_distr_xmit() to do this.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/node.c   | 16 ++++++++++++++++
 net/tipc/node.h   |  1 +
 net/tipc/socket.c | 14 ++------------
 3 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 6cc1ae6..89f8ac73 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1254,6 +1254,22 @@ int tipc_node_xmit_skb(struct net *net, struct sk_buff *skb, u32 dnode,
 	return 0;
 }
 
+/* tipc_node_distr_xmit(): send single buffer msgs to individual destinations
+ * Note: this is only for SYSTEM_IMPORTANCE messages, which cannot be rejected
+ */
+int tipc_node_distr_xmit(struct net *net, struct sk_buff_head *xmitq)
+{
+	struct sk_buff *skb;
+	u32 selector, dnode;
+
+	while ((skb = __skb_dequeue(xmitq))) {
+		selector = msg_origport(buf_msg(skb));
+		dnode = msg_destnode(buf_msg(skb));
+		tipc_node_xmit_skb(net, skb, dnode, selector);
+	}
+	return 0;
+}
+
 void tipc_node_broadcast(struct net *net, struct sk_buff *skb)
 {
 	struct sk_buff *txskb;
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 8db59fe..df2f219 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -68,6 +68,7 @@ int tipc_node_get_linkname(struct net *net, u32 bearer_id, u32 node,
 			   char *linkname, size_t len);
 int tipc_node_xmit(struct net *net, struct sk_buff_head *list, u32 dnode,
 		   int selector);
+int tipc_node_distr_xmit(struct net *net, struct sk_buff_head *list);
 int tipc_node_xmit_skb(struct net *net, struct sk_buff *skb, u32 dest,
 		       u32 selector);
 void tipc_node_subscribe(struct net *net, struct list_head *subscr, u32 addr);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 81b7d46c..6b2b4ca 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1740,14 +1740,11 @@ static void tipc_sk_filter_rcv(struct sock *sk, struct sk_buff *skb,
  * @skb: message
  *
  * Caller must hold socket lock
- *
- * Returns 0
  */
 static int tipc_sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	unsigned int before = sk_rmem_alloc_get(sk);
 	struct sk_buff_head xmitq;
-	u32 dnode, selector;
 	unsigned int added;
 
 	__skb_queue_head_init(&xmitq);
@@ -1757,11 +1754,7 @@ static int tipc_sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 	atomic_add(added, &tipc_sk(sk)->dupl_rcvcnt);
 
 	/* Send pending response/rejected messages, if any */
-	while ((skb = __skb_dequeue(&xmitq))) {
-		selector = msg_origport(buf_msg(skb));
-		dnode = msg_destnode(buf_msg(skb));
-		tipc_node_xmit_skb(sock_net(sk), skb, dnode, selector);
-	}
+	tipc_node_distr_xmit(sock_net(sk), &xmitq);
 	return 0;
 }
 
@@ -1840,10 +1833,7 @@ void tipc_sk_rcv(struct net *net, struct sk_buff_head *inputq)
 				spin_unlock_bh(&sk->sk_lock.slock);
 			}
 			/* Send pending response/rejected messages, if any */
-			while ((skb = __skb_dequeue(&xmitq))) {
-				dnode = msg_destnode(buf_msg(skb));
-				tipc_node_xmit_skb(net, skb, dnode, dport);
-			}
+			tipc_node_distr_xmit(sock_net(sk), &xmitq);
 			sock_put(sk);
 			continue;
 		}
-- 
2.1.4
