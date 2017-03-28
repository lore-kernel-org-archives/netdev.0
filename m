From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 03/16] drivers, net,
 mlx4: convert mlx4_cq.refcount from atomic_t to refcount_t
Date: Tue, 28 Mar 2017 11:56:30 +0300
Message-ID: <1490691403-4016-4-git-send-email-elena.reshetova@intel.com>
References: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, matanb@mellanox.com, paulus@samba.org,
 Elena Reshetova <elena.reshetova@intel.com>, nbd@openwrt.org,
 linux-rdma@vger.kernel.org, saeedm@mellanox.com, ganeshgr@chelsio.com,
 Hans Liljestrand <ishkamiel@gmail.com>, David Windsor <dwindsor@gmail.com>,
 keescook@chromium.org, j@w1.fi, ajk@comnets.uni-bremen.de, leonro@mellanox.com,
 matthias.bgg@gmail.com, linux-hams@vger.kernel.org, kvalo@codeaurora.org,
 blogic@openwrt.org, linux-arm-kernel@lists.infradead.org,
 linux-ppp@vger.kernel.org, yishaih@mellanox.com,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 gregkh@linuxfoundation.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/cq.c | 8 ++++----
 include/linux/mlx4/device.h             | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index fa6d235..c58e8b7 100644
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
@@ -343,7 +343,7 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent,
 	cq->cons_index = 0;
 	cq->arm_sn     = 1;
 	cq->uar        = uar;
-	atomic_set(&cq->refcount, 1);
+	refcount_set(&cq->refcount, 1);
 	init_completion(&cq->free);
 	cq->comp = mlx4_add_cq_to_tasklet;
 	cq->tasklet_ctx.priv =
@@ -385,7 +385,7 @@ void mlx4_cq_free(struct mlx4_dev *dev, struct mlx4_cq *cq)
 	    priv->eq_table.eq[MLX4_EQ_ASYNC].irq)
 		synchronize_irq(priv->eq_table.eq[MLX4_EQ_ASYNC].irq);
 
-	if (atomic_dec_and_test(&cq->refcount))
+	if (refcount_dec_and_test(&cq->refcount))
 		complete(&cq->free);
 	wait_for_completion(&cq->free);
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 7e66e4f..5fea001 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -40,7 +40,7 @@
 #include <linux/cpu_rmap.h>
 #include <linux/crash_dump.h>
 
-#include <linux/atomic.h>
+#include <linux/refcount.h>
 
 #include <linux/timecounter.h>
 
@@ -738,7 +738,7 @@ struct mlx4_cq {
 	int			cqn;
 	unsigned		vector;
 
-	atomic_t		refcount;
+	refcount_t		refcount;
 	struct completion	free;
 	struct {
 		struct list_head list;
-- 
2.7.4
