From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 12/17] RDS: Add rds_conn_path_connect_if_down() for MP-aware callers
Date: Mon, 13 Jun 2016 09:44:37 -0700
Message-ID: <b2737ea769b5774a2f0db7ebad17eac3906bfb4d.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25913 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965097AbcFMQpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:17 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rds_conn_path_connect_if_down() works on the rds_conn_path
that it is passed. Callers who are not t_m_capable may continue
calling rds_conn_connect_if_down, which will invoke
rds_conn_path_connect_if_down() with the default c_path[0].

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |   12 +++++++++---
 net/rds/rds.h        |    1 +
 net/rds/send.c       |    9 ++++-----
 3 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 6fa2074..953a426 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -572,11 +572,17 @@ EXPORT_SYMBOL_GPL(rds_conn_drop);
  * If the connection is down, trigger a connect. We may have scheduled a
  * delayed reconnect however - in this case we should not interfere.
  */
+void rds_conn_path_connect_if_down(struct rds_conn_path *cp)
+{
+	if (rds_conn_path_state(cp) == RDS_CONN_DOWN &&
+	    !test_and_set_bit(RDS_RECONNECT_PENDING, &cp->cp_flags))
+		queue_delayed_work(rds_wq, &cp->cp_conn_w, 0);
+}
+
 void rds_conn_connect_if_down(struct rds_connection *conn)
 {
-	if (rds_conn_state(conn) == RDS_CONN_DOWN &&
-	    !test_and_set_bit(RDS_RECONNECT_PENDING, &conn->c_flags))
-		queue_delayed_work(rds_wq, &conn->c_conn_w, 0);
+	WARN_ON(conn->c_trans->t_mp_capable);
+	rds_conn_path_connect_if_down(&conn->c_path[0]);
 }
 EXPORT_SYMBOL_GPL(rds_conn_connect_if_down);
 
diff --git a/net/rds/rds.h b/net/rds/rds.h
index e315151..74fcf5a 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -658,6 +658,7 @@ void rds_conn_destroy(struct rds_connection *conn);
 void rds_conn_drop(struct rds_connection *conn);
 void rds_conn_path_drop(struct rds_conn_path *cpath);
 void rds_conn_connect_if_down(struct rds_connection *conn);
+void rds_conn_path_connect_if_down(struct rds_conn_path *cp);
 void rds_for_each_conn_info(struct socket *sock, unsigned int len,
 			  struct rds_info_iterator *iter,
 			  struct rds_info_lengths *lens,
diff --git a/net/rds/send.c b/net/rds/send.c
index e614513..369bd66 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1088,16 +1088,15 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 		goto out;
 	}
 
-	rds_conn_connect_if_down(conn);
+	cpath = &conn->c_path[0];
+
+	rds_conn_path_connect_if_down(cpath);
 
 	ret = rds_cong_wait(conn->c_fcong, dport, nonblock, rs);
 	if (ret) {
 		rs->rs_seen_congestion = 1;
 		goto out;
 	}
-
-	cpath = &conn->c_path[0];
-
 	while (!rds_send_queue_rm(rs, conn, cpath, rm, rs->rs_bound_port,
 				  dport, &queued)) {
 		rds_stats_inc(s_send_queue_full);
@@ -1167,7 +1166,7 @@ rds_send_pong(struct rds_conn_path *cp, __be16 dport)
 	rm->m_daddr = cp->cp_conn->c_faddr;
 	rm->data.op_active = 1;
 
-	rds_conn_connect_if_down(cp->cp_conn);
+	rds_conn_path_connect_if_down(cp);
 
 	ret = rds_cong_wait(cp->cp_conn->c_fcong, dport, 1, NULL);
 	if (ret)
-- 
1.7.1
