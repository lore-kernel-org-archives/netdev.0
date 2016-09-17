From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 03/11] rxrpc: Add connection tracepoint and client
 conn state tracepoint
Date: Sun, 18 Sep 2016 00:21:50 +0100
Message-ID: <147415451062.18436.5068053223129973355.stgit@warthog.procyon.org.uk>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a pair of tracepoints, one to track rxrpc_connection struct ref
counting and the other to track the client connection cache state.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   60 +++++++++++++++++++++++++++++++
 net/rxrpc/ar-internal.h      |   76 +++++++++++++++++++++++++--------------
 net/rxrpc/call_accept.c      |    4 ++
 net/rxrpc/call_object.c      |    2 -
 net/rxrpc/conn_client.c      |   82 +++++++++++++++++++++++++++++-------------
 net/rxrpc/conn_event.c       |    2 +
 net/rxrpc/conn_object.c      |   72 +++++++++++++++++++++++++++++++++++--
 net/rxrpc/conn_service.c     |    4 ++
 net/rxrpc/misc.c             |   31 ++++++++++++++++
 9 files changed, 274 insertions(+), 59 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 0a30c673509c..c0c496c83f31 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -16,6 +16,66 @@
 
 #include <linux/tracepoint.h>
 
+TRACE_EVENT(rxrpc_conn,
+	    TP_PROTO(struct rxrpc_connection *conn, enum rxrpc_conn_trace op,
+		     int usage, const void *where),
+
+	    TP_ARGS(conn, op, usage, where),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_connection *,	conn		)
+		    __field(int,			op		)
+		    __field(int,			usage		)
+		    __field(const void *,		where		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->conn = conn;
+		    __entry->op = op;
+		    __entry->usage = usage;
+		    __entry->where = where;
+			   ),
+
+	    TP_printk("C=%p %s u=%d sp=%pSR",
+		      __entry->conn,
+		      rxrpc_conn_traces[__entry->op],
+		      __entry->usage,
+		      __entry->where)
+	    );
+
+TRACE_EVENT(rxrpc_client,
+	    TP_PROTO(struct rxrpc_connection *conn, int channel,
+		     enum rxrpc_client_trace op),
+
+	    TP_ARGS(conn, channel, op),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_connection *,	conn		)
+		    __field(u32,			cid		)
+		    __field(int,			channel		)
+		    __field(int,			usage		)
+		    __field(enum rxrpc_client_trace,	op		)
+		    __field(enum rxrpc_conn_cache_state, cs		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->conn = conn;
+		    __entry->channel = channel;
+		    __entry->usage = atomic_read(&conn->usage);
+		    __entry->op = op;
+		    __entry->cid = conn->proto.cid;
+		    __entry->cs = conn->cache_state;
+			   ),
+
+	    TP_printk("C=%p h=%2d %s %s i=%08x u=%d",
+		      __entry->conn,
+		      __entry->channel,
+		      rxrpc_client_traces[__entry->op],
+		      rxrpc_conn_cache_states[__entry->cs],
+		      __entry->cid,
+		      __entry->usage)
+	    );
+
 TRACE_EVENT(rxrpc_call,
 	    TP_PROTO(struct rxrpc_call *call, enum rxrpc_call_trace op,
 		     int usage, const void *where, const void *aux),
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 4a73c20d9436..6ca40eea3022 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -314,6 +314,7 @@ enum rxrpc_conn_cache_state {
 	RXRPC_CONN_CLIENT_ACTIVE,	/* Conn is on active list, doing calls */
 	RXRPC_CONN_CLIENT_CULLED,	/* Conn is culled and delisted, doing calls */
 	RXRPC_CONN_CLIENT_IDLE,		/* Conn is on idle list, doing mostly nothing */
+	RXRPC_CONN__NR_CACHE_STATES
 };
 
 /*
@@ -533,6 +534,44 @@ struct rxrpc_call {
 	rxrpc_serial_t		acks_latest;	/* serial number of latest ACK received */
 };
 
+enum rxrpc_conn_trace {
+	rxrpc_conn_new_client,
+	rxrpc_conn_new_service,
+	rxrpc_conn_queued,
+	rxrpc_conn_seen,
+	rxrpc_conn_got,
+	rxrpc_conn_put_client,
+	rxrpc_conn_put_service,
+	rxrpc_conn__nr_trace
+};
+
+extern const char rxrpc_conn_traces[rxrpc_conn__nr_trace][4];
+
+enum rxrpc_client_trace {
+	rxrpc_client_activate_chans,
+	rxrpc_client_alloc,
+	rxrpc_client_chan_activate,
+	rxrpc_client_chan_disconnect,
+	rxrpc_client_chan_pass,
+	rxrpc_client_chan_unstarted,
+	rxrpc_client_cleanup,
+	rxrpc_client_count,
+	rxrpc_client_discard,
+	rxrpc_client_duplicate,
+	rxrpc_client_exposed,
+	rxrpc_client_replace,
+	rxrpc_client_to_active,
+	rxrpc_client_to_culled,
+	rxrpc_client_to_idle,
+	rxrpc_client_to_inactive,
+	rxrpc_client_to_waiting,
+	rxrpc_client_uncount,
+	rxrpc_client__nr_trace
+};
+
+extern const char rxrpc_client_traces[rxrpc_client__nr_trace][7];
+extern const char rxrpc_conn_cache_states[RXRPC_CONN__NR_CACHE_STATES][5];
+
 enum rxrpc_call_trace {
 	rxrpc_call_new_client,
 	rxrpc_call_new_service,
@@ -734,7 +773,11 @@ struct rxrpc_connection *rxrpc_find_connection_rcu(struct rxrpc_local *,
 void __rxrpc_disconnect_call(struct rxrpc_connection *, struct rxrpc_call *);
 void rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_kill_connection(struct rxrpc_connection *);
-void __rxrpc_put_connection(struct rxrpc_connection *);
+bool rxrpc_queue_conn(struct rxrpc_connection *);
+void rxrpc_see_connection(struct rxrpc_connection *);
+void rxrpc_get_connection(struct rxrpc_connection *);
+struct rxrpc_connection *rxrpc_get_connection_maybe(struct rxrpc_connection *);
+void rxrpc_put_service_conn(struct rxrpc_connection *);
 void __exit rxrpc_destroy_all_connections(void);
 
 static inline bool rxrpc_conn_is_client(const struct rxrpc_connection *conn)
@@ -747,38 +790,15 @@ static inline bool rxrpc_conn_is_service(const struct rxrpc_connection *conn)
 	return !rxrpc_conn_is_client(conn);
 }
 
-static inline void rxrpc_get_connection(struct rxrpc_connection *conn)
-{
-	atomic_inc(&conn->usage);
-}
-
-static inline
-struct rxrpc_connection *rxrpc_get_connection_maybe(struct rxrpc_connection *conn)
-{
-	return atomic_inc_not_zero(&conn->usage) ? conn : NULL;
-}
-
 static inline void rxrpc_put_connection(struct rxrpc_connection *conn)
 {
 	if (!conn)
 		return;
 
-	if (rxrpc_conn_is_client(conn)) {
-		if (atomic_dec_and_test(&conn->usage))
-			rxrpc_put_client_conn(conn);
-	} else {
-		if (atomic_dec_return(&conn->usage) == 1)
-			__rxrpc_put_connection(conn);
-	}
-}
-
-static inline bool rxrpc_queue_conn(struct rxrpc_connection *conn)
-{
-	if (!rxrpc_get_connection_maybe(conn))
-		return false;
-	if (!rxrpc_queue_work(&conn->processor))
-		rxrpc_put_connection(conn);
-	return true;
+	if (rxrpc_conn_is_client(conn))
+		rxrpc_put_client_conn(conn);
+	else
+		rxrpc_put_service_conn(conn);
 }
 
 /*
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 323b8da50163..3e474508ba75 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -85,6 +85,9 @@ static int rxrpc_service_prealloc_one(struct rxrpc_sock *rx,
 		b->conn_backlog[head] = conn;
 		smp_store_release(&b->conn_backlog_head,
 				  (head + 1) & (size - 1));
+
+		trace_rxrpc_conn(conn, rxrpc_conn_new_service,
+				 atomic_read(&conn->usage), here);
 	}
 
 	/* Now it gets complicated, because calls get registered with the
@@ -290,6 +293,7 @@ static struct rxrpc_call *rxrpc_alloc_incoming_call(struct rxrpc_sock *rx,
 		rxrpc_get_local(local);
 		conn->params.local = local;
 		conn->params.peer = peer;
+		rxrpc_see_connection(conn);
 		rxrpc_new_incoming_connection(conn, skb);
 	} else {
 		rxrpc_get_connection(conn);
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 0df9d1af8edb..54f30482a7fd 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -479,8 +479,6 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 				  struct rxrpc_call, accept_link);
 		list_del(&call->accept_link);
 		rxrpc_abort_call("SKR", call, 0, RX_CALL_DEAD, ECONNRESET);
-		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
-		rxrpc_release_call(rx, call);
 		rxrpc_put_call(call, rxrpc_call_put);
 	}
 
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 226bc910e556..c76a125df891 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -105,6 +105,14 @@ static void rxrpc_discard_expired_client_conns(struct work_struct *);
 static DECLARE_DELAYED_WORK(rxrpc_client_conn_reap,
 			    rxrpc_discard_expired_client_conns);
 
+const char rxrpc_conn_cache_states[RXRPC_CONN__NR_CACHE_STATES][5] = {
+	[RXRPC_CONN_CLIENT_INACTIVE]	= "Inac",
+	[RXRPC_CONN_CLIENT_WAITING]	= "Wait",
+	[RXRPC_CONN_CLIENT_ACTIVE]	= "Actv",
+	[RXRPC_CONN_CLIENT_CULLED]	= "Cull",
+	[RXRPC_CONN_CLIENT_IDLE]	= "Idle",
+};
+
 /*
  * Get a connection ID and epoch for a client connection from the global pool.
  * The connection struct pointer is then recorded in the idr radix tree.  The
@@ -220,6 +228,9 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 	rxrpc_get_local(conn->params.local);
 	key_get(conn->params.key);
 
+	trace_rxrpc_conn(conn, rxrpc_conn_new_client, atomic_read(&conn->usage),
+			 __builtin_return_address(0));
+	trace_rxrpc_client(conn, -1, rxrpc_client_alloc);
 	_leave(" = %p", conn);
 	return conn;
 
@@ -385,6 +396,7 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 			rb_replace_node(&conn->client_node,
 					&candidate->client_node,
 					&local->client_conns);
+			trace_rxrpc_client(conn, -1, rxrpc_client_replace);
 			goto candidate_published;
 		}
 	}
@@ -409,8 +421,11 @@ found_extant_conn:
 	_debug("found conn");
 	spin_unlock(&local->client_conns_lock);
 
-	rxrpc_put_connection(candidate);
-	candidate = NULL;
+	if (candidate) {
+		trace_rxrpc_client(candidate, -1, rxrpc_client_duplicate);
+		rxrpc_put_connection(candidate);
+		candidate = NULL;
+	}
 
 	spin_lock(&conn->channel_lock);
 	call->conn = conn;
@@ -433,6 +448,7 @@ error:
  */
 static void rxrpc_activate_conn(struct rxrpc_connection *conn)
 {
+	trace_rxrpc_client(conn, -1, rxrpc_client_to_active);
 	conn->cache_state = RXRPC_CONN_CLIENT_ACTIVE;
 	rxrpc_nr_active_client_conns++;
 	list_move_tail(&conn->cache_link, &rxrpc_active_client_conns);
@@ -462,8 +478,10 @@ static void rxrpc_animate_client_conn(struct rxrpc_connection *conn)
 	spin_lock(&rxrpc_client_conn_cache_lock);
 
 	nr_conns = rxrpc_nr_client_conns;
-	if (!test_and_set_bit(RXRPC_CONN_COUNTED, &conn->flags))
+	if (!test_and_set_bit(RXRPC_CONN_COUNTED, &conn->flags)) {
+		trace_rxrpc_client(conn, -1, rxrpc_client_count);
 		rxrpc_nr_client_conns = nr_conns + 1;
+	}
 
 	switch (conn->cache_state) {
 	case RXRPC_CONN_CLIENT_ACTIVE:
@@ -494,6 +512,7 @@ activate_conn:
 
 wait_for_capacity:
 	_debug("wait");
+	trace_rxrpc_client(conn, -1, rxrpc_client_to_waiting);
 	conn->cache_state = RXRPC_CONN_CLIENT_WAITING;
 	list_move_tail(&conn->cache_link, &rxrpc_waiting_client_conns);
 	goto out_unlock;
@@ -524,6 +543,8 @@ static void rxrpc_activate_one_channel(struct rxrpc_connection *conn,
 					     struct rxrpc_call, chan_wait_link);
 	u32 call_id = chan->call_counter + 1;
 
+	trace_rxrpc_client(conn, channel, rxrpc_client_chan_activate);
+
 	write_lock_bh(&call->state_lock);
 	call->state = RXRPC_CALL_CLIENT_SEND_REQUEST;
 	write_unlock_bh(&call->state_lock);
@@ -563,6 +584,8 @@ static void rxrpc_activate_channels(struct rxrpc_connection *conn)
 
 	_enter("%d", conn->debug_id);
 
+	trace_rxrpc_client(conn, -1, rxrpc_client_activate_chans);
+
 	if (conn->cache_state != RXRPC_CONN_CLIENT_ACTIVE ||
 	    conn->active_chans == RXRPC_ACTIVE_CHANS_MASK)
 		return;
@@ -657,10 +680,13 @@ int rxrpc_connect_call(struct rxrpc_call *call,
  * had a chance at re-use (the per-connection security negotiation is
  * expensive).
  */
-static void rxrpc_expose_client_conn(struct rxrpc_connection *conn)
+static void rxrpc_expose_client_conn(struct rxrpc_connection *conn,
+				     unsigned int channel)
 {
-	if (!test_and_set_bit(RXRPC_CONN_EXPOSED, &conn->flags))
+	if (!test_and_set_bit(RXRPC_CONN_EXPOSED, &conn->flags)) {
+		trace_rxrpc_client(conn, channel, rxrpc_client_exposed);
 		rxrpc_get_connection(conn);
+	}
 }
 
 /*
@@ -669,9 +695,9 @@ static void rxrpc_expose_client_conn(struct rxrpc_connection *conn)
  */
 void rxrpc_expose_client_call(struct rxrpc_call *call)
 {
+	unsigned int channel = call->cid & RXRPC_CHANNELMASK;
 	struct rxrpc_connection *conn = call->conn;
-	struct rxrpc_channel *chan =
-		&conn->channels[call->cid & RXRPC_CHANNELMASK];
+	struct rxrpc_channel *chan = &conn->channels[channel];
 
 	if (!test_and_set_bit(RXRPC_CALL_EXPOSED, &call->flags)) {
 		/* Mark the call ID as being used.  If the callNumber counter
@@ -682,7 +708,7 @@ void rxrpc_expose_client_call(struct rxrpc_call *call)
 		chan->call_counter++;
 		if (chan->call_counter >= INT_MAX)
 			set_bit(RXRPC_CONN_DONT_REUSE, &conn->flags);
-		rxrpc_expose_client_conn(conn);
+		rxrpc_expose_client_conn(conn, channel);
 	}
 }
 
@@ -695,6 +721,7 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 	struct rxrpc_connection *conn = call->conn;
 	struct rxrpc_channel *chan = &conn->channels[channel];
 
+	trace_rxrpc_client(conn, channel, rxrpc_client_chan_disconnect);
 	call->conn = NULL;
 
 	spin_lock(&conn->channel_lock);
@@ -709,6 +736,8 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 		ASSERT(!test_bit(RXRPC_CALL_EXPOSED, &call->flags));
 		list_del_init(&call->chan_wait_link);
 
+		trace_rxrpc_client(conn, channel, rxrpc_client_chan_unstarted);
+
 		/* We must deactivate or idle the connection if it's now
 		 * waiting for nothing.
 		 */
@@ -739,7 +768,7 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 	/* See if we can pass the channel directly to another call. */
 	if (conn->cache_state == RXRPC_CONN_CLIENT_ACTIVE &&
 	    !list_empty(&conn->waiting_calls)) {
-		_debug("pass chan");
+		trace_rxrpc_client(conn, channel, rxrpc_client_chan_pass);
 		rxrpc_activate_one_channel(conn, channel);
 		goto out_2;
 	}
@@ -762,7 +791,7 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 			goto out;
 		}
 
-		_debug("pass chan 2");
+		trace_rxrpc_client(conn, channel, rxrpc_client_chan_pass);
 		rxrpc_activate_one_channel(conn, channel);
 		goto out;
 
@@ -794,7 +823,7 @@ idle_connection:
 	 * immediately or moved to the idle list for a short while.
 	 */
 	if (test_bit(RXRPC_CONN_EXPOSED, &conn->flags)) {
-		_debug("make idle");
+		trace_rxrpc_client(conn, channel, rxrpc_client_to_idle);
 		conn->idle_timestamp = jiffies;
 		conn->cache_state = RXRPC_CONN_CLIENT_IDLE;
 		list_move_tail(&conn->cache_link, &rxrpc_idle_client_conns);
@@ -804,7 +833,7 @@ idle_connection:
 					   &rxrpc_client_conn_reap,
 					   rxrpc_conn_idle_client_expiry);
 	} else {
-		_debug("make inactive");
+		trace_rxrpc_client(conn, channel, rxrpc_client_to_inactive);
 		conn->cache_state = RXRPC_CONN_CLIENT_INACTIVE;
 		list_del_init(&conn->cache_link);
 	}
@@ -821,6 +850,8 @@ rxrpc_put_one_client_conn(struct rxrpc_connection *conn)
 	struct rxrpc_local *local = conn->params.local;
 	unsigned int nr_conns;
 
+	trace_rxrpc_client(conn, -1, rxrpc_client_cleanup);
+
 	if (test_bit(RXRPC_CONN_IN_CLIENT_CONNS, &conn->flags)) {
 		spin_lock(&local->client_conns_lock);
 		if (test_and_clear_bit(RXRPC_CONN_IN_CLIENT_CONNS,
@@ -834,6 +865,7 @@ rxrpc_put_one_client_conn(struct rxrpc_connection *conn)
 	ASSERTCMP(conn->cache_state, ==, RXRPC_CONN_CLIENT_INACTIVE);
 
 	if (test_bit(RXRPC_CONN_COUNTED, &conn->flags)) {
+		trace_rxrpc_client(conn, -1, rxrpc_client_uncount);
 		spin_lock(&rxrpc_client_conn_cache_lock);
 		nr_conns = --rxrpc_nr_client_conns;
 
@@ -863,20 +895,18 @@ rxrpc_put_one_client_conn(struct rxrpc_connection *conn)
  */
 void rxrpc_put_client_conn(struct rxrpc_connection *conn)
 {
-	struct rxrpc_connection *next;
+	const void *here = __builtin_return_address(0);
+	int n;
 
 	do {
-		_enter("%p{u=%d,d=%d}",
-		       conn, atomic_read(&conn->usage), conn->debug_id);
-
-		next = rxrpc_put_one_client_conn(conn);
-
-		if (!next)
-			break;
-		conn = next;
-	} while (atomic_dec_and_test(&conn->usage));
-
-	_leave("");
+		n = atomic_dec_return(&conn->usage);
+		trace_rxrpc_conn(conn, rxrpc_conn_put_client, n, here);
+		if (n > 0)
+			return;
+		ASSERTCMP(n, >=, 0);
+
+		conn = rxrpc_put_one_client_conn(conn);
+	} while (conn);
 }
 
 /*
@@ -907,9 +937,11 @@ static void rxrpc_cull_active_client_conns(void)
 		ASSERTCMP(conn->cache_state, ==, RXRPC_CONN_CLIENT_ACTIVE);
 
 		if (list_empty(&conn->waiting_calls)) {
+			trace_rxrpc_client(conn, -1, rxrpc_client_to_culled);
 			conn->cache_state = RXRPC_CONN_CLIENT_CULLED;
 			list_del_init(&conn->cache_link);
 		} else {
+			trace_rxrpc_client(conn, -1, rxrpc_client_to_waiting);
 			conn->cache_state = RXRPC_CONN_CLIENT_WAITING;
 			list_move_tail(&conn->cache_link,
 				       &rxrpc_waiting_client_conns);
@@ -983,7 +1015,7 @@ next:
 			goto not_yet_expired;
 	}
 
-	_debug("discard conn %d", conn->debug_id);
+	trace_rxrpc_client(conn, -1, rxrpc_client_discard);
 	if (!test_and_clear_bit(RXRPC_CONN_EXPOSED, &conn->flags))
 		BUG();
 	conn->cache_state = RXRPC_CONN_CLIENT_INACTIVE;
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 0691007cfc02..a43f4c94a88d 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -377,7 +377,7 @@ void rxrpc_process_connection(struct work_struct *work)
 	u32 abort_code = RX_PROTOCOL_ERROR;
 	int ret;
 
-	_enter("{%d}", conn->debug_id);
+	rxrpc_see_connection(conn);
 
 	if (test_and_clear_bit(RXRPC_CONN_EV_CHALLENGE, &conn->events))
 		rxrpc_secure_connection(conn);
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index bb1f29280aea..3b55aee0c436 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -246,11 +246,77 @@ void rxrpc_kill_connection(struct rxrpc_connection *conn)
 }
 
 /*
- * release a virtual connection
+ * Queue a connection's work processor, getting a ref to pass to the work
+ * queue.
  */
-void __rxrpc_put_connection(struct rxrpc_connection *conn)
+bool rxrpc_queue_conn(struct rxrpc_connection *conn)
 {
-	rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
+	const void *here = __builtin_return_address(0);
+	int n = __atomic_add_unless(&conn->usage, 1, 0);
+	if (n == 0)
+		return false;
+	if (rxrpc_queue_work(&conn->processor))
+		trace_rxrpc_conn(conn, rxrpc_conn_queued, n + 1, here);
+	else
+		rxrpc_put_connection(conn);
+	return true;
+}
+
+/*
+ * Note the re-emergence of a connection.
+ */
+void rxrpc_see_connection(struct rxrpc_connection *conn)
+{
+	const void *here = __builtin_return_address(0);
+	if (conn) {
+		int n = atomic_read(&conn->usage);
+
+		trace_rxrpc_conn(conn, rxrpc_conn_seen, n, here);
+	}
+}
+
+/*
+ * Get a ref on a connection.
+ */
+void rxrpc_get_connection(struct rxrpc_connection *conn)
+{
+	const void *here = __builtin_return_address(0);
+	int n = atomic_inc_return(&conn->usage);
+
+	trace_rxrpc_conn(conn, rxrpc_conn_got, n, here);
+}
+
+/*
+ * Try to get a ref on a connection.
+ */
+struct rxrpc_connection *
+rxrpc_get_connection_maybe(struct rxrpc_connection *conn)
+{
+	const void *here = __builtin_return_address(0);
+
+	if (conn) {
+		int n = __atomic_add_unless(&conn->usage, 1, 0);
+		if (n > 0)
+			trace_rxrpc_conn(conn, rxrpc_conn_got, n + 1, here);
+		else
+			conn = NULL;
+	}
+	return conn;
+}
+
+/*
+ * Release a service connection
+ */
+void rxrpc_put_service_conn(struct rxrpc_connection *conn)
+{
+	const void *here = __builtin_return_address(0);
+	int n;
+
+	n = atomic_dec_return(&conn->usage);
+	trace_rxrpc_conn(conn, rxrpc_conn_put_service, n, here);
+	ASSERTCMP(n, >=, 0);
+	if (n == 0)
+		rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
 }
 
 /*
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index 83d54da4ce8b..eef551f40dc2 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -136,6 +136,10 @@ struct rxrpc_connection *rxrpc_prealloc_service_connection(gfp_t gfp)
 		list_add_tail(&conn->link, &rxrpc_connections);
 		list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
 		write_unlock(&rxrpc_connection_lock);
+
+		trace_rxrpc_conn(conn, rxrpc_conn_new_service,
+				 atomic_read(&conn->usage),
+				 __builtin_return_address(0));
 	}
 
 	return conn;
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 8b910780f1ac..598064d3bdd2 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -101,3 +101,34 @@ const char *rxrpc_acks(u8 reason)
 		reason = ARRAY_SIZE(str) - 1;
 	return str[reason];
 }
+
+const char rxrpc_conn_traces[rxrpc_conn__nr_trace][4] = {
+	[rxrpc_conn_new_client]		= "NWc",
+	[rxrpc_conn_new_service]	= "NWs",
+	[rxrpc_conn_queued]		= "QUE",
+	[rxrpc_conn_seen]		= "SEE",
+	[rxrpc_conn_got]		= "GOT",
+	[rxrpc_conn_put_client]		= "PTc",
+	[rxrpc_conn_put_service]	= "PTs",
+};
+
+const char rxrpc_client_traces[rxrpc_client__nr_trace][7] = {
+	[rxrpc_client_activate_chans]	= "Activa",
+	[rxrpc_client_alloc]		= "Alloc ",
+	[rxrpc_client_chan_activate]	= "ChActv",
+	[rxrpc_client_chan_disconnect]	= "ChDisc",
+	[rxrpc_client_chan_pass]	= "ChPass",
+	[rxrpc_client_chan_unstarted]	= "ChUnst",
+	[rxrpc_client_cleanup]		= "Clean ",
+	[rxrpc_client_count]		= "Count ",
+	[rxrpc_client_discard]		= "Discar",
+	[rxrpc_client_duplicate]	= "Duplic",
+	[rxrpc_client_exposed]		= "Expose",
+	[rxrpc_client_replace]		= "Replac",
+	[rxrpc_client_to_active]	= "->Actv",
+	[rxrpc_client_to_culled]	= "->Cull",
+	[rxrpc_client_to_idle]		= "->Idle",
+	[rxrpc_client_to_inactive]	= "->Inac",
+	[rxrpc_client_to_waiting]	= "->Wait",
+	[rxrpc_client_uncount]		= "Uncoun",
+};
