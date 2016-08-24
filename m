From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/2] rxrpc: Make /proc/net/rxrpc_calls safer
Date: Wed, 24 Aug 2016 16:00:00 +0100
Message-ID: <147205080006.13418.6206630254557176879.stgit@warthog.procyon.org.uk>
References: <147205078637.13418.9976056129378485689.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147205078637.13418.9976056129378485689.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make /proc/net/rxrpc_calls safer by stashing a copy of the peer pointer in
the rxrpc_call struct and checking in the show routine that the peer
pointer, the socket pointer and the local pointer obtained from the socket
pointer aren't NULL before we use them.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    4 +++-
 net/rxrpc/call_object.c |    3 +++
 net/rxrpc/conn_client.c |    1 +
 net/rxrpc/proc.c        |   27 +++++++++++++++++++--------
 4 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 7296039c537a..5292bf0bce52 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -407,6 +407,7 @@ enum rxrpc_call_state {
 struct rxrpc_call {
 	struct rcu_head		rcu;
 	struct rxrpc_connection	*conn;		/* connection carrying call */
+	struct rxrpc_peer	*peer;		/* Peer record for remote address */
 	struct rxrpc_sock	*socket;	/* socket responsible */
 	struct timer_list	lifetimer;	/* lifetime remaining on call */
 	struct timer_list	deadspan;	/* reap timer for re-ACK'ing, etc  */
@@ -717,9 +718,10 @@ struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *,
 				     struct sockaddr_rxrpc *, gfp_t);
 struct rxrpc_peer *rxrpc_alloc_peer(struct rxrpc_local *, gfp_t);
 
-static inline void rxrpc_get_peer(struct rxrpc_peer *peer)
+static inline struct rxrpc_peer *rxrpc_get_peer(struct rxrpc_peer *peer)
 {
 	atomic_inc(&peer->usage);
+	return peer;
 }
 
 static inline
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 4af01805bfc7..f23432591a0f 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -315,6 +315,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	chan = sp->hdr.cid & RXRPC_CHANNELMASK;
 	candidate->socket	= rx;
 	candidate->conn		= conn;
+	candidate->peer		= conn->params.peer;
 	candidate->cid		= sp->hdr.cid;
 	candidate->call_id	= sp->hdr.callNumber;
 	candidate->rx_data_post	= 0;
@@ -384,6 +385,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	rcu_assign_pointer(conn->channels[chan].call, call);
 	sock_hold(&rx->sk);
 	rxrpc_get_connection(conn);
+	rxrpc_get_peer(call->peer);
 	spin_unlock(&conn->channel_lock);
 
 	spin_lock(&conn->params.peer->lock);
@@ -610,6 +612,7 @@ static void rxrpc_rcu_destroy_call(struct rcu_head *rcu)
 	struct rxrpc_call *call = container_of(rcu, struct rxrpc_call, rcu);
 
 	rxrpc_purge_queue(&call->rx_queue);
+	rxrpc_put_peer(call->peer);
 	kmem_cache_free(rxrpc_call_jar, call);
 }
 
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index fc32cc67c2de..2d43c99e5360 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -280,6 +280,7 @@ attached:
 found_channel:
 	_debug("found chan");
 	call->conn	= conn;
+	call->peer	= rxrpc_get_peer(conn->params.peer);
 	call->cid	= conn->proto.cid | chan;
 	call->call_id	= ++conn->channels[chan].call_counter;
 	conn->channels[chan].call_id = call->call_id;
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index 31b7f36a39cb..53872631a66d 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -46,7 +46,9 @@ static void rxrpc_call_seq_stop(struct seq_file *seq, void *v)
 
 static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 {
-	struct rxrpc_connection *conn;
+	struct rxrpc_local *local;
+	struct rxrpc_sock *rx;
+	struct rxrpc_peer *peer;
 	struct rxrpc_call *call;
 	char lbuff[4 + 4 + 4 + 4 + 5 + 1], rbuff[4 + 4 + 4 + 4 + 5 + 1];
 
@@ -60,15 +62,24 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 
 	call = list_entry(v, struct rxrpc_call, link);
 
-	sprintf(lbuff, "%pI4:%u",
-		&call->socket->local->srx.transport.sin.sin_addr,
-		ntohs(call->socket->local->srx.transport.sin.sin_port));
+	rx = READ_ONCE(call->socket);
+	if (rx) {
+		local = READ_ONCE(rx->local);
+		if (local)
+			sprintf(lbuff, "%pI4:%u",
+				&local->srx.transport.sin.sin_addr,
+				ntohs(local->srx.transport.sin.sin_port));
+		else
+			strcpy(lbuff, "no_local");
+	} else {
+		strcpy(lbuff, "no_socket");
+	}
 
-	conn = call->conn;
-	if (conn)
+	peer = call->peer;
+	if (peer)
 		sprintf(rbuff, "%pI4:%u",
-			&conn->params.peer->srx.transport.sin.sin_addr,
-			ntohs(conn->params.peer->srx.transport.sin.sin_port));
+			&peer->srx.transport.sin.sin_addr,
+			ntohs(peer->srx.transport.sin.sin_port));
 	else
 		strcpy(rbuff, "no_connection");
 
