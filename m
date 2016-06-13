From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 10/17] RDS: Extract rds_conn_path from i_conn_path in rds_send_drop_to() for MP-capable transports
Date: Mon, 13 Jun 2016 09:44:35 -0700
Message-ID: <a86af33247a43dbeb0f98751dcbb156835e241f6.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25917 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161065AbcFMQpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:12 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Explicitly set up rds_conn_path, either from i_conn_path (for
MP capable transpots) or as c_path[0], and use this in
rds_send_drop_to()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/send.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 966311d..9c34fd2 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -710,6 +710,7 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 {
 	struct rds_message *rm, *tmp;
 	struct rds_connection *conn;
+	struct rds_conn_path *cp;
 	unsigned long flags;
 	LIST_HEAD(list);
 
@@ -738,22 +739,26 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 	list_for_each_entry(rm, &list, m_sock_item) {
 
 		conn = rm->m_inc.i_conn;
+		if (conn->c_trans->t_mp_capable)
+			cp = rm->m_inc.i_conn_path;
+		else
+			cp = &conn->c_path[0];
 
-		spin_lock_irqsave(&conn->c_lock, flags);
+		spin_lock_irqsave(&cp->cp_lock, flags);
 		/*
 		 * Maybe someone else beat us to removing rm from the conn.
 		 * If we race with their flag update we'll get the lock and
 		 * then really see that the flag has been cleared.
 		 */
 		if (!test_and_clear_bit(RDS_MSG_ON_CONN, &rm->m_flags)) {
-			spin_unlock_irqrestore(&conn->c_lock, flags);
+			spin_unlock_irqrestore(&cp->cp_lock, flags);
 			spin_lock_irqsave(&rm->m_rs_lock, flags);
 			rm->m_rs = NULL;
 			spin_unlock_irqrestore(&rm->m_rs_lock, flags);
 			continue;
 		}
 		list_del_init(&rm->m_conn_item);
-		spin_unlock_irqrestore(&conn->c_lock, flags);
+		spin_unlock_irqrestore(&cp->cp_lock, flags);
 
 		/*
 		 * Couldn't grab m_rs_lock in top loop (lock ordering),
-- 
1.7.1
