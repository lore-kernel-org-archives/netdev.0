From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 7/7] rxrpc: Fix the call timer handling
Date: Fri, 30 Sep 2016 22:41:00 +0100
Message-ID: <147527166041.28826.12555941295774387849.stgit@warthog.procyon.org.uk>
References: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The call timer's concept of a call timeout (of which there are three) that
is inactive is that it is the timeout has the same expiration time as the
call expiration timeout (the expiration timer is never inactive).  However,
I'm not resetting the timeouts when they expire, leading to repeated
processing of expired timeouts when other timeout events occur.

Fix this by:

 (1) Move the timer expiry detection into rxrpc_set_timer() inside the
     locked section.  This means that if a timeout is set that will expire
     immediately, we deal with it immediately.

 (2) If a timeout is at or before now then it has expired.  When an expiry
     is detected, an event is raised, the timeout is automatically
     inactivated and the event processor is queued.

 (3) If a timeout is at or after the expiry timeout then it is inactive.
     Inactive timeouts do not contribute to the timer setting.

 (4) The call timer callback can now just call rxrpc_set_timer() to handle
     things.

 (5) The call processor work function now checks the event flags rather
     than checking the timeouts directly.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c  |   26 ++++++++++++++++++--------
 net/rxrpc/call_object.c |    7 ++-----
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 9ff3bb3ffb41..4f00476630b9 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -29,6 +29,7 @@ void rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why,
 {
 	unsigned long t_j, now_j = jiffies;
 	ktime_t t;
+	bool queue = false;
 
 	read_lock_bh(&call->state_lock);
 
@@ -37,13 +38,21 @@ void rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why,
 		if (!ktime_after(t, now))
 			goto out;
 
-		if (ktime_after(call->resend_at, now) &&
-		    ktime_before(call->resend_at, t))
+		if (!ktime_after(call->resend_at, now)) {
+			call->resend_at = call->expire_at;
+			if (!test_and_set_bit(RXRPC_CALL_EV_RESEND, &call->events))
+				queue = true;
+		} else if (ktime_before(call->resend_at, t)) {
 			t = call->resend_at;
+		}
 
-		if (ktime_after(call->ack_at, now) &&
-		    ktime_before(call->ack_at, t))
+		if (!ktime_after(call->ack_at, now)) {
+			call->ack_at = call->expire_at;
+			if (!test_and_set_bit(RXRPC_CALL_EV_ACK, &call->events))
+				queue = true;
+		} else if (ktime_before(call->ack_at, t)) {
 			t = call->ack_at;
+		}
 
 		t_j = nsecs_to_jiffies(ktime_to_ns(ktime_sub(t, now)));
 		t_j += jiffies;
@@ -59,6 +68,9 @@ void rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why,
 			mod_timer(&call->timer, t_j);
 			trace_rxrpc_timer(call, why, now, now_j);
 		}
+
+		if (queue)
+			rxrpc_queue_call(call);
 	}
 
 out:
@@ -332,8 +344,7 @@ recheck_state:
 		goto recheck_state;
 	}
 
-	if (test_and_clear_bit(RXRPC_CALL_EV_ACK, &call->events) ||
-	    ktime_before(call->ack_at, now)) {
+	if (test_and_clear_bit(RXRPC_CALL_EV_ACK, &call->events)) {
 		call->ack_at = call->expire_at;
 		if (call->ackr_reason) {
 			rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
@@ -341,8 +352,7 @@ recheck_state:
 		}
 	}
 
-	if (test_and_clear_bit(RXRPC_CALL_EV_RESEND, &call->events) ||
-	    ktime_before(call->resend_at, now)) {
+	if (test_and_clear_bit(RXRPC_CALL_EV_RESEND, &call->events)) {
 		rxrpc_resend(call, now);
 		goto recheck_state;
 	}
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 456ab752d473..364b42dc3dce 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -71,11 +71,8 @@ static void rxrpc_call_timer_expired(unsigned long _call)
 
 	_enter("%d", call->debug_id);
 
-	if (call->state < RXRPC_CALL_COMPLETE) {
-		trace_rxrpc_timer(call, rxrpc_timer_expired,
-				  ktime_get_real(), jiffies);
-		rxrpc_queue_call(call);
-	}
+	if (call->state < RXRPC_CALL_COMPLETE)
+		rxrpc_set_timer(call, rxrpc_timer_expired, ktime_get_real());
 }
 
 /*
