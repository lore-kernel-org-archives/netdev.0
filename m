From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 5/9 net-next-2.6] [TIPC]: Elimination of print buffer chaining
Date: Mon, 28 Apr 2008 15:48:42 -0400
Message-ID: <1209412126-2109-6-git-send-email-allan.stephens@windriver.com>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33678 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934085AbYD1TwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:52:04 -0400
In-Reply-To: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch revamps TIPC's print buffer subsystem to eliminate
support for arbitrary chains of print buffers, which were
rarely needed and difficult to use safely.

In its place, print buffers can now be configured to echo their
output to the system console.  This provides an equivalent for
the only chaining currently utilized by TIPC, in a faster and
more compact manner.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.h |    7 ++-
 net/tipc/dbg.c  |  163 +++++++++++++++++++++++++------------------------------
 net/tipc/dbg.h  |    4 +-
 3 files changed, 80 insertions(+), 94 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 325404f..7042ef3 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -66,7 +66,6 @@
 
 struct tipc_msg;
 extern struct print_buf *TIPC_NULL, *TIPC_CONS, *TIPC_LOG;
-extern struct print_buf *TIPC_TEE(struct print_buf *, struct print_buf *);
 void tipc_msg_print(struct print_buf*,struct tipc_msg *,const char*);
 void tipc_printf(struct print_buf *, const char *fmt, ...);
 void tipc_dump(struct print_buf*,const char *fmt, ...);
@@ -98,11 +97,13 @@ void tipc_dump(struct print_buf*,const char *fmt, ...);
  * TIPC_CONS		   : system console
  * TIPC_LOG		   : TIPC log buffer
  * &buf			   : user-defined buffer (struct print_buf *)
- * TIPC_TEE(&buf_a,&buf_b) : list of buffers (eg. TIPC_TEE(TIPC_CONS,TIPC_LOG))
+ *
+ * Note: TIPC_LOG is configured to echo its output to the system console;
+ *       user-defined buffers can be configured to do the same thing.
  */
 
 #ifndef TIPC_OUTPUT
-#define TIPC_OUTPUT TIPC_TEE(TIPC_CONS,TIPC_LOG)
+#define TIPC_OUTPUT TIPC_LOG
 #endif
 
 #ifndef DBG_OUTPUT
diff --git a/net/tipc/dbg.c b/net/tipc/dbg.c
index 834319e..8ca9457 100644
--- a/net/tipc/dbg.c
+++ b/net/tipc/dbg.c
@@ -38,18 +38,44 @@
 #include "config.h"
 #include "dbg.h"
 
-static char print_string[TIPC_PB_MAX_STR];
-static DEFINE_SPINLOCK(print_lock);
+/*
+ * TIPC pre-defines the following print buffers:
+ *
+ * TIPC_NULL : null buffer (i.e. print nowhere)
+ * TIPC_CONS : system console
+ * TIPC_LOG  : TIPC log buffer
+ *
+ * Additional user-defined print buffers are also permitted.
+ */
 
-static struct print_buf null_buf = { NULL, 0, NULL, NULL };
+static struct print_buf null_buf = { NULL, 0, NULL, 0 };
 struct print_buf *TIPC_NULL = &null_buf;
 
-static struct print_buf cons_buf = { NULL, 0, NULL, NULL };
+static struct print_buf cons_buf = { NULL, 0, NULL, 1 };
 struct print_buf *TIPC_CONS = &cons_buf;
 
-static struct print_buf log_buf = { NULL, 0, NULL, NULL };
+static struct print_buf log_buf = { NULL, 0, NULL, 1 };
 struct print_buf *TIPC_LOG = &log_buf;
 
+/*
+ * Locking policy when using print buffers.
+ *
+ * 1) tipc_printf() uses 'print_lock' to protect against concurrent access to
+ * 'print_string' when writing to a print buffer. This also protects against
+ * concurrent writes to the print buffer being written to.
+ *
+ * 2) tipc_dump() and tipc_log_XXX() leverage the aforementioned
+ * use of 'print_lock' to protect against all types of concurrent operations
+ * on their associated print buffer (not just write operations).
+ *
+ * Note: All routines of the form tipc_printbuf_XXX() are lock-free, and rely
+ * on the caller to prevent simultaneous use of the print buffer(s) being
+ * manipulated.
+ */
+
+static char print_string[TIPC_PB_MAX_STR];
+static DEFINE_SPINLOCK(print_lock);
+
 
 #define FORMAT(PTR,LEN,FMT) \
 {\
@@ -60,27 +86,14 @@ struct print_buf *TIPC_LOG = &log_buf;
        *(PTR + LEN) = '\0';\
 }
 
-/*
- * Locking policy when using print buffers.
- *
- * The following routines use 'print_lock' for protection:
- * 1) tipc_printf()  - to protect its print buffer(s) and 'print_string'
- * 2) TIPC_TEE()     - to protect its print buffer(s)
- * 3) tipc_dump()    - to protect its print buffer(s) and 'print_string'
- * 4) tipc_log_XXX() - to protect TIPC_LOG
- *
- * All routines of the form tipc_printbuf_XXX() rely on the caller to prevent
- * simultaneous use of the print buffer(s) being manipulated.
- */
-
 /**
  * tipc_printbuf_init - initialize print buffer to empty
  * @pb: pointer to print buffer structure
  * @raw: pointer to character array used by print buffer
  * @size: size of character array
  *
- * Makes the print buffer a null device that discards anything written to it
- * if the character array is too small (or absent).
+ * Note: If the character array is too small (or absent), the print buffer
+ * becomes a null device that discards anything written to it.
  */
 
 void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 size)
@@ -88,7 +101,7 @@ void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 size)
 	pb->buf = raw;
 	pb->crs = raw;
 	pb->size = size;
-	pb->next = NULL;
+	pb->echo = 0;
 
 	if (size < TIPC_PB_MIN_SIZE) {
 		pb->buf = NULL;
@@ -105,7 +118,11 @@ void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 size)
 
 void tipc_printbuf_reset(struct print_buf *pb)
 {
-	tipc_printbuf_init(pb, pb->buf, pb->size);
+	if (pb->buf != NULL) {
+		pb->crs = pb->buf;
+		pb->buf[0] = 0;
+		pb->buf[pb->size - 1] = ~0;
+	}
 }
 
 /**
@@ -182,7 +199,6 @@ void tipc_printbuf_move(struct print_buf *pb_to, struct print_buf *pb_from)
 		strcpy(pb_to->buf, "*** PRINT BUFFER MOVE ERROR ***");
 		pb_to->buf[pb_to->size - 1] = ~0;
 		pb_to->crs = strchr(pb_to->buf, 0);
-		pb_to->next = NULL;
 		return;
 	}
 
@@ -205,8 +221,8 @@ void tipc_printbuf_move(struct print_buf *pb_to, struct print_buf *pb_from)
 }
 
 /**
- * tipc_printf - append formatted output to print buffer chain
- * @pb: pointer to chain of print buffers (may be NULL)
+ * tipc_printf - append formatted output to print buffer
+ * @pb: pointer to print buffer
  * @fmt: formatted info to be printed
  */
 
@@ -215,66 +231,36 @@ void tipc_printf(struct print_buf *pb, const char *fmt, ...)
 	int chars_to_add;
 	int chars_left;
 	char save_char;
-	struct print_buf *pb_next;
 
 	spin_lock_bh(&print_lock);
+
 	FORMAT(print_string, chars_to_add, fmt);
 	if (chars_to_add >= TIPC_PB_MAX_STR)
 		strcpy(print_string, "*** PRINT BUFFER STRING TOO LONG ***");
 
-	while (pb) {
-		if (pb == TIPC_CONS)
-			printk(print_string);
-		else if (pb->buf) {
-			chars_left = pb->buf + pb->size - pb->crs - 1;
-			if (chars_to_add <= chars_left) {
-				strcpy(pb->crs, print_string);
-				pb->crs += chars_to_add;
-			} else if (chars_to_add >= (pb->size - 1)) {
-				strcpy(pb->buf, print_string + chars_to_add + 1
-				       - pb->size);
-				pb->crs = pb->buf + pb->size - 1;
-			} else {
-				strcpy(pb->buf, print_string + chars_left);
-				save_char = print_string[chars_left];
-				print_string[chars_left] = 0;
-				strcpy(pb->crs, print_string);
-				print_string[chars_left] = save_char;
-				pb->crs = pb->buf + chars_to_add - chars_left;
-			}
+	if (pb->buf) {
+		chars_left = pb->buf + pb->size - pb->crs - 1;
+		if (chars_to_add <= chars_left) {
+			strcpy(pb->crs, print_string);
+			pb->crs += chars_to_add;
+		} else if (chars_to_add >= (pb->size - 1)) {
+			strcpy(pb->buf, print_string + chars_to_add + 1
+			       - pb->size);
+			pb->crs = pb->buf + pb->size - 1;
+		} else {
+			strcpy(pb->buf, print_string + chars_left);
+			save_char = print_string[chars_left];
+			print_string[chars_left] = 0;
+			strcpy(pb->crs, print_string);
+			print_string[chars_left] = save_char;
+			pb->crs = pb->buf + chars_to_add - chars_left;
 		}
-		pb_next = pb->next;
-		pb->next = NULL;
-		pb = pb_next;
 	}
-	spin_unlock_bh(&print_lock);
-}
 
-/**
- * TIPC_TEE - perform next output operation on both print buffers
- * @b0: pointer to chain of print buffers (may be NULL)
- * @b1: pointer to print buffer to add to chain
- *
- * Returns pointer to print buffer chain.
- */
-
-struct print_buf *TIPC_TEE(struct print_buf *b0, struct print_buf *b1)
-{
-	struct print_buf *pb = b0;
+	if (pb->echo)
+		printk(print_string);
 
-	if (!b0 || (b0 == b1))
-		return b1;
-
-	spin_lock_bh(&print_lock);
-	while (pb->next) {
-		if ((pb->next == b1) || (pb->next == b0))
-			pb->next = pb->next->next;
-		else
-			pb = pb->next;
-	}
-	pb->next = b1;
 	spin_unlock_bh(&print_lock);
-	return b0;
 }
 
 /**
@@ -323,31 +309,28 @@ static void printbuf_dump(struct print_buf *pb)
 }
 
 /**
- * tipc_dump - dump non-console print buffer(s) to console
- * @pb: pointer to chain of print buffers
+ * tipc_dump - dump (non-console) print buffer to console
+ * @pb: pointer to print buffer
  */
 
 void tipc_dump(struct print_buf *pb, const char *fmt, ...)
 {
-	struct print_buf *pb_next;
 	int len;
 
+	if (pb == TIPC_CONS)
+		return;
+
 	spin_lock_bh(&print_lock);
+
 	FORMAT(print_string, len, fmt);
 	printk(print_string);
 
-	for (; pb; pb = pb->next) {
-		if (pb != TIPC_CONS) {
-			printk("\n---- Start of %s log dump ----\n\n",
-			       (pb == TIPC_LOG) ? "global" : "local");
-			printbuf_dump(pb);
-			tipc_printbuf_reset(pb);
-			printk("\n---- End of dump ----\n");
-		}
-		pb_next = pb->next;
-		pb->next = NULL;
-		pb = pb_next;
-	}
+	printk("\n---- Start of %s log dump ----\n\n",
+	       (pb == TIPC_LOG) ? "global" : "local");
+	printbuf_dump(pb);
+	tipc_printbuf_reset(pb);
+	printk("\n---- End of dump ----\n");
+
 	spin_unlock_bh(&print_lock);
 }
 
@@ -368,8 +351,10 @@ int tipc_log_resize(int log_size)
 	if (log_size) {
 		if (log_size < TIPC_PB_MIN_SIZE)
 			log_size = TIPC_PB_MIN_SIZE;
+		res = TIPC_LOG->echo;
 		tipc_printbuf_init(TIPC_LOG, kmalloc(log_size, GFP_ATOMIC),
 				   log_size);
+		TIPC_LOG->echo = res;
 		res = !TIPC_LOG->buf;
 	}
 	spin_unlock_bh(&print_lock);
diff --git a/net/tipc/dbg.h b/net/tipc/dbg.h
index 6b00062..5ef1bc8 100644
--- a/net/tipc/dbg.h
+++ b/net/tipc/dbg.h
@@ -42,14 +42,14 @@
  * @buf: pointer to character array containing print buffer contents
  * @size: size of character array
  * @crs: pointer to first unused space in character array (i.e. final NUL)
- * @next: used to link print buffers when printing to more than one at a time
+ * @echo: echo output to system console if non-zero
  */
 
 struct print_buf {
 	char *buf;
 	u32 size;
 	char *crs;
-	struct print_buf *next;
+	int echo;
 };
 
 #define TIPC_PB_MIN_SIZE 64	/* minimum size for a print buffer's array */
-- 
1.5.3.2

