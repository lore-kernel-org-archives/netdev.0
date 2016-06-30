From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 17/19] rxrpc: Prune the contents of the
 rxrpc_conn_proto struct
Date: Thu, 30 Jun 2016 15:12:44 +0100
Message-ID: <146729596430.26306.8396808153971578445.stgit@warthog.procyon.org.uk>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prune the contents of the rxrpc_conn_proto struct.  Most of the fields aren't
used anymore.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h  |   20 +++++++-------------
 net/rxrpc/call_object.c  |    2 +-
 net/rxrpc/conn_client.c  |   11 -----------
 net/rxrpc/conn_service.c |    2 --
 net/rxrpc/proc.c         |    6 ++++--
 5 files changed, 12 insertions(+), 29 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 71618e983b4a..db866552877e 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -229,18 +229,12 @@ struct rxrpc_peer {
  * Keys for matching a connection.
  */
 struct rxrpc_conn_proto {
-	unsigned long		hash_key;
-	struct rxrpc_local	*local;		/* Representation of local endpoint */
-	u32			epoch;		/* epoch of this connection */
-	u32			cid;		/* connection ID */
-	u8			in_clientflag;	/* RXRPC_CLIENT_INITIATED if we are server */
-	u8			addr_size;	/* Size of the address */
-	sa_family_t		family;		/* Transport protocol */
-	__be16			port;		/* Peer UDP/UDP6 port */
-	union {					/* Peer address */
-		struct in_addr	ipv4_addr;
-		struct in6_addr	ipv6_addr;
-		u32		raw_addr[0];
+	union {
+		struct {
+			u32	epoch;		/* epoch of this connection */
+			u32	cid;		/* connection ID */
+		};
+		u64		index_key;
 	};
 };
 
@@ -586,7 +580,7 @@ static inline bool rxrpc_conn_is_client(const struct rxrpc_connection *conn)
 
 static inline bool rxrpc_conn_is_service(const struct rxrpc_connection *conn)
 {
-	return conn->proto.in_clientflag;
+	return !rxrpc_conn_is_client(conn);
 }
 
 static inline void rxrpc_get_connection(struct rxrpc_connection *conn)
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 118b0c00a7b4..a88a94c16402 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -566,7 +566,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	}
 	call->epoch = conn->proto.epoch;
 	call->service_id = conn->params.service_id;
-	call->in_clientflag = conn->proto.in_clientflag;
+	call->in_clientflag = RXRPC_CLIENT_INITIATED;
 	/* Add the new call to the hashtable */
 	rxrpc_call_hash_add(call);
 
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 52809e21f56d..74b97f67acf5 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -132,22 +132,11 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 	}
 
 	conn->params		= *cp;
-	conn->proto.local	= cp->local;
 	conn->proto.epoch	= rxrpc_epoch;
 	conn->proto.cid		= 0;
-	conn->proto.in_clientflag = 0;
-	conn->proto.family	= cp->peer->srx.transport.family;
 	conn->out_clientflag	= RXRPC_CLIENT_INITIATED;
 	conn->state		= RXRPC_CONN_CLIENT;
 
-	switch (conn->proto.family) {
-	case AF_INET:
-		conn->proto.addr_size = sizeof(conn->proto.ipv4_addr);
-		conn->proto.ipv4_addr = cp->peer->srx.transport.sin.sin_addr;
-		conn->proto.port = cp->peer->srx.transport.sin.sin_port;
-		break;
-	}
-
 	ret = rxrpc_get_client_connection_id(conn, gfp);
 	if (ret < 0)
 		goto error_0;
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index 4ae9a9e7f31f..ac56ecf1c079 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -71,10 +71,8 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	candidate->proto.local		= local;
 	candidate->proto.epoch		= sp->hdr.epoch;
 	candidate->proto.cid		= sp->hdr.cid & RXRPC_CIDMASK;
-	candidate->proto.in_clientflag	= RXRPC_CLIENT_INITIATED;
 	candidate->params.local		= local;
 	candidate->params.peer		= peer;
 	candidate->params.service_id	= sp->hdr.serviceId;
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index ed5a94d8be7b..f8a3d0f285e5 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -67,7 +67,8 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	conn = call->conn;
 	if (conn)
 		sprintf(rbuff, "%pI4:%u",
-			&conn->proto.ipv4_addr, ntohs(conn->proto.port));
+			&conn->params.peer->srx.transport.sin.sin_addr,
+			ntohs(conn->params.peer->srx.transport.sin.sin_port));
 	else
 		strcpy(rbuff, "no_connection");
 
@@ -149,7 +150,8 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 		ntohs(conn->params.local->srx.transport.sin.sin_port));
 
 	sprintf(rbuff, "%pI4:%u",
-		&conn->proto.ipv4_addr, ntohs(conn->proto.port));
+		&conn->params.peer->srx.transport.sin.sin_addr,
+		ntohs(conn->params.peer->srx.transport.sin.sin_port));
 
 	seq_printf(seq,
 		   "UDP   %-22.22s %-22.22s %4x %08x %s %3u"
