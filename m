From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 3/5] RDS: Fix panic on unload
Date: Fri, 30 Oct 2009 11:51:55 -0700
Message-ID: <1256928717-17757-3-git-send-email-andy.grover@oracle.com>
References: <1256928717-17757-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:65093 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756574AbZJ3SxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 14:53:08 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9UIqj1f001899
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 18:52:46 GMT
In-Reply-To: <1256928717-17757-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove explicit destruction of passive connection when destroying
active end of the connection. The passive end is also on the
device's connection list, and will thus be cleaned up properly.
Panic was caused by trying to clean it up twice.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_rdma.c |    5 +----
 net/rds/iw_rdma.c |    5 +----
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index ef3ab5b..c5e9165 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -187,11 +187,8 @@ void __rds_ib_destroy_conns(struct list_head *list, spinlock_t *list_lock)
 	INIT_LIST_HEAD(list);
 	spin_unlock_irq(list_lock);
 
-	list_for_each_entry_safe(ic, _ic, &tmp_list, ib_node) {
-		if (ic->conn->c_passive)
-			rds_conn_destroy(ic->conn->c_passive);
+	list_for_each_entry_safe(ic, _ic, &tmp_list, ib_node)
 		rds_conn_destroy(ic->conn);
-	}
 }
 
 struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_ibdev)
diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index de4a1b1..b25d785 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -245,11 +245,8 @@ void __rds_iw_destroy_conns(struct list_head *list, spinlock_t *list_lock)
 	INIT_LIST_HEAD(list);
 	spin_unlock_irq(list_lock);
 
-	list_for_each_entry_safe(ic, _ic, &tmp_list, iw_node) {
-		if (ic->conn->c_passive)
-			rds_conn_destroy(ic->conn->c_passive);
+	list_for_each_entry_safe(ic, _ic, &tmp_list, iw_node)
 		rds_conn_destroy(ic->conn);
-	}
 }
 
 static void rds_iw_set_scatterlist(struct rds_iw_scatterlist *sg,
-- 
1.6.3.3

