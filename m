From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next V0 07/21] mlx4_core: srq modifications for SRIOV
Date: Fri, 2 Dec 2011 12:17:24 +0200
Message-ID: <4ED8A5B4.5090006@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<roland@purestorage.com>, <yevgenyp@mellanox.co.il>,
	<liranl@mellanox.co.il>, <jackm@dev.mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:41125 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754311Ab1LBM6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 07:58:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

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

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/srq.c |  118 +++++++++++++++++++++++------
 1 files changed, 93 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
index d87d1e4..4407133 100644
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
@@ -85,8 +87,8 @@ void mlx4_srq_event(struct mlx4_dev *dev, u32 srqn, int event_type)
 static int mlx4_SW2HW_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			  int srq_num)
 {
-	return mlx4_cmd(dev, mailbox->dma, srq_num, 0, MLX4_CMD_SW2HW_SRQ,
-			MLX4_CMD_TIME_CLASS_A, 0);
+	return mlx4_cmd(dev, mailbox->dma | dev->caps.function, srq_num, 0,
+			MLX4_CMD_SW2HW_SRQ, MLX4_CMD_TIME_CLASS_A, 0);
 }
 
 static int mlx4_HW2SW_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
@@ -110,32 +112,93 @@ static int mlx4_QUERY_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 			    MLX4_CMD_TIME_CLASS_A, 0);
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
+				   MLX4_CMD_TIME_CLASS_A, 0);
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
+			     MLX4_CMD_TIME_CLASS_A, 0))
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
@@ -174,38 +237,39 @@ err_radix:
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
 
-void mlx4_srq_free(struct mlx4_dev *dev, struct mlx4_srq *srq)
+static void mlx4_srq_invalidate(struct mlx4_dev *dev, struct mlx4_srq *srq)
 {
-	struct mlx4_srq_table *srq_table = &mlx4_priv(dev)->srq_table;
 	int err;
 
 	err = mlx4_HW2SW_SRQ(dev, NULL, srq->srqn);
 	if (err)
 		mlx4_warn(dev, "HW2SW_SRQ failed (%d) for SRQN %06x\n", err, srq->srqn);
+}
+EXPORT_SYMBOL_GPL(mlx4_srq_invalidate);
+
+static void mlx4_srq_remove(struct mlx4_dev *dev, struct mlx4_srq *srq)
+{
+	struct mlx4_srq_table *srq_table = &mlx4_priv(dev)->srq_table;
 
 	spin_lock_irq(&srq_table->lock);
 	radix_tree_delete(&srq_table->tree, srq->srqn);
 	spin_unlock_irq(&srq_table->lock);
+}
+EXPORT_SYMBOL_GPL(mlx4_srq_remove);
 
+void mlx4_srq_free(struct mlx4_dev *dev, struct mlx4_srq *srq)
+{
 	if (atomic_dec_and_test(&srq->refcount))
 		complete(&srq->free);
 	wait_for_completion(&srq->free);
 
-	mlx4_table_put(dev, &srq_table->table, srq->srqn);
-	mlx4_bitmap_free(&srq_table->bitmap, srq->srqn);
+	mlx4_srq_free_icm(dev, srq->srqn);
 }
 EXPORT_SYMBOL_GPL(mlx4_srq_free);
 
@@ -245,6 +309,8 @@ int mlx4_init_srq_table(struct mlx4_dev *dev)
 
 	spin_lock_init(&srq_table->lock);
 	INIT_RADIX_TREE(&srq_table->tree, GFP_ATOMIC);
+	if (mlx4_is_slave(dev))
+		return 0;
 
 	err = mlx4_bitmap_init(&srq_table->bitmap, dev->caps.num_srqs,
 			       dev->caps.num_srqs - 1, dev->caps.reserved_srqs, 0);
@@ -256,5 +322,7 @@ int mlx4_init_srq_table(struct mlx4_dev *dev)
 
 void mlx4_cleanup_srq_table(struct mlx4_dev *dev)
 {
+	if (mlx4_is_slave(dev))
+		return;
 	mlx4_bitmap_cleanup(&mlx4_priv(dev)->srq_table.bitmap);
 }
-- 
1.7.7
