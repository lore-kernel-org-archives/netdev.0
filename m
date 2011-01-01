From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/20] tipc: Finish streamlining of debugging code
Date: Fri, 31 Dec 2010 23:59:28 -0500
Message-ID: <1293857975-30267-14-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53327 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab1AAFAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:10 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Completes the simplification of TIPC's debugging capabilities. By default
TIPC includes no debugging code, and any debugging code added by developers
that calls the dbg() and dbg_macros() is compiled out. If debugging support
is enabled, TIPC prints out some additional data about its internal state
when certain abnormal conditions occur, and any developer-added calls to the
TIPC debug macros are compiled in.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/Kconfig |   11 +++++++----
 net/tipc/core.h  |   47 +++++++++--------------------------------------
 net/tipc/log.c   |    4 +---
 net/tipc/msg.c   |    1 +
 4 files changed, 18 insertions(+), 45 deletions(-)

diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index c02d3e9..0e7ce30 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -67,12 +67,15 @@ config TIPC_LOG
 	  managed remotely via TIPC.
 
 config TIPC_DEBUG
-	bool "Enable debug messages"
+	bool "Enable debugging support"
 	default n
 	help
-	  This enables debugging of TIPC.
+	  Saying Y here enables TIPC debugging capabilities used by developers.
+	  Most users do not need to bother; if unsure, just say N.
 
-	  Only say Y here if you are having trouble with TIPC.  It will
-	  enable the display of detailed information about what is going on.
+	  Enabling debugging support causes TIPC to display data about its
+	  internal state when certain abnormal conditions occur. It also
+	  makes it easy for developers to capture additional information of
+	  interest using the dbg() or msg_dbg() macros.
 
 endif # TIPC
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 3af0b36..9971585 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -83,6 +83,7 @@ struct print_buf;	/* log.h */
  *       user-defined buffers can be configured to do the same thing.
  */
 extern struct print_buf *const TIPC_NULL;
+extern struct print_buf *const TIPC_CONS;
 extern struct print_buf *const TIPC_LOG;
 
 void tipc_printf(struct print_buf *, const char *fmt, ...);
@@ -95,56 +96,26 @@ void tipc_printf(struct print_buf *, const char *fmt, ...);
 #define TIPC_OUTPUT TIPC_LOG
 #endif
 
-/*
- * TIPC can be configured to send system messages to TIPC_OUTPUT
- * or to the system console only.
- */
-
-#ifdef CONFIG_TIPC_DEBUG
-
 #define err(fmt, arg...)  tipc_printf(TIPC_OUTPUT, \
-					KERN_ERR "TIPC: " fmt, ## arg)
+				      KERN_ERR "TIPC: " fmt, ## arg)
 #define warn(fmt, arg...) tipc_printf(TIPC_OUTPUT, \
-					KERN_WARNING "TIPC: " fmt, ## arg)
+				      KERN_WARNING "TIPC: " fmt, ## arg)
 #define info(fmt, arg...) tipc_printf(TIPC_OUTPUT, \
-					KERN_NOTICE "TIPC: " fmt, ## arg)
-
-#else
+				      KERN_NOTICE "TIPC: " fmt, ## arg)
 
-#define err(fmt, arg...)  printk(KERN_ERR "TIPC: " fmt , ## arg)
-#define info(fmt, arg...) printk(KERN_INFO "TIPC: " fmt , ## arg)
-#define warn(fmt, arg...) printk(KERN_WARNING "TIPC: " fmt , ## arg)
-
-#endif
+#ifdef CONFIG_TIPC_DEBUG
 
 /*
  * DBG_OUTPUT is the destination print buffer for debug messages.
- * It defaults to the the null print buffer, but can be redefined
- * (typically in the individual .c files being debugged) to allow
- * selected debug messages to be generated where needed.
  */
 
 #ifndef DBG_OUTPUT
-#define DBG_OUTPUT TIPC_NULL
+#define DBG_OUTPUT TIPC_LOG
 #endif
 
-/*
- * TIPC can be configured to send debug messages to the specified print buffer
- * (typically DBG_OUTPUT) or to suppress them entirely.
- */
-
-#ifdef CONFIG_TIPC_DEBUG
+#define dbg(fmt, arg...)  tipc_printf(DBG_OUTPUT, KERN_DEBUG fmt, ## arg);
 
-#define dbg(fmt, arg...)  \
-	do { \
-		if (DBG_OUTPUT != TIPC_NULL) \
-			tipc_printf(DBG_OUTPUT, fmt, ## arg); \
-	} while (0)
-#define msg_dbg(msg, txt) \
-	do { \
-		if (DBG_OUTPUT != TIPC_NULL) \
-			tipc_msg_dbg(DBG_OUTPUT, msg, txt); \
-	} while (0)
+#define msg_dbg(msg, txt) tipc_msg_dbg(DBG_OUTPUT, msg, txt);
 
 void tipc_msg_dbg(struct print_buf *, struct tipc_msg *, const char *);
 
@@ -153,7 +124,7 @@ void tipc_msg_dbg(struct print_buf *, struct tipc_msg *, const char *);
 #define dbg(fmt, arg...)	do {} while (0)
 #define msg_dbg(msg, txt)	do {} while (0)
 
-#define tipc_msg_dbg(...)	do {} while (0)
+#define tipc_msg_dbg(buf, msg, txt) do {} while (0)
 
 #endif
 
diff --git a/net/tipc/log.c b/net/tipc/log.c
index 2796044..952c39f 100644
--- a/net/tipc/log.c
+++ b/net/tipc/log.c
@@ -52,7 +52,7 @@ static struct print_buf null_buf = { NULL, 0, NULL, 0 };
 struct print_buf *const TIPC_NULL = &null_buf;
 
 static struct print_buf cons_buf = { NULL, 0, NULL, 1 };
-static struct print_buf *const TIPC_CONS = &cons_buf;
+struct print_buf *const TIPC_CONS = &cons_buf;
 
 static struct print_buf log_buf = { NULL, 0, NULL, 1 };
 struct print_buf *const TIPC_LOG = &log_buf;
@@ -76,8 +76,6 @@ struct print_buf *const TIPC_LOG = &log_buf;
 static char print_string[TIPC_PB_MAX_STR];
 static DEFINE_SPINLOCK(print_lock);
 
-static void tipc_printbuf_reset(struct print_buf *pb);
-static int  tipc_printbuf_empty(struct print_buf *pb);
 static void tipc_printbuf_move(struct print_buf *pb_to,
 			       struct print_buf *pb_from);
 
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index ee6b4c6..a029cdc 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -138,6 +138,7 @@ int tipc_msg_build(struct tipc_msg *hdr,
 void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 {
 	u32 usr = msg_user(msg);
+	tipc_printf(buf, KERN_DEBUG);
 	tipc_printf(buf, str);
 
 	switch (usr) {
-- 
1.7.3.3

