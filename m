From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 05/17] RDS: Add rds_send_path_reset()
Date: Mon, 13 Jun 2016 09:44:30 -0700
Message-ID: <0264268d44b3dedc8d87ac8816cb0c3e2735bc2b.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25864 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964982AbcFMQpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:08 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rds_send_path_reset() is the path specific version of rds_send_reset()
intended for MP capable callers.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/send.c |   39 ++++++++++++++++++++++-----------------
 1 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index a3b3b35..bfb3e05 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -63,14 +63,14 @@ static void rds_send_remove_from_sock(struct list_head *messages, int status);
  * Reset the send state.  Callers must ensure that this doesn't race with
  * rds_send_xmit().
  */
-void rds_send_reset(struct rds_connection *conn)
+static void rds_send_path_reset(struct rds_conn_path *cp)
 {
 	struct rds_message *rm, *tmp;
 	unsigned long flags;
 
-	if (conn->c_xmit_rm) {
-		rm = conn->c_xmit_rm;
-		conn->c_xmit_rm = NULL;
+	if (cp->cp_xmit_rm) {
+		rm = cp->cp_xmit_rm;
+		cp->cp_xmit_rm = NULL;
 		/* Tell the user the RDMA op is no longer mapped by the
 		 * transport. This isn't entirely true (it's flushed out
 		 * independently) but as the connection is down, there's
@@ -79,26 +79,31 @@ void rds_send_reset(struct rds_connection *conn)
 		rds_message_put(rm);
 	}
 
-	conn->c_xmit_sg = 0;
-	conn->c_xmit_hdr_off = 0;
-	conn->c_xmit_data_off = 0;
-	conn->c_xmit_atomic_sent = 0;
-	conn->c_xmit_rdma_sent = 0;
-	conn->c_xmit_data_sent = 0;
+	cp->cp_xmit_sg = 0;
+	cp->cp_xmit_hdr_off = 0;
+	cp->cp_xmit_data_off = 0;
+	cp->cp_xmit_atomic_sent = 0;
+	cp->cp_xmit_rdma_sent = 0;
+	cp->cp_xmit_data_sent = 0;
 
-	conn->c_map_queued = 0;
+	cp->cp_conn->c_map_queued = 0;
 
-	conn->c_unacked_packets = rds_sysctl_max_unacked_packets;
-	conn->c_unacked_bytes = rds_sysctl_max_unacked_bytes;
+	cp->cp_unacked_packets = rds_sysctl_max_unacked_packets;
+	cp->cp_unacked_bytes = rds_sysctl_max_unacked_bytes;
 
 	/* Mark messages as retransmissions, and move them to the send q */
-	spin_lock_irqsave(&conn->c_lock, flags);
-	list_for_each_entry_safe(rm, tmp, &conn->c_retrans, m_conn_item) {
+	spin_lock_irqsave(&cp->cp_lock, flags);
+	list_for_each_entry_safe(rm, tmp, &cp->cp_retrans, m_conn_item) {
 		set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
 		set_bit(RDS_MSG_RETRANSMITTED, &rm->m_flags);
 	}
-	list_splice_init(&conn->c_retrans, &conn->c_send_queue);
-	spin_unlock_irqrestore(&conn->c_lock, flags);
+	list_splice_init(&cp->cp_retrans, &cp->cp_send_queue);
+	spin_unlock_irqrestore(&cp->cp_lock, flags);
+}
+
+void rds_send_reset(struct rds_connection *conn)
+{
+	rds_send_path_reset(&conn->c_path[0]);
 }
 EXPORT_SYMBOL_GPL(rds_send_reset);
 
-- 
1.7.1
