From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/4] rxrpc: Add service upgrade support for client
 connections
Date: Tue, 06 Jun 2017 10:54:48 +0100
Message-ID: <149674288881.26138.1996612243548008028.stgit@warthog.procyon.org.uk>
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

Make it possible for a client to use AuriStor's service upgrade facility.

The client does this by adding an RXRPC_UPGRADE_SERVICE control message to
the first sendmsg() of a call.  This takes no parameters.

When recvmsg() starts returning data from the call, the service ID field in
the returned msg_name will reflect the result of the upgrade attempt.  If
the upgrade was ignored, srx_service will match what was set in the
sendmsg(); if the upgrade happened the srx_service will be altered to
indicate the service the server upgraded to.

Note that:

 (1) The choice of upgrade service is up to the server

 (2) Further client calls to the same server that would share a connection
     are blocked if an upgrade probe is in progress.

 (3) This should only be used to probe the service.  Clients should then
     use the returned service ID in all subsequent communications with that
     server (and not set the upgrade).  Note that the kernel will not
     retain this information should the connection expire from its cache.

 (4) If a server that supports upgrading is replaced by one that doesn't,
     whilst a connection is live, and if the replacement is running, say,
     OpenAFS 1.6.4 or older or an older IBM AFS, then the replacement
     server will not respond to packets sent to the upgraded connection.

     At this point, calls will time out and the server must be reprobed.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   30 +++++++++++++++++++++++++
 include/linux/rxrpc.h              |    1 +
 include/trace/events/rxrpc.h       |    1 +
 net/rxrpc/ar-internal.h            |    3 +++
 net/rxrpc/conn_client.c            |   43 +++++++++++++++++++++++++++++-------
 net/rxrpc/input.c                  |   17 ++++++++++++++
 net/rxrpc/output.c                 |    4 +++
 net/rxrpc/sendmsg.c                |   19 +++++++++++++---
 8 files changed, 106 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 2a1662760450..18078e630a63 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -325,6 +325,8 @@ calls, to invoke certain actions and to report certain conditions.  These are:
 	RXRPC_LOCAL_ERROR	-rt error num	Local error encountered
 	RXRPC_NEW_CALL		-r- n/a		New call received
 	RXRPC_ACCEPT		s-- n/a		Accept new call
+	RXRPC_EXCLUSIVE_CALL	s-- n/a		Make an exclusive client call
+	RXRPC_UPGRADE_SERVICE	s-- n/a		Client call can be upgraded
 
 	(SRT = usable in Sendmsg / delivered by Recvmsg / Terminal message)
 
@@ -387,6 +389,23 @@ calls, to invoke certain actions and to report certain conditions.  These are:
      return error ENODATA.  If the user ID is already in use by another call,
      then error EBADSLT will be returned.
 
+ (*) RXRPC_EXCLUSIVE_CALL
+
+     This is used to indicate that a client call should be made on a one-off
+     connection.  The connection is discarded once the call has terminated.
+
+ (*) RXRPC_UPGRADE_SERVICE
+
+     This is used to make a client call to probe if the specified service ID
+     may be upgraded by the server.  The caller must check msg_name returned to
+     recvmsg() for the service ID actually in use.  The operation probed must
+     be one that takes the same arguments in both services.
+
+     Once this has been used to establish the upgrade capability (or lack
+     thereof) of the server, the service ID returned should be used for all
+     future communication to that server and RXRPC_UPGRADE_SERVICE should no
+     longer be set.
+
 
 ==============
 SOCKET OPTIONS
@@ -566,6 +585,17 @@ A client would issue an operation by:
      buffer instead, and MSG_EOR will be flagged to indicate the end of that
      call.
 
+A client may ask for a service ID it knows and ask that this be upgraded to a
+better service if one is available by supplying RXRPC_UPGRADE_SERVICE on the
+first sendmsg() of a call.  The client should then check srx_service in the
+msg_name filled in by recvmsg() when collecting the result.  srx_service will
+hold the same value as given to sendmsg() if the upgrade request was ignored by
+the service - otherwise it will be altered to indicate the service ID the
+server upgraded to.  Note that the upgraded service ID is chosen by the server.
+The caller has to wait until it sees the service ID in the reply before sending
+any more calls (further calls to the same destination will be blocked until the
+probe is concluded).
+
 
 ====================
 EXAMPLE SERVER USAGE
diff --git a/include/linux/rxrpc.h b/include/linux/rxrpc.h
index 634116561a6a..707910c6c6c5 100644
--- a/include/linux/rxrpc.h
+++ b/include/linux/rxrpc.h
@@ -54,6 +54,7 @@ struct sockaddr_rxrpc {
 #define RXRPC_NEW_CALL		8	/* -r: [Service] new incoming call notification */
 #define RXRPC_ACCEPT		9	/* s-: [Service] accept request */
 #define RXRPC_EXCLUSIVE_CALL	10	/* s-: Call should be on exclusive connection */
+#define RXRPC_UPGRADE_SERVICE	11	/* s-: Request service upgrade for client call */
 
 /*
  * RxRPC security levels
diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 29a3d53a4015..ebe96796027a 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -233,6 +233,7 @@ enum rxrpc_congest_change {
 	EM(RXRPC_CONN_CLIENT_INACTIVE,		"Inac") \
 	EM(RXRPC_CONN_CLIENT_WAITING,		"Wait") \
 	EM(RXRPC_CONN_CLIENT_ACTIVE,		"Actv") \
+	EM(RXRPC_CONN_CLIENT_UPGRADE,		"Upgd") \
 	EM(RXRPC_CONN_CLIENT_CULLED,		"Cull") \
 	E_(RXRPC_CONN_CLIENT_IDLE,		"Idle") \
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index c1ebd886a53f..e9b536cb0acf 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -320,6 +320,7 @@ struct rxrpc_conn_parameters {
 	struct rxrpc_peer	*peer;		/* Remote endpoint */
 	struct key		*key;		/* Security details */
 	bool			exclusive;	/* T if conn is exclusive */
+	bool			upgrade;	/* T if service ID can be upgraded */
 	u16			service_id;	/* Service ID for this connection */
 	u32			security_level;	/* Security level selected */
 };
@@ -334,6 +335,7 @@ enum rxrpc_conn_flag {
 	RXRPC_CONN_EXPOSED,		/* Conn has extra ref for exposure */
 	RXRPC_CONN_DONT_REUSE,		/* Don't reuse this connection */
 	RXRPC_CONN_COUNTED,		/* Counted by rxrpc_nr_client_conns */
+	RXRPC_CONN_PROBING_FOR_UPGRADE,	/* Probing for service upgrade */
 };
 
 /*
@@ -350,6 +352,7 @@ enum rxrpc_conn_cache_state {
 	RXRPC_CONN_CLIENT_INACTIVE,	/* Conn is not yet listed */
 	RXRPC_CONN_CLIENT_WAITING,	/* Conn is on wait list, waiting for capacity */
 	RXRPC_CONN_CLIENT_ACTIVE,	/* Conn is on active list, doing calls */
+	RXRPC_CONN_CLIENT_UPGRADE,	/* Conn is on active list, probing for upgrade */
 	RXRPC_CONN_CLIENT_CULLED,	/* Conn is culled and delisted, doing calls */
 	RXRPC_CONN_CLIENT_IDLE,		/* Conn is on idle list, doing mostly nothing */
 	RXRPC_CONN__NR_CACHE_STATES
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 3f358bf424ad..dd8bb919c15a 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -36,12 +36,15 @@
  *
  *	rxrpc_nr_active_client_conns is held incremented also.
  *
- *  (4) CULLED - The connection got summarily culled to try and free up
+ *  (4) UPGRADE - As for ACTIVE, but only one call may be in progress and is
+ *      being used to probe for service upgrade.
+ *
+ *  (5) CULLED - The connection got summarily culled to try and free up
  *      capacity.  Calls currently in progress on the connection are allowed to
  *      continue, but new calls will have to wait.  There can be no waiters in
  *      this state - the conn would have to go to the WAITING state instead.
  *
- *  (5) IDLE - The connection has no calls in progress upon it and must have
+ *  (6) IDLE - The connection has no calls in progress upon it and must have
  *      been exposed to the world (ie. the EXPOSED flag must be set).  When it
  *      expires, the EXPOSED flag is cleared and the connection transitions to
  *      the INACTIVE state.
@@ -184,6 +187,8 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 	atomic_set(&conn->usage, 1);
 	if (cp->exclusive)
 		__set_bit(RXRPC_CONN_DONT_REUSE, &conn->flags);
+	if (cp->upgrade)
+		__set_bit(RXRPC_CONN_PROBING_FOR_UPGRADE, &conn->flags);
 
 	conn->params		= *cp;
 	conn->out_clientflag	= RXRPC_CLIENT_INITIATED;
@@ -300,7 +305,8 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 #define cmp(X) ((long)conn->params.X - (long)cp->X)
 			diff = (cmp(peer) ?:
 				cmp(key) ?:
-				cmp(security_level));
+				cmp(security_level) ?:
+				cmp(upgrade));
 #undef cmp
 			if (diff < 0) {
 				p = p->rb_left;
@@ -365,7 +371,8 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 #define cmp(X) ((long)conn->params.X - (long)candidate->params.X)
 		diff = (cmp(peer) ?:
 			cmp(key) ?:
-			cmp(security_level));
+			cmp(security_level) ?:
+			cmp(upgrade));
 #undef cmp
 		if (diff < 0) {
 			pp = &(*pp)->rb_left;
@@ -436,8 +443,13 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 static void rxrpc_activate_conn(struct rxrpc_net *rxnet,
 				struct rxrpc_connection *conn)
 {
-	trace_rxrpc_client(conn, -1, rxrpc_client_to_active);
-	conn->cache_state = RXRPC_CONN_CLIENT_ACTIVE;
+	if (test_bit(RXRPC_CONN_PROBING_FOR_UPGRADE, &conn->flags)) {
+		trace_rxrpc_client(conn, -1, rxrpc_client_to_upgrade);
+		conn->cache_state = RXRPC_CONN_CLIENT_UPGRADE;
+	} else {
+		trace_rxrpc_client(conn, -1, rxrpc_client_to_active);
+		conn->cache_state = RXRPC_CONN_CLIENT_ACTIVE;
+	}
 	rxnet->nr_active_client_conns++;
 	list_move_tail(&conn->cache_link, &rxnet->active_client_conns);
 }
@@ -461,7 +473,8 @@ static void rxrpc_animate_client_conn(struct rxrpc_net *rxnet,
 
 	_enter("%d,%d", conn->debug_id, conn->cache_state);
 
-	if (conn->cache_state == RXRPC_CONN_CLIENT_ACTIVE)
+	if (conn->cache_state == RXRPC_CONN_CLIENT_ACTIVE ||
+	    conn->cache_state == RXRPC_CONN_CLIENT_UPGRADE)
 		goto out;
 
 	spin_lock(&rxnet->client_conn_cache_lock);
@@ -474,6 +487,7 @@ static void rxrpc_animate_client_conn(struct rxrpc_net *rxnet,
 
 	switch (conn->cache_state) {
 	case RXRPC_CONN_CLIENT_ACTIVE:
+	case RXRPC_CONN_CLIENT_UPGRADE:
 	case RXRPC_CONN_CLIENT_WAITING:
 		break;
 
@@ -577,6 +591,9 @@ static void rxrpc_activate_channels_locked(struct rxrpc_connection *conn)
 	case RXRPC_CONN_CLIENT_ACTIVE:
 		mask = RXRPC_ACTIVE_CHANS_MASK;
 		break;
+	case RXRPC_CONN_CLIENT_UPGRADE:
+		mask = 0x01;
+		break;
 	default:
 		return;
 	}
@@ -787,6 +804,15 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 	spin_lock(&rxnet->client_conn_cache_lock);
 
 	switch (conn->cache_state) {
+	case RXRPC_CONN_CLIENT_UPGRADE:
+		/* Deal with termination of a service upgrade probe. */
+		if (test_bit(RXRPC_CONN_EXPOSED, &conn->flags)) {
+			clear_bit(RXRPC_CONN_PROBING_FOR_UPGRADE, &conn->flags);
+			trace_rxrpc_client(conn, channel, rxrpc_client_to_active);
+			conn->cache_state = RXRPC_CONN_CLIENT_ACTIVE;
+			rxrpc_activate_channels_locked(conn);
+		}
+		/* fall through */
 	case RXRPC_CONN_CLIENT_ACTIVE:
 		if (list_empty(&conn->waiting_calls)) {
 			rxrpc_deactivate_one_channel(conn, channel);
@@ -941,7 +967,8 @@ static void rxrpc_cull_active_client_conns(struct rxrpc_net *rxnet)
 		ASSERT(!list_empty(&rxnet->active_client_conns));
 		conn = list_entry(rxnet->active_client_conns.next,
 				  struct rxrpc_connection, cache_link);
-		ASSERTCMP(conn->cache_state, ==, RXRPC_CONN_CLIENT_ACTIVE);
+		ASSERTIFCMP(conn->cache_state != RXRPC_CONN_CLIENT_ACTIVE,
+			    conn->cache_state, ==, RXRPC_CONN_CLIENT_UPGRADE);
 
 		if (list_empty(&conn->waiting_calls)) {
 			trace_rxrpc_client(conn, -1, rxrpc_client_to_culled);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 45dba732a3b4..e56e23ed2229 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -1142,6 +1142,13 @@ void rxrpc_data_ready(struct sock *udp_sk)
 		if (sp->hdr.securityIndex != conn->security_ix)
 			goto wrong_security;
 
+		if (sp->hdr.serviceId != conn->service_id) {
+			if (!test_bit(RXRPC_CONN_PROBING_FOR_UPGRADE, &conn->flags) ||
+			    conn->service_id != conn->params.service_id)
+				goto reupgrade;
+			conn->service_id = sp->hdr.serviceId;
+		}
+		
 		if (sp->hdr.callNumber == 0) {
 			/* Connection-level packet */
 			_debug("CONN %p {%d}", conn, conn->debug_id);
@@ -1194,6 +1201,9 @@ void rxrpc_data_ready(struct sock *udp_sk)
 				rxrpc_input_implicit_end_call(conn, call);
 			call = NULL;
 		}
+
+		if (call && sp->hdr.serviceId != call->service_id)
+			call->service_id = sp->hdr.serviceId;
 	} else {
 		skew = 0;
 		call = NULL;
@@ -1237,11 +1247,18 @@ void rxrpc_data_ready(struct sock *udp_sk)
 	skb->priority = RXKADINCONSISTENCY;
 	goto post_abort;
 
+reupgrade:
+	rcu_read_unlock();
+	trace_rxrpc_abort("UPG", sp->hdr.cid, sp->hdr.callNumber, sp->hdr.seq,
+			  RX_PROTOCOL_ERROR, EBADMSG);
+	goto protocol_error;
+
 bad_message_unlock:
 	rcu_read_unlock();
 bad_message:
 	trace_rxrpc_abort("BAD", sp->hdr.cid, sp->hdr.callNumber, sp->hdr.seq,
 			  RX_PROTOCOL_ERROR, EBADMSG);
+protocol_error:
 	skb->priority = RX_PROTOCOL_ERROR;
 post_abort:
 	skb->mark = RXRPC_SKB_MARK_LOCAL_ABORT;
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 5dab1ff3a6c2..5bd2d0fa4a03 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -292,6 +292,10 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	whdr._rsvd	= htons(sp->hdr._rsvd);
 	whdr.serviceId	= htons(call->service_id);
 
+	if (test_bit(RXRPC_CONN_PROBING_FOR_UPGRADE, &conn->flags) &&
+	    sp->hdr.seq == 1)
+		whdr.userStatus	= RXRPC_USERSTATUS_SERVICE_UPGRADE;
+
 	iov[0].iov_base = &whdr;
 	iov[0].iov_len = sizeof(whdr);
 	iov[1].iov_base = skb->head;
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 96ffa5d5733b..5a4801e7f560 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -366,7 +366,8 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 			      unsigned long *user_call_ID,
 			      enum rxrpc_command *command,
 			      u32 *abort_code,
-			      bool *_exclusive)
+			      bool *_exclusive,
+			      bool *_upgrade)
 {
 	struct cmsghdr *cmsg;
 	bool got_user_ID = false;
@@ -429,6 +430,13 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 			if (len != 0)
 				return -EINVAL;
 			break;
+
+		case RXRPC_UPGRADE_SERVICE:
+			*_upgrade = true;
+			if (len != 0)
+				return -EINVAL;
+			break;
+
 		default:
 			return -EINVAL;
 		}
@@ -447,7 +455,8 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
  */
 static struct rxrpc_call *
 rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
-				  unsigned long user_call_ID, bool exclusive)
+				  unsigned long user_call_ID, bool exclusive,
+				  bool upgrade)
 	__releases(&rx->sk.sk_lock.slock)
 {
 	struct rxrpc_conn_parameters cp;
@@ -472,6 +481,7 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 	cp.key			= rx->key;
 	cp.security_level	= rx->min_sec_level;
 	cp.exclusive		= rx->exclusive | exclusive;
+	cp.upgrade		= upgrade;
 	cp.service_id		= srx->srx_service;
 	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, GFP_KERNEL);
 	/* The socket is now unlocked */
@@ -493,13 +503,14 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	struct rxrpc_call *call;
 	unsigned long user_call_ID = 0;
 	bool exclusive = false;
+	bool upgrade = true;
 	u32 abort_code = 0;
 	int ret;
 
 	_enter("");
 
 	ret = rxrpc_sendmsg_cmsg(msg, &user_call_ID, &cmd, &abort_code,
-				 &exclusive);
+				 &exclusive, &upgrade);
 	if (ret < 0)
 		goto error_release_sock;
 
@@ -521,7 +532,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		if (cmd != RXRPC_CMD_SEND_DATA)
 			goto error_release_sock;
 		call = rxrpc_new_client_call_for_sendmsg(rx, msg, user_call_ID,
-							 exclusive);
+							 exclusive, upgrade);
 		/* The socket is now unlocked... */
 		if (IS_ERR(call))
 			return PTR_ERR(call);
