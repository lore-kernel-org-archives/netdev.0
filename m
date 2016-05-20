From: David Howells <dhowells@redhat.com>
Subject: rxrpc: Simplify connect() implementation and simplify sendmsg() op
Date: Fri, 20 May 2016 13:37:29 +0100
Message-ID: <7818.1463747849@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-ID: <7817.1463747849.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Are you okay with taking this into net-next?

I no longer take away the ability to do connect(), but now it does nothing
more than specify a default address and mark the socket as being client
only.  As before, the default address is overridden if sendmsg() is given
an address.

The other significant UAPI change is that I deal better with a race between
two threads trying to register calls with the same user ID (one of them
will get an error).

David
---
rxrpc: Simplify connect() implementation and simplify sendmsg() op

Simplify the RxRPC connect() implementation.  It will just note the
destination address it is given, and if a sendmsg() comes along with no
address, this will be assigned as the address.  No transport struct will be
held internally, which will allow us to remove this later.

Simplify sendmsg() also.  Whilst a call is active, userspace refers to it
by a private unique user ID specified in a control message.  When sendmsg()
sees a user ID that doesn't map to an extant call, it creates a new call
for that user ID and attempts to add it.  If, when we try to add it, the
user ID is now registered, we now reject the message with -EEXIST.  We
should never see this situation unless two threads are racing, trying to
create a call with the same ID - which would be an error.

It also isn't required to provide sendmsg() with an address - provided the
control message data holds a user ID that maps to a currently active call.

Signed-off-by: David Howells <dhowells@redhat.com>
---
 include/linux/rxrpc.h     |   18 ++--
 net/rxrpc/af_rxrpc.c      |  177 +++++++++++++++----------------------------
 net/rxrpc/ar-call.c       |  158 +++++++++++++++------------------------
 net/rxrpc/ar-connection.c |   17 ----
 net/rxrpc/ar-internal.h   |   22 ++---
 net/rxrpc/ar-output.c     |  186 +++++++++++++++++++++-------------------------
 6 files changed, 234 insertions(+), 344 deletions(-)

diff --git a/include/linux/rxrpc.h b/include/linux/rxrpc.h
index a53915cd5581..1e8f216e2cf1 100644
--- a/include/linux/rxrpc.h
+++ b/include/linux/rxrpc.h
@@ -40,16 +40,18 @@ struct sockaddr_rxrpc {
 
 /*
  * RxRPC control messages
+ * - If neither abort or accept are specified, the message is a data message.
  * - terminal messages mean that a user call ID tag can be recycled
+ * - s/r/- indicate whether these are applicable to sendmsg() and/or recvmsg()
  */
-#define RXRPC_USER_CALL_ID	1	/* user call ID specifier */
-#define RXRPC_ABORT		2	/* abort request / notification [terminal] */
-#define RXRPC_ACK		3	/* [Server] RPC op final ACK received [terminal] */
-#define RXRPC_NET_ERROR		5	/* network error received [terminal] */
-#define RXRPC_BUSY		6	/* server busy received [terminal] */
-#define RXRPC_LOCAL_ERROR	7	/* local error generated [terminal] */
-#define RXRPC_NEW_CALL		8	/* [Server] new incoming call notification */
-#define RXRPC_ACCEPT		9	/* [Server] accept request */
+#define RXRPC_USER_CALL_ID	1	/* sr: user call ID specifier */
+#define RXRPC_ABORT		2	/* sr: abort request / notification [terminal] */
+#define RXRPC_ACK		3	/* -r: [Service] RPC op final ACK received [terminal] */
+#define RXRPC_NET_ERROR		5	/* -r: network error received [terminal] */
+#define RXRPC_BUSY		6	/* -r: server busy received [terminal] */
+#define RXRPC_LOCAL_ERROR	7	/* -r: local error generated [terminal] */
+#define RXRPC_NEW_CALL		8	/* -r: [Service] new incoming call notification */
+#define RXRPC_ACCEPT		9	/* s-: [Service] accept request */
 
 /*
  * RxRPC security levels
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index e45e94ca030f..484b5ee16a50 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -137,33 +137,33 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 
 	lock_sock(&rx->sk);
 
-	if (rx->sk.sk_state != RXRPC_UNCONNECTED) {
+	if (rx->sk.sk_state != RXRPC_UNBOUND) {
 		ret = -EINVAL;
 		goto error_unlock;
 	}
 
 	memcpy(&rx->srx, srx, sizeof(rx->srx));
 
-	/* Find or create a local transport endpoint to use */
 	local = rxrpc_lookup_local(&rx->srx);
 	if (IS_ERR(local)) {
 		ret = PTR_ERR(local);
 		goto error_unlock;
 	}
 
-	rx->local = local;
-	if (srx->srx_service) {
+	if (rx->srx.srx_service) {
 		write_lock_bh(&local->services_lock);
 		list_for_each_entry(prx, &local->services, listen_link) {
-			if (prx->srx.srx_service == srx->srx_service)
+			if (prx->srx.srx_service == rx->srx.srx_service)
 				goto service_in_use;
 		}
 
+		rx->local = local;
 		list_add_tail(&rx->listen_link, &local->services);
 		write_unlock_bh(&local->services_lock);
 
 		rx->sk.sk_state = RXRPC_SERVER_BOUND;
 	} else {
+		rx->local = local;
 		rx->sk.sk_state = RXRPC_CLIENT_BOUND;
 	}
 
@@ -172,8 +172,9 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 	return 0;
 
 service_in_use:
-	ret = -EADDRINUSE;
 	write_unlock_bh(&local->services_lock);
+	rxrpc_put_local(local);
+	ret = -EADDRINUSE;
 error_unlock:
 	release_sock(&rx->sk);
 error:
@@ -195,11 +196,11 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 	lock_sock(&rx->sk);
 
 	switch (rx->sk.sk_state) {
-	case RXRPC_UNCONNECTED:
+	case RXRPC_UNBOUND:
 		ret = -EADDRNOTAVAIL;
 		break;
+	case RXRPC_CLIENT_UNBOUND:
 	case RXRPC_CLIENT_BOUND:
-	case RXRPC_CLIENT_CONNECTED:
 	default:
 		ret = -EBUSY;
 		break;
@@ -219,20 +220,18 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 /*
  * find a transport by address
  */
-static struct rxrpc_transport *rxrpc_name_to_transport(struct socket *sock,
-						       struct sockaddr *addr,
-						       int addr_len, int flags,
-						       gfp_t gfp)
+struct rxrpc_transport *rxrpc_name_to_transport(struct rxrpc_sock *rx,
+						struct sockaddr *addr,
+						int addr_len, int flags,
+						gfp_t gfp)
 {
 	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *) addr;
 	struct rxrpc_transport *trans;
-	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
 	struct rxrpc_peer *peer;
 
 	_enter("%p,%p,%d,%d", rx, addr, addr_len, flags);
 
 	ASSERT(rx->local != NULL);
-	ASSERT(rx->sk.sk_state > RXRPC_UNCONNECTED);
 
 	if (rx->srx.transport_type != srx->transport_type)
 		return ERR_PTR(-ESOCKTNOSUPPORT);
@@ -254,7 +253,7 @@ static struct rxrpc_transport *rxrpc_name_to_transport(struct socket *sock,
 /**
  * rxrpc_kernel_begin_call - Allow a kernel service to begin a call
  * @sock: The socket on which to make the call
- * @srx: The address of the peer to contact (defaults to socket setting)
+ * @srx: The address of the peer to contact
  * @key: The security context to use (defaults to socket setting)
  * @user_call_ID: The ID to use
  *
@@ -280,25 +279,14 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 
 	lock_sock(&rx->sk);
 
-	if (srx) {
-		trans = rxrpc_name_to_transport(sock, (struct sockaddr *) srx,
-						sizeof(*srx), 0, gfp);
-		if (IS_ERR(trans)) {
-			call = ERR_CAST(trans);
-			trans = NULL;
-			goto out_notrans;
-		}
-	} else {
-		trans = rx->trans;
-		if (!trans) {
-			call = ERR_PTR(-ENOTCONN);
-			goto out_notrans;
-		}
-		atomic_inc(&trans->usage);
+	trans = rxrpc_name_to_transport(rx, (struct sockaddr *)srx,
+					sizeof(*srx), 0, gfp);
+	if (IS_ERR(trans)) {
+		call = ERR_CAST(trans);
+		trans = NULL;
+		goto out_notrans;
 	}
 
-	if (!srx)
-		srx = &rx->srx;
 	if (!key)
 		key = rx->key;
 	if (key && !key->payload.data[0])
@@ -310,8 +298,7 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 		goto out;
 	}
 
-	call = rxrpc_get_client_call(rx, trans, bundle, user_call_ID, true,
-				     gfp);
+	call = rxrpc_new_client_call(rx, trans, bundle, user_call_ID, gfp);
 	rxrpc_put_bundle(trans, bundle);
 out:
 	rxrpc_put_transport(trans);
@@ -367,11 +354,8 @@ EXPORT_SYMBOL(rxrpc_kernel_intercept_rx_messages);
 static int rxrpc_connect(struct socket *sock, struct sockaddr *addr,
 			 int addr_len, int flags)
 {
-	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *) addr;
-	struct sock *sk = sock->sk;
-	struct rxrpc_transport *trans;
-	struct rxrpc_local *local;
-	struct rxrpc_sock *rx = rxrpc_sk(sk);
+	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *)addr;
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
 	int ret;
 
 	_enter("%p,%p,%d,%d", rx, addr, addr_len, flags);
@@ -384,45 +368,28 @@ static int rxrpc_connect(struct socket *sock, struct sockaddr *addr,
 
 	lock_sock(&rx->sk);
 
+	ret = -EISCONN;
+	if (test_bit(RXRPC_SOCK_CONNECTED, &rx->flags))
+		goto error;
+	
 	switch (rx->sk.sk_state) {
-	case RXRPC_UNCONNECTED:
-		/* find a local transport endpoint if we don't have one already */
-		ASSERTCMP(rx->local, ==, NULL);
-		rx->srx.srx_family = AF_RXRPC;
-		rx->srx.srx_service = 0;
-		rx->srx.transport_type = srx->transport_type;
-		rx->srx.transport_len = sizeof(sa_family_t);
-		rx->srx.transport.family = srx->transport.family;
-		local = rxrpc_lookup_local(&rx->srx);
-		if (IS_ERR(local)) {
-			release_sock(&rx->sk);
-			return PTR_ERR(local);
-		}
-		rx->local = local;
-		rx->sk.sk_state = RXRPC_CLIENT_BOUND;
+	case RXRPC_UNBOUND:
+		rx->sk.sk_state = RXRPC_CLIENT_UNBOUND;
+	case RXRPC_CLIENT_UNBOUND:
 	case RXRPC_CLIENT_BOUND:
 		break;
-	case RXRPC_CLIENT_CONNECTED:
-		release_sock(&rx->sk);
-		return -EISCONN;
 	default:
-		release_sock(&rx->sk);
-		return -EBUSY; /* server sockets can't connect as well */
-	}
-
-	trans = rxrpc_name_to_transport(sock, addr, addr_len, flags,
-					GFP_KERNEL);
-	if (IS_ERR(trans)) {
-		release_sock(&rx->sk);
-		_leave(" = %ld", PTR_ERR(trans));
-		return PTR_ERR(trans);
+		ret = -EBUSY;
+		goto error;
 	}
 
-	rx->trans = trans;
-	rx->sk.sk_state = RXRPC_CLIENT_CONNECTED;
+	rx->connect_srx = *srx;
+	set_bit(RXRPC_SOCK_CONNECTED, &rx->flags);
+	ret = 0;
 
+error:
 	release_sock(&rx->sk);
-	return 0;
+	return ret;
 }
 
 /*
@@ -436,7 +403,7 @@ static int rxrpc_connect(struct socket *sock, struct sockaddr *addr,
  */
 static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 {
-	struct rxrpc_transport *trans;
+	struct rxrpc_local *local;
 	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
 	int ret;
 
@@ -453,48 +420,38 @@ static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 		}
 	}
 
-	trans = NULL;
 	lock_sock(&rx->sk);
 
-	if (m->msg_name) {
-		ret = -EISCONN;
-		trans = rxrpc_name_to_transport(sock, m->msg_name,
-						m->msg_namelen, 0, GFP_KERNEL);
-		if (IS_ERR(trans)) {
-			ret = PTR_ERR(trans);
-			trans = NULL;
-			goto out;
-		}
-	} else {
-		trans = rx->trans;
-		if (trans)
-			atomic_inc(&trans->usage);
-	}
-
 	switch (rx->sk.sk_state) {
-	case RXRPC_SERVER_LISTENING:
-		if (!m->msg_name) {
-			ret = rxrpc_server_sendmsg(rx, m, len);
-			break;
+	case RXRPC_UNBOUND:
+		local = rxrpc_lookup_local(&rx->srx);
+		if (IS_ERR(local)) {
+			ret = PTR_ERR(local);
+			goto error_unlock;
 		}
-	case RXRPC_SERVER_BOUND:
+
+		rx->local = local;
+		rx->sk.sk_state = RXRPC_CLIENT_UNBOUND;
+		/* Fall through */
+
+	case RXRPC_CLIENT_UNBOUND:
 	case RXRPC_CLIENT_BOUND:
-		if (!m->msg_name) {
-			ret = -ENOTCONN;
-			break;
+		if (!m->msg_name &&
+		    test_bit(RXRPC_SOCK_CONNECTED, &rx->flags)) {
+			m->msg_name = &rx->connect_srx;
+			m->msg_namelen = sizeof(rx->connect_srx);
 		}
-	case RXRPC_CLIENT_CONNECTED:
-		ret = rxrpc_client_sendmsg(rx, trans, m, len);
+	case RXRPC_SERVER_BOUND:
+	case RXRPC_SERVER_LISTENING:
+		ret = rxrpc_do_sendmsg(rx, m, len);
 		break;
 	default:
-		ret = -ENOTCONN;
+		ret = -EINVAL;
 		break;
 	}
 
-out:
+error_unlock:
 	release_sock(&rx->sk);
-	if (trans)
-		rxrpc_put_transport(trans);
 	_leave(" = %d", ret);
 	return ret;
 }
@@ -521,7 +478,7 @@ static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
 			if (optlen != 0)
 				goto error;
 			ret = -EISCONN;
-			if (rx->sk.sk_state != RXRPC_UNCONNECTED)
+			if (rx->sk.sk_state != RXRPC_UNBOUND)
 				goto error;
 			set_bit(RXRPC_SOCK_EXCLUSIVE_CONN, &rx->flags);
 			goto success;
@@ -531,7 +488,7 @@ static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
 			if (rx->key)
 				goto error;
 			ret = -EISCONN;
-			if (rx->sk.sk_state != RXRPC_UNCONNECTED)
+			if (rx->sk.sk_state != RXRPC_UNBOUND)
 				goto error;
 			ret = rxrpc_request_key(rx, optval, optlen);
 			goto error;
@@ -541,7 +498,7 @@ static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
 			if (rx->key)
 				goto error;
 			ret = -EISCONN;
-			if (rx->sk.sk_state != RXRPC_UNCONNECTED)
+			if (rx->sk.sk_state != RXRPC_UNBOUND)
 				goto error;
 			ret = rxrpc_server_keyring(rx, optval, optlen);
 			goto error;
@@ -551,7 +508,7 @@ static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
 			if (optlen != sizeof(unsigned int))
 				goto error;
 			ret = -EISCONN;
-			if (rx->sk.sk_state != RXRPC_UNCONNECTED)
+			if (rx->sk.sk_state != RXRPC_UNBOUND)
 				goto error;
 			ret = get_user(min_sec_level,
 				       (unsigned int __user *) optval);
@@ -630,7 +587,7 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 		return -ENOMEM;
 
 	sock_init_data(sock, sk);
-	sk->sk_state		= RXRPC_UNCONNECTED;
+	sk->sk_state		= RXRPC_UNBOUND;
 	sk->sk_write_space	= rxrpc_write_space;
 	sk->sk_max_ack_backlog	= sysctl_rxrpc_max_qlen;
 	sk->sk_destruct		= rxrpc_sock_destructor;
@@ -703,14 +660,6 @@ static int rxrpc_release_sock(struct sock *sk)
 		rx->conn = NULL;
 	}
 
-	if (rx->bundle) {
-		rxrpc_put_bundle(rx->trans, rx->bundle);
-		rx->bundle = NULL;
-	}
-	if (rx->trans) {
-		rxrpc_put_transport(rx->trans);
-		rx->trans = NULL;
-	}
 	if (rx->local) {
 		rxrpc_put_local(rx->local);
 		rx->local = NULL;
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 571a41fd5a32..9296bdb26c24 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -194,6 +194,43 @@ struct rxrpc_call *rxrpc_find_call_hash(
 }
 
 /*
+ * find an extant server call
+ * - called in process context with IRQs enabled
+ */
+struct rxrpc_call *rxrpc_find_call_by_user_ID(struct rxrpc_sock *rx,
+					      unsigned long user_call_ID)
+{
+	struct rxrpc_call *call;
+	struct rb_node *p;
+
+	_enter("%p,%lx", rx, user_call_ID);
+
+	read_lock(&rx->call_lock);
+
+	p = rx->calls.rb_node;
+	while (p) {
+		call = rb_entry(p, struct rxrpc_call, sock_node);
+
+		if (user_call_ID < call->user_call_ID)
+			p = p->rb_left;
+		else if (user_call_ID > call->user_call_ID)
+			p = p->rb_right;
+		else
+			goto found_extant_call;
+	}
+
+	read_unlock(&rx->call_lock);
+	_leave(" = NULL");
+	return NULL;
+
+found_extant_call:
+	rxrpc_get_call(call);
+	read_unlock(&rx->call_lock);
+	_leave(" = %p [%d]", call, atomic_read(&call->usage));
+	return call;
+}
+
+/*
  * allocate a new call
  */
 static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
@@ -309,51 +346,27 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
  * set up a call for the given data
  * - called in process context with IRQs enabled
  */
-struct rxrpc_call *rxrpc_get_client_call(struct rxrpc_sock *rx,
+struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 					 struct rxrpc_transport *trans,
 					 struct rxrpc_conn_bundle *bundle,
 					 unsigned long user_call_ID,
-					 int create,
 					 gfp_t gfp)
 {
-	struct rxrpc_call *call, *candidate;
-	struct rb_node *p, *parent, **pp;
+	struct rxrpc_call *call, *xcall;
+	struct rb_node *parent, **pp;
 
-	_enter("%p,%d,%d,%lx,%d",
-	       rx, trans ? trans->debug_id : -1, bundle ? bundle->debug_id : -1,
-	       user_call_ID, create);
+	_enter("%p,%d,%d,%lx",
+	       rx, trans->debug_id, bundle ? bundle->debug_id : -1,
+	       user_call_ID);
 
-	/* search the extant calls first for one that matches the specified
-	 * user ID */
-	read_lock(&rx->call_lock);
-
-	p = rx->calls.rb_node;
-	while (p) {
-		call = rb_entry(p, struct rxrpc_call, sock_node);
-
-		if (user_call_ID < call->user_call_ID)
-			p = p->rb_left;
-		else if (user_call_ID > call->user_call_ID)
-			p = p->rb_right;
-		else
-			goto found_extant_call;
+	call = rxrpc_alloc_client_call(rx, trans, bundle, gfp);
+	if (IS_ERR(call)) {
+		_leave(" = %ld", PTR_ERR(call));
+		return call;
 	}
 
-	read_unlock(&rx->call_lock);
-
-	if (!create || !trans)
-		return ERR_PTR(-EBADSLT);
-
-	/* not yet present - create a candidate for a new record and then
-	 * redo the search */
-	candidate = rxrpc_alloc_client_call(rx, trans, bundle, gfp);
-	if (IS_ERR(candidate)) {
-		_leave(" = %ld", PTR_ERR(candidate));
-		return candidate;
-	}
-
-	candidate->user_call_ID = user_call_ID;
-	__set_bit(RXRPC_CALL_HAS_USERID, &candidate->flags);
+	call->user_call_ID = user_call_ID;
+	__set_bit(RXRPC_CALL_HAS_USERID, &call->flags);
 
 	write_lock(&rx->call_lock);
 
@@ -361,19 +374,16 @@ struct rxrpc_call *rxrpc_get_client_call(struct rxrpc_sock *rx,
 	parent = NULL;
 	while (*pp) {
 		parent = *pp;
-		call = rb_entry(parent, struct rxrpc_call, sock_node);
+		xcall = rb_entry(parent, struct rxrpc_call, sock_node);
 
-		if (user_call_ID < call->user_call_ID)
+		if (user_call_ID < xcall->user_call_ID)
 			pp = &(*pp)->rb_left;
-		else if (user_call_ID > call->user_call_ID)
+		else if (user_call_ID > xcall->user_call_ID)
 			pp = &(*pp)->rb_right;
 		else
-			goto found_extant_second;
+			goto found_user_ID_now_present;
 	}
 
-	/* second search also failed; add the new call */
-	call = candidate;
-	candidate = NULL;
 	rxrpc_get_call(call);
 
 	rb_link_node(&call->sock_node, parent, pp);
@@ -389,20 +399,16 @@ struct rxrpc_call *rxrpc_get_client_call(struct rxrpc_sock *rx,
 	_leave(" = %p [new]", call);
 	return call;
 
-	/* we found the call in the list immediately */
-found_extant_call:
-	rxrpc_get_call(call);
-	read_unlock(&rx->call_lock);
-	_leave(" = %p [extant %d]", call, atomic_read(&call->usage));
-	return call;
-
-	/* we found the call on the second time through the list */
-found_extant_second:
-	rxrpc_get_call(call);
+	/* We unexpectedly found the user ID in the list after taking
+	 * the call_lock.  This shouldn't happen unless the user races
+	 * with itself and tries to add the same user ID twice at the
+	 * same time in different threads.
+	 */
+found_user_ID_now_present:
 	write_unlock(&rx->call_lock);
-	rxrpc_put_call(candidate);
-	_leave(" = %p [second %d]", call, atomic_read(&call->usage));
-	return call;
+	rxrpc_put_call(call);
+	_leave(" = -EEXIST [%p]", call);
+	return ERR_PTR(-EEXIST);
 }
 
 /*
@@ -564,46 +570,6 @@ old_call:
 }
 
 /*
- * find an extant server call
- * - called in process context with IRQs enabled
- */
-struct rxrpc_call *rxrpc_find_server_call(struct rxrpc_sock *rx,
-					  unsigned long user_call_ID)
-{
-	struct rxrpc_call *call;
-	struct rb_node *p;
-
-	_enter("%p,%lx", rx, user_call_ID);
-
-	/* search the extant calls for one that matches the specified user
-	 * ID */
-	read_lock(&rx->call_lock);
-
-	p = rx->calls.rb_node;
-	while (p) {
-		call = rb_entry(p, struct rxrpc_call, sock_node);
-
-		if (user_call_ID < call->user_call_ID)
-			p = p->rb_left;
-		else if (user_call_ID > call->user_call_ID)
-			p = p->rb_right;
-		else
-			goto found_extant_call;
-	}
-
-	read_unlock(&rx->call_lock);
-	_leave(" = NULL");
-	return NULL;
-
-	/* we found the call in the list immediately */
-found_extant_call:
-	rxrpc_get_call(call);
-	read_unlock(&rx->call_lock);
-	_leave(" = %p [%d]", call, atomic_read(&call->usage));
-	return call;
-}
-
-/*
  * detach a call from a socket and set up for release
  */
 void rxrpc_release_call(struct rxrpc_call *call)
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 97f4fae74bca..5307dba4a13a 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -78,11 +78,6 @@ struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
 	_enter("%p{%x},%x,%hx,",
 	       rx, key_serial(key), trans->debug_id, service_id);
 
-	if (rx->trans == trans && rx->bundle) {
-		atomic_inc(&rx->bundle->usage);
-		return rx->bundle;
-	}
-
 	/* search the extant bundles first for one that matches the specified
 	 * user ID */
 	spin_lock(&trans->client_lock);
@@ -136,10 +131,6 @@ struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
 	rb_insert_color(&bundle->node, &trans->bundles);
 	spin_unlock(&trans->client_lock);
 	_net("BUNDLE new on trans %d", trans->debug_id);
-	if (!rx->bundle && rx->sk.sk_state == RXRPC_CLIENT_CONNECTED) {
-		atomic_inc(&bundle->usage);
-		rx->bundle = bundle;
-	}
 	_leave(" = %p [new]", bundle);
 	return bundle;
 
@@ -148,10 +139,6 @@ found_extant_bundle:
 	atomic_inc(&bundle->usage);
 	spin_unlock(&trans->client_lock);
 	_net("BUNDLE old on trans %d", trans->debug_id);
-	if (!rx->bundle && rx->sk.sk_state == RXRPC_CLIENT_CONNECTED) {
-		atomic_inc(&bundle->usage);
-		rx->bundle = bundle;
-	}
 	_leave(" = %p [extant %d]", bundle, atomic_read(&bundle->usage));
 	return bundle;
 
@@ -161,10 +148,6 @@ found_extant_second:
 	spin_unlock(&trans->client_lock);
 	kfree(candidate);
 	_net("BUNDLE old2 on trans %d", trans->debug_id);
-	if (!rx->bundle && rx->sk.sk_state == RXRPC_CLIENT_CONNECTED) {
-		atomic_inc(&bundle->usage);
-		rx->bundle = bundle;
-	}
 	_leave(" = %p [second %d]", bundle, atomic_read(&bundle->usage));
 	return bundle;
 }
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index f0b807a163fa..65fc3464fad1 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -39,9 +39,9 @@ struct rxrpc_crypt {
  * sk_state for RxRPC sockets
  */
 enum {
-	RXRPC_UNCONNECTED = 0,
+	RXRPC_UNBOUND = 0,
+	RXRPC_CLIENT_UNBOUND,		/* Unbound socket used as client */
 	RXRPC_CLIENT_BOUND,		/* client local address bound */
-	RXRPC_CLIENT_CONNECTED,		/* client is connected */
 	RXRPC_SERVER_BOUND,		/* server local address bound */
 	RXRPC_SERVER_LISTENING,		/* server listening for connections */
 	RXRPC_CLOSE,			/* socket is being closed */
@@ -55,8 +55,6 @@ struct rxrpc_sock {
 	struct sock		sk;
 	rxrpc_interceptor_t	interceptor;	/* kernel service Rx interceptor function */
 	struct rxrpc_local	*local;		/* local endpoint */
-	struct rxrpc_transport	*trans;		/* transport handler */
-	struct rxrpc_conn_bundle *bundle;	/* virtual connection bundle */
 	struct rxrpc_connection	*conn;		/* exclusive virtual connection */
 	struct list_head	listen_link;	/* link in the local endpoint's listen list */
 	struct list_head	secureq;	/* calls awaiting connection security clearance */
@@ -65,11 +63,13 @@ struct rxrpc_sock {
 	struct key		*securities;	/* list of server security descriptors */
 	struct rb_root		calls;		/* outstanding calls on this socket */
 	unsigned long		flags;
+#define RXRPC_SOCK_CONNECTED		0	/* connect_srx is set */
 #define RXRPC_SOCK_EXCLUSIVE_CONN	1	/* exclusive connection for a client socket */
 	rwlock_t		call_lock;	/* lock for calls */
 	u32			min_sec_level;	/* minimum security level */
 #define RXRPC_SECURITY_MAX	RXRPC_SECURITY_ENCRYPT
 	struct sockaddr_rxrpc	srx;		/* local address */
+	struct sockaddr_rxrpc	connect_srx;	/* Default client address from connect() */
 	sa_family_t		proto;		/* protocol created with */
 };
 
@@ -477,6 +477,10 @@ extern u32 rxrpc_epoch;
 extern atomic_t rxrpc_debug_id;
 extern struct workqueue_struct *rxrpc_workqueue;
 
+extern struct rxrpc_transport *rxrpc_name_to_transport(struct rxrpc_sock *,
+						       struct sockaddr *,
+						       int, int, gfp_t);
+
 /*
  * ar-accept.c
  */
@@ -502,14 +506,14 @@ extern rwlock_t rxrpc_call_lock;
 
 struct rxrpc_call *rxrpc_find_call_hash(struct rxrpc_host_header *,
 					void *, sa_family_t, const void *);
-struct rxrpc_call *rxrpc_get_client_call(struct rxrpc_sock *,
+struct rxrpc_call *rxrpc_find_call_by_user_ID(struct rxrpc_sock *, unsigned long);
+struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
 					 struct rxrpc_transport *,
 					 struct rxrpc_conn_bundle *,
-					 unsigned long, int, gfp_t);
+					 unsigned long, gfp_t);
 struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
 				       struct rxrpc_connection *,
 				       struct rxrpc_host_header *);
-struct rxrpc_call *rxrpc_find_server_call(struct rxrpc_sock *, unsigned long);
 void rxrpc_release_call(struct rxrpc_call *);
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
 void __rxrpc_put_call(struct rxrpc_call *);
@@ -581,9 +585,7 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time_t,
 extern unsigned int rxrpc_resend_timeout;
 
 int rxrpc_send_packet(struct rxrpc_transport *, struct sk_buff *);
-int rxrpc_client_sendmsg(struct rxrpc_sock *, struct rxrpc_transport *,
-			 struct msghdr *, size_t);
-int rxrpc_server_sendmsg(struct rxrpc_sock *, struct msghdr *, size_t);
+int rxrpc_do_sendmsg(struct rxrpc_sock *, struct msghdr *, size_t);
 
 /*
  * ar-peer.c
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 51cb10062a8d..b87fda075b45 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -30,13 +30,13 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 /*
  * extract control messages from the sendmsg() control buffer
  */
-static int rxrpc_sendmsg_cmsg(struct rxrpc_sock *rx, struct msghdr *msg,
+static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 			      unsigned long *user_call_ID,
 			      enum rxrpc_command *command,
-			      u32 *abort_code,
-			      bool server)
+			      u32 *abort_code)
 {
 	struct cmsghdr *cmsg;
+	bool got_user_ID = false;
 	int len;
 
 	*command = RXRPC_CMD_SEND_DATA;
@@ -68,6 +68,7 @@ static int rxrpc_sendmsg_cmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 					CMSG_DATA(cmsg);
 			}
 			_debug("User Call ID %lx", *user_call_ID);
+			got_user_ID = true;
 			break;
 
 		case RXRPC_ABORT:
@@ -88,8 +89,6 @@ static int rxrpc_sendmsg_cmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 			*command = RXRPC_CMD_ACCEPT;
 			if (len != 0)
 				return -EINVAL;
-			if (!server)
-				return -EISCONN;
 			break;
 
 		default:
@@ -97,6 +96,8 @@ static int rxrpc_sendmsg_cmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 		}
 	}
 
+	if (!got_user_ID)
+		return -EINVAL;
 	_leave(" = 0");
 	return 0;
 }
@@ -124,55 +125,96 @@ static void rxrpc_send_abort(struct rxrpc_call *call, u32 abort_code)
 }
 
 /*
+ * Create a new client call for sendmsg().
+ */
+static struct rxrpc_call *
+rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
+				  unsigned long user_call_ID)
+{
+	struct rxrpc_conn_bundle *bundle;
+	struct rxrpc_transport *trans;
+	struct rxrpc_call *call;
+	struct key *key;
+	long ret;
+
+	DECLARE_SOCKADDR(struct sockaddr_rxrpc *, srx, msg->msg_name);
+
+	_enter("");
+
+	if (!msg->msg_name)
+		return ERR_PTR(-EDESTADDRREQ);
+
+	trans = rxrpc_name_to_transport(rx, msg->msg_name, msg->msg_namelen, 0,
+					GFP_KERNEL);
+	if (IS_ERR(trans)) {
+		ret = PTR_ERR(trans);
+		goto out;
+	}
+
+	key = rx->key;
+	if (key && !rx->key->payload.data[0])
+		key = NULL;
+	bundle = rxrpc_get_bundle(rx, trans, key, srx->srx_service, GFP_KERNEL);
+	if (IS_ERR(bundle)) {
+		ret = PTR_ERR(bundle);
+		goto out_trans;
+	}
+
+	call = rxrpc_new_client_call(rx, trans, bundle, user_call_ID,
+				     GFP_KERNEL);
+	rxrpc_put_bundle(trans, bundle);
+	rxrpc_put_transport(trans);
+	if (IS_ERR(call)) {
+		ret = PTR_ERR(call);
+		goto out_trans;
+	}
+
+	_leave(" = %p\n", call);
+	return call;
+
+out_trans:
+	rxrpc_put_transport(trans);
+out:
+	_leave(" = %ld", ret);
+	return ERR_PTR(ret);
+}
+
+/*
  * send a message forming part of a client call through an RxRPC socket
  * - caller holds the socket locked
  * - the socket may be either a client socket or a server socket
  */
-int rxrpc_client_sendmsg(struct rxrpc_sock *rx, struct rxrpc_transport *trans,
-			 struct msghdr *msg, size_t len)
+int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 {
-	struct rxrpc_conn_bundle *bundle;
 	enum rxrpc_command cmd;
 	struct rxrpc_call *call;
 	unsigned long user_call_ID = 0;
-	struct key *key;
-	u16 service_id;
 	u32 abort_code = 0;
 	int ret;
 
 	_enter("");
 
-	ASSERT(trans != NULL);
-
-	ret = rxrpc_sendmsg_cmsg(rx, msg, &user_call_ID, &cmd, &abort_code,
-				 false);
+	ret = rxrpc_sendmsg_cmsg(msg, &user_call_ID, &cmd, &abort_code);
 	if (ret < 0)
 		return ret;
 
-	bundle = NULL;
-	if (trans) {
-		service_id = rx->srx.srx_service;
-		if (msg->msg_name) {
-			DECLARE_SOCKADDR(struct sockaddr_rxrpc *, srx,
-					 msg->msg_name);
-			service_id = srx->srx_service;
-		}
-		key = rx->key;
-		if (key && !rx->key->payload.data[0])
-			key = NULL;
-		bundle = rxrpc_get_bundle(rx, trans, key, service_id,
-					  GFP_KERNEL);
-		if (IS_ERR(bundle))
-			return PTR_ERR(bundle);
+	if (cmd == RXRPC_CMD_ACCEPT) {
+		if (rx->sk.sk_state != RXRPC_SERVER_LISTENING)
+			return -EINVAL;
+		call = rxrpc_accept_call(rx, user_call_ID);
+		if (IS_ERR(call))
+			return PTR_ERR(call);
+		rxrpc_put_call(call);
+		return 0;
 	}
 
-	call = rxrpc_get_client_call(rx, trans, bundle, user_call_ID,
-				     abort_code == 0, GFP_KERNEL);
-	if (trans)
-		rxrpc_put_bundle(trans, bundle);
-	if (IS_ERR(call)) {
-		_leave(" = %ld", PTR_ERR(call));
-		return PTR_ERR(call);
+	call = rxrpc_find_call_by_user_ID(rx, user_call_ID);
+	if (!call) {
+		if (cmd != RXRPC_CMD_SEND_DATA)
+			return -EBADSLT;
+		call = rxrpc_new_client_call_for_sendmsg(rx, msg, user_call_ID);
+		if (IS_ERR(call))
+			return PTR_ERR(call);
 	}
 
 	_debug("CALL %d USR %lx ST %d on CONN %p",
@@ -180,14 +222,21 @@ int rxrpc_client_sendmsg(struct rxrpc_sock *rx, struct rxrpc_transport *trans,
 
 	if (call->state >= RXRPC_CALL_COMPLETE) {
 		/* it's too late for this call */
-		ret = -ESHUTDOWN;
+		ret = -ECONNRESET;
 	} else if (cmd == RXRPC_CMD_SEND_ABORT) {
 		rxrpc_send_abort(call, abort_code);
+		ret = 0;
 	} else if (cmd != RXRPC_CMD_SEND_DATA) {
 		ret = -EINVAL;
-	} else if (call->state != RXRPC_CALL_CLIENT_SEND_REQUEST) {
+	} else if (!call->in_clientflag &&
+		   call->state != RXRPC_CALL_CLIENT_SEND_REQUEST) {
 		/* request phase complete for this client call */
 		ret = -EPROTO;
+	} else if (call->in_clientflag &&
+		   call->state != RXRPC_CALL_SERVER_ACK_REQUEST &&
+		   call->state != RXRPC_CALL_SERVER_SEND_REPLY) {
+		/* Reply phase not begun or not complete for service call. */
+		ret = -EPROTO;
 	} else {
 		ret = rxrpc_send_data(rx, call, msg, len);
 	}
@@ -266,67 +315,6 @@ void rxrpc_kernel_abort_call(struct rxrpc_call *call, u32 abort_code)
 EXPORT_SYMBOL(rxrpc_kernel_abort_call);
 
 /*
- * send a message through a server socket
- * - caller holds the socket locked
- */
-int rxrpc_server_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
-{
-	enum rxrpc_command cmd;
-	struct rxrpc_call *call;
-	unsigned long user_call_ID = 0;
-	u32 abort_code = 0;
-	int ret;
-
-	_enter("");
-
-	ret = rxrpc_sendmsg_cmsg(rx, msg, &user_call_ID, &cmd, &abort_code,
-				 true);
-	if (ret < 0)
-		return ret;
-
-	if (cmd == RXRPC_CMD_ACCEPT) {
-		call = rxrpc_accept_call(rx, user_call_ID);
-		if (IS_ERR(call))
-			return PTR_ERR(call);
-		rxrpc_put_call(call);
-		return 0;
-	}
-
-	call = rxrpc_find_server_call(rx, user_call_ID);
-	if (!call)
-		return -EBADSLT;
-	if (call->state >= RXRPC_CALL_COMPLETE) {
-		ret = -ESHUTDOWN;
-		goto out;
-	}
-
-	switch (cmd) {
-	case RXRPC_CMD_SEND_DATA:
-		if (call->state != RXRPC_CALL_CLIENT_SEND_REQUEST &&
-		    call->state != RXRPC_CALL_SERVER_ACK_REQUEST &&
-		    call->state != RXRPC_CALL_SERVER_SEND_REPLY) {
-			/* Tx phase not yet begun for this call */
-			ret = -EPROTO;
-			break;
-		}
-
-		ret = rxrpc_send_data(rx, call, msg, len);
-		break;
-
-	case RXRPC_CMD_SEND_ABORT:
-		rxrpc_send_abort(call, abort_code);
-		break;
-	default:
-		BUG();
-	}
-
-	out:
-	rxrpc_put_call(call);
-	_leave(" = %d", ret);
-	return ret;
-}
-
-/*
  * send a packet through the transport endpoint
  */
 int rxrpc_send_packet(struct rxrpc_transport *trans, struct sk_buff *skb)
