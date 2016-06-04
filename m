From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 1/3] RDS: TCP: Add/use rds_tcp_reset_callbacks to reset tcp socket safely
Date: Sat,  4 Jun 2016 13:59:58 -0700
Message-ID: <1d38b67763bc39068310a4dbc13ee9e56b8f0dab.1465071319.git.sowmini.varadhan@oracle.com>
References: <cover.1465071319.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32682 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbcFDVAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 17:00:54 -0400
In-Reply-To: <cover.1465071319.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465071319.git.sowmini.varadhan@oracle.com>
References: <cover.1465071319.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When rds_tcp_accept_one() has to replace the existing tcp socket
with a newer tcp socket (duelling-syn resolution), it must lock_sock()
to suppress the rds_tcp_data_recv() path while callbacks are being
changed.  Also, existing RDS datagram reassembly state must be reset,
so that the next datagram on the new socket  does not have corrupted
state. Similarly when resetting the newly accepted socket, appropriate
locks and synchronization is needed.

This commit ensures correct synchronization by invoking
kernel_sock_shutdown to reset a newly accepted sock, and by taking
appropriate lock_sock()s (for old and new sockets) when resetting
existing callbacks.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c        |   65 +++++++++++++++++++++++++++++++++++++++++++++++--
 net/rds/tcp.h        |    1 +
 net/rds/tcp_listen.c |   13 +++-------
 3 files changed, 67 insertions(+), 12 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 86187da..8faa0b1 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -126,9 +126,68 @@ void rds_tcp_restore_callbacks(struct socket *sock,
 }
 
 /*
- * This is the only path that sets tc->t_sock.  Send and receive trust that
- * it is set.  The RDS_CONN_UP bit protects those paths from being
- * called while it isn't set.
+ * rds_tcp_reset_callbacks() switches the to the new sock and
+ * returns the existing tc->t_sock.
+ *
+ * The only functions that set tc->t_sock are rds_tcp_set_callbacks
+ * and rds_tcp_reset_callbacks.  Send and receive trust that
+ * it is set.  The absence of RDS_CONN_UP bit protects those paths
+ * from being called while it isn't set.
+ */
+void rds_tcp_reset_callbacks(struct socket *sock,
+			     struct rds_connection *conn)
+{
+	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct socket *osock = tc->t_sock;
+
+	if (!osock)
+		goto newsock;
+
+	/* Need to resolve a duelling SYN between peers.
+	 * We have an outstanding SYN to this peer, which may
+	 * potentially have transitioned to the RDS_CONN_UP state,
+	 * so we must quiesce any send threads before resetting
+	 * c_transport_data. We quiesce these threads by setting
+	 * cp_state to something other than RDS_CONN_UP, and then
+	 * waiting for any existing threads in rds_send_xmit to
+	 * complete release_in_xmit(). (Subsequent threads entering
+	 * rds_send_xmit() will bail on !rds_conn_up().
+	 */
+	lock_sock(osock->sk);
+	/* reset receive side state for rds_tcp_data_recv() for osock  */
+	if (tc->t_tinc) {
+		rds_inc_put(&tc->t_tinc->ti_inc);
+		tc->t_tinc = NULL;
+	}
+	tc->t_tinc_hdr_rem = sizeof(struct rds_header);
+	tc->t_tinc_data_rem = 0;
+	tc->t_sock = NULL;
+
+	write_lock_bh(&osock->sk->sk_callback_lock);
+
+	osock->sk->sk_user_data = NULL;
+	osock->sk->sk_data_ready = tc->t_orig_data_ready;
+	osock->sk->sk_write_space = tc->t_orig_write_space;
+	osock->sk->sk_state_change = tc->t_orig_state_change;
+	write_unlock_bh(&osock->sk->sk_callback_lock);
+	release_sock(osock->sk);
+	sock_release(osock);
+newsock:
+	lock_sock(sock->sk);
+	write_lock_bh(&sock->sk->sk_callback_lock);
+	tc->t_sock = sock;
+	sock->sk->sk_user_data = conn;
+	sock->sk->sk_data_ready = rds_tcp_data_ready;
+	sock->sk->sk_write_space = rds_tcp_write_space;
+	sock->sk->sk_state_change = rds_tcp_state_change;
+
+	write_unlock_bh(&sock->sk->sk_callback_lock);
+	release_sock(sock->sk);
+}
+
+/* Add tc to rds_tcp_tc_list and set tc->t_sock. See comments
+ * above rds_tcp_reset_callbacks for notes about synchronization
+ * with data path
  */
 void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn)
 {
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 41c2283..ec0602b 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -50,6 +50,7 @@ struct rds_tcp_statistics {
 void rds_tcp_tune(struct socket *sock);
 void rds_tcp_nonagle(struct socket *sock);
 void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn);
+void rds_tcp_reset_callbacks(struct socket *sock, struct rds_connection *conn);
 void rds_tcp_restore_callbacks(struct socket *sock,
 			       struct rds_tcp_connection *tc);
 u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc);
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 4bf4bef..d9fe536 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -78,7 +78,6 @@ int rds_tcp_accept_one(struct socket *sock)
 	struct inet_sock *inet;
 	struct rds_tcp_connection *rs_tcp = NULL;
 	int conn_state;
-	struct sock *nsk;
 
 	if (!sock) /* module unload or netns delete in progress */
 		return -ENETUNREACH;
@@ -139,23 +138,19 @@ int rds_tcp_accept_one(struct socket *sock)
 			atomic_set(&conn->c_state, RDS_CONN_CONNECTING);
 			wait_event(conn->c_waitq,
 				   !test_bit(RDS_IN_XMIT, &conn->c_flags));
-			rds_tcp_restore_callbacks(rs_tcp->t_sock, rs_tcp);
+			rds_tcp_reset_callbacks(new_sock, conn);
 			conn->c_outgoing = 0;
 		}
+	} else {
+		rds_tcp_set_callbacks(new_sock, conn);
 	}
-	rds_tcp_set_callbacks(new_sock, conn);
 	rds_connect_complete(conn); /* marks RDS_CONN_UP */
 	new_sock = NULL;
 	ret = 0;
 	goto out;
 rst_nsk:
 	/* reset the newly returned accept sock and bail */
-	nsk = new_sock->sk;
-	rds_tcp_stats_inc(s_tcp_listen_closed_stale);
-	nsk->sk_user_data = NULL;
-	nsk->sk_prot->disconnect(nsk, 0);
-	tcp_done(nsk);
-	new_sock = NULL;
+	kernel_sock_shutdown(new_sock, SHUT_RDWR);
 	ret = 0;
 out:
 	if (rs_tcp)
-- 
1.7.1
