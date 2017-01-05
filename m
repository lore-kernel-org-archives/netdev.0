From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/3] rxrpc: Add some more tracing
Date: Thu, 05 Jan 2017 14:32:04 +0000
Message-ID: <148362672452.31085.13864786838575838782.stgit@warthog.procyon.org.uk>
References: <148362671062.31085.13249164388796003311.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55772 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033948AbdAEOcH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 09:32:07 -0500
In-Reply-To: <148362671062.31085.13249164388796003311.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the following extra tracing information:

 (1) Modify the rxrpc_transmit tracepoint to record the Tx window size as
     this is varied by the slow-start algorithm.

 (2) Modify the rxrpc_rx_ack tracepoint to record more information from
     received ACK packets.

 (3) Add an rxrpc_rx_data tracepoint to record the information in DATA
     packets.

 (4) Add an rxrpc_disconnect_call tracepoint to record call disconnection,
     including the reason the call was disconnected.

 (5) Add an rxrpc_improper_term tracepoint to record implicit termination
     of a call by a client either by starting a new call on a particular
     connection channel without first transmitting the final ACK for the
     previous call.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   94 ++++++++++++++++++++++++++++++++++++++++--
 net/rxrpc/conn_object.c      |    1 
 net/rxrpc/input.c            |    6 ++-
 3 files changed, 95 insertions(+), 6 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 2395a57462c9..593f586545eb 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -595,6 +595,7 @@ TRACE_EVENT(rxrpc_transmit,
 		    __field(enum rxrpc_transmit_trace,	why		)
 		    __field(rxrpc_seq_t,		tx_hard_ack	)
 		    __field(rxrpc_seq_t,		tx_top		)
+		    __field(int,			tx_winsize	)
 			     ),
 
 	    TP_fast_assign(
@@ -602,38 +603,81 @@ TRACE_EVENT(rxrpc_transmit,
 		    __entry->why = why;
 		    __entry->tx_hard_ack = call->tx_hard_ack;
 		    __entry->tx_top = call->tx_top;
+		    __entry->tx_winsize = call->tx_winsize;
 			   ),
 
-	    TP_printk("c=%p %s f=%08x n=%u",
+	    TP_printk("c=%p %s f=%08x n=%u/%u",
 		      __entry->call,
 		      __print_symbolic(__entry->why, rxrpc_transmit_traces),
 		      __entry->tx_hard_ack + 1,
-		      __entry->tx_top - __entry->tx_hard_ack)
+		      __entry->tx_top - __entry->tx_hard_ack,
+		      __entry->tx_winsize)
+	    );
+
+TRACE_EVENT(rxrpc_rx_data,
+	    TP_PROTO(struct rxrpc_call *call, rxrpc_seq_t seq,
+		     rxrpc_serial_t serial, u8 flags, u8 anno),
+
+	    TP_ARGS(call, seq, serial, flags, anno),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(rxrpc_seq_t,		seq		)
+		    __field(rxrpc_serial_t,		serial		)
+		    __field(u8,				flags		)
+		    __field(u8,				anno		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->seq = seq;
+		    __entry->serial = serial;
+		    __entry->flags = flags;
+		    __entry->anno = anno;
+			   ),
+
+	    TP_printk("c=%p DATA %08x q=%08x fl=%02x a=%02x",
+		      __entry->call,
+		      __entry->serial,
+		      __entry->seq,
+		      __entry->flags,
+		      __entry->anno)
 	    );
 
 TRACE_EVENT(rxrpc_rx_ack,
-	    TP_PROTO(struct rxrpc_call *call, rxrpc_seq_t first, u8 reason, u8 n_acks),
+	    TP_PROTO(struct rxrpc_call *call,
+		     rxrpc_serial_t serial, rxrpc_serial_t ack_serial,
+		     rxrpc_seq_t first, rxrpc_seq_t prev, u8 reason, u8 n_acks),
 
-	    TP_ARGS(call, first, reason, n_acks),
+	    TP_ARGS(call, serial, ack_serial, first, prev, reason, n_acks),
 
 	    TP_STRUCT__entry(
 		    __field(struct rxrpc_call *,	call		)
+		    __field(rxrpc_serial_t,		serial		)
+		    __field(rxrpc_serial_t,		ack_serial	)
 		    __field(rxrpc_seq_t,		first		)
+		    __field(rxrpc_seq_t,		prev		)
 		    __field(u8,				reason		)
 		    __field(u8,				n_acks		)
 			     ),
 
 	    TP_fast_assign(
 		    __entry->call = call;
+		    __entry->serial = serial;
+		    __entry->ack_serial = ack_serial;
 		    __entry->first = first;
+		    __entry->prev = prev;
 		    __entry->reason = reason;
 		    __entry->n_acks = n_acks;
 			   ),
 
-	    TP_printk("c=%p %s f=%08x n=%u",
+	    TP_printk("c=%p %08x %s r=%08x f=%08x p=%08x n=%u",
 		      __entry->call,
+		      __entry->serial,
 		      __print_symbolic(__entry->reason, rxrpc_ack_names),
+		      __entry->ack_serial,
 		      __entry->first,
+		      __entry->prev,
 		      __entry->n_acks)
 	    );
 
@@ -1001,6 +1045,46 @@ TRACE_EVENT(rxrpc_congest,
 		      __entry->sum.retrans_timeo ? " rTxTo" : "")
 	    );
 
+TRACE_EVENT(rxrpc_disconnect_call,
+	    TP_PROTO(struct rxrpc_call *call),
+
+	    TP_ARGS(call),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(u32,			abort_code	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->abort_code = call->abort_code;
+			   ),
+
+	    TP_printk("c=%p ab=%08x",
+		      __entry->call,
+		      __entry->abort_code)
+	    );
+
+TRACE_EVENT(rxrpc_improper_term,
+	    TP_PROTO(struct rxrpc_call *call),
+
+	    TP_ARGS(call),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(u32,			abort_code	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->abort_code = call->abort_code;
+			   ),
+
+	    TP_printk("c=%p ab=%08x",
+		      __entry->call,
+		      __entry->abort_code)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index e1e83af47866..b0ecb770fdce 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -173,6 +173,7 @@ void __rxrpc_disconnect_call(struct rxrpc_connection *conn,
 		/* Save the result of the call so that we can repeat it if necessary
 		 * through the channel, whilst disposing of the actual call record.
 		 */
+		trace_rxrpc_disconnect_call(call);
 		chan->last_service_id = call->service_id;
 		if (call->abort_code) {
 			chan->last_abort = call->abort_code;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 7c2abd85def9..78ec33477adf 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -481,6 +481,7 @@ static void rxrpc_input_data(struct rxrpc_call *call, struct sk_buff *skb,
 			return rxrpc_proto_abort("LSA", call, seq);
 	}
 
+	trace_rxrpc_rx_data(call, seq, serial, flags, annotation);
 	if (before_eq(seq, hard_ack)) {
 		ack = RXRPC_ACK_DUPLICATE;
 		ack_serial = serial;
@@ -765,7 +766,9 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	summary.ack_reason = (buf.ack.reason < RXRPC_ACK__INVALID ?
 			      buf.ack.reason : RXRPC_ACK__INVALID);
 
-	trace_rxrpc_rx_ack(call, first_soft_ack, summary.ack_reason, nr_acks);
+	trace_rxrpc_rx_ack(call, sp->hdr.serial, acked_serial,
+			   first_soft_ack, ntohl(buf.ack.previousPacket),
+			   summary.ack_reason, nr_acks);
 
 	if (buf.ack.reason == RXRPC_ACK_PING_RESPONSE)
 		rxrpc_input_ping_response(call, skb->tstamp, acked_serial,
@@ -951,6 +954,7 @@ static void rxrpc_input_implicit_end_call(struct rxrpc_connection *conn,
 		break;
 	}
 
+	trace_rxrpc_improper_term(call);
 	__rxrpc_disconnect_call(conn, call);
 	rxrpc_notify_socket(call);
 }
