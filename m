From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 12/14] rxrpc: Provide more refcount helper
 functions [ver #2]
Date: Wed, 22 Jun 2016 17:04:17 +0100
Message-ID: <146661145773.15011.3231923495698331414.stgit@warthog.procyon.org.uk>
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

Provide refcount helper functions for connections so that the code doesn't
touch local or connection usage counts directly.

Also make it such that local and peer put functions can take a NULL
pointer.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c     |    7 ++-----
 net/rxrpc/ar-internal.h  |   15 +++++++++++++--
 net/rxrpc/call_accept.c  |    2 +-
 net/rxrpc/call_object.c  |    2 +-
 net/rxrpc/conn_event.c   |    2 +-
 net/rxrpc/conn_object.c  |   12 ++++++------
 net/rxrpc/input.c        |    2 +-
 net/rxrpc/local_object.c |    2 +-
 8 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index b29bb50af5de..57dcbfc061e4 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -674,11 +674,8 @@ static int rxrpc_release_sock(struct sock *sk)
 	flush_workqueue(rxrpc_workqueue);
 	rxrpc_purge_queue(&sk->sk_receive_queue);
 
-	if (rx->local) {
-		rxrpc_put_local(rx->local);
-		rx->local = NULL;
-	}
-
+	rxrpc_put_local(rx->local);
+	rx->local = NULL;
 	key_put(rx->key);
 	rx->key = NULL;
 	key_put(rx->securities);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index cfbd028aa551..c0ed5e7f22ef 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -597,6 +597,17 @@ static inline bool rxrpc_conn_is_service(const struct rxrpc_connection *conn)
 	return conn->proto.in_clientflag;
 }
 
+static inline void rxrpc_get_connection(struct rxrpc_connection *conn)
+{
+	atomic_inc(&conn->usage);
+}
+
+static inline
+struct rxrpc_connection *rxrpc_get_connection_maybe(struct rxrpc_connection *conn)
+{
+	return atomic_inc_not_zero(&conn->usage) ? conn : NULL;
+}
+
 /*
  * input.c
  */
@@ -645,7 +656,7 @@ struct rxrpc_local *rxrpc_get_local_maybe(struct rxrpc_local *local)
 
 static inline void rxrpc_put_local(struct rxrpc_local *local)
 {
-	if (atomic_dec_and_test(&local->usage))
+	if (local && atomic_dec_and_test(&local->usage))
 		__rxrpc_put_local(local);
 }
 
@@ -702,7 +713,7 @@ struct rxrpc_peer *rxrpc_get_peer_maybe(struct rxrpc_peer *peer)
 extern void __rxrpc_put_peer(struct rxrpc_peer *peer);
 static inline void rxrpc_put_peer(struct rxrpc_peer *peer)
 {
-	if (atomic_dec_and_test(&peer->usage))
+	if (peer && atomic_dec_and_test(&peer->usage))
 		__rxrpc_put_peer(peer);
 }
 
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 5a70dc4e28c6..833ad0622b61 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -141,7 +141,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 			_debug("await conn sec");
 			list_add_tail(&call->accept_link, &rx->secureq);
 			call->conn->state = RXRPC_CONN_SERVER_CHALLENGING;
-			atomic_inc(&call->conn->usage);
+			rxrpc_get_connection(call->conn);
 			set_bit(RXRPC_CONN_CHALLENGE, &call->conn->events);
 			rxrpc_queue_conn(call->conn);
 		} else {
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index d83f2cbb80a9..45849a66bc56 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -515,7 +515,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	rb_insert_color(&call->conn_node, &conn->calls);
 	conn->channels[call->channel] = call;
 	sock_hold(&rx->sk);
-	atomic_inc(&conn->usage);
+	rxrpc_get_connection(conn);
 	write_unlock_bh(&conn->lock);
 
 	spin_lock(&conn->params.peer->lock);
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index a022439f6f5a..bf6971555eac 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -263,7 +263,7 @@ void rxrpc_process_connection(struct work_struct *work)
 
 	_enter("{%d}", conn->debug_id);
 
-	atomic_inc(&conn->usage);
+	rxrpc_get_connection(conn);
 
 	if (test_and_clear_bit(RXRPC_CONN_CHALLENGE, &conn->events)) {
 		rxrpc_secure_connection(conn);
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 312b75091d29..1754f2e2e16b 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -333,7 +333,7 @@ static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
 	 * channel.
 	 */
 	chan = 0;
-	atomic_inc(&conn->usage);
+	rxrpc_get_connection(conn);
 	conn->avail_calls = RXRPC_MAXCALLS - 1;
 	conn->channels[chan] = call;
 	conn->call_counter = 1;
@@ -392,7 +392,7 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 			       conn->channels[1] == NULL ||
 			       conn->channels[2] == NULL ||
 			       conn->channels[3] == NULL);
-			atomic_inc(&conn->usage);
+			rxrpc_get_connection(conn);
 			break;
 		}
 
@@ -412,7 +412,7 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 			       conn->channels[1] == NULL &&
 			       conn->channels[2] == NULL &&
 			       conn->channels[3] == NULL);
-			atomic_inc(&conn->usage);
+			rxrpc_get_connection(conn);
 			list_move(&conn->bundle_link, &bundle->avail_conns);
 			break;
 		}
@@ -629,7 +629,7 @@ found_extant_connection:
 		read_unlock_bh(&trans->conn_lock);
 		goto security_mismatch;
 	}
-	atomic_inc(&conn->usage);
+	rxrpc_get_connection(conn);
 	read_unlock_bh(&trans->conn_lock);
 	goto success;
 
@@ -639,7 +639,7 @@ found_extant_second:
 		write_unlock_bh(&trans->conn_lock);
 		goto security_mismatch;
 	}
-	atomic_inc(&conn->usage);
+	rxrpc_get_connection(conn);
 	write_unlock_bh(&trans->conn_lock);
 	kfree(candidate);
 	goto success;
@@ -698,7 +698,7 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
 	return NULL;
 
 found:
-	atomic_inc(&conn->usage);
+	rxrpc_get_connection(conn);
 	read_unlock_bh(&trans->conn_lock);
 	_leave(" = %p", conn);
 	return conn;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index cf540efa9c17..799aec18aa7b 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -580,7 +580,7 @@ static void rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
 {
 	_enter("%p,%p", conn, skb);
 
-	atomic_inc(&conn->usage);
+	rxrpc_get_connection(conn);
 	skb_queue_tail(&conn->rx_queue, skb);
 	rxrpc_queue_conn(conn);
 }
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index 009b321712bc..5703b0d18ed4 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -209,7 +209,7 @@ struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *srx)
 		 * bind the transport socket may still fail if we're attempting
 		 * to use a local address that the dying object is still using.
 		 */
-		if (!atomic_inc_not_zero(&local->usage)) {
+		if (!rxrpc_get_local_maybe(local)) {
 			cursor = cursor->next;
 			list_del_init(&local->link);
 			break;
