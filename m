From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 8/8] rxrpc: Calls shouldn't hold socket refs
Date: Wed, 07 Sep 2016 16:23:22 +0100
Message-ID: <147326180285.26593.7173855424186846008.stgit@warthog.procyon.org.uk>
References: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rxrpc calls shouldn't hold refs on the sock struct.  This was done so that
the socket wouldn't go away whilst the call was in progress, such that the
call could reach the socket's queues.

However, we can mark the socket as requiring an RCU release and rely on the
RCU read lock.

To make this work, we do:

 (1) rxrpc_release_call() removes the call's call user ID.  This is now
     only called from socket operations and not from the call processor:

	rxrpc_accept_call() / rxrpc_kernel_accept_call()
	rxrpc_reject_call() / rxrpc_kernel_reject_call()
	rxrpc_kernel_end_call()
	rxrpc_release_calls_on_socket()
	rxrpc_recvmsg()

     Though it is also called in the cleanup path of
     rxrpc_accept_incoming_call() before we assign a user ID.

 (2) Pass the socket pointer into rxrpc_release_call() rather than getting
     it from the call so that we can get rid of uninitialised calls.

 (3) Fix call processor queueing to pass a ref to the work queue and to
     release that ref at the end of the processor function (or to pass it
     back to the work queue if we have to requeue).

 (4) Skip out of the call processor function asap if the call is complete
     and don't requeue it if the call is complete.

 (5) Clean up the call immediately that the refcount reaches 0 rather than
     trying to defer it.  Actual deallocation is deferred to RCU, however.

 (6) Don't hold socket refs for allocated calls.

 (7) Use the RCU read lock when queueing a message on a socket and treat
     the call's socket pointer according to RCU rules and check it for
     NULL.

     We also need to use the RCU read lock when viewing a call through
     procfs.

 (8) Transmit the final ACK/ABORT to a client call in rxrpc_release_call()
     if this hasn't been done yet so that we can then disconnect the call.
     Once the call is disconnected, it won't have any access to the
     connection struct and the UDP socket for the call work processor to be
     able to send the ACK.  Terminal retransmission will be handled by the
     connection processor.

 (9) Release all calls immediately on the closing of a socket rather than
     trying to defer this.  Incomplete calls will be aborted.

The call refcount model is much simplified.  Refs are held on the call by:

 (1) A socket's user ID tree.

 (2) A socket's incoming call secureq and acceptq.

 (3) A kernel service that has a call in progress.

 (4) A queued call work processor.  We have to take care to put any call
     that we failed to queue.

 (5) sk_buffs on a socket's receive queue.  A future patch will get rid of
     this.

Whilst we're at it, we can do:

 (1) Get rid of the RXRPC_CALL_EV_RELEASE event.  Release is now done
     entirely from the socket routines and never from the call's processor.

 (2) Get rid of the RXRPC_CALL_DEAD state.  Calls now end in the
     RXRPC_CALL_COMPLETE state.

 (3) Get rid of the rxrpc_call::destroyer work item.  Calls are now torn
     down when their refcount reaches 0 and then handed over to RCU for
     final cleanup.

 (4) Get rid of the rxrpc_call::deadspan timer.  Calls are cleaned up
     immediately they're finished with and don't hang around.
     Post-completion retransmission is handled by the connection processor
     once the call is disconnected.

 (5) Get rid of the dead call expiry setting as there's no longer a timer
     to set.

 (6) rxrpc_destroy_all_calls() can just check that the call list is empty.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c    |    4 -
 net/rxrpc/ar-internal.h |   15 +--
 net/rxrpc/call_accept.c |   55 +++---------
 net/rxrpc/call_event.c  |   74 ++++++----------
 net/rxrpc/call_object.c |  224 ++++++++++++++++++-----------------------------
 net/rxrpc/input.c       |   26 +++--
 net/rxrpc/output.c      |  145 ++++++++++++++++++++++++++++++
 net/rxrpc/proc.c        |    4 +
 net/rxrpc/recvmsg.c     |   24 -----
 net/rxrpc/skbuff.c      |    3 -
 net/rxrpc/sysctl.c      |    8 --
 11 files changed, 303 insertions(+), 279 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 8356cd003d51..77a132abf140 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -294,8 +294,7 @@ EXPORT_SYMBOL(rxrpc_kernel_begin_call);
 void rxrpc_kernel_end_call(struct socket *sock, struct rxrpc_call *call)
 {
 	_enter("%d{%d}", call->debug_id, atomic_read(&call->usage));
-	rxrpc_remove_user_ID(rxrpc_sk(sock->sk), call);
-	rxrpc_purge_queue(&call->knlrecv_queue);
+	rxrpc_release_call(rxrpc_sk(sock->sk), call);
 	rxrpc_put_call(call, rxrpc_call_put);
 }
 EXPORT_SYMBOL(rxrpc_kernel_end_call);
@@ -558,6 +557,7 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 		return -ENOMEM;
 
 	sock_init_data(sock, sk);
+	sock_set_flag(sk, SOCK_RCU_FREE);
 	sk->sk_state		= RXRPC_UNBOUND;
 	sk->sk_write_space	= rxrpc_write_space;
 	sk->sk_max_ack_backlog	= 0;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index e3dfc9da05fe..3addda4bfa6b 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -35,8 +35,6 @@ struct rxrpc_crypt {
 #define rxrpc_queue_delayed_work(WS,D)	\
 	queue_delayed_work(rxrpc_workqueue, (WS), (D))
 
-#define rxrpc_queue_call(CALL)	rxrpc_queue_work(&(CALL)->processor)
-
 struct rxrpc_connection;
 
 /*
@@ -397,7 +395,6 @@ enum rxrpc_call_event {
 	RXRPC_CALL_EV_ACCEPTED,		/* incoming call accepted by userspace app */
 	RXRPC_CALL_EV_SECURED,		/* incoming call's connection is now secure */
 	RXRPC_CALL_EV_POST_ACCEPT,	/* need to post an "accept?" message to the app */
-	RXRPC_CALL_EV_RELEASE,		/* need to release the call's resources */
 };
 
 /*
@@ -417,7 +414,6 @@ enum rxrpc_call_state {
 	RXRPC_CALL_SERVER_SEND_REPLY,	/* - server sending reply */
 	RXRPC_CALL_SERVER_AWAIT_ACK,	/* - server awaiting final ACK */
 	RXRPC_CALL_COMPLETE,		/* - call complete */
-	RXRPC_CALL_DEAD,		/* - call is dead */
 	NR__RXRPC_CALL_STATES
 };
 
@@ -442,12 +438,10 @@ struct rxrpc_call {
 	struct rcu_head		rcu;
 	struct rxrpc_connection	*conn;		/* connection carrying call */
 	struct rxrpc_peer	*peer;		/* Peer record for remote address */
-	struct rxrpc_sock	*socket;	/* socket responsible */
+	struct rxrpc_sock __rcu	*socket;	/* socket responsible */
 	struct timer_list	lifetimer;	/* lifetime remaining on call */
-	struct timer_list	deadspan;	/* reap timer for re-ACK'ing, etc  */
 	struct timer_list	ack_timer;	/* ACK generation timer */
 	struct timer_list	resend_timer;	/* Tx resend timer */
-	struct work_struct	destroyer;	/* call destroyer */
 	struct work_struct	processor;	/* packet processor and ACK generator */
 	rxrpc_notify_rx_t	notify_rx;	/* kernel service Rx notification function */
 	struct list_head	link;		/* link in master call list */
@@ -558,7 +552,6 @@ void rxrpc_process_call(struct work_struct *);
 extern const char *const rxrpc_call_states[];
 extern const char *const rxrpc_call_completions[];
 extern unsigned int rxrpc_max_call_lifetime;
-extern unsigned int rxrpc_dead_call_expiry;
 extern struct kmem_cache *rxrpc_call_jar;
 extern struct list_head rxrpc_calls;
 extern rwlock_t rxrpc_call_lock;
@@ -571,8 +564,10 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
 struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
 				       struct rxrpc_connection *,
 				       struct sk_buff *);
-void rxrpc_release_call(struct rxrpc_call *);
+void rxrpc_release_call(struct rxrpc_sock *, struct rxrpc_call *);
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
+bool __rxrpc_queue_call(struct rxrpc_call *);
+bool rxrpc_queue_call(struct rxrpc_call *);
 void rxrpc_see_call(struct rxrpc_call *);
 void rxrpc_get_call(struct rxrpc_call *, enum rxrpc_call_trace);
 void rxrpc_put_call(struct rxrpc_call *, enum rxrpc_call_trace);
@@ -835,6 +830,7 @@ extern const char *rxrpc_acks(u8 reason);
 /*
  * output.c
  */
+int rxrpc_send_call_packet(struct rxrpc_call *, u8);
 int rxrpc_send_data_packet(struct rxrpc_connection *, struct sk_buff *);
 
 /*
@@ -880,7 +876,6 @@ extern const struct file_operations rxrpc_connection_seq_fops;
 /*
  * recvmsg.c
  */
-void rxrpc_remove_user_ID(struct rxrpc_sock *, struct rxrpc_call *);
 int rxrpc_recvmsg(struct socket *, struct msghdr *, size_t, int);
 
 /*
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 487ae7aa86db..879a964de80c 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -163,13 +163,7 @@ invalid_service:
 	_debug("invalid");
 	read_unlock_bh(&local->services_lock);
 
-	read_lock_bh(&call->state_lock);
-	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-	    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
-		rxrpc_get_call(call, rxrpc_call_got);
-		rxrpc_queue_call(call);
-	}
-	read_unlock_bh(&call->state_lock);
+	rxrpc_release_call(rx, call);
 	rxrpc_put_call(call, rxrpc_call_put);
 	ret = -ECONNREFUSED;
 error:
@@ -236,13 +230,11 @@ found_service:
 	if (sk_acceptq_is_full(&rx->sk))
 		goto backlog_full;
 	sk_acceptq_added(&rx->sk);
-	sock_hold(&rx->sk);
 	read_unlock_bh(&local->services_lock);
 
 	ret = rxrpc_accept_incoming_call(local, rx, skb, &srx);
 	if (ret < 0)
 		sk_acceptq_removed(&rx->sk);
-	sock_put(&rx->sk);
 	switch (ret) {
 	case -ECONNRESET: /* old calls are ignored */
 	case -ECONNABORTED: /* aborted calls are reaborted or ignored */
@@ -333,9 +325,6 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	case RXRPC_CALL_COMPLETE:
 		ret = call->error;
 		goto out_release;
-	case RXRPC_CALL_DEAD:
-		ret = -ETIME;
-		goto out_discard;
 	default:
 		BUG();
 	}
@@ -350,24 +339,20 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 		BUG();
 	if (test_and_set_bit(RXRPC_CALL_EV_ACCEPTED, &call->events))
 		BUG();
-	rxrpc_queue_call(call);
 
 	write_unlock_bh(&call->state_lock);
 	write_unlock(&rx->call_lock);
+	rxrpc_queue_call(call);
 	_leave(" = %p{%d}", call, call->debug_id);
 	return call;
 
-	/* if the call is already dying or dead, then we leave the socket's ref
-	 * on it to be released by rxrpc_dead_call_expired() as induced by
-	 * rxrpc_release_call() */
 out_release:
-	_debug("release %p", call);
-	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-	    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
-		rxrpc_queue_call(call);
-out_discard:
 	write_unlock_bh(&call->state_lock);
-	_debug("discard %p", call);
+	write_unlock(&rx->call_lock);
+	_debug("release %p", call);
+	rxrpc_release_call(rx, call);
+	_leave(" = %d", ret);
+	return ERR_PTR(ret);
 out:
 	write_unlock(&rx->call_lock);
 	_leave(" = %d", ret);
@@ -390,8 +375,11 @@ int rxrpc_reject_call(struct rxrpc_sock *rx)
 	write_lock(&rx->call_lock);
 
 	ret = -ENODATA;
-	if (list_empty(&rx->acceptq))
-		goto out;
+	if (list_empty(&rx->acceptq)) {
+		write_unlock(&rx->call_lock);
+		_leave(" = -ENODATA");
+		return -ENODATA;
+	}
 
 	/* dequeue the first call and check it's still valid */
 	call = list_entry(rx->acceptq.next, struct rxrpc_call, accept_link);
@@ -407,30 +395,17 @@ int rxrpc_reject_call(struct rxrpc_sock *rx)
 		if (test_and_set_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events))
 			rxrpc_queue_call(call);
 		ret = 0;
-		goto out_release;
+		break;
 	case RXRPC_CALL_COMPLETE:
 		ret = call->error;
-		goto out_release;
-	case RXRPC_CALL_DEAD:
-		ret = -ETIME;
-		goto out_discard;
+		break;
 	default:
 		BUG();
 	}
 
-	/* if the call is already dying or dead, then we leave the socket's ref
-	 * on it to be released by rxrpc_dead_call_expired() as induced by
-	 * rxrpc_release_call() */
-out_release:
-	_debug("release %p", call);
-	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-	    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
-		rxrpc_queue_call(call);
-out_discard:
 	write_unlock_bh(&call->state_lock);
-	_debug("discard %p", call);
-out:
 	write_unlock(&rx->call_lock);
+	rxrpc_release_call(rx, call);
 	_leave(" = %d", ret);
 	return ret;
 }
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index fee8b6ddb334..8365d3366114 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -811,8 +811,9 @@ static int rxrpc_post_message(struct rxrpc_call *call, u32 mark, u32 error,
 }
 
 /*
- * handle background processing of incoming call packets and ACK / abort
- * generation
+ * Handle background processing of incoming call packets and ACK / abort
+ * generation.  A ref on the call is donated to us by whoever queued the work
+ * item.
  */
 void rxrpc_process_call(struct work_struct *work)
 {
@@ -827,6 +828,7 @@ void rxrpc_process_call(struct work_struct *work)
 	unsigned long bits;
 	__be32 data, pad;
 	size_t len;
+	bool requeue = false;
 	int loop, nbit, ioc, ret, mtu;
 	u32 serial, abort_code = RX_PROTOCOL_ERROR;
 	u8 *acks = NULL;
@@ -838,6 +840,11 @@ void rxrpc_process_call(struct work_struct *work)
 	       call->debug_id, rxrpc_call_states[call->state], call->events,
 	       (jiffies - call->creation_jif) / (HZ / 10));
 
+	if (call->state >= RXRPC_CALL_COMPLETE) {
+		rxrpc_put_call(call, rxrpc_call_put);
+		return;
+	}
+
 	if (!call->conn)
 		goto skip_msg_init;
 
@@ -1088,16 +1095,21 @@ skip_msg_init:
 		spin_lock_bh(&call->lock);
 
 		if (call->state == RXRPC_CALL_SERVER_SECURING) {
+			struct rxrpc_sock *rx;
 			_debug("securing");
-			write_lock(&call->socket->call_lock);
-			if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-			    !test_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
-				_debug("not released");
-				call->state = RXRPC_CALL_SERVER_ACCEPTING;
-				list_move_tail(&call->accept_link,
-					       &call->socket->acceptq);
+			rcu_read_lock();
+			rx = rcu_dereference(call->socket);
+			if (rx) {
+				write_lock(&rx->call_lock);
+				if (!test_bit(RXRPC_CALL_RELEASED, &call->flags)) {
+					_debug("not released");
+					call->state = RXRPC_CALL_SERVER_ACCEPTING;
+					list_move_tail(&call->accept_link,
+						       &rx->acceptq);
+				}
+				write_unlock(&rx->call_lock);
 			}
-			write_unlock(&call->socket->call_lock);
+			rcu_read_unlock();
 			read_lock(&call->state_lock);
 			if (call->state < RXRPC_CALL_COMPLETE)
 				set_bit(RXRPC_CALL_EV_POST_ACCEPT, &call->events);
@@ -1139,11 +1151,6 @@ skip_msg_init:
 		goto maybe_reschedule;
 	}
 
-	if (test_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
-		rxrpc_release_call(call);
-		clear_bit(RXRPC_CALL_EV_RELEASE, &call->events);
-	}
-
 	/* other events may have been raised since we started checking */
 	goto maybe_reschedule;
 
@@ -1209,10 +1216,8 @@ send_message_2:
 			     &msg, iov, ioc, len);
 	if (ret < 0) {
 		_debug("sendmsg failed: %d", ret);
-		read_lock_bh(&call->state_lock);
-		if (call->state < RXRPC_CALL_DEAD)
-			rxrpc_queue_call(call);
-		read_unlock_bh(&call->state_lock);
+		if (call->state < RXRPC_CALL_COMPLETE)
+			requeue = true;
 		goto error;
 	}
 
@@ -1245,41 +1250,22 @@ send_message_2:
 
 kill_ACKs:
 	del_timer_sync(&call->ack_timer);
-	if (test_and_clear_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events))
-		rxrpc_put_call(call, rxrpc_call_put);
 	clear_bit(RXRPC_CALL_EV_ACK, &call->events);
 
 maybe_reschedule:
 	if (call->events || !skb_queue_empty(&call->rx_queue)) {
-		read_lock_bh(&call->state_lock);
-		if (call->state < RXRPC_CALL_DEAD)
-			rxrpc_queue_call(call);
-		read_unlock_bh(&call->state_lock);
-	}
-
-	/* don't leave aborted connections on the accept queue */
-	if (call->state >= RXRPC_CALL_COMPLETE &&
-	    !list_empty(&call->accept_link)) {
-		_debug("X unlinking once-pending call %p { e=%lx f=%lx c=%x }",
-		       call, call->events, call->flags, call->conn->proto.cid);
-
-		read_lock_bh(&call->state_lock);
-		if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-		    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
-			rxrpc_queue_call(call);
-		read_unlock_bh(&call->state_lock);
+		if (call->state < RXRPC_CALL_COMPLETE)
+			requeue = true;
 	}
 
 error:
 	kfree(acks);
 
-	/* because we don't want two CPUs both processing the work item for one
-	 * call at the same time, we use a flag to note when it's busy; however
-	 * this means there's a race between clearing the flag and setting the
-	 * work pending bit and the work item being processed again */
-	if (call->events && !work_pending(&call->processor)) {
+	if ((requeue || call->events) && !work_pending(&call->processor)) {
 		_debug("jumpstart %x", call->conn->proto.cid);
-		rxrpc_queue_call(call);
+		__rxrpc_queue_call(call);
+	} else {
+		rxrpc_put_call(call, rxrpc_call_put);
 	}
 
 	_leave("");
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 83019e489555..be5733d55794 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -24,11 +24,6 @@
  */
 unsigned int rxrpc_max_call_lifetime = 60 * HZ;
 
-/*
- * Time till dead call expires after last use (in jiffies).
- */
-unsigned int rxrpc_dead_call_expiry = 2 * HZ;
-
 const char *const rxrpc_call_states[NR__RXRPC_CALL_STATES] = {
 	[RXRPC_CALL_UNINITIALISED]		= "Uninit  ",
 	[RXRPC_CALL_CLIENT_AWAIT_CONN]		= "ClWtConn",
@@ -43,7 +38,6 @@ const char *const rxrpc_call_states[NR__RXRPC_CALL_STATES] = {
 	[RXRPC_CALL_SERVER_SEND_REPLY]		= "SvSndRpl",
 	[RXRPC_CALL_SERVER_AWAIT_ACK]		= "SvAwtACK",
 	[RXRPC_CALL_COMPLETE]			= "Complete",
-	[RXRPC_CALL_DEAD]			= "Dead    ",
 };
 
 const char *const rxrpc_call_completions[NR__RXRPC_CALL_COMPLETIONS] = {
@@ -74,11 +68,10 @@ struct kmem_cache *rxrpc_call_jar;
 LIST_HEAD(rxrpc_calls);
 DEFINE_RWLOCK(rxrpc_call_lock);
 
-static void rxrpc_destroy_call(struct work_struct *work);
 static void rxrpc_call_life_expired(unsigned long _call);
-static void rxrpc_dead_call_expired(unsigned long _call);
 static void rxrpc_ack_time_expired(unsigned long _call);
 static void rxrpc_resend_time_expired(unsigned long _call);
+static void rxrpc_cleanup_call(struct rxrpc_call *call);
 
 /*
  * find an extant server call
@@ -138,13 +131,10 @@ static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 
 	setup_timer(&call->lifetimer, &rxrpc_call_life_expired,
 		    (unsigned long) call);
-	setup_timer(&call->deadspan, &rxrpc_dead_call_expired,
-		    (unsigned long) call);
 	setup_timer(&call->ack_timer, &rxrpc_ack_time_expired,
 		    (unsigned long) call);
 	setup_timer(&call->resend_timer, &rxrpc_resend_time_expired,
 		    (unsigned long) call);
-	INIT_WORK(&call->destroyer, &rxrpc_destroy_call);
 	INIT_WORK(&call->processor, &rxrpc_process_call);
 	INIT_LIST_HEAD(&call->link);
 	INIT_LIST_HEAD(&call->chan_wait_link);
@@ -185,11 +175,9 @@ static struct rxrpc_call *rxrpc_alloc_client_call(struct rxrpc_sock *rx,
 	if (!call)
 		return ERR_PTR(-ENOMEM);
 	call->state = RXRPC_CALL_CLIENT_AWAIT_CONN;
-
-	sock_hold(&rx->sk);
-	call->socket = rx;
 	call->rx_data_post = 1;
 	call->service_id = srx->srx_service;
+	rcu_assign_pointer(call->socket, rx);
 
 	_leave(" = %p", call);
 	return call;
@@ -244,8 +232,9 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 		return call;
 	}
 
-	trace_rxrpc_call(call, 0, atomic_read(&call->usage), 0, here,
-			 (const void *)user_call_ID);
+	trace_rxrpc_call(call, rxrpc_call_new_client,
+			 atomic_read(&call->usage), 0,
+			 here, (const void *)user_call_ID);
 
 	/* Publish the call, even though it is incompletely set up as yet */
 	call->user_call_ID = user_call_ID;
@@ -295,8 +284,10 @@ error:
 	list_del_init(&call->link);
 	write_unlock_bh(&rxrpc_call_lock);
 
+error_out:
+	__rxrpc_set_call_completion(call, RXRPC_CALL_LOCAL_ERROR,
+				    RX_CALL_DEAD, ret);
 	set_bit(RXRPC_CALL_RELEASED, &call->flags);
-	call->state = RXRPC_CALL_DEAD;
 	rxrpc_put_call(call, rxrpc_call_put);
 	_leave(" = %d", ret);
 	return ERR_PTR(ret);
@@ -308,11 +299,8 @@ error:
 	 */
 found_user_ID_now_present:
 	write_unlock(&rx->call_lock);
-	set_bit(RXRPC_CALL_RELEASED, &call->flags);
-	call->state = RXRPC_CALL_DEAD;
-	rxrpc_put_call(call, rxrpc_call_put);
-	_leave(" = -EEXIST [%p]", call);
-	return ERR_PTR(-EEXIST);
+	ret = -EEXIST;
+	goto error_out;
 }
 
 /*
@@ -340,7 +328,6 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 			 atomic_read(&candidate->usage), 0, here, NULL);
 
 	chan = sp->hdr.cid & RXRPC_CHANNELMASK;
-	candidate->socket	= rx;
 	candidate->conn		= conn;
 	candidate->peer		= conn->params.peer;
 	candidate->cid		= sp->hdr.cid;
@@ -351,6 +338,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	candidate->flags	|= (1 << RXRPC_CALL_IS_SERVICE);
 	if (conn->security_ix > 0)
 		candidate->state = RXRPC_CALL_SERVER_SECURING;
+	rcu_assign_pointer(candidate->socket, rx);
 
 	spin_lock(&conn->channel_lock);
 
@@ -411,7 +399,6 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	candidate = NULL;
 	conn->channels[chan].call_counter = call_id;
 	rcu_assign_pointer(conn->channels[chan].call, call);
-	sock_hold(&rx->sk);
 	rxrpc_get_connection(conn);
 	rxrpc_get_peer(call->peer);
 	spin_unlock(&conn->channel_lock);
@@ -453,6 +440,39 @@ old_call:
 }
 
 /*
+ * Queue a call's work processor, getting a ref to pass to the work queue.
+ */
+bool rxrpc_queue_call(struct rxrpc_call *call)
+{
+	const void *here = __builtin_return_address(0);
+	int n = __atomic_add_unless(&call->usage, 1, 0);
+	int m = atomic_read(&call->skb_count);
+	if (n == 0)
+		return false;
+	if (rxrpc_queue_work(&call->processor))
+		trace_rxrpc_call(call, rxrpc_call_queued, n + 1, m, here, NULL);
+	else
+		rxrpc_put_call(call, rxrpc_call_put_noqueue);
+	return true;
+}
+
+/*
+ * Queue a call's work processor, passing the callers ref to the work queue.
+ */
+bool __rxrpc_queue_call(struct rxrpc_call *call)
+{
+	const void *here = __builtin_return_address(0);
+	int n = atomic_read(&call->usage);
+	int m = atomic_read(&call->skb_count);
+	ASSERTCMP(n, >=, 1);
+	if (rxrpc_queue_work(&call->processor))
+		trace_rxrpc_call(call, rxrpc_call_queued_ref, n, m, here, NULL);
+	else
+		rxrpc_put_call(call, rxrpc_call_put_noqueue);
+	return true;
+}
+
+/*
  * Note the re-emergence of a call.
  */
 void rxrpc_see_call(struct rxrpc_call *call)
@@ -493,11 +513,8 @@ void rxrpc_get_call_for_skb(struct rxrpc_call *call, struct sk_buff *skb)
 /*
  * detach a call from a socket and set up for release
  */
-void rxrpc_release_call(struct rxrpc_call *call)
+void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
 {
-	struct rxrpc_connection *conn = call->conn;
-	struct rxrpc_sock *rx = call->socket;
-
 	_enter("{%d,%d,%d,%d}",
 	       call->debug_id, atomic_read(&call->usage),
 	       atomic_read(&call->ackr_not_idle),
@@ -513,7 +530,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	/* dissociate from the socket
 	 * - the socket's ref on the call is passed to the death timer
 	 */
-	_debug("RELEASE CALL %p (%d CONN %p)", call, call->debug_id, conn);
+	_debug("RELEASE CALL %p (%d)", call, call->debug_id);
 
 	if (call->peer) {
 		spin_lock(&call->peer->lock);
@@ -532,20 +549,30 @@ void rxrpc_release_call(struct rxrpc_call *call)
 		rb_erase(&call->sock_node, &rx->calls);
 		memset(&call->sock_node, 0xdd, sizeof(call->sock_node));
 		clear_bit(RXRPC_CALL_HAS_USERID, &call->flags);
+		rxrpc_put_call(call, rxrpc_call_put_userid);
 	}
 	write_unlock_bh(&rx->call_lock);
 
 	/* free up the channel for reuse */
-	write_lock_bh(&call->state_lock);
+	if (call->state == RXRPC_CALL_CLIENT_FINAL_ACK) {
+		clear_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
+		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+		rxrpc_call_completed(call);
+	} else {
+		write_lock_bh(&call->state_lock);
+
+		if (call->state < RXRPC_CALL_COMPLETE) {
+			_debug("+++ ABORTING STATE %d +++\n", call->state);
+			__rxrpc_abort_call(call, RX_CALL_DEAD, ECONNRESET);
+			clear_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
+			rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+		}
 
-	if (call->state < RXRPC_CALL_COMPLETE &&
-	    call->state != RXRPC_CALL_CLIENT_FINAL_ACK) {
-		_debug("+++ ABORTING STATE %d +++\n", call->state);
-		__rxrpc_abort_call(call, RX_CALL_DEAD, ECONNRESET);
+		write_unlock_bh(&call->state_lock);
 	}
-	write_unlock_bh(&call->state_lock);
 
-	rxrpc_disconnect_call(call);
+	if (call->conn)
+		rxrpc_disconnect_call(call);
 
 	/* clean up the Rx queue */
 	if (!skb_queue_empty(&call->rx_queue) ||
@@ -569,53 +596,16 @@ void rxrpc_release_call(struct rxrpc_call *call)
 		}
 		spin_unlock_bh(&call->lock);
 	}
+	rxrpc_purge_queue(&call->knlrecv_queue);
 
 	del_timer_sync(&call->resend_timer);
 	del_timer_sync(&call->ack_timer);
 	del_timer_sync(&call->lifetimer);
-	call->deadspan.expires = jiffies + rxrpc_dead_call_expiry;
-	add_timer(&call->deadspan);
 
 	_leave("");
 }
 
 /*
- * handle a dead call being ready for reaping
- */
-static void rxrpc_dead_call_expired(unsigned long _call)
-{
-	struct rxrpc_call *call = (struct rxrpc_call *) _call;
-
-	_enter("{%d}", call->debug_id);
-
-	rxrpc_see_call(call);
-	write_lock_bh(&call->state_lock);
-	call->state = RXRPC_CALL_DEAD;
-	write_unlock_bh(&call->state_lock);
-	rxrpc_put_call(call, rxrpc_call_put);
-}
-
-/*
- * mark a call as to be released, aborting it if it's still in progress
- * - called with softirqs disabled
- */
-static void rxrpc_mark_call_released(struct rxrpc_call *call)
-{
-	bool sched = false;
-
-	rxrpc_see_call(call);
-	write_lock(&call->state_lock);
-	if (call->state < RXRPC_CALL_DEAD) {
-		sched = __rxrpc_abort_call(call, RX_CALL_DEAD, ECONNRESET);
-		if (!test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
-			sched = true;
-	}
-	write_unlock(&call->state_lock);
-	if (sched)
-		rxrpc_queue_call(call);
-}
-
-/*
  * release all the calls associated with a socket
  */
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
@@ -629,17 +619,17 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 
 	/* kill the not-yet-accepted incoming calls */
 	list_for_each_entry(call, &rx->secureq, accept_link) {
-		rxrpc_mark_call_released(call);
+		rxrpc_release_call(rx, call);
 	}
 
 	list_for_each_entry(call, &rx->acceptq, accept_link) {
-		rxrpc_mark_call_released(call);
+		rxrpc_release_call(rx, call);
 	}
 
 	/* mark all the calls as no longer wanting incoming packets */
 	for (p = rb_first(&rx->calls); p; p = rb_next(p)) {
 		call = rb_entry(p, struct rxrpc_call, sock_node);
-		rxrpc_mark_call_released(call);
+		rxrpc_release_call(rx, call);
 	}
 
 	read_unlock_bh(&rx->call_lock);
@@ -663,8 +653,7 @@ void rxrpc_put_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
 	if (n == 0) {
 		_debug("call %d dead", call->debug_id);
 		WARN_ON(m != 0);
-		ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
-		rxrpc_queue_work(&call->destroyer);
+		rxrpc_cleanup_call(call);
 	}
 }
 
@@ -683,8 +672,7 @@ void rxrpc_put_call_for_skb(struct rxrpc_call *call, struct sk_buff *skb)
 	if (n == 0) {
 		_debug("call %d dead", call->debug_id);
 		WARN_ON(m != 0);
-		ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
-		rxrpc_queue_work(&call->destroyer);
+		rxrpc_cleanup_call(call);
 	}
 }
 
@@ -708,23 +696,19 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 {
 	_net("DESTROY CALL %d", call->debug_id);
 
-	ASSERT(call->socket);
+	write_lock_bh(&rxrpc_call_lock);
+	list_del_init(&call->link);
+	write_unlock_bh(&rxrpc_call_lock);
 
 	memset(&call->sock_node, 0xcd, sizeof(call->sock_node));
 
 	del_timer_sync(&call->lifetimer);
-	del_timer_sync(&call->deadspan);
 	del_timer_sync(&call->ack_timer);
 	del_timer_sync(&call->resend_timer);
 
+	ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
 	ASSERT(test_bit(RXRPC_CALL_RELEASED, &call->flags));
-	ASSERTCMP(call->events, ==, 0);
-	if (work_pending(&call->processor)) {
-		_debug("defer destroy");
-		rxrpc_queue_work(&call->destroyer);
-		return;
-	}
-
+	ASSERT(!work_pending(&call->processor));
 	ASSERTCMP(call->conn, ==, NULL);
 
 	if (call->acks_window) {
@@ -753,40 +737,21 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 	rxrpc_purge_queue(&call->rx_queue);
 	ASSERT(skb_queue_empty(&call->rx_oos_queue));
 	rxrpc_purge_queue(&call->knlrecv_queue);
-	sock_put(&call->socket->sk);
 	call_rcu(&call->rcu, rxrpc_rcu_destroy_call);
 }
 
 /*
- * destroy a call
- */
-static void rxrpc_destroy_call(struct work_struct *work)
-{
-	struct rxrpc_call *call =
-		container_of(work, struct rxrpc_call, destroyer);
-
-	_enter("%p{%d,%x,%p}",
-	       call, atomic_read(&call->usage), call->cid, call->conn);
-
-	ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
-
-	write_lock_bh(&rxrpc_call_lock);
-	list_del_init(&call->link);
-	write_unlock_bh(&rxrpc_call_lock);
-
-	rxrpc_cleanup_call(call);
-	_leave("");
-}
-
-/*
- * preemptively destroy all the call records from a transport endpoint rather
- * than waiting for them to time out
+ * Make sure that all calls are gone.
  */
 void __exit rxrpc_destroy_all_calls(void)
 {
 	struct rxrpc_call *call;
 
 	_enter("");
+
+	if (list_empty(&rxrpc_calls))
+		return;
+	
 	write_lock_bh(&rxrpc_call_lock);
 
 	while (!list_empty(&rxrpc_calls)) {
@@ -796,28 +761,15 @@ void __exit rxrpc_destroy_all_calls(void)
 		rxrpc_see_call(call);
 		list_del_init(&call->link);
 
-		switch (atomic_read(&call->usage)) {
-		case 0:
-			ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
-			break;
-		case 1:
-			if (del_timer_sync(&call->deadspan) != 0 &&
-			    call->state != RXRPC_CALL_DEAD)
-				rxrpc_dead_call_expired((unsigned long) call);
-			if (call->state != RXRPC_CALL_DEAD)
-				break;
-		default:
-			pr_err("Call %p still in use (%d,%d,%s,%lx,%lx)!\n",
-			       call, atomic_read(&call->usage),
-			       atomic_read(&call->ackr_not_idle),
-			       rxrpc_call_states[call->state],
-			       call->flags, call->events);
-			if (!skb_queue_empty(&call->rx_queue))
-				pr_err("Rx queue occupied\n");
-			if (!skb_queue_empty(&call->rx_oos_queue))
-				pr_err("OOS queue occupied\n");
-			break;
-		}
+		pr_err("Call %p still in use (%d,%d,%s,%lx,%lx)!\n",
+		       call, atomic_read(&call->usage),
+		       atomic_read(&call->ackr_not_idle),
+		       rxrpc_call_states[call->state],
+		       call->flags, call->events);
+		if (!skb_queue_empty(&call->rx_queue))
+			pr_err("Rx queue occupied\n");
+		if (!skb_queue_empty(&call->rx_oos_queue))
+			pr_err("OOS queue occupied\n");
 
 		write_unlock_bh(&rxrpc_call_lock);
 		cond_resched();
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 8267f42a7753..79f3f585cdc3 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -39,7 +39,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 			bool force, bool terminal)
 {
 	struct rxrpc_skb_priv *sp;
-	struct rxrpc_sock *rx = call->socket;
+	struct rxrpc_sock *rx;
 	struct sock *sk;
 	int ret;
 
@@ -59,7 +59,15 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 		return 0;
 	}
 
+	/* The socket may go away under us */
+	ret = 0;
+	rcu_read_lock();
+	rx = rcu_dereference(call->socket);
+	if (!rx)
+		goto out;
 	sk = &rx->sk;
+	if (sock_flag(sk, SOCK_DEAD))
+		goto out;
 
 	if (!force) {
 		/* cast skb->rcvbuf to unsigned...  It's pointless, but
@@ -78,7 +86,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (!test_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags) &&
 	    !test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-	    call->socket->sk.sk_state != RXRPC_CLOSE) {
+	    sk->sk_state != RXRPC_CLOSE) {
 		skb->destructor = rxrpc_packet_destructor;
 		skb->dev = NULL;
 		skb->sk = sk;
@@ -104,8 +112,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 			__skb_queue_tail(&sk->sk_receive_queue, skb);
 			spin_unlock_bh(&sk->sk_receive_queue.lock);
 
-			if (!sock_flag(sk, SOCK_DEAD))
-				sk->sk_data_ready(sk);
+			sk->sk_data_ready(sk);
 		}
 		skb = NULL;
 	} else {
@@ -115,6 +122,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 
 out:
 	rxrpc_free_skb(skb);
+	rcu_read_unlock();
 
 	_leave(" = %d", ret);
 	return ret;
@@ -266,7 +274,7 @@ enqueue_packet:
 	skb_queue_tail(&call->rx_queue, skb);
 	atomic_inc(&call->ackr_not_idle);
 	read_lock(&call->state_lock);
-	if (call->state < RXRPC_CALL_DEAD)
+	if (call->state < RXRPC_CALL_COMPLETE)
 		rxrpc_queue_call(call);
 	read_unlock(&call->state_lock);
 	_leave(" = 0 [queued]");
@@ -408,7 +416,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	case RXRPC_PACKET_TYPE_ACK:
 		/* ACK processing is done in process context */
 		read_lock_bh(&call->state_lock);
-		if (call->state < RXRPC_CALL_DEAD) {
+		if (call->state < RXRPC_CALL_COMPLETE) {
 			skb_queue_tail(&call->rx_queue, skb);
 			rxrpc_queue_call(call);
 			skb = NULL;
@@ -511,9 +519,6 @@ static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
 
 	read_lock(&call->state_lock);
 	switch (call->state) {
-	case RXRPC_CALL_DEAD:
-		goto dead_call;
-
 	case RXRPC_CALL_COMPLETE:
 		switch (call->completion) {
 		case RXRPC_CALL_LOCALLY_ABORTED:
@@ -538,7 +543,6 @@ static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
 	}
 
 	read_unlock(&call->state_lock);
-	rxrpc_get_call(call, rxrpc_call_got);
 
 	if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA &&
 	    sp->hdr.flags & RXRPC_JUMBO_PACKET)
@@ -546,12 +550,10 @@ static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
 	else
 		rxrpc_fast_process_packet(call, skb);
 
-	rxrpc_put_call(call, rxrpc_call_put);
 	goto done;
 
 resend_final_ack:
 	_debug("final ack again");
-	rxrpc_get_call(call, rxrpc_call_got);
 	set_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
 	rxrpc_queue_call(call);
 	goto free_unlock;
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 5b5508f6fc2a..8756d74fd74b 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -19,6 +19,151 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
+struct rxrpc_pkt_buffer {
+	struct rxrpc_wire_header whdr;
+	union {
+		struct {
+			struct rxrpc_ackpacket ack;
+			u8 acks[255];
+			u8 pad[3];
+		};
+		__be32 abort_code;
+	};
+	struct rxrpc_ackinfo ackinfo;
+};
+
+/*
+ * Fill out an ACK packet.
+ */
+static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
+				 struct rxrpc_pkt_buffer *pkt)
+{
+	u32 mtu, jmax;
+	u8 *ackp = pkt->acks;
+
+	pkt->ack.bufferSpace	= htons(8);
+	pkt->ack.maxSkew	= htons(0);
+	pkt->ack.firstPacket	= htonl(call->rx_data_eaten + 1);
+	pkt->ack.previousPacket	= htonl(call->ackr_prev_seq);
+	pkt->ack.serial		= htonl(call->ackr_serial);
+	pkt->ack.reason		= RXRPC_ACK_IDLE;
+	pkt->ack.nAcks		= 0;
+
+	mtu = call->peer->if_mtu;
+	mtu -= call->peer->hdrsize;
+	jmax = rxrpc_rx_jumbo_max;
+	pkt->ackinfo.rxMTU	= htonl(rxrpc_rx_mtu);
+	pkt->ackinfo.maxMTU	= htonl(mtu);
+	pkt->ackinfo.rwind	= htonl(rxrpc_rx_window_size);
+	pkt->ackinfo.jumbo_max	= htonl(jmax);
+
+	*ackp++ = 0;
+	*ackp++ = 0;
+	*ackp++ = 0;
+	return 3;
+}
+
+/*
+ * Send a final ACK or ABORT call packet.
+ */
+int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
+{
+	struct rxrpc_connection *conn = NULL;
+	struct rxrpc_pkt_buffer *pkt;
+	struct msghdr msg;
+	struct kvec iov[2];
+	rxrpc_serial_t serial;
+	size_t len, n;
+	int ioc, ret;
+	u32 abort_code;
+
+	_enter("%u,%s", call->debug_id, rxrpc_pkts[type]);
+
+	spin_lock_bh(&call->lock);
+	if (call->conn)
+		conn = rxrpc_get_connection_maybe(call->conn);
+	spin_unlock_bh(&call->lock);
+	if (!conn)
+		return -ECONNRESET;
+
+	pkt = kzalloc(sizeof(*pkt), GFP_KERNEL);
+	if (!pkt) {
+		rxrpc_put_connection(conn);
+		return -ENOMEM;
+	}
+
+	serial = atomic_inc_return(&conn->serial);
+
+	msg.msg_name	= &call->peer->srx.transport;
+	msg.msg_namelen	= call->peer->srx.transport_len;
+	msg.msg_control	= NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags	= 0;
+
+	pkt->whdr.epoch		= htonl(conn->proto.epoch);
+	pkt->whdr.cid		= htonl(call->cid);
+	pkt->whdr.callNumber	= htonl(call->call_id);
+	pkt->whdr.seq		= 0;
+	pkt->whdr.serial	= htonl(serial);
+	pkt->whdr.type		= type;
+	pkt->whdr.flags		= conn->out_clientflag;
+	pkt->whdr.userStatus	= 0;
+	pkt->whdr.securityIndex	= call->security_ix;
+	pkt->whdr._rsvd		= 0;
+	pkt->whdr.serviceId	= htons(call->service_id);
+
+	iov[0].iov_base	= pkt;
+	iov[0].iov_len	= sizeof(pkt->whdr);
+	len = sizeof(pkt->whdr);
+
+	switch (type) {
+	case RXRPC_PACKET_TYPE_ACK:
+		spin_lock_bh(&call->lock);
+		n = rxrpc_fill_out_ack(call, pkt);
+		call->ackr_reason = 0;
+
+		spin_unlock_bh(&call->lock);
+
+		_proto("Tx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
+		       serial,
+		       ntohs(pkt->ack.maxSkew),
+		       ntohl(pkt->ack.firstPacket),
+		       ntohl(pkt->ack.previousPacket),
+		       ntohl(pkt->ack.serial),
+		       rxrpc_acks(pkt->ack.reason),
+		       pkt->ack.nAcks);
+
+		iov[0].iov_len += sizeof(pkt->ack) + n;
+		iov[1].iov_base = &pkt->ackinfo;
+		iov[1].iov_len	= sizeof(pkt->ackinfo);
+		len += sizeof(pkt->ack) + n + sizeof(pkt->ackinfo);
+		ioc = 2;
+		break;
+
+	case RXRPC_PACKET_TYPE_ABORT:
+		abort_code = call->abort_code;
+		pkt->abort_code = htonl(abort_code);
+		_proto("Tx ABORT %%%u { %d }", serial, abort_code);
+		iov[0].iov_len += sizeof(pkt->abort_code);
+		len += sizeof(pkt->abort_code);
+		ioc = 1;
+		break;
+
+	default:
+		BUG();
+		ret = -ENOANO;
+		goto out;
+	}
+
+	ret = kernel_sendmsg(conn->params.local->socket,
+			     &msg, iov, ioc, len);
+
+out:
+	rxrpc_put_connection(conn);
+	kfree(pkt);
+	return ret;
+}
+
 /*
  * send a packet through the transport endpoint
  */
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index 82c64055449d..dfad23821a62 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -29,6 +29,7 @@ static const char *const rxrpc_conn_states[RXRPC_CONN__NR_STATES] = {
  */
 static void *rxrpc_call_seq_start(struct seq_file *seq, loff_t *_pos)
 {
+	rcu_read_lock();
 	read_lock(&rxrpc_call_lock);
 	return seq_list_start_head(&rxrpc_calls, *_pos);
 }
@@ -41,6 +42,7 @@ static void *rxrpc_call_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 static void rxrpc_call_seq_stop(struct seq_file *seq, void *v)
 {
 	read_unlock(&rxrpc_call_lock);
+	rcu_read_unlock();
 }
 
 static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
@@ -61,7 +63,7 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 
 	call = list_entry(v, struct rxrpc_call, link);
 
-	rx = READ_ONCE(call->socket);
+	rx = rcu_dereference(call->socket);
 	if (rx) {
 		local = READ_ONCE(rx->local);
 		if (local)
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 97f8ee76c67c..6876ffb3b410 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -19,28 +19,6 @@
 #include "ar-internal.h"
 
 /*
- * removal a call's user ID from the socket tree to make the user ID available
- * again and so that it won't be seen again in association with that call
- */
-void rxrpc_remove_user_ID(struct rxrpc_sock *rx, struct rxrpc_call *call)
-{
-	_debug("RELEASE CALL %d", call->debug_id);
-
-	if (test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
-		write_lock_bh(&rx->call_lock);
-		rb_erase(&call->sock_node, &call->socket->calls);
-		clear_bit(RXRPC_CALL_HAS_USERID, &call->flags);
-		write_unlock_bh(&rx->call_lock);
-	}
-
-	read_lock_bh(&call->state_lock);
-	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-	    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
-		rxrpc_queue_call(call);
-	read_unlock_bh(&call->state_lock);
-}
-
-/*
  * receive a message from an RxRPC socket
  * - we need to be careful about two or more threads calling recvmsg
  *   simultaneously
@@ -338,7 +316,7 @@ terminal_message:
 		if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
 			BUG();
 		rxrpc_free_skb(skb);
-		rxrpc_remove_user_ID(rx, call);
+		rxrpc_release_call(rx, call);
 	}
 
 	release_sock(&rx->sk);
diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index c0613ab6d2d5..9b8f8456d3bf 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -33,9 +33,6 @@ static void rxrpc_request_final_ACK(struct rxrpc_call *call)
 		call->state = RXRPC_CALL_CLIENT_FINAL_ACK;
 		_debug("request final ACK");
 
-		/* get an extra ref on the call for the final-ACK generator to
-		 * release */
-		rxrpc_get_call(call, rxrpc_call_got);
 		set_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
 		if (try_to_del_timer_sync(&call->ack_timer) >= 0)
 			rxrpc_queue_call(call);
diff --git a/net/rxrpc/sysctl.c b/net/rxrpc/sysctl.c
index dc380af8a81e..b7ca8cf13c84 100644
--- a/net/rxrpc/sysctl.c
+++ b/net/rxrpc/sysctl.c
@@ -88,14 +88,6 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 		.extra1		= (void *)&one,
 	},
-	{
-		.procname	= "dead_call_expiry",
-		.data		= &rxrpc_dead_call_expiry,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-		.extra1		= (void *)&one,
-	},
 
 	/* Non-time values */
 	{
