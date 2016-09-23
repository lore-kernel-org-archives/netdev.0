From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 14/15] rxrpc: Add tracepoint for ACK proposal
Date: Fri, 23 Sep 2016 16:16:54 +0100
Message-ID: <147464381419.5090.14059613688273483196.stgit@warthog.procyon.org.uk>
References: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a tracepoint to log proposed ACKs, including whether the proposal is
used to update a pending ACK or is discarded in favour of an easlier,
higher priority ACK.

Whilst we're at it, get rid of the rxrpc_acks() function and access the
name array directly.  We do, however, need to validate the ACK reason
number given to trace_rxrpc_rx_ack() to make sure we don't overrun the
array.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/rxrpc/packet.h       |    1 +
 include/trace/events/rxrpc.h |   42 ++++++++++++++++++++++++++++++++++++++++--
 net/rxrpc/ar-internal.h      |   25 +++++++++++++++++++++++--
 net/rxrpc/call_event.c       |   21 ++++++++++++++-------
 net/rxrpc/input.c            |   19 +++++++++++++------
 net/rxrpc/misc.c             |   30 +++++++++++++++++++-----------
 net/rxrpc/output.c           |    3 ++-
 net/rxrpc/recvmsg.c          |    3 ++-
 8 files changed, 114 insertions(+), 30 deletions(-)

diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index fd6eb3a60a8c..703a64b4681a 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -123,6 +123,7 @@ struct rxrpc_ackpacket {
 #define RXRPC_ACK_PING_RESPONSE		7	/* response to RXRPC_ACK_PING */
 #define RXRPC_ACK_DELAY			8	/* nothing happened since received packet */
 #define RXRPC_ACK_IDLE			9	/* ACK due to fully received ACK window */
+#define RXRPC_ACK__INVALID		10	/* Representation of invalid ACK reason */
 
 	uint8_t		nAcks;		/* number of ACKs */
 #define RXRPC_MAXACKS	255
diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 9413b17ba04b..d67a8c6b085a 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -251,7 +251,7 @@ TRACE_EVENT(rxrpc_rx_ack,
 
 	    TP_printk("c=%p %s f=%08x n=%u",
 		      __entry->call,
-		      rxrpc_acks(__entry->reason),
+		      rxrpc_ack_names[__entry->reason],
 		      __entry->first,
 		      __entry->n_acks)
 	    );
@@ -314,7 +314,7 @@ TRACE_EVENT(rxrpc_tx_ack,
 	    TP_printk(" c=%p ACK  %08x %s f=%08x r=%08x n=%u",
 		      __entry->call,
 		      __entry->serial,
-		      rxrpc_acks(__entry->reason),
+		      rxrpc_ack_names[__entry->reason],
 		      __entry->ack_first,
 		      __entry->ack_serial,
 		      __entry->n_acks)
@@ -505,6 +505,44 @@ TRACE_EVENT(rxrpc_rx_lose,
 		      __entry->hdr.type <= 15 ? rxrpc_pkts[__entry->hdr.type] : "?UNK")
 	    );
 
+TRACE_EVENT(rxrpc_propose_ack,
+	    TP_PROTO(struct rxrpc_call *call, enum rxrpc_propose_ack_trace why,
+		     u8 ack_reason, rxrpc_serial_t serial, bool immediate,
+		     bool background, enum rxrpc_propose_ack_outcome outcome),
+
+	    TP_ARGS(call, why, ack_reason, serial, immediate, background,
+		    outcome),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,		call		)
+		    __field(enum rxrpc_propose_ack_trace,	why		)
+		    __field(rxrpc_serial_t,			serial		)
+		    __field(u8,					ack_reason	)
+		    __field(bool,				immediate	)
+		    __field(bool,				background	)
+		    __field(enum rxrpc_propose_ack_outcome,	outcome		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call	= call;
+		    __entry->why	= why;
+		    __entry->serial	= serial;
+		    __entry->ack_reason	= ack_reason;
+		    __entry->immediate	= immediate;
+		    __entry->background	= background;
+		    __entry->outcome	= outcome;
+			   ),
+
+	    TP_printk("c=%p %s %s r=%08x i=%u b=%u%s",
+		      __entry->call,
+		      rxrpc_propose_ack_traces[__entry->why],
+		      rxrpc_ack_names[__entry->ack_reason],
+		      __entry->serial,
+		      __entry->immediate,
+		      __entry->background,
+		      rxrpc_propose_ack_outcomes[__entry->outcome])
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index e564eca75985..042dbcc52654 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -689,8 +689,28 @@ enum rxrpc_timer_trace {
 
 extern const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8];
 
+enum rxrpc_propose_ack_trace {
+	rxrpc_propose_ack_input_data,
+	rxrpc_propose_ack_ping_for_params,
+	rxrpc_propose_ack_respond_to_ack,
+	rxrpc_propose_ack_respond_to_ping,
+	rxrpc_propose_ack_retry_tx,
+	rxrpc_propose_ack_terminal_ack,
+	rxrpc_propose_ack__nr_trace
+};
+
+enum rxrpc_propose_ack_outcome {
+	rxrpc_propose_ack_use,
+	rxrpc_propose_ack_update,
+	rxrpc_propose_ack_subsume,
+	rxrpc_propose_ack__nr_outcomes
+};
+
+extern const char rxrpc_propose_ack_traces[rxrpc_propose_ack__nr_trace][8];
+extern const char *const rxrpc_propose_ack_outcomes[rxrpc_propose_ack__nr_outcomes];
+
 extern const char *const rxrpc_pkts[];
-extern const char *rxrpc_acks(u8 reason);
+extern const char const rxrpc_ack_names[RXRPC_ACK__INVALID + 1][4];
 
 #include <trace/events/rxrpc.h>
 
@@ -719,7 +739,8 @@ int rxrpc_reject_call(struct rxrpc_sock *);
  * call_event.c
  */
 void rxrpc_set_timer(struct rxrpc_call *, enum rxrpc_timer_trace);
-void rxrpc_propose_ACK(struct rxrpc_call *, u8, u16, u32, bool, bool);
+void rxrpc_propose_ACK(struct rxrpc_call *, u8, u16, u32, bool, bool,
+		       enum rxrpc_propose_ack_trace);
 void rxrpc_process_call(struct work_struct *);
 
 /*
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 90e970ba048a..fd5b11339ffb 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -58,14 +58,13 @@ out:
  */
 static void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 				u16 skew, u32 serial, bool immediate,
-				bool background)
+				bool background,
+				enum rxrpc_propose_ack_trace why)
 {
+	enum rxrpc_propose_ack_outcome outcome = rxrpc_propose_ack_use;
 	unsigned long now, ack_at, expiry = rxrpc_soft_ack_delay;
 	s8 prior = rxrpc_ack_priority[ack_reason];
 
-	_enter("{%d},%s,%%%x,%u",
-	       call->debug_id, rxrpc_acks(ack_reason), serial, immediate);
-
 	/* Update DELAY, IDLE, REQUESTED and PING_RESPONSE ACK serial
 	 * numbers, but we don't alter the timeout.
 	 */
@@ -74,15 +73,18 @@ static void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 	       call->ackr_reason, rxrpc_ack_priority[call->ackr_reason]);
 	if (ack_reason == call->ackr_reason) {
 		if (RXRPC_ACK_UPDATEABLE & (1 << ack_reason)) {
+			outcome = rxrpc_propose_ack_update;
 			call->ackr_serial = serial;
 			call->ackr_skew = skew;
 		}
 		if (!immediate)
-			return;
+			goto trace;
 	} else if (prior > rxrpc_ack_priority[call->ackr_reason]) {
 		call->ackr_reason = ack_reason;
 		call->ackr_serial = serial;
 		call->ackr_skew = skew;
+	} else {
+		outcome = rxrpc_propose_ack_subsume;
 	}
 
 	switch (ack_reason) {
@@ -124,17 +126,22 @@ static void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 			rxrpc_set_timer(call, rxrpc_timer_set_for_ack);
 		}
 	}
+
+trace:
+	trace_rxrpc_propose_ack(call, why, ack_reason, serial, immediate,
+				background, outcome);
 }
 
 /*
  * propose an ACK be sent, locking the call structure
  */
 void rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
-		       u16 skew, u32 serial, bool immediate, bool background)
+		       u16 skew, u32 serial, bool immediate, bool background,
+		       enum rxrpc_propose_ack_trace why)
 {
 	spin_lock_bh(&call->lock);
 	__rxrpc_propose_ACK(call, ack_reason, skew, serial,
-			    immediate, background);
+			    immediate, background, why);
 	spin_unlock_bh(&call->lock);
 }
 
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 19b1e189f5dc..349698d87ad1 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -49,7 +49,8 @@ static void rxrpc_send_ping(struct rxrpc_call *call, struct sk_buff *skb,
 	if (call->peer->rtt_usage < 3 ||
 	    ktime_before(ktime_add_ms(call->peer->rtt_last_req, 1000), now))
 		rxrpc_propose_ACK(call, RXRPC_ACK_PING, skew, sp->hdr.serial,
-				  true, true);
+				  true, true,
+				  rxrpc_propose_ack_ping_for_params);
 }
 
 /*
@@ -382,7 +383,8 @@ skip:
 ack:
 	if (ack)
 		rxrpc_propose_ACK(call, ack, skew, ack_serial,
-				  immediate_ack, true);
+				  immediate_ack, true,
+				  rxrpc_propose_ack_input_data);
 
 	if (sp->hdr.seq == READ_ONCE(call->rx_hard_ack) + 1)
 		rxrpc_notify_socket(call);
@@ -539,6 +541,7 @@ static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
 static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 			    u16 skew)
 {
+	u8 ack_reason;
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	union {
 		struct rxrpc_ackpacket ack;
@@ -561,8 +564,10 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	first_soft_ack = ntohl(buf.ack.firstPacket);
 	hard_ack = first_soft_ack - 1;
 	nr_acks = buf.ack.nAcks;
+	ack_reason = (buf.ack.reason < RXRPC_ACK__INVALID ?
+		      buf.ack.reason : RXRPC_ACK__INVALID);
 
-	trace_rxrpc_rx_ack(call, first_soft_ack, buf.ack.reason, nr_acks);
+	trace_rxrpc_rx_ack(call, first_soft_ack, ack_reason, nr_acks);
 
 	_proto("Rx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
 	       sp->hdr.serial,
@@ -570,7 +575,7 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	       first_soft_ack,
 	       ntohl(buf.ack.previousPacket),
 	       acked_serial,
-	       rxrpc_acks(buf.ack.reason),
+	       rxrpc_ack_names[ack_reason],
 	       buf.ack.nAcks);
 
 	if (buf.ack.reason == RXRPC_ACK_PING_RESPONSE)
@@ -583,10 +588,12 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	if (buf.ack.reason == RXRPC_ACK_PING) {
 		_proto("Rx ACK %%%u PING Request", sp->hdr.serial);
 		rxrpc_propose_ACK(call, RXRPC_ACK_PING_RESPONSE,
-				  skew, sp->hdr.serial, true, true);
+				  skew, sp->hdr.serial, true, true,
+				  rxrpc_propose_ack_respond_to_ping);
 	} else if (sp->hdr.flags & RXRPC_REQUEST_ACK) {
 		rxrpc_propose_ACK(call, RXRPC_ACK_REQUESTED,
-				  skew, sp->hdr.serial, true, true);
+				  skew, sp->hdr.serial, true, true,
+				  rxrpc_propose_ack_respond_to_ack);
 	}
 
 	offset = sp->offset + nr_acks + 3;
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index fa9942fabdf2..1ca14835d87f 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -91,17 +91,10 @@ const s8 rxrpc_ack_priority[] = {
 	[RXRPC_ACK_PING]		= 9,
 };
 
-const char *rxrpc_acks(u8 reason)
-{
-	static const char *const str[] = {
-		"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY",
-		"IDL", "-?-"
-	};
-
-	if (reason >= ARRAY_SIZE(str))
-		reason = ARRAY_SIZE(str) - 1;
-	return str[reason];
-}
+const char const rxrpc_ack_names[RXRPC_ACK__INVALID + 1][4] = {
+	"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY",
+	"IDL", "-?-"
+};
 
 const char rxrpc_skb_traces[rxrpc_skb__nr_trace][7] = {
 	[rxrpc_skb_rx_cleaned]		= "Rx CLN",
@@ -202,3 +195,18 @@ const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8] = {
 	[rxrpc_timer_set_for_send]		= "SetTx ",
 	[rxrpc_timer_set_for_resend]		= "SetRTx",
 };
+
+const char rxrpc_propose_ack_traces[rxrpc_propose_ack__nr_trace][8] = {
+	[rxrpc_propose_ack_input_data]		= "DataIn ",
+	[rxrpc_propose_ack_ping_for_params]	= "Params ",
+	[rxrpc_propose_ack_respond_to_ack]	= "Rsp2Ack",
+	[rxrpc_propose_ack_respond_to_ping]	= "Rsp2Png",
+	[rxrpc_propose_ack_retry_tx]		= "RetryTx",
+	[rxrpc_propose_ack_terminal_ack]	= "ClTerm ",
+};
+
+const char *const rxrpc_propose_ack_outcomes[rxrpc_propose_ack__nr_outcomes] = {
+	[rxrpc_propose_ack_use]			= "",
+	[rxrpc_propose_ack_update]		= " Update",
+	[rxrpc_propose_ack_subsume]		= " Subsume",
+};
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index e47fbd1c836d..0c563e325c9d 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -210,7 +210,8 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 			rxrpc_propose_ACK(call, pkt->ack.reason,
 					  ntohs(pkt->ack.maxSkew),
 					  ntohl(pkt->ack.serial),
-					  true, true);
+					  true, true,
+					  rxrpc_propose_ack_retry_tx);
 			break;
 		case RXRPC_PACKET_TYPE_ABORT:
 			break;
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 99e4c0ae30f1..8c7f3de45bac 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -141,7 +141,8 @@ static void rxrpc_end_rx_phase(struct rxrpc_call *call)
 	ASSERTCMP(call->rx_hard_ack, ==, call->rx_top);
 
 	if (call->state == RXRPC_CALL_CLIENT_RECV_REPLY) {
-		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, 0, true, false);
+		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, 0, true, false,
+				  rxrpc_propose_ack_terminal_ack);
 		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
 	}
 
