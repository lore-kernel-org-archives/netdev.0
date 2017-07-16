From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] rds: cancel send/recv work before queuing connection shutdown
Date: Sun, 16 Jul 2017 16:43:46 -0700
Message-ID: <1500248626-80602-1-git-send-email-sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
        sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51264 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdGPXrr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 19:47:47 -0400
To: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We could end up executing rds_conn_shutdown before the rds_recv_worker
thread, then rds_conn_shutdown -> rds_tcp_conn_shutdown can do a
sock_release and set sock->sk to null, which may interleave in bad
ways with rds_recv_worker, e.g., it could result in:

"BUG: unable to handle kernel NULL pointer dereference at 0000000000000078"
    [ffff881769f6fd70] release_sock at ffffffff815f337b
    [ffff881769f6fd90] rds_tcp_recv at ffffffffa043c888 [rds_tcp]
    [ffff881769f6fdb0] rds_recv_worker at ffffffffa04a4810 [rds]
    [ffff881769f6fde0] process_one_work at ffffffff810a14c1
    [ffff881769f6fe40] worker_thread at ffffffff810a1940
    [ffff881769f6fec0] kthread at ffffffff810a6b1e

Also, do not enqueue any new shutdown workq items when the connection is
shutting down (this may happen for rds-tcp in softirq mode, if a FIN
or CLOSE is received while the modules is in the middle of an unload)

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c  |   16 ++++++++++------
 net/rds/rds.h         |    2 +-
 net/rds/tcp.c         |    2 +-
 net/rds/tcp_connect.c |    4 ++--
 net/rds/tcp_send.c    |    2 +-
 net/rds/threads.c     |    2 +-
 6 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 50a3789..005bca6 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -374,13 +374,13 @@ static void rds_conn_path_destroy(struct rds_conn_path *cp)
 	if (!cp->cp_transport_data)
 		return;
 
-	rds_conn_path_drop(cp);
-	flush_work(&cp->cp_down_w);
-
 	/* make sure lingering queued work won't try to ref the conn */
 	cancel_delayed_work_sync(&cp->cp_send_w);
 	cancel_delayed_work_sync(&cp->cp_recv_w);
 
+	rds_conn_path_drop(cp, true);
+	flush_work(&cp->cp_down_w);
+
 	/* tear down queued messages */
 	list_for_each_entry_safe(rm, rtmp,
 				 &cp->cp_send_queue,
@@ -664,9 +664,13 @@ void rds_conn_exit(void)
 /*
  * Force a disconnect
  */
-void rds_conn_path_drop(struct rds_conn_path *cp)
+void rds_conn_path_drop(struct rds_conn_path *cp, bool destroy)
 {
 	atomic_set(&cp->cp_state, RDS_CONN_ERROR);
+
+	if (!destroy && cp->cp_conn->c_destroy_in_prog)
+		return;
+
 	queue_work(rds_wq, &cp->cp_down_w);
 }
 EXPORT_SYMBOL_GPL(rds_conn_path_drop);
@@ -674,7 +678,7 @@ void rds_conn_path_drop(struct rds_conn_path *cp)
 void rds_conn_drop(struct rds_connection *conn)
 {
 	WARN_ON(conn->c_trans->t_mp_capable);
-	rds_conn_path_drop(&conn->c_path[0]);
+	rds_conn_path_drop(&conn->c_path[0], false);
 }
 EXPORT_SYMBOL_GPL(rds_conn_drop);
 
@@ -706,5 +710,5 @@ void rds_conn_connect_if_down(struct rds_connection *conn)
 	vprintk(fmt, ap);
 	va_end(ap);
 
-	rds_conn_path_drop(cp);
+	rds_conn_path_drop(cp, false);
 }
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 516bcc8..3382695 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -700,7 +700,7 @@ struct rds_connection *rds_conn_create_outgoing(struct net *net,
 void rds_conn_shutdown(struct rds_conn_path *cpath);
 void rds_conn_destroy(struct rds_connection *conn);
 void rds_conn_drop(struct rds_connection *conn);
-void rds_conn_path_drop(struct rds_conn_path *cpath);
+void rds_conn_path_drop(struct rds_conn_path *cpath, bool destroy);
 void rds_conn_connect_if_down(struct rds_connection *conn);
 void rds_conn_path_connect_if_down(struct rds_conn_path *cp);
 void rds_for_each_conn_info(struct socket *sock, unsigned int len,
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 431404d..6b7ee71 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -592,7 +592,7 @@ static void rds_tcp_sysctl_reset(struct net *net)
 			continue;
 
 		/* reconnect with new parameters */
-		rds_conn_path_drop(tc->t_cpath);
+		rds_conn_path_drop(tc->t_cpath, false);
 	}
 	spin_unlock_irq(&rds_tcp_conn_lock);
 }
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index cbe08a1..46f74da 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -69,14 +69,14 @@ void rds_tcp_state_change(struct sock *sk)
 		if (!IS_CANONICAL(cp->cp_conn->c_laddr, cp->cp_conn->c_faddr) &&
 		    rds_conn_path_transition(cp, RDS_CONN_CONNECTING,
 					     RDS_CONN_ERROR)) {
-			rds_conn_path_drop(cp);
+			rds_conn_path_drop(cp, false);
 		} else {
 			rds_connect_path_complete(cp, RDS_CONN_CONNECTING);
 		}
 		break;
 	case TCP_CLOSE_WAIT:
 	case TCP_CLOSE:
-		rds_conn_path_drop(cp);
+		rds_conn_path_drop(cp, false);
 	default:
 		break;
 	}
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 0d8616a..dc860d1 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -157,7 +157,7 @@ int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 					"returned %d, "
 					"disconnecting and reconnecting\n",
 					&conn->c_faddr, cp->cp_index, ret);
-				rds_conn_path_drop(cp);
+				rds_conn_path_drop(cp, false);
 			}
 		}
 	}
diff --git a/net/rds/threads.c b/net/rds/threads.c
index 2852bc1..f121daa 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -78,7 +78,7 @@ void rds_connect_path_complete(struct rds_conn_path *cp, int curr)
 				"current state is %d\n",
 				__func__,
 				atomic_read(&cp->cp_state));
-		rds_conn_path_drop(cp);
+		rds_conn_path_drop(cp, false);
 		return;
 	}
 
-- 
1.7.1
