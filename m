From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V2 07/21] mlx4_core: srq modifications for SRIOV
Date: Tue, 13 Dec 2011 16:13:05 +0200
Message-ID: <4EE75D71.9030800@mellanox.co.il>
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

SRQs are resources which are allocated and tracked by the PF driver.
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
 drivers/net/ethernet/mellanox/mlx4/srq.c |  106 +++++++++++++++++++++++-------
 1 files changed, 83 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
index f4ca096..ca9e152 100644
--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
@@ -31,6 +31,8 @@
  * SOFTWARE.
  */
 
+#include <linux/init.h>
+
 #include <linux/mlx4/cmd.h>
 #include <linux/export.h>
 #include <linux/gfp.h>
@@ -85,8 +87,9 @@ void mlx4_srq_event(struct mlx4_dev *dev, u32 srqn, int event_type)
 static int mlx4_SW2HW_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			  int srq_num)
 {
-	return mlx4_cmd(dev, mailbox->dma, srq_num, 0, MLX4_CMD_SW2HW_SRQ,
-			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+	return mlx4_cmd(dev, mailbox->dma | dev->caps.function, srq_num, 0,
+			MLX4_CMD_SW2HW_SRQ, MLX4_CMD_TIME_CLASS_A,
+			MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_HW2SW_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
@@ -110,32 +113,93 @@ static int mlx4_QUERY_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 			    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 
-int mlx4_srq_alloc(struct mlx4_dev *dev, u32 pdn, u32 cqn, u16 xrcd,
-		   struct mlx4_mtt *mtt, u64 db_rec, struct mlx4_srq *srq)
+static int __mlx4_srq_alloc_icm(struct mlx4_dev *dev, int *srqn)
 {
 	struct mlx4_srq_table *srq_table = &mlx4_priv(dev)->srq_table;
-	struct mlx4_cmd_mailbox *mailbox;
-	struct mlx4_srq_context *srq_context;
-	u64 mtt_addr;
 	int err;
 
-	srq->srqn = mlx4_bitmap_alloc(&srq_table->bitmap);
-	if (srq->srqn == -1)
+
+	*srqn = mlx4_bitmap_alloc(&srq_table->bitmap);
+	if (*srqn == -1)
 		return -ENOMEM;
 
-	err = mlx4_table_get(dev, &srq_table->table, srq->srqn);
+	err = mlx4_table_get(dev, &srq_table->table, *srqn);
 	if (err)
 		goto err_out;
 
-	err = mlx4_table_get(dev, &srq_table->cmpt_table, srq->srqn);
+	err = mlx4_table_get(dev, &srq_table->cmpt_table, *srqn);
 	if (err)
 		goto err_put;
+	return 0;
+
+err_put:
+	mlx4_table_put(dev, &srq_table->table, *srqn);
+
+err_out:
+	mlx4_bitmap_free(&srq_table->bitmap, *srqn);
+	return err;
+}
+
+static int mlx4_srq_alloc_icm(struct mlx4_dev *dev, int *srqn)
+{
+	u64 out_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		err = mlx4_cmd_imm(dev, 0, &out_param, RES_SRQ,
+				   RES_OP_RESERVE_AND_MAP,
+				   MLX4_CMD_ALLOC_RES,
+				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (!err)
+			*srqn = get_param_l(&out_param);
+
+		return err;
+	}
+	return __mlx4_srq_alloc_icm(dev, srqn);
+}
+
+static void __mlx4_srq_free_icm(struct mlx4_dev *dev, int srqn)
+{
+	struct mlx4_srq_table *srq_table = &mlx4_priv(dev)->srq_table;
+
+	mlx4_table_put(dev, &srq_table->cmpt_table, srqn);
+	mlx4_table_put(dev, &srq_table->table, srqn);
+	mlx4_bitmap_free(&srq_table->bitmap, srqn);
+}
+
+static void mlx4_srq_free_icm(struct mlx4_dev *dev, int srqn)
+{
+	u64 in_param;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&in_param, srqn);
+		if (mlx4_cmd(dev, in_param, RES_SRQ, RES_OP_RESERVE_AND_MAP,
+			     MLX4_CMD_FREE_RES,
+			     MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED))
+			mlx4_warn(dev, "Failed freeing cq:%d\n", srqn);
+		return;
+	}
+	__mlx4_srq_free_icm(dev, srqn);
+}
+
+int mlx4_srq_alloc(struct mlx4_dev *dev, u32 pdn, u32 cqn, u16 xrcd,
+		   struct mlx4_mtt *mtt, u64 db_rec, struct mlx4_srq *srq)
+{
+	struct mlx4_srq_table *srq_table = &mlx4_priv(dev)->srq_table;
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_srq_context *srq_context;
+	u64 mtt_addr;
+	int err;
+
+	err = mlx4_srq_alloc_icm(dev, &srq->srqn);
+	if (err)
+		return err;
 
 	spin_lock_irq(&srq_table->lock);
 	err = radix_tree_insert(&srq_table->tree, srq->srqn, srq);
 	spin_unlock_irq(&srq_table->lock);
 	if (err)
-		goto err_cmpt_put;
+		goto err_icm;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox)) {
@@ -174,15 +238,8 @@ err_radix:
 	radix_tree_delete(&srq_table->tree, srq->srqn);
 	spin_unlock_irq(&srq_table->lock);
 
-err_cmpt_put:
-	mlx4_table_put(dev, &srq_table->cmpt_table, srq->srqn);
-
-err_put:
-	mlx4_table_put(dev, &srq_table->table, srq->srqn);
-
-err_out:
-	mlx4_bitmap_free(&srq_table->bitmap, srq->srqn);
-
+err_icm:
+	mlx4_srq_free_icm(dev, srq->srqn);
 	return err;
 }
 EXPORT_SYMBOL_GPL(mlx4_srq_alloc);
@@ -204,8 +261,7 @@ void mlx4_srq_free(struct mlx4_dev *dev, struct mlx4_srq *srq)
 		complete(&srq->free);
 	wait_for_completion(&srq->free);
 
-	mlx4_table_put(dev, &srq_table->table, srq->srqn);
-	mlx4_bitmap_free(&srq_table->bitmap, srq->srqn);
+	mlx4_srq_free_icm(dev, srq->srqn);
 }
 EXPORT_SYMBOL_GPL(mlx4_srq_free);
 
@@ -245,6 +301,8 @@ int mlx4_init_srq_table(struct mlx4_dev *dev)
 
 	spin_lock_init(&srq_table->lock);
 	INIT_RADIX_TREE(&srq_table->tree, GFP_ATOMIC);
+	if (mlx4_is_slave(dev))
+		return 0;
 
 	err = mlx4_bitmap_init(&srq_table->bitmap, dev->caps.num_srqs,
 			       dev->caps.num_srqs - 1, dev->caps.reserved_srqs, 0);
@@ -256,5 +314,7 @@ int mlx4_init_srq_table(struct mlx4_dev *dev)
 
 void mlx4_cleanup_srq_table(struct mlx4_dev *dev)
 {
+	if (mlx4_is_slave(dev))
+		return;
 	mlx4_bitmap_cleanup(&mlx4_priv(dev)->srq_table.bitmap);
 }
-- 
1.7.7








--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
