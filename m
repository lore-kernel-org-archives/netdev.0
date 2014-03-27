From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 08/10] tipc: tipc: convert node
	list and node hlist to RCU lists
Date: Thu, 27 Mar 2014 12:54:37 +0800
Message-ID: <1395896080-7926-9-git-send-email-ying.xue@windriver.com>
References: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Convert tipc_node_list list and node_htable hash list to RCU lists.
On read side, the two lists are protected with RCU read lock, and
on update side, node_list_lock is applied to them.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c       |   16 ++++++++++------
 net/tipc/name_distr.c |    6 +++---
 net/tipc/node.c       |   28 ++++++++++++++++------------
 net/tipc/node.h       |    2 ++
 4 files changed, 31 insertions(+), 21 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 882c5c9..c5190ab 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -280,13 +280,13 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	return l_ptr;
 }
 
-
 void tipc_link_delete_list(unsigned int bearer_id, bool shutting_down)
 {
 	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
 
-	list_for_each_entry(n_ptr, &tipc_node_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
 		spin_lock_bh(&n_ptr->lock);
 		l_ptr = n_ptr->links[bearer_id];
 		if (l_ptr) {
@@ -309,6 +309,7 @@ void tipc_link_delete_list(unsigned int bearer_id, bool shutting_down)
 		}
 		spin_unlock_bh(&n_ptr->lock);
 	}
+	rcu_read_unlock();
 }
 
 /**
@@ -461,13 +462,15 @@ void tipc_link_reset_list(unsigned int bearer_id)
 	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
 
-	list_for_each_entry(n_ptr, &tipc_node_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
 		spin_lock_bh(&n_ptr->lock);
 		l_ptr = n_ptr->links[bearer_id];
 		if (l_ptr)
 			tipc_link_reset(l_ptr);
 		spin_unlock_bh(&n_ptr->lock);
 	}
+	rcu_read_unlock();
 }
 
 static void link_activate(struct tipc_link *l_ptr)
@@ -2404,13 +2407,12 @@ static struct tipc_node *tipc_link_find_owner(const char *link_name,
 {
 	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
-	struct tipc_node *tmp_n_ptr;
 	struct tipc_node *found_node = 0;
-
 	int i;
 
 	*bearer_id = 0;
-	list_for_each_entry_safe(n_ptr, tmp_n_ptr, &tipc_node_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
 		tipc_node_lock(n_ptr);
 		for (i = 0; i < MAX_BEARERS; i++) {
 			l_ptr = n_ptr->links[i];
@@ -2424,6 +2426,8 @@ static struct tipc_node *tipc_link_find_owner(const char *link_name,
 		if (found_node)
 			break;
 	}
+	rcu_read_unlock();
+
 	return found_node;
 }
 
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index c5904d1..aff8041 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -133,8 +133,8 @@ static void named_cluster_distribute(struct sk_buff *buf)
 	struct tipc_node *n_ptr;
 	struct tipc_link *l_ptr;
 
-	read_lock_bh(&tipc_net_lock);
-	list_for_each_entry(n_ptr, &tipc_node_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
 		spin_lock_bh(&n_ptr->lock);
 		l_ptr = n_ptr->active_links[n_ptr->addr & 1];
 		if (l_ptr) {
@@ -148,7 +148,7 @@ static void named_cluster_distribute(struct sk_buff *buf)
 		}
 		spin_unlock_bh(&n_ptr->lock);
 	}
-	read_unlock_bh(&tipc_net_lock);
+	rcu_read_unlock();
 
 	kfree_skb(buf);
 }
diff --git a/net/tipc/node.c b/net/tipc/node.c
index ec83607..4f517ff 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -72,14 +72,14 @@ struct tipc_node *tipc_node_find(u32 addr)
 	if (unlikely(!in_own_cluster_exact(addr)))
 		return NULL;
 
-	spin_lock_bh(&node_list_lock);
-	hlist_for_each_entry(node, &node_htable[tipc_hashfn(addr)], hash) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(node, &node_htable[tipc_hashfn(addr)], hash) {
 		if (node->addr == addr) {
-			spin_unlock_bh(&node_list_lock);
+			rcu_read_unlock();
 			return node;
 		}
 	}
-	spin_unlock_bh(&node_list_lock);
+	rcu_read_unlock();
 	return NULL;
 }
 
@@ -102,13 +102,13 @@ struct tipc_node *tipc_node_create(u32 addr)
 	INIT_LIST_HEAD(&n_ptr->list);
 	INIT_LIST_HEAD(&n_ptr->nsub);
 
-	hlist_add_head(&n_ptr->hash, &node_htable[tipc_hashfn(addr)]);
+	hlist_add_head_rcu(&n_ptr->hash, &node_htable[tipc_hashfn(addr)]);
 
-	list_for_each_entry(temp_node, &tipc_node_list, list) {
+	list_for_each_entry_rcu(temp_node, &tipc_node_list, list) {
 		if (n_ptr->addr < temp_node->addr)
 			break;
 	}
-	list_add_tail(&n_ptr->list, &temp_node->list);
+	list_add_tail_rcu(&n_ptr->list, &temp_node->list);
 	n_ptr->block_setup = WAIT_PEER_DOWN;
 	n_ptr->signature = INVALID_NODE_SIG;
 
@@ -120,9 +120,9 @@ struct tipc_node *tipc_node_create(u32 addr)
 
 static void tipc_node_delete(struct tipc_node *n_ptr)
 {
-	list_del(&n_ptr->list);
-	hlist_del(&n_ptr->hash);
-	kfree(n_ptr);
+	list_del_rcu(&n_ptr->list);
+	hlist_del_rcu(&n_ptr->hash);
+	kfree_rcu(n_ptr, rcu);
 
 	tipc_num_nodes--;
 }
@@ -359,7 +359,8 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 	}
 
 	/* Add TLVs for all nodes in scope */
-	list_for_each_entry(n_ptr, &tipc_node_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
 		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		node_info.addr = htonl(n_ptr->addr);
@@ -367,6 +368,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 		tipc_cfg_append_tlv(buf, TIPC_TLV_NODE_INFO,
 				    &node_info, sizeof(node_info));
 	}
+	rcu_read_unlock();
 	spin_unlock_bh(&node_list_lock);
 	return buf;
 }
@@ -412,7 +414,8 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO, &link_info, sizeof(link_info));
 
 	/* Add TLVs for any other links in scope */
-	list_for_each_entry(n_ptr, &tipc_node_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
 		u32 i;
 
 		if (!tipc_in_scope(domain, n_ptr->addr))
@@ -429,6 +432,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 		}
 		tipc_node_unlock(n_ptr);
 	}
+	rcu_read_unlock();
 	spin_unlock_bh(&node_list_lock);
 	return buf;
 }
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 4203869..7cbb8ce 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -66,6 +66,7 @@
  * @link_cnt: number of links to node
  * @signature: node instance identifier
  * @bclink: broadcast-related info
+ * @rcu: rcu struct for tipc_node
  *    @acked: sequence # of last outbound b'cast message acknowledged by node
  *    @last_in: sequence # of last in-sequence b'cast message received from node
  *    @last_sent: sequence # of last b'cast message sent by node
@@ -89,6 +90,7 @@ struct tipc_node {
 	int working_links;
 	int block_setup;
 	u32 signature;
+	struct rcu_head rcu;
 	struct {
 		u32 acked;
 		u32 last_in;
-- 
1.7.9.5


------------------------------------------------------------------------------
