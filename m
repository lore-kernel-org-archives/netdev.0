From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 2/2] tipc: involve reference
	counter for node structure
Date: Thu, 26 Mar 2015 18:10:24 +0800
Message-ID: <1427364624-5930-3-git-send-email-ying.xue@windriver.com>
References: <1427364624-5930-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1427364624-5930-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

TIPC node hash node table is protected with rcu lock on read side.
tipc_node_find() is used to look for a node object with node address
through iterating the hash node table. As the entire process of what
tipc_node_find() traverses the table is guarded with rcu read lock,
it's safe for us. However, when callers use the node object returned
by tipc_node_find(), there is no rcu read lock applied. Therefore,
this is absolutely unsafe for callers of tipc_node_find().

Now we introduce a reference counter for node structure. Before
tipc_node_find() returns node object to its caller, it first increases
the reference counter. Accordingly, after its caller used it up,
it decreases the counter again. This can prevent a node being used by
one thread from being freed by another thread.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c      |    5 +--
 net/tipc/discover.c   |    1 +
 net/tipc/link.c       |    7 ++--
 net/tipc/name_distr.c |    2 ++
 net/tipc/node.c       |   85 +++++++++++++++++++++++++++++++++++--------------
 net/tipc/node.h       |    9 ++++--
 6 files changed, 79 insertions(+), 30 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 4289dd6..ae558dd 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -329,13 +329,12 @@ static void bclink_peek_nack(struct net *net, struct tipc_msg *msg)
 		return;
 
 	tipc_node_lock(n_ptr);
-
 	if (n_ptr->bclink.recv_permitted &&
 	    (n_ptr->bclink.last_in != n_ptr->bclink.last_sent) &&
 	    (n_ptr->bclink.last_in == msg_bcgap_after(msg)))
 		n_ptr->bclink.oos_state = 2;
-
 	tipc_node_unlock(n_ptr);
+	tipc_node_put(n_ptr);
 }
 
 /* tipc_bclink_xmit - deliver buffer chain to all nodes in cluster
@@ -466,6 +465,7 @@ void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 			tipc_node_unlock(node);
 			bclink_peek_nack(net, msg);
 		}
+		tipc_node_put(node);
 		goto exit;
 	}
 
@@ -570,6 +570,7 @@ receive:
 
 unlock:
 	tipc_node_unlock(node);
+	tipc_node_put(node);
 exit:
 	kfree_skb(buf);
 }
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 169f3dd..967e292 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -260,6 +260,7 @@ void tipc_disc_rcv(struct net *net, struct sk_buff *buf,
 		}
 	}
 	tipc_node_unlock(node);
+	tipc_node_put(node);
 }
 
 /**
diff --git a/net/tipc/link.c b/net/tipc/link.c
index f5e086c..514466e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -854,6 +854,7 @@ int tipc_link_xmit(struct net *net, struct sk_buff_head *list, u32 dnode,
 		if (link)
 			rc = __tipc_link_xmit(net, link, list);
 		tipc_node_unlock(node);
+		tipc_node_put(node);
 	}
 	if (link)
 		return rc;
@@ -1116,8 +1117,8 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		n_ptr = tipc_node_find(net, msg_prevnode(msg));
 		if (unlikely(!n_ptr))
 			goto discard;
-		tipc_node_lock(n_ptr);
 
+		tipc_node_lock(n_ptr);
 		/* Locate unicast link endpoint that should handle message */
 		l_ptr = n_ptr->links[b_ptr->identity];
 		if (unlikely(!l_ptr))
@@ -1205,6 +1206,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		skb = NULL;
 unlock:
 		tipc_node_unlock(n_ptr);
+		tipc_node_put(n_ptr);
 discard:
 		if (unlikely(skb))
 			kfree_skb(skb);
@@ -2236,7 +2238,6 @@ int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	msg.seq = cb->nlh->nlmsg_seq;
 
 	rcu_read_lock();
-
 	if (prev_node) {
 		node = tipc_node_find(net, prev_node);
 		if (!node) {
@@ -2249,6 +2250,7 @@ int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			cb->prev_seq = 1;
 			goto out;
 		}
+		tipc_node_put(node);
 
 		list_for_each_entry_continue_rcu(node, &tn->node_list,
 						 list) {
@@ -2256,6 +2258,7 @@ int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			err = __tipc_nl_add_node_links(net, &msg, node,
 						       &prev_link);
 			tipc_node_unlock(node);
+			tipc_node_put(node);
 			if (err)
 				goto out;
 
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 506aaa5..41e7b7e 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -244,6 +244,7 @@ static void tipc_publ_subscribe(struct net *net, struct publication *publ,
 	tipc_node_lock(node);
 	list_add_tail(&publ->nodesub_list, &node->publ_list);
 	tipc_node_unlock(node);
+	tipc_node_put(node);
 }
 
 static void tipc_publ_unsubscribe(struct net *net, struct publication *publ,
@@ -258,6 +259,7 @@ static void tipc_publ_unsubscribe(struct net *net, struct publication *publ,
 	tipc_node_lock(node);
 	list_del_init(&publ->nodesub_list);
 	tipc_node_unlock(node);
+	tipc_node_put(node);
 }
 
 /**
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 5cc43d3..3e4f048 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -42,6 +42,7 @@
 
 static void node_lost_contact(struct tipc_node *n_ptr);
 static void node_established_contact(struct tipc_node *n_ptr);
+static void tipc_node_delete(struct tipc_node *node);
 
 struct tipc_sock_conn {
 	u32 port;
@@ -67,6 +68,23 @@ static unsigned int tipc_hashfn(u32 addr)
 	return addr & (NODE_HTABLE_SIZE - 1);
 }
 
+static void tipc_node_kref_release(struct kref *kref)
+{
+	struct tipc_node *node = container_of(kref, struct tipc_node, kref);
+
+	tipc_node_delete(node);
+}
+
+void tipc_node_put(struct tipc_node *node)
+{
+	kref_put(&node->kref, tipc_node_kref_release);
+}
+
+static void tipc_node_get(struct tipc_node *node)
+{
+	kref_get(&node->kref);
+}
+
 /*
  * tipc_node_find - locate specified node object, if it exists
  */
@@ -82,6 +100,7 @@ struct tipc_node *tipc_node_find(struct net *net, u32 addr)
 	hlist_for_each_entry_rcu(node, &tn->node_htable[tipc_hashfn(addr)],
 				 hash) {
 		if (node->addr == addr) {
+			tipc_node_get(node);
 			rcu_read_unlock();
 			return node;
 		}
@@ -106,6 +125,7 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr)
 	}
 	n_ptr->addr = addr;
 	n_ptr->net = net;
+	kref_init(&n_ptr->kref);
 	spin_lock_init(&n_ptr->lock);
 	INIT_HLIST_NODE(&n_ptr->hash);
 	INIT_LIST_HEAD(&n_ptr->list);
@@ -120,16 +140,17 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr)
 	list_add_tail_rcu(&n_ptr->list, &temp_node->list);
 	n_ptr->action_flags = TIPC_WAIT_PEER_LINKS_DOWN;
 	n_ptr->signature = INVALID_NODE_SIG;
+	tipc_node_get(n_ptr);
 exit:
 	spin_unlock_bh(&tn->node_list_lock);
 	return n_ptr;
 }
 
-static void tipc_node_delete(struct tipc_net *tn, struct tipc_node *n_ptr)
+static void tipc_node_delete(struct tipc_node *node)
 {
-	list_del_rcu(&n_ptr->list);
-	hlist_del_rcu(&n_ptr->hash);
-	kfree_rcu(n_ptr, rcu);
+	list_del_rcu(&node->list);
+	hlist_del_rcu(&node->hash);
+	kfree_rcu(node, rcu);
 }
 
 void tipc_node_stop(struct net *net)
@@ -139,7 +160,7 @@ void tipc_node_stop(struct net *net)
 
 	spin_lock_bh(&tn->node_list_lock);
 	list_for_each_entry_safe(node, t_node, &tn->node_list, list)
-		tipc_node_delete(tn, node);
+		tipc_node_put(node);
 	spin_unlock_bh(&tn->node_list_lock);
 }
 
@@ -147,6 +168,7 @@ int tipc_node_add_conn(struct net *net, u32 dnode, u32 port, u32 peer_port)
 {
 	struct tipc_node *node;
 	struct tipc_sock_conn *conn;
+	int err = 0;
 
 	if (in_own_node(net, dnode))
 		return 0;
@@ -157,8 +179,10 @@ int tipc_node_add_conn(struct net *net, u32 dnode, u32 port, u32 peer_port)
 		return -EHOSTUNREACH;
 	}
 	conn = kmalloc(sizeof(*conn), GFP_ATOMIC);
-	if (!conn)
-		return -EHOSTUNREACH;
+	if (!conn) {
+		err = -EHOSTUNREACH;
+		goto exit;
+	}
 	conn->peer_node = dnode;
 	conn->port = port;
 	conn->peer_port = peer_port;
@@ -166,7 +190,9 @@ int tipc_node_add_conn(struct net *net, u32 dnode, u32 port, u32 peer_port)
 	tipc_node_lock(node);
 	list_add_tail(&conn->list, &node->conn_sks);
 	tipc_node_unlock(node);
-	return 0;
+exit:
+	tipc_node_put(node);
+	return err;
 }
 
 void tipc_node_remove_conn(struct net *net, u32 dnode, u32 port)
@@ -189,6 +215,7 @@ void tipc_node_remove_conn(struct net *net, u32 dnode, u32 port)
 		kfree(conn);
 	}
 	tipc_node_unlock(node);
+	tipc_node_put(node);
 }
 
 /**
@@ -417,19 +444,25 @@ int tipc_node_get_linkname(struct net *net, u32 bearer_id, u32 addr,
 			   char *linkname, size_t len)
 {
 	struct tipc_link *link;
+	int err = -EINVAL;
 	struct tipc_node *node = tipc_node_find(net, addr);
 
-	if ((bearer_id >= MAX_BEARERS) || !node)
-		return -EINVAL;
+	if (!node)
+		return err;
+
+	if (bearer_id >= MAX_BEARERS)
+		goto exit;
+
 	tipc_node_lock(node);
 	link = node->links[bearer_id];
 	if (link) {
 		strncpy(linkname, link->name, len);
-		tipc_node_unlock(node);
-		return 0;
+		err = 0;
 	}
+exit:
 	tipc_node_unlock(node);
-	return -EINVAL;
+	tipc_node_put(node);
+	return err;
 }
 
 void tipc_node_unlock(struct tipc_node *node)
@@ -545,17 +578,21 @@ int tipc_nl_node_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	msg.seq = cb->nlh->nlmsg_seq;
 
 	rcu_read_lock();
-
-	if (last_addr && !tipc_node_find(net, last_addr)) {
-		rcu_read_unlock();
-		/* We never set seq or call nl_dump_check_consistent() this
-		 * means that setting prev_seq here will cause the consistence
-		 * check to fail in the netlink callback handler. Resulting in
-		 * the NLMSG_DONE message having the NLM_F_DUMP_INTR flag set if
-		 * the node state changed while we released the lock.
-		 */
-		cb->prev_seq = 1;
-		return -EPIPE;
+	if (last_addr) {
+		node = tipc_node_find(net, last_addr);
+		if (!node) {
+			rcu_read_unlock();
+			/* We never set seq or call nl_dump_check_consistent()
+			 * this means that setting prev_seq here will cause the
+			 * consistence check to fail in the netlink callback
+			 * handler. Resulting in the NLMSG_DONE message having
+			 * the NLM_F_DUMP_INTR flag set if the node state
+			 * changed while we released the lock.
+			 */
+			cb->prev_seq = 1;
+			return -EPIPE;
+		}
+		tipc_node_put(node);
 	}
 
 	list_for_each_entry_rcu(node, &tn->node_list, list) {
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 9629ecd..02d5c20 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -94,6 +94,7 @@ struct tipc_node_bclink {
 /**
  * struct tipc_node - TIPC node structure
  * @addr: network address of node
+ * @ref: reference counter to node object
  * @lock: spinlock governing access to structure
  * @net: the applicable net namespace
  * @hash: links to adjacent nodes in unsorted hash chain
@@ -115,6 +116,7 @@ struct tipc_node_bclink {
  */
 struct tipc_node {
 	u32 addr;
+	struct kref kref;
 	spinlock_t lock;
 	struct net *net;
 	struct hlist_node hash;
@@ -137,6 +139,7 @@ struct tipc_node {
 };
 
 struct tipc_node *tipc_node_find(struct net *net, u32 addr);
+void tipc_node_put(struct tipc_node *node);
 struct tipc_node *tipc_node_create(struct net *net, u32 addr);
 void tipc_node_stop(struct net *net);
 void tipc_node_attach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
@@ -171,10 +174,12 @@ static inline uint tipc_node_get_mtu(struct net *net, u32 addr, u32 selector)
 
 	node = tipc_node_find(net, addr);
 
-	if (likely(node))
+	if (likely(node)) {
 		mtu = node->act_mtus[selector & 1];
-	else
+		tipc_node_put(node);
+	} else {
 		mtu = MAX_MSG_SIZE;
+	}
 
 	return mtu;
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
