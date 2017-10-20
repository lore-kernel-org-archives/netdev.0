From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 03/15] drivers, net, mlx4: convert mlx4_cq.refcount from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:37 +0300
Message-ID: <1508484229-19706-4-git-send-email-elena.reshetova@intel.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:42529 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752247AbdJTHYP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Oct 2017 03:24:15 -0400
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

The variable mlx4_cq.refcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/net/ethernet/mellanox/mlx4/cq.c | 8 ++++----
 include/linux/mlx4/device.h             | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 72eb50c..d8e9a32 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -69,7 +69,7 @@ void mlx4_cq_tasklet_cb(unsigned long data)
 	list_for_each_entry_safe(mcq, temp, &ctx->process_list, tasklet_ctx.list) {
 		list_del_init(&mcq->tasklet_ctx.list);
 		mcq->tasklet_ctx.comp(mcq);
-		if (atomic_dec_and_test(&mcq->refcount))
+		if (refcount_dec_and_test(&mcq->refcount))
 			complete(&mcq->free);
 		if (time_after(jiffies, end))
 			break;
@@ -92,7 +92,7 @@ static void mlx4_add_cq_to_tasklet(struct mlx4_cq *cq)
 	 * still arrive.
 	 */
 	if (list_empty_careful(&cq->tasklet_ctx.list)) {
-		atomic_inc(&cq->refcount);
+		refcount_inc(&cq->refcount);
 		kick = list_empty(&tasklet_ctx->list);
 		list_add_tail(&cq->tasklet_ctx.list, &tasklet_ctx->list);
 		if (kick)
@@ -344,7 +344,7 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent,
 	cq->cons_index = 0;
 	cq->arm_sn     = 1;
 	cq->uar        = uar;
-	atomic_set(&cq->refcount, 1);
+	refcount_set(&cq->refcount, 1);
 	init_completion(&cq->free);
 	cq->comp = mlx4_add_cq_to_tasklet;
 	cq->tasklet_ctx.priv =
@@ -386,7 +386,7 @@ void mlx4_cq_free(struct mlx4_dev *dev, struct mlx4_cq *cq)
 	    priv->eq_table.eq[MLX4_EQ_ASYNC].irq)
 		synchronize_irq(priv->eq_table.eq[MLX4_EQ_ASYNC].irq);
 
-	if (atomic_dec_and_test(&cq->refcount))
+	if (refcount_dec_and_test(&cq->refcount))
 		complete(&cq->free);
 	wait_for_completion(&cq->free);
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b0a57e0..daac2e3 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -40,7 +40,7 @@
 #include <linux/cpu_rmap.h>
 #include <linux/crash_dump.h>
 
-#include <linux/atomic.h>
+#include <linux/refcount.h>
 
 #include <linux/timecounter.h>
 
@@ -751,7 +751,7 @@ struct mlx4_cq {
 	int			cqn;
 	unsigned		vector;
 
-	atomic_t		refcount;
+	refcount_t		refcount;
 	struct completion	free;
 	struct {
 		struct list_head list;
-- 
2.7.4
