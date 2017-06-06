From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/4] rxrpc: Implement service upgrade
Date: Tue, 06 Jun 2017 10:54:41 +0100
Message-ID: <149674288185.26138.2650839156655846418.stgit@warthog.procyon.org.uk>
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

Implement AuriStor's service upgrade facility.  There are three problems
that this is meant to deal with:

 (1) Various of the standard AFS RPC calls have IPv4 addresses in their
     requests and/or replies - but there's no room for including IPv6
     addresses.

 (2) Definition of IPv6-specific RPC operations in the standard operation
     sets has not yet been achieved.

 (3) One could envision the creation a new service on the same port that as
     the original service.  The new service could implement improved
     operations - and the client could try this first, falling back to the
     original service if it's not there.

     Unfortunately, certain servers ignore packets addressed to a service
     they don't implement and don't respond in any way - not even with an
     ABORT.  This means that the client must then wait for the call timeout
     to occur.

What service upgrade does is to see if the connection is marked as being
'upgradeable' and if so, change the service ID in the server and thus the
request and reply formats.  Note that the upgrade isn't mandatory - a
server that supports only the original call set will ignore the upgrade
request.

In the protocol, the procedure is then as follows:

 (1) To request an upgrade, the first DATA packet in a new connection must
     have the userStatus set to 1 (this is normally 0).  The userStatus
     value is normally ignored by the server.

 (2) If the server doesn't support upgrading, the reply packets will
     contain the same service ID as for the first request packet.

 (3) If the server does support upgrading, all future reply packets on that
     connection will contain the new service ID and the new service ID will
     be applied to *all* further calls on that connection as well.

 (4) The RPC op used to probe the upgrade must take the same request data
     as the shadow call in the upgrade set (but may return a different
     reply).  GetCapability RPC ops were added to all standard sets for
     just this purpose.  Ops where the request formats differ cannot be
     used for probing.

 (5) The client must wait for completion of the probe before sending any
     further RPC ops to the same destination.  It should then use the
     service ID that recvmsg() reported back in all future calls.

 (6) The shadow service must have call definitions for all the operation
     IDs defined by the original service.


To support service upgrading, a server should:

 (1) Call bind() twice on its AF_RXRPC socket before calling listen().
     Each bind() should supply a different service ID, but the transport
     addresses must be the same.  This allows the server to receive
     requests with either service ID.

 (2) Enable automatic upgrading by calling setsockopt(), specifying
     RXRPC_UPGRADEABLE_SERVICE and passing in a two-member array of
     unsigned shorts as the argument:

	unsigned short optval[2];

     This specifies a pair of service IDs.  They must be different and must
     match the service IDs bound to the socket.  Member 0 is the service ID
     to upgrade from and member 1 is the service ID to upgrade to.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   34 ++++++++++++++++++++++++++--------
 include/linux/rxrpc.h              |    1 +
 include/rxrpc/packet.h             |    2 ++
 net/rxrpc/af_rxrpc.c               |   23 +++++++++++++++++++++++
 net/rxrpc/ar-internal.h            |   10 ++++++++--
 net/rxrpc/call_accept.c            |    2 +-
 net/rxrpc/conn_service.c           |   11 ++++++++++-
 7 files changed, 71 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index b7115ec55e04..2a1662760450 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -433,6 +433,13 @@ AF_RXRPC sockets support a few socket options at the SOL_RXRPC level:
 	 Encrypted checksum plus entire packet padded and encrypted, including
 	 actual packet length.
 
+ (*) RXRPC_UPGRADEABLE_SERVICE
+
+     This is used to indicate that a service socket with two bindings may
+     upgrade one bound service to the other if requested by the client.  optval
+     must point to an array of two unsigned short ints.  The first is the
+     service ID to upgrade from and the second the service ID to upgrade to.
+
 
 ========
 SECURITY
@@ -588,7 +595,7 @@ A server would be set up to accept operations in the following manner:
      The keyring can be manipulated after it has been given to the socket. This
      permits the server to add more keys, replace keys, etc. whilst it is live.
 
- (2) A local address must then be bound:
+ (3) A local address must then be bound:
 
 	struct sockaddr_rxrpc srx = {
 		.srx_family	= AF_RXRPC,
@@ -604,11 +611,22 @@ A server would be set up to accept operations in the following manner:
      parameters are the same.  The limit is currently two.  To do this, bind()
      should be called twice.
 
- (3) The server is then set to listen out for incoming calls:
+ (4) If service upgrading is required, first two service IDs must have been
+     bound and then the following option must be set:
+
+	unsigned short service_ids[2] = { from_ID, to_ID };
+	setsockopt(server, SOL_RXRPC, RXRPC_UPGRADEABLE_SERVICE,
+		   service_ids, sizeof(service_ids));
+
+     This will automatically upgrade connections on service from_ID to service
+     to_ID if they request it.  This will be reflected in msg_name obtained
+     through recvmsg() when the request data is delivered to userspace.
+
+ (5) The server is then set to listen out for incoming calls:
 
 	listen(server, 100);
 
- (4) The kernel notifies the server of pending incoming connections by sending
+ (6) The kernel notifies the server of pending incoming connections by sending
      it a message for each.  This is received with recvmsg() on the server
      socket.  It has no data, and has a single dataless control message
      attached:
@@ -620,13 +638,13 @@ A server would be set up to accept operations in the following manner:
      the time it is accepted - in which case the first call still on the queue
      will be accepted.
 
- (5) The server then accepts the new call by issuing a sendmsg() with two
+ (7) The server then accepts the new call by issuing a sendmsg() with two
      pieces of control data and no actual data:
 
 	RXRPC_ACCEPT		- indicate connection acceptance
 	RXRPC_USER_CALL_ID	- specify user ID for this call
 
- (6) The first request data packet will then be posted to the server socket for
+ (8) The first request data packet will then be posted to the server socket for
      recvmsg() to pick up.  At that point, the RxRPC address for the call can
      be read from the address fields in the msghdr struct.
 
@@ -638,7 +656,7 @@ A server would be set up to accept operations in the following manner:
 
 	RXRPC_USER_CALL_ID	- specifies the user ID for this call
 
- (8) The reply data should then be posted to the server socket using a series
+ (9) The reply data should then be posted to the server socket using a series
      of sendmsg() calls, each with the following control messages attached:
 
 	RXRPC_USER_CALL_ID	- specifies the user ID for this call
@@ -646,7 +664,7 @@ A server would be set up to accept operations in the following manner:
      MSG_MORE should be set in msghdr::msg_flags on all but the last message
      for a particular call.
 
- (9) The final ACK from the client will be posted for retrieval by recvmsg()
+(10) The final ACK from the client will be posted for retrieval by recvmsg()
      when it is received.  It will take the form of a dataless message with two
      control messages attached:
 
@@ -656,7 +674,7 @@ A server would be set up to accept operations in the following manner:
      MSG_EOR will be flagged to indicate that this is the final message for
      this call.
 
-(10) Up to the point the final packet of reply data is sent, the call can be
+(11) Up to the point the final packet of reply data is sent, the call can be
      aborted by calling sendmsg() with a dataless message with the following
      control messages attached:
 
diff --git a/include/linux/rxrpc.h b/include/linux/rxrpc.h
index c68307bc306f..634116561a6a 100644
--- a/include/linux/rxrpc.h
+++ b/include/linux/rxrpc.h
@@ -37,6 +37,7 @@ struct sockaddr_rxrpc {
 #define RXRPC_SECURITY_KEYRING		2	/* [srvr] set ring of server security keys */
 #define RXRPC_EXCLUSIVE_CONNECTION	3	/* Deprecated; use RXRPC_EXCLUSIVE_CALL instead */
 #define RXRPC_MIN_SECURITY_LEVEL	4	/* minimum security level */
+#define RXRPC_UPGRADEABLE_SERVICE	5	/* Upgrade service[0] -> service[1] */
 
 /*
  * RxRPC control messages
diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index 703a64b4681a..a2dcfb850b9f 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -58,6 +58,8 @@ struct rxrpc_wire_header {
 #define RXRPC_SLOW_START_OK	0x20		/* [ACK] slow start supported */
 
 	uint8_t		userStatus;	/* app-layer defined status */
+#define RXRPC_USERSTATUS_SERVICE_UPGRADE 0x01	/* AuriStor service upgrade request */
+	
 	uint8_t		securityIndex;	/* security protocol ID */
 	union {
 		__be16	_rsvd;		/* reserved */
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 3b982bca7d22..0c4dc4a7832c 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -490,6 +490,7 @@ static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
 {
 	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
 	unsigned int min_sec_level;
+	u16 service_upgrade[2];
 	int ret;
 
 	_enter(",%d,%d,,%d", level, optname, optlen);
@@ -546,6 +547,28 @@ static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
 			rx->min_sec_level = min_sec_level;
 			goto success;
 
+		case RXRPC_UPGRADEABLE_SERVICE:
+			ret = -EINVAL;
+			if (optlen != sizeof(service_upgrade) ||
+			    rx->service_upgrade.from != 0)
+				goto error;
+			ret = -EISCONN;
+			if (rx->sk.sk_state != RXRPC_SERVER_BOUND2)
+				goto error;
+			ret = -EFAULT;
+			if (copy_from_user(service_upgrade, optval,
+					   sizeof(service_upgrade)) != 0)
+				goto error;
+			ret = -EINVAL;
+			if ((service_upgrade[0] != rx->srx.srx_service ||
+			     service_upgrade[1] != rx->second_service) &&
+			    (service_upgrade[0] != rx->second_service ||
+			     service_upgrade[1] != rx->srx.srx_service))
+				goto error;
+			rx->service_upgrade.from = service_upgrade[0];
+			rx->service_upgrade.to = service_upgrade[1];
+			goto success;
+
 		default:
 			break;
 		}
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 781fbc253b5a..c1ebd886a53f 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -144,8 +144,13 @@ struct rxrpc_sock {
 #define RXRPC_SECURITY_MAX	RXRPC_SECURITY_ENCRYPT
 	bool			exclusive;	/* Exclusive connection for a client socket */
 	u16			second_service;	/* Additional service bound to the endpoint */
+	struct {
+		/* Service upgrade information */
+		u16		from;		/* Service ID to upgrade (if not 0) */
+		u16		to;		/* service ID to upgrade to */
+	} service_upgrade;
 	sa_family_t		family;		/* Protocol family created with */
-	struct sockaddr_rxrpc	srx;		/* local address */
+	struct sockaddr_rxrpc	srx;		/* Primary Service/local addresses */
 	struct sockaddr_rxrpc	connect_srx;	/* Default client address from connect() */
 };
 
@@ -861,7 +866,8 @@ static inline void rxrpc_put_connection(struct rxrpc_connection *conn)
 struct rxrpc_connection *rxrpc_find_service_conn_rcu(struct rxrpc_peer *,
 						     struct sk_buff *);
 struct rxrpc_connection *rxrpc_prealloc_service_connection(struct rxrpc_net *, gfp_t);
-void rxrpc_new_incoming_connection(struct rxrpc_connection *, struct sk_buff *);
+void rxrpc_new_incoming_connection(struct rxrpc_sock *,
+				   struct rxrpc_connection *, struct sk_buff *);
 void rxrpc_unpublish_service_conn(struct rxrpc_connection *);
 
 /*
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 544df53ccf79..0d4d84e8c074 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -296,7 +296,7 @@ static struct rxrpc_call *rxrpc_alloc_incoming_call(struct rxrpc_sock *rx,
 		conn->params.local = local;
 		conn->params.peer = peer;
 		rxrpc_see_connection(conn);
-		rxrpc_new_incoming_connection(conn, skb);
+		rxrpc_new_incoming_connection(rx, conn, skb);
 	} else {
 		rxrpc_get_connection(conn);
 	}
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index c7f8682a55b2..e60fcd2a4a02 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -150,7 +150,8 @@ struct rxrpc_connection *rxrpc_prealloc_service_connection(struct rxrpc_net *rxn
  * Set up an incoming connection.  This is called in BH context with the RCU
  * read lock held.
  */
-void rxrpc_new_incoming_connection(struct rxrpc_connection *conn,
+void rxrpc_new_incoming_connection(struct rxrpc_sock *rx,
+				   struct rxrpc_connection *conn,
 				   struct sk_buff *skb)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
@@ -168,6 +169,14 @@ void rxrpc_new_incoming_connection(struct rxrpc_connection *conn,
 	else
 		conn->state	= RXRPC_CONN_SERVICE;
 
+	/* See if we should upgrade the service.  This can only happen on the
+	 * first packet on a new connection.  Once done, it applies to all
+	 * subsequent calls on that connection.
+	 */
+	if (sp->hdr.userStatus == RXRPC_USERSTATUS_SERVICE_UPGRADE &&
+	    conn->service_id == rx->service_upgrade.from)
+		conn->service_id = rx->service_upgrade.to;
+
 	/* Make the connection a target for incoming packets. */
 	rxrpc_publish_service_conn(conn->params.peer, conn);
 
