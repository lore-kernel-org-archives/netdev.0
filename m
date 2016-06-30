From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/9] RDS: Rework path specific indirections
Date: Thu, 30 Jun 2016 16:11:10 -0700
Message-ID: <2df996d087d975231d004db792c41e04c292fcb7.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44438 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755AbcF3XMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:12:20 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
	by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5UNC6W6007262
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 23:12:06 GMT
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor code to avoid separate indirections for single-path
and multipath transports. All transports (both single and mp-capable)
will get a pointer to the rds_conn_path, and can trivially derive
the rds_connection from the ->cp_conn.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c  |    5 +----
 net/rds/ib.c          |    4 ++--
 net/rds/ib.h          |    4 ++--
 net/rds/ib_cm.c       |    3 ++-
 net/rds/ib_send.c     |    3 ++-
 net/rds/loop.c        |    4 ++--
 net/rds/rds.h         |    3 ---
 net/rds/send.c        |   16 ++++------------
 net/rds/tcp.c         |    6 +++---
 net/rds/tcp.h         |    6 +++---
 net/rds/tcp_connect.c |    7 ++++---
 net/rds/tcp_send.c    |    8 ++++----
 12 files changed, 29 insertions(+), 40 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index a4b07c8..17c2f25 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -326,10 +326,7 @@ void rds_conn_shutdown(struct rds_conn_path *cp)
 		wait_event(cp->cp_waitq,
 			   !test_bit(RDS_RECV_REFILL, &cp->cp_flags));
 
-		if (!conn->c_trans->t_mp_capable)
-			conn->c_trans->conn_shutdown(conn);
-		else
-			conn->c_trans->conn_path_shutdown(cp);
+		conn->c_trans->conn_path_shutdown(cp);
 		rds_conn_path_reset(cp);
 
 		if (!rds_conn_path_transition(cp, RDS_CONN_DISCONNECTING,
diff --git a/net/rds/ib.c b/net/rds/ib.c
index 44946a6..1b29ec9 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -381,7 +381,7 @@ void rds_ib_exit(void)
 
 struct rds_transport rds_ib_transport = {
 	.laddr_check		= rds_ib_laddr_check,
-	.xmit_complete		= rds_ib_xmit_complete,
+	.xmit_path_complete	= rds_ib_xmit_path_complete,
 	.xmit			= rds_ib_xmit,
 	.xmit_rdma		= rds_ib_xmit_rdma,
 	.xmit_atomic		= rds_ib_xmit_atomic,
@@ -389,7 +389,7 @@ struct rds_transport rds_ib_transport = {
 	.conn_alloc		= rds_ib_conn_alloc,
 	.conn_free		= rds_ib_conn_free,
 	.conn_connect		= rds_ib_conn_connect,
-	.conn_shutdown		= rds_ib_conn_shutdown,
+	.conn_path_shutdown	= rds_ib_conn_path_shutdown,
 	.inc_copy_to_user	= rds_ib_inc_copy_to_user,
 	.inc_free		= rds_ib_inc_free,
 	.cm_initiate_connect	= rds_ib_cm_initiate_connect,
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 627fb79..2051f4b 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -329,7 +329,7 @@ extern struct list_head ib_nodev_conns;
 int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp);
 void rds_ib_conn_free(void *arg);
 int rds_ib_conn_connect(struct rds_connection *conn);
-void rds_ib_conn_shutdown(struct rds_connection *conn);
+void rds_ib_conn_path_shutdown(struct rds_conn_path *cp);
 void rds_ib_state_change(struct sock *sk);
 int rds_ib_listen_init(void);
 void rds_ib_listen_stop(void);
@@ -384,7 +384,7 @@ u32 rds_ib_ring_completed(struct rds_ib_work_ring *ring, u32 wr_id, u32 oldest);
 extern wait_queue_head_t rds_ib_ring_empty_wait;
 
 /* ib_send.c */
-void rds_ib_xmit_complete(struct rds_connection *conn);
+void rds_ib_xmit_path_complete(struct rds_conn_path *cp);
 int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 		unsigned int hdr_off, unsigned int sg, unsigned int off);
 void rds_ib_send_cqe_handler(struct rds_ib_connection *ic, struct ib_wc *wc);
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index e48bb1b..e34ea0b 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -731,8 +731,9 @@ int rds_ib_conn_connect(struct rds_connection *conn)
  * so that it can be called at any point during startup.  In fact it
  * can be called multiple times for a given connection.
  */
-void rds_ib_conn_shutdown(struct rds_connection *conn)
+void rds_ib_conn_path_shutdown(struct rds_conn_path *cp)
 {
+	struct rds_connection *conn = cp->cp_conn;
 	struct rds_ib_connection *ic = conn->c_transport_data;
 	int err = 0;
 
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 6e4110a..84d90c9 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -980,8 +980,9 @@ int rds_ib_xmit_rdma(struct rds_connection *conn, struct rm_rdma_op *op)
 	return ret;
 }
 
-void rds_ib_xmit_complete(struct rds_connection *conn)
+void rds_ib_xmit_path_complete(struct rds_conn_path *cp)
 {
+	struct rds_connection *conn = cp->cp_conn;
 	struct rds_ib_connection *ic = conn->c_transport_data;
 
 	/* We may have a pending ACK or window update we were unable
diff --git a/net/rds/loop.c b/net/rds/loop.c
index 15f83db..318c21d 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -156,7 +156,7 @@ static int rds_loop_conn_connect(struct rds_connection *conn)
 	return 0;
 }
 
-static void rds_loop_conn_shutdown(struct rds_connection *conn)
+static void rds_loop_conn_path_shutdown(struct rds_conn_path *cp)
 {
 }
 
@@ -189,7 +189,7 @@ struct rds_transport rds_loop_transport = {
 	.conn_alloc		= rds_loop_conn_alloc,
 	.conn_free		= rds_loop_conn_free,
 	.conn_connect		= rds_loop_conn_connect,
-	.conn_shutdown		= rds_loop_conn_shutdown,
+	.conn_path_shutdown	= rds_loop_conn_path_shutdown,
 	.inc_copy_to_user	= rds_message_inc_copy_to_user,
 	.inc_free		= rds_loop_inc_free,
 	.t_name			= "loopback",
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 2e35b73..5bbad08 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -455,11 +455,8 @@ struct rds_transport {
 	int (*conn_alloc)(struct rds_connection *conn, gfp_t gfp);
 	void (*conn_free)(void *data);
 	int (*conn_connect)(struct rds_connection *conn);
-	void (*conn_shutdown)(struct rds_connection *conn);
 	void (*conn_path_shutdown)(struct rds_conn_path *conn);
-	void (*xmit_prepare)(struct rds_connection *conn);
 	void (*xmit_path_prepare)(struct rds_conn_path *cp);
-	void (*xmit_complete)(struct rds_connection *conn);
 	void (*xmit_path_complete)(struct rds_conn_path *cp);
 	int (*xmit)(struct rds_connection *conn, struct rds_message *rm,
 		    unsigned int hdr_off, unsigned int sg, unsigned int off);
diff --git a/net/rds/send.c b/net/rds/send.c
index ee43d6b..5a9caf1 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -183,12 +183,8 @@ int rds_send_xmit(struct rds_conn_path *cp)
 		goto out;
 	}
 
-	if (conn->c_trans->t_mp_capable) {
-		if (conn->c_trans->xmit_path_prepare)
-			conn->c_trans->xmit_path_prepare(cp);
-	} else if (conn->c_trans->xmit_prepare) {
-		conn->c_trans->xmit_prepare(conn);
-	}
+	if (conn->c_trans->xmit_path_prepare)
+		conn->c_trans->xmit_path_prepare(cp);
 
 	/*
 	 * spin trying to push headers and data down the connection until
@@ -403,12 +399,8 @@ int rds_send_xmit(struct rds_conn_path *cp)
 	}
 
 over_batch:
-	if (conn->c_trans->t_mp_capable) {
-		if (conn->c_trans->xmit_path_complete)
-			conn->c_trans->xmit_path_complete(cp);
-	} else if (conn->c_trans->xmit_complete) {
-		conn->c_trans->xmit_complete(conn);
-	}
+	if (conn->c_trans->xmit_path_complete)
+		conn->c_trans->xmit_path_complete(cp);
 	release_in_xmit(cp);
 
 	/* Nuke any messages we decided not to retransmit. */
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 5217d49..b139630 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -340,14 +340,14 @@ static void rds_tcp_exit(void);
 
 struct rds_transport rds_tcp_transport = {
 	.laddr_check		= rds_tcp_laddr_check,
-	.xmit_prepare		= rds_tcp_xmit_prepare,
-	.xmit_complete		= rds_tcp_xmit_complete,
+	.xmit_path_prepare	= rds_tcp_xmit_path_prepare,
+	.xmit_path_complete	= rds_tcp_xmit_path_complete,
 	.xmit			= rds_tcp_xmit,
 	.recv			= rds_tcp_recv,
 	.conn_alloc		= rds_tcp_conn_alloc,
 	.conn_free		= rds_tcp_conn_free,
 	.conn_connect		= rds_tcp_conn_connect,
-	.conn_shutdown		= rds_tcp_conn_shutdown,
+	.conn_path_shutdown	= rds_tcp_conn_path_shutdown,
 	.inc_copy_to_user	= rds_tcp_inc_copy_to_user,
 	.inc_free		= rds_tcp_inc_free,
 	.stats_info_copy	= rds_tcp_stats_info_copy,
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 7940bab..728abe2 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -61,7 +61,7 @@ void rds_tcp_accept_work(struct sock *sk);
 
 /* tcp_connect.c */
 int rds_tcp_conn_connect(struct rds_connection *conn);
-void rds_tcp_conn_shutdown(struct rds_connection *conn);
+void rds_tcp_conn_path_shutdown(struct rds_conn_path *conn);
 void rds_tcp_state_change(struct sock *sk);
 
 /* tcp_listen.c */
@@ -80,8 +80,8 @@ void rds_tcp_inc_free(struct rds_incoming *inc);
 int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to);
 
 /* tcp_send.c */
-void rds_tcp_xmit_prepare(struct rds_connection *conn);
-void rds_tcp_xmit_complete(struct rds_connection *conn);
+void rds_tcp_xmit_path_prepare(struct rds_conn_path *cp);
+void rds_tcp_xmit_path_complete(struct rds_conn_path *cp);
 int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 		 unsigned int hdr_off, unsigned int sg, unsigned int off);
 void rds_tcp_write_space(struct sock *sk);
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 96c2c4d..aa65c16 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -144,12 +144,13 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
  * callbacks to those set by TCP.  Our callbacks won't execute again once we
  * hold the sock lock.
  */
-void rds_tcp_conn_shutdown(struct rds_connection *conn)
+void rds_tcp_conn_path_shutdown(struct rds_conn_path *cp)
 {
-	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_tcp_connection *tc = cp->cp_transport_data;
 	struct socket *sock = tc->t_sock;
 
-	rdsdebug("shutting down conn %p tc %p sock %p\n", conn, tc, sock);
+	rdsdebug("shutting down conn %p tc %p sock %p\n",
+		 cp->cp_conn, tc, sock);
 
 	if (sock) {
 		sock->ops->shutdown(sock, RCV_SHUTDOWN | SEND_SHUTDOWN);
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 710f1aa..52cda94 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -49,16 +49,16 @@ static void rds_tcp_cork(struct socket *sock, int val)
 	set_fs(oldfs);
 }
 
-void rds_tcp_xmit_prepare(struct rds_connection *conn)
+void rds_tcp_xmit_path_prepare(struct rds_conn_path *cp)
 {
-	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_tcp_connection *tc = cp->cp_transport_data;
 
 	rds_tcp_cork(tc->t_sock, 1);
 }
 
-void rds_tcp_xmit_complete(struct rds_connection *conn)
+void rds_tcp_xmit_path_complete(struct rds_conn_path *cp)
 {
-	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_tcp_connection *tc = cp->cp_transport_data;
 
 	rds_tcp_cork(tc->t_sock, 0);
 }
-- 
1.7.1
