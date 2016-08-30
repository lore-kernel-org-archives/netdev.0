From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/8] rxrpc: Calls should only have one terminal
 state
Date: Tue, 30 Aug 2016 16:41:50 +0100
Message-ID: <147257171072.6391.8691256802200478759.stgit@warthog.procyon.org.uk>
References: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44430 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756690AbcH3Plx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 11:41:53 -0400
In-Reply-To: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Condense the terminal states of a call state machine to a single state,
plus a separate completion type value.  The value is then set, along with
error and abort code values, only when the call is transitioned to the
completion state.

Helpers are provided to simplify this.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |  116 ++++++++++++++++++++++++++++++++++++-----------
 net/rxrpc/call_accept.c |   19 ++------
 net/rxrpc/call_event.c  |   42 ++++++-----------
 net/rxrpc/call_object.c |   43 +++++++----------
 net/rxrpc/conn_client.c |    2 -
 net/rxrpc/conn_event.c  |   50 ++++++++++----------
 net/rxrpc/conn_object.c |    4 +-
 net/rxrpc/input.c       |   68 ++++++++++++++--------------
 net/rxrpc/output.c      |   27 ++++-------
 net/rxrpc/peer_event.c  |   24 ++++++----
 net/rxrpc/proc.c        |    3 -
 net/rxrpc/recvmsg.c     |   12 +++--
 12 files changed, 226 insertions(+), 184 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index c761124961cc..ce6afd931e91 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -289,8 +289,6 @@ enum rxrpc_conn_proto_state {
 	RXRPC_CONN_SERVICE,		/* Service secured connection */
 	RXRPC_CONN_REMOTELY_ABORTED,	/* Conn aborted by peer */
 	RXRPC_CONN_LOCALLY_ABORTED,	/* Conn aborted locally */
-	RXRPC_CONN_NETWORK_ERROR,	/* Conn terminated by network error */
-	RXRPC_CONN_LOCAL_ERROR,		/* Conn terminated by local error */
 	RXRPC_CONN__NR_STATES
 };
 
@@ -344,7 +342,6 @@ struct rxrpc_connection {
 	enum rxrpc_conn_proto_state state : 8;	/* current state of connection */
 	u32			local_abort;	/* local abort code */
 	u32			remote_abort;	/* remote abort code */
-	int			error;		/* local error incurred */
 	int			debug_id;	/* debug ID for printks */
 	atomic_t		serial;		/* packet serial number counter */
 	unsigned int		hi_serial;	/* highest serial number received */
@@ -411,13 +408,22 @@ enum rxrpc_call_state {
 	RXRPC_CALL_SERVER_ACK_REQUEST,	/* - server pending ACK of request */
 	RXRPC_CALL_SERVER_SEND_REPLY,	/* - server sending reply */
 	RXRPC_CALL_SERVER_AWAIT_ACK,	/* - server awaiting final ACK */
-	RXRPC_CALL_COMPLETE,		/* - call completed */
+	RXRPC_CALL_COMPLETE,		/* - call complete */
+	RXRPC_CALL_DEAD,		/* - call is dead */
+	NR__RXRPC_CALL_STATES
+};
+
+/*
+ * Call completion condition (state == RXRPC_CALL_COMPLETE).
+ */
+enum rxrpc_call_completion {
+	RXRPC_CALL_SUCCEEDED,		/* - Normal termination */
 	RXRPC_CALL_SERVER_BUSY,		/* - call rejected by busy server */
 	RXRPC_CALL_REMOTELY_ABORTED,	/* - call aborted by peer */
 	RXRPC_CALL_LOCALLY_ABORTED,	/* - call aborted locally on error or close */
+	RXRPC_CALL_LOCAL_ERROR,		/* - call failed due to local error */
 	RXRPC_CALL_NETWORK_ERROR,	/* - call terminated by network error */
-	RXRPC_CALL_DEAD,		/* - call is dead */
-	NR__RXRPC_CALL_STATES
+	NR__RXRPC_CALL_COMPLETIONS
 };
 
 /*
@@ -451,14 +457,13 @@ struct rxrpc_call {
 	unsigned long		events;
 	spinlock_t		lock;
 	rwlock_t		state_lock;	/* lock for state transition */
+	u32			abort_code;	/* Local/remote abort code */
+	int			error;		/* Local error incurred */
+	enum rxrpc_call_state	state : 8;	/* current state of call */
+	enum rxrpc_call_completion completion : 8; /* Call completion condition */
 	atomic_t		usage;
 	atomic_t		skb_count;	/* Outstanding packets on this call */
 	atomic_t		sequence;	/* Tx data packet sequence counter */
-	u32			local_abort;	/* local abort code */
-	u32			remote_abort;	/* remote abort code */
-	int			error_report;	/* Network error (ICMP/local transport) */
-	int			error;		/* Local error incurred */
-	enum rxrpc_call_state	state : 8;	/* current state of call */
 	u16			service_id;	/* service ID */
 	u32			call_id;	/* call ID on connection  */
 	u32			cid;		/* connection ID plus channel index */
@@ -493,20 +498,6 @@ struct rxrpc_call {
 	unsigned long		ackr_window[RXRPC_ACKR_WINDOW_ASZ + 1];
 };
 
-/*
- * locally abort an RxRPC call
- */
-static inline void rxrpc_abort_call(struct rxrpc_call *call, u32 abort_code)
-{
-	write_lock_bh(&call->state_lock);
-	if (call->state < RXRPC_CALL_COMPLETE) {
-		call->local_abort = abort_code;
-		call->state = RXRPC_CALL_LOCALLY_ABORTED;
-		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
-	}
-	write_unlock_bh(&call->state_lock);
-}
-
 #include <trace/events/rxrpc.h>
 
 /*
@@ -534,6 +525,8 @@ void rxrpc_process_call(struct work_struct *);
 /*
  * call_object.c
  */
+extern const char *const rxrpc_call_states[];
+extern const char *const rxrpc_call_completions[];
 extern unsigned int rxrpc_max_call_lifetime;
 extern unsigned int rxrpc_dead_call_expiry;
 extern struct kmem_cache *rxrpc_call_jar;
@@ -564,6 +557,78 @@ static inline bool rxrpc_is_client_call(const struct rxrpc_call *call)
 }
 
 /*
+ * Transition a call to the complete state.
+ */
+static inline bool __rxrpc_set_call_completion(struct rxrpc_call *call,
+					       enum rxrpc_call_completion compl,
+					       u32 abort_code,
+					       int error)
+{
+	if (call->state < RXRPC_CALL_COMPLETE) {
+		call->abort_code = abort_code;
+		call->error = error;
+		call->completion = compl,
+		call->state = RXRPC_CALL_COMPLETE;
+		return true;
+	}
+	return false;
+}
+
+static inline bool rxrpc_set_call_completion(struct rxrpc_call *call,
+					     enum rxrpc_call_completion compl,
+					     u32 abort_code,
+					     int error)
+{
+	int ret;
+
+	write_lock_bh(&call->state_lock);
+	ret = __rxrpc_set_call_completion(call, compl, abort_code, error);
+	write_unlock_bh(&call->state_lock);
+	return ret;
+}
+
+/*
+ * Record that a call successfully completed.
+ */
+static inline void __rxrpc_call_completed(struct rxrpc_call *call)
+{
+	__rxrpc_set_call_completion(call, RXRPC_CALL_SUCCEEDED, 0, 0);
+}
+
+static inline void rxrpc_call_completed(struct rxrpc_call *call)
+{
+	write_lock_bh(&call->state_lock);
+	__rxrpc_call_completed(call);
+	write_unlock_bh(&call->state_lock);
+}
+
+/*
+ * Record that a call is locally aborted.
+ */
+static inline bool __rxrpc_abort_call(struct rxrpc_call *call,
+				      u32 abort_code, int error)
+{
+	if (__rxrpc_set_call_completion(call,
+					RXRPC_CALL_LOCALLY_ABORTED,
+					abort_code, error)) {
+		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
+		return true;
+	}
+	return false;
+}
+
+static inline bool rxrpc_abort_call(struct rxrpc_call *call,
+				    u32 abort_code, int error)
+{
+	bool ret;
+
+	write_lock_bh(&call->state_lock);
+	ret = __rxrpc_abort_call(call, abort_code, error);
+	write_unlock_bh(&call->state_lock);
+	return ret;
+}
+
+/*
  * conn_client.c
  */
 extern unsigned int rxrpc_max_client_connections;
@@ -778,7 +843,6 @@ static inline void rxrpc_put_peer(struct rxrpc_peer *peer)
 /*
  * proc.c
  */
-extern const char *const rxrpc_call_states[];
 extern const struct file_operations rxrpc_call_seq_fops;
 extern const struct file_operations rxrpc_connection_seq_fops;
 
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 669ac79d3b44..ef9ef0d6c917 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -329,12 +329,8 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	case RXRPC_CALL_SERVER_ACCEPTING:
 		call->state = RXRPC_CALL_SERVER_RECV_REQUEST;
 		break;
-	case RXRPC_CALL_REMOTELY_ABORTED:
-	case RXRPC_CALL_LOCALLY_ABORTED:
-		ret = -ECONNABORTED;
-		goto out_release;
-	case RXRPC_CALL_NETWORK_ERROR:
-		ret = call->conn->error;
+	case RXRPC_CALL_COMPLETE:
+		ret = call->error;
 		goto out_release;
 	case RXRPC_CALL_DEAD:
 		ret = -ETIME;
@@ -403,17 +399,14 @@ int rxrpc_reject_call(struct rxrpc_sock *rx)
 	write_lock_bh(&call->state_lock);
 	switch (call->state) {
 	case RXRPC_CALL_SERVER_ACCEPTING:
-		call->state = RXRPC_CALL_SERVER_BUSY;
+		__rxrpc_set_call_completion(call, RXRPC_CALL_SERVER_BUSY,
+					    0, ECONNABORTED);
 		if (test_and_set_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events))
 			rxrpc_queue_call(call);
 		ret = 0;
 		goto out_release;
-	case RXRPC_CALL_REMOTELY_ABORTED:
-	case RXRPC_CALL_LOCALLY_ABORTED:
-		ret = -ECONNABORTED;
-		goto out_release;
-	case RXRPC_CALL_NETWORK_ERROR:
-		ret = call->conn->error;
+	case RXRPC_CALL_COMPLETE:
+		ret = call->error;
 		goto out_release;
 	case RXRPC_CALL_DEAD:
 		ret = -ETIME;
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 5292bcfd8816..94c7751fd99a 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -95,7 +95,7 @@ cancel_timer:
 	_debug("cancel timer %%%u", serial);
 	try_to_del_timer_sync(&call->ack_timer);
 	read_lock_bh(&call->state_lock);
-	if (call->state <= RXRPC_CALL_COMPLETE &&
+	if (call->state < RXRPC_CALL_COMPLETE &&
 	    !test_and_set_bit(RXRPC_CALL_EV_ACK, &call->events))
 		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
@@ -123,7 +123,7 @@ static void rxrpc_set_resend(struct rxrpc_call *call, u8 resend,
 			     unsigned long resend_at)
 {
 	read_lock_bh(&call->state_lock);
-	if (call->state >= RXRPC_CALL_COMPLETE)
+	if (call->state == RXRPC_CALL_COMPLETE)
 		resend = 0;
 
 	if (resend & 1) {
@@ -230,7 +230,7 @@ static void rxrpc_resend_timer(struct rxrpc_call *call)
 	_enter("%d,%d,%d",
 	       call->acks_tail, call->acks_unacked, call->acks_head);
 
-	if (call->state >= RXRPC_CALL_COMPLETE)
+	if (call->state == RXRPC_CALL_COMPLETE)
 		return;
 
 	resend = 0;
@@ -711,7 +711,7 @@ all_acked:
 		break;
 	case RXRPC_CALL_SERVER_AWAIT_ACK:
 		_debug("srv complete");
-		call->state = RXRPC_CALL_COMPLETE;
+		__rxrpc_call_completed(call);
 		post_ACK = true;
 		break;
 	case RXRPC_CALL_CLIENT_SEND_REQUEST:
@@ -875,24 +875,22 @@ skip_msg_init:
 		clear_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events);
 		clear_bit(RXRPC_CALL_EV_ABORT, &call->events);
 
-		error = call->error_report;
-		if (error < RXRPC_LOCAL_ERROR_OFFSET) {
+		if (call->completion == RXRPC_CALL_NETWORK_ERROR) {
 			mark = RXRPC_SKB_MARK_NET_ERROR;
 			_debug("post net error %d", error);
 		} else {
 			mark = RXRPC_SKB_MARK_LOCAL_ERROR;
-			error -= RXRPC_LOCAL_ERROR_OFFSET;
 			_debug("post net local error %d", error);
 		}
 
-		if (rxrpc_post_message(call, mark, error, true) < 0)
+		if (rxrpc_post_message(call, mark, call->error, true) < 0)
 			goto no_mem;
 		clear_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events);
 		goto kill_ACKs;
 	}
 
 	if (test_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events)) {
-		ASSERTCMP(call->state, >, RXRPC_CALL_COMPLETE);
+		ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
 
 		clear_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events);
 		clear_bit(RXRPC_CALL_EV_ABORT, &call->events);
@@ -900,7 +898,7 @@ skip_msg_init:
 		_debug("post conn abort");
 
 		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
-				       call->conn->error, true) < 0)
+				       call->error, true) < 0)
 			goto no_mem;
 		clear_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events);
 		goto kill_ACKs;
@@ -913,13 +911,13 @@ skip_msg_init:
 	}
 
 	if (test_bit(RXRPC_CALL_EV_ABORT, &call->events)) {
-		ASSERTCMP(call->state, >, RXRPC_CALL_COMPLETE);
+		ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
 
 		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
-				       ECONNABORTED, true) < 0)
+				       call->error, true) < 0)
 			goto no_mem;
 		whdr.type = RXRPC_PACKET_TYPE_ABORT;
-		data = htonl(call->local_abort);
+		data = htonl(call->abort_code);
 		iov[1].iov_base = &data;
 		iov[1].iov_len = sizeof(data);
 		genbit = RXRPC_CALL_EV_ABORT;
@@ -979,13 +977,7 @@ skip_msg_init:
 	}
 
 	if (test_bit(RXRPC_CALL_EV_LIFE_TIMER, &call->events)) {
-		write_lock_bh(&call->state_lock);
-		if (call->state <= RXRPC_CALL_COMPLETE) {
-			call->state = RXRPC_CALL_LOCALLY_ABORTED;
-			call->local_abort = RX_CALL_TIMEOUT;
-			set_bit(RXRPC_CALL_EV_ABORT, &call->events);
-		}
-		write_unlock_bh(&call->state_lock);
+		rxrpc_abort_call(call, RX_CALL_TIMEOUT, ETIME);
 
 		_debug("post timeout");
 		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
@@ -998,7 +990,8 @@ skip_msg_init:
 
 	/* deal with assorted inbound messages */
 	if (!skb_queue_empty(&call->rx_queue)) {
-		switch (rxrpc_process_rx_queue(call, &abort_code)) {
+		ret = rxrpc_process_rx_queue(call, &abort_code);
+		switch (ret) {
 		case 0:
 		case -EAGAIN:
 			break;
@@ -1007,7 +1000,7 @@ skip_msg_init:
 		case -EKEYEXPIRED:
 		case -EKEYREJECTED:
 		case -EPROTO:
-			rxrpc_abort_call(call, abort_code);
+			rxrpc_abort_call(call, abort_code, -ret);
 			goto kill_ACKs;
 		}
 	}
@@ -1232,10 +1225,7 @@ send_message_2:
 		goto kill_ACKs;
 
 	case RXRPC_CALL_EV_ACK_FINAL:
-		write_lock_bh(&call->state_lock);
-		if (call->state == RXRPC_CALL_CLIENT_FINAL_ACK)
-			call->state = RXRPC_CALL_COMPLETE;
-		write_unlock_bh(&call->state_lock);
+		rxrpc_call_completed(call);
 		goto kill_ACKs;
 
 	default:
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index e7cbcc4a87cf..852c30dc7b75 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -30,7 +30,7 @@ unsigned int rxrpc_max_call_lifetime = 60 * HZ;
 unsigned int rxrpc_dead_call_expiry = 2 * HZ;
 
 const char *const rxrpc_call_states[NR__RXRPC_CALL_STATES] = {
-	[RXRPC_CALL_UNINITIALISED]		= "Uninit",
+	[RXRPC_CALL_UNINITIALISED]		= "Uninit  ",
 	[RXRPC_CALL_CLIENT_AWAIT_CONN]		= "ClWtConn",
 	[RXRPC_CALL_CLIENT_SEND_REQUEST]	= "ClSndReq",
 	[RXRPC_CALL_CLIENT_AWAIT_REPLY]		= "ClAwtRpl",
@@ -43,11 +43,16 @@ const char *const rxrpc_call_states[NR__RXRPC_CALL_STATES] = {
 	[RXRPC_CALL_SERVER_SEND_REPLY]		= "SvSndRpl",
 	[RXRPC_CALL_SERVER_AWAIT_ACK]		= "SvAwtACK",
 	[RXRPC_CALL_COMPLETE]			= "Complete",
+	[RXRPC_CALL_DEAD]			= "Dead    ",
+};
+
+const char *const rxrpc_call_completions[NR__RXRPC_CALL_COMPLETIONS] = {
+	[RXRPC_CALL_SUCCEEDED]			= "Complete",
 	[RXRPC_CALL_SERVER_BUSY]		= "SvBusy  ",
 	[RXRPC_CALL_REMOTELY_ABORTED]		= "RmtAbort",
 	[RXRPC_CALL_LOCALLY_ABORTED]		= "LocAbort",
+	[RXRPC_CALL_LOCAL_ERROR]		= "LocError",
 	[RXRPC_CALL_NETWORK_ERROR]		= "NetError",
-	[RXRPC_CALL_DEAD]			= "Dead    ",
 };
 
 struct kmem_cache *rxrpc_call_jar;
@@ -358,7 +363,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 		_debug("CALL: %u { %s }",
 		       call->debug_id, rxrpc_call_states[call->state]);
 
-		if (call->state >= RXRPC_CALL_COMPLETE) {
+		if (call->state == RXRPC_CALL_COMPLETE) {
 			__rxrpc_disconnect_call(conn, call);
 		} else {
 			spin_unlock(&conn->channel_lock);
@@ -472,8 +477,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    call->state != RXRPC_CALL_CLIENT_FINAL_ACK) {
 		_debug("+++ ABORTING STATE %d +++\n", call->state);
-		call->state = RXRPC_CALL_LOCALLY_ABORTED;
-		call->local_abort = RX_CALL_DEAD;
+		__rxrpc_abort_call(call, RX_CALL_DEAD, ECONNRESET);
 	}
 	write_unlock_bh(&call->state_lock);
 
@@ -538,20 +542,13 @@ static void rxrpc_mark_call_released(struct rxrpc_call *call)
 
 	write_lock(&call->state_lock);
 	if (call->state < RXRPC_CALL_DEAD) {
-		sched = false;
-		if (call->state < RXRPC_CALL_COMPLETE) {
-			_debug("abort call %p", call);
-			call->state = RXRPC_CALL_LOCALLY_ABORTED;
-			call->local_abort = RX_CALL_DEAD;
-			if (!test_and_set_bit(RXRPC_CALL_EV_ABORT, &call->events))
-				sched = true;
-		}
+		sched = __rxrpc_abort_call(call, RX_CALL_DEAD, ECONNRESET);
 		if (!test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
 			sched = true;
-		if (sched)
-			rxrpc_queue_call(call);
 	}
 	write_unlock(&call->state_lock);
+	if (sched)
+		rxrpc_queue_call(call);
 }
 
 /*
@@ -749,16 +746,13 @@ static void rxrpc_call_life_expired(unsigned long _call)
 {
 	struct rxrpc_call *call = (struct rxrpc_call *) _call;
 
+	_enter("{%d}", call->debug_id);
+
 	if (call->state >= RXRPC_CALL_COMPLETE)
 		return;
 
-	_enter("{%d}", call->debug_id);
-	read_lock_bh(&call->state_lock);
-	if (call->state < RXRPC_CALL_COMPLETE) {
-		set_bit(RXRPC_CALL_EV_LIFE_TIMER, &call->events);
-		rxrpc_queue_call(call);
-	}
-	read_unlock_bh(&call->state_lock);
+	set_bit(RXRPC_CALL_EV_LIFE_TIMER, &call->events);
+	rxrpc_queue_call(call);
 }
 
 /*
@@ -791,9 +785,6 @@ static void rxrpc_ack_time_expired(unsigned long _call)
 	if (call->state >= RXRPC_CALL_COMPLETE)
 		return;
 
-	read_lock_bh(&call->state_lock);
-	if (call->state < RXRPC_CALL_COMPLETE &&
-	    !test_and_set_bit(RXRPC_CALL_EV_ACK, &call->events))
+	if (!test_and_set_bit(RXRPC_CALL_EV_ACK, &call->events))
 		rxrpc_queue_call(call);
-	read_unlock_bh(&call->state_lock);
 }
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 349402b08e5a..44850a2d90b5 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -741,7 +741,7 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 	 * terminal retransmission without requiring access to the call.
 	 */
 	if (test_bit(RXRPC_CALL_EXPOSED, &call->flags)) {
-		_debug("exposed %u,%u", call->call_id, call->local_abort);
+		_debug("exposed %u,%u", call->call_id, call->abort_code);
 		__rxrpc_disconnect_call(conn, call);
 	}
 
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index bb81801fb805..bcea99c73b40 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -27,8 +27,8 @@
 /*
  * Retransmit terminal ACK or ABORT of the previous call.
  */
-static void rxrpc_conn_retransmit(struct rxrpc_connection *conn,
-				  struct sk_buff *skb)
+static void rxrpc_conn_retransmit_call(struct rxrpc_connection *conn,
+				       struct sk_buff *skb)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_channel *chan;
@@ -135,14 +135,21 @@ static void rxrpc_conn_retransmit(struct rxrpc_connection *conn,
 /*
  * pass a connection-level abort onto all calls on that connection
  */
-static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
-			      u32 abort_code)
+static void rxrpc_abort_calls(struct rxrpc_connection *conn,
+			      enum rxrpc_call_completion compl,
+			      u32 abort_code, int error)
 {
 	struct rxrpc_call *call;
-	int i;
+	bool queue;
+	int i, bit;
 
 	_enter("{%d},%x", conn->debug_id, abort_code);
 
+	if (compl == RXRPC_CALL_LOCALLY_ABORTED)
+		bit = RXRPC_CALL_EV_CONN_ABORT;
+	else
+		bit = RXRPC_CALL_EV_RCVD_ABORT;
+
 	spin_lock(&conn->channel_lock);
 
 	for (i = 0; i < RXRPC_MAXCALLS; i++) {
@@ -151,20 +158,14 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
 			lockdep_is_held(&conn->channel_lock));
 		if (call) {
 			write_lock_bh(&call->state_lock);
-			if (call->state <= RXRPC_CALL_COMPLETE) {
-				call->state = state;
-				if (state == RXRPC_CALL_LOCALLY_ABORTED) {
-					call->local_abort = conn->local_abort;
-					set_bit(RXRPC_CALL_EV_CONN_ABORT,
-						&call->events);
-				} else {
-					call->remote_abort = conn->remote_abort;
-					set_bit(RXRPC_CALL_EV_RCVD_ABORT,
-						&call->events);
-				}
-				rxrpc_queue_call(call);
+			if (rxrpc_set_call_completion(call, compl, abort_code,
+						      error)) {
+				set_bit(bit, &call->events);
+				queue = true;
 			}
 			write_unlock_bh(&call->state_lock);
+			if (queue)
+				rxrpc_queue_call(call);
 		}
 	}
 
@@ -190,17 +191,16 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 
 	/* generate a connection-level abort */
 	spin_lock_bh(&conn->state_lock);
-	if (conn->state < RXRPC_CONN_REMOTELY_ABORTED) {
-		conn->state = RXRPC_CONN_LOCALLY_ABORTED;
-		conn->error = error;
-		spin_unlock_bh(&conn->state_lock);
-	} else {
+	if (conn->state >= RXRPC_CONN_REMOTELY_ABORTED) {
 		spin_unlock_bh(&conn->state_lock);
 		_leave(" = 0 [already dead]");
 		return 0;
 	}
 
-	rxrpc_abort_calls(conn, RXRPC_CALL_LOCALLY_ABORTED, abort_code);
+	conn->state = RXRPC_CONN_LOCALLY_ABORTED;
+	spin_unlock_bh(&conn->state_lock);
+
+	rxrpc_abort_calls(conn, RXRPC_CALL_LOCALLY_ABORTED, abort_code, error);
 
 	msg.msg_name	= &conn->params.peer->srx.transport;
 	msg.msg_namelen	= conn->params.peer->srx.transport_len;
@@ -280,7 +280,7 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 	switch (sp->hdr.type) {
 	case RXRPC_PACKET_TYPE_DATA:
 	case RXRPC_PACKET_TYPE_ACK:
-		rxrpc_conn_retransmit(conn, skb);
+		rxrpc_conn_retransmit_call(conn, skb);
 		rxrpc_free_skb(skb);
 		return 0;
 
@@ -291,7 +291,7 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		_proto("Rx ABORT %%%u { ac=%d }", sp->hdr.serial, abort_code);
 
 		conn->state = RXRPC_CONN_REMOTELY_ABORTED;
-		rxrpc_abort_calls(conn, RXRPC_CALL_REMOTELY_ABORTED,
+		rxrpc_abort_calls(conn, 0, RXRPC_CALL_REMOTELY_ABORTED,
 				  abort_code);
 		return -ECONNABORTED;
 
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 5b45b6c367e7..9c6685b97e70 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -165,8 +165,8 @@ void __rxrpc_disconnect_call(struct rxrpc_connection *conn,
 		 * through the channel, whilst disposing of the actual call record.
 		 */
 		chan->last_service_id = call->service_id;
-		if (call->local_abort) {
-			chan->last_abort = call->local_abort;
+		if (call->abort_code) {
+			chan->last_abort = call->abort_code;
 			chan->last_type = RXRPC_PACKET_TYPE_ABORT;
 		} else {
 			chan->last_seq = call->rx_data_eaten;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 5e683dd21ab9..af49c2992c4a 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -341,14 +341,13 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		abort_code = ntohl(wtmp);
 		_proto("Rx ABORT %%%u { %x }", sp->hdr.serial, abort_code);
 
-		write_lock_bh(&call->state_lock);
-		if (call->state < RXRPC_CALL_COMPLETE) {
-			call->state = RXRPC_CALL_REMOTELY_ABORTED;
-			call->remote_abort = abort_code;
+		if (__rxrpc_set_call_completion(call,
+						RXRPC_CALL_REMOTELY_ABORTED,
+						abort_code, ECONNABORTED)) {
 			set_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
 			rxrpc_queue_call(call);
 		}
-		goto free_packet_unlock;
+		goto free_packet;
 
 	case RXRPC_PACKET_TYPE_BUSY:
 		_proto("Rx BUSY %%%u", sp->hdr.serial);
@@ -359,7 +358,9 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		write_lock_bh(&call->state_lock);
 		switch (call->state) {
 		case RXRPC_CALL_CLIENT_SEND_REQUEST:
-			call->state = RXRPC_CALL_SERVER_BUSY;
+			__rxrpc_set_call_completion(call,
+						    RXRPC_CALL_SERVER_BUSY,
+						    0, EBUSY);
 			set_bit(RXRPC_CALL_EV_RCVD_BUSY, &call->events);
 			rxrpc_queue_call(call);
 		case RXRPC_CALL_SERVER_BUSY:
@@ -415,12 +416,8 @@ protocol_error:
 	_debug("protocol error");
 	write_lock_bh(&call->state_lock);
 protocol_error_locked:
-	if (call->state <= RXRPC_CALL_COMPLETE) {
-		call->state = RXRPC_CALL_LOCALLY_ABORTED;
-		call->local_abort = RX_PROTOCOL_ERROR;
-		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
+	if (__rxrpc_abort_call(call, RX_PROTOCOL_ERROR, EPROTO))
 		rxrpc_queue_call(call);
-	}
 free_packet_unlock:
 	write_unlock_bh(&call->state_lock);
 free_packet:
@@ -486,14 +483,8 @@ protocol_error:
 	_debug("protocol error");
 	rxrpc_free_skb(part);
 	rxrpc_free_skb(jumbo);
-	write_lock_bh(&call->state_lock);
-	if (call->state <= RXRPC_CALL_COMPLETE) {
-		call->state = RXRPC_CALL_LOCALLY_ABORTED;
-		call->local_abort = RX_PROTOCOL_ERROR;
-		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
+	if (rxrpc_abort_call(call, RX_PROTOCOL_ERROR, EPROTO))
 		rxrpc_queue_call(call);
-	}
-	write_unlock_bh(&call->state_lock);
 	_leave("");
 }
 
@@ -514,26 +505,28 @@ static void rxrpc_post_packet_to_call(struct rxrpc_call *call,
 
 	read_lock(&call->state_lock);
 	switch (call->state) {
-	case RXRPC_CALL_LOCALLY_ABORTED:
-		if (!test_and_set_bit(RXRPC_CALL_EV_ABORT, &call->events)) {
-			rxrpc_queue_call(call);
-			goto free_unlock;
-		}
-	case RXRPC_CALL_REMOTELY_ABORTED:
-	case RXRPC_CALL_NETWORK_ERROR:
 	case RXRPC_CALL_DEAD:
 		goto dead_call;
+
 	case RXRPC_CALL_COMPLETE:
-	case RXRPC_CALL_CLIENT_FINAL_ACK:
-		/* complete server call */
-		if (rxrpc_conn_is_service(call->conn))
+		switch (call->completion) {
+		case RXRPC_CALL_LOCALLY_ABORTED:
+			if (!test_and_set_bit(RXRPC_CALL_EV_ABORT,
+					      &call->events)) {
+				rxrpc_queue_call(call);
+				goto free_unlock;
+			}
+		default:
 			goto dead_call;
-		/* resend last packet of a completed call */
-		_debug("final ack again");
-		rxrpc_get_call(call);
-		set_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
-		rxrpc_queue_call(call);
-		goto free_unlock;
+		case RXRPC_CALL_SUCCEEDED:
+			if (rxrpc_conn_is_service(call->conn))
+				goto dead_call;
+			goto resend_final_ack;
+		}
+
+	case RXRPC_CALL_CLIENT_FINAL_ACK:
+		goto resend_final_ack;
+
 	default:
 		break;
 	}
@@ -550,6 +543,13 @@ static void rxrpc_post_packet_to_call(struct rxrpc_call *call,
 	rxrpc_put_call(call);
 	goto done;
 
+resend_final_ack:
+	_debug("final ack again");
+	rxrpc_get_call(call);
+	set_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
+	rxrpc_queue_call(call);
+	goto free_unlock;
+
 dead_call:
 	if (sp->hdr.type != RXRPC_PACKET_TYPE_ABORT) {
 		skb->priority = RX_CALL_DEAD;
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 8a9917cba6fe..036e1112b0c5 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -115,12 +115,12 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
  */
 static void rxrpc_send_abort(struct rxrpc_call *call, u32 abort_code)
 {
+	if (call->state >= RXRPC_CALL_COMPLETE)
+		return;
+
 	write_lock_bh(&call->state_lock);
 
-	if (call->state <= RXRPC_CALL_COMPLETE) {
-		call->state = RXRPC_CALL_LOCALLY_ABORTED;
-		call->local_abort = abort_code;
-		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
+	if (__rxrpc_abort_call(call, abort_code, ECONNABORTED)) {
 		del_timer_sync(&call->resend_timer);
 		del_timer_sync(&call->ack_timer);
 		clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events);
@@ -212,7 +212,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 
 	if (call->state >= RXRPC_CALL_COMPLETE) {
 		/* it's too late for this call */
-		ret = -ECONNRESET;
+		ret = -ESHUTDOWN;
 	} else if (cmd == RXRPC_CMD_SEND_ABORT) {
 		rxrpc_send_abort(call, abort_code);
 		ret = 0;
@@ -295,8 +295,7 @@ void rxrpc_kernel_abort_call(struct rxrpc_call *call, u32 abort_code)
 	_debug("CALL %d USR %lx ST %d on CONN %p",
 	       call->debug_id, call->user_call_ID, call->state, call->conn);
 
-	if (call->state < RXRPC_CALL_COMPLETE)
-		rxrpc_send_abort(call, abort_code);
+	rxrpc_send_abort(call, abort_code);
 
 	release_sock(&call->socket->sk);
 	_leave("");
@@ -640,8 +639,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 		/* check for the far side aborting the call or a network error
 		 * occurring */
-		if (call->state > RXRPC_CALL_COMPLETE)
-			goto call_aborted;
+		if (call->state == RXRPC_CALL_COMPLETE)
+			goto call_terminated;
 
 		/* add the packet to the send queue if it's now full */
 		if (sp->remain <= 0 ||
@@ -702,15 +701,9 @@ out:
 	_leave(" = %d", ret);
 	return ret;
 
-call_aborted:
+call_terminated:
 	rxrpc_free_skb(skb);
-	if (call->state == RXRPC_CALL_NETWORK_ERROR)
-		ret = call->error_report < RXRPC_LOCAL_ERROR_OFFSET ?
-			call->error_report :
-			call->error_report - RXRPC_LOCAL_ERROR_OFFSET;
-	else
-		ret = -ECONNABORTED;
-	_leave(" = %d", ret);
+	_leave(" = %d", -call->error);
 	return ret;
 
 maybe_error:
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 8940674b5e08..865078d76ad3 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -248,13 +248,21 @@ void rxrpc_peer_error_distributor(struct work_struct *work)
 	struct rxrpc_peer *peer =
 		container_of(work, struct rxrpc_peer, error_distributor);
 	struct rxrpc_call *call;
-	int error_report;
+	enum rxrpc_call_completion compl;
+	bool queue;
+	int error;
 
 	_enter("");
 
-	error_report = READ_ONCE(peer->error_report);
+	error = READ_ONCE(peer->error_report);
+	if (error < RXRPC_LOCAL_ERROR_OFFSET) {
+		compl = RXRPC_CALL_NETWORK_ERROR;
+	} else {
+		compl = RXRPC_CALL_LOCAL_ERROR;
+		error -= RXRPC_LOCAL_ERROR_OFFSET;
+	}
 
-	_debug("ISSUE ERROR %d", error_report);
+	_debug("ISSUE ERROR %s %d", rxrpc_call_completions[compl], error);
 
 	spin_lock_bh(&peer->lock);
 
@@ -263,15 +271,15 @@ void rxrpc_peer_error_distributor(struct work_struct *work)
 				   struct rxrpc_call, error_link);
 		hlist_del_init(&call->error_link);
 
+		queue = false;
 		write_lock(&call->state_lock);
-		if (call->state != RXRPC_CALL_COMPLETE &&
-		    call->state < RXRPC_CALL_NETWORK_ERROR) {
-			call->error_report = error_report;
-			call->state = RXRPC_CALL_NETWORK_ERROR;
+		if (__rxrpc_set_call_completion(call, compl, 0, error)) {
 			set_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events);
-			rxrpc_queue_call(call);
+			queue = true;
 		}
 		write_unlock(&call->state_lock);
+		if (queue)
+			rxrpc_queue_call(call);
 	}
 
 	spin_unlock_bh(&peer->lock);
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index 060fb4892c39..82c64055449d 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -22,7 +22,6 @@ static const char *const rxrpc_conn_states[RXRPC_CONN__NR_STATES] = {
 	[RXRPC_CONN_SERVICE]			= "SvSecure",
 	[RXRPC_CONN_REMOTELY_ABORTED]		= "RmtAbort",
 	[RXRPC_CONN_LOCALLY_ABORTED]		= "LocAbort",
-	[RXRPC_CONN_NETWORK_ERROR]		= "NetError",
 };
 
 /*
@@ -94,7 +93,7 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 		   rxrpc_is_service_call(call) ? "Svc" : "Clt",
 		   atomic_read(&call->usage),
 		   rxrpc_call_states[call->state],
-		   call->remote_abort ?: call->local_abort,
+		   call->abort_code,
 		   call->user_call_ID);
 
 	return 0;
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index b964c2d49a88..96d98a3a7087 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -294,12 +294,17 @@ receive_non_data_message:
 		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_BUSY, 0, &abort_code);
 		break;
 	case RXRPC_SKB_MARK_REMOTE_ABORT:
-		abort_code = call->remote_abort;
+		abort_code = call->abort_code;
 		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &abort_code);
 		break;
 	case RXRPC_SKB_MARK_LOCAL_ABORT:
-		abort_code = call->local_abort;
+		abort_code = call->abort_code;
 		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &abort_code);
+		if (call->error) {
+			abort_code = call->error;
+			ret = put_cmsg(msg, SOL_RXRPC, RXRPC_LOCAL_ERROR, 4,
+				       &abort_code);
+		}
 		break;
 	case RXRPC_SKB_MARK_NET_ERROR:
 		_debug("RECV NET ERROR %d", sp->error);
@@ -392,9 +397,8 @@ u32 rxrpc_kernel_get_abort_code(struct sk_buff *skb)
 
 	switch (skb->mark) {
 	case RXRPC_SKB_MARK_REMOTE_ABORT:
-		return sp->call->remote_abort;
 	case RXRPC_SKB_MARK_LOCAL_ABORT:
-		return sp->call->local_abort;
+		return sp->call->abort_code;
 	default:
 		BUG();
 	}
