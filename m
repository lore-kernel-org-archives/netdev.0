From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/16] tipc: Add support for "-s" configuration option
Date: Tue, 11 May 2010 20:30:08 -0400
Message-ID: <ebc8f620796c5a9a3c5841bd8b1b78a9cd207c89.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35230 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab0ELAa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:28 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0URvV000104
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:27 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Provide initial support for displaying overall TIPC status/statistics
information at runtime.  Currently, only version info for the TIPC
kernel module is displayed.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |    1 +
 net/tipc/config.c           |   40 +++++++++++++++++++++++++++++++++++++++-
 net/tipc/core.c             |    2 --
 net/tipc/core.h             |    3 +++
 4 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 2bc6fa4..9cde86c 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -74,6 +74,7 @@
 #define  TIPC_CMD_SHOW_NAME_TABLE   0x0005    /* tx name_tbl_query, rx ultra_string */
 #define  TIPC_CMD_SHOW_PORTS        0x0006    /* tx none, rx ultra_string */
 #define  TIPC_CMD_SHOW_LINK_STATS   0x000B    /* tx link_name, rx ultra_string */
+#define  TIPC_CMD_SHOW_STATS        0x000F    /* tx unsigned, rx ultra_string */
 
 #if 0
 #define  TIPC_CMD_SHOW_PORT_STATS   0x0008    /* tx port_ref, rx ultra_string */
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 7370241..961d1b0 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -246,13 +246,48 @@ static void cfg_cmd_event(struct tipc_cmd_msg *msg,
 	default:
 		rv = tipc_cfg_cmd(msg, data, sz, (u32 *)&msg_sect[1].iov_len, orig);
 	}
-	exit:
+exit:
 	rmsg.result_len = htonl(msg_sect[1].iov_len);
 	rmsg.retval = htonl(rv);
 	tipc_cfg_respond(msg_sect, 2u, orig);
 }
 #endif
 
+#define MAX_STATS_INFO 2000
+
+static struct sk_buff *tipc_show_stats(void)
+{
+	struct sk_buff *buf;
+	struct tlv_desc *rep_tlv;
+	struct print_buf pb;
+	int str_len;
+	u32 value;
+
+	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
+		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
+
+	value = ntohl(*(u32 *)TLV_DATA(req_tlv_area));
+	if (value != 0)
+		return tipc_cfg_reply_error_string("unsupported argument");
+
+	buf = tipc_cfg_reply_alloc(TLV_SPACE(MAX_STATS_INFO));
+	if (buf == NULL)
+		return NULL;
+
+	rep_tlv = (struct tlv_desc *)buf->data;
+	tipc_printbuf_init(&pb, (char *)TLV_DATA(rep_tlv), MAX_STATS_INFO);
+
+	tipc_printf(&pb, "TIPC version " TIPC_MOD_VER "\n");
+
+	/* Use additional tipc_printf()'s to return more info ... */
+
+	str_len = tipc_printbuf_validate(&pb);
+	skb_put(buf, TLV_SPACE(str_len));
+	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
+
+	return buf;
+}
+
 static struct sk_buff *cfg_enable_bearer(void)
 {
 	struct tipc_bearer_config *args;
@@ -536,6 +571,9 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_DUMP_LOG:
 		rep_tlv_buf = tipc_log_dump();
 		break;
+	case TIPC_CMD_SHOW_STATS:
+		rep_tlv_buf = tipc_show_stats();
+		break;
 	case TIPC_CMD_SET_LINK_TOL:
 	case TIPC_CMD_SET_LINK_PRI:
 	case TIPC_CMD_SET_LINK_WINDOW:
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 4e84c84..b47d184 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -49,8 +49,6 @@
 #include "config.h"
 
 
-#define TIPC_MOD_VER "2.0.0"
-
 #ifndef CONFIG_TIPC_ZONES
 #define CONFIG_TIPC_ZONES 3
 #endif
diff --git a/net/tipc/core.h b/net/tipc/core.h
index c58a1d1..1e149f5 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -59,6 +59,9 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 
+
+#define TIPC_MOD_VER "2.0.0"
+
 /*
  * TIPC sanity test macros
  */
-- 
1.7.1.rc2

