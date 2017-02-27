From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] rxrpc: Fix deadlock between call creation and
 sendmsg/recvmsg
Date: Mon, 27 Feb 2017 15:43:06 +0000
Message-ID: <148821018671.8207.5142446588523098523.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All the routines by which rxrpc is accessed from the outside are serialised
by means of the socket lock (sendmsg, recvmsg, bind,
rxrpc_kernel_begin_call(), ...) and this presents a problem:

 (1) If a number of calls on the same socket are in the process of
     connection to the same peer, a maximum of four concurrent live calls
     are permitted before further calls need to wait for a slot.

 (2) If a call is waiting for a slot, it is deep inside sendmsg() or
     rxrpc_kernel_begin_call() and the entry function is holding the socket
     lock.

 (3) sendmsg() and recvmsg() or the in-kernel equivalents are prevented
     from servicing the other calls as they need to take the socket lock to
     do so.

 (4) The socket is stuck until a call is aborted and makes its slot
     available to the waiter.

Fix this by:

 (1) Provide each call with a mutex ('user_mutex') that arbitrates access
     by the users of rxrpc separately for each specific call.

 (2) Make rxrpc_sendmsg() and rxrpc_recvmsg() unlock the socket as soon as
     they've got a call and taken its mutex.

     Note that I'm returning EWOULDBLOCK from recvmsg() if MSG_DONTWAIT is
     set but someone else has the lock.  Should I instead only return
     EWOULDBLOCK if there's nothing currently to be done on a socket, and
     sleep in this particular instance because there is something to be
     done, but we appear to be blocked by the interrupt handler doing its
     ping?

 (3) Make rxrpc_new_client_call() unlock the socket after allocating a new
     call, locking its user mutex and adding it to the socket's call tree.
     The call is returned locked so that sendmsg() can add data to it
     immediately.

     From the moment the call is in the socket tree, it is subject to
     access by sendmsg() and recvmsg() - even if it isn't connected yet.

 (4) Lock new service calls in the UDP data_ready handler (in
     rxrpc_new_incoming_call()) because they may already be in the socket's
     tree and the data_ready handler makes them live immediately if a user
     ID has already been preassigned.

     Note that the new call is locked before any notifications are sent
     that it is live, so doing mutex_trylock() *ought* to always succeed.
     Userspace is prevented from doing sendmsg() on calls that are in a
     too-early state in rxrpc_do_sendmsg().

 (5) Make rxrpc_new_incoming_call() return the call with the user mutex
     held so that a ping can be scheduled immediately under it.

     Note that it might be worth moving the ping call into
     rxrpc_new_incoming_call() and then we can drop the mutex there.

 (6) Make rxrpc_accept_call() take the lock on the call it is accepting and
     release the socket after adding the call to the socket's tree.  This
     is slightly tricky as we've dequeued the call by that point and have
     to requeue it.

     Note that requeuing emits a trace event.

 (7) Make rxrpc_kernel_send_data() and rxrpc_kernel_recv_data() take the
     new mutex immediately and don't bother with the socket mutex at all.

This patch has the nice bonus that calls on the same socket are now to some
extent parallelisable.


Note that we might want to move rxrpc_service_prealloc() calls out from the
socket lock and give it its own lock, so that we don't hang progress in
other calls because we're waiting for the allocator.

We probably also want to avoid calling rxrpc_notify_socket() from within
the socket lock (rxrpc_accept_call()).

Signed-off-by: David Howells <dhowells@redhat.com>
Tested-by: Marc Dionne <marc.c.dionne@auristor.com>
---

 include/trace/events/rxrpc.h |    2 +
 net/rxrpc/af_rxrpc.c         |   12 +++++++--
 net/rxrpc/ar-internal.h      |    1 +
 net/rxrpc/call_accept.c      |   48 +++++++++++++++++++++++++++++++++++
 net/rxrpc/call_object.c      |   18 ++++++++++++-
 net/rxrpc/input.c            |    1 +
 net/rxrpc/recvmsg.c          |   39 ++++++++++++++++++++++++-----
 net/rxrpc/sendmsg.c          |   57 ++++++++++++++++++++++++++++++++++--------
 8 files changed, 156 insertions(+), 22 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 593f586545eb..39123c06a566 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -119,6 +119,7 @@ enum rxrpc_recvmsg_trace {
 	rxrpc_recvmsg_full,
 	rxrpc_recvmsg_hole,
 	rxrpc_recvmsg_next,
+	rxrpc_recvmsg_requeue,
 	rxrpc_recvmsg_return,
 	rxrpc_recvmsg_terminal,
 	rxrpc_recvmsg_to_be_accepted,
@@ -277,6 +278,7 @@ enum rxrpc_congest_change {
 	EM(rxrpc_recvmsg_full,			"FULL") \
 	EM(rxrpc_recvmsg_hole,			"HOLE") \
 	EM(rxrpc_recvmsg_next,			"NEXT") \
+	EM(rxrpc_recvmsg_requeue,		"REQU") \
 	EM(rxrpc_recvmsg_return,		"RETN") \
 	EM(rxrpc_recvmsg_terminal,		"TERM") \
 	EM(rxrpc_recvmsg_to_be_accepted,	"TBAC") \
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 199b46e93e64..7fb59c3f1542 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -290,10 +290,11 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 	cp.exclusive		= false;
 	cp.service_id		= srx->srx_service;
 	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, gfp);
+	/* The socket has been unlocked. */
 	if (!IS_ERR(call))
 		call->notify_rx = notify_rx;
 
-	release_sock(&rx->sk);
+	mutex_unlock(&call->user_mutex);
 	_leave(" = %p", call);
 	return call;
 }
@@ -310,7 +311,10 @@ EXPORT_SYMBOL(rxrpc_kernel_begin_call);
 void rxrpc_kernel_end_call(struct socket *sock, struct rxrpc_call *call)
 {
 	_enter("%d{%d}", call->debug_id, atomic_read(&call->usage));
+
+	mutex_lock(&call->user_mutex);
 	rxrpc_release_call(rxrpc_sk(sock->sk), call);
+	mutex_unlock(&call->user_mutex);
 	rxrpc_put_call(call, rxrpc_call_put_kernel);
 }
 EXPORT_SYMBOL(rxrpc_kernel_end_call);
@@ -450,14 +454,16 @@ static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 	case RXRPC_SERVER_BOUND:
 	case RXRPC_SERVER_LISTENING:
 		ret = rxrpc_do_sendmsg(rx, m, len);
-		break;
+		/* The socket has been unlocked */
+		goto out;
 	default:
 		ret = -EINVAL;
-		break;
+		goto error_unlock;
 	}
 
 error_unlock:
 	release_sock(&rx->sk);
+out:
 	_leave(" = %d", ret);
 	return ret;
 }
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 12be432be9b2..26a7b1db1361 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -467,6 +467,7 @@ struct rxrpc_call {
 	struct rxrpc_connection	*conn;		/* connection carrying call */
 	struct rxrpc_peer	*peer;		/* Peer record for remote address */
 	struct rxrpc_sock __rcu	*socket;	/* socket responsible */
+	struct mutex		user_mutex;	/* User access mutex */
 	ktime_t			ack_at;		/* When deferred ACK needs to happen */
 	ktime_t			resend_at;	/* When next resend needs to happen */
 	ktime_t			ping_at;	/* When next to send a ping */
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 7c4c64ab8da2..0ed181f53f32 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -323,6 +323,8 @@ static struct rxrpc_call *rxrpc_alloc_incoming_call(struct rxrpc_sock *rx,
  *
  * If we want to report an error, we mark the skb with the packet type and
  * abort code and return NULL.
+ *
+ * The call is returned with the user access mutex held.
  */
 struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *local,
 					   struct rxrpc_connection *conn,
@@ -371,6 +373,18 @@ struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *local,
 	trace_rxrpc_receive(call, rxrpc_receive_incoming,
 			    sp->hdr.serial, sp->hdr.seq);
 
+	/* Lock the call to prevent rxrpc_kernel_send/recv_data() and
+	 * sendmsg()/recvmsg() inconveniently stealing the mutex once the
+	 * notification is generated.
+	 *
+	 * The BUG should never happen because the kernel should be well
+	 * behaved enough not to access the call before the first notification
+	 * event and userspace is prevented from doing so until the state is
+	 * appropriate.
+	 */
+	if (!mutex_trylock(&call->user_mutex))
+		BUG();
+
 	/* Make the call live. */
 	rxrpc_incoming_call(rx, call, skb);
 	conn = call->conn;
@@ -429,10 +443,12 @@ struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *local,
 /*
  * handle acceptance of a call by userspace
  * - assign the user call ID to the call at the front of the queue
+ * - called with the socket locked.
  */
 struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 				     unsigned long user_call_ID,
 				     rxrpc_notify_rx_t notify_rx)
+	__releases(&rx->sk.sk_lock.slock)
 {
 	struct rxrpc_call *call;
 	struct rb_node *parent, **pp;
@@ -446,6 +462,7 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 
 	if (list_empty(&rx->to_be_accepted)) {
 		write_unlock(&rx->call_lock);
+		release_sock(&rx->sk);
 		kleave(" = -ENODATA [empty]");
 		return ERR_PTR(-ENODATA);
 	}
@@ -470,10 +487,39 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	 */
 	call = list_entry(rx->to_be_accepted.next,
 			  struct rxrpc_call, accept_link);
+	write_unlock(&rx->call_lock);
+
+	/* We need to gain the mutex from the interrupt handler without
+	 * upsetting lockdep, so we have to release it there and take it here.
+	 * We are, however, still holding the socket lock, so other accepts
+	 * must wait for us and no one can add the user ID behind our backs.
+	 */
+	if (mutex_lock_interruptible(&call->user_mutex) < 0) {
+		release_sock(&rx->sk);
+		kleave(" = -ERESTARTSYS");
+		return ERR_PTR(-ERESTARTSYS);
+	}
+
+	write_lock(&rx->call_lock);
 	list_del_init(&call->accept_link);
 	sk_acceptq_removed(&rx->sk);
 	rxrpc_see_call(call);
 
+	/* Find the user ID insertion point. */
+	pp = &rx->calls.rb_node;
+	parent = NULL;
+	while (*pp) {
+		parent = *pp;
+		call = rb_entry(parent, struct rxrpc_call, sock_node);
+
+		if (user_call_ID < call->user_call_ID)
+			pp = &(*pp)->rb_left;
+		else if (user_call_ID > call->user_call_ID)
+			pp = &(*pp)->rb_right;
+		else
+			BUG();
+	}
+
 	write_lock_bh(&call->state_lock);
 	switch (call->state) {
 	case RXRPC_CALL_SERVER_ACCEPTING:
@@ -499,6 +545,7 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	write_unlock(&rx->call_lock);
 	rxrpc_notify_socket(call);
 	rxrpc_service_prealloc(rx, GFP_KERNEL);
+	release_sock(&rx->sk);
 	_leave(" = %p{%d}", call, call->debug_id);
 	return call;
 
@@ -515,6 +562,7 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	write_unlock(&rx->call_lock);
 out:
 	rxrpc_service_prealloc(rx, GFP_KERNEL);
+	release_sock(&rx->sk);
 	_leave(" = %d", ret);
 	return ERR_PTR(ret);
 }
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 8b94db3c9b2e..d79cd36987a9 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -115,6 +115,7 @@ struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 	if (!call->rxtx_annotations)
 		goto nomem_2;
 
+	mutex_init(&call->user_mutex);
 	setup_timer(&call->timer, rxrpc_call_timer_expired,
 		    (unsigned long)call);
 	INIT_WORK(&call->processor, &rxrpc_process_call);
@@ -194,14 +195,16 @@ static void rxrpc_start_call_timer(struct rxrpc_call *call)
 }
 
 /*
- * set up a call for the given data
- * - called in process context with IRQs enabled
+ * Set up a call for the given parameters.
+ * - Called with the socket lock held, which it must release.
+ * - If it returns a call, the call's lock will need releasing by the caller.
  */
 struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 					 struct rxrpc_conn_parameters *cp,
 					 struct sockaddr_rxrpc *srx,
 					 unsigned long user_call_ID,
 					 gfp_t gfp)
+	__releases(&rx->sk.sk_lock.slock)
 {
 	struct rxrpc_call *call, *xcall;
 	struct rb_node *parent, **pp;
@@ -212,6 +215,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 
 	call = rxrpc_alloc_client_call(srx, gfp);
 	if (IS_ERR(call)) {
+		release_sock(&rx->sk);
 		_leave(" = %ld", PTR_ERR(call));
 		return call;
 	}
@@ -219,6 +223,11 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	trace_rxrpc_call(call, rxrpc_call_new_client, atomic_read(&call->usage),
 			 here, (const void *)user_call_ID);
 
+	/* We need to protect a partially set up call against the user as we
+	 * will be acting outside the socket lock.
+	 */
+	mutex_lock(&call->user_mutex);
+
 	/* Publish the call, even though it is incompletely set up as yet */
 	write_lock(&rx->call_lock);
 
@@ -250,6 +259,9 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	list_add_tail(&call->link, &rxrpc_calls);
 	write_unlock(&rxrpc_call_lock);
 
+	/* From this point on, the call is protected by its own lock. */
+	release_sock(&rx->sk);
+
 	/* Set up or get a connection record and set the protocol parameters,
 	 * including channel number and call ID.
 	 */
@@ -279,6 +291,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	 */
 error_dup_user_ID:
 	write_unlock(&rx->call_lock);
+	release_sock(&rx->sk);
 	ret = -EEXIST;
 
 error:
@@ -287,6 +300,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	trace_rxrpc_call(call, rxrpc_call_error, atomic_read(&call->usage),
 			 here, ERR_PTR(ret));
 	rxrpc_release_call(rx, call);
+	mutex_unlock(&call->user_mutex);
 	rxrpc_put_call(call, rxrpc_call_put);
 	_leave(" = %d", ret);
 	return ERR_PTR(ret);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 78ec33477adf..9f4cfa25af7c 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -1194,6 +1194,7 @@ void rxrpc_data_ready(struct sock *udp_sk)
 			goto reject_packet;
 		}
 		rxrpc_send_ping(call, skb, skew);
+		mutex_unlock(&call->user_mutex);
 	}
 
 	rxrpc_input_call_packet(call, skb, skew);
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index f3a688e10843..22447dbcc380 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -487,6 +487,20 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 
 	trace_rxrpc_recvmsg(call, rxrpc_recvmsg_dequeue, 0, 0, 0, 0);
 
+	/* We're going to drop the socket lock, so we need to lock the call
+	 * against interference by sendmsg.
+	 */
+	if (!mutex_trylock(&call->user_mutex)) {
+		ret = -EWOULDBLOCK;
+		if (flags & MSG_DONTWAIT)
+			goto error_requeue_call;
+		ret = -ERESTARTSYS;
+		if (mutex_lock_interruptible(&call->user_mutex) < 0)
+			goto error_requeue_call;
+	}
+
+	release_sock(&rx->sk);
+
 	if (test_bit(RXRPC_CALL_RELEASED, &call->flags))
 		BUG();
 
@@ -502,7 +516,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 				       &call->user_call_ID);
 		}
 		if (ret < 0)
-			goto error;
+			goto error_unlock_call;
 	}
 
 	if (msg->msg_name) {
@@ -533,12 +547,12 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	}
 
 	if (ret < 0)
-		goto error;
+		goto error_unlock_call;
 
 	if (call->state == RXRPC_CALL_COMPLETE) {
 		ret = rxrpc_recvmsg_term(call, msg);
 		if (ret < 0)
-			goto error;
+			goto error_unlock_call;
 		if (!(flags & MSG_PEEK))
 			rxrpc_release_call(rx, call);
 		msg->msg_flags |= MSG_EOR;
@@ -551,8 +565,21 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		msg->msg_flags &= ~MSG_MORE;
 	ret = copied;
 
-error:
+error_unlock_call:
+	mutex_unlock(&call->user_mutex);
 	rxrpc_put_call(call, rxrpc_call_put);
+	trace_rxrpc_recvmsg(call, rxrpc_recvmsg_return, 0, 0, 0, ret);
+	return ret;
+
+error_requeue_call:
+	if (!(flags & MSG_PEEK)) {
+		write_lock_bh(&rx->recvmsg_lock);
+		list_add(&call->recvmsg_link, &rx->recvmsg_q);
+		write_unlock_bh(&rx->recvmsg_lock);
+		trace_rxrpc_recvmsg(call, rxrpc_recvmsg_requeue, 0, 0, 0, 0);
+	} else {
+		rxrpc_put_call(call, rxrpc_call_put);
+	}
 error_no_call:
 	release_sock(&rx->sk);
 	trace_rxrpc_recvmsg(call, rxrpc_recvmsg_return, 0, 0, 0, ret);
@@ -609,7 +636,7 @@ int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
 	iov.iov_len = size - *_offset;
 	iov_iter_kvec(&iter, ITER_KVEC | READ, &iov, 1, size - *_offset);
 
-	lock_sock(sock->sk);
+	mutex_lock(&call->user_mutex);
 
 	switch (call->state) {
 	case RXRPC_CALL_CLIENT_RECV_REPLY:
@@ -648,7 +675,7 @@ int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
 read_phase_complete:
 	ret = 1;
 out:
-	release_sock(sock->sk);
+	mutex_unlock(&call->user_mutex);
 	_leave(" = %d [%zu,%d]", ret, *_offset, *_abort);
 	return ret;
 
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 0a6ef217aa8a..31c1538c1a8d 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -59,9 +59,12 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 		}
 
 		trace_rxrpc_transmit(call, rxrpc_transmit_wait);
-		release_sock(&rx->sk);
+		mutex_unlock(&call->user_mutex);
 		*timeo = schedule_timeout(*timeo);
-		lock_sock(&rx->sk);
+		if (mutex_lock_interruptible(&call->user_mutex) < 0) {
+			ret = sock_intr_errno(*timeo);
+			break;
+		}
 	}
 
 	remove_wait_queue(&call->waitq, &myself);
@@ -171,7 +174,7 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 /*
  * send data through a socket
  * - must be called in process context
- * - caller holds the socket locked
+ * - The caller holds the call user access mutex, but not the socket lock.
  */
 static int rxrpc_send_data(struct rxrpc_sock *rx,
 			   struct rxrpc_call *call,
@@ -437,10 +440,13 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 
 /*
  * Create a new client call for sendmsg().
+ * - Called with the socket lock held, which it must release.
+ * - If it returns a call, the call's lock will need releasing by the caller.
  */
 static struct rxrpc_call *
 rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 				  unsigned long user_call_ID, bool exclusive)
+	__releases(&rx->sk.sk_lock.slock)
 {
 	struct rxrpc_conn_parameters cp;
 	struct rxrpc_call *call;
@@ -450,8 +456,10 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 
 	_enter("");
 
-	if (!msg->msg_name)
+	if (!msg->msg_name) {
+		release_sock(&rx->sk);
 		return ERR_PTR(-EDESTADDRREQ);
+	}
 
 	key = rx->key;
 	if (key && !rx->key->payload.data[0])
@@ -464,6 +472,7 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 	cp.exclusive		= rx->exclusive | exclusive;
 	cp.service_id		= srx->srx_service;
 	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, GFP_KERNEL);
+	/* The socket is now unlocked */
 
 	_leave(" = %p\n", call);
 	return call;
@@ -475,6 +484,7 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
  * - the socket may be either a client socket or a server socket
  */
 int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
+	__releases(&rx->sk.sk_lock.slock)
 {
 	enum rxrpc_command cmd;
 	struct rxrpc_call *call;
@@ -488,12 +498,14 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	ret = rxrpc_sendmsg_cmsg(msg, &user_call_ID, &cmd, &abort_code,
 				 &exclusive);
 	if (ret < 0)
-		return ret;
+		goto error_release_sock;
 
 	if (cmd == RXRPC_CMD_ACCEPT) {
+		ret = -EINVAL;
 		if (rx->sk.sk_state != RXRPC_SERVER_LISTENING)
-			return -EINVAL;
+			goto error_release_sock;
 		call = rxrpc_accept_call(rx, user_call_ID, NULL);
+		/* The socket is now unlocked. */
 		if (IS_ERR(call))
 			return PTR_ERR(call);
 		rxrpc_put_call(call, rxrpc_call_put);
@@ -502,12 +514,29 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 
 	call = rxrpc_find_call_by_user_ID(rx, user_call_ID);
 	if (!call) {
+		ret = -EBADSLT;
 		if (cmd != RXRPC_CMD_SEND_DATA)
-			return -EBADSLT;
+			goto error_release_sock;
+		ret = -EBUSY;
+		if (call->state == RXRPC_CALL_UNINITIALISED ||
+		    call->state == RXRPC_CALL_CLIENT_AWAIT_CONN ||
+		    call->state == RXRPC_CALL_SERVER_PREALLOC ||
+		    call->state == RXRPC_CALL_SERVER_SECURING ||
+		    call->state == RXRPC_CALL_SERVER_ACCEPTING)
+			goto error_release_sock;
 		call = rxrpc_new_client_call_for_sendmsg(rx, msg, user_call_ID,
 							 exclusive);
+		/* The socket is now unlocked... */
 		if (IS_ERR(call))
 			return PTR_ERR(call);
+		/* ... and we have the call lock. */
+	} else {
+		ret = mutex_lock_interruptible(&call->user_mutex);
+		release_sock(&rx->sk);
+		if (ret < 0) {
+			ret = -ERESTARTSYS;
+			goto error_put;
+		}
 	}
 
 	_debug("CALL %d USR %lx ST %d on CONN %p",
@@ -535,9 +564,15 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		ret = rxrpc_send_data(rx, call, msg, len);
 	}
 
+	mutex_unlock(&call->user_mutex);
+error_put:
 	rxrpc_put_call(call, rxrpc_call_put);
 	_leave(" = %d", ret);
 	return ret;
+
+error_release_sock:
+	release_sock(&rx->sk);
+	return ret;
 }
 
 /**
@@ -562,7 +597,7 @@ int rxrpc_kernel_send_data(struct socket *sock, struct rxrpc_call *call,
 	ASSERTCMP(msg->msg_name, ==, NULL);
 	ASSERTCMP(msg->msg_control, ==, NULL);
 
-	lock_sock(sock->sk);
+	mutex_lock(&call->user_mutex);
 
 	_debug("CALL %d USR %lx ST %d on CONN %p",
 	       call->debug_id, call->user_call_ID, call->state, call->conn);
@@ -577,7 +612,7 @@ int rxrpc_kernel_send_data(struct socket *sock, struct rxrpc_call *call,
 		ret = rxrpc_send_data(rxrpc_sk(sock->sk), call, msg, len);
 	}
 
-	release_sock(sock->sk);
+	mutex_unlock(&call->user_mutex);
 	_leave(" = %d", ret);
 	return ret;
 }
@@ -598,12 +633,12 @@ void rxrpc_kernel_abort_call(struct socket *sock, struct rxrpc_call *call,
 {
 	_enter("{%d},%d,%d,%s", call->debug_id, abort_code, error, why);
 
-	lock_sock(sock->sk);
+	mutex_lock(&call->user_mutex);
 
 	if (rxrpc_abort_call(why, call, 0, abort_code, error))
 		rxrpc_send_abort_packet(call);
 
-	release_sock(sock->sk);
+	mutex_unlock(&call->user_mutex);
 	_leave("");
 }
 
