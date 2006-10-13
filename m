From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 2/14] [TIPC] Debug print buffer enhancements and fixes
Date: Fri, 13 Oct 2006 13:37:43 +0200
Message-ID: <11607394754031-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:40352 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751380AbWJMLiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:00 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This change modifies TIPC's print buffer code as follows:
1) Now supports small print buffers (min. size reduced from 512 bytes to 64)
2) Now uses TIPC_NULL print buffer structure to indicate null device
   instead of NULL pointer (this simplified error handling)
3) Fixed misuse of console buffer structure by tipc_dump()
4) Added and corrected comments in various places

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/core.h |   16 +++---
 net/tipc/dbg.c  |  136 ++++++++++++++++++++++++++++++++++++-------------------
 net/tipc/dbg.h  |   15 +++++-
 3 files changed, 110 insertions(+), 57 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 762aac2..31331e8 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -65,7 +65,7 @@ #include <linux/vmalloc.h>
 #define assert(i)  BUG_ON(!(i))
 
 struct tipc_msg;
-extern struct print_buf *TIPC_CONS, *TIPC_LOG;
+extern struct print_buf *TIPC_NULL, *TIPC_CONS, *TIPC_LOG;
 extern struct print_buf *TIPC_TEE(struct print_buf *, struct print_buf *);
 void tipc_msg_print(struct print_buf*,struct tipc_msg *,const char*);
 void tipc_printf(struct print_buf *, const char *fmt, ...);
@@ -94,11 +94,11 @@ #define dump(fmt, arg...) do {if (DBG_OU
  * here, or on a per .c file basis, by redefining these symbols.  The following
  * print buffer options are available:
  *
- * NULL				: Output to null print buffer (i.e. print nowhere)
- * TIPC_CONS			: Output to system console
- * TIPC_LOG			: Output to TIPC log buffer 
- * &buf				: Output to user-defined buffer (struct print_buf *)
- * TIPC_TEE(&buf_a,&buf_b)	: Output to two print buffers (eg. TIPC_TEE(TIPC_CONS,TIPC_LOG) )
+ * TIPC_NULL		   : null buffer (i.e. print nowhere)
+ * TIPC_CONS		   : system console
+ * TIPC_LOG		   : TIPC log buffer 
+ * &buf			   : user-defined buffer (struct print_buf *)
+ * TIPC_TEE(&buf_a,&buf_b) : list of buffers (eg. TIPC_TEE(TIPC_CONS,TIPC_LOG))
  */
 
 #ifndef TIPC_OUTPUT
@@ -106,7 +106,7 @@ #define TIPC_OUTPUT TIPC_TEE(TIPC_CONS,T
 #endif
 
 #ifndef DBG_OUTPUT
-#define DBG_OUTPUT NULL
+#define DBG_OUTPUT TIPC_NULL
 #endif
 
 #else
@@ -136,7 +136,7 @@ #undef  TIPC_OUTPUT
 #define TIPC_OUTPUT TIPC_CONS
 
 #undef  DBG_OUTPUT
-#define DBG_OUTPUT NULL
+#define DBG_OUTPUT TIPC_NULL
 
 #endif			  
 
diff --git a/net/tipc/dbg.c b/net/tipc/dbg.c
index 5513065..48e33ab 100644
--- a/net/tipc/dbg.c
+++ b/net/tipc/dbg.c
@@ -1,8 +1,8 @@
 /*
- * net/tipc/dbg.c: TIPC print buffer routines for debuggign
+ * net/tipc/dbg.c: TIPC print buffer routines for debugging
  * 
  * Copyright (c) 1996-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -38,11 +38,12 @@ #include "core.h"
 #include "config.h"
 #include "dbg.h"
 
-#define MAX_STRING 512
-
-static char print_string[MAX_STRING];
+static char print_string[TIPC_PB_MAX_STR];
 static DEFINE_SPINLOCK(print_lock);
 
+static struct print_buf null_buf = { NULL, 0, NULL, NULL };
+struct print_buf *TIPC_NULL = &null_buf;
+
 static struct print_buf cons_buf = { NULL, 0, NULL, NULL };
 struct print_buf *TIPC_CONS = &cons_buf;
 
@@ -62,68 +63,83 @@ #define FORMAT(PTR,LEN,FMT) \
 /*
  * Locking policy when using print buffers.
  *
- * 1) Routines of the form printbuf_XXX() rely on the caller to prevent
- *    simultaneous use of the print buffer(s) being manipulated.
- * 2) tipc_printf() uses 'print_lock' to prevent simultaneous use of
- *    'print_string' and to protect its print buffer(s).
- * 3) TIPC_TEE() uses 'print_lock' to protect its print buffer(s).
- * 4) Routines of the form log_XXX() uses 'print_lock' to protect TIPC_LOG.
+ * The following routines use 'print_lock' for protection:
+ * 1) tipc_printf()  - to protect its print buffer(s) and 'print_string'
+ * 2) TIPC_TEE()     - to protect its print buffer(s)
+ * 3) tipc_dump()    - to protect its print buffer(s) and 'print_string'
+ * 4) tipc_log_XXX() - to protect TIPC_LOG
+ *
+ * All routines of the form tipc_printbuf_XXX() rely on the caller to prevent
+ * simultaneous use of the print buffer(s) being manipulated.
  */
 
 /**
  * tipc_printbuf_init - initialize print buffer to empty
+ * @pb: pointer to print buffer structure
+ * @raw: pointer to character array used by print buffer
+ * @size: size of character array
+ * 
+ * Makes the print buffer a null device that discards anything written to it
+ * if the character array is too small (or absent).
  */
 
-void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 sz)
+void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 size)
 {
-	if (!pb || !raw || (sz < (MAX_STRING + 1)))
-		return;
-
-	pb->crs = pb->buf = raw;
-	pb->size = sz;
+	pb->buf = raw;
+	pb->crs = raw;
+	pb->size = size;
 	pb->next = NULL;
-	pb->buf[0] = 0;
-	pb->buf[sz-1] = ~0;
+
+	if (size < TIPC_PB_MIN_SIZE) {
+		pb->buf = NULL;
+	} else if (raw) {
+		pb->buf[0] = 0;
+		pb->buf[size-1] = ~0;
+	}
 }
 
 /**
  * tipc_printbuf_reset - reinitialize print buffer to empty state
+ * @pb: pointer to print buffer structure
  */
 
 void tipc_printbuf_reset(struct print_buf *pb)
 {
-	if (pb && pb->buf)
-		tipc_printbuf_init(pb, pb->buf, pb->size);
+	tipc_printbuf_init(pb, pb->buf, pb->size);
 }
 
 /**
  * tipc_printbuf_empty - test if print buffer is in empty state
+ * @pb: pointer to print buffer structure
+ * 
+ * Returns non-zero if print buffer is empty.
  */
 
 int tipc_printbuf_empty(struct print_buf *pb)
 {
-	return (!pb || !pb->buf || (pb->crs == pb->buf));
+	return (!pb->buf || (pb->crs == pb->buf));
 }
 
 /**
  * tipc_printbuf_validate - check for print buffer overflow
+ * @pb: pointer to print buffer structure
  * 
  * Verifies that a print buffer has captured all data written to it. 
  * If data has been lost, linearize buffer and prepend an error message
  * 
- * Returns length of print buffer data string (including trailing NULL)
+ * Returns length of print buffer data string (including trailing NUL)
  */
 
 int tipc_printbuf_validate(struct print_buf *pb)
 {
-        char *err = "             *** PRINT BUFFER WRAPPED AROUND ***\n";
+        char *err = "\n\n*** PRINT BUFFER OVERFLOW ***\n\n";
         char *cp_buf;
         struct print_buf cb;
 
-	if (!pb || !pb->buf)
+	if (!pb->buf)
 		return 0;
 
-	if (pb->buf[pb->size - 1] == '\0') {
+	if (pb->buf[pb->size - 1] == 0) {
                 cp_buf = kmalloc(pb->size, GFP_ATOMIC);
                 if (cp_buf != NULL){
                         tipc_printbuf_init(&cb, cp_buf, pb->size);
@@ -141,6 +157,8 @@ int tipc_printbuf_validate(struct print_
 
 /**
  * tipc_printbuf_move - move print buffer contents to another print buffer
+ * @pb_to: pointer to destination print buffer structure
+ * @pb_from: pointer to source print buffer structure
  * 
  * Current contents of destination print buffer (if any) are discarded.
  * Source print buffer becomes empty if a successful move occurs.
@@ -152,21 +170,22 @@ void tipc_printbuf_move(struct print_buf
 
 	/* Handle the cases where contents can't be moved */
 
-	if (!pb_to || !pb_to->buf)
+	if (!pb_to->buf)
 		return;
 
-	if (!pb_from || !pb_from->buf) {
+	if (!pb_from->buf) {
 		tipc_printbuf_reset(pb_to);
 		return;
 	}
 
 	if (pb_to->size < pb_from->size) {
 		tipc_printbuf_reset(pb_to);
-		tipc_printf(pb_to, "*** PRINT BUFFER OVERFLOW ***");
+		tipc_printf(pb_to, "*** PRINT BUFFER MOVE ERROR ***");
 		return;
 	}
 
 	/* Copy data from char after cursor to end (if used) */
+
 	len = pb_from->buf + pb_from->size - pb_from->crs - 2;
 	if ((pb_from->buf[pb_from->size-1] == 0) && (len > 0)) {
 		strcpy(pb_to->buf, pb_from->crs + 1);
@@ -175,6 +194,7 @@ void tipc_printbuf_move(struct print_buf
 		pb_to->crs = pb_to->buf;
 
 	/* Copy data from start to cursor (always) */
+
 	len = pb_from->crs - pb_from->buf;
 	strcpy(pb_to->crs, pb_from->buf);
 	pb_to->crs += len;
@@ -184,6 +204,8 @@ void tipc_printbuf_move(struct print_buf
 
 /**
  * tipc_printf - append formatted output to print buffer chain
+ * @pb: pointer to chain of print buffers (may be NULL)
+ * @fmt: formatted info to be printed
  */
 
 void tipc_printf(struct print_buf *pb, const char *fmt, ...)
@@ -195,8 +217,8 @@ void tipc_printf(struct print_buf *pb, c
 
 	spin_lock_bh(&print_lock);
 	FORMAT(print_string, chars_to_add, fmt);
-	if (chars_to_add >= MAX_STRING)
-		strcpy(print_string, "*** STRING TOO LONG ***");
+	if (chars_to_add >= TIPC_PB_MAX_STR)
+		strcpy(print_string, "*** PRINT BUFFER STRING TOO LONG ***");
 
 	while (pb) {
 		if (pb == TIPC_CONS)
@@ -206,6 +228,10 @@ void tipc_printf(struct print_buf *pb, c
 			if (chars_to_add <= chars_left) {
 				strcpy(pb->crs, print_string);
 				pb->crs += chars_to_add;
+			} else if (chars_to_add >= (pb->size - 1)) {
+				strcpy(pb->buf, print_string + chars_to_add + 1
+				       - pb->size);
+				pb->crs = pb->buf + pb->size - 1;
 			} else {
 				strcpy(pb->buf, print_string + chars_left);
                                 save_char = print_string[chars_left];
@@ -224,6 +250,10 @@ void tipc_printf(struct print_buf *pb, c
 
 /**
  * TIPC_TEE - perform next output operation on both print buffers  
+ * @b0: pointer to chain of print buffers (may be NULL)
+ * @b1: pointer to print buffer to add to chain
+ *
+ * Returns pointer to print buffer chain.
  */
 
 struct print_buf *TIPC_TEE(struct print_buf *b0, struct print_buf *b1)
@@ -232,8 +262,6 @@ struct print_buf *TIPC_TEE(struct print_
 
 	if (!b0 || (b0 == b1))
 		return b1;
-	if (!b1)
-		return b0;
 
 	spin_lock_bh(&print_lock);
 	while (pb->next) {
@@ -256,7 +284,7 @@ static void print_to_console(char *crs, 
 	int rest = len;
 
 	while (rest > 0) {
-		int sz = rest < MAX_STRING ? rest : MAX_STRING;
+		int sz = rest < TIPC_PB_MAX_STR ? rest : TIPC_PB_MAX_STR;
 		char c = crs[sz];
 
 		crs[sz] = 0;
@@ -275,36 +303,48 @@ static void printbuf_dump(struct print_b
 {
 	int len;
 
+	if (!pb->buf) {
+		printk("*** PRINT BUFFER NOT ALLOCATED ***");
+		return;
+	}
+
 	/* Dump print buffer from char after cursor to end (if used) */
+
 	len = pb->buf + pb->size - pb->crs - 2;
 	if ((pb->buf[pb->size - 1] == 0) && (len > 0))
 		print_to_console(pb->crs + 1, len);
 
 	/* Dump print buffer from start to cursor (always) */
+
 	len = pb->crs - pb->buf;
 	print_to_console(pb->buf, len);
 }
 
 /**
  * tipc_dump - dump non-console print buffer(s) to console
+ * @pb: pointer to chain of print buffers
  */
 
 void tipc_dump(struct print_buf *pb, const char *fmt, ...)
 {
+	struct print_buf *pb_next;
 	int len;
 
 	spin_lock_bh(&print_lock);
-	FORMAT(TIPC_CONS->buf, len, fmt);
-	printk(TIPC_CONS->buf);
+	FORMAT(print_string, len, fmt);
+	printk(print_string);
 
 	for (; pb; pb = pb->next) {
-		if (pb == TIPC_CONS)
-			continue;
-		printk("\n---- Start of dump,%s log ----\n\n", 
-		       (pb == TIPC_LOG) ? "global" : "local");
-		printbuf_dump(pb);
-		tipc_printbuf_reset(pb);
-		printk("\n-------- End of dump --------\n");
+		if (pb != TIPC_CONS) {
+			printk("\n---- Start of %s log dump ----\n\n", 
+			       (pb == TIPC_LOG) ? "global" : "local");
+			printbuf_dump(pb);
+			tipc_printbuf_reset(pb);
+			printk("\n---- End of dump ----\n");
+		}
+		pb_next = pb->next;
+		pb->next = NULL;
+		pb = pb_next;
 	}
 	spin_unlock_bh(&print_lock);
 }
@@ -324,7 +364,8 @@ void tipc_log_stop(void)
 }
 
 /**
- * tipc_log_reinit - set TIPC log print buffer to specified size
+ * tipc_log_reinit - (re)initialize TIPC log print buffer
+ * @log_size: print buffer size to use
  */
 
 void tipc_log_reinit(int log_size)
@@ -332,10 +373,11 @@ void tipc_log_reinit(int log_size)
 	tipc_log_stop();
 
 	if (log_size) {
-		if (log_size <= MAX_STRING)
-			log_size = MAX_STRING + 1;
+		if (log_size < TIPC_PB_MIN_SIZE)
+			log_size = TIPC_PB_MIN_SIZE;
 		spin_lock_bh(&print_lock);
-		tipc_printbuf_init(TIPC_LOG, kmalloc(log_size, GFP_ATOMIC), log_size);
+		tipc_printbuf_init(TIPC_LOG, kmalloc(log_size, GFP_ATOMIC), 
+				   log_size);
 		spin_unlock_bh(&print_lock);
 	}
 }
diff --git a/net/tipc/dbg.h b/net/tipc/dbg.h
index 227f050..382afdc 100644
--- a/net/tipc/dbg.h
+++ b/net/tipc/dbg.h
@@ -2,7 +2,7 @@
  * net/tipc/dbg.h: Include file for TIPC print buffer routines
  * 
  * Copyright (c) 1997-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -37,6 +37,14 @@
 #ifndef _TIPC_DBG_H
 #define _TIPC_DBG_H
 
+/**
+ * struct print_buf - TIPC print buffer structure
+ * @buf: pointer to character array containing print buffer contents
+ * @size: size of character array
+ * @crs: pointer to first unused space in character array (i.e. final NUL)
+ * @next: used to link print buffers when printing to more than one at a time 
+ */
+ 
 struct print_buf {
 	char *buf;
 	u32 size;
@@ -44,7 +52,10 @@ struct print_buf {
 	struct print_buf *next;
 };
 
-void tipc_printbuf_init(struct print_buf *pb, char *buf, u32 sz);
+#define TIPC_PB_MIN_SIZE 64	/* minimum size for a print buffer's array */
+#define TIPC_PB_MAX_STR 512	/* max printable string (with trailing NUL) */
+
+void tipc_printbuf_init(struct print_buf *pb, char *buf, u32 size);
 void tipc_printbuf_reset(struct print_buf *pb);
 int  tipc_printbuf_empty(struct print_buf *pb);
 int  tipc_printbuf_validate(struct print_buf *pb);
-- 
1.4.1

