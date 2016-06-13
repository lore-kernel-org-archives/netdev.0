From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 16/17] RDS: Update rds_conn_shutdown to work with rds_conn_path
Date: Mon, 13 Jun 2016 09:44:41 -0700
Message-ID: <f0bda57bcc53ef4433aac33fd1ab5e3a7ea8c04b.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41006 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965108AbcFMQpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:15 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit changes rds_conn_shutdown to take a rds_conn_path *
argument, allowing it to shutdown paths other than c_path[0] for
MP-capable transports.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |   64 +++++++++++++++++++++++++++++---------------------
 net/rds/rds.h        |    5 ++-
 net/rds/send.c       |    9 +-----
 net/rds/tcp.c        |    2 +-
 net/rds/threads.c    |    2 +-
 5 files changed, 44 insertions(+), 38 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index a99ac69..a88d26f 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -96,14 +96,16 @@ static struct rds_connection *rds_conn_lookup(struct net *net,
  * and receiving over this connection again in the future.  It is up to
  * the transport to have serialized this call with its send and recv.
  */
-static void rds_conn_reset(struct rds_connection *conn)
+static void rds_conn_path_reset(struct rds_conn_path *cp)
 {
+	struct rds_connection *conn = cp->cp_conn;
+
 	rdsdebug("connection %pI4 to %pI4 reset\n",
 	  &conn->c_laddr, &conn->c_faddr);
 
 	rds_stats_inc(s_conn_reset);
-	rds_send_reset(conn);
-	conn->c_flags = 0;
+	rds_send_path_reset(cp);
+	cp->cp_flags = 0;
 
 	/* Do not clear next_rx_seq here, else we cannot distinguish
 	 * retransmitted packets from new packets, and will hand all
@@ -294,10 +296,12 @@ struct rds_connection *rds_conn_create_outgoing(struct net *net,
 }
 EXPORT_SYMBOL_GPL(rds_conn_create_outgoing);
 
-void rds_conn_shutdown(struct rds_connection *conn)
+void rds_conn_shutdown(struct rds_conn_path *cp)
 {
+	struct rds_connection *conn = cp->cp_conn;
+
 	/* shut it down unless it's down already */
-	if (!rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_DOWN)) {
+	if (!rds_conn_path_transition(cp, RDS_CONN_DOWN, RDS_CONN_DOWN)) {
 		/*
 		 * Quiesce the connection mgmt handlers before we start tearing
 		 * things down. We don't hold the mutex for the entire
@@ -305,35 +309,41 @@ void rds_conn_shutdown(struct rds_connection *conn)
 		 * deadlocking with the CM handler. Instead, the CM event
 		 * handler is supposed to check for state DISCONNECTING
 		 */
-		mutex_lock(&conn->c_cm_lock);
-		if (!rds_conn_transition(conn, RDS_CONN_UP, RDS_CONN_DISCONNECTING)
-		 && !rds_conn_transition(conn, RDS_CONN_ERROR, RDS_CONN_DISCONNECTING)) {
-			rds_conn_error(conn, "shutdown called in state %d\n",
-					atomic_read(&conn->c_state));
-			mutex_unlock(&conn->c_cm_lock);
+		mutex_lock(&cp->cp_cm_lock);
+		if (!rds_conn_path_transition(cp, RDS_CONN_UP,
+					      RDS_CONN_DISCONNECTING) &&
+		    !rds_conn_path_transition(cp, RDS_CONN_ERROR,
+					      RDS_CONN_DISCONNECTING)) {
+			rds_conn_path_error(cp,
+					    "shutdown called in state %d\n",
+					    atomic_read(&cp->cp_state));
+			mutex_unlock(&cp->cp_cm_lock);
 			return;
 		}
-		mutex_unlock(&conn->c_cm_lock);
+		mutex_unlock(&cp->cp_cm_lock);
 
-		wait_event(conn->c_waitq,
-			   !test_bit(RDS_IN_XMIT, &conn->c_flags));
-		wait_event(conn->c_waitq,
-			   !test_bit(RDS_RECV_REFILL, &conn->c_flags));
+		wait_event(cp->cp_waitq,
+			   !test_bit(RDS_IN_XMIT, &cp->cp_flags));
+		wait_event(cp->cp_waitq,
+			   !test_bit(RDS_RECV_REFILL, &cp->cp_flags));
 
-		conn->c_trans->conn_shutdown(conn);
-		rds_conn_reset(conn);
+		if (!conn->c_trans->t_mp_capable)
+			conn->c_trans->conn_shutdown(conn);
+		else
+			conn->c_trans->conn_path_shutdown(cp);
+		rds_conn_path_reset(cp);
 
-		if (!rds_conn_transition(conn, RDS_CONN_DISCONNECTING, RDS_CONN_DOWN)) {
+		if (!rds_conn_path_transition(cp, RDS_CONN_DISCONNECTING,
+					      RDS_CONN_DOWN)) {
 			/* This can happen - eg when we're in the middle of tearing
 			 * down the connection, and someone unloads the rds module.
 			 * Quite reproduceable with loopback connections.
 			 * Mostly harmless.
 			 */
-			rds_conn_error(conn,
-				"%s: failed to transition to state DOWN, "
-				"current state is %d\n",
-				__func__,
-				atomic_read(&conn->c_state));
+			rds_conn_path_error(cp, "%s: failed to transition "
+					    "to state DOWN, current state "
+					    "is %d\n", __func__,
+					    atomic_read(&cp->cp_state));
 			return;
 		}
 	}
@@ -342,13 +352,13 @@ void rds_conn_shutdown(struct rds_connection *conn)
 	 * The passive side of an IB loopback connection is never added
 	 * to the conn hash, so we never trigger a reconnect on this
 	 * conn - the reconnect is always triggered by the active peer. */
-	cancel_delayed_work_sync(&conn->c_conn_w);
+	cancel_delayed_work_sync(&cp->cp_conn_w);
 	rcu_read_lock();
 	if (!hlist_unhashed(&conn->c_hash_node)) {
 		rcu_read_unlock();
 		if (conn->c_trans->t_type != RDS_TRANS_TCP ||
-		    conn->c_path[0].cp_outgoing == 1)
-			rds_queue_reconnect(&conn->c_path[0]);
+		    cp->cp_outgoing == 1)
+			rds_queue_reconnect(cp);
 	} else {
 		rcu_read_unlock();
 	}
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 85f98bd..2e35b73 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -456,6 +456,7 @@ struct rds_transport {
 	void (*conn_free)(void *data);
 	int (*conn_connect)(struct rds_connection *conn);
 	void (*conn_shutdown)(struct rds_connection *conn);
+	void (*conn_path_shutdown)(struct rds_conn_path *conn);
 	void (*xmit_prepare)(struct rds_connection *conn);
 	void (*xmit_path_prepare)(struct rds_conn_path *cp);
 	void (*xmit_complete)(struct rds_connection *conn);
@@ -653,7 +654,7 @@ struct rds_connection *rds_conn_create(struct net *net,
 struct rds_connection *rds_conn_create_outgoing(struct net *net,
 						__be32 laddr, __be32 faddr,
 			       struct rds_transport *trans, gfp_t gfp);
-void rds_conn_shutdown(struct rds_connection *conn);
+void rds_conn_shutdown(struct rds_conn_path *cpath);
 void rds_conn_destroy(struct rds_connection *conn);
 void rds_conn_drop(struct rds_connection *conn);
 void rds_conn_path_drop(struct rds_conn_path *cpath);
@@ -786,7 +787,7 @@ void rds_inc_info_copy(struct rds_incoming *inc,
 
 /* send.c */
 int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len);
-void rds_send_reset(struct rds_connection *conn);
+void rds_send_path_reset(struct rds_conn_path *conn);
 int rds_send_xmit(struct rds_conn_path *cp);
 struct sockaddr_in;
 void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest);
diff --git a/net/rds/send.c b/net/rds/send.c
index 369bd66..ee43d6b 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -62,7 +62,7 @@ static void rds_send_remove_from_sock(struct list_head *messages, int status);
  * Reset the send state.  Callers must ensure that this doesn't race with
  * rds_send_xmit().
  */
-static void rds_send_path_reset(struct rds_conn_path *cp)
+void rds_send_path_reset(struct rds_conn_path *cp)
 {
 	struct rds_message *rm, *tmp;
 	unsigned long flags;
@@ -99,12 +99,7 @@ static void rds_send_path_reset(struct rds_conn_path *cp)
 	list_splice_init(&cp->cp_retrans, &cp->cp_send_queue);
 	spin_unlock_irqrestore(&cp->cp_lock, flags);
 }
-
-void rds_send_reset(struct rds_connection *conn)
-{
-	rds_send_path_reset(&conn->c_path[0]);
-}
-EXPORT_SYMBOL_GPL(rds_send_reset);
+EXPORT_SYMBOL_GPL(rds_send_path_reset);
 
 static int acquire_in_xmit(struct rds_conn_path *cp)
 {
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 4bc1c15..0e757a0 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -186,7 +186,7 @@ void rds_tcp_reset_callbacks(struct socket *sock,
 	release_sock(osock->sk);
 	sock_release(osock);
 newsock:
-	rds_send_reset(conn);
+	rds_send_path_reset(&conn->c_path[0]);
 	lock_sock(sock->sk);
 	write_lock_bh(&sock->sk->sk_callback_lock);
 	tc->t_sock = sock;
diff --git a/net/rds/threads.c b/net/rds/threads.c
index 94cca66..9fbe95b 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -225,7 +225,7 @@ void rds_shutdown_worker(struct work_struct *work)
 						struct rds_conn_path,
 						cp_down_w);
 
-	rds_conn_shutdown(cp->cp_conn);
+	rds_conn_shutdown(cp);
 }
 
 void rds_threads_exit(void)
-- 
1.7.1
