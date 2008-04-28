From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 1/9 net-next-2.6] [TIPC]: Simplify log buffer resizing
Date: Mon, 28 Apr 2008 15:48:38 -0400
Message-ID: <1209412126-2109-2-git-send-email-allan.stephens@windriver.com>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33650 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932884AbYD1TwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:52:03 -0400
In-Reply-To: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch simplifies & standardizes the way TIPC's print buffer
log is resized.  Code to terminate use of the log buffer is
eliminated by simply setting the log buffer size to 0 bytes.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/config.c |    2 +-
 net/tipc/core.c   |    4 ++--
 net/tipc/dbg.c    |   26 +++++++-------------------
 net/tipc/dbg.h    |    6 +++---
 4 files changed, 13 insertions(+), 25 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index c71337a..91d56f8 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -529,7 +529,7 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 		break;
 #endif
 	case TIPC_CMD_SET_LOG_SIZE:
-		rep_tlv_buf = tipc_log_resize(req_tlv_area, req_tlv_space);
+		rep_tlv_buf = tipc_log_resize_cmd(req_tlv_area, req_tlv_space);
 		break;
 	case TIPC_CMD_DUMP_LOG:
 		rep_tlv_buf = tipc_log_dump();
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 740aac5..862d415 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -182,7 +182,7 @@ static int __init tipc_init(void)
 {
 	int res;
 
-	tipc_log_reinit(CONFIG_TIPC_LOG);
+	tipc_log_resize(CONFIG_TIPC_LOG);
 	info("Activated (version " TIPC_MOD_VER
 	     " compiled " __DATE__ " " __TIME__ ")\n");
 
@@ -209,7 +209,7 @@ static void __exit tipc_exit(void)
 	tipc_core_stop_net();
 	tipc_core_stop();
 	info("Deactivated\n");
-	tipc_log_stop();
+	tipc_log_resize(0);
 }
 
 module_init(tipc_init);
diff --git a/net/tipc/dbg.c b/net/tipc/dbg.c
index e809d2a..1a8d0a2 100644
--- a/net/tipc/dbg.c
+++ b/net/tipc/dbg.c
@@ -350,43 +350,31 @@ void tipc_dump(struct print_buf *pb, const char *fmt, ...)
 }
 
 /**
- * tipc_log_stop - free up TIPC log print buffer
+ * tipc_log_resize - change the size of the TIPC log buffer
+ * @log_size: print buffer size to use
  */
 
-void tipc_log_stop(void)
+void tipc_log_resize(int log_size)
 {
 	spin_lock_bh(&print_lock);
 	if (TIPC_LOG->buf) {
 		kfree(TIPC_LOG->buf);
 		TIPC_LOG->buf = NULL;
 	}
-	spin_unlock_bh(&print_lock);
-}
-
-/**
- * tipc_log_reinit - (re)initialize TIPC log print buffer
- * @log_size: print buffer size to use
- */
-
-void tipc_log_reinit(int log_size)
-{
-	tipc_log_stop();
-
 	if (log_size) {
 		if (log_size < TIPC_PB_MIN_SIZE)
 			log_size = TIPC_PB_MIN_SIZE;
-		spin_lock_bh(&print_lock);
 		tipc_printbuf_init(TIPC_LOG, kmalloc(log_size, GFP_ATOMIC),
 				   log_size);
-		spin_unlock_bh(&print_lock);
 	}
+	spin_unlock_bh(&print_lock);
 }
 
 /**
- * tipc_log_resize - reconfigure size of TIPC log buffer
+ * tipc_log_resize_cmd - reconfigure size of TIPC log buffer
  */
 
-struct sk_buff *tipc_log_resize(const void *req_tlv_area, int req_tlv_space)
+struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area, int req_tlv_space)
 {
 	u32 value;
 
@@ -397,7 +385,7 @@ struct sk_buff *tipc_log_resize(const void *req_tlv_area, int req_tlv_space)
 	if (value != delimit(value, 0, 32768))
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (log size must be 0-32768)");
-	tipc_log_reinit(value);
+	tipc_log_resize(value);
 	return tipc_cfg_reply_none();
 }
 
diff --git a/net/tipc/dbg.h b/net/tipc/dbg.h
index c01b085..718a5db 100644
--- a/net/tipc/dbg.h
+++ b/net/tipc/dbg.h
@@ -61,10 +61,10 @@ int  tipc_printbuf_empty(struct print_buf *pb);
 int  tipc_printbuf_validate(struct print_buf *pb);
 void tipc_printbuf_move(struct print_buf *pb_to, struct print_buf *pb_from);
 
-void tipc_log_reinit(int log_size);
-void tipc_log_stop(void);
+void tipc_log_resize(int log_size);
 
-struct sk_buff *tipc_log_resize(const void *req_tlv_area, int req_tlv_space);
+struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area,
+				    int req_tlv_space);
 struct sk_buff *tipc_log_dump(void);
 
 #endif
-- 
1.5.3.2

