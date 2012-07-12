From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 8/8] tipc: remove print_buf and deprecated log buffer code
Date: Thu, 12 Jul 2012 12:40:01 -0400
Message-ID: <1342111201-9426-9-git-send-email-paul.gortmaker@windriver.com>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43564 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161344Ab2GLQkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:40:32 -0400
In-Reply-To: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

The internal log buffer handling functions can now safely be
removed since there is no code using it anymore.  Requests to
interact with the internal tipc log buffer over netlink (in
config.c) will report 'obsolete command'.

This represents the final removal of any references to a
struct print_buf, and the removal of the struct itself.
We also get rid of a TIPC specific Kconfig in the process.

Finally, log.h is removed since it is not needed anymore.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |    4 +-
 net/tipc/Kconfig            |   13 ---
 net/tipc/config.c           |    8 +-
 net/tipc/core.c             |    7 --
 net/tipc/core.h             |   27 ------
 net/tipc/link.h             |    1 -
 net/tipc/log.c              |  213 -------------------------------------------
 net/tipc/log.h              |   66 --------------
 8 files changed, 4 insertions(+), 335 deletions(-)
 delete mode 100644 net/tipc/log.h

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 9730b0e..c989284 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -102,8 +102,8 @@
 #define  TIPC_CMD_SET_LINK_TOL      0x4107    /* tx link_config, rx none */
 #define  TIPC_CMD_SET_LINK_PRI      0x4108    /* tx link_config, rx none */
 #define  TIPC_CMD_SET_LINK_WINDOW   0x4109    /* tx link_config, rx none */
-#define  TIPC_CMD_SET_LOG_SIZE      0x410A    /* tx unsigned, rx none */
-#define  TIPC_CMD_DUMP_LOG          0x410B    /* tx none, rx ultra_string */
+#define  TIPC_CMD_SET_LOG_SIZE      0x410A    /* obsoleted */
+#define  TIPC_CMD_DUMP_LOG          0x410B    /* obsoleted */
 #define  TIPC_CMD_RESET_LINK_STATS  0x410C    /* tx link_name, rx none */
 
 /*
diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index e24519a..5854601 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -41,17 +41,4 @@ config TIPC_PORTS
 	  Setting this to a smaller value saves some memory,
 	  setting it to higher allows for more ports.
 
-config TIPC_LOG
-	int "Size of log buffer"
-	depends on TIPC_ADVANCED
-	range 0 32768
-	default "0"
-	help
-	  Size (in bytes) of TIPC's internal log buffer, which records the
-	  occurrence of significant events.  Can range from 0 to 32768 bytes;
-	  default is 0.
-
-	  There is no need to enable the log buffer unless the node will be
-	  managed remotely via TIPC.
-
 endif # TIPC
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 65057e9..7cbff85 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -334,12 +334,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SHOW_PORTS:
 		rep_tlv_buf = tipc_port_get_ports();
 		break;
-	case TIPC_CMD_SET_LOG_SIZE:
-		rep_tlv_buf = tipc_log_resize_cmd(req_tlv_area, req_tlv_space);
-		break;
-	case TIPC_CMD_DUMP_LOG:
-		rep_tlv_buf = tipc_log_dump();
-		break;
 	case TIPC_CMD_SHOW_STATS:
 		rep_tlv_buf = tipc_show_stats();
 		break;
@@ -399,6 +393,8 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_CLUSTERS:
 	case TIPC_CMD_SET_MAX_NODES:
 	case TIPC_CMD_GET_MAX_NODES:
+	case TIPC_CMD_SET_LOG_SIZE:
+	case TIPC_CMD_DUMP_LOG:
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 							  " (obsolete command)");
 		break;
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 019d054..a6deab4 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -47,9 +47,6 @@
 #define CONFIG_TIPC_PORTS 8191
 #endif
 
-#ifndef CONFIG_TIPC_LOG
-#define CONFIG_TIPC_LOG 0
-#endif
 
 /* global variables used by multiple sub-systems within TIPC */
 int tipc_random;
@@ -125,7 +122,6 @@ static void tipc_core_stop(void)
 	tipc_nametbl_stop();
 	tipc_ref_table_stop();
 	tipc_socket_stop();
-	tipc_log_resize(0);
 }
 
 /**
@@ -161,9 +157,6 @@ static int __init tipc_init(void)
 {
 	int res;
 
-	if (tipc_log_resize(CONFIG_TIPC_LOG) != 0)
-		pr_warn("TIPC: Unable to create log buffer\n");
-
 	pr_info("TIPC: Activated (version " TIPC_MOD_VER ")\n");
 
 	tipc_own_addr = 0;
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 7ba74ba..253e53a 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -61,37 +61,10 @@
 #define ULTRA_STRING_MAX_LEN 32768
 
 struct tipc_msg;	/* msg.h */
-struct print_buf;	/* log.h */
-
-/*
- * TIPC system monitoring code
- */
-
-/*
- * TIPC's print buffer subsystem supports the following print buffers:
- *
- * TIPC_NULL : null buffer (i.e. print nowhere)
- * TIPC_CONS : system console
- * TIPC_LOG  : TIPC log buffer
- * &buf	     : user-defined buffer (struct print_buf *)
- *
- * Note: TIPC_LOG is configured to echo its output to the system console;
- *       user-defined buffers can be configured to do the same thing.
- */
-extern struct print_buf *const TIPC_NULL;
-extern struct print_buf *const TIPC_CONS;
-extern struct print_buf *const TIPC_LOG;
 
 int tipc_snprintf(char *buf, int len, const char *fmt, ...);
 
 /*
- * TIPC_OUTPUT is the destination print buffer for system messages.
- */
-#ifndef TIPC_OUTPUT
-#define TIPC_OUTPUT TIPC_LOG
-#endif
-
-/*
  * TIPC-specific error codes
  */
 #define ELINKCONG EAGAIN	/* link congestion <=> resource unavailable */
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 8024a56..6e92112 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -37,7 +37,6 @@
 #ifndef _TIPC_LINK_H
 #define _TIPC_LINK_H
 
-#include "log.h"
 #include "msg.h"
 #include "node.h"
 
diff --git a/net/tipc/log.c b/net/tipc/log.c
index fa7ce92..abef644 100644
--- a/net/tipc/log.c
+++ b/net/tipc/log.c
@@ -36,138 +36,6 @@
 
 #include "core.h"
 #include "config.h"
-#include "log.h"
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
-static struct print_buf null_buf = { NULL, 0, NULL, 0 };
-struct print_buf *const TIPC_NULL = &null_buf;
-
-static struct print_buf cons_buf = { NULL, 0, NULL, 1 };
-struct print_buf *const TIPC_CONS = &cons_buf;
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
- * 2) tipc_log_XXX() leverages the aforementioned use of 'print_lock' to
- * protect against all types of concurrent operations on their associated
- * print buffer (not just write operations).
- *
- * Note: All routines of the form tipc_printbuf_XXX() are lock-free, and rely
- * on the caller to prevent simultaneous use of the print buffer(s) being
- * manipulated.
- */
-static DEFINE_SPINLOCK(print_lock);
-
-static void tipc_printbuf_move(struct print_buf *pb_to,
-			       struct print_buf *pb_from);
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
-static int tipc_printbuf_empty(struct print_buf *pb)
-{
-	return !pb->buf || (pb->crs == pb->buf);
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
-static void tipc_printbuf_move(struct print_buf *pb_to,
-			       struct print_buf *pb_from)
-{
-	int len;
-
-	/* Handle the cases where contents can't be moved */
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
-	len = pb_from->buf + pb_from->size - pb_from->crs - 2;
-	if ((pb_from->buf[pb_from->size - 1] == 0) && (len > 0)) {
-		strcpy(pb_to->buf, pb_from->crs + 1);
-		pb_to->crs = pb_to->buf + len;
-	} else
-		pb_to->crs = pb_to->buf;
-
-	/* Copy data from start to cursor (always) */
-	len = pb_from->crs - pb_from->buf;
-	strcpy(pb_to->crs, pb_from->buf);
-	pb_to->crs += len;
-
-	tipc_printbuf_reset(pb_from);
-}
 
 /**
  * tipc_snprintf - append formatted output to print buffer
@@ -185,84 +53,3 @@ int tipc_snprintf(char *buf, int len, const char *fmt, ...)
 	va_end(args);
 	return i;
 }
-
-/**
- * tipc_log_resize - change the size of the TIPC log buffer
- * @log_size: print buffer size to use
- */
-int tipc_log_resize(int log_size)
-{
-	int res = 0;
-
-	spin_lock_bh(&print_lock);
-	kfree(TIPC_LOG->buf);
-	TIPC_LOG->buf = NULL;
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
-struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area, int req_tlv_space)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value > 32768)
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
-	} else {
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
diff --git a/net/tipc/log.h b/net/tipc/log.h
deleted file mode 100644
index d1f5eb9..0000000
--- a/net/tipc/log.h
+++ /dev/null
@@ -1,66 +0,0 @@
-/*
- * net/tipc/log.h: Include file for TIPC print buffer routines
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
-#ifndef _TIPC_LOG_H
-#define _TIPC_LOG_H
-
-/**
- * struct print_buf - TIPC print buffer structure
- * @buf: pointer to character array containing print buffer contents
- * @size: size of character array
- * @crs: pointer to first unused space in character array (i.e. final NUL)
- * @echo: echo output to system console if non-zero
- */
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
-- 
1.7.9.7
