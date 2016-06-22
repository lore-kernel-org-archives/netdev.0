From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 03/14] rxrpc: Use structs to hold connection params
 and protocol info [ver #2]
Date: Wed, 22 Jun 2016 17:03:13 +0100
Message-ID: <146661139325.15011.9511203435057124098.stgit@warthog.procyon.org.uk>
References: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Define and use a structure to hold connection parameters.  This makes it
easier to pass multiple connection parameters around.

Define and use a structure to hold protocol information used to hash a
connection for lookup on incoming packet.  Most of these fields will be
disposed of eventually, including the duplicate local pointer.

Whilst we're at it rename "proto" to "family" when referring to a protocol
family.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c    |   55 ++++++++++++++-----------
 net/rxrpc/ar-internal.h |   61 ++++++++++++++++++++++------
 net/rxrpc/call_event.c  |    6 +--
 net/rxrpc/call_object.c |   44 ++++++++++----------
 net/rxrpc/conn_event.c  |    8 ++--
 net/rxrpc/conn_object.c |  103 +++++++++++++++++++++++++----------------------
 net/rxrpc/input.c       |    4 +-
 net/rxrpc/key.c         |    2 -
 net/rxrpc/output.c      |   24 ++++++++---
 net/rxrpc/proc.c        |   12 +++--
 net/rxrpc/recvmsg.c     |    2 -
 net/rxrpc/rxkad.c       |   62 ++++++++++++++--------------
 net/rxrpc/security.c    |    6 +--
 13 files changed, 226 insertions(+), 163 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 9dd160bb16d2..48b45a0280c0 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -97,7 +97,7 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
 	    srx->transport_len > len)
 		return -EINVAL;
 
-	if (srx->transport.family != rx->proto)
+	if (srx->transport.family != rx->family)
 		return -EAFNOSUPPORT;
 
 	switch (srx->transport.family) {
@@ -227,32 +227,30 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 /*
  * find a transport by address
  */
-struct rxrpc_transport *rxrpc_name_to_transport(struct rxrpc_sock *rx,
-						struct sockaddr *addr,
-						int addr_len, int flags,
-						gfp_t gfp)
+struct rxrpc_transport *
+rxrpc_name_to_transport(struct rxrpc_conn_parameters *cp,
+			struct sockaddr *addr,
+			int addr_len,
+			gfp_t gfp)
 {
 	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *) addr;
 	struct rxrpc_transport *trans;
-	struct rxrpc_peer *peer;
 
-	_enter("%p,%p,%d,%d", rx, addr, addr_len, flags);
-
-	ASSERT(rx->local != NULL);
+	_enter("%p,%d", addr, addr_len);
 
-	if (rx->srx.transport_type != srx->transport_type)
+	if (cp->local->srx.transport_type != srx->transport_type)
 		return ERR_PTR(-ESOCKTNOSUPPORT);
-	if (rx->srx.transport.family != srx->transport.family)
+	if (cp->local->srx.transport.family != srx->transport.family)
 		return ERR_PTR(-EAFNOSUPPORT);
 
 	/* find a remote transport endpoint from the local one */
-	peer = rxrpc_lookup_peer(rx->local, srx, gfp);
-	if (!peer)
+	cp->peer = rxrpc_lookup_peer(cp->local, srx, gfp);
+	if (!cp->peer)
 		return ERR_PTR(-ENOMEM);
 
 	/* find a transport */
-	trans = rxrpc_get_transport(rx->local, peer, gfp);
-	rxrpc_put_peer(peer);
+	trans = rxrpc_get_transport(cp->local, cp->peer, gfp);
+	rxrpc_put_peer(cp->peer);
 	_leave(" = %p", trans);
 	return trans;
 }
@@ -277,6 +275,7 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 					   unsigned long user_call_ID,
 					   gfp_t gfp)
 {
+	struct rxrpc_conn_parameters cp;
 	struct rxrpc_conn_bundle *bundle;
 	struct rxrpc_transport *trans;
 	struct rxrpc_call *call;
@@ -286,18 +285,26 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 
 	lock_sock(&rx->sk);
 
-	trans = rxrpc_name_to_transport(rx, (struct sockaddr *)srx,
-					sizeof(*srx), 0, gfp);
+	if (!key)
+		key = rx->key;
+	if (key && !key->payload.data[0])
+		key = NULL; /* a no-security key */
+
+	memset(&cp, 0, sizeof(cp));
+	cp.local		= rx->local;
+	cp.key			= key;
+	cp.security_level	= 0;
+	cp.exclusive		= false;
+	cp.service_id		= srx->srx_service;
+
+	trans = rxrpc_name_to_transport(&cp, (struct sockaddr *)srx,
+					sizeof(*srx), gfp);
 	if (IS_ERR(trans)) {
 		call = ERR_CAST(trans);
 		trans = NULL;
 		goto out_notrans;
 	}
-
-	if (!key)
-		key = rx->key;
-	if (key && !key->payload.data[0])
-		key = NULL; /* a no-security key */
+	cp.peer = trans->peer;
 
 	bundle = rxrpc_get_bundle(rx, trans, key, srx->srx_service, gfp);
 	if (IS_ERR(bundle)) {
@@ -305,7 +312,7 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 		goto out;
 	}
 
-	call = rxrpc_new_client_call(rx, trans, bundle, user_call_ID, gfp);
+	call = rxrpc_new_client_call(rx, &cp, trans, bundle, user_call_ID, gfp);
 	rxrpc_put_bundle(trans, bundle);
 out:
 	rxrpc_put_transport(trans);
@@ -600,7 +607,7 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 	sk->sk_destruct		= rxrpc_sock_destructor;
 
 	rx = rxrpc_sk(sk);
-	rx->proto = protocol;
+	rx->family = protocol;
 	rx->calls = RB_ROOT;
 
 	INIT_LIST_HEAD(&rx->listen_link);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index c168268467cd..efe6673deb28 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -72,7 +72,7 @@ struct rxrpc_sock {
 #define RXRPC_SECURITY_MAX	RXRPC_SECURITY_ENCRYPT
 	struct sockaddr_rxrpc	srx;		/* local address */
 	struct sockaddr_rxrpc	connect_srx;	/* Default client address from connect() */
-	sa_family_t		proto;		/* protocol created with */
+	sa_family_t		family;		/* protocol family created with */
 };
 
 #define rxrpc_sk(__sk) container_of((__sk), struct rxrpc_sock, sk)
@@ -262,6 +262,34 @@ struct rxrpc_conn_bundle {
 };
 
 /*
+ * Keys for matching a connection.
+ */
+struct rxrpc_conn_proto {
+	unsigned long		hash_key;
+	struct rxrpc_local	*local;		/* Representation of local endpoint */
+	u32			epoch;		/* epoch of this connection */
+	u32			cid;		/* connection ID */
+	u8			in_clientflag;	/* RXRPC_CLIENT_INITIATED if we are server */
+	u8			addr_size;	/* Size of the address */
+	sa_family_t		family;		/* Transport protocol */
+	__be16			port;		/* Peer UDP/UDP6 port */
+	union {					/* Peer address */
+		struct in_addr	ipv4_addr;
+		struct in6_addr	ipv6_addr;
+		u32		raw_addr[0];
+	};
+};
+
+struct rxrpc_conn_parameters {
+	struct rxrpc_local	*local;		/* Representation of local endpoint */
+	struct rxrpc_peer	*peer;		/* Remote endpoint */
+	struct key		*key;		/* Security details */
+	bool			exclusive;	/* T if conn is exclusive */
+	u16			service_id;	/* Service ID for this connection */
+	u32			security_level;	/* Security level selected */
+};
+
+/*
  * RxRPC connection definition
  * - matched by { transport, service_id, conn_id, direction, key }
  * - each connection can only handle four simultaneous calls
@@ -269,6 +297,9 @@ struct rxrpc_conn_bundle {
 struct rxrpc_connection {
 	struct rxrpc_transport	*trans;		/* transport session */
 	struct rxrpc_conn_bundle *bundle;	/* connection bundle (client) */
+	struct rxrpc_conn_proto	proto;
+	struct rxrpc_conn_parameters params;
+
 	struct work_struct	processor;	/* connection event processor */
 	struct rb_node		node;		/* node in transport's lookup tree */
 	struct list_head	link;		/* link in master connection list */
@@ -277,7 +308,6 @@ struct rxrpc_connection {
 	struct sk_buff_head	rx_queue;	/* received conn-level packets */
 	struct rxrpc_call	*channels[RXRPC_MAXCALLS]; /* channels (active calls) */
 	const struct rxrpc_security *security;	/* applied security module */
-	struct key		*key;		/* security for this connection (client) */
 	struct key		*server_key;	/* security for this service */
 	struct crypto_skcipher	*cipher;	/* encryption handle */
 	struct rxrpc_crypt	csum_iv;	/* packet checksum base */
@@ -308,13 +338,8 @@ struct rxrpc_connection {
 	u8			size_align;	/* data size alignment (for security) */
 	u8			header_size;	/* rxrpc + security header size */
 	u8			security_size;	/* security header size */
-	u32			security_level;	/* security level negotiated */
 	u32			security_nonce;	/* response re-use preventer */
-	u32			epoch;		/* epoch of this connection */
-	u32			cid;		/* connection ID */
-	u16			service_id;	/* service ID for this connection */
 	u8			security_ix;	/* security type */
-	u8			in_clientflag;	/* RXRPC_CLIENT_INITIATED if we are server */
 	u8			out_clientflag;	/* RXRPC_CLIENT_INITIATED if we are client */
 };
 
@@ -448,7 +473,7 @@ struct rxrpc_call {
 	unsigned long		hash_key;	/* Full hash key */
 	u8			in_clientflag;	/* Copy of conn->in_clientflag for hashing */
 	struct rxrpc_local	*local;		/* Local endpoint. Used for hashing. */
-	sa_family_t		proto;		/* Frame protocol */
+	sa_family_t		family;		/* Frame protocol */
 	u32			call_id;	/* call ID on connection  */
 	u32			cid;		/* connection ID plus channel index */
 	u32			epoch;		/* epoch of this connection */
@@ -481,9 +506,9 @@ extern u32 rxrpc_epoch;
 extern atomic_t rxrpc_debug_id;
 extern struct workqueue_struct *rxrpc_workqueue;
 
-extern struct rxrpc_transport *rxrpc_name_to_transport(struct rxrpc_sock *,
+extern struct rxrpc_transport *rxrpc_name_to_transport(struct rxrpc_conn_parameters *,
 						       struct sockaddr *,
-						       int, int, gfp_t);
+						       int, gfp_t);
 
 /*
  * call_accept.c
@@ -512,6 +537,7 @@ struct rxrpc_call *rxrpc_find_call_hash(struct rxrpc_host_header *,
 					void *, sa_family_t, const void *);
 struct rxrpc_call *rxrpc_find_call_by_user_ID(struct rxrpc_sock *, unsigned long);
 struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
+					 struct rxrpc_conn_parameters *,
 					 struct rxrpc_transport *,
 					 struct rxrpc_conn_bundle *,
 					 unsigned long, gfp_t);
@@ -541,8 +567,9 @@ struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *,
 					   struct rxrpc_transport *,
 					   struct key *, u16, gfp_t);
 void rxrpc_put_bundle(struct rxrpc_transport *, struct rxrpc_conn_bundle *);
-int rxrpc_connect_call(struct rxrpc_sock *, struct rxrpc_transport *,
-		       struct rxrpc_conn_bundle *, struct rxrpc_call *, gfp_t);
+int rxrpc_connect_call(struct rxrpc_sock *, struct rxrpc_conn_parameters *,
+		       struct rxrpc_transport *, struct rxrpc_conn_bundle *,
+		       struct rxrpc_call *, gfp_t);
 void rxrpc_put_connection(struct rxrpc_connection *);
 void __exit rxrpc_destroy_all_connections(void);
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *,
@@ -550,6 +577,16 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *,
 extern struct rxrpc_connection *
 rxrpc_incoming_connection(struct rxrpc_transport *, struct rxrpc_host_header *);
 
+static inline bool rxrpc_conn_is_client(const struct rxrpc_connection *conn)
+{
+	return conn->out_clientflag;
+}
+
+static inline bool rxrpc_conn_is_service(const struct rxrpc_connection *conn)
+{
+	return conn->proto.in_clientflag;
+}
+
 /*
  * input.c
  */
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index e610b106c913..1571dfb95aa3 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -842,7 +842,7 @@ void rxrpc_process_call(struct work_struct *work)
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
 
-	whdr.epoch	= htonl(call->conn->epoch);
+	whdr.epoch	= htonl(call->conn->proto.epoch);
 	whdr.cid	= htonl(call->cid);
 	whdr.callNumber	= htonl(call->call_id);
 	whdr.seq	= 0;
@@ -1264,7 +1264,7 @@ maybe_reschedule:
 	if (call->state >= RXRPC_CALL_COMPLETE &&
 	    !list_empty(&call->accept_link)) {
 		_debug("X unlinking once-pending call %p { e=%lx f=%lx c=%x }",
-		       call, call->events, call->flags, call->conn->cid);
+		       call, call->events, call->flags, call->conn->proto.cid);
 
 		read_lock_bh(&call->state_lock);
 		if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
@@ -1282,7 +1282,7 @@ error:
 	 * this means there's a race between clearing the flag and setting the
 	 * work pending bit and the work item being processed again */
 	if (call->events && !work_pending(&call->processor)) {
-		_debug("jumpstart %x", call->conn->cid);
+		_debug("jumpstart %x", call->conn->proto.cid);
 		rxrpc_queue_call(call);
 	}
 
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 8b4d47b3ccac..b7c6011c71bb 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -71,7 +71,7 @@ static unsigned long rxrpc_call_hashfunc(
 	u32		call_id,
 	u32		epoch,
 	u16		service_id,
-	sa_family_t	proto,
+	sa_family_t	family,
 	void		*localptr,
 	unsigned int	addr_size,
 	const u8	*peer_addr)
@@ -92,7 +92,7 @@ static unsigned long rxrpc_call_hashfunc(
 	key += (cid & RXRPC_CIDMASK) >> RXRPC_CIDSHIFT;
 	key += cid & RXRPC_CHANNELMASK;
 	key += in_clientflag;
-	key += proto;
+	key += family;
 	/* Step through the peer address in 16-bit portions for speed */
 	for (i = 0, p = (const u16 *)peer_addr; i < addr_size >> 1; i++, p++)
 		key += *p;
@@ -109,7 +109,7 @@ static void rxrpc_call_hash_add(struct rxrpc_call *call)
 	unsigned int addr_size = 0;
 
 	_enter("");
-	switch (call->proto) {
+	switch (call->family) {
 	case AF_INET:
 		addr_size = sizeof(call->peer_ip.ipv4_addr);
 		break;
@@ -121,7 +121,7 @@ static void rxrpc_call_hash_add(struct rxrpc_call *call)
 	}
 	key = rxrpc_call_hashfunc(call->in_clientflag, call->cid,
 				  call->call_id, call->epoch,
-				  call->service_id, call->proto,
+				  call->service_id, call->family,
 				  call->conn->trans->local, addr_size,
 				  call->peer_ip.ipv6_addr);
 	/* Store the full key in the call */
@@ -151,7 +151,7 @@ static void rxrpc_call_hash_del(struct rxrpc_call *call)
 struct rxrpc_call *rxrpc_find_call_hash(
 	struct rxrpc_host_header *hdr,
 	void		*localptr,
-	sa_family_t	proto,
+	sa_family_t	family,
 	const void	*peer_addr)
 {
 	unsigned long key;
@@ -161,7 +161,7 @@ struct rxrpc_call *rxrpc_find_call_hash(
 	u8 in_clientflag = hdr->flags & RXRPC_CLIENT_INITIATED;
 
 	_enter("");
-	switch (proto) {
+	switch (family) {
 	case AF_INET:
 		addr_size = sizeof(call->peer_ip.ipv4_addr);
 		break;
@@ -174,7 +174,7 @@ struct rxrpc_call *rxrpc_find_call_hash(
 
 	key = rxrpc_call_hashfunc(in_clientflag, hdr->cid, hdr->callNumber,
 				  hdr->epoch, hdr->serviceId,
-				  proto, localptr, addr_size,
+				  family, localptr, addr_size,
 				  peer_addr);
 	hash_for_each_possible_rcu(rxrpc_call_hash, call, hash_node, key) {
 		if (call->hash_key == key &&
@@ -182,7 +182,7 @@ struct rxrpc_call *rxrpc_find_call_hash(
 		    call->cid == hdr->cid &&
 		    call->in_clientflag == in_clientflag &&
 		    call->service_id == hdr->serviceId &&
-		    call->proto == proto &&
+		    call->family == family &&
 		    call->local == localptr &&
 		    memcmp(call->peer_ip.ipv6_addr, peer_addr,
 			   addr_size) == 0 &&
@@ -286,6 +286,7 @@ static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
  */
 static struct rxrpc_call *rxrpc_alloc_client_call(
 	struct rxrpc_sock *rx,
+	struct rxrpc_conn_parameters *cp,
 	struct rxrpc_transport *trans,
 	struct rxrpc_conn_bundle *bundle,
 	gfp_t gfp)
@@ -307,16 +308,16 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
 	call->socket = rx;
 	call->rx_data_post = 1;
 
-	ret = rxrpc_connect_call(rx, trans, bundle, call, gfp);
+	ret = rxrpc_connect_call(rx, cp, trans, bundle, call, gfp);
 	if (ret < 0) {
 		kmem_cache_free(rxrpc_call_jar, call);
 		return ERR_PTR(ret);
 	}
 
 	/* Record copies of information for hashtable lookup */
-	call->proto = rx->proto;
-	call->local = trans->local;
-	switch (call->proto) {
+	call->family = rx->family;
+	call->local = call->conn->params.local;
+	switch (call->family) {
 	case AF_INET:
 		call->peer_ip.ipv4_addr =
 			trans->peer->srx.transport.sin.sin_addr.s_addr;
@@ -327,9 +328,9 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
 		       sizeof(call->peer_ip.ipv6_addr));
 		break;
 	}
-	call->epoch = call->conn->epoch;
-	call->service_id = call->conn->service_id;
-	call->in_clientflag = call->conn->in_clientflag;
+	call->epoch = call->conn->proto.epoch;
+	call->service_id = call->conn->params.service_id;
+	call->in_clientflag = call->conn->proto.in_clientflag;
 	/* Add the new call to the hashtable */
 	rxrpc_call_hash_add(call);
 
@@ -349,6 +350,7 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
  * - called in process context with IRQs enabled
  */
 struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
+					 struct rxrpc_conn_parameters *cp,
 					 struct rxrpc_transport *trans,
 					 struct rxrpc_conn_bundle *bundle,
 					 unsigned long user_call_ID,
@@ -361,7 +363,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	       rx, trans->debug_id, bundle ? bundle->debug_id : -1,
 	       user_call_ID);
 
-	call = rxrpc_alloc_client_call(rx, trans, bundle, gfp);
+	call = rxrpc_alloc_client_call(rx, cp, trans, bundle, gfp);
 	if (IS_ERR(call)) {
 		_leave(" = %ld", PTR_ERR(call));
 		return call;
@@ -524,9 +526,9 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	write_unlock_bh(&rxrpc_call_lock);
 
 	/* Record copies of information for hashtable lookup */
-	call->proto = rx->proto;
+	call->family = rx->family;
 	call->local = conn->trans->local;
-	switch (call->proto) {
+	switch (call->family) {
 	case AF_INET:
 		call->peer_ip.ipv4_addr =
 			conn->trans->peer->srx.transport.sin.sin_addr.s_addr;
@@ -539,9 +541,9 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	default:
 		break;
 	}
-	call->epoch = conn->epoch;
-	call->service_id = conn->service_id;
-	call->in_clientflag = conn->in_clientflag;
+	call->epoch = conn->proto.epoch;
+	call->service_id = conn->params.service_id;
+	call->in_clientflag = conn->proto.in_clientflag;
 	/* Add the new call to the hashtable */
 	rxrpc_call_hash_add(call);
 
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 00c92b614485..51e280c662e0 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -94,8 +94,8 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
 
-	whdr.epoch	= htonl(conn->epoch);
-	whdr.cid	= htonl(conn->cid);
+	whdr.epoch	= htonl(conn->proto.epoch);
+	whdr.cid	= htonl(conn->proto.cid);
 	whdr.callNumber	= 0;
 	whdr.seq	= 0;
 	whdr.type	= RXRPC_PACKET_TYPE_ABORT;
@@ -103,7 +103,7 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 	whdr.userStatus	= 0;
 	whdr.securityIndex = conn->security_ix;
 	whdr._rsvd	= 0;
-	whdr.serviceId	= htons(conn->service_id);
+	whdr.serviceId	= htons(conn->params.service_id);
 
 	word		= htonl(conn->local_abort);
 
@@ -220,7 +220,7 @@ static void rxrpc_secure_connection(struct rxrpc_connection *conn)
 
 	ASSERT(conn->security_ix != 0);
 
-	if (!conn->key) {
+	if (!conn->params.key) {
 		_debug("set up security");
 		ret = rxrpc_init_server_conn_security(conn);
 		switch (ret) {
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 8ecde4b77b55..c6787b6f459f 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -220,7 +220,7 @@ static void rxrpc_assign_connection_id(struct rxrpc_connection *conn)
 
 	_enter("");
 
-	epoch = conn->epoch;
+	epoch = conn->proto.epoch;
 
 	write_lock_bh(&conn->trans->conn_lock);
 
@@ -237,13 +237,13 @@ attempt_insertion:
 		parent = *p;
 		xconn = rb_entry(parent, struct rxrpc_connection, node);
 
-		if (epoch < xconn->epoch)
+		if (epoch < xconn->proto.epoch)
 			p = &(*p)->rb_left;
-		else if (epoch > xconn->epoch)
+		else if (epoch > xconn->proto.epoch)
 			p = &(*p)->rb_right;
-		else if (cid < xconn->cid)
+		else if (cid < xconn->proto.cid)
 			p = &(*p)->rb_left;
-		else if (cid > xconn->cid)
+		else if (cid > xconn->proto.cid)
 			p = &(*p)->rb_right;
 		else
 			goto id_exists;
@@ -254,7 +254,7 @@ attempt_insertion:
 	rb_link_node(&conn->node, parent, p);
 	rb_insert_color(&conn->node, &conn->trans->client_conns);
 
-	conn->cid = cid;
+	conn->proto.cid = cid;
 	write_unlock_bh(&conn->trans->conn_lock);
 	_leave(" [CID %x]", cid);
 	return;
@@ -275,8 +275,8 @@ id_exists:
 			goto attempt_insertion;
 
 		xconn = rb_entry(parent, struct rxrpc_connection, node);
-		if (epoch < xconn->epoch ||
-		    cid < xconn->cid)
+		if (epoch < xconn->proto.epoch ||
+		    cid < xconn->proto.cid)
 			goto attempt_insertion;
 	}
 }
@@ -318,8 +318,8 @@ static void rxrpc_add_call_ID_to_conn(struct rxrpc_connection *conn,
  * connect a call on an exclusive connection
  */
 static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
+				   struct rxrpc_conn_parameters *cp,
 				   struct rxrpc_transport *trans,
-				   u16 service_id,
 				   struct rxrpc_call *call,
 				   gfp_t gfp)
 {
@@ -340,19 +340,21 @@ static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
 
 		conn->trans = trans;
 		conn->bundle = NULL;
-		conn->service_id = service_id;
-		conn->epoch = rxrpc_epoch;
-		conn->in_clientflag = 0;
+		conn->params = *cp;
+		conn->proto.local = cp->local;
+		conn->proto.epoch = rxrpc_epoch;
+		conn->proto.cid = 0;
+		conn->proto.in_clientflag = 0;
+		conn->proto.family = cp->peer->srx.transport.family;
 		conn->out_clientflag = RXRPC_CLIENT_INITIATED;
-		conn->cid = 0;
 		conn->state = RXRPC_CONN_CLIENT;
 		conn->avail_calls = RXRPC_MAXCALLS - 1;
-		conn->security_level = rx->min_sec_level;
-		conn->key = key_get(rx->key);
+
+		key_get(conn->params.key);
 
 		ret = rxrpc_init_client_conn_security(conn);
 		if (ret < 0) {
-			key_put(conn->key);
+			key_put(conn->params.key);
 			kfree(conn);
 			_leave(" = %d [key]", ret);
 			return ret;
@@ -389,7 +391,7 @@ found_channel:
 	conn->channels[chan] = call;
 	call->conn = conn;
 	call->channel = chan;
-	call->cid = conn->cid | chan;
+	call->cid = conn->proto.cid | chan;
 	call->call_id = ++conn->call_counter;
 
 	_net("CONNECT client on conn %d chan %d as call %x",
@@ -412,6 +414,7 @@ no_free_channels:
  * - called in process context with IRQs enabled
  */
 int rxrpc_connect_call(struct rxrpc_sock *rx,
+		       struct rxrpc_conn_parameters *cp,
 		       struct rxrpc_transport *trans,
 		       struct rxrpc_conn_bundle *bundle,
 		       struct rxrpc_call *call,
@@ -425,8 +428,7 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 	_enter("%p,%lx,", rx, call->user_call_ID);
 
 	if (test_bit(RXRPC_SOCK_EXCLUSIVE_CONN, &rx->flags))
-		return rxrpc_connect_exclusive(rx, trans, bundle->service_id,
-					       call, gfp);
+		return rxrpc_connect_exclusive(rx, cp, trans, call, gfp);
 
 	spin_lock(&trans->client_lock);
 	for (;;) {
@@ -517,19 +519,21 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 
 		candidate->trans = trans;
 		candidate->bundle = bundle;
-		candidate->service_id = bundle->service_id;
-		candidate->epoch = rxrpc_epoch;
-		candidate->in_clientflag = 0;
+		candidate->params = *cp;
+		candidate->proto.local = cp->local;
+		candidate->proto.epoch = rxrpc_epoch;
+		candidate->proto.cid = 0;
+		candidate->proto.in_clientflag = 0;
+		candidate->proto.family = cp->peer->srx.transport.family;
 		candidate->out_clientflag = RXRPC_CLIENT_INITIATED;
-		candidate->cid = 0;
 		candidate->state = RXRPC_CONN_CLIENT;
 		candidate->avail_calls = RXRPC_MAXCALLS;
-		candidate->security_level = rx->min_sec_level;
-		candidate->key = key_get(bundle->key);
+
+		key_get(candidate->params.key);
 
 		ret = rxrpc_init_client_conn_security(candidate);
 		if (ret < 0) {
-			key_put(candidate->key);
+			key_put(candidate->params.key);
 			kfree(candidate);
 			_leave(" = %d [key]", ret);
 			return ret;
@@ -577,7 +581,7 @@ found_channel:
 	conn->channels[chan] = call;
 	call->conn = conn;
 	call->channel = chan;
-	call->cid = conn->cid | chan;
+	call->cid = conn->proto.cid | chan;
 	call->call_id = ++conn->call_counter;
 
 	_net("CONNECT client on conn %d chan %d as call %x",
@@ -626,15 +630,15 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 	while (p) {
 		conn = rb_entry(p, struct rxrpc_connection, node);
 
-		_debug("maybe %x", conn->cid);
+		_debug("maybe %x", conn->proto.cid);
 
-		if (epoch < conn->epoch)
+		if (epoch < conn->proto.epoch)
 			p = p->rb_left;
-		else if (epoch > conn->epoch)
+		else if (epoch > conn->proto.epoch)
 			p = p->rb_right;
-		else if (cid < conn->cid)
+		else if (cid < conn->proto.cid)
 			p = p->rb_left;
-		else if (cid > conn->cid)
+		else if (cid > conn->proto.cid)
 			p = p->rb_right;
 		else
 			goto found_extant_connection;
@@ -650,14 +654,17 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 	}
 
 	candidate->trans = trans;
-	candidate->epoch = hdr->epoch;
-	candidate->cid = hdr->cid & RXRPC_CIDMASK;
-	candidate->service_id = hdr->serviceId;
+	candidate->proto.local = trans->local;
+	candidate->proto.epoch = hdr->epoch;
+	candidate->proto.cid = hdr->cid & RXRPC_CIDMASK;
+	candidate->proto.in_clientflag = RXRPC_CLIENT_INITIATED;
+	candidate->params.local = trans->local;
+	candidate->params.peer = trans->peer;
+	candidate->params.service_id = hdr->serviceId;
 	candidate->security_ix = hdr->securityIndex;
-	candidate->in_clientflag = RXRPC_CLIENT_INITIATED;
 	candidate->out_clientflag = 0;
 	candidate->state = RXRPC_CONN_SERVER;
-	if (candidate->service_id)
+	if (candidate->params.service_id)
 		candidate->state = RXRPC_CONN_SERVER_UNSECURED;
 
 	write_lock_bh(&trans->conn_lock);
@@ -668,13 +675,13 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 		p = *pp;
 		conn = rb_entry(p, struct rxrpc_connection, node);
 
-		if (epoch < conn->epoch)
+		if (epoch < conn->proto.epoch)
 			pp = &(*pp)->rb_left;
-		else if (epoch > conn->epoch)
+		else if (epoch > conn->proto.epoch)
 			pp = &(*pp)->rb_right;
-		else if (cid < conn->cid)
+		else if (cid < conn->proto.cid)
 			pp = &(*pp)->rb_left;
-		else if (cid > conn->cid)
+		else if (cid > conn->proto.cid)
 			pp = &(*pp)->rb_right;
 		else
 			goto found_extant_second;
@@ -696,7 +703,7 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 	new = "new";
 
 success:
-	_net("CONNECTION %s %d {%x}", new, conn->debug_id, conn->cid);
+	_net("CONNECTION %s %d {%x}", new, conn->debug_id, conn->proto.cid);
 
 	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
 	return conn;
@@ -754,15 +761,15 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
 	while (p) {
 		conn = rb_entry(p, struct rxrpc_connection, node);
 
-		_debug("maybe %x", conn->cid);
+		_debug("maybe %x", conn->proto.cid);
 
-		if (epoch < conn->epoch)
+		if (epoch < conn->proto.epoch)
 			p = p->rb_left;
-		else if (epoch > conn->epoch)
+		else if (epoch > conn->proto.epoch)
 			p = p->rb_right;
-		else if (cid < conn->cid)
+		else if (cid < conn->proto.cid)
 			p = p->rb_left;
-		else if (cid > conn->cid)
+		else if (cid > conn->proto.cid)
 			p = p->rb_right;
 		else
 			goto found;
@@ -816,7 +823,7 @@ static void rxrpc_destroy_connection(struct rxrpc_connection *conn)
 	rxrpc_purge_queue(&conn->rx_queue);
 
 	conn->security->clear(conn);
-	key_put(conn->key);
+	key_put(conn->params.key);
 	key_put(conn->server_key);
 
 	rxrpc_put_transport(conn->trans);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index e11e4d785127..c030abd4d2d8 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -360,7 +360,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	case RXRPC_PACKET_TYPE_BUSY:
 		_proto("Rx BUSY %%%u", sp->hdr.serial);
 
-		if (call->conn->out_clientflag)
+		if (rxrpc_conn_is_service(call->conn))
 			goto protocol_error;
 
 		write_lock_bh(&call->state_lock);
@@ -533,7 +533,7 @@ static void rxrpc_post_packet_to_call(struct rxrpc_call *call,
 	case RXRPC_CALL_COMPLETE:
 	case RXRPC_CALL_CLIENT_FINAL_ACK:
 		/* complete server call */
-		if (call->conn->in_clientflag)
+		if (rxrpc_conn_is_service(call->conn))
 			goto dead_call;
 		/* resend last packet of a completed call */
 		_debug("final ack again");
diff --git a/net/rxrpc/key.c b/net/rxrpc/key.c
index 4ad56fafe3a7..18c737a61d80 100644
--- a/net/rxrpc/key.c
+++ b/net/rxrpc/key.c
@@ -987,7 +987,7 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
 	if (ret < 0)
 		goto error;
 
-	conn->key = key;
+	conn->params.key = key;
 	_leave(" = 0 [%d]", key_serial(key));
 	return 0;
 
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index e6fb3863b0bc..8c51745cccea 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -133,6 +133,7 @@ static struct rxrpc_call *
 rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 				  unsigned long user_call_ID)
 {
+	struct rxrpc_conn_parameters cp;
 	struct rxrpc_conn_bundle *bundle;
 	struct rxrpc_transport *trans;
 	struct rxrpc_call *call;
@@ -146,23 +147,32 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 	if (!msg->msg_name)
 		return ERR_PTR(-EDESTADDRREQ);
 
-	trans = rxrpc_name_to_transport(rx, msg->msg_name, msg->msg_namelen, 0,
+	key = rx->key;
+	if (key && !rx->key->payload.data[0])
+		key = NULL;
+
+	memset(&cp, 0, sizeof(cp));
+	cp.local		= rx->local;
+	cp.key			= rx->key;
+	cp.security_level	= rx->min_sec_level;
+	cp.exclusive		= test_bit(RXRPC_SOCK_EXCLUSIVE_CONN, &rx->flags);
+	cp.service_id		= srx->srx_service;
+	trans = rxrpc_name_to_transport(&cp, msg->msg_name, msg->msg_namelen,
 					GFP_KERNEL);
 	if (IS_ERR(trans)) {
 		ret = PTR_ERR(trans);
 		goto out;
 	}
+	cp.peer = trans->peer;
 
-	key = rx->key;
-	if (key && !rx->key->payload.data[0])
-		key = NULL;
-	bundle = rxrpc_get_bundle(rx, trans, key, srx->srx_service, GFP_KERNEL);
+	bundle = rxrpc_get_bundle(rx, trans, cp.key, srx->srx_service,
+				  GFP_KERNEL);
 	if (IS_ERR(bundle)) {
 		ret = PTR_ERR(bundle);
 		goto out_trans;
 	}
 
-	call = rxrpc_new_client_call(rx, trans, bundle, user_call_ID,
+	call = rxrpc_new_client_call(rx, &cp, trans, bundle, user_call_ID,
 				     GFP_KERNEL);
 	rxrpc_put_bundle(trans, bundle);
 	rxrpc_put_transport(trans);
@@ -664,7 +674,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 			seq = atomic_inc_return(&call->sequence);
 
-			sp->hdr.epoch	= conn->epoch;
+			sp->hdr.epoch	= conn->proto.epoch;
 			sp->hdr.cid	= call->cid;
 			sp->hdr.callNumber = call->call_id;
 			sp->hdr.seq	= seq;
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index 225163bc658d..bbee05850801 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -74,10 +74,10 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 		   " %-8.8s %08x %lx\n",
 		   lbuff,
 		   rbuff,
-		   call->conn->service_id,
+		   call->conn->params.service_id,
 		   call->cid,
 		   call->call_id,
-		   call->conn->in_clientflag ? "Svc" : "Clt",
+		   rxrpc_conn_is_service(call->conn) ? "Svc" : "Clt",
 		   atomic_read(&call->usage),
 		   rxrpc_call_states[call->state],
 		   call->remote_abort ?: call->local_abort,
@@ -157,13 +157,13 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 		   " %s %08x %08x %08x\n",
 		   lbuff,
 		   rbuff,
-		   conn->service_id,
-		   conn->cid,
+		   conn->params.service_id,
+		   conn->proto.cid,
 		   conn->call_counter,
-		   conn->in_clientflag ? "Svc" : "Clt",
+		   rxrpc_conn_is_service(conn) ? "Svc" : "Clt",
 		   atomic_read(&conn->usage),
 		   rxrpc_conn_states[conn->state],
-		   key_serial(conn->key),
+		   key_serial(conn->params.key),
 		   atomic_read(&conn->serial),
 		   atomic_read(&conn->hi_serial));
 
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 59706b9f2f7a..c5bac4e0db71 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -205,7 +205,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		/* we transferred the whole data packet */
 		if (sp->hdr.flags & RXRPC_LAST_PACKET) {
 			_debug("last");
-			if (call->conn->out_clientflag) {
+			if (rxrpc_conn_is_client(call->conn)) {
 				 /* last byte of reply received */
 				ret = copied;
 				goto terminal_message;
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 36a634027d9d..134c2713ae23 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -58,9 +58,9 @@ static int rxkad_init_connection_security(struct rxrpc_connection *conn)
 	struct rxrpc_key_token *token;
 	int ret;
 
-	_enter("{%d},{%x}", conn->debug_id, key_serial(conn->key));
+	_enter("{%d},{%x}", conn->debug_id, key_serial(conn->params.key));
 
-	token = conn->key->payload.data[0];
+	token = conn->params.key->payload.data[0];
 	conn->security_ix = token->security_index;
 
 	ci = crypto_alloc_skcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
@@ -74,7 +74,7 @@ static int rxkad_init_connection_security(struct rxrpc_connection *conn)
 				   sizeof(token->kad->session_key)) < 0)
 		BUG();
 
-	switch (conn->security_level) {
+	switch (conn->params.security_level) {
 	case RXRPC_SECURITY_PLAIN:
 		break;
 	case RXRPC_SECURITY_AUTH:
@@ -115,14 +115,14 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 
 	_enter("");
 
-	if (!conn->key)
+	if (!conn->params.key)
 		return;
 
-	token = conn->key->payload.data[0];
+	token = conn->params.key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 
-	tmpbuf.x[0] = htonl(conn->epoch);
-	tmpbuf.x[1] = htonl(conn->cid);
+	tmpbuf.x[0] = htonl(conn->proto.epoch);
+	tmpbuf.x[1] = htonl(conn->proto.cid);
 	tmpbuf.x[2] = 0;
 	tmpbuf.x[3] = htonl(conn->security_ix);
 
@@ -220,7 +220,7 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	rxkhdr.checksum = 0;
 
 	/* encrypt from the session key */
-	token = call->conn->key->payload.data[0];
+	token = call->conn->params.key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 
 	sg_init_one(&sg[0], sechdr, sizeof(rxkhdr));
@@ -277,13 +277,13 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	sp = rxrpc_skb(skb);
 
 	_enter("{%d{%x}},{#%u},%zu,",
-	       call->debug_id, key_serial(call->conn->key), sp->hdr.seq,
-	       data_size);
+	       call->debug_id, key_serial(call->conn->params.key),
+	       sp->hdr.seq, data_size);
 
 	if (!call->conn->cipher)
 		return 0;
 
-	ret = key_validate(call->conn->key);
+	ret = key_validate(call->conn->params.key);
 	if (ret < 0)
 		return ret;
 
@@ -312,7 +312,7 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 		y = 1; /* zero checksums are not permitted */
 	sp->hdr.cksum = y;
 
-	switch (call->conn->security_level) {
+	switch (call->conn->params.security_level) {
 	case RXRPC_SECURITY_PLAIN:
 		ret = 0;
 		break;
@@ -446,7 +446,7 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	skb_to_sgvec(skb, sg, 0, skb->len);
 
 	/* decrypt from the session key */
-	token = call->conn->key->payload.data[0];
+	token = call->conn->params.key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 
 	skcipher_request_set_tfm(req, call->conn->cipher);
@@ -516,7 +516,7 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 	sp = rxrpc_skb(skb);
 
 	_enter("{%d{%x}},{#%u}",
-	       call->debug_id, key_serial(call->conn->key), sp->hdr.seq);
+	       call->debug_id, key_serial(call->conn->params.key), sp->hdr.seq);
 
 	if (!call->conn->cipher)
 		return 0;
@@ -557,7 +557,7 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 		return -EPROTO;
 	}
 
-	switch (call->conn->security_level) {
+	switch (call->conn->params.security_level) {
 	case RXRPC_SECURITY_PLAIN:
 		ret = 0;
 		break;
@@ -589,9 +589,9 @@ static int rxkad_issue_challenge(struct rxrpc_connection *conn)
 	u32 serial;
 	int ret;
 
-	_enter("{%d,%x}", conn->debug_id, key_serial(conn->key));
+	_enter("{%d,%x}", conn->debug_id, key_serial(conn->params.key));
 
-	ret = key_validate(conn->key);
+	ret = key_validate(conn->params.key);
 	if (ret < 0)
 		return ret;
 
@@ -608,8 +608,8 @@ static int rxkad_issue_challenge(struct rxrpc_connection *conn)
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
 
-	whdr.epoch	= htonl(conn->epoch);
-	whdr.cid	= htonl(conn->cid);
+	whdr.epoch	= htonl(conn->proto.epoch);
+	whdr.cid	= htonl(conn->proto.cid);
 	whdr.callNumber	= 0;
 	whdr.seq	= 0;
 	whdr.type	= RXRPC_PACKET_TYPE_CHALLENGE;
@@ -617,7 +617,7 @@ static int rxkad_issue_challenge(struct rxrpc_connection *conn)
 	whdr.userStatus	= 0;
 	whdr.securityIndex = conn->security_ix;
 	whdr._rsvd	= 0;
-	whdr.serviceId	= htons(conn->service_id);
+	whdr.serviceId	= htons(conn->params.service_id);
 
 	iov[0].iov_base	= &whdr;
 	iov[0].iov_len	= sizeof(whdr);
@@ -771,14 +771,14 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	u32 version, nonce, min_level, abort_code;
 	int ret;
 
-	_enter("{%d,%x}", conn->debug_id, key_serial(conn->key));
+	_enter("{%d,%x}", conn->debug_id, key_serial(conn->params.key));
 
-	if (!conn->key) {
+	if (!conn->params.key) {
 		_leave(" = -EPROTO [no key]");
 		return -EPROTO;
 	}
 
-	ret = key_validate(conn->key);
+	ret = key_validate(conn->params.key);
 	if (ret < 0) {
 		*_abort_code = RXKADEXPIRED;
 		return ret;
@@ -801,20 +801,20 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 		goto protocol_error;
 
 	abort_code = RXKADLEVELFAIL;
-	if (conn->security_level < min_level)
+	if (conn->params.security_level < min_level)
 		goto protocol_error;
 
-	token = conn->key->payload.data[0];
+	token = conn->params.key->payload.data[0];
 
 	/* build the response packet */
 	memset(&resp, 0, sizeof(resp));
 
 	resp.version			= htonl(RXKAD_VERSION);
-	resp.encrypted.epoch		= htonl(conn->epoch);
-	resp.encrypted.cid		= htonl(conn->cid);
+	resp.encrypted.epoch		= htonl(conn->proto.epoch);
+	resp.encrypted.cid		= htonl(conn->proto.cid);
 	resp.encrypted.securityIndex	= htonl(conn->security_ix);
 	resp.encrypted.inc_nonce	= htonl(nonce + 1);
-	resp.encrypted.level		= htonl(conn->security_level);
+	resp.encrypted.level		= htonl(conn->params.security_level);
 	resp.kvno			= htonl(token->kad->kvno);
 	resp.ticket_len			= htonl(token->kad->ticket_len);
 
@@ -1096,9 +1096,9 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	rxkad_decrypt_response(conn, &response, &session_key);
 
 	abort_code = RXKADSEALEDINCON;
-	if (ntohl(response.encrypted.epoch) != conn->epoch)
+	if (ntohl(response.encrypted.epoch) != conn->proto.epoch)
 		goto protocol_error_free;
-	if (ntohl(response.encrypted.cid) != conn->cid)
+	if (ntohl(response.encrypted.cid) != conn->proto.cid)
 		goto protocol_error_free;
 	if (ntohl(response.encrypted.securityIndex) != conn->security_ix)
 		goto protocol_error_free;
@@ -1122,7 +1122,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	level = ntohl(response.encrypted.level);
 	if (level > RXRPC_SECURITY_ENCRYPT)
 		goto protocol_error_free;
-	conn->security_level = level;
+	conn->params.security_level = level;
 
 	/* create a key to hold the security data and expiration time - after
 	 * this the connection security can be handled in exactly the same way
diff --git a/net/rxrpc/security.c b/net/rxrpc/security.c
index d223253b22fa..40955d0f2693 100644
--- a/net/rxrpc/security.c
+++ b/net/rxrpc/security.c
@@ -76,7 +76,7 @@ int rxrpc_init_client_conn_security(struct rxrpc_connection *conn)
 {
 	const struct rxrpc_security *sec;
 	struct rxrpc_key_token *token;
-	struct key *key = conn->key;
+	struct key *key = conn->params.key;
 	int ret;
 
 	_enter("{%d},{%x}", conn->debug_id, key_serial(key));
@@ -121,7 +121,7 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 
 	_enter("");
 
-	sprintf(kdesc, "%u:%u", conn->service_id, conn->security_ix);
+	sprintf(kdesc, "%u:%u", conn->params.service_id, conn->security_ix);
 
 	sec = rxrpc_security_lookup(conn->security_ix);
 	if (!sec) {
@@ -132,7 +132,7 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 	/* find the service */
 	read_lock_bh(&local->services_lock);
 	list_for_each_entry(rx, &local->services, listen_link) {
-		if (rx->srx.srx_service == conn->service_id)
+		if (rx->srx.srx_service == conn->params.service_id)
 			goto found_service;
 	}
 
