From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 4/6] RDS: push FMR pool flush work to its own worker
Date: Tue, 25 Aug 2015 12:02:01 -0700
Message-ID: <1440529323-4171-5-git-send-email-santosh.shilimkar@oracle.com>
References: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RDS FMR flush operation and also it races with connect/reconect
which happes a lot with RDS. FMR flush being on common rds_wq aggrevates
the problem. Lets push RDS FMR pool flush work to its own worker.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.c      |  9 ++++++++-
 net/rds/ib.h      |  2 ++
 net/rds/ib_rdma.c | 27 ++++++++++++++++++++++++---
 3 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index ba2dffe..b5f7336 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -366,6 +366,7 @@ void rds_ib_exit(void)
 	rds_ib_sysctl_exit();
 	rds_ib_recv_exit();
 	rds_trans_unregister(&rds_ib_transport);
+	rds_ib_fmr_exit();
 }
 
 struct rds_transport rds_ib_transport = {
@@ -401,10 +402,14 @@ int rds_ib_init(void)
 
 	INIT_LIST_HEAD(&rds_ib_devices);
 
-	ret = ib_register_client(&rds_ib_client);
+	ret = rds_ib_fmr_init();
 	if (ret)
 		goto out;
 
+	ret = ib_register_client(&rds_ib_client);
+	if (ret)
+		goto out_fmr_exit;
+
 	ret = rds_ib_sysctl_init();
 	if (ret)
 		goto out_ibreg;
@@ -427,6 +432,8 @@ out_sysctl:
 	rds_ib_sysctl_exit();
 out_ibreg:
 	rds_ib_unregister_client();
+out_fmr_exit:
+	rds_ib_fmr_exit();
 out:
 	return ret;
 }
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 6422c52..9fc95e3 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -313,6 +313,8 @@ void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
 void rds_ib_sync_mr(void *trans_private, int dir);
 void rds_ib_free_mr(void *trans_private, int invalidate);
 void rds_ib_flush_mrs(void);
+int rds_ib_fmr_init(void);
+void rds_ib_fmr_exit(void);
 
 /* ib_recv.c */
 int rds_ib_recv_init(void);
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index a275b7d..2ac78c9 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -83,6 +83,25 @@ struct rds_ib_mr_pool {
 	struct ib_fmr_attr	fmr_attr;
 };
 
+struct workqueue_struct *rds_ib_fmr_wq;
+
+int rds_ib_fmr_init(void)
+{
+	rds_ib_fmr_wq = create_workqueue("rds_fmr_flushd");
+	if (!rds_ib_fmr_wq)
+		return -ENOMEM;
+	return 0;
+}
+
+/* By the time this is called all the IB devices should have been torn down and
+ * had their pools freed.  As each pool is freed its work struct is waited on,
+ * so the pool flushing work queue should be idle by the time we get here.
+ */
+void rds_ib_fmr_exit(void)
+{
+	destroy_workqueue(rds_ib_fmr_wq);
+}
+
 static int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool, int free_all, struct rds_ib_mr **);
 static void rds_ib_teardown_mr(struct rds_ib_mr *ibmr);
 static void rds_ib_mr_pool_flush_worker(struct work_struct *work);
@@ -719,15 +738,17 @@ void rds_ib_free_mr(void *trans_private, int invalidate)
 	/* If we've pinned too many pages, request a flush */
 	if (atomic_read(&pool->free_pinned) >= pool->max_free_pinned ||
 	    atomic_read(&pool->dirty_count) >= pool->max_items / 10)
-		schedule_delayed_work(&pool->flush_worker, 10);
+		queue_delayed_work(rds_ib_fmr_wq, &pool->flush_worker, 10);
 
 	if (invalidate) {
 		if (likely(!in_interrupt())) {
 			rds_ib_flush_mr_pool(pool, 0, NULL);
 		} else {
 			/* We get here if the user created a MR marked
-			 * as use_once and invalidate at the same time. */
-			schedule_delayed_work(&pool->flush_worker, 10);
+			 * as use_once and invalidate at the same time.
+			 */
+			queue_delayed_work(rds_ib_fmr_wq,
+					   &pool->flush_worker, 10);
 		}
 	}
 
-- 
1.9.1
