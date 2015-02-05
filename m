From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 9/9] tipc: eliminate race
	condition at multicast reception
Date: Thu,  5 Feb 2015 08:36:44 -0500
Message-ID: <1423143404-23322-10-git-send-email-jon.maloy@ericsson.com>
References: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In a previous commit in this series we resolved a race problem during
unicast message reception.

Here, we resolve the same problem at multicast reception. We apply the
same technique: an input queue serializing the delivery of arriving
buffers. The main difference is that here we do it in two steps.
First, the broadcast link feeds arriving buffers into the tail of an
arrival queue, which head is consumed at the socket level, and where
destination lookup is performed. Second, if the lookup is successful,
the resulting buffer clones are fed into a second queue, the input
queue. This queue is consumed at reception in the socket just like
in the unicast case. Both queues are protected by the same lock, -the
one of the input queue.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c      | 57 ++++++++++++++++++++++++----------------
 net/tipc/bcast.h      |  3 +++
 net/tipc/msg.h        | 17 ++++++++++++
 net/tipc/name_table.h |  2 +-
 net/tipc/node.c       | 11 +++++---
 net/tipc/node.h       |  7 +++--
 net/tipc/socket.c     | 72 +++++++++++++++++++++++++++++++--------------------
 net/tipc/socket.h     |  4 +--
 8 files changed, 114 insertions(+), 59 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 3eaa931..81b1fef 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -79,6 +79,13 @@ static void tipc_bclink_unlock(struct net *net)
 		tipc_link_reset_all(node);
 }
 
+void tipc_bclink_input(struct net *net)
+{
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	tipc_sk_mcast_rcv(net, &tn->bclink->arrvq, &tn->bclink->inputq);
+}
+
 uint  tipc_bclink_get_mtu(void)
 {
 	return MAX_PKT_DEFAULT_MCAST;
@@ -356,7 +363,7 @@ static void bclink_peek_nack(struct net *net, struct tipc_msg *msg)
 	tipc_node_unlock(n_ptr);
 }
 
-/* tipc_bclink_xmit - broadcast buffer chain to all nodes in cluster
+/* tipc_bclink_xmit - deliver buffer chain to all nodes in cluster
  *                    and to identified node local sockets
  * @net: the applicable net namespace
  * @list: chain of buffers containing message
@@ -371,6 +378,8 @@ int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list)
 	int rc = 0;
 	int bc = 0;
 	struct sk_buff *skb;
+	struct sk_buff_head arrvq;
+	struct sk_buff_head inputq;
 
 	/* Prepare clone of message for local node */
 	skb = tipc_msg_reassemble(list);
@@ -379,7 +388,7 @@ int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list)
 		return -EHOSTUNREACH;
 	}
 
-	/* Broadcast to all other nodes */
+	/* Broadcast to all nodes */
 	if (likely(bclink)) {
 		tipc_bclink_lock(net);
 		if (likely(bclink->bcast_nodes.count)) {
@@ -399,12 +408,15 @@ int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list)
 	if (unlikely(!bc))
 		__skb_queue_purge(list);
 
-	/* Deliver message clone */
-	if (likely(!rc))
-		tipc_sk_mcast_rcv(net, skb);
-	else
+	if (unlikely(rc)) {
 		kfree_skb(skb);
-
+		return rc;
+	}
+	/* Deliver message clone */
+	__skb_queue_head_init(&arrvq);
+	skb_queue_head_init(&inputq);
+	__skb_queue_tail(&arrvq, skb);
+	tipc_sk_mcast_rcv(net, &arrvq, &inputq);
 	return rc;
 }
 
@@ -449,7 +461,7 @@ void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 	int deferred = 0;
 	int pos = 0;
 	struct sk_buff *iskb;
-	struct sk_buff_head msgs;
+	struct sk_buff_head *arrvq, *inputq;
 
 	/* Screen out unwanted broadcast messages */
 	if (msg_mc_netid(msg) != tn->net_id)
@@ -486,6 +498,8 @@ void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 	/* Handle in-sequence broadcast message */
 	seqno = msg_seqno(msg);
 	next_in = mod(node->bclink.last_in + 1);
+	arrvq = &tn->bclink->arrvq;
+	inputq = &tn->bclink->inputq;
 
 	if (likely(seqno == next_in)) {
 receive:
@@ -493,21 +507,26 @@ receive:
 		if (likely(msg_isdata(msg))) {
 			tipc_bclink_lock(net);
 			bclink_accept_pkt(node, seqno);
+			spin_lock_bh(&inputq->lock);
+			__skb_queue_tail(arrvq, buf);
+			spin_unlock_bh(&inputq->lock);
+			node->action_flags |= TIPC_BCAST_MSG_EVT;
 			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
-			if (likely(msg_mcast(msg)))
-				tipc_sk_mcast_rcv(net, buf);
-			else
-				kfree_skb(buf);
 		} else if (msg_user(msg) == MSG_BUNDLER) {
 			tipc_bclink_lock(net);
 			bclink_accept_pkt(node, seqno);
 			bcl->stats.recv_bundles++;
 			bcl->stats.recv_bundled += msg_msgcnt(msg);
+			pos = 0;
+			while (tipc_msg_extract(buf, &iskb, &pos)) {
+				spin_lock_bh(&inputq->lock);
+				__skb_queue_tail(arrvq, iskb);
+				spin_unlock_bh(&inputq->lock);
+			}
+			node->action_flags |= TIPC_BCAST_MSG_EVT;
 			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
-			while (tipc_msg_extract(buf, &iskb, &pos))
-				tipc_sk_mcast_rcv(net, iskb);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
 			tipc_buf_append(&node->bclink.reasm_buf, &buf);
 			if (unlikely(!buf && !node->bclink.reasm_buf))
@@ -523,14 +542,6 @@ receive:
 			}
 			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
-		} else if (msg_user(msg) == NAME_DISTRIBUTOR) {
-			tipc_bclink_lock(net);
-			bclink_accept_pkt(node, seqno);
-			tipc_bclink_unlock(net);
-			tipc_node_unlock(node);
-			skb_queue_head_init(&msgs);
-			skb_queue_tail(&msgs, buf);
-			tipc_named_rcv(net, &msgs);
 		} else {
 			tipc_bclink_lock(net);
 			bclink_accept_pkt(node, seqno);
@@ -950,6 +961,8 @@ int tipc_bclink_init(struct net *net)
 	skb_queue_head_init(&bcl->wakeupq);
 	bcl->next_out_no = 1;
 	spin_lock_init(&bclink->node.lock);
+	__skb_queue_head_init(&bclink->arrvq);
+	skb_queue_head_init(&bclink->inputq);
 	bcl->owner = &bclink->node;
 	bcl->owner->net = net;
 	bcl->max_pkt = MAX_PKT_DEFAULT_MCAST;
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 8f4d4dc..a910c0b 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -97,6 +97,8 @@ struct tipc_bclink {
 	struct tipc_link link;
 	struct tipc_node node;
 	unsigned int flags;
+	struct sk_buff_head arrvq;
+	struct sk_buff_head inputq;
 	struct tipc_node_map bcast_nodes;
 	struct tipc_node *retransmit_to;
 };
@@ -134,5 +136,6 @@ uint  tipc_bclink_get_mtu(void);
 int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list);
 void tipc_bclink_wakeup_users(struct net *net);
 int tipc_nl_add_bc_link(struct net *net, struct tipc_nl_msg *msg);
+void tipc_bclink_input(struct net *net);
 
 #endif
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index ab46726..9ace47f 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -767,6 +767,23 @@ bool tipc_msg_lookup_dest(struct net *net, struct sk_buff *skb, u32 *dnode,
 			  int *err);
 struct sk_buff *tipc_msg_reassemble(struct sk_buff_head *list);
 
+/* tipc_skb_peek(): peek and reserve first buffer in list
+ * @list: list to be peeked in
+ * Returns pointer to first buffer in list, if any
+ */
+static inline struct sk_buff *tipc_skb_peek(struct sk_buff_head *list,
+					    spinlock_t *lock)
+{
+	struct sk_buff *skb;
+
+	spin_lock_bh(lock);
+	skb = skb_peek(list);
+	if (skb)
+		skb_get(skb);
+	spin_unlock_bh(lock);
+	return skb;
+}
+
 /* tipc_skb_peek_port(): find a destination port, ignoring all destinations
  *                       up to and including 'filter'.
  * Note: ignoring previously tried destinations minimizes the risk of
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index 52501fd..0304ddc 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/name_table.h: Include file for TIPC name table code
  *
- * Copyright (c) 2000-2006, 2014, Ericsson AB
+ * Copyright (c) 2000-2006, 2014-2015, Ericsson AB
  * Copyright (c) 2004-2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
diff --git a/net/tipc/node.c b/net/tipc/node.c
index c7fdf3d..5230849 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -582,10 +582,10 @@ void tipc_node_unlock(struct tipc_node *node)
 	namedq = node->namedq;
 	publ_list = &node->publ_list;
 
-	node->action_flags &= ~(TIPC_MSG_EVT | TIPC_NOTIFY_NODE_DOWN |
-				TIPC_NOTIFY_NODE_UP | TIPC_NOTIFY_LINK_UP |
-				TIPC_NOTIFY_LINK_DOWN |
-				TIPC_WAKEUP_BCAST_USERS |
+	node->action_flags &= ~(TIPC_MSG_EVT |
+				TIPC_NOTIFY_NODE_DOWN | TIPC_NOTIFY_NODE_UP |
+				TIPC_NOTIFY_LINK_DOWN | TIPC_NOTIFY_LINK_UP |
+				TIPC_WAKEUP_BCAST_USERS | TIPC_BCAST_MSG_EVT |
 				TIPC_NAMED_MSG_EVT);
 
 	spin_unlock_bh(&node->lock);
@@ -612,6 +612,9 @@ void tipc_node_unlock(struct tipc_node *node)
 
 	if (flags & TIPC_NAMED_MSG_EVT)
 		tipc_named_rcv(net, namedq);
+
+	if (flags & TIPC_BCAST_MSG_EVT)
+		tipc_bclink_input(net);
 }
 
 /* Caller should hold node lock for the passed node */
diff --git a/net/tipc/node.h b/net/tipc/node.h
index c2b0fcf..20ec13f 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/node.h: Include file for TIPC node management routines
  *
- * Copyright (c) 2000-2006, 2014, Ericsson AB
+ * Copyright (c) 2000-2006, 2014-2015, Ericsson AB
  * Copyright (c) 2005, 2010-2014, Wind River Systems
  * All rights reserved.
  *
@@ -63,7 +63,8 @@ enum {
 	TIPC_WAKEUP_BCAST_USERS		= (1 << 5),
 	TIPC_NOTIFY_LINK_UP		= (1 << 6),
 	TIPC_NOTIFY_LINK_DOWN		= (1 << 7),
-	TIPC_NAMED_MSG_EVT		= (1 << 8)
+	TIPC_NAMED_MSG_EVT		= (1 << 8),
+	TIPC_BCAST_MSG_EVT		= (1 << 9)
 };
 
 /**
@@ -74,6 +75,7 @@ enum {
  * @oos_state: state tracker for handling OOS b'cast messages
  * @deferred_queue: deferred queue saved OOS b'cast message received from node
  * @reasm_buf: broadcast reassembly queue head from node
+ * @inputq_map: bitmap indicating which inqueues should be kicked
  * @recv_permitted: true if node is allowed to receive b'cast messages
  */
 struct tipc_node_bclink {
@@ -84,6 +86,7 @@ struct tipc_node_bclink {
 	u32 deferred_size;
 	struct sk_buff_head deferred_queue;
 	struct sk_buff *reasm_buf;
+	int inputq_map;
 	bool recv_permitted;
 };
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 26aec84..6666680 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -776,44 +776,60 @@ new_mtu:
 	return rc;
 }
 
-/* tipc_sk_mcast_rcv - Deliver multicast message to all destination sockets
+/**
+ * tipc_sk_mcast_rcv - Deliver multicast messages to all destination sockets
+ * @arrvq: queue with arriving messages, to be cloned after destination lookup
+ * @inputq: queue with cloned messages, delivered to socket after dest lookup
+ *
+ * Multi-threaded: parallel calls with reference to same queues may occur
  */
-void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *skb)
+void tipc_sk_mcast_rcv(struct net *net, struct sk_buff_head *arrvq,
+		       struct sk_buff_head *inputq)
 {
-	struct tipc_msg *msg = buf_msg(skb);
+	struct tipc_msg *msg;
 	struct tipc_plist dports;
-	struct sk_buff *cskb;
 	u32 portid;
 	u32 scope = TIPC_CLUSTER_SCOPE;
-	struct sk_buff_head msgq;
-	uint hsz = skb_headroom(skb) + msg_hdr_sz(msg);
+	struct sk_buff_head tmpq;
+	uint hsz;
+	struct sk_buff *skb, *_skb;
 
-	skb_queue_head_init(&msgq);
+	__skb_queue_head_init(&tmpq);
 	tipc_plist_init(&dports);
 
-	if (in_own_node(net, msg_orignode(msg)))
-		scope = TIPC_NODE_SCOPE;
-
-	if (unlikely(!msg_mcast(msg))) {
-		pr_warn("Received non-multicast msg in multicast\n");
-		goto exit;
-	}
-	/* Create destination port list: */
-	tipc_nametbl_mc_translate(net, msg_nametype(msg), msg_namelower(msg),
-				  msg_nameupper(msg), scope, &dports);
-	portid = tipc_plist_pop(&dports);
-	for (; portid; portid = tipc_plist_pop(&dports)) {
-		cskb = __pskb_copy(skb, hsz, GFP_ATOMIC);
-		if (!cskb) {
-			pr_warn("Failed do clone mcast rcv buffer\n");
-			continue;
+	skb = tipc_skb_peek(arrvq, &inputq->lock);
+	for (; skb; skb = tipc_skb_peek(arrvq, &inputq->lock)) {
+		msg = buf_msg(skb);
+		hsz = skb_headroom(skb) + msg_hdr_sz(msg);
+
+		if (in_own_node(net, msg_orignode(msg)))
+			scope = TIPC_NODE_SCOPE;
+
+		/* Create destination port list and message clones: */
+		tipc_nametbl_mc_translate(net,
+					  msg_nametype(msg), msg_namelower(msg),
+					  msg_nameupper(msg), scope, &dports);
+		portid = tipc_plist_pop(&dports);
+		for (; portid; portid = tipc_plist_pop(&dports)) {
+			_skb = __pskb_copy(skb, hsz, GFP_ATOMIC);
+			if (_skb) {
+				msg_set_destport(buf_msg(_skb), portid);
+				__skb_queue_tail(&tmpq, _skb);
+				continue;
+			}
+			pr_warn("Failed to clone mcast rcv buffer\n");
 		}
-		msg_set_destport(buf_msg(cskb), portid);
-		skb_queue_tail(&msgq, cskb);
+		/* Append to inputq if not already done by other thread */
+		spin_lock_bh(&inputq->lock);
+		if (skb_peek(arrvq) == skb) {
+			skb_queue_splice_tail_init(&tmpq, inputq);
+			kfree_skb(__skb_dequeue(arrvq));
+		}
+		spin_unlock_bh(&inputq->lock);
+		__skb_queue_purge(&tmpq);
+		kfree_skb(skb);
 	}
-	tipc_sk_rcv(net, &msgq);
-exit:
-	kfree_skb(skb);
+	tipc_sk_rcv(net, inputq);
 }
 
 /**
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 95b0159..8be0da7 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -42,7 +42,6 @@
 #define TIPC_FLOWCTRL_WIN        (TIPC_CONNACK_INTV * 2)
 #define TIPC_CONN_OVERLOAD_LIMIT ((TIPC_FLOWCTRL_WIN * 2 + 1) * \
 				  SKB_TRUESIZE(TIPC_MAX_USER_MSG_SIZE))
-
 int tipc_socket_init(void);
 void tipc_socket_stop(void);
 int tipc_sock_create_local(struct net *net, int type, struct socket **res);
@@ -51,7 +50,8 @@ int tipc_sock_accept_local(struct socket *sock, struct socket **newsock,
 			   int flags);
 int tipc_sk_rcv(struct net *net, struct sk_buff_head *inputq);
 struct sk_buff *tipc_sk_socks_show(struct net *net);
-void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf);
+void tipc_sk_mcast_rcv(struct net *net, struct sk_buff_head *arrvq,
+		       struct sk_buff_head *inputq);
 void tipc_sk_reinit(struct net *net);
 int tipc_sk_rht_init(struct net *net);
 void tipc_sk_rht_destroy(struct net *net);
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
