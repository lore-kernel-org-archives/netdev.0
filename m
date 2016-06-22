From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 13/14] rxrpc: Kill the client connection bundle
 concept
Date: Wed, 22 Jun 2016 10:51:15 +0100
Message-ID: <146658907528.4550.8589638624803918837.stgit@warthog.procyon.org.uk>
References: <146658898230.4550.7226255613607733759.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146658898230.4550.7226255613607733759.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kill off the concept of maintaining a bundle of connections to a particular
target service to increase the number of call slots available for any
beyond four for that service (there are four call slots per connection).

This will make cleaning up the connection handling code easier and
facilitate removal of the rxrpc_transport struct.  Bundling can be
reintroduced later if necessary.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c     |   11 -
 net/rxrpc/ar-internal.h  |   54 ++---
 net/rxrpc/call_object.c  |  124 ++++++-----
 net/rxrpc/conn_object.c  |  518 +++++++++++++++-------------------------------
 net/rxrpc/local_object.c |    3 
 net/rxrpc/output.c       |   11 -
 net/rxrpc/transport.c    |    2 
 7 files changed, 260 insertions(+), 463 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 57dcbfc061e4..f3b6ed8196c3 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -276,7 +276,6 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 					   gfp_t gfp)
 {
 	struct rxrpc_conn_parameters cp;
-	struct rxrpc_conn_bundle *bundle;
 	struct rxrpc_transport *trans;
 	struct rxrpc_call *call;
 	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
@@ -311,15 +310,7 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 	}
 	cp.peer = trans->peer;
 
-	bundle = rxrpc_get_bundle(rx, trans, key, srx->srx_service, gfp);
-	if (IS_ERR(bundle)) {
-		call = ERR_CAST(bundle);
-		goto out;
-	}
-
-	call = rxrpc_new_client_call(rx, &cp, trans, bundle, user_call_ID, gfp);
-	rxrpc_put_bundle(trans, bundle);
-out:
+	call = rxrpc_new_client_call(rx, &cp, trans, srx, user_call_ID, gfp);
 	rxrpc_put_transport(trans);
 out_notrans:
 	release_sock(&rx->sk);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index c0ed5e7f22ef..9a0bd153c71b 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -186,7 +186,8 @@ struct rxrpc_local {
 	struct sk_buff_head	accept_queue;	/* incoming calls awaiting acceptance */
 	struct sk_buff_head	reject_queue;	/* packets awaiting rejection */
 	struct sk_buff_head	event_queue;	/* endpoint event packets awaiting processing */
-	struct mutex		conn_lock;	/* Client connection creation lock */
+	struct rb_root		client_conns;	/* Client connections by socket params */
+	spinlock_t		client_conns_lock; /* Lock for client_conns */
 	spinlock_t		lock;		/* access lock */
 	rwlock_t		services_lock;	/* lock for services list */
 	int			debug_id;	/* debug ID for printks */
@@ -232,35 +233,15 @@ struct rxrpc_peer {
 struct rxrpc_transport {
 	struct rxrpc_local	*local;		/* local transport endpoint */
 	struct rxrpc_peer	*peer;		/* remote transport endpoint */
-	struct rb_root		bundles;	/* client connection bundles on this transport */
 	struct rb_root		server_conns;	/* server connections on this transport */
 	struct list_head	link;		/* link in master session list */
 	unsigned long		put_time;	/* time at which to reap */
-	spinlock_t		client_lock;	/* client connection allocation lock */
 	rwlock_t		conn_lock;	/* lock for active/dead connections */
 	atomic_t		usage;
 	int			debug_id;	/* debug ID for printks */
 };
 
 /*
- * RxRPC client connection bundle
- * - matched by { transport, service_id, key }
- */
-struct rxrpc_conn_bundle {
-	struct rb_node		node;		/* node in transport's lookup tree */
-	struct list_head	unused_conns;	/* unused connections in this bundle */
-	struct list_head	avail_conns;	/* available connections in this bundle */
-	struct list_head	busy_conns;	/* busy connections in this bundle */
-	struct key		*key;		/* security for this bundle */
-	wait_queue_head_t	chanwait;	/* wait for channel to become available */
-	atomic_t		usage;
-	int			debug_id;	/* debug ID for printks */
-	unsigned short		num_conns;	/* number of connections in this bundle */
-	u16			service_id;	/* Service ID for this bundle */
-	u8			security_ix;	/* security type */
-};
-
-/*
  * Keys for matching a connection.
  */
 struct rxrpc_conn_proto {
@@ -295,17 +276,21 @@ struct rxrpc_conn_parameters {
  */
 struct rxrpc_connection {
 	struct rxrpc_transport	*trans;		/* transport session */
-	struct rxrpc_conn_bundle *bundle;	/* connection bundle (client) */
 	struct rxrpc_conn_proto	proto;
 	struct rxrpc_conn_parameters params;
 
+	spinlock_t		channel_lock;
+	struct rxrpc_call	*channels[RXRPC_MAXCALLS]; /* active calls */
+	wait_queue_head_t	channel_wq;	/* queue to wait for channel to become available */
+
 	struct work_struct	processor;	/* connection event processor */
-	struct rb_node		node;		/* node in transport's lookup tree */
+	union {
+		struct rb_node	client_node;	/* Node in local->client_conns */
+		struct rb_node	service_node;	/* Node in trans->server_conns */
+	};
 	struct list_head	link;		/* link in master connection list */
-	struct list_head	bundle_link;	/* link in bundle */
 	struct rb_root		calls;		/* calls on this connection */
 	struct sk_buff_head	rx_queue;	/* received conn-level packets */
-	struct rxrpc_call	*channels[RXRPC_MAXCALLS]; /* channels (active calls) */
 	const struct rxrpc_security *security;	/* applied security module */
 	struct key		*server_key;	/* security for this service */
 	struct crypto_skcipher	*cipher;	/* encryption handle */
@@ -314,7 +299,7 @@ struct rxrpc_connection {
 #define RXRPC_CONN_HAS_IDR	0		/* - Has a client conn ID assigned */
 	unsigned long		events;
 #define RXRPC_CONN_CHALLENGE	0		/* send challenge packet */
-	unsigned long		put_time;	/* time at which to reap */
+	unsigned long		put_time;	/* Time at which last put */
 	rwlock_t		lock;		/* access lock */
 	spinlock_t		state_lock;	/* state-change lock */
 	atomic_t		usage;
@@ -335,7 +320,7 @@ struct rxrpc_connection {
 	unsigned int		call_counter;	/* call ID counter */
 	atomic_t		serial;		/* packet serial number counter */
 	atomic_t		hi_serial;	/* highest serial number received */
-	u8			avail_calls;	/* number of calls available */
+	atomic_t		avail_chans;	/* number of channels available */
 	u8			size_align;	/* data size alignment (for security) */
 	u8			header_size;	/* rxrpc + security header size */
 	u8			security_size;	/* security header size */
@@ -386,6 +371,8 @@ enum rxrpc_call_event {
  * The states that a call can be in.
  */
 enum rxrpc_call_state {
+	RXRPC_CALL_UNINITIALISED,
+	RXRPC_CALL_CLIENT_AWAIT_CONN,	/* - client waiting for connection to become available */
 	RXRPC_CALL_CLIENT_SEND_REQUEST,	/* - client sending request phase */
 	RXRPC_CALL_CLIENT_AWAIT_REPLY,	/* - client awaiting reply */
 	RXRPC_CALL_CLIENT_RECV_REPLY,	/* - client receiving reply phase */
@@ -540,7 +527,7 @@ struct rxrpc_call *rxrpc_find_call_by_user_ID(struct rxrpc_sock *, unsigned long
 struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
 					 struct rxrpc_conn_parameters *,
 					 struct rxrpc_transport *,
-					 struct rxrpc_conn_bundle *,
+					 struct sockaddr_rxrpc *,
 					 unsigned long, gfp_t);
 struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
 				       struct rxrpc_connection *,
@@ -573,13 +560,10 @@ extern unsigned int rxrpc_connection_expiry;
 extern struct list_head rxrpc_connections;
 extern rwlock_t rxrpc_connection_lock;
 
-struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *,
-					   struct rxrpc_transport *,
-					   struct key *, u16, gfp_t);
-void rxrpc_put_bundle(struct rxrpc_transport *, struct rxrpc_conn_bundle *);
-int rxrpc_connect_call(struct rxrpc_sock *, struct rxrpc_conn_parameters *,
-		       struct rxrpc_transport *, struct rxrpc_conn_bundle *,
-		       struct rxrpc_call *, gfp_t);
+int rxrpc_connect_call(struct rxrpc_call *, struct rxrpc_conn_parameters *,
+		       struct rxrpc_transport *,
+		       struct sockaddr_rxrpc *, gfp_t);
+void rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_put_connection(struct rxrpc_connection *);
 void __exit rxrpc_destroy_all_connections(void);
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *,
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 45849a66bc56..9b3b48abe12f 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -31,6 +31,8 @@ unsigned int rxrpc_max_call_lifetime = 60 * HZ;
 unsigned int rxrpc_dead_call_expiry = 2 * HZ;
 
 const char *const rxrpc_call_states[NR__RXRPC_CALL_STATES] = {
+	[RXRPC_CALL_UNINITIALISED]		= "Uninit",
+	[RXRPC_CALL_CLIENT_AWAIT_CONN]		= "ClWtConn",
 	[RXRPC_CALL_CLIENT_SEND_REQUEST]	= "ClSndReq",
 	[RXRPC_CALL_CLIENT_AWAIT_REPLY]		= "ClAwtRpl",
 	[RXRPC_CALL_CLIENT_RECV_REPLY]		= "ClRcvRpl",
@@ -261,6 +263,7 @@ static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 		    (unsigned long) call);
 	INIT_WORK(&call->destroyer, &rxrpc_destroy_call);
 	INIT_WORK(&call->processor, &rxrpc_process_call);
+	INIT_LIST_HEAD(&call->link);
 	INIT_LIST_HEAD(&call->accept_link);
 	skb_queue_head_init(&call->rx_queue);
 	skb_queue_head_init(&call->rx_oos_queue);
@@ -269,7 +272,6 @@ static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 	rwlock_init(&call->state_lock);
 	atomic_set(&call->usage, 1);
 	call->debug_id = atomic_inc_return(&rxrpc_debug_id);
-	call->state = RXRPC_CALL_CLIENT_SEND_REQUEST;
 
 	memset(&call->sock_node, 0xed, sizeof(call->sock_node));
 
@@ -282,55 +284,70 @@ static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 }
 
 /*
- * allocate a new client call and attempt to get a connection slot for it
+ * Allocate a new client call.
  */
 static struct rxrpc_call *rxrpc_alloc_client_call(
 	struct rxrpc_sock *rx,
 	struct rxrpc_conn_parameters *cp,
-	struct rxrpc_transport *trans,
-	struct rxrpc_conn_bundle *bundle,
+	struct sockaddr_rxrpc *srx,
 	gfp_t gfp)
 {
 	struct rxrpc_call *call;
-	int ret;
 
 	_enter("");
 
-	ASSERT(rx != NULL);
-	ASSERT(trans != NULL);
-	ASSERT(bundle != NULL);
+	ASSERT(rx->local != NULL);
 
 	call = rxrpc_alloc_call(gfp);
 	if (!call)
 		return ERR_PTR(-ENOMEM);
+	call->state = RXRPC_CALL_CLIENT_AWAIT_CONN;
 
 	sock_hold(&rx->sk);
 	call->socket = rx;
 	call->rx_data_post = 1;
 
-	ret = rxrpc_connect_call(rx, cp, trans, bundle, call, gfp);
-	if (ret < 0) {
-		kmem_cache_free(rxrpc_call_jar, call);
-		return ERR_PTR(ret);
-	}
-
 	/* Record copies of information for hashtable lookup */
 	call->family = rx->family;
-	call->local = call->conn->params.local;
+	call->local = rx->local;
 	switch (call->family) {
 	case AF_INET:
-		call->peer_ip.ipv4_addr =
-			call->conn->params.peer->srx.transport.sin.sin_addr.s_addr;
+		call->peer_ip.ipv4_addr = srx->transport.sin.sin_addr.s_addr;
 		break;
 	case AF_INET6:
 		memcpy(call->peer_ip.ipv6_addr,
-		       call->conn->params.peer->srx.transport.sin6.sin6_addr.in6_u.u6_addr8,
+		       srx->transport.sin6.sin6_addr.in6_u.u6_addr8,
 		       sizeof(call->peer_ip.ipv6_addr));
 		break;
 	}
-	call->epoch = call->conn->proto.epoch;
-	call->service_id = call->conn->params.service_id;
-	call->in_clientflag = call->conn->proto.in_clientflag;
+
+	call->service_id = srx->srx_service;
+	call->in_clientflag = 0;
+
+	_leave(" = %p", call);
+	return call;
+}
+
+/*
+ * Begin client call.
+ */
+static int rxrpc_begin_client_call(struct rxrpc_call *call,
+				   struct rxrpc_conn_parameters *cp,
+				   struct rxrpc_transport *trans,
+				   struct sockaddr_rxrpc *srx,
+				   gfp_t gfp)
+{
+	int ret;
+
+	/* Set up or get a connection record and set the protocol parameters,
+	 * including channel number and call ID.
+	 */
+	ret = rxrpc_connect_call(call, cp, trans, srx, gfp);
+	if (ret < 0)
+		return ret;
+
+	call->state = RXRPC_CALL_CLIENT_SEND_REQUEST;
+
 	/* Add the new call to the hashtable */
 	rxrpc_call_hash_add(call);
 
@@ -340,9 +357,7 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
 
 	call->lifetimer.expires = jiffies + rxrpc_max_call_lifetime;
 	add_timer(&call->lifetimer);
-
-	_leave(" = %p", call);
-	return call;
+	return 0;
 }
 
 /*
@@ -352,23 +367,23 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
 struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 					 struct rxrpc_conn_parameters *cp,
 					 struct rxrpc_transport *trans,
-					 struct rxrpc_conn_bundle *bundle,
+					 struct sockaddr_rxrpc *srx,
 					 unsigned long user_call_ID,
 					 gfp_t gfp)
 {
 	struct rxrpc_call *call, *xcall;
 	struct rb_node *parent, **pp;
+	int ret;
 
-	_enter("%p,%d,%d,%lx",
-	       rx, trans->debug_id, bundle ? bundle->debug_id : -1,
-	       user_call_ID);
+	_enter("%p,%lx", rx, user_call_ID);
 
-	call = rxrpc_alloc_client_call(rx, cp, trans, bundle, gfp);
+	call = rxrpc_alloc_client_call(rx, cp, srx, gfp);
 	if (IS_ERR(call)) {
 		_leave(" = %ld", PTR_ERR(call));
 		return call;
 	}
 
+	/* Publish the call, even though it is incompletely set up as yet */
 	call->user_call_ID = user_call_ID;
 	__set_bit(RXRPC_CALL_HAS_USERID, &call->flags);
 
@@ -398,11 +413,29 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	list_add_tail(&call->link, &rxrpc_calls);
 	write_unlock_bh(&rxrpc_call_lock);
 
+	ret = rxrpc_begin_client_call(call, cp, trans, srx, gfp);
+	if (ret < 0)
+		goto error;
+
 	_net("CALL new %d on CONN %d", call->debug_id, call->conn->debug_id);
 
 	_leave(" = %p [new]", call);
 	return call;
 
+error:
+	write_lock(&rx->call_lock);
+	rb_erase(&call->sock_node, &rx->calls);
+	write_unlock(&rx->call_lock);
+	rxrpc_put_call(call);
+
+	write_lock_bh(&rxrpc_call_lock);
+	list_del(&call->link);
+	write_unlock_bh(&rxrpc_call_lock);
+
+	rxrpc_put_call(call);
+	_leave(" = %d", ret);
+	return ERR_PTR(ret);
+
 	/* We unexpectedly found the user ID in the list after taking
 	 * the call_lock.  This shouldn't happen unless the user races
 	 * with itself and tries to add the same user ID twice at the
@@ -612,40 +645,13 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	write_unlock_bh(&rx->call_lock);
 
 	/* free up the channel for reuse */
-	spin_lock(&conn->trans->client_lock);
+	spin_lock(&conn->channel_lock);
 	write_lock_bh(&conn->lock);
 	write_lock(&call->state_lock);
 
-	if (conn->channels[call->channel] == call)
-		conn->channels[call->channel] = NULL;
-
-	if (conn->out_clientflag && conn->bundle) {
-		conn->avail_calls++;
-		switch (conn->avail_calls) {
-		case 1:
-			list_move_tail(&conn->bundle_link,
-				       &conn->bundle->avail_conns);
-		case 2 ... RXRPC_MAXCALLS - 1:
-			ASSERT(conn->channels[0] == NULL ||
-			       conn->channels[1] == NULL ||
-			       conn->channels[2] == NULL ||
-			       conn->channels[3] == NULL);
-			break;
-		case RXRPC_MAXCALLS:
-			list_move_tail(&conn->bundle_link,
-				       &conn->bundle->unused_conns);
-			ASSERT(conn->channels[0] == NULL &&
-			       conn->channels[1] == NULL &&
-			       conn->channels[2] == NULL &&
-			       conn->channels[3] == NULL);
-			break;
-		default:
-			pr_err("conn->avail_calls=%d\n", conn->avail_calls);
-			BUG();
-		}
-	}
+	rxrpc_disconnect_call(call);
 
-	spin_unlock(&conn->trans->client_lock);
+	spin_unlock(&conn->channel_lock);
 
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    call->state != RXRPC_CALL_CLIENT_FINAL_ACK) {
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 1754f2e2e16b..5b27241ebea6 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -32,152 +32,6 @@ DEFINE_RWLOCK(rxrpc_connection_lock);
 static DECLARE_DELAYED_WORK(rxrpc_connection_reap, rxrpc_connection_reaper);
 
 /*
- * allocate a new client connection bundle
- */
-static struct rxrpc_conn_bundle *rxrpc_alloc_bundle(gfp_t gfp)
-{
-	struct rxrpc_conn_bundle *bundle;
-
-	_enter("");
-
-	bundle = kzalloc(sizeof(struct rxrpc_conn_bundle), gfp);
-	if (bundle) {
-		INIT_LIST_HEAD(&bundle->unused_conns);
-		INIT_LIST_HEAD(&bundle->avail_conns);
-		INIT_LIST_HEAD(&bundle->busy_conns);
-		init_waitqueue_head(&bundle->chanwait);
-		atomic_set(&bundle->usage, 1);
-	}
-
-	_leave(" = %p", bundle);
-	return bundle;
-}
-
-/*
- * compare bundle parameters with what we're looking for
- * - return -ve, 0 or +ve
- */
-static inline
-int rxrpc_cmp_bundle(const struct rxrpc_conn_bundle *bundle,
-		     struct key *key, u16 service_id)
-{
-	return (bundle->service_id - service_id) ?:
-		((unsigned long)bundle->key - (unsigned long)key);
-}
-
-/*
- * get bundle of client connections that a client socket can make use of
- */
-struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
-					   struct rxrpc_transport *trans,
-					   struct key *key,
-					   u16 service_id,
-					   gfp_t gfp)
-{
-	struct rxrpc_conn_bundle *bundle, *candidate;
-	struct rb_node *p, *parent, **pp;
-
-	_enter("%p{%x},%x,%hx,",
-	       rx, key_serial(key), trans->debug_id, service_id);
-
-	/* search the extant bundles first for one that matches the specified
-	 * user ID */
-	spin_lock(&trans->client_lock);
-
-	p = trans->bundles.rb_node;
-	while (p) {
-		bundle = rb_entry(p, struct rxrpc_conn_bundle, node);
-
-		if (rxrpc_cmp_bundle(bundle, key, service_id) < 0)
-			p = p->rb_left;
-		else if (rxrpc_cmp_bundle(bundle, key, service_id) > 0)
-			p = p->rb_right;
-		else
-			goto found_extant_bundle;
-	}
-
-	spin_unlock(&trans->client_lock);
-
-	/* not yet present - create a candidate for a new record and then
-	 * redo the search */
-	candidate = rxrpc_alloc_bundle(gfp);
-	if (!candidate) {
-		_leave(" = -ENOMEM");
-		return ERR_PTR(-ENOMEM);
-	}
-
-	candidate->key = key_get(key);
-	candidate->service_id = service_id;
-
-	spin_lock(&trans->client_lock);
-
-	pp = &trans->bundles.rb_node;
-	parent = NULL;
-	while (*pp) {
-		parent = *pp;
-		bundle = rb_entry(parent, struct rxrpc_conn_bundle, node);
-
-		if (rxrpc_cmp_bundle(bundle, key, service_id) < 0)
-			pp = &(*pp)->rb_left;
-		else if (rxrpc_cmp_bundle(bundle, key, service_id) > 0)
-			pp = &(*pp)->rb_right;
-		else
-			goto found_extant_second;
-	}
-
-	/* second search also failed; add the new bundle */
-	bundle = candidate;
-	candidate = NULL;
-
-	rb_link_node(&bundle->node, parent, pp);
-	rb_insert_color(&bundle->node, &trans->bundles);
-	spin_unlock(&trans->client_lock);
-	_net("BUNDLE new on trans %d", trans->debug_id);
-	_leave(" = %p [new]", bundle);
-	return bundle;
-
-	/* we found the bundle in the list immediately */
-found_extant_bundle:
-	atomic_inc(&bundle->usage);
-	spin_unlock(&trans->client_lock);
-	_net("BUNDLE old on trans %d", trans->debug_id);
-	_leave(" = %p [extant %d]", bundle, atomic_read(&bundle->usage));
-	return bundle;
-
-	/* we found the bundle on the second time through the list */
-found_extant_second:
-	atomic_inc(&bundle->usage);
-	spin_unlock(&trans->client_lock);
-	kfree(candidate);
-	_net("BUNDLE old2 on trans %d", trans->debug_id);
-	_leave(" = %p [second %d]", bundle, atomic_read(&bundle->usage));
-	return bundle;
-}
-
-/*
- * release a bundle
- */
-void rxrpc_put_bundle(struct rxrpc_transport *trans,
-		      struct rxrpc_conn_bundle *bundle)
-{
-	_enter("%p,%p{%d}",trans, bundle, atomic_read(&bundle->usage));
-
-	if (atomic_dec_and_lock(&bundle->usage, &trans->client_lock)) {
-		_debug("Destroy bundle");
-		rb_erase(&bundle->node, &trans->bundles);
-		spin_unlock(&trans->client_lock);
-		ASSERT(list_empty(&bundle->unused_conns));
-		ASSERT(list_empty(&bundle->avail_conns));
-		ASSERT(list_empty(&bundle->busy_conns));
-		ASSERTCMP(bundle->num_conns, ==, 0);
-		key_put(bundle->key);
-		kfree(bundle);
-	}
-
-	_leave("");
-}
-
-/*
  * allocate a new connection
  */
 static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
@@ -188,8 +42,10 @@ static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 
 	conn = kzalloc(sizeof(struct rxrpc_connection), gfp);
 	if (conn) {
+		spin_lock_init(&conn->channel_lock);
+		init_waitqueue_head(&conn->channel_wq);
 		INIT_WORK(&conn->processor, &rxrpc_process_connection);
-		INIT_LIST_HEAD(&conn->bundle_link);
+		INIT_LIST_HEAD(&conn->link);
 		conn->calls = RB_ROOT;
 		skb_queue_head_init(&conn->rx_queue);
 		conn->security = &rxrpc_no_security;
@@ -197,7 +53,7 @@ static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 		spin_lock_init(&conn->state_lock);
 		atomic_set(&conn->usage, 1);
 		conn->debug_id = atomic_inc_return(&rxrpc_debug_id);
-		conn->avail_calls = RXRPC_MAXCALLS;
+		atomic_set(&conn->avail_chans, RXRPC_MAXCALLS);
 		conn->size_align = 4;
 		conn->header_size = sizeof(struct rxrpc_wire_header);
 	}
@@ -240,7 +96,8 @@ static void rxrpc_add_call_ID_to_conn(struct rxrpc_connection *conn,
 }
 
 /*
- * Allocate a client connection.
+ * Allocate a client connection.  The caller must take care to clear any
+ * padding bytes in *cp.
  */
 static struct rxrpc_connection *
 rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp,
@@ -290,6 +147,8 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp,
 	write_unlock(&rxrpc_connection_lock);
 
 	key_get(conn->params.key);
+	conn->trans = trans;
+	atomic_inc(&trans->usage);
 
 	_leave(" = %p", conn);
 	return conn;
@@ -303,217 +162,172 @@ error_0:
 }
 
 /*
- * connect a call on an exclusive connection
- */
-static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
-				   struct rxrpc_conn_parameters *cp,
-				   struct rxrpc_transport *trans,
-				   struct rxrpc_call *call,
-				   gfp_t gfp)
-{
-	struct rxrpc_connection *conn;
-	int chan;
-
-	_enter("");
-
-	conn = rxrpc_alloc_client_connection(cp, trans, gfp);
-	if (IS_ERR(conn)) {
-		_leave(" = %ld", PTR_ERR(conn));
-		return PTR_ERR(conn);
-	}
-
-	atomic_inc(&trans->usage);
-	conn->trans = trans;
-	conn->bundle = NULL;
-
-	_net("CONNECT EXCL new %d on TRANS %d",
-	     conn->debug_id, conn->trans->debug_id);
-
-	/* Since no one else can use the connection, we just use the first
-	 * channel.
-	 */
-	chan = 0;
-	rxrpc_get_connection(conn);
-	conn->avail_calls = RXRPC_MAXCALLS - 1;
-	conn->channels[chan] = call;
-	conn->call_counter = 1;
-	call->conn = conn;
-	call->channel = chan;
-	call->cid = conn->proto.cid | chan;
-	call->call_id = 1;
-
-	_net("CONNECT client on conn %d chan %d as call %x",
-	     conn->debug_id, chan, call->call_id);
-
-	rxrpc_add_call_ID_to_conn(conn, call);
-	_leave(" = 0");
-	return 0;
-}
-
-/*
  * find a connection for a call
  * - called in process context with IRQs enabled
  */
-int rxrpc_connect_call(struct rxrpc_sock *rx,
+int rxrpc_connect_call(struct rxrpc_call *call,
 		       struct rxrpc_conn_parameters *cp,
 		       struct rxrpc_transport *trans,
-		       struct rxrpc_conn_bundle *bundle,
-		       struct rxrpc_call *call,
+		       struct sockaddr_rxrpc *srx,
 		       gfp_t gfp)
 {
-	struct rxrpc_connection *conn, *candidate;
+	struct rxrpc_connection *conn, *candidate = NULL;
+	struct rxrpc_local *local = cp->local;
+	struct rb_node *p, **pp, *parent;
+	long diff;
 	int chan;
 
 	DECLARE_WAITQUEUE(myself, current);
 
-	_enter("%p,%lx,", rx, call->user_call_ID);
-
-	if (cp->exclusive)
-		return rxrpc_connect_exclusive(rx, cp, trans, call, gfp);
-
-	spin_lock(&trans->client_lock);
-	for (;;) {
-		/* see if the bundle has a call slot available */
-		if (!list_empty(&bundle->avail_conns)) {
-			_debug("avail");
-			conn = list_entry(bundle->avail_conns.next,
-					  struct rxrpc_connection,
-					  bundle_link);
-			if (conn->state >= RXRPC_CONN_REMOTELY_ABORTED) {
-				list_del_init(&conn->bundle_link);
-				bundle->num_conns--;
-				continue;
-			}
-			if (--conn->avail_calls == 0)
-				list_move(&conn->bundle_link,
-					  &bundle->busy_conns);
-			ASSERTCMP(conn->avail_calls, <, RXRPC_MAXCALLS);
-			ASSERT(conn->channels[0] == NULL ||
-			       conn->channels[1] == NULL ||
-			       conn->channels[2] == NULL ||
-			       conn->channels[3] == NULL);
-			rxrpc_get_connection(conn);
-			break;
-		}
+	_enter("{%d,%lx},", call->debug_id, call->user_call_ID);
 
-		if (!list_empty(&bundle->unused_conns)) {
-			_debug("unused");
-			conn = list_entry(bundle->unused_conns.next,
-					  struct rxrpc_connection,
-					  bundle_link);
-			if (conn->state >= RXRPC_CONN_REMOTELY_ABORTED) {
-				list_del_init(&conn->bundle_link);
-				bundle->num_conns--;
-				continue;
-			}
-			ASSERTCMP(conn->avail_calls, ==, RXRPC_MAXCALLS);
-			conn->avail_calls = RXRPC_MAXCALLS - 1;
-			ASSERT(conn->channels[0] == NULL &&
-			       conn->channels[1] == NULL &&
-			       conn->channels[2] == NULL &&
-			       conn->channels[3] == NULL);
-			rxrpc_get_connection(conn);
-			list_move(&conn->bundle_link, &bundle->avail_conns);
-			break;
-		}
+	cp->peer = trans->peer;
+	rxrpc_get_peer(cp->peer);
 
-		/* need to allocate a new connection */
-		_debug("get new conn [%d]", bundle->num_conns);
-
-		spin_unlock(&trans->client_lock);
-
-		if (signal_pending(current))
-			goto interrupted;
-
-		if (bundle->num_conns >= 20) {
-			_debug("too many conns");
-
-			if (!gfpflags_allow_blocking(gfp)) {
-				_leave(" = -EAGAIN");
-				return -EAGAIN;
-			}
-
-			add_wait_queue(&bundle->chanwait, &myself);
-			for (;;) {
-				set_current_state(TASK_INTERRUPTIBLE);
-				if (bundle->num_conns < 20 ||
-				    !list_empty(&bundle->unused_conns) ||
-				    !list_empty(&bundle->avail_conns))
-					break;
-				if (signal_pending(current))
-					goto interrupted_dequeue;
-				schedule();
-			}
-			remove_wait_queue(&bundle->chanwait, &myself);
-			__set_current_state(TASK_RUNNING);
-			spin_lock(&trans->client_lock);
-			continue;
-		}
+	if (!cp->exclusive) {
+		/* Search for a existing client connection unless this is going
+		 * to be a connection that's used exclusively for a single call.
+		 */
+		_debug("search 1");
+		spin_lock(&local->client_conns_lock);
+		p = local->client_conns.rb_node;
+		while (p) {
+			conn = rb_entry(p, struct rxrpc_connection, client_node);
 
-		/* not yet present - create a candidate for a new connection and then
-		 * redo the check */
-		candidate = rxrpc_alloc_client_connection(cp, trans, gfp);
-		if (!candidate) {
-			_leave(" = -ENOMEM");
-			return -ENOMEM;
+#define cmp(X) ((long)conn->params.X - (long)cp->X)
+			diff = (cmp(peer) ?:
+				cmp(key) ?:
+				cmp(security_level));
+			if (diff < 0)
+				p = p->rb_left;
+			else if (diff > 0)
+				p = p->rb_right;
+			else
+				goto found_extant_conn;
 		}
+		spin_unlock(&local->client_conns_lock);
+	}
 
-		atomic_inc(&bundle->usage);
-		atomic_inc(&trans->usage);
-		candidate->trans = trans;
-		candidate->bundle = bundle;
+	/* We didn't find a connection or we want an exclusive one. */
+	_debug("get new conn");
+	candidate = rxrpc_alloc_client_connection(cp, trans, gfp);
+	if (!candidate) {
+		_leave(" = -ENOMEM");
+		return -ENOMEM;
+	}
 
-		spin_lock(&trans->client_lock);
+	if (cp->exclusive) {
+		/* Assign the call on an exclusive connection to channel 0 and
+		 * don't add the connection to the endpoint's shareable conn
+		 * lookup tree.
+		 */
+		_debug("exclusive chan 0");
+		atomic_set(&conn->avail_chans, RXRPC_MAXCALLS - 1);
+		spin_lock(&conn->channel_lock);
+		chan = 0;
+		goto found_channel;
+	}
 
-		list_add(&candidate->bundle_link, &bundle->unused_conns);
-		bundle->num_conns++;
+	/* We need to redo the search before attempting to add a new connection
+	 * lest we race with someone else adding a conflicting instance.
+	 */
+	_debug("search 2");
+	spin_lock(&local->client_conns_lock);
 
-		_net("CONNECT new %d on TRANS %d",
-		     candidate->debug_id, candidate->trans->debug_id);
+	pp = &local->client_conns.rb_node;
+	parent = NULL;
+	while (*pp) {
+		parent = *pp;
+		conn = rb_entry(parent, struct rxrpc_connection, client_node);
 
-		/* leave the candidate lurking in zombie mode attached to the
-		 * bundle until we're ready for it */
-		rxrpc_put_connection(candidate);
-		candidate = NULL;
+		diff = (cmp(peer) ?:
+			cmp(key) ?:
+			cmp(security_level));
+		if (diff < 0)
+			pp = &(*pp)->rb_left;
+		else if (diff > 0)
+			pp = &(*pp)->rb_right;
+		else
+			goto found_extant_conn;
 	}
 
-	/* we've got a connection with a free channel and we can now attach the
-	 * call to it
-	 * - we're holding the transport's client lock
-	 * - we're holding a reference on the connection
-	 * - we're holding a reference on the bundle
+	/* The second search also failed; simply add the new connection with
+	 * the new call in channel 0.  Note that we need to take the channel
+	 * lock before dropping the client conn lock.
 	 */
-	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
-		if (!conn->channels[chan])
-			goto found_channel;
-	ASSERT(conn->channels[0] == NULL ||
-	       conn->channels[1] == NULL ||
-	       conn->channels[2] == NULL ||
-	       conn->channels[3] == NULL);
-	BUG();
+	_debug("new conn");
+	conn = candidate;
+	candidate = NULL;
 
-found_channel:
-	conn->channels[chan] = call;
-	call->conn = conn;
-	call->channel = chan;
-	call->cid = conn->proto.cid | chan;
-	call->call_id = ++conn->call_counter;
+	rb_link_node(&conn->client_node, parent, pp);
+	rb_insert_color(&conn->client_node, &local->client_conns);
+
+	atomic_set(&conn->avail_chans, RXRPC_MAXCALLS - 1);
+	spin_lock(&conn->channel_lock);
+	spin_unlock(&local->client_conns_lock);
+	chan = 0;
 
-	_net("CONNECT client on conn %d chan %d as call %x",
-	     conn->debug_id, chan, call->call_id);
+found_channel:
+	_debug("found chan");
+	call->conn	= conn;
+	call->channel	= chan;
+	call->epoch	= conn->proto.epoch;
+	call->cid	= conn->proto.cid | chan;
+	call->call_id	= ++conn->call_counter;
+	rcu_assign_pointer(conn->channels[chan], call);
 
-	ASSERTCMP(conn->avail_calls, <, RXRPC_MAXCALLS);
-	spin_unlock(&trans->client_lock);
+	_net("CONNECT call %d on conn %d", call->debug_id, conn->debug_id);
 
 	rxrpc_add_call_ID_to_conn(conn, call);
-
-	_leave(" = 0");
+	spin_unlock(&conn->channel_lock);
+	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
 	return 0;
 
-interrupted_dequeue:
-	remove_wait_queue(&bundle->chanwait, &myself);
-	__set_current_state(TASK_RUNNING);
+	/* We found a suitable connection already in existence.  Discard any
+	 * candidate we may have allocated, and try to get a channel on this
+	 * one.
+	 */
+found_extant_conn:
+	_debug("found conn");
+	rxrpc_get_connection(conn);
+	spin_unlock(&local->client_conns_lock);
+
+	rxrpc_put_connection(candidate);
+
+	if (!atomic_add_unless(&conn->avail_chans, -1, 0)) {
+		if (!gfpflags_allow_blocking(gfp)) {
+			rxrpc_put_connection(conn);
+			_leave(" = -EAGAIN");
+			return -EAGAIN;
+		}
+
+		add_wait_queue(&conn->channel_wq, &myself);
+		for (;;) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			if (atomic_add_unless(&conn->avail_chans, -1, 0))
+				break;
+			if (signal_pending(current))
+				goto interrupted;
+			schedule();
+		}
+		remove_wait_queue(&conn->channel_wq, &myself);
+		__set_current_state(TASK_RUNNING);
+	}
+
+	/* The connection allegedly now has a free channel and we can now
+	 * attach the call to it.
+	 */
+	spin_lock(&conn->channel_lock);
+
+	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
+		if (!conn->channels[chan])
+			goto found_channel;
+	BUG();
+
 interrupted:
+	remove_wait_queue(&conn->channel_wq, &myself);
+	__set_current_state(TASK_RUNNING);
+	rxrpc_put_connection(conn);
 	_leave(" = -ERESTARTSYS");
 	return -ERESTARTSYS;
 }
@@ -521,8 +335,8 @@ interrupted:
 /*
  * get a record of an incoming connection
  */
-struct rxrpc_connection *
-rxrpc_incoming_connection(struct rxrpc_transport *trans, struct sk_buff *skb)
+struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_transport *trans,
+						   struct sk_buff *skb)
 {
 	struct rxrpc_connection *conn, *candidate = NULL;
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
@@ -543,7 +357,7 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans, struct sk_buff *skb)
 
 	p = trans->server_conns.rb_node;
 	while (p) {
-		conn = rb_entry(p, struct rxrpc_connection, node);
+		conn = rb_entry(p, struct rxrpc_connection, service_node);
 
 		_debug("maybe %x", conn->proto.cid);
 
@@ -588,7 +402,7 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans, struct sk_buff *skb)
 	p = NULL;
 	while (*pp) {
 		p = *pp;
-		conn = rb_entry(p, struct rxrpc_connection, node);
+		conn = rb_entry(p, struct rxrpc_connection, service_node);
 
 		if (epoch < conn->proto.epoch)
 			pp = &(*pp)->rb_left;
@@ -605,8 +419,8 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans, struct sk_buff *skb)
 	/* we can now add the new candidate to the list */
 	conn = candidate;
 	candidate = NULL;
-	rb_link_node(&conn->node, p, pp);
-	rb_insert_color(&conn->node, &trans->server_conns);
+	rb_link_node(&conn->service_node, p, pp);
+	rb_insert_color(&conn->service_node, &trans->server_conns);
 	atomic_inc(&conn->trans->usage);
 
 	write_unlock_bh(&trans->conn_lock);
@@ -672,7 +486,7 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
 	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED) {
 		p = trans->server_conns.rb_node;
 		while (p) {
-			conn = rb_entry(p, struct rxrpc_connection, node);
+			conn = rb_entry(p, struct rxrpc_connection, service_node);
 
 			_debug("maybe %x", conn->proto.cid);
 
@@ -705,10 +519,31 @@ found:
 }
 
 /*
+ * Disconnect a call and clear any channel it occupies when that call
+ * terminates.
+ */
+void rxrpc_disconnect_call(struct rxrpc_call *call)
+{
+	struct rxrpc_connection *conn = call->conn;
+	unsigned chan = call->channel;
+
+	_enter("%d,%d", conn->debug_id, call->channel);
+
+	if (conn->channels[chan] == call) {
+		rcu_assign_pointer(conn->channels[chan], NULL);
+		atomic_inc(&conn->avail_chans);
+		wake_up(&conn->channel_wq);
+	}
+}
+
+/*
  * release a virtual connection
  */
 void rxrpc_put_connection(struct rxrpc_connection *conn)
 {
+	if (!conn)
+		return;
+
 	_enter("%p{u=%d,d=%d}",
 	       conn, atomic_read(&conn->usage), conn->debug_id);
 
@@ -734,9 +569,6 @@ static void rxrpc_destroy_connection(struct rxrpc_connection *conn)
 
 	_net("DESTROY CONN %d", conn->debug_id);
 
-	if (conn->bundle)
-		rxrpc_put_bundle(conn->trans, conn->bundle);
-
 	ASSERT(RB_EMPTY_ROOT(&conn->calls));
 	rxrpc_purge_queue(&conn->rx_queue);
 
@@ -773,7 +605,6 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 		if (likely(atomic_read(&conn->usage) > 0))
 			continue;
 
-		spin_lock(&conn->trans->client_lock);
 		write_lock_bh(&conn->trans->conn_lock);
 		reap_time = conn->put_time + rxrpc_connection_expiry;
 
@@ -784,19 +615,14 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 			if (conn->out_clientflag)
 				rxrpc_put_client_connection_id(conn);
 			else
-				rb_erase(&conn->node,
+				rb_erase(&conn->service_node,
 					 &conn->trans->server_conns);
-			if (conn->bundle) {
-				list_del_init(&conn->bundle_link);
-				conn->bundle->num_conns--;
-			}
 
 		} else if (reap_time < earliest) {
 			earliest = reap_time;
 		}
 
 		write_unlock_bh(&conn->trans->conn_lock);
-		spin_unlock(&conn->trans->client_lock);
 	}
 	write_unlock(&rxrpc_connection_lock);
 
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index 5703b0d18ed4..284a14c30b9b 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -80,7 +80,8 @@ static struct rxrpc_local *rxrpc_alloc_local(const struct sockaddr_rxrpc *srx)
 		skb_queue_head_init(&local->accept_queue);
 		skb_queue_head_init(&local->reject_queue);
 		skb_queue_head_init(&local->event_queue);
-		mutex_init(&local->conn_lock);
+		local->client_conns = RB_ROOT;
+		spin_lock_init(&local->client_conns_lock);
 		spin_lock_init(&local->lock);
 		rwlock_init(&local->services_lock);
 		local->debug_id = atomic_inc_return(&rxrpc_debug_id);
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index db3933cf6b97..8e24939aeac8 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -140,7 +140,6 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 				  unsigned long user_call_ID, bool exclusive)
 {
 	struct rxrpc_conn_parameters cp;
-	struct rxrpc_conn_bundle *bundle;
 	struct rxrpc_transport *trans;
 	struct rxrpc_call *call;
 	struct key *key;
@@ -171,16 +170,8 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 	}
 	cp.peer = trans->peer;
 
-	bundle = rxrpc_get_bundle(rx, trans, cp.key, srx->srx_service,
-				  GFP_KERNEL);
-	if (IS_ERR(bundle)) {
-		ret = PTR_ERR(bundle);
-		goto out_trans;
-	}
-
-	call = rxrpc_new_client_call(rx, &cp, trans, bundle, user_call_ID,
+	call = rxrpc_new_client_call(rx, &cp, trans, srx, user_call_ID,
 				     GFP_KERNEL);
-	rxrpc_put_bundle(trans, bundle);
 	rxrpc_put_transport(trans);
 	if (IS_ERR(call)) {
 		ret = PTR_ERR(call);
diff --git a/net/rxrpc/transport.c b/net/rxrpc/transport.c
index 140628d94bb0..71947402d071 100644
--- a/net/rxrpc/transport.c
+++ b/net/rxrpc/transport.c
@@ -46,9 +46,7 @@ static struct rxrpc_transport *rxrpc_alloc_transport(struct rxrpc_local *local,
 		trans->local = local;
 		trans->peer = peer;
 		INIT_LIST_HEAD(&trans->link);
-		trans->bundles = RB_ROOT;
 		trans->server_conns = RB_ROOT;
-		spin_lock_init(&trans->client_lock);
 		rwlock_init(&trans->conn_lock);
 		atomic_set(&trans->usage, 1);
 		trans->debug_id = atomic_inc_return(&rxrpc_debug_id);
