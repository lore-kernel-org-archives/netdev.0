From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 6/7 net-next-2.6] tipc: Add missing locks when inspecting node list & link list
Date: Thu, 10 Jul 2008 17:26:10 -0400
Message-ID: <1215725171-10094-7-git-send-email-allan.stephens@windriver.com>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33130 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752AbYGJVZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:25:12 -0400
In-Reply-To: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that TIPC configuration commands that display info
about neighboring nodes and their links take the spinlocks that
protect the node list and link lists from changing while the lists
are being traversed.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/node.c |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 34e9a2b..ee952ad 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -600,12 +600,14 @@ u32 tipc_available_nodes(const u32 domain)
 	struct node *n_ptr;
 	u32 cnt = 0;
 
+	read_lock_bh(&tipc_net_lock);
 	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
 		if (!in_scope(domain, n_ptr->addr))
 			continue;
 		if (tipc_node_is_up(n_ptr))
 			cnt++;
 	}
+	read_unlock_bh(&tipc_net_lock);
 	return cnt;
 }
 
@@ -625,19 +627,26 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (network address)");
 
-	if (!tipc_nodes)
+	read_lock_bh(&tipc_net_lock);
+	if (!tipc_nodes) {
+		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_none();
+	}
 
 	/* For now, get space for all other nodes
 	   (will need to modify this when slave nodes are supported */
 
 	payload_size = TLV_SPACE(sizeof(node_info)) * (tipc_max_nodes - 1);
-	if (payload_size > 32768u)
+	if (payload_size > 32768u) {
+		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (too many nodes)");
+	}
 	buf = tipc_cfg_reply_alloc(payload_size);
-	if (!buf)
+	if (!buf) {
+		read_unlock_bh(&tipc_net_lock);
 		return NULL;
+	}
 
 	/* Add TLVs for all nodes in scope */
 
@@ -650,6 +659,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 				    &node_info, sizeof(node_info));
 	}
 
+	read_unlock_bh(&tipc_net_lock);
 	return buf;
 }
 
@@ -672,16 +682,22 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	if (tipc_mode != TIPC_NET_MODE)
 		return tipc_cfg_reply_none();
 
+	read_lock_bh(&tipc_net_lock);
+
 	/* Get space for all unicast links + multicast link */
 
 	payload_size = TLV_SPACE(sizeof(link_info)) *
 		(tipc_net.zones[tipc_zone(tipc_own_addr)]->links + 1);
-	if (payload_size > 32768u)
+	if (payload_size > 32768u) {
+		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (too many links)");
+	}
 	buf = tipc_cfg_reply_alloc(payload_size);
-	if (!buf)
+	if (!buf) {
+		read_unlock_bh(&tipc_net_lock);
 		return NULL;
+	}
 
 	/* Add TLV for broadcast link */
 
@@ -697,6 +713,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 
 		if (!in_scope(domain, n_ptr->addr))
 			continue;
+		tipc_node_lock(n_ptr);
 		for (i = 0; i < MAX_BEARERS; i++) {
 			if (!n_ptr->links[i])
 				continue;
@@ -706,7 +723,9 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 			tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO,
 					    &link_info, sizeof(link_info));
 		}
+		tipc_node_unlock(n_ptr);
 	}
 
+	read_unlock_bh(&tipc_net_lock);
 	return buf;
 }
-- 
1.5.4.3

