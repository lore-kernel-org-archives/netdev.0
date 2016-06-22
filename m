From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 14/14] rxrpc: Kill off the rxrpc_transport struct
 [ver #2]
Date: Wed, 22 Jun 2016 17:04:32 +0100
Message-ID: <146661147245.15011.16813688533062355393.stgit@warthog.procyon.org.uk>
References: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40196 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753141AbcFVQFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 12:05:15 -0400
In-Reply-To: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rxrpc_transport struct is now redundant, given that the rxrpc_peer
struct is now per peer port rather than per peer host, so get rid of it.

Service connection lists are transferred to the rxrpc_peer struct, as is
the conn_lock.  Previous patches moved the client connection handling out
of the rxrpc_transport struct and discarded the connection bundling code.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile      |    1 -
 net/rxrpc/af_rxrpc.c    |   46 +---------------------------
 net/rxrpc/ar-internal.h |   57 ++++++----------------------------
 net/rxrpc/call_accept.c |   11 +------
 net/rxrpc/call_object.c |   16 ++++------
 net/rxrpc/conn_object.c |   78 ++++++++++++++++++++++++++---------------------
 net/rxrpc/input.c       |    8 +----
 net/rxrpc/output.c      |   24 +-------------
 net/rxrpc/peer_object.c |    2 +
 net/rxrpc/sysctl.c      |    8 -----
 net/rxrpc/transport.c   |    0 
 11 files changed, 65 insertions(+), 186 deletions(-)
 delete mode 100644 net/rxrpc/transport.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index cfa221536f33..6522e50fb750 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -22,7 +22,6 @@ af-rxrpc-y := \
 	recvmsg.o \
 	security.o \
 	skbuff.o \
-	transport.o \
 	utils.o
 
 af-rxrpc-$(CONFIG_PROC_FS) += proc.o
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index f3b6ed8196c3..5d3e795a7c48 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -224,37 +224,6 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 	return ret;
 }
 
-/*
- * find a transport by address
- */
-struct rxrpc_transport *
-rxrpc_name_to_transport(struct rxrpc_conn_parameters *cp,
-			struct sockaddr *addr,
-			int addr_len,
-			gfp_t gfp)
-{
-	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *) addr;
-	struct rxrpc_transport *trans;
-
-	_enter("%p,%d", addr, addr_len);
-
-	if (cp->local->srx.transport_type != srx->transport_type)
-		return ERR_PTR(-ESOCKTNOSUPPORT);
-	if (cp->local->srx.transport.family != srx->transport.family)
-		return ERR_PTR(-EAFNOSUPPORT);
-
-	/* find a remote transport endpoint from the local one */
-	cp->peer = rxrpc_lookup_peer(cp->local, srx, gfp);
-	if (!cp->peer)
-		return ERR_PTR(-ENOMEM);
-
-	/* find a transport */
-	trans = rxrpc_get_transport(cp->local, cp->peer, gfp);
-	rxrpc_put_peer(cp->peer);
-	_leave(" = %p", trans);
-	return trans;
-}
-
 /**
  * rxrpc_kernel_begin_call - Allow a kernel service to begin a call
  * @sock: The socket on which to make the call
@@ -276,7 +245,6 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 					   gfp_t gfp)
 {
 	struct rxrpc_conn_parameters cp;
-	struct rxrpc_transport *trans;
 	struct rxrpc_call *call;
 	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
 	int ret;
@@ -300,19 +268,8 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 	cp.security_level	= 0;
 	cp.exclusive		= false;
 	cp.service_id		= srx->srx_service;
+	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, gfp);
 
-	trans = rxrpc_name_to_transport(&cp, (struct sockaddr *)srx,
-					sizeof(*srx), gfp);
-	if (IS_ERR(trans)) {
-		call = ERR_CAST(trans);
-		trans = NULL;
-		goto out_notrans;
-	}
-	cp.peer = trans->peer;
-
-	call = rxrpc_new_client_call(rx, &cp, trans, srx, user_call_ID, gfp);
-	rxrpc_put_transport(trans);
-out_notrans:
 	release_sock(&rx->sk);
 	_leave(" = %p", call);
 	return call;
@@ -831,7 +788,6 @@ static void __exit af_rxrpc_exit(void)
 	proto_unregister(&rxrpc_proto);
 	rxrpc_destroy_all_calls();
 	rxrpc_destroy_all_connections();
-	rxrpc_destroy_all_transports();
 
 	ASSERTCMP(atomic_read(&rxrpc_n_skbs), ==, 0);
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 26fe137d62bb..702db72196fb 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -207,6 +207,8 @@ struct rxrpc_peer {
 	struct rxrpc_local	*local;
 	struct hlist_head	error_targets;	/* targets for net error distribution */
 	struct work_struct	error_distributor;
+	struct rb_root		service_conns;	/* Service connections */
+	rwlock_t		conn_lock;
 	spinlock_t		lock;		/* access lock */
 	unsigned int		if_mtu;		/* interface MTU for this peer */
 	unsigned int		mtu;		/* network MTU for this peer */
@@ -226,22 +228,6 @@ struct rxrpc_peer {
 };
 
 /*
- * RxRPC point-to-point transport / connection manager definition
- * - handles a bundle of connections between two endpoints
- * - matched by { local, peer }
- */
-struct rxrpc_transport {
-	struct rxrpc_local	*local;		/* local transport endpoint */
-	struct rxrpc_peer	*peer;		/* remote transport endpoint */
-	struct rb_root		server_conns;	/* server connections on this transport */
-	struct list_head	link;		/* link in master session list */
-	unsigned long		put_time;	/* time at which to reap */
-	rwlock_t		conn_lock;	/* lock for active/dead connections */
-	atomic_t		usage;
-	int			debug_id;	/* debug ID for printks */
-};
-
-/*
  * Keys for matching a connection.
  */
 struct rxrpc_conn_proto {
@@ -271,11 +257,10 @@ struct rxrpc_conn_parameters {
 
 /*
  * RxRPC connection definition
- * - matched by { transport, service_id, conn_id, direction, key }
+ * - matched by { local, peer, epoch, conn_id, direction }
  * - each connection can only handle four simultaneous calls
  */
 struct rxrpc_connection {
-	struct rxrpc_transport	*trans;		/* transport session */
 	struct rxrpc_conn_proto	proto;
 	struct rxrpc_conn_parameters params;
 
@@ -286,7 +271,7 @@ struct rxrpc_connection {
 	struct work_struct	processor;	/* connection event processor */
 	union {
 		struct rb_node	client_node;	/* Node in local->client_conns */
-		struct rb_node	service_node;	/* Node in trans->server_conns */
+		struct rb_node	service_node;	/* Node in peer->service_conns */
 	};
 	struct list_head	link;		/* link in master connection list */
 	struct rb_root		calls;		/* calls on this connection */
@@ -494,10 +479,6 @@ extern u32 rxrpc_epoch;
 extern atomic_t rxrpc_debug_id;
 extern struct workqueue_struct *rxrpc_workqueue;
 
-extern struct rxrpc_transport *rxrpc_name_to_transport(struct rxrpc_conn_parameters *,
-						       struct sockaddr *,
-						       int, gfp_t);
-
 /*
  * call_accept.c
  */
@@ -526,7 +507,6 @@ struct rxrpc_call *rxrpc_find_call_hash(struct rxrpc_host_header *,
 struct rxrpc_call *rxrpc_find_call_by_user_ID(struct rxrpc_sock *, unsigned long);
 struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
 					 struct rxrpc_conn_parameters *,
-					 struct rxrpc_transport *,
 					 struct sockaddr_rxrpc *,
 					 unsigned long, gfp_t);
 struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
@@ -560,15 +540,16 @@ extern struct list_head rxrpc_connections;
 extern rwlock_t rxrpc_connection_lock;
 
 int rxrpc_connect_call(struct rxrpc_call *, struct rxrpc_conn_parameters *,
-		       struct rxrpc_transport *,
 		       struct sockaddr_rxrpc *, gfp_t);
+struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *,
+					       struct rxrpc_peer *,
+					       struct sk_buff *);
 void rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_put_connection(struct rxrpc_connection *);
 void __exit rxrpc_destroy_all_connections(void);
-struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *,
-					       struct sk_buff *);
-extern struct rxrpc_connection *
-rxrpc_incoming_connection(struct rxrpc_transport *, struct sk_buff *);
+struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *,
+						   struct rxrpc_peer *,
+						   struct sk_buff *);
 
 static inline bool rxrpc_conn_is_client(const struct rxrpc_connection *conn)
 {
@@ -585,12 +566,6 @@ static inline void rxrpc_get_connection(struct rxrpc_connection *conn)
 	atomic_inc(&conn->usage);
 }
 
-static inline
-struct rxrpc_connection *rxrpc_get_connection_maybe(struct rxrpc_connection *conn)
-{
-	return atomic_inc_not_zero(&conn->usage) ? conn : NULL;
-}
-
 /*
  * input.c
  */
@@ -745,18 +720,6 @@ static inline void rxrpc_sysctl_exit(void) {}
 #endif
 
 /*
- * transport.c
- */
-extern unsigned int rxrpc_transport_expiry;
-
-struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *,
-					    struct rxrpc_peer *, gfp_t);
-void rxrpc_put_transport(struct rxrpc_transport *);
-void __exit rxrpc_destroy_all_transports(void);
-struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
-					     struct rxrpc_peer *);
-
-/*
  * utils.c
  */
 void rxrpc_get_addr_from_skb(struct rxrpc_local *, const struct sk_buff *,
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 833ad0622b61..202e053a3c6d 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -74,7 +74,6 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 				      struct sockaddr_rxrpc *srx)
 {
 	struct rxrpc_connection *conn;
-	struct rxrpc_transport *trans;
 	struct rxrpc_skb_priv *sp, *nsp;
 	struct rxrpc_peer *peer;
 	struct rxrpc_call *call;
@@ -102,16 +101,8 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 		goto error;
 	}
 
-	trans = rxrpc_get_transport(local, peer, GFP_NOIO);
+	conn = rxrpc_incoming_connection(local, peer, skb);
 	rxrpc_put_peer(peer);
-	if (IS_ERR(trans)) {
-		_debug("no trans");
-		ret = -EBUSY;
-		goto error;
-	}
-
-	conn = rxrpc_incoming_connection(trans, skb);
-	rxrpc_put_transport(trans);
 	if (IS_ERR(conn)) {
 		_debug("no conn");
 		ret = PTR_ERR(conn);
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 9b3b48abe12f..ad933daae13b 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -286,11 +286,9 @@ static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 /*
  * Allocate a new client call.
  */
-static struct rxrpc_call *rxrpc_alloc_client_call(
-	struct rxrpc_sock *rx,
-	struct rxrpc_conn_parameters *cp,
-	struct sockaddr_rxrpc *srx,
-	gfp_t gfp)
+static struct rxrpc_call *rxrpc_alloc_client_call(struct rxrpc_sock *rx,
+						  struct sockaddr_rxrpc *srx,
+						  gfp_t gfp)
 {
 	struct rxrpc_call *call;
 
@@ -333,7 +331,6 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
  */
 static int rxrpc_begin_client_call(struct rxrpc_call *call,
 				   struct rxrpc_conn_parameters *cp,
-				   struct rxrpc_transport *trans,
 				   struct sockaddr_rxrpc *srx,
 				   gfp_t gfp)
 {
@@ -342,7 +339,7 @@ static int rxrpc_begin_client_call(struct rxrpc_call *call,
 	/* Set up or get a connection record and set the protocol parameters,
 	 * including channel number and call ID.
 	 */
-	ret = rxrpc_connect_call(call, cp, trans, srx, gfp);
+	ret = rxrpc_connect_call(call, cp, srx, gfp);
 	if (ret < 0)
 		return ret;
 
@@ -366,7 +363,6 @@ static int rxrpc_begin_client_call(struct rxrpc_call *call,
  */
 struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 					 struct rxrpc_conn_parameters *cp,
-					 struct rxrpc_transport *trans,
 					 struct sockaddr_rxrpc *srx,
 					 unsigned long user_call_ID,
 					 gfp_t gfp)
@@ -377,7 +373,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 
 	_enter("%p,%lx", rx, user_call_ID);
 
-	call = rxrpc_alloc_client_call(rx, cp, srx, gfp);
+	call = rxrpc_alloc_client_call(rx, srx, gfp);
 	if (IS_ERR(call)) {
 		_leave(" = %ld", PTR_ERR(call));
 		return call;
@@ -413,7 +409,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	list_add_tail(&call->link, &rxrpc_calls);
 	write_unlock_bh(&rxrpc_call_lock);
 
-	ret = rxrpc_begin_client_call(call, cp, trans, srx, gfp);
+	ret = rxrpc_begin_client_call(call, cp, srx, gfp);
 	if (ret < 0)
 		goto error;
 
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 276ff505394f..4bfad7cf96cb 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -100,9 +100,7 @@ static void rxrpc_add_call_ID_to_conn(struct rxrpc_connection *conn,
  * padding bytes in *cp.
  */
 static struct rxrpc_connection *
-rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp,
-			      struct rxrpc_transport *trans,
-			      gfp_t gfp)
+rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 {
 	struct rxrpc_connection *conn;
 	int ret;
@@ -146,9 +144,10 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp,
 	list_add_tail(&conn->link, &rxrpc_connections);
 	write_unlock(&rxrpc_connection_lock);
 
+	/* We steal the caller's peer ref. */
+	cp->peer = NULL;
+	rxrpc_get_local(conn->params.local);
 	key_get(conn->params.key);
-	conn->trans = trans;
-	atomic_inc(&trans->usage);
 
 	_leave(" = %p", conn);
 	return conn;
@@ -167,7 +166,6 @@ error_0:
  */
 int rxrpc_connect_call(struct rxrpc_call *call,
 		       struct rxrpc_conn_parameters *cp,
-		       struct rxrpc_transport *trans,
 		       struct sockaddr_rxrpc *srx,
 		       gfp_t gfp)
 {
@@ -181,8 +179,9 @@ int rxrpc_connect_call(struct rxrpc_call *call,
 
 	_enter("{%d,%lx},", call->debug_id, call->user_call_ID);
 
-	cp->peer = trans->peer;
-	rxrpc_get_peer(cp->peer);
+	cp->peer = rxrpc_lookup_peer(cp->local, srx, gfp);
+	if (!cp->peer)
+		return -ENOMEM;
 
 	if (!cp->exclusive) {
 		/* Search for a existing client connection unless this is going
@@ -210,7 +209,7 @@ int rxrpc_connect_call(struct rxrpc_call *call,
 
 	/* We didn't find a connection or we want an exclusive one. */
 	_debug("get new conn");
-	candidate = rxrpc_alloc_client_connection(cp, trans, gfp);
+	candidate = rxrpc_alloc_client_connection(cp, gfp);
 	if (!candidate) {
 		_leave(" = -ENOMEM");
 		return -ENOMEM;
@@ -281,6 +280,8 @@ found_channel:
 
 	rxrpc_add_call_ID_to_conn(conn, call);
 	spin_unlock(&conn->channel_lock);
+	rxrpc_put_peer(cp->peer);
+	cp->peer = NULL;
 	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
 	return 0;
 
@@ -329,6 +330,8 @@ interrupted:
 	remove_wait_queue(&conn->channel_wq, &myself);
 	__set_current_state(TASK_RUNNING);
 	rxrpc_put_connection(conn);
+	rxrpc_put_peer(cp->peer);
+	cp->peer = NULL;
 	_leave(" = -ERESTARTSYS");
 	return -ERESTARTSYS;
 }
@@ -336,7 +339,8 @@ interrupted:
 /*
  * get a record of an incoming connection
  */
-struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_transport *trans,
+struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
+						   struct rxrpc_peer *peer,
 						   struct sk_buff *skb)
 {
 	struct rxrpc_connection *conn, *candidate = NULL;
@@ -354,9 +358,9 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_transport *trans
 	cid = sp->hdr.cid & RXRPC_CIDMASK;
 
 	/* search the connection list first */
-	read_lock_bh(&trans->conn_lock);
+	read_lock_bh(&peer->conn_lock);
 
-	p = trans->server_conns.rb_node;
+	p = peer->service_conns.rb_node;
 	while (p) {
 		conn = rb_entry(p, struct rxrpc_connection, service_node);
 
@@ -373,7 +377,7 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_transport *trans
 		else
 			goto found_extant_connection;
 	}
-	read_unlock_bh(&trans->conn_lock);
+	read_unlock_bh(&peer->conn_lock);
 
 	/* not yet present - create a candidate for a new record and then
 	 * redo the search */
@@ -383,13 +387,12 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_transport *trans
 		return ERR_PTR(-ENOMEM);
 	}
 
-	candidate->trans		= trans;
-	candidate->proto.local		= trans->local;
+	candidate->proto.local		= local;
 	candidate->proto.epoch		= sp->hdr.epoch;
 	candidate->proto.cid		= sp->hdr.cid & RXRPC_CIDMASK;
 	candidate->proto.in_clientflag	= RXRPC_CLIENT_INITIATED;
-	candidate->params.local		= trans->local;
-	candidate->params.peer		= trans->peer;
+	candidate->params.local		= local;
+	candidate->params.peer		= peer;
 	candidate->params.service_id	= sp->hdr.serviceId;
 	candidate->security_ix		= sp->hdr.securityIndex;
 	candidate->out_clientflag	= 0;
@@ -397,9 +400,9 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_transport *trans
 	if (candidate->params.service_id)
 		candidate->state	= RXRPC_CONN_SERVER_UNSECURED;
 
-	write_lock_bh(&trans->conn_lock);
+	write_lock_bh(&peer->conn_lock);
 
-	pp = &trans->server_conns.rb_node;
+	pp = &peer->service_conns.rb_node;
 	p = NULL;
 	while (*pp) {
 		p = *pp;
@@ -421,10 +424,11 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_transport *trans
 	conn = candidate;
 	candidate = NULL;
 	rb_link_node(&conn->service_node, p, pp);
-	rb_insert_color(&conn->service_node, &trans->server_conns);
-	atomic_inc(&conn->trans->usage);
+	rb_insert_color(&conn->service_node, &peer->service_conns);
+	rxrpc_get_peer(peer);
+	rxrpc_get_local(local);
 
-	write_unlock_bh(&trans->conn_lock);
+	write_unlock_bh(&peer->conn_lock);
 
 	write_lock(&rxrpc_connection_lock);
 	list_add_tail(&conn->link, &rxrpc_connections);
@@ -441,21 +445,21 @@ success:
 	/* we found the connection in the list immediately */
 found_extant_connection:
 	if (sp->hdr.securityIndex != conn->security_ix) {
-		read_unlock_bh(&trans->conn_lock);
+		read_unlock_bh(&peer->conn_lock);
 		goto security_mismatch;
 	}
 	rxrpc_get_connection(conn);
-	read_unlock_bh(&trans->conn_lock);
+	read_unlock_bh(&peer->conn_lock);
 	goto success;
 
 	/* we found the connection on the second time through the list */
 found_extant_second:
 	if (sp->hdr.securityIndex != conn->security_ix) {
-		write_unlock_bh(&trans->conn_lock);
+		write_unlock_bh(&peer->conn_lock);
 		goto security_mismatch;
 	}
 	rxrpc_get_connection(conn);
-	write_unlock_bh(&trans->conn_lock);
+	write_unlock_bh(&peer->conn_lock);
 	kfree(candidate);
 	goto success;
 
@@ -469,7 +473,8 @@ security_mismatch:
  * find a connection based on transport and RxRPC connection ID for an incoming
  * packet
  */
-struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
+struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *local,
+					       struct rxrpc_peer *peer,
 					       struct sk_buff *skb)
 {
 	struct rxrpc_connection *conn;
@@ -479,13 +484,13 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
 
 	_enter(",{%x,%x}", sp->hdr.cid, sp->hdr.flags);
 
-	read_lock_bh(&trans->conn_lock);
+	read_lock_bh(&peer->conn_lock);
 
 	cid	= sp->hdr.cid & RXRPC_CIDMASK;
 	epoch	= sp->hdr.epoch;
 
 	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED) {
-		p = trans->server_conns.rb_node;
+		p = peer->service_conns.rb_node;
 		while (p) {
 			conn = rb_entry(p, struct rxrpc_connection, service_node);
 
@@ -508,13 +513,13 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
 			goto found;
 	}
 
-	read_unlock_bh(&trans->conn_lock);
+	read_unlock_bh(&peer->conn_lock);
 	_leave(" = NULL");
 	return NULL;
 
 found:
 	rxrpc_get_connection(conn);
-	read_unlock_bh(&trans->conn_lock);
+	read_unlock_bh(&peer->conn_lock);
 	_leave(" = %p", conn);
 	return conn;
 }
@@ -576,8 +581,9 @@ static void rxrpc_destroy_connection(struct rxrpc_connection *conn)
 	conn->security->clear(conn);
 	key_put(conn->params.key);
 	key_put(conn->server_key);
+	rxrpc_put_peer(conn->params.peer);
+	rxrpc_put_local(conn->params.local);
 
-	rxrpc_put_transport(conn->trans);
 	kfree(conn);
 	_leave("");
 }
@@ -588,6 +594,7 @@ static void rxrpc_destroy_connection(struct rxrpc_connection *conn)
 static void rxrpc_connection_reaper(struct work_struct *work)
 {
 	struct rxrpc_connection *conn, *_p;
+	struct rxrpc_peer *peer;
 	unsigned long now, earliest, reap_time;
 
 	LIST_HEAD(graveyard);
@@ -624,7 +631,8 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 
 			spin_unlock(&local->client_conns_lock);
 		} else {
-			write_lock_bh(&conn->trans->conn_lock);
+			peer = conn->params.peer;
+			write_lock_bh(&peer->conn_lock);
 			reap_time = conn->put_time + rxrpc_connection_expiry;
 
 			if (atomic_read(&conn->usage) > 0) {
@@ -632,12 +640,12 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 			} else if (reap_time <= now) {
 				list_move_tail(&conn->link, &graveyard);
 				rb_erase(&conn->service_node,
-					 &conn->trans->server_conns);
+					 &peer->service_conns);
 			} else if (reap_time < earliest) {
 				earliest = reap_time;
 			}
 
-			write_unlock_bh(&conn->trans->conn_lock);
+			write_unlock_bh(&peer->conn_lock);
 		}
 	}
 	write_unlock(&rxrpc_connection_lock);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 799aec18aa7b..f4bd57b77b93 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -631,7 +631,6 @@ static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
 						      struct sk_buff *skb)
 {
 	struct rxrpc_peer *peer;
-	struct rxrpc_transport *trans;
 	struct rxrpc_connection *conn;
 	struct sockaddr_rxrpc srx;
 
@@ -641,13 +640,8 @@ static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
 	if (!peer)
 		goto cant_find_peer;
 
-	trans = rxrpc_find_transport(local, peer);
+	conn = rxrpc_find_connection(local, peer, skb);
 	rcu_read_unlock();
-	if (!trans)
-		goto cant_find_conn;
-
-	conn = rxrpc_find_connection(trans, skb);
-	rxrpc_put_transport(trans);
 	if (!conn)
 		goto cant_find_conn;
 
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 8e24939aeac8..f4bda06b7d2d 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -140,10 +140,8 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 				  unsigned long user_call_ID, bool exclusive)
 {
 	struct rxrpc_conn_parameters cp;
-	struct rxrpc_transport *trans;
 	struct rxrpc_call *call;
 	struct key *key;
-	long ret;
 
 	DECLARE_SOCKADDR(struct sockaddr_rxrpc *, srx, msg->msg_name);
 
@@ -162,30 +160,10 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 	cp.security_level	= rx->min_sec_level;
 	cp.exclusive		= rx->exclusive | exclusive;
 	cp.service_id		= srx->srx_service;
-	trans = rxrpc_name_to_transport(&cp, msg->msg_name, msg->msg_namelen,
-					GFP_KERNEL);
-	if (IS_ERR(trans)) {
-		ret = PTR_ERR(trans);
-		goto out;
-	}
-	cp.peer = trans->peer;
-
-	call = rxrpc_new_client_call(rx, &cp, trans, srx, user_call_ID,
-				     GFP_KERNEL);
-	rxrpc_put_transport(trans);
-	if (IS_ERR(call)) {
-		ret = PTR_ERR(call);
-		goto out_trans;
-	}
+	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, GFP_KERNEL);
 
 	_leave(" = %p\n", call);
 	return call;
-
-out_trans:
-	rxrpc_put_transport(trans);
-out:
-	_leave(" = %ld", ret);
-	return ERR_PTR(ret);
 }
 
 /*
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index 6baad708f3b1..01d4930a11f7 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -188,6 +188,8 @@ struct rxrpc_peer *rxrpc_alloc_peer(struct rxrpc_local *local, gfp_t gfp)
 		INIT_HLIST_HEAD(&peer->error_targets);
 		INIT_WORK(&peer->error_distributor,
 			  &rxrpc_peer_error_distributor);
+		peer->service_conns = RB_ROOT;
+		rwlock_init(&peer->conn_lock);
 		spin_lock_init(&peer->lock);
 		peer->debug_id = atomic_inc_return(&rxrpc_debug_id);
 	}
diff --git a/net/rxrpc/sysctl.c b/net/rxrpc/sysctl.c
index a99690a8a3da..03ad08774d4e 100644
--- a/net/rxrpc/sysctl.c
+++ b/net/rxrpc/sysctl.c
@@ -90,14 +90,6 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= (void *)&one,
 	},
-	{
-		.procname	= "transport_expiry",
-		.data		= &rxrpc_transport_expiry,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= (void *)&one,
-	},
 
 	/* Non-time values */
 	{
diff --git a/net/rxrpc/transport.c b/net/rxrpc/transport.c
deleted file mode 100644
index 71947402d071..000000000000
