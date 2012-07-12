From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 6/8] tipc: simplify print buffer handling in tipc_printf
Date: Thu, 12 Jul 2012 12:39:59 -0400
Message-ID: <1342111201-9426-7-git-send-email-paul.gortmaker@windriver.com>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43559 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161338Ab2GLQka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:40:30 -0400
In-Reply-To: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

tipc_printf was previously used both to construct debug traces
and to append data to buffers that should be sent over netlink
to the tipc-config application.  A global print_buffer was
used to format the string before it was copied to the actual
output buffer.  This could lead to concurrent access of the
global print_buffer, which then had to be lock protected.
This is simplified by changing tipc_printf to append data
directly to the output buffer using vscnprintf.

With the new implementation of tipc_printf, there is no longer
any risk of concurrent access to the internal log buffer, so
the lock (and the comments describing it) are no longer
strictly necessary.  However, there are still a few functions
that do grab this lock before resizing/dumping the log
buffer.  We leave the lock, and these functions untouched since
they will be removed with a subsequent commit that drops the
deprecated log buffer handling code

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/log.c |   52 ++++++++++------------------------------------------
 1 file changed, 10 insertions(+), 42 deletions(-)

diff --git a/net/tipc/log.c b/net/tipc/log.c
index 026733f..d01e37a 100644
--- a/net/tipc/log.c
+++ b/net/tipc/log.c
@@ -71,21 +71,11 @@ struct print_buf *const TIPC_LOG = &log_buf;
  * on the caller to prevent simultaneous use of the print buffer(s) being
  * manipulated.
  */
-static char print_string[TIPC_PB_MAX_STR];
 static DEFINE_SPINLOCK(print_lock);
 
 static void tipc_printbuf_move(struct print_buf *pb_to,
 			       struct print_buf *pb_from);
 
-#define FORMAT(PTR, LEN, FMT) \
-{\
-	va_list args;\
-	va_start(args, FMT);\
-	LEN = vsprintf(PTR, FMT, args);\
-	va_end(args);\
-	*(PTR + LEN) = '\0';\
-}
-
 /**
  * tipc_printbuf_init - initialize print buffer to empty
  * @pb: pointer to print buffer structure
@@ -220,39 +210,17 @@ static void tipc_printbuf_move(struct print_buf *pb_to,
  */
 void tipc_printf(struct print_buf *pb, const char *fmt, ...)
 {
-	int chars_to_add;
-	int chars_left;
-	char save_char;
-
-	spin_lock_bh(&print_lock);
-
-	FORMAT(print_string, chars_to_add, fmt);
-	if (chars_to_add >= TIPC_PB_MAX_STR)
-		strcpy(print_string, "*** PRINT BUFFER STRING TOO LONG ***");
-
-	if (pb->buf) {
-		chars_left = pb->buf + pb->size - pb->crs - 1;
-		if (chars_to_add <= chars_left) {
-			strcpy(pb->crs, print_string);
-			pb->crs += chars_to_add;
-		} else if (chars_to_add >= (pb->size - 1)) {
-			strcpy(pb->buf, print_string + chars_to_add + 1
-			       - pb->size);
-			pb->crs = pb->buf + pb->size - 1;
-		} else {
-			strcpy(pb->buf, print_string + chars_left);
-			save_char = print_string[chars_left];
-			print_string[chars_left] = 0;
-			strcpy(pb->crs, print_string);
-			print_string[chars_left] = save_char;
-			pb->crs = pb->buf + chars_to_add - chars_left;
-		}
-	}
-
-	if (pb->echo)
-		printk("%s", print_string);
+	int i;
+	va_list args;
+	char *buf;
+	int len;
 
-	spin_unlock_bh(&print_lock);
+	buf = pb->crs;
+	len = pb->buf + pb->size - pb->crs;
+	va_start(args, fmt);
+	i = vscnprintf(buf, len, fmt, args);
+	va_end(args);
+	pb->crs += i;
 }
 
 /**
-- 
1.7.9.7
