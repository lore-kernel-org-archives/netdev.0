From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 11/15] rxrpc: Add a tracepoint for the call timer
Date: Fri, 23 Sep 2016 16:16:33 +0100
Message-ID: <147464379347.5090.13751863428044452562.stgit@warthog.procyon.org.uk>
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

Add a tracepoint to log call timer initiation, setting and expiry.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   36 ++++++++++++++++++++++++++++++++++++
 net/rxrpc/ar-internal.h      |   13 ++++++++++++-
 net/rxrpc/call_event.c       |    7 ++++---
 net/rxrpc/call_object.c      |    6 ++++--
 net/rxrpc/misc.c             |    8 ++++++++
 net/rxrpc/sendmsg.c          |    2 +-
 6 files changed, 65 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index e8f2afbbe0bf..57322897d745 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -414,6 +414,42 @@ TRACE_EVENT(rxrpc_rtt_rx,
 		      __entry->avg)
 	    );
 
+TRACE_EVENT(rxrpc_timer,
+	    TP_PROTO(struct rxrpc_call *call, enum rxrpc_timer_trace why,
+		     unsigned long now),
+
+	    TP_ARGS(call, why, now),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,		call		)
+		    __field(enum rxrpc_timer_trace,		why		)
+		    __field(unsigned long,			now		)
+		    __field(unsigned long,			expire_at	)
+		    __field(unsigned long,			ack_at		)
+		    __field(unsigned long,			resend_at	)
+		    __field(unsigned long,			timer		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call	= call;
+		    __entry->why	= why;
+		    __entry->now	= now;
+		    __entry->expire_at	= call->expire_at;
+		    __entry->ack_at	= call->ack_at;
+		    __entry->resend_at	= call->resend_at;
+		    __entry->timer	= call->timer.expires;
+			   ),
+
+	    TP_printk("c=%p %s now=%lx x=%ld a=%ld r=%ld t=%ld",
+		      __entry->call,
+		      rxrpc_timer_traces[__entry->why],
+		      __entry->now,
+		      __entry->expire_at - __entry->now,
+		      __entry->ack_at - __entry->now,
+		      __entry->resend_at - __entry->now,
+		      __entry->timer - __entry->now)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index a494d56eb236..e564eca75985 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -678,6 +678,17 @@ enum rxrpc_rtt_rx_trace {
 
 extern const char rxrpc_rtt_rx_traces[rxrpc_rtt_rx__nr_trace][5];
 
+enum rxrpc_timer_trace {
+	rxrpc_timer_begin,
+	rxrpc_timer_expired,
+	rxrpc_timer_set_for_ack,
+	rxrpc_timer_set_for_resend,
+	rxrpc_timer_set_for_send,
+	rxrpc_timer__nr_trace
+};
+
+extern const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8];
+
 extern const char *const rxrpc_pkts[];
 extern const char *rxrpc_acks(u8 reason);
 
@@ -707,7 +718,7 @@ int rxrpc_reject_call(struct rxrpc_sock *);
 /*
  * call_event.c
  */
-void rxrpc_set_timer(struct rxrpc_call *);
+void rxrpc_set_timer(struct rxrpc_call *, enum rxrpc_timer_trace);
 void rxrpc_propose_ACK(struct rxrpc_call *, u8, u16, u32, bool, bool);
 void rxrpc_process_call(struct work_struct *);
 
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 8bc5c8e37ab4..90e970ba048a 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -24,7 +24,7 @@
 /*
  * Set the timer
  */
-void rxrpc_set_timer(struct rxrpc_call *call)
+void rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why)
 {
 	unsigned long t, now = jiffies;
 
@@ -45,6 +45,7 @@ void rxrpc_set_timer(struct rxrpc_call *call)
 
 		if (call->timer.expires != t || !timer_pending(&call->timer)) {
 			mod_timer(&call->timer, t);
+			trace_rxrpc_timer(call, why, now);
 		}
 	}
 
@@ -120,7 +121,7 @@ static void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 		_debug("deferred ACK %ld < %ld", expiry, call->ack_at - now);
 		if (time_before(ack_at, call->ack_at)) {
 			call->ack_at = ack_at;
-			rxrpc_set_timer(call);
+			rxrpc_set_timer(call, rxrpc_timer_set_for_ack);
 		}
 	}
 }
@@ -293,7 +294,7 @@ recheck_state:
 		goto recheck_state;
 	}
 
-	rxrpc_set_timer(call);
+	rxrpc_set_timer(call, rxrpc_timer_set_for_resend);
 
 	/* other events may have been raised since we started checking */
 	if (call->events && call->state < RXRPC_CALL_COMPLETE) {
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index f2fadf667e19..a53f4c2c0025 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -76,8 +76,10 @@ static void rxrpc_call_timer_expired(unsigned long _call)
 
 	_enter("%d", call->debug_id);
 
-	if (call->state < RXRPC_CALL_COMPLETE)
+	if (call->state < RXRPC_CALL_COMPLETE) {
+		trace_rxrpc_timer(call, rxrpc_timer_expired, jiffies);
 		rxrpc_queue_call(call);
+	}
 }
 
 /*
@@ -200,7 +202,7 @@ static void rxrpc_start_call_timer(struct rxrpc_call *call)
 	call->ack_at = expire_at;
 	call->resend_at = expire_at;
 	call->timer.expires = expire_at + 1;
-	rxrpc_set_timer(call);
+	rxrpc_set_timer(call, rxrpc_timer_begin);
 }
 
 /*
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index fe648711c2f7..fa9942fabdf2 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -194,3 +194,11 @@ const char rxrpc_rtt_rx_traces[rxrpc_rtt_rx__nr_trace][5] = {
 	[rxrpc_rtt_rx_ping_response]	= "PONG",
 	[rxrpc_rtt_rx_requested_ack]	= "RACK",
 };
+
+const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8] = {
+	[rxrpc_timer_begin]			= "Begin ",
+	[rxrpc_timer_expired]			= "*EXPR*",
+	[rxrpc_timer_set_for_ack]		= "SetAck",
+	[rxrpc_timer_set_for_send]		= "SetTx ",
+	[rxrpc_timer_set_for_resend]		= "SetRTx",
+};
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 93e6584cd751..99939372b5a4 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -153,7 +153,7 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 
 		if (time_before(resend_at, call->resend_at)) {
 			call->resend_at = resend_at;
-			rxrpc_set_timer(call);
+			rxrpc_set_timer(call, rxrpc_timer_set_for_send);
 		}
 	}
 
