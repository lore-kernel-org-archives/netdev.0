From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/26] tipc: Eliminate configuration for maximum number of cluster nodes
Date: Sun, 13 Mar 2011 17:33:57 -0400
Message-ID: <1300052054-7531-10-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49885 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754883Ab1CMVel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:41 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Gets rid of the need for users to specify the maximum number of
cluster nodes supported by TIPC. TIPC now automatically provides
support for all 4K nodes allowed by its addressing scheme.

Note: This change sets TIPC's memory usage to the amount used by
a maximum size node table with 4K entries.  An upcoming patch that
converts the node table from a linear array to a hash table will
compact the node table to a more efficient design, but for clarity
it is nice to have all the Kconfig infrastruture go away separately.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |    4 ++--
 net/tipc/Kconfig            |   12 ------------
 net/tipc/addr.c             |   11 +++--------
 net/tipc/config.c           |   29 +++--------------------------
 net/tipc/core.c             |    6 ------
 net/tipc/core.h             |    1 -
 net/tipc/net.c              |    3 +--
 7 files changed, 9 insertions(+), 57 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 011556f..64aba5a 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -89,7 +89,7 @@
 #define  TIPC_CMD_GET_MAX_SUBSCR    0x4006    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_ZONES     0x4007    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_CLUSTERS  0x4008    /* obsoleted */
-#define  TIPC_CMD_GET_MAX_NODES     0x4009    /* tx none, rx unsigned */
+#define  TIPC_CMD_GET_MAX_NODES     0x4009    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_SLAVES    0x400A    /* obsoleted */
 #define  TIPC_CMD_GET_NETID         0x400B    /* tx none, rx unsigned */
 
@@ -115,7 +115,7 @@
 #define  TIPC_CMD_SET_MAX_SUBSCR    0x8006    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_ZONES     0x8007    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_CLUSTERS  0x8008    /* obsoleted */
-#define  TIPC_CMD_SET_MAX_NODES     0x8009    /* tx unsigned, rx none */
+#define  TIPC_CMD_SET_MAX_NODES     0x8009    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_SLAVES    0x800A    /* obsoleted */
 #define  TIPC_CMD_SET_NETID         0x800B    /* tx unsigned, rx none */
 
diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index 0436927..2c5954b 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -29,18 +29,6 @@ config TIPC_ADVANCED
 	  Saying Y here will open some advanced configuration for TIPC.
 	  Most users do not need to bother; if unsure, just say N.
 
-config TIPC_NODES
-	int "Maximum number of nodes in a cluster"
-	depends on TIPC_ADVANCED
-	range 8 2047
-	default "255"
-	help
-	  Specifies how many nodes can be supported in a TIPC cluster.
-	  Can range from 8 to 2047 nodes; default is 255.
-
-	  Setting this to a smaller value saves some memory;
-	  setting it to higher allows for more nodes.
-
 config TIPC_PORTS
 	int "Maximum number of ports in a node"
 	depends on TIPC_ADVANCED
diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index 087e399..a6fdab3 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -2,7 +2,7 @@
  * net/tipc/addr.c: TIPC address utility routines
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 2004-2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -41,7 +41,7 @@
  * tipc_addr_domain_valid - validates a network domain address
  *
  * Accepts <Z.C.N>, <Z.C.0>, <Z.0.0>, and <0.0.0>,
- * where Z, C, and N are non-zero and do not exceed the configured limits.
+ * where Z, C, and N are non-zero.
  *
  * Returns 1 if domain address is valid, otherwise 0
  */
@@ -51,10 +51,6 @@ int tipc_addr_domain_valid(u32 addr)
 	u32 n = tipc_node(addr);
 	u32 c = tipc_cluster(addr);
 	u32 z = tipc_zone(addr);
-	u32 max_nodes = tipc_max_nodes;
-
-	if (n > max_nodes)
-		return 0;
 
 	if (n && (!z || !c))
 		return 0;
@@ -66,8 +62,7 @@ int tipc_addr_domain_valid(u32 addr)
 /**
  * tipc_addr_node_valid - validates a proposed network address for this node
  *
- * Accepts <Z.C.N>, where Z, C, and N are non-zero and do not exceed
- * the configured limits.
+ * Accepts <Z.C.N>, where Z, C, and N are non-zero.
  *
  * Returns 1 if address can be used, otherwise 0
  */
diff --git a/net/tipc/config.c b/net/tipc/config.c
index e16750d..fa3d508 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -2,7 +2,7 @@
  * net/tipc/config.c: TIPC configuration management code
  *
  * Copyright (c) 2002-2006, Ericsson AB
- * Copyright (c) 2004-2007, Wind River Systems
+ * Copyright (c) 2004-2007, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -260,25 +260,6 @@ static struct sk_buff *cfg_set_max_ports(void)
 	return tipc_cfg_reply_none();
 }
 
-static struct sk_buff *cfg_set_max_nodes(void)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value == tipc_max_nodes)
-		return tipc_cfg_reply_none();
-	if (value != delimit(value, 8, 2047))
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (max nodes must be 8-2047)");
-	if (tipc_mode == TIPC_NET_MODE)
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-			" (cannot change max nodes once TIPC has joined a network)");
-	tipc_max_nodes = value;
-	return tipc_cfg_reply_none();
-}
-
 static struct sk_buff *cfg_set_netid(void)
 {
 	u32 value;
@@ -397,9 +378,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SET_MAX_SUBSCR:
 		rep_tlv_buf = cfg_set_max_subscriptions();
 		break;
-	case TIPC_CMD_SET_MAX_NODES:
-		rep_tlv_buf = cfg_set_max_nodes();
-		break;
 	case TIPC_CMD_SET_NETID:
 		rep_tlv_buf = cfg_set_netid();
 		break;
@@ -415,9 +393,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_SUBSCR:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_subscriptions);
 		break;
-	case TIPC_CMD_GET_MAX_NODES:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_nodes);
-		break;
 	case TIPC_CMD_GET_NETID:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_net_id);
 		break;
@@ -431,6 +406,8 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_SLAVES:
 	case TIPC_CMD_SET_MAX_CLUSTERS:
 	case TIPC_CMD_GET_MAX_CLUSTERS:
+	case TIPC_CMD_SET_MAX_NODES:
+	case TIPC_CMD_GET_MAX_NODES:
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 							  " (obsolete command)");
 		break;
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 2da1fc7..c9a73e7 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -41,10 +41,6 @@
 #include "config.h"
 
 
-#ifndef CONFIG_TIPC_NODES
-#define CONFIG_TIPC_NODES 255
-#endif
-
 #ifndef CONFIG_TIPC_PORTS
 #define CONFIG_TIPC_PORTS 8191
 #endif
@@ -64,7 +60,6 @@ const char tipc_alphabet[] =
 /* configurable TIPC parameters */
 
 u32 tipc_own_addr;
-int tipc_max_nodes;
 int tipc_max_ports;
 int tipc_max_subscriptions;
 int tipc_max_publications;
@@ -192,7 +187,6 @@ static int __init tipc_init(void)
 	tipc_max_publications = 10000;
 	tipc_max_subscriptions = 2000;
 	tipc_max_ports = CONFIG_TIPC_PORTS;
-	tipc_max_nodes = CONFIG_TIPC_NODES;
 	tipc_net_id = 4711;
 
 	res = tipc_core_start();
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 37544d9..436dda1 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -147,7 +147,6 @@ void tipc_msg_dbg(struct print_buf *, struct tipc_msg *, const char *);
  */
 
 extern u32 tipc_own_addr;
-extern int tipc_max_nodes;
 extern int tipc_max_ports;
 extern int tipc_max_subscriptions;
 extern int tipc_max_publications;
diff --git a/net/tipc/net.c b/net/tipc/net.c
index f6303d7..b5b337f 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -114,8 +114,7 @@ atomic_t tipc_num_links;
 
 static int net_start(void)
 {
-	tipc_nodes = kcalloc(tipc_max_nodes + 1,
-				 sizeof(*tipc_nodes), GFP_ATOMIC);
+	tipc_nodes = kcalloc(4096, sizeof(*tipc_nodes), GFP_ATOMIC);
 	tipc_highest_node = 0;
 	atomic_set(&tipc_num_links, 0);
 
-- 
1.7.3.3

