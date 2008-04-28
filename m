From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 8/9 net-next-2.6] [TIPC]: Exclude debug-only print buffer code when not debugging
Date: Mon, 28 Apr 2008 15:48:45 -0400
Message-ID: <1209412126-2109-9-git-send-email-allan.stephens@windriver.com>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33701 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934205AbYD1TwH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:52:07 -0400
In-Reply-To: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies TIPC to only exclude debug-related print buffer
routines when debugging capabilities are not required.  It also
fixes up some related #defines that exceed 80 characters.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.h |   12 ++++++++----
 net/tipc/dbg.c  |    8 ++++++--
 net/tipc/link.c |   20 ++++++++++++++++----
 net/tipc/msg.c  |   10 +++++++---
 4 files changed, 37 insertions(+), 13 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index d7f3b3c..0d783bc 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -85,8 +85,6 @@ extern struct print_buf *const TIPC_CONS;
 extern struct print_buf *const TIPC_LOG;
 
 void tipc_printf(struct print_buf *, const char *fmt, ...);
-void tipc_msg_print(struct print_buf *, struct tipc_msg *, const char *);
-void tipc_dump(struct print_buf *, const char *fmt, ...);
 
 /*
  * TIPC_OUTPUT is the destination print buffer for system messages.
@@ -144,20 +142,26 @@ void tipc_dump(struct print_buf *, const char *fmt, ...);
 #define msg_dbg(msg, txt) \
 	do { \
 		if (DBG_OUTPUT != TIPC_NULL) \
-			tipc_msg_print(DBG_OUTPUT, msg, txt); \
+			tipc_msg_dbg(DBG_OUTPUT, msg, txt); \
 	} while (0)
 #define dump(fmt, arg...) \
 	do { \
 		if (DBG_OUTPUT != TIPC_NULL) \
-			tipc_dump(DBG_OUTPUT, fmt, ##arg); \
+			tipc_dump_dbg(DBG_OUTPUT, fmt, ##arg); \
 	} while (0)
 
+void tipc_msg_dbg(struct print_buf *, struct tipc_msg *, const char *);
+void tipc_dump_dbg(struct print_buf *, const char *fmt, ...);
+
 #else
 
 #define dbg(fmt, arg...)	do {} while (0)
 #define msg_dbg(msg, txt)	do {} while (0)
 #define dump(fmt, arg...)	do {} while (0)
 
+#define tipc_msg_dbg(...)	do {} while (0)
+#define tipc_dump_dbg(...)	do {} while (0)
+
 #endif
 
 
diff --git a/net/tipc/dbg.c b/net/tipc/dbg.c
index cda4968..29ecae8 100644
--- a/net/tipc/dbg.c
+++ b/net/tipc/dbg.c
@@ -263,6 +263,8 @@ void tipc_printf(struct print_buf *pb, const char *fmt, ...)
 	spin_unlock_bh(&print_lock);
 }
 
+#ifdef CONFIG_TIPC_DEBUG
+
 /**
  * print_to_console - write string of bytes to console in multiple chunks
  */
@@ -309,11 +311,11 @@ static void printbuf_dump(struct print_buf *pb)
 }
 
 /**
- * tipc_dump - dump (non-console) print buffer to console
+ * tipc_dump_dbg - dump (non-console) print buffer to console
  * @pb: pointer to print buffer
  */
 
-void tipc_dump(struct print_buf *pb, const char *fmt, ...)
+void tipc_dump_dbg(struct print_buf *pb, const char *fmt, ...)
 {
 	int len;
 
@@ -334,6 +336,8 @@ void tipc_dump(struct print_buf *pb, const char *fmt, ...)
 	spin_unlock_bh(&print_lock);
 }
 
+#endif
+
 /**
  * tipc_log_resize - change the size of the TIPC log buffer
  * @log_size: print buffer size to use
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2a26a16..bd206eb 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -147,9 +147,21 @@ static void link_print(struct link *l_ptr, struct print_buf *buf,
 
 #define LINK_LOG_BUF_SIZE 0
 
-#define dbg_link(fmt, arg...)  do {if (LINK_LOG_BUF_SIZE) tipc_printf(&l_ptr->print_buf, fmt, ## arg); } while(0)
-#define dbg_link_msg(msg, txt) do {if (LINK_LOG_BUF_SIZE) tipc_msg_print(&l_ptr->print_buf, msg, txt); } while(0)
-#define dbg_link_state(txt) do {if (LINK_LOG_BUF_SIZE) link_print(l_ptr, &l_ptr->print_buf, txt); } while(0)
+#define dbg_link(fmt, arg...) \
+	do { \
+		if (LINK_LOG_BUF_SIZE) \
+			tipc_printf(&l_ptr->print_buf, fmt, ## arg); \
+	} while (0)
+#define dbg_link_msg(msg, txt) \
+	do { \
+		if (LINK_LOG_BUF_SIZE) \
+			tipc_msg_dbg(&l_ptr->print_buf, msg, txt); \
+	} while (0)
+#define dbg_link_state(txt) \
+	do { \
+		if (LINK_LOG_BUF_SIZE) \
+			link_print(l_ptr, &l_ptr->print_buf, txt); \
+	} while (0)
 #define dbg_link_dump() do { \
 	if (LINK_LOG_BUF_SIZE) { \
 		tipc_printf(LOG, "\n\nDumping link <%s>:\n", l_ptr->name); \
@@ -1651,7 +1663,7 @@ static void link_retransmit_failure(struct link *l_ptr, struct sk_buff *buf)
 	struct tipc_msg *msg = buf_msg(buf);
 
 	warn("Retransmission failure on link <%s>\n", l_ptr->name);
-	tipc_msg_print(TIPC_OUTPUT, msg, ">RETR-FAIL>");
+	tipc_msg_dbg(TIPC_OUTPUT, msg, ">RETR-FAIL>");
 
 	if (l_ptr->addr) {
 
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 696a863..38abeba 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -41,7 +41,9 @@
 #include "bearer.h"
 
 
-void tipc_msg_print(struct print_buf *buf, struct tipc_msg *msg, const char *str)
+#ifdef CONFIG_TIPC_DEBUG
+
+void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 {
 	u32 usr = msg_user(msg);
 	tipc_printf(buf, str);
@@ -315,9 +317,11 @@ void tipc_msg_print(struct print_buf *buf, struct tipc_msg *msg, const char *str
 	}
 	tipc_printf(buf, "\n");
 	if ((usr == CHANGEOVER_PROTOCOL) && (msg_msgcnt(msg))) {
-		tipc_msg_print(buf,msg_get_wrapped(msg),"      /");
+		tipc_msg_dbg(buf, msg_get_wrapped(msg), "      /");
 	}
 	if ((usr == MSG_FRAGMENTER) && (msg_type(msg) == FIRST_FRAGMENT)) {
-		tipc_msg_print(buf,msg_get_wrapped(msg),"      /");
+		tipc_msg_dbg(buf, msg_get_wrapped(msg), "      /");
 	}
 }
+
+#endif
-- 
1.5.3.2

