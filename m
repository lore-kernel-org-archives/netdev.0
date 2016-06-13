From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 17/17] RDS: Update rds_conn_destroy to be MP capable
Date: Mon, 13 Jun 2016 09:44:42 -0700
Message-ID: <20a59c8b9be76a9f2a6c2ebd48719a6c68365979.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41044 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161313AbcFMQpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:19 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor rds_conn_destroy() so that the per-path dismantling
is done in rds_conn_path_destroy, and then iterate as needed
over rds_conn_path_destroy().

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |   59 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 39 insertions(+), 20 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index a88d26f..a4b07c8 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -36,7 +36,6 @@
 #include <linux/export.h>
 #include <net/inet_hashtables.h>
 
-#include "rds_single_path.h"
 #include "rds.h"
 #include "loop.h"
 
@@ -364,6 +363,34 @@ void rds_conn_shutdown(struct rds_conn_path *cp)
 	}
 }
 
+/* destroy a single rds_conn_path. rds_conn_destroy() iterates over
+ * all paths using rds_conn_path_destroy()
+ */
+static void rds_conn_path_destroy(struct rds_conn_path *cp)
+{
+	struct rds_message *rm, *rtmp;
+
+	rds_conn_path_drop(cp);
+	flush_work(&cp->cp_down_w);
+
+	/* make sure lingering queued work won't try to ref the conn */
+	cancel_delayed_work_sync(&cp->cp_send_w);
+	cancel_delayed_work_sync(&cp->cp_recv_w);
+
+	/* tear down queued messages */
+	list_for_each_entry_safe(rm, rtmp,
+				 &cp->cp_send_queue,
+				 m_conn_item) {
+		list_del_init(&rm->m_conn_item);
+		BUG_ON(!list_empty(&rm->m_sock_item));
+		rds_message_put(rm);
+	}
+	if (cp->cp_xmit_rm)
+		rds_message_put(cp->cp_xmit_rm);
+
+	cp->cp_conn->c_trans->conn_free(cp->cp_transport_data);
+}
+
 /*
  * Stop and free a connection.
  *
@@ -373,7 +400,6 @@ void rds_conn_shutdown(struct rds_conn_path *cp)
  */
 void rds_conn_destroy(struct rds_connection *conn)
 {
-	struct rds_message *rm, *rtmp;
 	unsigned long flags;
 
 	rdsdebug("freeing conn %p for %pI4 -> "
@@ -387,25 +413,19 @@ void rds_conn_destroy(struct rds_connection *conn)
 	synchronize_rcu();
 
 	/* shut the connection down */
-	rds_conn_drop(conn);
-	flush_work(&conn->c_down_w);
-
-	/* make sure lingering queued work won't try to ref the conn */
-	cancel_delayed_work_sync(&conn->c_send_w);
-	cancel_delayed_work_sync(&conn->c_recv_w);
+	if (!conn->c_trans->t_mp_capable) {
+		rds_conn_path_destroy(&conn->c_path[0]);
+		BUG_ON(!list_empty(&conn->c_path[0].cp_retrans));
+	} else {
+		int i;
+		struct rds_conn_path *cp;
 
-	/* tear down queued messages */
-	list_for_each_entry_safe(rm, rtmp,
-				 &conn->c_send_queue,
-				 m_conn_item) {
-		list_del_init(&rm->m_conn_item);
-		BUG_ON(!list_empty(&rm->m_sock_item));
-		rds_message_put(rm);
+		for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+			cp = &conn->c_path[i];
+			rds_conn_path_destroy(cp);
+			BUG_ON(!list_empty(&cp->cp_retrans));
+		}
 	}
-	if (conn->c_xmit_rm)
-		rds_message_put(conn->c_xmit_rm);
-
-	conn->c_trans->conn_free(conn->c_transport_data);
 
 	/*
 	 * The congestion maps aren't freed up here.  They're
@@ -414,7 +434,6 @@ void rds_conn_destroy(struct rds_connection *conn)
 	 */
 	rds_cong_remove_conn(conn);
 
-	BUG_ON(!list_empty(&conn->c_retrans));
 	kmem_cache_free(rds_conn_slab, conn);
 
 	spin_lock_irqsave(&rds_conn_lock, flags);
-- 
1.7.1
