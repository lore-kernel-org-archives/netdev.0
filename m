From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 07/24] rxrpc: Turn connection #defines into enums
 and put outside struct def
Date: Tue, 05 Jul 2016 14:13:01 +0100
Message-ID: <146772438137.21657.1609850494609329594.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754977AbcGENND (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 09:13:03 -0400
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn the connection event and state #define lists into enums and move
outside of the struct definition.

Whilst we're at it, change _SERVER to _SERVICE in those identifiers and add
EV_ into the event name to distinguish them from flags and states.

Also add a symbol indicating the number of states and use that in the state
text array.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   42 ++++++++++++++++++++++++++++++------------
 net/rxrpc/call_accept.c |    6 +++---
 net/rxrpc/conn_event.c  |    6 +++---
 net/rxrpc/conn_object.c |    4 ++--
 net/rxrpc/proc.c        |   18 +++++++++---------
 5 files changed, 47 insertions(+), 29 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index f2b1c6dd5e9a..6f62b0eef0e0 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -254,6 +254,35 @@ struct rxrpc_conn_parameters {
 };
 
 /*
+ * Bits in the connection flags.
+ */
+enum rxrpc_conn_flag {
+	RXRPC_CONN_HAS_IDR,		/* Has a client conn ID assigned */
+};
+
+/*
+ * Events that can be raised upon a connection.
+ */
+enum rxrpc_conn_event {
+	RXRPC_CONN_EV_CHALLENGE,	/* Send challenge packet */
+};
+
+/*
+ * The connection protocol state.
+ */
+enum rxrpc_conn_proto_state {
+	RXRPC_CONN_UNUSED,		/* Connection not yet attempted */
+	RXRPC_CONN_CLIENT,		/* Client connection */
+	RXRPC_CONN_SERVICE_UNSECURED,	/* Service unsecured connection */
+	RXRPC_CONN_SERVICE_CHALLENGING,	/* Service challenging for security */
+	RXRPC_CONN_SERVICE,		/* Service secured connection */
+	RXRPC_CONN_REMOTELY_ABORTED,	/* Conn aborted by peer */
+	RXRPC_CONN_LOCALLY_ABORTED,	/* Conn aborted locally */
+	RXRPC_CONN_NETWORK_ERROR,	/* Conn terminated by network error */
+	RXRPC_CONN__NR_STATES
+};
+
+/*
  * RxRPC connection definition
  * - matched by { local, peer, epoch, conn_id, direction }
  * - each connection can only handle four simultaneous calls
@@ -280,23 +309,12 @@ struct rxrpc_connection {
 	struct crypto_skcipher	*cipher;	/* encryption handle */
 	struct rxrpc_crypt	csum_iv;	/* packet checksum base */
 	unsigned long		flags;
-#define RXRPC_CONN_HAS_IDR	0		/* - Has a client conn ID assigned */
 	unsigned long		events;
-#define RXRPC_CONN_CHALLENGE	0		/* send challenge packet */
 	unsigned long		put_time;	/* Time at which last put */
 	rwlock_t		lock;		/* access lock */
 	spinlock_t		state_lock;	/* state-change lock */
 	atomic_t		usage;
-	enum {					/* current state of connection */
-		RXRPC_CONN_UNUSED,		/* - connection not yet attempted */
-		RXRPC_CONN_CLIENT,		/* - client connection */
-		RXRPC_CONN_SERVER_UNSECURED,	/* - server unsecured connection */
-		RXRPC_CONN_SERVER_CHALLENGING,	/* - server challenging for security */
-		RXRPC_CONN_SERVER,		/* - server secured connection */
-		RXRPC_CONN_REMOTELY_ABORTED,	/* - conn aborted by peer */
-		RXRPC_CONN_LOCALLY_ABORTED,	/* - conn aborted locally */
-		RXRPC_CONN_NETWORK_ERROR,	/* - conn terminated by network error */
-	} state;
+	enum rxrpc_conn_proto_state state : 8;	/* current state of connection */
 	u32			local_abort;	/* local abort code */
 	u32			remote_abort;	/* remote abort code */
 	int			error;		/* local error incurred */
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 202e053a3c6d..1c0860df150e 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -128,12 +128,12 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 
 		spin_lock(&call->conn->state_lock);
 		if (sp->hdr.securityIndex > 0 &&
-		    call->conn->state == RXRPC_CONN_SERVER_UNSECURED) {
+		    call->conn->state == RXRPC_CONN_SERVICE_UNSECURED) {
 			_debug("await conn sec");
 			list_add_tail(&call->accept_link, &rx->secureq);
-			call->conn->state = RXRPC_CONN_SERVER_CHALLENGING;
+			call->conn->state = RXRPC_CONN_SERVICE_CHALLENGING;
 			rxrpc_get_connection(call->conn);
-			set_bit(RXRPC_CONN_CHALLENGE, &call->conn->events);
+			set_bit(RXRPC_CONN_EV_CHALLENGE, &call->conn->events);
 			rxrpc_queue_conn(call->conn);
 		} else {
 			_debug("conn ready");
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index d7e183c6b5df..b9c39b83eddb 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -195,8 +195,8 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		read_lock_bh(&conn->lock);
 		spin_lock(&conn->state_lock);
 
-		if (conn->state == RXRPC_CONN_SERVER_CHALLENGING) {
-			conn->state = RXRPC_CONN_SERVER;
+		if (conn->state == RXRPC_CONN_SERVICE_CHALLENGING) {
+			conn->state = RXRPC_CONN_SERVICE;
 			for (loop = 0; loop < RXRPC_MAXCALLS; loop++)
 				rxrpc_call_is_secure(conn->channels[loop]);
 		}
@@ -268,7 +268,7 @@ void rxrpc_process_connection(struct work_struct *work)
 
 	rxrpc_get_connection(conn);
 
-	if (test_and_clear_bit(RXRPC_CONN_CHALLENGE, &conn->events)) {
+	if (test_and_clear_bit(RXRPC_CONN_EV_CHALLENGE, &conn->events)) {
 		rxrpc_secure_connection(conn);
 		rxrpc_put_connection(conn);
 	}
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index b54e2be0a0b1..f28578b31281 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -402,9 +402,9 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 	candidate->params.service_id	= sp->hdr.serviceId;
 	candidate->security_ix		= sp->hdr.securityIndex;
 	candidate->out_clientflag	= 0;
-	candidate->state		= RXRPC_CONN_SERVER;
+	candidate->state		= RXRPC_CONN_SERVICE;
 	if (candidate->params.service_id)
-		candidate->state	= RXRPC_CONN_SERVER_UNSECURED;
+		candidate->state	= RXRPC_CONN_SERVICE_UNSECURED;
 
 	write_lock_bh(&peer->conn_lock);
 
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index afb5e1bc1b6e..46d470335263 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -14,15 +14,15 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
-static const char *const rxrpc_conn_states[] = {
-	[RXRPC_CONN_UNUSED]		= "Unused  ",
-	[RXRPC_CONN_CLIENT]		= "Client  ",
-	[RXRPC_CONN_SERVER_UNSECURED]	= "SvUnsec ",
-	[RXRPC_CONN_SERVER_CHALLENGING]	= "SvChall ",
-	[RXRPC_CONN_SERVER]		= "SvSecure",
-	[RXRPC_CONN_REMOTELY_ABORTED]	= "RmtAbort",
-	[RXRPC_CONN_LOCALLY_ABORTED]	= "LocAbort",
-	[RXRPC_CONN_NETWORK_ERROR]	= "NetError",
+static const char *const rxrpc_conn_states[RXRPC_CONN__NR_STATES] = {
+	[RXRPC_CONN_UNUSED]			= "Unused  ",
+	[RXRPC_CONN_CLIENT]			= "Client  ",
+	[RXRPC_CONN_SERVICE_UNSECURED]		= "SvUnsec ",
+	[RXRPC_CONN_SERVICE_CHALLENGING]	= "SvChall ",
+	[RXRPC_CONN_SERVICE]			= "SvSecure",
+	[RXRPC_CONN_REMOTELY_ABORTED]		= "RmtAbort",
+	[RXRPC_CONN_LOCALLY_ABORTED]		= "LocAbort",
+	[RXRPC_CONN_NETWORK_ERROR]		= "NetError",
 };
 
 /*
