From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 06/17] RDS: Add rds_send_path_drop_acked()
Date: Mon, 13 Jun 2016 09:44:31 -0700
Message-ID: <78dbe8cef1c52d12ba552bf1b16fdcbccdf67412.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25872 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965088AbcFMQpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:14 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rds_send_path_drop_acked() is the path-specific version of
rds_send_drop_acked() to be invoked by MP capable callers.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/rds.h  |    2 ++
 net/rds/send.c |   18 +++++++++++++-----
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index c3b14cc..d94aa36 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -786,6 +786,8 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest);
 typedef int (*is_acked_func)(struct rds_message *rm, uint64_t ack);
 void rds_send_drop_acked(struct rds_connection *conn, u64 ack,
 			 is_acked_func is_acked);
+void rds_send_path_drop_acked(struct rds_conn_path *cp, u64 ack,
+			      is_acked_func is_acked);
 int rds_send_pong(struct rds_connection *conn, __be16 dport);
 struct rds_message *rds_send_get_message(struct rds_connection *,
 					 struct rm_rdma_op *);
diff --git a/net/rds/send.c b/net/rds/send.c
index bfb3e05..3f6a96c 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -691,16 +691,16 @@ static void rds_send_remove_from_sock(struct list_head *messages, int status)
  * assigned the m_ack_seq yet - but that's fine as long as tcp_is_acked
  * checks the RDS_MSG_HAS_ACK_SEQ bit.
  */
-void rds_send_drop_acked(struct rds_connection *conn, u64 ack,
-			 is_acked_func is_acked)
+void rds_send_path_drop_acked(struct rds_conn_path *cp, u64 ack,
+			      is_acked_func is_acked)
 {
 	struct rds_message *rm, *tmp;
 	unsigned long flags;
 	LIST_HEAD(list);
 
-	spin_lock_irqsave(&conn->c_lock, flags);
+	spin_lock_irqsave(&cp->cp_lock, flags);
 
-	list_for_each_entry_safe(rm, tmp, &conn->c_retrans, m_conn_item) {
+	list_for_each_entry_safe(rm, tmp, &cp->cp_retrans, m_conn_item) {
 		if (!rds_send_is_acked(rm, ack, is_acked))
 			break;
 
@@ -712,11 +712,19 @@ void rds_send_drop_acked(struct rds_connection *conn, u64 ack,
 	if (!list_empty(&list))
 		smp_mb__after_atomic();
 
-	spin_unlock_irqrestore(&conn->c_lock, flags);
+	spin_unlock_irqrestore(&cp->cp_lock, flags);
 
 	/* now remove the messages from the sock list as needed */
 	rds_send_remove_from_sock(&list, RDS_RDMA_SUCCESS);
 }
+EXPORT_SYMBOL_GPL(rds_send_path_drop_acked);
+
+void rds_send_drop_acked(struct rds_connection *conn, u64 ack,
+			 is_acked_func is_acked)
+{
+	WARN_ON(conn->c_trans->t_mp_capable);
+	rds_send_path_drop_acked(&conn->c_path[0], ack, is_acked);
+}
 EXPORT_SYMBOL_GPL(rds_send_drop_acked);
 
 void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
-- 
1.7.1
