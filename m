From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 4/8] tipc: remove TIPC packet debugging functions and macros
Date: Thu, 12 Jul 2012 12:39:57 -0400
Message-ID: <1342111201-9426-5-git-send-email-paul.gortmaker@windriver.com>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43551 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161240Ab2GLQk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:40:29 -0400
In-Reply-To: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

The link queue traces and packet level debug functions served
a purpose during early development, but are now redundant
since there are other, more capable tools available for
debugging at the packet level.

The TIPC_DEBUG Kconfig option is removed since it does not
provide any extra debugging features anymore.

This gets rid of a lot of tipc_printf usages, which will
make the pending cleanup work of that function easier.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/Kconfig |   12 ---
 net/tipc/core.h  |   22 -----
 net/tipc/link.c  |   36 --------
 net/tipc/msg.c   |  242 ------------------------------------------------------
 4 files changed, 312 deletions(-)

diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index 2c5954b..e24519a 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -54,16 +54,4 @@ config TIPC_LOG
 	  There is no need to enable the log buffer unless the node will be
 	  managed remotely via TIPC.
 
-config TIPC_DEBUG
-	bool "Enable debugging support"
-	default n
-	help
-	  Saying Y here enables TIPC debugging capabilities used by developers.
-	  Most users do not need to bother; if unsure, just say N.
-
-	  Enabling debugging support causes TIPC to display data about its
-	  internal state when certain abnormal conditions occur. It also
-	  makes it easy for developers to capture additional information of
-	  interest using the dbg() or msg_dbg() macros.
-
 endif # TIPC
diff --git a/net/tipc/core.h b/net/tipc/core.h
index e8b4909..c7b5ab5 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -89,28 +89,6 @@ void tipc_printf(struct print_buf *, const char *fmt, ...);
 #define TIPC_OUTPUT TIPC_LOG
 #endif
 
-#ifdef CONFIG_TIPC_DEBUG
-
-/*
- * DBG_OUTPUT is the destination print buffer for debug messages.
- */
-#ifndef DBG_OUTPUT
-#define DBG_OUTPUT TIPC_LOG
-#endif
-
-#define msg_dbg(msg, txt) tipc_msg_dbg(DBG_OUTPUT, msg, txt);
-
-void tipc_msg_dbg(struct print_buf *, struct tipc_msg *, const char *);
-
-#else
-
-#define msg_dbg(msg, txt)	do {} while (0)
-
-#define tipc_msg_dbg(buf, msg, txt) do {} while (0)
-
-#endif
-
-
 /*
  * TIPC-specific error codes
  */
diff --git a/net/tipc/link.c b/net/tipc/link.c
index da1f3c5..b389ab9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -3018,42 +3018,6 @@ static void link_print(struct tipc_link *l_ptr, const char *str)
 	tipc_printf(buf, "Link %x<%s>:",
 		    l_ptr->addr, l_ptr->b_ptr->name);
 
-#ifdef CONFIG_TIPC_DEBUG
-	if (link_reset_reset(l_ptr) || link_reset_unknown(l_ptr))
-		goto print_state;
-
-	tipc_printf(buf, ": NXO(%u):", mod(l_ptr->next_out_no));
-	tipc_printf(buf, "NXI(%u):", mod(l_ptr->next_in_no));
-	tipc_printf(buf, "SQUE");
-	if (l_ptr->first_out) {
-		tipc_printf(buf, "[%u..", buf_seqno(l_ptr->first_out));
-		if (l_ptr->next_out)
-			tipc_printf(buf, "%u..", buf_seqno(l_ptr->next_out));
-		tipc_printf(buf, "%u]", buf_seqno(l_ptr->last_out));
-		if ((mod(buf_seqno(l_ptr->last_out) -
-			 buf_seqno(l_ptr->first_out))
-		     != (l_ptr->out_queue_size - 1)) ||
-		    (l_ptr->last_out->next != NULL)) {
-			tipc_printf(buf, "\nSend queue inconsistency\n");
-			tipc_printf(buf, "first_out= %p ", l_ptr->first_out);
-			tipc_printf(buf, "next_out= %p ", l_ptr->next_out);
-			tipc_printf(buf, "last_out= %p ", l_ptr->last_out);
-		}
-	} else
-		tipc_printf(buf, "[]");
-	tipc_printf(buf, "SQSIZ(%u)", l_ptr->out_queue_size);
-	if (l_ptr->oldest_deferred_in) {
-		u32 o = buf_seqno(l_ptr->oldest_deferred_in);
-		u32 n = buf_seqno(l_ptr->newest_deferred_in);
-		tipc_printf(buf, ":RQUE[%u..%u]", o, n);
-		if (l_ptr->deferred_inqueue_sz != mod((n + 1) - o)) {
-			tipc_printf(buf, ":RQSIZ(%u)",
-				    l_ptr->deferred_inqueue_sz);
-		}
-	}
-print_state:
-#endif
-
 	if (link_working_unknown(l_ptr))
 		tipc_printf(buf, ":WU");
 	else if (link_reset_reset(l_ptr))
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index deea0d2..f2db8a8 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -109,245 +109,3 @@ int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 	*buf = NULL;
 	return -EFAULT;
 }
-
-#ifdef CONFIG_TIPC_DEBUG
-void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
-{
-	u32 usr = msg_user(msg);
-	tipc_printf(buf, KERN_DEBUG);
-	tipc_printf(buf, str);
-
-	switch (usr) {
-	case MSG_BUNDLER:
-		tipc_printf(buf, "BNDL::");
-		tipc_printf(buf, "MSGS(%u):", msg_msgcnt(msg));
-		break;
-	case BCAST_PROTOCOL:
-		tipc_printf(buf, "BCASTP::");
-		break;
-	case MSG_FRAGMENTER:
-		tipc_printf(buf, "FRAGM::");
-		switch (msg_type(msg)) {
-		case FIRST_FRAGMENT:
-			tipc_printf(buf, "FIRST:");
-			break;
-		case FRAGMENT:
-			tipc_printf(buf, "BODY:");
-			break;
-		case LAST_FRAGMENT:
-			tipc_printf(buf, "LAST:");
-			break;
-		default:
-			tipc_printf(buf, "UNKNOWN:%x", msg_type(msg));
-
-		}
-		tipc_printf(buf, "NO(%u/%u):", msg_long_msgno(msg),
-			    msg_fragm_no(msg));
-		break;
-	case TIPC_LOW_IMPORTANCE:
-	case TIPC_MEDIUM_IMPORTANCE:
-	case TIPC_HIGH_IMPORTANCE:
-	case TIPC_CRITICAL_IMPORTANCE:
-		tipc_printf(buf, "DAT%u:", msg_user(msg));
-		if (msg_short(msg)) {
-			tipc_printf(buf, "CON:");
-			break;
-		}
-		switch (msg_type(msg)) {
-		case TIPC_CONN_MSG:
-			tipc_printf(buf, "CON:");
-			break;
-		case TIPC_MCAST_MSG:
-			tipc_printf(buf, "MCST:");
-			break;
-		case TIPC_NAMED_MSG:
-			tipc_printf(buf, "NAM:");
-			break;
-		case TIPC_DIRECT_MSG:
-			tipc_printf(buf, "DIR:");
-			break;
-		default:
-			tipc_printf(buf, "UNKNOWN TYPE %u", msg_type(msg));
-		}
-		if (msg_reroute_cnt(msg))
-			tipc_printf(buf, "REROUTED(%u):",
-				    msg_reroute_cnt(msg));
-		break;
-	case NAME_DISTRIBUTOR:
-		tipc_printf(buf, "NMD::");
-		switch (msg_type(msg)) {
-		case PUBLICATION:
-			tipc_printf(buf, "PUBL(%u):", (msg_size(msg) - msg_hdr_sz(msg)) / 20);	/* Items */
-			break;
-		case WITHDRAWAL:
-			tipc_printf(buf, "WDRW:");
-			break;
-		default:
-			tipc_printf(buf, "UNKNOWN:%x", msg_type(msg));
-		}
-		if (msg_reroute_cnt(msg))
-			tipc_printf(buf, "REROUTED(%u):",
-				    msg_reroute_cnt(msg));
-		break;
-	case CONN_MANAGER:
-		tipc_printf(buf, "CONN_MNG:");
-		switch (msg_type(msg)) {
-		case CONN_PROBE:
-			tipc_printf(buf, "PROBE:");
-			break;
-		case CONN_PROBE_REPLY:
-			tipc_printf(buf, "PROBE_REPLY:");
-			break;
-		case CONN_ACK:
-			tipc_printf(buf, "CONN_ACK:");
-			tipc_printf(buf, "ACK(%u):", msg_msgcnt(msg));
-			break;
-		default:
-			tipc_printf(buf, "UNKNOWN TYPE:%x", msg_type(msg));
-		}
-		if (msg_reroute_cnt(msg))
-			tipc_printf(buf, "REROUTED(%u):", msg_reroute_cnt(msg));
-		break;
-	case LINK_PROTOCOL:
-		switch (msg_type(msg)) {
-		case STATE_MSG:
-			tipc_printf(buf, "STATE:");
-			tipc_printf(buf, "%s:", msg_probe(msg) ? "PRB" : "");
-			tipc_printf(buf, "NXS(%u):", msg_next_sent(msg));
-			tipc_printf(buf, "GAP(%u):", msg_seq_gap(msg));
-			tipc_printf(buf, "LSTBC(%u):", msg_last_bcast(msg));
-			break;
-		case RESET_MSG:
-			tipc_printf(buf, "RESET:");
-			if (msg_size(msg) != msg_hdr_sz(msg))
-				tipc_printf(buf, "BEAR:%s:", msg_data(msg));
-			break;
-		case ACTIVATE_MSG:
-			tipc_printf(buf, "ACTIVATE:");
-			break;
-		default:
-			tipc_printf(buf, "UNKNOWN TYPE:%x", msg_type(msg));
-		}
-		tipc_printf(buf, "PLANE(%c):", msg_net_plane(msg));
-		tipc_printf(buf, "SESS(%u):", msg_session(msg));
-		break;
-	case CHANGEOVER_PROTOCOL:
-		tipc_printf(buf, "TUNL:");
-		switch (msg_type(msg)) {
-		case DUPLICATE_MSG:
-			tipc_printf(buf, "DUPL:");
-			break;
-		case ORIGINAL_MSG:
-			tipc_printf(buf, "ORIG:");
-			tipc_printf(buf, "EXP(%u)", msg_msgcnt(msg));
-			break;
-		default:
-			tipc_printf(buf, "UNKNOWN TYPE:%x", msg_type(msg));
-		}
-		break;
-	case LINK_CONFIG:
-		tipc_printf(buf, "CFG:");
-		switch (msg_type(msg)) {
-		case DSC_REQ_MSG:
-			tipc_printf(buf, "DSC_REQ:");
-			break;
-		case DSC_RESP_MSG:
-			tipc_printf(buf, "DSC_RESP:");
-			break;
-		default:
-			tipc_printf(buf, "UNKNOWN TYPE:%x:", msg_type(msg));
-			break;
-		}
-		break;
-	default:
-		tipc_printf(buf, "UNKNOWN USER:");
-	}
-
-	switch (usr) {
-	case CONN_MANAGER:
-	case TIPC_LOW_IMPORTANCE:
-	case TIPC_MEDIUM_IMPORTANCE:
-	case TIPC_HIGH_IMPORTANCE:
-	case TIPC_CRITICAL_IMPORTANCE:
-		switch (msg_errcode(msg)) {
-		case TIPC_OK:
-			break;
-		case TIPC_ERR_NO_NAME:
-			tipc_printf(buf, "NO_NAME:");
-			break;
-		case TIPC_ERR_NO_PORT:
-			tipc_printf(buf, "NO_PORT:");
-			break;
-		case TIPC_ERR_NO_NODE:
-			tipc_printf(buf, "NO_PROC:");
-			break;
-		case TIPC_ERR_OVERLOAD:
-			tipc_printf(buf, "OVERLOAD:");
-			break;
-		case TIPC_CONN_SHUTDOWN:
-			tipc_printf(buf, "SHUTDOWN:");
-			break;
-		default:
-			tipc_printf(buf, "UNKNOWN ERROR(%x):",
-				    msg_errcode(msg));
-		}
-	default:
-		break;
-	}
-
-	tipc_printf(buf, "HZ(%u):", msg_hdr_sz(msg));
-	tipc_printf(buf, "SZ(%u):", msg_size(msg));
-	tipc_printf(buf, "SQNO(%u):", msg_seqno(msg));
-
-	if (msg_non_seq(msg))
-		tipc_printf(buf, "NOSEQ:");
-	else
-		tipc_printf(buf, "ACK(%u):", msg_ack(msg));
-	tipc_printf(buf, "BACK(%u):", msg_bcast_ack(msg));
-	tipc_printf(buf, "PRND(%x)", msg_prevnode(msg));
-
-	if (msg_isdata(msg)) {
-		if (msg_named(msg)) {
-			tipc_printf(buf, "NTYP(%u):", msg_nametype(msg));
-			tipc_printf(buf, "NINST(%u)", msg_nameinst(msg));
-		}
-	}
-
-	if ((usr != LINK_PROTOCOL) && (usr != LINK_CONFIG) &&
-	    (usr != MSG_BUNDLER)) {
-		if (!msg_short(msg)) {
-			tipc_printf(buf, ":ORIG(%x:%u):",
-				    msg_orignode(msg), msg_origport(msg));
-			tipc_printf(buf, ":DEST(%x:%u):",
-				    msg_destnode(msg), msg_destport(msg));
-		} else {
-			tipc_printf(buf, ":OPRT(%u):", msg_origport(msg));
-			tipc_printf(buf, ":DPRT(%u):", msg_destport(msg));
-		}
-	}
-	if (msg_user(msg) == NAME_DISTRIBUTOR) {
-		tipc_printf(buf, ":ONOD(%x):", msg_orignode(msg));
-		tipc_printf(buf, ":DNOD(%x):", msg_destnode(msg));
-	}
-
-	if (msg_user(msg) ==  LINK_CONFIG) {
-		struct tipc_media_addr orig;
-
-		tipc_printf(buf, ":DDOM(%x):", msg_dest_domain(msg));
-		tipc_printf(buf, ":NETID(%u):", msg_bc_netid(msg));
-		memcpy(orig.value, msg_media_addr(msg), sizeof(orig.value));
-		orig.media_id = 0;
-		orig.broadcast = 0;
-		tipc_media_addr_printf(buf, &orig);
-	}
-	if (msg_user(msg) == BCAST_PROTOCOL) {
-		tipc_printf(buf, "BCNACK:AFTER(%u):", msg_bcgap_after(msg));
-		tipc_printf(buf, "TO(%u):", msg_bcgap_to(msg));
-	}
-	tipc_printf(buf, "\n");
-	if ((usr == CHANGEOVER_PROTOCOL) && (msg_msgcnt(msg)))
-		tipc_msg_dbg(buf, msg_get_wrapped(msg), "      /");
-	if ((usr == MSG_FRAGMENTER) && (msg_type(msg) == FIRST_FRAGMENT))
-		tipc_msg_dbg(buf, msg_get_wrapped(msg), "      /");
-}
-#endif
-- 
1.7.9.7
