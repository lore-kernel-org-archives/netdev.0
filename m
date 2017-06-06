From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/4] rxrpc: Permit multiple service binding
Date: Tue, 06 Jun 2017 10:54:35 +0100
Message-ID: <149674287506.26138.3263649174705312167.stgit@warthog.procyon.org.uk>
References: <149674286135.26138.12623162384868251541.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149674286135.26138.12623162384868251541.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Permit bind() to be called on an AF_RXRPC socket more than once (currently
maximum twice) to bind multiple listening services to it.  There are some
restrictions:

 (1) All bind() calls involved must have a non-zero service ID.

 (2) The service IDs must all be different.

 (3) The rest of the address (notably the transport part) must be the same
     in all (a single UDP socket is shared).

 (4) This must be done before listen() or sendmsg() is called.

This allows someone to connect to the service socket with different service
IDs and lays the foundation for service upgrading.

The service ID used by an incoming call can be extracted from the msg_name
returned by recvmsg().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |    4 ++
 net/rxrpc/af_rxrpc.c               |   62 +++++++++++++++++++++++-------------
 net/rxrpc/ar-internal.h            |    2 +
 net/rxrpc/call_accept.c            |    3 +-
 net/rxrpc/local_object.c           |    1 +
 net/rxrpc/security.c               |    3 +-
 6 files changed, 51 insertions(+), 24 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 1b63bbc6b94f..b7115ec55e04 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -600,6 +600,10 @@ A server would be set up to accept operations in the following manner:
 	};
 	bind(server, &srx, sizeof(srx));
 
+     More than one service ID may be bound to a socket, provided the transport
+     parameters are the same.  The limit is currently two.  To do this, bind()
+     should be called twice.
+
  (3) The server is then set to listen out for incoming calls:
 
 	listen(server, 100);
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 1e4ac889ec00..3b982bca7d22 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -144,31 +144,48 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 
 	lock_sock(&rx->sk);
 
-	if (rx->sk.sk_state != RXRPC_UNBOUND) {
-		ret = -EINVAL;
-		goto error_unlock;
-	}
-
-	memcpy(&rx->srx, srx, sizeof(rx->srx));
+	switch (rx->sk.sk_state) {
+	case RXRPC_UNBOUND:
+		rx->srx = *srx;
+		local = rxrpc_lookup_local(sock_net(&rx->sk), &rx->srx);
+		if (IS_ERR(local)) {
+			ret = PTR_ERR(local);
+			goto error_unlock;
+		}
 
-	local = rxrpc_lookup_local(sock_net(&rx->sk), &rx->srx);
-	if (IS_ERR(local)) {
-		ret = PTR_ERR(local);
-		goto error_unlock;
-	}
+		if (service_id) {
+			write_lock(&local->services_lock);
+			if (rcu_access_pointer(local->service))
+				goto service_in_use;
+			rx->local = local;
+			rcu_assign_pointer(local->service, rx);
+			write_unlock(&local->services_lock);
+
+			rx->sk.sk_state = RXRPC_SERVER_BOUND;
+		} else {
+			rx->local = local;
+			rx->sk.sk_state = RXRPC_CLIENT_BOUND;
+		}
+		break;
 
-	if (service_id) {
-		write_lock(&local->services_lock);
-		if (rcu_access_pointer(local->service))
-			goto service_in_use;
-		rx->local = local;
-		rcu_assign_pointer(local->service, rx);
-		write_unlock(&local->services_lock);
+	case RXRPC_SERVER_BOUND:
+		ret = -EINVAL;
+		if (service_id == 0)
+			goto error_unlock;
+		ret = -EADDRINUSE;
+		if (service_id == rx->srx.srx_service)
+			goto error_unlock;
+		ret = -EINVAL;
+		srx->srx_service = rx->srx.srx_service;
+		if (memcmp(srx, &rx->srx, sizeof(*srx)) != 0)
+			goto error_unlock;
+		rx->second_service = service_id;
+		rx->sk.sk_state = RXRPC_SERVER_BOUND2;
+		break;
 
-		rx->sk.sk_state = RXRPC_SERVER_BOUND;
-	} else {
-		rx->local = local;
-		rx->sk.sk_state = RXRPC_CLIENT_BOUND;
+	default:
+		ret = -EINVAL;
+		goto error_unlock;
 	}
 
 	release_sock(&rx->sk);
@@ -205,6 +222,7 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 		ret = -EADDRNOTAVAIL;
 		break;
 	case RXRPC_SERVER_BOUND:
+	case RXRPC_SERVER_BOUND2:
 		ASSERT(rx->local != NULL);
 		max = READ_ONCE(rxrpc_max_backlog);
 		ret = -EINVAL;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index de98a49adb35..781fbc253b5a 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -61,6 +61,7 @@ enum {
 	RXRPC_CLIENT_UNBOUND,		/* Unbound socket used as client */
 	RXRPC_CLIENT_BOUND,		/* client local address bound */
 	RXRPC_SERVER_BOUND,		/* server local address bound */
+	RXRPC_SERVER_BOUND2,		/* second server local address bound */
 	RXRPC_SERVER_LISTENING,		/* server listening for connections */
 	RXRPC_SERVER_LISTEN_DISABLED,	/* server listening disabled */
 	RXRPC_CLOSE,			/* socket is being closed */
@@ -142,6 +143,7 @@ struct rxrpc_sock {
 	u32			min_sec_level;	/* minimum security level */
 #define RXRPC_SECURITY_MAX	RXRPC_SECURITY_ENCRYPT
 	bool			exclusive;	/* Exclusive connection for a client socket */
+	u16			second_service;	/* Additional service bound to the endpoint */
 	sa_family_t		family;		/* Protocol family created with */
 	struct sockaddr_rxrpc	srx;		/* local address */
 	struct sockaddr_rxrpc	connect_srx;	/* Default client address from connect() */
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index a8515b0d4717..544df53ccf79 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -341,7 +341,8 @@ struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *local,
 
 	/* Get the socket providing the service */
 	rx = rcu_dereference(local->service);
-	if (rx && service_id == rx->srx.srx_service)
+	if (rx && (service_id == rx->srx.srx_service ||
+		   service_id == rx->second_service))
 		goto found_service;
 
 	trace_rxrpc_abort("INV", sp->hdr.cid, sp->hdr.callNumber, sp->hdr.seq,
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index 17d79fd73ade..38b99db30e54 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -94,6 +94,7 @@ static struct rxrpc_local *rxrpc_alloc_local(struct rxrpc_net *rxnet,
 		rwlock_init(&local->services_lock);
 		local->debug_id = atomic_inc_return(&rxrpc_debug_id);
 		memcpy(&local->srx, srx, sizeof(*srx));
+		local->srx.srx_service = 0;
 	}
 
 	_leave(" = %p", local);
diff --git a/net/rxrpc/security.c b/net/rxrpc/security.c
index b9f5dbbe0b8b..e9f428351293 100644
--- a/net/rxrpc/security.c
+++ b/net/rxrpc/security.c
@@ -133,7 +133,8 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 	read_lock(&local->services_lock);
 	rx = rcu_dereference_protected(local->service,
 				       lockdep_is_held(&local->services_lock));
-	if (rx && rx->srx.srx_service == conn->service_id)
+	if (rx && (rx->srx.srx_service == conn->service_id ||
+		   rx->second_service == conn->service_id))
 		goto found_service;
 
 	/* the service appears to have died */
