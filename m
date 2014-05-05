From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 04/10] tipc: avoid to asynchronously notify subscriptions
Date: Mon, 5 May 2014 08:56:12 +0800
Message-ID: <1399251378-23842-5-git-send-email-ying.xue@windriver.com>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59966 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbaEEA4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:46 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Postpone the actions of notifying subscriptions until after node lock
is released, avoiding to asynchronously execute registered handlers
when node is lost.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c        |   23 +++++++++++++++++++++--
 net/tipc/node.h        |   15 +++++++--------
 net/tipc/node_subscr.c |    9 ++++-----
 net/tipc/node_subscr.h |    2 +-
 4 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 2b0a084..befbcc9 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -321,10 +321,10 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	}
 
 	/* Notify subscribers */
-	tipc_nodesub_notify(n_ptr);
+	n_ptr->flags = TIPC_NODE_LOST;
 
 	/* Prevent re-contact with node until cleanup is done */
-	n_ptr->flags = TIPC_NODE_DOWN | TIPC_NAMES_GONE;
+	n_ptr->flags |= TIPC_NODE_DOWN | TIPC_NAMES_GONE;
 	tipc_k_signal((Handler)node_name_purge_complete, n_ptr->addr);
 }
 
@@ -465,3 +465,22 @@ int tipc_node_get_linkname(u32 bearer_id, u32 addr, char *linkname, size_t len)
 	tipc_node_unlock(node);
 	return -EINVAL;
 }
+
+void tipc_node_unlock(struct tipc_node *node)
+{
+	LIST_HEAD(nsub_list);
+
+	if (likely(!node->flags)) {
+		spin_unlock_bh(&node->lock);
+		return;
+	}
+
+	if (node->flags & TIPC_NODE_LOST) {
+		list_replace_init(&node->nsub, &nsub_list);
+		node->flags &= ~TIPC_NODE_LOST;
+	}
+	spin_unlock_bh(&node->lock);
+
+	if (!list_empty(&nsub_list))
+		tipc_nodesub_notify(&nsub_list);
+}
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 242b918..fd86726 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -51,11 +51,14 @@
  * TIPC_NODE_DOWN: indicate node is down
  * TIPC_NAMES_GONE: indicate the node's publications are purged
  * TIPC_NODE_RESET: indicate node is reset
+ * TIPC_NODE_LOST: indicate node is lost and it's used to notify subscriptions
+ *                 when node lock is released
  */
 enum {
 	TIPC_NODE_DOWN	= (1 << 1),
 	TIPC_NAMES_GONE	= (1 << 2),
-	TIPC_NODE_RESET	= (1 << 3)
+	TIPC_NODE_RESET	= (1 << 3),
+	TIPC_NODE_LOST	= (1 << 4)
 };
 
 /**
@@ -130,15 +133,11 @@ int tipc_node_is_up(struct tipc_node *n_ptr);
 struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space);
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space);
 int tipc_node_get_linkname(u32 bearer_id, u32 node, char *linkname, size_t len);
+void tipc_node_unlock(struct tipc_node *node);
 
-static inline void tipc_node_lock(struct tipc_node *n_ptr)
+static inline void tipc_node_lock(struct tipc_node *node)
 {
-	spin_lock_bh(&n_ptr->lock);
-}
-
-static inline void tipc_node_unlock(struct tipc_node *n_ptr)
-{
-	spin_unlock_bh(&n_ptr->lock);
+	spin_lock_bh(&node->lock);
 }
 
 static inline bool tipc_node_blocked(struct tipc_node *node)
diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
index 8a7384c..7c59ab1 100644
--- a/net/tipc/node_subscr.c
+++ b/net/tipc/node_subscr.c
@@ -81,14 +81,13 @@ void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub)
  *
  * Note: node is locked by caller
  */
-void tipc_nodesub_notify(struct tipc_node *node)
+void tipc_nodesub_notify(struct list_head *nsub_list)
 {
-	struct tipc_node_subscr *ns;
+	struct tipc_node_subscr *ns, *safe;
 
-	list_for_each_entry(ns, &node->nsub, nodesub_list) {
+	list_for_each_entry_safe(ns, safe, nsub_list, nodesub_list) {
 		if (ns->handle_node_down) {
-			tipc_k_signal((Handler)ns->handle_node_down,
-				      (unsigned long)ns->usr_handle);
+			ns->handle_node_down(ns->usr_handle);
 			ns->handle_node_down = NULL;
 		}
 	}
diff --git a/net/tipc/node_subscr.h b/net/tipc/node_subscr.h
index c95d207..d91b8cc 100644
--- a/net/tipc/node_subscr.h
+++ b/net/tipc/node_subscr.h
@@ -58,6 +58,6 @@ struct tipc_node_subscr {
 void tipc_nodesub_subscribe(struct tipc_node_subscr *node_sub, u32 addr,
 			    void *usr_handle, net_ev_handler handle_down);
 void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub);
-void tipc_nodesub_notify(struct tipc_node *node);
+void tipc_nodesub_notify(struct list_head *nsub_list);
 
 #endif
-- 
1.7.9.5
