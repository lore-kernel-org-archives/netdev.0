From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/2] rxrpc: Improve management and caching of
 client connection objects
Date: Wed, 24 Aug 2016 16:04:21 +0100
Message-ID: <147205106112.13653.15214661145563552331.stgit@warthog.procyon.org.uk>
References: <147205104744.13653.18154187942560167277.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147205104744.13653.18154187942560167277.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Improve the management and caching of client rxrpc connection objects.
>From this point, client connections will be managed separately from service
connections because AF_RXRPC controls the creation and re-use of client
connections but doesn't have that luxury with service connections.

Further, there will be limits on the numbers of client connections that may
be live on a machine.  No direct restriction will be placed on the number
of client calls, excepting that each client connection can support a
maximum of four concurrent calls.

Note that, for a number of reasons, we don't want to simply discard a
client connection as soon as the last call is apparently finished:

 (1) Security is negotiated per-connection and the context is then shared
     between all calls on that connection.  The context can be negotiated
     again if the connection lapses, but that involves holding up calls
     whilst at least two packets are exchanged and various crypto bits are
     performed - so we'd ideally like to cache it for a little while at
     least.

 (2) If a packet goes astray, we will need to retransmit a final ACK or
     ABORT packet.  To make this work, we need to keep around the
     connection details for a little while.

 (3) The locally held structures represent some amount of setup time, to be
     weighed against their occupation of memory when idle.


To this end, the client connection cache is managed by a state machine on
each connection.  There are five states:

 (1) INACTIVE - The connection is not held in any list and may not have
     been exposed to the world.  If it has been previously exposed, it was
     discarded from the idle list after expiring.

 (2) WAITING - The connection is waiting for the number of client conns to
     drop below the maximum capacity.  Calls may be in progress upon it
     from when it was active and got culled.

     The connection is on the rxrpc_waiting_client_conns list which is kept
     in to-be-granted order.  Culled conns with waiters go to the back of
     the queue just like new conns.

 (3) ACTIVE - The connection has at least one call in progress upon it, it
     may freely grant available channels to new calls and calls may be
     waiting on it for channels to become available.

     The connection is on the rxrpc_active_client_conns list which is kept
     in activation order for culling purposes.

 (4) CULLED - The connection got summarily culled to try and free up
     capacity.  Calls currently in progress on the connection are allowed
     to continue, but new calls will have to wait.  There can be no waiters
     in this state - the conn would have to go to the WAITING state
     instead.

 (5) IDLE - The connection has no calls in progress upon it and must have
     been exposed to the world (ie. the EXPOSED flag must be set).  When it
     expires, the EXPOSED flag is cleared and the connection transitions to
     the INACTIVE state.

     The connection is on the rxrpc_idle_client_conns list which is kept in
     order of how soon they'll expire.

A connection in the ACTIVE or CULLED state must have at least one active
call upon it; if in the WAITING state it may have active calls upon it;
other states may not have active calls.

As long as a connection remains active and doesn't get culled, it may
continue to process calls - even if there are connections on the wait
queue.  This simplifies things a bit and reduces the amount of checking we
need do.


There are a couple flags of relevance to the cache:

 (1) EXPOSED - The connection ID got exposed to the world.  If this flag is
     set, an extra ref is added to the connection preventing it from being
     reaped when it has no calls outstanding.  This flag is cleared and the
     ref dropped when a conn is discarded from the idle list.

 (2) DONT_REUSE - The connection should be discarded as soon as possible and
     should not be reused.


This commit also provides a number of new settings:

 (*) /proc/net/rxrpc/max_client_conns

     The maximum number of live client connections.  Above this number, new
     connections get added to the wait list and must wait for an active
     conn to be culled.  Culled connections can be reused, but they will go
     to the back of the wait list and have to wait.

 (*) /proc/net/rxrpc/reap_client_conns

     If the number of desired connections exceeds the maximum above, the
     active connection list will be culled until there are only this many
     left in it.

 (*) /proc/net/rxrpc/idle_conn_expiry

     The normal expiry time for a client connection, provided there are
     fewer than reap_client_conns of them around.

 (*) /proc/net/rxrpc/idle_conn_fast_expiry

     The expedited expiry time, used when there are more than
     reap_client_conns of them around.


Note that I combined the Tx wait queue with the channel grant wait queue to
save space as only one of these should be in use at once.

Note also that, for the moment, the service connection cache still uses the
old connection management code.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h  |   56 ++-
 net/rxrpc/call_event.c   |    4 
 net/rxrpc/call_object.c  |    5 
 net/rxrpc/conn_client.c  |  910 ++++++++++++++++++++++++++++++++++++++++------
 net/rxrpc/conn_object.c  |   71 ++--
 net/rxrpc/conn_service.c |    5 
 net/rxrpc/output.c       |    6 
 net/rxrpc/sysctl.c       |   33 +-
 8 files changed, 933 insertions(+), 157 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 2efbfba87cbe..c761124961cc 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -255,6 +255,9 @@ enum rxrpc_conn_flag {
 	RXRPC_CONN_HAS_IDR,		/* Has a client conn ID assigned */
 	RXRPC_CONN_IN_SERVICE_CONNS,	/* Conn is in peer->service_conns */
 	RXRPC_CONN_IN_CLIENT_CONNS,	/* Conn is in local->client_conns */
+	RXRPC_CONN_EXPOSED,		/* Conn has extra ref for exposure */
+	RXRPC_CONN_DONT_REUSE,		/* Don't reuse this connection */
+	RXRPC_CONN_COUNTED,		/* Counted by rxrpc_nr_client_conns */
 };
 
 /*
@@ -265,6 +268,17 @@ enum rxrpc_conn_event {
 };
 
 /*
+ * The connection cache state.
+ */
+enum rxrpc_conn_cache_state {
+	RXRPC_CONN_CLIENT_INACTIVE,	/* Conn is not yet listed */
+	RXRPC_CONN_CLIENT_WAITING,	/* Conn is on wait list, waiting for capacity */
+	RXRPC_CONN_CLIENT_ACTIVE,	/* Conn is on active list, doing calls */
+	RXRPC_CONN_CLIENT_CULLED,	/* Conn is culled and delisted, doing calls */
+	RXRPC_CONN_CLIENT_IDLE,		/* Conn is on idle list, doing mostly nothing */
+};
+
+/*
  * The connection protocol state.
  */
 enum rxrpc_conn_proto_state {
@@ -276,6 +290,7 @@ enum rxrpc_conn_proto_state {
 	RXRPC_CONN_REMOTELY_ABORTED,	/* Conn aborted by peer */
 	RXRPC_CONN_LOCALLY_ABORTED,	/* Conn aborted locally */
 	RXRPC_CONN_NETWORK_ERROR,	/* Conn terminated by network error */
+	RXRPC_CONN_LOCAL_ERROR,		/* Conn terminated by local error */
 	RXRPC_CONN__NR_STATES
 };
 
@@ -288,8 +303,14 @@ struct rxrpc_connection {
 	struct rxrpc_conn_proto	proto;
 	struct rxrpc_conn_parameters params;
 
-	spinlock_t		channel_lock;
+	atomic_t		usage;
+	struct rcu_head		rcu;
+	struct list_head	cache_link;
 
+	spinlock_t		channel_lock;
+	unsigned char		active_chans;	/* Mask of active channels */
+#define RXRPC_ACTIVE_CHANS_MASK	((1 << RXRPC_MAXCALLS) - 1)
+	struct list_head	waiting_calls;	/* Calls waiting for channels */
 	struct rxrpc_channel {
 		struct rxrpc_call __rcu	*call;		/* Active call */
 		u32			call_id;	/* ID of current call */
@@ -302,9 +323,7 @@ struct rxrpc_connection {
 			u32		last_abort;
 		};
 	} channels[RXRPC_MAXCALLS];
-	wait_queue_head_t	channel_wq;	/* queue to wait for channel to become available */
 
-	struct rcu_head		rcu;
 	struct work_struct	processor;	/* connection event processor */
 	union {
 		struct rb_node	client_node;	/* Node in local->client_conns */
@@ -321,7 +340,7 @@ struct rxrpc_connection {
 	unsigned long		events;
 	unsigned long		idle_timestamp;	/* Time at which last became idle */
 	spinlock_t		state_lock;	/* state-change lock */
-	atomic_t		usage;
+	enum rxrpc_conn_cache_state cache_state : 8;
 	enum rxrpc_conn_proto_state state : 8;	/* current state of connection */
 	u32			local_abort;	/* local abort code */
 	u32			remote_abort;	/* remote abort code */
@@ -329,7 +348,6 @@ struct rxrpc_connection {
 	int			debug_id;	/* debug ID for printks */
 	atomic_t		serial;		/* packet serial number counter */
 	unsigned int		hi_serial;	/* highest serial number received */
-	atomic_t		avail_chans;	/* number of channels available */
 	u8			size_align;	/* data size alignment (for security) */
 	u8			header_size;	/* rxrpc + security header size */
 	u8			security_size;	/* security header size */
@@ -351,6 +369,7 @@ enum rxrpc_call_flag {
 	RXRPC_CALL_HAS_USERID,		/* has a user ID attached */
 	RXRPC_CALL_EXPECT_OOS,		/* expect out of sequence packets */
 	RXRPC_CALL_IS_SERVICE,		/* Call is service call */
+	RXRPC_CALL_EXPOSED,		/* The call was exposed to the world */
 };
 
 /*
@@ -417,13 +436,14 @@ struct rxrpc_call {
 	struct work_struct	destroyer;	/* call destroyer */
 	struct work_struct	processor;	/* packet processor and ACK generator */
 	struct list_head	link;		/* link in master call list */
+	struct list_head	chan_wait_link;	/* Link in conn->waiting_calls */
 	struct hlist_node	error_link;	/* link in error distribution list */
 	struct list_head	accept_link;	/* calls awaiting acceptance */
 	struct rb_node		sock_node;	/* node in socket call tree */
 	struct sk_buff_head	rx_queue;	/* received packets */
 	struct sk_buff_head	rx_oos_queue;	/* packets received out of sequence */
 	struct sk_buff		*tx_pending;	/* Tx socket buffer being filled */
-	wait_queue_head_t	tx_waitq;	/* wait for Tx window space to become available */
+	wait_queue_head_t	waitq;		/* Wait queue for channel or Tx */
 	__be32			crypto_buf[2];	/* Temporary packet crypto buffer */
 	unsigned long		user_call_ID;	/* user-defined call ID */
 	unsigned long		creation_jif;	/* time of call creation */
@@ -546,12 +566,19 @@ static inline bool rxrpc_is_client_call(const struct rxrpc_call *call)
 /*
  * conn_client.c
  */
+extern unsigned int rxrpc_max_client_connections;
+extern unsigned int rxrpc_reap_client_connections;
+extern unsigned int rxrpc_conn_idle_client_expiry;
+extern unsigned int rxrpc_conn_idle_client_fast_expiry;
 extern struct idr rxrpc_client_conn_ids;
 
 void rxrpc_destroy_client_conn_ids(void);
 int rxrpc_connect_call(struct rxrpc_call *, struct rxrpc_conn_parameters *,
 		       struct sockaddr_rxrpc *, gfp_t);
-void rxrpc_unpublish_client_conn(struct rxrpc_connection *);
+void rxrpc_expose_client_call(struct rxrpc_call *);
+void rxrpc_disconnect_client_call(struct rxrpc_call *);
+void rxrpc_put_client_conn(struct rxrpc_connection *);
+void __exit rxrpc_destroy_all_client_connections(void);
 
 /*
  * conn_event.c
@@ -572,8 +599,9 @@ int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *, struct sk_buff *);
 struct rxrpc_connection *rxrpc_alloc_connection(gfp_t);
 struct rxrpc_connection *rxrpc_find_connection_rcu(struct rxrpc_local *,
 						   struct sk_buff *);
-void __rxrpc_disconnect_call(struct rxrpc_call *);
+void __rxrpc_disconnect_call(struct rxrpc_connection *, struct rxrpc_call *);
 void rxrpc_disconnect_call(struct rxrpc_call *);
+void rxrpc_kill_connection(struct rxrpc_connection *);
 void __rxrpc_put_connection(struct rxrpc_connection *);
 void __exit rxrpc_destroy_all_connections(void);
 
@@ -600,8 +628,16 @@ struct rxrpc_connection *rxrpc_get_connection_maybe(struct rxrpc_connection *con
 
 static inline void rxrpc_put_connection(struct rxrpc_connection *conn)
 {
-	if (conn && atomic_dec_return(&conn->usage) == 1)
-		__rxrpc_put_connection(conn);
+	if (!conn)
+		return;
+
+	if (rxrpc_conn_is_client(conn)) {
+		if (atomic_dec_and_test(&conn->usage))
+			rxrpc_put_client_conn(conn);
+	} else {
+		if (atomic_dec_return(&conn->usage) == 1)
+			__rxrpc_put_connection(conn);
+	}
 }
 
 
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 3d1961d82325..5292bcfd8816 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -193,6 +193,8 @@ static void rxrpc_resend(struct rxrpc_call *call)
 				stop = true;
 				sp->resend_at = jiffies + 3;
 			} else {
+				if (rxrpc_is_client_call(call))
+					rxrpc_expose_client_call(call);
 				sp->resend_at =
 					jiffies + rxrpc_resend_timeout;
 			}
@@ -378,7 +380,7 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, u32 hard)
 		call->acks_hard++;
 	}
 
-	wake_up(&call->tx_waitq);
+	wake_up(&call->waitq);
 }
 
 /*
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index f23432591a0f..e7cbcc4a87cf 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -127,10 +127,11 @@ static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 	INIT_WORK(&call->destroyer, &rxrpc_destroy_call);
 	INIT_WORK(&call->processor, &rxrpc_process_call);
 	INIT_LIST_HEAD(&call->link);
+	INIT_LIST_HEAD(&call->chan_wait_link);
 	INIT_LIST_HEAD(&call->accept_link);
 	skb_queue_head_init(&call->rx_queue);
 	skb_queue_head_init(&call->rx_oos_queue);
-	init_waitqueue_head(&call->tx_waitq);
+	init_waitqueue_head(&call->waitq);
 	spin_lock_init(&call->lock);
 	rwlock_init(&call->state_lock);
 	atomic_set(&call->usage, 1);
@@ -358,7 +359,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 		       call->debug_id, rxrpc_call_states[call->state]);
 
 		if (call->state >= RXRPC_CALL_COMPLETE) {
-			__rxrpc_disconnect_call(call);
+			__rxrpc_disconnect_call(conn, call);
 		} else {
 			spin_unlock(&conn->channel_lock);
 			kmem_cache_free(rxrpc_call_jar, candidate);
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 6e1099ed1dbd..349402b08e5a 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -7,6 +7,68 @@
  * modify it under the terms of the GNU General Public Licence
  * as published by the Free Software Foundation; either version
  * 2 of the Licence, or (at your option) any later version.
+ *
+ *
+ * Client connections need to be cached for a little while after they've made a
+ * call so as to handle retransmitted DATA packets in case the server didn't
+ * receive the final ACK or terminating ABORT we sent it.
+ *
+ * Client connections can be in one of a number of cache states:
+ *
+ *  (1) INACTIVE - The connection is not held in any list and may not have been
+ *      exposed to the world.  If it has been previously exposed, it was
+ *      discarded from the idle list after expiring.
+ *
+ *  (2) WAITING - The connection is waiting for the number of client conns to
+ *      drop below the maximum capacity.  Calls may be in progress upon it from
+ *      when it was active and got culled.
+ *
+ *	The connection is on the rxrpc_waiting_client_conns list which is kept
+ *	in to-be-granted order.  Culled conns with waiters go to the back of
+ *	the queue just like new conns.
+ *
+ *  (3) ACTIVE - The connection has at least one call in progress upon it, it
+ *      may freely grant available channels to new calls and calls may be
+ *      waiting on it for channels to become available.
+ *
+ *	The connection is on the rxrpc_active_client_conns list which is kept
+ *	in activation order for culling purposes.
+ *
+ *	rxrpc_nr_active_client_conns is held incremented also.
+ *
+ *  (4) CULLED - The connection got summarily culled to try and free up
+ *      capacity.  Calls currently in progress on the connection are allowed to
+ *      continue, but new calls will have to wait.  There can be no waiters in
+ *      this state - the conn would have to go to the WAITING state instead.
+ *
+ *  (5) IDLE - The connection has no calls in progress upon it and must have
+ *      been exposed to the world (ie. the EXPOSED flag must be set).  When it
+ *      expires, the EXPOSED flag is cleared and the connection transitions to
+ *      the INACTIVE state.
+ *
+ *	The connection is on the rxrpc_idle_client_conns list which is kept in
+ *	order of how soon they'll expire.
+ *
+ * There are flags of relevance to the cache:
+ *
+ *  (1) EXPOSED - The connection ID got exposed to the world.  If this flag is
+ *      set, an extra ref is added to the connection preventing it from being
+ *      reaped when it has no calls outstanding.  This flag is cleared and the
+ *      ref dropped when a conn is discarded from the idle list.
+ *
+ *      This allows us to move terminal call state retransmission to the
+ *      connection and to discard the call immediately we think it is done
+ *      with.  It also give us a chance to reuse the connection.
+ *
+ *  (2) DONT_REUSE - The connection should be discarded as soon as possible and
+ *      should not be reused.  This is set when an exclusive connection is used
+ *      or a call ID counter overflows.
+ *
+ * The caching state may only be changed if the cache lock is held.
+ *
+ * There are two idle client connection expiry durations.  If the total number
+ * of connections is below the reap threshold, we use the normal duration; if
+ * it's above, we use the fast duration.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -16,22 +78,37 @@
 #include <linux/timer.h>
 #include "ar-internal.h"
 
+__read_mostly unsigned int rxrpc_max_client_connections = 1000;
+__read_mostly unsigned int rxrpc_reap_client_connections = 900;
+__read_mostly unsigned int rxrpc_conn_idle_client_expiry = 2 * 60 * HZ;
+__read_mostly unsigned int rxrpc_conn_idle_client_fast_expiry = 2 * HZ;
+
+static unsigned int rxrpc_nr_client_conns;
+static unsigned int rxrpc_nr_active_client_conns;
+static __read_mostly bool rxrpc_kill_all_client_conns;
+
+static DEFINE_SPINLOCK(rxrpc_client_conn_cache_lock);
+static DEFINE_SPINLOCK(rxrpc_client_conn_discard_mutex);
+static LIST_HEAD(rxrpc_waiting_client_conns);
+static LIST_HEAD(rxrpc_active_client_conns);
+static LIST_HEAD(rxrpc_idle_client_conns);
+
 /*
  * We use machine-unique IDs for our client connections.
  */
 DEFINE_IDR(rxrpc_client_conn_ids);
 static DEFINE_SPINLOCK(rxrpc_conn_id_lock);
 
+static void rxrpc_cull_active_client_conns(void);
+static void rxrpc_discard_expired_client_conns(struct work_struct *);
+
+static DECLARE_DELAYED_WORK(rxrpc_client_conn_reap,
+			    rxrpc_discard_expired_client_conns);
+
 /*
  * Get a connection ID and epoch for a client connection from the global pool.
  * The connection struct pointer is then recorded in the idr radix tree.  The
  * epoch is changed if this wraps.
- *
- * TODO: The IDR tree gets very expensive on memory if the connection IDs are
- * widely scattered throughout the number space, so we shall need to retire
- * connections that have, say, an ID more than four times the maximum number of
- * client conns away from the current allocation point to try and keep the IDs
- * concentrated.  We will also need to retire connections from an old epoch.
  */
 static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 					  gfp_t gfp)
@@ -114,8 +191,7 @@ void rxrpc_destroy_client_conn_ids(void)
 }
 
 /*
- * Allocate a client connection.  The caller must take care to clear any
- * padding bytes in *cp.
+ * Allocate a client connection.
  */
 static struct rxrpc_connection *
 rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
@@ -131,6 +207,10 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 		return ERR_PTR(-ENOMEM);
 	}
 
+	atomic_set(&conn->usage, 1);
+	if (conn->params.exclusive)
+		__set_bit(RXRPC_CONN_DONT_REUSE, &conn->flags);
+
 	conn->params		= *cp;
 	conn->out_clientflag	= RXRPC_CLIENT_INITIATED;
 	conn->state		= RXRPC_CONN_CLIENT;
@@ -148,7 +228,6 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 		goto error_2;
 
 	write_lock(&rxrpc_connection_lock);
-	list_add_tail(&conn->link, &rxrpc_connections);
 	list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
 	write_unlock(&rxrpc_connection_lock);
 
@@ -171,32 +250,68 @@ error_0:
 }
 
 /*
- * find a connection for a call
- * - called in process context with IRQs enabled
+ * Determine if a connection may be reused.
  */
-int rxrpc_connect_call(struct rxrpc_call *call,
-		       struct rxrpc_conn_parameters *cp,
-		       struct sockaddr_rxrpc *srx,
-		       gfp_t gfp)
+static bool rxrpc_may_reuse_conn(struct rxrpc_connection *conn)
+{
+	int id_cursor, id, distance, limit;
+
+	if (test_bit(RXRPC_CONN_DONT_REUSE, &conn->flags))
+		goto dont_reuse;
+
+	if (conn->proto.epoch != rxrpc_epoch)
+		goto mark_dont_reuse;
+
+	/* The IDR tree gets very expensive on memory if the connection IDs are
+	 * widely scattered throughout the number space, so we shall want to
+	 * kill off connections that, say, have an ID more than about four
+	 * times the maximum number of client conns away from the current
+	 * allocation point to try and keep the IDs concentrated.
+	 */
+	id_cursor = READ_ONCE(rxrpc_client_conn_ids.cur);
+	id = conn->proto.cid >> RXRPC_CIDSHIFT;
+	distance = id - id_cursor;
+	if (distance < 0)
+		distance = -distance;
+	limit = round_up(rxrpc_max_client_connections, IDR_SIZE) * 4;
+	if (distance > limit)
+		goto mark_dont_reuse;
+
+	return true;
+
+mark_dont_reuse:
+	set_bit(RXRPC_CONN_DONT_REUSE, &conn->flags);
+dont_reuse:
+	return false;
+}
+
+/*
+ * Create or find a client connection to use for a call.
+ *
+ * If we return with a connection, the call will be on its waiting list.  It's
+ * left to the caller to assign a channel and wake up the call.
+ */
+static int rxrpc_get_client_conn(struct rxrpc_call *call,
+				 struct rxrpc_conn_parameters *cp,
+				 struct sockaddr_rxrpc *srx,
+				 gfp_t gfp)
 {
 	struct rxrpc_connection *conn, *candidate = NULL;
 	struct rxrpc_local *local = cp->local;
 	struct rb_node *p, **pp, *parent;
 	long diff;
-	int chan;
-
-	DECLARE_WAITQUEUE(myself, current);
+	int ret = -ENOMEM;
 
 	_enter("{%d,%lx},", call->debug_id, call->user_call_ID);
 
 	cp->peer = rxrpc_lookup_peer(cp->local, srx, gfp);
 	if (!cp->peer)
-		return -ENOMEM;
+		goto error;
 
+	/* If the connection is not meant to be exclusive, search the available
+	 * connections to see if the connection we want to use already exists.
+	 */
 	if (!cp->exclusive) {
-		/* Search for a existing client connection unless this is going
-		 * to be a connection that's used exclusively for a single call.
-		 */
 		_debug("search 1");
 		spin_lock(&local->client_conns_lock);
 		p = local->client_conns.rb_node;
@@ -207,39 +322,55 @@ int rxrpc_connect_call(struct rxrpc_call *call,
 			diff = (cmp(peer) ?:
 				cmp(key) ?:
 				cmp(security_level));
-			if (diff < 0)
+#undef cmp
+			if (diff < 0) {
 				p = p->rb_left;
-			else if (diff > 0)
+			} else if (diff > 0) {
 				p = p->rb_right;
-			else
-				goto found_extant_conn;
+			} else {
+				if (rxrpc_may_reuse_conn(conn) &&
+				    rxrpc_get_connection_maybe(conn))
+					goto found_extant_conn;
+				/* The connection needs replacing.  It's better
+				 * to effect that when we have something to
+				 * replace it with so that we don't have to
+				 * rebalance the tree twice.
+				 */
+				break;
+			}
 		}
 		spin_unlock(&local->client_conns_lock);
 	}
 
-	/* We didn't find a connection or we want an exclusive one. */
-	_debug("get new conn");
+	/* There wasn't a connection yet or we need an exclusive connection.
+	 * We need to create a candidate and then potentially redo the search
+	 * in case we're racing with another thread also trying to connect on a
+	 * shareable connection.
+	 */
+	_debug("new conn");
 	candidate = rxrpc_alloc_client_connection(cp, gfp);
-	if (!candidate) {
-		_leave(" = -ENOMEM");
-		return -ENOMEM;
+	if (IS_ERR(candidate)) {
+		ret = PTR_ERR(candidate);
+		goto error_peer;
 	}
 
+	/* Add the call to the new connection's waiting list in case we're
+	 * going to have to wait for the connection to come live.  It's our
+	 * connection, so we want first dibs on the channel slots.  We would
+	 * normally have to take channel_lock but we do this before anyone else
+	 * can see the connection.
+	 */
+	list_add_tail(&call->chan_wait_link, &candidate->waiting_calls);
+
 	if (cp->exclusive) {
-		/* Assign the call on an exclusive connection to channel 0 and
-		 * don't add the connection to the endpoint's shareable conn
-		 * lookup tree.
-		 */
-		_debug("exclusive chan 0");
-		conn = candidate;
-		atomic_set(&conn->avail_chans, RXRPC_MAXCALLS - 1);
-		spin_lock(&conn->channel_lock);
-		chan = 0;
-		goto found_channel;
+		call->conn = candidate;
+		_leave(" = 0 [exclusive %d]", candidate->debug_id);
+		return 0;
 	}
 
-	/* We need to redo the search before attempting to add a new connection
-	 * lest we race with someone else adding a conflicting instance.
+	/* Publish the new connection for userspace to find.  We need to redo
+	 * the search before doing this lest we race with someone else adding a
+	 * conflicting instance.
 	 */
 	_debug("search 2");
 	spin_lock(&local->client_conns_lock);
@@ -250,123 +381,672 @@ int rxrpc_connect_call(struct rxrpc_call *call,
 		parent = *pp;
 		conn = rb_entry(parent, struct rxrpc_connection, client_node);
 
+#define cmp(X) ((long)conn->params.X - (long)candidate->params.X)
 		diff = (cmp(peer) ?:
 			cmp(key) ?:
 			cmp(security_level));
-		if (diff < 0)
+#undef cmp
+		if (diff < 0) {
 			pp = &(*pp)->rb_left;
-		else if (diff > 0)
+		} else if (diff > 0) {
 			pp = &(*pp)->rb_right;
-		else
-			goto found_extant_conn;
+		} else {
+			if (rxrpc_may_reuse_conn(conn) &&
+			    rxrpc_get_connection_maybe(conn))
+				goto found_extant_conn;
+			/* The old connection is from an outdated epoch. */
+			_debug("replace conn");
+			clear_bit(RXRPC_CONN_IN_CLIENT_CONNS, &conn->flags);
+			rb_replace_node(&conn->client_node,
+					&candidate->client_node,
+					&local->client_conns);
+			goto candidate_published;
+		}
 	}
 
-	/* The second search also failed; simply add the new connection with
-	 * the new call in channel 0.  Note that we need to take the channel
-	 * lock before dropping the client conn lock.
-	 */
 	_debug("new conn");
-	set_bit(RXRPC_CONN_IN_CLIENT_CONNS, &candidate->flags);
 	rb_link_node(&candidate->client_node, parent, pp);
 	rb_insert_color(&candidate->client_node, &local->client_conns);
-attached:
-	conn = candidate;
-	candidate = NULL;
 
-	atomic_set(&conn->avail_chans, RXRPC_MAXCALLS - 1);
-	spin_lock(&conn->channel_lock);
+candidate_published:
+	set_bit(RXRPC_CONN_IN_CLIENT_CONNS, &candidate->flags);
+	call->conn = candidate;
 	spin_unlock(&local->client_conns_lock);
-	chan = 0;
+	_leave(" = 0 [new %d]", candidate->debug_id);
+	return 0;
 
-found_channel:
-	_debug("found chan");
-	call->conn	= conn;
-	call->peer	= rxrpc_get_peer(conn->params.peer);
-	call->cid	= conn->proto.cid | chan;
-	call->call_id	= ++conn->channels[chan].call_counter;
-	conn->channels[chan].call_id = call->call_id;
-	rcu_assign_pointer(conn->channels[chan].call, call);
+	/* We come here if we found a suitable connection already in existence.
+	 * Discard any candidate we may have allocated, and try to get a
+	 * channel on this one.
+	 */
+found_extant_conn:
+	_debug("found conn");
+	spin_unlock(&local->client_conns_lock);
 
-	_net("CONNECT call %d on conn %d", call->debug_id, conn->debug_id);
+	rxrpc_put_connection(candidate);
+	candidate = NULL;
 
+	spin_lock(&conn->channel_lock);
+	call->conn = conn;
+	list_add(&call->chan_wait_link, &conn->waiting_calls);
 	spin_unlock(&conn->channel_lock);
+	_leave(" = 0 [extant %d]", conn->debug_id);
+	return 0;
+
+error_peer:
 	rxrpc_put_peer(cp->peer);
 	cp->peer = NULL;
-	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
-	return 0;
+error:
+	_leave(" = %d", ret);
+	return ret;
+}
 
-	/* We found a potentially suitable connection already in existence.  If
-	 * we can reuse it (ie. its usage count hasn't been reduced to 0 by the
-	 * reaper), discard any candidate we may have allocated, and try to get
-	 * a channel on this one, otherwise we have to replace it.
-	 */
-found_extant_conn:
-	_debug("found conn");
-	if (!rxrpc_get_connection_maybe(conn)) {
-		set_bit(RXRPC_CONN_IN_CLIENT_CONNS, &candidate->flags);
-		rb_replace_node(&conn->client_node,
-				&candidate->client_node,
-				&local->client_conns);
-		clear_bit(RXRPC_CONN_IN_CLIENT_CONNS, &conn->flags);
-		goto attached;
+/*
+ * Activate a connection.
+ */
+static void rxrpc_activate_conn(struct rxrpc_connection *conn)
+{
+	conn->cache_state = RXRPC_CONN_CLIENT_ACTIVE;
+	rxrpc_nr_active_client_conns++;
+	list_move_tail(&conn->cache_link, &rxrpc_active_client_conns);
+}
+
+/*
+ * Attempt to animate a connection for a new call.
+ *
+ * If it's not exclusive, the connection is in the endpoint tree, and we're in
+ * the conn's list of those waiting to grab a channel.  There is, however, a
+ * limit on the number of live connections allowed at any one time, so we may
+ * have to wait for capacity to become available.
+ *
+ * Note that a connection on the waiting queue might *also* have active
+ * channels if it has been culled to make space and then re-requested by a new
+ * call.
+ */
+static void rxrpc_animate_client_conn(struct rxrpc_connection *conn)
+{
+	unsigned int nr_conns;
+
+	_enter("%d,%d", conn->debug_id, conn->cache_state);
+
+	if (conn->cache_state == RXRPC_CONN_CLIENT_ACTIVE)
+		goto out;
+
+	spin_lock(&rxrpc_client_conn_cache_lock);
+
+	nr_conns = rxrpc_nr_client_conns;
+	if (!test_and_set_bit(RXRPC_CONN_COUNTED, &conn->flags))
+		rxrpc_nr_client_conns = nr_conns + 1;
+
+	switch (conn->cache_state) {
+	case RXRPC_CONN_CLIENT_ACTIVE:
+	case RXRPC_CONN_CLIENT_WAITING:
+		break;
+
+	case RXRPC_CONN_CLIENT_INACTIVE:
+	case RXRPC_CONN_CLIENT_CULLED:
+	case RXRPC_CONN_CLIENT_IDLE:
+		if (nr_conns >= rxrpc_max_client_connections)
+			goto wait_for_capacity;
+		goto activate_conn;
+
+	default:
+		BUG();
 	}
 
-	spin_unlock(&local->client_conns_lock);
+out_unlock:
+	spin_unlock(&rxrpc_client_conn_cache_lock);
+out:
+	_leave(" [%d]", conn->cache_state);
+	return;
 
-	rxrpc_put_connection(candidate);
+activate_conn:
+	_debug("activate");
+	rxrpc_activate_conn(conn);
+	goto out_unlock;
+
+wait_for_capacity:
+	_debug("wait");
+	conn->cache_state = RXRPC_CONN_CLIENT_WAITING;
+	list_move_tail(&conn->cache_link, &rxrpc_waiting_client_conns);
+	goto out_unlock;
+}
+
+/*
+ * Deactivate a channel.
+ */
+static void rxrpc_deactivate_one_channel(struct rxrpc_connection *conn,
+					 unsigned int channel)
+{
+	struct rxrpc_channel *chan = &conn->channels[channel];
+
+	rcu_assign_pointer(chan->call, NULL);
+	conn->active_chans &= ~(1 << channel);
+}
+
+/*
+ * Assign a channel to the call at the front of the queue and wake the call up.
+ * We don't increment the callNumber counter until this number has been exposed
+ * to the world.
+ */
+static void rxrpc_activate_one_channel(struct rxrpc_connection *conn,
+				       unsigned int channel)
+{
+	struct rxrpc_channel *chan = &conn->channels[channel];
+	struct rxrpc_call *call = list_entry(conn->waiting_calls.next,
+					     struct rxrpc_call, chan_wait_link);
+	u32 call_id = chan->call_counter + 1;
+
+	list_del_init(&call->chan_wait_link);
+	conn->active_chans |= 1 << channel;
+	call->peer	= rxrpc_get_peer(conn->params.peer);
+	call->cid	= conn->proto.cid | channel;
+	call->call_id	= call_id;
+
+	_net("CONNECT call %08x:%08x as call %d on conn %d",
+	     call->cid, call->call_id, call->debug_id, conn->debug_id);
+
+	/* Paired with the read barrier in rxrpc_wait_for_channel().  This
+	 * orders cid and epoch in the connection wrt to call_id without the
+	 * need to take the channel_lock.
+	 *
+	 * We provisionally assign a callNumber at this point, but we don't
+	 * confirm it until the call is about to be exposed.
+	 *
+	 * TODO: Pair with a barrier in the data_ready handler when that looks
+	 * at the call ID through a connection channel.
+	 */
+	smp_wmb();
+	chan->call_id	= call_id;
+	rcu_assign_pointer(chan->call, call);
+	wake_up(&call->waitq);
+}
+
+/*
+ * Assign channels and callNumbers to waiting calls.
+ */
+static void rxrpc_activate_channels(struct rxrpc_connection *conn)
+{
+	unsigned char mask;
+
+	_enter("%d", conn->debug_id);
+
+	if (conn->cache_state != RXRPC_CONN_CLIENT_ACTIVE ||
+	    conn->active_chans == RXRPC_ACTIVE_CHANS_MASK)
+		return;
+
+	spin_lock(&conn->channel_lock);
+
+	while (!list_empty(&conn->waiting_calls) &&
+	       (mask = ~conn->active_chans,
+		mask &= RXRPC_ACTIVE_CHANS_MASK,
+		mask != 0))
+		rxrpc_activate_one_channel(conn, __ffs(mask));
+
+	spin_unlock(&conn->channel_lock);
+	_leave("");
+}
+
+/*
+ * Wait for a callNumber and a channel to be granted to a call.
+ */
+static int rxrpc_wait_for_channel(struct rxrpc_call *call, gfp_t gfp)
+{
+	int ret = 0;
+
+	_enter("%d", call->debug_id);
+
+	if (!call->call_id) {
+		DECLARE_WAITQUEUE(myself, current);
 
-	if (!atomic_add_unless(&conn->avail_chans, -1, 0)) {
 		if (!gfpflags_allow_blocking(gfp)) {
-			rxrpc_put_connection(conn);
-			_leave(" = -EAGAIN");
-			return -EAGAIN;
+			ret = -EAGAIN;
+			goto out;
 		}
 
-		add_wait_queue(&conn->channel_wq, &myself);
+		add_wait_queue_exclusive(&call->waitq, &myself);
 		for (;;) {
 			set_current_state(TASK_INTERRUPTIBLE);
-			if (atomic_add_unless(&conn->avail_chans, -1, 0))
+			if (call->call_id)
+				break;
+			if (signal_pending(current)) {
+				ret = -ERESTARTSYS;
 				break;
-			if (signal_pending(current))
-				goto interrupted;
+			}
 			schedule();
 		}
-		remove_wait_queue(&conn->channel_wq, &myself);
+		remove_wait_queue(&call->waitq, &myself);
 		__set_current_state(TASK_RUNNING);
 	}
 
-	/* The connection allegedly now has a free channel and we can now
-	 * attach the call to it.
-	 */
+	/* Paired with the write barrier in rxrpc_activate_one_channel(). */
+	smp_rmb();
+
+out:
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * find a connection for a call
+ * - called in process context with IRQs enabled
+ */
+int rxrpc_connect_call(struct rxrpc_call *call,
+		       struct rxrpc_conn_parameters *cp,
+		       struct sockaddr_rxrpc *srx,
+		       gfp_t gfp)
+{
+	int ret;
+
+	_enter("{%d,%lx},", call->debug_id, call->user_call_ID);
+
+	rxrpc_discard_expired_client_conns(NULL);
+	rxrpc_cull_active_client_conns();
+
+	ret = rxrpc_get_client_conn(call, cp, srx, gfp);
+	if (ret < 0)
+		return ret;
+
+	rxrpc_animate_client_conn(call->conn);
+	rxrpc_activate_channels(call->conn);
+
+	ret = rxrpc_wait_for_channel(call, gfp);
+	if (ret < 0)
+		rxrpc_disconnect_client_call(call);
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * Note that a connection is about to be exposed to the world.  Once it is
+ * exposed, we maintain an extra ref on it that stops it from being summarily
+ * discarded before it's (a) had a chance to deal with retransmission and (b)
+ * had a chance at re-use (the per-connection security negotiation is
+ * expensive).
+ */
+static void rxrpc_expose_client_conn(struct rxrpc_connection *conn)
+{
+	if (!test_and_set_bit(RXRPC_CONN_EXPOSED, &conn->flags))
+		rxrpc_get_connection(conn);
+}
+
+/*
+ * Note that a call, and thus a connection, is about to be exposed to the
+ * world.
+ */
+void rxrpc_expose_client_call(struct rxrpc_call *call)
+{
+	struct rxrpc_connection *conn = call->conn;
+	struct rxrpc_channel *chan =
+		&conn->channels[call->cid & RXRPC_CHANNELMASK];
+
+	if (!test_and_set_bit(RXRPC_CALL_EXPOSED, &call->flags)) {
+		/* Mark the call ID as being used.  If the callNumber counter
+		 * exceeds ~2 billion, we kill the connection after its
+		 * outstanding calls have finished so that the counter doesn't
+		 * wrap.
+		 */
+		chan->call_counter++;
+		if (chan->call_counter >= INT_MAX)
+			set_bit(RXRPC_CONN_DONT_REUSE, &conn->flags);
+		rxrpc_expose_client_conn(conn);
+	}
+}
+
+/*
+ * Disconnect a client call.
+ */
+void rxrpc_disconnect_client_call(struct rxrpc_call *call)
+{
+	unsigned int channel = call->cid & RXRPC_CHANNELMASK;
+	struct rxrpc_connection *conn = call->conn;
+	struct rxrpc_channel *chan = &conn->channels[channel];
+
+	call->conn = NULL;
+
 	spin_lock(&conn->channel_lock);
 
-	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
-		if (!conn->channels[chan].call)
-			goto found_channel;
-	BUG();
+	/* Calls that have never actually been assigned a channel can simply be
+	 * discarded.  If the conn didn't get used either, it will follow
+	 * immediately unless someone else grabs it in the meantime.
+	 */
+	if (!list_empty(&call->chan_wait_link)) {
+		_debug("call is waiting");
+		ASSERTCMP(call->call_id, ==, 0);
+		ASSERT(!test_bit(RXRPC_CALL_EXPOSED, &call->flags));
+		list_del_init(&call->chan_wait_link);
+
+		/* We must deactivate or idle the connection if it's now
+		 * waiting for nothing.
+		 */
+		spin_lock(&rxrpc_client_conn_cache_lock);
+		if (conn->cache_state == RXRPC_CONN_CLIENT_WAITING &&
+		    list_empty(&conn->waiting_calls) &&
+		    !conn->active_chans)
+			goto idle_connection;
+		goto out;
+	}
+
+	ASSERTCMP(rcu_access_pointer(chan->call), ==, call);
+	ASSERTCMP(atomic_read(&conn->usage), >=, 2);
+
+	/* If a client call was exposed to the world, we save the result for
+	 * retransmission.
+	 *
+	 * We use a barrier here so that the call number and abort code can be
+	 * read without needing to take a lock.
+	 *
+	 * TODO: Make the incoming packet handler check this and handle
+	 * terminal retransmission without requiring access to the call.
+	 */
+	if (test_bit(RXRPC_CALL_EXPOSED, &call->flags)) {
+		_debug("exposed %u,%u", call->call_id, call->local_abort);
+		__rxrpc_disconnect_call(conn, call);
+	}
+
+	/* See if we can pass the channel directly to another call. */
+	if (conn->cache_state == RXRPC_CONN_CLIENT_ACTIVE &&
+	    !list_empty(&conn->waiting_calls)) {
+		_debug("pass chan");
+		rxrpc_activate_one_channel(conn, channel);
+		goto out_2;
+	}
+
+	/* Things are more complex and we need the cache lock.  We might be
+	 * able to simply idle the conn or it might now be lurking on the wait
+	 * list.  It might even get moved back to the active list whilst we're
+	 * waiting for the lock.
+	 */
+	spin_lock(&rxrpc_client_conn_cache_lock);
+
+	switch (conn->cache_state) {
+	case RXRPC_CONN_CLIENT_ACTIVE:
+		if (list_empty(&conn->waiting_calls)) {
+			rxrpc_deactivate_one_channel(conn, channel);
+			if (!conn->active_chans) {
+				rxrpc_nr_active_client_conns--;
+				goto idle_connection;
+			}
+			goto out;
+		}
+
+		_debug("pass chan 2");
+		rxrpc_activate_one_channel(conn, channel);
+		goto out;
+
+	case RXRPC_CONN_CLIENT_CULLED:
+		rxrpc_deactivate_one_channel(conn, channel);
+		ASSERT(list_empty(&conn->waiting_calls));
+		if (!conn->active_chans)
+			goto idle_connection;
+		goto out;
+
+	case RXRPC_CONN_CLIENT_WAITING:
+		rxrpc_deactivate_one_channel(conn, channel);
+		goto out;
+
+	default:
+		BUG();
+	}
 
-interrupted:
-	remove_wait_queue(&conn->channel_wq, &myself);
-	__set_current_state(TASK_RUNNING);
+out:
+	spin_unlock(&rxrpc_client_conn_cache_lock);
+out_2:
+	spin_unlock(&conn->channel_lock);
 	rxrpc_put_connection(conn);
-	rxrpc_put_peer(cp->peer);
-	cp->peer = NULL;
-	_leave(" = -ERESTARTSYS");
-	return -ERESTARTSYS;
+	_leave("");
+	return;
+
+idle_connection:
+	/* As no channels remain active, the connection gets deactivated
+	 * immediately or moved to the idle list for a short while.
+	 */
+	if (test_bit(RXRPC_CONN_EXPOSED, &conn->flags)) {
+		_debug("make idle");
+		conn->idle_timestamp = jiffies;
+		conn->cache_state = RXRPC_CONN_CLIENT_IDLE;
+		list_move_tail(&conn->cache_link, &rxrpc_idle_client_conns);
+		if (rxrpc_idle_client_conns.next == &conn->cache_link &&
+		    !rxrpc_kill_all_client_conns)
+			queue_delayed_work(rxrpc_workqueue,
+					   &rxrpc_client_conn_reap,
+					   rxrpc_conn_idle_client_expiry);
+	} else {
+		_debug("make inactive");
+		conn->cache_state = RXRPC_CONN_CLIENT_INACTIVE;
+		list_del_init(&conn->cache_link);
+	}
+	goto out;
 }
 
 /*
- * Remove a client connection from the local endpoint's tree, thereby removing
- * it as a target for reuse for new client calls.
+ * Clean up a dead client connection.
  */
-void rxrpc_unpublish_client_conn(struct rxrpc_connection *conn)
+static struct rxrpc_connection *
+rxrpc_put_one_client_conn(struct rxrpc_connection *conn)
 {
+	struct rxrpc_connection *next;
 	struct rxrpc_local *local = conn->params.local;
+	unsigned int nr_conns;
 
-	spin_lock(&local->client_conns_lock);
-	if (test_and_clear_bit(RXRPC_CONN_IN_CLIENT_CONNS, &conn->flags))
-		rb_erase(&conn->client_node, &local->client_conns);
-	spin_unlock(&local->client_conns_lock);
+	if (test_bit(RXRPC_CONN_IN_CLIENT_CONNS, &conn->flags)) {
+		spin_lock(&local->client_conns_lock);
+		if (test_and_clear_bit(RXRPC_CONN_IN_CLIENT_CONNS,
+				       &conn->flags))
+			rb_erase(&conn->client_node, &local->client_conns);
+		spin_unlock(&local->client_conns_lock);
+	}
 
 	rxrpc_put_client_connection_id(conn);
+
+	ASSERTCMP(conn->cache_state, ==, RXRPC_CONN_CLIENT_INACTIVE);
+
+	if (!test_bit(RXRPC_CONN_COUNTED, &conn->flags))
+		return NULL;
+
+	spin_lock(&rxrpc_client_conn_cache_lock);
+	nr_conns = --rxrpc_nr_client_conns;
+
+	next = NULL;
+	if (nr_conns < rxrpc_max_client_connections &&
+	    !list_empty(&rxrpc_waiting_client_conns)) {
+		next = list_entry(rxrpc_waiting_client_conns.next,
+				  struct rxrpc_connection, cache_link);
+		rxrpc_get_connection(next);
+		rxrpc_activate_conn(next);
+	}
+
+	spin_unlock(&rxrpc_client_conn_cache_lock);
+	rxrpc_kill_connection(conn);
+
+	if (next)
+		rxrpc_activate_channels(next);
+
+	/* We need to get rid of the temporary ref we took upon next, but we
+	 * can't call rxrpc_put_connection() recursively.
+	 */
+	return next;
+}
+
+/*
+ * Clean up a dead client connections.
+ */
+void rxrpc_put_client_conn(struct rxrpc_connection *conn)
+{
+	struct rxrpc_connection *next;
+
+	do {
+		_enter("%p{u=%d,d=%d}",
+		       conn, atomic_read(&conn->usage), conn->debug_id);
+
+		next = rxrpc_put_one_client_conn(conn);
+
+		if (!next)
+			break;
+		conn = next;
+	} while (atomic_dec_and_test(&conn->usage));
+
+	_leave("");
+}
+
+/*
+ * Kill the longest-active client connections to make room for new ones.
+ */
+static void rxrpc_cull_active_client_conns(void)
+{
+	struct rxrpc_connection *conn;
+	unsigned int nr_conns = rxrpc_nr_client_conns;
+	unsigned int nr_active, limit;
+
+	_enter("");
+
+	ASSERTCMP(nr_conns, >=, 0);
+	if (nr_conns < rxrpc_max_client_connections) {
+		_leave(" [ok]");
+		return;
+	}
+	limit = rxrpc_reap_client_connections;
+
+	spin_lock(&rxrpc_client_conn_cache_lock);
+	nr_active = rxrpc_nr_active_client_conns;
+
+	while (nr_active > limit) {
+		ASSERT(!list_empty(&rxrpc_active_client_conns));
+		conn = list_entry(rxrpc_active_client_conns.next,
+				  struct rxrpc_connection, cache_link);
+		ASSERTCMP(conn->cache_state, ==, RXRPC_CONN_CLIENT_ACTIVE);
+
+		if (list_empty(&conn->waiting_calls)) {
+			conn->cache_state = RXRPC_CONN_CLIENT_CULLED;
+			list_del_init(&conn->cache_link);
+		} else {
+			conn->cache_state = RXRPC_CONN_CLIENT_WAITING;
+			list_move_tail(&conn->cache_link,
+				       &rxrpc_waiting_client_conns);
+		}
+
+		nr_active--;
+	}
+
+	rxrpc_nr_active_client_conns = nr_active;
+	spin_unlock(&rxrpc_client_conn_cache_lock);
+	ASSERTCMP(nr_active, >=, 0);
+	_leave(" [culled]");
+}
+
+/*
+ * Discard expired client connections from the idle list.  Each conn in the
+ * idle list has been exposed and holds an extra ref because of that.
+ *
+ * This may be called from conn setup or from a work item so cannot be
+ * considered non-reentrant.
+ */
+static void rxrpc_discard_expired_client_conns(struct work_struct *work)
+{
+	struct rxrpc_connection *conn;
+	unsigned long expiry, conn_expires_at, now;
+	unsigned int nr_conns;
+	bool did_discard = false;
+
+	_enter("%c", work ? 'w' : 'n');
+
+	if (list_empty(&rxrpc_idle_client_conns)) {
+		_leave(" [empty]");
+		return;
+	}
+
+	/* Don't double up on the discarding */
+	if (!spin_trylock(&rxrpc_client_conn_discard_mutex)) {
+		_leave(" [already]");
+		return;
+	}
+
+	/* We keep an estimate of what the number of conns ought to be after
+	 * we've discarded some so that we don't overdo the discarding.
+	 */
+	nr_conns = rxrpc_nr_client_conns;
+
+next:
+	spin_lock(&rxrpc_client_conn_cache_lock);
+
+	if (list_empty(&rxrpc_idle_client_conns))
+		goto out;
+
+	conn = list_entry(rxrpc_idle_client_conns.next,
+			  struct rxrpc_connection, cache_link);
+	ASSERT(test_bit(RXRPC_CONN_EXPOSED, &conn->flags));
+
+	if (!rxrpc_kill_all_client_conns) {
+		/* If the number of connections is over the reap limit, we
+		 * expedite discard by reducing the expiry timeout.  We must,
+		 * however, have at least a short grace period to be able to do
+		 * final-ACK or ABORT retransmission.
+		 */
+		expiry = rxrpc_conn_idle_client_expiry;
+		if (nr_conns > rxrpc_reap_client_connections)
+			expiry = rxrpc_conn_idle_client_fast_expiry;
+
+		conn_expires_at = conn->idle_timestamp + expiry;
+
+		now = READ_ONCE(jiffies);
+		if (time_after(conn_expires_at, now))
+			goto not_yet_expired;
+	}
+
+	_debug("discard conn %d", conn->debug_id);
+	if (!test_and_clear_bit(RXRPC_CONN_EXPOSED, &conn->flags))
+		BUG();
+	conn->cache_state = RXRPC_CONN_CLIENT_INACTIVE;
+	list_del_init(&conn->cache_link);
+
+	spin_unlock(&rxrpc_client_conn_cache_lock);
+
+	/* When we cleared the EXPOSED flag, we took on responsibility for the
+	 * reference that that had on the usage count.  We deal with that here.
+	 * If someone re-sets the flag and re-gets the ref, that's fine.
+	 */
+	rxrpc_put_connection(conn);
+	did_discard = true;
+	nr_conns--;
+	goto next;
+
+not_yet_expired:
+	/* The connection at the front of the queue hasn't yet expired, so
+	 * schedule the work item for that point if we discarded something.
+	 *
+	 * We don't worry if the work item is already scheduled - it can look
+	 * after rescheduling itself at a later time.  We could cancel it, but
+	 * then things get messier.
+	 */
+	_debug("not yet");
+	if (!rxrpc_kill_all_client_conns)
+		queue_delayed_work(rxrpc_workqueue,
+				   &rxrpc_client_conn_reap,
+				   conn_expires_at - now);
+
+out:
+	spin_unlock(&rxrpc_client_conn_cache_lock);
+	spin_unlock(&rxrpc_client_conn_discard_mutex);
+	_leave("");
+}
+
+/*
+ * Preemptively destroy all the client connection records rather than waiting
+ * for them to time out
+ */
+void __exit rxrpc_destroy_all_client_connections(void)
+{
+	_enter("");
+
+	spin_lock(&rxrpc_client_conn_cache_lock);
+	rxrpc_kill_all_client_conns = true;
+	spin_unlock(&rxrpc_client_conn_cache_lock);
+
+	cancel_delayed_work(&rxrpc_client_conn_reap);
+
+	if (!queue_delayed_work(rxrpc_workqueue, &rxrpc_client_conn_reap, 0))
+		_debug("destroy: queue failed");
+
+	_leave("");
 }
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index afc2d83d5995..5b45b6c367e7 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -1,6 +1,6 @@
-/* RxRPC virtual connection handler
+/* RxRPC virtual connection handler, common bits.
  *
- * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2007, 2016 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -15,8 +15,6 @@
 #include <linux/slab.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
-#include <net/sock.h>
-#include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
 /*
@@ -31,6 +29,8 @@ LIST_HEAD(rxrpc_connection_proc_list);
 DEFINE_RWLOCK(rxrpc_connection_lock);
 static DECLARE_DELAYED_WORK(rxrpc_connection_reap, rxrpc_connection_reaper);
 
+static void rxrpc_destroy_connection(struct rcu_head *);
+
 /*
  * allocate a new connection
  */
@@ -42,20 +42,16 @@ struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 
 	conn = kzalloc(sizeof(struct rxrpc_connection), gfp);
 	if (conn) {
+		INIT_LIST_HEAD(&conn->cache_link);
 		spin_lock_init(&conn->channel_lock);
-		init_waitqueue_head(&conn->channel_wq);
+		INIT_LIST_HEAD(&conn->waiting_calls);
 		INIT_WORK(&conn->processor, &rxrpc_process_connection);
 		INIT_LIST_HEAD(&conn->proc_link);
 		INIT_LIST_HEAD(&conn->link);
 		skb_queue_head_init(&conn->rx_queue);
 		conn->security = &rxrpc_no_security;
 		spin_lock_init(&conn->state_lock);
-		/* We maintain an extra ref on the connection whilst it is
-		 * on the rxrpc_connections list.
-		 */
-		atomic_set(&conn->usage, 2);
 		conn->debug_id = atomic_inc_return(&rxrpc_debug_id);
-		atomic_set(&conn->avail_chans, RXRPC_MAXCALLS);
 		conn->size_align = 4;
 		conn->header_size = sizeof(struct rxrpc_wire_header);
 		conn->idle_timestamp = jiffies;
@@ -156,9 +152,9 @@ not_found:
  * terminates.  The caller must hold the channel_lock and must release the
  * call's ref on the connection.
  */
-void __rxrpc_disconnect_call(struct rxrpc_call *call)
+void __rxrpc_disconnect_call(struct rxrpc_connection *conn,
+			     struct rxrpc_call *call)
 {
-	struct rxrpc_connection *conn = call->conn;
 	struct rxrpc_channel *chan =
 		&conn->channels[call->cid & RXRPC_CHANNELMASK];
 
@@ -182,8 +178,6 @@ void __rxrpc_disconnect_call(struct rxrpc_call *call)
 		chan->call_id = chan->call_counter;
 
 		rcu_assign_pointer(chan->call, NULL);
-		atomic_inc(&conn->avail_chans);
-		wake_up(&conn->channel_wq);
 	}
 
 	_leave("");
@@ -197,8 +191,11 @@ void rxrpc_disconnect_call(struct rxrpc_call *call)
 {
 	struct rxrpc_connection *conn = call->conn;
 
+	if (rxrpc_is_client_call(call))
+		return rxrpc_disconnect_client_call(call);
+
 	spin_lock(&conn->channel_lock);
-	__rxrpc_disconnect_call(call);
+	__rxrpc_disconnect_call(conn, call);
 	spin_unlock(&conn->channel_lock);
 
 	call->conn = NULL;
@@ -207,6 +204,34 @@ void rxrpc_disconnect_call(struct rxrpc_call *call)
 }
 
 /*
+ * Kill off a connection.
+ */
+void rxrpc_kill_connection(struct rxrpc_connection *conn)
+{
+	ASSERT(!rcu_access_pointer(conn->channels[0].call) &&
+	       !rcu_access_pointer(conn->channels[1].call) &&
+	       !rcu_access_pointer(conn->channels[2].call) &&
+	       !rcu_access_pointer(conn->channels[3].call));
+	ASSERT(list_empty(&conn->cache_link));
+
+	write_lock(&rxrpc_connection_lock);
+	list_del_init(&conn->proc_link);
+	write_unlock(&rxrpc_connection_lock);
+
+	/* Drain the Rx queue.  Note that even though we've unpublished, an
+	 * incoming packet could still be being added to our Rx queue, so we
+	 * will need to drain it again in the RCU cleanup handler.
+	 */
+	rxrpc_purge_queue(&conn->rx_queue);
+
+	/* Leave final destruction to RCU.  The connection processor work item
+	 * must carry a ref on the connection to prevent us getting here whilst
+	 * it is queued or running.
+	 */
+	call_rcu(&conn->rcu, rxrpc_destroy_connection);
+}
+
+/*
  * release a virtual connection
  */
 void __rxrpc_put_connection(struct rxrpc_connection *conn)
@@ -241,7 +266,7 @@ static void rxrpc_destroy_connection(struct rcu_head *rcu)
 }
 
 /*
- * reap dead connections
+ * reap dead service connections
  */
 static void rxrpc_connection_reaper(struct work_struct *work)
 {
@@ -280,12 +305,11 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 			continue;
 
 		if (rxrpc_conn_is_client(conn))
-			rxrpc_unpublish_client_conn(conn);
+			BUG();
 		else
 			rxrpc_unpublish_service_conn(conn);
 
 		list_move_tail(&conn->link, &graveyard);
-		list_del_init(&conn->proc_link);
 	}
 	write_unlock(&rxrpc_connection_lock);
 
@@ -302,16 +326,15 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 		list_del_init(&conn->link);
 
 		ASSERTCMP(atomic_read(&conn->usage), ==, 0);
-		skb_queue_purge(&conn->rx_queue);
-		call_rcu(&conn->rcu, rxrpc_destroy_connection);
+		rxrpc_kill_connection(conn);
 	}
 
 	_leave("");
 }
 
 /*
- * preemptively destroy all the connection records rather than waiting for them
- * to time out
+ * preemptively destroy all the service connection records rather than
+ * waiting for them to time out
  */
 void __exit rxrpc_destroy_all_connections(void)
 {
@@ -320,6 +343,8 @@ void __exit rxrpc_destroy_all_connections(void)
 
 	_enter("");
 
+	rxrpc_destroy_all_client_connections();
+
 	rxrpc_connection_expiry = 0;
 	cancel_delayed_work(&rxrpc_connection_reap);
 	rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
@@ -334,6 +359,8 @@ void __exit rxrpc_destroy_all_connections(void)
 	write_unlock(&rxrpc_connection_lock);
 	BUG_ON(leak);
 
+	ASSERT(list_empty(&rxrpc_connection_proc_list));
+
 	/* Make sure the local and peer records pinned by any dying connections
 	 * are released.
 	 */
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index 6ad6ae926cc3..316a92107fee 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -185,6 +185,11 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 
 	rxrpc_get_local(local);
 
+	/* We maintain an extra ref on the connection whilst it is on
+	 * the rxrpc_connections list.
+	 */
+	atomic_set(&conn->usage, 2);
+
 	write_lock(&rxrpc_connection_lock);
 	list_add_tail(&conn->link, &rxrpc_connections);
 	list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index e3a08d542fb7..8a9917cba6fe 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -390,7 +390,7 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 			  call->acks_winsz),
 	       *timeo);
 
-	add_wait_queue(&call->tx_waitq, &myself);
+	add_wait_queue(&call->waitq, &myself);
 
 	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
@@ -408,7 +408,7 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 		lock_sock(&rx->sk);
 	}
 
-	remove_wait_queue(&call->tx_waitq, &myself);
+	remove_wait_queue(&call->waitq, &myself);
 	set_current_state(TASK_RUNNING);
 	_leave(" = %d", ret);
 	return ret;
@@ -482,6 +482,8 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	if (try_to_del_timer_sync(&call->ack_timer) >= 0) {
 		/* the packet may be freed by rxrpc_process_call() before this
 		 * returns */
+		if (rxrpc_is_client_call(call))
+			rxrpc_expose_client_call(call);
 		ret = rxrpc_send_data_packet(call->conn, skb);
 		_net("sent skb %p", skb);
 	} else {
diff --git a/net/rxrpc/sysctl.c b/net/rxrpc/sysctl.c
index 03ad08774d4e..dc380af8a81e 100644
--- a/net/rxrpc/sysctl.c
+++ b/net/rxrpc/sysctl.c
@@ -62,6 +62,22 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 		.proc_handler	= proc_dointvec_ms_jiffies,
 		.extra1		= (void *)&one,
 	},
+	{
+		.procname	= "idle_conn_expiry",
+		.data		= &rxrpc_conn_idle_client_expiry,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.extra1		= (void *)&one,
+	},
+	{
+		.procname	= "idle_conn_fast_expiry",
+		.data		= &rxrpc_conn_idle_client_fast_expiry,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.extra1		= (void *)&one,
+	},
 
 	/* Values measured in seconds but used in jiffies */
 	{
@@ -81,17 +97,24 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 		.extra1		= (void *)&one,
 	},
 
-	/* Values measured in seconds */
+	/* Non-time values */
+	{
+		.procname	= "max_client_conns",
+		.data		= &rxrpc_max_client_connections,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&rxrpc_reap_client_connections,
+	},
 	{
-		.procname	= "connection_expiry",
-		.data		= &rxrpc_connection_expiry,
+		.procname	= "reap_client_conns",
+		.data		= &rxrpc_reap_client_connections,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= (void *)&one,
+		.extra2		= (void *)&rxrpc_max_client_connections,
 	},
-
-	/* Non-time values */
 	{
 		.procname	= "max_backlog",
 		.data		= &rxrpc_max_backlog,
