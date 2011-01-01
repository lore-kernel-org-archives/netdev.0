From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/20] tipc: Remove internal linked list of node objects
Date: Fri, 31 Dec 2010 23:59:23 -0500
Message-ID: <1293857975-30267-9-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53287 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab1AAFAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:05 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates a sorted list TIPC uses to keep track of the neighboring
nodes it has links to, since this duplicates information already present
in the internal array of node object pointers.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/node.c |   43 ++++++++++++++++---------------------------
 1 files changed, 16 insertions(+), 27 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 58e189b..31dcca9 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -43,9 +43,6 @@
 static void node_lost_contact(struct tipc_node *n_ptr);
 static void node_established_contact(struct tipc_node *n_ptr);
 
-/* sorted list of nodes within cluster */
-static struct tipc_node *tipc_nodes = NULL;
-
 static DEFINE_SPINLOCK(node_create_lock);
 
 u32 tipc_own_tag = 0;
@@ -63,21 +60,17 @@ u32 tipc_own_tag = 0;
 struct tipc_node *tipc_node_create(u32 addr)
 {
 	struct tipc_node *n_ptr;
-	struct tipc_node **curr_node;
 	u32 n_num;
 
 	spin_lock_bh(&node_create_lock);
 
-	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
-		if (addr < n_ptr->addr)
-			break;
-		if (addr == n_ptr->addr) {
-			spin_unlock_bh(&node_create_lock);
-			return n_ptr;
-		}
+	n_ptr = tipc_node_find(addr);
+	if (n_ptr) {
+		spin_unlock_bh(&node_create_lock);
+		return n_ptr;
 	}
 
-	n_ptr = kzalloc(sizeof(*n_ptr),GFP_ATOMIC);
+	n_ptr = kzalloc(sizeof(*n_ptr), GFP_ATOMIC);
 	if (!n_ptr) {
 		spin_unlock_bh(&node_create_lock);
 		warn("Node creation failed, no memory\n");
@@ -93,15 +86,6 @@ struct tipc_node *tipc_node_create(u32 addr)
 	if (n_num > tipc_net.highest_node)
 		tipc_net.highest_node = n_num;
 
-	/* Insert node into ordered list */
-	for (curr_node = &tipc_nodes; *curr_node;
-	     curr_node = &(*curr_node)->next) {
-		if (addr < (*curr_node)->addr) {
-			n_ptr->next = *curr_node;
-			break;
-		}
-	}
-	(*curr_node) = n_ptr;
 	spin_unlock_bh(&node_create_lock);
 	return n_ptr;
 }
@@ -405,6 +389,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 	struct tipc_node *n_ptr;
 	struct tipc_node_info node_info;
 	u32 payload_size;
+	u32 n_num;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
@@ -415,14 +400,15 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 						   " (network address)");
 
 	read_lock_bh(&tipc_net_lock);
-	if (!tipc_nodes) {
+	if (!tipc_net.nodes) {
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_none();
 	}
 
 	/* For now, get space for all other nodes */
 
-	payload_size = TLV_SPACE(sizeof(node_info)) * (tipc_max_nodes - 1);
+	payload_size = TLV_SPACE(sizeof(node_info)) *
+		(tipc_net.highest_node - 1);
 	if (payload_size > 32768u) {
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
@@ -436,8 +422,9 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 
 	/* Add TLVs for all nodes in scope */
 
-	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
-		if (!tipc_in_scope(domain, n_ptr->addr))
+	for (n_num = 1; n_num <= tipc_net.highest_node; n_num++) {
+		n_ptr = tipc_net.nodes[n_num];
+		if (!n_ptr || !tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		node_info.addr = htonl(n_ptr->addr);
 		node_info.up = htonl(tipc_node_is_up(n_ptr));
@@ -456,6 +443,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	struct tipc_node *n_ptr;
 	struct tipc_link_info link_info;
 	u32 payload_size;
+	u32 n_num;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
@@ -493,10 +481,11 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 
 	/* Add TLVs for any other links in scope */
 
-	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
+	for (n_num = 1; n_num <= tipc_net.highest_node; n_num++) {
 		u32 i;
 
-		if (!tipc_in_scope(domain, n_ptr->addr))
+		n_ptr = tipc_net.nodes[n_num];
+		if (!n_ptr || !tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		tipc_node_lock(n_ptr);
 		for (i = 0; i < MAX_BEARERS; i++) {
-- 
1.7.3.3

