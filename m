From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 5/9] RDS: TCP: make ->sk_user_data point to a rds_conn_path
Date: Thu, 30 Jun 2016 16:11:14 -0700
Message-ID: <f91ba441386ae239b1319d3ef6186d8ef32d1e46.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44440 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbcF3XMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:12:21 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
	by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5UNC6w6007265
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 23:12:06 GMT
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The socket callbacks should all operate on a struct rds_conn_path,
in preparation for a MP capable RDS-TCP.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c         |   25 +++++++++++++------------
 net/rds/tcp.h         |    4 ++--
 net/rds/tcp_connect.c |   16 ++++++++--------
 net/rds/tcp_listen.c  |   12 ++++++------
 net/rds/tcp_recv.c    |   12 ++++++------
 net/rds/tcp_send.c    |   12 ++++++------
 6 files changed, 41 insertions(+), 40 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index b327727..5658f3e 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -136,9 +136,9 @@ void rds_tcp_restore_callbacks(struct socket *sock,
  * from being called while it isn't set.
  */
 void rds_tcp_reset_callbacks(struct socket *sock,
-			     struct rds_connection *conn)
+			     struct rds_conn_path *cp)
 {
-	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_tcp_connection *tc = cp->cp_transport_data;
 	struct socket *osock = tc->t_sock;
 
 	if (!osock)
@@ -148,8 +148,8 @@ void rds_tcp_reset_callbacks(struct socket *sock,
 	 * We have an outstanding SYN to this peer, which may
 	 * potentially have transitioned to the RDS_CONN_UP state,
 	 * so we must quiesce any send threads before resetting
-	 * c_transport_data. We quiesce these threads by setting
-	 * c_state to something other than RDS_CONN_UP, and then
+	 * cp_transport_data. We quiesce these threads by setting
+	 * cp_state to something other than RDS_CONN_UP, and then
 	 * waiting for any existing threads in rds_send_xmit to
 	 * complete release_in_xmit(). (Subsequent threads entering
 	 * rds_send_xmit() will bail on !rds_conn_up().
@@ -164,8 +164,8 @@ void rds_tcp_reset_callbacks(struct socket *sock,
 	 * RDS_CONN_RESETTTING, to ensure that rds_tcp_state_change
 	 * cannot mark rds_conn_path_up() in the window before lock_sock()
 	 */
-	atomic_set(&conn->c_state, RDS_CONN_RESETTING);
-	wait_event(conn->c_waitq, !test_bit(RDS_IN_XMIT, &conn->c_flags));
+	atomic_set(&cp->cp_state, RDS_CONN_RESETTING);
+	wait_event(cp->cp_waitq, !test_bit(RDS_IN_XMIT, &cp->cp_flags));
 	lock_sock(osock->sk);
 	/* reset receive side state for rds_tcp_data_recv() for osock  */
 	if (tc->t_tinc) {
@@ -186,11 +186,12 @@ void rds_tcp_reset_callbacks(struct socket *sock,
 	release_sock(osock->sk);
 	sock_release(osock);
 newsock:
-	rds_send_path_reset(&conn->c_path[0]);
+	rds_send_path_reset(cp);
 	lock_sock(sock->sk);
 	write_lock_bh(&sock->sk->sk_callback_lock);
 	tc->t_sock = sock;
-	sock->sk->sk_user_data = conn;
+	tc->t_cpath = cp;
+	sock->sk->sk_user_data = cp;
 	sock->sk->sk_data_ready = rds_tcp_data_ready;
 	sock->sk->sk_write_space = rds_tcp_write_space;
 	sock->sk->sk_state_change = rds_tcp_state_change;
@@ -203,9 +204,9 @@ void rds_tcp_reset_callbacks(struct socket *sock,
  * above rds_tcp_reset_callbacks for notes about synchronization
  * with data path
  */
-void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn)
+void rds_tcp_set_callbacks(struct socket *sock, struct rds_conn_path *cp)
 {
-	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_tcp_connection *tc = cp->cp_transport_data;
 
 	rdsdebug("setting sock %p callbacks to tc %p\n", sock, tc);
 	write_lock_bh(&sock->sk->sk_callback_lock);
@@ -221,12 +222,12 @@ void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn)
 		sock->sk->sk_data_ready = sock->sk->sk_user_data;
 
 	tc->t_sock = sock;
-	tc->t_cpath = &conn->c_path[0];
+	tc->t_cpath = cp;
 	tc->t_orig_data_ready = sock->sk->sk_data_ready;
 	tc->t_orig_write_space = sock->sk->sk_write_space;
 	tc->t_orig_state_change = sock->sk->sk_state_change;
 
-	sock->sk->sk_user_data = conn;
+	sock->sk->sk_user_data = cp;
 	sock->sk->sk_data_ready = rds_tcp_data_ready;
 	sock->sk->sk_write_space = rds_tcp_write_space;
 	sock->sk->sk_state_change = rds_tcp_state_change;
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index e1ff169..151b09d 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -49,8 +49,8 @@ struct rds_tcp_statistics {
 /* tcp.c */
 void rds_tcp_tune(struct socket *sock);
 void rds_tcp_nonagle(struct socket *sock);
-void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn);
-void rds_tcp_reset_callbacks(struct socket *sock, struct rds_connection *conn);
+void rds_tcp_set_callbacks(struct socket *sock, struct rds_conn_path *cp);
+void rds_tcp_reset_callbacks(struct socket *sock, struct rds_conn_path *cp);
 void rds_tcp_restore_callbacks(struct socket *sock,
 			       struct rds_tcp_connection *tc);
 u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc);
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 146692c..7eddce5 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -41,16 +41,16 @@
 void rds_tcp_state_change(struct sock *sk)
 {
 	void (*state_change)(struct sock *sk);
-	struct rds_connection *conn;
+	struct rds_conn_path *cp;
 	struct rds_tcp_connection *tc;
 
 	read_lock_bh(&sk->sk_callback_lock);
-	conn = sk->sk_user_data;
-	if (!conn) {
+	cp = sk->sk_user_data;
+	if (!cp) {
 		state_change = sk->sk_state_change;
 		goto out;
 	}
-	tc = conn->c_transport_data;
+	tc = cp->cp_transport_data;
 	state_change = tc->t_orig_state_change;
 
 	rdsdebug("sock %p state_change to %d\n", tc->t_sock, sk->sk_state);
@@ -61,12 +61,11 @@ void rds_tcp_state_change(struct sock *sk)
 	case TCP_SYN_RECV:
 		break;
 	case TCP_ESTABLISHED:
-		rds_connect_path_complete(&conn->c_path[0],
-					  RDS_CONN_CONNECTING);
+		rds_connect_path_complete(cp, RDS_CONN_CONNECTING);
 		break;
 	case TCP_CLOSE_WAIT:
 	case TCP_CLOSE:
-		rds_conn_drop(conn);
+		rds_conn_path_drop(cp);
 	default:
 		break;
 	}
@@ -81,6 +80,7 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 	struct sockaddr_in src, dest;
 	int ret;
 	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_conn_path *cp = &conn->c_path[0];
 
 	mutex_lock(&tc->t_conn_path_lock);
 
@@ -114,7 +114,7 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 	 * once we call connect() we can start getting callbacks and they
 	 * own the socket
 	 */
-	rds_tcp_set_callbacks(sock, conn);
+	rds_tcp_set_callbacks(sock, cp);
 	ret = sock->ops->connect(sock, (struct sockaddr *)&dest, sizeof(dest),
 				 O_NONBLOCK);
 
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index d893346..ca975a2 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -79,6 +79,7 @@ int rds_tcp_accept_one(struct socket *sock)
 	struct inet_sock *inet;
 	struct rds_tcp_connection *rs_tcp = NULL;
 	int conn_state;
+	struct rds_conn_path *cp;
 
 	if (!sock) /* module unload or netns delete in progress */
 		return -ENETUNREACH;
@@ -120,6 +121,7 @@ int rds_tcp_accept_one(struct socket *sock)
 	 * rds_tcp_state_change() will do that cleanup
 	 */
 	rs_tcp = (struct rds_tcp_connection *)conn->c_transport_data;
+	cp = &conn->c_path[0];
 	rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
 	mutex_lock(&rs_tcp->t_conn_path_lock);
 	conn_state = rds_conn_state(conn);
@@ -136,16 +138,14 @@ int rds_tcp_accept_one(struct socket *sock)
 		    !conn->c_path[0].cp_outgoing) {
 			goto rst_nsk;
 		} else {
-			rds_tcp_reset_callbacks(new_sock, conn);
+			rds_tcp_reset_callbacks(new_sock, cp);
 			conn->c_path[0].cp_outgoing = 0;
 			/* rds_connect_path_complete() marks RDS_CONN_UP */
-			rds_connect_path_complete(&conn->c_path[0],
-						  RDS_CONN_RESETTING);
+			rds_connect_path_complete(cp, RDS_CONN_RESETTING);
 		}
 	} else {
-		rds_tcp_set_callbacks(new_sock, conn);
-		rds_connect_path_complete(&conn->c_path[0],
-					  RDS_CONN_CONNECTING);
+		rds_tcp_set_callbacks(new_sock, cp);
+		rds_connect_path_complete(cp, RDS_CONN_CONNECTING);
 	}
 	new_sock = NULL;
 	ret = 0;
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index 4a87d9e..aa7a79a 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -297,24 +297,24 @@ int rds_tcp_recv(struct rds_connection *conn)
 void rds_tcp_data_ready(struct sock *sk)
 {
 	void (*ready)(struct sock *sk);
-	struct rds_connection *conn;
+	struct rds_conn_path *cp;
 	struct rds_tcp_connection *tc;
 
 	rdsdebug("data ready sk %p\n", sk);
 
 	read_lock_bh(&sk->sk_callback_lock);
-	conn = sk->sk_user_data;
-	if (!conn) { /* check for teardown race */
+	cp = sk->sk_user_data;
+	if (!cp) { /* check for teardown race */
 		ready = sk->sk_data_ready;
 		goto out;
 	}
 
-	tc = conn->c_transport_data;
+	tc = cp->cp_transport_data;
 	ready = tc->t_orig_data_ready;
 	rds_tcp_stats_inc(s_tcp_data_ready_calls);
 
-	if (rds_tcp_read_sock(conn, GFP_ATOMIC) == -ENOMEM)
-		queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
+	if (rds_tcp_read_sock(cp->cp_conn, GFP_ATOMIC) == -ENOMEM)
+		queue_delayed_work(rds_wq, &cp->cp_recv_w, 0);
 out:
 	read_unlock_bh(&sk->sk_callback_lock);
 	ready(sk);
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 52cda94..57e0f58 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -178,27 +178,27 @@ static int rds_tcp_is_acked(struct rds_message *rm, uint64_t ack)
 void rds_tcp_write_space(struct sock *sk)
 {
 	void (*write_space)(struct sock *sk);
-	struct rds_connection *conn;
+	struct rds_conn_path *cp;
 	struct rds_tcp_connection *tc;
 
 	read_lock_bh(&sk->sk_callback_lock);
-	conn = sk->sk_user_data;
-	if (!conn) {
+	cp = sk->sk_user_data;
+	if (!cp) {
 		write_space = sk->sk_write_space;
 		goto out;
 	}
 
-	tc = conn->c_transport_data;
+	tc = cp->cp_transport_data;
 	rdsdebug("write_space for tc %p\n", tc);
 	write_space = tc->t_orig_write_space;
 	rds_tcp_stats_inc(s_tcp_write_space_calls);
 
 	rdsdebug("tcp una %u\n", rds_tcp_snd_una(tc));
 	tc->t_last_seen_una = rds_tcp_snd_una(tc);
-	rds_send_drop_acked(conn, rds_tcp_snd_una(tc), rds_tcp_is_acked);
+	rds_send_path_drop_acked(cp, rds_tcp_snd_una(tc), rds_tcp_is_acked);
 
 	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf)
-		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
+		queue_delayed_work(rds_wq, &cp->cp_send_w, 0);
 
 out:
 	read_unlock_bh(&sk->sk_callback_lock);
-- 
1.7.1
