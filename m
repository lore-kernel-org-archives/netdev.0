From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 06/13] rxrpc: Fix loss of PING RESPONSE ACK production
 due to PING ACKs
Date: Thu, 06 Oct 2016 11:04:38 +0100
Message-ID: <147574827846.30350.14644516715668036382.stgit@warthog.procyon.org.uk>
References: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Separate the output of PING ACKs from the output of other sorts of ACK so
that if we receive a PING ACK and schedule transmission of a PING RESPONSE
ACK, the response doesn't get cancelled by a PING ACK we happen to be
scheduling transmission of at the same time.

If a PING RESPONSE gets lost, the other side might just sit there waiting
for it and refuse to proceed otherwise.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   12 +++++++++---
 net/rxrpc/call_event.c  |   48 +++++++++++++++++++++++++++++++++++++++++++----
 net/rxrpc/call_object.c |    1 +
 net/rxrpc/input.c       |    4 ++--
 net/rxrpc/misc.c        |    2 +-
 net/rxrpc/output.c      |   38 ++++++++++++++++++++++---------------
 net/rxrpc/recvmsg.c     |    4 ++--
 net/rxrpc/sendmsg.c     |    2 +-
 8 files changed, 82 insertions(+), 29 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ef849a12a0f0..b56676be07c7 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -398,6 +398,7 @@ enum rxrpc_call_flag {
 	RXRPC_CALL_EXPOSED,		/* The call was exposed to the world */
 	RXRPC_CALL_RX_LAST,		/* Received the last packet (at rxtx_top) */
 	RXRPC_CALL_TX_LAST,		/* Last packet in Tx buffer (at rxtx_top) */
+	RXRPC_CALL_SEND_PING,		/* A ping will need to be sent */
 	RXRPC_CALL_PINGING,		/* Ping in process */
 	RXRPC_CALL_RETRANS_TIMEOUT,	/* Retransmission due to timeout occurred */
 };
@@ -410,6 +411,7 @@ enum rxrpc_call_event {
 	RXRPC_CALL_EV_ABORT,		/* need to generate abort */
 	RXRPC_CALL_EV_TIMER,		/* Timer expired */
 	RXRPC_CALL_EV_RESEND,		/* Tx resend required */
+	RXRPC_CALL_EV_PING,		/* Ping send required */
 };
 
 /*
@@ -466,6 +468,7 @@ struct rxrpc_call {
 	struct rxrpc_sock __rcu	*socket;	/* socket responsible */
 	ktime_t			ack_at;		/* When deferred ACK needs to happen */
 	ktime_t			resend_at;	/* When next resend needs to happen */
+	ktime_t			ping_at;	/* When next to send a ping */
 	ktime_t			expire_at;	/* When the call times out */
 	struct timer_list	timer;		/* Combined event timer */
 	struct work_struct	processor;	/* Event processor */
@@ -558,8 +561,10 @@ struct rxrpc_call {
 	rxrpc_seq_t		ackr_prev_seq;	/* previous sequence number received */
 	rxrpc_seq_t		ackr_consumed;	/* Highest packet shown consumed */
 	rxrpc_seq_t		ackr_seen;	/* Highest packet shown seen */
-	rxrpc_serial_t		ackr_ping;	/* Last ping sent */
-	ktime_t			ackr_ping_time;	/* Time last ping sent */
+
+	/* ping management */
+	rxrpc_serial_t		ping_serial;	/* Last ping sent */
+	ktime_t			ping_time;	/* Time last ping sent */
 
 	/* transmission-phase ACK management */
 	ktime_t			acks_latest_ts;	/* Timestamp of latest ACK received */
@@ -730,6 +735,7 @@ enum rxrpc_timer_trace {
 	rxrpc_timer_init_for_reply,
 	rxrpc_timer_expired,
 	rxrpc_timer_set_for_ack,
+	rxrpc_timer_set_for_ping,
 	rxrpc_timer_set_for_resend,
 	rxrpc_timer_set_for_send,
 	rxrpc_timer__nr_trace
@@ -1068,7 +1074,7 @@ extern const s8 rxrpc_ack_priority[];
 /*
  * output.c
  */
-int rxrpc_send_ack_packet(struct rxrpc_call *);
+int rxrpc_send_ack_packet(struct rxrpc_call *, bool);
 int rxrpc_send_abort_packet(struct rxrpc_call *);
 int rxrpc_send_data_packet(struct rxrpc_call *, struct sk_buff *, bool);
 void rxrpc_reject_packets(struct rxrpc_local *);
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index e313099860d5..eeea9602cb89 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -54,6 +54,14 @@ void rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why,
 			t = call->ack_at;
 		}
 
+		if (!ktime_after(call->ping_at, now)) {
+			call->ping_at = call->expire_at;
+			if (!test_and_set_bit(RXRPC_CALL_EV_PING, &call->events))
+				queue = true;
+		} else if (ktime_before(call->ping_at, t)) {
+			t = call->ping_at;
+		}
+
 		t_j = nsecs_to_jiffies(ktime_to_ns(ktime_sub(t, now)));
 		t_j += jiffies;
 
@@ -78,6 +86,27 @@ out:
 }
 
 /*
+ * Propose a PING ACK be sent.
+ */
+static void rxrpc_propose_ping(struct rxrpc_call *call,
+			       bool immediate, bool background)
+{
+	if (immediate) {
+		if (background &&
+		    !test_and_set_bit(RXRPC_CALL_EV_PING, &call->events))
+			rxrpc_queue_call(call);
+	} else {
+		ktime_t now = ktime_get_real();
+		ktime_t ping_at = ktime_add_ms(now, rxrpc_idle_ack_delay);
+
+		if (ktime_before(ping_at, call->ping_at)) {
+			call->ping_at = ping_at;
+			rxrpc_set_timer(call, rxrpc_timer_set_for_ping, now);
+		}
+	}
+}
+
+/*
  * propose an ACK be sent
  */
 static void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
@@ -90,6 +119,14 @@ static void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 	ktime_t now, ack_at;
 	s8 prior = rxrpc_ack_priority[ack_reason];
 
+	/* Pings are handled specially because we don't want to accidentally
+	 * lose a ping response by subsuming it into a ping.
+	 */
+	if (ack_reason == RXRPC_ACK_PING) {
+		rxrpc_propose_ping(call, immediate, background);
+		goto trace;
+	}
+
 	/* Update DELAY, IDLE, REQUESTED and PING_RESPONSE ACK serial
 	 * numbers, but we don't alter the timeout.
 	 */
@@ -125,7 +162,6 @@ static void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 			expiry = rxrpc_soft_ack_delay;
 		break;
 
-	case RXRPC_ACK_PING:
 	case RXRPC_ACK_IDLE:
 		if (rxrpc_idle_ack_delay < expiry)
 			expiry = rxrpc_idle_ack_delay;
@@ -253,7 +289,7 @@ static void rxrpc_resend(struct rxrpc_call *call, ktime_t now)
 			goto out;
 		rxrpc_propose_ACK(call, RXRPC_ACK_PING, 0, 0, true, false,
 				  rxrpc_propose_ack_ping_for_lost_ack);
-		rxrpc_send_ack_packet(call);
+		rxrpc_send_ack_packet(call, true);
 		goto out;
 	}
 
@@ -345,13 +381,17 @@ recheck_state:
 	}
 
 	if (test_and_clear_bit(RXRPC_CALL_EV_ACK, &call->events)) {
-		call->ack_at = call->expire_at;
 		if (call->ackr_reason) {
-			rxrpc_send_ack_packet(call);
+			rxrpc_send_ack_packet(call, false);
 			goto recheck_state;
 		}
 	}
 
+	if (test_and_clear_bit(RXRPC_CALL_EV_PING, &call->events)) {
+		rxrpc_send_ack_packet(call, true);
+		goto recheck_state;
+	}
+
 	if (test_and_clear_bit(RXRPC_CALL_EV_RESEND, &call->events)) {
 		rxrpc_resend(call, now);
 		goto recheck_state;
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 07094012ac15..4353a29f3b57 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -205,6 +205,7 @@ static void rxrpc_start_call_timer(struct rxrpc_call *call)
 	expire_at = ktime_add_ms(now, rxrpc_max_call_lifetime);
 	call->expire_at = expire_at;
 	call->ack_at = expire_at;
+	call->ping_at = expire_at;
 	call->resend_at = expire_at;
 	call->timer.expires = jiffies + LONG_MAX / 2;
 	rxrpc_set_timer(call, rxrpc_timer_begin, now);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 103d2b0d4690..a6da83f036d6 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -625,9 +625,9 @@ static void rxrpc_input_ping_response(struct rxrpc_call *call,
 	rxrpc_serial_t ping_serial;
 	ktime_t ping_time;
 
-	ping_time = call->ackr_ping_time;
+	ping_time = call->ping_time;
 	smp_rmb();
-	ping_serial = call->ackr_ping;
+	ping_serial = call->ping_serial;
 
 	if (!test_bit(RXRPC_CALL_PINGING, &call->flags) ||
 	    before(orig_serial, ping_serial))
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 804a88e28739..1cdcba52f83b 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -93,7 +93,6 @@ const s8 rxrpc_ack_priority[] = {
 	[RXRPC_ACK_EXCEEDS_WINDOW]	= 6,
 	[RXRPC_ACK_NOSPACE]		= 7,
 	[RXRPC_ACK_PING_RESPONSE]	= 8,
-	[RXRPC_ACK_PING]		= 9,
 };
 
 const char rxrpc_ack_names[RXRPC_ACK__INVALID + 1][4] = {
@@ -197,6 +196,7 @@ const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8] = {
 	[rxrpc_timer_expired]			= "*EXPR*",
 	[rxrpc_timer_init_for_reply]		= "IniRpl",
 	[rxrpc_timer_set_for_ack]		= "SetAck",
+	[rxrpc_timer_set_for_ping]		= "SetPng",
 	[rxrpc_timer_set_for_send]		= "SetTx ",
 	[rxrpc_timer_set_for_resend]		= "SetRTx",
 };
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 2dae877c0876..a12cea0cbc05 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -38,7 +38,8 @@ struct rxrpc_abort_buffer {
 static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 				 struct rxrpc_ack_buffer *pkt,
 				 rxrpc_seq_t *_hard_ack,
-				 rxrpc_seq_t *_top)
+				 rxrpc_seq_t *_top,
+				 u8 reason)
 {
 	rxrpc_serial_t serial;
 	rxrpc_seq_t hard_ack, top, seq;
@@ -58,10 +59,10 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 	pkt->ack.firstPacket	= htonl(hard_ack + 1);
 	pkt->ack.previousPacket	= htonl(call->ackr_prev_seq);
 	pkt->ack.serial		= htonl(serial);
-	pkt->ack.reason		= call->ackr_reason;
+	pkt->ack.reason		= reason;
 	pkt->ack.nAcks		= top - hard_ack;
 
-	if (pkt->ack.reason == RXRPC_ACK_PING)
+	if (reason == RXRPC_ACK_PING)
 		pkt->whdr.flags |= RXRPC_REQUEST_ACK;
 
 	if (after(top, hard_ack)) {
@@ -93,7 +94,7 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 /*
  * Send an ACK call packet.
  */
-int rxrpc_send_ack_packet(struct rxrpc_call *call)
+int rxrpc_send_ack_packet(struct rxrpc_call *call, bool ping)
 {
 	struct rxrpc_connection *conn = NULL;
 	struct rxrpc_ack_buffer *pkt;
@@ -102,8 +103,8 @@ int rxrpc_send_ack_packet(struct rxrpc_call *call)
 	rxrpc_serial_t serial;
 	rxrpc_seq_t hard_ack, top;
 	size_t len, n;
-	bool ping = false;
 	int ret;
+	u8 reason;
 
 	spin_lock_bh(&call->lock);
 	if (call->conn)
@@ -136,14 +137,18 @@ int rxrpc_send_ack_packet(struct rxrpc_call *call)
 	pkt->whdr.serviceId	= htons(call->service_id);
 
 	spin_lock_bh(&call->lock);
-	if (!call->ackr_reason) {
-		spin_unlock_bh(&call->lock);
-		ret = 0;
-		goto out;
+	if (ping) {
+		reason = RXRPC_ACK_PING;
+	} else {
+		reason = call->ackr_reason;
+		if (!call->ackr_reason) {
+			spin_unlock_bh(&call->lock);
+			ret = 0;
+			goto out;
+		}
+		call->ackr_reason = 0;
 	}
-	ping = (call->ackr_reason == RXRPC_ACK_PING);
-	n = rxrpc_fill_out_ack(call, pkt, &hard_ack, &top);
-	call->ackr_reason = 0;
+	n = rxrpc_fill_out_ack(call, pkt, &hard_ack, &top, reason);
 
 	spin_unlock_bh(&call->lock);
 
@@ -161,7 +166,7 @@ int rxrpc_send_ack_packet(struct rxrpc_call *call)
 			   pkt->ack.reason, pkt->ack.nAcks);
 
 	if (ping) {
-		call->ackr_ping = serial;
+		call->ping_serial = serial;
 		smp_wmb();
 		/* We need to stick a time in before we send the packet in case
 		 * the reply gets back before kernel_sendmsg() completes - but
@@ -170,18 +175,19 @@ int rxrpc_send_ack_packet(struct rxrpc_call *call)
 		 * the packet transmission is more likely to happen towards the
 		 * end of the kernel_sendmsg() call.
 		 */
-		call->ackr_ping_time = ktime_get_real();
+		call->ping_time = ktime_get_real();
 		set_bit(RXRPC_CALL_PINGING, &call->flags);
 		trace_rxrpc_rtt_tx(call, rxrpc_rtt_tx_ping, serial);
 	}
 
 	ret = kernel_sendmsg(conn->params.local->socket, &msg, iov, 2, len);
 	if (ping)
-		call->ackr_ping_time = ktime_get_real();
+		call->ping_time = ktime_get_real();
 
 	if (call->state < RXRPC_CALL_COMPLETE) {
 		if (ret < 0) {
-			clear_bit(RXRPC_CALL_PINGING, &call->flags);
+			if (ping)
+				clear_bit(RXRPC_CALL_PINGING, &call->flags);
 			rxrpc_propose_ACK(call, pkt->ack.reason,
 					  ntohs(pkt->ack.maxSkew),
 					  ntohl(pkt->ack.serial),
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 11723bc1c783..3fa7771c2a9d 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -143,7 +143,7 @@ static void rxrpc_end_rx_phase(struct rxrpc_call *call, rxrpc_serial_t serial)
 	if (call->state == RXRPC_CALL_CLIENT_RECV_REPLY) {
 		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, serial, true, false,
 				  rxrpc_propose_ack_terminal_ack);
-		rxrpc_send_ack_packet(call);
+		rxrpc_send_ack_packet(call, false);
 	}
 
 	write_lock_bh(&call->state_lock);
@@ -212,7 +212,7 @@ static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
 					  true, false,
 					  rxrpc_propose_ack_rotate_rx);
 		if (call->ackr_reason)
-			rxrpc_send_ack_packet(call);
+			rxrpc_send_ack_packet(call, false);
 	}
 }
 
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 901b28ceeff4..55a2fb2cfc2f 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -197,7 +197,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 	do {
 		/* Check to see if there's a ping ACK to reply to. */
 		if (call->ackr_reason == RXRPC_ACK_PING_RESPONSE)
-			rxrpc_send_ack_packet(call);
+			rxrpc_send_ack_packet(call, false);
 
 		if (!skb) {
 			size_t size, chunk, max, space;
