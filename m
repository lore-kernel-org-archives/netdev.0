From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/20] tipc: rename dbg.[ch] to log.[ch]
Date: Fri, 31 Dec 2010 23:59:24 -0500
Message-ID: <1293857975-30267-10-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53296 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab1AAFAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:07 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

As the first step in removing obsolete debugging code from TIPC the
files that implement TIPC's non-debug-related log buffer subsystem
are renamed to better reflect their true nature.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/Makefile |    2 +-
 net/tipc/core.h   |    2 +-
 net/tipc/dbg.c    |  432 -----------------------------------------------------
 net/tipc/dbg.h    |   67 --------
 net/tipc/link.h   |    2 +-
 net/tipc/log.c    |  428 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/log.h    |   67 ++++++++
 7 files changed, 498 insertions(+), 502 deletions(-)
 delete mode 100644 net/tipc/dbg.c
 delete mode 100644 net/tipc/dbg.h
 create mode 100644 net/tipc/log.c
 create mode 100644 net/tipc/log.h

diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index d41cd11..521d24d 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -8,6 +8,6 @@ tipc-y	+= addr.o bcast.o bearer.o config.o \
 	   core.o handler.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
 	   netlink.o node.o node_subscr.o port.o ref.o  \
-	   socket.o dbg.o eth_media.o
+	   socket.o log.o eth_media.o
 
 # End of file
diff --git a/net/tipc/core.h b/net/tipc/core.h
index c44f955..17f3670 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -59,7 +59,7 @@
 #define TIPC_MOD_VER "2.0.0"
 
 struct tipc_msg;	/* msg.h */
-struct print_buf;	/* dbg.h */
+struct print_buf;	/* log.h */
 
 /*
  * TIPC sanity test macros
diff --git a/net/tipc/dbg.c b/net/tipc/dbg.c
deleted file mode 100644
index 46f51d2..0000000
--- a/net/tipc/dbg.c
+++ /dev/null
@@ -1,432 +0,0 @@
-/*
- * net/tipc/dbg.c: TIPC print buffer routines for debugging
- *
- * Copyright (c) 1996-2006, Ericsson AB
- * Copyright (c) 2005-2007, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#include "core.h"
-#include "config.h"
-#include "dbg.h"
-
-/*
- * TIPC pre-defines the following print buffers:
- *
- * TIPC_NULL : null buffer (i.e. print nowhere)
- * TIPC_CONS : system console
- * TIPC_LOG  : TIPC log buffer
- *
- * Additional user-defined print buffers are also permitted.
- */
-
-static struct print_buf null_buf = { NULL, 0, NULL, 0 };
-struct print_buf *const TIPC_NULL = &null_buf;
-
-static struct print_buf cons_buf = { NULL, 0, NULL, 1 };
-static struct print_buf *const TIPC_CONS = &cons_buf;
-
-static struct print_buf log_buf = { NULL, 0, NULL, 1 };
-struct print_buf *const TIPC_LOG = &log_buf;
-
-/*
- * Locking policy when using print buffers.
- *
- * 1) tipc_printf() uses 'print_lock' to protect against concurrent access to
- * 'print_string' when writing to a print buffer. This also protects against
- * concurrent writes to the print buffer being written to.
- *
- * 2) tipc_dump() and tipc_log_XXX() leverage the aforementioned
- * use of 'print_lock' to protect against all types of concurrent operations
- * on their associated print buffer (not just write operations).
- *
- * Note: All routines of the form tipc_printbuf_XXX() are lock-free, and rely
- * on the caller to prevent simultaneous use of the print buffer(s) being
- * manipulated.
- */
-
-static char print_string[TIPC_PB_MAX_STR];
-static DEFINE_SPINLOCK(print_lock);
-
-static void tipc_printbuf_reset(struct print_buf *pb);
-static int  tipc_printbuf_empty(struct print_buf *pb);
-static void tipc_printbuf_move(struct print_buf *pb_to,
-			       struct print_buf *pb_from);
-
-#define FORMAT(PTR,LEN,FMT) \
-{\
-       va_list args;\
-       va_start(args, FMT);\
-       LEN = vsprintf(PTR, FMT, args);\
-       va_end(args);\
-       *(PTR + LEN) = '\0';\
-}
-
-/**
- * tipc_printbuf_init - initialize print buffer to empty
- * @pb: pointer to print buffer structure
- * @raw: pointer to character array used by print buffer
- * @size: size of character array
- *
- * Note: If the character array is too small (or absent), the print buffer
- * becomes a null device that discards anything written to it.
- */
-
-void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 size)
-{
-	pb->buf = raw;
-	pb->crs = raw;
-	pb->size = size;
-	pb->echo = 0;
-
-	if (size < TIPC_PB_MIN_SIZE) {
-		pb->buf = NULL;
-	} else if (raw) {
-		pb->buf[0] = 0;
-		pb->buf[size - 1] = ~0;
-	}
-}
-
-/**
- * tipc_printbuf_reset - reinitialize print buffer to empty state
- * @pb: pointer to print buffer structure
- */
-
-static void tipc_printbuf_reset(struct print_buf *pb)
-{
-	if (pb->buf) {
-		pb->crs = pb->buf;
-		pb->buf[0] = 0;
-		pb->buf[pb->size - 1] = ~0;
-	}
-}
-
-/**
- * tipc_printbuf_empty - test if print buffer is in empty state
- * @pb: pointer to print buffer structure
- *
- * Returns non-zero if print buffer is empty.
- */
-
-static int tipc_printbuf_empty(struct print_buf *pb)
-{
-	return !pb->buf || (pb->crs == pb->buf);
-}
-
-/**
- * tipc_printbuf_validate - check for print buffer overflow
- * @pb: pointer to print buffer structure
- *
- * Verifies that a print buffer has captured all data written to it.
- * If data has been lost, linearize buffer and prepend an error message
- *
- * Returns length of print buffer data string (including trailing NUL)
- */
-
-int tipc_printbuf_validate(struct print_buf *pb)
-{
-	char *err = "\n\n*** PRINT BUFFER OVERFLOW ***\n\n";
-	char *cp_buf;
-	struct print_buf cb;
-
-	if (!pb->buf)
-		return 0;
-
-	if (pb->buf[pb->size - 1] == 0) {
-		cp_buf = kmalloc(pb->size, GFP_ATOMIC);
-		if (cp_buf) {
-			tipc_printbuf_init(&cb, cp_buf, pb->size);
-			tipc_printbuf_move(&cb, pb);
-			tipc_printbuf_move(pb, &cb);
-			kfree(cp_buf);
-			memcpy(pb->buf, err, strlen(err));
-		} else {
-			tipc_printbuf_reset(pb);
-			tipc_printf(pb, err);
-		}
-	}
-	return pb->crs - pb->buf + 1;
-}
-
-/**
- * tipc_printbuf_move - move print buffer contents to another print buffer
- * @pb_to: pointer to destination print buffer structure
- * @pb_from: pointer to source print buffer structure
- *
- * Current contents of destination print buffer (if any) are discarded.
- * Source print buffer becomes empty if a successful move occurs.
- */
-
-static void tipc_printbuf_move(struct print_buf *pb_to,
-			       struct print_buf *pb_from)
-{
-	int len;
-
-	/* Handle the cases where contents can't be moved */
-
-	if (!pb_to->buf)
-		return;
-
-	if (!pb_from->buf) {
-		tipc_printbuf_reset(pb_to);
-		return;
-	}
-
-	if (pb_to->size < pb_from->size) {
-		strcpy(pb_to->buf, "*** PRINT BUFFER MOVE ERROR ***");
-		pb_to->buf[pb_to->size - 1] = ~0;
-		pb_to->crs = strchr(pb_to->buf, 0);
-		return;
-	}
-
-	/* Copy data from char after cursor to end (if used) */
-
-	len = pb_from->buf + pb_from->size - pb_from->crs - 2;
-	if ((pb_from->buf[pb_from->size - 1] == 0) && (len > 0)) {
-		strcpy(pb_to->buf, pb_from->crs + 1);
-		pb_to->crs = pb_to->buf + len;
-	} else
-		pb_to->crs = pb_to->buf;
-
-	/* Copy data from start to cursor (always) */
-
-	len = pb_from->crs - pb_from->buf;
-	strcpy(pb_to->crs, pb_from->buf);
-	pb_to->crs += len;
-
-	tipc_printbuf_reset(pb_from);
-}
-
-/**
- * tipc_printf - append formatted output to print buffer
- * @pb: pointer to print buffer
- * @fmt: formatted info to be printed
- */
-
-void tipc_printf(struct print_buf *pb, const char *fmt, ...)
-{
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
-
-	spin_unlock_bh(&print_lock);
-}
-
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
-/**
- * tipc_log_resize - change the size of the TIPC log buffer
- * @log_size: print buffer size to use
- */
-
-int tipc_log_resize(int log_size)
-{
-	int res = 0;
-
-	spin_lock_bh(&print_lock);
-	if (TIPC_LOG->buf) {
-		kfree(TIPC_LOG->buf);
-		TIPC_LOG->buf = NULL;
-	}
-	if (log_size) {
-		if (log_size < TIPC_PB_MIN_SIZE)
-			log_size = TIPC_PB_MIN_SIZE;
-		res = TIPC_LOG->echo;
-		tipc_printbuf_init(TIPC_LOG, kmalloc(log_size, GFP_ATOMIC),
-				   log_size);
-		TIPC_LOG->echo = res;
-		res = !TIPC_LOG->buf;
-	}
-	spin_unlock_bh(&print_lock);
-
-	return res;
-}
-
-/**
- * tipc_log_resize_cmd - reconfigure size of TIPC log buffer
- */
-
-struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area, int req_tlv_space)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value != delimit(value, 0, 32768))
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (log size must be 0-32768)");
-	if (tipc_log_resize(value))
-		return tipc_cfg_reply_error_string(
-			"unable to create specified log (log size is now 0)");
-	return tipc_cfg_reply_none();
-}
-
-/**
- * tipc_log_dump - capture TIPC log buffer contents in configuration message
- */
-
-struct sk_buff *tipc_log_dump(void)
-{
-	struct sk_buff *reply;
-
-	spin_lock_bh(&print_lock);
-	if (!TIPC_LOG->buf) {
-		spin_unlock_bh(&print_lock);
-		reply = tipc_cfg_reply_ultra_string("log not activated\n");
-	} else if (tipc_printbuf_empty(TIPC_LOG)) {
-		spin_unlock_bh(&print_lock);
-		reply = tipc_cfg_reply_ultra_string("log is empty\n");
-	}
-	else {
-		struct tlv_desc *rep_tlv;
-		struct print_buf pb;
-		int str_len;
-
-		str_len = min(TIPC_LOG->size, 32768u);
-		spin_unlock_bh(&print_lock);
-		reply = tipc_cfg_reply_alloc(TLV_SPACE(str_len));
-		if (reply) {
-			rep_tlv = (struct tlv_desc *)reply->data;
-			tipc_printbuf_init(&pb, TLV_DATA(rep_tlv), str_len);
-			spin_lock_bh(&print_lock);
-			tipc_printbuf_move(&pb, TIPC_LOG);
-			spin_unlock_bh(&print_lock);
-			str_len = strlen(TLV_DATA(rep_tlv)) + 1;
-			skb_put(reply, TLV_SPACE(str_len));
-			TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-		}
-	}
-	return reply;
-}
-
diff --git a/net/tipc/dbg.h b/net/tipc/dbg.h
deleted file mode 100644
index 3ba6ba8..0000000
--- a/net/tipc/dbg.h
+++ /dev/null
@@ -1,67 +0,0 @@
-/*
- * net/tipc/dbg.h: Include file for TIPC print buffer routines
- *
- * Copyright (c) 1997-2006, Ericsson AB
- * Copyright (c) 2005-2007, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#ifndef _TIPC_DBG_H
-#define _TIPC_DBG_H
-
-/**
- * struct print_buf - TIPC print buffer structure
- * @buf: pointer to character array containing print buffer contents
- * @size: size of character array
- * @crs: pointer to first unused space in character array (i.e. final NUL)
- * @echo: echo output to system console if non-zero
- */
-
-struct print_buf {
-	char *buf;
-	u32 size;
-	char *crs;
-	int echo;
-};
-
-#define TIPC_PB_MIN_SIZE 64	/* minimum size for a print buffer's array */
-#define TIPC_PB_MAX_STR 512	/* max printable string (with trailing NUL) */
-
-void tipc_printbuf_init(struct print_buf *pb, char *buf, u32 size);
-int  tipc_printbuf_validate(struct print_buf *pb);
-
-int tipc_log_resize(int log_size);
-
-struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area,
-				    int req_tlv_space);
-struct sk_buff *tipc_log_dump(void);
-
-#endif
diff --git a/net/tipc/link.h b/net/tipc/link.h
index c562888..eeb0c01 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -37,7 +37,7 @@
 #ifndef _TIPC_LINK_H
 #define _TIPC_LINK_H
 
-#include "dbg.h"
+#include "log.h"
 #include "msg.h"
 #include "node.h"
 
diff --git a/net/tipc/log.c b/net/tipc/log.c
new file mode 100644
index 0000000..9d99f70
--- /dev/null
+++ b/net/tipc/log.c
@@ -0,0 +1,428 @@
+/*
+ * net/tipc/log.c: TIPC print buffer routines for debugging
+ *
+ * Copyright (c) 1996-2006, Ericsson AB
+ * Copyright (c) 2005-2007, Wind River Systems
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "core.h"
+#include "config.h"
+#include "log.h"
+
+/*
+ * TIPC pre-defines the following print buffers:
+ *
+ * TIPC_NULL : null buffer (i.e. print nowhere)
+ * TIPC_CONS : system console
+ * TIPC_LOG  : TIPC log buffer
+ *
+ * Additional user-defined print buffers are also permitted.
+ */
+
+static struct print_buf null_buf = { NULL, 0, NULL, 0 };
+struct print_buf *const TIPC_NULL = &null_buf;
+
+static struct print_buf cons_buf = { NULL, 0, NULL, 1 };
+static struct print_buf *const TIPC_CONS = &cons_buf;
+
+static struct print_buf log_buf = { NULL, 0, NULL, 1 };
+struct print_buf *const TIPC_LOG = &log_buf;
+
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
+static void tipc_printbuf_reset(struct print_buf *pb);
+static int  tipc_printbuf_empty(struct print_buf *pb);
+static void tipc_printbuf_move(struct print_buf *pb_to,
+			       struct print_buf *pb_from);
+
+#define FORMAT(PTR, LEN, FMT) \
+{\
+	va_list args;\
+	va_start(args, FMT);\
+	LEN = vsprintf(PTR, FMT, args);\
+	va_end(args);\
+	*(PTR + LEN) = '\0';\
+}
+
+/**
+ * tipc_printbuf_init - initialize print buffer to empty
+ * @pb: pointer to print buffer structure
+ * @raw: pointer to character array used by print buffer
+ * @size: size of character array
+ *
+ * Note: If the character array is too small (or absent), the print buffer
+ * becomes a null device that discards anything written to it.
+ */
+
+void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 size)
+{
+	pb->buf = raw;
+	pb->crs = raw;
+	pb->size = size;
+	pb->echo = 0;
+
+	if (size < TIPC_PB_MIN_SIZE) {
+		pb->buf = NULL;
+	} else if (raw) {
+		pb->buf[0] = 0;
+		pb->buf[size - 1] = ~0;
+	}
+}
+
+/**
+ * tipc_printbuf_reset - reinitialize print buffer to empty state
+ * @pb: pointer to print buffer structure
+ */
+
+static void tipc_printbuf_reset(struct print_buf *pb)
+{
+	if (pb->buf) {
+		pb->crs = pb->buf;
+		pb->buf[0] = 0;
+		pb->buf[pb->size - 1] = ~0;
+	}
+}
+
+/**
+ * tipc_printbuf_empty - test if print buffer is in empty state
+ * @pb: pointer to print buffer structure
+ *
+ * Returns non-zero if print buffer is empty.
+ */
+
+static int tipc_printbuf_empty(struct print_buf *pb)
+{
+	return !pb->buf || (pb->crs == pb->buf);
+}
+
+/**
+ * tipc_printbuf_validate - check for print buffer overflow
+ * @pb: pointer to print buffer structure
+ *
+ * Verifies that a print buffer has captured all data written to it.
+ * If data has been lost, linearize buffer and prepend an error message
+ *
+ * Returns length of print buffer data string (including trailing NUL)
+ */
+
+int tipc_printbuf_validate(struct print_buf *pb)
+{
+	char *err = "\n\n*** PRINT BUFFER OVERFLOW ***\n\n";
+	char *cp_buf;
+	struct print_buf cb;
+
+	if (!pb->buf)
+		return 0;
+
+	if (pb->buf[pb->size - 1] == 0) {
+		cp_buf = kmalloc(pb->size, GFP_ATOMIC);
+		if (cp_buf) {
+			tipc_printbuf_init(&cb, cp_buf, pb->size);
+			tipc_printbuf_move(&cb, pb);
+			tipc_printbuf_move(pb, &cb);
+			kfree(cp_buf);
+			memcpy(pb->buf, err, strlen(err));
+		} else {
+			tipc_printbuf_reset(pb);
+			tipc_printf(pb, err);
+		}
+	}
+	return pb->crs - pb->buf + 1;
+}
+
+/**
+ * tipc_printbuf_move - move print buffer contents to another print buffer
+ * @pb_to: pointer to destination print buffer structure
+ * @pb_from: pointer to source print buffer structure
+ *
+ * Current contents of destination print buffer (if any) are discarded.
+ * Source print buffer becomes empty if a successful move occurs.
+ */
+
+static void tipc_printbuf_move(struct print_buf *pb_to,
+			       struct print_buf *pb_from)
+{
+	int len;
+
+	/* Handle the cases where contents can't be moved */
+
+	if (!pb_to->buf)
+		return;
+
+	if (!pb_from->buf) {
+		tipc_printbuf_reset(pb_to);
+		return;
+	}
+
+	if (pb_to->size < pb_from->size) {
+		strcpy(pb_to->buf, "*** PRINT BUFFER MOVE ERROR ***");
+		pb_to->buf[pb_to->size - 1] = ~0;
+		pb_to->crs = strchr(pb_to->buf, 0);
+		return;
+	}
+
+	/* Copy data from char after cursor to end (if used) */
+
+	len = pb_from->buf + pb_from->size - pb_from->crs - 2;
+	if ((pb_from->buf[pb_from->size - 1] == 0) && (len > 0)) {
+		strcpy(pb_to->buf, pb_from->crs + 1);
+		pb_to->crs = pb_to->buf + len;
+	} else
+		pb_to->crs = pb_to->buf;
+
+	/* Copy data from start to cursor (always) */
+
+	len = pb_from->crs - pb_from->buf;
+	strcpy(pb_to->crs, pb_from->buf);
+	pb_to->crs += len;
+
+	tipc_printbuf_reset(pb_from);
+}
+
+/**
+ * tipc_printf - append formatted output to print buffer
+ * @pb: pointer to print buffer
+ * @fmt: formatted info to be printed
+ */
+
+void tipc_printf(struct print_buf *pb, const char *fmt, ...)
+{
+	int chars_to_add;
+	int chars_left;
+	char save_char;
+
+	spin_lock_bh(&print_lock);
+
+	FORMAT(print_string, chars_to_add, fmt);
+	if (chars_to_add >= TIPC_PB_MAX_STR)
+		strcpy(print_string, "*** PRINT BUFFER STRING TOO LONG ***");
+
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
+		}
+	}
+
+	if (pb->echo)
+		printk("%s", print_string);
+
+	spin_unlock_bh(&print_lock);
+}
+
+#ifdef CONFIG_TIPC_DEBUG
+
+/**
+ * print_to_console - write string of bytes to console in multiple chunks
+ */
+
+static void print_to_console(char *crs, int len)
+{
+	int rest = len;
+
+	while (rest > 0) {
+		int sz = rest < TIPC_PB_MAX_STR ? rest : TIPC_PB_MAX_STR;
+		char c = crs[sz];
+
+		crs[sz] = 0;
+		printk((const char *)crs);
+		crs[sz] = c;
+		rest -= sz;
+		crs += sz;
+	}
+}
+
+/**
+ * printbuf_dump - write print buffer contents to console
+ */
+
+static void printbuf_dump(struct print_buf *pb)
+{
+	int len;
+
+	if (!pb->buf) {
+		printk("*** PRINT BUFFER NOT ALLOCATED ***");
+		return;
+	}
+
+	/* Dump print buffer from char after cursor to end (if used) */
+
+	len = pb->buf + pb->size - pb->crs - 2;
+	if ((pb->buf[pb->size - 1] == 0) && (len > 0))
+		print_to_console(pb->crs + 1, len);
+
+	/* Dump print buffer from start to cursor (always) */
+
+	len = pb->crs - pb->buf;
+	print_to_console(pb->buf, len);
+}
+
+/**
+ * tipc_dump_dbg - dump (non-console) print buffer to console
+ * @pb: pointer to print buffer
+ */
+
+void tipc_dump_dbg(struct print_buf *pb, const char *fmt, ...)
+{
+	int len;
+
+	if (pb == TIPC_CONS)
+		return;
+
+	spin_lock_bh(&print_lock);
+
+	FORMAT(print_string, len, fmt);
+	printk(print_string);
+
+	printk("\n---- Start of %s log dump ----\n\n",
+	       (pb == TIPC_LOG) ? "global" : "local");
+	printbuf_dump(pb);
+	tipc_printbuf_reset(pb);
+	printk("\n---- End of dump ----\n");
+
+	spin_unlock_bh(&print_lock);
+}
+
+#endif
+
+/**
+ * tipc_log_resize - change the size of the TIPC log buffer
+ * @log_size: print buffer size to use
+ */
+
+int tipc_log_resize(int log_size)
+{
+	int res = 0;
+
+	spin_lock_bh(&print_lock);
+	kfree(TIPC_LOG->buf);
+	TIPC_LOG->buf = NULL;
+	if (log_size) {
+		if (log_size < TIPC_PB_MIN_SIZE)
+			log_size = TIPC_PB_MIN_SIZE;
+		res = TIPC_LOG->echo;
+		tipc_printbuf_init(TIPC_LOG, kmalloc(log_size, GFP_ATOMIC),
+				   log_size);
+		TIPC_LOG->echo = res;
+		res = !TIPC_LOG->buf;
+	}
+	spin_unlock_bh(&print_lock);
+
+	return res;
+}
+
+/**
+ * tipc_log_resize_cmd - reconfigure size of TIPC log buffer
+ */
+
+struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area, int req_tlv_space)
+{
+	u32 value;
+
+	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
+		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
+
+	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
+	if (value != delimit(value, 0, 32768))
+		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
+						   " (log size must be 0-32768)");
+	if (tipc_log_resize(value))
+		return tipc_cfg_reply_error_string(
+			"unable to create specified log (log size is now 0)");
+	return tipc_cfg_reply_none();
+}
+
+/**
+ * tipc_log_dump - capture TIPC log buffer contents in configuration message
+ */
+
+struct sk_buff *tipc_log_dump(void)
+{
+	struct sk_buff *reply;
+
+	spin_lock_bh(&print_lock);
+	if (!TIPC_LOG->buf) {
+		spin_unlock_bh(&print_lock);
+		reply = tipc_cfg_reply_ultra_string("log not activated\n");
+	} else if (tipc_printbuf_empty(TIPC_LOG)) {
+		spin_unlock_bh(&print_lock);
+		reply = tipc_cfg_reply_ultra_string("log is empty\n");
+	} else {
+		struct tlv_desc *rep_tlv;
+		struct print_buf pb;
+		int str_len;
+
+		str_len = min(TIPC_LOG->size, 32768u);
+		spin_unlock_bh(&print_lock);
+		reply = tipc_cfg_reply_alloc(TLV_SPACE(str_len));
+		if (reply) {
+			rep_tlv = (struct tlv_desc *)reply->data;
+			tipc_printbuf_init(&pb, TLV_DATA(rep_tlv), str_len);
+			spin_lock_bh(&print_lock);
+			tipc_printbuf_move(&pb, TIPC_LOG);
+			spin_unlock_bh(&print_lock);
+			str_len = strlen(TLV_DATA(rep_tlv)) + 1;
+			skb_put(reply, TLV_SPACE(str_len));
+			TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
+		}
+	}
+	return reply;
+}
diff --git a/net/tipc/log.h b/net/tipc/log.h
new file mode 100644
index 0000000..f4343bb
--- /dev/null
+++ b/net/tipc/log.h
@@ -0,0 +1,67 @@
+/*
+ * net/tipc/log.h: Include file for TIPC print buffer routines
+ *
+ * Copyright (c) 1997-2006, Ericsson AB
+ * Copyright (c) 2005-2007, Wind River Systems
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _TIPC_DBG_H
+#define _TIPC_DBG_H
+
+/**
+ * struct print_buf - TIPC print buffer structure
+ * @buf: pointer to character array containing print buffer contents
+ * @size: size of character array
+ * @crs: pointer to first unused space in character array (i.e. final NUL)
+ * @echo: echo output to system console if non-zero
+ */
+
+struct print_buf {
+	char *buf;
+	u32 size;
+	char *crs;
+	int echo;
+};
+
+#define TIPC_PB_MIN_SIZE 64	/* minimum size for a print buffer's array */
+#define TIPC_PB_MAX_STR 512	/* max printable string (with trailing NUL) */
+
+void tipc_printbuf_init(struct print_buf *pb, char *buf, u32 size);
+int  tipc_printbuf_validate(struct print_buf *pb);
+
+int tipc_log_resize(int log_size);
+
+struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area,
+				    int req_tlv_space);
+struct sk_buff *tipc_log_dump(void);
+
+#endif
-- 
1.7.3.3

