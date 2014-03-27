From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 07/10] tipc: rename node create
	lock to protect node list and hlist
Date: Thu, 27 Mar 2014 12:54:36 +0800
Message-ID: <1395896080-7926-8-git-send-email-ying.xue@windriver.com>
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

When a node is created, tipc_net_lock read lock is first held and
then node_create_lock is grabbed in order to prevent the same node
from being created and inserted into both node list and hlist twice.
But when we query node from the two node lists, we only hold
tipc_net_lock read lock without grabbing node_create_lock. Obviously
this locking policy is unable to guarantee that the two node lists
are always synchronized especially when the operation of changing
and accessing them occurs in different contexts like currently doing.

Therefore, rename node_create_lock to node_list_lock to protect the
two node lists, that is, whenever node is inserted into them or node
is queried from them, the node_list_lock should be always held. As a
result, tipc_net_lock read lock becomes redundant and then can be
removed from the node query functions.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/net.c  |    7 +++----
 net/tipc/node.c |   59 ++++++++++++++++++++++++++++---------------------------
 net/tipc/node.h |    4 ++--
 3 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index bb171c3..0374a81 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -189,15 +189,14 @@ void tipc_net_start(u32 addr)
 
 void tipc_net_stop(void)
 {
-	struct tipc_node *node, *t_node;
-
 	if (!tipc_own_addr)
 		return;
+
 	write_lock_bh(&tipc_net_lock);
 	tipc_bearer_stop();
 	tipc_bclink_stop();
-	list_for_each_entry_safe(node, t_node, &tipc_node_list, list)
-		tipc_node_delete(node);
+	tipc_node_stop();
 	write_unlock_bh(&tipc_net_lock);
+
 	pr_info("Left network mode\n");
 }
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 7c9b667..ec83607 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -2,7 +2,7 @@
  * net/tipc/node.c: TIPC node management routines
  *
  * Copyright (c) 2000-2006, 2012 Ericsson AB
- * Copyright (c) 2005-2006, 2010-2011, Wind River Systems
+ * Copyright (c) 2005-2006, 2010-2014, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -44,11 +44,10 @@
 static void node_lost_contact(struct tipc_node *n_ptr);
 static void node_established_contact(struct tipc_node *n_ptr);
 
-static DEFINE_SPINLOCK(node_create_lock);
-
 static struct hlist_head node_htable[NODE_HTABLE_SIZE];
 LIST_HEAD(tipc_node_list);
 static u32 tipc_num_nodes;
+static DEFINE_SPINLOCK(node_list_lock);
 
 static atomic_t tipc_num_links = ATOMIC_INIT(0);
 
@@ -73,31 +72,26 @@ struct tipc_node *tipc_node_find(u32 addr)
 	if (unlikely(!in_own_cluster_exact(addr)))
 		return NULL;
 
+	spin_lock_bh(&node_list_lock);
 	hlist_for_each_entry(node, &node_htable[tipc_hashfn(addr)], hash) {
-		if (node->addr == addr)
+		if (node->addr == addr) {
+			spin_unlock_bh(&node_list_lock);
 			return node;
+		}
 	}
+	spin_unlock_bh(&node_list_lock);
 	return NULL;
 }
 
-/**
- * tipc_node_create - create neighboring node
- *
- * Currently, this routine is called by neighbor discovery code, which holds
- * net_lock for reading only.  We must take node_create_lock to ensure a node
- * isn't created twice if two different bearers discover the node at the same
- * time.  (It would be preferable to switch to holding net_lock in write mode,
- * but this is a non-trivial change.)
- */
 struct tipc_node *tipc_node_create(u32 addr)
 {
 	struct tipc_node *n_ptr, *temp_node;
 
-	spin_lock_bh(&node_create_lock);
+	spin_lock_bh(&node_list_lock);
 
 	n_ptr = kzalloc(sizeof(*n_ptr), GFP_ATOMIC);
 	if (!n_ptr) {
-		spin_unlock_bh(&node_create_lock);
+		spin_unlock_bh(&node_list_lock);
 		pr_warn("Node creation failed, no memory\n");
 		return NULL;
 	}
@@ -120,11 +114,11 @@ struct tipc_node *tipc_node_create(u32 addr)
 
 	tipc_num_nodes++;
 
-	spin_unlock_bh(&node_create_lock);
+	spin_unlock_bh(&node_list_lock);
 	return n_ptr;
 }
 
-void tipc_node_delete(struct tipc_node *n_ptr)
+static void tipc_node_delete(struct tipc_node *n_ptr)
 {
 	list_del(&n_ptr->list);
 	hlist_del(&n_ptr->hash);
@@ -133,6 +127,16 @@ void tipc_node_delete(struct tipc_node *n_ptr)
 	tipc_num_nodes--;
 }
 
+void tipc_node_stop(void)
+{
+	struct tipc_node *node, *t_node;
+
+	spin_lock_bh(&node_list_lock);
+	list_for_each_entry_safe(node, t_node, &tipc_node_list, list)
+		tipc_node_delete(node);
+	spin_unlock_bh(&node_list_lock);
+}
+
 /**
  * tipc_node_link_up - handle addition of link
  *
@@ -335,22 +339,22 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (network address)");
 
-	read_lock_bh(&tipc_net_lock);
+	spin_lock_bh(&node_list_lock);
 	if (!tipc_num_nodes) {
-		read_unlock_bh(&tipc_net_lock);
+		spin_unlock_bh(&node_list_lock);
 		return tipc_cfg_reply_none();
 	}
 
 	/* For now, get space for all other nodes */
 	payload_size = TLV_SPACE(sizeof(node_info)) * tipc_num_nodes;
 	if (payload_size > 32768u) {
-		read_unlock_bh(&tipc_net_lock);
+		spin_unlock_bh(&node_list_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (too many nodes)");
 	}
 	buf = tipc_cfg_reply_alloc(payload_size);
 	if (!buf) {
-		read_unlock_bh(&tipc_net_lock);
+		spin_unlock_bh(&node_list_lock);
 		return NULL;
 	}
 
@@ -363,8 +367,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 		tipc_cfg_append_tlv(buf, TIPC_TLV_NODE_INFO,
 				    &node_info, sizeof(node_info));
 	}
-
-	read_unlock_bh(&tipc_net_lock);
+	spin_unlock_bh(&node_list_lock);
 	return buf;
 }
 
@@ -387,19 +390,18 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	if (!tipc_own_addr)
 		return tipc_cfg_reply_none();
 
-	read_lock_bh(&tipc_net_lock);
-
+	spin_lock_bh(&node_list_lock);
 	/* Get space for all unicast links + broadcast link */
 	payload_size = TLV_SPACE(sizeof(link_info)) *
 		(atomic_read(&tipc_num_links) + 1);
 	if (payload_size > 32768u) {
-		read_unlock_bh(&tipc_net_lock);
+		spin_unlock_bh(&node_list_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (too many links)");
 	}
 	buf = tipc_cfg_reply_alloc(payload_size);
 	if (!buf) {
-		read_unlock_bh(&tipc_net_lock);
+		spin_unlock_bh(&node_list_lock);
 		return NULL;
 	}
 
@@ -427,7 +429,6 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 		}
 		tipc_node_unlock(n_ptr);
 	}
-
-	read_unlock_bh(&tipc_net_lock);
+	spin_unlock_bh(&node_list_lock);
 	return buf;
 }
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 63e2e8e..4203869 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -2,7 +2,7 @@
  * net/tipc/node.h: Include file for TIPC node management routines
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005, 2010-2011, Wind River Systems
+ * Copyright (c) 2005, 2010-2014, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -107,7 +107,7 @@ extern struct list_head tipc_node_list;
 
 struct tipc_node *tipc_node_find(u32 addr);
 struct tipc_node *tipc_node_create(u32 addr);
-void tipc_node_delete(struct tipc_node *n_ptr);
+void tipc_node_stop(void);
 void tipc_node_attach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
-- 
1.7.9.5


------------------------------------------------------------------------------
