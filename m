From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/3] rxrpc: Fix handling of enums-to-string
 translation in tracing
Date: Thu, 05 Jan 2017 14:31:57 +0000
Message-ID: <148362671743.31085.2126720562776055970.stgit@warthog.procyon.org.uk>
References: <148362671062.31085.13249164388796003311.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36320 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033943AbdAEOb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 09:31:59 -0500
In-Reply-To: <148362671062.31085.13249164388796003311.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the way enum values are translated into strings in AF_RXRPC
tracepoints.  The problem with just doing a lookup in a normal flat array
of strings or chars is that external tracing infrastructure can't find it.
Rather, TRACE_DEFINE_ENUM must be used.

Also sort the enums and string tables to make it easier to keep them in
order so that a future patch to __print_symbolic() can be optimised to try
a direct lookup into the table first before iterating over it.

A couple of _proto() macro calls are removed because they refered to tables
that got moved to the tracing infrastructure.  The relevant data can be
found by way of tracing.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |  424 ++++++++++++++++++++++++++++++++++++++++--
 net/rxrpc/ar-internal.h      |  194 -------------------
 net/rxrpc/call_object.c      |   18 --
 net/rxrpc/conn_client.c      |    8 -
 net/rxrpc/input.c            |   10 -
 net/rxrpc/misc.c             |  151 ---------------
 6 files changed, 403 insertions(+), 402 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 0383e5e9a0f3..2395a57462c9 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -16,6 +16,386 @@
 
 #include <linux/tracepoint.h>
 
+/*
+ * Define enums for tracing information.
+ *
+ * These should all be kept sorted, making it easier to match the string
+ * mapping tables further on.
+ */
+#ifndef __RXRPC_DECLARE_TRACE_ENUMS_ONCE_ONLY
+#define __RXRPC_DECLARE_TRACE_ENUMS_ONCE_ONLY
+
+enum rxrpc_skb_trace {
+	rxrpc_skb_rx_cleaned,
+	rxrpc_skb_rx_freed,
+	rxrpc_skb_rx_got,
+	rxrpc_skb_rx_lost,
+	rxrpc_skb_rx_purged,
+	rxrpc_skb_rx_received,
+	rxrpc_skb_rx_rotated,
+	rxrpc_skb_rx_seen,
+	rxrpc_skb_tx_cleaned,
+	rxrpc_skb_tx_freed,
+	rxrpc_skb_tx_got,
+	rxrpc_skb_tx_new,
+	rxrpc_skb_tx_rotated,
+	rxrpc_skb_tx_seen,
+};
+
+enum rxrpc_conn_trace {
+	rxrpc_conn_got,
+	rxrpc_conn_new_client,
+	rxrpc_conn_new_service,
+	rxrpc_conn_put_client,
+	rxrpc_conn_put_service,
+	rxrpc_conn_queued,
+	rxrpc_conn_seen,
+};
+
+enum rxrpc_client_trace {
+	rxrpc_client_activate_chans,
+	rxrpc_client_alloc,
+	rxrpc_client_chan_activate,
+	rxrpc_client_chan_disconnect,
+	rxrpc_client_chan_pass,
+	rxrpc_client_chan_unstarted,
+	rxrpc_client_cleanup,
+	rxrpc_client_count,
+	rxrpc_client_discard,
+	rxrpc_client_duplicate,
+	rxrpc_client_exposed,
+	rxrpc_client_replace,
+	rxrpc_client_to_active,
+	rxrpc_client_to_culled,
+	rxrpc_client_to_idle,
+	rxrpc_client_to_inactive,
+	rxrpc_client_to_upgrade,
+	rxrpc_client_to_waiting,
+	rxrpc_client_uncount,
+};
+
+enum rxrpc_call_trace {
+	rxrpc_call_connected,
+	rxrpc_call_error,
+	rxrpc_call_got,
+	rxrpc_call_got_kernel,
+	rxrpc_call_got_userid,
+	rxrpc_call_new_client,
+	rxrpc_call_new_service,
+	rxrpc_call_put,
+	rxrpc_call_put_kernel,
+	rxrpc_call_put_noqueue,
+	rxrpc_call_put_userid,
+	rxrpc_call_queued,
+	rxrpc_call_queued_ref,
+	rxrpc_call_release,
+	rxrpc_call_seen,
+};
+
+enum rxrpc_transmit_trace {
+	rxrpc_transmit_await_reply,
+	rxrpc_transmit_end,
+	rxrpc_transmit_queue,
+	rxrpc_transmit_queue_last,
+	rxrpc_transmit_rotate,
+	rxrpc_transmit_rotate_last,
+	rxrpc_transmit_wait,
+};
+
+enum rxrpc_receive_trace {
+	rxrpc_receive_end,
+	rxrpc_receive_front,
+	rxrpc_receive_incoming,
+	rxrpc_receive_queue,
+	rxrpc_receive_queue_last,
+	rxrpc_receive_rotate,
+};
+
+enum rxrpc_recvmsg_trace {
+	rxrpc_recvmsg_cont,
+	rxrpc_recvmsg_data_return,
+	rxrpc_recvmsg_dequeue,
+	rxrpc_recvmsg_enter,
+	rxrpc_recvmsg_full,
+	rxrpc_recvmsg_hole,
+	rxrpc_recvmsg_next,
+	rxrpc_recvmsg_return,
+	rxrpc_recvmsg_terminal,
+	rxrpc_recvmsg_to_be_accepted,
+	rxrpc_recvmsg_wait,
+};
+
+enum rxrpc_rtt_tx_trace {
+	rxrpc_rtt_tx_data,
+	rxrpc_rtt_tx_ping,
+};
+
+enum rxrpc_rtt_rx_trace {
+	rxrpc_rtt_rx_ping_response,
+	rxrpc_rtt_rx_requested_ack,
+};
+
+enum rxrpc_timer_trace {
+	rxrpc_timer_begin,
+	rxrpc_timer_expired,
+	rxrpc_timer_init_for_reply,
+	rxrpc_timer_init_for_send_reply,
+	rxrpc_timer_set_for_ack,
+	rxrpc_timer_set_for_ping,
+	rxrpc_timer_set_for_resend,
+	rxrpc_timer_set_for_send,
+};
+
+enum rxrpc_propose_ack_trace {
+	rxrpc_propose_ack_client_tx_end,
+	rxrpc_propose_ack_input_data,
+	rxrpc_propose_ack_ping_for_lost_ack,
+	rxrpc_propose_ack_ping_for_lost_reply,
+	rxrpc_propose_ack_ping_for_params,
+	rxrpc_propose_ack_processing_op,
+	rxrpc_propose_ack_respond_to_ack,
+	rxrpc_propose_ack_respond_to_ping,
+	rxrpc_propose_ack_retry_tx,
+	rxrpc_propose_ack_rotate_rx,
+	rxrpc_propose_ack_terminal_ack,
+};
+
+enum rxrpc_propose_ack_outcome {
+	rxrpc_propose_ack_subsume,
+	rxrpc_propose_ack_update,
+	rxrpc_propose_ack_use,
+};
+
+enum rxrpc_congest_change {
+	rxrpc_cong_begin_retransmission,
+	rxrpc_cong_cleared_nacks,
+	rxrpc_cong_new_low_nack,
+	rxrpc_cong_no_change,
+	rxrpc_cong_progress,
+	rxrpc_cong_retransmit_again,
+	rxrpc_cong_rtt_window_end,
+	rxrpc_cong_saw_nack,
+};
+
+#endif /* end __RXRPC_DECLARE_TRACE_ENUMS_ONCE_ONLY */
+
+/*
+ * Declare tracing information enums and their string mappings for display.
+ */
+#define rxrpc_skb_traces \
+	EM(rxrpc_skb_rx_cleaned,		"Rx CLN") \
+	EM(rxrpc_skb_rx_freed,			"Rx FRE") \
+	EM(rxrpc_skb_rx_got,			"Rx GOT") \
+	EM(rxrpc_skb_rx_lost,			"Rx *L*") \
+	EM(rxrpc_skb_rx_purged,			"Rx PUR") \
+	EM(rxrpc_skb_rx_received,		"Rx RCV") \
+	EM(rxrpc_skb_rx_rotated,		"Rx ROT") \
+	EM(rxrpc_skb_rx_seen,			"Rx SEE") \
+	EM(rxrpc_skb_tx_cleaned,		"Tx CLN") \
+	EM(rxrpc_skb_tx_freed,			"Tx FRE") \
+	EM(rxrpc_skb_tx_got,			"Tx GOT") \
+	EM(rxrpc_skb_tx_new,			"Tx NEW") \
+	EM(rxrpc_skb_tx_rotated,		"Tx ROT") \
+	E_(rxrpc_skb_tx_seen,			"Tx SEE")
+
+#define rxrpc_conn_traces \
+	EM(rxrpc_conn_got,			"GOT") \
+	EM(rxrpc_conn_new_client,		"NWc") \
+	EM(rxrpc_conn_new_service,		"NWs") \
+	EM(rxrpc_conn_put_client,		"PTc") \
+	EM(rxrpc_conn_put_service,		"PTs") \
+	EM(rxrpc_conn_queued,			"QUE") \
+	E_(rxrpc_conn_seen,			"SEE")
+
+#define rxrpc_client_traces \
+	EM(rxrpc_client_activate_chans,		"Activa") \
+	EM(rxrpc_client_alloc,			"Alloc ") \
+	EM(rxrpc_client_chan_activate,		"ChActv") \
+	EM(rxrpc_client_chan_disconnect,	"ChDisc") \
+	EM(rxrpc_client_chan_pass,		"ChPass") \
+	EM(rxrpc_client_chan_unstarted,		"ChUnst") \
+	EM(rxrpc_client_cleanup,		"Clean ") \
+	EM(rxrpc_client_count,			"Count ") \
+	EM(rxrpc_client_discard,		"Discar") \
+	EM(rxrpc_client_duplicate,		"Duplic") \
+	EM(rxrpc_client_exposed,		"Expose") \
+	EM(rxrpc_client_replace,		"Replac") \
+	EM(rxrpc_client_to_active,		"->Actv") \
+	EM(rxrpc_client_to_culled,		"->Cull") \
+	EM(rxrpc_client_to_idle,		"->Idle") \
+	EM(rxrpc_client_to_inactive,		"->Inac") \
+	EM(rxrpc_client_to_upgrade,		"->Upgd") \
+	EM(rxrpc_client_to_waiting,		"->Wait") \
+	E_(rxrpc_client_uncount,		"Uncoun")
+
+#define rxrpc_conn_cache_states \
+	EM(RXRPC_CONN_CLIENT_INACTIVE,		"Inac") \
+	EM(RXRPC_CONN_CLIENT_WAITING,		"Wait") \
+	EM(RXRPC_CONN_CLIENT_ACTIVE,		"Actv") \
+	EM(RXRPC_CONN_CLIENT_CULLED,		"Cull") \
+	E_(RXRPC_CONN_CLIENT_IDLE,		"Idle") \
+
+#define rxrpc_call_traces \
+	EM(rxrpc_call_connected,		"CON") \
+	EM(rxrpc_call_error,			"*E*") \
+	EM(rxrpc_call_got,			"GOT") \
+	EM(rxrpc_call_got_kernel,		"Gke") \
+	EM(rxrpc_call_got_userid,		"Gus") \
+	EM(rxrpc_call_new_client,		"NWc") \
+	EM(rxrpc_call_new_service,		"NWs") \
+	EM(rxrpc_call_put,			"PUT") \
+	EM(rxrpc_call_put_kernel,		"Pke") \
+	EM(rxrpc_call_put_noqueue,		"PNQ") \
+	EM(rxrpc_call_put_userid,		"Pus") \
+	EM(rxrpc_call_queued,			"QUE") \
+	EM(rxrpc_call_queued_ref,		"QUR") \
+	EM(rxrpc_call_release,			"RLS") \
+	E_(rxrpc_call_seen,			"SEE")
+
+#define rxrpc_transmit_traces \
+	EM(rxrpc_transmit_await_reply,		"AWR") \
+	EM(rxrpc_transmit_end,			"END") \
+	EM(rxrpc_transmit_queue,		"QUE") \
+	EM(rxrpc_transmit_queue_last,		"QLS") \
+	EM(rxrpc_transmit_rotate,		"ROT") \
+	EM(rxrpc_transmit_rotate_last,		"RLS") \
+	E_(rxrpc_transmit_wait,			"WAI")
+
+#define rxrpc_receive_traces \
+	EM(rxrpc_receive_end,			"END") \
+	EM(rxrpc_receive_front,			"FRN") \
+	EM(rxrpc_receive_incoming,		"INC") \
+	EM(rxrpc_receive_queue,			"QUE") \
+	EM(rxrpc_receive_queue_last,		"QLS") \
+	E_(rxrpc_receive_rotate,		"ROT")
+
+#define rxrpc_recvmsg_traces \
+	EM(rxrpc_recvmsg_cont,			"CONT") \
+	EM(rxrpc_recvmsg_data_return,		"DATA") \
+	EM(rxrpc_recvmsg_dequeue,		"DEQU") \
+	EM(rxrpc_recvmsg_enter,			"ENTR") \
+	EM(rxrpc_recvmsg_full,			"FULL") \
+	EM(rxrpc_recvmsg_hole,			"HOLE") \
+	EM(rxrpc_recvmsg_next,			"NEXT") \
+	EM(rxrpc_recvmsg_return,		"RETN") \
+	EM(rxrpc_recvmsg_terminal,		"TERM") \
+	EM(rxrpc_recvmsg_to_be_accepted,	"TBAC") \
+	E_(rxrpc_recvmsg_wait,			"WAIT")
+
+#define rxrpc_rtt_tx_traces \
+	EM(rxrpc_rtt_tx_data,			"DATA") \
+	E_(rxrpc_rtt_tx_ping,			"PING")
+
+#define rxrpc_rtt_rx_traces \
+	EM(rxrpc_rtt_rx_ping_response,		"PONG") \
+	E_(rxrpc_rtt_rx_requested_ack,		"RACK")
+
+#define rxrpc_timer_traces \
+	EM(rxrpc_timer_begin,			"Begin ") \
+	EM(rxrpc_timer_expired,			"*EXPR*") \
+	EM(rxrpc_timer_init_for_reply,		"IniRpl") \
+	EM(rxrpc_timer_init_for_send_reply,	"SndRpl") \
+	EM(rxrpc_timer_set_for_ack,		"SetAck") \
+	EM(rxrpc_timer_set_for_ping,		"SetPng") \
+	EM(rxrpc_timer_set_for_resend,		"SetRTx") \
+	E_(rxrpc_timer_set_for_send,		"SetTx ")
+
+#define rxrpc_propose_ack_traces \
+	EM(rxrpc_propose_ack_client_tx_end,	"ClTxEnd") \
+	EM(rxrpc_propose_ack_input_data,	"DataIn ") \
+	EM(rxrpc_propose_ack_ping_for_lost_ack,	"LostAck") \
+	EM(rxrpc_propose_ack_ping_for_lost_reply, "LostRpl") \
+	EM(rxrpc_propose_ack_ping_for_params,	"Params ") \
+	EM(rxrpc_propose_ack_processing_op,	"ProcOp ") \
+	EM(rxrpc_propose_ack_respond_to_ack,	"Rsp2Ack") \
+	EM(rxrpc_propose_ack_respond_to_ping,	"Rsp2Png") \
+	EM(rxrpc_propose_ack_retry_tx,		"RetryTx") \
+	EM(rxrpc_propose_ack_rotate_rx,		"RxAck  ") \
+	E_(rxrpc_propose_ack_terminal_ack,	"ClTerm ")
+
+#define rxrpc_propose_ack_outcomes \
+	EM(rxrpc_propose_ack_subsume,		" Subsume") \
+	EM(rxrpc_propose_ack_update,		" Update") \
+	E_(rxrpc_propose_ack_use,		"")
+
+#define rxrpc_congest_modes \
+	EM(RXRPC_CALL_CONGEST_AVOIDANCE,	"CongAvoid") \
+	EM(RXRPC_CALL_FAST_RETRANSMIT,		"FastReTx ") \
+	EM(RXRPC_CALL_PACKET_LOSS,		"PktLoss  ") \
+	E_(RXRPC_CALL_SLOW_START,		"SlowStart")
+
+#define rxrpc_congest_changes \
+	EM(rxrpc_cong_begin_retransmission,	" Retrans") \
+	EM(rxrpc_cong_cleared_nacks,		" Cleared") \
+	EM(rxrpc_cong_new_low_nack,		" NewLowN") \
+	EM(rxrpc_cong_no_change,		"") \
+	EM(rxrpc_cong_progress,			" Progres") \
+	EM(rxrpc_cong_retransmit_again,		" ReTxAgn") \
+	EM(rxrpc_cong_rtt_window_end,		" RttWinE") \
+	E_(rxrpc_cong_saw_nack,			" SawNack")
+
+#define rxrpc_pkts \
+	EM(0,					"?00") \
+	EM(RXRPC_PACKET_TYPE_DATA,		"DATA") \
+	EM(RXRPC_PACKET_TYPE_ACK,		"ACK") \
+	EM(RXRPC_PACKET_TYPE_BUSY,		"BUSY") \
+	EM(RXRPC_PACKET_TYPE_ABORT,		"ABORT") \
+	EM(RXRPC_PACKET_TYPE_ACKALL,		"ACKALL") \
+	EM(RXRPC_PACKET_TYPE_CHALLENGE,		"CHALL") \
+	EM(RXRPC_PACKET_TYPE_RESPONSE,		"RESP") \
+	EM(RXRPC_PACKET_TYPE_DEBUG,		"DEBUG") \
+	EM(9,					"?09") \
+	EM(10,					"?10") \
+	EM(11,					"?11") \
+	EM(12,					"?12") \
+	EM(RXRPC_PACKET_TYPE_VERSION,		"VERSION") \
+	EM(14,					"?14") \
+	E_(15,					"?15")
+
+#define rxrpc_ack_names \
+	EM(0,					"-0-") \
+	EM(RXRPC_ACK_REQUESTED,			"REQ") \
+	EM(RXRPC_ACK_DUPLICATE,			"DUP") \
+	EM(RXRPC_ACK_OUT_OF_SEQUENCE,		"OOS") \
+	EM(RXRPC_ACK_EXCEEDS_WINDOW,		"WIN") \
+	EM(RXRPC_ACK_NOSPACE,			"MEM") \
+	EM(RXRPC_ACK_PING,			"PNG") \
+	EM(RXRPC_ACK_PING_RESPONSE,		"PNR") \
+	EM(RXRPC_ACK_DELAY,			"DLY") \
+	EM(RXRPC_ACK_IDLE,			"IDL") \
+	E_(RXRPC_ACK__INVALID,			"-?-")
+
+/*
+ * Export enum symbols via userspace.
+ */
+#undef EM
+#undef E_
+#define EM(a, b) TRACE_DEFINE_ENUM(a);
+#define E_(a, b) TRACE_DEFINE_ENUM(a);
+
+rxrpc_skb_traces;
+rxrpc_conn_traces;
+rxrpc_client_traces;
+rxrpc_call_traces;
+rxrpc_transmit_traces;
+rxrpc_receive_traces;
+rxrpc_recvmsg_traces;
+rxrpc_rtt_tx_traces;
+rxrpc_rtt_rx_traces;
+rxrpc_timer_traces;
+rxrpc_propose_ack_traces;
+rxrpc_propose_ack_outcomes;
+rxrpc_congest_changes;
+
+/*
+ * Now redefine the EM() and E_() macros to map the enums to the strings that
+ * will be printed in the output.
+ */
+#undef EM
+#undef E_
+#define EM(a, b)	{ a, b },
+#define E_(a, b)	{ a, b }
+
 TRACE_EVENT(rxrpc_conn,
 	    TP_PROTO(struct rxrpc_connection *conn, enum rxrpc_conn_trace op,
 		     int usage, const void *where),
@@ -38,7 +418,7 @@ TRACE_EVENT(rxrpc_conn,
 
 	    TP_printk("C=%p %s u=%d sp=%pSR",
 		      __entry->conn,
-		      rxrpc_conn_traces[__entry->op],
+		      __print_symbolic(__entry->op, rxrpc_conn_traces),
 		      __entry->usage,
 		      __entry->where)
 	    );
@@ -70,8 +450,8 @@ TRACE_EVENT(rxrpc_client,
 	    TP_printk("C=%p h=%2d %s %s i=%08x u=%d",
 		      __entry->conn,
 		      __entry->channel,
-		      rxrpc_client_traces[__entry->op],
-		      rxrpc_conn_cache_states[__entry->cs],
+		      __print_symbolic(__entry->op, rxrpc_client_traces),
+		      __print_symbolic(__entry->cs, rxrpc_conn_cache_states),
 		      __entry->cid,
 		      __entry->usage)
 	    );
@@ -100,7 +480,7 @@ TRACE_EVENT(rxrpc_call,
 
 	    TP_printk("c=%p %s u=%d sp=%pSR a=%p",
 		      __entry->call,
-		      rxrpc_call_traces[__entry->op],
+		      __print_symbolic(__entry->op, rxrpc_call_traces),
 		      __entry->usage,
 		      __entry->where,
 		      __entry->aux)
@@ -130,7 +510,7 @@ TRACE_EVENT(rxrpc_skb,
 
 	    TP_printk("s=%p %s u=%d m=%d p=%pSR",
 		      __entry->skb,
-		      rxrpc_skb_traces[__entry->op],
+		      __print_symbolic(__entry->op, rxrpc_skb_traces),
 		      __entry->usage,
 		      __entry->mod_count,
 		      __entry->where)
@@ -154,7 +534,8 @@ TRACE_EVENT(rxrpc_rx_packet,
 		      __entry->hdr.callNumber, __entry->hdr.serviceId,
 		      __entry->hdr.serial, __entry->hdr.seq,
 		      __entry->hdr.type, __entry->hdr.flags,
-		      __entry->hdr.type <= 15 ? rxrpc_pkts[__entry->hdr.type] : "?UNK")
+		      __entry->hdr.type <= 15 ?
+		      __print_symbolic(__entry->hdr.type, rxrpc_pkts) : "?UNK")
 	    );
 
 TRACE_EVENT(rxrpc_rx_done,
@@ -225,7 +606,7 @@ TRACE_EVENT(rxrpc_transmit,
 
 	    TP_printk("c=%p %s f=%08x n=%u",
 		      __entry->call,
-		      rxrpc_transmit_traces[__entry->why],
+		      __print_symbolic(__entry->why, rxrpc_transmit_traces),
 		      __entry->tx_hard_ack + 1,
 		      __entry->tx_top - __entry->tx_hard_ack)
 	    );
@@ -251,7 +632,7 @@ TRACE_EVENT(rxrpc_rx_ack,
 
 	    TP_printk("c=%p %s f=%08x n=%u",
 		      __entry->call,
-		      rxrpc_ack_names[__entry->reason],
+		      __print_symbolic(__entry->reason, rxrpc_ack_names),
 		      __entry->first,
 		      __entry->n_acks)
 	    );
@@ -317,7 +698,7 @@ TRACE_EVENT(rxrpc_tx_ack,
 	    TP_printk(" c=%p ACK  %08x %s f=%08x r=%08x n=%u",
 		      __entry->call,
 		      __entry->serial,
-		      rxrpc_ack_names[__entry->reason],
+		      __print_symbolic(__entry->reason, rxrpc_ack_names),
 		      __entry->ack_first,
 		      __entry->ack_serial,
 		      __entry->n_acks)
@@ -349,7 +730,7 @@ TRACE_EVENT(rxrpc_receive,
 
 	    TP_printk("c=%p %s r=%08x q=%08x w=%08x-%08x",
 		      __entry->call,
-		      rxrpc_receive_traces[__entry->why],
+		      __print_symbolic(__entry->why, rxrpc_receive_traces),
 		      __entry->serial,
 		      __entry->seq,
 		      __entry->hard_ack,
@@ -383,7 +764,7 @@ TRACE_EVENT(rxrpc_recvmsg,
 
 	    TP_printk("c=%p %s q=%08x o=%u l=%u ret=%d",
 		      __entry->call,
-		      rxrpc_recvmsg_traces[__entry->why],
+		      __print_symbolic(__entry->why, rxrpc_recvmsg_traces),
 		      __entry->seq,
 		      __entry->offset,
 		      __entry->len,
@@ -410,7 +791,7 @@ TRACE_EVENT(rxrpc_rtt_tx,
 
 	    TP_printk("c=%p %s sr=%08x",
 		      __entry->call,
-		      rxrpc_rtt_tx_traces[__entry->why],
+		      __print_symbolic(__entry->why, rxrpc_rtt_tx_traces),
 		      __entry->send_serial)
 	    );
 
@@ -443,7 +824,7 @@ TRACE_EVENT(rxrpc_rtt_rx,
 
 	    TP_printk("c=%p %s sr=%08x rr=%08x rtt=%lld nr=%u avg=%lld",
 		      __entry->call,
-		      rxrpc_rtt_rx_traces[__entry->why],
+		      __print_symbolic(__entry->why, rxrpc_rtt_rx_traces),
 		      __entry->send_serial,
 		      __entry->resp_serial,
 		      __entry->rtt,
@@ -481,7 +862,7 @@ TRACE_EVENT(rxrpc_timer,
 
 	    TP_printk("c=%p %s x=%lld a=%lld r=%lld t=%ld",
 		      __entry->call,
-		      rxrpc_timer_traces[__entry->why],
+		      __print_symbolic(__entry->why, rxrpc_timer_traces),
 		      ktime_to_ns(ktime_sub(__entry->expire_at, __entry->now)),
 		      ktime_to_ns(ktime_sub(__entry->ack_at, __entry->now)),
 		      ktime_to_ns(ktime_sub(__entry->resend_at, __entry->now)),
@@ -506,7 +887,8 @@ TRACE_EVENT(rxrpc_rx_lose,
 		      __entry->hdr.callNumber, __entry->hdr.serviceId,
 		      __entry->hdr.serial, __entry->hdr.seq,
 		      __entry->hdr.type, __entry->hdr.flags,
-		      __entry->hdr.type <= 15 ? rxrpc_pkts[__entry->hdr.type] : "?UNK")
+		      __entry->hdr.type <= 15 ?
+		      __print_symbolic(__entry->hdr.type, rxrpc_pkts) : "?UNK")
 	    );
 
 TRACE_EVENT(rxrpc_propose_ack,
@@ -539,12 +921,12 @@ TRACE_EVENT(rxrpc_propose_ack,
 
 	    TP_printk("c=%p %s %s r=%08x i=%u b=%u%s",
 		      __entry->call,
-		      rxrpc_propose_ack_traces[__entry->why],
-		      rxrpc_ack_names[__entry->ack_reason],
+		      __print_symbolic(__entry->why, rxrpc_propose_ack_traces),
+		      __print_symbolic(__entry->ack_reason, rxrpc_ack_names),
 		      __entry->serial,
 		      __entry->immediate,
 		      __entry->background,
-		      rxrpc_propose_ack_outcomes[__entry->outcome])
+		      __print_symbolic(__entry->outcome, rxrpc_propose_ack_outcomes))
 	    );
 
 TRACE_EVENT(rxrpc_retransmit,
@@ -603,9 +985,9 @@ TRACE_EVENT(rxrpc_congest,
 	    TP_printk("c=%p %08x %s %08x %s cw=%u ss=%u nr=%u,%u nw=%u,%u r=%u b=%u u=%u d=%u l=%x%s%s%s",
 		      __entry->call,
 		      __entry->ack_serial,
-		      rxrpc_ack_names[__entry->sum.ack_reason],
+		      __print_symbolic(__entry->sum.ack_reason, rxrpc_ack_names),
 		      __entry->hard_ack,
-		      rxrpc_congest_modes[__entry->sum.mode],
+		      __print_symbolic(__entry->sum.mode, rxrpc_congest_modes),
 		      __entry->sum.cwnd,
 		      __entry->sum.ssthresh,
 		      __entry->sum.nr_acks, __entry->sum.nr_nacks,
@@ -615,7 +997,7 @@ TRACE_EVENT(rxrpc_congest,
 		      __entry->sum.cumulative_acks,
 		      __entry->sum.dup_acks,
 		      __entry->lowest_nak, __entry->sum.new_low_nack ? "!" : "",
-		      rxrpc_congest_changes[__entry->change],
+		      __print_symbolic(__entry->change, rxrpc_congest_changes),
 		      __entry->sum.retrans_timeo ? " rTxTo" : "")
 	    );
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index f60e35576526..84927c7b5fdf 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -593,200 +593,6 @@ struct rxrpc_ack_summary {
 	u8			cumulative_acks;
 };
 
-enum rxrpc_skb_trace {
-	rxrpc_skb_rx_cleaned,
-	rxrpc_skb_rx_freed,
-	rxrpc_skb_rx_got,
-	rxrpc_skb_rx_lost,
-	rxrpc_skb_rx_received,
-	rxrpc_skb_rx_rotated,
-	rxrpc_skb_rx_purged,
-	rxrpc_skb_rx_seen,
-	rxrpc_skb_tx_cleaned,
-	rxrpc_skb_tx_freed,
-	rxrpc_skb_tx_got,
-	rxrpc_skb_tx_new,
-	rxrpc_skb_tx_rotated,
-	rxrpc_skb_tx_seen,
-	rxrpc_skb__nr_trace
-};
-
-extern const char rxrpc_skb_traces[rxrpc_skb__nr_trace][7];
-
-enum rxrpc_conn_trace {
-	rxrpc_conn_new_client,
-	rxrpc_conn_new_service,
-	rxrpc_conn_queued,
-	rxrpc_conn_seen,
-	rxrpc_conn_got,
-	rxrpc_conn_put_client,
-	rxrpc_conn_put_service,
-	rxrpc_conn__nr_trace
-};
-
-extern const char rxrpc_conn_traces[rxrpc_conn__nr_trace][4];
-
-enum rxrpc_client_trace {
-	rxrpc_client_activate_chans,
-	rxrpc_client_alloc,
-	rxrpc_client_chan_activate,
-	rxrpc_client_chan_disconnect,
-	rxrpc_client_chan_pass,
-	rxrpc_client_chan_unstarted,
-	rxrpc_client_cleanup,
-	rxrpc_client_count,
-	rxrpc_client_discard,
-	rxrpc_client_duplicate,
-	rxrpc_client_exposed,
-	rxrpc_client_replace,
-	rxrpc_client_to_active,
-	rxrpc_client_to_culled,
-	rxrpc_client_to_idle,
-	rxrpc_client_to_inactive,
-	rxrpc_client_to_waiting,
-	rxrpc_client_uncount,
-	rxrpc_client__nr_trace
-};
-
-extern const char rxrpc_client_traces[rxrpc_client__nr_trace][7];
-extern const char rxrpc_conn_cache_states[RXRPC_CONN__NR_CACHE_STATES][5];
-
-enum rxrpc_call_trace {
-	rxrpc_call_new_client,
-	rxrpc_call_new_service,
-	rxrpc_call_queued,
-	rxrpc_call_queued_ref,
-	rxrpc_call_seen,
-	rxrpc_call_connected,
-	rxrpc_call_release,
-	rxrpc_call_got,
-	rxrpc_call_got_userid,
-	rxrpc_call_got_kernel,
-	rxrpc_call_put,
-	rxrpc_call_put_userid,
-	rxrpc_call_put_kernel,
-	rxrpc_call_put_noqueue,
-	rxrpc_call_error,
-	rxrpc_call__nr_trace
-};
-
-extern const char rxrpc_call_traces[rxrpc_call__nr_trace][4];
-
-enum rxrpc_transmit_trace {
-	rxrpc_transmit_wait,
-	rxrpc_transmit_queue,
-	rxrpc_transmit_queue_last,
-	rxrpc_transmit_rotate,
-	rxrpc_transmit_rotate_last,
-	rxrpc_transmit_await_reply,
-	rxrpc_transmit_end,
-	rxrpc_transmit__nr_trace
-};
-
-extern const char rxrpc_transmit_traces[rxrpc_transmit__nr_trace][4];
-
-enum rxrpc_receive_trace {
-	rxrpc_receive_incoming,
-	rxrpc_receive_queue,
-	rxrpc_receive_queue_last,
-	rxrpc_receive_front,
-	rxrpc_receive_rotate,
-	rxrpc_receive_end,
-	rxrpc_receive__nr_trace
-};
-
-extern const char rxrpc_receive_traces[rxrpc_receive__nr_trace][4];
-
-enum rxrpc_recvmsg_trace {
-	rxrpc_recvmsg_enter,
-	rxrpc_recvmsg_wait,
-	rxrpc_recvmsg_dequeue,
-	rxrpc_recvmsg_hole,
-	rxrpc_recvmsg_next,
-	rxrpc_recvmsg_cont,
-	rxrpc_recvmsg_full,
-	rxrpc_recvmsg_data_return,
-	rxrpc_recvmsg_terminal,
-	rxrpc_recvmsg_to_be_accepted,
-	rxrpc_recvmsg_return,
-	rxrpc_recvmsg__nr_trace
-};
-
-extern const char rxrpc_recvmsg_traces[rxrpc_recvmsg__nr_trace][5];
-
-enum rxrpc_rtt_tx_trace {
-	rxrpc_rtt_tx_ping,
-	rxrpc_rtt_tx_data,
-	rxrpc_rtt_tx__nr_trace
-};
-
-extern const char rxrpc_rtt_tx_traces[rxrpc_rtt_tx__nr_trace][5];
-
-enum rxrpc_rtt_rx_trace {
-	rxrpc_rtt_rx_ping_response,
-	rxrpc_rtt_rx_requested_ack,
-	rxrpc_rtt_rx__nr_trace
-};
-
-extern const char rxrpc_rtt_rx_traces[rxrpc_rtt_rx__nr_trace][5];
-
-enum rxrpc_timer_trace {
-	rxrpc_timer_begin,
-	rxrpc_timer_init_for_reply,
-	rxrpc_timer_init_for_send_reply,
-	rxrpc_timer_expired,
-	rxrpc_timer_set_for_ack,
-	rxrpc_timer_set_for_ping,
-	rxrpc_timer_set_for_resend,
-	rxrpc_timer_set_for_send,
-	rxrpc_timer__nr_trace
-};
-
-extern const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8];
-
-enum rxrpc_propose_ack_trace {
-	rxrpc_propose_ack_client_tx_end,
-	rxrpc_propose_ack_input_data,
-	rxrpc_propose_ack_ping_for_lost_ack,
-	rxrpc_propose_ack_ping_for_lost_reply,
-	rxrpc_propose_ack_ping_for_params,
-	rxrpc_propose_ack_processing_op,
-	rxrpc_propose_ack_respond_to_ack,
-	rxrpc_propose_ack_respond_to_ping,
-	rxrpc_propose_ack_retry_tx,
-	rxrpc_propose_ack_rotate_rx,
-	rxrpc_propose_ack_terminal_ack,
-	rxrpc_propose_ack__nr_trace
-};
-
-enum rxrpc_propose_ack_outcome {
-	rxrpc_propose_ack_use,
-	rxrpc_propose_ack_update,
-	rxrpc_propose_ack_subsume,
-	rxrpc_propose_ack__nr_outcomes
-};
-
-extern const char rxrpc_propose_ack_traces[rxrpc_propose_ack__nr_trace][8];
-extern const char *const rxrpc_propose_ack_outcomes[rxrpc_propose_ack__nr_outcomes];
-
-enum rxrpc_congest_change {
-	rxrpc_cong_begin_retransmission,
-	rxrpc_cong_cleared_nacks,
-	rxrpc_cong_new_low_nack,
-	rxrpc_cong_no_change,
-	rxrpc_cong_progress,
-	rxrpc_cong_retransmit_again,
-	rxrpc_cong_rtt_window_end,
-	rxrpc_cong_saw_nack,
-	rxrpc_congest__nr_change
-};
-
-extern const char rxrpc_congest_modes[NR__RXRPC_CONGEST_MODES][10];
-extern const char rxrpc_congest_changes[rxrpc_congest__nr_change][9];
-
-extern const char *const rxrpc_pkts[];
-extern const char rxrpc_ack_names[RXRPC_ACK__INVALID + 1][4];
-
 #include <trace/events/rxrpc.h>
 
 /*
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 1ed18d8c9c9f..8b94db3c9b2e 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -43,24 +43,6 @@ const char *const rxrpc_call_completions[NR__RXRPC_CALL_COMPLETIONS] = {
 	[RXRPC_CALL_NETWORK_ERROR]		= "NetError",
 };
 
-const char rxrpc_call_traces[rxrpc_call__nr_trace][4] = {
-	[rxrpc_call_new_client]		= "NWc",
-	[rxrpc_call_new_service]	= "NWs",
-	[rxrpc_call_queued]		= "QUE",
-	[rxrpc_call_queued_ref]		= "QUR",
-	[rxrpc_call_connected]		= "CON",
-	[rxrpc_call_release]		= "RLS",
-	[rxrpc_call_seen]		= "SEE",
-	[rxrpc_call_got]		= "GOT",
-	[rxrpc_call_got_userid]		= "Gus",
-	[rxrpc_call_got_kernel]		= "Gke",
-	[rxrpc_call_put]		= "PUT",
-	[rxrpc_call_put_userid]		= "Pus",
-	[rxrpc_call_put_kernel]		= "Pke",
-	[rxrpc_call_put_noqueue]	= "PNQ",
-	[rxrpc_call_error]		= "*E*",
-};
-
 struct kmem_cache *rxrpc_call_jar;
 LIST_HEAD(rxrpc_calls);
 DEFINE_RWLOCK(rxrpc_call_lock);
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 6cbcdcc29853..40a1ef2adeb4 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -105,14 +105,6 @@ static void rxrpc_discard_expired_client_conns(struct work_struct *);
 static DECLARE_DELAYED_WORK(rxrpc_client_conn_reap,
 			    rxrpc_discard_expired_client_conns);
 
-const char rxrpc_conn_cache_states[RXRPC_CONN__NR_CACHE_STATES][5] = {
-	[RXRPC_CONN_CLIENT_INACTIVE]	= "Inac",
-	[RXRPC_CONN_CLIENT_WAITING]	= "Wait",
-	[RXRPC_CONN_CLIENT_ACTIVE]	= "Actv",
-	[RXRPC_CONN_CLIENT_CULLED]	= "Cull",
-	[RXRPC_CONN_CLIENT_IDLE]	= "Idle",
-};
-
 /*
  * Get a connection ID and epoch for a client connection from the global pool.
  * The connection struct pointer is then recorded in the idr radix tree.  The
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 1d87b5453ef7..7c2abd85def9 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -767,15 +767,6 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 
 	trace_rxrpc_rx_ack(call, first_soft_ack, summary.ack_reason, nr_acks);
 
-	_proto("Rx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
-	       sp->hdr.serial,
-	       ntohs(buf.ack.maxSkew),
-	       first_soft_ack,
-	       ntohl(buf.ack.previousPacket),
-	       acked_serial,
-	       rxrpc_ack_names[summary.ack_reason],
-	       buf.ack.nAcks);
-
 	if (buf.ack.reason == RXRPC_ACK_PING_RESPONSE)
 		rxrpc_input_ping_response(call, skb->tstamp, acked_serial,
 					  sp->hdr.serial);
@@ -931,7 +922,6 @@ static void rxrpc_input_call_packet(struct rxrpc_call *call,
 		break;
 
 	default:
-		_proto("Rx %s %%%u", rxrpc_pkts[sp->hdr.type], sp->hdr.serial);
 		break;
 	}
 
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 6dee55fad2d3..1a2d4b112064 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -77,12 +77,6 @@ unsigned int rxrpc_rx_jumbo_max = 4;
  */
 unsigned int rxrpc_resend_timeout = 4 * 1000;
 
-const char *const rxrpc_pkts[] = {
-	"?00",
-	"DATA", "ACK", "BUSY", "ABORT", "ACKALL", "CHALL", "RESP", "DEBUG",
-	"?09", "?10", "?11", "?12", "VERSION", "?14", "?15"
-};
-
 const s8 rxrpc_ack_priority[] = {
 	[0]				= 0,
 	[RXRPC_ACK_DELAY]		= 1,
@@ -94,148 +88,3 @@ const s8 rxrpc_ack_priority[] = {
 	[RXRPC_ACK_NOSPACE]		= 7,
 	[RXRPC_ACK_PING_RESPONSE]	= 8,
 };
-
-const char rxrpc_ack_names[RXRPC_ACK__INVALID + 1][4] = {
-	"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY",
-	"IDL", "-?-"
-};
-
-const char rxrpc_skb_traces[rxrpc_skb__nr_trace][7] = {
-	[rxrpc_skb_rx_cleaned]		= "Rx CLN",
-	[rxrpc_skb_rx_freed]		= "Rx FRE",
-	[rxrpc_skb_rx_got]		= "Rx GOT",
-	[rxrpc_skb_rx_lost]		= "Rx *L*",
-	[rxrpc_skb_rx_received]		= "Rx RCV",
-	[rxrpc_skb_rx_purged]		= "Rx PUR",
-	[rxrpc_skb_rx_rotated]		= "Rx ROT",
-	[rxrpc_skb_rx_seen]		= "Rx SEE",
-	[rxrpc_skb_tx_cleaned]		= "Tx CLN",
-	[rxrpc_skb_tx_freed]		= "Tx FRE",
-	[rxrpc_skb_tx_got]		= "Tx GOT",
-	[rxrpc_skb_tx_new]		= "Tx NEW",
-	[rxrpc_skb_tx_rotated]		= "Tx ROT",
-	[rxrpc_skb_tx_seen]		= "Tx SEE",
-};
-
-const char rxrpc_conn_traces[rxrpc_conn__nr_trace][4] = {
-	[rxrpc_conn_new_client]		= "NWc",
-	[rxrpc_conn_new_service]	= "NWs",
-	[rxrpc_conn_queued]		= "QUE",
-	[rxrpc_conn_seen]		= "SEE",
-	[rxrpc_conn_got]		= "GOT",
-	[rxrpc_conn_put_client]		= "PTc",
-	[rxrpc_conn_put_service]	= "PTs",
-};
-
-const char rxrpc_client_traces[rxrpc_client__nr_trace][7] = {
-	[rxrpc_client_activate_chans]	= "Activa",
-	[rxrpc_client_alloc]		= "Alloc ",
-	[rxrpc_client_chan_activate]	= "ChActv",
-	[rxrpc_client_chan_disconnect]	= "ChDisc",
-	[rxrpc_client_chan_pass]	= "ChPass",
-	[rxrpc_client_chan_unstarted]	= "ChUnst",
-	[rxrpc_client_cleanup]		= "Clean ",
-	[rxrpc_client_count]		= "Count ",
-	[rxrpc_client_discard]		= "Discar",
-	[rxrpc_client_duplicate]	= "Duplic",
-	[rxrpc_client_exposed]		= "Expose",
-	[rxrpc_client_replace]		= "Replac",
-	[rxrpc_client_to_active]	= "->Actv",
-	[rxrpc_client_to_culled]	= "->Cull",
-	[rxrpc_client_to_idle]		= "->Idle",
-	[rxrpc_client_to_inactive]	= "->Inac",
-	[rxrpc_client_to_waiting]	= "->Wait",
-	[rxrpc_client_uncount]		= "Uncoun",
-};
-
-const char rxrpc_transmit_traces[rxrpc_transmit__nr_trace][4] = {
-	[rxrpc_transmit_wait]		= "WAI",
-	[rxrpc_transmit_queue]		= "QUE",
-	[rxrpc_transmit_queue_last]	= "QLS",
-	[rxrpc_transmit_rotate]		= "ROT",
-	[rxrpc_transmit_rotate_last]	= "RLS",
-	[rxrpc_transmit_await_reply]	= "AWR",
-	[rxrpc_transmit_end]		= "END",
-};
-
-const char rxrpc_receive_traces[rxrpc_receive__nr_trace][4] = {
-	[rxrpc_receive_incoming]	= "INC",
-	[rxrpc_receive_queue]		= "QUE",
-	[rxrpc_receive_queue_last]	= "QLS",
-	[rxrpc_receive_front]		= "FRN",
-	[rxrpc_receive_rotate]		= "ROT",
-	[rxrpc_receive_end]		= "END",
-};
-
-const char rxrpc_recvmsg_traces[rxrpc_recvmsg__nr_trace][5] = {
-	[rxrpc_recvmsg_enter]		= "ENTR",
-	[rxrpc_recvmsg_wait]		= "WAIT",
-	[rxrpc_recvmsg_dequeue]		= "DEQU",
-	[rxrpc_recvmsg_hole]		= "HOLE",
-	[rxrpc_recvmsg_next]		= "NEXT",
-	[rxrpc_recvmsg_cont]		= "CONT",
-	[rxrpc_recvmsg_full]		= "FULL",
-	[rxrpc_recvmsg_data_return]	= "DATA",
-	[rxrpc_recvmsg_terminal]	= "TERM",
-	[rxrpc_recvmsg_to_be_accepted]	= "TBAC",
-	[rxrpc_recvmsg_return]		= "RETN",
-};
-
-const char rxrpc_rtt_tx_traces[rxrpc_rtt_tx__nr_trace][5] = {
-	[rxrpc_rtt_tx_ping]		= "PING",
-	[rxrpc_rtt_tx_data]		= "DATA",
-};
-
-const char rxrpc_rtt_rx_traces[rxrpc_rtt_rx__nr_trace][5] = {
-	[rxrpc_rtt_rx_ping_response]	= "PONG",
-	[rxrpc_rtt_rx_requested_ack]	= "RACK",
-};
-
-const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8] = {
-	[rxrpc_timer_begin]			= "Begin ",
-	[rxrpc_timer_expired]			= "*EXPR*",
-	[rxrpc_timer_init_for_reply]		= "IniRpl",
-	[rxrpc_timer_init_for_send_reply]	= "SndRpl",
-	[rxrpc_timer_set_for_ack]		= "SetAck",
-	[rxrpc_timer_set_for_ping]		= "SetPng",
-	[rxrpc_timer_set_for_send]		= "SetTx ",
-	[rxrpc_timer_set_for_resend]		= "SetRTx",
-};
-
-const char rxrpc_propose_ack_traces[rxrpc_propose_ack__nr_trace][8] = {
-	[rxrpc_propose_ack_client_tx_end]	= "ClTxEnd",
-	[rxrpc_propose_ack_input_data]		= "DataIn ",
-	[rxrpc_propose_ack_ping_for_lost_ack]	= "LostAck",
-	[rxrpc_propose_ack_ping_for_lost_reply]	= "LostRpl",
-	[rxrpc_propose_ack_ping_for_params]	= "Params ",
-	[rxrpc_propose_ack_processing_op]	= "ProcOp ",
-	[rxrpc_propose_ack_respond_to_ack]	= "Rsp2Ack",
-	[rxrpc_propose_ack_respond_to_ping]	= "Rsp2Png",
-	[rxrpc_propose_ack_retry_tx]		= "RetryTx",
-	[rxrpc_propose_ack_rotate_rx]		= "RxAck  ",
-	[rxrpc_propose_ack_terminal_ack]	= "ClTerm ",
-};
-
-const char *const rxrpc_propose_ack_outcomes[rxrpc_propose_ack__nr_outcomes] = {
-	[rxrpc_propose_ack_use]			= "",
-	[rxrpc_propose_ack_update]		= " Update",
-	[rxrpc_propose_ack_subsume]		= " Subsume",
-};
-
-const char rxrpc_congest_modes[NR__RXRPC_CONGEST_MODES][10] = {
-	[RXRPC_CALL_SLOW_START]		= "SlowStart",
-	[RXRPC_CALL_CONGEST_AVOIDANCE]	= "CongAvoid",
-	[RXRPC_CALL_PACKET_LOSS]	= "PktLoss  ",
-	[RXRPC_CALL_FAST_RETRANSMIT]	= "FastReTx ",
-};
-
-const char rxrpc_congest_changes[rxrpc_congest__nr_change][9] = {
-	[rxrpc_cong_begin_retransmission]	= " Retrans",
-	[rxrpc_cong_cleared_nacks]		= " Cleared",
-	[rxrpc_cong_new_low_nack]		= " NewLowN",
-	[rxrpc_cong_no_change]			= "",
-	[rxrpc_cong_progress]			= " Progres",
-	[rxrpc_cong_retransmit_again]		= " ReTxAgn",
-	[rxrpc_cong_rtt_window_end]		= " RttWinE",
-	[rxrpc_cong_saw_nack]			= " SawNack",
-};
