From: David Howells <dhowells@redhat.com>
Subject: [PATCH 03/13] rxrpc: Rename call events to begin RXRPC_CALL_EV_
Date: Fri, 04 Mar 2016 16:37:26 +0000
Message-ID: <20160304163726.31057.37489.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename call event names to begin RXRPC_CALL_EV_ to distinguish them from the
flags.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-accept.c    |   10 ++---
 net/rxrpc/ar-ack.c       |  102 +++++++++++++++++++++++-----------------------
 net/rxrpc/ar-call.c      |   14 +++---
 net/rxrpc/ar-connevent.c |    6 +--
 net/rxrpc/ar-error.c     |    2 -
 net/rxrpc/ar-input.c     |   20 +++++----
 net/rxrpc/ar-internal.h  |   36 ++++++++--------
 net/rxrpc/ar-output.c    |    8 ++--
 net/rxrpc/ar-recvmsg.c   |    2 -
 net/rxrpc/ar-skbuff.c    |    2 -
 10 files changed, 101 insertions(+), 101 deletions(-)

diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index 65ea81399f6a..9a49f32e9e1e 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -186,7 +186,7 @@ invalid_service:
 
 	read_lock_bh(&call->state_lock);
 	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events)) {
+	    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
 		rxrpc_get_call(call);
 		rxrpc_queue_call(call);
 	}
@@ -379,7 +379,7 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	rb_insert_color(&call->sock_node, &rx->calls);
 	if (test_and_set_bit(RXRPC_CALL_HAS_USERID, &call->flags))
 		BUG();
-	if (test_and_set_bit(RXRPC_CALL_ACCEPTED, &call->events))
+	if (test_and_set_bit(RXRPC_CALL_EV_ACCEPTED, &call->events))
 		BUG();
 	rxrpc_queue_call(call);
 
@@ -395,7 +395,7 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 out_release:
 	_debug("release %p", call);
 	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+	    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
 		rxrpc_queue_call(call);
 out_discard:
 	write_unlock_bh(&call->state_lock);
@@ -434,7 +434,7 @@ int rxrpc_reject_call(struct rxrpc_sock *rx)
 	switch (call->state) {
 	case RXRPC_CALL_SERVER_ACCEPTING:
 		call->state = RXRPC_CALL_SERVER_BUSY;
-		if (test_and_set_bit(RXRPC_CALL_REJECT_BUSY, &call->events))
+		if (test_and_set_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events))
 			rxrpc_queue_call(call);
 		ret = 0;
 		goto out_release;
@@ -458,7 +458,7 @@ int rxrpc_reject_call(struct rxrpc_sock *rx)
 out_release:
 	_debug("release %p", call);
 	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+	    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
 		rxrpc_queue_call(call);
 out_discard:
 	write_unlock_bh(&call->state_lock);
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 7cb7e45c8bad..9183da740600 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -161,7 +161,7 @@ cancel_timer:
 	try_to_del_timer_sync(&call->ack_timer);
 	read_lock_bh(&call->state_lock);
 	if (call->state <= RXRPC_CALL_COMPLETE &&
-	    !test_and_set_bit(RXRPC_CALL_ACK, &call->events))
+	    !test_and_set_bit(RXRPC_CALL_EV_ACK, &call->events))
 		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
@@ -193,7 +193,7 @@ static void rxrpc_set_resend(struct rxrpc_call *call, u8 resend,
 
 	if (resend & 1) {
 		_debug("SET RESEND");
-		set_bit(RXRPC_CALL_RESEND, &call->events);
+		set_bit(RXRPC_CALL_EV_RESEND, &call->events);
 	}
 
 	if (resend & 2) {
@@ -203,7 +203,7 @@ static void rxrpc_set_resend(struct rxrpc_call *call, u8 resend,
 	} else {
 		_debug("KILL RESEND TIMER");
 		del_timer_sync(&call->resend_timer);
-		clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events);
+		clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events);
 		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
 	}
 	read_unlock_bh(&call->state_lock);
@@ -555,7 +555,7 @@ inserted:
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    call->rx_data_post == call->rx_first_oos) {
 		_debug("drain rx oos now");
-		set_bit(RXRPC_CALL_DRAIN_RX_OOS, &call->events);
+		set_bit(RXRPC_CALL_EV_DRAIN_RX_OOS, &call->events);
 	}
 	read_unlock(&call->state_lock);
 
@@ -793,7 +793,7 @@ all_acked:
 
 	del_timer_sync(&call->resend_timer);
 	clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-	clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events);
+	clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events);
 
 	if (call->acks_window)
 		rxrpc_zap_tx_window(call);
@@ -928,17 +928,17 @@ void rxrpc_process_call(struct work_struct *work)
 	iov[0].iov_len	= sizeof(hdr);
 
 	/* deal with events of a final nature */
-	if (test_bit(RXRPC_CALL_RELEASE, &call->events)) {
+	if (test_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
 		rxrpc_release_call(call);
-		clear_bit(RXRPC_CALL_RELEASE, &call->events);
+		clear_bit(RXRPC_CALL_EV_RELEASE, &call->events);
 	}
 
-	if (test_bit(RXRPC_CALL_RCVD_ERROR, &call->events)) {
+	if (test_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events)) {
 		int error;
 
-		clear_bit(RXRPC_CALL_CONN_ABORT, &call->events);
-		clear_bit(RXRPC_CALL_REJECT_BUSY, &call->events);
-		clear_bit(RXRPC_CALL_ABORT, &call->events);
+		clear_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events);
+		clear_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events);
+		clear_bit(RXRPC_CALL_EV_ABORT, &call->events);
 
 		error = call->conn->trans->peer->net_error;
 		_debug("post net error %d", error);
@@ -946,32 +946,32 @@ void rxrpc_process_call(struct work_struct *work)
 		if (rxrpc_post_message(call, RXRPC_SKB_MARK_NET_ERROR,
 				       error, true) < 0)
 			goto no_mem;
-		clear_bit(RXRPC_CALL_RCVD_ERROR, &call->events);
+		clear_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events);
 		goto kill_ACKs;
 	}
 
-	if (test_bit(RXRPC_CALL_CONN_ABORT, &call->events)) {
+	if (test_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events)) {
 		ASSERTCMP(call->state, >, RXRPC_CALL_COMPLETE);
 
-		clear_bit(RXRPC_CALL_REJECT_BUSY, &call->events);
-		clear_bit(RXRPC_CALL_ABORT, &call->events);
+		clear_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events);
+		clear_bit(RXRPC_CALL_EV_ABORT, &call->events);
 
 		_debug("post conn abort");
 
 		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
 				       call->conn->error, true) < 0)
 			goto no_mem;
-		clear_bit(RXRPC_CALL_CONN_ABORT, &call->events);
+		clear_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events);
 		goto kill_ACKs;
 	}
 
-	if (test_bit(RXRPC_CALL_REJECT_BUSY, &call->events)) {
+	if (test_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events)) {
 		hdr.type = RXRPC_PACKET_TYPE_BUSY;
-		genbit = RXRPC_CALL_REJECT_BUSY;
+		genbit = RXRPC_CALL_EV_REJECT_BUSY;
 		goto send_message;
 	}
 
-	if (test_bit(RXRPC_CALL_ABORT, &call->events)) {
+	if (test_bit(RXRPC_CALL_EV_ABORT, &call->events)) {
 		ASSERTCMP(call->state, >, RXRPC_CALL_COMPLETE);
 
 		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
@@ -981,12 +981,12 @@ void rxrpc_process_call(struct work_struct *work)
 		data = htonl(call->abort_code);
 		iov[1].iov_base = &data;
 		iov[1].iov_len = sizeof(data);
-		genbit = RXRPC_CALL_ABORT;
+		genbit = RXRPC_CALL_EV_ABORT;
 		goto send_message;
 	}
 
-	if (test_bit(RXRPC_CALL_ACK_FINAL, &call->events)) {
-		genbit = RXRPC_CALL_ACK_FINAL;
+	if (test_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events)) {
+		genbit = RXRPC_CALL_EV_ACK_FINAL;
 
 		ack.bufferSpace	= htons(8);
 		ack.maxSkew	= 0;
@@ -1012,12 +1012,12 @@ void rxrpc_process_call(struct work_struct *work)
 		goto send_ACK;
 	}
 
-	if (call->events & ((1 << RXRPC_CALL_RCVD_BUSY) |
-			    (1 << RXRPC_CALL_RCVD_ABORT))
+	if (call->events & ((1 << RXRPC_CALL_EV_RCVD_BUSY) |
+			    (1 << RXRPC_CALL_EV_RCVD_ABORT))
 	    ) {
 		u32 mark;
 
-		if (test_bit(RXRPC_CALL_RCVD_ABORT, &call->events))
+		if (test_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events))
 			mark = RXRPC_SKB_MARK_REMOTE_ABORT;
 		else
 			mark = RXRPC_SKB_MARK_BUSY;
@@ -1027,22 +1027,22 @@ void rxrpc_process_call(struct work_struct *work)
 		if (rxrpc_post_message(call, mark, ECONNABORTED, true) < 0)
 			goto no_mem;
 
-		clear_bit(RXRPC_CALL_RCVD_BUSY, &call->events);
-		clear_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
+		clear_bit(RXRPC_CALL_EV_RCVD_BUSY, &call->events);
+		clear_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
 		goto kill_ACKs;
 	}
 
-	if (test_and_clear_bit(RXRPC_CALL_RCVD_ACKALL, &call->events)) {
+	if (test_and_clear_bit(RXRPC_CALL_EV_RCVD_ACKALL, &call->events)) {
 		_debug("do implicit ackall");
 		rxrpc_clear_tx_window(call);
 	}
 
-	if (test_bit(RXRPC_CALL_LIFE_TIMER, &call->events)) {
+	if (test_bit(RXRPC_CALL_EV_LIFE_TIMER, &call->events)) {
 		write_lock_bh(&call->state_lock);
 		if (call->state <= RXRPC_CALL_COMPLETE) {
 			call->state = RXRPC_CALL_LOCALLY_ABORTED;
 			call->abort_code = RX_CALL_TIMEOUT;
-			set_bit(RXRPC_CALL_ABORT, &call->events);
+			set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		}
 		write_unlock_bh(&call->state_lock);
 
@@ -1051,7 +1051,7 @@ void rxrpc_process_call(struct work_struct *work)
 				       ETIME, true) < 0)
 			goto no_mem;
 
-		clear_bit(RXRPC_CALL_LIFE_TIMER, &call->events);
+		clear_bit(RXRPC_CALL_EV_LIFE_TIMER, &call->events);
 		goto kill_ACKs;
 	}
 
@@ -1072,13 +1072,13 @@ void rxrpc_process_call(struct work_struct *work)
 	}
 
 	/* handle resending */
-	if (test_and_clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
+	if (test_and_clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events))
 		rxrpc_resend_timer(call);
-	if (test_and_clear_bit(RXRPC_CALL_RESEND, &call->events))
+	if (test_and_clear_bit(RXRPC_CALL_EV_RESEND, &call->events))
 		rxrpc_resend(call);
 
 	/* consider sending an ordinary ACK */
-	if (test_bit(RXRPC_CALL_ACK, &call->events)) {
+	if (test_bit(RXRPC_CALL_EV_ACK, &call->events)) {
 		_debug("send ACK: window: %d - %d { %lx }",
 		       call->rx_data_eaten, call->ackr_win_top,
 		       call->ackr_window[0]);
@@ -1086,11 +1086,11 @@ void rxrpc_process_call(struct work_struct *work)
 		if (call->state > RXRPC_CALL_SERVER_ACK_REQUEST &&
 		    call->ackr_reason != RXRPC_ACK_PING_RESPONSE) {
 			/* ACK by sending reply DATA packet in this state */
-			clear_bit(RXRPC_CALL_ACK, &call->events);
+			clear_bit(RXRPC_CALL_EV_ACK, &call->events);
 			goto maybe_reschedule;
 		}
 
-		genbit = RXRPC_CALL_ACK;
+		genbit = RXRPC_CALL_EV_ACK;
 
 		acks = kzalloc(call->ackr_win_top - call->rx_data_eaten,
 			       GFP_NOFS);
@@ -1153,7 +1153,7 @@ void rxrpc_process_call(struct work_struct *work)
 
 	/* handle completion of security negotiations on an incoming
 	 * connection */
-	if (test_and_clear_bit(RXRPC_CALL_SECURED, &call->events)) {
+	if (test_and_clear_bit(RXRPC_CALL_EV_SECURED, &call->events)) {
 		_debug("secured");
 		spin_lock_bh(&call->lock);
 
@@ -1161,7 +1161,7 @@ void rxrpc_process_call(struct work_struct *work)
 			_debug("securing");
 			write_lock(&call->conn->lock);
 			if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-			    !test_bit(RXRPC_CALL_RELEASE, &call->events)) {
+			    !test_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
 				_debug("not released");
 				call->state = RXRPC_CALL_SERVER_ACCEPTING;
 				list_move_tail(&call->accept_link,
@@ -1170,39 +1170,39 @@ void rxrpc_process_call(struct work_struct *work)
 			write_unlock(&call->conn->lock);
 			read_lock(&call->state_lock);
 			if (call->state < RXRPC_CALL_COMPLETE)
-				set_bit(RXRPC_CALL_POST_ACCEPT, &call->events);
+				set_bit(RXRPC_CALL_EV_POST_ACCEPT, &call->events);
 			read_unlock(&call->state_lock);
 		}
 
 		spin_unlock_bh(&call->lock);
-		if (!test_bit(RXRPC_CALL_POST_ACCEPT, &call->events))
+		if (!test_bit(RXRPC_CALL_EV_POST_ACCEPT, &call->events))
 			goto maybe_reschedule;
 	}
 
 	/* post a notification of an acceptable connection to the app */
-	if (test_bit(RXRPC_CALL_POST_ACCEPT, &call->events)) {
+	if (test_bit(RXRPC_CALL_EV_POST_ACCEPT, &call->events)) {
 		_debug("post accept");
 		if (rxrpc_post_message(call, RXRPC_SKB_MARK_NEW_CALL,
 				       0, false) < 0)
 			goto no_mem;
-		clear_bit(RXRPC_CALL_POST_ACCEPT, &call->events);
+		clear_bit(RXRPC_CALL_EV_POST_ACCEPT, &call->events);
 		goto maybe_reschedule;
 	}
 
 	/* handle incoming call acceptance */
-	if (test_and_clear_bit(RXRPC_CALL_ACCEPTED, &call->events)) {
+	if (test_and_clear_bit(RXRPC_CALL_EV_ACCEPTED, &call->events)) {
 		_debug("accepted");
 		ASSERTCMP(call->rx_data_post, ==, 0);
 		call->rx_data_post = 1;
 		read_lock_bh(&call->state_lock);
 		if (call->state < RXRPC_CALL_COMPLETE)
-			set_bit(RXRPC_CALL_DRAIN_RX_OOS, &call->events);
+			set_bit(RXRPC_CALL_EV_DRAIN_RX_OOS, &call->events);
 		read_unlock_bh(&call->state_lock);
 	}
 
 	/* drain the out of sequence received packet queue into the packet Rx
 	 * queue */
-	if (test_and_clear_bit(RXRPC_CALL_DRAIN_RX_OOS, &call->events)) {
+	if (test_and_clear_bit(RXRPC_CALL_EV_DRAIN_RX_OOS, &call->events)) {
 		while (call->rx_data_post == call->rx_first_oos)
 			if (rxrpc_drain_rx_oos_queue(call) < 0)
 				break;
@@ -1281,12 +1281,12 @@ send_message_2:
 	}
 
 	switch (genbit) {
-	case RXRPC_CALL_ABORT:
+	case RXRPC_CALL_EV_ABORT:
 		clear_bit(genbit, &call->events);
-		clear_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
+		clear_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
 		goto kill_ACKs;
 
-	case RXRPC_CALL_ACK_FINAL:
+	case RXRPC_CALL_EV_ACK_FINAL:
 		write_lock_bh(&call->state_lock);
 		if (call->state == RXRPC_CALL_CLIENT_FINAL_ACK)
 			call->state = RXRPC_CALL_COMPLETE;
@@ -1311,9 +1311,9 @@ send_message_2:
 
 kill_ACKs:
 	del_timer_sync(&call->ack_timer);
-	if (test_and_clear_bit(RXRPC_CALL_ACK_FINAL, &call->events))
+	if (test_and_clear_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events))
 		rxrpc_put_call(call);
-	clear_bit(RXRPC_CALL_ACK, &call->events);
+	clear_bit(RXRPC_CALL_EV_ACK, &call->events);
 
 maybe_reschedule:
 	if (call->events || !skb_queue_empty(&call->rx_queue)) {
@@ -1332,7 +1332,7 @@ maybe_reschedule:
 
 		read_lock_bh(&call->state_lock);
 		if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-		    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+		    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
 			rxrpc_queue_call(call);
 		read_unlock_bh(&call->state_lock);
 	}
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index d9a8eeb9290a..3468a0705ab7 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -452,7 +452,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 		read_lock(&call->state_lock);
 		switch (call->state) {
 		case RXRPC_CALL_LOCALLY_ABORTED:
-			if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events))
+			if (!test_and_set_bit(RXRPC_CALL_EV_ABORT, &call->events))
 				rxrpc_queue_call(call);
 		case RXRPC_CALL_REMOTELY_ABORTED:
 			read_unlock(&call->state_lock);
@@ -686,7 +686,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 		_debug("+++ ABORTING STATE %d +++\n", call->state);
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->abort_code = RX_CALL_DEAD;
-		set_bit(RXRPC_CALL_ABORT, &call->events);
+		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		rxrpc_queue_call(call);
 	}
 	write_unlock(&call->state_lock);
@@ -763,10 +763,10 @@ static void rxrpc_mark_call_released(struct rxrpc_call *call)
 			_debug("abort call %p", call);
 			call->state = RXRPC_CALL_LOCALLY_ABORTED;
 			call->abort_code = RX_CALL_DEAD;
-			if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events))
+			if (!test_and_set_bit(RXRPC_CALL_EV_ABORT, &call->events))
 				sched = true;
 		}
-		if (!test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+		if (!test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
 			sched = true;
 		if (sched)
 			rxrpc_queue_call(call);
@@ -975,7 +975,7 @@ static void rxrpc_call_life_expired(unsigned long _call)
 	_enter("{%d}", call->debug_id);
 	read_lock_bh(&call->state_lock);
 	if (call->state < RXRPC_CALL_COMPLETE) {
-		set_bit(RXRPC_CALL_LIFE_TIMER, &call->events);
+		set_bit(RXRPC_CALL_EV_LIFE_TIMER, &call->events);
 		rxrpc_queue_call(call);
 	}
 	read_unlock_bh(&call->state_lock);
@@ -995,7 +995,7 @@ static void rxrpc_resend_time_expired(unsigned long _call)
 		return;
 
 	clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-	if (!test_and_set_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
+	if (!test_and_set_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events))
 		rxrpc_queue_call(call);
 }
 
@@ -1013,7 +1013,7 @@ static void rxrpc_ack_time_expired(unsigned long _call)
 
 	read_lock_bh(&call->state_lock);
 	if (call->state < RXRPC_CALL_COMPLETE &&
-	    !test_and_set_bit(RXRPC_CALL_ACK, &call->events))
+	    !test_and_set_bit(RXRPC_CALL_EV_ACK, &call->events))
 		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index e7ed43a54c41..45e81b7e96ae 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -42,9 +42,9 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
 			call->state = state;
 			call->abort_code = abort_code;
 			if (state == RXRPC_CALL_LOCALLY_ABORTED)
-				set_bit(RXRPC_CALL_CONN_ABORT, &call->events);
+				set_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events);
 			else
-				set_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
+				set_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
 			rxrpc_queue_call(call);
 		}
 		write_unlock(&call->state_lock);
@@ -132,7 +132,7 @@ static void rxrpc_call_is_secure(struct rxrpc_call *call)
 	if (call) {
 		read_lock(&call->state_lock);
 		if (call->state < RXRPC_CALL_COMPLETE &&
-		    !test_and_set_bit(RXRPC_CALL_SECURED, &call->events))
+		    !test_and_set_bit(RXRPC_CALL_EV_SECURED, &call->events))
 			rxrpc_queue_call(call);
 		read_unlock(&call->state_lock);
 	}
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index 0610efa83d72..3c47441c472b 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -222,7 +222,7 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 			if (call->state != RXRPC_CALL_COMPLETE &&
 			    call->state < RXRPC_CALL_NETWORK_ERROR) {
 				call->state = RXRPC_CALL_NETWORK_ERROR;
-				set_bit(RXRPC_CALL_RCVD_ERROR, &call->events);
+				set_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events);
 				rxrpc_queue_call(call);
 			}
 			write_unlock(&call->state_lock);
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 4505a691d88c..9185535af5f5 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -231,7 +231,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 		_debug("drain rx oos now");
 		read_lock(&call->state_lock);
 		if (call->state < RXRPC_CALL_COMPLETE &&
-		    !test_and_set_bit(RXRPC_CALL_DRAIN_RX_OOS, &call->events))
+		    !test_and_set_bit(RXRPC_CALL_EV_DRAIN_RX_OOS, &call->events))
 			rxrpc_queue_call(call);
 		read_unlock(&call->state_lock);
 	}
@@ -287,12 +287,12 @@ static void rxrpc_assume_implicit_ackall(struct rxrpc_call *call, u32 serial)
 		call->acks_latest = serial;
 
 		_debug("implicit ACKALL %%%u", call->acks_latest);
-		set_bit(RXRPC_CALL_RCVD_ACKALL, &call->events);
+		set_bit(RXRPC_CALL_EV_RCVD_ACKALL, &call->events);
 		write_unlock_bh(&call->state_lock);
 
 		if (try_to_del_timer_sync(&call->resend_timer) >= 0) {
-			clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events);
-			clear_bit(RXRPC_CALL_RESEND, &call->events);
+			clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events);
+			clear_bit(RXRPC_CALL_EV_RESEND, &call->events);
 			clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
 		}
 		break;
@@ -358,7 +358,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		if (call->state < RXRPC_CALL_COMPLETE) {
 			call->state = RXRPC_CALL_REMOTELY_ABORTED;
 			call->abort_code = abort_code;
-			set_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
+			set_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
 			rxrpc_queue_call(call);
 		}
 		goto free_packet_unlock;
@@ -373,7 +373,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		switch (call->state) {
 		case RXRPC_CALL_CLIENT_SEND_REQUEST:
 			call->state = RXRPC_CALL_SERVER_BUSY;
-			set_bit(RXRPC_CALL_RCVD_BUSY, &call->events);
+			set_bit(RXRPC_CALL_EV_RCVD_BUSY, &call->events);
 			rxrpc_queue_call(call);
 		case RXRPC_CALL_SERVER_BUSY:
 			goto free_packet_unlock;
@@ -433,7 +433,7 @@ protocol_error_locked:
 	if (call->state <= RXRPC_CALL_COMPLETE) {
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->abort_code = RX_PROTOCOL_ERROR;
-		set_bit(RXRPC_CALL_ABORT, &call->events);
+		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		rxrpc_queue_call(call);
 	}
 free_packet_unlock:
@@ -505,7 +505,7 @@ protocol_error:
 	if (call->state <= RXRPC_CALL_COMPLETE) {
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->abort_code = RX_PROTOCOL_ERROR;
-		set_bit(RXRPC_CALL_ABORT, &call->events);
+		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		rxrpc_queue_call(call);
 	}
 	write_unlock_bh(&call->state_lock);
@@ -530,7 +530,7 @@ static void rxrpc_post_packet_to_call(struct rxrpc_call *call,
 	read_lock(&call->state_lock);
 	switch (call->state) {
 	case RXRPC_CALL_LOCALLY_ABORTED:
-		if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events)) {
+		if (!test_and_set_bit(RXRPC_CALL_EV_ABORT, &call->events)) {
 			rxrpc_queue_call(call);
 			goto free_unlock;
 		}
@@ -546,7 +546,7 @@ static void rxrpc_post_packet_to_call(struct rxrpc_call *call,
 		/* resend last packet of a completed call */
 		_debug("final ack again");
 		rxrpc_get_call(call);
-		set_bit(RXRPC_CALL_ACK_FINAL, &call->events);
+		set_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
 		rxrpc_queue_call(call);
 		goto free_unlock;
 	default:
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 3aea424a88e4..3f2940626569 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -311,23 +311,23 @@ enum rxrpc_call_flag {
  * Events that can be raised on a call.
  */
 enum rxrpc_call_event {
-	RXRPC_CALL_RCVD_ACKALL,		/* ACKALL or reply received */
-	RXRPC_CALL_RCVD_BUSY,		/* busy packet received */
-	RXRPC_CALL_RCVD_ABORT,		/* abort packet received */
-	RXRPC_CALL_RCVD_ERROR,		/* network error received */
-	RXRPC_CALL_ACK_FINAL,		/* need to generate final ACK (and release call) */
-	RXRPC_CALL_ACK,			/* need to generate ACK */
-	RXRPC_CALL_REJECT_BUSY,		/* need to generate busy message */
-	RXRPC_CALL_ABORT,		/* need to generate abort */
-	RXRPC_CALL_CONN_ABORT,		/* local connection abort generated */
-	RXRPC_CALL_RESEND_TIMER,	/* Tx resend timer expired */
-	RXRPC_CALL_RESEND,		/* Tx resend required */
-	RXRPC_CALL_DRAIN_RX_OOS,	/* drain the Rx out of sequence queue */
-	RXRPC_CALL_LIFE_TIMER,		/* call's lifetimer ran out */
-	RXRPC_CALL_ACCEPTED,		/* incoming call accepted by userspace app */
-	RXRPC_CALL_SECURED,		/* incoming call's connection is now secure */
-	RXRPC_CALL_POST_ACCEPT,		/* need to post an "accept?" message to the app */
-	RXRPC_CALL_RELEASE,		/* need to release the call's resources */
+	RXRPC_CALL_EV_RCVD_ACKALL,	/* ACKALL or reply received */
+	RXRPC_CALL_EV_RCVD_BUSY,	/* busy packet received */
+	RXRPC_CALL_EV_RCVD_ABORT,	/* abort packet received */
+	RXRPC_CALL_EV_RCVD_ERROR,	/* network error received */
+	RXRPC_CALL_EV_ACK_FINAL,	/* need to generate final ACK (and release call) */
+	RXRPC_CALL_EV_ACK,		/* need to generate ACK */
+	RXRPC_CALL_EV_REJECT_BUSY,	/* need to generate busy message */
+	RXRPC_CALL_EV_ABORT,		/* need to generate abort */
+	RXRPC_CALL_EV_CONN_ABORT,	/* local connection abort generated */
+	RXRPC_CALL_EV_RESEND_TIMER,	/* Tx resend timer expired */
+	RXRPC_CALL_EV_RESEND,		/* Tx resend required */
+	RXRPC_CALL_EV_DRAIN_RX_OOS,	/* drain the Rx out of sequence queue */
+	RXRPC_CALL_EV_LIFE_TIMER,	/* call's lifetimer ran out */
+	RXRPC_CALL_EV_ACCEPTED,		/* incoming call accepted by userspace app */
+	RXRPC_CALL_EV_SECURED,		/* incoming call's connection is now secure */
+	RXRPC_CALL_EV_POST_ACCEPT,	/* need to post an "accept?" message to the app */
+	RXRPC_CALL_EV_RELEASE,		/* need to release the call's resources */
 };
 
 /*
@@ -440,7 +440,7 @@ static inline void rxrpc_abort_call(struct rxrpc_call *call, u32 abort_code)
 	if (call->state < RXRPC_CALL_COMPLETE) {
 		call->abort_code = abort_code;
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
-		set_bit(RXRPC_CALL_ABORT, &call->events);
+		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 	}
 	write_unlock_bh(&call->state_lock);
 }
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 14c4e12c47b0..9e1527a6d026 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -111,11 +111,11 @@ static void rxrpc_send_abort(struct rxrpc_call *call, u32 abort_code)
 	if (call->state <= RXRPC_CALL_COMPLETE) {
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->abort_code = abort_code;
-		set_bit(RXRPC_CALL_ABORT, &call->events);
+		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		del_timer_sync(&call->resend_timer);
 		del_timer_sync(&call->ack_timer);
-		clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events);
-		clear_bit(RXRPC_CALL_ACK, &call->events);
+		clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events);
+		clear_bit(RXRPC_CALL_EV_ACK, &call->events);
 		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
 		rxrpc_queue_call(call);
 	}
@@ -437,7 +437,7 @@ static inline void rxrpc_instant_resend(struct rxrpc_call *call)
 	if (try_to_del_timer_sync(&call->resend_timer) >= 0) {
 		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
 		if (call->state < RXRPC_CALL_COMPLETE &&
-		    !test_and_set_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
+		    !test_and_set_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events))
 			rxrpc_queue_call(call);
 	}
 	read_unlock_bh(&call->state_lock);
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index b92beded7459..70f47033ff2f 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -33,7 +33,7 @@ void rxrpc_remove_user_ID(struct rxrpc_sock *rx, struct rxrpc_call *call)
 
 	read_lock_bh(&call->state_lock);
 	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+	    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
 		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
diff --git a/net/rxrpc/ar-skbuff.c b/net/rxrpc/ar-skbuff.c
index 4cfab49e329d..81f3c0238b9a 100644
--- a/net/rxrpc/ar-skbuff.c
+++ b/net/rxrpc/ar-skbuff.c
@@ -34,7 +34,7 @@ static void rxrpc_request_final_ACK(struct rxrpc_call *call)
 		/* get an extra ref on the call for the final-ACK generator to
 		 * release */
 		rxrpc_get_call(call);
-		set_bit(RXRPC_CALL_ACK_FINAL, &call->events);
+		set_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
 		if (try_to_del_timer_sync(&call->ack_timer) >= 0)
 			rxrpc_queue_call(call);
 		break;
