From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 9/9] tipc: eliminate configuration for maximum number of name publications
Date: Thu, 16 Aug 2012 18:09:14 -0400
Message-ID: <1345154954-12526-10-git-send-email-paul.gortmaker@windriver.com>
References: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57514 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395Ab2HPWOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 18:14:55 -0400
In-Reply-To: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Gets rid of the need for users to specify the maximum number of
name publications supported by TIPC. TIPC now automatically provides
support for the maximum number of name publications to 65535.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |  4 ++--
 net/tipc/config.c           | 23 ++---------------------
 net/tipc/core.c             |  2 --
 net/tipc/core.h             |  2 +-
 net/tipc/name_table.c       |  4 ++--
 5 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 8dd8305..0b1e3f2 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -89,7 +89,7 @@
 
 #define  TIPC_CMD_GET_REMOTE_MNG    0x4003    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_PORTS     0x4004    /* tx none, rx unsigned */
-#define  TIPC_CMD_GET_MAX_PUBL      0x4005    /* tx none, rx unsigned */
+#define  TIPC_CMD_GET_MAX_PUBL      0x4005    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_SUBSCR    0x4006    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_ZONES     0x4007    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_CLUSTERS  0x4008    /* obsoleted */
@@ -115,7 +115,7 @@
 #define  TIPC_CMD_SET_NODE_ADDR     0x8001    /* tx net_addr, rx none */
 #define  TIPC_CMD_SET_REMOTE_MNG    0x8003    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_PORTS     0x8004    /* tx unsigned, rx none */
-#define  TIPC_CMD_SET_MAX_PUBL      0x8005    /* tx unsigned, rx none */
+#define  TIPC_CMD_SET_MAX_PUBL      0x8005    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_SUBSCR    0x8006    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_ZONES     0x8007    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_CLUSTERS  0x8008    /* obsoleted */
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 7a12758..f67866c 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -208,21 +208,6 @@ static struct sk_buff *cfg_set_remote_mng(void)
 	return tipc_cfg_reply_none();
 }
 
-static struct sk_buff *cfg_set_max_publications(void)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value < 1 || value > 65535)
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (max publications must be 1-65535)");
-	tipc_max_publications = value;
-	return tipc_cfg_reply_none();
-}
-
 static struct sk_buff *cfg_set_max_ports(void)
 {
 	u32 value;
@@ -342,9 +327,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SET_MAX_PORTS:
 		rep_tlv_buf = cfg_set_max_ports();
 		break;
-	case TIPC_CMD_SET_MAX_PUBL:
-		rep_tlv_buf = cfg_set_max_publications();
-		break;
 	case TIPC_CMD_SET_NETID:
 		rep_tlv_buf = cfg_set_netid();
 		break;
@@ -354,9 +336,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_PORTS:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_ports);
 		break;
-	case TIPC_CMD_GET_MAX_PUBL:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_publications);
-		break;
 	case TIPC_CMD_GET_NETID:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_net_id);
 		break;
@@ -374,6 +353,8 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_NODES:
 	case TIPC_CMD_SET_MAX_SUBSCR:
 	case TIPC_CMD_GET_MAX_SUBSCR:
+	case TIPC_CMD_SET_MAX_PUBL:
+	case TIPC_CMD_GET_MAX_PUBL:
 	case TIPC_CMD_SET_LOG_SIZE:
 	case TIPC_CMD_DUMP_LOG:
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 73e5eac..bfe8af8 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -53,7 +53,6 @@ int tipc_random __read_mostly;
 /* configurable TIPC parameters */
 u32 tipc_own_addr __read_mostly;
 int tipc_max_ports __read_mostly;
-int tipc_max_publications;
 int tipc_net_id __read_mostly;
 int tipc_remote_management __read_mostly;
 
@@ -155,7 +154,6 @@ static int __init tipc_init(void)
 
 	tipc_own_addr = 0;
 	tipc_remote_management = 1;
-	tipc_max_publications = 10000;
 	tipc_max_ports = CONFIG_TIPC_PORTS;
 	tipc_net_id = 4711;
 
diff --git a/net/tipc/core.h b/net/tipc/core.h
index ef01412..0207db0 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -62,6 +62,7 @@
 
 #define ULTRA_STRING_MAX_LEN	32768
 #define TIPC_MAX_SUBSCRIPTIONS	65535
+#define TIPC_MAX_PUBLICATIONS	65535
 
 struct tipc_msg;	/* msg.h */
 
@@ -77,7 +78,6 @@ int tipc_snprintf(char *buf, int len, const char *fmt, ...);
  */
 extern u32 tipc_own_addr __read_mostly;
 extern int tipc_max_ports __read_mostly;
-extern int tipc_max_publications;
 extern int tipc_net_id __read_mostly;
 extern int tipc_remote_management __read_mostly;
 
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 4ebdcc9..98975e8 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -667,9 +667,9 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 {
 	struct publication *publ;
 
-	if (table.local_publ_count >= tipc_max_publications) {
+	if (table.local_publ_count >= TIPC_MAX_PUBLICATIONS) {
 		pr_warn("Publication failed, local publication limit reached (%u)\n",
-			tipc_max_publications);
+			TIPC_MAX_PUBLICATIONS);
 		return NULL;
 	}
 
-- 
1.7.11.1
