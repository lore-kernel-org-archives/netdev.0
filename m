From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 14/24] rxrpc: Call channels should have separate
 call number spaces
Date: Tue, 05 Jul 2016 14:13:51 +0100
Message-ID: <146772443102.21657.5361035720001741672.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Each channel on a connection has a separate, independent number space from
which to allocate callNumber values.  It is entirely possible, for example,
to have a connection with four active calls, each with call number 1.

Note that the callNumber values for any particular channel don't have to
start at 1, but they are supposed to increment monotonically for that
channel from a client's perspective and may not be reused once the call
number is transmitted (until the epoch cycles all the way back round).

Currently, however, call numbers are allocated on a per-connection basis
and, further, are held in an rb-tree.  The rb-tree is redundant as the four
channel pointers in the rxrpc_connection struct are entirely capable of
pointing to all the calls currently in progress on a connection.

To this end, make the following changes:

 (1) Handle call number allocation independently per channel.

 (2) Get rid of the conn->calls rb-tree.  This is overkill as a connection
     may have a maximum of four calls in progress at any one time.  Use the
     pointers in the channels[] array instead, indexed by the channel
     number from the packet.

 (3) For each channel, save the result of the last call that was in
     progress on that channel in conn->channels[] so that the final ACK or
     ABORT packet can be replayed if necessary.  Any call earlier than that
     is just ignored.  If we've seen the next call number in a packet, the
     last one is most definitely defunct.

 (4) When generating a RESPONSE packet for a connection, the call number
     counter for each channel must be included in it.

 (5) When parsing a RESPONSE packet for a connection, the call number
     counters contained therein should be used to set the minimum expected
     call numbers on each channel.

To do in future commits:

 (1) Replay terminal packets based on the last call stored in
     conn->channels[].

 (2) Connections should be retired before the callNumber space on any
     channel runs out.

 (3) A server is expected to disregard or reject any new incoming call that
     has a call number less than the current call number counter.  The call
     number counter for that channel must be advanced to the new call
     number.

     Note that the server cannot just require that the next call that it
     sees on a channel be exactly the call number counter + 1 because then
     there's a scenario that could cause a problem: The client transmits a
     packet to initiate a connection, the network goes out, the server
     sends an ACK (which gets lost), the client sends an ABORT (which also
     gets lost); the network then reconnects, the client then reuses the
     call number for the next call (it doesn't know the server already saw
     the call number), but the server thinks it already has the first
     packet of this call (it doesn't know that the client doesn't know that
     it saw the call number the first time).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   14 +++++----
 net/rxrpc/call_object.c |   60 ++++++++++++++-----------------------
 net/rxrpc/conn_event.c  |   24 ++++++++-------
 net/rxrpc/conn_object.c |   77 ++++++++++++++++++-----------------------------
 net/rxrpc/proc.c        |    5 +--
 net/rxrpc/rxkad.c       |   41 ++++++++++++++++---------
 6 files changed, 104 insertions(+), 117 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ea45f1fc4ded..3685d99f2671 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -292,7 +292,14 @@ struct rxrpc_connection {
 	struct rxrpc_conn_parameters params;
 
 	spinlock_t		channel_lock;
-	struct rxrpc_call __rcu	*channels[RXRPC_MAXCALLS]; /* active calls */
+
+	struct rxrpc_channel {
+		struct rxrpc_call __rcu	*call;		/* Active call */
+		u32			call_id;	/* ID of current call */
+		u32			call_counter;	/* Call ID counter */
+		u32			last_call;	/* ID of last call */
+		u32			last_result;	/* Result of last call (0/abort) */
+	} channels[RXRPC_MAXCALLS];
 	wait_queue_head_t	channel_wq;	/* queue to wait for channel to become available */
 
 	struct rcu_head		rcu;
@@ -303,7 +310,6 @@ struct rxrpc_connection {
 	};
 	struct list_head	proc_link;	/* link in procfs list */
 	struct list_head	link;		/* link in master connection list */
-	struct rb_root		calls;		/* calls on this connection */
 	struct sk_buff_head	rx_queue;	/* received conn-level packets */
 	const struct rxrpc_security *security;	/* applied security module */
 	struct key		*server_key;	/* security for this service */
@@ -312,7 +318,6 @@ struct rxrpc_connection {
 	unsigned long		flags;
 	unsigned long		events;
 	unsigned long		put_time;	/* Time at which last put */
-	rwlock_t		lock;		/* access lock */
 	spinlock_t		state_lock;	/* state-change lock */
 	atomic_t		usage;
 	enum rxrpc_conn_proto_state state : 8;	/* current state of connection */
@@ -320,7 +325,6 @@ struct rxrpc_connection {
 	u32			remote_abort;	/* remote abort code */
 	int			error;		/* local error incurred */
 	int			debug_id;	/* debug ID for printks */
-	unsigned int		call_counter;	/* call ID counter */
 	atomic_t		serial;		/* packet serial number counter */
 	atomic_t		hi_serial;	/* highest serial number received */
 	atomic_t		avail_chans;	/* number of channels available */
@@ -413,7 +417,6 @@ struct rxrpc_call {
 	struct hlist_node	error_link;	/* link in error distribution list */
 	struct list_head	accept_link;	/* calls awaiting acceptance */
 	struct rb_node		sock_node;	/* node in socket call tree */
-	struct rb_node		conn_node;	/* node in connection call tree */
 	struct sk_buff_head	rx_queue;	/* received packets */
 	struct sk_buff_head	rx_oos_queue;	/* packets received out of sequence */
 	struct sk_buff		*tx_pending;	/* Tx socket buffer being filled */
@@ -565,6 +568,7 @@ int rxrpc_connect_call(struct rxrpc_call *, struct rxrpc_conn_parameters *,
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *,
 					       struct rxrpc_peer *,
 					       struct sk_buff *);
+void __rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_put_connection(struct rxrpc_connection *);
 void __exit rxrpc_destroy_all_connections(void);
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 2c6c57c0d52c..3f278721269e 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -456,8 +456,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_call *call, *candidate;
-	struct rb_node **p, *parent;
-	u32 call_id;
+	u32 call_id, chan;
 
 	_enter(",%d", conn->debug_id);
 
@@ -467,21 +466,23 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	if (!candidate)
 		return ERR_PTR(-EBUSY);
 
+	chan = sp->hdr.cid & RXRPC_CHANNELMASK;
 	candidate->socket	= rx;
 	candidate->conn		= conn;
 	candidate->cid		= sp->hdr.cid;
 	candidate->call_id	= sp->hdr.callNumber;
-	candidate->channel	= sp->hdr.cid & RXRPC_CHANNELMASK;
+	candidate->channel	= chan;
 	candidate->rx_data_post	= 0;
 	candidate->state	= RXRPC_CALL_SERVER_ACCEPTING;
 	if (conn->security_ix > 0)
 		candidate->state = RXRPC_CALL_SERVER_SECURING;
 
-	write_lock_bh(&conn->lock);
+	spin_lock(&conn->channel_lock);
 
 	/* set the channel for this call */
-	call = rcu_dereference_protected(conn->channels[candidate->channel],
-					 lockdep_is_held(&conn->lock));
+	call = rcu_dereference_protected(conn->channels[chan].call,
+					 lockdep_is_held(&conn->channel_lock));
+
 	_debug("channel[%u] is %p", candidate->channel, call);
 	if (call && call->call_id == sp->hdr.callNumber) {
 		/* already set; must've been a duplicate packet */
@@ -510,9 +511,9 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 		       call->debug_id, rxrpc_call_states[call->state]);
 
 		if (call->state >= RXRPC_CALL_COMPLETE) {
-			conn->channels[call->channel] = NULL;
+			__rxrpc_disconnect_call(call);
 		} else {
-			write_unlock_bh(&conn->lock);
+			spin_unlock(&conn->channel_lock);
 			kmem_cache_free(rxrpc_call_jar, candidate);
 			_leave(" = -EBUSY");
 			return ERR_PTR(-EBUSY);
@@ -522,33 +523,22 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	/* check the call number isn't duplicate */
 	_debug("check dup");
 	call_id = sp->hdr.callNumber;
-	p = &conn->calls.rb_node;
-	parent = NULL;
-	while (*p) {
-		parent = *p;
-		call = rb_entry(parent, struct rxrpc_call, conn_node);
-
-		/* The tree is sorted in order of the __be32 value without
-		 * turning it into host order.
-		 */
-		if (call_id < call->call_id)
-			p = &(*p)->rb_left;
-		else if (call_id > call->call_id)
-			p = &(*p)->rb_right;
-		else
-			goto old_call;
-	}
+
+	/* We just ignore calls prior to the current call ID.  Terminated calls
+	 * are handled via the connection.
+	 */
+	if (call_id <= conn->channels[chan].call_counter)
+		goto old_call; /* TODO: Just drop packet */
 
 	/* make the call available */
 	_debug("new call");
 	call = candidate;
 	candidate = NULL;
-	rb_link_node(&call->conn_node, parent, p);
-	rb_insert_color(&call->conn_node, &conn->calls);
-	rcu_assign_pointer(conn->channels[call->channel], call);
+	conn->channels[chan].call_counter = call_id;
+	rcu_assign_pointer(conn->channels[chan].call, call);
 	sock_hold(&rx->sk);
 	rxrpc_get_connection(conn);
-	write_unlock_bh(&conn->lock);
+	spin_unlock(&conn->channel_lock);
 
 	spin_lock(&conn->params.peer->lock);
 	hlist_add_head(&call->error_link, &conn->params.peer->error_targets);
@@ -588,19 +578,19 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	return call;
 
 extant_call:
-	write_unlock_bh(&conn->lock);
+	spin_unlock(&conn->channel_lock);
 	kmem_cache_free(rxrpc_call_jar, candidate);
 	_leave(" = %p {%d} [extant]", call, call ? call->debug_id : -1);
 	return call;
 
 aborted_call:
-	write_unlock_bh(&conn->lock);
+	spin_unlock(&conn->channel_lock);
 	kmem_cache_free(rxrpc_call_jar, candidate);
 	_leave(" = -ECONNABORTED");
 	return ERR_PTR(-ECONNABORTED);
 
 old_call:
-	write_unlock_bh(&conn->lock);
+	spin_unlock(&conn->channel_lock);
 	kmem_cache_free(rxrpc_call_jar, candidate);
 	_leave(" = -ECONNRESET [old]");
 	return ERR_PTR(-ECONNRESET);
@@ -648,8 +638,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	write_unlock_bh(&rx->call_lock);
 
 	/* free up the channel for reuse */
-	write_lock_bh(&conn->lock);
-	write_lock(&call->state_lock);
+	write_lock_bh(&call->state_lock);
 
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    call->state != RXRPC_CALL_CLIENT_FINAL_ACK) {
@@ -657,10 +646,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->local_abort = RX_CALL_DEAD;
 	}
-	write_unlock(&call->state_lock);
-
-	rb_erase(&call->conn_node, &conn->calls);
-	write_unlock_bh(&conn->lock);
+	write_unlock_bh(&call->state_lock);
 
 	rxrpc_disconnect_call(call);
 
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index f6ca8c5c4496..cee0f35bc1cf 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -31,15 +31,17 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
 			      u32 abort_code)
 {
 	struct rxrpc_call *call;
-	struct rb_node *p;
+	int i;
 
 	_enter("{%d},%x", conn->debug_id, abort_code);
 
-	read_lock_bh(&conn->lock);
+	spin_lock(&conn->channel_lock);
 
-	for (p = rb_first(&conn->calls); p; p = rb_next(p)) {
-		call = rb_entry(p, struct rxrpc_call, conn_node);
-		write_lock(&call->state_lock);
+	for (i = 0; i < RXRPC_MAXCALLS; i++) {
+		call = rcu_dereference_protected(
+			conn->channels[i].call,
+			lockdep_is_held(&conn->channel_lock));
+		write_lock_bh(&call->state_lock);
 		if (call->state <= RXRPC_CALL_COMPLETE) {
 			call->state = state;
 			if (state == RXRPC_CALL_LOCALLY_ABORTED) {
@@ -51,10 +53,10 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
 			}
 			rxrpc_queue_call(call);
 		}
-		write_unlock(&call->state_lock);
+		write_unlock_bh(&call->state_lock);
 	}
 
-	read_unlock_bh(&conn->lock);
+	spin_unlock(&conn->channel_lock);
 	_leave("");
 }
 
@@ -192,7 +194,7 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		if (ret < 0)
 			return ret;
 
-		read_lock_bh(&conn->lock);
+		spin_lock(&conn->channel_lock);
 		spin_lock(&conn->state_lock);
 
 		if (conn->state == RXRPC_CONN_SERVICE_CHALLENGING) {
@@ -200,12 +202,12 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 			for (loop = 0; loop < RXRPC_MAXCALLS; loop++)
 				rxrpc_call_is_secure(
 					rcu_dereference_protected(
-						conn->channels[loop],
-						lockdep_is_held(&conn->lock)));
+						conn->channels[loop].call,
+						lockdep_is_held(&conn->channel_lock)));
 		}
 
 		spin_unlock(&conn->state_lock);
-		read_unlock_bh(&conn->lock);
+		spin_unlock(&conn->channel_lock);
 		return 0;
 
 	default:
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 8d14dc9c5174..fcc6d2421a37 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -48,10 +48,8 @@ static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 		INIT_WORK(&conn->processor, &rxrpc_process_connection);
 		INIT_LIST_HEAD(&conn->proc_link);
 		INIT_LIST_HEAD(&conn->link);
-		conn->calls = RB_ROOT;
 		skb_queue_head_init(&conn->rx_queue);
 		conn->security = &rxrpc_no_security;
-		rwlock_init(&conn->lock);
 		spin_lock_init(&conn->state_lock);
 		atomic_set(&conn->usage, 1);
 		conn->debug_id = atomic_inc_return(&rxrpc_debug_id);
@@ -65,39 +63,6 @@ static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 }
 
 /*
- * add a call to a connection's call-by-ID tree
- */
-static void rxrpc_add_call_ID_to_conn(struct rxrpc_connection *conn,
-				      struct rxrpc_call *call)
-{
-	struct rxrpc_call *xcall;
-	struct rb_node *parent, **p;
-	u32 call_id;
-
-	write_lock_bh(&conn->lock);
-
-	call_id = call->call_id;
-	p = &conn->calls.rb_node;
-	parent = NULL;
-	while (*p) {
-		parent = *p;
-		xcall = rb_entry(parent, struct rxrpc_call, conn_node);
-
-		if (call_id < xcall->call_id)
-			p = &(*p)->rb_left;
-		else if (call_id > xcall->call_id)
-			p = &(*p)->rb_right;
-		else
-			BUG();
-	}
-
-	rb_link_node(&call->conn_node, parent, p);
-	rb_insert_color(&call->conn_node, &conn->calls);
-
-	write_unlock_bh(&conn->lock);
-}
-
-/*
  * Allocate a client connection.  The caller must take care to clear any
  * padding bytes in *cp.
  */
@@ -280,12 +245,12 @@ found_channel:
 	call->channel	= chan;
 	call->epoch	= conn->proto.epoch;
 	call->cid	= conn->proto.cid | chan;
-	call->call_id	= ++conn->call_counter;
-	rcu_assign_pointer(conn->channels[chan], call);
+	call->call_id	= ++conn->channels[chan].call_counter;
+	conn->channels[chan].call_id = call->call_id;
+	rcu_assign_pointer(conn->channels[chan].call, call);
 
 	_net("CONNECT call %d on conn %d", call->debug_id, conn->debug_id);
 
-	rxrpc_add_call_ID_to_conn(conn, call);
 	spin_unlock(&conn->channel_lock);
 	rxrpc_put_peer(cp->peer);
 	cp->peer = NULL;
@@ -329,7 +294,7 @@ found_extant_conn:
 	spin_lock(&conn->channel_lock);
 
 	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
-		if (!conn->channels[chan])
+		if (!conn->channels[chan].call)
 			goto found_channel;
 	BUG();
 
@@ -534,28 +499,47 @@ found:
 
 /*
  * Disconnect a call and clear any channel it occupies when that call
- * terminates.
+ * terminates.  The caller must hold the channel_lock and must release the
+ * call's ref on the connection.
  */
-void rxrpc_disconnect_call(struct rxrpc_call *call)
+void __rxrpc_disconnect_call(struct rxrpc_call *call)
 {
 	struct rxrpc_connection *conn = call->conn;
-	unsigned chan = call->channel;
+	struct rxrpc_channel *chan = &conn->channels[call->channel];
 
 	_enter("%d,%d", conn->debug_id, call->channel);
 
-	spin_lock(&conn->channel_lock);
+	if (rcu_access_pointer(chan->call) == call) {
+		/* Save the result of the call so that we can repeat it if necessary
+		 * through the channel, whilst disposing of the actual call record.
+		 */
+		chan->last_result = call->local_abort;
+		smp_wmb();
+		chan->last_call = chan->call_id;
+		chan->call_id = chan->call_counter;
 
-	if (rcu_access_pointer(conn->channels[chan]) == call) {
-		rcu_assign_pointer(conn->channels[chan], NULL);
+		rcu_assign_pointer(chan->call, NULL);
 		atomic_inc(&conn->avail_chans);
 		wake_up(&conn->channel_wq);
 	}
 
+	_leave("");
+}
+
+/*
+ * Disconnect a call and clear any channel it occupies when that call
+ * terminates.
+ */
+void rxrpc_disconnect_call(struct rxrpc_call *call)
+{
+	struct rxrpc_connection *conn = call->conn;
+
+	spin_lock(&conn->channel_lock);
+	__rxrpc_disconnect_call(call);
 	spin_unlock(&conn->channel_lock);
 
 	call->conn = NULL;
 	rxrpc_put_connection(conn);
-	_leave("");
 }
 
 /*
@@ -594,7 +578,6 @@ static void rxrpc_destroy_connection(struct rcu_head *rcu)
 
 	_net("DESTROY CONN %d", conn->debug_id);
 
-	ASSERT(RB_EMPTY_ROOT(&conn->calls));
 	rxrpc_purge_queue(&conn->rx_queue);
 
 	conn->security->clear(conn);
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index 46d470335263..ed5a94d8be7b 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -136,7 +136,7 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 	if (v == &rxrpc_connection_proc_list) {
 		seq_puts(seq,
 			 "Proto Local                  Remote                "
-			 " SvID ConnID   Calls    End Use State    Key     "
+			 " SvID ConnID   End Use State    Key     "
 			 " Serial   ISerial\n"
 			 );
 		return 0;
@@ -152,13 +152,12 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 		&conn->proto.ipv4_addr, ntohs(conn->proto.port));
 
 	seq_printf(seq,
-		   "UDP   %-22.22s %-22.22s %4x %08x %08x %s %3u"
+		   "UDP   %-22.22s %-22.22s %4x %08x %s %3u"
 		   " %s %08x %08x %08x\n",
 		   lbuff,
 		   rbuff,
 		   conn->params.service_id,
 		   conn->proto.cid,
-		   conn->call_counter,
 		   rxrpc_conn_is_service(conn) ? "Svc" : "Clt",
 		   atomic_read(&conn->usage),
 		   rxrpc_conn_states[conn->state],
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 3acc7c1241d4..63afa9e9cc08 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -767,14 +767,10 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	resp.kvno			= htonl(token->kad->kvno);
 	resp.ticket_len			= htonl(token->kad->ticket_len);
 
-	resp.encrypted.call_id[0] =
-		htonl(conn->channels[0] ? conn->channels[0]->call_id : 0);
-	resp.encrypted.call_id[1] =
-		htonl(conn->channels[1] ? conn->channels[1]->call_id : 0);
-	resp.encrypted.call_id[2] =
-		htonl(conn->channels[2] ? conn->channels[2]->call_id : 0);
-	resp.encrypted.call_id[3] =
-		htonl(conn->channels[3] ? conn->channels[3]->call_id : 0);
+	resp.encrypted.call_id[0] = htonl(conn->channels[0].call_counter);
+	resp.encrypted.call_id[1] = htonl(conn->channels[1].call_counter);
+	resp.encrypted.call_id[2] = htonl(conn->channels[2].call_counter);
+	resp.encrypted.call_id[3] = htonl(conn->channels[3].call_counter);
 
 	/* calculate the response checksum and then do the encryption */
 	rxkad_calc_response_checksum(&resp);
@@ -991,7 +987,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	void *ticket;
 	u32 abort_code, version, kvno, ticket_len, level;
 	__be32 csum;
-	int ret;
+	int ret, i;
 
 	_enter("{%d,%x}", conn->debug_id, key_serial(conn->server_key));
 
@@ -1054,11 +1050,26 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	if (response.encrypted.checksum != csum)
 		goto protocol_error_free;
 
-	if (ntohl(response.encrypted.call_id[0]) > INT_MAX ||
-	    ntohl(response.encrypted.call_id[1]) > INT_MAX ||
-	    ntohl(response.encrypted.call_id[2]) > INT_MAX ||
-	    ntohl(response.encrypted.call_id[3]) > INT_MAX)
-		goto protocol_error_free;
+	spin_lock(&conn->channel_lock);
+	for (i = 0; i < RXRPC_MAXCALLS; i++) {
+		struct rxrpc_call *call;
+		u32 call_id = ntohl(response.encrypted.call_id[i]);
+
+		if (call_id > INT_MAX)
+			goto protocol_error_unlock;
+
+		if (call_id < conn->channels[i].call_counter)
+			goto protocol_error_unlock;
+		if (call_id > conn->channels[i].call_counter) {
+			call = rcu_dereference_protected(
+				conn->channels[i].call,
+				lockdep_is_held(&conn->channel_lock));
+			if (call && call->state < RXRPC_CALL_COMPLETE)
+				goto protocol_error_unlock;
+			conn->channels[i].call_counter = call_id;
+		}
+	}
+	spin_unlock(&conn->channel_lock);
 
 	abort_code = RXKADOUTOFSEQUENCE;
 	if (ntohl(response.encrypted.inc_nonce) != conn->security_nonce + 1)
@@ -1083,6 +1094,8 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	_leave(" = 0");
 	return 0;
 
+protocol_error_unlock:
+	spin_unlock(&conn->channel_lock);
 protocol_error_free:
 	kfree(ticket);
 protocol_error:
