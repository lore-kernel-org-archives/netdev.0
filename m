From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/7] rxrpc: Preallocate peers,
 conns and calls for incoming service requests
Date: Thu, 08 Sep 2016 12:44:11 +0100
Message-ID: <147333505128.5646.9881054784581360027.stgit@warthog.procyon.org.uk>
References: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make it possible for the data_ready handler called from the UDP transport
socket to completely instantiate an rxrpc_call structure and make it
immediately live by preallocating all the memory it might need.  The idea
is to cut out the background thread usage as much as possible.

[Note that the preallocated structs are not actually used in this patch -
 that will be done in a future patch.]

If insufficient resources are available in the preallocation buffers, it
will be possible to discard the DATA packet in the data_ready handler or
schedule a BUSY packet without the need to schedule an attempt at
allocation in a background thread.

To this end:

 (1) Preallocate rxrpc_peer, rxrpc_connection and rxrpc_call structs to a
     maximum number each of the listen backlog size.  The backlog size is
     limited to a maxmimum of 32.  Only this many of each can be in the
     preallocation buffer.

 (2) For userspace sockets, the preallocation is charged initially by
     listen() and will be recharged by accepting or rejecting pending
     new incoming calls.

 (3) For kernel services {,re,dis}charging of the preallocation buffers is
     handled manually.  Two notifier callbacks have to be provided before
     kernel_listen() is invoked:

     (a) An indication that a new call has been instantiated.  This can be
     	 used to trigger background recharging.

     (b) An indication that a call is being discarded.  This is used when
     	 the socket is being released.

     A function, rxrpc_kernel_charge_accept() is called by the kernel
     service to preallocate a single call.  It should be passed the user ID
     to be used for that call and a callback to associate the rxrpc call
     with the kernel service's side of the ID.

 (4) Discard the preallocation when the socket is closed.

 (5) Temporarily bump the refcount on the call allocated in
     rxrpc_incoming_call() so that rxrpc_release_call() can ditch the
     preallocation ref on service calls unconditionally.  This will no
     longer be necessary once the preallocation is used.

Note that this does not yet control the number of active service calls on a
client - that will come in a later patch.

A future development would be to provide a setsockopt() call that allows a
userspace server to manually charge the preallocation buffer.  This would
allow user call IDs to be provided in advance and the awkward manual accept
stage to be bypassed.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/rxrpc.c           |   71 ++++++++++++++
 include/net/af_rxrpc.h   |   10 ++
 net/rxrpc/af_rxrpc.c     |   16 ++-
 net/rxrpc/ar-internal.h  |   32 ++++++
 net/rxrpc/call_accept.c  |  229 ++++++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/call_object.c  |   12 ++
 net/rxrpc/conn_object.c  |    2 
 net/rxrpc/conn_service.c |   24 +++++
 net/rxrpc/input.c        |    2 
 net/rxrpc/proc.c         |    8 +-
 10 files changed, 391 insertions(+), 15 deletions(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 53750dece80e..720ef05a24fe 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -18,6 +18,7 @@
 
 struct socket *afs_socket; /* my RxRPC socket */
 static struct workqueue_struct *afs_async_calls;
+static struct afs_call *afs_spare_incoming_call;
 static atomic_t afs_outstanding_calls;
 
 static void afs_free_call(struct afs_call *);
@@ -26,7 +27,8 @@ static int afs_wait_for_call_to_complete(struct afs_call *);
 static void afs_wake_up_async_call(struct sock *, struct rxrpc_call *, unsigned long);
 static int afs_dont_wait_for_call_to_complete(struct afs_call *);
 static void afs_process_async_call(struct work_struct *);
-static void afs_rx_new_call(struct sock *);
+static void afs_rx_new_call(struct sock *, struct rxrpc_call *, unsigned long);
+static void afs_rx_discard_new_call(struct rxrpc_call *, unsigned long);
 static int afs_deliver_cm_op_id(struct afs_call *);
 
 /* synchronous call management */
@@ -54,8 +56,10 @@ static const struct afs_call_type afs_RXCMxxxx = {
 };
 
 static void afs_collect_incoming_call(struct work_struct *);
+static void afs_charge_preallocation(struct work_struct *);
 
 static DECLARE_WORK(afs_collect_incoming_call_work, afs_collect_incoming_call);
+static DECLARE_WORK(afs_charge_preallocation_work, afs_charge_preallocation);
 
 static int afs_wait_atomic_t(atomic_t *p)
 {
@@ -100,13 +104,15 @@ int afs_open_socket(void)
 	if (ret < 0)
 		goto error_2;
 
-	rxrpc_kernel_new_call_notification(socket, afs_rx_new_call);
+	rxrpc_kernel_new_call_notification(socket, afs_rx_new_call,
+					   afs_rx_discard_new_call);
 
 	ret = kernel_listen(socket, INT_MAX);
 	if (ret < 0)
 		goto error_2;
 
 	afs_socket = socket;
+	afs_charge_preallocation(NULL);
 	_leave(" = 0");
 	return 0;
 
@@ -126,6 +132,12 @@ void afs_close_socket(void)
 {
 	_enter("");
 
+	if (afs_spare_incoming_call) {
+		atomic_inc(&afs_outstanding_calls);
+		afs_free_call(afs_spare_incoming_call);
+		afs_spare_incoming_call = NULL;
+	}
+
 	_debug("outstanding %u", atomic_read(&afs_outstanding_calls));
 	wait_on_atomic_t(&afs_outstanding_calls, afs_wait_atomic_t,
 			 TASK_UNINTERRUPTIBLE);
@@ -635,12 +647,65 @@ static void afs_collect_incoming_call(struct work_struct *work)
 		afs_free_call(call);
 }
 
+static void afs_rx_attach(struct rxrpc_call *rxcall, unsigned long user_call_ID)
+{
+	struct afs_call *call = (struct afs_call *)user_call_ID;
+
+	call->rxcall = rxcall;
+}
+
+/*
+ * Charge the incoming call preallocation.
+ */
+static void afs_charge_preallocation(struct work_struct *work)
+{
+	struct afs_call *call = afs_spare_incoming_call;
+
+	for (;;) {
+		if (!call) {
+			call = kzalloc(sizeof(struct afs_call), GFP_KERNEL);
+			if (!call)
+				break;
+
+			INIT_WORK(&call->async_work, afs_process_async_call);
+			call->wait_mode = &afs_async_incoming_call;
+			call->type = &afs_RXCMxxxx;
+			init_waitqueue_head(&call->waitq);
+			call->state = AFS_CALL_AWAIT_OP_ID;
+		}
+
+		if (rxrpc_kernel_charge_accept(afs_socket,
+					       afs_wake_up_async_call,
+					       afs_rx_attach,
+					       (unsigned long)call,
+					       GFP_KERNEL) < 0)
+			break;
+		call = NULL;
+	}
+	afs_spare_incoming_call = call;
+}
+
+/*
+ * Discard a preallocated call when a socket is shut down.
+ */
+static void afs_rx_discard_new_call(struct rxrpc_call *rxcall,
+				    unsigned long user_call_ID)
+{
+	struct afs_call *call = (struct afs_call *)user_call_ID;
+
+	atomic_inc(&afs_outstanding_calls);
+	call->rxcall = NULL;
+	afs_free_call(call);
+}
+
 /*
  * Notification of an incoming call.
  */
-static void afs_rx_new_call(struct sock *sk)
+static void afs_rx_new_call(struct sock *sk, struct rxrpc_call *rxcall,
+			    unsigned long user_call_ID)
 {
 	queue_work(afs_wq, &afs_collect_incoming_call_work);
+	queue_work(afs_wq, &afs_charge_preallocation_work);
 }
 
 /*
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index 08ed8729126c..9cf551be916b 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -21,10 +21,14 @@ struct rxrpc_call;
 
 typedef void (*rxrpc_notify_rx_t)(struct sock *, struct rxrpc_call *,
 				  unsigned long);
-typedef void (*rxrpc_notify_new_call_t)(struct sock *);
+typedef void (*rxrpc_notify_new_call_t)(struct sock *, struct rxrpc_call *,
+					unsigned long);
+typedef void (*rxrpc_discard_new_call_t)(struct rxrpc_call *, unsigned long);
+typedef void (*rxrpc_user_attach_call_t)(struct rxrpc_call *, unsigned long);
 
 void rxrpc_kernel_new_call_notification(struct socket *,
-					rxrpc_notify_new_call_t);
+					rxrpc_notify_new_call_t,
+					rxrpc_discard_new_call_t);
 struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *,
 					   struct sockaddr_rxrpc *,
 					   struct key *,
@@ -43,5 +47,7 @@ struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *, unsigned long,
 int rxrpc_kernel_reject_call(struct socket *);
 void rxrpc_kernel_get_peer(struct socket *, struct rxrpc_call *,
 			   struct sockaddr_rxrpc *);
+int rxrpc_kernel_charge_accept(struct socket *, rxrpc_notify_rx_t,
+			       rxrpc_user_attach_call_t, unsigned long, gfp_t);
 
 #endif /* _NET_RXRPC_H */
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index f13cca1e973e..1e8cf3ded81f 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -193,7 +193,7 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 {
 	struct sock *sk = sock->sk;
 	struct rxrpc_sock *rx = rxrpc_sk(sk);
-	unsigned int max;
+	unsigned int max, old;
 	int ret;
 
 	_enter("%p,%d", rx, backlog);
@@ -212,9 +212,13 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 			backlog = max;
 		else if (backlog < 0 || backlog > max)
 			break;
+		old = sk->sk_max_ack_backlog;
 		sk->sk_max_ack_backlog = backlog;
-		rx->sk.sk_state = RXRPC_SERVER_LISTENING;
-		ret = 0;
+		ret = rxrpc_service_prealloc(rx, GFP_KERNEL);
+		if (ret == 0)
+			rx->sk.sk_state = RXRPC_SERVER_LISTENING;
+		else
+			sk->sk_max_ack_backlog = old;
 		break;
 	default:
 		ret = -EBUSY;
@@ -303,16 +307,19 @@ EXPORT_SYMBOL(rxrpc_kernel_end_call);
  * rxrpc_kernel_new_call_notification - Get notifications of new calls
  * @sock: The socket to intercept received messages on
  * @notify_new_call: Function to be called when new calls appear
+ * @discard_new_call: Function to discard preallocated calls
  *
  * Allow a kernel service to be given notifications about new calls.
  */
 void rxrpc_kernel_new_call_notification(
 	struct socket *sock,
-	rxrpc_notify_new_call_t notify_new_call)
+	rxrpc_notify_new_call_t notify_new_call,
+	rxrpc_discard_new_call_t discard_new_call)
 {
 	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
 
 	rx->notify_new_call = notify_new_call;
+	rx->discard_new_call = discard_new_call;
 }
 EXPORT_SYMBOL(rxrpc_kernel_new_call_notification);
 
@@ -622,6 +629,7 @@ static int rxrpc_release_sock(struct sock *sk)
 	}
 
 	/* try to flush out this socket */
+	rxrpc_discard_prealloc(rx);
 	rxrpc_release_calls_on_socket(rx);
 	flush_workqueue(rxrpc_workqueue);
 	rxrpc_purge_queue(&sk->sk_receive_queue);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 027791261768..45e1c269f90e 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -64,19 +64,42 @@ enum {
 };
 
 /*
+ * Service backlog preallocation.
+ *
+ * This contains circular buffers of preallocated peers, connections and calls
+ * for incoming service calls and their head and tail pointers.  This allows
+ * calls to be set up in the data_ready handler, thereby avoiding the need to
+ * shuffle packets around so much.
+ */
+struct rxrpc_backlog {
+	unsigned short		peer_backlog_head;
+	unsigned short		peer_backlog_tail;
+	unsigned short		conn_backlog_head;
+	unsigned short		conn_backlog_tail;
+	unsigned short		call_backlog_head;
+	unsigned short		call_backlog_tail;
+#define RXRPC_BACKLOG_MAX	32
+	struct rxrpc_peer	*peer_backlog[RXRPC_BACKLOG_MAX];
+	struct rxrpc_connection	*conn_backlog[RXRPC_BACKLOG_MAX];
+	struct rxrpc_call	*call_backlog[RXRPC_BACKLOG_MAX];
+};
+
+/*
  * RxRPC socket definition
  */
 struct rxrpc_sock {
 	/* WARNING: sk has to be the first member */
 	struct sock		sk;
 	rxrpc_notify_new_call_t	notify_new_call; /* Func to notify of new call */
+	rxrpc_discard_new_call_t discard_new_call; /* Func to discard a new call */
 	struct rxrpc_local	*local;		/* local endpoint */
 	struct hlist_node	listen_link;	/* link in the local endpoint's listen list */
 	struct list_head	secureq;	/* calls awaiting connection security clearance */
 	struct list_head	acceptq;	/* calls awaiting acceptance */
+	struct rxrpc_backlog	*backlog;	/* Preallocation for services */
 	struct key		*key;		/* security for this socket */
 	struct key		*securities;	/* list of server security descriptors */
-	struct rb_root		calls;		/* outstanding calls on this socket */
+	struct rb_root		calls;		/* User ID -> call mapping */
 	unsigned long		flags;
 #define RXRPC_SOCK_CONNECTED		0	/* connect_srx is set */
 	rwlock_t		call_lock;	/* lock for calls */
@@ -290,6 +313,7 @@ enum rxrpc_conn_cache_state {
 enum rxrpc_conn_proto_state {
 	RXRPC_CONN_UNUSED,		/* Connection not yet attempted */
 	RXRPC_CONN_CLIENT,		/* Client connection */
+	RXRPC_CONN_SERVICE_PREALLOC,	/* Service connection preallocation */
 	RXRPC_CONN_SERVICE_UNSECURED,	/* Service unsecured connection */
 	RXRPC_CONN_SERVICE_CHALLENGING,	/* Service challenging for security */
 	RXRPC_CONN_SERVICE,		/* Service secured connection */
@@ -408,6 +432,7 @@ enum rxrpc_call_state {
 	RXRPC_CALL_CLIENT_AWAIT_REPLY,	/* - client awaiting reply */
 	RXRPC_CALL_CLIENT_RECV_REPLY,	/* - client receiving reply phase */
 	RXRPC_CALL_CLIENT_FINAL_ACK,	/* - client sending final ACK phase */
+	RXRPC_CALL_SERVER_PREALLOC,	/* - service preallocation */
 	RXRPC_CALL_SERVER_SECURING,	/* - server securing request connection */
 	RXRPC_CALL_SERVER_ACCEPTING,	/* - server accepting request */
 	RXRPC_CALL_SERVER_RECV_REQUEST,	/* - server receiving request */
@@ -534,6 +559,8 @@ extern struct workqueue_struct *rxrpc_workqueue;
 /*
  * call_accept.c
  */
+int rxrpc_service_prealloc(struct rxrpc_sock *, gfp_t);
+void rxrpc_discard_prealloc(struct rxrpc_sock *);
 void rxrpc_accept_incoming_calls(struct rxrpc_local *);
 struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *, unsigned long,
 				     rxrpc_notify_rx_t);
@@ -557,6 +584,7 @@ extern struct list_head rxrpc_calls;
 extern rwlock_t rxrpc_call_lock;
 
 struct rxrpc_call *rxrpc_find_call_by_user_ID(struct rxrpc_sock *, unsigned long);
+struct rxrpc_call *rxrpc_alloc_call(gfp_t);
 struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
 					 struct rxrpc_conn_parameters *,
 					 struct sockaddr_rxrpc *,
@@ -573,6 +601,7 @@ void rxrpc_get_call(struct rxrpc_call *, enum rxrpc_call_trace);
 void rxrpc_put_call(struct rxrpc_call *, enum rxrpc_call_trace);
 void rxrpc_get_call_for_skb(struct rxrpc_call *, struct sk_buff *);
 void rxrpc_put_call_for_skb(struct rxrpc_call *, struct sk_buff *);
+void rxrpc_cleanup_call(struct rxrpc_call *);
 void __exit rxrpc_destroy_all_calls(void);
 
 static inline bool rxrpc_is_service_call(const struct rxrpc_call *call)
@@ -757,6 +786,7 @@ struct rxrpc_connection *rxrpc_find_service_conn_rcu(struct rxrpc_peer *,
 struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *,
 						   struct sockaddr_rxrpc *,
 						   struct sk_buff *);
+struct rxrpc_connection *rxrpc_prealloc_service_connection(gfp_t);
 void rxrpc_unpublish_service_conn(struct rxrpc_connection *);
 
 /*
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 4c71efcf82ed..cc7194e05a15 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -20,12 +20,210 @@
 #include <linux/in6.h>
 #include <linux/icmp.h>
 #include <linux/gfp.h>
+#include <linux/circ_buf.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <net/ip.h>
 #include "ar-internal.h"
 
 /*
+ * Preallocate a single service call, connection and peer and, if possible,
+ * give them a user ID and attach the user's side of the ID to them.
+ */
+static int rxrpc_service_prealloc_one(struct rxrpc_sock *rx,
+				      struct rxrpc_backlog *b,
+				      rxrpc_notify_rx_t notify_rx,
+				      rxrpc_user_attach_call_t user_attach_call,
+				      unsigned long user_call_ID, gfp_t gfp)
+{
+	const void *here = __builtin_return_address(0);
+	struct rxrpc_call *call;
+	int max, tmp;
+	unsigned int size = RXRPC_BACKLOG_MAX;
+	unsigned int head, tail, call_head, call_tail;
+
+	max = rx->sk.sk_max_ack_backlog;
+	tmp = rx->sk.sk_ack_backlog;
+	if (tmp >= max) {
+		_leave(" = -ENOBUFS [full %u]", max);
+		return -ENOBUFS;
+	}
+	max -= tmp;
+
+	/* We don't need more conns and peers than we have calls, but on the
+	 * other hand, we shouldn't ever use more peers than conns or conns
+	 * than calls.
+	 */
+	call_head = b->call_backlog_head;
+	call_tail = READ_ONCE(b->call_backlog_tail);
+	tmp = CIRC_CNT(call_head, call_tail, size);
+	if (tmp >= max) {
+		_leave(" = -ENOBUFS [enough %u]", tmp);
+		return -ENOBUFS;
+	}
+	max = tmp + 1;
+
+	head = b->peer_backlog_head;
+	tail = READ_ONCE(b->peer_backlog_tail);
+	if (CIRC_CNT(head, tail, size) < max) {
+		struct rxrpc_peer *peer = rxrpc_alloc_peer(rx->local, gfp);
+		if (!peer)
+			return -ENOMEM;
+		b->peer_backlog[head] = peer;
+		smp_store_release(&b->peer_backlog_head,
+				  (head + 1) & (size - 1));
+	}
+
+	head = b->conn_backlog_head;
+	tail = READ_ONCE(b->conn_backlog_tail);
+	if (CIRC_CNT(head, tail, size) < max) {
+		struct rxrpc_connection *conn;
+
+		conn = rxrpc_prealloc_service_connection(gfp);
+		if (!conn)
+			return -ENOMEM;
+		b->conn_backlog[head] = conn;
+		smp_store_release(&b->conn_backlog_head,
+				  (head + 1) & (size - 1));
+	}
+
+	/* Now it gets complicated, because calls get registered with the
+	 * socket here, particularly if a user ID is preassigned by the user.
+	 */
+	call = rxrpc_alloc_call(gfp);
+	if (!call)
+		return -ENOMEM;
+	call->flags |= (1 << RXRPC_CALL_IS_SERVICE);
+	call->state = RXRPC_CALL_SERVER_PREALLOC;
+
+	trace_rxrpc_call(call, rxrpc_call_new_service,
+			 atomic_read(&call->usage),
+			 here, (const void *)user_call_ID);
+
+	write_lock(&rx->call_lock);
+	if (user_attach_call) {
+		struct rxrpc_call *xcall;
+		struct rb_node *parent, **pp;
+
+		/* Check the user ID isn't already in use */
+		pp = &rx->calls.rb_node;
+		parent = NULL;
+		while (*pp) {
+			parent = *pp;
+			xcall = rb_entry(parent, struct rxrpc_call, sock_node);
+			if (user_call_ID < call->user_call_ID)
+				pp = &(*pp)->rb_left;
+			else if (user_call_ID > call->user_call_ID)
+				pp = &(*pp)->rb_right;
+			else
+				goto id_in_use;
+		}
+
+		call->user_call_ID = user_call_ID;
+		call->notify_rx = notify_rx;
+		rxrpc_get_call(call, rxrpc_call_got);
+		user_attach_call(call, user_call_ID);
+		rxrpc_get_call(call, rxrpc_call_got_userid);
+		rb_link_node(&call->sock_node, parent, pp);
+		rb_insert_color(&call->sock_node, &rx->calls);
+		set_bit(RXRPC_CALL_HAS_USERID, &call->flags);
+	}
+
+	write_unlock(&rx->call_lock);
+
+	write_lock(&rxrpc_call_lock);
+	list_add_tail(&call->link, &rxrpc_calls);
+	write_unlock(&rxrpc_call_lock);
+
+	b->call_backlog[call_head] = call;
+	smp_store_release(&b->call_backlog_head, (call_head + 1) & (size - 1));
+	_leave(" = 0 [%d -> %lx]", call->debug_id, user_call_ID);
+	return 0;
+
+id_in_use:
+	write_unlock(&rx->call_lock);
+	rxrpc_cleanup_call(call);
+	_leave(" = -EBADSLT");
+	return -EBADSLT;
+}
+
+/*
+ * Preallocate sufficient service connections, calls and peers to cover the
+ * entire backlog of a socket.  When a new call comes in, if we don't have
+ * sufficient of each available, the call gets rejected as busy or ignored.
+ *
+ * The backlog is replenished when a connection is accepted or rejected.
+ */
+int rxrpc_service_prealloc(struct rxrpc_sock *rx, gfp_t gfp)
+{
+	struct rxrpc_backlog *b = rx->backlog;
+
+	if (!b) {
+		b = kzalloc(sizeof(struct rxrpc_backlog), gfp);
+		if (!b)
+			return -ENOMEM;
+		rx->backlog = b;
+	}
+
+	if (rx->discard_new_call)
+		return 0;
+
+	while (rxrpc_service_prealloc_one(rx, b, NULL, NULL, 0, gfp) == 0)
+		;
+
+	return 0;
+}
+
+/*
+ * Discard the preallocation on a service.
+ */
+void rxrpc_discard_prealloc(struct rxrpc_sock *rx)
+{
+	struct rxrpc_backlog *b = rx->backlog;
+	unsigned int size = RXRPC_BACKLOG_MAX, head, tail;
+
+	if (!b)
+		return;
+	rx->backlog = NULL;
+
+	head = b->peer_backlog_head;
+	tail = b->peer_backlog_tail;
+	while (CIRC_CNT(head, tail, size) > 0) {
+		struct rxrpc_peer *peer = b->peer_backlog[tail];
+		kfree(peer);
+		tail = (tail + 1) & (size - 1);
+	}
+
+	head = b->conn_backlog_head;
+	tail = b->conn_backlog_tail;
+	while (CIRC_CNT(head, tail, size) > 0) {
+		struct rxrpc_connection *conn = b->conn_backlog[tail];
+		write_lock(&rxrpc_connection_lock);
+		list_del(&conn->link);
+		list_del(&conn->proc_link);
+		write_unlock(&rxrpc_connection_lock);
+		kfree(conn);
+		tail = (tail + 1) & (size - 1);
+	}
+
+	head = b->call_backlog_head;
+	tail = b->call_backlog_tail;
+	while (CIRC_CNT(head, tail, size) > 0) {
+		struct rxrpc_call *call = b->call_backlog[tail];
+		if (rx->discard_new_call) {
+			_debug("discard %lx", call->user_call_ID);
+			rx->discard_new_call(call, call->user_call_ID);
+		}
+		rxrpc_call_completed(call);
+		rxrpc_release_call(rx, call);
+		rxrpc_put_call(call, rxrpc_call_put);
+		tail = (tail + 1) & (size - 1);
+	}
+
+	kfree(b);
+}
+
+/*
  * generate a connection-level abort
  */
 static int rxrpc_busy(struct rxrpc_local *local, struct sockaddr_rxrpc *srx,
@@ -450,3 +648,34 @@ int rxrpc_kernel_reject_call(struct socket *sock)
 	return ret;
 }
 EXPORT_SYMBOL(rxrpc_kernel_reject_call);
+
+/*
+ * rxrpc_kernel_charge_accept - Charge up socket with preallocated calls
+ * @sock: The socket on which to preallocate
+ * @notify_rx: Event notification function for the call
+ * @user_attach_call: Func to attach call to user_call_ID
+ * @user_call_ID: The tag to attach to the preallocated call
+ * @gfp: The allocation conditions.
+ *
+ * Charge up the socket with preallocated calls, each with a user ID.  A
+ * function should be provided to effect the attachment from the user's side.
+ * The user is given a ref to hold on the call.
+ *
+ * Note that the call may be come connected before this function returns.
+ */
+int rxrpc_kernel_charge_accept(struct socket *sock,
+			       rxrpc_notify_rx_t notify_rx,
+			       rxrpc_user_attach_call_t user_attach_call,
+			       unsigned long user_call_ID, gfp_t gfp)
+{
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+	struct rxrpc_backlog *b = rx->backlog;
+
+	if (sock->sk->sk_state == RXRPC_CLOSE)
+		return -ESHUTDOWN;
+
+	return rxrpc_service_prealloc_one(rx, b, notify_rx,
+					  user_attach_call, user_call_ID,
+					  gfp);
+}
+EXPORT_SYMBOL(rxrpc_kernel_charge_accept);
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index f843397e03b6..d233adc9b5e5 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -31,6 +31,7 @@ const char *const rxrpc_call_states[NR__RXRPC_CALL_STATES] = {
 	[RXRPC_CALL_CLIENT_AWAIT_REPLY]		= "ClAwtRpl",
 	[RXRPC_CALL_CLIENT_RECV_REPLY]		= "ClRcvRpl",
 	[RXRPC_CALL_CLIENT_FINAL_ACK]		= "ClFnlACK",
+	[RXRPC_CALL_SERVER_PREALLOC]		= "SvPrealc",
 	[RXRPC_CALL_SERVER_SECURING]		= "SvSecure",
 	[RXRPC_CALL_SERVER_ACCEPTING]		= "SvAccept",
 	[RXRPC_CALL_SERVER_RECV_REQUEST]	= "SvRcvReq",
@@ -71,7 +72,6 @@ DEFINE_RWLOCK(rxrpc_call_lock);
 static void rxrpc_call_life_expired(unsigned long _call);
 static void rxrpc_ack_time_expired(unsigned long _call);
 static void rxrpc_resend_time_expired(unsigned long _call);
-static void rxrpc_cleanup_call(struct rxrpc_call *call);
 
 /*
  * find an extant server call
@@ -113,7 +113,7 @@ found_extant_call:
 /*
  * allocate a new call
  */
-static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
+struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 {
 	struct rxrpc_call *call;
 
@@ -392,6 +392,9 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	if (call_id <= conn->channels[chan].call_counter)
 		goto old_call; /* TODO: Just drop packet */
 
+	/* Temporary: Mirror the backlog prealloc ref (TODO: use prealloc) */
+	rxrpc_get_call(candidate, rxrpc_call_got);
+
 	/* make the call available */
 	_debug("new call");
 	call = candidate;
@@ -596,6 +599,9 @@ void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
 	del_timer_sync(&call->ack_timer);
 	del_timer_sync(&call->lifetimer);
 
+	/* We have to release the prealloc backlog ref */
+	if (rxrpc_is_service_call(call))
+		rxrpc_put_call(call, rxrpc_call_put);
 	_leave("");
 }
 
@@ -682,7 +688,7 @@ static void rxrpc_rcu_destroy_call(struct rcu_head *rcu)
 /*
  * clean up a call
  */
-static void rxrpc_cleanup_call(struct rxrpc_call *call)
+void rxrpc_cleanup_call(struct rxrpc_call *call)
 {
 	_net("DESTROY CALL %d", call->debug_id);
 
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 9c6685b97e70..8da82e3aa00e 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -286,6 +286,8 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 		ASSERTCMP(atomic_read(&conn->usage), >, 0);
 		if (likely(atomic_read(&conn->usage) > 1))
 			continue;
+		if (conn->state == RXRPC_CONN_SERVICE_PREALLOC)
+			continue;
 
 		idle_timestamp = READ_ONCE(conn->idle_timestamp);
 		_debug("reap CONN %d { u=%d,t=%ld }",
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index 316a92107fee..189338a60457 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -119,6 +119,30 @@ replace_old_connection:
 }
 
 /*
+ * Preallocate a service connection.  The connection is placed on the proc and
+ * reap lists so that we don't have to get the lock from BH context.
+ */
+struct rxrpc_connection *rxrpc_prealloc_service_connection(gfp_t gfp)
+{
+	struct rxrpc_connection *conn = rxrpc_alloc_connection(gfp);
+
+	if (conn) {
+		/* We maintain an extra ref on the connection whilst it is on
+		 * the rxrpc_connections list.
+		 */
+		conn->state = RXRPC_CONN_SERVICE_PREALLOC;
+		atomic_set(&conn->usage, 2);
+
+		write_lock(&rxrpc_connection_lock);
+		list_add_tail(&conn->link, &rxrpc_connections);
+		list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
+		write_unlock(&rxrpc_connection_lock);
+	}
+
+	return conn;
+}
+
+/*
  * get a record of an incoming connection
  */
 struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 6c4b7df05e95..5906579060cd 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -102,7 +102,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 		    rx->notify_new_call) {
 			spin_unlock_bh(&sk->sk_receive_queue.lock);
 			skb_queue_tail(&call->knlrecv_queue, skb);
-			rx->notify_new_call(&rx->sk);
+			rx->notify_new_call(&rx->sk, NULL, 0);
 		} else if (call->notify_rx) {
 			spin_unlock_bh(&sk->sk_receive_queue.lock);
 			skb_queue_tail(&call->knlrecv_queue, skb);
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index dfad23821a62..d529d1b4021c 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -17,6 +17,7 @@
 static const char *const rxrpc_conn_states[RXRPC_CONN__NR_STATES] = {
 	[RXRPC_CONN_UNUSED]			= "Unused  ",
 	[RXRPC_CONN_CLIENT]			= "Client  ",
+	[RXRPC_CONN_SERVICE_PREALLOC]		= "SvPrealc",
 	[RXRPC_CONN_SERVICE_UNSECURED]		= "SvUnsec ",
 	[RXRPC_CONN_SERVICE_CHALLENGING]	= "SvChall ",
 	[RXRPC_CONN_SERVICE]			= "SvSecure",
@@ -156,6 +157,11 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 	}
 
 	conn = list_entry(v, struct rxrpc_connection, proc_link);
+	if (conn->state == RXRPC_CONN_SERVICE_PREALLOC) {
+		strcpy(lbuff, "no_local");
+		strcpy(rbuff, "no_connection");
+		goto print;
+	}
 
 	sprintf(lbuff, "%pI4:%u",
 		&conn->params.local->srx.transport.sin.sin_addr,
@@ -164,7 +170,7 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 	sprintf(rbuff, "%pI4:%u",
 		&conn->params.peer->srx.transport.sin.sin_addr,
 		ntohs(conn->params.peer->srx.transport.sin.sin_port));
-
+print:
 	seq_printf(seq,
 		   "UDP   %-22.22s %-22.22s %4x %08x %s %3u"
 		   " %s %08x %08x %08x\n",
