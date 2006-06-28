From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 2/3] [TIPC] Improve response to requests for node/link information
Date: Wed, 28 Jun 2006 14:07:51 +0200
Message-ID: <11514964721454-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606281358100.6341@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:16554 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1423304AbWF1MH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 08:07:56 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606281358100.6341@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Now allocates reply space for "get links" request based on number of actual
links, not number of potential links.  Also, limits reply to "get links" and
"get nodes" requests to 32KB to match capabilities of tipc-config utility
that issued request.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/node.c |   26 +++++++++++++++++---------
 net/tipc/zone.h |    4 ++--
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index ce9678e..bf24168 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -2,7 +2,7 @@
  * net/tipc/node.c: TIPC node management routines
  * 
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -592,6 +592,7 @@ struct sk_buff *tipc_node_get_nodes(cons
 	struct sk_buff *buf;
 	struct node *n_ptr;
         struct tipc_node_info node_info;
+	u32 payload_size;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
@@ -608,8 +609,11 @@ struct sk_buff *tipc_node_get_nodes(cons
 	/* For now, get space for all other nodes 
 	   (will need to modify this when slave nodes are supported */
 
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(sizeof(node_info)) *
-				   (tipc_max_nodes - 1));
+	payload_size = TLV_SPACE(sizeof(node_info)) * (tipc_max_nodes - 1);
+	if (payload_size > 32768u)
+		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
+						   " (too many nodes)");
+	buf = tipc_cfg_reply_alloc(payload_size);
 	if (!buf)
 		return NULL;
 
@@ -633,6 +637,7 @@ struct sk_buff *tipc_node_get_links(cons
 	struct sk_buff *buf;
 	struct node *n_ptr;
         struct tipc_link_info link_info;
+	u32 payload_size;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
@@ -645,12 +650,15 @@ struct sk_buff *tipc_node_get_links(cons
 
         if (!tipc_nodes)
                 return tipc_cfg_reply_none();
-
-	/* For now, get space for 2 links to all other nodes + bcast link 
-	   (will need to modify this when slave nodes are supported */
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(sizeof(link_info)) *
-				   (2 * (tipc_max_nodes - 1) + 1));
+	
+	/* Get space for all unicast links + multicast link */
+
+	payload_size = TLV_SPACE(sizeof(link_info)) *
+		(tipc_net.zones[tipc_zone(tipc_own_addr)]->links + 1);
+	if (payload_size > 32768u)
+		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
+						   " (too many links)");
+	buf = tipc_cfg_reply_alloc(payload_size);
 	if (!buf)
 		return NULL;
 
diff --git a/net/tipc/zone.h b/net/tipc/zone.h
index 267999c..5ab3d08 100644
--- a/net/tipc/zone.h
+++ b/net/tipc/zone.h
@@ -2,7 +2,7 @@
  * net/tipc/zone.h: Include file for TIPC zone management routines
  * 
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -45,7 +45,7 @@ #include "net.h"
  * struct _zone - TIPC zone structure
  * @addr: network address of zone
  * @clusters: array of pointers to all clusters within zone
- * @links: (used for inter-zone communication)
+ * @links: number of (unicast) links to zone
  */
  
 struct _zone {
-- 
1.4.0

