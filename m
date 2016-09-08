From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 7/7] rxrpc: Rewrite the data and ack handling code
Date: Thu, 08 Sep 2016 12:44:18 +0100
Message-ID: <147333505883.5646.5681436087065539408.stgit@warthog.procyon.org.uk>
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

Rewrite the data and ack handling code such that:

 (1) Parsing of received ACK and ABORT packets and the distribution and the
     filing of DATA packets happens entirely within the data_ready context
     called from the UDP socket.  This allows us to process and discard ACK
     and ABORT packets much more quickly (they're no longer stashed on a
     queue for a background thread to process).

 (2) We avoid calling skb_clone(), pskb_pull() and pskb_trim().  We instead
     keep track of the offset and length of the content of each packet in
     the sk_buff metadata.  This means we don't do any allocation in the
     receive path.

 (3) Jumbo DATA packet parsing is now done in data_ready context.  Rather
     than cloning the packet once for each subpacket and pulling/trimming
     it, we file the packet multiple times with an annotation for each
     indicating which subpacket is there.  From that we can directly
     calculate the offset and length.

 (4) A call's receive queue can be accessed without taking locks (memory
     barriers do have to be used, though).

 (5) Incoming calls are set up from preallocated resources and immediately
     made live.  They can than have packets queued upon them and ACKs
     generated.  If insufficient resources exist, DATA packet #1 is given a
     BUSY reply and other DATA packets are discarded).

 (6) sk_buffs no longer take a ref on their parent call.

To make this work, the following changes are made:

 (1) Each call's receive buffer is now a circular buffer of sk_buff
     pointers (rxtx_buffer) rather than a number of sk_buff_heads spread
     between the call and the socket.  This permits each sk_buff to be in
     the buffer multiple times.  The receive buffer is reused for the
     transmit buffer.

 (2) A circular buffer of annotations (rxtx_annotations) is kept parallel
     to the data buffer.  Transmission phase annotations indicate whether a
     buffered packet has been ACK'd or not and whether it needs
     retransmission.

     Receive phase annotations indicate whether a slot holds a whole packet
     or a jumbo subpacket and, if the latter, which subpacket.  They also
     note whether the packet has been decrypted in place.

 (3) DATA packet window tracking is much simplified.  Each phase has just
     two numbers representing the window (rx_hard_ack/rx_top and
     tx_hard_ack/tx_top).

     The hard_ack number is the sequence number before base of the window,
     representing the last packet the other side says it has consumed.
     hard_ack starts from 0 and the first packet is sequence number 1.

     The top number is the sequence number of the highest-numbered packet
     residing in the buffer.  Packets between hard_ack+1 and top are
     soft-ACK'd to indicate they've been received, but not yet consumed.

     Four macros, before(), before_eq(), after() and after_eq() are added
     to compare sequence numbers within the window.  This allows for the
     top of the window to wrap when the hard-ack sequence number gets close
     to the limit.

     Two flags, RXRPC_CALL_RX_LAST and RXRPC_CALL_TX_LAST, are added also
     to indicate when rx_top and tx_top point at the packets with the
     LAST_PACKET bit set, indicating the end of the phase.

 (4) Calls are queued on the socket 'receive queue' rather than packets.
     This means that we don't need have to invent dummy packets to queue to
     indicate abnormal/terminal states and we don't have to keep metadata
     packets (such as ABORTs) around

 (5) The offset and length of a (sub)packet's content are now passed to
     the verify_packet security op.  This is currently expected to decrypt
     the packet in place and validate it.

     However, there's now nowhere to store the revised offset and length of
     the actual data within the decrypted blob (there may be a header and
     padding to skip) because an sk_buff may represent multiple packets, so
     a locate_data security op is added to retrieve these details from the
     sk_buff content when needed.

 (6) recvmsg() now has to handle jumbo subpackets, where each subpacket is
     individually secured and needs to be individually decrypted.  The code
     to do this is broken out into rxrpc_recvmsg_data() and shared with the
     kernel API.  It now iterates over the call's receive buffer rather
     than walking the socket receive queue.

Additional changes:

 (1) The timers are condensed to a single timer that is set for the soonest
     of three timeouts (delayed ACK generation, DATA retransmission and
     call lifespan).

 (2) Transmission of ACK and ABORT packets is effected immediately from
     process-context socket ops/kernel API calls that cause them instead of
     them being punted off to a background work item.  The data_ready
     handler still has to defer to the background, though.

 (3) A shutdown op is added to the AF_RXRPC socket so that the AFS
     filesystem can shut down the socket and flush its own work items
     before closing the socket to deal with any in-progress service calls.

Future additional changes that will need to be considered:

 (1) Make sure that a call doesn't hog the front of the queue by receiving
     data from the network as fast as userspace is consuming it to the
     exclusion of other calls.

 (2) Transmit delayed ACKs from within recvmsg() when we've consumed
     sufficiently more packets to avoid the background work item needing to
     run.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/rxrpc.c           |   51 --
 include/net/af_rxrpc.h   |    3 
 include/rxrpc/packet.h   |    7 
 net/rxrpc/af_rxrpc.c     |   57 ++
 net/rxrpc/ar-internal.h  |  177 +++---
 net/rxrpc/call_accept.c  |  472 ++++++----------
 net/rxrpc/call_event.c   | 1357 +++++++---------------------------------------
 net/rxrpc/call_object.c  |  535 +++++-------------
 net/rxrpc/conn_event.c   |  137 +----
 net/rxrpc/conn_object.c  |    6 
 net/rxrpc/conn_service.c |  101 ---
 net/rxrpc/input.c        | 1044 ++++++++++++++++++-----------------
 net/rxrpc/insecure.c     |   13 
 net/rxrpc/local_event.c  |    2 
 net/rxrpc/local_object.c |    7 
 net/rxrpc/misc.c         |    2 
 net/rxrpc/output.c       |  125 ++++
 net/rxrpc/peer_event.c   |   17 -
 net/rxrpc/peer_object.c  |   82 ++-
 net/rxrpc/recvmsg.c      |  764 ++++++++++++++------------
 net/rxrpc/rxkad.c        |  108 +++-
 net/rxrpc/security.c     |   10 
 net/rxrpc/sendmsg.c      |  126 ++--
 net/rxrpc/skbuff.c       |  127 ----
 24 files changed, 1993 insertions(+), 3337 deletions(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 720ef05a24fe..59bdaa7527b6 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -55,10 +55,8 @@ static const struct afs_call_type afs_RXCMxxxx = {
 	.abort_to_error	= afs_abort_to_error,
 };
 
-static void afs_collect_incoming_call(struct work_struct *);
 static void afs_charge_preallocation(struct work_struct *);
 
-static DECLARE_WORK(afs_collect_incoming_call_work, afs_collect_incoming_call);
 static DECLARE_WORK(afs_charge_preallocation_work, afs_charge_preallocation);
 
 static int afs_wait_atomic_t(atomic_t *p)
@@ -144,6 +142,8 @@ void afs_close_socket(void)
 	_debug("no outstanding calls");
 
 	flush_workqueue(afs_async_calls);
+	kernel_sock_shutdown(afs_socket, SHUT_RDWR);
+	flush_workqueue(afs_async_calls);
 	sock_release(afs_socket);
 
 	_debug("dework");
@@ -602,51 +602,6 @@ static void afs_process_async_call(struct work_struct *work)
 	_leave("");
 }
 
-/*
- * accept the backlog of incoming calls
- */
-static void afs_collect_incoming_call(struct work_struct *work)
-{
-	struct rxrpc_call *rxcall;
-	struct afs_call *call = NULL;
-
-	_enter("");
-
-	do {
-		if (!call) {
-			call = kzalloc(sizeof(struct afs_call), GFP_KERNEL);
-			if (!call) {
-				rxrpc_kernel_reject_call(afs_socket);
-				return;
-			}
-
-			INIT_WORK(&call->async_work, afs_process_async_call);
-			call->wait_mode = &afs_async_incoming_call;
-			call->type = &afs_RXCMxxxx;
-			init_waitqueue_head(&call->waitq);
-			call->state = AFS_CALL_AWAIT_OP_ID;
-
-			_debug("CALL %p{%s} [%d]",
-			       call, call->type->name,
-			       atomic_read(&afs_outstanding_calls));
-			atomic_inc(&afs_outstanding_calls);
-		}
-
-		rxcall = rxrpc_kernel_accept_call(afs_socket,
-						  (unsigned long)call,
-						  afs_wake_up_async_call);
-		if (!IS_ERR(rxcall)) {
-			call->rxcall = rxcall;
-			call->need_attention = true;
-			queue_work(afs_async_calls, &call->async_work);
-			call = NULL;
-		}
-	} while (!call);
-
-	if (call)
-		afs_free_call(call);
-}
-
 static void afs_rx_attach(struct rxrpc_call *rxcall, unsigned long user_call_ID)
 {
 	struct afs_call *call = (struct afs_call *)user_call_ID;
@@ -704,7 +659,7 @@ static void afs_rx_discard_new_call(struct rxrpc_call *rxcall,
 static void afs_rx_new_call(struct sock *sk, struct rxrpc_call *rxcall,
 			    unsigned long user_call_ID)
 {
-	queue_work(afs_wq, &afs_collect_incoming_call_work);
+	atomic_inc(&afs_outstanding_calls);
 	queue_work(afs_wq, &afs_charge_preallocation_work);
 }
 
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index 9cf551be916b..1061a472a3e3 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -42,9 +42,6 @@ int rxrpc_kernel_recv_data(struct socket *, struct rxrpc_call *,
 void rxrpc_kernel_abort_call(struct socket *, struct rxrpc_call *,
 			     u32, int, const char *);
 void rxrpc_kernel_end_call(struct socket *, struct rxrpc_call *);
-struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *, unsigned long,
-					    rxrpc_notify_rx_t);
-int rxrpc_kernel_reject_call(struct socket *);
 void rxrpc_kernel_get_peer(struct socket *, struct rxrpc_call *,
 			   struct sockaddr_rxrpc *);
 int rxrpc_kernel_charge_accept(struct socket *, rxrpc_notify_rx_t,
diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index b0ae5c1a6ce6..fd6eb3a60a8c 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -133,6 +133,13 @@ struct rxrpc_ackpacket {
 
 } __packed;
 
+/* Some ACKs refer to specific packets and some are general and can be updated. */
+#define RXRPC_ACK_UPDATEABLE ((1 << RXRPC_ACK_REQUESTED)	|	\
+			      (1 << RXRPC_ACK_PING_RESPONSE)	|	\
+			      (1 << RXRPC_ACK_DELAY)		|	\
+			      (1 << RXRPC_ACK_IDLE))
+
+
 /*
  * ACK packets can have a further piece of information tagged on the end
  */
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 1e8cf3ded81f..caa226dd436e 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -155,7 +155,7 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 	}
 
 	if (rx->srx.srx_service) {
-		write_lock_bh(&local->services_lock);
+		write_lock(&local->services_lock);
 		hlist_for_each_entry(prx, &local->services, listen_link) {
 			if (prx->srx.srx_service == rx->srx.srx_service)
 				goto service_in_use;
@@ -163,7 +163,7 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 
 		rx->local = local;
 		hlist_add_head_rcu(&rx->listen_link, &local->services);
-		write_unlock_bh(&local->services_lock);
+		write_unlock(&local->services_lock);
 
 		rx->sk.sk_state = RXRPC_SERVER_BOUND;
 	} else {
@@ -176,7 +176,7 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 	return 0;
 
 service_in_use:
-	write_unlock_bh(&local->services_lock);
+	write_unlock(&local->services_lock);
 	rxrpc_put_local(local);
 	ret = -EADDRINUSE;
 error_unlock:
@@ -515,15 +515,16 @@ error:
 static unsigned int rxrpc_poll(struct file *file, struct socket *sock,
 			       poll_table *wait)
 {
-	unsigned int mask;
 	struct sock *sk = sock->sk;
+	struct rxrpc_sock *rx = rxrpc_sk(sk);
+	unsigned int mask;
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask = 0;
 
 	/* the socket is readable if there are any messages waiting on the Rx
 	 * queue */
-	if (!skb_queue_empty(&sk->sk_receive_queue))
+	if (!list_empty(&rx->recvmsg_q))
 		mask |= POLLIN | POLLRDNORM;
 
 	/* the socket is writable if there is space to add new data to the
@@ -575,8 +576,11 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 	rx->calls = RB_ROOT;
 
 	INIT_HLIST_NODE(&rx->listen_link);
-	INIT_LIST_HEAD(&rx->secureq);
-	INIT_LIST_HEAD(&rx->acceptq);
+	spin_lock_init(&rx->incoming_lock);
+	INIT_LIST_HEAD(&rx->sock_calls);
+	INIT_LIST_HEAD(&rx->to_be_accepted);
+	INIT_LIST_HEAD(&rx->recvmsg_q);
+	rwlock_init(&rx->recvmsg_lock);
 	rwlock_init(&rx->call_lock);
 	memset(&rx->srx, 0, sizeof(rx->srx));
 
@@ -585,6 +589,39 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 }
 
 /*
+ * Kill all the calls on a socket and shut it down.
+ */
+static int rxrpc_shutdown(struct socket *sock, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct rxrpc_sock *rx = rxrpc_sk(sk);
+	int ret = 0;
+
+	_enter("%p,%d", sk, flags);
+
+	if (flags != SHUT_RDWR)
+		return -EOPNOTSUPP;
+	if (sk->sk_state == RXRPC_CLOSE)
+		return -ESHUTDOWN;
+
+	lock_sock(sk);
+
+	spin_lock_bh(&sk->sk_receive_queue.lock);
+	if (sk->sk_state < RXRPC_CLOSE) {
+		sk->sk_state = RXRPC_CLOSE;
+		sk->sk_shutdown = SHUTDOWN_MASK;
+	} else {
+		ret = -ESHUTDOWN;
+	}
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
+
+	rxrpc_discard_prealloc(rx);
+
+	release_sock(sk);
+	return ret;
+}
+
+/*
  * RxRPC socket destructor
  */
 static void rxrpc_sock_destructor(struct sock *sk)
@@ -623,9 +660,9 @@ static int rxrpc_release_sock(struct sock *sk)
 	ASSERTCMP(rx->listen_link.next, !=, LIST_POISON1);
 
 	if (!hlist_unhashed(&rx->listen_link)) {
-		write_lock_bh(&rx->local->services_lock);
+		write_lock(&rx->local->services_lock);
 		hlist_del_rcu(&rx->listen_link);
-		write_unlock_bh(&rx->local->services_lock);
+		write_unlock(&rx->local->services_lock);
 	}
 
 	/* try to flush out this socket */
@@ -678,7 +715,7 @@ static const struct proto_ops rxrpc_rpc_ops = {
 	.poll		= rxrpc_poll,
 	.ioctl		= sock_no_ioctl,
 	.listen		= rxrpc_listen,
-	.shutdown	= sock_no_shutdown,
+	.shutdown	= rxrpc_shutdown,
 	.setsockopt	= rxrpc_setsockopt,
 	.getsockopt	= sock_no_getsockopt,
 	.sendmsg	= rxrpc_sendmsg,
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 45e1c269f90e..b1cb79ec4e96 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -94,9 +94,12 @@ struct rxrpc_sock {
 	rxrpc_discard_new_call_t discard_new_call; /* Func to discard a new call */
 	struct rxrpc_local	*local;		/* local endpoint */
 	struct hlist_node	listen_link;	/* link in the local endpoint's listen list */
-	struct list_head	secureq;	/* calls awaiting connection security clearance */
-	struct list_head	acceptq;	/* calls awaiting acceptance */
 	struct rxrpc_backlog	*backlog;	/* Preallocation for services */
+	spinlock_t		incoming_lock;	/* Incoming call vs service shutdown lock */
+	struct list_head	sock_calls;	/* List of calls owned by this socket */
+	struct list_head	to_be_accepted;	/* calls awaiting acceptance */
+	struct list_head	recvmsg_q;	/* Calls awaiting recvmsg's attention  */
+	rwlock_t		recvmsg_lock;	/* Lock for recvmsg_q */
 	struct key		*key;		/* security for this socket */
 	struct key		*securities;	/* list of server security descriptors */
 	struct rb_root		calls;		/* User ID -> call mapping */
@@ -138,13 +141,16 @@ struct rxrpc_host_header {
  * - max 48 bytes (struct sk_buff::cb)
  */
 struct rxrpc_skb_priv {
-	struct rxrpc_call	*call;		/* call with which associated */
-	unsigned long		resend_at;	/* time in jiffies at which to resend */
+	union {
+		unsigned long	resend_at;	/* time in jiffies at which to resend */
+		struct {
+			u8	nr_jumbo;	/* Number of jumbo subpackets */
+		};
+	};
 	union {
 		unsigned int	offset;		/* offset into buffer of next read */
 		int		remain;		/* amount of space remaining for next write */
 		u32		error;		/* network error code */
-		bool		need_resend;	/* T if needs resending */
 	};
 
 	struct rxrpc_host_header hdr;		/* RxRPC packet header from this packet */
@@ -179,7 +185,11 @@ struct rxrpc_security {
 
 	/* verify the security on a received packet */
 	int (*verify_packet)(struct rxrpc_call *, struct sk_buff *,
-			     rxrpc_seq_t, u16);
+			     unsigned int, unsigned int, rxrpc_seq_t, u16);
+
+	/* Locate the data in a received packet that has been verified. */
+	void (*locate_data)(struct rxrpc_call *, struct sk_buff *,
+			    unsigned int *, unsigned int *);
 
 	/* issue a challenge */
 	int (*issue_challenge)(struct rxrpc_connection *);
@@ -211,7 +221,6 @@ struct rxrpc_local {
 	struct work_struct	processor;
 	struct hlist_head	services;	/* services listening on this endpoint */
 	struct rw_semaphore	defrag_sem;	/* control re-enablement of IP DF bit */
-	struct sk_buff_head	accept_queue;	/* incoming calls awaiting acceptance */
 	struct sk_buff_head	reject_queue;	/* packets awaiting rejection */
 	struct sk_buff_head	event_queue;	/* endpoint event packets awaiting processing */
 	struct rb_root		client_conns;	/* Client connections by socket params */
@@ -388,38 +397,21 @@ struct rxrpc_connection {
  */
 enum rxrpc_call_flag {
 	RXRPC_CALL_RELEASED,		/* call has been released - no more message to userspace */
-	RXRPC_CALL_TERMINAL_MSG,	/* call has given the socket its final message */
-	RXRPC_CALL_RCVD_LAST,		/* all packets received */
-	RXRPC_CALL_RUN_RTIMER,		/* Tx resend timer started */
-	RXRPC_CALL_TX_SOFT_ACK,		/* sent some soft ACKs */
-	RXRPC_CALL_INIT_ACCEPT,		/* acceptance was initiated */
 	RXRPC_CALL_HAS_USERID,		/* has a user ID attached */
-	RXRPC_CALL_EXPECT_OOS,		/* expect out of sequence packets */
 	RXRPC_CALL_IS_SERVICE,		/* Call is service call */
 	RXRPC_CALL_EXPOSED,		/* The call was exposed to the world */
-	RXRPC_CALL_RX_NO_MORE,		/* Don't indicate MSG_MORE from recvmsg() */
+	RXRPC_CALL_RX_LAST,		/* Received the last packet (at rxtx_top) */
+	RXRPC_CALL_TX_LAST,		/* Last packet in Tx buffer (at rxtx_top) */
 };
 
 /*
  * Events that can be raised on a call.
  */
 enum rxrpc_call_event {
-	RXRPC_CALL_EV_RCVD_ACKALL,	/* ACKALL or reply received */
-	RXRPC_CALL_EV_RCVD_BUSY,	/* busy packet received */
-	RXRPC_CALL_EV_RCVD_ABORT,	/* abort packet received */
-	RXRPC_CALL_EV_RCVD_ERROR,	/* network error received */
-	RXRPC_CALL_EV_ACK_FINAL,	/* need to generate final ACK (and release call) */
 	RXRPC_CALL_EV_ACK,		/* need to generate ACK */
-	RXRPC_CALL_EV_REJECT_BUSY,	/* need to generate busy message */
 	RXRPC_CALL_EV_ABORT,		/* need to generate abort */
-	RXRPC_CALL_EV_CONN_ABORT,	/* local connection abort generated */
-	RXRPC_CALL_EV_RESEND_TIMER,	/* Tx resend timer expired */
+	RXRPC_CALL_EV_TIMER,		/* Timer expired */
 	RXRPC_CALL_EV_RESEND,		/* Tx resend required */
-	RXRPC_CALL_EV_DRAIN_RX_OOS,	/* drain the Rx out of sequence queue */
-	RXRPC_CALL_EV_LIFE_TIMER,	/* call's lifetimer ran out */
-	RXRPC_CALL_EV_ACCEPTED,		/* incoming call accepted by userspace app */
-	RXRPC_CALL_EV_SECURED,		/* incoming call's connection is now secure */
-	RXRPC_CALL_EV_POST_ACCEPT,	/* need to post an "accept?" message to the app */
 };
 
 /*
@@ -431,7 +423,6 @@ enum rxrpc_call_state {
 	RXRPC_CALL_CLIENT_SEND_REQUEST,	/* - client sending request phase */
 	RXRPC_CALL_CLIENT_AWAIT_REPLY,	/* - client awaiting reply */
 	RXRPC_CALL_CLIENT_RECV_REPLY,	/* - client receiving reply phase */
-	RXRPC_CALL_CLIENT_FINAL_ACK,	/* - client sending final ACK phase */
 	RXRPC_CALL_SERVER_PREALLOC,	/* - service preallocation */
 	RXRPC_CALL_SERVER_SECURING,	/* - server securing request connection */
 	RXRPC_CALL_SERVER_ACCEPTING,	/* - server accepting request */
@@ -448,7 +439,6 @@ enum rxrpc_call_state {
  */
 enum rxrpc_call_completion {
 	RXRPC_CALL_SUCCEEDED,		/* - Normal termination */
-	RXRPC_CALL_SERVER_BUSY,		/* - call rejected by busy server */
 	RXRPC_CALL_REMOTELY_ABORTED,	/* - call aborted by peer */
 	RXRPC_CALL_LOCALLY_ABORTED,	/* - call aborted locally on error or close */
 	RXRPC_CALL_LOCAL_ERROR,		/* - call failed due to local error */
@@ -465,24 +455,23 @@ struct rxrpc_call {
 	struct rxrpc_connection	*conn;		/* connection carrying call */
 	struct rxrpc_peer	*peer;		/* Peer record for remote address */
 	struct rxrpc_sock __rcu	*socket;	/* socket responsible */
-	struct timer_list	lifetimer;	/* lifetime remaining on call */
-	struct timer_list	ack_timer;	/* ACK generation timer */
-	struct timer_list	resend_timer;	/* Tx resend timer */
-	struct work_struct	processor;	/* packet processor and ACK generator */
+	unsigned long		ack_at;		/* When deferred ACK needs to happen */
+	unsigned long		resend_at;	/* When next resend needs to happen */
+	unsigned long		expire_at;	/* When the call times out */
+	struct timer_list	timer;		/* Combined event timer */
+	struct work_struct	processor;	/* Event processor */
 	rxrpc_notify_rx_t	notify_rx;	/* kernel service Rx notification function */
 	struct list_head	link;		/* link in master call list */
 	struct list_head	chan_wait_link;	/* Link in conn->waiting_calls */
 	struct hlist_node	error_link;	/* link in error distribution list */
-	struct list_head	accept_link;	/* calls awaiting acceptance */
-	struct rb_node		sock_node;	/* node in socket call tree */
-	struct sk_buff_head	rx_queue;	/* received packets */
-	struct sk_buff_head	rx_oos_queue;	/* packets received out of sequence */
-	struct sk_buff_head	knlrecv_queue;	/* Queue for kernel_recv [TODO: replace this] */
+	struct list_head	accept_link;	/* Link in rx->acceptq */
+	struct list_head	recvmsg_link;	/* Link in rx->recvmsg_q */
+	struct list_head	sock_link;	/* Link in rx->sock_calls */
+	struct rb_node		sock_node;	/* Node in rx->calls */
 	struct sk_buff		*tx_pending;	/* Tx socket buffer being filled */
 	wait_queue_head_t	waitq;		/* Wait queue for channel or Tx */
 	__be32			crypto_buf[2];	/* Temporary packet crypto buffer */
 	unsigned long		user_call_ID;	/* user-defined call ID */
-	unsigned long		creation_jif;	/* time of call creation */
 	unsigned long		flags;
 	unsigned long		events;
 	spinlock_t		lock;
@@ -492,40 +481,55 @@ struct rxrpc_call {
 	enum rxrpc_call_state	state;		/* current state of call */
 	enum rxrpc_call_completion completion;	/* Call completion condition */
 	atomic_t		usage;
-	atomic_t		sequence;	/* Tx data packet sequence counter */
 	u16			service_id;	/* service ID */
 	u8			security_ix;	/* Security type */
 	u32			call_id;	/* call ID on connection  */
 	u32			cid;		/* connection ID plus channel index */
 	int			debug_id;	/* debug ID for printks */
 
-	/* transmission-phase ACK management */
-	u8			acks_head;	/* offset into window of first entry */
-	u8			acks_tail;	/* offset into window of last entry */
-	u8			acks_winsz;	/* size of un-ACK'd window */
-	u8			acks_unacked;	/* lowest unacked packet in last ACK received */
-	int			acks_latest;	/* serial number of latest ACK received */
-	rxrpc_seq_t		acks_hard;	/* highest definitively ACK'd msg seq */
-	unsigned long		*acks_window;	/* sent packet window
-						 * - elements are pointers with LSB set if ACK'd
+	/* Rx/Tx circular buffer, depending on phase.
+	 *
+	 * In the Rx phase, packets are annotated with 0 or the number of the
+	 * segment of a jumbo packet each buffer refers to.  There can be up to
+	 * 47 segments in a maximum-size UDP packet.
+	 *
+	 * In the Tx phase, packets are annotated with which buffers have been
+	 * acked.
+	 */
+#define RXRPC_RXTX_BUFF_SIZE	64
+#define RXRPC_RXTX_BUFF_MASK	(RXRPC_RXTX_BUFF_SIZE - 1)
+	struct sk_buff		**rxtx_buffer;
+	u8			*rxtx_annotations;
+#define RXRPC_TX_ANNO_ACK	0
+#define RXRPC_TX_ANNO_UNACK	1
+#define RXRPC_TX_ANNO_NAK	2
+#define RXRPC_TX_ANNO_RETRANS	3
+#define RXRPC_RX_ANNO_JUMBO	0x3f		/* Jumbo subpacket number + 1 if not zero */
+#define RXRPC_RX_ANNO_JLAST	0x40		/* Set if last element of a jumbo packet */
+#define RXRPC_RX_ANNO_VERIFIED	0x80		/* Set if verified and decrypted */
+	rxrpc_seq_t		tx_hard_ack;	/* Dead slot in buffer; the first transmitted but
+						 * not hard-ACK'd packet follows this.
+						 */
+	rxrpc_seq_t		tx_top;		/* Highest Tx slot allocated. */
+	rxrpc_seq_t		rx_hard_ack;	/* Dead slot in buffer; the first received but not
+						 * consumed packet follows this.
 						 */
+	rxrpc_seq_t		rx_top;		/* Highest Rx slot allocated. */
+	rxrpc_seq_t		rx_expect_next;	/* Expected next packet sequence number */
+	u8			rx_winsize;	/* Size of Rx window */
+	u8			tx_winsize;	/* Maximum size of Tx window */
+	u8			nr_jumbo_dup;	/* Number of jumbo duplicates */
 
 	/* receive-phase ACK management */
-	rxrpc_seq_t		rx_data_expect;	/* next data seq ID expected to be received */
-	rxrpc_seq_t		rx_data_post;	/* next data seq ID expected to be posted */
-	rxrpc_seq_t		rx_data_recv;	/* last data seq ID encountered by recvmsg */
-	rxrpc_seq_t		rx_data_eaten;	/* last data seq ID consumed by recvmsg */
-	rxrpc_seq_t		rx_first_oos;	/* first packet in rx_oos_queue (or 0) */
-	rxrpc_seq_t		ackr_win_top;	/* top of ACK window (rx_data_eaten is bottom) */
-	rxrpc_seq_t		ackr_prev_seq;	/* previous sequence number received */
 	u8			ackr_reason;	/* reason to ACK */
 	u16			ackr_skew;	/* skew on packet being ACK'd */
 	rxrpc_serial_t		ackr_serial;	/* serial of packet being ACK'd */
-	atomic_t		ackr_not_idle;	/* number of packets in Rx queue */
+	rxrpc_seq_t		ackr_prev_seq;	/* previous sequence number received */
+	unsigned short		rx_pkt_offset;	/* Current recvmsg packet offset */
+	unsigned short		rx_pkt_len;	/* Current recvmsg packet len */
 
-	/* received packet records, 1 bit per record */
-#define RXRPC_ACKR_WINDOW_ASZ DIV_ROUND_UP(RXRPC_MAXACKS, BITS_PER_LONG)
-	unsigned long		ackr_window[RXRPC_ACKR_WINDOW_ASZ + 1];
+	/* transmission-phase ACK management */
+	rxrpc_serial_t		acks_latest;	/* serial number of latest ACK received */
 };
 
 enum rxrpc_call_trace {
@@ -535,10 +539,8 @@ enum rxrpc_call_trace {
 	rxrpc_call_queued_ref,
 	rxrpc_call_seen,
 	rxrpc_call_got,
-	rxrpc_call_got_skb,
 	rxrpc_call_got_userid,
 	rxrpc_call_put,
-	rxrpc_call_put_skb,
 	rxrpc_call_put_userid,
 	rxrpc_call_put_noqueue,
 	rxrpc_call__nr_trace
@@ -561,6 +563,9 @@ extern struct workqueue_struct *rxrpc_workqueue;
  */
 int rxrpc_service_prealloc(struct rxrpc_sock *, gfp_t);
 void rxrpc_discard_prealloc(struct rxrpc_sock *);
+struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *,
+					   struct rxrpc_connection *,
+					   struct sk_buff *);
 void rxrpc_accept_incoming_calls(struct rxrpc_local *);
 struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *, unsigned long,
 				     rxrpc_notify_rx_t);
@@ -569,8 +574,7 @@ int rxrpc_reject_call(struct rxrpc_sock *);
 /*
  * call_event.c
  */
-void __rxrpc_propose_ACK(struct rxrpc_call *, u8, u16, u32, bool);
-void rxrpc_propose_ACK(struct rxrpc_call *, u8, u16, u32, bool);
+void rxrpc_propose_ACK(struct rxrpc_call *, u8, u16, u32, bool, bool);
 void rxrpc_process_call(struct work_struct *);
 
 /*
@@ -589,9 +593,8 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
 					 struct rxrpc_conn_parameters *,
 					 struct sockaddr_rxrpc *,
 					 unsigned long, gfp_t);
-struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
-				       struct rxrpc_connection *,
-				       struct sk_buff *);
+void rxrpc_incoming_call(struct rxrpc_sock *, struct rxrpc_call *,
+			 struct sk_buff *);
 void rxrpc_release_call(struct rxrpc_sock *, struct rxrpc_call *);
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
 bool __rxrpc_queue_call(struct rxrpc_call *);
@@ -599,8 +602,6 @@ bool rxrpc_queue_call(struct rxrpc_call *);
 void rxrpc_see_call(struct rxrpc_call *);
 void rxrpc_get_call(struct rxrpc_call *, enum rxrpc_call_trace);
 void rxrpc_put_call(struct rxrpc_call *, enum rxrpc_call_trace);
-void rxrpc_get_call_for_skb(struct rxrpc_call *, struct sk_buff *);
-void rxrpc_put_call_for_skb(struct rxrpc_call *, struct sk_buff *);
 void rxrpc_cleanup_call(struct rxrpc_call *);
 void __exit rxrpc_destroy_all_calls(void);
 
@@ -672,13 +673,8 @@ static inline bool __rxrpc_abort_call(const char *why, struct rxrpc_call *call,
 {
 	trace_rxrpc_abort(why, call->cid, call->call_id, seq,
 			  abort_code, error);
-	if (__rxrpc_set_call_completion(call,
-					RXRPC_CALL_LOCALLY_ABORTED,
-					abort_code, error)) {
-		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
-		return true;
-	}
-	return false;
+	return __rxrpc_set_call_completion(call, RXRPC_CALL_LOCALLY_ABORTED,
+					   abort_code, error);
 }
 
 static inline bool rxrpc_abort_call(const char *why, struct rxrpc_call *call,
@@ -713,8 +709,6 @@ void __exit rxrpc_destroy_all_client_connections(void);
  * conn_event.c
  */
 void rxrpc_process_connection(struct work_struct *);
-void rxrpc_reject_packet(struct rxrpc_local *, struct sk_buff *);
-void rxrpc_reject_packets(struct rxrpc_local *);
 
 /*
  * conn_object.c
@@ -783,18 +777,14 @@ static inline bool rxrpc_queue_conn(struct rxrpc_connection *conn)
  */
 struct rxrpc_connection *rxrpc_find_service_conn_rcu(struct rxrpc_peer *,
 						     struct sk_buff *);
-struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *,
-						   struct sockaddr_rxrpc *,
-						   struct sk_buff *);
 struct rxrpc_connection *rxrpc_prealloc_service_connection(gfp_t);
+void rxrpc_new_incoming_connection(struct rxrpc_connection *, struct sk_buff *);
 void rxrpc_unpublish_service_conn(struct rxrpc_connection *);
 
 /*
  * input.c
  */
 void rxrpc_data_ready(struct sock *);
-int rxrpc_queue_rcv_skb(struct rxrpc_call *, struct sk_buff *, bool, bool);
-void rxrpc_fast_process_packet(struct rxrpc_call *, struct sk_buff *);
 
 /*
  * insecure.c
@@ -868,6 +858,7 @@ extern const char *rxrpc_acks(u8 reason);
  */
 int rxrpc_send_call_packet(struct rxrpc_call *, u8);
 int rxrpc_send_data_packet(struct rxrpc_connection *, struct sk_buff *);
+void rxrpc_reject_packets(struct rxrpc_local *);
 
 /*
  * peer_event.c
@@ -883,6 +874,8 @@ struct rxrpc_peer *rxrpc_lookup_peer_rcu(struct rxrpc_local *,
 struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *,
 				     struct sockaddr_rxrpc *, gfp_t);
 struct rxrpc_peer *rxrpc_alloc_peer(struct rxrpc_local *, gfp_t);
+struct rxrpc_peer *rxrpc_lookup_incoming_peer(struct rxrpc_local *,
+					      struct rxrpc_peer *);
 
 static inline struct rxrpc_peer *rxrpc_get_peer(struct rxrpc_peer *peer)
 {
@@ -912,6 +905,7 @@ extern const struct file_operations rxrpc_connection_seq_fops;
 /*
  * recvmsg.c
  */
+void rxrpc_notify_socket(struct rxrpc_call *);
 int rxrpc_recvmsg(struct socket *, struct msghdr *, size_t, int);
 
 /*
@@ -961,6 +955,23 @@ static inline void rxrpc_sysctl_exit(void) {}
  */
 int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *, struct sk_buff *);
 
+static inline bool before(u32 seq1, u32 seq2)
+{
+        return (s32)(seq1 - seq2) < 0;
+}
+static inline bool before_eq(u32 seq1, u32 seq2)
+{
+        return (s32)(seq1 - seq2) <= 0;
+}
+static inline bool after(u32 seq1, u32 seq2)
+{
+        return (s32)(seq1 - seq2) > 0;
+}
+static inline bool after_eq(u32 seq1, u32 seq2)
+{
+        return (s32)(seq1 - seq2) >= 0;
+}
+
 /*
  * debug tracing
  */
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index cc7194e05a15..b8acec0d596e 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -129,6 +129,8 @@ static int rxrpc_service_prealloc_one(struct rxrpc_sock *rx,
 		set_bit(RXRPC_CALL_HAS_USERID, &call->flags);
 	}
 
+	list_add(&call->sock_link, &rx->sock_calls);
+
 	write_unlock(&rx->call_lock);
 
 	write_lock(&rxrpc_call_lock);
@@ -186,6 +188,12 @@ void rxrpc_discard_prealloc(struct rxrpc_sock *rx)
 		return;
 	rx->backlog = NULL;
 
+	/* Make sure that there aren't any incoming calls in progress before we
+	 * clear the preallocation buffers.
+	 */
+	spin_lock_bh(&rx->incoming_lock);
+	spin_unlock_bh(&rx->incoming_lock);
+
 	head = b->peer_backlog_head;
 	tail = b->peer_backlog_tail;
 	while (CIRC_CNT(head, tail, size) > 0) {
@@ -224,251 +232,179 @@ void rxrpc_discard_prealloc(struct rxrpc_sock *rx)
 }
 
 /*
- * generate a connection-level abort
+ * Allocate a new incoming call from the prealloc pool, along with a connection
+ * and a peer as necessary.
  */
-static int rxrpc_busy(struct rxrpc_local *local, struct sockaddr_rxrpc *srx,
-		      struct rxrpc_wire_header *whdr)
+static struct rxrpc_call *rxrpc_alloc_incoming_call(struct rxrpc_sock *rx,
+						    struct rxrpc_local *local,
+						    struct rxrpc_connection *conn,
+						    struct sk_buff *skb)
 {
-	struct msghdr msg;
-	struct kvec iov[1];
-	size_t len;
-	int ret;
-
-	_enter("%d,,", local->debug_id);
-
-	whdr->type	= RXRPC_PACKET_TYPE_BUSY;
-	whdr->serial	= htonl(1);
-
-	msg.msg_name	= &srx->transport.sin;
-	msg.msg_namelen	= sizeof(srx->transport.sin);
-	msg.msg_control	= NULL;
-	msg.msg_controllen = 0;
-	msg.msg_flags	= 0;
-
-	iov[0].iov_base	= whdr;
-	iov[0].iov_len	= sizeof(*whdr);
-
-	len = iov[0].iov_len;
-
-	_proto("Tx BUSY %%1");
+	struct rxrpc_backlog *b = rx->backlog;
+	struct rxrpc_peer *peer, *xpeer;
+	struct rxrpc_call *call;
+	unsigned short call_head, conn_head, peer_head;
+	unsigned short call_tail, conn_tail, peer_tail;
+	unsigned short call_count, conn_count;
+
+	/* #calls >= #conns >= #peers must hold true. */
+	call_head = smp_load_acquire(&b->call_backlog_head);
+	call_tail = b->call_backlog_tail;
+	call_count = CIRC_CNT(call_head, call_tail, RXRPC_BACKLOG_MAX);
+	conn_head = smp_load_acquire(&b->conn_backlog_head);
+	conn_tail = b->conn_backlog_tail;
+	conn_count = CIRC_CNT(conn_head, conn_tail, RXRPC_BACKLOG_MAX);
+	ASSERTCMP(conn_count, >=, call_count);
+	peer_head = smp_load_acquire(&b->peer_backlog_head);
+	peer_tail = b->peer_backlog_tail;
+	ASSERTCMP(CIRC_CNT(peer_head, peer_tail, RXRPC_BACKLOG_MAX), >=,
+		  conn_count);
+
+	if (call_count == 0)
+		return NULL;
+
+	if (!conn) {
+		/* No connection.  We're going to need a peer to start off
+		 * with.  If one doesn't yet exist, use a spare from the
+		 * preallocation set.  We dump the address into the spare in
+		 * anticipation - and to save on stack space.
+		 */
+		xpeer = b->peer_backlog[peer_tail];
+		if (rxrpc_extract_addr_from_skb(&xpeer->srx, skb) < 0)
+			return NULL;
+
+		peer = rxrpc_lookup_incoming_peer(local, xpeer);
+		if (peer == xpeer) {
+			b->peer_backlog[peer_tail] = NULL;
+			smp_store_release(&b->peer_backlog_tail,
+					  (peer_tail + 1) &
+					  (RXRPC_BACKLOG_MAX - 1));
+		}
 
-	ret = kernel_sendmsg(local->socket, &msg, iov, 1, len);
-	if (ret < 0) {
-		_leave(" = -EAGAIN [sendmsg failed: %d]", ret);
-		return -EAGAIN;
+		/* Now allocate and set up the connection */
+		conn = b->conn_backlog[conn_tail];
+		b->conn_backlog[conn_tail] = NULL;
+		smp_store_release(&b->conn_backlog_tail,
+				  (conn_tail + 1) & (RXRPC_BACKLOG_MAX - 1));
+		rxrpc_get_local(local);
+		conn->params.local = local;
+		conn->params.peer = peer;
+		rxrpc_new_incoming_connection(conn, skb);
+	} else {
+		rxrpc_get_connection(conn);
 	}
 
-	_leave(" = 0");
-	return 0;
+	/* And now we can allocate and set up a new call */
+	call = b->call_backlog[call_tail];
+	b->call_backlog[call_tail] = NULL;
+	smp_store_release(&b->call_backlog_tail,
+			  (call_tail + 1) & (RXRPC_BACKLOG_MAX - 1));
+
+	call->conn = conn;
+	call->peer = rxrpc_get_peer(conn->params.peer);
+	return call;
 }
 
 /*
- * accept an incoming call that needs peer, transport and/or connection setting
- * up
+ * Set up a new incoming call.  Called in BH context with the RCU read lock
+ * held.
+ *
+ * If this is for a kernel service, when we allocate the call, it will have
+ * three refs on it: (1) the kernel service, (2) the user_call_ID tree, (3) the
+ * retainer ref obtained from the backlog buffer.  Prealloc calls for userspace
+ * services only have the ref from the backlog buffer.  We want to pass this
+ * ref to non-BH context to dispose of.
+ *
+ * If we want to report an error, we mark the skb with the packet type and
+ * abort code and return NULL.
  */
-static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
-				      struct rxrpc_sock *rx,
-				      struct sk_buff *skb,
-				      struct sockaddr_rxrpc *srx)
+struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *local,
+					   struct rxrpc_connection *conn,
+					   struct sk_buff *skb)
 {
-	struct rxrpc_connection *conn;
-	struct rxrpc_skb_priv *sp, *nsp;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct rxrpc_sock *rx;
 	struct rxrpc_call *call;
-	struct sk_buff *notification;
-	int ret;
 
 	_enter("");
 
-	sp = rxrpc_skb(skb);
-
-	/* get a notification message to send to the server app */
-	notification = alloc_skb(0, GFP_NOFS);
-	if (!notification) {
-		_debug("no memory");
-		ret = -ENOMEM;
-		goto error_nofree;
-	}
-	rxrpc_new_skb(notification);
-	notification->mark = RXRPC_SKB_MARK_NEW_CALL;
-
-	conn = rxrpc_incoming_connection(local, srx, skb);
-	if (IS_ERR(conn)) {
-		_debug("no conn");
-		ret = PTR_ERR(conn);
-		goto error;
-	}
-
-	call = rxrpc_incoming_call(rx, conn, skb);
-	rxrpc_put_connection(conn);
-	if (IS_ERR(call)) {
-		_debug("no call");
-		ret = PTR_ERR(call);
-		goto error;
+	/* Get the socket providing the service */
+	hlist_for_each_entry_rcu_bh(rx, &local->services, listen_link) {
+		if (rx->srx.srx_service == sp->hdr.serviceId)
+			goto found_service;
 	}
 
-	/* attach the call to the socket */
-	read_lock_bh(&local->services_lock);
-	if (rx->sk.sk_state == RXRPC_CLOSE)
-		goto invalid_service;
-
-	write_lock(&rx->call_lock);
-	if (!test_and_set_bit(RXRPC_CALL_INIT_ACCEPT, &call->flags)) {
-		rxrpc_get_call(call, rxrpc_call_got);
-
-		spin_lock(&call->conn->state_lock);
-		if (sp->hdr.securityIndex > 0 &&
-		    call->conn->state == RXRPC_CONN_SERVICE_UNSECURED) {
-			_debug("await conn sec");
-			list_add_tail(&call->accept_link, &rx->secureq);
-			call->conn->state = RXRPC_CONN_SERVICE_CHALLENGING;
-			set_bit(RXRPC_CONN_EV_CHALLENGE, &call->conn->events);
-			rxrpc_queue_conn(call->conn);
-		} else {
-			_debug("conn ready");
-			call->state = RXRPC_CALL_SERVER_ACCEPTING;
-			list_add_tail(&call->accept_link, &rx->acceptq);
-			rxrpc_get_call_for_skb(call, notification);
-			nsp = rxrpc_skb(notification);
-			nsp->call = call;
-
-			ASSERTCMP(atomic_read(&call->usage), >=, 3);
-
-			_debug("notify");
-			spin_lock(&call->lock);
-			ret = rxrpc_queue_rcv_skb(call, notification, true,
-						  false);
-			spin_unlock(&call->lock);
-			notification = NULL;
-			BUG_ON(ret < 0);
-		}
-		spin_unlock(&call->conn->state_lock);
+	trace_rxrpc_abort("INV", sp->hdr.cid, sp->hdr.callNumber, sp->hdr.seq,
+			  RX_INVALID_OPERATION, EOPNOTSUPP);
+	skb->mark = RXRPC_SKB_MARK_LOCAL_ABORT;
+	skb->priority = RX_INVALID_OPERATION;
+	_leave(" = NULL [service]");
+	return NULL;
 
-		_debug("queued");
+found_service:
+	spin_lock(&rx->incoming_lock);
+	if (rx->sk.sk_state == RXRPC_CLOSE) {
+		trace_rxrpc_abort("CLS", sp->hdr.cid, sp->hdr.callNumber,
+				  sp->hdr.seq, RX_INVALID_OPERATION, ESHUTDOWN);
+		skb->mark = RXRPC_SKB_MARK_LOCAL_ABORT;
+		skb->priority = RX_INVALID_OPERATION;
+		_leave(" = NULL [close]");
+		call = NULL;
+		goto out;
 	}
-	write_unlock(&rx->call_lock);
 
-	_debug("process");
-	rxrpc_fast_process_packet(call, skb);
-
-	_debug("done");
-	read_unlock_bh(&local->services_lock);
-	rxrpc_free_skb(notification);
-	rxrpc_put_call(call, rxrpc_call_put);
-	_leave(" = 0");
-	return 0;
-
-invalid_service:
-	_debug("invalid");
-	read_unlock_bh(&local->services_lock);
-
-	rxrpc_release_call(rx, call);
-	rxrpc_put_call(call, rxrpc_call_put);
-	ret = -ECONNREFUSED;
-error:
-	rxrpc_free_skb(notification);
-error_nofree:
-	_leave(" = %d", ret);
-	return ret;
-}
+	call = rxrpc_alloc_incoming_call(rx, local, conn, skb);
+	if (!call) {
+		skb->mark = RXRPC_SKB_MARK_BUSY;
+		_leave(" = NULL [busy]");
+		call = NULL;
+		goto out;
+	}
 
-/*
- * accept incoming calls that need peer, transport and/or connection setting up
- * - the packets we get are all incoming client DATA packets that have seq == 1
- */
-void rxrpc_accept_incoming_calls(struct rxrpc_local *local)
-{
-	struct rxrpc_skb_priv *sp;
-	struct sockaddr_rxrpc srx;
-	struct rxrpc_sock *rx;
-	struct rxrpc_wire_header whdr;
-	struct sk_buff *skb;
-	int ret;
+	/* Make the call live. */
+	rxrpc_incoming_call(rx, call, skb);
+	conn = call->conn;
 
-	_enter("%d", local->debug_id);
+	if (rx->notify_new_call)
+		rx->notify_new_call(&rx->sk, call, call->user_call_ID);
 
-	skb = skb_dequeue(&local->accept_queue);
-	if (!skb) {
-		_leave("\n");
-		return;
-	}
+	spin_lock(&conn->state_lock);
+	switch (conn->state) {
+	case RXRPC_CONN_SERVICE_UNSECURED:
+		conn->state = RXRPC_CONN_SERVICE_CHALLENGING;
+		set_bit(RXRPC_CONN_EV_CHALLENGE, &call->conn->events);
+		rxrpc_queue_conn(call->conn);
+		break;
 
-	_net("incoming call skb %p", skb);
-
-	rxrpc_see_skb(skb);
-	sp = rxrpc_skb(skb);
-
-	/* Set up a response packet header in case we need it */
-	whdr.epoch	= htonl(sp->hdr.epoch);
-	whdr.cid	= htonl(sp->hdr.cid);
-	whdr.callNumber	= htonl(sp->hdr.callNumber);
-	whdr.seq	= htonl(sp->hdr.seq);
-	whdr.serial	= 0;
-	whdr.flags	= 0;
-	whdr.type	= 0;
-	whdr.userStatus	= 0;
-	whdr.securityIndex = sp->hdr.securityIndex;
-	whdr._rsvd	= 0;
-	whdr.serviceId	= htons(sp->hdr.serviceId);
-
-	if (rxrpc_extract_addr_from_skb(&srx, skb) < 0)
-		goto drop;
-
-	/* get the socket providing the service */
-	read_lock_bh(&local->services_lock);
-	hlist_for_each_entry(rx, &local->services, listen_link) {
-		if (rx->srx.srx_service == sp->hdr.serviceId &&
-		    rx->sk.sk_state != RXRPC_CLOSE)
-			goto found_service;
-	}
-	read_unlock_bh(&local->services_lock);
-	goto invalid_service;
+	case RXRPC_CONN_SERVICE:
+		write_lock(&call->state_lock);
+		if (rx->discard_new_call)
+			call->state = RXRPC_CALL_SERVER_RECV_REQUEST;
+		else
+			call->state = RXRPC_CALL_SERVER_ACCEPTING;
+		write_unlock(&call->state_lock);
+		break;
 
-found_service:
-	_debug("found service %hd", rx->srx.srx_service);
-	if (sk_acceptq_is_full(&rx->sk))
-		goto backlog_full;
-	sk_acceptq_added(&rx->sk);
-	read_unlock_bh(&local->services_lock);
-
-	ret = rxrpc_accept_incoming_call(local, rx, skb, &srx);
-	if (ret < 0)
-		sk_acceptq_removed(&rx->sk);
-	switch (ret) {
-	case -ECONNRESET: /* old calls are ignored */
-	case -ECONNABORTED: /* aborted calls are reaborted or ignored */
-	case 0:
-		return;
-	case -ECONNREFUSED:
-		goto invalid_service;
-	case -EBUSY:
-		goto busy;
-	case -EKEYREJECTED:
-		goto security_mismatch;
+	case RXRPC_CONN_REMOTELY_ABORTED:
+		rxrpc_set_call_completion(call, RXRPC_CALL_REMOTELY_ABORTED,
+					  conn->remote_abort, ECONNABORTED);
+		break;
+	case RXRPC_CONN_LOCALLY_ABORTED:
+		rxrpc_abort_call("CON", call, sp->hdr.seq,
+				 conn->local_abort, ECONNABORTED);
+		break;
 	default:
 		BUG();
 	}
+	spin_unlock(&conn->state_lock);
 
-backlog_full:
-	read_unlock_bh(&local->services_lock);
-busy:
-	rxrpc_busy(local, &srx, &whdr);
-	rxrpc_free_skb(skb);
-	return;
-
-drop:
-	rxrpc_free_skb(skb);
-	return;
+	if (call->state == RXRPC_CALL_SERVER_ACCEPTING)
+		rxrpc_notify_socket(call);
 
-invalid_service:
-	skb->priority = RX_INVALID_OPERATION;
-	rxrpc_reject_packet(local, skb);
-	return;
-
-	/* can't change connection security type mid-flow */
-security_mismatch:
-	skb->priority = RX_PROTOCOL_ERROR;
-	rxrpc_reject_packet(local, skb);
-	return;
+	_leave(" = %p{%d}", call, call->debug_id);
+out:
+	spin_unlock(&rx->incoming_lock);
+	return call;
 }
 
 /*
@@ -490,11 +426,10 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	write_lock(&rx->call_lock);
 
 	ret = -ENODATA;
-	if (list_empty(&rx->acceptq))
+	if (list_empty(&rx->to_be_accepted))
 		goto out;
 
 	/* check the user ID isn't already in use */
-	ret = -EBADSLT;
 	pp = &rx->calls.rb_node;
 	parent = NULL;
 	while (*pp) {
@@ -506,11 +441,14 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 		else if (user_call_ID > call->user_call_ID)
 			pp = &(*pp)->rb_right;
 		else
-			goto out;
+			goto id_in_use;
 	}
 
-	/* dequeue the first call and check it's still valid */
-	call = list_entry(rx->acceptq.next, struct rxrpc_call, accept_link);
+	/* Dequeue the first call and check it's still valid.  We gain
+	 * responsibility for the queue's reference.
+	 */
+	call = list_entry(rx->to_be_accepted.next,
+			  struct rxrpc_call, accept_link);
 	list_del_init(&call->accept_link);
 	sk_acceptq_removed(&rx->sk);
 	rxrpc_see_call(call);
@@ -528,31 +466,35 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	}
 
 	/* formalise the acceptance */
-	rxrpc_get_call(call, rxrpc_call_got_userid);
+	rxrpc_get_call(call, rxrpc_call_got);
 	call->notify_rx = notify_rx;
 	call->user_call_ID = user_call_ID;
+	rxrpc_get_call(call, rxrpc_call_got_userid);
 	rb_link_node(&call->sock_node, parent, pp);
 	rb_insert_color(&call->sock_node, &rx->calls);
 	if (test_and_set_bit(RXRPC_CALL_HAS_USERID, &call->flags))
 		BUG();
-	if (test_and_set_bit(RXRPC_CALL_EV_ACCEPTED, &call->events))
-		BUG();
 
 	write_unlock_bh(&call->state_lock);
 	write_unlock(&rx->call_lock);
-	rxrpc_queue_call(call);
+	rxrpc_notify_socket(call);
+	rxrpc_service_prealloc(rx, GFP_KERNEL);
 	_leave(" = %p{%d}", call, call->debug_id);
 	return call;
 
 out_release:
+	_debug("release %p", call);
 	write_unlock_bh(&call->state_lock);
 	write_unlock(&rx->call_lock);
-	_debug("release %p", call);
 	rxrpc_release_call(rx, call);
-	_leave(" = %d", ret);
-	return ERR_PTR(ret);
-out:
+	rxrpc_put_call(call, rxrpc_call_put);
+	goto out;
+
+id_in_use:
+	ret = -EBADSLT;
 	write_unlock(&rx->call_lock);
+out:
+	rxrpc_service_prealloc(rx, GFP_KERNEL);
 	_leave(" = %d", ret);
 	return ERR_PTR(ret);
 }
@@ -564,6 +506,7 @@ out:
 int rxrpc_reject_call(struct rxrpc_sock *rx)
 {
 	struct rxrpc_call *call;
+	bool abort = false;
 	int ret;
 
 	_enter("");
@@ -572,15 +515,16 @@ int rxrpc_reject_call(struct rxrpc_sock *rx)
 
 	write_lock(&rx->call_lock);
 
-	ret = -ENODATA;
-	if (list_empty(&rx->acceptq)) {
+	if (list_empty(&rx->to_be_accepted)) {
 		write_unlock(&rx->call_lock);
-		_leave(" = -ENODATA");
 		return -ENODATA;
 	}
 
-	/* dequeue the first call and check it's still valid */
-	call = list_entry(rx->acceptq.next, struct rxrpc_call, accept_link);
+	/* Dequeue the first call and check it's still valid.  We gain
+	 * responsibility for the queue's reference.
+	 */
+	call = list_entry(rx->to_be_accepted.next,
+			  struct rxrpc_call, accept_link);
 	list_del_init(&call->accept_link);
 	sk_acceptq_removed(&rx->sk);
 	rxrpc_see_call(call);
@@ -588,66 +532,28 @@ int rxrpc_reject_call(struct rxrpc_sock *rx)
 	write_lock_bh(&call->state_lock);
 	switch (call->state) {
 	case RXRPC_CALL_SERVER_ACCEPTING:
-		__rxrpc_set_call_completion(call, RXRPC_CALL_SERVER_BUSY,
-					    0, ECONNABORTED);
-		if (test_and_set_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events))
-			rxrpc_queue_call(call);
-		ret = 0;
-		break;
+		__rxrpc_abort_call("REJ", call, 1, RX_USER_ABORT, ECONNABORTED);
+		abort = true;
+		/* fall through */
 	case RXRPC_CALL_COMPLETE:
 		ret = call->error;
-		break;
+		goto out_discard;
 	default:
 		BUG();
 	}
 
+out_discard:
 	write_unlock_bh(&call->state_lock);
 	write_unlock(&rx->call_lock);
-	rxrpc_release_call(rx, call);
-	_leave(" = %d", ret);
-	return ret;
-}
-
-/**
- * rxrpc_kernel_accept_call - Allow a kernel service to accept an incoming call
- * @sock: The socket on which the impending call is waiting
- * @user_call_ID: The tag to attach to the call
- * @notify_rx: Where to send notifications instead of socket queue
- *
- * Allow a kernel service to accept an incoming call, assuming the incoming
- * call is still valid.  The caller should immediately trigger their own
- * notification as there must be data waiting.
- */
-struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *sock,
-					    unsigned long user_call_ID,
-					    rxrpc_notify_rx_t notify_rx)
-{
-	struct rxrpc_call *call;
-
-	_enter(",%lx", user_call_ID);
-	call = rxrpc_accept_call(rxrpc_sk(sock->sk), user_call_ID, notify_rx);
-	_leave(" = %p", call);
-	return call;
-}
-EXPORT_SYMBOL(rxrpc_kernel_accept_call);
-
-/**
- * rxrpc_kernel_reject_call - Allow a kernel service to reject an incoming call
- * @sock: The socket on which the impending call is waiting
- *
- * Allow a kernel service to reject an incoming call with a BUSY message,
- * assuming the incoming call is still valid.
- */
-int rxrpc_kernel_reject_call(struct socket *sock)
-{
-	int ret;
-
-	_enter("");
-	ret = rxrpc_reject_call(rxrpc_sk(sock->sk));
+	if (abort) {
+		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+		rxrpc_release_call(rx, call);
+		rxrpc_put_call(call, rxrpc_call_put);
+	}
+	rxrpc_service_prealloc(rx, GFP_KERNEL);
 	_leave(" = %d", ret);
 	return ret;
 }
-EXPORT_SYMBOL(rxrpc_kernel_reject_call);
 
 /*
  * rxrpc_kernel_charge_accept - Charge up socket with preallocated calls
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index af88ad7d2cf9..2b976e789562 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -22,1257 +22,286 @@
 #include "ar-internal.h"
 
 /*
- * propose an ACK be sent
+ * Set the timer
  */
-void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
-			 u16 skew, u32 serial, bool immediate)
+static void rxrpc_set_timer(struct rxrpc_call *call)
 {
-	unsigned long expiry;
-	s8 prior = rxrpc_ack_priority[ack_reason];
-
-	ASSERTCMP(prior, >, 0);
-
-	_enter("{%d},%s,%%%x,%u",
-	       call->debug_id, rxrpc_acks(ack_reason), serial, immediate);
+	unsigned long t, now = jiffies;
 
-	if (prior < rxrpc_ack_priority[call->ackr_reason]) {
-		if (immediate)
-			goto cancel_timer;
-		return;
-	}
-
-	/* update DELAY, IDLE, REQUESTED and PING_RESPONSE ACK serial
-	 * numbers */
-	if (prior == rxrpc_ack_priority[call->ackr_reason]) {
-		if (prior <= 4) {
-			call->ackr_skew = skew;
-			call->ackr_serial = serial;
-		}
-		if (immediate)
-			goto cancel_timer;
-		return;
-	}
-
-	call->ackr_reason = ack_reason;
-	call->ackr_serial = serial;
-
-	switch (ack_reason) {
-	case RXRPC_ACK_DELAY:
-		_debug("run delay timer");
-		expiry = rxrpc_soft_ack_delay;
-		goto run_timer;
-
-	case RXRPC_ACK_IDLE:
-		if (!immediate) {
-			_debug("run defer timer");
-			expiry = rxrpc_idle_ack_delay;
-			goto run_timer;
-		}
-		goto cancel_timer;
+	_enter("{%ld,%ld,%ld:%ld}",
+	       call->ack_at - now, call->resend_at - now, call->expire_at - now,
+	       call->timer.expires - now);
+	
+	read_lock_bh(&call->state_lock);
 
-	case RXRPC_ACK_REQUESTED:
-		expiry = rxrpc_requested_ack_delay;
-		if (!expiry)
-			goto cancel_timer;
-		if (!immediate || serial == 1) {
-			_debug("run defer timer");
-			goto run_timer;
+	if (call->state < RXRPC_CALL_COMPLETE) {
+		t = call->ack_at;
+		if (time_before(call->resend_at, t))
+			t = call->resend_at;
+		if (time_before(call->expire_at, t))
+			t = call->expire_at;
+		if (!timer_pending(&call->timer) ||
+		    time_before(t, call->timer.expires)) {
+			_debug("set timer %ld", t - now);
+			mod_timer(&call->timer, t);
 		}
-
-	default:
-		_debug("immediate ACK");
-		goto cancel_timer;
 	}
-
-run_timer:
-	expiry += jiffies;
-	if (!timer_pending(&call->ack_timer) ||
-	    time_after(call->ack_timer.expires, expiry))
-		mod_timer(&call->ack_timer, expiry);
-	return;
-
-cancel_timer:
-	_debug("cancel timer %%%u", serial);
-	try_to_del_timer_sync(&call->ack_timer);
-	read_lock_bh(&call->state_lock);
-	if (call->state < RXRPC_CALL_COMPLETE &&
-	    !test_and_set_bit(RXRPC_CALL_EV_ACK, &call->events))
-		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
 
 /*
- * propose an ACK be sent, locking the call structure
+ * propose an ACK be sent
  */
-void rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
-		       u16 skew, u32 serial, bool immediate)
+static void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
+				u16 skew, u32 serial, bool immediate,
+				bool background)
 {
+	unsigned long now, ack_at, expiry = rxrpc_soft_ack_delay;
 	s8 prior = rxrpc_ack_priority[ack_reason];
 
-	if (prior > rxrpc_ack_priority[call->ackr_reason]) {
-		spin_lock_bh(&call->lock);
-		__rxrpc_propose_ACK(call, ack_reason, skew, serial, immediate);
-		spin_unlock_bh(&call->lock);
-	}
-}
-
-/*
- * set the resend timer
- */
-static void rxrpc_set_resend(struct rxrpc_call *call, u8 resend,
-			     unsigned long resend_at)
-{
-	read_lock_bh(&call->state_lock);
-	if (call->state == RXRPC_CALL_COMPLETE)
-		resend = 0;
-
-	if (resend & 1) {
-		_debug("SET RESEND");
-		set_bit(RXRPC_CALL_EV_RESEND, &call->events);
-	}
-
-	if (resend & 2) {
-		_debug("MODIFY RESEND TIMER");
-		set_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-		mod_timer(&call->resend_timer, resend_at);
-	} else {
-		_debug("KILL RESEND TIMER");
-		del_timer_sync(&call->resend_timer);
-		clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events);
-		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-	}
-	read_unlock_bh(&call->state_lock);
-}
-
-/*
- * resend packets
- */
-static void rxrpc_resend(struct rxrpc_call *call)
-{
-	struct rxrpc_wire_header *whdr;
-	struct rxrpc_skb_priv *sp;
-	struct sk_buff *txb;
-	unsigned long *p_txb, resend_at;
-	bool stop;
-	int loop;
-	u8 resend;
-
-	_enter("{%d,%d,%d,%d},",
-	       call->acks_hard, call->acks_unacked,
-	       atomic_read(&call->sequence),
-	       CIRC_CNT(call->acks_head, call->acks_tail, call->acks_winsz));
-
-	stop = false;
-	resend = 0;
-	resend_at = 0;
-
-	for (loop = call->acks_tail;
-	     loop != call->acks_head || stop;
-	     loop = (loop + 1) &  (call->acks_winsz - 1)
-	     ) {
-		p_txb = call->acks_window + loop;
-		smp_read_barrier_depends();
-		if (*p_txb & 1)
-			continue;
-
-		txb = (struct sk_buff *) *p_txb;
-		sp = rxrpc_skb(txb);
-
-		if (sp->need_resend) {
-			sp->need_resend = false;
-
-			/* each Tx packet has a new serial number */
-			sp->hdr.serial = atomic_inc_return(&call->conn->serial);
-
-			whdr = (struct rxrpc_wire_header *)txb->head;
-			whdr->serial = htonl(sp->hdr.serial);
-
-			_proto("Tx DATA %%%u { #%d }",
-			       sp->hdr.serial, sp->hdr.seq);
-			if (rxrpc_send_data_packet(call->conn, txb) < 0) {
-				stop = true;
-				sp->resend_at = jiffies + 3;
-			} else {
-				if (rxrpc_is_client_call(call))
-					rxrpc_expose_client_call(call);
-				sp->resend_at =
-					jiffies + rxrpc_resend_timeout;
-			}
-		}
-
-		if (time_after_eq(jiffies + 1, sp->resend_at)) {
-			sp->need_resend = true;
-			resend |= 1;
-		} else if (resend & 2) {
-			if (time_before(sp->resend_at, resend_at))
-				resend_at = sp->resend_at;
-		} else {
-			resend_at = sp->resend_at;
-			resend |= 2;
-		}
-	}
-
-	rxrpc_set_resend(call, resend, resend_at);
-	_leave("");
-}
-
-/*
- * handle resend timer expiry
- */
-static void rxrpc_resend_timer(struct rxrpc_call *call)
-{
-	struct rxrpc_skb_priv *sp;
-	struct sk_buff *txb;
-	unsigned long *p_txb, resend_at;
-	int loop;
-	u8 resend;
-
-	_enter("%d,%d,%d",
-	       call->acks_tail, call->acks_unacked, call->acks_head);
-
-	if (call->state == RXRPC_CALL_COMPLETE)
-		return;
-
-	resend = 0;
-	resend_at = 0;
-
-	for (loop = call->acks_unacked;
-	     loop != call->acks_head;
-	     loop = (loop + 1) &  (call->acks_winsz - 1)
-	     ) {
-		p_txb = call->acks_window + loop;
-		smp_read_barrier_depends();
-		txb = (struct sk_buff *) (*p_txb & ~1);
-		sp = rxrpc_skb(txb);
-
-		ASSERT(!(*p_txb & 1));
+	_enter("{%d},%s,%%%x,%u",
+	       call->debug_id, rxrpc_acks(ack_reason), serial, immediate);
 
-		if (sp->need_resend) {
-			;
-		} else if (time_after_eq(jiffies + 1, sp->resend_at)) {
-			sp->need_resend = true;
-			resend |= 1;
-		} else if (resend & 2) {
-			if (time_before(sp->resend_at, resend_at))
-				resend_at = sp->resend_at;
-		} else {
-			resend_at = sp->resend_at;
-			resend |= 2;
+	/* Update DELAY, IDLE, REQUESTED and PING_RESPONSE ACK serial
+	 * numbers, but we don't alter the timeout.
+	 */
+	_debug("prior %u %u vs %u %u",
+	       ack_reason, prior,
+	       call->ackr_reason, rxrpc_ack_priority[call->ackr_reason]);
+	if (ack_reason == call->ackr_reason) {
+		if (RXRPC_ACK_UPDATEABLE & (1 << ack_reason)) {
+			call->ackr_serial = serial;
+			call->ackr_skew = skew;
 		}
+		if (!immediate)
+			return;
+	} else if (prior > rxrpc_ack_priority[call->ackr_reason]) {
+		call->ackr_reason = ack_reason;
+		call->ackr_serial = serial;
+		call->ackr_skew = skew;
 	}
 
-	rxrpc_set_resend(call, resend, resend_at);
-	_leave("");
-}
-
-/*
- * process soft ACKs of our transmitted packets
- * - these indicate packets the peer has or has not received, but hasn't yet
- *   given to the consumer, and so can still be discarded and re-requested
- */
-static int rxrpc_process_soft_ACKs(struct rxrpc_call *call,
-				   struct rxrpc_ackpacket *ack,
-				   struct sk_buff *skb)
-{
-	struct rxrpc_skb_priv *sp;
-	struct sk_buff *txb;
-	unsigned long *p_txb, resend_at;
-	int loop;
-	u8 sacks[RXRPC_MAXACKS], resend;
-
-	_enter("{%d,%d},{%d},",
-	       call->acks_hard,
-	       CIRC_CNT(call->acks_head, call->acks_tail, call->acks_winsz),
-	       ack->nAcks);
+	switch (ack_reason) {
+	case RXRPC_ACK_REQUESTED:
+		if (rxrpc_requested_ack_delay < expiry)
+			expiry = rxrpc_requested_ack_delay;
+		if (serial == 1)
+			immediate = false;
+		break;
 
-	if (skb_copy_bits(skb, 0, sacks, ack->nAcks) < 0)
-		goto protocol_error;
+	case RXRPC_ACK_DELAY:
+		if (rxrpc_soft_ack_delay < expiry)
+			expiry = rxrpc_soft_ack_delay;
+		break;
 
-	resend = 0;
-	resend_at = 0;
-	for (loop = 0; loop < ack->nAcks; loop++) {
-		p_txb = call->acks_window;
-		p_txb += (call->acks_tail + loop) & (call->acks_winsz - 1);
-		smp_read_barrier_depends();
-		txb = (struct sk_buff *) (*p_txb & ~1);
-		sp = rxrpc_skb(txb);
+	case RXRPC_ACK_IDLE:
+		if (rxrpc_soft_ack_delay < expiry)
+			expiry = rxrpc_idle_ack_delay;
+		break;
 
-		switch (sacks[loop]) {
-		case RXRPC_ACK_TYPE_ACK:
-			sp->need_resend = false;
-			*p_txb |= 1;
-			break;
-		case RXRPC_ACK_TYPE_NACK:
-			sp->need_resend = true;
-			*p_txb &= ~1;
-			resend = 1;
-			break;
-		default:
-			_debug("Unsupported ACK type %d", sacks[loop]);
-			goto protocol_error;
-		}
+	default:
+		immediate = true;
+		break;
 	}
 
-	smp_mb();
-	call->acks_unacked = (call->acks_tail + loop) & (call->acks_winsz - 1);
-
-	/* anything not explicitly ACK'd is implicitly NACK'd, but may just not
-	 * have been received or processed yet by the far end */
-	for (loop = call->acks_unacked;
-	     loop != call->acks_head;
-	     loop = (loop + 1) &  (call->acks_winsz - 1)
-	     ) {
-		p_txb = call->acks_window + loop;
-		smp_read_barrier_depends();
-		txb = (struct sk_buff *) (*p_txb & ~1);
-		sp = rxrpc_skb(txb);
-
-		if (*p_txb & 1) {
-			/* packet must have been discarded */
-			sp->need_resend = true;
-			*p_txb &= ~1;
-			resend |= 1;
-		} else if (sp->need_resend) {
-			;
-		} else if (time_after_eq(jiffies + 1, sp->resend_at)) {
-			sp->need_resend = true;
-			resend |= 1;
-		} else if (resend & 2) {
-			if (time_before(sp->resend_at, resend_at))
-				resend_at = sp->resend_at;
-		} else {
-			resend_at = sp->resend_at;
-			resend |= 2;
+	now = jiffies;
+	if (test_bit(RXRPC_CALL_EV_ACK, &call->events)) {
+		_debug("already scheduled");
+	} else if (immediate || expiry == 0) {
+		_debug("immediate ACK %lx", call->events);
+		if (!test_and_set_bit(RXRPC_CALL_EV_ACK, &call->events) &&
+		    background)
+			rxrpc_queue_call(call);
+	} else {
+		ack_at = now + expiry;
+		_debug("deferred ACK %ld < %ld", expiry, call->ack_at - now);
+		if (time_before(ack_at, call->ack_at)) {
+			call->ack_at = ack_at;
+			rxrpc_set_timer(call);
 		}
 	}
-
-	rxrpc_set_resend(call, resend, resend_at);
-	_leave(" = 0");
-	return 0;
-
-protocol_error:
-	_leave(" = -EPROTO");
-	return -EPROTO;
 }
 
 /*
- * discard hard-ACK'd packets from the Tx window
- */
-static void rxrpc_rotate_tx_window(struct rxrpc_call *call, u32 hard)
-{
-	unsigned long _skb;
-	int tail = call->acks_tail, old_tail;
-	int win = CIRC_CNT(call->acks_head, tail, call->acks_winsz);
-
-	_enter("{%u,%u},%u", call->acks_hard, win, hard);
-
-	ASSERTCMP(hard - call->acks_hard, <=, win);
-
-	while (call->acks_hard < hard) {
-		smp_read_barrier_depends();
-		_skb = call->acks_window[tail] & ~1;
-		rxrpc_free_skb((struct sk_buff *) _skb);
-		old_tail = tail;
-		tail = (tail + 1) & (call->acks_winsz - 1);
-		call->acks_tail = tail;
-		if (call->acks_unacked == old_tail)
-			call->acks_unacked = tail;
-		call->acks_hard++;
-	}
-
-	wake_up(&call->waitq);
-}
-
-/*
- * clear the Tx window in the event of a failure
+ * propose an ACK be sent, locking the call structure
  */
-static void rxrpc_clear_tx_window(struct rxrpc_call *call)
+void rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
+		       u16 skew, u32 serial, bool immediate, bool background)
 {
-	rxrpc_rotate_tx_window(call, atomic_read(&call->sequence));
+	spin_lock_bh(&call->lock);
+	__rxrpc_propose_ACK(call, ack_reason, skew, serial,
+			    immediate, background);
+	spin_unlock_bh(&call->lock);
 }
 
 /*
- * drain the out of sequence received packet queue into the packet Rx queue
+ * Perform retransmission of NAK'd and unack'd packets.
  */
-static int rxrpc_drain_rx_oos_queue(struct rxrpc_call *call)
+static void rxrpc_resend(struct rxrpc_call *call)
 {
+	struct rxrpc_wire_header *whdr;
 	struct rxrpc_skb_priv *sp;
 	struct sk_buff *skb;
-	bool terminal;
-	int ret;
+	rxrpc_seq_t cursor, seq, top;
+	unsigned long resend_at, now;
+	int ix;
+	u8 annotation;
 
-	_enter("{%d,%d}", call->rx_data_post, call->rx_first_oos);
+	_enter("{%d,%d}", call->tx_hard_ack, call->tx_top);
 
 	spin_lock_bh(&call->lock);
 
-	ret = -ECONNRESET;
-	if (test_bit(RXRPC_CALL_RELEASED, &call->flags))
-		goto socket_unavailable;
+	cursor = call->tx_hard_ack;
+	top = call->tx_top;
+	ASSERT(before_eq(cursor, top));
+	if (cursor == top)
+		goto out_unlock;
+
+	/* Scan the packet list without dropping the lock and decide which of
+	 * the packets in the Tx buffer we're going to resend and what the new
+	 * resend timeout will be.
+	 */
+	now = jiffies;
+	resend_at = now + rxrpc_resend_timeout;
+	seq = cursor + 1;
+	do {
+		ix = seq & RXRPC_RXTX_BUFF_MASK;
+		annotation = call->rxtx_annotations[ix];
+		if (annotation == RXRPC_TX_ANNO_ACK)
+			continue;
 
-	skb = skb_dequeue(&call->rx_oos_queue);
-	if (skb) {
+		skb = call->rxtx_buffer[ix];
 		rxrpc_see_skb(skb);
 		sp = rxrpc_skb(skb);
 
-		_debug("drain OOS packet %d [%d]",
-		       sp->hdr.seq, call->rx_first_oos);
-
-		if (sp->hdr.seq != call->rx_first_oos) {
-			skb_queue_head(&call->rx_oos_queue, skb);
-			call->rx_first_oos = rxrpc_skb(skb)->hdr.seq;
-			_debug("requeue %p {%u}", skb, call->rx_first_oos);
-		} else {
-			skb->mark = RXRPC_SKB_MARK_DATA;
-			terminal = ((sp->hdr.flags & RXRPC_LAST_PACKET) &&
-				!(sp->hdr.flags & RXRPC_CLIENT_INITIATED));
-			ret = rxrpc_queue_rcv_skb(call, skb, true, terminal);
-			BUG_ON(ret < 0);
-			_debug("drain #%u", call->rx_data_post);
-			call->rx_data_post++;
-
-			/* find out what the next packet is */
-			skb = skb_peek(&call->rx_oos_queue);
-			rxrpc_see_skb(skb);
-			if (skb)
-				call->rx_first_oos = rxrpc_skb(skb)->hdr.seq;
-			else
-				call->rx_first_oos = 0;
-			_debug("peek %p {%u}", skb, call->rx_first_oos);
-		}
-	}
-
-	ret = 0;
-socket_unavailable:
-	spin_unlock_bh(&call->lock);
-	_leave(" = %d", ret);
-	return ret;
-}
-
-/*
- * insert an out of sequence packet into the buffer
- */
-static void rxrpc_insert_oos_packet(struct rxrpc_call *call,
-				    struct sk_buff *skb)
-{
-	struct rxrpc_skb_priv *sp, *psp;
-	struct sk_buff *p;
-	u32 seq;
-
-	sp = rxrpc_skb(skb);
-	seq = sp->hdr.seq;
-	_enter(",,{%u}", seq);
-
-	skb->destructor = rxrpc_packet_destructor;
-	ASSERTCMP(sp->call, ==, NULL);
-	sp->call = call;
-	rxrpc_get_call_for_skb(call, skb);
-
-	/* insert into the buffer in sequence order */
-	spin_lock_bh(&call->lock);
-
-	skb_queue_walk(&call->rx_oos_queue, p) {
-		psp = rxrpc_skb(p);
-		if (psp->hdr.seq > seq) {
-			_debug("insert oos #%u before #%u", seq, psp->hdr.seq);
-			skb_insert(p, skb, &call->rx_oos_queue);
-			goto inserted;
-		}
-	}
-
-	_debug("append oos #%u", seq);
-	skb_queue_tail(&call->rx_oos_queue, skb);
-inserted:
-
-	/* we might now have a new front to the queue */
-	if (call->rx_first_oos == 0 || seq < call->rx_first_oos)
-		call->rx_first_oos = seq;
-
-	read_lock(&call->state_lock);
-	if (call->state < RXRPC_CALL_COMPLETE &&
-	    call->rx_data_post == call->rx_first_oos) {
-		_debug("drain rx oos now");
-		set_bit(RXRPC_CALL_EV_DRAIN_RX_OOS, &call->events);
-	}
-	read_unlock(&call->state_lock);
-
-	spin_unlock_bh(&call->lock);
-	_leave(" [stored #%u]", call->rx_first_oos);
-}
-
-/*
- * clear the Tx window on final ACK reception
- */
-static void rxrpc_zap_tx_window(struct rxrpc_call *call)
-{
-	struct rxrpc_skb_priv *sp;
-	struct sk_buff *skb;
-	unsigned long _skb, *acks_window;
-	u8 winsz = call->acks_winsz;
-	int tail;
-
-	acks_window = call->acks_window;
-	call->acks_window = NULL;
-
-	while (CIRC_CNT(call->acks_head, call->acks_tail, winsz) > 0) {
-		tail = call->acks_tail;
-		smp_read_barrier_depends();
-		_skb = acks_window[tail] & ~1;
-		smp_mb();
-		call->acks_tail = (call->acks_tail + 1) & (winsz - 1);
-
-		skb = (struct sk_buff *) _skb;
-		sp = rxrpc_skb(skb);
-		_debug("+++ clear Tx %u", sp->hdr.seq);
-		rxrpc_free_skb(skb);
-	}
-
-	kfree(acks_window);
-}
-
-/*
- * process the extra information that may be appended to an ACK packet
- */
-static void rxrpc_extract_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
-				  unsigned int latest, int nAcks)
-{
-	struct rxrpc_ackinfo ackinfo;
-	struct rxrpc_peer *peer;
-	unsigned int mtu;
-
-	if (skb_copy_bits(skb, nAcks + 3, &ackinfo, sizeof(ackinfo)) < 0) {
-		_leave(" [no ackinfo]");
-		return;
-	}
-
-	_proto("Rx ACK %%%u Info { rx=%u max=%u rwin=%u jm=%u }",
-	       latest,
-	       ntohl(ackinfo.rxMTU), ntohl(ackinfo.maxMTU),
-	       ntohl(ackinfo.rwind), ntohl(ackinfo.jumbo_max));
-
-	mtu = min(ntohl(ackinfo.rxMTU), ntohl(ackinfo.maxMTU));
-
-	peer = call->peer;
-	if (mtu < peer->maxdata) {
-		spin_lock_bh(&peer->lock);
-		peer->maxdata = mtu;
-		peer->mtu = mtu + peer->hdrsize;
-		spin_unlock_bh(&peer->lock);
-		_net("Net MTU %u (maxdata %u)", peer->mtu, peer->maxdata);
-	}
-}
-
-/*
- * process packets in the reception queue
- */
-static int rxrpc_process_rx_queue(struct rxrpc_call *call,
-				  u32 *_abort_code)
-{
-	struct rxrpc_ackpacket ack;
-	struct rxrpc_skb_priv *sp;
-	struct sk_buff *skb;
-	bool post_ACK;
-	int latest;
-	u32 hard, tx;
-
-	_enter("");
-
-process_further:
-	skb = skb_dequeue(&call->rx_queue);
-	if (!skb)
-		return -EAGAIN;
-
-	rxrpc_see_skb(skb);
-	_net("deferred skb %p", skb);
-
-	sp = rxrpc_skb(skb);
-
-	_debug("process %s [st %d]", rxrpc_pkts[sp->hdr.type], call->state);
-
-	post_ACK = false;
-
-	switch (sp->hdr.type) {
-		/* data packets that wind up here have been received out of
-		 * order, need security processing or are jumbo packets */
-	case RXRPC_PACKET_TYPE_DATA:
-		_proto("OOSQ DATA %%%u { #%u }", sp->hdr.serial, sp->hdr.seq);
-
-		/* secured packets must be verified and possibly decrypted */
-		if (call->conn->security->verify_packet(call, skb,
-							sp->hdr.seq,
-							sp->hdr.cksum) < 0)
-			goto protocol_error;
-
-		rxrpc_insert_oos_packet(call, skb);
-		goto process_further;
-
-		/* partial ACK to process */
-	case RXRPC_PACKET_TYPE_ACK:
-		if (skb_copy_bits(skb, 0, &ack, sizeof(ack)) < 0) {
-			_debug("extraction failure");
-			goto protocol_error;
-		}
-		if (!skb_pull(skb, sizeof(ack)))
-			BUG();
-
-		latest = sp->hdr.serial;
-		hard = ntohl(ack.firstPacket);
-		tx = atomic_read(&call->sequence);
-
-		_proto("Rx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
-		       latest,
-		       ntohs(ack.maxSkew),
-		       hard,
-		       ntohl(ack.previousPacket),
-		       ntohl(ack.serial),
-		       rxrpc_acks(ack.reason),
-		       ack.nAcks);
-
-		rxrpc_extract_ackinfo(call, skb, latest, ack.nAcks);
-
-		if (ack.reason == RXRPC_ACK_PING) {
-			_proto("Rx ACK %%%u PING Request", latest);
-			rxrpc_propose_ACK(call, RXRPC_ACK_PING_RESPONSE,
-					  skb->priority, sp->hdr.serial, true);
-		}
-
-		/* discard any out-of-order or duplicate ACKs */
-		if (latest - call->acks_latest <= 0) {
-			_debug("discard ACK %d <= %d",
-			       latest, call->acks_latest);
-			goto discard;
-		}
-		call->acks_latest = latest;
-
-		if (call->state != RXRPC_CALL_CLIENT_SEND_REQUEST &&
-		    call->state != RXRPC_CALL_CLIENT_AWAIT_REPLY &&
-		    call->state != RXRPC_CALL_SERVER_SEND_REPLY &&
-		    call->state != RXRPC_CALL_SERVER_AWAIT_ACK)
-			goto discard;
-
-		_debug("Tx=%d H=%u S=%d", tx, call->acks_hard, call->state);
-
-		if (hard > 0) {
-			if (hard - 1 > tx) {
-				_debug("hard-ACK'd packet %d not transmitted"
-				       " (%d top)",
-				       hard - 1, tx);
-				goto protocol_error;
-			}
-
-			if ((call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY ||
-			     call->state == RXRPC_CALL_SERVER_AWAIT_ACK) &&
-			    hard > tx) {
-				call->acks_hard = tx;
-				goto all_acked;
+		if (annotation == RXRPC_TX_ANNO_UNACK) {
+			if (time_after(sp->resend_at, now)) {
+				if (time_before(sp->resend_at, resend_at))
+					resend_at = sp->resend_at;
+				continue;
 			}
-
-			smp_rmb();
-			rxrpc_rotate_tx_window(call, hard - 1);
-		}
-
-		if (ack.nAcks > 0) {
-			if (hard - 1 + ack.nAcks > tx) {
-				_debug("soft-ACK'd packet %d+%d not"
-				       " transmitted (%d top)",
-				       hard - 1, ack.nAcks, tx);
-				goto protocol_error;
-			}
-
-			if (rxrpc_process_soft_ACKs(call, &ack, skb) < 0)
-				goto protocol_error;
 		}
-		goto discard;
 
-		/* complete ACK to process */
-	case RXRPC_PACKET_TYPE_ACKALL:
-		goto all_acked;
-
-		/* abort and busy are handled elsewhere */
-	case RXRPC_PACKET_TYPE_BUSY:
-	case RXRPC_PACKET_TYPE_ABORT:
-		BUG();
-
-		/* connection level events - also handled elsewhere */
-	case RXRPC_PACKET_TYPE_CHALLENGE:
-	case RXRPC_PACKET_TYPE_RESPONSE:
-	case RXRPC_PACKET_TYPE_DEBUG:
-		BUG();
-	}
-
-	/* if we've had a hard ACK that covers all the packets we've sent, then
-	 * that ends that phase of the operation */
-all_acked:
-	write_lock_bh(&call->state_lock);
-	_debug("ack all %d", call->state);
-
-	switch (call->state) {
-	case RXRPC_CALL_CLIENT_AWAIT_REPLY:
-		call->state = RXRPC_CALL_CLIENT_RECV_REPLY;
-		break;
-	case RXRPC_CALL_SERVER_AWAIT_ACK:
-		_debug("srv complete");
-		__rxrpc_call_completed(call);
-		post_ACK = true;
-		break;
-	case RXRPC_CALL_CLIENT_SEND_REQUEST:
-	case RXRPC_CALL_SERVER_RECV_REQUEST:
-		goto protocol_error_unlock; /* can't occur yet */
-	default:
-		write_unlock_bh(&call->state_lock);
-		goto discard; /* assume packet left over from earlier phase */
-	}
-
-	write_unlock_bh(&call->state_lock);
-
-	/* if all the packets we sent are hard-ACK'd, then we can discard
-	 * whatever we've got left */
-	_debug("clear Tx %d",
-	       CIRC_CNT(call->acks_head, call->acks_tail, call->acks_winsz));
-
-	del_timer_sync(&call->resend_timer);
-	clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-	clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events);
-
-	if (call->acks_window)
-		rxrpc_zap_tx_window(call);
+		/* Okay, we need to retransmit a packet. */
+		call->rxtx_annotations[ix] = RXRPC_TX_ANNO_RETRANS;
+		seq++;
+	} while (before_eq(seq, top));
+
+	call->resend_at = resend_at;
+
+	/* Now go through the Tx window and perform the retransmissions.  We
+	 * have to drop the lock for each send.  If an ACK comes in whilst the
+	 * lock is dropped, it may clear some of the retransmission markers for
+	 * packets that it soft-ACKs.
+	 */
+	seq = cursor + 1;
+	do {
+		ix = seq & RXRPC_RXTX_BUFF_MASK;
+		annotation = call->rxtx_annotations[ix];
+		if (annotation != RXRPC_TX_ANNO_RETRANS)
+			continue;
 
-	if (post_ACK) {
-		/* post the final ACK message for userspace to pick up */
-		_debug("post ACK");
-		skb->mark = RXRPC_SKB_MARK_FINAL_ACK;
-		sp->call = call;
-		rxrpc_get_call_for_skb(call, skb);
-		spin_lock_bh(&call->lock);
-		if (rxrpc_queue_rcv_skb(call, skb, true, true) < 0)
-			BUG();
+		skb = call->rxtx_buffer[ix];
+		rxrpc_get_skb(skb);
 		spin_unlock_bh(&call->lock);
-		goto process_further;
-	}
-
-discard:
-	rxrpc_free_skb(skb);
-	goto process_further;
-
-protocol_error_unlock:
-	write_unlock_bh(&call->state_lock);
-protocol_error:
-	rxrpc_free_skb(skb);
-	_leave(" = -EPROTO");
-	return -EPROTO;
-}
-
-/*
- * post a message to the socket Rx queue for recvmsg() to pick up
- */
-static int rxrpc_post_message(struct rxrpc_call *call, u32 mark, u32 error,
-			      bool fatal)
-{
-	struct rxrpc_skb_priv *sp;
-	struct sk_buff *skb;
-	int ret;
-
-	_enter("{%d,%lx},%u,%u,%d",
-	       call->debug_id, call->flags, mark, error, fatal);
-
-	/* remove timers and things for fatal messages */
-	if (fatal) {
-		del_timer_sync(&call->resend_timer);
-		del_timer_sync(&call->ack_timer);
-		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-	}
+		sp = rxrpc_skb(skb);
 
-	if (mark != RXRPC_SKB_MARK_NEW_CALL &&
-	    !test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
-		_leave("[no userid]");
-		return 0;
-	}
+		/* Each Tx packet needs a new serial number */
+		sp->hdr.serial = atomic_inc_return(&call->conn->serial);
 
-	if (!test_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags)) {
-		skb = alloc_skb(0, GFP_NOFS);
-		if (!skb)
-			return -ENOMEM;
+		whdr = (struct rxrpc_wire_header *)skb->head;
+		whdr->serial = htonl(sp->hdr.serial);
 
-		rxrpc_new_skb(skb);
+		if (rxrpc_send_data_packet(call->conn, skb) < 0) {
+			call->resend_at = now + 2;
+			rxrpc_free_skb(skb);
+			return;
+		}
 
-		skb->mark = mark;
-
-		sp = rxrpc_skb(skb);
-		memset(sp, 0, sizeof(*sp));
-		sp->error = error;
-		sp->call = call;
-		rxrpc_get_call_for_skb(call, skb);
+		if (rxrpc_is_client_call(call))
+			rxrpc_expose_client_call(call);
+		sp->resend_at = now + rxrpc_resend_timeout;
 
+		rxrpc_free_skb(skb);
 		spin_lock_bh(&call->lock);
-		ret = rxrpc_queue_rcv_skb(call, skb, true, fatal);
-		spin_unlock_bh(&call->lock);
-		BUG_ON(ret < 0);
-	}
 
-	return 0;
+		/* We need to clear the retransmit state, but there are two
+		 * things we need to be aware of: A new ACK/NAK might have been
+		 * received and the packet might have been hard-ACK'd (in which
+		 * case it will no longer be in the buffer).
+		 */
+		if (after(seq, call->tx_hard_ack) &&
+		    (call->rxtx_annotations[ix] == RXRPC_TX_ANNO_RETRANS ||
+		     call->rxtx_annotations[ix] == RXRPC_TX_ANNO_NAK))
+			call->rxtx_annotations[ix] = RXRPC_TX_ANNO_UNACK;
+
+		if (after(call->tx_hard_ack, seq))
+			seq = call->tx_hard_ack;
+		seq++;
+	} while (before_eq(seq, top));
+
+out_unlock:
+	spin_unlock_bh(&call->lock);
+	_leave("");
 }
 
 /*
- * Handle background processing of incoming call packets and ACK / abort
- * generation.  A ref on the call is donated to us by whoever queued the work
- * item.
+ * Handle retransmission and deferred ACK/abort generation.
  */
 void rxrpc_process_call(struct work_struct *work)
 {
 	struct rxrpc_call *call =
 		container_of(work, struct rxrpc_call, processor);
-	struct rxrpc_wire_header whdr;
-	struct rxrpc_ackpacket ack;
-	struct rxrpc_ackinfo ackinfo;
-	struct msghdr msg;
-	struct kvec iov[5];
-	enum rxrpc_call_event genbit;
-	unsigned long bits;
-	__be32 data, pad;
-	size_t len;
-	bool requeue = false;
-	int loop, nbit, ioc, ret, mtu;
-	u32 serial, abort_code = RX_PROTOCOL_ERROR;
-	u8 *acks = NULL;
+	unsigned long now;
 
 	rxrpc_see_call(call);
 
 	//printk("\n--------------------\n");
-	_enter("{%d,%s,%lx} [%lu]",
-	       call->debug_id, rxrpc_call_states[call->state], call->events,
-	       (jiffies - call->creation_jif) / (HZ / 10));
-
-	if (call->state >= RXRPC_CALL_COMPLETE) {
-		rxrpc_put_call(call, rxrpc_call_put);
-		return;
-	}
-
-	if (!call->conn)
-		goto skip_msg_init;
-
-	/* there's a good chance we're going to have to send a message, so set
-	 * one up in advance */
-	msg.msg_name	= &call->peer->srx.transport;
-	msg.msg_namelen	= call->peer->srx.transport_len;
-	msg.msg_control	= NULL;
-	msg.msg_controllen = 0;
-	msg.msg_flags	= 0;
+	_enter("{%d,%s,%lx}",
+	       call->debug_id, rxrpc_call_states[call->state], call->events);
 
-	whdr.epoch	= htonl(call->conn->proto.epoch);
-	whdr.cid	= htonl(call->cid);
-	whdr.callNumber	= htonl(call->call_id);
-	whdr.seq	= 0;
-	whdr.type	= RXRPC_PACKET_TYPE_ACK;
-	whdr.flags	= call->conn->out_clientflag;
-	whdr.userStatus	= 0;
-	whdr.securityIndex = call->conn->security_ix;
-	whdr._rsvd	= 0;
-	whdr.serviceId	= htons(call->service_id);
-
-	memset(iov, 0, sizeof(iov));
-	iov[0].iov_base	= &whdr;
-	iov[0].iov_len	= sizeof(whdr);
-skip_msg_init:
-
-	/* deal with events of a final nature */
-	if (test_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events)) {
-		enum rxrpc_skb_mark mark;
-
-		clear_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events);
-		clear_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events);
-		clear_bit(RXRPC_CALL_EV_ABORT, &call->events);
-
-		if (call->completion == RXRPC_CALL_NETWORK_ERROR) {
-			mark = RXRPC_SKB_MARK_NET_ERROR;
-			_debug("post net error %d", call->error);
-		} else {
-			mark = RXRPC_SKB_MARK_LOCAL_ERROR;
-			_debug("post net local error %d", call->error);
-		}
-
-		if (rxrpc_post_message(call, mark, call->error, true) < 0)
-			goto no_mem;
-		clear_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events);
-		goto kill_ACKs;
-	}
-
-	if (test_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events)) {
-		ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
-
-		clear_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events);
-		clear_bit(RXRPC_CALL_EV_ABORT, &call->events);
-
-		_debug("post conn abort");
-
-		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
-				       call->error, true) < 0)
-			goto no_mem;
-		clear_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events);
-		goto kill_ACKs;
-	}
-
-	if (test_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events)) {
-		whdr.type = RXRPC_PACKET_TYPE_BUSY;
-		genbit = RXRPC_CALL_EV_REJECT_BUSY;
-		goto send_message;
-	}
-
-	if (test_bit(RXRPC_CALL_EV_ABORT, &call->events)) {
-		ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
-
-		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
-				       call->error, true) < 0)
-			goto no_mem;
-		whdr.type = RXRPC_PACKET_TYPE_ABORT;
-		data = htonl(call->abort_code);
-		iov[1].iov_base = &data;
-		iov[1].iov_len = sizeof(data);
-		genbit = RXRPC_CALL_EV_ABORT;
-		goto send_message;
-	}
-
-	if (test_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events)) {
-		genbit = RXRPC_CALL_EV_ACK_FINAL;
-
-		ack.bufferSpace	= htons(8);
-		ack.maxSkew	= 0;
-		ack.serial	= 0;
-		ack.reason	= RXRPC_ACK_IDLE;
-		ack.nAcks	= 0;
-		call->ackr_reason = 0;
-
-		spin_lock_bh(&call->lock);
-		ack.serial	= htonl(call->ackr_serial);
-		ack.previousPacket = htonl(call->ackr_prev_seq);
-		ack.firstPacket	= htonl(call->rx_data_eaten + 1);
-		spin_unlock_bh(&call->lock);
-
-		pad = 0;
-
-		iov[1].iov_base = &ack;
-		iov[1].iov_len	= sizeof(ack);
-		iov[2].iov_base = &pad;
-		iov[2].iov_len	= 3;
-		iov[3].iov_base = &ackinfo;
-		iov[3].iov_len	= sizeof(ackinfo);
-		goto send_ACK;
+recheck_state:
+	if (test_and_clear_bit(RXRPC_CALL_EV_ABORT, &call->events)) {
+		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+		goto recheck_state;
 	}
 
-	if (call->events & ((1 << RXRPC_CALL_EV_RCVD_BUSY) |
-			    (1 << RXRPC_CALL_EV_RCVD_ABORT))
-	    ) {
-		u32 mark;
-
-		if (test_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events))
-			mark = RXRPC_SKB_MARK_REMOTE_ABORT;
-		else
-			mark = RXRPC_SKB_MARK_BUSY;
-
-		_debug("post abort/busy");
-		rxrpc_clear_tx_window(call);
-		if (rxrpc_post_message(call, mark, ECONNABORTED, true) < 0)
-			goto no_mem;
-
-		clear_bit(RXRPC_CALL_EV_RCVD_BUSY, &call->events);
-		clear_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
-		goto kill_ACKs;
+	if (call->state == RXRPC_CALL_COMPLETE) {
+		del_timer_sync(&call->timer);
+		goto out_put;
 	}
 
-	if (test_and_clear_bit(RXRPC_CALL_EV_RCVD_ACKALL, &call->events)) {
-		_debug("do implicit ackall");
-		rxrpc_clear_tx_window(call);
-	}
-
-	if (test_bit(RXRPC_CALL_EV_LIFE_TIMER, &call->events)) {
+	now = jiffies;
+	if (time_after_eq(now, call->expire_at)) {
 		rxrpc_abort_call("EXP", call, 0, RX_CALL_TIMEOUT, ETIME);
-
-		_debug("post timeout");
-		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
-				       ETIME, true) < 0)
-			goto no_mem;
-
-		clear_bit(RXRPC_CALL_EV_LIFE_TIMER, &call->events);
-		goto kill_ACKs;
+		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 	}
 
-	/* deal with assorted inbound messages */
-	if (!skb_queue_empty(&call->rx_queue)) {
-		ret = rxrpc_process_rx_queue(call, &abort_code);
-		switch (ret) {
-		case 0:
-		case -EAGAIN:
-			break;
-		case -ENOMEM:
-			goto no_mem;
-		case -EKEYEXPIRED:
-		case -EKEYREJECTED:
-		case -EPROTO:
-			rxrpc_abort_call("PRO", call, 0, abort_code, -ret);
-			goto kill_ACKs;
+	if (test_and_clear_bit(RXRPC_CALL_EV_ACK, &call->events) ||
+	    time_after_eq(now, call->ack_at)) {
+		call->ack_at = call->expire_at;
+		if (call->ackr_reason) {
+			rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+			goto recheck_state;
 		}
 	}
 
-	/* handle resending */
-	if (test_and_clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events))
-		rxrpc_resend_timer(call);
-	if (test_and_clear_bit(RXRPC_CALL_EV_RESEND, &call->events))
+	if (test_and_clear_bit(RXRPC_CALL_EV_RESEND, &call->events) ||
+	    time_after_eq(now, call->resend_at)) {
 		rxrpc_resend(call);
-
-	/* consider sending an ordinary ACK */
-	if (test_bit(RXRPC_CALL_EV_ACK, &call->events)) {
-		_debug("send ACK: window: %d - %d { %lx }",
-		       call->rx_data_eaten, call->ackr_win_top,
-		       call->ackr_window[0]);
-
-		if (call->state > RXRPC_CALL_SERVER_ACK_REQUEST &&
-		    call->ackr_reason != RXRPC_ACK_PING_RESPONSE) {
-			/* ACK by sending reply DATA packet in this state */
-			clear_bit(RXRPC_CALL_EV_ACK, &call->events);
-			goto maybe_reschedule;
-		}
-
-		genbit = RXRPC_CALL_EV_ACK;
-
-		acks = kzalloc(call->ackr_win_top - call->rx_data_eaten,
-			       GFP_NOFS);
-		if (!acks)
-			goto no_mem;
-
-		//hdr.flags	= RXRPC_SLOW_START_OK;
-		ack.bufferSpace	= htons(8);
-		ack.maxSkew	= 0;
-
-		spin_lock_bh(&call->lock);
-		ack.reason	= call->ackr_reason;
-		ack.serial	= htonl(call->ackr_serial);
-		ack.previousPacket = htonl(call->ackr_prev_seq);
-		ack.firstPacket = htonl(call->rx_data_eaten + 1);
-
-		ack.nAcks = 0;
-		for (loop = 0; loop < RXRPC_ACKR_WINDOW_ASZ; loop++) {
-			nbit = loop * BITS_PER_LONG;
-			for (bits = call->ackr_window[loop]; bits; bits >>= 1
-			     ) {
-				_debug("- l=%d n=%d b=%lx", loop, nbit, bits);
-				if (bits & 1) {
-					acks[nbit] = RXRPC_ACK_TYPE_ACK;
-					ack.nAcks = nbit + 1;
-				}
-				nbit++;
-			}
-		}
-		call->ackr_reason = 0;
-		spin_unlock_bh(&call->lock);
-
-		pad = 0;
-
-		iov[1].iov_base = &ack;
-		iov[1].iov_len	= sizeof(ack);
-		iov[2].iov_base = acks;
-		iov[2].iov_len	= ack.nAcks;
-		iov[3].iov_base = &pad;
-		iov[3].iov_len	= 3;
-		iov[4].iov_base = &ackinfo;
-		iov[4].iov_len	= sizeof(ackinfo);
-
-		switch (ack.reason) {
-		case RXRPC_ACK_REQUESTED:
-		case RXRPC_ACK_DUPLICATE:
-		case RXRPC_ACK_OUT_OF_SEQUENCE:
-		case RXRPC_ACK_EXCEEDS_WINDOW:
-		case RXRPC_ACK_NOSPACE:
-		case RXRPC_ACK_PING:
-		case RXRPC_ACK_PING_RESPONSE:
-			goto send_ACK_with_skew;
-		case RXRPC_ACK_DELAY:
-		case RXRPC_ACK_IDLE:
-			goto send_ACK;
-		}
+		goto recheck_state;
 	}
 
-	/* handle completion of security negotiations on an incoming
-	 * connection */
-	if (test_and_clear_bit(RXRPC_CALL_EV_SECURED, &call->events)) {
-		_debug("secured");
-		spin_lock_bh(&call->lock);
-
-		if (call->state == RXRPC_CALL_SERVER_SECURING) {
-			struct rxrpc_sock *rx;
-			_debug("securing");
-			rcu_read_lock();
-			rx = rcu_dereference(call->socket);
-			if (rx) {
-				write_lock(&rx->call_lock);
-				if (!test_bit(RXRPC_CALL_RELEASED, &call->flags)) {
-					_debug("not released");
-					call->state = RXRPC_CALL_SERVER_ACCEPTING;
-					list_move_tail(&call->accept_link,
-						       &rx->acceptq);
-				}
-				write_unlock(&rx->call_lock);
-			}
-			rcu_read_unlock();
-			read_lock(&call->state_lock);
-			if (call->state < RXRPC_CALL_COMPLETE)
-				set_bit(RXRPC_CALL_EV_POST_ACCEPT, &call->events);
-			read_unlock(&call->state_lock);
-		}
-
-		spin_unlock_bh(&call->lock);
-		if (!test_bit(RXRPC_CALL_EV_POST_ACCEPT, &call->events))
-			goto maybe_reschedule;
-	}
-
-	/* post a notification of an acceptable connection to the app */
-	if (test_bit(RXRPC_CALL_EV_POST_ACCEPT, &call->events)) {
-		_debug("post accept");
-		if (rxrpc_post_message(call, RXRPC_SKB_MARK_NEW_CALL,
-				       0, false) < 0)
-			goto no_mem;
-		clear_bit(RXRPC_CALL_EV_POST_ACCEPT, &call->events);
-		goto maybe_reschedule;
-	}
-
-	/* handle incoming call acceptance */
-	if (test_and_clear_bit(RXRPC_CALL_EV_ACCEPTED, &call->events)) {
-		_debug("accepted");
-		ASSERTCMP(call->rx_data_post, ==, 0);
-		call->rx_data_post = 1;
-		read_lock_bh(&call->state_lock);
-		if (call->state < RXRPC_CALL_COMPLETE)
-			set_bit(RXRPC_CALL_EV_DRAIN_RX_OOS, &call->events);
-		read_unlock_bh(&call->state_lock);
-	}
-
-	/* drain the out of sequence received packet queue into the packet Rx
-	 * queue */
-	if (test_and_clear_bit(RXRPC_CALL_EV_DRAIN_RX_OOS, &call->events)) {
-		while (call->rx_data_post == call->rx_first_oos)
-			if (rxrpc_drain_rx_oos_queue(call) < 0)
-				break;
-		goto maybe_reschedule;
-	}
+	rxrpc_set_timer(call);
 
 	/* other events may have been raised since we started checking */
-	goto maybe_reschedule;
-
-send_ACK_with_skew:
-	ack.maxSkew = htons(call->ackr_skew);
-send_ACK:
-	mtu = call->peer->if_mtu;
-	mtu -= call->peer->hdrsize;
-	ackinfo.maxMTU	= htonl(mtu);
-	ackinfo.rwind	= htonl(rxrpc_rx_window_size);
-
-	/* permit the peer to send us jumbo packets if it wants to */
-	ackinfo.rxMTU	= htonl(rxrpc_rx_mtu);
-	ackinfo.jumbo_max = htonl(rxrpc_rx_jumbo_max);
-
-	serial = atomic_inc_return(&call->conn->serial);
-	whdr.serial = htonl(serial);
-	_proto("Tx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
-	       serial,
-	       ntohs(ack.maxSkew),
-	       ntohl(ack.firstPacket),
-	       ntohl(ack.previousPacket),
-	       ntohl(ack.serial),
-	       rxrpc_acks(ack.reason),
-	       ack.nAcks);
-
-	del_timer_sync(&call->ack_timer);
-	if (ack.nAcks > 0)
-		set_bit(RXRPC_CALL_TX_SOFT_ACK, &call->flags);
-	goto send_message_2;
-
-send_message:
-	_debug("send message");
-
-	serial = atomic_inc_return(&call->conn->serial);
-	whdr.serial = htonl(serial);
-	_proto("Tx %s %%%u", rxrpc_pkts[whdr.type], serial);
-send_message_2:
-
-	len = iov[0].iov_len;
-	ioc = 1;
-	if (iov[4].iov_len) {
-		ioc = 5;
-		len += iov[4].iov_len;
-		len += iov[3].iov_len;
-		len += iov[2].iov_len;
-		len += iov[1].iov_len;
-	} else if (iov[3].iov_len) {
-		ioc = 4;
-		len += iov[3].iov_len;
-		len += iov[2].iov_len;
-		len += iov[1].iov_len;
-	} else if (iov[2].iov_len) {
-		ioc = 3;
-		len += iov[2].iov_len;
-		len += iov[1].iov_len;
-	} else if (iov[1].iov_len) {
-		ioc = 2;
-		len += iov[1].iov_len;
-	}
-
-	ret = kernel_sendmsg(call->conn->params.local->socket,
-			     &msg, iov, ioc, len);
-	if (ret < 0) {
-		_debug("sendmsg failed: %d", ret);
-		if (call->state < RXRPC_CALL_COMPLETE)
-			requeue = true;
-		goto error;
-	}
-
-	switch (genbit) {
-	case RXRPC_CALL_EV_ABORT:
-		clear_bit(genbit, &call->events);
-		clear_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
-		goto kill_ACKs;
-
-	case RXRPC_CALL_EV_ACK_FINAL:
-		rxrpc_call_completed(call);
-		goto kill_ACKs;
-
-	default:
-		clear_bit(genbit, &call->events);
-		switch (call->state) {
-		case RXRPC_CALL_CLIENT_AWAIT_REPLY:
-		case RXRPC_CALL_CLIENT_RECV_REPLY:
-		case RXRPC_CALL_SERVER_RECV_REQUEST:
-		case RXRPC_CALL_SERVER_ACK_REQUEST:
-			_debug("start ACK timer");
-			rxrpc_propose_ACK(call, RXRPC_ACK_DELAY,
-					  call->ackr_skew, call->ackr_serial,
-					  false);
-		default:
-			break;
-		}
-		goto maybe_reschedule;
-	}
-
-kill_ACKs:
-	del_timer_sync(&call->ack_timer);
-	clear_bit(RXRPC_CALL_EV_ACK, &call->events);
-
-maybe_reschedule:
-	if (call->events || !skb_queue_empty(&call->rx_queue)) {
-		if (call->state < RXRPC_CALL_COMPLETE)
-			requeue = true;
-	}
-
-error:
-	kfree(acks);
-
-	if ((requeue || call->events) && !work_pending(&call->processor)) {
-		_debug("jumpstart %x", call->conn->proto.cid);
+	if (call->events && call->state < RXRPC_CALL_COMPLETE) {
 		__rxrpc_queue_call(call);
-	} else {
-		rxrpc_put_call(call, rxrpc_call_put);
+		goto out;
 	}
 
+out_put:
+	rxrpc_put_call(call, rxrpc_call_put);
+out:
 	_leave("");
-	return;
-
-no_mem:
-	_debug("out of memory");
-	goto maybe_reschedule;
 }
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index d233adc9b5e5..18ab13f82f6e 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -30,7 +30,6 @@ const char *const rxrpc_call_states[NR__RXRPC_CALL_STATES] = {
 	[RXRPC_CALL_CLIENT_SEND_REQUEST]	= "ClSndReq",
 	[RXRPC_CALL_CLIENT_AWAIT_REPLY]		= "ClAwtRpl",
 	[RXRPC_CALL_CLIENT_RECV_REPLY]		= "ClRcvRpl",
-	[RXRPC_CALL_CLIENT_FINAL_ACK]		= "ClFnlACK",
 	[RXRPC_CALL_SERVER_PREALLOC]		= "SvPrealc",
 	[RXRPC_CALL_SERVER_SECURING]		= "SvSecure",
 	[RXRPC_CALL_SERVER_ACCEPTING]		= "SvAccept",
@@ -43,7 +42,6 @@ const char *const rxrpc_call_states[NR__RXRPC_CALL_STATES] = {
 
 const char *const rxrpc_call_completions[NR__RXRPC_CALL_COMPLETIONS] = {
 	[RXRPC_CALL_SUCCEEDED]			= "Complete",
-	[RXRPC_CALL_SERVER_BUSY]		= "SvBusy  ",
 	[RXRPC_CALL_REMOTELY_ABORTED]		= "RmtAbort",
 	[RXRPC_CALL_LOCALLY_ABORTED]		= "LocAbort",
 	[RXRPC_CALL_LOCAL_ERROR]		= "LocError",
@@ -57,10 +55,8 @@ const char rxrpc_call_traces[rxrpc_call__nr_trace][4] = {
 	[rxrpc_call_queued_ref]		= "QUR",
 	[rxrpc_call_seen]		= "SEE",
 	[rxrpc_call_got]		= "GOT",
-	[rxrpc_call_got_skb]		= "Gsk",
 	[rxrpc_call_got_userid]		= "Gus",
 	[rxrpc_call_put]		= "PUT",
-	[rxrpc_call_put_skb]		= "Psk",
 	[rxrpc_call_put_userid]		= "Pus",
 	[rxrpc_call_put_noqueue]	= "PNQ",
 };
@@ -69,9 +65,15 @@ struct kmem_cache *rxrpc_call_jar;
 LIST_HEAD(rxrpc_calls);
 DEFINE_RWLOCK(rxrpc_call_lock);
 
-static void rxrpc_call_life_expired(unsigned long _call);
-static void rxrpc_ack_time_expired(unsigned long _call);
-static void rxrpc_resend_time_expired(unsigned long _call);
+static void rxrpc_call_timer_expired(unsigned long _call)
+{
+	struct rxrpc_call *call = (struct rxrpc_call *)_call;
+
+	_enter("%d", call->debug_id);
+
+	if (call->state < RXRPC_CALL_COMPLETE)
+		rxrpc_queue_call(call);
+}
 
 /*
  * find an extant server call
@@ -121,27 +123,24 @@ struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 	if (!call)
 		return NULL;
 
-	call->acks_winsz = 16;
-	call->acks_window = kmalloc(call->acks_winsz * sizeof(unsigned long),
+	call->rxtx_buffer = kcalloc(RXRPC_RXTX_BUFF_SIZE,
+				    sizeof(struct sk_buff *),
 				    gfp);
-	if (!call->acks_window) {
-		kmem_cache_free(rxrpc_call_jar, call);
-		return NULL;
-	}
+	if (!call->rxtx_buffer)
+		goto nomem;
 
-	setup_timer(&call->lifetimer, &rxrpc_call_life_expired,
-		    (unsigned long) call);
-	setup_timer(&call->ack_timer, &rxrpc_ack_time_expired,
-		    (unsigned long) call);
-	setup_timer(&call->resend_timer, &rxrpc_resend_time_expired,
-		    (unsigned long) call);
+	call->rxtx_annotations = kcalloc(RXRPC_RXTX_BUFF_SIZE, sizeof(u8), gfp);
+	if (!call->rxtx_annotations)
+		goto nomem_2;
+
+	setup_timer(&call->timer, rxrpc_call_timer_expired,
+		    (unsigned long)call);
 	INIT_WORK(&call->processor, &rxrpc_process_call);
 	INIT_LIST_HEAD(&call->link);
 	INIT_LIST_HEAD(&call->chan_wait_link);
 	INIT_LIST_HEAD(&call->accept_link);
-	skb_queue_head_init(&call->rx_queue);
-	skb_queue_head_init(&call->rx_oos_queue);
-	skb_queue_head_init(&call->knlrecv_queue);
+	INIT_LIST_HEAD(&call->recvmsg_link);
+	INIT_LIST_HEAD(&call->sock_link);
 	init_waitqueue_head(&call->waitq);
 	spin_lock_init(&call->lock);
 	rwlock_init(&call->state_lock);
@@ -150,63 +149,52 @@ struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 
 	memset(&call->sock_node, 0xed, sizeof(call->sock_node));
 
-	call->rx_data_expect = 1;
-	call->rx_data_eaten = 0;
-	call->rx_first_oos = 0;
-	call->ackr_win_top = call->rx_data_eaten + 1 + rxrpc_rx_window_size;
-	call->creation_jif = jiffies;
+	/* Leave space in the ring to handle a maxed-out jumbo packet */
+	call->rx_winsize = RXRPC_RXTX_BUFF_SIZE - 1 - 46;
+	call->tx_winsize = 16;
+	call->rx_expect_next = 1;
 	return call;
+
+nomem_2:
+	kfree(call->rxtx_buffer);
+nomem:
+	kmem_cache_free(rxrpc_call_jar, call);
+	return NULL;
 }
 
 /*
  * Allocate a new client call.
  */
-static struct rxrpc_call *rxrpc_alloc_client_call(struct rxrpc_sock *rx,
-						  struct sockaddr_rxrpc *srx,
+static struct rxrpc_call *rxrpc_alloc_client_call(struct sockaddr_rxrpc *srx,
 						  gfp_t gfp)
 {
 	struct rxrpc_call *call;
 
 	_enter("");
 
-	ASSERT(rx->local != NULL);
-
 	call = rxrpc_alloc_call(gfp);
 	if (!call)
 		return ERR_PTR(-ENOMEM);
 	call->state = RXRPC_CALL_CLIENT_AWAIT_CONN;
-	call->rx_data_post = 1;
 	call->service_id = srx->srx_service;
-	rcu_assign_pointer(call->socket, rx);
 
 	_leave(" = %p", call);
 	return call;
 }
 
 /*
- * Begin client call.
+ * Initiate the call ack/resend/expiry timer.
  */
-static int rxrpc_begin_client_call(struct rxrpc_call *call,
-				   struct rxrpc_conn_parameters *cp,
-				   struct sockaddr_rxrpc *srx,
-				   gfp_t gfp)
+static void rxrpc_start_call_timer(struct rxrpc_call *call)
 {
-	int ret;
-
-	/* Set up or get a connection record and set the protocol parameters,
-	 * including channel number and call ID.
-	 */
-	ret = rxrpc_connect_call(call, cp, srx, gfp);
-	if (ret < 0)
-		return ret;
-
-	spin_lock(&call->conn->params.peer->lock);
-	hlist_add_head(&call->error_link, &call->conn->params.peer->error_targets);
-	spin_unlock(&call->conn->params.peer->lock);
-
-	call->lifetimer.expires = jiffies + rxrpc_max_call_lifetime;
-	add_timer(&call->lifetimer);
-	return 0;
+	unsigned long expire_at;
+
+	expire_at = jiffies + rxrpc_max_call_lifetime;
+	call->expire_at = expire_at;
+	call->ack_at = expire_at;
+	call->resend_at = expire_at;
+	call->timer.expires = expire_at;
+	add_timer(&call->timer);
 }
 
 /*
@@ -226,7 +214,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 
 	_enter("%p,%lx", rx, user_call_ID);
 
-	call = rxrpc_alloc_client_call(rx, srx, gfp);
+	call = rxrpc_alloc_client_call(srx, gfp);
 	if (IS_ERR(call)) {
 		_leave(" = %ld", PTR_ERR(call));
 		return call;
@@ -255,19 +243,32 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 			goto found_user_ID_now_present;
 	}
 
+	rcu_assign_pointer(call->socket, rx);
 	rxrpc_get_call(call, rxrpc_call_got_userid);
 	rb_link_node(&call->sock_node, parent, pp);
 	rb_insert_color(&call->sock_node, &rx->calls);
+	list_add(&call->sock_link, &rx->sock_calls);
+
 	write_unlock(&rx->call_lock);
 
-	write_lock_bh(&rxrpc_call_lock);
+	write_lock(&rxrpc_call_lock);
 	list_add_tail(&call->link, &rxrpc_calls);
-	write_unlock_bh(&rxrpc_call_lock);
+	write_unlock(&rxrpc_call_lock);
 
-	ret = rxrpc_begin_client_call(call, cp, srx, gfp);
+	/* Set up or get a connection record and set the protocol parameters,
+	 * including channel number and call ID.
+	 */
+	ret = rxrpc_connect_call(call, cp, srx, gfp);
 	if (ret < 0)
 		goto error;
 
+	spin_lock_bh(&call->conn->params.peer->lock);
+	hlist_add_head(&call->error_link,
+		       &call->conn->params.peer->error_targets);
+	spin_unlock_bh(&call->conn->params.peer->lock);
+
+	rxrpc_start_call_timer(call);
+
 	_net("CALL new %d on CONN %d", call->debug_id, call->conn->debug_id);
 
 	_leave(" = %p [new]", call);
@@ -279,9 +280,9 @@ error:
 	write_unlock(&rx->call_lock);
 	rxrpc_put_call(call, rxrpc_call_put_userid);
 
-	write_lock_bh(&rxrpc_call_lock);
+	write_lock(&rxrpc_call_lock);
 	list_del_init(&call->link);
-	write_unlock_bh(&rxrpc_call_lock);
+	write_unlock(&rxrpc_call_lock);
 
 error_out:
 	__rxrpc_set_call_completion(call, RXRPC_CALL_LOCAL_ERROR,
@@ -303,142 +304,46 @@ found_user_ID_now_present:
 }
 
 /*
- * set up an incoming call
- * - called in process context with IRQs enabled
+ * Set up an incoming call.  call->conn points to the connection.
+ * This is called in BH context and isn't allowed to fail.
  */
-struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
-				       struct rxrpc_connection *conn,
-				       struct sk_buff *skb)
+void rxrpc_incoming_call(struct rxrpc_sock *rx,
+			 struct rxrpc_call *call,
+			 struct sk_buff *skb)
 {
+	struct rxrpc_connection *conn = call->conn;
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	struct rxrpc_call *call, *candidate;
-	const void *here = __builtin_return_address(0);
-	u32 call_id, chan;
-
-	_enter(",%d", conn->debug_id);
-
-	ASSERT(rx != NULL);
-
-	candidate = rxrpc_alloc_call(GFP_NOIO);
-	if (!candidate)
-		return ERR_PTR(-EBUSY);
+	u32 chan;
 
-	trace_rxrpc_call(candidate, rxrpc_call_new_service,
-			 atomic_read(&candidate->usage), here, NULL);
+	_enter(",%d", call->conn->debug_id);
 
-	chan = sp->hdr.cid & RXRPC_CHANNELMASK;
-	candidate->conn		= conn;
-	candidate->peer		= conn->params.peer;
-	candidate->cid		= sp->hdr.cid;
-	candidate->call_id	= sp->hdr.callNumber;
-	candidate->security_ix	= sp->hdr.securityIndex;
-	candidate->rx_data_post	= 0;
-	candidate->state	= RXRPC_CALL_SERVER_ACCEPTING;
-	candidate->flags	|= (1 << RXRPC_CALL_IS_SERVICE);
-	if (conn->security_ix > 0)
-		candidate->state = RXRPC_CALL_SERVER_SECURING;
-	rcu_assign_pointer(candidate->socket, rx);
-
-	spin_lock(&conn->channel_lock);
-
-	/* set the channel for this call */
-	call = rcu_dereference_protected(conn->channels[chan].call,
-					 lockdep_is_held(&conn->channel_lock));
-
-	_debug("channel[%u] is %p", candidate->cid & RXRPC_CHANNELMASK, call);
-	if (call && call->call_id == sp->hdr.callNumber) {
-		/* already set; must've been a duplicate packet */
-		_debug("extant call [%d]", call->state);
-		ASSERTCMP(call->conn, ==, conn);
-
-		read_lock(&call->state_lock);
-		switch (call->state) {
-		case RXRPC_CALL_LOCALLY_ABORTED:
-			if (!test_and_set_bit(RXRPC_CALL_EV_ABORT, &call->events))
-				rxrpc_queue_call(call);
-		case RXRPC_CALL_REMOTELY_ABORTED:
-			read_unlock(&call->state_lock);
-			goto aborted_call;
-		default:
-			rxrpc_get_call(call, rxrpc_call_got);
-			read_unlock(&call->state_lock);
-			goto extant_call;
-		}
-	}
-
-	if (call) {
-		/* it seems the channel is still in use from the previous call
-		 * - ditch the old binding if its call is now complete */
-		_debug("CALL: %u { %s }",
-		       call->debug_id, rxrpc_call_states[call->state]);
-
-		if (call->state == RXRPC_CALL_COMPLETE) {
-			__rxrpc_disconnect_call(conn, call);
-		} else {
-			spin_unlock(&conn->channel_lock);
-			kmem_cache_free(rxrpc_call_jar, candidate);
-			_leave(" = -EBUSY");
-			return ERR_PTR(-EBUSY);
-		}
-	}
-
-	/* check the call number isn't duplicate */
-	_debug("check dup");
-	call_id = sp->hdr.callNumber;
-
-	/* We just ignore calls prior to the current call ID.  Terminated calls
-	 * are handled via the connection.
+	rcu_assign_pointer(call->socket, rx);
+	call->call_id		= sp->hdr.callNumber;
+	call->service_id	= sp->hdr.serviceId;
+	call->cid		= sp->hdr.cid;
+	call->state		= RXRPC_CALL_SERVER_ACCEPTING;
+	if (sp->hdr.securityIndex > 0)
+		call->state	= RXRPC_CALL_SERVER_SECURING;
+
+	/* Set the channel for this call.  We don't get channel_lock as we're
+	 * only defending against the data_ready handler (which we're called
+	 * from) and the RESPONSE packet parser (which is only really
+	 * interested in call_counter and can cope with a disagreement with the
+	 * call pointer).
 	 */
-	if (call_id <= conn->channels[chan].call_counter)
-		goto old_call; /* TODO: Just drop packet */
-
-	/* Temporary: Mirror the backlog prealloc ref (TODO: use prealloc) */
-	rxrpc_get_call(candidate, rxrpc_call_got);
-
-	/* make the call available */
-	_debug("new call");
-	call = candidate;
-	candidate = NULL;
-	conn->channels[chan].call_counter = call_id;
+	chan = sp->hdr.cid & RXRPC_CHANNELMASK;
+	conn->channels[chan].call_counter = call->call_id;
+	conn->channels[chan].call_id = call->call_id;
 	rcu_assign_pointer(conn->channels[chan].call, call);
-	rxrpc_get_connection(conn);
-	rxrpc_get_peer(call->peer);
-	spin_unlock(&conn->channel_lock);
 
 	spin_lock(&conn->params.peer->lock);
 	hlist_add_head(&call->error_link, &conn->params.peer->error_targets);
 	spin_unlock(&conn->params.peer->lock);
 
-	write_lock_bh(&rxrpc_call_lock);
-	list_add_tail(&call->link, &rxrpc_calls);
-	write_unlock_bh(&rxrpc_call_lock);
-
-	call->service_id = conn->params.service_id;
-
 	_net("CALL incoming %d on CONN %d", call->debug_id, call->conn->debug_id);
 
-	call->lifetimer.expires = jiffies + rxrpc_max_call_lifetime;
-	add_timer(&call->lifetimer);
-	_leave(" = %p {%d} [new]", call, call->debug_id);
-	return call;
-
-extant_call:
-	spin_unlock(&conn->channel_lock);
-	kmem_cache_free(rxrpc_call_jar, candidate);
-	_leave(" = %p {%d} [extant]", call, call ? call->debug_id : -1);
-	return call;
-
-aborted_call:
-	spin_unlock(&conn->channel_lock);
-	kmem_cache_free(rxrpc_call_jar, candidate);
-	_leave(" = -ECONNABORTED");
-	return ERR_PTR(-ECONNABORTED);
-
-old_call:
-	spin_unlock(&conn->channel_lock);
-	kmem_cache_free(rxrpc_call_jar, candidate);
-	_leave(" = -ECONNRESET [old]");
-	return ERR_PTR(-ECONNRESET);
+	rxrpc_start_call_timer(call);
+	_leave("");
 }
 
 /*
@@ -497,25 +402,17 @@ void rxrpc_get_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
 }
 
 /*
- * Note the addition of a ref on a call for a socket buffer.
+ * Detach a call from its owning socket.
  */
-void rxrpc_get_call_for_skb(struct rxrpc_call *call, struct sk_buff *skb)
+void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
 {
-	const void *here = __builtin_return_address(0);
-	int n = atomic_inc_return(&call->usage);
+	struct rxrpc_connection *conn = call->conn;
+	bool put = false;
+	int i;
 
-	trace_rxrpc_call(call, rxrpc_call_got_skb, n, here, skb);
-}
+	_enter("{%d,%d}", call->debug_id, atomic_read(&call->usage));
 
-/*
- * detach a call from a socket and set up for release
- */
-void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
-{
-	_enter("{%d,%d,%d,%d}",
-	       call->debug_id, atomic_read(&call->usage),
-	       atomic_read(&call->ackr_not_idle),
-	       call->rx_first_oos);
+	ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
 
 	rxrpc_see_call(call);
 
@@ -524,80 +421,46 @@ void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
 		BUG();
 	spin_unlock_bh(&call->lock);
 
-	/* dissociate from the socket
-	 * - the socket's ref on the call is passed to the death timer
-	 */
-	_debug("RELEASE CALL %p (%d)", call, call->debug_id);
+	del_timer_sync(&call->timer);
 
-	if (call->peer) {
-		spin_lock(&call->peer->lock);
-		hlist_del_init(&call->error_link);
-		spin_unlock(&call->peer->lock);
-	}
+	/* Make sure we don't get any more notifications */
+	write_lock_bh(&rx->recvmsg_lock);
 
-	write_lock_bh(&rx->call_lock);
-	if (!list_empty(&call->accept_link)) {
+	if (!list_empty(&call->recvmsg_link)) {
 		_debug("unlinking once-pending call %p { e=%lx f=%lx }",
 		       call, call->events, call->flags);
-		ASSERT(!test_bit(RXRPC_CALL_HAS_USERID, &call->flags));
-		list_del_init(&call->accept_link);
-		sk_acceptq_removed(&rx->sk);
-	} else if (test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
+		list_del(&call->recvmsg_link);
+		put = true;
+	}
+
+	/* list_empty() must return false in rxrpc_notify_socket() */
+	call->recvmsg_link.next = NULL;
+	call->recvmsg_link.prev = NULL;
+
+	write_unlock_bh(&rx->recvmsg_lock);
+	if (put)
+		rxrpc_put_call(call, rxrpc_call_put);
+
+	write_lock(&rx->call_lock);
+
+	if (test_and_clear_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
 		rb_erase(&call->sock_node, &rx->calls);
 		memset(&call->sock_node, 0xdd, sizeof(call->sock_node));
-		clear_bit(RXRPC_CALL_HAS_USERID, &call->flags);
 		rxrpc_put_call(call, rxrpc_call_put_userid);
 	}
-	write_unlock_bh(&rx->call_lock);
-
-	/* free up the channel for reuse */
-	if (call->state == RXRPC_CALL_CLIENT_FINAL_ACK) {
-		clear_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
-		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
-		rxrpc_call_completed(call);
-	} else {
-		write_lock_bh(&call->state_lock);
-
-		if (call->state < RXRPC_CALL_COMPLETE) {
-			_debug("+++ ABORTING STATE %d +++\n", call->state);
-			__rxrpc_abort_call("SKT", call, 0, RX_CALL_DEAD, ECONNRESET);
-			clear_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
-			rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
-		}
-
-		write_unlock_bh(&call->state_lock);
-	}
 
-	if (call->conn)
+	list_del(&call->sock_link);
+	write_unlock(&rx->call_lock);
+
+	_debug("RELEASE CALL %p (%d CONN %p)", call, call->debug_id, conn);
+
+	if (conn)
 		rxrpc_disconnect_call(call);
 
-	/* clean up the Rx queue */
-	if (!skb_queue_empty(&call->rx_queue) ||
-	    !skb_queue_empty(&call->rx_oos_queue)) {
-		struct rxrpc_skb_priv *sp;
-		struct sk_buff *skb;
-
-		_debug("purge Rx queues");
-
-		spin_lock_bh(&call->lock);
-		while ((skb = skb_dequeue(&call->rx_queue)) ||
-		       (skb = skb_dequeue(&call->rx_oos_queue))) {
-			spin_unlock_bh(&call->lock);
-
-			sp = rxrpc_skb(skb);
-			_debug("- zap %s %%%u #%u",
-			       rxrpc_pkts[sp->hdr.type],
-			       sp->hdr.serial, sp->hdr.seq);
-			rxrpc_free_skb(skb);
-			spin_lock_bh(&call->lock);
-		}
-		spin_unlock_bh(&call->lock);
+	for (i = 0; i < RXRPC_RXTX_BUFF_SIZE; i++) {
+		rxrpc_free_skb(call->rxtx_buffer[i]);
+		call->rxtx_buffer[i] = NULL;
 	}
-	rxrpc_purge_queue(&call->knlrecv_queue);
-
-	del_timer_sync(&call->resend_timer);
-	del_timer_sync(&call->ack_timer);
-	del_timer_sync(&call->lifetimer);
 
 	/* We have to release the prealloc backlog ref */
 	if (rxrpc_is_service_call(call))
@@ -611,28 +474,19 @@ void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 {
 	struct rxrpc_call *call;
-	struct rb_node *p;
 
 	_enter("%p", rx);
 
-	read_lock_bh(&rx->call_lock);
-
-	/* kill the not-yet-accepted incoming calls */
-	list_for_each_entry(call, &rx->secureq, accept_link) {
-		rxrpc_release_call(rx, call);
-	}
-
-	list_for_each_entry(call, &rx->acceptq, accept_link) {
-		rxrpc_release_call(rx, call);
-	}
-
-	/* mark all the calls as no longer wanting incoming packets */
-	for (p = rb_first(&rx->calls); p; p = rb_next(p)) {
-		call = rb_entry(p, struct rxrpc_call, sock_node);
+	while (!list_empty(&rx->sock_calls)) {
+		call = list_entry(rx->sock_calls.next,
+				  struct rxrpc_call, sock_link);
+		rxrpc_get_call(call, rxrpc_call_got);
+		rxrpc_abort_call("SKT", call, 0, RX_CALL_DEAD, ECONNRESET);
+		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
 		rxrpc_release_call(rx, call);
+		rxrpc_put_call(call, rxrpc_call_put);
 	}
 
-	read_unlock_bh(&rx->call_lock);
 	_leave("");
 }
 
@@ -651,23 +505,12 @@ void rxrpc_put_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
 	ASSERTCMP(n, >=, 0);
 	if (n == 0) {
 		_debug("call %d dead", call->debug_id);
-		rxrpc_cleanup_call(call);
-	}
-}
+		ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
 
-/*
- * Release a call ref held by a socket buffer.
- */
-void rxrpc_put_call_for_skb(struct rxrpc_call *call, struct sk_buff *skb)
-{
-	const void *here = __builtin_return_address(0);
-	int n;
+		write_lock(&rxrpc_call_lock);
+		list_del_init(&call->link);
+		write_unlock(&rxrpc_call_lock);
 
-	n = atomic_dec_return(&call->usage);
-	trace_rxrpc_call(call, rxrpc_call_put_skb, n, here, skb);
-	ASSERTCMP(n, >=, 0);
-	if (n == 0) {
-		_debug("call %d dead", call->debug_id);
 		rxrpc_cleanup_call(call);
 	}
 }
@@ -679,9 +522,9 @@ static void rxrpc_rcu_destroy_call(struct rcu_head *rcu)
 {
 	struct rxrpc_call *call = container_of(rcu, struct rxrpc_call, rcu);
 
-	rxrpc_purge_queue(&call->rx_queue);
-	rxrpc_purge_queue(&call->knlrecv_queue);
 	rxrpc_put_peer(call->peer);
+	kfree(call->rxtx_buffer);
+	kfree(call->rxtx_annotations);
 	kmem_cache_free(rxrpc_call_jar, call);
 }
 
@@ -690,49 +533,24 @@ static void rxrpc_rcu_destroy_call(struct rcu_head *rcu)
  */
 void rxrpc_cleanup_call(struct rxrpc_call *call)
 {
-	_net("DESTROY CALL %d", call->debug_id);
+	int i;
 
-	write_lock_bh(&rxrpc_call_lock);
-	list_del_init(&call->link);
-	write_unlock_bh(&rxrpc_call_lock);
+	_net("DESTROY CALL %d", call->debug_id);
 
 	memset(&call->sock_node, 0xcd, sizeof(call->sock_node));
 
-	del_timer_sync(&call->lifetimer);
-	del_timer_sync(&call->ack_timer);
-	del_timer_sync(&call->resend_timer);
+	del_timer_sync(&call->timer);
 
 	ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
 	ASSERT(test_bit(RXRPC_CALL_RELEASED, &call->flags));
-	ASSERT(!work_pending(&call->processor));
 	ASSERTCMP(call->conn, ==, NULL);
 
-	if (call->acks_window) {
-		_debug("kill Tx window %d",
-		       CIRC_CNT(call->acks_head, call->acks_tail,
-				call->acks_winsz));
-		smp_mb();
-		while (CIRC_CNT(call->acks_head, call->acks_tail,
-				call->acks_winsz) > 0) {
-			struct rxrpc_skb_priv *sp;
-			unsigned long _skb;
-
-			_skb = call->acks_window[call->acks_tail] & ~1;
-			sp = rxrpc_skb((struct sk_buff *)_skb);
-			_debug("+++ clear Tx %u", sp->hdr.seq);
-			rxrpc_free_skb((struct sk_buff *)_skb);
-			call->acks_tail =
-				(call->acks_tail + 1) & (call->acks_winsz - 1);
-		}
-
-		kfree(call->acks_window);
-	}
+	/* Clean up the Rx/Tx buffer */
+	for (i = 0; i < RXRPC_RXTX_BUFF_SIZE; i++)
+		rxrpc_free_skb(call->rxtx_buffer[i]);
 
 	rxrpc_free_skb(call->tx_pending);
 
-	rxrpc_purge_queue(&call->rx_queue);
-	ASSERT(skb_queue_empty(&call->rx_oos_queue));
-	rxrpc_purge_queue(&call->knlrecv_queue);
 	call_rcu(&call->rcu, rxrpc_rcu_destroy_call);
 }
 
@@ -747,8 +565,8 @@ void __exit rxrpc_destroy_all_calls(void)
 
 	if (list_empty(&rxrpc_calls))
 		return;
-	
-	write_lock_bh(&rxrpc_call_lock);
+
+	write_lock(&rxrpc_call_lock);
 
 	while (!list_empty(&rxrpc_calls)) {
 		call = list_entry(rxrpc_calls.next, struct rxrpc_call, link);
@@ -757,74 +575,15 @@ void __exit rxrpc_destroy_all_calls(void)
 		rxrpc_see_call(call);
 		list_del_init(&call->link);
 
-		pr_err("Call %p still in use (%d,%d,%s,%lx,%lx)!\n",
+		pr_err("Call %p still in use (%d,%s,%lx,%lx)!\n",
 		       call, atomic_read(&call->usage),
-		       atomic_read(&call->ackr_not_idle),
 		       rxrpc_call_states[call->state],
 		       call->flags, call->events);
-		if (!skb_queue_empty(&call->rx_queue))
-			pr_err("Rx queue occupied\n");
-		if (!skb_queue_empty(&call->rx_oos_queue))
-			pr_err("OOS queue occupied\n");
 
-		write_unlock_bh(&rxrpc_call_lock);
+		write_unlock(&rxrpc_call_lock);
 		cond_resched();
-		write_lock_bh(&rxrpc_call_lock);
+		write_lock(&rxrpc_call_lock);
 	}
 
-	write_unlock_bh(&rxrpc_call_lock);
-	_leave("");
-}
-
-/*
- * handle call lifetime being exceeded
- */
-static void rxrpc_call_life_expired(unsigned long _call)
-{
-	struct rxrpc_call *call = (struct rxrpc_call *) _call;
-
-	_enter("{%d}", call->debug_id);
-
-	rxrpc_see_call(call);
-	if (call->state >= RXRPC_CALL_COMPLETE)
-		return;
-
-	set_bit(RXRPC_CALL_EV_LIFE_TIMER, &call->events);
-	rxrpc_queue_call(call);
-}
-
-/*
- * handle resend timer expiry
- * - may not take call->state_lock as this can deadlock against del_timer_sync()
- */
-static void rxrpc_resend_time_expired(unsigned long _call)
-{
-	struct rxrpc_call *call = (struct rxrpc_call *) _call;
-
-	_enter("{%d}", call->debug_id);
-
-	rxrpc_see_call(call);
-	if (call->state >= RXRPC_CALL_COMPLETE)
-		return;
-
-	clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-	if (!test_and_set_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events))
-		rxrpc_queue_call(call);
-}
-
-/*
- * handle ACK timer expiry
- */
-static void rxrpc_ack_time_expired(unsigned long _call)
-{
-	struct rxrpc_call *call = (struct rxrpc_call *) _call;
-
-	_enter("{%d}", call->debug_id);
-
-	rxrpc_see_call(call);
-	if (call->state >= RXRPC_CALL_COMPLETE)
-		return;
-
-	if (!test_and_set_bit(RXRPC_CALL_EV_ACK, &call->events))
-		rxrpc_queue_call(call);
+	write_unlock(&rxrpc_call_lock);
 }
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 8c7938ba6a84..0691007cfc02 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -15,10 +15,6 @@
 #include <linux/net.h>
 #include <linux/skbuff.h>
 #include <linux/errqueue.h>
-#include <linux/udp.h>
-#include <linux/in.h>
-#include <linux/in6.h>
-#include <linux/icmp.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <net/ip.h>
@@ -140,16 +136,10 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn,
 			      u32 abort_code, int error)
 {
 	struct rxrpc_call *call;
-	bool queue;
-	int i, bit;
+	int i;
 
 	_enter("{%d},%x", conn->debug_id, abort_code);
 
-	if (compl == RXRPC_CALL_LOCALLY_ABORTED)
-		bit = RXRPC_CALL_EV_CONN_ABORT;
-	else
-		bit = RXRPC_CALL_EV_RCVD_ABORT;
-
 	spin_lock(&conn->channel_lock);
 
 	for (i = 0; i < RXRPC_MAXCALLS; i++) {
@@ -157,22 +147,13 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn,
 			conn->channels[i].call,
 			lockdep_is_held(&conn->channel_lock));
 		if (call) {
-			rxrpc_see_call(call);
 			if (compl == RXRPC_CALL_LOCALLY_ABORTED)
 				trace_rxrpc_abort("CON", call->cid,
 						  call->call_id, 0,
 						  abort_code, error);
-
-			write_lock_bh(&call->state_lock);
-			if (rxrpc_set_call_completion(call, compl, abort_code,
-						      error)) {
-				set_bit(bit, &call->events);
-				queue = true;
-			}
-			write_unlock_bh(&call->state_lock);
-			if (queue)
-				rxrpc_queue_call(call);
-
+			if (rxrpc_set_call_completion(call, compl,
+						      abort_code, error))
+				rxrpc_notify_socket(call);
 		}
 	}
 
@@ -251,17 +232,18 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 
 /*
  * mark a call as being on a now-secured channel
- * - must be called with softirqs disabled
+ * - must be called with BH's disabled.
  */
 static void rxrpc_call_is_secure(struct rxrpc_call *call)
 {
 	_enter("%p", call);
 	if (call) {
-		read_lock(&call->state_lock);
-		if (call->state < RXRPC_CALL_COMPLETE &&
-		    !test_and_set_bit(RXRPC_CALL_EV_SECURED, &call->events))
-			rxrpc_queue_call(call);
-		read_unlock(&call->state_lock);
+		write_lock_bh(&call->state_lock);
+		if (call->state == RXRPC_CALL_SERVER_SECURING) {
+			call->state = RXRPC_CALL_SERVER_ACCEPTING;
+			rxrpc_notify_socket(call);
+		}
+		write_unlock_bh(&call->state_lock);
 	}
 }
 
@@ -278,7 +260,7 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 	int loop, ret;
 
 	if (conn->state >= RXRPC_CONN_REMOTELY_ABORTED) {
-		kleave(" = -ECONNABORTED [%u]", conn->state);
+		_leave(" = -ECONNABORTED [%u]", conn->state);
 		return -ECONNABORTED;
 	}
 
@@ -291,14 +273,14 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		return 0;
 
 	case RXRPC_PACKET_TYPE_ABORT:
-		if (skb_copy_bits(skb, 0, &wtmp, sizeof(wtmp)) < 0)
+		if (skb_copy_bits(skb, sp->offset, &wtmp, sizeof(wtmp)) < 0)
 			return -EPROTO;
 		abort_code = ntohl(wtmp);
 		_proto("Rx ABORT %%%u { ac=%d }", sp->hdr.serial, abort_code);
 
 		conn->state = RXRPC_CONN_REMOTELY_ABORTED;
-		rxrpc_abort_calls(conn, 0, RXRPC_CALL_REMOTELY_ABORTED,
-				  abort_code);
+		rxrpc_abort_calls(conn, RXRPC_CALL_REMOTELY_ABORTED,
+				  abort_code, ECONNABORTED);
 		return -ECONNABORTED;
 
 	case RXRPC_PACKET_TYPE_CHALLENGE:
@@ -323,14 +305,16 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 
 		if (conn->state == RXRPC_CONN_SERVICE_CHALLENGING) {
 			conn->state = RXRPC_CONN_SERVICE;
+			spin_unlock(&conn->state_lock);
 			for (loop = 0; loop < RXRPC_MAXCALLS; loop++)
 				rxrpc_call_is_secure(
 					rcu_dereference_protected(
 						conn->channels[loop].call,
 						lockdep_is_held(&conn->channel_lock)));
+		} else {
+			spin_unlock(&conn->state_lock);
 		}
 
-		spin_unlock(&conn->state_lock);
 		spin_unlock(&conn->channel_lock);
 		return 0;
 
@@ -433,88 +417,3 @@ protocol_error:
 	_leave(" [EPROTO]");
 	goto out;
 }
-
-/*
- * put a packet up for transport-level abort
- */
-void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
-{
-	CHECK_SLAB_OKAY(&local->usage);
-
-	skb_queue_tail(&local->reject_queue, skb);
-	rxrpc_queue_local(local);
-}
-
-/*
- * reject packets through the local endpoint
- */
-void rxrpc_reject_packets(struct rxrpc_local *local)
-{
-	union {
-		struct sockaddr sa;
-		struct sockaddr_in sin;
-	} sa;
-	struct rxrpc_skb_priv *sp;
-	struct rxrpc_wire_header whdr;
-	struct sk_buff *skb;
-	struct msghdr msg;
-	struct kvec iov[2];
-	size_t size;
-	__be32 code;
-
-	_enter("%d", local->debug_id);
-
-	iov[0].iov_base = &whdr;
-	iov[0].iov_len = sizeof(whdr);
-	iov[1].iov_base = &code;
-	iov[1].iov_len = sizeof(code);
-	size = sizeof(whdr) + sizeof(code);
-
-	msg.msg_name = &sa;
-	msg.msg_control = NULL;
-	msg.msg_controllen = 0;
-	msg.msg_flags = 0;
-
-	memset(&sa, 0, sizeof(sa));
-	sa.sa.sa_family = local->srx.transport.family;
-	switch (sa.sa.sa_family) {
-	case AF_INET:
-		msg.msg_namelen = sizeof(sa.sin);
-		break;
-	default:
-		msg.msg_namelen = 0;
-		break;
-	}
-
-	memset(&whdr, 0, sizeof(whdr));
-	whdr.type = RXRPC_PACKET_TYPE_ABORT;
-
-	while ((skb = skb_dequeue(&local->reject_queue))) {
-		rxrpc_see_skb(skb);
-		sp = rxrpc_skb(skb);
-		switch (sa.sa.sa_family) {
-		case AF_INET:
-			sa.sin.sin_port = udp_hdr(skb)->source;
-			sa.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
-			code = htonl(skb->priority);
-
-			whdr.epoch	= htonl(sp->hdr.epoch);
-			whdr.cid	= htonl(sp->hdr.cid);
-			whdr.callNumber	= htonl(sp->hdr.callNumber);
-			whdr.serviceId	= htons(sp->hdr.serviceId);
-			whdr.flags	= sp->hdr.flags;
-			whdr.flags	^= RXRPC_CLIENT_INITIATED;
-			whdr.flags	&= RXRPC_CLIENT_INITIATED;
-
-			kernel_sendmsg(local->socket, &msg, iov, 2, size);
-			break;
-
-		default:
-			break;
-		}
-
-		rxrpc_free_skb(skb);
-	}
-
-	_leave("");
-}
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 8da82e3aa00e..ffa9addb97b2 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -169,7 +169,7 @@ void __rxrpc_disconnect_call(struct rxrpc_connection *conn,
 			chan->last_abort = call->abort_code;
 			chan->last_type = RXRPC_PACKET_TYPE_ABORT;
 		} else {
-			chan->last_seq = call->rx_data_eaten;
+			chan->last_seq = call->rx_hard_ack;
 			chan->last_type = RXRPC_PACKET_TYPE_ACK;
 		}
 		/* Sync with rxrpc_conn_retransmit(). */
@@ -191,6 +191,10 @@ void rxrpc_disconnect_call(struct rxrpc_call *call)
 {
 	struct rxrpc_connection *conn = call->conn;
 
+	spin_lock_bh(&conn->params.peer->lock);
+	hlist_del_init(&call->error_link);
+	spin_unlock_bh(&conn->params.peer->lock);
+
 	if (rxrpc_is_client_call(call))
 		return rxrpc_disconnect_client_call(call);
 
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index 189338a60457..83d54da4ce8b 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -65,9 +65,8 @@ done:
  * Insert a service connection into a peer's tree, thereby making it a target
  * for incoming packets.
  */
-static struct rxrpc_connection *
-rxrpc_publish_service_conn(struct rxrpc_peer *peer,
-			   struct rxrpc_connection *conn)
+static void rxrpc_publish_service_conn(struct rxrpc_peer *peer,
+				       struct rxrpc_connection *conn)
 {
 	struct rxrpc_connection *cursor = NULL;
 	struct rxrpc_conn_proto k = conn->proto;
@@ -96,7 +95,7 @@ conn_published:
 	set_bit(RXRPC_CONN_IN_SERVICE_CONNS, &conn->flags);
 	write_sequnlock_bh(&peer->service_conn_lock);
 	_leave(" = %d [new]", conn->debug_id);
-	return conn;
+	return;
 
 found_extant_conn:
 	if (atomic_read(&cursor->usage) == 0)
@@ -143,106 +142,30 @@ struct rxrpc_connection *rxrpc_prealloc_service_connection(gfp_t gfp)
 }
 
 /*
- * get a record of an incoming connection
+ * Set up an incoming connection.  This is called in BH context with the RCU
+ * read lock held.
  */
-struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
-						   struct sockaddr_rxrpc *srx,
-						   struct sk_buff *skb)
+void rxrpc_new_incoming_connection(struct rxrpc_connection *conn,
+				   struct sk_buff *skb)
 {
-	struct rxrpc_connection *conn;
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	struct rxrpc_peer *peer;
-	const char *new = "old";
 
 	_enter("");
 
-	peer = rxrpc_lookup_peer(local, srx, GFP_NOIO);
-	if (!peer) {
-		_debug("no peer");
-		return ERR_PTR(-EBUSY);
-	}
-
-	ASSERT(sp->hdr.flags & RXRPC_CLIENT_INITIATED);
-
-	rcu_read_lock();
-	peer = rxrpc_lookup_peer_rcu(local, srx);
-	if (peer) {
-		conn = rxrpc_find_service_conn_rcu(peer, skb);
-		if (conn) {
-			if (sp->hdr.securityIndex != conn->security_ix)
-				goto security_mismatch_rcu;
-			if (rxrpc_get_connection_maybe(conn))
-				goto found_extant_connection_rcu;
-
-			/* The conn has expired but we can't remove it without
-			 * the appropriate lock, so we attempt to replace it
-			 * when we have a new candidate.
-			 */
-		}
-
-		if (!rxrpc_get_peer_maybe(peer))
-			peer = NULL;
-	}
-	rcu_read_unlock();
-
-	if (!peer) {
-		peer = rxrpc_lookup_peer(local, srx, GFP_NOIO);
-		if (!peer)
-			goto enomem;
-	}
-
-	/* We don't have a matching record yet. */
-	conn = rxrpc_alloc_connection(GFP_NOIO);
-	if (!conn)
-		goto enomem_peer;
-
 	conn->proto.epoch	= sp->hdr.epoch;
 	conn->proto.cid		= sp->hdr.cid & RXRPC_CIDMASK;
-	conn->params.local	= local;
-	conn->params.peer	= peer;
 	conn->params.service_id	= sp->hdr.serviceId;
 	conn->security_ix	= sp->hdr.securityIndex;
 	conn->out_clientflag	= 0;
-	conn->state		= RXRPC_CONN_SERVICE;
-	if (conn->params.service_id)
+	if (conn->security_ix)
 		conn->state	= RXRPC_CONN_SERVICE_UNSECURED;
-
-	rxrpc_get_local(local);
-
-	/* We maintain an extra ref on the connection whilst it is on
-	 * the rxrpc_connections list.
-	 */
-	atomic_set(&conn->usage, 2);
-
-	write_lock(&rxrpc_connection_lock);
-	list_add_tail(&conn->link, &rxrpc_connections);
-	list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
-	write_unlock(&rxrpc_connection_lock);
+	else
+		conn->state	= RXRPC_CONN_SERVICE;
 
 	/* Make the connection a target for incoming packets. */
-	rxrpc_publish_service_conn(peer, conn);
-
-	new = "new";
-
-success:
-	_net("CONNECTION %s %d {%x}", new, conn->debug_id, conn->proto.cid);
-	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
-	return conn;
-
-found_extant_connection_rcu:
-	rcu_read_unlock();
-	goto success;
-
-security_mismatch_rcu:
-	rcu_read_unlock();
-	_leave(" = -EKEYREJECTED");
-	return ERR_PTR(-EKEYREJECTED);
+	rxrpc_publish_service_conn(conn->params.peer, conn);
 
-enomem_peer:
-	rxrpc_put_peer(peer);
-enomem:
-	_leave(" = -ENOMEM");
-	return ERR_PTR(-ENOMEM);
+	_net("CONNECTION new %d {%x}", conn->debug_id, conn->proto.cid);
 }
 
 /*
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 5906579060cd..afeba98004b1 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -1,6 +1,6 @@
 /* RxRPC packet reception
  *
- * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2007, 2016 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -27,549 +27,547 @@
 #include <net/net_namespace.h>
 #include "ar-internal.h"
 
+static void rxrpc_proto_abort(const char *why,
+			      struct rxrpc_call *call, rxrpc_seq_t seq)
+{
+	if (rxrpc_abort_call(why, call, seq, RX_PROTOCOL_ERROR, EBADMSG)) {
+		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
+		rxrpc_queue_call(call);
+	}
+}
+
 /*
- * queue a packet for recvmsg to pass to userspace
- * - the caller must hold a lock on call->lock
- * - must not be called with interrupts disabled (sk_filter() disables BH's)
- * - eats the packet whether successful or not
- * - there must be just one reference to the packet, which the caller passes to
- *   this function
+ * Apply a hard ACK by advancing the Tx window.
  */
-int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
-			bool force, bool terminal)
+static void rxrpc_rotate_tx_window(struct rxrpc_call *call, rxrpc_seq_t to)
 {
-	struct rxrpc_skb_priv *sp;
-	struct rxrpc_sock *rx;
-	struct sock *sk;
-	int ret;
+	struct sk_buff *skb, *list = NULL;
+	int ix;
 
-	_enter(",,%d,%d", force, terminal);
+	spin_lock(&call->lock);
 
-	ASSERT(!irqs_disabled());
+	while (before(call->tx_hard_ack, to)) {
+		call->tx_hard_ack++;
+		ix = call->tx_hard_ack & RXRPC_RXTX_BUFF_MASK;
+		skb = call->rxtx_buffer[ix];
+		rxrpc_see_skb(skb);
+		call->rxtx_buffer[ix] = NULL;
+		call->rxtx_annotations[ix] = 0;
+		skb->next = list;
+		list = skb;
+	}
 
-	sp = rxrpc_skb(skb);
-	ASSERTCMP(sp->call, ==, call);
+	spin_unlock(&call->lock);
 
-	/* if we've already posted the terminal message for a call, then we
-	 * don't post any more */
-	if (test_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags)) {
-		_debug("already terminated");
-		ASSERTCMP(call->state, >=, RXRPC_CALL_COMPLETE);
+	while (list) {
+		skb = list;
+		list = skb->next;
+		skb->next = NULL;
 		rxrpc_free_skb(skb);
-		return 0;
 	}
+}
 
-	/* The socket may go away under us */
-	ret = 0;
-	rcu_read_lock();
-	rx = rcu_dereference(call->socket);
-	if (!rx)
-		goto out;
-	sk = &rx->sk;
-	if (sock_flag(sk, SOCK_DEAD))
-		goto out;
+/*
+ * End the transmission phase of a call.
+ *
+ * This occurs when we get an ACKALL packet, the first DATA packet of a reply,
+ * or a final ACK packet.
+ */
+static bool rxrpc_end_tx_phase(struct rxrpc_call *call, const char *abort_why)
+{
+	_enter("");
 
-	if (!force) {
-		/* cast skb->rcvbuf to unsigned...  It's pointless, but
-		 * reduces number of warnings when compiling with -W
-		 * --ANK */
-//		ret = -ENOBUFS;
-//		if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
-//		    (unsigned int) sk->sk_rcvbuf)
-//			goto out;
-
-		ret = sk_filter(sk, skb);
-		if (ret < 0)
-			goto out;
+	switch (call->state) {
+	case RXRPC_CALL_CLIENT_RECV_REPLY:
+		return true;
+	case RXRPC_CALL_CLIENT_AWAIT_REPLY:
+	case RXRPC_CALL_SERVER_AWAIT_ACK:
+		break;
+	default:
+		rxrpc_proto_abort(abort_why, call, call->tx_top);
+		return false;
 	}
 
-	spin_lock_bh(&sk->sk_receive_queue.lock);
-	if (!test_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags) &&
-	    !test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-	    sk->sk_state != RXRPC_CLOSE) {
-		skb->destructor = rxrpc_packet_destructor;
-		skb->dev = NULL;
-		skb->sk = sk;
-		atomic_add(skb->truesize, &sk->sk_rmem_alloc);
-
-		if (terminal) {
-			_debug("<<<< TERMINAL MESSAGE >>>>");
-			set_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags);
-		}
+	rxrpc_rotate_tx_window(call, call->tx_top);
 
-		/* allow interception by a kernel service */
-		if (skb->mark == RXRPC_SKB_MARK_NEW_CALL &&
-		    rx->notify_new_call) {
-			spin_unlock_bh(&sk->sk_receive_queue.lock);
-			skb_queue_tail(&call->knlrecv_queue, skb);
-			rx->notify_new_call(&rx->sk, NULL, 0);
-		} else if (call->notify_rx) {
-			spin_unlock_bh(&sk->sk_receive_queue.lock);
-			skb_queue_tail(&call->knlrecv_queue, skb);
-			call->notify_rx(&rx->sk, call, call->user_call_ID);
-		} else {
-			_net("post skb %p", skb);
-			__skb_queue_tail(&sk->sk_receive_queue, skb);
-			spin_unlock_bh(&sk->sk_receive_queue.lock);
+	write_lock(&call->state_lock);
 
-			sk->sk_data_ready(sk);
-		}
-		skb = NULL;
-	} else {
-		spin_unlock_bh(&sk->sk_receive_queue.lock);
+	switch (call->state) {
+	default:
+		break;
+	case RXRPC_CALL_CLIENT_AWAIT_REPLY:
+		call->state = RXRPC_CALL_CLIENT_RECV_REPLY;
+		break;
+	case RXRPC_CALL_SERVER_AWAIT_ACK:
+		__rxrpc_call_completed(call);
+		rxrpc_notify_socket(call);
+		break;
 	}
-	ret = 0;
 
-out:
-	rxrpc_free_skb(skb);
-	rcu_read_unlock();
+	write_unlock(&call->state_lock);
+	_leave(" = ok");
+	return true;
+}
+
+/*
+ * Scan a jumbo packet to validate its structure and to work out how many
+ * subpackets it contains.
+ *
+ * A jumbo packet is a collection of consecutive packets glued together with
+ * little headers between that indicate how to change the initial header for
+ * each subpacket.
+ *
+ * RXRPC_JUMBO_PACKET must be set on all but the last subpacket - and all but
+ * the last are RXRPC_JUMBO_DATALEN in size.  The last subpacket may be of any
+ * size.
+ */
+static bool rxrpc_validate_jumbo(struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	unsigned int offset = sp->offset;
+	unsigned int len = skb->data_len;
+	int nr_jumbo = 1;
+	u8 flags = sp->hdr.flags;
+
+	do {
+		nr_jumbo++;
+		if (len - offset < RXRPC_JUMBO_SUBPKTLEN)
+			goto protocol_error;
+		if (flags & RXRPC_LAST_PACKET)
+			goto protocol_error;
+		offset += RXRPC_JUMBO_DATALEN;
+		if (skb_copy_bits(skb, offset, &flags, 1) < 0)
+			goto protocol_error;
+		offset += sizeof(struct rxrpc_jumbo_header);
+	} while (flags & RXRPC_JUMBO_PACKET);
+
+	sp->nr_jumbo = nr_jumbo;
+	return true;
 
-	_leave(" = %d", ret);
-	return ret;
+protocol_error:
+	return false;
 }
 
 /*
- * process a DATA packet, posting the packet to the appropriate queue
- * - eats the packet if successful
+ * Handle reception of a duplicate packet.
+ *
+ * We have to take care to avoid an attack here whereby we're given a series of
+ * jumbograms, each with a sequence number one before the preceding one and
+ * filled up to maximum UDP size.  If they never send us the first packet in
+ * the sequence, they can cause us to have to hold on to around 2MiB of kernel
+ * space until the call times out.
+ *
+ * We limit the space usage by only accepting three duplicate jumbo packets per
+ * call.  After that, we tell the other side we're no longer accepting jumbos
+ * (that information is encoded in the ACK packet).
  */
-static int rxrpc_fast_process_data(struct rxrpc_call *call,
-				   struct sk_buff *skb, u32 seq)
+static void rxrpc_input_dup_data(struct rxrpc_call *call, rxrpc_seq_t seq,
+				 u8 annotation, bool *_jumbo_dup)
 {
-	struct rxrpc_skb_priv *sp;
-	bool terminal;
-	int ret, ackbit, ack;
-	u32 serial;
-	u16 skew;
-	u8 flags;
+	/* Discard normal packets that are duplicates. */
+	if (annotation == 0)
+		return;
 
-	_enter("{%u,%u},,{%u}", call->rx_data_post, call->rx_first_oos, seq);
+	/* Skip jumbo subpackets that are duplicates.  When we've had three or
+	 * more partially duplicate jumbo packets, we refuse to take any more
+	 * jumbos for this call.
+	 */
+	if (!*_jumbo_dup) {
+		call->nr_jumbo_dup++;
+		*_jumbo_dup = true;
+	}
+}
 
-	sp = rxrpc_skb(skb);
-	ASSERTCMP(sp->call, ==, NULL);
-	flags = sp->hdr.flags;
-	serial = sp->hdr.serial;
-	skew = skb->priority;
+/*
+ * Process a DATA packet, adding the packet to the Rx ring.
+ */
+static void rxrpc_input_data(struct rxrpc_call *call, struct sk_buff *skb,
+			     u16 skew)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	unsigned int offset = sp->offset;
+	unsigned int ix;
+	rxrpc_serial_t serial = sp->hdr.serial, ack_serial = 0;
+	rxrpc_seq_t seq = sp->hdr.seq, hard_ack;
+	bool immediate_ack = false, jumbo_dup = false, queued;
+	u16 len;
+	u8 ack = 0, flags, annotation = 0;
 
-	spin_lock(&call->lock);
+	_enter("{%u,%u},{%u,%u}",
+	       call->rx_hard_ack, call->rx_top, skb->data_len, seq);
 
-	if (call->state > RXRPC_CALL_COMPLETE)
-		goto discard;
+	_proto("Rx DATA %%%u { #%u f=%02x }",
+	       sp->hdr.serial, seq, sp->hdr.flags);
 
-	ASSERTCMP(call->rx_data_expect, >=, call->rx_data_post);
-	ASSERTCMP(call->rx_data_post, >=, call->rx_data_recv);
-	ASSERTCMP(call->rx_data_recv, >=, call->rx_data_eaten);
+	if (call->state >= RXRPC_CALL_COMPLETE)
+		return;
 
-	if (seq < call->rx_data_post) {
-		_debug("dup #%u [-%u]", seq, call->rx_data_post);
-		ack = RXRPC_ACK_DUPLICATE;
-		ret = -ENOBUFS;
-		goto discard_and_ack;
-	}
+	/* Received data implicitly ACKs all of the request packets we sent
+	 * when we're acting as a client.
+	 */
+	if (call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY &&
+	    !rxrpc_end_tx_phase(call, "ETD"))
+		return;
 
-	/* we may already have the packet in the out of sequence queue */
-	ackbit = seq - (call->rx_data_eaten + 1);
-	ASSERTCMP(ackbit, >=, 0);
-	if (__test_and_set_bit(ackbit, call->ackr_window)) {
-		_debug("dup oos #%u [%u,%u]",
-		       seq, call->rx_data_eaten, call->rx_data_post);
-		ack = RXRPC_ACK_DUPLICATE;
-		goto discard_and_ack;
-	}
+	call->ackr_prev_seq = seq;
 
-	if (seq >= call->ackr_win_top) {
-		_debug("exceed #%u [%u]", seq, call->ackr_win_top);
-		__clear_bit(ackbit, call->ackr_window);
+	hard_ack = READ_ONCE(call->rx_hard_ack);
+	if (after(seq, hard_ack + call->rx_winsize)) {
 		ack = RXRPC_ACK_EXCEEDS_WINDOW;
-		goto discard_and_ack;
+		ack_serial = serial;
+		goto ack;
 	}
 
-	if (seq == call->rx_data_expect) {
-		clear_bit(RXRPC_CALL_EXPECT_OOS, &call->flags);
-		call->rx_data_expect++;
-	} else if (seq > call->rx_data_expect) {
-		_debug("oos #%u [%u]", seq, call->rx_data_expect);
-		call->rx_data_expect = seq + 1;
-		if (test_and_set_bit(RXRPC_CALL_EXPECT_OOS, &call->flags)) {
-			ack = RXRPC_ACK_OUT_OF_SEQUENCE;
-			goto enqueue_and_ack;
+	flags = sp->hdr.flags;
+	if (flags & RXRPC_JUMBO_PACKET) {
+		if (call->nr_jumbo_dup > 3) {
+			ack = RXRPC_ACK_NOSPACE;
+			ack_serial = serial;
+			goto ack;
 		}
-		goto enqueue_packet;
+		annotation = 1;
 	}
 
-	if (seq != call->rx_data_post) {
-		_debug("ahead #%u [%u]", seq, call->rx_data_post);
-		goto enqueue_packet;
+next_subpacket:
+	queued = false;
+	ix = seq & RXRPC_RXTX_BUFF_MASK;
+	len = skb->data_len;
+	if (flags & RXRPC_JUMBO_PACKET)
+		len = RXRPC_JUMBO_DATALEN;
+
+	if (flags & RXRPC_LAST_PACKET) {
+		if (test_and_set_bit(RXRPC_CALL_RX_LAST, &call->flags) &&
+		    seq != call->rx_top)
+			return rxrpc_proto_abort("LSN", call, seq);
+	} else {
+		if (test_bit(RXRPC_CALL_RX_LAST, &call->flags) &&
+		    after_eq(seq, call->rx_top))
+			return rxrpc_proto_abort("LSA", call, seq);
 	}
 
-	if (test_bit(RXRPC_CALL_RCVD_LAST, &call->flags))
-		goto protocol_error;
-
-	/* if the packet need security things doing to it, then it goes down
-	 * the slow path */
-	if (call->security_ix)
-		goto enqueue_packet;
-
-	sp->call = call;
-	rxrpc_get_call_for_skb(call, skb);
-	terminal = ((flags & RXRPC_LAST_PACKET) &&
-		    !(flags & RXRPC_CLIENT_INITIATED));
-	ret = rxrpc_queue_rcv_skb(call, skb, false, terminal);
-	if (ret < 0) {
-		if (ret == -ENOMEM || ret == -ENOBUFS) {
-			__clear_bit(ackbit, call->ackr_window);
-			ack = RXRPC_ACK_NOSPACE;
-			goto discard_and_ack;
+	if (before_eq(seq, hard_ack)) {
+		ack = RXRPC_ACK_DUPLICATE;
+		ack_serial = serial;
+		goto skip;
+	}
+
+	if (flags & RXRPC_REQUEST_ACK && !ack) {
+		ack = RXRPC_ACK_REQUESTED;
+		ack_serial = serial;
+	}
+
+	if (call->rxtx_buffer[ix]) {
+		rxrpc_input_dup_data(call, seq, annotation, &jumbo_dup);
+		if (ack != RXRPC_ACK_DUPLICATE) {
+			ack = RXRPC_ACK_DUPLICATE;
+			ack_serial = serial;
 		}
-		goto out;
+		immediate_ack = true;
+		goto skip;
 	}
 
-	skb = NULL;
-	sp = NULL;
-
-	_debug("post #%u", seq);
-	ASSERTCMP(call->rx_data_post, ==, seq);
-	call->rx_data_post++;
-
-	if (flags & RXRPC_LAST_PACKET)
-		set_bit(RXRPC_CALL_RCVD_LAST, &call->flags);
-
-	/* if we've reached an out of sequence packet then we need to drain
-	 * that queue into the socket Rx queue now */
-	if (call->rx_data_post == call->rx_first_oos) {
-		_debug("drain rx oos now");
-		read_lock(&call->state_lock);
-		if (call->state < RXRPC_CALL_COMPLETE &&
-		    !test_and_set_bit(RXRPC_CALL_EV_DRAIN_RX_OOS, &call->events))
-			rxrpc_queue_call(call);
-		read_unlock(&call->state_lock);
+	/* Queue the packet.  We use a couple of memory barriers here as need
+	 * to make sure that rx_top is perceived to be set after the buffer
+	 * pointer and that the buffer pointer is set after the annotation and
+	 * the skb data.
+	 *
+	 * Barriers against rxrpc_recvmsg_data() and rxrpc_rotate_rx_window()
+	 * and also rxrpc_fill_out_ack().
+	 */
+	rxrpc_get_skb(skb);
+	call->rxtx_annotations[ix] = annotation;
+	smp_wmb();
+	call->rxtx_buffer[ix] = skb;
+	if (after(seq, call->rx_top))
+		smp_store_release(&call->rx_top, seq);
+	queued = true;
+
+	if (after_eq(seq, call->rx_expect_next)) {
+		if (after(seq, call->rx_expect_next)) {
+			_net("OOS %u > %u", seq, call->rx_expect_next);
+			ack = RXRPC_ACK_OUT_OF_SEQUENCE;
+			ack_serial = serial;
+		}
+		call->rx_expect_next = seq + 1;
 	}
 
-	spin_unlock(&call->lock);
-	atomic_inc(&call->ackr_not_idle);
-	rxrpc_propose_ACK(call, RXRPC_ACK_DELAY, skew, serial, false);
-	_leave(" = 0 [posted]");
-	return 0;
+skip:
+	offset += len;
+	if (flags & RXRPC_JUMBO_PACKET) {
+		if (skb_copy_bits(skb, offset, &flags, 1) < 0)
+			return rxrpc_proto_abort("XJF", call, seq);
+		offset += sizeof(struct rxrpc_jumbo_header);
+		seq++;
+		serial++;
+		annotation++;
+		if (flags & RXRPC_JUMBO_PACKET)
+			annotation |= RXRPC_RX_ANNO_JLAST;
+
+		_proto("Rx DATA Jumbo %%%u", serial);
+		goto next_subpacket;
+	}
 
-protocol_error:
-	ret = -EBADMSG;
-out:
-	spin_unlock(&call->lock);
-	_leave(" = %d", ret);
-	return ret;
+	if (queued && flags & RXRPC_LAST_PACKET && !ack) {
+		ack = RXRPC_ACK_DELAY;
+		ack_serial = serial;
+	}
 
-discard_and_ack:
-	_debug("discard and ACK packet %p", skb);
-	__rxrpc_propose_ACK(call, ack, skew, serial, true);
-discard:
-	spin_unlock(&call->lock);
-	rxrpc_free_skb(skb);
-	_leave(" = 0 [discarded]");
-	return 0;
+ack:
+	if (ack)
+		rxrpc_propose_ACK(call, ack, skew, ack_serial,
+				  immediate_ack, true);
 
-enqueue_and_ack:
-	__rxrpc_propose_ACK(call, ack, skew, serial, true);
-enqueue_packet:
-	_net("defer skb %p", skb);
-	spin_unlock(&call->lock);
-	skb_queue_tail(&call->rx_queue, skb);
-	atomic_inc(&call->ackr_not_idle);
-	read_lock(&call->state_lock);
-	if (call->state < RXRPC_CALL_COMPLETE)
-		rxrpc_queue_call(call);
-	read_unlock(&call->state_lock);
-	_leave(" = 0 [queued]");
-	return 0;
+	if (sp->hdr.seq == READ_ONCE(call->rx_hard_ack) + 1)
+		rxrpc_notify_socket(call);
+	_leave(" [queued]");
 }
 
 /*
- * assume an implicit ACKALL of the transmission phase of a client socket upon
- * reception of the first reply packet
+ * Process the extra information that may be appended to an ACK packet
  */
-static void rxrpc_assume_implicit_ackall(struct rxrpc_call *call, u32 serial)
+static void rxrpc_input_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
+				struct rxrpc_ackinfo *ackinfo)
 {
-	write_lock_bh(&call->state_lock);
-
-	switch (call->state) {
-	case RXRPC_CALL_CLIENT_AWAIT_REPLY:
-		call->state = RXRPC_CALL_CLIENT_RECV_REPLY;
-		call->acks_latest = serial;
-
-		_debug("implicit ACKALL %%%u", call->acks_latest);
-		set_bit(RXRPC_CALL_EV_RCVD_ACKALL, &call->events);
-		write_unlock_bh(&call->state_lock);
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct rxrpc_peer *peer;
+	unsigned int mtu;
+
+	_proto("Rx ACK %%%u Info { rx=%u max=%u rwin=%u jm=%u }",
+	       sp->hdr.serial,
+	       ntohl(ackinfo->rxMTU), ntohl(ackinfo->maxMTU),
+	       ntohl(ackinfo->rwind), ntohl(ackinfo->jumbo_max));
+
+	if (call->tx_winsize > ntohl(ackinfo->rwind))
+		call->tx_winsize = ntohl(ackinfo->rwind);
+
+	mtu = min(ntohl(ackinfo->rxMTU), ntohl(ackinfo->maxMTU));
+
+	peer = call->peer;
+	if (mtu < peer->maxdata) {
+		spin_lock_bh(&peer->lock);
+		peer->maxdata = mtu;
+		peer->mtu = mtu + peer->hdrsize;
+		spin_unlock_bh(&peer->lock);
+		_net("Net MTU %u (maxdata %u)", peer->mtu, peer->maxdata);
+	}
+}
 
-		if (try_to_del_timer_sync(&call->resend_timer) >= 0) {
-			clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events);
-			clear_bit(RXRPC_CALL_EV_RESEND, &call->events);
-			clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
+/*
+ * Process individual soft ACKs.
+ *
+ * Each ACK in the array corresponds to one packet and can be either an ACK or
+ * a NAK.  If we get find an explicitly NAK'd packet we resend immediately;
+ * packets that lie beyond the end of the ACK list are scheduled for resend by
+ * the timer on the basis that the peer might just not have processed them at
+ * the time the ACK was sent.
+ */
+static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
+				  rxrpc_seq_t seq, int nr_acks)
+{
+	bool resend = false;
+	int ix;
+
+	for (; nr_acks > 0; nr_acks--, seq++) {
+		ix = seq & RXRPC_RXTX_BUFF_MASK;
+		switch (*acks) {
+		case RXRPC_ACK_TYPE_ACK:
+			call->rxtx_annotations[ix] = RXRPC_TX_ANNO_ACK;
+			break;
+		case RXRPC_ACK_TYPE_NACK:
+			if (call->rxtx_annotations[ix] == RXRPC_TX_ANNO_NAK)
+				continue;
+			call->rxtx_annotations[ix] = RXRPC_TX_ANNO_NAK;
+			resend = true;
+			break;
+		default:
+			return rxrpc_proto_abort("SFT", call, 0);
 		}
-		break;
-
-	default:
-		write_unlock_bh(&call->state_lock);
-		break;
 	}
+
+	if (resend &&
+	    !test_and_set_bit(RXRPC_CALL_EV_RESEND, &call->events))
+		rxrpc_queue_call(call);
 }
 
 /*
- * post an incoming packet to the nominated call to deal with
- * - must get rid of the sk_buff, either by freeing it or by queuing it
+ * Process an ACK packet.
+ *
+ * ack.firstPacket is the sequence number of the first soft-ACK'd/NAK'd packet
+ * in the ACK array.  Anything before that is hard-ACK'd and may be discarded.
+ *
+ * A hard-ACK means that a packet has been processed and may be discarded; a
+ * soft-ACK means that the packet may be discarded and retransmission
+ * requested.  A phase is complete when all packets are hard-ACK'd.
  */
-void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
+static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
+			    u16 skew)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	__be32 wtmp;
-	u32 abort_code;
-
-	_enter("%p,%p", call, skb);
-
-	ASSERT(!irqs_disabled());
-
-#if 0 // INJECT RX ERROR
-	if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA) {
-		static int skip = 0;
-		if (++skip == 3) {
-			printk("DROPPED 3RD PACKET!!!!!!!!!!!!!\n");
-			skip = 0;
-			goto free_packet;
-		}
+	union {
+		struct rxrpc_ackpacket ack;
+		struct rxrpc_ackinfo info;
+		u8 acks[RXRPC_MAXACKS];
+	} buf;
+	rxrpc_seq_t first_soft_ack, hard_ack;
+	int nr_acks, offset;
+
+	_enter("");
+
+	if (skb_copy_bits(skb, sp->offset, &buf.ack, sizeof(buf.ack)) < 0) {
+		_debug("extraction failure");
+		return rxrpc_proto_abort("XAK", call, 0);
 	}
-#endif
-
-	/* request ACK generation for any ACK or DATA packet that requests
-	 * it */
-	if (sp->hdr.flags & RXRPC_REQUEST_ACK) {
-		_proto("ACK Requested on %%%u", sp->hdr.serial);
+	sp->offset += sizeof(buf.ack);
+
+	first_soft_ack = ntohl(buf.ack.firstPacket);
+	hard_ack = first_soft_ack - 1;
+	nr_acks = buf.ack.nAcks;
+
+	_proto("Rx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
+	       sp->hdr.serial,
+	       ntohs(buf.ack.maxSkew),
+	       first_soft_ack,
+	       ntohl(buf.ack.previousPacket),
+	       ntohl(buf.ack.serial),
+	       rxrpc_acks(buf.ack.reason),
+	       buf.ack.nAcks);
+
+	if (buf.ack.reason == RXRPC_ACK_PING) {
+		_proto("Rx ACK %%%u PING Request", sp->hdr.serial);
+		rxrpc_propose_ACK(call, RXRPC_ACK_PING_RESPONSE,
+				  skew, sp->hdr.serial, true, true);
+	} else if (sp->hdr.flags & RXRPC_REQUEST_ACK) {
 		rxrpc_propose_ACK(call, RXRPC_ACK_REQUESTED,
-				  skb->priority, sp->hdr.serial, false);
+				  skew, sp->hdr.serial, true, true);
 	}
 
-	switch (sp->hdr.type) {
-	case RXRPC_PACKET_TYPE_ABORT:
-		_debug("abort");
-
-		if (skb_copy_bits(skb, 0, &wtmp, sizeof(wtmp)) < 0)
-			goto protocol_error;
-
-		abort_code = ntohl(wtmp);
-		_proto("Rx ABORT %%%u { %x }", sp->hdr.serial, abort_code);
-
-		if (__rxrpc_set_call_completion(call,
-						RXRPC_CALL_REMOTELY_ABORTED,
-						abort_code, ECONNABORTED)) {
-			set_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
-			rxrpc_queue_call(call);
-		}
-		goto free_packet;
-
-	case RXRPC_PACKET_TYPE_BUSY:
-		_proto("Rx BUSY %%%u", sp->hdr.serial);
-
-		if (rxrpc_is_service_call(call))
-			goto protocol_error;
+	offset = sp->offset + nr_acks + 3;
+	if (skb->data_len >= offset + sizeof(buf.info)) {
+		if (skb_copy_bits(skb, offset, &buf.info, sizeof(buf.info)) < 0)
+			return rxrpc_proto_abort("XAI", call, 0);
+		rxrpc_input_ackinfo(call, skb, &buf.info);
+	}
 
-		write_lock_bh(&call->state_lock);
-		switch (call->state) {
-		case RXRPC_CALL_CLIENT_SEND_REQUEST:
-			__rxrpc_set_call_completion(call,
-						    RXRPC_CALL_SERVER_BUSY,
-						    0, EBUSY);
-			set_bit(RXRPC_CALL_EV_RCVD_BUSY, &call->events);
-			rxrpc_queue_call(call);
-		case RXRPC_CALL_SERVER_BUSY:
-			goto free_packet_unlock;
-		default:
-			goto protocol_error_locked;
-		}
+	if (first_soft_ack == 0)
+		return rxrpc_proto_abort("AK0", call, 0);
 
+	/* Ignore ACKs unless we are or have just been transmitting. */
+	switch (call->state) {
+	case RXRPC_CALL_CLIENT_SEND_REQUEST:
+	case RXRPC_CALL_CLIENT_AWAIT_REPLY:
+	case RXRPC_CALL_SERVER_SEND_REPLY:
+	case RXRPC_CALL_SERVER_AWAIT_ACK:
+		break;
 	default:
-		_proto("Rx %s %%%u", rxrpc_pkts[sp->hdr.type], sp->hdr.serial);
-		goto protocol_error;
-
-	case RXRPC_PACKET_TYPE_DATA:
-		_proto("Rx DATA %%%u { #%u }", sp->hdr.serial, sp->hdr.seq);
-
-		if (sp->hdr.seq == 0)
-			goto protocol_error;
-
-		call->ackr_prev_seq = sp->hdr.seq;
+		return;
+	}
 
-		/* received data implicitly ACKs all of the request packets we
-		 * sent when we're acting as a client */
-		if (call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY)
-			rxrpc_assume_implicit_ackall(call, sp->hdr.serial);
+	/* Discard any out-of-order or duplicate ACKs. */
+	if ((int)sp->hdr.serial - (int)call->acks_latest <= 0) {
+		_debug("discard ACK %d <= %d",
+		       sp->hdr.serial, call->acks_latest);
+		return;
+	}
+	call->acks_latest = sp->hdr.serial;
 
-		switch (rxrpc_fast_process_data(call, skb, sp->hdr.seq)) {
-		case 0:
-			skb = NULL;
-			goto done;
+	if (test_bit(RXRPC_CALL_TX_LAST, &call->flags) &&
+	    hard_ack == call->tx_top) {
+		rxrpc_end_tx_phase(call, "ETA");
+		return;
+	}
 
-		default:
-			BUG();
+	if (before(hard_ack, call->tx_hard_ack) ||
+	    after(hard_ack, call->tx_top))
+		return rxrpc_proto_abort("AKW", call, 0);
 
-			/* data packet received beyond the last packet */
-		case -EBADMSG:
-			goto protocol_error;
-		}
+	if (after(hard_ack, call->tx_hard_ack))
+		rxrpc_rotate_tx_window(call, hard_ack);
 
-	case RXRPC_PACKET_TYPE_ACKALL:
-	case RXRPC_PACKET_TYPE_ACK:
-		/* ACK processing is done in process context */
-		read_lock_bh(&call->state_lock);
-		if (call->state < RXRPC_CALL_COMPLETE) {
-			skb_queue_tail(&call->rx_queue, skb);
-			rxrpc_queue_call(call);
-			skb = NULL;
-		}
-		read_unlock_bh(&call->state_lock);
-		goto free_packet;
-	}
+	if (after(first_soft_ack, call->tx_top))
+		return;
 
-protocol_error:
-	_debug("protocol error");
-	write_lock_bh(&call->state_lock);
-protocol_error_locked:
-	if (__rxrpc_abort_call("FPR", call, 0, RX_PROTOCOL_ERROR, EPROTO))
-		rxrpc_queue_call(call);
-free_packet_unlock:
-	write_unlock_bh(&call->state_lock);
-free_packet:
-	rxrpc_free_skb(skb);
-done:
-	_leave("");
+	if (nr_acks > call->tx_top - first_soft_ack + 1)
+		nr_acks = first_soft_ack - call->tx_top + 1;
+	if (skb_copy_bits(skb, sp->offset, buf.acks, nr_acks) < 0)
+		return rxrpc_proto_abort("XSA", call, 0);
+	rxrpc_input_soft_acks(call, buf.acks, first_soft_ack, nr_acks);
 }
 
 /*
- * split up a jumbo data packet
+ * Process an ACKALL packet.
  */
-static void rxrpc_process_jumbo_packet(struct rxrpc_call *call,
-				       struct sk_buff *jumbo)
+static void rxrpc_input_ackall(struct rxrpc_call *call, struct sk_buff *skb)
 {
-	struct rxrpc_jumbo_header jhdr;
-	struct rxrpc_skb_priv *sp;
-	struct sk_buff *part;
-
-	_enter(",{%u,%u}", jumbo->data_len, jumbo->len);
-
-	sp = rxrpc_skb(jumbo);
-
-	do {
-		sp->hdr.flags &= ~RXRPC_JUMBO_PACKET;
-
-		/* make a clone to represent the first subpacket in what's left
-		 * of the jumbo packet */
-		part = skb_clone(jumbo, GFP_ATOMIC);
-		if (!part) {
-			/* simply ditch the tail in the event of ENOMEM */
-			pskb_trim(jumbo, RXRPC_JUMBO_DATALEN);
-			break;
-		}
-		rxrpc_new_skb(part);
-
-		pskb_trim(part, RXRPC_JUMBO_DATALEN);
-
-		if (!pskb_pull(jumbo, RXRPC_JUMBO_DATALEN))
-			goto protocol_error;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 
-		if (skb_copy_bits(jumbo, 0, &jhdr, sizeof(jhdr)) < 0)
-			goto protocol_error;
-		if (!pskb_pull(jumbo, sizeof(jhdr)))
-			BUG();
+	_proto("Rx ACKALL %%%u", sp->hdr.serial);
 
-		sp->hdr.seq	+= 1;
-		sp->hdr.serial	+= 1;
-		sp->hdr.flags	= jhdr.flags;
-		sp->hdr._rsvd	= ntohs(jhdr._rsvd);
+	rxrpc_end_tx_phase(call, "ETL");
+}
 
-		_proto("Rx DATA Jumbo %%%u", sp->hdr.serial - 1);
+/*
+ * Process an ABORT packet.
+ */
+static void rxrpc_input_abort(struct rxrpc_call *call, struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	__be32 wtmp;
+	u32 abort_code = RX_CALL_DEAD;
 
-		rxrpc_fast_process_packet(call, part);
-		part = NULL;
+	_enter("");
 
-	} while (sp->hdr.flags & RXRPC_JUMBO_PACKET);
+	if (skb->len >= 4 &&
+	    skb_copy_bits(skb, sp->offset, &wtmp, sizeof(wtmp)) >= 0)
+		abort_code = ntohl(wtmp);
 
-	rxrpc_fast_process_packet(call, jumbo);
-	_leave("");
-	return;
+	_proto("Rx ABORT %%%u { %x }", sp->hdr.serial, abort_code);
 
-protocol_error:
-	_debug("protocol error");
-	rxrpc_free_skb(part);
-	if (rxrpc_abort_call("PJP", call, sp->hdr.seq,
-			     RX_PROTOCOL_ERROR, EPROTO))
-		rxrpc_queue_call(call);
-	rxrpc_free_skb(jumbo);
-	_leave("");
+	if (rxrpc_set_call_completion(call, RXRPC_CALL_REMOTELY_ABORTED,
+				      abort_code, ECONNABORTED))
+		rxrpc_notify_socket(call);
 }
 
 /*
- * post an incoming packet to the appropriate call/socket to deal with
- * - must get rid of the sk_buff, either by freeing it or by queuing it
+ * Process an incoming call packet.
  */
-static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
-				      struct rxrpc_call *call,
-				      struct sk_buff *skb)
+static void rxrpc_input_call_packet(struct rxrpc_call *call,
+				    struct sk_buff *skb, u16 skew)
 {
-	struct rxrpc_skb_priv *sp;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 
 	_enter("%p,%p", call, skb);
 
-	sp = rxrpc_skb(skb);
-
-	_debug("extant call [%d]", call->state);
-
-	read_lock(&call->state_lock);
-	switch (call->state) {
-	case RXRPC_CALL_COMPLETE:
-		switch (call->completion) {
-		case RXRPC_CALL_LOCALLY_ABORTED:
-			if (!test_and_set_bit(RXRPC_CALL_EV_ABORT,
-					      &call->events)) {
-				rxrpc_queue_call(call);
-				goto free_unlock;
-			}
-		default:
-			goto dead_call;
-		case RXRPC_CALL_SUCCEEDED:
-			if (rxrpc_is_service_call(call))
-				goto dead_call;
-			goto resend_final_ack;
-		}
-
-	case RXRPC_CALL_CLIENT_FINAL_ACK:
-		goto resend_final_ack;
+	switch (sp->hdr.type) {
+	case RXRPC_PACKET_TYPE_DATA:
+		rxrpc_input_data(call, skb, skew);
+		break;
 
-	default:
+	case RXRPC_PACKET_TYPE_ACK:
+		rxrpc_input_ack(call, skb, skew);
 		break;
-	}
 
-	read_unlock(&call->state_lock);
+	case RXRPC_PACKET_TYPE_BUSY:
+		_proto("Rx BUSY %%%u", sp->hdr.serial);
 
-	if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA &&
-	    sp->hdr.flags & RXRPC_JUMBO_PACKET)
-		rxrpc_process_jumbo_packet(call, skb);
-	else
-		rxrpc_fast_process_packet(call, skb);
+		/* Just ignore BUSY packets from the server; the retry and
+		 * lifespan timers will take care of business.  BUSY packets
+		 * from the client don't make sense.
+		 */
+		break;
 
-	goto done;
+	case RXRPC_PACKET_TYPE_ABORT:
+		rxrpc_input_abort(call, skb);
+		break;
 
-resend_final_ack:
-	_debug("final ack again");
-	set_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
-	rxrpc_queue_call(call);
-	goto free_unlock;
+	case RXRPC_PACKET_TYPE_ACKALL:
+		rxrpc_input_ackall(call, skb);
+		break;
 
-dead_call:
-	if (sp->hdr.type != RXRPC_PACKET_TYPE_ABORT) {
-		skb->priority = RX_CALL_DEAD;
-		rxrpc_reject_packet(conn->params.local, skb);
-		goto unlock;
+	default:
+		_proto("Rx %s %%%u", rxrpc_pkts[sp->hdr.type], sp->hdr.serial);
+		break;
 	}
-free_unlock:
-	rxrpc_free_skb(skb);
-unlock:
-	read_unlock(&call->state_lock);
-done:
+
 	_leave("");
 }
 
@@ -601,6 +599,17 @@ static void rxrpc_post_packet_to_local(struct rxrpc_local *local,
 }
 
 /*
+ * put a packet up for transport-level abort
+ */
+static void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
+{
+	CHECK_SLAB_OKAY(&local->usage);
+
+	skb_queue_tail(&local->reject_queue, skb);
+	rxrpc_queue_local(local);
+}
+
+/*
  * Extract the wire header from a packet and translate the byte order.
  */
 static noinline
@@ -611,8 +620,6 @@ int rxrpc_extract_header(struct rxrpc_skb_priv *sp, struct sk_buff *skb)
 	/* dig out the RxRPC connection details */
 	if (skb_copy_bits(skb, 0, &whdr, sizeof(whdr)) < 0)
 		return -EBADMSG;
-	if (!pskb_pull(skb, sizeof(whdr)))
-		BUG();
 
 	memset(sp, 0, sizeof(*sp));
 	sp->hdr.epoch		= ntohl(whdr.epoch);
@@ -626,6 +633,7 @@ int rxrpc_extract_header(struct rxrpc_skb_priv *sp, struct sk_buff *skb)
 	sp->hdr.securityIndex	= whdr.securityIndex;
 	sp->hdr._rsvd		= ntohs(whdr._rsvd);
 	sp->hdr.serviceId	= ntohs(whdr.serviceId);
+	sp->offset = sizeof(whdr);
 	return 0;
 }
 
@@ -637,19 +645,22 @@ int rxrpc_extract_header(struct rxrpc_skb_priv *sp, struct sk_buff *skb)
  * shut down and the local endpoint from going away, thus sk_user_data will not
  * be cleared until this function returns.
  */
-void rxrpc_data_ready(struct sock *sk)
+void rxrpc_data_ready(struct sock *udp_sk)
 {
 	struct rxrpc_connection *conn;
+	struct rxrpc_channel *chan;
+	struct rxrpc_call *call;
 	struct rxrpc_skb_priv *sp;
-	struct rxrpc_local *local = sk->sk_user_data;
+	struct rxrpc_local *local = udp_sk->sk_user_data;
 	struct sk_buff *skb;
+	unsigned int channel;
 	int ret, skew;
 
-	_enter("%p", sk);
+	_enter("%p", udp_sk);
 
 	ASSERT(!irqs_disabled());
 
-	skb = skb_recv_datagram(sk, 0, 1, &ret);
+	skb = skb_recv_datagram(udp_sk, 0, 1, &ret);
 	if (!skb) {
 		if (ret == -EAGAIN)
 			return;
@@ -695,111 +706,122 @@ void rxrpc_data_ready(struct sock *sk)
 		goto bad_message;
 	}
 
-	if (sp->hdr.type == RXRPC_PACKET_TYPE_VERSION) {
+	switch (sp->hdr.type) {
+	case RXRPC_PACKET_TYPE_VERSION:
 		rxrpc_post_packet_to_local(local, skb);
 		goto out;
-	}
 
-	if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA &&
-	    (sp->hdr.callNumber == 0 || sp->hdr.seq == 0))
-		goto bad_message;
+	case RXRPC_PACKET_TYPE_BUSY:
+		if (sp->hdr.flags & RXRPC_CLIENT_INITIATED)
+			goto discard;
+
+	case RXRPC_PACKET_TYPE_DATA:
+		if (sp->hdr.callNumber == 0)
+			goto bad_message;
+		if (sp->hdr.flags & RXRPC_JUMBO_PACKET &&
+		    !rxrpc_validate_jumbo(skb))
+			goto bad_message;
+		break;
+	}
 
 	rcu_read_lock();
 
 	conn = rxrpc_find_connection_rcu(local, skb);
-	if (!conn) {
-		skb->priority = 0;
-		goto cant_route_call;
-	}
+	if (conn) {
+		if (sp->hdr.securityIndex != conn->security_ix)
+			goto wrong_security;
 
-	/* Note the serial number skew here */
-	skew = (int)sp->hdr.serial - (int)conn->hi_serial;
-	if (skew >= 0) {
-		if (skew > 0)
-			conn->hi_serial = sp->hdr.serial;
-		skb->priority = 0;
-	} else {
-		skew = -skew;
-		skb->priority = min(skew, 65535);
-	}
+		if (sp->hdr.callNumber == 0) {
+			/* Connection-level packet */
+			_debug("CONN %p {%d}", conn, conn->debug_id);
+			rxrpc_post_packet_to_conn(conn, skb);
+			goto out_unlock;
+		}
+
+		/* Note the serial number skew here */
+		skew = (int)sp->hdr.serial - (int)conn->hi_serial;
+		if (skew >= 0) {
+			if (skew > 0)
+				conn->hi_serial = sp->hdr.serial;
+		} else {
+			skew = -skew;
+			skew = min(skew, 65535);
+		}
 
-	if (sp->hdr.callNumber == 0) {
-		/* Connection-level packet */
-		_debug("CONN %p {%d}", conn, conn->debug_id);
-		rxrpc_post_packet_to_conn(conn, skb);
-		goto out_unlock;
-	} else {
 		/* Call-bound packets are routed by connection channel. */
-		unsigned int channel = sp->hdr.cid & RXRPC_CHANNELMASK;
-		struct rxrpc_channel *chan = &conn->channels[channel];
-		struct rxrpc_call *call;
+		channel = sp->hdr.cid & RXRPC_CHANNELMASK;
+		chan = &conn->channels[channel];
 
 		/* Ignore really old calls */
 		if (sp->hdr.callNumber < chan->last_call)
 			goto discard_unlock;
 
 		if (sp->hdr.callNumber == chan->last_call) {
-			/* For the previous service call, if completed
-			 * successfully, we discard all further packets.
+			/* For the previous service call, if completed successfully, we
+			 * discard all further packets.
 			 */
 			if (rxrpc_conn_is_service(conn) &&
 			    (chan->last_type == RXRPC_PACKET_TYPE_ACK ||
 			     sp->hdr.type == RXRPC_PACKET_TYPE_ABORT))
 				goto discard_unlock;
 
-			/* But otherwise we need to retransmit the final packet
-			 * from data cached in the connection record.
+			/* But otherwise we need to retransmit the final packet from
+			 * data cached in the connection record.
 			 */
 			rxrpc_post_packet_to_conn(conn, skb);
 			goto out_unlock;
 		}
 
 		call = rcu_dereference(chan->call);
-		if (!call || atomic_read(&call->usage) == 0)
-			goto cant_route_call;
+	} else {
+		skew = 0;
+		call = NULL;
+	}
 
-		rxrpc_see_call(call);
-		rxrpc_post_packet_to_call(conn, call, skb);
-		goto out_unlock;
+	if (!call || atomic_read(&call->usage) == 0) {
+		if (!(sp->hdr.type & RXRPC_CLIENT_INITIATED) ||
+		    sp->hdr.callNumber == 0 ||
+		    sp->hdr.type != RXRPC_PACKET_TYPE_DATA)
+			goto bad_message_unlock;
+		if (sp->hdr.seq != 1)
+			goto discard_unlock;
+		call = rxrpc_new_incoming_call(local, conn, skb);
+		if (!call) {
+			rcu_read_unlock();
+			goto reject_packet;
+		}
 	}
 
+	rxrpc_input_call_packet(call, skb, skew);
+	goto discard_unlock;
+
 discard_unlock:
-	rxrpc_free_skb(skb);
-out_unlock:
 	rcu_read_unlock();
+discard:
+	rxrpc_free_skb(skb);
 out:
 	trace_rxrpc_rx_done(0, 0);
 	return;
 
-cant_route_call:
+out_unlock:
 	rcu_read_unlock();
+	goto out;
 
-	_debug("can't route call");
-	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED &&
-	    sp->hdr.type == RXRPC_PACKET_TYPE_DATA) {
-		if (sp->hdr.seq == 1) {
-			_debug("first packet");
-			skb_queue_tail(&local->accept_queue, skb);
-			rxrpc_queue_work(&local->processor);
-			_leave(" [incoming]");
-			goto out;
-		}
-		skb->priority = RX_INVALID_OPERATION;
-	} else {
-		skb->priority = RX_CALL_DEAD;
-	}
-
-	if (sp->hdr.type != RXRPC_PACKET_TYPE_ABORT) {
-		_debug("reject type %d",sp->hdr.type);
-		goto reject_packet;
-	} else {
-		rxrpc_free_skb(skb);
-	}
-	_leave(" [no call]");
-	return;
+wrong_security:
+	rcu_read_unlock();
+	trace_rxrpc_abort("SEC", sp->hdr.cid, sp->hdr.callNumber, sp->hdr.seq,
+			  RXKADINCONSISTENCY, EBADMSG);
+	skb->priority = RXKADINCONSISTENCY;
+	goto post_abort;
 
+bad_message_unlock:
+	rcu_read_unlock();
 bad_message:
+	trace_rxrpc_abort("BAD", sp->hdr.cid, sp->hdr.callNumber, sp->hdr.seq,
+			  RX_PROTOCOL_ERROR, EBADMSG);
 	skb->priority = RX_PROTOCOL_ERROR;
+post_abort:
+	skb->mark = RXRPC_SKB_MARK_LOCAL_ABORT;
 reject_packet:
 	trace_rxrpc_rx_done(skb->mark, skb->priority);
 	rxrpc_reject_packet(local, skb);
diff --git a/net/rxrpc/insecure.c b/net/rxrpc/insecure.c
index a4aba0246731..7d4375e557e6 100644
--- a/net/rxrpc/insecure.c
+++ b/net/rxrpc/insecure.c
@@ -30,14 +30,18 @@ static int none_secure_packet(struct rxrpc_call *call,
 	return 0;
 }
 
-static int none_verify_packet(struct rxrpc_call *call,
-			      struct sk_buff *skb,
-			      rxrpc_seq_t seq,
-			      u16 expected_cksum)
+static int none_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
+			      unsigned int offset, unsigned int len,
+			      rxrpc_seq_t seq, u16 expected_cksum)
 {
 	return 0;
 }
 
+static void none_locate_data(struct rxrpc_call *call, struct sk_buff *skb,
+			     unsigned int *_offset, unsigned int *_len)
+{
+}
+
 static int none_respond_to_challenge(struct rxrpc_connection *conn,
 				     struct sk_buff *skb,
 				     u32 *_abort_code)
@@ -79,6 +83,7 @@ const struct rxrpc_security rxrpc_no_security = {
 	.prime_packet_security		= none_prime_packet_security,
 	.secure_packet			= none_secure_packet,
 	.verify_packet			= none_verify_packet,
+	.locate_data			= none_locate_data,
 	.respond_to_challenge		= none_respond_to_challenge,
 	.verify_response		= none_verify_response,
 	.clear				= none_clear,
diff --git a/net/rxrpc/local_event.c b/net/rxrpc/local_event.c
index bcc6593b4cdb..cdd58e6e9fbd 100644
--- a/net/rxrpc/local_event.c
+++ b/net/rxrpc/local_event.c
@@ -98,7 +98,7 @@ void rxrpc_process_local_events(struct rxrpc_local *local)
 
 		switch (sp->hdr.type) {
 		case RXRPC_PACKET_TYPE_VERSION:
-			if (skb_copy_bits(skb, 0, &v, 1) < 0)
+			if (skb_copy_bits(skb, sp->offset, &v, 1) < 0)
 				return;
 			_proto("Rx VERSION { %02x }", v);
 			if (v == 0)
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index 610916f4ae34..782b9adf67cb 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -77,7 +77,6 @@ static struct rxrpc_local *rxrpc_alloc_local(const struct sockaddr_rxrpc *srx)
 		INIT_WORK(&local->processor, rxrpc_local_processor);
 		INIT_HLIST_HEAD(&local->services);
 		init_rwsem(&local->defrag_sem);
-		skb_queue_head_init(&local->accept_queue);
 		skb_queue_head_init(&local->reject_queue);
 		skb_queue_head_init(&local->event_queue);
 		local->client_conns = RB_ROOT;
@@ -308,7 +307,6 @@ static void rxrpc_local_destroyer(struct rxrpc_local *local)
 	/* At this point, there should be no more packets coming in to the
 	 * local endpoint.
 	 */
-	rxrpc_purge_queue(&local->accept_queue);
 	rxrpc_purge_queue(&local->reject_queue);
 	rxrpc_purge_queue(&local->event_queue);
 
@@ -332,11 +330,6 @@ static void rxrpc_local_processor(struct work_struct *work)
 		if (atomic_read(&local->usage) == 0)
 			return rxrpc_local_destroyer(local);
 
-		if (!skb_queue_empty(&local->accept_queue)) {
-			rxrpc_accept_incoming_calls(local);
-			again = true;
-		}
-
 		if (!skb_queue_empty(&local->reject_queue)) {
 			rxrpc_reject_packets(local);
 			again = true;
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 39e7cc37c392..fd096f742e4b 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -50,7 +50,7 @@ unsigned int rxrpc_idle_ack_delay = 0.5 * HZ;
  * limit is hit, we should generate an EXCEEDS_WINDOW ACK and discard further
  * packets.
  */
-unsigned int rxrpc_rx_window_size = 32;
+unsigned int rxrpc_rx_window_size = RXRPC_RXTX_BUFF_SIZE - 46;
 
 /*
  * Maximum Rx MTU size.  This indicates to the sender the size of jumbo packet
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 8756d74fd74b..719a4c23f09d 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -15,6 +15,8 @@
 #include <linux/gfp.h>
 #include <linux/skbuff.h>
 #include <linux/export.h>
+#include <linux/udp.h>
+#include <linux/ip.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
@@ -38,20 +40,38 @@ struct rxrpc_pkt_buffer {
 static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 				 struct rxrpc_pkt_buffer *pkt)
 {
+	rxrpc_seq_t hard_ack, top, seq;
+	int ix;
 	u32 mtu, jmax;
 	u8 *ackp = pkt->acks;
 
+	/* Barrier against rxrpc_input_data(). */
+	hard_ack = READ_ONCE(call->rx_hard_ack);
+	top = smp_load_acquire(&call->rx_top);
+
 	pkt->ack.bufferSpace	= htons(8);
-	pkt->ack.maxSkew	= htons(0);
-	pkt->ack.firstPacket	= htonl(call->rx_data_eaten + 1);
+	pkt->ack.maxSkew	= htons(call->ackr_skew);
+	pkt->ack.firstPacket	= htonl(hard_ack + 1);
 	pkt->ack.previousPacket	= htonl(call->ackr_prev_seq);
 	pkt->ack.serial		= htonl(call->ackr_serial);
-	pkt->ack.reason		= RXRPC_ACK_IDLE;
-	pkt->ack.nAcks		= 0;
+	pkt->ack.reason		= call->ackr_reason;
+	pkt->ack.nAcks		= top - hard_ack;
+
+	if (after(top, hard_ack)) {
+		seq = hard_ack + 1;
+		do {
+			ix = seq & RXRPC_RXTX_BUFF_MASK;
+			if (call->rxtx_buffer[ix])
+				*ackp++ = RXRPC_ACK_TYPE_ACK;
+			else
+				*ackp++ = RXRPC_ACK_TYPE_NACK;
+			seq++;
+		} while (before_eq(seq, top));
+	}
 
-	mtu = call->peer->if_mtu;
-	mtu -= call->peer->hdrsize;
-	jmax = rxrpc_rx_jumbo_max;
+	mtu = call->conn->params.peer->if_mtu;
+	mtu -= call->conn->params.peer->hdrsize;
+	jmax = (call->nr_jumbo_dup > 3) ? 1 : rxrpc_rx_jumbo_max;
 	pkt->ackinfo.rxMTU	= htonl(rxrpc_rx_mtu);
 	pkt->ackinfo.maxMTU	= htonl(mtu);
 	pkt->ackinfo.rwind	= htonl(rxrpc_rx_window_size);
@@ -60,11 +80,11 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 	*ackp++ = 0;
 	*ackp++ = 0;
 	*ackp++ = 0;
-	return 3;
+	return top - hard_ack + 3;
 }
 
 /*
- * Send a final ACK or ABORT call packet.
+ * Send an ACK or ABORT call packet.
  */
 int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 {
@@ -158,6 +178,19 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 	ret = kernel_sendmsg(conn->params.local->socket,
 			     &msg, iov, ioc, len);
 
+	if (ret < 0 && call->state < RXRPC_CALL_COMPLETE) {
+		switch (pkt->whdr.type) {
+		case RXRPC_PACKET_TYPE_ACK:
+			rxrpc_propose_ACK(call, pkt->ack.reason,
+					  ntohs(pkt->ack.maxSkew),
+					  ntohl(pkt->ack.serial),
+					  true, true);
+			break;
+		case RXRPC_PACKET_TYPE_ABORT:
+			break;
+		}
+	}
+
 out:
 	rxrpc_put_connection(conn);
 	kfree(pkt);
@@ -233,3 +266,77 @@ send_fragmentable:
 	_leave(" = %d [frag %u]", ret, conn->params.peer->maxdata);
 	return ret;
 }
+
+/*
+ * reject packets through the local endpoint
+ */
+void rxrpc_reject_packets(struct rxrpc_local *local)
+{
+	union {
+		struct sockaddr sa;
+		struct sockaddr_in sin;
+	} sa;
+	struct rxrpc_skb_priv *sp;
+	struct rxrpc_wire_header whdr;
+	struct sk_buff *skb;
+	struct msghdr msg;
+	struct kvec iov[2];
+	size_t size;
+	__be32 code;
+
+	_enter("%d", local->debug_id);
+
+	iov[0].iov_base = &whdr;
+	iov[0].iov_len = sizeof(whdr);
+	iov[1].iov_base = &code;
+	iov[1].iov_len = sizeof(code);
+	size = sizeof(whdr) + sizeof(code);
+
+	msg.msg_name = &sa;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = 0;
+
+	memset(&sa, 0, sizeof(sa));
+	sa.sa.sa_family = local->srx.transport.family;
+	switch (sa.sa.sa_family) {
+	case AF_INET:
+		msg.msg_namelen = sizeof(sa.sin);
+		break;
+	default:
+		msg.msg_namelen = 0;
+		break;
+	}
+
+	memset(&whdr, 0, sizeof(whdr));
+	whdr.type = RXRPC_PACKET_TYPE_ABORT;
+
+	while ((skb = skb_dequeue(&local->reject_queue))) {
+		rxrpc_see_skb(skb);
+		sp = rxrpc_skb(skb);
+		switch (sa.sa.sa_family) {
+		case AF_INET:
+			sa.sin.sin_port = udp_hdr(skb)->source;
+			sa.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
+			code = htonl(skb->priority);
+
+			whdr.epoch	= htonl(sp->hdr.epoch);
+			whdr.cid	= htonl(sp->hdr.cid);
+			whdr.callNumber	= htonl(sp->hdr.callNumber);
+			whdr.serviceId	= htons(sp->hdr.serviceId);
+			whdr.flags	= sp->hdr.flags;
+			whdr.flags	^= RXRPC_CLIENT_INITIATED;
+			whdr.flags	&= RXRPC_CLIENT_INITIATED;
+
+			kernel_sendmsg(local->socket, &msg, iov, 2, size);
+			break;
+
+		default:
+			break;
+		}
+
+		rxrpc_free_skb(skb);
+	}
+
+	_leave("");
+}
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 27b9ecad007e..c8948936c6fc 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -129,15 +129,14 @@ void rxrpc_error_report(struct sock *sk)
 		_leave("UDP socket errqueue empty");
 		return;
 	}
+	rxrpc_new_skb(skb);
 	serr = SKB_EXT_ERR(skb);
 	if (!skb->len && serr->ee.ee_origin == SO_EE_ORIGIN_TIMESTAMPING) {
 		_leave("UDP empty message");
-		kfree_skb(skb);
+		rxrpc_free_skb(skb);
 		return;
 	}
 
-	rxrpc_new_skb(skb);
-
 	rcu_read_lock();
 	peer = rxrpc_lookup_peer_icmp_rcu(local, skb);
 	if (peer && !rxrpc_get_peer_maybe(peer))
@@ -249,7 +248,6 @@ void rxrpc_peer_error_distributor(struct work_struct *work)
 		container_of(work, struct rxrpc_peer, error_distributor);
 	struct rxrpc_call *call;
 	enum rxrpc_call_completion compl;
-	bool queue;
 	int error;
 
 	_enter("");
@@ -272,15 +270,8 @@ void rxrpc_peer_error_distributor(struct work_struct *work)
 		hlist_del_init(&call->error_link);
 		rxrpc_see_call(call);
 
-		queue = false;
-		write_lock(&call->state_lock);
-		if (__rxrpc_set_call_completion(call, compl, 0, error)) {
-			set_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events);
-			queue = true;
-		}
-		write_unlock(&call->state_lock);
-		if (queue)
-			rxrpc_queue_call(call);
+		if (rxrpc_set_call_completion(call, compl, 0, error))
+			rxrpc_notify_socket(call);
 	}
 
 	spin_unlock_bh(&peer->lock);
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index aebc73ac16dc..2efe29a4c232 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -199,6 +199,32 @@ struct rxrpc_peer *rxrpc_alloc_peer(struct rxrpc_local *local, gfp_t gfp)
 }
 
 /*
+ * Initialise peer record.
+ */
+static void rxrpc_init_peer(struct rxrpc_peer *peer, unsigned long hash_key)
+{
+	rxrpc_assess_MTU_size(peer);
+	peer->mtu = peer->if_mtu;
+
+	if (peer->srx.transport.family == AF_INET) {
+		peer->hdrsize = sizeof(struct iphdr);
+		switch (peer->srx.transport_type) {
+		case SOCK_DGRAM:
+			peer->hdrsize += sizeof(struct udphdr);
+			break;
+		default:
+			BUG();
+			break;
+		}
+	} else {
+		BUG();
+	}
+
+	peer->hdrsize += sizeof(struct rxrpc_wire_header);
+	peer->maxdata = peer->mtu - peer->hdrsize;
+}
+
+/*
  * Set up a new peer.
  */
 static struct rxrpc_peer *rxrpc_create_peer(struct rxrpc_local *local,
@@ -214,29 +240,39 @@ static struct rxrpc_peer *rxrpc_create_peer(struct rxrpc_local *local,
 	if (peer) {
 		peer->hash_key = hash_key;
 		memcpy(&peer->srx, srx, sizeof(*srx));
+		rxrpc_init_peer(peer, hash_key);
+	}
 
-		rxrpc_assess_MTU_size(peer);
-		peer->mtu = peer->if_mtu;
-
-		if (srx->transport.family == AF_INET) {
-			peer->hdrsize = sizeof(struct iphdr);
-			switch (srx->transport_type) {
-			case SOCK_DGRAM:
-				peer->hdrsize += sizeof(struct udphdr);
-				break;
-			default:
-				BUG();
-				break;
-			}
-		} else {
-			BUG();
-		}
+	_leave(" = %p", peer);
+	return peer;
+}
 
-		peer->hdrsize += sizeof(struct rxrpc_wire_header);
-		peer->maxdata = peer->mtu - peer->hdrsize;
+/*
+ * Set up a new incoming peer.  The address is prestored in the preallocated
+ * peer.
+ */
+struct rxrpc_peer *rxrpc_lookup_incoming_peer(struct rxrpc_local *local,
+					      struct rxrpc_peer *prealloc)
+{
+	struct rxrpc_peer *peer;
+	unsigned long hash_key;
+
+	hash_key = rxrpc_peer_hash_key(local, &prealloc->srx);
+	prealloc->local = local;
+	rxrpc_init_peer(prealloc, hash_key);
+
+	spin_lock(&rxrpc_peer_hash_lock);
+
+	/* Need to check that we aren't racing with someone else */
+	peer = __rxrpc_lookup_peer_rcu(local, &prealloc->srx, hash_key);
+	if (peer && !rxrpc_get_peer_maybe(peer))
+		peer = NULL;
+	if (!peer) {
+		peer = prealloc;
+		hash_add_rcu(rxrpc_peer_hash, &peer->hash_link, hash_key);
 	}
 
-	_leave(" = %p", peer);
+	spin_unlock(&rxrpc_peer_hash_lock);
 	return peer;
 }
 
@@ -272,7 +308,7 @@ struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *local,
 			return NULL;
 		}
 
-		spin_lock(&rxrpc_peer_hash_lock);
+		spin_lock_bh(&rxrpc_peer_hash_lock);
 
 		/* Need to check that we aren't racing with someone else */
 		peer = __rxrpc_lookup_peer_rcu(local, srx, hash_key);
@@ -282,7 +318,7 @@ struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *local,
 			hash_add_rcu(rxrpc_peer_hash,
 				     &candidate->hash_link, hash_key);
 
-		spin_unlock(&rxrpc_peer_hash_lock);
+		spin_unlock_bh(&rxrpc_peer_hash_lock);
 
 		if (peer)
 			kfree(candidate);
@@ -307,9 +343,9 @@ void __rxrpc_put_peer(struct rxrpc_peer *peer)
 {
 	ASSERT(hlist_empty(&peer->error_targets));
 
-	spin_lock(&rxrpc_peer_hash_lock);
+	spin_lock_bh(&rxrpc_peer_hash_lock);
 	hash_del_rcu(&peer->hash_link);
-	spin_unlock(&rxrpc_peer_hash_lock);
+	spin_unlock_bh(&rxrpc_peer_hash_lock);
 
 	kfree_rcu(peer, rcu);
 }
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 6876ffb3b410..20d0b5c6f81b 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -19,319 +19,479 @@
 #include "ar-internal.h"
 
 /*
- * receive a message from an RxRPC socket
- * - we need to be careful about two or more threads calling recvmsg
- *   simultaneously
+ * Post a call for attention by the socket or kernel service.  Further
+ * notifications are suppressed by putting recvmsg_link on a dummy queue.
  */
-int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
-		  int flags)
+void rxrpc_notify_socket(struct rxrpc_call *call)
 {
-	struct rxrpc_skb_priv *sp;
-	struct rxrpc_call *call = NULL, *continue_call = NULL;
-	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
-	struct sk_buff *skb;
-	long timeo;
-	int copy, ret, ullen, offset, copied = 0;
-	u32 abort_code;
+	struct rxrpc_sock *rx;
+	struct sock *sk;
 
-	DEFINE_WAIT(wait);
+	_enter("%d", call->debug_id);
 
-	_enter(",,,%zu,%d", len, flags);
+	if (!list_empty(&call->recvmsg_link))
+		return;
+
+	rcu_read_lock();
+
+	rx = rcu_dereference(call->socket);
+	sk = &rx->sk;
+	if (rx && sk->sk_state < RXRPC_CLOSE) {
+		if (call->notify_rx) {
+			call->notify_rx(sk, call, call->user_call_ID);
+		} else {
+			write_lock_bh(&rx->recvmsg_lock);
+			if (list_empty(&call->recvmsg_link)) {
+				rxrpc_get_call(call, rxrpc_call_got);
+				list_add_tail(&call->recvmsg_link, &rx->recvmsg_q);
+			}
+			write_unlock_bh(&rx->recvmsg_lock);
 
-	if (flags & (MSG_OOB | MSG_TRUNC))
-		return -EOPNOTSUPP;
+			if (!sock_flag(sk, SOCK_DEAD)) {
+				_debug("call %ps", sk->sk_data_ready);
+				sk->sk_data_ready(sk);
+			}
+		}
+	}
 
-	ullen = msg->msg_flags & MSG_CMSG_COMPAT ? 4 : sizeof(unsigned long);
+	rcu_read_unlock();
+	_leave("");
+}
 
-	timeo = sock_rcvtimeo(&rx->sk, flags & MSG_DONTWAIT);
-	msg->msg_flags |= MSG_MORE;
+/*
+ * Pass a call terminating message to userspace.
+ */
+static int rxrpc_recvmsg_term(struct rxrpc_call *call, struct msghdr *msg)
+{
+	u32 tmp = 0;
+	int ret;
 
-	lock_sock(&rx->sk);
+	switch (call->completion) {
+	case RXRPC_CALL_SUCCEEDED:
+		ret = 0;
+		if (rxrpc_is_service_call(call))
+			ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ACK, 0, &tmp);
+		break;
+	case RXRPC_CALL_REMOTELY_ABORTED:
+		tmp = call->abort_code;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &tmp);
+		break;
+	case RXRPC_CALL_LOCALLY_ABORTED:
+		tmp = call->abort_code;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &tmp);
+		break;
+	case RXRPC_CALL_NETWORK_ERROR:
+		tmp = call->error;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NET_ERROR, 4, &tmp);
+		break;
+	case RXRPC_CALL_LOCAL_ERROR:
+		tmp = call->error;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_LOCAL_ERROR, 4, &tmp);
+		break;
+	default:
+		pr_err("Invalid terminal call state %u\n", call->state);
+		BUG();
+		break;
+	}
 
-	for (;;) {
-		/* return immediately if a client socket has no outstanding
-		 * calls */
-		if (RB_EMPTY_ROOT(&rx->calls)) {
-			if (copied)
-				goto out;
-			if (rx->sk.sk_state != RXRPC_SERVER_LISTENING) {
-				release_sock(&rx->sk);
-				if (continue_call)
-					rxrpc_put_call(continue_call,
-						       rxrpc_call_put);
-				return -ENODATA;
-			}
-		}
+	return ret;
+}
 
-		/* get the next message on the Rx queue */
-		skb = skb_peek(&rx->sk.sk_receive_queue);
-		if (!skb) {
-			/* nothing remains on the queue */
-			if (copied &&
-			    (flags & MSG_PEEK || timeo == 0))
-				goto out;
+/*
+ * Pass back notification of a new call.  The call is added to the
+ * to-be-accepted list.  This means that the next call to be accepted might not
+ * be the last call seen awaiting acceptance, but unless we leave this on the
+ * front of the queue and block all other messages until someone gives us a
+ * user_ID for it, there's not a lot we can do.
+ */
+static int rxrpc_recvmsg_new_call(struct rxrpc_sock *rx,
+				  struct rxrpc_call *call,
+				  struct msghdr *msg, int flags)
+{
+	int tmp = 0, ret;
 
-			/* wait for a message to turn up */
-			release_sock(&rx->sk);
-			prepare_to_wait_exclusive(sk_sleep(&rx->sk), &wait,
-						  TASK_INTERRUPTIBLE);
-			ret = sock_error(&rx->sk);
-			if (ret)
-				goto wait_error;
-
-			if (skb_queue_empty(&rx->sk.sk_receive_queue)) {
-				if (signal_pending(current))
-					goto wait_interrupted;
-				timeo = schedule_timeout(timeo);
-			}
-			finish_wait(sk_sleep(&rx->sk), &wait);
-			lock_sock(&rx->sk);
-			continue;
-		}
+	ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NEW_CALL, 0, &tmp);
 
-	peek_next_packet:
-		rxrpc_see_skb(skb);
-		sp = rxrpc_skb(skb);
-		call = sp->call;
-		ASSERT(call != NULL);
-		rxrpc_see_call(call);
-
-		_debug("next pkt %s", rxrpc_pkts[sp->hdr.type]);
-
-		/* make sure we wait for the state to be updated in this call */
-		spin_lock_bh(&call->lock);
-		spin_unlock_bh(&call->lock);
-
-		if (test_bit(RXRPC_CALL_RELEASED, &call->flags)) {
-			_debug("packet from released call");
-			if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
-				BUG();
-			rxrpc_free_skb(skb);
-			continue;
-		}
+	if (ret == 0 && !(flags & MSG_PEEK)) {
+		_debug("to be accepted");
+		write_lock_bh(&rx->recvmsg_lock);
+		list_del_init(&call->recvmsg_link);
+		write_unlock_bh(&rx->recvmsg_lock);
 
-		/* determine whether to continue last data receive */
-		if (continue_call) {
-			_debug("maybe cont");
-			if (call != continue_call ||
-			    skb->mark != RXRPC_SKB_MARK_DATA) {
-				release_sock(&rx->sk);
-				rxrpc_put_call(continue_call, rxrpc_call_put);
-				_leave(" = %d [noncont]", copied);
-				return copied;
-			}
-		}
+		write_lock(&rx->call_lock);
+		list_add_tail(&call->accept_link, &rx->to_be_accepted);
+		write_unlock(&rx->call_lock);
+	}
 
-		rxrpc_get_call(call, rxrpc_call_got);
+	return ret;
+}
 
-		/* copy the peer address and timestamp */
-		if (!continue_call) {
-			if (msg->msg_name) {
-				size_t len =
-					sizeof(call->conn->params.peer->srx);
-				memcpy(msg->msg_name,
-				       &call->conn->params.peer->srx, len);
-				msg->msg_namelen = len;
-			}
-			sock_recv_timestamp(msg, &rx->sk, skb);
-		}
+/*
+ * End the packet reception phase.
+ */
+static void rxrpc_end_rx_phase(struct rxrpc_call *call)
+{
+	_enter("%d,%s", call->debug_id, rxrpc_call_states[call->state]);
 
-		/* receive the message */
-		if (skb->mark != RXRPC_SKB_MARK_DATA)
-			goto receive_non_data_message;
+	if (call->state == RXRPC_CALL_CLIENT_RECV_REPLY) {
+		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, 0, true, false);
+		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+	} else {
+		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, 0, false, false);
+	}
 
-		_debug("recvmsg DATA #%u { %d, %d }",
-		       sp->hdr.seq, skb->len, sp->offset);
+	write_lock_bh(&call->state_lock);
 
-		if (!continue_call) {
-			/* only set the control data once per recvmsg() */
-			ret = put_cmsg(msg, SOL_RXRPC, RXRPC_USER_CALL_ID,
-				       ullen, &call->user_call_ID);
-			if (ret < 0)
-				goto copy_error;
-			ASSERT(test_bit(RXRPC_CALL_HAS_USERID, &call->flags));
-		}
+	switch (call->state) {
+	case RXRPC_CALL_CLIENT_RECV_REPLY:
+		__rxrpc_call_completed(call);
+		break;
 
-		ASSERTCMP(sp->hdr.seq, >=, call->rx_data_recv);
-		ASSERTCMP(sp->hdr.seq, <=, call->rx_data_recv + 1);
-		call->rx_data_recv = sp->hdr.seq;
+	case RXRPC_CALL_SERVER_RECV_REQUEST:
+		call->state = RXRPC_CALL_SERVER_ACK_REQUEST;
+		break;
+	default:
+		break;
+	}
 
-		ASSERTCMP(sp->hdr.seq, >, call->rx_data_eaten);
+	write_unlock_bh(&call->state_lock);
+}
 
-		offset = sp->offset;
-		copy = skb->len - offset;
-		if (copy > len - copied)
-			copy = len - copied;
+/*
+ * Discard a packet we've used up and advance the Rx window by one.
+ */
+static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
+{
+	struct sk_buff *skb;
+	rxrpc_seq_t hard_ack, top;
+	int ix;
+
+	_enter("%d", call->debug_id);
+
+	hard_ack = call->rx_hard_ack;
+	top = smp_load_acquire(&call->rx_top);
+	ASSERT(before(hard_ack, top));
+
+	hard_ack++;
+	ix = hard_ack & RXRPC_RXTX_BUFF_MASK;
+	skb = call->rxtx_buffer[ix];
+	rxrpc_see_skb(skb);
+	call->rxtx_buffer[ix] = NULL;
+	call->rxtx_annotations[ix] = 0;
+	/* Barrier against rxrpc_input_data(). */
+	smp_store_release(&call->rx_hard_ack, hard_ack);
 
-		ret = skb_copy_datagram_msg(skb, offset, msg, copy);
+	rxrpc_free_skb(skb);
 
+	_debug("%u,%u,%lx", hard_ack, top, call->flags);
+	if (hard_ack == top && test_bit(RXRPC_CALL_RX_LAST, &call->flags))
+		rxrpc_end_rx_phase(call);
+}
+
+/*
+ * Decrypt and verify a (sub)packet.  The packet's length may be changed due to
+ * padding, but if this is the case, the packet length will be resident in the
+ * socket buffer.  Note that we can't modify the master skb info as the skb may
+ * be the home to multiple subpackets.
+ */
+static int rxrpc_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
+			       u8 annotation,
+			       unsigned int offset, unsigned int len)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	rxrpc_seq_t seq = sp->hdr.seq;
+	u16 cksum = sp->hdr.cksum;
+
+	_enter("");
+
+	/* For all but the head jumbo subpacket, the security checksum is in a
+	 * jumbo header immediately prior to the data.
+	 */
+	if ((annotation & RXRPC_RX_ANNO_JUMBO) > 1) {
+		__be16 tmp;
+		if (skb_copy_bits(skb, offset - 2, &tmp, 2) < 0)
+			BUG();
+		cksum = ntohs(tmp);
+		seq += (annotation & RXRPC_RX_ANNO_JUMBO) - 1;
+	}
+
+	return call->conn->security->verify_packet(call, skb, offset, len,
+						   seq, cksum);
+}
+
+/*
+ * Locate the data within a packet.  This is complicated by:
+ *
+ * (1) An skb may contain a jumbo packet - so we have to find the appropriate
+ *     subpacket.
+ *
+ * (2) The (sub)packets may be encrypted and, if so, the encrypted portion
+ *     contains an extra header which includes the true length of the data,
+ *     excluding any encrypted padding.
+ */
+static int rxrpc_locate_data(struct rxrpc_call *call, struct sk_buff *skb,
+			     u8 *_annotation,
+			     unsigned int *_offset, unsigned int *_len)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	unsigned int offset = *_offset;
+	unsigned int len = *_len;
+	int ret;
+	u8 annotation = *_annotation;
+
+	if (offset > 0)
+		return 0;
+
+	/* Locate the subpacket */
+	offset = sp->offset;
+	len = skb->len - sp->offset;
+	if ((annotation & RXRPC_RX_ANNO_JUMBO) > 0) {
+		offset += (((annotation & RXRPC_RX_ANNO_JUMBO) - 1) *
+			   RXRPC_JUMBO_SUBPKTLEN);
+		len = (annotation & RXRPC_RX_ANNO_JLAST) ?
+			skb->len - offset : RXRPC_JUMBO_SUBPKTLEN;
+	}
+
+	if (!(annotation & RXRPC_RX_ANNO_VERIFIED)) {
+		ret = rxrpc_verify_packet(call, skb, annotation, offset, len);
 		if (ret < 0)
-			goto copy_error;
+			return ret;
+		*_annotation |= RXRPC_RX_ANNO_VERIFIED;
+	}
 
-		/* handle piecemeal consumption of data packets */
-		_debug("copied %d+%d", copy, copied);
+	*_offset = offset;
+	*_len = len;
+	call->conn->security->locate_data(call, skb, _offset, _len);
+	return 0;
+}
 
-		offset += copy;
-		copied += copy;
+/*
+ * Deliver messages to a call.  This keeps processing packets until the buffer
+ * is filled and we find either more DATA (returns 0) or the end of the DATA
+ * (returns 1).  If more packets are required, it returns -EAGAIN.
+ */
+static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
+			      struct msghdr *msg, struct iov_iter *iter,
+			      size_t len, int flags, size_t *_offset)
+{
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *skb;
+	rxrpc_seq_t hard_ack, top, seq;
+	size_t remain;
+	bool last;
+	unsigned int rx_pkt_offset, rx_pkt_len;
+	int ix, copy, ret = 0;
+
+	_enter("");
+
+	rx_pkt_offset = call->rx_pkt_offset;
+	rx_pkt_len = call->rx_pkt_len;
+
+	/* Barriers against rxrpc_input_data(). */
+	hard_ack = call->rx_hard_ack;
+	top = smp_load_acquire(&call->rx_top);
+	for (seq = hard_ack + 1; before_eq(seq, top); seq++) {
+		ix = seq & RXRPC_RXTX_BUFF_MASK;
+		skb = call->rxtx_buffer[ix];
+		if (!skb)
+			break;
+		smp_rmb();
+		rxrpc_see_skb(skb);
+		sp = rxrpc_skb(skb);
 
-		if (!(flags & MSG_PEEK))
-			sp->offset = offset;
+		if (msg)
+			sock_recv_timestamp(msg, sock->sk, skb);
+
+		ret = rxrpc_locate_data(call, skb, &call->rxtx_annotations[ix],
+					&rx_pkt_offset, &rx_pkt_len);
+		_debug("recvmsg %x DATA #%u { %d, %d }",
+		       sp->hdr.callNumber, seq, rx_pkt_offset, rx_pkt_len);
+
+		/* We have to handle short, empty and used-up DATA packets. */
+		remain = len - *_offset;
+		copy = rx_pkt_len;
+		if (copy > remain)
+			copy = remain;
+		if (copy > 0) {
+			ret = skb_copy_datagram_iter(skb, rx_pkt_offset, iter,
+						     copy);
+			if (ret < 0)
+				goto out;
+
+			/* handle piecemeal consumption of data packets */
+			_debug("copied %d @%zu", copy, *_offset);
+
+			rx_pkt_offset += copy;
+			rx_pkt_len -= copy;
+			*_offset += copy;
+		}
 
-		if (sp->offset < skb->len) {
+		if (rx_pkt_len > 0) {
 			_debug("buffer full");
-			ASSERTCMP(copied, ==, len);
+			ASSERTCMP(*_offset, ==, len);
 			break;
 		}
 
-		/* we transferred the whole data packet */
+		/* The whole packet has been transferred. */
+		last = sp->hdr.flags & RXRPC_LAST_PACKET;
 		if (!(flags & MSG_PEEK))
-			rxrpc_kernel_data_consumed(call, skb);
-
-		if (sp->hdr.flags & RXRPC_LAST_PACKET) {
-			_debug("last");
-			if (rxrpc_conn_is_client(call->conn)) {
-				 /* last byte of reply received */
-				ret = copied;
-				goto terminal_message;
-			}
+			rxrpc_rotate_rx_window(call);
+		rx_pkt_offset = 0;
+		rx_pkt_len = 0;
 
-			/* last bit of request received */
-			if (!(flags & MSG_PEEK)) {
-				_debug("eat packet");
-				if (skb_dequeue(&rx->sk.sk_receive_queue) !=
-				    skb)
-					BUG();
-				rxrpc_free_skb(skb);
-			}
-			msg->msg_flags &= ~MSG_MORE;
-			break;
-		}
+		ASSERTIFCMP(last, seq, ==, top);
+	}
 
-		/* move on to the next data message */
-		_debug("next");
-		if (!continue_call)
-			continue_call = sp->call;
-		else
-			rxrpc_put_call(call, rxrpc_call_put);
-		call = NULL;
-
-		if (flags & MSG_PEEK) {
-			_debug("peek next");
-			skb = skb->next;
-			if (skb == (struct sk_buff *) &rx->sk.sk_receive_queue)
-				break;
-			goto peek_next_packet;
-		}
+	if (after(seq, top)) {
+		ret = -EAGAIN;
+		if (test_bit(RXRPC_CALL_RX_LAST, &call->flags))
+			ret = 1;
+	}
+out:
+	if (!(flags & MSG_PEEK)) {
+		call->rx_pkt_offset = rx_pkt_offset;
+		call->rx_pkt_len = rx_pkt_len;
+	}
+	_leave(" = %d [%u/%u]", ret, seq, top);
+	return ret;
+}
 
-		_debug("eat packet");
-		if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
-			BUG();
-		rxrpc_free_skb(skb);
+/*
+ * Receive a message from an RxRPC socket
+ * - we need to be careful about two or more threads calling recvmsg
+ *   simultaneously
+ */
+int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+		  int flags)
+{
+	struct rxrpc_call *call;
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+	struct list_head *l;
+	size_t copied = 0;
+	long timeo;
+	int ret;
+
+	DEFINE_WAIT(wait);
+
+	_enter(",,,%zu,%d", len, flags);
+
+	if (flags & (MSG_OOB | MSG_TRUNC))
+		return -EOPNOTSUPP;
+
+	timeo = sock_rcvtimeo(&rx->sk, flags & MSG_DONTWAIT);
+
+try_again:
+	lock_sock(&rx->sk);
+
+	/* Return immediately if a client socket has no outstanding calls */
+	if (RB_EMPTY_ROOT(&rx->calls) &&
+	    list_empty(&rx->recvmsg_q) &&
+	    rx->sk.sk_state != RXRPC_SERVER_LISTENING) {
+		release_sock(&rx->sk);
+		return -ENODATA;
 	}
 
-	/* end of non-terminal data packet reception for the moment */
-	_debug("end rcv data");
-out:
-	release_sock(&rx->sk);
-	if (call)
-		rxrpc_put_call(call, rxrpc_call_put);
-	if (continue_call)
-		rxrpc_put_call(continue_call, rxrpc_call_put);
-	_leave(" = %d [data]", copied);
-	return copied;
-
-	/* handle non-DATA messages such as aborts, incoming connections and
-	 * final ACKs */
-receive_non_data_message:
-	_debug("non-data");
-
-	if (skb->mark == RXRPC_SKB_MARK_NEW_CALL) {
-		_debug("RECV NEW CALL");
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NEW_CALL, 0, &abort_code);
-		if (ret < 0)
-			goto copy_error;
-		if (!(flags & MSG_PEEK)) {
-			if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
-				BUG();
-			rxrpc_free_skb(skb);
+	if (list_empty(&rx->recvmsg_q)) {
+		ret = -EWOULDBLOCK;
+		if (timeo == 0)
+			goto error_no_call;
+
+		release_sock(&rx->sk);
+
+		/* Wait for something to happen */
+		prepare_to_wait_exclusive(sk_sleep(&rx->sk), &wait,
+					  TASK_INTERRUPTIBLE);
+		ret = sock_error(&rx->sk);
+		if (ret)
+			goto wait_error;
+
+		if (list_empty(&rx->recvmsg_q)) {
+			if (signal_pending(current))
+				goto wait_interrupted;
+			timeo = schedule_timeout(timeo);
 		}
-		goto out;
+		finish_wait(sk_sleep(&rx->sk), &wait);
+		goto try_again;
 	}
 
-	ret = put_cmsg(msg, SOL_RXRPC, RXRPC_USER_CALL_ID,
-		       ullen, &call->user_call_ID);
-	if (ret < 0)
-		goto copy_error;
-	ASSERT(test_bit(RXRPC_CALL_HAS_USERID, &call->flags));
+	/* Find the next call and dequeue it if we're not just peeking.  If we
+	 * do dequeue it, that comes with a ref that we will need to release.
+	 */
+	write_lock_bh(&rx->recvmsg_lock);
+	l = rx->recvmsg_q.next;
+	call = list_entry(l, struct rxrpc_call, recvmsg_link);
+	if (!(flags & MSG_PEEK))
+		list_del_init(&call->recvmsg_link);
+	else
+		rxrpc_get_call(call, rxrpc_call_got);
+	write_unlock_bh(&rx->recvmsg_lock);
 
-	switch (skb->mark) {
-	case RXRPC_SKB_MARK_DATA:
+	_debug("recvmsg call %p", call);
+
+	if (test_bit(RXRPC_CALL_RELEASED, &call->flags))
 		BUG();
-	case RXRPC_SKB_MARK_FINAL_ACK:
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ACK, 0, &abort_code);
-		break;
-	case RXRPC_SKB_MARK_BUSY:
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_BUSY, 0, &abort_code);
-		break;
-	case RXRPC_SKB_MARK_REMOTE_ABORT:
-		abort_code = call->abort_code;
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &abort_code);
-		break;
-	case RXRPC_SKB_MARK_LOCAL_ABORT:
-		abort_code = call->abort_code;
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &abort_code);
-		if (call->error) {
-			abort_code = call->error;
-			ret = put_cmsg(msg, SOL_RXRPC, RXRPC_LOCAL_ERROR, 4,
-				       &abort_code);
+
+	if (test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
+		if (flags & MSG_CMSG_COMPAT) {
+			unsigned int id32 = call->user_call_ID;
+
+			ret = put_cmsg(msg, SOL_RXRPC, RXRPC_USER_CALL_ID,
+				       sizeof(unsigned int), &id32);
+		} else {
+			ret = put_cmsg(msg, SOL_RXRPC, RXRPC_USER_CALL_ID,
+				       sizeof(unsigned long),
+				       &call->user_call_ID);
 		}
+		if (ret < 0)
+			goto error;
+	}
+
+	if (msg->msg_name) {
+		size_t len = sizeof(call->conn->params.peer->srx);
+		memcpy(msg->msg_name, &call->conn->params.peer->srx, len);
+		msg->msg_namelen = len;
+	}
+
+	switch (call->state) {
+	case RXRPC_CALL_SERVER_ACCEPTING:
+		ret = rxrpc_recvmsg_new_call(rx, call, msg, flags);
 		break;
-	case RXRPC_SKB_MARK_NET_ERROR:
-		_debug("RECV NET ERROR %d", sp->error);
-		abort_code = sp->error;
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NET_ERROR, 4, &abort_code);
-		break;
-	case RXRPC_SKB_MARK_LOCAL_ERROR:
-		_debug("RECV LOCAL ERROR %d", sp->error);
-		abort_code = sp->error;
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_LOCAL_ERROR, 4,
-			       &abort_code);
+	case RXRPC_CALL_CLIENT_RECV_REPLY:
+	case RXRPC_CALL_SERVER_RECV_REQUEST:
+	case RXRPC_CALL_SERVER_ACK_REQUEST:
+		ret = rxrpc_recvmsg_data(sock, call, msg, &msg->msg_iter, len,
+					 flags, &copied);
+		if (ret == -EAGAIN)
+			ret = 0;
 		break;
 	default:
-		pr_err("Unknown packet mark %u\n", skb->mark);
-		BUG();
+		ret = 0;
 		break;
 	}
 
 	if (ret < 0)
-		goto copy_error;
-
-terminal_message:
-	_debug("terminal");
-	msg->msg_flags &= ~MSG_MORE;
-	msg->msg_flags |= MSG_EOR;
+		goto error;
 
-	if (!(flags & MSG_PEEK)) {
-		_net("free terminal skb %p", skb);
-		if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
-			BUG();
-		rxrpc_free_skb(skb);
-		rxrpc_release_call(rx, call);
+	if (call->state == RXRPC_CALL_COMPLETE) {
+		ret = rxrpc_recvmsg_term(call, msg);
+		if (ret < 0)
+			goto error;
+		if (!(flags & MSG_PEEK))
+			rxrpc_release_call(rx, call);
+		msg->msg_flags |= MSG_EOR;
+		ret = 1;
 	}
 
-	release_sock(&rx->sk);
-	rxrpc_put_call(call, rxrpc_call_put);
-	if (continue_call)
-		rxrpc_put_call(continue_call, rxrpc_call_put);
-	_leave(" = %d", ret);
-	return ret;
+	if (ret == 0)
+		msg->msg_flags |= MSG_MORE;
+	else
+		msg->msg_flags &= ~MSG_MORE;
+	ret = copied;
 
-copy_error:
-	_debug("copy error");
-	release_sock(&rx->sk);
+error:
 	rxrpc_put_call(call, rxrpc_call_put);
-	if (continue_call)
-		rxrpc_put_call(continue_call, rxrpc_call_put);
+error_no_call:
+	release_sock(&rx->sk);
 	_leave(" = %d", ret);
 	return ret;
 
@@ -339,85 +499,8 @@ wait_interrupted:
 	ret = sock_intr_errno(timeo);
 wait_error:
 	finish_wait(sk_sleep(&rx->sk), &wait);
-	if (continue_call)
-		rxrpc_put_call(continue_call, rxrpc_call_put);
-	if (copied)
-		copied = ret;
-	_leave(" = %d [waitfail %d]", copied, ret);
-	return copied;
-
-}
-
-/*
- * Deliver messages to a call.  This keeps processing packets until the buffer
- * is filled and we find either more DATA (returns 0) or the end of the DATA
- * (returns 1).  If more packets are required, it returns -EAGAIN.
- *
- * TODO: Note that this is hacked in at the moment and will be replaced.
- */
-static int temp_deliver_data(struct socket *sock, struct rxrpc_call *call,
-			     struct iov_iter *iter, size_t size,
-			     size_t *_offset)
-{
-	struct rxrpc_skb_priv *sp;
-	struct sk_buff *skb;
-	size_t remain;
-	int ret, copy;
-
-	_enter("%d", call->debug_id);
-
-next:
-	local_bh_disable();
-	skb = skb_dequeue(&call->knlrecv_queue);
-	local_bh_enable();
-	if (!skb) {
-		if (test_bit(RXRPC_CALL_RX_NO_MORE, &call->flags))
-			return 1;
-		_leave(" = -EAGAIN [empty]");
-		return -EAGAIN;
-	}
-
-	sp = rxrpc_skb(skb);
-	_debug("dequeued %p %u/%zu", skb, sp->offset, size);
-
-	switch (skb->mark) {
-	case RXRPC_SKB_MARK_DATA:
-		remain = size - *_offset;
-		if (remain > 0) {
-			copy = skb->len - sp->offset;
-			if (copy > remain)
-				copy = remain;
-			ret = skb_copy_datagram_iter(skb, sp->offset, iter,
-						     copy);
-			if (ret < 0)
-				goto requeue_and_leave;
-
-			/* handle piecemeal consumption of data packets */
-			sp->offset += copy;
-			*_offset += copy;
-		}
-
-		if (sp->offset < skb->len)
-			goto partially_used_skb;
-
-		/* We consumed the whole packet */
-		ASSERTCMP(sp->offset, ==, skb->len);
-		if (sp->hdr.flags & RXRPC_LAST_PACKET)
-			set_bit(RXRPC_CALL_RX_NO_MORE, &call->flags);
-		rxrpc_kernel_data_consumed(call, skb);
-		rxrpc_free_skb(skb);
-		goto next;
-
-	default:
-		rxrpc_free_skb(skb);
-		goto next;
-	}
-
-partially_used_skb:
-	ASSERTCMP(*_offset, ==, size);
-	ret = 0;
-requeue_and_leave:
-	skb_queue_head(&call->knlrecv_queue, skb);
+	release_sock(&rx->sk);
+	_leave(" = %d [wait]", ret);
 	return ret;
 }
 
@@ -453,8 +536,9 @@ int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
 	struct kvec iov;
 	int ret;
 
-	_enter("{%d,%s},%zu,%d",
-	       call->debug_id, rxrpc_call_states[call->state], size, want_more);
+	_enter("{%d,%s},%zu/%zu,%d",
+	       call->debug_id, rxrpc_call_states[call->state],
+	       *_offset, size, want_more);
 
 	ASSERTCMP(*_offset, <=, size);
 	ASSERTCMP(call->state, !=, RXRPC_CALL_SERVER_ACCEPTING);
@@ -469,7 +553,8 @@ int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
 	case RXRPC_CALL_CLIENT_RECV_REPLY:
 	case RXRPC_CALL_SERVER_RECV_REQUEST:
 	case RXRPC_CALL_SERVER_ACK_REQUEST:
-		ret = temp_deliver_data(sock, call, &iter, size, _offset);
+		ret = rxrpc_recvmsg_data(sock, call, NULL, &iter, size, 0,
+					 _offset);
 		if (ret < 0)
 			goto out;
 
@@ -494,7 +579,6 @@ int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
 		goto call_complete;
 
 	default:
-		*_offset = 0;
 		ret = -EINPROGRESS;
 		goto out;
 	}
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 3777432df10b..ae392558829d 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -317,6 +317,7 @@ static int rxkad_secure_packet(struct rxrpc_call *call,
  * decrypt partial encryption on a packet (level 1 security)
  */
 static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
+				 unsigned int offset, unsigned int len,
 				 rxrpc_seq_t seq)
 {
 	struct rxkad_level1_hdr sechdr;
@@ -330,18 +331,20 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 
 	_enter("");
 
-	if (skb->len < 8) {
+	if (len < 8) {
 		rxrpc_abort_call("V1H", call, seq, RXKADSEALEDINCON, EPROTO);
 		goto protocol_error;
 	}
 
-	/* we want to decrypt the skbuff in-place */
+	/* Decrypt the skbuff in-place.  TODO: We really want to decrypt
+	 * directly into the target buffer.
+	 */
 	nsg = skb_cow_data(skb, 0, &trailer);
 	if (nsg < 0 || nsg > 16)
 		goto nomem;
 
 	sg_init_table(sg, nsg);
-	skb_to_sgvec(skb, sg, 0, 8);
+	skb_to_sgvec(skb, sg, offset, 8);
 
 	/* start the decryption afresh */
 	memset(&iv, 0, sizeof(iv));
@@ -353,12 +356,12 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 	skcipher_request_zero(req);
 
 	/* Extract the decrypted packet length */
-	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0) {
+	if (skb_copy_bits(skb, offset, &sechdr, sizeof(sechdr)) < 0) {
 		rxrpc_abort_call("XV1", call, seq, RXKADDATALEN, EPROTO);
 		goto protocol_error;
 	}
-	if (!skb_pull(skb, sizeof(sechdr)))
-		BUG();
+	offset += sizeof(sechdr);
+	len -= sizeof(sechdr);
 
 	buf = ntohl(sechdr.data_size);
 	data_size = buf & 0xffff;
@@ -371,18 +374,16 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 		goto protocol_error;
 	}
 
-	/* shorten the packet to remove the padding */
-	if (data_size > skb->len) {
+	if (data_size > len) {
 		rxrpc_abort_call("V1L", call, seq, RXKADDATALEN, EPROTO);
 		goto protocol_error;
 	}
-	if (data_size < skb->len)
-		skb->len = data_size;
 
 	_leave(" = 0 [dlen=%x]", data_size);
 	return 0;
 
 protocol_error:
+	rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
 	_leave(" = -EPROTO");
 	return -EPROTO;
 
@@ -395,6 +396,7 @@ nomem:
  * wholly decrypt a packet (level 2 security)
  */
 static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
+				 unsigned int offset, unsigned int len,
 				 rxrpc_seq_t seq)
 {
 	const struct rxrpc_key_token *token;
@@ -409,12 +411,14 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 
 	_enter(",{%d}", skb->len);
 
-	if (skb->len < 8) {
+	if (len < 8) {
 		rxrpc_abort_call("V2H", call, seq, RXKADSEALEDINCON, EPROTO);
 		goto protocol_error;
 	}
 
-	/* we want to decrypt the skbuff in-place */
+	/* Decrypt the skbuff in-place.  TODO: We really want to decrypt
+	 * directly into the target buffer.
+	 */
 	nsg = skb_cow_data(skb, 0, &trailer);
 	if (nsg < 0)
 		goto nomem;
@@ -427,7 +431,7 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	}
 
 	sg_init_table(sg, nsg);
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	skb_to_sgvec(skb, sg, offset, len);
 
 	/* decrypt from the session key */
 	token = call->conn->params.key->payload.data[0];
@@ -435,19 +439,19 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, sg, sg, skb->len, iv.x);
+	skcipher_request_set_crypt(req, sg, sg, len, iv.x);
 	crypto_skcipher_decrypt(req);
 	skcipher_request_zero(req);
 	if (sg != _sg)
 		kfree(sg);
 
 	/* Extract the decrypted packet length */
-	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0) {
+	if (skb_copy_bits(skb, offset, &sechdr, sizeof(sechdr)) < 0) {
 		rxrpc_abort_call("XV2", call, seq, RXKADDATALEN, EPROTO);
 		goto protocol_error;
 	}
-	if (!skb_pull(skb, sizeof(sechdr)))
-		BUG();
+	offset += sizeof(sechdr);
+	len -= sizeof(sechdr);
 
 	buf = ntohl(sechdr.data_size);
 	data_size = buf & 0xffff;
@@ -460,17 +464,16 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 		goto protocol_error;
 	}
 
-	if (data_size > skb->len) {
+	if (data_size > len) {
 		rxrpc_abort_call("V2L", call, seq, RXKADDATALEN, EPROTO);
 		goto protocol_error;
 	}
-	if (data_size < skb->len)
-		skb->len = data_size;
 
 	_leave(" = 0 [dlen=%x]", data_size);
 	return 0;
 
 protocol_error:
+	rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
 	_leave(" = -EPROTO");
 	return -EPROTO;
 
@@ -484,6 +487,7 @@ nomem:
  * jumbo packet).
  */
 static int rxkad_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
+			       unsigned int offset, unsigned int len,
 			       rxrpc_seq_t seq, u16 expected_cksum)
 {
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
@@ -521,6 +525,7 @@ static int rxkad_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
 
 	if (cksum != expected_cksum) {
 		rxrpc_abort_call("VCK", call, seq, RXKADSEALEDINCON, EPROTO);
+		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
 		_leave(" = -EPROTO [csum failed]");
 		return -EPROTO;
 	}
@@ -529,15 +534,61 @@ static int rxkad_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	case RXRPC_SECURITY_PLAIN:
 		return 0;
 	case RXRPC_SECURITY_AUTH:
-		return rxkad_verify_packet_1(call, skb, seq);
+		return rxkad_verify_packet_1(call, skb, offset, len, seq);
 	case RXRPC_SECURITY_ENCRYPT:
-		return rxkad_verify_packet_2(call, skb, seq);
+		return rxkad_verify_packet_2(call, skb, offset, len, seq);
 	default:
 		return -ENOANO;
 	}
 }
 
 /*
+ * Locate the data contained in a packet that was partially encrypted.
+ */
+static void rxkad_locate_data_1(struct rxrpc_call *call, struct sk_buff *skb,
+				unsigned int *_offset, unsigned int *_len)
+{
+	struct rxkad_level1_hdr sechdr;
+
+	if (skb_copy_bits(skb, *_offset, &sechdr, sizeof(sechdr)) < 0)
+		BUG();
+	*_offset += sizeof(sechdr);
+	*_len = ntohl(sechdr.data_size) & 0xffff;
+}
+
+/*
+ * Locate the data contained in a packet that was completely encrypted.
+ */
+static void rxkad_locate_data_2(struct rxrpc_call *call, struct sk_buff *skb,
+				unsigned int *_offset, unsigned int *_len)
+{
+	struct rxkad_level2_hdr sechdr;
+
+	if (skb_copy_bits(skb, *_offset, &sechdr, sizeof(sechdr)) < 0)
+		BUG();
+	*_offset += sizeof(sechdr);
+	*_len = ntohl(sechdr.data_size) & 0xffff;
+}
+
+/*
+ * Locate the data contained in an already decrypted packet.
+ */
+static void rxkad_locate_data(struct rxrpc_call *call, struct sk_buff *skb,
+			      unsigned int *_offset, unsigned int *_len)
+{
+	switch (call->conn->params.security_level) {
+	case RXRPC_SECURITY_AUTH:
+		rxkad_locate_data_1(call, skb, _offset, _len);
+		return;
+	case RXRPC_SECURITY_ENCRYPT:
+		rxkad_locate_data_2(call, skb, _offset, _len);
+		return;
+	default:
+		return;
+	}
+}
+
+/*
  * issue a challenge
  */
 static int rxkad_issue_challenge(struct rxrpc_connection *conn)
@@ -704,7 +755,7 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	struct rxkad_challenge challenge;
 	struct rxkad_response resp
 		__attribute__((aligned(8))); /* must be aligned for crypto */
-	struct rxrpc_skb_priv *sp;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	u32 version, nonce, min_level, abort_code;
 	int ret;
 
@@ -722,8 +773,7 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	}
 
 	abort_code = RXKADPACKETSHORT;
-	sp = rxrpc_skb(skb);
-	if (skb_copy_bits(skb, 0, &challenge, sizeof(challenge)) < 0)
+	if (skb_copy_bits(skb, sp->offset, &challenge, sizeof(challenge)) < 0)
 		goto protocol_error;
 
 	version = ntohl(challenge.version);
@@ -969,7 +1019,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 {
 	struct rxkad_response response
 		__attribute__((aligned(8))); /* must be aligned for crypto */
-	struct rxrpc_skb_priv *sp;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_crypt session_key;
 	time_t expiry;
 	void *ticket;
@@ -980,7 +1030,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	_enter("{%d,%x}", conn->debug_id, key_serial(conn->server_key));
 
 	abort_code = RXKADPACKETSHORT;
-	if (skb_copy_bits(skb, 0, &response, sizeof(response)) < 0)
+	if (skb_copy_bits(skb, sp->offset, &response, sizeof(response)) < 0)
 		goto protocol_error;
 	if (!pskb_pull(skb, sizeof(response)))
 		BUG();
@@ -988,7 +1038,6 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	version = ntohl(response.version);
 	ticket_len = ntohl(response.ticket_len);
 	kvno = ntohl(response.kvno);
-	sp = rxrpc_skb(skb);
 	_proto("Rx RESPONSE %%%u { v=%u kv=%u tl=%u }",
 	       sp->hdr.serial, version, kvno, ticket_len);
 
@@ -1010,7 +1059,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 		return -ENOMEM;
 
 	abort_code = RXKADPACKETSHORT;
-	if (skb_copy_bits(skb, 0, ticket, ticket_len) < 0)
+	if (skb_copy_bits(skb, sp->offset, ticket, ticket_len) < 0)
 		goto protocol_error_free;
 
 	ret = rxkad_decrypt_ticket(conn, ticket, ticket_len, &session_key,
@@ -1135,6 +1184,7 @@ const struct rxrpc_security rxkad = {
 	.prime_packet_security		= rxkad_prime_packet_security,
 	.secure_packet			= rxkad_secure_packet,
 	.verify_packet			= rxkad_verify_packet,
+	.locate_data			= rxkad_locate_data,
 	.issue_challenge		= rxkad_issue_challenge,
 	.respond_to_challenge		= rxkad_respond_to_challenge,
 	.verify_response		= rxkad_verify_response,
diff --git a/net/rxrpc/security.c b/net/rxrpc/security.c
index 5d79d5a9c944..82d8134e9287 100644
--- a/net/rxrpc/security.c
+++ b/net/rxrpc/security.c
@@ -130,20 +130,20 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 	}
 
 	/* find the service */
-	read_lock_bh(&local->services_lock);
+	read_lock(&local->services_lock);
 	hlist_for_each_entry(rx, &local->services, listen_link) {
 		if (rx->srx.srx_service == conn->params.service_id)
 			goto found_service;
 	}
 
 	/* the service appears to have died */
-	read_unlock_bh(&local->services_lock);
+	read_unlock(&local->services_lock);
 	_leave(" = -ENOENT");
 	return -ENOENT;
 
 found_service:
 	if (!rx->securities) {
-		read_unlock_bh(&local->services_lock);
+		read_unlock(&local->services_lock);
 		_leave(" = -ENOKEY");
 		return -ENOKEY;
 	}
@@ -152,13 +152,13 @@ found_service:
 	kref = keyring_search(make_key_ref(rx->securities, 1UL),
 			      &key_type_rxrpc_s, kdesc);
 	if (IS_ERR(kref)) {
-		read_unlock_bh(&local->services_lock);
+		read_unlock(&local->services_lock);
 		_leave(" = %ld [search]", PTR_ERR(kref));
 		return PTR_ERR(kref);
 	}
 
 	key = key_ref_to_ptr(kref);
-	read_unlock_bh(&local->services_lock);
+	read_unlock(&local->services_lock);
 
 	conn->server_key = key;
 	conn->security = sec;
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 9a4af992fcdf..cba236575073 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -15,7 +15,6 @@
 #include <linux/gfp.h>
 #include <linux/skbuff.h>
 #include <linux/export.h>
-#include <linux/circ_buf.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
@@ -38,19 +37,20 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 	DECLARE_WAITQUEUE(myself, current);
 	int ret;
 
-	_enter(",{%d},%ld",
-	       CIRC_SPACE(call->acks_head, ACCESS_ONCE(call->acks_tail),
-			  call->acks_winsz),
-	       *timeo);
+	_enter(",{%u,%u,%u}",
+	       call->tx_hard_ack, call->tx_top, call->tx_winsize);
 
 	add_wait_queue(&call->waitq, &myself);
 
 	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		ret = 0;
-		if (CIRC_SPACE(call->acks_head, ACCESS_ONCE(call->acks_tail),
-			       call->acks_winsz) > 0)
+		if (call->tx_top - call->tx_hard_ack < call->tx_winsize)
 			break;
+		if (call->state >= RXRPC_CALL_COMPLETE) {
+			ret = -call->error;
+			break;
+		}
 		if (signal_pending(current)) {
 			ret = sock_intr_errno(*timeo);
 			break;
@@ -68,36 +68,44 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 }
 
 /*
- * attempt to schedule an instant Tx resend
+ * Schedule an instant Tx resend.
  */
-static inline void rxrpc_instant_resend(struct rxrpc_call *call)
+static inline void rxrpc_instant_resend(struct rxrpc_call *call, int ix)
 {
-	read_lock_bh(&call->state_lock);
-	if (try_to_del_timer_sync(&call->resend_timer) >= 0) {
-		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-		if (call->state < RXRPC_CALL_COMPLETE &&
-		    !test_and_set_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events))
+	spin_lock_bh(&call->lock);
+
+	if (call->state < RXRPC_CALL_COMPLETE) {
+		call->rxtx_annotations[ix] = RXRPC_TX_ANNO_RETRANS;
+		if (!test_and_set_bit(RXRPC_CALL_EV_RESEND, &call->events))
 			rxrpc_queue_call(call);
 	}
-	read_unlock_bh(&call->state_lock);
+
+	spin_unlock_bh(&call->lock);
 }
 
 /*
- * queue a packet for transmission, set the resend timer and attempt
- * to send the packet immediately
+ * Queue a DATA packet for transmission, set the resend timeout and send the
+ * packet immediately
  */
 static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 			       bool last)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	int ret;
+	rxrpc_seq_t seq = sp->hdr.seq;
+	int ret, ix;
+
+	_net("queue skb %p [%d]", skb, seq);
 
-	_net("queue skb %p [%d]", skb, call->acks_head);
+	ASSERTCMP(seq, ==, call->tx_top + 1);
 
-	ASSERT(call->acks_window != NULL);
-	call->acks_window[call->acks_head] = (unsigned long) skb;
+	ix = seq & RXRPC_RXTX_BUFF_MASK;
+	rxrpc_get_skb(skb);
+	call->rxtx_annotations[ix] = RXRPC_TX_ANNO_UNACK;
 	smp_wmb();
-	call->acks_head = (call->acks_head + 1) & (call->acks_winsz - 1);
+	call->rxtx_buffer[ix] = skb;
+	call->tx_top = seq;
+	if (last)
+		set_bit(RXRPC_CALL_TX_LAST, &call->flags);
 
 	if (last || call->state == RXRPC_CALL_SERVER_ACK_REQUEST) {
 		_debug("________awaiting reply/ACK__________");
@@ -121,34 +129,17 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 
 	_proto("Tx DATA %%%u { #%u }", sp->hdr.serial, sp->hdr.seq);
 
-	sp->need_resend = false;
-	sp->resend_at = jiffies + rxrpc_resend_timeout;
-	if (!test_and_set_bit(RXRPC_CALL_RUN_RTIMER, &call->flags)) {
-		_debug("run timer");
-		call->resend_timer.expires = sp->resend_at;
-		add_timer(&call->resend_timer);
-	}
-
-	/* attempt to cancel the rx-ACK timer, deferring reply transmission if
-	 * we're ACK'ing the request phase of an incoming call */
-	ret = -EAGAIN;
-	if (try_to_del_timer_sync(&call->ack_timer) >= 0) {
-		/* the packet may be freed by rxrpc_process_call() before this
-		 * returns */
-		if (rxrpc_is_client_call(call))
-			rxrpc_expose_client_call(call);
-		ret = rxrpc_send_data_packet(call->conn, skb);
-		_net("sent skb %p", skb);
-	} else {
-		_debug("failed to delete ACK timer");
-	}
+	if (seq == 1 && rxrpc_is_client_call(call))
+		rxrpc_expose_client_call(call);
 
+	sp->resend_at = jiffies + rxrpc_resend_timeout;
+	ret = rxrpc_send_data_packet(call->conn, skb);
 	if (ret < 0) {
 		_debug("need instant resend %d", ret);
-		sp->need_resend = true;
-		rxrpc_instant_resend(call);
+		rxrpc_instant_resend(call, ix);
 	}
 
+	rxrpc_free_skb(skb);
 	_leave("");
 }
 
@@ -212,9 +203,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 			_debug("alloc");
 
-			if (CIRC_SPACE(call->acks_head,
-				       ACCESS_ONCE(call->acks_tail),
-				       call->acks_winsz) <= 0) {
+			if (call->tx_top - call->tx_hard_ack >=
+			    call->tx_winsize) {
 				ret = -EAGAIN;
 				if (msg->msg_flags & MSG_DONTWAIT)
 					goto maybe_error;
@@ -313,7 +303,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 					memset(skb_put(skb, pad), 0, pad);
 			}
 
-			seq = atomic_inc_return(&call->sequence);
+			seq = call->tx_top + 1;
 
 			sp->hdr.epoch	= conn->proto.epoch;
 			sp->hdr.cid	= call->cid;
@@ -329,9 +319,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			sp->hdr.flags = conn->out_clientflag;
 			if (msg_data_left(msg) == 0 && !more)
 				sp->hdr.flags |= RXRPC_LAST_PACKET;
-			else if (CIRC_SPACE(call->acks_head,
-					    ACCESS_ONCE(call->acks_tail),
-					    call->acks_winsz) > 1)
+			else if (call->tx_top - call->tx_hard_ack <
+				 call->tx_winsize)
 				sp->hdr.flags |= RXRPC_MORE_PACKETS;
 			if (more && seq & 1)
 				sp->hdr.flags |= RXRPC_REQUEST_ACK;
@@ -358,7 +347,7 @@ out:
 call_terminated:
 	rxrpc_free_skb(skb);
 	_leave(" = %d", -call->error);
-	return ret;
+	return -call->error;
 
 maybe_error:
 	if (copied)
@@ -452,29 +441,6 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 }
 
 /*
- * abort a call, sending an ABORT packet to the peer
- */
-static void rxrpc_send_abort(struct rxrpc_call *call, const char *why,
-			     u32 abort_code, int error)
-{
-	if (call->state >= RXRPC_CALL_COMPLETE)
-		return;
-
-	write_lock_bh(&call->state_lock);
-
-	if (__rxrpc_abort_call(why, call, 0, abort_code, error)) {
-		del_timer_sync(&call->resend_timer);
-		del_timer_sync(&call->ack_timer);
-		clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events);
-		clear_bit(RXRPC_CALL_EV_ACK, &call->events);
-		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-		rxrpc_queue_call(call);
-	}
-
-	write_unlock_bh(&call->state_lock);
-}
-
-/*
  * Create a new client call for sendmsg().
  */
 static struct rxrpc_call *
@@ -549,7 +515,6 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 			return PTR_ERR(call);
 	}
 
-	rxrpc_see_call(call);
 	_debug("CALL %d USR %lx ST %d on CONN %p",
 	       call->debug_id, call->user_call_ID, call->state, call->conn);
 
@@ -557,8 +522,10 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		/* it's too late for this call */
 		ret = -ESHUTDOWN;
 	} else if (cmd == RXRPC_CMD_SEND_ABORT) {
-		rxrpc_send_abort(call, "CMD", abort_code, ECONNABORTED);
 		ret = 0;
+		if (rxrpc_abort_call("CMD", call, 0, abort_code, ECONNABORTED))
+			ret = rxrpc_send_call_packet(call,
+						     RXRPC_PACKET_TYPE_ABORT);
 	} else if (cmd != RXRPC_CMD_SEND_DATA) {
 		ret = -EINVAL;
 	} else if (rxrpc_is_client_call(call) &&
@@ -639,7 +606,8 @@ void rxrpc_kernel_abort_call(struct socket *sock, struct rxrpc_call *call,
 
 	lock_sock(sock->sk);
 
-	rxrpc_send_abort(call, why, abort_code, error);
+	if (rxrpc_abort_call(why, call, 0, abort_code, error))
+		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
 
 	release_sock(sock->sk);
 	_leave("");
diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index 9b8f8456d3bf..620d9ccaf3c1 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -19,133 +19,6 @@
 #include "ar-internal.h"
 
 /*
- * set up for the ACK at the end of the receive phase when we discard the final
- * receive phase data packet
- * - called with softirqs disabled
- */
-static void rxrpc_request_final_ACK(struct rxrpc_call *call)
-{
-	/* the call may be aborted before we have a chance to ACK it */
-	write_lock(&call->state_lock);
-
-	switch (call->state) {
-	case RXRPC_CALL_CLIENT_RECV_REPLY:
-		call->state = RXRPC_CALL_CLIENT_FINAL_ACK;
-		_debug("request final ACK");
-
-		set_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
-		if (try_to_del_timer_sync(&call->ack_timer) >= 0)
-			rxrpc_queue_call(call);
-		break;
-
-	case RXRPC_CALL_SERVER_RECV_REQUEST:
-		call->state = RXRPC_CALL_SERVER_ACK_REQUEST;
-	default:
-		break;
-	}
-
-	write_unlock(&call->state_lock);
-}
-
-/*
- * drop the bottom ACK off of the call ACK window and advance the window
- */
-static void rxrpc_hard_ACK_data(struct rxrpc_call *call, struct sk_buff *skb)
-{
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	int loop;
-	u32 seq;
-
-	spin_lock_bh(&call->lock);
-
-	_debug("hard ACK #%u", sp->hdr.seq);
-
-	for (loop = 0; loop < RXRPC_ACKR_WINDOW_ASZ; loop++) {
-		call->ackr_window[loop] >>= 1;
-		call->ackr_window[loop] |=
-			call->ackr_window[loop + 1] << (BITS_PER_LONG - 1);
-	}
-
-	seq = sp->hdr.seq;
-	ASSERTCMP(seq, ==, call->rx_data_eaten + 1);
-	call->rx_data_eaten = seq;
-
-	if (call->ackr_win_top < UINT_MAX)
-		call->ackr_win_top++;
-
-	ASSERTIFCMP(call->state <= RXRPC_CALL_COMPLETE,
-		    call->rx_data_post, >=, call->rx_data_recv);
-	ASSERTIFCMP(call->state <= RXRPC_CALL_COMPLETE,
-		    call->rx_data_recv, >=, call->rx_data_eaten);
-
-	if (sp->hdr.flags & RXRPC_LAST_PACKET) {
-		rxrpc_request_final_ACK(call);
-	} else if (atomic_dec_and_test(&call->ackr_not_idle) &&
-		   test_and_clear_bit(RXRPC_CALL_TX_SOFT_ACK, &call->flags)) {
-		/* We previously soft-ACK'd some received packets that have now
-		 * been consumed, so send a hard-ACK if no more packets are
-		 * immediately forthcoming to allow the transmitter to free up
-		 * its Tx bufferage.
-		 */
-		_debug("send Rx idle ACK");
-		__rxrpc_propose_ACK(call, RXRPC_ACK_IDLE,
-				    skb->priority, sp->hdr.serial, false);
-	}
-
-	spin_unlock_bh(&call->lock);
-}
-
-/**
- * rxrpc_kernel_data_consumed - Record consumption of data message
- * @call: The call to which the message pertains.
- * @skb: Message holding data
- *
- * Record the consumption of a data message and generate an ACK if appropriate.
- * The call state is shifted if this was the final packet.  The caller must be
- * in process context with no spinlocks held.
- *
- * TODO: Actually generate the ACK here rather than punting this to the
- * workqueue.
- */
-void rxrpc_kernel_data_consumed(struct rxrpc_call *call, struct sk_buff *skb)
-{
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-
-	_enter("%d,%p{%u}", call->debug_id, skb, sp->hdr.seq);
-
-	ASSERTCMP(sp->call, ==, call);
-	ASSERTCMP(sp->hdr.type, ==, RXRPC_PACKET_TYPE_DATA);
-
-	/* TODO: Fix the sequence number tracking */
-	ASSERTCMP(sp->hdr.seq, >=, call->rx_data_recv);
-	ASSERTCMP(sp->hdr.seq, <=, call->rx_data_recv + 1);
-	ASSERTCMP(sp->hdr.seq, >, call->rx_data_eaten);
-
-	call->rx_data_recv = sp->hdr.seq;
-	rxrpc_hard_ACK_data(call, skb);
-}
-
-/*
- * Destroy a packet that has an RxRPC control buffer
- */
-void rxrpc_packet_destructor(struct sk_buff *skb)
-{
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	struct rxrpc_call *call = sp->call;
-
-	_enter("%p{%p}", skb, call);
-
-	if (call) {
-		rxrpc_put_call_for_skb(call, skb);
-		sp->call = NULL;
-	}
-
-	if (skb->sk)
-		sock_rfree(skb);
-	_leave("");
-}
-
-/*
  * Note the existence of a new-to-us socket buffer (allocated or dequeued).
  */
 void rxrpc_new_skb(struct sk_buff *skb)
