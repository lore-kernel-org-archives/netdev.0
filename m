From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] rds: reduce memory footprint for RDS when transport is RDMA
Date: Wed,  2 Aug 2017 10:34:31 -0700
Message-ID: <1501695271-146367-1-git-send-email-sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
        sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43236 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdHBRjb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 13:39:31 -0400
To: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS over IB does not use multipath RDS, so the array
of additional rds_conn_path structures is always superfluous
in this case. Reduce the memory footprint of the rds module
by making this a dynamic allocation predicated on whether
the transport is mp_capable.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Tested-by: Efrain Galaviz <efrain.galaviz@oracle.com>
---
 net/rds/connection.c |   34 +++++++++++++++++++++++++---------
 net/rds/rds.h        |    2 +-
 2 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 005bca6..7ee2d5d 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -151,6 +151,7 @@ static void __rds_conn_path_init(struct rds_connection *conn,
 	struct rds_transport *loop_trans;
 	unsigned long flags;
 	int ret, i;
+	int npaths = (trans->t_mp_capable ? RDS_MPATH_WORKERS : 1);
 
 	rcu_read_lock();
 	conn = rds_conn_lookup(net, head, laddr, faddr, trans);
@@ -172,6 +173,12 @@ static void __rds_conn_path_init(struct rds_connection *conn,
 		conn = ERR_PTR(-ENOMEM);
 		goto out;
 	}
+	conn->c_path = kcalloc(npaths, sizeof(struct rds_conn_path), gfp);
+	if (!conn->c_path) {
+		kmem_cache_free(rds_conn_slab, conn);
+		conn = ERR_PTR(-ENOMEM);
+		goto out;
+	}
 
 	INIT_HLIST_NODE(&conn->c_hash_node);
 	conn->c_laddr = laddr;
@@ -181,6 +188,7 @@ static void __rds_conn_path_init(struct rds_connection *conn,
 
 	ret = rds_cong_get_maps(conn);
 	if (ret) {
+		kfree(conn->c_path);
 		kmem_cache_free(rds_conn_slab, conn);
 		conn = ERR_PTR(ret);
 		goto out;
@@ -207,13 +215,14 @@ static void __rds_conn_path_init(struct rds_connection *conn,
 	conn->c_trans = trans;
 
 	init_waitqueue_head(&conn->c_hs_waitq);
-	for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+	for (i = 0; i < npaths; i++) {
 		__rds_conn_path_init(conn, &conn->c_path[i],
 				     is_outgoing);
 		conn->c_path[i].cp_index = i;
 	}
 	ret = trans->conn_alloc(conn, gfp);
 	if (ret) {
+		kfree(conn->c_path);
 		kmem_cache_free(rds_conn_slab, conn);
 		conn = ERR_PTR(ret);
 		goto out;
@@ -236,6 +245,7 @@ static void __rds_conn_path_init(struct rds_connection *conn,
 		/* Creating passive conn */
 		if (parent->c_passive) {
 			trans->conn_free(conn->c_path[0].cp_transport_data);
+			kfree(conn->c_path);
 			kmem_cache_free(rds_conn_slab, conn);
 			conn = parent->c_passive;
 		} else {
@@ -252,7 +262,7 @@ static void __rds_conn_path_init(struct rds_connection *conn,
 			struct rds_conn_path *cp;
 			int i;
 
-			for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+			for (i = 0; i < npaths; i++) {
 				cp = &conn->c_path[i];
 				/* The ->conn_alloc invocation may have
 				 * allocated resource for all paths, so all
@@ -261,6 +271,7 @@ static void __rds_conn_path_init(struct rds_connection *conn,
 				if (cp->cp_transport_data)
 					trans->conn_free(cp->cp_transport_data);
 			}
+			kfree(conn->c_path);
 			kmem_cache_free(rds_conn_slab, conn);
 			conn = found;
 		} else {
@@ -407,6 +418,7 @@ void rds_conn_destroy(struct rds_connection *conn)
 	unsigned long flags;
 	int i;
 	struct rds_conn_path *cp;
+	int npaths = (conn->c_trans->t_mp_capable ? RDS_MPATH_WORKERS : 1);
 
 	rdsdebug("freeing conn %p for %pI4 -> "
 		 "%pI4\n", conn, &conn->c_laddr,
@@ -420,7 +432,7 @@ void rds_conn_destroy(struct rds_connection *conn)
 	synchronize_rcu();
 
 	/* shut the connection down */
-	for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+	for (i = 0; i < npaths; i++) {
 		cp = &conn->c_path[i];
 		rds_conn_path_destroy(cp);
 		BUG_ON(!list_empty(&cp->cp_retrans));
@@ -434,6 +446,7 @@ void rds_conn_destroy(struct rds_connection *conn)
 	rds_cong_remove_conn(conn);
 
 	put_net(conn->c_net);
+	kfree(conn->c_path);
 	kmem_cache_free(rds_conn_slab, conn);
 
 	spin_lock_irqsave(&rds_conn_lock, flags);
@@ -464,8 +477,12 @@ static void rds_conn_message_info(struct socket *sock, unsigned int len,
 	     i++, head++) {
 		hlist_for_each_entry_rcu(conn, head, c_hash_node) {
 			struct rds_conn_path *cp;
+			int npaths;
+
+			npaths = (conn->c_trans->t_mp_capable ?
+				 RDS_MPATH_WORKERS : 1);
 
-			for (j = 0; j < RDS_MPATH_WORKERS; j++) {
+			for (j = 0; j < npaths; j++) {
 				cp = &conn->c_path[j];
 				if (want_send)
 					list = &cp->cp_send_queue;
@@ -486,8 +503,6 @@ static void rds_conn_message_info(struct socket *sock, unsigned int len,
 				}
 
 				spin_unlock_irqrestore(&cp->cp_lock, flags);
-				if (!conn->c_trans->t_mp_capable)
-					break;
 			}
 		}
 	}
@@ -571,15 +586,16 @@ static void rds_walk_conn_path_info(struct socket *sock, unsigned int len,
 	     i++, head++) {
 		hlist_for_each_entry_rcu(conn, head, c_hash_node) {
 			struct rds_conn_path *cp;
+			int npaths;
 
-			for (j = 0; j < RDS_MPATH_WORKERS; j++) {
+			npaths = (conn->c_trans->t_mp_capable ?
+				 RDS_MPATH_WORKERS : 1);
+			for (j = 0; j < npaths; j++) {
 				cp = &conn->c_path[j];
 
 				/* XXX no cp_lock usage.. */
 				if (!visitor(cp, buffer))
 					continue;
-				if (!conn->c_trans->t_mp_capable)
-					break;
 			}
 
 			/* We copy as much as we can fit in the buffer,
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 3382695..2e0315b 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -154,7 +154,7 @@ struct rds_connection {
 	struct list_head	c_map_item;
 	unsigned long		c_map_queued;
 
-	struct rds_conn_path	c_path[RDS_MPATH_WORKERS];
+	struct rds_conn_path	*c_path;
 	wait_queue_head_t	c_hs_waitq; /* handshake waitq */
 
 	u32			c_my_gen_num;
-- 
1.7.1
