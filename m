From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 13/17] RDS: update rds-info related functions to traverse multiple conn_paths
Date: Mon, 13 Jun 2016 09:44:38 -0700
Message-ID: <76a423c0062eba4845a7cc27a8e350d29038d399.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25939 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964982AbcFMQpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:15 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit updates the callbacks related to the rds-info command
so that they walk through all the rds_conn_path structures and
report the requested info.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |  109 +++++++++++++++++++++++++++++++++++++------------
 1 files changed, 82 insertions(+), 27 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 953a426..9e0b489 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -400,6 +400,7 @@ static void rds_conn_message_info(struct socket *sock, unsigned int len,
 	unsigned int total = 0;
 	unsigned long flags;
 	size_t i;
+	int j;
 
 	len /= sizeof(struct rds_info_message);
 
@@ -408,23 +409,32 @@ static void rds_conn_message_info(struct socket *sock, unsigned int len,
 	for (i = 0, head = rds_conn_hash; i < ARRAY_SIZE(rds_conn_hash);
 	     i++, head++) {
 		hlist_for_each_entry_rcu(conn, head, c_hash_node) {
-			if (want_send)
-				list = &conn->c_send_queue;
-			else
-				list = &conn->c_retrans;
-
-			spin_lock_irqsave(&conn->c_lock, flags);
-
-			/* XXX too lazy to maintain counts.. */
-			list_for_each_entry(rm, list, m_conn_item) {
-				total++;
-				if (total <= len)
-					rds_inc_info_copy(&rm->m_inc, iter,
-							  conn->c_laddr,
-							  conn->c_faddr, 0);
+			struct rds_conn_path *cp;
+
+			for (j = 0; j < RDS_MPATH_WORKERS; j++) {
+				cp = &conn->c_path[j];
+				if (want_send)
+					list = &cp->cp_send_queue;
+				else
+					list = &cp->cp_retrans;
+
+				spin_lock_irqsave(&cp->cp_lock, flags);
+
+				/* XXX too lazy to maintain counts.. */
+				list_for_each_entry(rm, list, m_conn_item) {
+					total++;
+					if (total <= len)
+						rds_inc_info_copy(&rm->m_inc,
+								  iter,
+								  conn->c_laddr,
+								  conn->c_faddr,
+								  0);
+				}
+
+				spin_unlock_irqrestore(&cp->cp_lock, flags);
+				if (!conn->c_trans->t_mp_capable)
+					break;
 			}
-
-			spin_unlock_irqrestore(&conn->c_lock, flags);
 		}
 	}
 	rcu_read_unlock();
@@ -486,27 +496,72 @@ void rds_for_each_conn_info(struct socket *sock, unsigned int len,
 }
 EXPORT_SYMBOL_GPL(rds_for_each_conn_info);
 
-static int rds_conn_info_visitor(struct rds_connection *conn,
-				  void *buffer)
+void rds_walk_conn_path_info(struct socket *sock, unsigned int len,
+			     struct rds_info_iterator *iter,
+			     struct rds_info_lengths *lens,
+			     int (*visitor)(struct rds_conn_path *, void *),
+			     size_t item_len)
+{
+	u64  buffer[(item_len + 7) / 8];
+	struct hlist_head *head;
+	struct rds_connection *conn;
+	size_t i;
+	int j;
+
+	rcu_read_lock();
+
+	lens->nr = 0;
+	lens->each = item_len;
+
+	for (i = 0, head = rds_conn_hash; i < ARRAY_SIZE(rds_conn_hash);
+	     i++, head++) {
+		hlist_for_each_entry_rcu(conn, head, c_hash_node) {
+			struct rds_conn_path *cp;
+
+			for (j = 0; j < RDS_MPATH_WORKERS; j++) {
+				cp = &conn->c_path[j];
+
+				/* XXX no cp_lock usage.. */
+				if (!visitor(cp, buffer))
+					continue;
+				if (!conn->c_trans->t_mp_capable)
+					break;
+			}
+
+			/* We copy as much as we can fit in the buffer,
+			 * but we count all items so that the caller
+			 * can resize the buffer.
+			 */
+			if (len >= item_len) {
+				rds_info_copy(iter, buffer, item_len);
+				len -= item_len;
+			}
+			lens->nr++;
+		}
+	}
+	rcu_read_unlock();
+}
+
+static int rds_conn_info_visitor(struct rds_conn_path *cp, void *buffer)
 {
 	struct rds_info_connection *cinfo = buffer;
 
-	cinfo->next_tx_seq = conn->c_next_tx_seq;
-	cinfo->next_rx_seq = conn->c_next_rx_seq;
-	cinfo->laddr = conn->c_laddr;
-	cinfo->faddr = conn->c_faddr;
-	strncpy(cinfo->transport, conn->c_trans->t_name,
+	cinfo->next_tx_seq = cp->cp_next_tx_seq;
+	cinfo->next_rx_seq = cp->cp_next_rx_seq;
+	cinfo->laddr = cp->cp_conn->c_laddr;
+	cinfo->faddr = cp->cp_conn->c_faddr;
+	strncpy(cinfo->transport, cp->cp_conn->c_trans->t_name,
 		sizeof(cinfo->transport));
 	cinfo->flags = 0;
 
-	rds_conn_info_set(cinfo->flags, test_bit(RDS_IN_XMIT, &conn->c_flags),
+	rds_conn_info_set(cinfo->flags, test_bit(RDS_IN_XMIT, &cp->cp_flags),
 			  SENDING);
 	/* XXX Future: return the state rather than these funky bits */
 	rds_conn_info_set(cinfo->flags,
-			  atomic_read(&conn->c_state) == RDS_CONN_CONNECTING,
+			  atomic_read(&cp->cp_state) == RDS_CONN_CONNECTING,
 			  CONNECTING);
 	rds_conn_info_set(cinfo->flags,
-			  atomic_read(&conn->c_state) == RDS_CONN_UP,
+			  atomic_read(&cp->cp_state) == RDS_CONN_UP,
 			  CONNECTED);
 	return 1;
 }
@@ -515,7 +570,7 @@ static void rds_conn_info(struct socket *sock, unsigned int len,
 			  struct rds_info_iterator *iter,
 			  struct rds_info_lengths *lens)
 {
-	rds_for_each_conn_info(sock, len, iter, lens,
+	rds_walk_conn_path_info(sock, len, iter, lens,
 				rds_conn_info_visitor,
 				sizeof(struct rds_info_connection));
 }
-- 
1.7.1
