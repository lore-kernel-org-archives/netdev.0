From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 2/9 net-next-2.6] [TIPC]: Provide feedback when log buffer resizing fails
Date: Mon, 28 Apr 2008 15:48:39 -0400
Message-ID: <1209412126-2109-3-git-send-email-allan.stephens@windriver.com>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33654 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933854AbYD1TwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:52:03 -0400
In-Reply-To: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides feedback to the user when TIPC is unable
to set its log buffer to the requested size.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/dbg.c |   13 ++++++++++---
 net/tipc/dbg.h |    4 ++--
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/tipc/dbg.c b/net/tipc/dbg.c
index 1a8d0a2..c680691 100644
--- a/net/tipc/dbg.c
+++ b/net/tipc/dbg.c
@@ -2,7 +2,7 @@
  * net/tipc/dbg.c: TIPC print buffer routines for debugging
  *
  * Copyright (c) 1996-2006, Ericsson AB
- * Copyright (c) 2005-2006, Wind River Systems
+ * Copyright (c) 2005-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -354,8 +354,10 @@ void tipc_dump(struct print_buf *pb, const char *fmt, ...)
  * @log_size: print buffer size to use
  */
 
-void tipc_log_resize(int log_size)
+int tipc_log_resize(int log_size)
 {
+	int res = 0;
+
 	spin_lock_bh(&print_lock);
 	if (TIPC_LOG->buf) {
 		kfree(TIPC_LOG->buf);
@@ -366,8 +368,11 @@ void tipc_log_resize(int log_size)
 			log_size = TIPC_PB_MIN_SIZE;
 		tipc_printbuf_init(TIPC_LOG, kmalloc(log_size, GFP_ATOMIC),
 				   log_size);
+		res = !TIPC_LOG->buf;
 	}
 	spin_unlock_bh(&print_lock);
+
+	return res;
 }
 
 /**
@@ -385,7 +390,9 @@ struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area, int req_tlv_space)
 	if (value != delimit(value, 0, 32768))
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (log size must be 0-32768)");
-	tipc_log_resize(value);
+	if (tipc_log_resize(value))
+		return tipc_cfg_reply_error_string(
+			"unable to create specified log (log size is now 0)");
 	return tipc_cfg_reply_none();
 }
 
diff --git a/net/tipc/dbg.h b/net/tipc/dbg.h
index 718a5db..6b00062 100644
--- a/net/tipc/dbg.h
+++ b/net/tipc/dbg.h
@@ -2,7 +2,7 @@
  * net/tipc/dbg.h: Include file for TIPC print buffer routines
  *
  * Copyright (c) 1997-2006, Ericsson AB
- * Copyright (c) 2005-2006, Wind River Systems
+ * Copyright (c) 2005-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -61,7 +61,7 @@ int  tipc_printbuf_empty(struct print_buf *pb);
 int  tipc_printbuf_validate(struct print_buf *pb);
 void tipc_printbuf_move(struct print_buf *pb_to, struct print_buf *pb_from);
 
-void tipc_log_resize(int log_size);
+int tipc_log_resize(int log_size);
 
 struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area,
 				    int req_tlv_space);
-- 
1.5.3.2

