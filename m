From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 15/17] RDS: Initialize all RDS_MPATH_WORKERS in __rds_conn_create
Date: Mon, 13 Jun 2016 09:44:40 -0700
Message-ID: <2b0bfd2d4af8bc0bf18e4d714d5c47538ccaad9c.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40990 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422641AbcFMQpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:24 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a for() loop in __rds_conn_create to initialize all the
conn_paths, in preparate for MP capable transports.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |   65 ++++++++++++++++++++++++++++++++++---------------
 1 files changed, 45 insertions(+), 20 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 57556e6..a99ac69 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -111,6 +111,32 @@ static void rds_conn_reset(struct rds_connection *conn)
 	 * reliability guarantees of RDS. */
 }
 
+static void __rds_conn_path_init(struct rds_connection *conn,
+				 struct rds_conn_path *cp, bool is_outgoing)
+{
+	spin_lock_init(&cp->cp_lock);
+	cp->cp_next_tx_seq = 1;
+	init_waitqueue_head(&cp->cp_waitq);
+	INIT_LIST_HEAD(&cp->cp_send_queue);
+	INIT_LIST_HEAD(&cp->cp_retrans);
+
+	cp->cp_conn = conn;
+	atomic_set(&cp->cp_state, RDS_CONN_DOWN);
+	cp->cp_send_gen = 0;
+	/* cp_outgoing is per-path. So we can only set it here
+	 * for the single-path transports.
+	 */
+	if (!conn->c_trans->t_mp_capable)
+		cp->cp_outgoing = (is_outgoing ? 1 : 0);
+	cp->cp_reconnect_jiffies = 0;
+	INIT_DELAYED_WORK(&cp->cp_send_w, rds_send_worker);
+	INIT_DELAYED_WORK(&cp->cp_recv_w, rds_recv_worker);
+	INIT_DELAYED_WORK(&cp->cp_conn_w, rds_connect_worker);
+	INIT_WORK(&cp->cp_down_w, rds_shutdown_worker);
+	mutex_init(&cp->cp_cm_lock);
+	cp->cp_flags = 0;
+}
+
 /*
  * There is only every one 'conn' for a given pair of addresses in the
  * system at a time.  They contain messages to be retransmitted and so
@@ -154,14 +180,8 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 	INIT_HLIST_NODE(&conn->c_hash_node);
 	conn->c_laddr = laddr;
 	conn->c_faddr = faddr;
-	spin_lock_init(&conn->c_lock);
-	conn->c_next_tx_seq = 1;
-	conn->c_path[0].cp_conn = conn;
-	rds_conn_net_set(conn, net);
 
-	init_waitqueue_head(&conn->c_waitq);
-	INIT_LIST_HEAD(&conn->c_send_queue);
-	INIT_LIST_HEAD(&conn->c_retrans);
+	rds_conn_net_set(conn, net);
 
 	ret = rds_cong_get_maps(conn);
 	if (ret) {
@@ -197,17 +217,6 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 		goto out;
 	}
 
-	atomic_set(&conn->c_state, RDS_CONN_DOWN);
-	conn->c_send_gen = 0;
-	conn->c_path[0].cp_outgoing = (is_outgoing ? 1 : 0);
-	conn->c_reconnect_jiffies = 0;
-	INIT_DELAYED_WORK(&conn->c_send_w, rds_send_worker);
-	INIT_DELAYED_WORK(&conn->c_recv_w, rds_recv_worker);
-	INIT_DELAYED_WORK(&conn->c_conn_w, rds_connect_worker);
-	INIT_WORK(&conn->c_down_w, rds_shutdown_worker);
-	mutex_init(&conn->c_cm_lock);
-	conn->c_flags = 0;
-
 	rdsdebug("allocated conn %p for %pI4 -> %pI4 over %s %s\n",
 	  conn, &laddr, &faddr,
 	  trans->t_name ? trans->t_name : "[unknown]",
@@ -224,7 +233,7 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 	if (parent) {
 		/* Creating passive conn */
 		if (parent->c_passive) {
-			trans->conn_free(conn->c_transport_data);
+			trans->conn_free(conn->c_path[0].cp_transport_data);
 			kmem_cache_free(rds_conn_slab, conn);
 			conn = parent->c_passive;
 		} else {
@@ -238,10 +247,26 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 
 		found = rds_conn_lookup(net, head, laddr, faddr, trans);
 		if (found) {
-			trans->conn_free(conn->c_transport_data);
+			struct rds_conn_path *cp;
+			int i;
+
+			for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+				cp = &conn->c_path[i];
+				trans->conn_free(cp->cp_transport_data);
+				if (!trans->t_mp_capable)
+					break;
+			}
 			kmem_cache_free(rds_conn_slab, conn);
 			conn = found;
 		} else {
+			int i;
+
+			for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+				__rds_conn_path_init(conn, &conn->c_path[i],
+						     is_outgoing);
+				conn->c_path[i].cp_index = i;
+			}
+
 			hlist_add_head_rcu(&conn->c_hash_node, head);
 			rds_cong_add_conn(conn);
 			rds_conn_count++;
-- 
1.7.1
