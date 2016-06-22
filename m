From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 05/14] rxrpc: Fix exclusive connection handling
 [ver #2]
Date: Wed, 22 Jun 2016 17:03:28 +0100
Message-ID: <146661140811.15011.9792663043244174972.stgit@warthog.procyon.org.uk>
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

"Exclusive connections" are meant to be used for a single client call and
then scrapped.  The idea is to limit the use of the negotiated security
context.  The current code, however, isn't doing this: it is instead
restricting the socket to a single virtual connection and doing all the
calls over that.

This is changed such that the socket no longer maintains a special virtual
connection over which it will do all the calls, but rather gets a new one
each time a new exclusive call is made.

Further, using a socket option for this is a poor choice.  It should be
done on sendmsg with a control message marker instead so that calls can be
marked exclusive individually.  To that end, add RXRPC_EXCLUSIVE_CALL
which, if passed to sendmsg() as a control message element, will cause the
call to be done on an single-use connection.

The socket option (RXRPC_EXCLUSIVE_CONNECTION) still exists and, if set,
will override any lack of RXRPC_EXCLUSIVE_CALL being specified so that
programs using the setsockopt() will appear to work the same.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/rxrpc.h   |    3 +
 net/rxrpc/af_rxrpc.c    |    7 ---
 net/rxrpc/ar-internal.h |    7 ++-
 net/rxrpc/conn_object.c |   97 +++++++++++++++++++----------------------------
 net/rxrpc/output.c      |   19 +++++++--
 5 files changed, 60 insertions(+), 73 deletions(-)

diff --git a/include/linux/rxrpc.h b/include/linux/rxrpc.h
index 1e8f216e2cf1..c68307bc306f 100644
--- a/include/linux/rxrpc.h
+++ b/include/linux/rxrpc.h
@@ -35,7 +35,7 @@ struct sockaddr_rxrpc {
  */
 #define RXRPC_SECURITY_KEY		1	/* [clnt] set client security key */
 #define RXRPC_SECURITY_KEYRING		2	/* [srvr] set ring of server security keys */
-#define RXRPC_EXCLUSIVE_CONNECTION	3	/* [clnt] use exclusive RxRPC connection */
+#define RXRPC_EXCLUSIVE_CONNECTION	3	/* Deprecated; use RXRPC_EXCLUSIVE_CALL instead */
 #define RXRPC_MIN_SECURITY_LEVEL	4	/* minimum security level */
 
 /*
@@ -52,6 +52,7 @@ struct sockaddr_rxrpc {
 #define RXRPC_LOCAL_ERROR	7	/* -r: local error generated [terminal] */
 #define RXRPC_NEW_CALL		8	/* -r: [Service] new incoming call notification */
 #define RXRPC_ACCEPT		9	/* s-: [Service] accept request */
+#define RXRPC_EXCLUSIVE_CALL	10	/* s-: Call should be on exclusive connection */
 
 /*
  * RxRPC security levels
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 48b45a0280c0..73f5c553eef4 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -494,7 +494,7 @@ static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
 			ret = -EISCONN;
 			if (rx->sk.sk_state != RXRPC_UNBOUND)
 				goto error;
-			set_bit(RXRPC_SOCK_EXCLUSIVE_CONN, &rx->flags);
+			rx->exclusive = true;
 			goto success;
 
 		case RXRPC_SECURITY_KEY:
@@ -669,11 +669,6 @@ static int rxrpc_release_sock(struct sock *sk)
 	flush_workqueue(rxrpc_workqueue);
 	rxrpc_purge_queue(&sk->sk_receive_queue);
 
-	if (rx->conn) {
-		rxrpc_put_connection(rx->conn);
-		rx->conn = NULL;
-	}
-
 	if (rx->local) {
 		rxrpc_put_local(rx->local);
 		rx->local = NULL;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index efe6673deb28..4ca99445e0b7 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -37,6 +37,8 @@ struct rxrpc_crypt {
 #define rxrpc_queue_call(CALL)	rxrpc_queue_work(&(CALL)->processor)
 #define rxrpc_queue_conn(CONN)	rxrpc_queue_work(&(CONN)->processor)
 
+struct rxrpc_connection;
+
 /*
  * sk_state for RxRPC sockets
  */
@@ -57,7 +59,6 @@ struct rxrpc_sock {
 	struct sock		sk;
 	rxrpc_interceptor_t	interceptor;	/* kernel service Rx interceptor function */
 	struct rxrpc_local	*local;		/* local endpoint */
-	struct rxrpc_connection	*conn;		/* exclusive virtual connection */
 	struct list_head	listen_link;	/* link in the local endpoint's listen list */
 	struct list_head	secureq;	/* calls awaiting connection security clearance */
 	struct list_head	acceptq;	/* calls awaiting acceptance */
@@ -66,13 +67,13 @@ struct rxrpc_sock {
 	struct rb_root		calls;		/* outstanding calls on this socket */
 	unsigned long		flags;
 #define RXRPC_SOCK_CONNECTED		0	/* connect_srx is set */
-#define RXRPC_SOCK_EXCLUSIVE_CONN	1	/* exclusive connection for a client socket */
 	rwlock_t		call_lock;	/* lock for calls */
 	u32			min_sec_level;	/* minimum security level */
 #define RXRPC_SECURITY_MAX	RXRPC_SECURITY_ENCRYPT
+	bool			exclusive;	/* Exclusive connection for a client socket */
+	sa_family_t		family;		/* Protocol family created with */
 	struct sockaddr_rxrpc	srx;		/* local address */
 	struct sockaddr_rxrpc	connect_srx;	/* Default client address from connect() */
-	sa_family_t		family;		/* protocol family created with */
 };
 
 #define rxrpc_sk(__sk) container_of((__sk), struct rxrpc_sock, sk)
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index c6787b6f459f..6164373d6ce3 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -328,71 +328,57 @@ static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
 
 	_enter("");
 
-	conn = rx->conn;
+	conn = rxrpc_alloc_connection(gfp);
 	if (!conn) {
-		/* not yet present - create a candidate for a new connection
-		 * and then redo the check */
-		conn = rxrpc_alloc_connection(gfp);
-		if (!conn) {
-			_leave(" = -ENOMEM");
-			return -ENOMEM;
-		}
+		_leave(" = -ENOMEM");
+		return -ENOMEM;
+	}
 
-		conn->trans = trans;
-		conn->bundle = NULL;
-		conn->params = *cp;
-		conn->proto.local = cp->local;
-		conn->proto.epoch = rxrpc_epoch;
-		conn->proto.cid = 0;
-		conn->proto.in_clientflag = 0;
-		conn->proto.family = cp->peer->srx.transport.family;
-		conn->out_clientflag = RXRPC_CLIENT_INITIATED;
-		conn->state = RXRPC_CONN_CLIENT;
-		conn->avail_calls = RXRPC_MAXCALLS - 1;
-
-		key_get(conn->params.key);
-
-		ret = rxrpc_init_client_conn_security(conn);
-		if (ret < 0) {
-			key_put(conn->params.key);
-			kfree(conn);
-			_leave(" = %d [key]", ret);
-			return ret;
-		}
+	conn->trans		= trans;
+	conn->bundle		= NULL;
+	conn->params		= *cp;
+	conn->proto.local	= cp->local;
+	conn->proto.epoch	= rxrpc_epoch;
+	conn->proto.cid		= 0;
+	conn->proto.in_clientflag = 0;
+	conn->proto.family	= cp->peer->srx.transport.family;
+	conn->out_clientflag	= RXRPC_CLIENT_INITIATED;
+	conn->state		= RXRPC_CONN_CLIENT;
+	conn->avail_calls	= RXRPC_MAXCALLS - 1;
+
+	key_get(conn->params.key);
+
+	ret = rxrpc_init_client_conn_security(conn);
+	if (ret < 0) {
+		key_put(conn->params.key);
+		kfree(conn);
+		_leave(" = %d [key]", ret);
+		return ret;
+	}
 
-		write_lock_bh(&rxrpc_connection_lock);
-		list_add_tail(&conn->link, &rxrpc_connections);
-		write_unlock_bh(&rxrpc_connection_lock);
+	write_lock_bh(&rxrpc_connection_lock);
+	list_add_tail(&conn->link, &rxrpc_connections);
+	write_unlock_bh(&rxrpc_connection_lock);
 
-		spin_lock(&trans->client_lock);
-		atomic_inc(&trans->usage);
+	spin_lock(&trans->client_lock);
+	atomic_inc(&trans->usage);
 
-		_net("CONNECT EXCL new %d on TRANS %d",
-		     conn->debug_id, conn->trans->debug_id);
+	_net("CONNECT EXCL new %d on TRANS %d",
+	     conn->debug_id, conn->trans->debug_id);
 
-		rxrpc_assign_connection_id(conn);
-		rx->conn = conn;
-	} else {
-		spin_lock(&trans->client_lock);
-	}
+	rxrpc_assign_connection_id(conn);
 
-	/* we've got a connection with a free channel and we can now attach the
-	 * call to it
-	 * - we're holding the transport's client lock
-	 * - we're holding a reference on the connection
+	/* Since no one else can use the connection, we just use the first
+	 * channel.
 	 */
-	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
-		if (!conn->channels[chan])
-			goto found_channel;
-	goto no_free_channels;
-
-found_channel:
+	chan = 0;
 	atomic_inc(&conn->usage);
 	conn->channels[chan] = call;
+	conn->call_counter = 1;
 	call->conn = conn;
 	call->channel = chan;
 	call->cid = conn->proto.cid | chan;
-	call->call_id = ++conn->call_counter;
+	call->call_id = 1;
 
 	_net("CONNECT client on conn %d chan %d as call %x",
 	     conn->debug_id, chan, call->call_id);
@@ -402,11 +388,6 @@ found_channel:
 	rxrpc_add_call_ID_to_conn(conn, call);
 	_leave(" = 0");
 	return 0;
-
-no_free_channels:
-	spin_unlock(&trans->client_lock);
-	_leave(" = -ENOSR");
-	return -ENOSR;
 }
 
 /*
@@ -427,7 +408,7 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 
 	_enter("%p,%lx,", rx, call->user_call_ID);
 
-	if (test_bit(RXRPC_SOCK_EXCLUSIVE_CONN, &rx->flags))
+	if (cp->exclusive)
 		return rxrpc_connect_exclusive(rx, cp, trans, call, gfp);
 
 	spin_lock(&trans->client_lock);
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index becbaa7c0a7c..6f8ab0ef839f 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -35,7 +35,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 			      unsigned long *user_call_ID,
 			      enum rxrpc_command *command,
-			      u32 *abort_code)
+			      u32 *abort_code,
+			      bool *_exclusive)
 {
 	struct cmsghdr *cmsg;
 	bool got_user_ID = false;
@@ -93,6 +94,11 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 				return -EINVAL;
 			break;
 
+		case RXRPC_EXCLUSIVE_CALL:
+			*_exclusive = true;
+			if (len != 0)
+				return -EINVAL;
+			break;
 		default:
 			return -EINVAL;
 		}
@@ -131,7 +137,7 @@ static void rxrpc_send_abort(struct rxrpc_call *call, u32 abort_code)
  */
 static struct rxrpc_call *
 rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
-				  unsigned long user_call_ID)
+				  unsigned long user_call_ID, bool exclusive)
 {
 	struct rxrpc_conn_parameters cp;
 	struct rxrpc_conn_bundle *bundle;
@@ -155,7 +161,7 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 	cp.local		= rx->local;
 	cp.key			= rx->key;
 	cp.security_level	= rx->min_sec_level;
-	cp.exclusive		= test_bit(RXRPC_SOCK_EXCLUSIVE_CONN, &rx->flags);
+	cp.exclusive		= rx->exclusive | exclusive;
 	cp.service_id		= srx->srx_service;
 	trans = rxrpc_name_to_transport(&cp, msg->msg_name, msg->msg_namelen,
 					GFP_KERNEL);
@@ -201,12 +207,14 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	enum rxrpc_command cmd;
 	struct rxrpc_call *call;
 	unsigned long user_call_ID = 0;
+	bool exclusive = false;
 	u32 abort_code = 0;
 	int ret;
 
 	_enter("");
 
-	ret = rxrpc_sendmsg_cmsg(msg, &user_call_ID, &cmd, &abort_code);
+	ret = rxrpc_sendmsg_cmsg(msg, &user_call_ID, &cmd, &abort_code,
+				 &exclusive);
 	if (ret < 0)
 		return ret;
 
@@ -224,7 +232,8 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	if (!call) {
 		if (cmd != RXRPC_CMD_SEND_DATA)
 			return -EBADSLT;
-		call = rxrpc_new_client_call_for_sendmsg(rx, msg, user_call_ID);
+		call = rxrpc_new_client_call_for_sendmsg(rx, msg, user_call_ID,
+							 exclusive);
 		if (IS_ERR(call))
 			return PTR_ERR(call);
 	}
