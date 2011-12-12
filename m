From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V1 09/21] mlx4_core: cq modifications for SRIOV
Date: Mon, 12 Dec 2011 16:44:20 +0200
Message-ID: <4EE61344.4050604@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>

CQs are resources which are allocated and tracked by the PF driver.
In multifunction mode, the allocation and icm mapping is done in
the resource tracker (later patch in this sequence).

To accomplish this, we have "work" functions whose names start with
"__", and "request" functions (same name, no __). If we are operating
in multifunction mode, the request function actually results in
comm-channel commands being sent (ALLOC_RES or FREE_RES).
The PF-driver comm-channel handler will ultimately invoke the
"work" (__) function and return the result.

If we are not in multifunction mode, the "work" handler is invoked
immediately.

Signed-off-by: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/cq.c |  116 +++++++++++++++++++++++-------
 1 files changed, 89 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index ebd0eb2..dd9211f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -34,9 +34,9 @@
  * SOFTWARE.
  */
 
+#include <linux/init.h>
 #include <linux/hardirq.h>
 #include <linux/export.h>
-#include <linux/gfp.h>
 
 #include <linux/mlx4/cmd.h>
 #include <linux/mlx4/cq.h>
@@ -81,7 +81,7 @@ void mlx4_cq_completion(struct mlx4_dev *dev, u32 cqn)
 	cq = radix_tree_lookup(&mlx4_priv(dev)->cq_table.tree,
 			       cqn & (dev->caps.num_cqs - 1));
 	if (!cq) {
-		mlx4_warn(dev, "Completion event for bogus CQ %08x\n", cqn);
+		mlx4_dbg(dev, "Completion event for bogus CQ %08x\n", cqn);
 		return;
 	}
 
@@ -117,8 +117,9 @@ void mlx4_cq_event(struct mlx4_dev *dev, u32 cqn, int event_type)
 static int mlx4_SW2HW_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 int cq_num)
 {
-	return mlx4_cmd(dev, mailbox->dma, cq_num, 0, MLX4_CMD_SW2HW_CQ,
-			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+	return mlx4_cmd(dev, mailbox->dma | dev->caps.function, cq_num, 0,
+			MLX4_CMD_SW2HW_CQ, MLX4_CMD_TIME_CLASS_A,
+			MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_MODIFY_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
@@ -131,8 +132,8 @@ static int mlx4_MODIFY_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 static int mlx4_HW2SW_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 int cq_num)
 {
-	return mlx4_cmd_box(dev, 0, mailbox ? mailbox->dma : 0, cq_num,
-			    mailbox ? 0 : 1, MLX4_CMD_HW2SW_CQ,
+	return mlx4_cmd_box(dev, dev->caps.function, mailbox ? mailbox->dma : 0,
+			    cq_num, mailbox ? 0 : 1, MLX4_CMD_HW2SW_CQ,
 			    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 
@@ -188,6 +189,78 @@ int mlx4_cq_resize(struct mlx4_dev *dev, struct mlx4_cq *cq,
 }
 EXPORT_SYMBOL_GPL(mlx4_cq_resize);
 
+static int __mlx4_cq_alloc_icm(struct mlx4_dev *dev, int *cqn)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_cq_table *cq_table = &priv->cq_table;
+	int err;
+
+	*cqn = mlx4_bitmap_alloc(&cq_table->bitmap);
+	if (*cqn == -1)
+		return -ENOMEM;
+
+	err = mlx4_table_get(dev, &cq_table->table, *cqn);
+	if (err)
+		goto err_out;
+
+	err = mlx4_table_get(dev, &cq_table->cmpt_table, *cqn);
+	if (err)
+		goto err_put;
+	return 0;
+
+err_put:
+	mlx4_table_put(dev, &cq_table->table, *cqn);
+
+err_out:
+	mlx4_bitmap_free(&cq_table->bitmap, *cqn);
+	return err;
+}
+
+static int mlx4_cq_alloc_icm(struct mlx4_dev *dev, int *cqn)
+{
+	u64 out_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		err = mlx4_cmd_imm(dev, 0, &out_param, RES_CQ,
+				   RES_OP_RESERVE_AND_MAP, MLX4_CMD_ALLOC_RES,
+				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (err)
+			return err;
+		else {
+			*cqn = get_param_l(&out_param);
+			return 0;
+		}
+	}
+	return __mlx4_cq_alloc_icm(dev, cqn);
+}
+
+static void __mlx4_cq_free_icm(struct mlx4_dev *dev, int cqn)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_cq_table *cq_table = &priv->cq_table;
+
+	mlx4_table_put(dev, &cq_table->cmpt_table, cqn);
+	mlx4_table_put(dev, &cq_table->table, cqn);
+	mlx4_bitmap_free(&cq_table->bitmap, cqn);
+}
+
+static void mlx4_cq_free_icm(struct mlx4_dev *dev, int cqn)
+{
+	u64 in_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&in_param, cqn);
+		err = mlx4_cmd(dev, in_param, RES_CQ, RES_OP_RESERVE_AND_MAP,
+			       MLX4_CMD_FREE_RES,
+			       MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (err)
+			mlx4_warn(dev, "Failed freeing cq:%d\n", cqn);
+	} else
+		__mlx4_cq_free_icm(dev, cqn);
+}
+
 int mlx4_cq_alloc(struct mlx4_dev *dev, int nent, struct mlx4_mtt *mtt,
 		  struct mlx4_uar *uar, u64 db_rec, struct mlx4_cq *cq,
 		  unsigned vector, int collapsed)
@@ -204,23 +277,15 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent, struct mlx4_mtt *mtt,
 
 	cq->vector = vector;
 
-	cq->cqn = mlx4_bitmap_alloc(&cq_table->bitmap);
-	if (cq->cqn == -1)
-		return -ENOMEM;
-
-	err = mlx4_table_get(dev, &cq_table->table, cq->cqn);
-	if (err)
-		goto err_out;
-
-	err = mlx4_table_get(dev, &cq_table->cmpt_table, cq->cqn);
+	err = mlx4_cq_alloc_icm(dev, &cq->cqn);
 	if (err)
-		goto err_put;
+		return err;
 
 	spin_lock_irq(&cq_table->lock);
 	err = radix_tree_insert(&cq_table->tree, cq->cqn, cq);
 	spin_unlock_irq(&cq_table->lock);
 	if (err)
-		goto err_cmpt_put;
+		goto err_icm;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox)) {
@@ -259,14 +324,8 @@ err_radix:
 	radix_tree_delete(&cq_table->tree, cq->cqn);
 	spin_unlock_irq(&cq_table->lock);
 
-err_cmpt_put:
-	mlx4_table_put(dev, &cq_table->cmpt_table, cq->cqn);
-
-err_put:
-	mlx4_table_put(dev, &cq_table->table, cq->cqn);
-
-err_out:
-	mlx4_bitmap_free(&cq_table->bitmap, cq->cqn);
+err_icm:
+	mlx4_cq_free_icm(dev, cq->cqn);
 
 	return err;
 }
@@ -292,8 +351,7 @@ void mlx4_cq_free(struct mlx4_dev *dev, struct mlx4_cq *cq)
 		complete(&cq->free);
 	wait_for_completion(&cq->free);
 
-	mlx4_table_put(dev, &cq_table->table, cq->cqn);
-	mlx4_bitmap_free(&cq_table->bitmap, cq->cqn);
+	mlx4_cq_free_icm(dev, cq->cqn);
 }
 EXPORT_SYMBOL_GPL(mlx4_cq_free);
 
@@ -304,6 +362,8 @@ int mlx4_init_cq_table(struct mlx4_dev *dev)
 
 	spin_lock_init(&cq_table->lock);
 	INIT_RADIX_TREE(&cq_table->tree, GFP_ATOMIC);
+	if (mlx4_is_slave(dev))
+		return 0;
 
 	err = mlx4_bitmap_init(&cq_table->bitmap, dev->caps.num_cqs,
 			       dev->caps.num_cqs - 1, dev->caps.reserved_cqs, 0);
@@ -315,6 +375,8 @@ int mlx4_init_cq_table(struct mlx4_dev *dev)
 
 void mlx4_cleanup_cq_table(struct mlx4_dev *dev)
 {
+	if (mlx4_is_slave(dev))
+		return;
 	/* Nothing to do to clean up radix_tree */
 	mlx4_bitmap_cleanup(&mlx4_priv(dev)->cq_table.bitmap);
 }
-- 
1.7.7






--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
