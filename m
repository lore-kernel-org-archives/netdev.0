From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 8/8] rxrpc: Implement slow-start
Date: Sun, 25 Sep 2016 00:25:51 +0100
Message-ID: <147475955185.15231.14974887203708699957.stgit@warthog.procyon.org.uk>
References: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52304 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966003AbcIXXZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Sep 2016 19:25:59 -0400
In-Reply-To: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement RxRPC slow-start, which is similar to RFC 5681 for TCP.  A
tracepoint is added to log the state of the congestion management algorithm
and the decisions it makes.

Notes:

 (1) Since we send fixed-size DATA packets (apart from the final packet in
     each phase), counters and calculations are in terms of packets rather
     than bytes.

 (2) The ACK packet carries the equivalent of TCP SACK.

 (3) The FLIGHT_SIZE calculation in RFC 5681 doesn't seem particularly
     suited to SACK of a small number of packets.  It seems that, almost
     inevitably, by the time three 'duplicate' ACKs have been seen, we have
     narrowed the loss down to one or two missing packets, and the
     FLIGHT_SIZE calculation ends up as 2.

 (4) In rxrpc_resend(), if there was no data that apparently needed
     retransmission, we transmit a PING ACK to ask the peer to tell us what
     its Rx window state is.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   45 +++++++++++
 net/rxrpc/ar-internal.h      |   53 +++++++++++++
 net/rxrpc/call_event.c       |   36 ++++++++-
 net/rxrpc/call_object.c      |   13 +++
 net/rxrpc/conn_event.c       |    1 
 net/rxrpc/input.c            |  169 +++++++++++++++++++++++++++++++++++++++++-
 net/rxrpc/misc.c             |   19 +++++
 net/rxrpc/output.c           |    9 ++
 net/rxrpc/sendmsg.c          |    7 +-
 9 files changed, 339 insertions(+), 13 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 56475497043d..ada12d00118c 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -570,6 +570,51 @@ TRACE_EVENT(rxrpc_retransmit,
 		      __entry->expiry)
 	    );
 
+TRACE_EVENT(rxrpc_congest,
+	    TP_PROTO(struct rxrpc_call *call, struct rxrpc_ack_summary *summary,
+		     rxrpc_serial_t ack_serial, enum rxrpc_congest_change change),
+
+	    TP_ARGS(call, summary, ack_serial, change),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,		call		)
+		    __field(enum rxrpc_congest_change,		change		)
+		    __field(rxrpc_seq_t,			hard_ack	)
+		    __field(rxrpc_seq_t,			top		)
+		    __field(rxrpc_seq_t,			lowest_nak	)
+		    __field(rxrpc_serial_t,			ack_serial	)
+		    __field_struct(struct rxrpc_ack_summary,	sum		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call	= call;
+		    __entry->change	= change;
+		    __entry->hard_ack	= call->tx_hard_ack;
+		    __entry->top	= call->tx_top;
+		    __entry->lowest_nak	= call->acks_lowest_nak;
+		    __entry->ack_serial	= ack_serial;
+		    memcpy(&__entry->sum, summary, sizeof(__entry->sum));
+			   ),
+
+	    TP_printk("c=%p %08x %s %08x %s cw=%u ss=%u nr=%u,%u nw=%u,%u r=%u b=%u u=%u d=%u l=%x%s%s%s",
+		      __entry->call,
+		      __entry->ack_serial,
+		      rxrpc_ack_names[__entry->sum.ack_reason],
+		      __entry->hard_ack,
+		      rxrpc_congest_modes[__entry->sum.mode],
+		      __entry->sum.cwnd,
+		      __entry->sum.ssthresh,
+		      __entry->sum.nr_acks, __entry->sum.nr_nacks,
+		      __entry->sum.nr_new_acks, __entry->sum.nr_new_nacks,
+		      __entry->sum.nr_rot_new_acks,
+		      __entry->top - __entry->hard_ack,
+		      __entry->sum.cumulative_acks,
+		      __entry->sum.dup_acks,
+		      __entry->lowest_nak, __entry->sum.new_low_nack ? "!" : "",
+		      rxrpc_congest_changes[__entry->change],
+		      __entry->sum.retrans_timeo ? " rTxTo" : "")
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index b1e697fc9ffb..ca96e547cb9a 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -402,6 +402,7 @@ enum rxrpc_call_flag {
 	RXRPC_CALL_RX_LAST,		/* Received the last packet (at rxtx_top) */
 	RXRPC_CALL_TX_LAST,		/* Last packet in Tx buffer (at rxtx_top) */
 	RXRPC_CALL_PINGING,		/* Ping in process */
+	RXRPC_CALL_RETRANS_TIMEOUT,	/* Retransmission due to timeout occurred */
 };
 
 /*
@@ -447,6 +448,17 @@ enum rxrpc_call_completion {
 };
 
 /*
+ * Call Tx congestion management modes.
+ */
+enum rxrpc_congest_mode {
+	RXRPC_CALL_SLOW_START,
+	RXRPC_CALL_CONGEST_AVOIDANCE,
+	RXRPC_CALL_PACKET_LOSS,
+	RXRPC_CALL_FAST_RETRANSMIT,
+	NR__RXRPC_CONGEST_MODES
+};
+
+/*
  * RxRPC call definition
  * - matched by { connection, call_id }
  */
@@ -518,6 +530,20 @@ struct rxrpc_call {
 						 * not hard-ACK'd packet follows this.
 						 */
 	rxrpc_seq_t		tx_top;		/* Highest Tx slot allocated. */
+
+	/* TCP-style slow-start congestion control [RFC5681].  Since the SMSS
+	 * is fixed, we keep these numbers in terms of segments (ie. DATA
+	 * packets) rather than bytes.
+	 */
+#define RXRPC_TX_SMSS		RXRPC_JUMBO_DATALEN
+	u8			cong_cwnd;	/* Congestion window size */
+	u8			cong_extra;	/* Extra to send for congestion management */
+	u8			cong_ssthresh;	/* Slow-start threshold */
+	enum rxrpc_congest_mode	cong_mode:8;	/* Congestion management mode */
+	u8			cong_dup_acks;	/* Count of ACKs showing missing packets */
+	u8			cong_cumul_acks; /* Cumulative ACK count */
+	ktime_t			cong_tstamp;	/* Last time cwnd was changed */
+
 	rxrpc_seq_t		rx_hard_ack;	/* Dead slot in buffer; the first received but not
 						 * consumed packet follows this.
 						 */
@@ -539,12 +565,13 @@ struct rxrpc_call {
 	ktime_t			ackr_ping_time;	/* Time last ping sent */
 
 	/* transmission-phase ACK management */
+	ktime_t			acks_latest_ts;	/* Timestamp of latest ACK received */
 	rxrpc_serial_t		acks_latest;	/* serial number of latest ACK received */
 	rxrpc_seq_t		acks_lowest_nak; /* Lowest NACK in the buffer (or ==tx_hard_ack) */
 };
 
 /*
- * Summary of a new ACK and the changes it made.
+ * Summary of a new ACK and the changes it made to the Tx buffer packet states.
  */
 struct rxrpc_ack_summary {
 	u8			ack_reason;
@@ -554,6 +581,14 @@ struct rxrpc_ack_summary {
 	u8			nr_new_nacks;		/* Number of new NACKs in packet */
 	u8			nr_rot_new_acks;	/* Number of rotated new ACKs */
 	bool			new_low_nack;		/* T if new low NACK found */
+	bool			retrans_timeo;		/* T if reTx due to timeout happened */
+	u8			flight_size;		/* Number of unreceived transmissions */
+	/* Place to stash values for tracing */
+	enum rxrpc_congest_mode	mode:8;
+	u8			cwnd;
+	u8			ssthresh;
+	u8			dup_acks;
+	u8			cumulative_acks;
 };
 
 enum rxrpc_skb_trace {
@@ -709,6 +744,7 @@ extern const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8];
 enum rxrpc_propose_ack_trace {
 	rxrpc_propose_ack_client_tx_end,
 	rxrpc_propose_ack_input_data,
+	rxrpc_propose_ack_ping_for_lost_ack,
 	rxrpc_propose_ack_ping_for_lost_reply,
 	rxrpc_propose_ack_ping_for_params,
 	rxrpc_propose_ack_respond_to_ack,
@@ -729,6 +765,21 @@ enum rxrpc_propose_ack_outcome {
 extern const char rxrpc_propose_ack_traces[rxrpc_propose_ack__nr_trace][8];
 extern const char *const rxrpc_propose_ack_outcomes[rxrpc_propose_ack__nr_outcomes];
 
+enum rxrpc_congest_change {
+	rxrpc_cong_begin_retransmission,
+	rxrpc_cong_cleared_nacks,
+	rxrpc_cong_new_low_nack,
+	rxrpc_cong_no_change,
+	rxrpc_cong_progress,
+	rxrpc_cong_retransmit_again,
+	rxrpc_cong_rtt_window_end,
+	rxrpc_cong_saw_nack,
+	rxrpc_congest__nr_change
+};
+
+extern const char rxrpc_congest_modes[NR__RXRPC_CONGEST_MODES][10];
+extern const char rxrpc_congest_changes[rxrpc_congest__nr_change][9];
+
 extern const char *const rxrpc_pkts[];
 extern const char const rxrpc_ack_names[RXRPC_ACK__INVALID + 1][4];
 
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 05b94d1acf52..0e8478012212 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -147,6 +147,14 @@ void rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 }
 
 /*
+ * Handle congestion being detected by the retransmit timeout.
+ */
+static void rxrpc_congestion_timeout(struct rxrpc_call *call)
+{
+	set_bit(RXRPC_CALL_RETRANS_TIMEOUT, &call->flags);
+}
+
+/*
  * Perform retransmission of NAK'd and unack'd packets.
  */
 static void rxrpc_resend(struct rxrpc_call *call)
@@ -154,9 +162,9 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	struct rxrpc_skb_priv *sp;
 	struct sk_buff *skb;
 	rxrpc_seq_t cursor, seq, top;
-	ktime_t now = ktime_get_real(), max_age, oldest,  resend_at;
+	ktime_t now = ktime_get_real(), max_age, oldest, resend_at, ack_ts;
 	int ix;
-	u8 annotation, anno_type;
+	u8 annotation, anno_type, retrans = 0, unacked = 0;
 
 	_enter("{%d,%d}", call->tx_hard_ack, call->tx_top);
 
@@ -193,10 +201,13 @@ static void rxrpc_resend(struct rxrpc_call *call)
 					oldest = skb->tstamp;
 				continue;
 			}
+			if (!(annotation & RXRPC_TX_ANNO_RESENT))
+				unacked++;
 		}
 
 		/* Okay, we need to retransmit a packet. */
 		call->rxtx_annotations[ix] = RXRPC_TX_ANNO_RETRANS | annotation;
+		retrans++;
 		trace_rxrpc_retransmit(call, seq, annotation | anno_type,
 				       ktime_to_ns(ktime_sub(skb->tstamp, max_age)));
 	}
@@ -210,6 +221,25 @@ static void rxrpc_resend(struct rxrpc_call *call)
 		    * reached the nsec timeout yet.
 		    */
 
+	if (unacked)
+		rxrpc_congestion_timeout(call);
+
+	/* If there was nothing that needed retransmission then it's likely
+	 * that an ACK got lost somewhere.  Send a ping to find out instead of
+	 * retransmitting data.
+	 */
+	if (!retrans) {
+		rxrpc_set_timer(call, rxrpc_timer_set_for_resend);
+		spin_unlock_bh(&call->lock);
+		ack_ts = ktime_sub(now, call->acks_latest_ts);
+		if (ktime_to_ns(ack_ts) < call->peer->rtt)
+			goto out;
+		rxrpc_propose_ACK(call, RXRPC_ACK_PING, 0, 0, true, false,
+				  rxrpc_propose_ack_ping_for_lost_ack);
+		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+		goto out;
+	}
+
 	/* Now go through the Tx window and perform the retransmissions.  We
 	 * have to drop the lock for each send.  If an ACK comes in whilst the
 	 * lock is dropped, it may clear some of the retransmission markers for
@@ -260,6 +290,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 
 out_unlock:
 	spin_unlock_bh(&call->lock);
+out:
 	_leave("");
 }
 
@@ -293,6 +324,7 @@ recheck_state:
 	if (time_after_eq(now, call->expire_at)) {
 		rxrpc_abort_call("EXP", call, 0, RX_CALL_TIMEOUT, ETIME);
 		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
+		goto recheck_state;
 	}
 
 	if (test_and_clear_bit(RXRPC_CALL_EV_ACK, &call->events) ||
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index a53f4c2c0025..d4b3293b78fa 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -160,6 +160,14 @@ struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 	call->rx_winsize = rxrpc_rx_window_size;
 	call->tx_winsize = 16;
 	call->rx_expect_next = 1;
+
+	if (RXRPC_TX_SMSS > 2190)
+		call->cong_cwnd = 2;
+	else if (RXRPC_TX_SMSS > 1095)
+		call->cong_cwnd = 3;
+	else
+		call->cong_cwnd = 4;
+	call->cong_ssthresh = RXRPC_RXTX_BUFF_SIZE - 1;
 	return call;
 
 nomem_2:
@@ -176,6 +184,7 @@ static struct rxrpc_call *rxrpc_alloc_client_call(struct sockaddr_rxrpc *srx,
 						  gfp_t gfp)
 {
 	struct rxrpc_call *call;
+	ktime_t now;
 
 	_enter("");
 
@@ -185,6 +194,9 @@ static struct rxrpc_call *rxrpc_alloc_client_call(struct sockaddr_rxrpc *srx,
 	call->state = RXRPC_CALL_CLIENT_AWAIT_CONN;
 	call->service_id = srx->srx_service;
 	call->tx_phase = true;
+	now = ktime_get_real();
+	call->acks_latest_ts = now;
+	call->cong_tstamp = now;
 
 	_leave(" = %p", call);
 	return call;
@@ -325,6 +337,7 @@ void rxrpc_incoming_call(struct rxrpc_sock *rx,
 	call->state		= RXRPC_CALL_SERVER_ACCEPTING;
 	if (sp->hdr.securityIndex > 0)
 		call->state	= RXRPC_CALL_SERVER_SECURING;
+	call->cong_tstamp	= skb->tstamp;
 
 	/* Set the channel for this call.  We don't get channel_lock as we're
 	 * only defending against the data_ready handler (which we're called
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index a1cf1ec5f29e..37609ce89f52 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -97,6 +97,7 @@ static void rxrpc_conn_retransmit_call(struct rxrpc_connection *conn,
 		pkt.info.maxMTU		= htonl(mtu);
 		pkt.info.rwind		= htonl(rxrpc_rx_window_size);
 		pkt.info.jumbo_max	= htonl(rxrpc_rx_jumbo_max);
+		pkt.whdr.flags		|= RXRPC_SLOW_START_OK;
 		len += sizeof(pkt.ack) + sizeof(pkt.info);
 		break;
 	}
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 0344f4494eb7..094720dd1eaf 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -37,6 +37,166 @@ static void rxrpc_proto_abort(const char *why,
 }
 
 /*
+ * Do TCP-style congestion management [RFC 5681].
+ */
+static void rxrpc_congestion_management(struct rxrpc_call *call,
+					struct sk_buff *skb,
+					struct rxrpc_ack_summary *summary)
+{
+	enum rxrpc_congest_change change = rxrpc_cong_no_change;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	unsigned int cumulative_acks = call->cong_cumul_acks;
+	unsigned int cwnd = call->cong_cwnd;
+	bool resend = false;
+
+	summary->flight_size =
+		(call->tx_top - call->tx_hard_ack) - summary->nr_acks;
+
+	if (test_and_clear_bit(RXRPC_CALL_RETRANS_TIMEOUT, &call->flags)) {
+		summary->retrans_timeo = true;
+		call->cong_ssthresh = max_t(unsigned int,
+					    summary->flight_size / 2, 2);
+		cwnd = 1;
+		if (cwnd > call->cong_ssthresh &&
+		    call->cong_mode == RXRPC_CALL_SLOW_START) {
+			call->cong_mode = RXRPC_CALL_CONGEST_AVOIDANCE;
+			call->cong_tstamp = skb->tstamp;
+			cumulative_acks = 0;
+		}
+	}
+
+	cumulative_acks += summary->nr_new_acks;
+	cumulative_acks += summary->nr_rot_new_acks;
+	if (cumulative_acks > 255)
+		cumulative_acks = 255;
+
+	summary->mode = call->cong_mode;
+	summary->cwnd = call->cong_cwnd;
+	summary->ssthresh = call->cong_ssthresh;
+	summary->cumulative_acks = cumulative_acks;
+	summary->dup_acks = call->cong_dup_acks;
+
+	switch (call->cong_mode) {
+	case RXRPC_CALL_SLOW_START:
+		if (summary->nr_nacks > 0)
+			goto packet_loss_detected;
+		if (summary->cumulative_acks > 0)
+			cwnd += 1;
+		if (cwnd > call->cong_ssthresh) {
+			call->cong_mode = RXRPC_CALL_CONGEST_AVOIDANCE;
+			call->cong_tstamp = skb->tstamp;
+		}
+		goto out;
+
+	case RXRPC_CALL_CONGEST_AVOIDANCE:
+		if (summary->nr_nacks > 0)
+			goto packet_loss_detected;
+
+		/* We analyse the number of packets that get ACK'd per RTT
+		 * period and increase the window if we managed to fill it.
+		 */
+		if (call->peer->rtt_usage == 0)
+			goto out;
+		if (ktime_before(skb->tstamp,
+				 ktime_add_ns(call->cong_tstamp,
+					      call->peer->rtt)))
+			goto out_no_clear_ca;
+		change = rxrpc_cong_rtt_window_end;
+		call->cong_tstamp = skb->tstamp;
+		if (cumulative_acks >= cwnd)
+			cwnd++;
+		goto out;
+
+	case RXRPC_CALL_PACKET_LOSS:
+		if (summary->nr_nacks == 0)
+			goto resume_normality;
+
+		if (summary->new_low_nack) {
+			change = rxrpc_cong_new_low_nack;
+			call->cong_dup_acks = 1;
+			if (call->cong_extra > 1)
+				call->cong_extra = 1;
+			goto send_extra_data;
+		}
+
+		call->cong_dup_acks++;
+		if (call->cong_dup_acks < 3)
+			goto send_extra_data;
+
+		change = rxrpc_cong_begin_retransmission;
+		call->cong_mode = RXRPC_CALL_FAST_RETRANSMIT;
+		call->cong_ssthresh = max_t(unsigned int,
+					    summary->flight_size / 2, 2);
+		cwnd = call->cong_ssthresh + 3;
+		call->cong_extra = 0;
+		call->cong_dup_acks = 0;
+		resend = true;
+		goto out;
+
+	case RXRPC_CALL_FAST_RETRANSMIT:
+		if (!summary->new_low_nack) {
+			if (summary->nr_new_acks == 0)
+				cwnd += 1;
+			call->cong_dup_acks++;
+			if (call->cong_dup_acks == 2) {
+				change = rxrpc_cong_retransmit_again;
+				call->cong_dup_acks = 0;
+				resend = true;
+			}
+		} else {
+			change = rxrpc_cong_progress;
+			cwnd = call->cong_ssthresh;
+			if (summary->nr_nacks == 0)
+				goto resume_normality;
+		}
+		goto out;
+
+	default:
+		BUG();
+		goto out;
+	}
+
+resume_normality:
+	change = rxrpc_cong_cleared_nacks;
+	call->cong_dup_acks = 0;
+	call->cong_extra = 0;
+	call->cong_tstamp = skb->tstamp;
+	if (cwnd <= call->cong_ssthresh)
+		call->cong_mode = RXRPC_CALL_SLOW_START;
+	else
+		call->cong_mode = RXRPC_CALL_CONGEST_AVOIDANCE;
+out:
+	cumulative_acks = 0;
+out_no_clear_ca:
+	if (cwnd >= RXRPC_RXTX_BUFF_SIZE - 1)
+		cwnd = RXRPC_RXTX_BUFF_SIZE - 1;
+	call->cong_cwnd = cwnd;
+	call->cong_cumul_acks = cumulative_acks;
+	trace_rxrpc_congest(call, summary, sp->hdr.serial, change);
+	if (resend && !test_and_set_bit(RXRPC_CALL_EV_RESEND, &call->events))
+		rxrpc_queue_call(call);
+	return;
+
+packet_loss_detected:
+	change = rxrpc_cong_saw_nack;
+	call->cong_mode = RXRPC_CALL_PACKET_LOSS;
+	call->cong_dup_acks = 0;
+	goto send_extra_data;
+
+send_extra_data:
+	/* Send some previously unsent DATA if we have some to advance the ACK
+	 * state.
+	 */
+	if (call->rxtx_annotations[call->tx_top & RXRPC_RXTX_BUFF_MASK] &
+	    RXRPC_TX_ANNO_LAST ||
+	    summary->nr_acks != call->tx_top - call->tx_hard_ack) {
+		call->cong_extra++;
+		wake_up(&call->waitq);
+	}
+	goto out_no_clear_ca;
+}
+
+/*
  * Ping the other end to fill our RTT cache and to retrieve the rwind
  * and MTU parameters.
  */
@@ -524,7 +684,6 @@ static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
 				  rxrpc_seq_t seq, int nr_acks,
 				  struct rxrpc_ack_summary *summary)
 {
-	bool resend = false;
 	int ix;
 	u8 annotation, anno_type;
 
@@ -556,16 +715,11 @@ static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
 				continue;
 			call->rxtx_annotations[ix] =
 				RXRPC_TX_ANNO_NAK | annotation;
-			resend = true;
 			break;
 		default:
 			return rxrpc_proto_abort("SFT", call, 0);
 		}
 	}
-
-	if (resend &&
-	    !test_and_set_bit(RXRPC_CALL_EV_RESEND, &call->events))
-		rxrpc_queue_call(call);
 }
 
 /*
@@ -663,6 +817,7 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 		       sp->hdr.serial, call->acks_latest);
 		return;
 	}
+	call->acks_latest_ts = skb->tstamp;
 	call->acks_latest = sp->hdr.serial;
 
 	if (before(hard_ack, call->tx_hard_ack) ||
@@ -692,6 +847,8 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 		rxrpc_propose_ACK(call, RXRPC_ACK_PING, skew, sp->hdr.serial,
 				  false, true,
 				  rxrpc_propose_ack_ping_for_lost_reply);
+
+	return rxrpc_congestion_management(call, skb, &summary);
 }
 
 /*
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index a608769343e6..aedb8978226d 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -200,6 +200,7 @@ const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8] = {
 const char rxrpc_propose_ack_traces[rxrpc_propose_ack__nr_trace][8] = {
 	[rxrpc_propose_ack_client_tx_end]	= "ClTxEnd",
 	[rxrpc_propose_ack_input_data]		= "DataIn ",
+	[rxrpc_propose_ack_ping_for_lost_ack]	= "LostAck",
 	[rxrpc_propose_ack_ping_for_lost_reply]	= "LostRpl",
 	[rxrpc_propose_ack_ping_for_params]	= "Params ",
 	[rxrpc_propose_ack_respond_to_ack]	= "Rsp2Ack",
@@ -214,3 +215,21 @@ const char *const rxrpc_propose_ack_outcomes[rxrpc_propose_ack__nr_outcomes] = {
 	[rxrpc_propose_ack_update]		= " Update",
 	[rxrpc_propose_ack_subsume]		= " Subsume",
 };
+
+const char rxrpc_congest_modes[NR__RXRPC_CONGEST_MODES][10] = {
+	[RXRPC_CALL_SLOW_START]		= "SlowStart",
+	[RXRPC_CALL_CONGEST_AVOIDANCE]	= "CongAvoid",
+	[RXRPC_CALL_PACKET_LOSS]	= "PktLoss  ",
+	[RXRPC_CALL_FAST_RETRANSMIT]	= "FastReTx ",
+};
+
+const char rxrpc_congest_changes[rxrpc_congest__nr_change][9] = {
+	[rxrpc_cong_begin_retransmission]	= " Retrans",
+	[rxrpc_cong_cleared_nacks]		= " Cleared",
+	[rxrpc_cong_new_low_nack]		= " NewLowN",
+	[rxrpc_cong_no_change]			= "",
+	[rxrpc_cong_progress]			= " Progres",
+	[rxrpc_cong_retransmit_again]		= " ReTxAgn",
+	[rxrpc_cong_rtt_window_end]		= " RttWinE",
+	[rxrpc_cong_saw_nack]			= " SawNack",
+};
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 3eb01445e814..cf43a715685e 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -157,6 +157,8 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 		spin_unlock_bh(&call->lock);
 
 
+		pkt->whdr.flags |= RXRPC_SLOW_START_OK;
+
 		iov[0].iov_len += sizeof(pkt->ack) + n;
 		iov[1].iov_base = &pkt->ackinfo;
 		iov[1].iov_len	= sizeof(pkt->ackinfo);
@@ -276,8 +278,11 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	msg.msg_controllen = 0;
 	msg.msg_flags = 0;
 
-	/* If our RTT cache needs working on, request an ACK. */
-	if ((call->peer->rtt_usage < 3 && sp->hdr.seq & 1) ||
+	/* If our RTT cache needs working on, request an ACK.  Also request
+	 * ACKs if a DATA packet appears to have been lost.
+	 */
+	if (call->cong_mode == RXRPC_CALL_FAST_RETRANSMIT ||
+	    (call->peer->rtt_usage < 3 && sp->hdr.seq & 1) ||
 	    ktime_before(ktime_add_ms(call->peer->rtt_last_req, 1000),
 			 ktime_get_real()))
 		whdr.flags |= RXRPC_REQUEST_ACK;
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 99939372b5a4..1f8040d82395 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -45,7 +45,9 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		ret = 0;
-		if (call->tx_top - call->tx_hard_ack < call->tx_winsize)
+		if (call->tx_top - call->tx_hard_ack <
+		    min_t(unsigned int, call->tx_winsize,
+			  call->cong_cwnd + call->cong_extra))
 			break;
 		if (call->state >= RXRPC_CALL_COMPLETE) {
 			ret = -call->error;
@@ -203,7 +205,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			_debug("alloc");
 
 			if (call->tx_top - call->tx_hard_ack >=
-			    call->tx_winsize) {
+			    min_t(unsigned int, call->tx_winsize,
+				  call->cong_cwnd + call->cong_extra)) {
 				ret = -EAGAIN;
 				if (msg->msg_flags & MSG_DONTWAIT)
 					goto maybe_error;
