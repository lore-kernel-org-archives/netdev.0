From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/3] net/rds: Use a single TCP socket for both send and receive.
Date: Wed, 30 Sep 2015 09:45:52 -0400
Message-ID: <603874beb1dedd0a989d84740d22565bfc568c97.1443569239.git.sowmini.varadhan@oracle.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22641 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbI3NqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 09:46:11 -0400
In-Reply-To: <cover.1443569239.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1443569239.git.sowmini.varadhan@oracle.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f711a6ae062c ("net/rds: RDS-TCP: Always create a new rds_sock
for an incoming connection.") modified rds-tcp so that an incoming SYN
would ignore an existing "client" TCP connection which had the local
port set to the transient port.  The motivation for ignoring the existing
"client" connection in f711a6ae was to avoid race conditions and an
endless duel of reconnect attempts triggered by a restart/abort of one
of the nodes in the TCP connection.

However, having separate sockets for active and passive sides
is avoidable, and the simpler model of a single TCP socket for
both send and receives of all RDS connections associated with
that tcp socket makes for easier observability. We avoid the race
conditions from f711a6ae by attempting reconnects in rds_conn_shutdown
if, and only if, the (new) c_outgoing bit is set for RDS_TRANS_TCP.
The c_outgoing bit is initialized in __rds_conn_create().

A side-effect of re-using the client rds_connection for an incoming
SYN is the potential of encountering duelling SYNs, i.e., we
have an outgoing RDS_CONN_CONNECTING socket when we get the incoming
SYN. The logic to arbitrate this criss-crossing SYN exchange in
rds_tcp_accept_one() has been modified to emulate the BGP state
machine: the smaller IP address should back off from the connection attempt.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |   22 ++++++----------------
 net/rds/rds.h        |    4 +++-
 net/rds/tcp_listen.c |   19 +++++++------------
 3 files changed, 16 insertions(+), 29 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 49adeef..d456403 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -128,10 +128,7 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 	struct rds_transport *loop_trans;
 	unsigned long flags;
 	int ret;
-	struct rds_transport *otrans = trans;
 
-	if (!is_outgoing && otrans->t_type == RDS_TRANS_TCP)
-		goto new_conn;
 	rcu_read_lock();
 	conn = rds_conn_lookup(net, head, laddr, faddr, trans);
 	if (conn && conn->c_loopback && conn->c_trans != &rds_loop_transport &&
@@ -147,7 +144,6 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 	if (conn)
 		goto out;
 
-new_conn:
 	conn = kmem_cache_zalloc(rds_conn_slab, gfp);
 	if (!conn) {
 		conn = ERR_PTR(-ENOMEM);
@@ -207,6 +203,7 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 
 	atomic_set(&conn->c_state, RDS_CONN_DOWN);
 	conn->c_send_gen = 0;
+	conn->c_outgoing = (is_outgoing ? 1 : 0);
 	conn->c_reconnect_jiffies = 0;
 	INIT_DELAYED_WORK(&conn->c_send_w, rds_send_worker);
 	INIT_DELAYED_WORK(&conn->c_recv_w, rds_recv_worker);
@@ -243,22 +240,13 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 		/* Creating normal conn */
 		struct rds_connection *found;
 
-		if (!is_outgoing && otrans->t_type == RDS_TRANS_TCP)
-			found = NULL;
-		else
-			found = rds_conn_lookup(net, head, laddr, faddr, trans);
+		found = rds_conn_lookup(net, head, laddr, faddr, trans);
 		if (found) {
 			trans->conn_free(conn->c_transport_data);
 			kmem_cache_free(rds_conn_slab, conn);
 			conn = found;
 		} else {
-			if ((is_outgoing && otrans->t_type == RDS_TRANS_TCP) ||
-			    (otrans->t_type != RDS_TRANS_TCP)) {
-				/* Only the active side should be added to
-				 * reconnect list for TCP.
-				 */
-				hlist_add_head_rcu(&conn->c_hash_node, head);
-			}
+			hlist_add_head_rcu(&conn->c_hash_node, head);
 			rds_cong_add_conn(conn);
 			rds_conn_count++;
 		}
@@ -337,7 +325,9 @@ void rds_conn_shutdown(struct rds_connection *conn)
 	rcu_read_lock();
 	if (!hlist_unhashed(&conn->c_hash_node)) {
 		rcu_read_unlock();
-		rds_queue_reconnect(conn);
+		if (conn->c_trans->t_type != RDS_TRANS_TCP ||
+		    conn->c_outgoing == 1)
+			rds_queue_reconnect(conn);
 	} else {
 		rcu_read_unlock();
 	}
diff --git a/net/rds/rds.h b/net/rds/rds.h
index afb4048..b4c7ac0 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -86,7 +86,9 @@ struct rds_connection {
 	struct hlist_node	c_hash_node;
 	__be32			c_laddr;
 	__be32			c_faddr;
-	unsigned int		c_loopback:1;
+	unsigned int		c_loopback:1,
+				c_outgoing:1,
+				c_pad_to_32:30;
 	struct rds_connection	*c_passive;
 
 	struct rds_cong_map	*c_lcong;
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 444d78d..ee70d13 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -110,28 +110,23 @@ int rds_tcp_accept_one(struct socket *sock)
 		goto out;
 	}
 	/* An incoming SYN request came in, and TCP just accepted it.
-	 * We always create a new conn for listen side of TCP, and do not
-	 * add it to the c_hash_list.
 	 *
 	 * If the client reboots, this conn will need to be cleaned up.
 	 * rds_tcp_state_change() will do that cleanup
 	 */
 	rs_tcp = (struct rds_tcp_connection *)conn->c_transport_data;
-	WARN_ON(!rs_tcp || rs_tcp->t_sock);
+	if (rs_tcp->t_sock && inet->inet_saddr < inet->inet_daddr) {
+		struct sock *nsk = new_sock->sk;
 
-	/*
-	 * see the comment above rds_queue_delayed_reconnect()
-	 */
-	if (!rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING)) {
-		if (rds_conn_state(conn) == RDS_CONN_UP)
-			rds_tcp_stats_inc(s_tcp_listen_closed_stale);
-		else
-			rds_tcp_stats_inc(s_tcp_connect_raced);
-		rds_conn_drop(conn);
+		nsk->sk_user_data = NULL;
+		nsk->sk_prot->disconnect(nsk, 0);
+		tcp_done(nsk);
+		new_sock = NULL;
 		ret = 0;
 		goto out;
 	}
 
+	rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
 	rds_tcp_set_callbacks(new_sock, conn);
 	rds_connect_complete(conn);
 	new_sock = NULL;
-- 
1.7.1
