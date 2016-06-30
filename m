From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 7/9] RDS: TCP: Hooks to set up a single connection path
Date: Thu, 30 Jun 2016 16:11:16 -0700
Message-ID: <d964067e31df56b123db360c81f297be9e333cf9.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44446 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791AbcF3XMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:12:23 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
	by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5UNC826007275
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 23:12:08 GMT
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds ->conn_path_connect callbacks in the rds_transport
that are used to set up a single connection path.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/ib.c          |    2 +-
 net/rds/ib.h          |    2 +-
 net/rds/ib_cm.c       |    3 ++-
 net/rds/loop.c        |    6 +++---
 net/rds/rds.h         |    2 +-
 net/rds/tcp.c         |    2 +-
 net/rds/tcp.h         |    4 ++--
 net/rds/tcp_connect.c |   11 ++++++-----
 net/rds/threads.c     |    5 +++--
 9 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index e6ba856..7eaf887 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -388,7 +388,7 @@ struct rds_transport rds_ib_transport = {
 	.recv_path		= rds_ib_recv_path,
 	.conn_alloc		= rds_ib_conn_alloc,
 	.conn_free		= rds_ib_conn_free,
-	.conn_connect		= rds_ib_conn_connect,
+	.conn_path_connect	= rds_ib_conn_path_connect,
 	.conn_path_shutdown	= rds_ib_conn_path_shutdown,
 	.inc_copy_to_user	= rds_ib_inc_copy_to_user,
 	.inc_free		= rds_ib_inc_free,
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 579de7e..046f750 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -328,7 +328,7 @@ extern struct list_head ib_nodev_conns;
 /* ib_cm.c */
 int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp);
 void rds_ib_conn_free(void *arg);
-int rds_ib_conn_connect(struct rds_connection *conn);
+int rds_ib_conn_path_connect(struct rds_conn_path *cp);
 void rds_ib_conn_path_shutdown(struct rds_conn_path *cp);
 void rds_ib_state_change(struct sock *sk);
 int rds_ib_listen_init(void);
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index e34ea0b..5b2ab95 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -685,8 +685,9 @@ int rds_ib_cm_initiate_connect(struct rdma_cm_id *cm_id)
 	return ret;
 }
 
-int rds_ib_conn_connect(struct rds_connection *conn)
+int rds_ib_conn_path_connect(struct rds_conn_path *cp)
 {
+	struct rds_connection *conn = cp->cp_conn;
 	struct rds_ib_connection *ic = conn->c_transport_data;
 	struct sockaddr_in src, dest;
 	int ret;
diff --git a/net/rds/loop.c b/net/rds/loop.c
index 20284a4..f2bf78d 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -150,9 +150,9 @@ static void rds_loop_conn_free(void *arg)
 	kfree(lc);
 }
 
-static int rds_loop_conn_connect(struct rds_connection *conn)
+static int rds_loop_conn_path_connect(struct rds_conn_path *cp)
 {
-	rds_connect_complete(conn);
+	rds_connect_complete(cp->cp_conn);
 	return 0;
 }
 
@@ -188,7 +188,7 @@ struct rds_transport rds_loop_transport = {
 	.recv_path		= rds_loop_recv_path,
 	.conn_alloc		= rds_loop_conn_alloc,
 	.conn_free		= rds_loop_conn_free,
-	.conn_connect		= rds_loop_conn_connect,
+	.conn_path_connect	= rds_loop_conn_path_connect,
 	.conn_path_shutdown	= rds_loop_conn_path_shutdown,
 	.inc_copy_to_user	= rds_message_inc_copy_to_user,
 	.inc_free		= rds_loop_inc_free,
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 0faca30..6ef07bd 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -454,7 +454,7 @@ struct rds_transport {
 	int (*laddr_check)(struct net *net, __be32 addr);
 	int (*conn_alloc)(struct rds_connection *conn, gfp_t gfp);
 	void (*conn_free)(void *data);
-	int (*conn_connect)(struct rds_connection *conn);
+	int (*conn_path_connect)(struct rds_conn_path *cp);
 	void (*conn_path_shutdown)(struct rds_conn_path *conn);
 	void (*xmit_path_prepare)(struct rds_conn_path *cp);
 	void (*xmit_path_complete)(struct rds_conn_path *cp);
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 7bc136c..d278432 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -362,7 +362,7 @@ struct rds_transport rds_tcp_transport = {
 	.recv_path		= rds_tcp_recv_path,
 	.conn_alloc		= rds_tcp_conn_alloc,
 	.conn_free		= rds_tcp_conn_free,
-	.conn_connect		= rds_tcp_conn_connect,
+	.conn_path_connect	= rds_tcp_conn_path_connect,
 	.conn_path_shutdown	= rds_tcp_conn_path_shutdown,
 	.inc_copy_to_user	= rds_tcp_inc_copy_to_user,
 	.inc_free		= rds_tcp_inc_free,
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 5a5f91a..1c3160f 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -13,7 +13,7 @@ struct rds_tcp_connection {
 	struct list_head	t_tcp_node;
 	struct rds_conn_path	*t_cpath;
 	/* t_conn_path_lock synchronizes the connection establishment between
-	 * rds_tcp_accept_one and rds_tcp_conn_connect
+	 * rds_tcp_accept_one and rds_tcp_conn_path_connect
 	 */
 	struct mutex		t_conn_path_lock;
 	struct socket		*t_sock;
@@ -60,7 +60,7 @@ extern struct rds_transport rds_tcp_transport;
 void rds_tcp_accept_work(struct sock *sk);
 
 /* tcp_connect.c */
-int rds_tcp_conn_connect(struct rds_connection *conn);
+int rds_tcp_conn_path_connect(struct rds_conn_path *cp);
 void rds_tcp_conn_path_shutdown(struct rds_conn_path *conn);
 void rds_tcp_state_change(struct sock *sk);
 
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 7eddce5..c916715 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -74,17 +74,17 @@ void rds_tcp_state_change(struct sock *sk)
 	state_change(sk);
 }
 
-int rds_tcp_conn_connect(struct rds_connection *conn)
+int rds_tcp_conn_path_connect(struct rds_conn_path *cp)
 {
 	struct socket *sock = NULL;
 	struct sockaddr_in src, dest;
 	int ret;
-	struct rds_tcp_connection *tc = conn->c_transport_data;
-	struct rds_conn_path *cp = &conn->c_path[0];
+	struct rds_connection *conn = cp->cp_conn;
+	struct rds_tcp_connection *tc = cp->cp_transport_data;
 
 	mutex_lock(&tc->t_conn_path_lock);
 
-	if (rds_conn_up(conn)) {
+	if (rds_conn_path_up(cp)) {
 		mutex_unlock(&tc->t_conn_path_lock);
 		return 0;
 	}
@@ -118,6 +118,7 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 	ret = sock->ops->connect(sock, (struct sockaddr *)&dest, sizeof(dest),
 				 O_NONBLOCK);
 
+	cp->cp_outgoing = 1;
 	rdsdebug("connect to address %pI4 returned %d\n", &conn->c_faddr, ret);
 	if (ret == -EINPROGRESS)
 		ret = 0;
@@ -125,7 +126,7 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 		rds_tcp_keepalive(sock);
 		sock = NULL;
 	} else {
-		rds_tcp_restore_callbacks(sock, conn->c_transport_data);
+		rds_tcp_restore_callbacks(sock, cp->cp_transport_data);
 	}
 
 out:
diff --git a/net/rds/threads.c b/net/rds/threads.c
index f717b69..e8f0941 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -152,8 +152,9 @@ void rds_connect_worker(struct work_struct *work)
 	int ret;
 
 	clear_bit(RDS_RECONNECT_PENDING, &cp->cp_flags);
-	if (rds_conn_path_transition(cp, RDS_CONN_DOWN, RDS_CONN_CONNECTING)) {
-		ret = conn->c_trans->conn_connect(conn);
+	ret = rds_conn_path_transition(cp, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
+	if (ret) {
+		ret = conn->c_trans->conn_path_connect(cp);
 		rdsdebug("conn %p for %pI4 to %pI4 dispatched, ret %d\n",
 			conn, &conn->c_laddr, &conn->c_faddr, ret);
 
-- 
1.7.1
