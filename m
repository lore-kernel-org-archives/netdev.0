From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/8] rxrpc: Cache the security index in the
 rxrpc_call struct
Date: Wed, 07 Sep 2016 16:23:01 +0100
Message-ID: <147326178174.26593.6865848746796250627.stgit@warthog.procyon.org.uk>
References: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cache the security index in the rxrpc_call struct so that we can get at it
even when the call has been disconnected and the connection pointer
cleared.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    1 +
 net/rxrpc/call_object.c |    1 +
 net/rxrpc/conn_client.c |    3 +++
 net/rxrpc/input.c       |    2 +-
 net/rxrpc/sendmsg.c     |    2 +-
 5 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 913255a53564..e3dfc9da05fe 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -475,6 +475,7 @@ struct rxrpc_call {
 	atomic_t		skb_count;	/* Outstanding packets on this call */
 	atomic_t		sequence;	/* Tx data packet sequence counter */
 	u16			service_id;	/* service ID */
+	u8			security_ix;	/* Security type */
 	u32			call_id;	/* call ID on connection  */
 	u32			cid;		/* connection ID plus channel index */
 	int			debug_id;	/* debug ID for printks */
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 060ddc32a85e..83019e489555 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -345,6 +345,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	candidate->peer		= conn->params.peer;
 	candidate->cid		= sp->hdr.cid;
 	candidate->call_id	= sp->hdr.callNumber;
+	candidate->security_ix	= sp->hdr.securityIndex;
 	candidate->rx_data_post	= 0;
 	candidate->state	= RXRPC_CALL_SERVER_ACCEPTING;
 	candidate->flags	|= (1 << RXRPC_CALL_IS_SERVICE);
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 82de1aeaef21..9344a8416ceb 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -348,6 +348,7 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 
 	if (cp->exclusive) {
 		call->conn = candidate;
+		call->security_ix = candidate->security_ix;
 		_leave(" = 0 [exclusive %d]", candidate->debug_id);
 		return 0;
 	}
@@ -395,6 +396,7 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 candidate_published:
 	set_bit(RXRPC_CONN_IN_CLIENT_CONNS, &candidate->flags);
 	call->conn = candidate;
+	call->security_ix = candidate->security_ix;
 	spin_unlock(&local->client_conns_lock);
 	_leave(" = 0 [new %d]", candidate->debug_id);
 	return 0;
@@ -412,6 +414,7 @@ found_extant_conn:
 
 	spin_lock(&conn->channel_lock);
 	call->conn = conn;
+	call->security_ix = conn->security_ix;
 	list_add(&call->chan_wait_link, &conn->waiting_calls);
 	spin_unlock(&conn->channel_lock);
 	_leave(" = 0 [extant %d]", conn->debug_id);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index f7239a6f9181..9242fefd7f40 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -198,7 +198,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 
 	/* if the packet need security things doing to it, then it goes down
 	 * the slow path */
-	if (call->conn->security_ix)
+	if (call->security_ix)
 		goto enqueue_packet;
 
 	sp->call = call;
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 803078bea507..2439aff131c7 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -322,7 +322,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			sp->hdr.serial	= atomic_inc_return(&conn->serial);
 			sp->hdr.type	= RXRPC_PACKET_TYPE_DATA;
 			sp->hdr.userStatus = 0;
-			sp->hdr.securityIndex = conn->security_ix;
+			sp->hdr.securityIndex = call->security_ix;
 			sp->hdr._rsvd	= 0;
 			sp->hdr.serviceId = call->service_id;
 
