From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 16/19] rxrpc: Maintain an extra ref on a conn for
 the cache list
Date: Thu, 30 Jun 2016 15:12:37 +0100
Message-ID: <146729595704.26306.9113530094478095254.stgit@warthog.procyon.org.uk>
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

Overhaul the usage count accounting for the rxrpc_connection struct to make
it easier to implement RCU access from the data_ready handler.

The problem is that currently we're using a lock to prevent the garbage
collector from trying to clean up a connection that we're contemplating
unidling.  We could just stick incoming packets on the connection we find,
but we've then got a problem that we may race when dispatching a work item
to process it as we need to give that a ref to prevent the rxrpc_connection
struct from disappearing in the meantime.

Further, incoming packets may get discarded if attached to an
rxrpc_connection struct that is going away.  Whilst this is not a total
disaster - the client will presumably resend - it would delay processing of
the call.  This would affect the AFS client filesystem's service manager
operation.

To this end:

 (1) We now maintain an extra count on the connection usage count whilst it
     is on the connection list.  This mean it is not in use when its
     refcount is 1.

 (2) When trying to reuse an old connection, we only increment the refcount
     if it is greater than 0.  If it is 0, we replace it in the tree with a
     new candidate connection.

 (3) Two connection flags are added to indicate whether or not a connection
     is in the local's client connection tree (used by sendmsg) or the
     peer's service connection tree (used by data_ready).  This makes sure
     that we don't try and remove a connection if it got replaced.

     The flags are tested under lock with the removal operation to prevent
     the reaper from killing the rxrpc_connection struct whilst someone
     else is trying to effect a replacement.

     This could probably be alleviated by using memory barriers between the
     flag set/test and the rb_tree ops.  The rb_tree op would still need to
     be under the lock, however.

 (4) When trying to reap an old connection, we try to flip the usage count
     from 1 to 0.  If it's not 1 at that point, then it must've come back
     to life temporarily and we ignore it.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h  |    5 ++-
 net/rxrpc/conn_client.c  |   42 ++++++++++++++++++++----
 net/rxrpc/conn_object.c  |   80 +++++++++++++++++-----------------------------
 net/rxrpc/conn_service.c |   34 +++++++++++++++++---
 4 files changed, 97 insertions(+), 64 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 7d87cace0177..71618e983b4a 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -258,6 +258,8 @@ struct rxrpc_conn_parameters {
  */
 enum rxrpc_conn_flag {
 	RXRPC_CONN_HAS_IDR,		/* Has a client conn ID assigned */
+	RXRPC_CONN_IN_SERVICE_CONNS,	/* Conn is in peer->service_conns */
+	RXRPC_CONN_IN_CLIENT_CONNS,	/* Conn is in local->client_conns */
 };
 
 /*
@@ -545,10 +547,10 @@ void __exit rxrpc_destroy_all_calls(void);
  */
 extern struct idr rxrpc_client_conn_ids;
 
-void rxrpc_put_client_connection_id(struct rxrpc_connection *);
 void rxrpc_destroy_client_conn_ids(void);
 int rxrpc_connect_call(struct rxrpc_call *, struct rxrpc_conn_parameters *,
 		       struct sockaddr_rxrpc *, gfp_t);
+void rxrpc_unpublish_client_conn(struct rxrpc_connection *);
 
 /*
  * conn_event.c
@@ -611,6 +613,7 @@ static inline void rxrpc_queue_conn(struct rxrpc_connection *conn)
 struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *,
 						   struct sockaddr_rxrpc *,
 						   struct sk_buff *);
+void rxrpc_unpublish_service_conn(struct rxrpc_connection *);
 
 /*
  * input.c
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index ce2fd4508bb5..52809e21f56d 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -84,7 +84,7 @@ error:
 /*
  * Release a connection ID for a client connection from the global pool.
  */
-void rxrpc_put_client_connection_id(struct rxrpc_connection *conn)
+static void rxrpc_put_client_connection_id(struct rxrpc_connection *conn)
 {
 	if (test_bit(RXRPC_CONN_HAS_IDR, &conn->flags)) {
 		spin_lock(&rxrpc_conn_id_lock);
@@ -279,12 +279,13 @@ int rxrpc_connect_call(struct rxrpc_call *call,
 	 * lock before dropping the client conn lock.
 	 */
 	_debug("new conn");
+	set_bit(RXRPC_CONN_IN_CLIENT_CONNS, &candidate->flags);
+	rb_link_node(&candidate->client_node, parent, pp);
+	rb_insert_color(&candidate->client_node, &local->client_conns);
+attached:
 	conn = candidate;
 	candidate = NULL;
 
-	rb_link_node(&conn->client_node, parent, pp);
-	rb_insert_color(&conn->client_node, &local->client_conns);
-
 	atomic_set(&conn->avail_chans, RXRPC_MAXCALLS - 1);
 	spin_lock(&conn->channel_lock);
 	spin_unlock(&local->client_conns_lock);
@@ -308,13 +309,22 @@ found_channel:
 	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
 	return 0;
 
-	/* We found a suitable connection already in existence.  Discard any
-	 * candidate we may have allocated, and try to get a channel on this
-	 * one.
+	/* We found a potentially suitable connection already in existence.  If
+	 * we can reuse it (ie. its usage count hasn't been reduced to 0 by the
+	 * reaper), discard any candidate we may have allocated, and try to get
+	 * a channel on this one, otherwise we have to replace it.
 	 */
 found_extant_conn:
 	_debug("found conn");
-	rxrpc_get_connection(conn);
+	if (!rxrpc_get_connection_maybe(conn)) {
+		set_bit(RXRPC_CONN_IN_CLIENT_CONNS, &candidate->flags);
+		rb_replace_node(&conn->client_node,
+				&candidate->client_node,
+				&local->client_conns);
+		clear_bit(RXRPC_CONN_IN_CLIENT_CONNS, &conn->flags);
+		goto attached;
+	}
+
 	spin_unlock(&local->client_conns_lock);
 
 	rxrpc_put_connection(candidate);
@@ -358,3 +368,19 @@ interrupted:
 	_leave(" = -ERESTARTSYS");
 	return -ERESTARTSYS;
 }
+
+/*
+ * Remove a client connection from the local endpoint's tree, thereby removing
+ * it as a target for reuse for new client calls.
+ */
+void rxrpc_unpublish_client_conn(struct rxrpc_connection *conn)
+{
+	struct rxrpc_local *local = conn->params.local;
+
+	spin_lock(&local->client_conns_lock);
+	if (test_and_clear_bit(RXRPC_CONN_IN_CLIENT_CONNS, &conn->flags))
+		rb_erase(&conn->client_node, &local->client_conns);
+	spin_unlock(&local->client_conns_lock);
+
+	rxrpc_put_client_connection_id(conn);
+}
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 12d7c7850aed..83cd3548ec10 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -51,7 +51,10 @@ struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 		skb_queue_head_init(&conn->rx_queue);
 		conn->security = &rxrpc_no_security;
 		spin_lock_init(&conn->state_lock);
-		atomic_set(&conn->usage, 1);
+		/* We maintain an extra ref on the connection whilst it is
+		 * on the rxrpc_connections list.
+		 */
+		atomic_set(&conn->usage, 2);
 		conn->debug_id = atomic_inc_return(&rxrpc_debug_id);
 		atomic_set(&conn->avail_chans, RXRPC_MAXCALLS);
 		conn->size_align = 4;
@@ -113,7 +116,7 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *local,
 	return NULL;
 
 found:
-	rxrpc_get_connection(conn);
+	conn = rxrpc_get_connection_maybe(conn);
 	read_unlock_bh(&peer->conn_lock);
 	_leave(" = %p", conn);
 	return conn;
@@ -175,10 +178,10 @@ void rxrpc_put_connection(struct rxrpc_connection *conn)
 	_enter("%p{u=%d,d=%d}",
 	       conn, atomic_read(&conn->usage), conn->debug_id);
 
-	ASSERTCMP(atomic_read(&conn->usage), >, 0);
+	ASSERTCMP(atomic_read(&conn->usage), >, 1);
 
 	conn->put_time = ktime_get_seconds();
-	if (atomic_dec_and_test(&conn->usage)) {
+	if (atomic_dec_return(&conn->usage) == 1) {
 		_debug("zombie");
 		rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
 	}
@@ -218,66 +221,42 @@ static void rxrpc_destroy_connection(struct rcu_head *rcu)
 static void rxrpc_connection_reaper(struct work_struct *work)
 {
 	struct rxrpc_connection *conn, *_p;
-	struct rxrpc_peer *peer;
-	unsigned long now, earliest, reap_time;
-	bool remove;
+	unsigned long reap_older_than, earliest, put_time, now;
 
 	LIST_HEAD(graveyard);
 
 	_enter("");
 
 	now = ktime_get_seconds();
+	reap_older_than =  now - rxrpc_connection_expiry;
 	earliest = ULONG_MAX;
 
 	write_lock(&rxrpc_connection_lock);
 	list_for_each_entry_safe(conn, _p, &rxrpc_connections, link) {
-		_debug("reap CONN %d { u=%d,t=%ld }",
-		       conn->debug_id, atomic_read(&conn->usage),
-		       (long) now - (long) conn->put_time);
-
-		if (likely(atomic_read(&conn->usage) > 0))
+		ASSERTCMP(atomic_read(&conn->usage), >, 0);
+		if (likely(atomic_read(&conn->usage) > 1))
 			continue;
 
-		remove = false;
-		if (rxrpc_conn_is_client(conn)) {
-			struct rxrpc_local *local = conn->params.local;
-			spin_lock(&local->client_conns_lock);
-			reap_time = conn->put_time + rxrpc_connection_expiry;
-
-			if (atomic_read(&conn->usage) > 0) {
-				;
-			} else if (reap_time <= now) {
-				list_move_tail(&conn->link, &graveyard);
-				rxrpc_put_client_connection_id(conn);
-				rb_erase(&conn->client_node,
-					 &local->client_conns);
-				remove = true;
-			} else if (reap_time < earliest) {
-				earliest = reap_time;
-			}
-
-			spin_unlock(&local->client_conns_lock);
-		} else {
-			peer = conn->params.peer;
-			write_lock_bh(&peer->conn_lock);
-			reap_time = conn->put_time + rxrpc_connection_expiry;
-
-			if (atomic_read(&conn->usage) > 0) {
-				;
-			} else if (reap_time <= now) {
-				list_move_tail(&conn->link, &graveyard);
-				rb_erase(&conn->service_node,
-					 &peer->service_conns);
-				remove = true;
-			} else if (reap_time < earliest) {
-				earliest = reap_time;
-			}
-
-			write_unlock_bh(&peer->conn_lock);
+		put_time = READ_ONCE(conn->put_time);
+		if (time_after(put_time, reap_older_than)) {
+			if (time_before(put_time, earliest))
+				earliest = put_time;
+			continue;
 		}
 
-		if (remove)
-			list_del_init(&conn->proc_link);
+		/* The usage count sits at 1 whilst the object is unused on the
+		 * list; we reduce that to 0 to make the object unavailable.
+		 */
+		if (atomic_cmpxchg(&conn->usage, 1, 0) != 1)
+			continue;
+
+		if (rxrpc_conn_is_client(conn))
+			rxrpc_unpublish_client_conn(conn);
+		else
+			rxrpc_unpublish_service_conn(conn);
+
+		list_move_tail(&conn->link, &graveyard);
+		list_del_init(&conn->proc_link);
 	}
 	write_unlock(&rxrpc_connection_lock);
 
@@ -288,7 +267,6 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 					 (earliest - now) * HZ);
 	}
 
-	/* then destroy all those pulled out */
 	while (!list_empty(&graveyard)) {
 		conn = list_entry(graveyard.next, struct rxrpc_connection,
 				  link);
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index 3f0242423a66..4ae9a9e7f31f 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -105,10 +105,12 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 	}
 
 	/* we can now add the new candidate to the list */
+	set_bit(RXRPC_CONN_IN_SERVICE_CONNS, &candidate->flags);
+	rb_link_node(&candidate->service_node, p, pp);
+	rb_insert_color(&candidate->service_node, &peer->service_conns);
+attached:
 	conn = candidate;
 	candidate = NULL;
-	rb_link_node(&conn->service_node, p, pp);
-	rb_insert_color(&conn->service_node, &peer->service_conns);
 	rxrpc_get_peer(peer);
 	rxrpc_get_local(local);
 
@@ -129,11 +131,19 @@ success:
 
 	/* we found the connection in the list immediately */
 found_extant_connection:
+	if (!rxrpc_get_connection_maybe(conn)) {
+		set_bit(RXRPC_CONN_IN_SERVICE_CONNS, &candidate->flags);
+		rb_replace_node(&conn->service_node,
+				&candidate->service_node,
+				&peer->service_conns);
+		clear_bit(RXRPC_CONN_IN_SERVICE_CONNS, &conn->flags);
+		goto attached;
+	}
+
 	if (sp->hdr.securityIndex != conn->security_ix) {
 		read_unlock_bh(&peer->conn_lock);
-		goto security_mismatch;
+		goto security_mismatch_put;
 	}
-	rxrpc_get_connection(conn);
 	read_unlock_bh(&peer->conn_lock);
 	goto success;
 
@@ -148,8 +158,24 @@ found_extant_second:
 	kfree(candidate);
 	goto success;
 
+security_mismatch_put:
+	rxrpc_put_connection(conn);
 security_mismatch:
 	kfree(candidate);
 	_leave(" = -EKEYREJECTED");
 	return ERR_PTR(-EKEYREJECTED);
 }
+
+/*
+ * Remove the service connection from the peer's tree, thereby removing it as a
+ * target for incoming packets.
+ */
+void rxrpc_unpublish_service_conn(struct rxrpc_connection *conn)
+{
+	struct rxrpc_peer *peer = conn->params.peer;
+
+	write_lock_bh(&peer->conn_lock);
+	if (test_and_clear_bit(RXRPC_CONN_IN_SERVICE_CONNS, &conn->flags))
+		rb_erase(&conn->service_node, &peer->service_conns);
+	write_unlock_bh(&peer->conn_lock);
+}
