From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 12/13] rxrpc: Need to produce an ACK for service op if
 op takes a long time
Date: Thu, 06 Oct 2016 11:05:20 +0100
Message-ID: <147574832016.30350.7145676018037106906.stgit@warthog.procyon.org.uk>
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

We need to generate a DELAY ACK from the service end of an operation if we
start doing the actual operation work and it takes longer than expected.
This will hard-ACK the request data and allow the client to release its
resources.

To make this work:

 (1) We have to set the ack timer and propose an ACK when the call moves to
     the RXRPC_CALL_SERVER_ACK_REQUEST and clear the pending ACK and cancel
     the timer when we start transmitting the reply (the first DATA packet
     of the reply implicitly ACKs the request phase).

 (2) It must be possible to set the timer when the caller is holding
     call->state_lock, so split the lock-getting part of the timer function
     out.

 (3) Add trace notes for the ACK we're requesting and the timer we clear.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    3 +++
 net/rxrpc/call_event.c  |   16 ++++++++++++----
 net/rxrpc/misc.c        |    2 ++
 net/rxrpc/recvmsg.c     |    8 ++++++--
 net/rxrpc/sendmsg.c     |    5 +++++
 5 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index b56676be07c7..f60e35576526 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -733,6 +733,7 @@ extern const char rxrpc_rtt_rx_traces[rxrpc_rtt_rx__nr_trace][5];
 enum rxrpc_timer_trace {
 	rxrpc_timer_begin,
 	rxrpc_timer_init_for_reply,
+	rxrpc_timer_init_for_send_reply,
 	rxrpc_timer_expired,
 	rxrpc_timer_set_for_ack,
 	rxrpc_timer_set_for_ping,
@@ -749,6 +750,7 @@ enum rxrpc_propose_ack_trace {
 	rxrpc_propose_ack_ping_for_lost_ack,
 	rxrpc_propose_ack_ping_for_lost_reply,
 	rxrpc_propose_ack_ping_for_params,
+	rxrpc_propose_ack_processing_op,
 	rxrpc_propose_ack_respond_to_ack,
 	rxrpc_propose_ack_respond_to_ping,
 	rxrpc_propose_ack_retry_tx,
@@ -811,6 +813,7 @@ int rxrpc_reject_call(struct rxrpc_sock *);
 /*
  * call_event.c
  */
+void __rxrpc_set_timer(struct rxrpc_call *, enum rxrpc_timer_trace, ktime_t);
 void rxrpc_set_timer(struct rxrpc_call *, enum rxrpc_timer_trace, ktime_t);
 void rxrpc_propose_ACK(struct rxrpc_call *, u8, u16, u32, bool, bool,
 		       enum rxrpc_propose_ack_trace);
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 0f91d329e910..97a17ada4431 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -24,15 +24,13 @@
 /*
  * Set the timer
  */
-void rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why,
-		     ktime_t now)
+void __rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why,
+		       ktime_t now)
 {
 	unsigned long t_j, now_j = jiffies;
 	ktime_t t;
 	bool queue = false;
 
-	read_lock_bh(&call->state_lock);
-
 	if (call->state < RXRPC_CALL_COMPLETE) {
 		t = call->expire_at;
 		if (!ktime_after(t, now)) {
@@ -84,6 +82,16 @@ void rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why,
 out:
 	if (queue)
 		rxrpc_queue_call(call);
+}
+
+/*
+ * Set the timer
+ */
+void rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why,
+		     ktime_t now)
+{
+	read_lock_bh(&call->state_lock);
+	__rxrpc_set_timer(call, why, now);
 	read_unlock_bh(&call->state_lock);
 }
 
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 1cdcba52f83b..6dee55fad2d3 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -195,6 +195,7 @@ const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8] = {
 	[rxrpc_timer_begin]			= "Begin ",
 	[rxrpc_timer_expired]			= "*EXPR*",
 	[rxrpc_timer_init_for_reply]		= "IniRpl",
+	[rxrpc_timer_init_for_send_reply]	= "SndRpl",
 	[rxrpc_timer_set_for_ack]		= "SetAck",
 	[rxrpc_timer_set_for_ping]		= "SetPng",
 	[rxrpc_timer_set_for_send]		= "SetTx ",
@@ -207,6 +208,7 @@ const char rxrpc_propose_ack_traces[rxrpc_propose_ack__nr_trace][8] = {
 	[rxrpc_propose_ack_ping_for_lost_ack]	= "LostAck",
 	[rxrpc_propose_ack_ping_for_lost_reply]	= "LostRpl",
 	[rxrpc_propose_ack_ping_for_params]	= "Params ",
+	[rxrpc_propose_ack_processing_op]	= "ProcOp ",
 	[rxrpc_propose_ack_respond_to_ack]	= "Rsp2Ack",
 	[rxrpc_propose_ack_respond_to_ping]	= "Rsp2Png",
 	[rxrpc_propose_ack_retry_tx]		= "RetryTx",
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index db5b02a47518..c29362d50a92 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -151,17 +151,21 @@ static void rxrpc_end_rx_phase(struct rxrpc_call *call, rxrpc_serial_t serial)
 	switch (call->state) {
 	case RXRPC_CALL_CLIENT_RECV_REPLY:
 		__rxrpc_call_completed(call);
+		write_unlock_bh(&call->state_lock);
 		break;
 
 	case RXRPC_CALL_SERVER_RECV_REQUEST:
 		call->tx_phase = true;
 		call->state = RXRPC_CALL_SERVER_ACK_REQUEST;
+		call->ack_at = call->expire_at;
+		write_unlock_bh(&call->state_lock);
+		rxrpc_propose_ACK(call, RXRPC_ACK_DELAY, 0, serial, false, true,
+				  rxrpc_propose_ack_processing_op);
 		break;
 	default:
+		write_unlock_bh(&call->state_lock);
 		break;
 	}
-
-	write_unlock_bh(&call->state_lock);
 }
 
 /*
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 55a2fb2cfc2f..b214a4d4a641 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -130,6 +130,11 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 			break;
 		case RXRPC_CALL_SERVER_ACK_REQUEST:
 			call->state = RXRPC_CALL_SERVER_SEND_REPLY;
+			call->ack_at = call->expire_at;
+			if (call->ackr_reason == RXRPC_ACK_DELAY)
+				call->ackr_reason = 0;
+			__rxrpc_set_timer(call, rxrpc_timer_init_for_send_reply,
+					  ktime_get_real());
 			if (!last)
 				break;
 		case RXRPC_CALL_SERVER_SEND_REPLY:
