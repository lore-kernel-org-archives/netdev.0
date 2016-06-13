From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 11/17] RDS: Make rds_send_pong() take a rds_conn_path argument
Date: Mon, 13 Jun 2016 09:44:36 -0700
Message-ID: <0441adf5fc4aafc1149859c8cfbb38df7cc2ab60.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40970 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161049AbcFMQpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:12 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit allows rds_send_pong() callers to send back
the rds pong message on some path other than c_path[0] by
passing in a struct rds_conn_path * argument.  It also
removes the last dependency on the #defines in rds_single.h
from send.c

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/rds.h  |    2 +-
 net/rds/recv.c |    2 +-
 net/rds/send.c |   24 ++++++++++++------------
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index b6072eb..e315151 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -790,7 +790,7 @@ void rds_send_drop_acked(struct rds_connection *conn, u64 ack,
 			 is_acked_func is_acked);
 void rds_send_path_drop_acked(struct rds_conn_path *cp, u64 ack,
 			      is_acked_func is_acked);
-int rds_send_pong(struct rds_connection *conn, __be16 dport);
+int rds_send_pong(struct rds_conn_path *cp, __be16 dport);
 
 /* rdma.c */
 void rds_rdma_unuse(struct rds_sock *rs, u32 r_key, int force);
diff --git a/net/rds/recv.c b/net/rds/recv.c
index 6d7bd63..b58f505 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -227,7 +227,7 @@ void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 
 	if (rds_sysctl_ping_enable && inc->i_hdr.h_dport == 0) {
 		rds_stats_inc(s_recv_ping);
-		rds_send_pong(conn, inc->i_hdr.h_sport);
+		rds_send_pong(cp, inc->i_hdr.h_sport);
 		goto out;
 	}
 
diff --git a/net/rds/send.c b/net/rds/send.c
index 9c34fd2..e614513 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -40,7 +40,6 @@
 #include <linux/export.h>
 #include <linux/sizes.h>
 
-#include "rds_single_path.h"
 #include "rds.h"
 
 /* When transmitting messages in rds_send_xmit, we need to emerge from
@@ -1153,7 +1152,7 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
  * Reply to a ping packet.
  */
 int
-rds_send_pong(struct rds_connection *conn, __be16 dport)
+rds_send_pong(struct rds_conn_path *cp, __be16 dport)
 {
 	struct rds_message *rm;
 	unsigned long flags;
@@ -1165,31 +1164,32 @@ rds_send_pong(struct rds_connection *conn, __be16 dport)
 		goto out;
 	}
 
-	rm->m_daddr = conn->c_faddr;
+	rm->m_daddr = cp->cp_conn->c_faddr;
 	rm->data.op_active = 1;
 
-	rds_conn_connect_if_down(conn);
+	rds_conn_connect_if_down(cp->cp_conn);
 
-	ret = rds_cong_wait(conn->c_fcong, dport, 1, NULL);
+	ret = rds_cong_wait(cp->cp_conn->c_fcong, dport, 1, NULL);
 	if (ret)
 		goto out;
 
-	spin_lock_irqsave(&conn->c_lock, flags);
-	list_add_tail(&rm->m_conn_item, &conn->c_send_queue);
+	spin_lock_irqsave(&cp->cp_lock, flags);
+	list_add_tail(&rm->m_conn_item, &cp->cp_send_queue);
 	set_bit(RDS_MSG_ON_CONN, &rm->m_flags);
 	rds_message_addref(rm);
-	rm->m_inc.i_conn = conn;
+	rm->m_inc.i_conn = cp->cp_conn;
+	rm->m_inc.i_conn_path = cp;
 
 	rds_message_populate_header(&rm->m_inc.i_hdr, 0, dport,
-				    conn->c_next_tx_seq);
-	conn->c_next_tx_seq++;
-	spin_unlock_irqrestore(&conn->c_lock, flags);
+				    cp->cp_next_tx_seq);
+	cp->cp_next_tx_seq++;
+	spin_unlock_irqrestore(&cp->cp_lock, flags);
 
 	rds_stats_inc(s_send_queued);
 	rds_stats_inc(s_send_pong);
 
 	/* schedule the send work on rds_wq */
-	queue_delayed_work(rds_wq, &conn->c_send_w, 1);
+	queue_delayed_work(rds_wq, &cp->cp_send_w, 1);
 
 	rds_message_put(rm);
 	return 0;
-- 
1.7.1
