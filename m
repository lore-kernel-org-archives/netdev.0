From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 2/3] RDS: Rewrite connection cleanup, fixing oops on rmmod
Date: Wed,  1 Apr 2009 11:20:19 -0700
Message-ID: <1238610020-30361-3-git-send-email-andy.grover@oracle.com>
References: <1238610020-30361-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:53349 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756981AbZDASUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 14:20:39 -0400
Received: from acsinet13.oracle.com (acsinet13.oracle.com [141.146.126.235])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n31INki0014206
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 1 Apr 2009 18:23:48 GMT
In-Reply-To: <1238610020-30361-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a bug where a connection was unexpectedly
not on *any* list while being destroyed. It also
cleans up some code duplication and regularizes some
function names.

* Grab appropriate lock in conn_free() and explain in comment
* Ensure via locking that a conn is never not on either
  a dev's list or the nodev list
* Add rds_xx_remove_conn() to match rds_xx_add_conn()
* Make rds_xx_add_conn() return void
* Rename remove_{,nodev_}conns() to
  destroy_{,nodev_}conns() and unify their implementation
  in a helper function
* Document lock ordering as nodev conn_lock before
  dev_conn_lock

Reported-by: Yosef Etigin <yosefe@voltaire.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib.c      |    5 +++--
 net/rds/ib.h      |   14 +++++++++++---
 net/rds/ib_cm.c   |   34 +++++++++++++++++++---------------
 net/rds/ib_rdma.c |   43 +++++++++++++++++++++----------------------
 net/rds/iw.c      |    5 +++--
 net/rds/iw.h      |   14 +++++++++++---
 net/rds/iw_cm.c   |   35 +++++++++++++++++++----------------
 net/rds/iw_rdma.c |   44 ++++++++++++++++++++++----------------------
 8 files changed, 109 insertions(+), 85 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 06a7b79..4933b38 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -51,6 +51,7 @@ MODULE_PARM_DESC(fmr_message_size, " Max size of a RDMA transfer");
 
 struct list_head rds_ib_devices;
 
+/* NOTE: if also grabbing ibdev lock, grab this first */
 DEFINE_SPINLOCK(ib_nodev_conns_lock);
 LIST_HEAD(ib_nodev_conns);
 
@@ -137,7 +138,7 @@ void rds_ib_remove_one(struct ib_device *device)
 		kfree(i_ipaddr);
 	}
 
-	rds_ib_remove_conns(rds_ibdev);
+	rds_ib_destroy_conns(rds_ibdev);
 
 	if (rds_ibdev->mr_pool)
 		rds_ib_destroy_mr_pool(rds_ibdev->mr_pool);
@@ -249,7 +250,7 @@ static int rds_ib_laddr_check(__be32 addr)
 void rds_ib_exit(void)
 {
 	rds_info_deregister_func(RDS_INFO_IB_CONNECTIONS, rds_ib_ic_info);
-	rds_ib_remove_nodev_conns();
+	rds_ib_destroy_nodev_conns();
 	ib_unregister_client(&rds_ib_client);
 	rds_ib_sysctl_exit();
 	rds_ib_recv_exit();
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 8be563a..c08ffff 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -267,9 +267,17 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn,
 
 /* ib_rdma.c */
 int rds_ib_update_ipaddr(struct rds_ib_device *rds_ibdev, __be32 ipaddr);
-int rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn);
-void rds_ib_remove_nodev_conns(void);
-void rds_ib_remove_conns(struct rds_ib_device *rds_ibdev);
+void rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn);
+void rds_ib_remove_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn);
+void __rds_ib_destroy_conns(struct list_head *list, spinlock_t *list_lock);
+static inline void rds_ib_destroy_nodev_conns(void)
+{
+	__rds_ib_destroy_conns(&ib_nodev_conns, &ib_nodev_conns_lock);
+}
+static inline void rds_ib_destroy_conns(struct rds_ib_device *rds_ibdev)
+{
+	__rds_ib_destroy_conns(&rds_ibdev->conn_list, &rds_ibdev->spinlock);
+}
 struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *);
 void rds_ib_get_mr_info(struct rds_ib_device *rds_ibdev, struct rds_info_rdma_connection *iinfo);
 void rds_ib_destroy_mr_pool(struct rds_ib_mr_pool *);
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 0532237..889ab04 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -126,9 +126,7 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 	err = rds_ib_update_ipaddr(rds_ibdev, conn->c_laddr);
 	if (err)
 		printk(KERN_ERR "rds_ib_update_ipaddr failed (%d)\n", err);
-	err = rds_ib_add_conn(rds_ibdev, conn);
-	if (err)
-		printk(KERN_ERR "rds_ib_add_conn failed (%d)\n", err);
+	rds_ib_add_conn(rds_ibdev, conn);
 
 	/* If the peer gave us the last packet it saw, process this as if
 	 * we had received a regular ACK. */
@@ -616,18 +614,8 @@ void rds_ib_conn_shutdown(struct rds_connection *conn)
 		/*
 		 * Move connection back to the nodev list.
 		 */
-		if (ic->rds_ibdev) {
-
-			spin_lock_irq(&ic->rds_ibdev->spinlock);
-			BUG_ON(list_empty(&ic->ib_node));
-			list_del(&ic->ib_node);
-			spin_unlock_irq(&ic->rds_ibdev->spinlock);
-
-			spin_lock_irq(&ib_nodev_conns_lock);
-			list_add_tail(&ic->ib_node, &ib_nodev_conns);
-			spin_unlock_irq(&ib_nodev_conns_lock);
-			ic->rds_ibdev = NULL;
-		}
+		if (ic->rds_ibdev)
+			rds_ib_remove_conn(ic->rds_ibdev, conn);
 
 		ic->i_cm_id = NULL;
 		ic->i_pd = NULL;
@@ -701,11 +689,27 @@ int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 	return 0;
 }
 
+/*
+ * Free a connection. Connection must be shut down and not set for reconnect.
+ */
 void rds_ib_conn_free(void *arg)
 {
 	struct rds_ib_connection *ic = arg;
+	spinlock_t	*lock_ptr;
+
 	rdsdebug("ic %p\n", ic);
+
+	/*
+	 * Conn is either on a dev's list or on the nodev list.
+	 * A race with shutdown() or connect() would cause problems
+	 * (since rds_ibdev would change) but that should never happen.
+	 */
+	lock_ptr = ic->rds_ibdev ? &ic->rds_ibdev->spinlock : &ib_nodev_conns_lock;
+
+	spin_lock_irq(lock_ptr);
 	list_del(&ic->ib_node);
+	spin_unlock_irq(lock_ptr);
+
 	kfree(ic);
 }
 
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 69a6289..81033af 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -139,7 +139,7 @@ int rds_ib_update_ipaddr(struct rds_ib_device *rds_ibdev, __be32 ipaddr)
 	return rds_ib_add_ipaddr(rds_ibdev, ipaddr);
 }
 
-int rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn)
+void rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn)
 {
 	struct rds_ib_connection *ic = conn->c_transport_data;
 
@@ -148,45 +148,44 @@ int rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn
 	BUG_ON(list_empty(&ib_nodev_conns));
 	BUG_ON(list_empty(&ic->ib_node));
 	list_del(&ic->ib_node);
-	spin_unlock_irq(&ib_nodev_conns_lock);
 
 	spin_lock_irq(&rds_ibdev->spinlock);
 	list_add_tail(&ic->ib_node, &rds_ibdev->conn_list);
 	spin_unlock_irq(&rds_ibdev->spinlock);
+	spin_unlock_irq(&ib_nodev_conns_lock);
 
 	ic->rds_ibdev = rds_ibdev;
-
-	return 0;
 }
 
-void rds_ib_remove_nodev_conns(void)
+void rds_ib_remove_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn)
 {
-	struct rds_ib_connection *ic, *_ic;
-	LIST_HEAD(tmp_list);
+	struct rds_ib_connection *ic = conn->c_transport_data;
 
-	/* avoid calling conn_destroy with irqs off */
-	spin_lock_irq(&ib_nodev_conns_lock);
-	list_splice(&ib_nodev_conns, &tmp_list);
-	INIT_LIST_HEAD(&ib_nodev_conns);
-	spin_unlock_irq(&ib_nodev_conns_lock);
+	/* place conn on nodev_conns_list */
+	spin_lock(&ib_nodev_conns_lock);
 
-	list_for_each_entry_safe(ic, _ic, &tmp_list, ib_node) {
-		if (ic->conn->c_passive)
-			rds_conn_destroy(ic->conn->c_passive);
-		rds_conn_destroy(ic->conn);
-	}
+	spin_lock_irq(&rds_ibdev->spinlock);
+	BUG_ON(list_empty(&ic->ib_node));
+	list_del(&ic->ib_node);
+	spin_unlock_irq(&rds_ibdev->spinlock);
+
+	list_add_tail(&ic->ib_node, &ib_nodev_conns);
+
+	spin_unlock(&ib_nodev_conns_lock);
+
+	ic->rds_ibdev = NULL;
 }
 
-void rds_ib_remove_conns(struct rds_ib_device *rds_ibdev)
+void __rds_ib_destroy_conns(struct list_head *list, spinlock_t *list_lock)
 {
 	struct rds_ib_connection *ic, *_ic;
 	LIST_HEAD(tmp_list);
 
 	/* avoid calling conn_destroy with irqs off */
-	spin_lock_irq(&rds_ibdev->spinlock);
-	list_splice(&rds_ibdev->conn_list, &tmp_list);
-	INIT_LIST_HEAD(&rds_ibdev->conn_list);
-	spin_unlock_irq(&rds_ibdev->spinlock);
+	spin_lock_irq(list_lock);
+	list_splice(list, &tmp_list);
+	INIT_LIST_HEAD(list);
+	spin_unlock_irq(list_lock);
 
 	list_for_each_entry_safe(ic, _ic, &tmp_list, ib_node) {
 		if (ic->conn->c_passive)
diff --git a/net/rds/iw.c b/net/rds/iw.c
index 1b56905..b732efb 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -51,6 +51,7 @@ MODULE_PARM_DESC(fastreg_message_size, " Max size of a RDMA transfer (fastreg MR
 
 struct list_head rds_iw_devices;
 
+/* NOTE: if also grabbing iwdev lock, grab this first */
 DEFINE_SPINLOCK(iw_nodev_conns_lock);
 LIST_HEAD(iw_nodev_conns);
 
@@ -145,7 +146,7 @@ void rds_iw_remove_one(struct ib_device *device)
 	}
 	spin_unlock_irq(&rds_iwdev->spinlock);
 
-	rds_iw_remove_conns(rds_iwdev);
+	rds_iw_destroy_conns(rds_iwdev);
 
 	if (rds_iwdev->mr_pool)
 		rds_iw_destroy_mr_pool(rds_iwdev->mr_pool);
@@ -258,7 +259,7 @@ static int rds_iw_laddr_check(__be32 addr)
 void rds_iw_exit(void)
 {
 	rds_info_deregister_func(RDS_INFO_IWARP_CONNECTIONS, rds_iw_ic_info);
-	rds_iw_remove_nodev_conns();
+	rds_iw_destroy_nodev_conns();
 	ib_unregister_client(&rds_iw_client);
 	rds_iw_sysctl_exit();
 	rds_iw_recv_exit();
diff --git a/net/rds/iw.h b/net/rds/iw.h
index 0ddda34..70eb948 100644
--- a/net/rds/iw.h
+++ b/net/rds/iw.h
@@ -294,9 +294,17 @@ void rds_iw_cm_connect_complete(struct rds_connection *conn,
 
 /* ib_rdma.c */
 int rds_iw_update_cm_id(struct rds_iw_device *rds_iwdev, struct rdma_cm_id *cm_id);
-int rds_iw_add_conn(struct rds_iw_device *rds_iwdev, struct rds_connection *conn);
-void rds_iw_remove_nodev_conns(void);
-void rds_iw_remove_conns(struct rds_iw_device *rds_iwdev);
+void rds_iw_add_conn(struct rds_iw_device *rds_iwdev, struct rds_connection *conn);
+void rds_iw_remove_conn(struct rds_iw_device *rds_iwdev, struct rds_connection *conn);
+void __rds_iw_destroy_conns(struct list_head *list, spinlock_t *list_lock);
+static inline void rds_iw_destroy_nodev_conns(void)
+{
+	__rds_iw_destroy_conns(&iw_nodev_conns, &iw_nodev_conns_lock);
+}
+static inline void rds_iw_destroy_conns(struct rds_iw_device *rds_iwdev)
+{
+	__rds_iw_destroy_conns(&rds_iwdev->conn_list, &rds_iwdev->spinlock);
+}
 struct rds_iw_mr_pool *rds_iw_create_mr_pool(struct rds_iw_device *);
 void rds_iw_get_mr_info(struct rds_iw_device *rds_iwdev, struct rds_info_rdma_connection *iinfo);
 void rds_iw_destroy_mr_pool(struct rds_iw_mr_pool *);
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index 57ecb3d..0ffaa3e 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -86,9 +86,7 @@ void rds_iw_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 	err = rds_iw_update_cm_id(rds_iwdev, ic->i_cm_id);
 	if (err)
 		printk(KERN_ERR "rds_iw_update_ipaddr failed (%d)\n", err);
-	err = rds_iw_add_conn(rds_iwdev, conn);
-	if (err)
-		printk(KERN_ERR "rds_iw_add_conn failed (%d)\n", err);
+	rds_iw_add_conn(rds_iwdev, conn);
 
 	/* If the peer gave us the last packet it saw, process this as if
 	 * we had received a regular ACK. */
@@ -637,19 +635,8 @@ void rds_iw_conn_shutdown(struct rds_connection *conn)
 		 * 	Move connection back to the nodev list.
 		 * 	Remove cm_id from the device cm_id list.
 		 */
-		if (ic->rds_iwdev) {
-
-			spin_lock_irq(&ic->rds_iwdev->spinlock);
-			BUG_ON(list_empty(&ic->iw_node));
-			list_del(&ic->iw_node);
-			spin_unlock_irq(&ic->rds_iwdev->spinlock);
-
-			spin_lock_irq(&iw_nodev_conns_lock);
-			list_add_tail(&ic->iw_node, &iw_nodev_conns);
-			spin_unlock_irq(&iw_nodev_conns_lock);
-			rds_iw_remove_cm_id(ic->rds_iwdev, ic->i_cm_id);
-			ic->rds_iwdev = NULL;
-		}
+		if (ic->rds_iwdev)
+			rds_iw_remove_conn(ic->rds_iwdev, conn);
 
 		rdma_destroy_id(ic->i_cm_id);
 
@@ -726,11 +713,27 @@ int rds_iw_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 	return 0;
 }
 
+/*
+ * Free a connection. Connection must be shut down and not set for reconnect.
+ */
 void rds_iw_conn_free(void *arg)
 {
 	struct rds_iw_connection *ic = arg;
+	spinlock_t	*lock_ptr;
+
 	rdsdebug("ic %p\n", ic);
+
+	/*
+	 * Conn is either on a dev's list or on the nodev list.
+	 * A race with shutdown() or connect() would cause problems
+	 * (since rds_iwdev would change) but that should never happen.
+	 */
+	lock_ptr = ic->rds_iwdev ? &ic->rds_iwdev->spinlock : &iw_nodev_conns_lock;
+
+	spin_lock_irq(lock_ptr);
 	list_del(&ic->iw_node);
+	spin_unlock_irq(lock_ptr);
+
 	kfree(ic);
 }
 
diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 1c02a8f..dcdb37d 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -196,7 +196,7 @@ int rds_iw_update_cm_id(struct rds_iw_device *rds_iwdev, struct rdma_cm_id *cm_i
 	return rds_iw_add_cm_id(rds_iwdev, cm_id);
 }
 
-int rds_iw_add_conn(struct rds_iw_device *rds_iwdev, struct rds_connection *conn)
+void rds_iw_add_conn(struct rds_iw_device *rds_iwdev, struct rds_connection *conn)
 {
 	struct rds_iw_connection *ic = conn->c_transport_data;
 
@@ -205,45 +205,45 @@ int rds_iw_add_conn(struct rds_iw_device *rds_iwdev, struct rds_connection *conn
 	BUG_ON(list_empty(&iw_nodev_conns));
 	BUG_ON(list_empty(&ic->iw_node));
 	list_del(&ic->iw_node);
-	spin_unlock_irq(&iw_nodev_conns_lock);
 
 	spin_lock_irq(&rds_iwdev->spinlock);
 	list_add_tail(&ic->iw_node, &rds_iwdev->conn_list);
 	spin_unlock_irq(&rds_iwdev->spinlock);
+	spin_unlock_irq(&iw_nodev_conns_lock);
 
 	ic->rds_iwdev = rds_iwdev;
-
-	return 0;
 }
 
-void rds_iw_remove_nodev_conns(void)
+void rds_iw_remove_conn(struct rds_iw_device *rds_iwdev, struct rds_connection *conn)
 {
-	struct rds_iw_connection *ic, *_ic;
-	LIST_HEAD(tmp_list);
+	struct rds_iw_connection *ic = conn->c_transport_data;
 
-	/* avoid calling conn_destroy with irqs off */
-	spin_lock_irq(&iw_nodev_conns_lock);
-	list_splice(&iw_nodev_conns, &tmp_list);
-	INIT_LIST_HEAD(&iw_nodev_conns);
-	spin_unlock_irq(&iw_nodev_conns_lock);
+	/* place conn on nodev_conns_list */
+	spin_lock(&iw_nodev_conns_lock);
 
-	list_for_each_entry_safe(ic, _ic, &tmp_list, iw_node) {
-		if (ic->conn->c_passive)
-			rds_conn_destroy(ic->conn->c_passive);
-		rds_conn_destroy(ic->conn);
-	}
+	spin_lock_irq(&rds_iwdev->spinlock);
+	BUG_ON(list_empty(&ic->iw_node));
+	list_del(&ic->iw_node);
+	spin_unlock_irq(&rds_iwdev->spinlock);
+
+	list_add_tail(&ic->iw_node, &iw_nodev_conns);
+
+	spin_unlock(&iw_nodev_conns_lock);
+
+	rds_iw_remove_cm_id(ic->rds_iwdev, ic->i_cm_id);
+	ic->rds_iwdev = NULL;
 }
 
-void rds_iw_remove_conns(struct rds_iw_device *rds_iwdev)
+void __rds_iw_destroy_conns(struct list_head *list, spinlock_t *list_lock)
 {
 	struct rds_iw_connection *ic, *_ic;
 	LIST_HEAD(tmp_list);
 
 	/* avoid calling conn_destroy with irqs off */
-	spin_lock_irq(&rds_iwdev->spinlock);
-	list_splice(&rds_iwdev->conn_list, &tmp_list);
-	INIT_LIST_HEAD(&rds_iwdev->conn_list);
-	spin_unlock_irq(&rds_iwdev->spinlock);
+	spin_lock_irq(list_lock);
+	list_splice(list, &tmp_list);
+	INIT_LIST_HEAD(list);
+	spin_unlock_irq(list_lock);
 
 	list_for_each_entry_safe(ic, _ic, &tmp_list, iw_node) {
 		if (ic->conn->c_passive)
-- 
1.5.6.3

