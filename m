From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 10/19] rxrpc: Add RCU destruction for connections
 and calls
Date: Thu, 30 Jun 2016 15:11:53 +0100
Message-ID: <146729591353.26306.2898861506902106306.stgit@warthog.procyon.org.uk>
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

Add RCU destruction for connections and calls as the RCU lookup from the
transport socket data_ready handler is going to come along shortly.

Whilst we're at it, move the cleanup workqueue flushing and RCU barrierage
into the destruction code for the objects that need it (locals and
connections) and add the extra RCU barrier required for connection cleanup.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c     |   19 -------------------
 net/rxrpc/ar-internal.h  |    4 +++-
 net/rxrpc/call_object.c  |   15 +++++++++++++--
 net/rxrpc/conn_object.c  |   29 ++++++++++++++++++++++++++---
 net/rxrpc/local_object.c |   19 +++++++++++--------
 5 files changed, 53 insertions(+), 33 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index d5073eb02498..d6e4e3b69dc3 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -788,26 +788,7 @@ static void __exit af_rxrpc_exit(void)
 	proto_unregister(&rxrpc_proto);
 	rxrpc_destroy_all_calls();
 	rxrpc_destroy_all_connections();
-
 	ASSERTCMP(atomic_read(&rxrpc_n_skbs), ==, 0);
-
-	/* We need to flush the scheduled work twice because the local endpoint
-	 * records involve a work item in their destruction as they can only be
-	 * destroyed from process context.  However, a connection may have a
-	 * work item outstanding - and this will pin the local endpoint record
-	 * until the connection goes away.
-	 *
-	 * Peers don't pin locals and calls pin sockets - which prevents the
-	 * module from being unloaded - so we should only need two flushes.
-	 */
-	_debug("flush scheduled work");
-	flush_workqueue(rxrpc_workqueue);
-	_debug("flush scheduled work 2");
-	flush_workqueue(rxrpc_workqueue);
-	_debug("synchronise RCU");
-	rcu_barrier();
-	_debug("destroy locals");
-	rxrpc_destroy_client_conn_ids();
 	rxrpc_destroy_all_locals();
 
 	remove_proc_entry("rxrpc_conns", init_net.proc_net);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index d43cb7831693..ea45f1fc4ded 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -292,9 +292,10 @@ struct rxrpc_connection {
 	struct rxrpc_conn_parameters params;
 
 	spinlock_t		channel_lock;
-	struct rxrpc_call	*channels[RXRPC_MAXCALLS]; /* active calls */
+	struct rxrpc_call __rcu	*channels[RXRPC_MAXCALLS]; /* active calls */
 	wait_queue_head_t	channel_wq;	/* queue to wait for channel to become available */
 
+	struct rcu_head		rcu;
 	struct work_struct	processor;	/* connection event processor */
 	union {
 		struct rb_node	client_node;	/* Node in local->client_conns */
@@ -399,6 +400,7 @@ enum rxrpc_call_state {
  * - matched by { connection, call_id }
  */
 struct rxrpc_call {
+	struct rcu_head		rcu;
 	struct rxrpc_connection	*conn;		/* connection carrying call */
 	struct rxrpc_sock	*socket;	/* socket responsible */
 	struct timer_list	lifetimer;	/* lifetime remaining on call */
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index b43d89c89744..3c4f8517ab55 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -544,7 +544,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	candidate = NULL;
 	rb_link_node(&call->conn_node, parent, p);
 	rb_insert_color(&call->conn_node, &conn->calls);
-	conn->channels[call->channel] = call;
+	rcu_assign_pointer(conn->channels[call->channel], call);
 	sock_hold(&rx->sk);
 	rxrpc_get_connection(conn);
 	write_unlock_bh(&conn->lock);
@@ -795,6 +795,17 @@ void __rxrpc_put_call(struct rxrpc_call *call)
 }
 
 /*
+ * Final call destruction under RCU.
+ */
+static void rxrpc_rcu_destroy_call(struct rcu_head *rcu)
+{
+	struct rxrpc_call *call = container_of(rcu, struct rxrpc_call, rcu);
+
+	rxrpc_purge_queue(&call->rx_queue);
+	kmem_cache_free(rxrpc_call_jar, call);
+}
+
+/*
  * clean up a call
  */
 static void rxrpc_cleanup_call(struct rxrpc_call *call)
@@ -849,7 +860,7 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 	rxrpc_purge_queue(&call->rx_queue);
 	ASSERT(skb_queue_empty(&call->rx_oos_queue));
 	sock_put(&call->socket->sk);
-	kmem_cache_free(rxrpc_call_jar, call);
+	call_rcu(&call->rcu, rxrpc_rcu_destroy_call);
 }
 
 /*
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index a2c1ddade974..b409b2cf7651 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -584,9 +584,12 @@ void rxrpc_put_connection(struct rxrpc_connection *conn)
 /*
  * destroy a virtual connection
  */
-static void rxrpc_destroy_connection(struct rxrpc_connection *conn)
+static void rxrpc_destroy_connection(struct rcu_head *rcu)
 {
-	_enter("%p{%d}", conn, atomic_read(&conn->usage));
+	struct rxrpc_connection *conn =
+		container_of(rcu, struct rxrpc_connection, rcu);
+
+	_enter("{%d,u=%d}", conn->debug_id, atomic_read(&conn->usage));
 
 	ASSERTCMP(atomic_read(&conn->usage), ==, 0);
 
@@ -688,7 +691,8 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 		list_del_init(&conn->link);
 
 		ASSERTCMP(atomic_read(&conn->usage), ==, 0);
-		rxrpc_destroy_connection(conn);
+		skb_queue_purge(&conn->rx_queue);
+		call_rcu(&conn->rcu, rxrpc_destroy_connection);
 	}
 
 	_leave("");
@@ -700,11 +704,30 @@ static void rxrpc_connection_reaper(struct work_struct *work)
  */
 void __exit rxrpc_destroy_all_connections(void)
 {
+	struct rxrpc_connection *conn, *_p;
+	bool leak = false;
+
 	_enter("");
 
 	rxrpc_connection_expiry = 0;
 	cancel_delayed_work(&rxrpc_connection_reap);
 	rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
+	flush_workqueue(rxrpc_workqueue);
+
+	write_lock(&rxrpc_connection_lock);
+	list_for_each_entry_safe(conn, _p, &rxrpc_connections, link) {
+		pr_err("AF_RXRPC: Leaked conn %p {%d}\n",
+		       conn, atomic_read(&conn->usage));
+		leak = true;
+	}
+	write_unlock(&rxrpc_connection_lock);
+	BUG_ON(leak);
+
+	/* Make sure the local and peer records pinned by any dying connections
+	 * are released.
+	 */
+	rcu_barrier();
+	rxrpc_destroy_client_conn_ids();
 
 	_leave("");
 }
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index 3ab7764f7cd8..a753796fbe8f 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -374,14 +374,17 @@ void __exit rxrpc_destroy_all_locals(void)
 
 	_enter("");
 
-	if (list_empty(&rxrpc_local_endpoints))
-		return;
+	flush_workqueue(rxrpc_workqueue);
 
-	mutex_lock(&rxrpc_local_mutex);
-	list_for_each_entry(local, &rxrpc_local_endpoints, link) {
-		pr_err("AF_RXRPC: Leaked local %p {%d}\n",
-		       local, atomic_read(&local->usage));
+	if (!list_empty(&rxrpc_local_endpoints)) {
+		mutex_lock(&rxrpc_local_mutex);
+		list_for_each_entry(local, &rxrpc_local_endpoints, link) {
+			pr_err("AF_RXRPC: Leaked local %p {%d}\n",
+			       local, atomic_read(&local->usage));
+		}
+		mutex_unlock(&rxrpc_local_mutex);
+		BUG();
 	}
-	mutex_unlock(&rxrpc_local_mutex);
-	BUG();
+
+	rcu_barrier();
 }
