From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 3/9] RDS: TCP: Make rds_tcp_connection track the rds_conn_path
Date: Thu, 30 Jun 2016 16:11:12 -0700
Message-ID: <600bc7b91d68f0dde5aa6917864e85c5e89c9661.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:43488 "EHLO
	userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbcF3XMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:12:17 -0400
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
	by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5UNCBYN007745
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 23:12:11 GMT
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The struct rds_tcp_connection is the transport-specific private
data structure that tracks TCP information per rds_conn_path.
Modify this structure to have a back-pointer to the rds_conn_path
for which it is the ->cp_transport_data.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c  |   30 +++++++++++++++---------------
 net/rds/tcp.c         |   44 +++++++++++++++++++++++++-------------------
 net/rds/tcp.h         |    6 +++---
 net/rds/tcp_connect.c |    6 +++---
 net/rds/tcp_listen.c  |    4 ++--
 5 files changed, 48 insertions(+), 42 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 17c2f25..1b0c2a7 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -253,9 +253,12 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 
 			for (i = 0; i < RDS_MPATH_WORKERS; i++) {
 				cp = &conn->c_path[i];
-				trans->conn_free(cp->cp_transport_data);
-				if (!trans->t_mp_capable)
-					break;
+				/* The ->conn_alloc invocation may have
+				 * allocated resource for all paths, so all
+				 * of them may have to be freed here.
+				 */
+				if (cp->cp_transport_data)
+					trans->conn_free(cp->cp_transport_data);
 			}
 			kmem_cache_free(rds_conn_slab, conn);
 			conn = found;
@@ -367,6 +370,9 @@ static void rds_conn_path_destroy(struct rds_conn_path *cp)
 {
 	struct rds_message *rm, *rtmp;
 
+	if (!cp->cp_transport_data)
+		return;
+
 	rds_conn_path_drop(cp);
 	flush_work(&cp->cp_down_w);
 
@@ -398,6 +404,8 @@ static void rds_conn_path_destroy(struct rds_conn_path *cp)
 void rds_conn_destroy(struct rds_connection *conn)
 {
 	unsigned long flags;
+	int i;
+	struct rds_conn_path *cp;
 
 	rdsdebug("freeing conn %p for %pI4 -> "
 		 "%pI4\n", conn, &conn->c_laddr,
@@ -410,18 +418,10 @@ void rds_conn_destroy(struct rds_connection *conn)
 	synchronize_rcu();
 
 	/* shut the connection down */
-	if (!conn->c_trans->t_mp_capable) {
-		rds_conn_path_destroy(&conn->c_path[0]);
-		BUG_ON(!list_empty(&conn->c_path[0].cp_retrans));
-	} else {
-		int i;
-		struct rds_conn_path *cp;
-
-		for (i = 0; i < RDS_MPATH_WORKERS; i++) {
-			cp = &conn->c_path[i];
-			rds_conn_path_destroy(cp);
-			BUG_ON(!list_empty(&cp->cp_retrans));
-		}
+	for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+		cp = &conn->c_path[i];
+		rds_conn_path_destroy(cp);
+		BUG_ON(!list_empty(&cp->cp_retrans));
 	}
 
 	/*
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index c56fff2..c6b47f6 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -221,7 +221,7 @@ void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn)
 		sock->sk->sk_data_ready = sock->sk->sk_user_data;
 
 	tc->t_sock = sock;
-	tc->conn = conn;
+	tc->t_cpath = &conn->c_path[0];
 	tc->t_orig_data_ready = sock->sk->sk_data_ready;
 	tc->t_orig_write_space = sock->sk->sk_write_space;
 	tc->t_orig_state_change = sock->sk->sk_state_change;
@@ -284,24 +284,29 @@ static int rds_tcp_laddr_check(struct net *net, __be32 addr)
 static int rds_tcp_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 {
 	struct rds_tcp_connection *tc;
+	int i;
 
-	tc = kmem_cache_alloc(rds_tcp_conn_slab, gfp);
-	if (!tc)
-		return -ENOMEM;
+	for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+		tc = kmem_cache_alloc(rds_tcp_conn_slab, gfp);
+		if (!tc)
+			return -ENOMEM;
 
-	mutex_init(&tc->t_conn_lock);
-	tc->t_sock = NULL;
-	tc->t_tinc = NULL;
-	tc->t_tinc_hdr_rem = sizeof(struct rds_header);
-	tc->t_tinc_data_rem = 0;
+		mutex_init(&tc->t_conn_path_lock);
+		tc->t_sock = NULL;
+		tc->t_tinc = NULL;
+		tc->t_tinc_hdr_rem = sizeof(struct rds_header);
+		tc->t_tinc_data_rem = 0;
 
-	conn->c_transport_data = tc;
+		conn->c_path[i].cp_transport_data = tc;
+		tc->t_cpath = &conn->c_path[i];
 
-	spin_lock_irq(&rds_tcp_conn_lock);
-	list_add_tail(&tc->t_tcp_node, &rds_tcp_conn_list);
-	spin_unlock_irq(&rds_tcp_conn_lock);
+		spin_lock_irq(&rds_tcp_conn_lock);
+		list_add_tail(&tc->t_tcp_node, &rds_tcp_conn_list);
+		spin_unlock_irq(&rds_tcp_conn_lock);
+		rdsdebug("rds_conn_path [%d] tc %p\n", i,
+			 conn->c_path[i].cp_transport_data);
+	}
 
-	rdsdebug("alloced tc %p\n", conn->c_transport_data);
 	return 0;
 }
 
@@ -330,7 +335,7 @@ static void rds_tcp_destroy_conns(void)
 	spin_unlock_irq(&rds_tcp_conn_lock);
 
 	list_for_each_entry_safe(tc, _tc, &tmp_list, t_tcp_node)
-		rds_conn_destroy(tc->conn);
+		rds_conn_destroy(tc->t_cpath->cp_conn);
 }
 
 static void rds_tcp_exit(void);
@@ -498,7 +503,7 @@ static void rds_tcp_kill_sock(struct net *net)
 	flush_work(&rtn->rds_tcp_accept_w);
 	spin_lock_irq(&rds_tcp_conn_lock);
 	list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
-		struct net *c_net = read_pnet(&tc->conn->c_net);
+		struct net *c_net = read_pnet(&tc->t_cpath->cp_conn->c_net);
 
 		if (net != c_net || !tc->t_sock)
 			continue;
@@ -509,7 +514,7 @@ static void rds_tcp_kill_sock(struct net *net)
 		sk = tc->t_sock->sk;
 		sk->sk_prot->disconnect(sk, 0);
 		tcp_done(sk);
-		rds_conn_destroy(tc->conn);
+		rds_conn_destroy(tc->t_cpath->cp_conn);
 	}
 }
 
@@ -547,12 +552,13 @@ static void rds_tcp_sysctl_reset(struct net *net)
 
 	spin_lock_irq(&rds_tcp_conn_lock);
 	list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
-		struct net *c_net = read_pnet(&tc->conn->c_net);
+		struct net *c_net = read_pnet(&tc->t_cpath->cp_conn->c_net);
 
 		if (net != c_net || !tc->t_sock)
 			continue;
 
-		rds_conn_drop(tc->conn); /* reconnect with new parameters */
+		/* reconnect with new parameters */
+		rds_conn_path_drop(tc->t_cpath);
 	}
 	spin_unlock_irq(&rds_tcp_conn_lock);
 }
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 728abe2..e1ff169 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -11,11 +11,11 @@ struct rds_tcp_incoming {
 struct rds_tcp_connection {
 
 	struct list_head	t_tcp_node;
-	struct rds_connection   *conn;
-	/* t_conn_lock synchronizes the connection establishment between
+	struct rds_conn_path	*t_cpath;
+	/* t_conn_path_lock synchronizes the connection establishment between
 	 * rds_tcp_accept_one and rds_tcp_conn_connect
 	 */
-	struct mutex		t_conn_lock;
+	struct mutex		t_conn_path_lock;
 	struct socket		*t_sock;
 	void			*t_orig_write_space;
 	void			*t_orig_data_ready;
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index aa65c16..146692c 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -82,10 +82,10 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 	int ret;
 	struct rds_tcp_connection *tc = conn->c_transport_data;
 
-	mutex_lock(&tc->t_conn_lock);
+	mutex_lock(&tc->t_conn_path_lock);
 
 	if (rds_conn_up(conn)) {
-		mutex_unlock(&tc->t_conn_lock);
+		mutex_unlock(&tc->t_conn_path_lock);
 		return 0;
 	}
 	ret = sock_create_kern(rds_conn_net(conn), PF_INET,
@@ -129,7 +129,7 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 	}
 
 out:
-	mutex_unlock(&tc->t_conn_lock);
+	mutex_unlock(&tc->t_conn_path_lock);
 	if (sock)
 		sock_release(sock);
 	return ret;
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index f9cc945..d893346 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -121,7 +121,7 @@ int rds_tcp_accept_one(struct socket *sock)
 	 */
 	rs_tcp = (struct rds_tcp_connection *)conn->c_transport_data;
 	rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
-	mutex_lock(&rs_tcp->t_conn_lock);
+	mutex_lock(&rs_tcp->t_conn_path_lock);
 	conn_state = rds_conn_state(conn);
 	if (conn_state != RDS_CONN_CONNECTING && conn_state != RDS_CONN_UP)
 		goto rst_nsk;
@@ -156,7 +156,7 @@ int rds_tcp_accept_one(struct socket *sock)
 	ret = 0;
 out:
 	if (rs_tcp)
-		mutex_unlock(&rs_tcp->t_conn_lock);
+		mutex_unlock(&rs_tcp->t_conn_path_lock);
 	if (new_sock)
 		sock_release(new_sock);
 	return ret;
-- 
1.7.1
