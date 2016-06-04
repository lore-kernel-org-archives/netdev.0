From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 3/3] RDS: TCP: fix race windows in send-path quiescence by rds_tcp_accept_one()
Date: Sat,  4 Jun 2016 14:00:00 -0700
Message-ID: <b5c21c0947c123c6a7812bb1e3547d7f445fdc43.1465071319.git.sowmini.varadhan@oracle.com>
References: <cover.1465071319.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32684 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbcFDVAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 17:00:54 -0400
In-Reply-To: <cover.1465071319.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465071319.git.sowmini.varadhan@oracle.com>
References: <cover.1465071319.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The send path needs to be quiesced before resetting callbacks from
rds_tcp_accept_one(), and commit eb192840266f ("RDS:TCP: Synchronize
rds_tcp_accept_one with rds_send_xmit when resetting t_sock") achieves
this using the c_state and RDS_IN_XMIT bit following the pattern
used by rds_conn_shutdown(). However this leaves the possibility
of a race window as shown in the sequence below
    take t_conn_lock in rds_tcp_conn_connect
    send outgoing syn to peer
    drop t_conn_lock in rds_tcp_conn_connect
    incoming from peer triggers rds_tcp_accept_one, conn is
	marked CONNECTING
    wait for RDS_IN_XMIT to quiesce any rds_send_xmit threads
    call rds_tcp_reset_callbacks
    [.. race-window where incoming syn-ack can cause the conn
	to be marked UP from rds_tcp_state_change ..]
    lock_sock called from rds_tcp_reset_callbacks, and we set
	t_sock to null
As soon as the conn is marked UP in the race-window above, rds_send_xmit()
threads will proceed to rds_tcp_xmit and may encounter a null-pointer
deref on the t_sock.

Given that rds_tcp_state_change() is invoked in softirq context, whereas
rds_tcp_reset_callbacks() is in workq context, and testing for RDS_IN_XMIT
after lock_sock could result in a deadlock with tcp_sendmsg, this
commit fixes the race by using a new c_state, RDS_TCP_RESETTING, which
will prevent a transition to RDS_CONN_UP from rds_tcp_state_change().

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/rds.h         |    2 ++
 net/rds/tcp.c         |   14 +++++++++++++-
 net/rds/tcp_connect.c |    2 +-
 net/rds/tcp_listen.c  |    7 +++----
 net/rds/threads.c     |   10 ++++++++--
 5 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index 80256b0..387df5f 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -74,6 +74,7 @@ enum {
 	RDS_CONN_CONNECTING,
 	RDS_CONN_DISCONNECTING,
 	RDS_CONN_UP,
+	RDS_CONN_RESETTING,
 	RDS_CONN_ERROR,
 };
 
@@ -813,6 +814,7 @@ void rds_connect_worker(struct work_struct *);
 void rds_shutdown_worker(struct work_struct *);
 void rds_send_worker(struct work_struct *);
 void rds_recv_worker(struct work_struct *);
+void rds_connect_path_complete(struct rds_connection *conn, int curr);
 void rds_connect_complete(struct rds_connection *conn);
 
 /* transport.c */
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 7ab1b41..74ee126 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -148,11 +148,23 @@ void rds_tcp_reset_callbacks(struct socket *sock,
 	 * potentially have transitioned to the RDS_CONN_UP state,
 	 * so we must quiesce any send threads before resetting
 	 * c_transport_data. We quiesce these threads by setting
-	 * cp_state to something other than RDS_CONN_UP, and then
+	 * c_state to something other than RDS_CONN_UP, and then
 	 * waiting for any existing threads in rds_send_xmit to
 	 * complete release_in_xmit(). (Subsequent threads entering
 	 * rds_send_xmit() will bail on !rds_conn_up().
+	 *
+	 * However an incoming syn-ack at this point would end up
+	 * marking the conn as RDS_CONN_UP, and would again permit
+	 * rds_send_xmi() threads through, so ideally we would
+	 * synchronize on RDS_CONN_UP after lock_sock(), but cannot
+	 * do that: waiting on !RDS_IN_XMIT after lock_sock() may
+	 * end up deadlocking with tcp_sendmsg(), and the RDS_IN_XMIT
+	 * would not get set. As a result, we set c_state to
+	 * RDS_CONN_RESETTTING, to ensure that rds_tcp_state_change
+	 * cannot mark rds_conn_path_up() in the window before lock_sock()
 	 */
+	atomic_set(&conn->c_state, RDS_CONN_RESETTING);
+	wait_event(conn->c_waitq, !test_bit(RDS_IN_XMIT, &conn->c_flags));
 	lock_sock(osock->sk);
 	/* reset receive side state for rds_tcp_data_recv() for osock  */
 	if (tc->t_tinc) {
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index fb82e0a..fba13d0 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -60,7 +60,7 @@ void rds_tcp_state_change(struct sock *sk)
 		case TCP_SYN_RECV:
 			break;
 		case TCP_ESTABLISHED:
-			rds_connect_complete(conn);
+			rds_connect_path_complete(conn, RDS_CONN_CONNECTING);
 			break;
 		case TCP_CLOSE_WAIT:
 		case TCP_CLOSE:
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index d9fe536..686b1d0 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -135,16 +135,15 @@ int rds_tcp_accept_one(struct socket *sock)
 		    !conn->c_outgoing) {
 			goto rst_nsk;
 		} else {
-			atomic_set(&conn->c_state, RDS_CONN_CONNECTING);
-			wait_event(conn->c_waitq,
-				   !test_bit(RDS_IN_XMIT, &conn->c_flags));
 			rds_tcp_reset_callbacks(new_sock, conn);
 			conn->c_outgoing = 0;
+			/* rds_connect_path_complete() marks RDS_CONN_UP */
+			rds_connect_path_complete(conn, RDS_CONN_DISCONNECTING);
 		}
 	} else {
 		rds_tcp_set_callbacks(new_sock, conn);
+		rds_connect_path_complete(conn, RDS_CONN_CONNECTING);
 	}
-	rds_connect_complete(conn); /* marks RDS_CONN_UP */
 	new_sock = NULL;
 	ret = 0;
 	goto out;
diff --git a/net/rds/threads.c b/net/rds/threads.c
index 454aa6d..4a32304 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -71,9 +71,9 @@
 struct workqueue_struct *rds_wq;
 EXPORT_SYMBOL_GPL(rds_wq);
 
-void rds_connect_complete(struct rds_connection *conn)
+void rds_connect_path_complete(struct rds_connection *conn, int curr)
 {
-	if (!rds_conn_transition(conn, RDS_CONN_CONNECTING, RDS_CONN_UP)) {
+	if (!rds_conn_transition(conn, curr, RDS_CONN_UP)) {
 		printk(KERN_WARNING "%s: Cannot transition to state UP, "
 				"current state is %d\n",
 				__func__,
@@ -90,6 +90,12 @@ void rds_connect_complete(struct rds_connection *conn)
 	queue_delayed_work(rds_wq, &conn->c_send_w, 0);
 	queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
 }
+EXPORT_SYMBOL_GPL(rds_connect_path_complete);
+
+void rds_connect_complete(struct rds_connection *conn)
+{
+	rds_connect_path_complete(conn, RDS_CONN_CONNECTING);
+}
 EXPORT_SYMBOL_GPL(rds_connect_complete);
 
 /*
-- 
1.7.1
