From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/26] tipc: Split up unified structure of network-related variables
Date: Sun, 13 Mar 2011 17:33:56 -0400
Message-ID: <1300052054-7531-9-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49881 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756546Ab1CMVek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:40 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Converts the fields of the global "tipc_net" structure into individual
variables.  Since the struct was never referenced as a complete unit,
its existence was pointless.  This will facilitate upcoming changes to
TIPC's node table and simpify upcoming relocation of the variables so
they are only visible to the files that actually use them.

This change is essentially cosmetic in nature, and doesn't affect the
operation of TIPC.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |    4 ++--
 net/tipc/net.c        |   22 ++++++++++++----------
 net/tipc/net.h        |   17 +++--------------
 net/tipc/node.c       |   30 +++++++++++++++---------------
 net/tipc/node.h       |    2 +-
 5 files changed, 33 insertions(+), 42 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index d58dae7..f2086f6 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -111,8 +111,8 @@ static void named_cluster_distribute(struct sk_buff *buf)
 	struct tipc_node *n_ptr;
 	u32 n_num;
 
-	for (n_num = 1; n_num <= tipc_net.highest_node; n_num++) {
-		n_ptr = tipc_net.nodes[n_num];
+	for (n_num = 1; n_num <= tipc_highest_node; n_num++) {
+		n_ptr = tipc_nodes[n_num];
 		if (n_ptr && tipc_node_has_active_links(n_ptr)) {
 			buf_copy = skb_copy(buf, GFP_ATOMIC);
 			if (!buf_copy)
diff --git a/net/tipc/net.c b/net/tipc/net.c
index dd78d86..f6303d7 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -108,26 +108,28 @@
 */
 
 DEFINE_RWLOCK(tipc_net_lock);
-struct network tipc_net;
+struct tipc_node **tipc_nodes;
+u32 tipc_highest_node;
+atomic_t tipc_num_links;
 
 static int net_start(void)
 {
-	tipc_net.nodes = kcalloc(tipc_max_nodes + 1,
-				 sizeof(*tipc_net.nodes), GFP_ATOMIC);
-	tipc_net.highest_node = 0;
-	atomic_set(&tipc_net.links, 0);
+	tipc_nodes = kcalloc(tipc_max_nodes + 1,
+				 sizeof(*tipc_nodes), GFP_ATOMIC);
+	tipc_highest_node = 0;
+	atomic_set(&tipc_num_links, 0);
 
-	return tipc_net.nodes ? 0 : -ENOMEM;
+	return tipc_nodes ? 0 : -ENOMEM;
 }
 
 static void net_stop(void)
 {
 	u32 n_num;
 
-	for (n_num = 1; n_num <= tipc_net.highest_node; n_num++)
-		tipc_node_delete(tipc_net.nodes[n_num]);
-	kfree(tipc_net.nodes);
-	tipc_net.nodes = NULL;
+	for (n_num = 1; n_num <= tipc_highest_node; n_num++)
+		tipc_node_delete(tipc_nodes[n_num]);
+	kfree(tipc_nodes);
+	tipc_nodes = NULL;
 }
 
 static void net_route_named_msg(struct sk_buff *buf)
diff --git a/net/tipc/net.h b/net/tipc/net.h
index aa431ef..b52b974 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -39,21 +39,10 @@
 
 struct tipc_node;
 
-/**
- * struct network - TIPC network structure
- * @nodes: array of pointers to all nodes within cluster
- * @highest_node: id of highest numbered node within cluster
- * @links: number of (unicast) links to cluster
- */
-
-struct network {
-	struct tipc_node **nodes;
-	u32 highest_node;
-	atomic_t links;
-};
-
+extern struct tipc_node **tipc_nodes;
+extern u32 tipc_highest_node;
+extern atomic_t tipc_num_links;
 
-extern struct network tipc_net;
 extern rwlock_t tipc_net_lock;
 
 void tipc_net_route_msg(struct sk_buff *buf);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index a24fad3..64976f2 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -81,9 +81,9 @@ struct tipc_node *tipc_node_create(u32 addr)
 	INIT_LIST_HEAD(&n_ptr->nsub);
 
 	n_num = tipc_node(addr);
-	tipc_net.nodes[n_num] = n_ptr;
-	if (n_num > tipc_net.highest_node)
-		tipc_net.highest_node = n_num;
+	tipc_nodes[n_num] = n_ptr;
+	if (n_num > tipc_highest_node)
+		tipc_highest_node = n_num;
 
 	spin_unlock_bh(&node_create_lock);
 	return n_ptr;
@@ -97,11 +97,11 @@ void tipc_node_delete(struct tipc_node *n_ptr)
 		return;
 
 	n_num = tipc_node(n_ptr->addr);
-	tipc_net.nodes[n_num] = NULL;
+	tipc_nodes[n_num] = NULL;
 	kfree(n_ptr);
 
-	while (!tipc_net.nodes[tipc_net.highest_node])
-		if (--tipc_net.highest_node == 0)
+	while (!tipc_nodes[tipc_highest_node])
+		if (--tipc_highest_node == 0)
 			break;
 }
 
@@ -233,7 +233,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 
 		if (!n_ptr->links[bearer_id]) {
 			n_ptr->links[bearer_id] = l_ptr;
-			atomic_inc(&tipc_net.links);
+			atomic_inc(&tipc_num_links);
 			n_ptr->link_cnt++;
 			return n_ptr;
 		}
@@ -247,7 +247,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr)
 {
 	n_ptr->links[l_ptr->b_ptr->identity] = NULL;
-	atomic_dec(&tipc_net.links);
+	atomic_dec(&tipc_num_links);
 	n_ptr->link_cnt--;
 }
 
@@ -390,7 +390,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 						   " (network address)");
 
 	read_lock_bh(&tipc_net_lock);
-	if (!tipc_net.nodes) {
+	if (!tipc_nodes) {
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_none();
 	}
@@ -398,7 +398,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 	/* For now, get space for all other nodes */
 
 	payload_size = TLV_SPACE(sizeof(node_info)) *
-		(tipc_net.highest_node - 1);
+		(tipc_highest_node - 1);
 	if (payload_size > 32768u) {
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
@@ -412,8 +412,8 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 
 	/* Add TLVs for all nodes in scope */
 
-	for (n_num = 1; n_num <= tipc_net.highest_node; n_num++) {
-		n_ptr = tipc_net.nodes[n_num];
+	for (n_num = 1; n_num <= tipc_highest_node; n_num++) {
+		n_ptr = tipc_nodes[n_num];
 		if (!n_ptr || !tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		node_info.addr = htonl(n_ptr->addr);
@@ -451,7 +451,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	/* Get space for all unicast links + multicast link */
 
 	payload_size = TLV_SPACE(sizeof(link_info)) *
-		(atomic_read(&tipc_net.links) + 1);
+		(atomic_read(&tipc_num_links) + 1);
 	if (payload_size > 32768u) {
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
@@ -472,10 +472,10 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 
 	/* Add TLVs for any other links in scope */
 
-	for (n_num = 1; n_num <= tipc_net.highest_node; n_num++) {
+	for (n_num = 1; n_num <= tipc_highest_node; n_num++) {
 		u32 i;
 
-		n_ptr = tipc_net.nodes[n_num];
+		n_ptr = tipc_nodes[n_num];
 		if (!n_ptr || !tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		tipc_node_lock(n_ptr);
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 206a8ef..c510a2a 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -107,7 +107,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 static inline struct tipc_node *tipc_node_find(u32 addr)
 {
 	if (likely(in_own_cluster(addr)))
-		return tipc_net.nodes[tipc_node(addr)];
+		return tipc_nodes[tipc_node(addr)];
 	return NULL;
 }
 
-- 
1.7.3.3

