From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 06/10] tipc: avoid to asynchronously deliver name tables to peer node
Date: Mon, 5 May 2014 08:56:14 +0800
Message-ID: <1399251378-23842-7-git-send-email-ying.xue@windriver.com>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59969 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754144AbaEEA4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:52 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Postpone the actions of delivering name tables until after node
lock is released, avoiding to do it under asynchronous context.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/name_distr.c |   52 ++-----------------------------------------------
 net/tipc/name_distr.h |   30 +++++++++++++++++++++++++++-
 net/tipc/node.c       |   16 ++++++++++++++-
 net/tipc/node.h       |    8 ++++++--
 4 files changed, 52 insertions(+), 54 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 8465263..8ce7309 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -38,34 +38,6 @@
 #include "link.h"
 #include "name_distr.h"
 
-#define ITEM_SIZE sizeof(struct distr_item)
-
-/**
- * struct distr_item - publication info distributed to other nodes
- * @type: name sequence type
- * @lower: name sequence lower bound
- * @upper: name sequence upper bound
- * @ref: publishing port reference
- * @key: publication key
- *
- * ===> All fields are stored in network byte order. <===
- *
- * First 3 fields identify (name or) name sequence being published.
- * Reference field uniquely identifies port that published name sequence.
- * Key field uniquely identifies publication, in the event a port has
- * multiple publications of the same name sequence.
- *
- * Note: There is no field that identifies the publishing node because it is
- * the same for all items contained within a publication message.
- */
-struct distr_item {
-	__be32 type;
-	__be32 lower;
-	__be32 upper;
-	__be32 ref;
-	__be32 key;
-};
-
 /**
  * struct publ_list - list of publications made by this node
  * @list: circular list of publications
@@ -239,29 +211,9 @@ static void named_distribute(struct list_head *message_list, u32 node,
 /**
  * tipc_named_node_up - tell specified node about all publications by this node
  */
-void tipc_named_node_up(unsigned long nodearg)
+void tipc_named_node_up(u32 max_item_buf, u32 node)
 {
-	struct tipc_node *n_ptr;
-	struct tipc_link *l_ptr;
-	struct list_head message_list;
-	u32 node = (u32)nodearg;
-	u32 max_item_buf = 0;
-
-	/* compute maximum amount of publication data to send per message */
-	n_ptr = tipc_node_find(node);
-	if (n_ptr) {
-		tipc_node_lock(n_ptr);
-		l_ptr = n_ptr->active_links[0];
-		if (l_ptr)
-			max_item_buf = ((l_ptr->max_pkt - INT_H_SIZE) /
-				ITEM_SIZE) * ITEM_SIZE;
-		tipc_node_unlock(n_ptr);
-	}
-	if (!max_item_buf)
-		return;
-
-	/* create list of publication messages, then send them as a unit */
-	INIT_LIST_HEAD(&message_list);
+	LIST_HEAD(message_list);
 
 	read_lock_bh(&tipc_nametbl_lock);
 	named_distribute(&message_list, node, &publ_cluster, max_item_buf);
diff --git a/net/tipc/name_distr.h b/net/tipc/name_distr.h
index 47ff829..b2eed4e 100644
--- a/net/tipc/name_distr.h
+++ b/net/tipc/name_distr.h
@@ -39,10 +39,38 @@
 
 #include "name_table.h"
 
+#define ITEM_SIZE sizeof(struct distr_item)
+
+/**
+ * struct distr_item - publication info distributed to other nodes
+ * @type: name sequence type
+ * @lower: name sequence lower bound
+ * @upper: name sequence upper bound
+ * @ref: publishing port reference
+ * @key: publication key
+ *
+ * ===> All fields are stored in network byte order. <===
+ *
+ * First 3 fields identify (name or) name sequence being published.
+ * Reference field uniquely identifies port that published name sequence.
+ * Key field uniquely identifies publication, in the event a port has
+ * multiple publications of the same name sequence.
+ *
+ * Note: There is no field that identifies the publishing node because it is
+ * the same for all items contained within a publication message.
+ */
+struct distr_item {
+	__be32 type;
+	__be32 lower;
+	__be32 upper;
+	__be32 ref;
+	__be32 key;
+};
+
 struct sk_buff *tipc_named_publish(struct publication *publ);
 struct sk_buff *tipc_named_withdraw(struct publication *publ);
 void named_cluster_distribute(struct sk_buff *buf);
-void tipc_named_node_up(unsigned long node);
+void tipc_named_node_up(u32 max_item_buf, u32 node);
 void tipc_named_rcv(struct sk_buff *buf);
 void tipc_named_reinit(void);
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index c3a36bb..74efebc 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -267,7 +267,7 @@ void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 
 static void node_established_contact(struct tipc_node *n_ptr)
 {
-	tipc_k_signal((Handler)tipc_named_node_up, n_ptr->addr);
+	n_ptr->flags |= TIPC_NODE_UP;
 	n_ptr->bclink.oos_state = 0;
 	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
 	tipc_bclink_add_node(n_ptr->addr);
@@ -455,6 +455,9 @@ int tipc_node_get_linkname(u32 bearer_id, u32 addr, char *linkname, size_t len)
 void tipc_node_unlock(struct tipc_node *node)
 {
 	LIST_HEAD(nsub_list);
+	struct tipc_link *link;
+	int pkt_sz = 0;
+	u32 addr = 0;
 
 	if (likely(!node->flags)) {
 		spin_unlock_bh(&node->lock);
@@ -465,8 +468,19 @@ void tipc_node_unlock(struct tipc_node *node)
 		list_replace_init(&node->nsub, &nsub_list);
 		node->flags &= ~TIPC_NODE_LOST;
 	}
+	if (node->flags & TIPC_NODE_UP) {
+		link = node->active_links[0];
+		node->flags &= ~TIPC_NODE_UP;
+		if (link) {
+			pkt_sz = ((link->max_pkt - INT_H_SIZE) / ITEM_SIZE) *
+				  ITEM_SIZE;
+			addr = node->addr;
+		}
+	}
 	spin_unlock_bh(&node->lock);
 
 	if (!list_empty(&nsub_list))
 		tipc_nodesub_notify(&nsub_list);
+	if (pkt_sz)
+		tipc_named_node_up(pkt_sz, addr);
 }
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 4bd5eff..38f710f 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -48,15 +48,19 @@
 #define INVALID_NODE_SIG 0x10000
 
 /* Flags used to block (re)establishment of contact with a neighboring node
- * TIPC_NODE_DOWN: indicate node is down
+ * TIPC_NODE_DOWN: indicate node is down and it's used to block the node's
+ *                 links until RESET or ACTIVE message arrives
  * TIPC_NODE_RESET: indicate node is reset
  * TIPC_NODE_LOST: indicate node is lost and it's used to notify subscriptions
  *                 when node lock is released
+ * TIPC_NODE_UP: indicate node is up and it's used to deliver local name table
+ *               when node lock is released
  */
 enum {
 	TIPC_NODE_DOWN	= (1 << 1),
 	TIPC_NODE_RESET	= (1 << 2),
-	TIPC_NODE_LOST	= (1 << 3)
+	TIPC_NODE_LOST	= (1 << 3),
+	TIPC_NODE_UP	= (1 << 4)
 };
 
 /**
-- 
1.7.9.5
