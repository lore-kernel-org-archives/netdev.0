From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/20] tipc: remove dump() and tipc_dump_dbg()
Date: Fri, 31 Dec 2010 23:59:26 -0500
Message-ID: <1293857975-30267-12-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53308 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab1AAFAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:08 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates calls to two debugging macros that are being completely obsoleted,
as well as any associated debugging routines that are no longer required.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.h |    8 -----
 net/tipc/log.c  |   81 ++----------------------------------------------------
 2 files changed, 3 insertions(+), 86 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index b4e54f8..3af0b36 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -145,23 +145,15 @@ void tipc_printf(struct print_buf *, const char *fmt, ...);
 		if (DBG_OUTPUT != TIPC_NULL) \
 			tipc_msg_dbg(DBG_OUTPUT, msg, txt); \
 	} while (0)
-#define dump(fmt, arg...) \
-	do { \
-		if (DBG_OUTPUT != TIPC_NULL) \
-			tipc_dump_dbg(DBG_OUTPUT, fmt, ##arg); \
-	} while (0)
 
 void tipc_msg_dbg(struct print_buf *, struct tipc_msg *, const char *);
-void tipc_dump_dbg(struct print_buf *, const char *fmt, ...);
 
 #else
 
 #define dbg(fmt, arg...)	do {} while (0)
 #define msg_dbg(msg, txt)	do {} while (0)
-#define dump(fmt, arg...)	do {} while (0)
 
 #define tipc_msg_dbg(...)	do {} while (0)
-#define tipc_dump_dbg(...)	do {} while (0)
 
 #endif
 
diff --git a/net/tipc/log.c b/net/tipc/log.c
index 9d99f70..2796044 100644
--- a/net/tipc/log.c
+++ b/net/tipc/log.c
@@ -64,9 +64,9 @@ struct print_buf *const TIPC_LOG = &log_buf;
  * 'print_string' when writing to a print buffer. This also protects against
  * concurrent writes to the print buffer being written to.
  *
- * 2) tipc_dump() and tipc_log_XXX() leverage the aforementioned
- * use of 'print_lock' to protect against all types of concurrent operations
- * on their associated print buffer (not just write operations).
+ * 2) tipc_log_XXX() leverages the aforementioned use of 'print_lock' to
+ * protect against all types of concurrent operations on their associated
+ * print buffer (not just write operations).
  *
  * Note: All routines of the form tipc_printbuf_XXX() are lock-free, and rely
  * on the caller to prevent simultaneous use of the print buffer(s) being
@@ -268,81 +268,6 @@ void tipc_printf(struct print_buf *pb, const char *fmt, ...)
 	spin_unlock_bh(&print_lock);
 }
 
-#ifdef CONFIG_TIPC_DEBUG
-
-/**
- * print_to_console - write string of bytes to console in multiple chunks
- */
-
-static void print_to_console(char *crs, int len)
-{
-	int rest = len;
-
-	while (rest > 0) {
-		int sz = rest < TIPC_PB_MAX_STR ? rest : TIPC_PB_MAX_STR;
-		char c = crs[sz];
-
-		crs[sz] = 0;
-		printk((const char *)crs);
-		crs[sz] = c;
-		rest -= sz;
-		crs += sz;
-	}
-}
-
-/**
- * printbuf_dump - write print buffer contents to console
- */
-
-static void printbuf_dump(struct print_buf *pb)
-{
-	int len;
-
-	if (!pb->buf) {
-		printk("*** PRINT BUFFER NOT ALLOCATED ***");
-		return;
-	}
-
-	/* Dump print buffer from char after cursor to end (if used) */
-
-	len = pb->buf + pb->size - pb->crs - 2;
-	if ((pb->buf[pb->size - 1] == 0) && (len > 0))
-		print_to_console(pb->crs + 1, len);
-
-	/* Dump print buffer from start to cursor (always) */
-
-	len = pb->crs - pb->buf;
-	print_to_console(pb->buf, len);
-}
-
-/**
- * tipc_dump_dbg - dump (non-console) print buffer to console
- * @pb: pointer to print buffer
- */
-
-void tipc_dump_dbg(struct print_buf *pb, const char *fmt, ...)
-{
-	int len;
-
-	if (pb == TIPC_CONS)
-		return;
-
-	spin_lock_bh(&print_lock);
-
-	FORMAT(print_string, len, fmt);
-	printk(print_string);
-
-	printk("\n---- Start of %s log dump ----\n\n",
-	       (pb == TIPC_LOG) ? "global" : "local");
-	printbuf_dump(pb);
-	tipc_printbuf_reset(pb);
-	printk("\n---- End of dump ----\n");
-
-	spin_unlock_bh(&print_lock);
-}
-
-#endif
-
 /**
  * tipc_log_resize - change the size of the TIPC log buffer
  * @log_size: print buffer size to use
-- 
1.7.3.3

