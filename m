From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next V2 08/21] mlx4_core: qp modifications for SRIOV
Date: Tue, 13 Dec 2011 16:13:22 +0200
Message-ID: <4EE75D82.2030208@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<roland@purestorage.com>, <yevgenyp@mellanox.co.il>,
	<liranl@mellanox.co.il>, <jackm@dev.mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:46899 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755044Ab1LMQSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 11:18:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

QPs are resources which are allocated and tracked by the PF driver.
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
 drivers/net/ethernet/mellanox/mlx4/qp.c |  235 ++++++++++++++++++++++++-------
 1 files changed, 181 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index e721f4c..d048974 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -35,6 +35,8 @@
 
 #include <linux/gfp.h>
 #include <linux/export.h>
+#include <linux/init.h>
+
 #include <linux/mlx4/cmd.h>
 #include <linux/mlx4/qp.h>
 
@@ -55,7 +57,7 @@ void mlx4_qp_event(struct mlx4_dev *dev, u32 qpn, int event_type)
 	spin_unlock(&qp_table->lock);
 
 	if (!qp) {
-		mlx4_warn(dev, "Async event for bogus QP %08x\n", qpn);
+		mlx4_dbg(dev, "Async event for none existent QP %08x\n", qpn);
 		return;
 	}
 
@@ -65,10 +67,17 @@ void mlx4_qp_event(struct mlx4_dev *dev, u32 qpn, int event_type)
 		complete(&qp->free);
 }
 
-int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
-		   enum mlx4_qp_state cur_state, enum mlx4_qp_state new_state,
-		   struct mlx4_qp_context *context, enum mlx4_qp_optpar optpar,
-		   int sqd_event, struct mlx4_qp *qp)
+static int is_qp0(struct mlx4_dev *dev, struct mlx4_qp *qp)
+{
+	return qp->qpn >= dev->caps.sqp_start &&
+		qp->qpn <= dev->caps.sqp_start + 1;
+}
+
+static int __mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
+		     enum mlx4_qp_state cur_state, enum mlx4_qp_state new_state,
+		     struct mlx4_qp_context *context,
+		     enum mlx4_qp_optpar optpar,
+		     int sqd_event, struct mlx4_qp *qp, int native)
 {
 	static const u16 op[MLX4_QP_NUM_STATE][MLX4_QP_NUM_STATE] = {
 		[MLX4_QP_STATE_RST] = {
@@ -110,17 +119,26 @@ int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		}
 	};
 
+	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_cmd_mailbox *mailbox;
 	int ret = 0;
+	u8 port;
 
 	if (cur_state >= MLX4_QP_NUM_STATE || new_state >= MLX4_QP_NUM_STATE ||
 	    !op[cur_state][new_state])
 		return -EINVAL;
 
-	if (op[cur_state][new_state] == MLX4_CMD_2RST_QP)
-		return mlx4_cmd(dev, 0, qp->qpn, 2,
-				MLX4_CMD_2RST_QP, MLX4_CMD_TIME_CLASS_A,
-				MLX4_CMD_WRAPPED);
+	if (op[cur_state][new_state] == MLX4_CMD_2RST_QP) {
+		ret = mlx4_cmd(dev, 0, qp->qpn, 2,
+			MLX4_CMD_2RST_QP, MLX4_CMD_TIME_CLASS_A, native);
+		if (mlx4_is_master(dev) && cur_state != MLX4_QP_STATE_ERR &&
+		    cur_state != MLX4_QP_STATE_RST &&
+		    is_qp0(dev, qp)) {
+			port = (qp->qpn & 1) + 1;
+			priv->mfunc.master.qp0_state[port].qp0_active = 0;
+		}
+		return ret;
+	}
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -133,108 +151,218 @@ int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		context->log_page_size   = mtt->page_shift - MLX4_ICM_PAGE_SHIFT;
 	}
 
+	port = ((context->pri_path.sched_queue >> 6) & 1) + 1;
+	if (dev->caps.port_type[port] == MLX4_PORT_TYPE_ETH)
+		context->pri_path.sched_queue = (context->pri_path.sched_queue &
+						0xc3);
+
 	*(__be32 *) mailbox->buf = cpu_to_be32(optpar);
 	memcpy(mailbox->buf + 8, context, sizeof *context);
 
 	((struct mlx4_qp_context *) (mailbox->buf + 8))->local_qpn =
 		cpu_to_be32(qp->qpn);
 
-	ret = mlx4_cmd(dev, mailbox->dma, qp->qpn | (!!sqd_event << 31),
+	ret = mlx4_cmd(dev, mailbox->dma | dev->caps.function,
+		       qp->qpn | (!!sqd_event << 31),
 		       new_state == MLX4_QP_STATE_RST ? 2 : 0,
-		       op[cur_state][new_state], MLX4_CMD_TIME_CLASS_C,
-		       MLX4_CMD_WRAPPED);
+		       op[cur_state][new_state], MLX4_CMD_TIME_CLASS_C, native);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return ret;
 }
+
+int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
+		   enum mlx4_qp_state cur_state, enum mlx4_qp_state new_state,
+		   struct mlx4_qp_context *context,
+		   enum mlx4_qp_optpar optpar,
+		   int sqd_event, struct mlx4_qp *qp)
+{
+	return __mlx4_qp_modify(dev, mtt, cur_state, new_state, context,
+				optpar, sqd_event, qp, 0);
+}
 EXPORT_SYMBOL_GPL(mlx4_qp_modify);
 
-int mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align, int *base)
+static int __mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align,
+				   int *base)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_qp_table *qp_table = &priv->qp_table;
-	int qpn;
 
-	qpn = mlx4_bitmap_alloc_range(&qp_table->bitmap, cnt, align);
-	if (qpn == -1)
+	*base = mlx4_bitmap_alloc_range(&qp_table->bitmap, cnt, align);
+	if (*base == -1)
 		return -ENOMEM;
 
-	*base = qpn;
 	return 0;
 }
+
+int mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align, int *base)
+{
+	u64 in_param;
+	u64 out_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&in_param, cnt);
+		set_param_h(&in_param, align);
+		err = mlx4_cmd_imm(dev, in_param, &out_param,
+				   RES_QP, RES_OP_RESERVE,
+				   MLX4_CMD_ALLOC_RES,
+				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (err)
+			return err;
+
+		*base = get_param_l(&out_param);
+		return 0;
+	}
+	return __mlx4_qp_reserve_range(dev, cnt, align, base);
+}
 EXPORT_SYMBOL_GPL(mlx4_qp_reserve_range);
 
-void mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt)
+static void __mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_qp_table *qp_table = &priv->qp_table;
-	if (base_qpn < dev->caps.sqp_start + 8)
-		return;
 
+	if (mlx4_is_qp_reserved(dev, (u32) base_qpn))
+		return;
 	mlx4_bitmap_free_range(&qp_table->bitmap, base_qpn, cnt);
 }
+
+void mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt)
+{
+	u64 in_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&in_param, base_qpn);
+		set_param_h(&in_param, cnt);
+		err = mlx4_cmd(dev, in_param, RES_QP, RES_OP_RESERVE,
+			       MLX4_CMD_FREE_RES,
+			       MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (err) {
+			mlx4_warn(dev, "Failed to release qp range"
+				  " base:%d cnt:%d\n", base_qpn, cnt);
+		}
+	} else
+		 __mlx4_qp_release_range(dev, base_qpn, cnt);
+}
 EXPORT_SYMBOL_GPL(mlx4_qp_release_range);
 
-int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp)
+static int __mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_qp_table *qp_table = &priv->qp_table;
 	int err;
 
-	if (!qpn)
-		return -EINVAL;
-
-	qp->qpn = qpn;
-
-	err = mlx4_table_get(dev, &qp_table->qp_table, qp->qpn);
+	err = mlx4_table_get(dev, &qp_table->qp_table, qpn);
 	if (err)
 		goto err_out;
 
-	err = mlx4_table_get(dev, &qp_table->auxc_table, qp->qpn);
+	err = mlx4_table_get(dev, &qp_table->auxc_table, qpn);
 	if (err)
 		goto err_put_qp;
 
-	err = mlx4_table_get(dev, &qp_table->altc_table, qp->qpn);
+	err = mlx4_table_get(dev, &qp_table->altc_table, qpn);
 	if (err)
 		goto err_put_auxc;
 
-	err = mlx4_table_get(dev, &qp_table->rdmarc_table, qp->qpn);
+	err = mlx4_table_get(dev, &qp_table->rdmarc_table, qpn);
 	if (err)
 		goto err_put_altc;
 
-	err = mlx4_table_get(dev, &qp_table->cmpt_table, qp->qpn);
+	err = mlx4_table_get(dev, &qp_table->cmpt_table, qpn);
 	if (err)
 		goto err_put_rdmarc;
 
-	spin_lock_irq(&qp_table->lock);
-	err = radix_tree_insert(&dev->qp_table_tree, qp->qpn & (dev->caps.num_qps - 1), qp);
-	spin_unlock_irq(&qp_table->lock);
-	if (err)
-		goto err_put_cmpt;
-
-	atomic_set(&qp->refcount, 1);
-	init_completion(&qp->free);
-
 	return 0;
 
-err_put_cmpt:
-	mlx4_table_put(dev, &qp_table->cmpt_table, qp->qpn);
-
 err_put_rdmarc:
-	mlx4_table_put(dev, &qp_table->rdmarc_table, qp->qpn);
+	mlx4_table_put(dev, &qp_table->rdmarc_table, qpn);
 
 err_put_altc:
-	mlx4_table_put(dev, &qp_table->altc_table, qp->qpn);
+	mlx4_table_put(dev, &qp_table->altc_table, qpn);
 
 err_put_auxc:
-	mlx4_table_put(dev, &qp_table->auxc_table, qp->qpn);
+	mlx4_table_put(dev, &qp_table->auxc_table, qpn);
 
 err_put_qp:
-	mlx4_table_put(dev, &qp_table->qp_table, qp->qpn);
+	mlx4_table_put(dev, &qp_table->qp_table, qpn);
 
 err_out:
 	return err;
 }
+
+static int mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn)
+{
+	u64 param;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&param, qpn);
+		return mlx4_cmd_imm(dev, param, &param, RES_QP, RES_OP_MAP_ICM,
+				    MLX4_CMD_ALLOC_RES, MLX4_CMD_TIME_CLASS_A,
+				    MLX4_CMD_WRAPPED);
+	}
+	return __mlx4_qp_alloc_icm(dev, qpn);
+}
+
+static void __mlx4_qp_free_icm(struct mlx4_dev *dev, int qpn)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_qp_table *qp_table = &priv->qp_table;
+
+	mlx4_table_put(dev, &qp_table->cmpt_table, qpn);
+	mlx4_table_put(dev, &qp_table->rdmarc_table, qpn);
+	mlx4_table_put(dev, &qp_table->altc_table, qpn);
+	mlx4_table_put(dev, &qp_table->auxc_table, qpn);
+	mlx4_table_put(dev, &qp_table->qp_table, qpn);
+}
+
+static void mlx4_qp_free_icm(struct mlx4_dev *dev, int qpn)
+{
+	u64 in_param;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&in_param, qpn);
+		if (mlx4_cmd(dev, in_param, RES_QP, RES_OP_MAP_ICM,
+			     MLX4_CMD_FREE_RES, MLX4_CMD_TIME_CLASS_A,
+			     MLX4_CMD_WRAPPED))
+			mlx4_warn(dev, "Failed to free icm of qp:%d\n", qpn);
+	} else
+		__mlx4_qp_free_icm(dev, qpn);
+}
+
+int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_qp_table *qp_table = &priv->qp_table;
+	int err;
+
+	if (!qpn)
+		return -EINVAL;
+
+	qp->qpn = qpn;
+
+	err = mlx4_qp_alloc_icm(dev, qpn);
+	if (err)
+		return err;
+
+	spin_lock_irq(&qp_table->lock);
+	err = radix_tree_insert(&dev->qp_table_tree, qp->qpn &
+				(dev->caps.num_qps - 1), qp);
+	spin_unlock_irq(&qp_table->lock);
+	if (err)
+		goto err_icm;
+
+	atomic_set(&qp->refcount, 1);
+	init_completion(&qp->free);
+
+	return 0;
+
+err_icm:
+	mlx4_qp_free_icm(dev, qpn);
+	return err;
+}
+
 EXPORT_SYMBOL_GPL(mlx4_qp_alloc);
 
 void mlx4_qp_remove(struct mlx4_dev *dev, struct mlx4_qp *qp)
@@ -250,17 +378,11 @@ EXPORT_SYMBOL_GPL(mlx4_qp_remove);
 
 void mlx4_qp_free(struct mlx4_dev *dev, struct mlx4_qp *qp)
 {
-	struct mlx4_qp_table *qp_table = &mlx4_priv(dev)->qp_table;
-
 	if (atomic_dec_and_test(&qp->refcount))
 		complete(&qp->free);
 	wait_for_completion(&qp->free);
 
-	mlx4_table_put(dev, &qp_table->cmpt_table, qp->qpn);
-	mlx4_table_put(dev, &qp_table->rdmarc_table, qp->qpn);
-	mlx4_table_put(dev, &qp_table->altc_table, qp->qpn);
-	mlx4_table_put(dev, &qp_table->auxc_table, qp->qpn);
-	mlx4_table_put(dev, &qp_table->qp_table, qp->qpn);
+	mlx4_qp_free_icm(dev, qp->qpn);
 }
 EXPORT_SYMBOL_GPL(mlx4_qp_free);
 
@@ -278,6 +400,8 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 
 	spin_lock_init(&qp_table->lock);
 	INIT_RADIX_TREE(&dev->qp_table_tree, GFP_ATOMIC);
+	if (mlx4_is_slave(dev))
+		return 0;
 
 	/*
 	 * We reserve 2 extra QPs per port for the special QPs.  The
@@ -329,6 +453,9 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 
 void mlx4_cleanup_qp_table(struct mlx4_dev *dev)
 {
+	if (mlx4_is_slave(dev))
+		return;
+
 	mlx4_CONF_SPECIAL_QP(dev, 0);
 	mlx4_bitmap_cleanup(&mlx4_priv(dev)->qp_table.bitmap);
 }
-- 
1.7.7
