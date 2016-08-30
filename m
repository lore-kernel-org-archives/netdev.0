From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/8] rxrpc: Trace rxrpc_call usage
Date: Tue, 30 Aug 2016 16:41:58 +0100
Message-ID: <147257171821.6391.3596629632725907207.stgit@warthog.procyon.org.uk>
References: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a trace event for debuging rxrpc_call struct usage.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   39 ++++++++++++++++++
 net/rxrpc/ar-internal.h      |   19 ++-------
 net/rxrpc/call_accept.c      |    5 +-
 net/rxrpc/call_event.c       |   11 ++---
 net/rxrpc/call_object.c      |   90 +++++++++++++++++++++++++++++++++++++++---
 net/rxrpc/conn_client.c      |    1 
 net/rxrpc/conn_event.c       |    1 
 net/rxrpc/input.c            |    4 +-
 net/rxrpc/output.c           |    1 
 net/rxrpc/peer_event.c       |    1 
 net/rxrpc/recvmsg.c          |    1 
 net/rxrpc/skbuff.c           |    4 --
 12 files changed, 143 insertions(+), 34 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 15283ee3e41a..cbe574ea674b 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -16,6 +16,45 @@
 
 #include <linux/tracepoint.h>
 
+TRACE_EVENT(rxrpc_call,
+	    TP_PROTO(struct rxrpc_call *call, int op, int usage, int nskb,
+		     const void *where, const void *aux),
+
+	    TP_ARGS(call, op, usage, nskb, where, aux),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(int,			op		)
+		    __field(int,			usage		)
+		    __field(int,			nskb		)
+		    __field(const void *,		where		)
+		    __field(const void *,		aux		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->op = op;
+		    __entry->usage = usage;
+		    __entry->nskb = nskb;
+		    __entry->where = where;
+		    __entry->aux = aux;
+			   ),
+
+	    TP_printk("c=%p %s u=%d s=%d p=%pSR a=%p",
+		      __entry->call,
+		      (__entry->op == 0 ? "NWc" :
+		       __entry->op == 1 ? "NWs" :
+		       __entry->op == 2 ? "SEE" :
+		       __entry->op == 3 ? "GET" :
+		       __entry->op == 4 ? "Gsb" :
+		       __entry->op == 5 ? "PUT" :
+		       "Psb"),
+		      __entry->usage,
+		      __entry->nskb,
+		      __entry->where,
+		      __entry->aux)
+	    );
+
 TRACE_EVENT(rxrpc_skb,
 	    TP_PROTO(struct sk_buff *skb, int op, int usage, int mod_count,
 		     const void *where),
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ce6afd931e91..0c320b2b7b43 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -543,7 +543,11 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
 				       struct sk_buff *);
 void rxrpc_release_call(struct rxrpc_call *);
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
-void __rxrpc_put_call(struct rxrpc_call *);
+void rxrpc_see_call(struct rxrpc_call *);
+void rxrpc_get_call(struct rxrpc_call *);
+void rxrpc_put_call(struct rxrpc_call *);
+void rxrpc_get_call_for_skb(struct rxrpc_call *, struct sk_buff *);
+void rxrpc_put_call_for_skb(struct rxrpc_call *, struct sk_buff *);
 void __exit rxrpc_destroy_all_calls(void);
 
 static inline bool rxrpc_is_service_call(const struct rxrpc_call *call)
@@ -1022,16 +1026,3 @@ do {						\
 } while (0)
 
 #endif /* __KDEBUGALL */
-
-
-#define rxrpc_get_call(CALL)				\
-do {							\
-	CHECK_SLAB_OKAY(&(CALL)->usage);		\
-	if (atomic_inc_return(&(CALL)->usage) == 1)	\
-		BUG();					\
-} while (0)
-
-#define rxrpc_put_call(CALL)				\
-do {							\
-	__rxrpc_put_call(CALL);				\
-} while (0)
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index ef9ef0d6c917..03af88fe798b 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -129,8 +129,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 			_debug("conn ready");
 			call->state = RXRPC_CALL_SERVER_ACCEPTING;
 			list_add_tail(&call->accept_link, &rx->acceptq);
-			rxrpc_get_call(call);
-			atomic_inc(&call->skb_count);
+			rxrpc_get_call_for_skb(call, notification);
 			nsp = rxrpc_skb(notification);
 			nsp->call = call;
 
@@ -323,6 +322,7 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	call = list_entry(rx->acceptq.next, struct rxrpc_call, accept_link);
 	list_del_init(&call->accept_link);
 	sk_acceptq_removed(&rx->sk);
+	rxrpc_see_call(call);
 
 	write_lock_bh(&call->state_lock);
 	switch (call->state) {
@@ -395,6 +395,7 @@ int rxrpc_reject_call(struct rxrpc_sock *rx)
 	call = list_entry(rx->acceptq.next, struct rxrpc_call, accept_link);
 	list_del_init(&call->accept_link);
 	sk_acceptq_removed(&rx->sk);
+	rxrpc_see_call(call);
 
 	write_lock_bh(&call->state_lock);
 	switch (call->state) {
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 94c7751fd99a..02fe4a4b60d9 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -465,8 +465,7 @@ static void rxrpc_insert_oos_packet(struct rxrpc_call *call,
 	skb->destructor = rxrpc_packet_destructor;
 	ASSERTCMP(sp->call, ==, NULL);
 	sp->call = call;
-	rxrpc_get_call(call);
-	atomic_inc(&call->skb_count);
+	rxrpc_get_call_for_skb(call, skb);
 
 	/* insert into the buffer in sequence order */
 	spin_lock_bh(&call->lock);
@@ -741,8 +740,7 @@ all_acked:
 		_debug("post ACK");
 		skb->mark = RXRPC_SKB_MARK_FINAL_ACK;
 		sp->call = call;
-		rxrpc_get_call(call);
-		atomic_inc(&call->skb_count);
+		rxrpc_get_call_for_skb(call, skb);
 		spin_lock_bh(&call->lock);
 		if (rxrpc_queue_rcv_skb(call, skb, true, true) < 0)
 			BUG();
@@ -801,8 +799,7 @@ static int rxrpc_post_message(struct rxrpc_call *call, u32 mark, u32 error,
 		memset(sp, 0, sizeof(*sp));
 		sp->error = error;
 		sp->call = call;
-		rxrpc_get_call(call);
-		atomic_inc(&call->skb_count);
+		rxrpc_get_call_for_skb(call, skb);
 
 		spin_lock_bh(&call->lock);
 		ret = rxrpc_queue_rcv_skb(call, skb, true, fatal);
@@ -834,6 +831,8 @@ void rxrpc_process_call(struct work_struct *work)
 	u32 serial, abort_code = RX_PROTOCOL_ERROR;
 	u8 *acks = NULL;
 
+	rxrpc_see_call(call);
+
 	//printk("\n--------------------\n");
 	_enter("{%d,%s,%lx} [%lu]",
 	       call->debug_id, rxrpc_call_states[call->state], call->events,
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 852c30dc7b75..104ee8b1de06 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -219,6 +219,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 {
 	struct rxrpc_call *call, *xcall;
 	struct rb_node *parent, **pp;
+	const void *here = __builtin_return_address(0);
 	int ret;
 
 	_enter("%p,%lx", rx, user_call_ID);
@@ -229,6 +230,9 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 		return call;
 	}
 
+	trace_rxrpc_call(call, 0, atomic_read(&call->usage), 0, here,
+			 (const void *)user_call_ID);
+
 	/* Publish the call, even though it is incompletely set up as yet */
 	call->user_call_ID = user_call_ID;
 	__set_bit(RXRPC_CALL_HAS_USERID, &call->flags);
@@ -308,6 +312,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_call *call, *candidate;
+	const void *here = __builtin_return_address(0);
 	u32 call_id, chan;
 
 	_enter(",%d", conn->debug_id);
@@ -318,6 +323,9 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	if (!candidate)
 		return ERR_PTR(-EBUSY);
 
+	trace_rxrpc_call(candidate, 1, atomic_read(&candidate->usage),
+			 0, here, NULL);
+
 	chan = sp->hdr.cid & RXRPC_CHANNELMASK;
 	candidate->socket	= rx;
 	candidate->conn		= conn;
@@ -431,6 +439,44 @@ old_call:
 }
 
 /*
+ * Note the re-emergence of a call.
+ */
+void rxrpc_see_call(struct rxrpc_call *call)
+{
+	const void *here = __builtin_return_address(0);
+	if (call) {
+		int n = atomic_read(&call->usage);
+		int m = atomic_read(&call->skb_count);
+
+		trace_rxrpc_call(call, 2, n, m, here, 0);
+	}
+}
+
+/*
+ * Note the addition of a ref on a call.
+ */
+void rxrpc_get_call(struct rxrpc_call *call)
+{
+	const void *here = __builtin_return_address(0);
+	int n = atomic_inc_return(&call->usage);
+	int m = atomic_read(&call->skb_count);
+
+	trace_rxrpc_call(call, 3, n, m, here, 0);
+}
+
+/*
+ * Note the addition of a ref on a call for a socket buffer.
+ */
+void rxrpc_get_call_for_skb(struct rxrpc_call *call, struct sk_buff *skb)
+{
+	const void *here = __builtin_return_address(0);
+	int n = atomic_inc_return(&call->usage);
+	int m = atomic_inc_return(&call->skb_count);
+
+	trace_rxrpc_call(call, 4, n, m, here, skb);
+}
+
+/*
  * detach a call from a socket and set up for release
  */
 void rxrpc_release_call(struct rxrpc_call *call)
@@ -443,6 +489,8 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	       atomic_read(&call->ackr_not_idle),
 	       call->rx_first_oos);
 
+	rxrpc_see_call(call);
+
 	spin_lock_bh(&call->lock);
 	if (test_and_set_bit(RXRPC_CALL_RELEASED, &call->flags))
 		BUG();
@@ -526,6 +574,7 @@ static void rxrpc_dead_call_expired(unsigned long _call)
 
 	_enter("{%d}", call->debug_id);
 
+	rxrpc_see_call(call);
 	write_lock_bh(&call->state_lock);
 	call->state = RXRPC_CALL_DEAD;
 	write_unlock_bh(&call->state_lock);
@@ -540,6 +589,7 @@ static void rxrpc_mark_call_released(struct rxrpc_call *call)
 {
 	bool sched;
 
+	rxrpc_see_call(call);
 	write_lock(&call->state_lock);
 	if (call->state < RXRPC_CALL_DEAD) {
 		sched = __rxrpc_abort_call(call, RX_CALL_DEAD, ECONNRESET);
@@ -585,21 +635,43 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 /*
  * release a call
  */
-void __rxrpc_put_call(struct rxrpc_call *call)
+void rxrpc_put_call(struct rxrpc_call *call)
 {
-	ASSERT(call != NULL);
+	const void *here = __builtin_return_address(0);
+	int n, m;
 
-	_enter("%p{u=%d}", call, atomic_read(&call->usage));
+	ASSERT(call != NULL);
 
-	ASSERTCMP(atomic_read(&call->usage), >, 0);
+	n = atomic_dec_return(&call->usage);
+	m = atomic_read(&call->skb_count);
+	trace_rxrpc_call(call, 5, n, m, here, NULL);
+	ASSERTCMP(n, >=, 0);
+	if (n == 0) {
+		_debug("call %d dead", call->debug_id);
+		WARN_ON(m != 0);
+		ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
+		rxrpc_queue_work(&call->destroyer);
+	}
+}
 
-	if (atomic_dec_and_test(&call->usage)) {
+/*
+ * Release a call ref held by a socket buffer.
+ */
+void rxrpc_put_call_for_skb(struct rxrpc_call *call, struct sk_buff *skb)
+{
+	const void *here = __builtin_return_address(0);
+	int n, m;
+
+	n = atomic_dec_return(&call->usage);
+	m = atomic_dec_return(&call->skb_count);
+	trace_rxrpc_call(call, 6, n, m, here, skb);
+	ASSERTCMP(n, >=, 0);
+	if (n == 0) {
 		_debug("call %d dead", call->debug_id);
-		WARN_ON(atomic_read(&call->skb_count) != 0);
+		WARN_ON(m != 0);
 		ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
 		rxrpc_queue_work(&call->destroyer);
 	}
-	_leave("");
 }
 
 /*
@@ -705,6 +777,7 @@ void __exit rxrpc_destroy_all_calls(void)
 		call = list_entry(rxrpc_calls.next, struct rxrpc_call, link);
 		_debug("Zapping call %p", call);
 
+		rxrpc_see_call(call);
 		list_del_init(&call->link);
 
 		switch (atomic_read(&call->usage)) {
@@ -748,6 +821,7 @@ static void rxrpc_call_life_expired(unsigned long _call)
 
 	_enter("{%d}", call->debug_id);
 
+	rxrpc_see_call(call);
 	if (call->state >= RXRPC_CALL_COMPLETE)
 		return;
 
@@ -765,6 +839,7 @@ static void rxrpc_resend_time_expired(unsigned long _call)
 
 	_enter("{%d}", call->debug_id);
 
+	rxrpc_see_call(call);
 	if (call->state >= RXRPC_CALL_COMPLETE)
 		return;
 
@@ -782,6 +857,7 @@ static void rxrpc_ack_time_expired(unsigned long _call)
 
 	_enter("{%d}", call->debug_id);
 
+	rxrpc_see_call(call);
 	if (call->state >= RXRPC_CALL_COMPLETE)
 		return;
 
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 44850a2d90b5..4b213bc0f554 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -537,6 +537,7 @@ static void rxrpc_activate_one_channel(struct rxrpc_connection *conn,
 					     struct rxrpc_call, chan_wait_link);
 	u32 call_id = chan->call_counter + 1;
 
+	rxrpc_see_call(call);
 	list_del_init(&call->chan_wait_link);
 	conn->active_chans |= 1 << channel;
 	call->peer	= rxrpc_get_peer(conn->params.peer);
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index bcea99c73b40..bc9b05938ff5 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -157,6 +157,7 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn,
 			conn->channels[i].call,
 			lockdep_is_held(&conn->channel_lock));
 		if (call) {
+			rxrpc_see_call(call);
 			write_lock_bh(&call->state_lock);
 			if (rxrpc_set_call_completion(call, compl, abort_code,
 						      error)) {
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index af49c2992c4a..86bea9ad6c3d 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -196,8 +196,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 		goto enqueue_packet;
 
 	sp->call = call;
-	rxrpc_get_call(call);
-	atomic_inc(&call->skb_count);
+	rxrpc_get_call_for_skb(call, skb);
 	terminal = ((flags & RXRPC_LAST_PACKET) &&
 		    !(flags & RXRPC_CLIENT_INITIATED));
 	ret = rxrpc_queue_rcv_skb(call, skb, false, terminal);
@@ -748,6 +747,7 @@ void rxrpc_data_ready(struct sock *sk)
 		if (!call || atomic_read(&call->usage) == 0)
 			goto cant_route_call;
 
+		rxrpc_see_call(call);
 		rxrpc_post_packet_to_call(call, skb);
 		goto out_unlock;
 	}
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 036e1112b0c5..888fa87ed1d6 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -207,6 +207,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 			return PTR_ERR(call);
 	}
 
+	rxrpc_see_call(call);
 	_debug("CALL %d USR %lx ST %d on CONN %p",
 	       call->debug_id, call->user_call_ID, call->state, call->conn);
 
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 865078d76ad3..27b9ecad007e 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -270,6 +270,7 @@ void rxrpc_peer_error_distributor(struct work_struct *work)
 		call = hlist_entry(peer->error_targets.first,
 				   struct rxrpc_call, error_link);
 		hlist_del_init(&call->error_link);
+		rxrpc_see_call(call);
 
 		queue = false;
 		write_lock(&call->state_lock);
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 96d98a3a7087..c9b38c7fb448 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -115,6 +115,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		sp = rxrpc_skb(skb);
 		call = sp->call;
 		ASSERT(call != NULL);
+		rxrpc_see_call(call);
 
 		_debug("next pkt %s", rxrpc_pkts[sp->hdr.type]);
 
diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index fbd8c74d9505..20529205bb8c 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -140,9 +140,7 @@ void rxrpc_packet_destructor(struct sk_buff *skb)
 	_enter("%p{%p}", skb, call);
 
 	if (call) {
-		if (atomic_dec_return(&call->skb_count) < 0)
-			BUG();
-		rxrpc_put_call(call);
+		rxrpc_put_call_for_skb(call, skb);
 		sp->call = NULL;
 	}
 
