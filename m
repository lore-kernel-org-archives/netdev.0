From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 8/9] tipc: eliminate configuration for maximum number of name subscriptions
Date: Thu, 16 Aug 2012 18:09:13 -0400
Message-ID: <1345154954-12526-9-git-send-email-paul.gortmaker@windriver.com>
References: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57509 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756178Ab2HPWOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 18:14:54 -0400
In-Reply-To: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Gets rid of the need for users to specify the maximum number of
name subscriptions supported by TIPC. TIPC now automatically provides
support for the maximum number of name subscriptions to 65535.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |  4 ++--
 net/tipc/config.c           | 25 +++----------------------
 net/tipc/core.c             |  2 --
 net/tipc/core.h             |  4 ++--
 net/tipc/subscr.c           |  4 ++--
 5 files changed, 9 insertions(+), 30 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index c989284..8dd8305 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -90,7 +90,7 @@
 #define  TIPC_CMD_GET_REMOTE_MNG    0x4003    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_PORTS     0x4004    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_PUBL      0x4005    /* tx none, rx unsigned */
-#define  TIPC_CMD_GET_MAX_SUBSCR    0x4006    /* tx none, rx unsigned */
+#define  TIPC_CMD_GET_MAX_SUBSCR    0x4006    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_ZONES     0x4007    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_CLUSTERS  0x4008    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_NODES     0x4009    /* obsoleted */
@@ -116,7 +116,7 @@
 #define  TIPC_CMD_SET_REMOTE_MNG    0x8003    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_PORTS     0x8004    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_PUBL      0x8005    /* tx unsigned, rx none */
-#define  TIPC_CMD_SET_MAX_SUBSCR    0x8006    /* tx unsigned, rx none */
+#define  TIPC_CMD_SET_MAX_SUBSCR    0x8006    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_ZONES     0x8007    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_CLUSTERS  0x8008    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_NODES     0x8009    /* obsoleted */
diff --git a/net/tipc/config.c b/net/tipc/config.c
index a056a38..7a12758 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -2,7 +2,7 @@
  * net/tipc/config.c: TIPC configuration management code
  *
  * Copyright (c) 2002-2006, Ericsson AB
- * Copyright (c) 2004-2007, 2010-2011, Wind River Systems
+ * Copyright (c) 2004-2007, 2010-2012, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -223,21 +223,6 @@ static struct sk_buff *cfg_set_max_publications(void)
 	return tipc_cfg_reply_none();
 }
 
-static struct sk_buff *cfg_set_max_subscriptions(void)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value < 1 || value > 65535)
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (max subscriptions must be 1-65535");
-	tipc_max_subscriptions = value;
-	return tipc_cfg_reply_none();
-}
-
 static struct sk_buff *cfg_set_max_ports(void)
 {
 	u32 value;
@@ -360,9 +345,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SET_MAX_PUBL:
 		rep_tlv_buf = cfg_set_max_publications();
 		break;
-	case TIPC_CMD_SET_MAX_SUBSCR:
-		rep_tlv_buf = cfg_set_max_subscriptions();
-		break;
 	case TIPC_CMD_SET_NETID:
 		rep_tlv_buf = cfg_set_netid();
 		break;
@@ -375,9 +357,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_PUBL:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_publications);
 		break;
-	case TIPC_CMD_GET_MAX_SUBSCR:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_subscriptions);
-		break;
 	case TIPC_CMD_GET_NETID:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_net_id);
 		break;
@@ -393,6 +372,8 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_CLUSTERS:
 	case TIPC_CMD_SET_MAX_NODES:
 	case TIPC_CMD_GET_MAX_NODES:
+	case TIPC_CMD_SET_MAX_SUBSCR:
+	case TIPC_CMD_GET_MAX_SUBSCR:
 	case TIPC_CMD_SET_LOG_SIZE:
 	case TIPC_CMD_DUMP_LOG:
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
diff --git a/net/tipc/core.c b/net/tipc/core.c
index b858f20..73e5eac 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -53,7 +53,6 @@ int tipc_random __read_mostly;
 /* configurable TIPC parameters */
 u32 tipc_own_addr __read_mostly;
 int tipc_max_ports __read_mostly;
-int tipc_max_subscriptions;
 int tipc_max_publications;
 int tipc_net_id __read_mostly;
 int tipc_remote_management __read_mostly;
@@ -157,7 +156,6 @@ static int __init tipc_init(void)
 	tipc_own_addr = 0;
 	tipc_remote_management = 1;
 	tipc_max_publications = 10000;
-	tipc_max_subscriptions = 2000;
 	tipc_max_ports = CONFIG_TIPC_PORTS;
 	tipc_net_id = 4711;
 
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 4c5705a..ef01412 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -60,7 +60,8 @@
 
 #define TIPC_MOD_VER "2.0.0"
 
-#define ULTRA_STRING_MAX_LEN 32768
+#define ULTRA_STRING_MAX_LEN	32768
+#define TIPC_MAX_SUBSCRIPTIONS	65535
 
 struct tipc_msg;	/* msg.h */
 
@@ -76,7 +77,6 @@ int tipc_snprintf(char *buf, int len, const char *fmt, ...);
  */
 extern u32 tipc_own_addr __read_mostly;
 extern int tipc_max_ports __read_mostly;
-extern int tipc_max_subscriptions;
 extern int tipc_max_publications;
 extern int tipc_net_id __read_mostly;
 extern int tipc_remote_management __read_mostly;
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 5ed5965..0f7d0d0 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -304,9 +304,9 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 	}
 
 	/* Refuse subscription if global limit exceeded */
-	if (atomic_read(&topsrv.subscription_count) >= tipc_max_subscriptions) {
+	if (atomic_read(&topsrv.subscription_count) >= TIPC_MAX_SUBSCRIPTIONS) {
 		pr_warn("Subscription rejected, limit reached (%u)\n",
-			tipc_max_subscriptions);
+			TIPC_MAX_SUBSCRIPTIONS);
 		subscr_terminate(subscriber);
 		return NULL;
 	}
-- 
1.7.11.1
