From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next] rxrpc: Cache the congestion window setting
Date: Wed, 14 Jun 2017 17:56:50 +0100
Message-ID: <149745941093.31933.4996708684908629747.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cache the congestion window setting that was determined during a call's
transmission phase when it finishes so that it can be used by the next call
to the same peer, thereby shortcutting the slow-start algorithm.

The value is stored in the rxrpc_peer struct and is accessed without
locking.  Each call takes the value that happens to be there when it starts
and just overwrites the value when it finishes.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    2 ++
 net/rxrpc/call_accept.c |    1 +
 net/rxrpc/call_object.c |    7 +------
 net/rxrpc/conn_client.c |    6 ++++++
 net/rxrpc/conn_object.c |    2 ++
 net/rxrpc/peer_object.c |    7 +++++++
 6 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index adbf37946450..69b97339ff9d 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -300,6 +300,8 @@ struct rxrpc_peer {
 	u64			rtt_cache[RXRPC_RTT_CACHE_SIZE]; /* Determined RTT cache */
 	u8			rtt_cursor;	/* next entry at which to insert */
 	u8			rtt_usage;	/* amount of cache actually used */
+
+	u8			cong_cwnd;	/* Congestion window size */
 };
 
 /*
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 0d4d84e8c074..dd30d74824b0 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -310,6 +310,7 @@ static struct rxrpc_call *rxrpc_alloc_incoming_call(struct rxrpc_sock *rx,
 	rxrpc_see_call(call);
 	call->conn = conn;
 	call->peer = rxrpc_get_peer(conn->params.peer);
+	call->cong_cwnd = call->peer->cong_cwnd;
 	return call;
 }
 
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 423030fd93be..d7809a0620b4 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -136,12 +136,7 @@ struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 	call->tx_winsize = 16;
 	call->rx_expect_next = 1;
 
-	if (RXRPC_TX_SMSS > 2190)
-		call->cong_cwnd = 2;
-	else if (RXRPC_TX_SMSS > 1095)
-		call->cong_cwnd = 3;
-	else
-		call->cong_cwnd = 4;
+	call->cong_cwnd = 2;
 	call->cong_ssthresh = RXRPC_RXTX_BUFF_SIZE - 1;
 	return call;
 
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index dd8bb919c15a..eb2157680399 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -292,6 +292,12 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 	if (!cp->peer)
 		goto error;
 
+	call->cong_cwnd = cp->peer->cong_cwnd;
+	if (call->cong_cwnd >= call->cong_ssthresh)
+		call->cong_mode = RXRPC_CALL_CONGEST_AVOIDANCE;
+	else
+		call->cong_mode = RXRPC_CALL_SLOW_START;
+
 	/* If the connection is not meant to be exclusive, search the available
 	 * connections to see if the connection we want to use already exists.
 	 */
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 5bb255107427..929b50d5afe8 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -193,6 +193,8 @@ void rxrpc_disconnect_call(struct rxrpc_call *call)
 {
 	struct rxrpc_connection *conn = call->conn;
 
+	call->peer->cong_cwnd = call->cong_cwnd;
+
 	spin_lock_bh(&conn->params.peer->lock);
 	hlist_del_init(&call->error_link);
 	spin_unlock_bh(&conn->params.peer->lock);
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index cfed3b27adf0..5787f97f5330 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -228,6 +228,13 @@ struct rxrpc_peer *rxrpc_alloc_peer(struct rxrpc_local *local, gfp_t gfp)
 		seqlock_init(&peer->service_conn_lock);
 		spin_lock_init(&peer->lock);
 		peer->debug_id = atomic_inc_return(&rxrpc_debug_id);
+
+		if (RXRPC_TX_SMSS > 2190)
+			peer->cong_cwnd = 2;
+		else if (RXRPC_TX_SMSS > 1095)
+			peer->cong_cwnd = 3;
+		else
+			peer->cong_cwnd = 4;
 	}
 
 	_leave(" = %p", peer);
