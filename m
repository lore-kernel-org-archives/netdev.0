From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 1/5 net-next-2.6] [TIPC]: Fix skb_under_panic when configuring TIPC without privileges
Date: Tue, 20 May 2008 17:08:28 -0400
Message-ID: <1211317712-13596-2-git-send-email-allan.stephens@windriver.com>
References: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41993 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763287AbYETVKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 17:10:07 -0400
In-Reply-To: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prevents a TIPC configuration command requiring network
administrator privileges from triggering an skbuff underrun if it
is issued by a process lacking those privileges.  The revised error
handling code avoids the use of a potentially uninitialized global
variable by transforming the unauthorized command into a new command,
then following the standard command processing path to generate the
required error message.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 include/linux/tipc_config.h |   10 +++++++++-
 net/tipc/config.c           |    6 +++++-
 net/tipc/netlink.c          |   16 +++++++++-------
 3 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index b0c916d..2bc6fa4 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -2,7 +2,7 @@
  * include/linux/tipc_config.h: Include file for TIPC configuration interface
  * 
  * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -136,6 +136,14 @@
 #define  TIPC_CMD_SET_NETID         0x800B    /* tx unsigned, rx none */
 
 /*
+ * Reserved commands:
+ * May not be issued by any process.
+ * Used internally by TIPC.
+ */
+
+#define  TIPC_CMD_NOT_NET_ADMIN     0xC001    /* tx none, rx none */
+
+/*
  * TLV types defined for TIPC
  */
 
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 91d56f8..16e7cb7 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -2,7 +2,7 @@
  * net/tipc/config.c: TIPC configuration management code
  *
  * Copyright (c) 2002-2006, Ericsson AB
- * Copyright (c) 2004-2006, Wind River Systems
+ * Copyright (c) 2004-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -602,6 +602,10 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_NETID:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_net_id);
 		break;
+	case TIPC_CMD_NOT_NET_ADMIN:
+		rep_tlv_buf =
+			tipc_cfg_reply_error_string(TIPC_CFG_NOT_NET_ADMIN);
+		break;
 	default:
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 							  " (unknown command)");
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 6a7f7b4..c387217 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -2,7 +2,7 @@
  * net/tipc/netlink.c: TIPC configuration handling
  *
  * Copyright (c) 2005-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -45,15 +45,17 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 	struct nlmsghdr *req_nlh = info->nlhdr;
 	struct tipc_genlmsghdr *req_userhdr = info->userhdr;
 	int hdr_space = NLMSG_SPACE(GENL_HDRLEN + TIPC_GENL_HDRLEN);
+	u16 cmd;
 
 	if ((req_userhdr->cmd & 0xC000) && (!capable(CAP_NET_ADMIN)))
-		rep_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_NET_ADMIN);
+		cmd = TIPC_CMD_NOT_NET_ADMIN;
 	else
-		rep_buf = tipc_cfg_do_cmd(req_userhdr->dest,
-					  req_userhdr->cmd,
-					  NLMSG_DATA(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN,
-					  NLMSG_PAYLOAD(req_nlh, GENL_HDRLEN + TIPC_GENL_HDRLEN),
-					  hdr_space);
+		cmd = req_userhdr->cmd;
+
+	rep_buf = tipc_cfg_do_cmd(req_userhdr->dest, cmd,
+			NLMSG_DATA(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN,
+			NLMSG_PAYLOAD(req_nlh, GENL_HDRLEN + TIPC_GENL_HDRLEN),
+			hdr_space);
 
 	if (rep_buf) {
 		skb_push(rep_buf, hdr_space);
-- 
1.5.3.2

