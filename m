From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 06/15] drivers, net, mlx5: convert mlx5_cq.refcount from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:40 +0300
Message-ID: <1508484229-19706-7-git-send-email-elena.reshetova@intel.com>
References: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-rdma@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-ppp@vger.kernel.org,
        ganeshgr@chelsio.com, nbd@openwrt.org, john@phrozen.org,
        sean.wang@mediatek.com, matthias.bgg@gmail.com,
        yishaih@mellanox.com, saeedm@mellanox.com, matanb@mellanox.com,
        tariqt@mellanox.com, leonro@mellanox.com,
        ajk@comnets.uni-bremen.de, paulus@samba.org, zbr@ioremap.net,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable mlx5_cq.refcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cq.c | 16 ++++++++--------
 include/linux/mlx5/cq.h                      |  4 ++--
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cq.c b/drivers/net/ethernet/mellanox/mlx5/core/cq.c
index 336d473..1016e05 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cq.c
@@ -58,7 +58,7 @@ void mlx5_cq_tasklet_cb(unsigned long data)
 				 tasklet_ctx.list) {
 		list_del_init(&mcq->tasklet_ctx.list);
 		mcq->tasklet_ctx.comp(mcq);
-		if (atomic_dec_and_test(&mcq->refcount))
+		if (refcount_dec_and_test(&mcq->refcount))
 			complete(&mcq->free);
 		if (time_after(jiffies, end))
 			break;
@@ -80,7 +80,7 @@ static void mlx5_add_cq_to_tasklet(struct mlx5_core_cq *cq)
 	 * still arrive.
 	 */
 	if (list_empty_careful(&cq->tasklet_ctx.list)) {
-		atomic_inc(&cq->refcount);
+		refcount_inc(&cq->refcount);
 		list_add_tail(&cq->tasklet_ctx.list, &tasklet_ctx->list);
 	}
 	spin_unlock_irqrestore(&tasklet_ctx->lock, flags);
@@ -94,7 +94,7 @@ void mlx5_cq_completion(struct mlx5_core_dev *dev, u32 cqn)
 	spin_lock(&table->lock);
 	cq = radix_tree_lookup(&table->tree, cqn);
 	if (likely(cq))
-		atomic_inc(&cq->refcount);
+		refcount_inc(&cq->refcount);
 	spin_unlock(&table->lock);
 
 	if (!cq) {
@@ -106,7 +106,7 @@ void mlx5_cq_completion(struct mlx5_core_dev *dev, u32 cqn)
 
 	cq->comp(cq);
 
-	if (atomic_dec_and_test(&cq->refcount))
+	if (refcount_dec_and_test(&cq->refcount))
 		complete(&cq->free);
 }
 
@@ -119,7 +119,7 @@ void mlx5_cq_event(struct mlx5_core_dev *dev, u32 cqn, int event_type)
 
 	cq = radix_tree_lookup(&table->tree, cqn);
 	if (cq)
-		atomic_inc(&cq->refcount);
+		refcount_inc(&cq->refcount);
 
 	spin_unlock(&table->lock);
 
@@ -130,7 +130,7 @@ void mlx5_cq_event(struct mlx5_core_dev *dev, u32 cqn, int event_type)
 
 	cq->event(cq, event_type);
 
-	if (atomic_dec_and_test(&cq->refcount))
+	if (refcount_dec_and_test(&cq->refcount))
 		complete(&cq->free);
 }
 
@@ -159,7 +159,7 @@ int mlx5_core_create_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
 	cq->cqn = MLX5_GET(create_cq_out, out, cqn);
 	cq->cons_index = 0;
 	cq->arm_sn     = 0;
-	atomic_set(&cq->refcount, 1);
+	refcount_set(&cq->refcount, 1);
 	init_completion(&cq->free);
 	if (!cq->comp)
 		cq->comp = mlx5_add_cq_to_tasklet;
@@ -222,7 +222,7 @@ int mlx5_core_destroy_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq)
 	synchronize_irq(cq->irqn);
 
 	mlx5_debug_cq_remove(dev, cq);
-	if (atomic_dec_and_test(&cq->refcount))
+	if (refcount_dec_and_test(&cq->refcount))
 		complete(&cq->free);
 	wait_for_completion(&cq->free);
 
diff --git a/include/linux/mlx5/cq.h b/include/linux/mlx5/cq.h
index 9589884..6a57ec2 100644
--- a/include/linux/mlx5/cq.h
+++ b/include/linux/mlx5/cq.h
@@ -35,7 +35,7 @@
 
 #include <rdma/ib_verbs.h>
 #include <linux/mlx5/driver.h>
-
+#include <linux/refcount.h>
 
 struct mlx5_core_cq {
 	u32			cqn;
@@ -43,7 +43,7 @@ struct mlx5_core_cq {
 	__be32		       *set_ci_db;
 	__be32		       *arm_db;
 	struct mlx5_uars_page  *uar;
-	atomic_t		refcount;
+	refcount_t		refcount;
 	struct completion	free;
 	unsigned		vector;
 	unsigned int		irqn;
-- 
2.7.4
