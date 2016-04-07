From: David Howells <dhowells@redhat.com>
Subject: [PATCH 5/9] rxrpc: Differentiate local and remote abort codes in
 structs
Date: Thu, 07 Apr 2016 17:23:30 +0100
Message-ID: <20160407162330.21283.6726.stgit@warthog.procyon.org.uk>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the rxrpc_connection and rxrpc_call structs, there's one field to hold
the abort code, no matter whether that value was generated locally to be
sent or was received from the peer via an abort packet.

Split the abort code fields in two for cleanliness sake and add an error
field to hold the Linux error number to the rxrpc_call struct too
(sometimes this is generated in a context where we can't return it to
userspace directly).

Furthermore, add a skb mark to indicate a packet that caused a local abort
to be generated so that recvmsg() can pick up the correct abort code.  A
future addition will need to be to indicate to userspace the difference
between aborts via a control message.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/rxrpc.c           |   14 +++++++++++---
 include/net/af_rxrpc.h   |    3 ++-
 net/rxrpc/ar-ack.c       |    4 ++--
 net/rxrpc/ar-call.c      |    4 ++--
 net/rxrpc/ar-connevent.c |   12 +++++++-----
 net/rxrpc/ar-input.c     |    6 +++---
 net/rxrpc/ar-internal.h  |   10 +++++++---
 net/rxrpc/ar-output.c    |    2 +-
 net/rxrpc/ar-proc.c      |    2 +-
 net/rxrpc/ar-recvmsg.c   |   18 ++++++++++++++----
 10 files changed, 50 insertions(+), 25 deletions(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 7c2567a711ea..e24ffa9ef166 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -430,9 +430,11 @@ error_kill_call:
 }
 
 /*
- * handles intercepted messages that were arriving in the socket's Rx queue
- * - called with the socket receive queue lock held to ensure message ordering
- * - called with softirqs disabled
+ * Handles intercepted messages that were arriving in the socket's Rx queue.
+ *
+ * Called from the AF_RXRPC call processor in waitqueue process context.  For
+ * each call, it is guaranteed this will be called in order of packet to be
+ * delivered.
  */
 static void afs_rx_interceptor(struct sock *sk, unsigned long user_call_ID,
 			       struct sk_buff *skb)
@@ -523,6 +525,12 @@ static void afs_deliver_to_call(struct afs_call *call)
 			call->state = AFS_CALL_ABORTED;
 			_debug("Rcv ABORT %u -> %d", abort_code, call->error);
 			break;
+		case RXRPC_SKB_MARK_LOCAL_ABORT:
+			abort_code = rxrpc_kernel_get_abort_code(skb);
+			call->error = call->type->abort_to_error(abort_code);
+			call->state = AFS_CALL_ABORTED;
+			_debug("Loc ABORT %u -> %d", abort_code, call->error);
+			break;
 		case RXRPC_SKB_MARK_NET_ERROR:
 			call->error = -rxrpc_kernel_get_error_number(skb);
 			call->state = AFS_CALL_ERROR;
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index 4fd3e4a2cadd..ac1bc3c49fbd 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -20,11 +20,12 @@ struct rxrpc_call;
 /*
  * the mark applied to socket buffers that may be intercepted
  */
-enum {
+enum rxrpc_skb_mark {
 	RXRPC_SKB_MARK_DATA,		/* data message */
 	RXRPC_SKB_MARK_FINAL_ACK,	/* final ACK received message */
 	RXRPC_SKB_MARK_BUSY,		/* server busy message */
 	RXRPC_SKB_MARK_REMOTE_ABORT,	/* remote abort message */
+	RXRPC_SKB_MARK_LOCAL_ABORT,	/* local abort message */
 	RXRPC_SKB_MARK_NET_ERROR,	/* network error message */
 	RXRPC_SKB_MARK_LOCAL_ERROR,	/* local error message */
 	RXRPC_SKB_MARK_NEW_CALL,	/* local error message */
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 54bf43ba9aa8..d0eb98e1391c 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -905,7 +905,7 @@ void rxrpc_process_call(struct work_struct *work)
 				       ECONNABORTED, true) < 0)
 			goto no_mem;
 		whdr.type = RXRPC_PACKET_TYPE_ABORT;
-		data = htonl(call->abort_code);
+		data = htonl(call->local_abort);
 		iov[1].iov_base = &data;
 		iov[1].iov_len = sizeof(data);
 		genbit = RXRPC_CALL_EV_ABORT;
@@ -968,7 +968,7 @@ void rxrpc_process_call(struct work_struct *work)
 		write_lock_bh(&call->state_lock);
 		if (call->state <= RXRPC_CALL_COMPLETE) {
 			call->state = RXRPC_CALL_LOCALLY_ABORTED;
-			call->abort_code = RX_CALL_TIMEOUT;
+			call->local_abort = RX_CALL_TIMEOUT;
 			set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		}
 		write_unlock_bh(&call->state_lock);
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 7c8d300ade9b..67a211f0ebba 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -682,7 +682,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	    call->state != RXRPC_CALL_CLIENT_FINAL_ACK) {
 		_debug("+++ ABORTING STATE %d +++\n", call->state);
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
-		call->abort_code = RX_CALL_DEAD;
+		call->local_abort = RX_CALL_DEAD;
 		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		rxrpc_queue_call(call);
 	}
@@ -758,7 +758,7 @@ static void rxrpc_mark_call_released(struct rxrpc_call *call)
 		if (call->state < RXRPC_CALL_COMPLETE) {
 			_debug("abort call %p", call);
 			call->state = RXRPC_CALL_LOCALLY_ABORTED;
-			call->abort_code = RX_CALL_DEAD;
+			call->local_abort = RX_CALL_DEAD;
 			if (!test_and_set_bit(RXRPC_CALL_EV_ABORT, &call->events))
 				sched = true;
 		}
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index 1bdaaed8cdc4..4dc6ab81fd2f 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -40,11 +40,13 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
 		write_lock(&call->state_lock);
 		if (call->state <= RXRPC_CALL_COMPLETE) {
 			call->state = state;
-			call->abort_code = abort_code;
-			if (state == RXRPC_CALL_LOCALLY_ABORTED)
+			if (state == RXRPC_CALL_LOCALLY_ABORTED) {
+				call->local_abort = conn->local_abort;
 				set_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events);
-			else
+			} else {
+				call->remote_abort = conn->remote_abort;
 				set_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
+			}
 			rxrpc_queue_call(call);
 		}
 		write_unlock(&call->state_lock);
@@ -101,7 +103,7 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 	whdr._rsvd	= 0;
 	whdr.serviceId	= htons(conn->service_id);
 
-	word = htonl(abort_code);
+	word		= htonl(conn->local_abort);
 
 	iov[0].iov_base	= &whdr;
 	iov[0].iov_len	= sizeof(whdr);
@@ -112,7 +114,7 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 
 	serial = atomic_inc_return(&conn->serial);
 	whdr.serial = htonl(serial);
-	_proto("Tx CONN ABORT %%%u { %d }", serial, abort_code);
+	_proto("Tx CONN ABORT %%%u { %d }", serial, conn->local_abort);
 
 	ret = kernel_sendmsg(conn->trans->local->socket, &msg, iov, 2, len);
 	if (ret < 0) {
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index f9d97fcb21ff..401ea55fb773 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -349,7 +349,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		write_lock_bh(&call->state_lock);
 		if (call->state < RXRPC_CALL_COMPLETE) {
 			call->state = RXRPC_CALL_REMOTELY_ABORTED;
-			call->abort_code = abort_code;
+			call->remote_abort = abort_code;
 			set_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
 			rxrpc_queue_call(call);
 		}
@@ -422,7 +422,7 @@ protocol_error:
 protocol_error_locked:
 	if (call->state <= RXRPC_CALL_COMPLETE) {
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
-		call->abort_code = RX_PROTOCOL_ERROR;
+		call->local_abort = RX_PROTOCOL_ERROR;
 		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		rxrpc_queue_call(call);
 	}
@@ -494,7 +494,7 @@ protocol_error:
 	write_lock_bh(&call->state_lock);
 	if (call->state <= RXRPC_CALL_COMPLETE) {
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
-		call->abort_code = RX_PROTOCOL_ERROR;
+		call->local_abort = RX_PROTOCOL_ERROR;
 		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		rxrpc_queue_call(call);
 	}
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index eeb829e837e1..258b74a2a23f 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -289,7 +289,9 @@ struct rxrpc_connection {
 		RXRPC_CONN_LOCALLY_ABORTED,	/* - conn aborted locally */
 		RXRPC_CONN_NETWORK_ERROR,	/* - conn terminated by network error */
 	} state;
-	int			error;		/* error code for local abort */
+	u32			local_abort;	/* local abort code */
+	u32			remote_abort;	/* remote abort code */
+	int			error;		/* local error incurred */
 	int			debug_id;	/* debug ID for printks */
 	unsigned int		call_counter;	/* call ID counter */
 	atomic_t		serial;		/* packet serial number counter */
@@ -399,7 +401,9 @@ struct rxrpc_call {
 	rwlock_t		state_lock;	/* lock for state transition */
 	atomic_t		usage;
 	atomic_t		sequence;	/* Tx data packet sequence counter */
-	u32			abort_code;	/* local/remote abort code */
+	u32			local_abort;	/* local abort code */
+	u32			remote_abort;	/* remote abort code */
+	int			error;		/* local error incurred */
 	enum rxrpc_call_state	state : 8;	/* current state of call */
 	int			debug_id;	/* debug ID for printks */
 	u8			channel;	/* connection channel occupied by this call */
@@ -453,7 +457,7 @@ static inline void rxrpc_abort_call(struct rxrpc_call *call, u32 abort_code)
 {
 	write_lock_bh(&call->state_lock);
 	if (call->state < RXRPC_CALL_COMPLETE) {
-		call->abort_code = abort_code;
+		call->local_abort = abort_code;
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 	}
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index d36fb6e1a29c..94e7d9537437 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -110,7 +110,7 @@ static void rxrpc_send_abort(struct rxrpc_call *call, u32 abort_code)
 
 	if (call->state <= RXRPC_CALL_COMPLETE) {
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
-		call->abort_code = abort_code;
+		call->local_abort = abort_code;
 		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		del_timer_sync(&call->resend_timer);
 		del_timer_sync(&call->ack_timer);
diff --git a/net/rxrpc/ar-proc.c b/net/rxrpc/ar-proc.c
index 525b2ba5a8f4..225163bc658d 100644
--- a/net/rxrpc/ar-proc.c
+++ b/net/rxrpc/ar-proc.c
@@ -80,7 +80,7 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 		   call->conn->in_clientflag ? "Svc" : "Clt",
 		   atomic_read(&call->usage),
 		   rxrpc_call_states[call->state],
-		   call->abort_code,
+		   call->remote_abort ?: call->local_abort,
 		   call->user_call_ID);
 
 	return 0;
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index 64facba24a45..160f0927aa3e 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -288,7 +288,11 @@ receive_non_data_message:
 		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_BUSY, 0, &abort_code);
 		break;
 	case RXRPC_SKB_MARK_REMOTE_ABORT:
-		abort_code = call->abort_code;
+		abort_code = call->remote_abort;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &abort_code);
+		break;
+	case RXRPC_SKB_MARK_LOCAL_ABORT:
+		abort_code = call->local_abort;
 		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &abort_code);
 		break;
 	case RXRPC_SKB_MARK_NET_ERROR:
@@ -303,6 +307,7 @@ receive_non_data_message:
 			       &abort_code);
 		break;
 	default:
+		pr_err("RxRPC: Unknown packet mark %u\n", skb->mark);
 		BUG();
 		break;
 	}
@@ -401,9 +406,14 @@ u32 rxrpc_kernel_get_abort_code(struct sk_buff *skb)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 
-	ASSERTCMP(skb->mark, ==, RXRPC_SKB_MARK_REMOTE_ABORT);
-
-	return sp->call->abort_code;
+	switch (skb->mark) {
+	case RXRPC_SKB_MARK_REMOTE_ABORT:
+		return sp->call->remote_abort;
+	case RXRPC_SKB_MARK_LOCAL_ABORT:
+		return sp->call->local_abort;
+	default:
+		BUG();
+	}
 }
 
 EXPORT_SYMBOL(rxrpc_kernel_get_abort_code);
