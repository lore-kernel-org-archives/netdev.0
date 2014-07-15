From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/7] tipc: make name table distributor use new send function
Date: Tue, 15 Jul 2014 10:49:51 -0400
Message-ID: <1405435797-30116-2-git-send-email-jon.maloy@ericsson.com>
References: <1405435797-30116-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.biz.mail.ne1.yahoo.com ([98.138.207.14]:33997 "HELO
	smtp107.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752419AbaGOOuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 10:50:03 -0400
In-Reply-To: <1405435797-30116-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a previous commit series ("tipc: new unicast transmission code")
we introduced a new message sending function, tipc_link_xmit2(),
and moved the unicast data users over to use that function. We now
let the internal name table distributor do the same.

The interaction between the name distributor and the node/link
layer also becomes significantly simpler, so we can eliminate
the function tipc_link_names_xmit().

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c       |   41 --------------------------
 net/tipc/link.h       |    1 -
 net/tipc/name_distr.c |   76 ++++++++++++++++++++++++++++---------------------
 net/tipc/name_distr.h |    2 +-
 net/tipc/node.c       |   13 ++-------
 5 files changed, 48 insertions(+), 85 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index a235b24..367b0f5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1033,47 +1033,6 @@ static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf)
 }
 
 /*
- * tipc_link_names_xmit - send name table entries to new neighbor
- *
- * Send routine for bulk delivery of name table messages when contact
- * with a new neighbor occurs. No link congestion checking is performed
- * because name table messages *must* be delivered. The messages must be
- * small enough not to require fragmentation.
- * Called without any locks held.
- */
-void tipc_link_names_xmit(struct list_head *message_list, u32 dest)
-{
-	struct tipc_node *n_ptr;
-	struct tipc_link *l_ptr;
-	struct sk_buff *buf;
-	struct sk_buff *temp_buf;
-
-	if (list_empty(message_list))
-		return;
-
-	n_ptr = tipc_node_find(dest);
-	if (n_ptr) {
-		tipc_node_lock(n_ptr);
-		l_ptr = n_ptr->active_links[0];
-		if (l_ptr) {
-			/* convert circular list to linear list */
-			((struct sk_buff *)message_list->prev)->next = NULL;
-			link_add_chain_to_outqueue(l_ptr,
-				(struct sk_buff *)message_list->next, 0);
-			tipc_link_push_queue(l_ptr);
-			INIT_LIST_HEAD(message_list);
-		}
-		tipc_node_unlock(n_ptr);
-	}
-
-	/* discard the messages if they couldn't be sent */
-	list_for_each_safe(buf, temp_buf, ((struct sk_buff *)message_list)) {
-		list_del((struct list_head *)buf);
-		kfree_skb(buf);
-	}
-}
-
-/*
  * tipc_link_push_packet: Push one unsent packet to the media
  */
 static u32 tipc_link_push_packet(struct tipc_link *l_ptr)
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 227ff81..04a59c5 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -228,7 +228,6 @@ void tipc_link_reset(struct tipc_link *l_ptr);
 void tipc_link_reset_list(unsigned int bearer_id);
 int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector);
 int tipc_link_xmit2(struct sk_buff *buf, u32 dest, u32 selector);
-void tipc_link_names_xmit(struct list_head *message_list, u32 dest);
 int __tipc_link_xmit(struct tipc_link *l_ptr, struct sk_buff *buf);
 int __tipc_link_xmit2(struct tipc_link *link, struct sk_buff *buf);
 int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf);
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 8ce7309..d16f947 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -101,24 +101,22 @@ static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
 
 void named_cluster_distribute(struct sk_buff *buf)
 {
-	struct sk_buff *buf_copy;
-	struct tipc_node *n_ptr;
-	struct tipc_link *l_ptr;
+	struct sk_buff *obuf;
+	struct tipc_node *node;
+	u32 dnode;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
-		tipc_node_lock(n_ptr);
-		l_ptr = n_ptr->active_links[n_ptr->addr & 1];
-		if (l_ptr) {
-			buf_copy = skb_copy(buf, GFP_ATOMIC);
-			if (!buf_copy) {
-				tipc_node_unlock(n_ptr);
-				break;
-			}
-			msg_set_destnode(buf_msg(buf_copy), n_ptr->addr);
-			__tipc_link_xmit(l_ptr, buf_copy);
-		}
-		tipc_node_unlock(n_ptr);
+	list_for_each_entry_rcu(node, &tipc_node_list, list) {
+		dnode = node->addr;
+		if (in_own_node(dnode))
+			continue;
+		if (!tipc_node_active_links(node))
+			continue;
+		obuf = skb_copy(buf, GFP_ATOMIC);
+		if (!obuf)
+			break;
+		msg_set_destnode(buf_msg(obuf), dnode);
+		tipc_link_xmit2(obuf, dnode, dnode);
 	}
 	rcu_read_unlock();
 
@@ -175,34 +173,44 @@ struct sk_buff *tipc_named_withdraw(struct publication *publ)
 	return buf;
 }
 
-/*
+/**
  * named_distribute - prepare name info for bulk distribution to another node
+ * @msg_list: list of messages (buffers) to be returned from this function
+ * @dnode: node to be updated
+ * @pls: linked list of publication items to be packed into buffer chain
  */
-static void named_distribute(struct list_head *message_list, u32 node,
-			     struct publ_list *pls, u32 max_item_buf)
+static void named_distribute(struct list_head *msg_list, u32 dnode,
+			     struct publ_list *pls)
 {
 	struct publication *publ;
 	struct sk_buff *buf = NULL;
 	struct distr_item *item = NULL;
-	u32 left = 0;
-	u32 rest = pls->size * ITEM_SIZE;
+	uint dsz = pls->size * ITEM_SIZE;
+	uint msg_dsz = (tipc_node_get_mtu(dnode, 0) / ITEM_SIZE) * ITEM_SIZE;
+	uint rem = dsz;
+	uint msg_rem = 0;
 
 	list_for_each_entry(publ, &pls->list, local_list) {
+		/* Prepare next buffer: */
 		if (!buf) {
-			left = (rest <= max_item_buf) ? rest : max_item_buf;
-			rest -= left;
-			buf = named_prepare_buf(PUBLICATION, left, node);
+			msg_rem = min_t(uint, rem, msg_dsz);
+			rem -= msg_rem;
+			buf = named_prepare_buf(PUBLICATION, msg_rem, dnode);
 			if (!buf) {
 				pr_warn("Bulk publication failure\n");
 				return;
 			}
 			item = (struct distr_item *)msg_data(buf_msg(buf));
 		}
+
+		/* Pack publication into message: */
 		publ_to_item(item, publ);
 		item++;
-		left -= ITEM_SIZE;
-		if (!left) {
-			list_add_tail((struct list_head *)buf, message_list);
+		msg_rem -= ITEM_SIZE;
+
+		/* Append full buffer to list: */
+		if (!msg_rem) {
+			list_add_tail((struct list_head *)buf, msg_list);
 			buf = NULL;
 		}
 	}
@@ -211,16 +219,20 @@ static void named_distribute(struct list_head *message_list, u32 node,
 /**
  * tipc_named_node_up - tell specified node about all publications by this node
  */
-void tipc_named_node_up(u32 max_item_buf, u32 node)
+void tipc_named_node_up(u32 dnode)
 {
-	LIST_HEAD(message_list);
+	LIST_HEAD(msg_list);
+	struct sk_buff *buf_chain;
 
 	read_lock_bh(&tipc_nametbl_lock);
-	named_distribute(&message_list, node, &publ_cluster, max_item_buf);
-	named_distribute(&message_list, node, &publ_zone, max_item_buf);
+	named_distribute(&msg_list, dnode, &publ_cluster);
+	named_distribute(&msg_list, dnode, &publ_zone);
 	read_unlock_bh(&tipc_nametbl_lock);
 
-	tipc_link_names_xmit(&message_list, node);
+	/* Convert circular list to linear list and send: */
+	buf_chain = (struct sk_buff *)msg_list.next;
+	((struct sk_buff *)msg_list.prev)->next = NULL;
+	tipc_link_xmit2(buf_chain, dnode, dnode);
 }
 
 /**
diff --git a/net/tipc/name_distr.h b/net/tipc/name_distr.h
index b2eed4e..8afe32b 100644
--- a/net/tipc/name_distr.h
+++ b/net/tipc/name_distr.h
@@ -70,7 +70,7 @@ struct distr_item {
 struct sk_buff *tipc_named_publish(struct publication *publ);
 struct sk_buff *tipc_named_withdraw(struct publication *publ);
 void named_cluster_distribute(struct sk_buff *buf);
-void tipc_named_node_up(u32 max_item_buf, u32 node);
+void tipc_named_node_up(u32 dnode);
 void tipc_named_rcv(struct sk_buff *buf);
 void tipc_named_reinit(void);
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index d959343..f706929 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -474,8 +474,6 @@ int tipc_node_get_linkname(u32 bearer_id, u32 addr, char *linkname, size_t len)
 void tipc_node_unlock(struct tipc_node *node)
 {
 	LIST_HEAD(nsub_list);
-	struct tipc_link *link;
-	int pkt_sz = 0;
 	u32 addr = 0;
 
 	if (likely(!node->action_flags)) {
@@ -488,18 +486,13 @@ void tipc_node_unlock(struct tipc_node *node)
 		node->action_flags &= ~TIPC_NOTIFY_NODE_DOWN;
 	}
 	if (node->action_flags & TIPC_NOTIFY_NODE_UP) {
-		link = node->active_links[0];
 		node->action_flags &= ~TIPC_NOTIFY_NODE_UP;
-		if (link) {
-			pkt_sz = ((link->max_pkt - INT_H_SIZE) / ITEM_SIZE) *
-				  ITEM_SIZE;
-			addr = node->addr;
-		}
+		addr = node->addr;
 	}
 	spin_unlock_bh(&node->lock);
 
 	if (!list_empty(&nsub_list))
 		tipc_nodesub_notify(&nsub_list);
-	if (pkt_sz)
-		tipc_named_node_up(pkt_sz, addr);
+	if (addr)
+		tipc_named_node_up(addr);
 }
-- 
1.7.9.5
