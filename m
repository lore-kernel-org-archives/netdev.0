From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/8] AF_RXRPC: Lower dead call timeout and fix available call
	counting on connections
Date: Wed, 11 Apr 2007 20:10:07 +0100
Message-ID: <20070411191007.15499.363.stgit@warthog.cambridge.redhat.com>
References: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964862AbXDKTKx@vger.kernel.org>
In-Reply-To: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make a couple of fixes to AF_RXRPC:

 (1) The dead call timeout is shortened to 2 seconds.  Without this, each
     completed call sits around eating up resources for 10 seconds.  The calls
     need to hang around for a little while in case duplicate packets appear,
     but 10 seconds is excessive.

 (2) The number of available calls on a connection (conn->avail_calls) wasn't
     being decremented when a new call was allocated for a connection that
     didn't have any calls in progress.  This an occasional BUG occurring when
     we tried to find an empty channel slot on a connection that was supposed
     to have one available and didn't.

     In association with this, more assertions have been added to check this.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-call.c       |   59 +++++++++++++++++++++++++++++----------------
 net/rxrpc/ar-connection.c |   20 ++++++++++++++-
 2 files changed, 56 insertions(+), 23 deletions(-)

diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 1d7698a..4d92d88 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -19,7 +19,7 @@ struct kmem_cache *rxrpc_call_jar;
 LIST_HEAD(rxrpc_calls);
 DEFINE_RWLOCK(rxrpc_call_lock);
 static unsigned rxrpc_call_max_lifetime = 60;
-static unsigned rxrpc_dead_call_timeout = 10;
+static unsigned rxrpc_dead_call_timeout = 2;
 
 static void rxrpc_destroy_call(struct work_struct *work);
 static void rxrpc_call_life_expired(unsigned long _call);
@@ -398,6 +398,7 @@ found_extant_call:
  */
 void rxrpc_release_call(struct rxrpc_call *call)
 {
+	struct rxrpc_connection *conn = call->conn;
 	struct rxrpc_sock *rx = call->socket;
 
 	_enter("{%d,%d,%d,%d}",
@@ -413,8 +414,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	/* dissociate from the socket
 	 * - the socket's ref on the call is passed to the death timer
 	 */
-	_debug("RELEASE CALL %p (%d CONN %p)",
-	       call, call->debug_id, call->conn);
+	_debug("RELEASE CALL %p (%d CONN %p)", call, call->debug_id, conn);
 
 	write_lock_bh(&rx->call_lock);
 	if (!list_empty(&call->accept_link)) {
@@ -430,24 +430,42 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	}
 	write_unlock_bh(&rx->call_lock);
 
-	if (call->conn->out_clientflag)
-		spin_lock(&call->conn->trans->client_lock);
-	write_lock_bh(&call->conn->lock);
-
 	/* free up the channel for reuse */
-	if (call->conn->out_clientflag) {
-		call->conn->avail_calls++;
-		if (call->conn->avail_calls == RXRPC_MAXCALLS)
-			list_move_tail(&call->conn->bundle_link,
-				       &call->conn->bundle->unused_conns);
-		else if (call->conn->avail_calls == 1)
-			list_move_tail(&call->conn->bundle_link,
-				       &call->conn->bundle->avail_conns);
+	spin_lock(&conn->trans->client_lock);
+	write_lock_bh(&conn->lock);
+	write_lock(&call->state_lock);
+
+	if (conn->channels[call->channel] == call)
+		conn->channels[call->channel] = NULL;
+
+	if (conn->out_clientflag && conn->bundle) {
+		conn->avail_calls++;
+		switch (conn->avail_calls) {
+		case 1:
+			list_move_tail(&conn->bundle_link,
+				       &conn->bundle->avail_conns);
+		case 2 ... RXRPC_MAXCALLS - 1:
+			ASSERT(conn->channels[0] == NULL ||
+			       conn->channels[1] == NULL ||
+			       conn->channels[2] == NULL ||
+			       conn->channels[3] == NULL);
+			break;
+		case RXRPC_MAXCALLS:
+			list_move_tail(&conn->bundle_link,
+				       &conn->bundle->unused_conns);
+			ASSERT(conn->channels[0] == NULL &&
+			       conn->channels[1] == NULL &&
+			       conn->channels[2] == NULL &&
+			       conn->channels[3] == NULL);
+			break;
+		default:
+			printk(KERN_ERR "RxRPC: conn->avail_calls=%d\n",
+			       conn->avail_calls);
+			BUG();
+		}
 	}
 
-	write_lock(&call->state_lock);
-	if (call->conn->channels[call->channel] == call)
-		call->conn->channels[call->channel] = NULL;
+	spin_unlock(&conn->trans->client_lock);
 
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    call->state != RXRPC_CALL_CLIENT_FINAL_ACK) {
@@ -458,10 +476,9 @@ void rxrpc_release_call(struct rxrpc_call *call)
 		rxrpc_queue_call(call);
 	}
 	write_unlock(&call->state_lock);
-	write_unlock_bh(&call->conn->lock);
-	if (call->conn->out_clientflag)
-		spin_unlock(&call->conn->trans->client_lock);
+	write_unlock_bh(&conn->lock);
 
+	/* clean up the Rx queue */
 	if (!skb_queue_empty(&call->rx_queue) ||
 	    !skb_queue_empty(&call->rx_oos_queue)) {
 		struct rxrpc_skb_priv *sp;
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 2d0efaa..5bb2673 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -356,7 +356,7 @@ static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
 		conn->out_clientflag = RXRPC_CLIENT_INITIATED;
 		conn->cid = 0;
 		conn->state = RXRPC_CONN_CLIENT;
-		conn->avail_calls = RXRPC_MAXCALLS;
+		conn->avail_calls = RXRPC_MAXCALLS - 1;
 		conn->security_level = rx->min_sec_level;
 		conn->key = key_get(rx->key);
 
@@ -447,6 +447,11 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 			if (--conn->avail_calls == 0)
 				list_move(&conn->bundle_link,
 					  &bundle->busy_conns);
+			ASSERTCMP(conn->avail_calls, <, RXRPC_MAXCALLS);
+			ASSERT(conn->channels[0] == NULL ||
+			       conn->channels[1] == NULL ||
+			       conn->channels[2] == NULL ||
+			       conn->channels[3] == NULL);
 			atomic_inc(&conn->usage);
 			break;
 		}
@@ -456,6 +461,12 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 			conn = list_entry(bundle->unused_conns.next,
 					  struct rxrpc_connection,
 					  bundle_link);
+			ASSERTCMP(conn->avail_calls, ==, RXRPC_MAXCALLS);
+			conn->avail_calls = RXRPC_MAXCALLS - 1;
+			ASSERT(conn->channels[0] == NULL &&
+			       conn->channels[1] == NULL &&
+			       conn->channels[2] == NULL &&
+			       conn->channels[3] == NULL);
 			atomic_inc(&conn->usage);
 			list_move(&conn->bundle_link, &bundle->avail_conns);
 			break;
@@ -512,7 +523,7 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 		candidate->state = RXRPC_CONN_CLIENT;
 		candidate->avail_calls = RXRPC_MAXCALLS;
 		candidate->security_level = rx->min_sec_level;
-		candidate->key = key_get(rx->key);
+		candidate->key = key_get(bundle->key);
 
 		ret = rxrpc_init_client_conn_security(candidate);
 		if (ret < 0) {
@@ -555,6 +566,10 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
 		if (!conn->channels[chan])
 			goto found_channel;
+	ASSERT(conn->channels[0] == NULL ||
+	       conn->channels[1] == NULL ||
+	       conn->channels[2] == NULL ||
+	       conn->channels[3] == NULL);
 	BUG();
 
 found_channel:
@@ -567,6 +582,7 @@ found_channel:
 	_net("CONNECT client on conn %d chan %d as call %x",
 	     conn->debug_id, chan, ntohl(call->call_id));
 
+	ASSERTCMP(conn->avail_calls, <, RXRPC_MAXCALLS);
 	spin_unlock(&trans->client_lock);
 
 	rxrpc_add_call_ID_to_conn(conn, call);
