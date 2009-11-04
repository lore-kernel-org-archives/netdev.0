From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 05/25] mlx4_core: add slave resource allocation
Date: Wed, 04 Nov 2009 17:30:38 +0200
Message-ID: <4AF19E1E.4000102@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il,
	yevgenyp@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:34599 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755839AbZKDMcx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 07:32:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All QPs/CQs/SRQs/MPTs/MTTs are allocated from shared pools, which are owned by
the master. In addition, all backing ICM memory for these objects is managed by
the master.
To allow slaves to allocate resources, ICM allocation is separated from the rest
of the object state, which is held at the slave.
Slaves can then reserve resource ranges and allocate ICM over the comm channel.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c   |   96 +++++++++++++++++++++++++++++
 drivers/net/mlx4/cq.c    |   91 +++++++++++++++++++++-------
 drivers/net/mlx4/mlx4.h  |   27 ++++++++
 drivers/net/mlx4/mr.c    |  125 ++++++++++++++++++++++++++++++++++----
 drivers/net/mlx4/qp.c    |  151 +++++++++++++++++++++++++++++++++-------------
 drivers/net/mlx4/srq.c   |   88 ++++++++++++++++++++-------
 include/linux/mlx4/cmd.h |    2 +
 7 files changed, 482 insertions(+), 98 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 96462f7..b1701d2 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -418,6 +418,100 @@ int mlx4_ACCESS_MEM(struct mlx4_dev *dev, u64 master_addr, int slave, u64 slave_
 					   MLX4_CMD_TIME_CLASS_A);
 }
 
+static int mlx4_RESOURCE_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						       struct mlx4_cmd_mailbox *inbox,
+						       struct mlx4_cmd_mailbox *outbox)
+{
+	u32 param1 = *((u32 *) &vhcr->in_param);
+	u32 param2 = *(((u32 *) &vhcr->in_param) + 1);
+	int ret;
+
+#if 0
+	char *res[] = {"QP", "CQ", "SRQ", "MPT", "MTT"};
+	mlx4_warn(dev, "resource wrapper - %s (mode: %s) type:%s param1:%d param2:%d\n",
+			vhcr->op == MLX4_CMD_ALLOC_RES ? "allocate" : "free",
+			vhcr->op_modifier == ICM_RESERVE ? "reserve" :
+				(vhcr->op_modifier == ICM_ALLOC ? "alloc" : "reserve+alloc"),
+			res[vhcr->in_modifier], param1, param2);
+#endif
+
+	vhcr->errno = 0;
+	switch (vhcr->in_modifier) {
+	case RES_QP:
+		switch (vhcr->op_modifier) {
+		case ICM_RESERVE:
+			if (vhcr->op == MLX4_CMD_ALLOC_RES) {
+				vhcr->errno = mlx4_qp_reserve_range(dev, param1, param2, &ret);
+				if (!vhcr->errno)
+					vhcr->out_param = ret;
+			} else {
+				mlx4_qp_release_range(dev, param1, param2);
+			}
+			break;
+		case ICM_ALLOC:
+			if (vhcr->op == MLX4_CMD_ALLOC_RES)
+				vhcr->errno = mlx4_qp_alloc_icm(dev, param1);
+			else
+				mlx4_qp_free_icm(dev, param1);
+			break;
+		default:
+			vhcr->errno = -EINVAL;
+		}
+		break;
+	case RES_CQ:
+		if (vhcr->op == MLX4_CMD_ALLOC_RES) {
+			vhcr->errno = mlx4_cq_alloc_icm(dev, &ret);
+			if (!vhcr->errno)
+				vhcr->out_param = ret;
+		} else
+			mlx4_cq_free_icm(dev, param1);
+		break;
+	case RES_SRQ:
+		if (vhcr->op == MLX4_CMD_ALLOC_RES) {
+			vhcr->errno = mlx4_srq_alloc_icm(dev, &ret);
+			if (!vhcr->errno)
+				vhcr->out_param = ret;
+		} else
+			mlx4_srq_free_icm(dev, param1);
+		break;
+	case RES_MPT:
+		switch (vhcr->op_modifier) {
+		case ICM_RESERVE:
+			if (vhcr->op == MLX4_CMD_ALLOC_RES) {
+				ret = mlx4_mr_reserve(dev);
+				if (ret == -1)
+					vhcr->errno = -ENOMEM;
+				else
+					vhcr->out_param = ret;
+			} else
+				mlx4_mr_release(dev, param1);
+			break;
+		case ICM_ALLOC:
+			if (vhcr->op == MLX4_CMD_ALLOC_RES)
+				vhcr->errno = mlx4_mr_alloc_icm(dev, param1);
+			else
+				mlx4_mr_free_icm(dev, param1);
+			break;
+		default:
+			vhcr->errno = -EINVAL;
+		}
+		break;
+	case RES_MTT:
+		if (vhcr->op == MLX4_CMD_ALLOC_RES) {
+			ret = mlx4_alloc_mtt_range(dev, param1 /* order */);
+			if (ret == -1)
+				vhcr->errno = -ENOMEM;
+			else
+				vhcr->out_param = ret;
+		} else
+			mlx4_free_mtt_range(dev, param1 /* first */, param2 /* order */);
+		break;
+	default:
+		vhcr->errno = -EINVAL;
+	}
+	return 0;
+}
+
 static struct mlx4_cmd_info {
 	u8 opcode;
 	u8 has_inbox;
@@ -434,6 +528,8 @@ static struct mlx4_cmd_info {
 
 	{MLX4_CMD_SW2HW_EQ,        1, 0, 0, NULL, NULL}, /* need verifier */
 	{MLX4_CMD_NOP,             0, 0, 0, NULL, NULL},
+	{MLX4_CMD_ALLOC_RES,	   0, 0, 1, NULL, mlx4_RESOURCE_wrapper},
+	{MLX4_CMD_FREE_RES,	   0, 0, 0, NULL, mlx4_RESOURCE_wrapper},
 
 	{MLX4_CMD_SW2HW_MPT,       1, 0, 0, NULL, NULL}, /* need verifier */
 	{MLX4_CMD_QUERY_MPT,       0, 1, 0, NULL, NULL}, /* need verifier */
diff --git a/drivers/net/mlx4/cq.c b/drivers/net/mlx4/cq.c
index ccfe276..3fb9f7f 100644
--- a/drivers/net/mlx4/cq.c
+++ b/drivers/net/mlx4/cq.c
@@ -186,6 +186,70 @@ int mlx4_cq_resize(struct mlx4_dev *dev, struct mlx4_cq *cq,
 }
 EXPORT_SYMBOL_GPL(mlx4_cq_resize);
 
+int mlx4_cq_alloc_icm(struct mlx4_dev *dev, int *cqn)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_cq_table *cq_table = &priv->cq_table;
+	u64 out_param;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		err = mlx4_cmd_imm(dev, 0, &out_param, RES_CQ,
+						       ICM_RESERVE_AND_ALLOC,
+						       MLX4_CMD_ALLOC_RES,
+						       MLX4_CMD_TIME_CLASS_A);
+		if (err) {
+			*cqn = -1;
+			return err;
+		} else {
+			*cqn = out_param;
+			return 0;
+		}
+	}
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
+void mlx4_cq_free_icm(struct mlx4_dev *dev, int cqn)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_cq_table *cq_table = &priv->cq_table;
+	u64 in_param;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &in_param) = cqn;
+		*(((u32 *) &in_param) + 1) = 0;
+		err = mlx4_cmd(dev, in_param, RES_CQ, ICM_RESERVE_AND_ALLOC,
+						      MLX4_CMD_FREE_RES,
+						      MLX4_CMD_TIME_CLASS_A);
+		if (err)
+			mlx4_warn(dev, "Failed freeing cq:%d\n", cqn);
+	} else {
+		mlx4_table_put(dev, &cq_table->cmpt_table, cqn);
+		mlx4_table_put(dev, &cq_table->table, cqn);
+		mlx4_bitmap_free(&cq_table->bitmap, cqn);
+	}
+}
+
 int mlx4_cq_alloc(struct mlx4_dev *dev, int nent, struct mlx4_mtt *mtt,
 		  struct mlx4_uar *uar, u64 db_rec, struct mlx4_cq *cq,
 		  unsigned vector, int collapsed)
@@ -202,23 +266,15 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent, struct mlx4_mtt *mtt,
 
 	cq->vector = vector;
 
-	cq->cqn = mlx4_bitmap_alloc(&cq_table->bitmap);
-	if (cq->cqn == -1)
-		return -ENOMEM;
-
-	err = mlx4_table_get(dev, &cq_table->table, cq->cqn);
+	err = mlx4_cq_alloc_icm(dev, &cq->cqn);
 	if (err)
-		goto err_out;
-
-	err = mlx4_table_get(dev, &cq_table->cmpt_table, cq->cqn);
-	if (err)
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
@@ -257,14 +313,8 @@ err_radix:
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
@@ -290,8 +340,7 @@ void mlx4_cq_free(struct mlx4_dev *dev, struct mlx4_cq *cq)
 		complete(&cq->free);
 	wait_for_completion(&cq->free);
 
-	mlx4_table_put(dev, &cq_table->table, cq->cqn);
-	mlx4_bitmap_free(&cq_table->bitmap, cq->cqn);
+	mlx4_cq_free_icm(dev, cq->cqn);
 }
 EXPORT_SYMBOL_GPL(mlx4_cq_free);
 
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 4796982..91f1215 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -94,6 +94,21 @@ enum {
 	MLX4_COMM_CMD_VHCR_POST
 };
 
+enum mlx4_resource {
+	RES_QP,
+	RES_CQ,
+	RES_SRQ,
+	RES_MPT,
+	RES_MTT
+};
+
+enum mlx4_alloc_mode {
+	ICM_RESERVE_AND_ALLOC,
+	ICM_RESERVE,
+	ICM_ALLOC,
+	ICM_MAC_VLAN,
+};
+
 enum {
 	MLX4_MFUNC_MAX_EQES     = 8,
 	MLX4_MFUNC_EQE_MASK     = (MLX4_MFUNC_MAX_EQES - 1)
@@ -422,6 +437,18 @@ void mlx4_cleanup_qp_table(struct mlx4_dev *dev);
 void mlx4_cleanup_srq_table(struct mlx4_dev *dev);
 void mlx4_cleanup_mcg_table(struct mlx4_dev *dev);
 
+int mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn);
+void mlx4_qp_free_icm(struct mlx4_dev *dev, int qpn);
+int mlx4_cq_alloc_icm(struct mlx4_dev *dev, int *cqn);
+void mlx4_cq_free_icm(struct mlx4_dev *dev, int cqn);
+int mlx4_srq_alloc_icm(struct mlx4_dev *dev, int *srqn);
+void mlx4_srq_free_icm(struct mlx4_dev *dev, int srqn);
+int mlx4_mr_reserve(struct mlx4_dev *dev);
+void mlx4_mr_release(struct mlx4_dev *dev, u32 index);
+int mlx4_mr_alloc_icm(struct mlx4_dev *dev, u32 index);
+void mlx4_mr_free_icm(struct mlx4_dev *dev, u32 index);
+u32 mlx4_alloc_mtt_range(struct mlx4_dev *dev, int order);
+void mlx4_free_mtt_range(struct mlx4_dev *dev, u32 first_seg, int order);
 int mlx4_WRITE_MTT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
 						 struct mlx4_cmd_mailbox *inbox,
 						 struct mlx4_cmd_mailbox *outbox);
diff --git a/drivers/net/mlx4/mr.c b/drivers/net/mlx4/mr.c
index 11a3d26..aa1eba6 100644
--- a/drivers/net/mlx4/mr.c
+++ b/drivers/net/mlx4/mr.c
@@ -178,10 +178,26 @@ static void mlx4_buddy_cleanup(struct mlx4_buddy *buddy)
 	kfree(buddy->num_free);
 }
 
-static u32 mlx4_alloc_mtt_range(struct mlx4_dev *dev, int order)
+u32 mlx4_alloc_mtt_range(struct mlx4_dev *dev, int order)
 {
 	struct mlx4_mr_table *mr_table = &mlx4_priv(dev)->mr_table;
+	u64 in_param;
+	u64 out_param;
 	u32 seg;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &in_param) = order;
+		*(((u32 *) &in_param) + 1) = 0;
+		err = mlx4_cmd_imm(dev, in_param, &out_param, RES_MTT,
+						       ICM_RESERVE_AND_ALLOC,
+						       MLX4_CMD_ALLOC_RES,
+						       MLX4_CMD_TIME_CLASS_A);
+		if (err)
+			return -1;
+		else
+			return out_param;
+	}
 
 	seg = mlx4_buddy_alloc(&mr_table->mtt_buddy, order);
 	if (seg == -1)
@@ -219,16 +235,33 @@ int mlx4_mtt_init(struct mlx4_dev *dev, int npages, int page_shift,
 }
 EXPORT_SYMBOL_GPL(mlx4_mtt_init);
 
-void mlx4_mtt_cleanup(struct mlx4_dev *dev, struct mlx4_mtt *mtt)
+void mlx4_free_mtt_range(struct mlx4_dev *dev, u32 first_seg, int order)
 {
 	struct mlx4_mr_table *mr_table = &mlx4_priv(dev)->mr_table;
+	u64 in_param;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &in_param) = first_seg;
+		*(((u32 *) &in_param) + 1) = order;
+		err = mlx4_cmd(dev, in_param, RES_MTT, ICM_RESERVE_AND_ALLOC,
+						       MLX4_CMD_FREE_RES,
+						       MLX4_CMD_TIME_CLASS_A);
+		if (err)
+			mlx4_warn(dev, "Failed to free mtt range at:%d order:%d\n", first_seg, order);
+	} else {
+		mlx4_buddy_free(&mr_table->mtt_buddy, first_seg, order);
+		mlx4_table_put_range(dev, &mr_table->mtt_table, first_seg,
+					     first_seg + (1 << order) - 1);
+	}
+}
 
+void mlx4_mtt_cleanup(struct mlx4_dev *dev, struct mlx4_mtt *mtt)
+{
 	if (mtt->order < 0)
 		return;
 
-	mlx4_buddy_free(&mr_table->mtt_buddy, mtt->first_seg, mtt->order);
-	mlx4_table_put_range(dev, &mr_table->mtt_table, mtt->first_seg,
-			     mtt->first_seg + (1 << mtt->order) - 1);
+	mlx4_free_mtt_range(dev, mtt->first_seg, mtt->order);
 }
 EXPORT_SYMBOL_GPL(mlx4_mtt_cleanup);
 
@@ -291,14 +324,81 @@ static int mlx4_WRITE_MTT(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 			MLX4_CMD_TIME_CLASS_A);
 }
 
+int mlx4_mr_reserve(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	u64 out_param;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		err = mlx4_cmd_imm(dev, 0, &out_param, RES_MPT, ICM_RESERVE,
+								MLX4_CMD_ALLOC_RES,
+								MLX4_CMD_TIME_CLASS_A);
+		if (err)
+			return -1;
+		return out_param;
+	}
+	return mlx4_bitmap_alloc(&priv->mr_table.mpt_bitmap);
+}
+
+void mlx4_mr_release(struct mlx4_dev *dev, u32 index)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	u64 in_param;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &in_param) = index;
+		*(((u32 *) &in_param) + 1) = 0;
+		err = mlx4_cmd(dev, in_param, RES_MPT, ICM_RESERVE,
+						       MLX4_CMD_FREE_RES,
+						       MLX4_CMD_TIME_CLASS_A);
+		if (err)
+			mlx4_warn(dev, "Failed to release mr index:%d\n", index);
+	} else
+		mlx4_bitmap_free(&priv->mr_table.mpt_bitmap, index);
+}
+
+int mlx4_mr_alloc_icm(struct mlx4_dev *dev, u32 index)
+{
+	struct mlx4_mr_table *mr_table = &mlx4_priv(dev)->mr_table;
+	u64 param;
+
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &param) = index;
+		*(((u32 *) &param) + 1) = 0;
+		return mlx4_cmd_imm(dev, param, &param, RES_MPT, ICM_ALLOC,
+							MLX4_CMD_ALLOC_RES,
+							MLX4_CMD_TIME_CLASS_A);
+	} else
+		return mlx4_table_get(dev, &mr_table->dmpt_table, index);
+}
+
+void mlx4_mr_free_icm(struct mlx4_dev *dev, u32 index)
+{
+	struct mlx4_mr_table *mr_table = &mlx4_priv(dev)->mr_table;
+	u64 in_param;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &in_param) = index;
+		*(((u32 *) &in_param) + 1) = 0;
+		err = mlx4_cmd(dev, in_param, RES_MPT, ICM_ALLOC,
+						       MLX4_CMD_FREE_RES,
+						       MLX4_CMD_TIME_CLASS_A);
+		if (err)
+			mlx4_warn(dev, "Failed to free icm of mr index:%d\n", index);
+	} else
+		mlx4_table_put(dev, &mr_table->dmpt_table, index);
+}
+
 int mlx4_mr_alloc(struct mlx4_dev *dev, u32 pd, u64 iova, u64 size, u32 access,
 		  int npages, int page_shift, struct mlx4_mr *mr)
 {
-	struct mlx4_priv *priv = mlx4_priv(dev);
 	u32 index;
 	int err;
 
-	index = mlx4_bitmap_alloc(&priv->mr_table.mpt_bitmap);
+	index = mlx4_mr_reserve(dev);
 	if (index == -1)
 		return -ENOMEM;
 
@@ -311,7 +411,7 @@ int mlx4_mr_alloc(struct mlx4_dev *dev, u32 pd, u64 iova, u64 size, u32 access,
 
 	err = mlx4_mtt_init(dev, npages, page_shift, &mr->mtt);
 	if (err)
-		mlx4_bitmap_free(&priv->mr_table.mpt_bitmap, index);
+		mlx4_mr_release(dev, index);
 
 	return err;
 }
@@ -319,7 +419,6 @@ EXPORT_SYMBOL_GPL(mlx4_mr_alloc);
 
 void mlx4_mr_free(struct mlx4_dev *dev, struct mlx4_mr *mr)
 {
-	struct mlx4_priv *priv = mlx4_priv(dev);
 	int err;
 
 	if (mr->enabled) {
@@ -331,18 +430,18 @@ void mlx4_mr_free(struct mlx4_dev *dev, struct mlx4_mr *mr)
 	}
 
 	mlx4_mtt_cleanup(dev, &mr->mtt);
-	mlx4_bitmap_free(&priv->mr_table.mpt_bitmap, key_to_hw_index(mr->key));
+	mlx4_mr_release(dev, key_to_hw_index(mr->key));
+	mlx4_mr_free_icm(dev, key_to_hw_index(mr->key));
 }
 EXPORT_SYMBOL_GPL(mlx4_mr_free);
 
 int mlx4_mr_enable(struct mlx4_dev *dev, struct mlx4_mr *mr)
 {
-	struct mlx4_mr_table *mr_table = &mlx4_priv(dev)->mr_table;
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_mpt_entry *mpt_entry;
 	int err;
 
-	err = mlx4_table_get(dev, &mr_table->dmpt_table, key_to_hw_index(mr->key));
+	err = mlx4_mr_alloc_icm(dev, key_to_hw_index(mr->key));
 	if (err)
 		return err;
 
@@ -400,7 +499,7 @@ err_cmd:
 	mlx4_free_cmd_mailbox(dev, mailbox);
 
 err_table:
-	mlx4_table_put(dev, &mr_table->dmpt_table, key_to_hw_index(mr->key));
+	mlx4_mr_free_icm(dev, key_to_hw_index(mr->key));
 	return err;
 }
 EXPORT_SYMBOL_GPL(mlx4_mr_enable);
diff --git a/drivers/net/mlx4/qp.c b/drivers/net/mlx4/qp.c
index 42ab9fc..065c7fc 100644
--- a/drivers/net/mlx4/qp.c
+++ b/drivers/net/mlx4/qp.c
@@ -149,13 +149,24 @@ int mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align, int *base)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_qp_table *qp_table = &priv->qp_table;
-	int qpn;
-
-	qpn = mlx4_bitmap_alloc_range(&qp_table->bitmap, cnt, align);
-	if (qpn == -1)
-		return -ENOMEM;
+	u64 in_param;
+	u64 out_param;
+	int err;
 
-	*base = qpn;
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &in_param) = cnt;
+		*(((u32 *) &in_param) + 1) = align;
+		err = mlx4_cmd_imm(dev, in_param, &out_param, RES_QP, ICM_RESERVE,
+							      MLX4_CMD_ALLOC_RES,
+							      MLX4_CMD_TIME_CLASS_A);
+		if (err)
+			return err;
+		*base = out_param;
+	} else {
+		*base = mlx4_bitmap_alloc_range(&qp_table->bitmap, cnt, align);
+		if (*base == -1)
+			return -ENOMEM;
+	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_qp_reserve_range);
@@ -164,73 +175,133 @@ void mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_qp_table *qp_table = &priv->qp_table;
-	if (base_qpn < dev->caps.sqp_start + 8)
-		return;
+	u64 in_param;
+	int err;
 
-	mlx4_bitmap_free_range(&qp_table->bitmap, base_qpn, cnt);
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &in_param) = base_qpn;
+		*(((u32 *) &in_param) + 1) = cnt;
+		err = mlx4_cmd(dev, in_param, RES_QP, ICM_RESERVE,
+						      MLX4_CMD_FREE_RES,
+						      MLX4_CMD_TIME_CLASS_A);
+		if (err) {
+			mlx4_warn(dev, "Failed to release qp range base:%d cnt:%d\n",
+									base_qpn, cnt);
+		}
+	} else {
+		if (base_qpn < dev->caps.sqp_start + 8)
+			return;
+		mlx4_bitmap_free_range(&qp_table->bitmap, base_qpn, cnt);
+	}
 }
 EXPORT_SYMBOL_GPL(mlx4_qp_release_range);
 
-int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp)
+int mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_qp_table *qp_table = &priv->qp_table;
+	u64 param;
 	int err;
 
-	if (!qpn)
-		return -EINVAL;
-
-	qp->qpn = qpn;
-
-	err = mlx4_table_get(dev, &qp_table->qp_table, qp->qpn);
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &param) = qpn;
+		*(((u32 *) &param) + 1) = 0;
+		return mlx4_cmd_imm(dev, param, &param, RES_QP, ICM_ALLOC,
+								MLX4_CMD_ALLOC_RES,
+								MLX4_CMD_TIME_CLASS_A);
+	}
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
+void mlx4_qp_free_icm(struct mlx4_dev *dev, int qpn)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_qp_table *qp_table = &priv->qp_table;
+	u64 in_param;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &in_param) = qpn;
+		*(((u32 *) &in_param) + 1) = 0;
+		err = mlx4_cmd(dev, in_param, RES_QP, ICM_ALLOC,
+						      MLX4_CMD_FREE_RES,
+						      MLX4_CMD_TIME_CLASS_A);
+		if (err)
+			mlx4_warn(dev, "Failed to free icm of qp:%d\n", qpn);
+	} else {
+		mlx4_table_put(dev, &qp_table->cmpt_table, qpn);
+		mlx4_table_put(dev, &qp_table->rdmarc_table, qpn);
+		mlx4_table_put(dev, &qp_table->altc_table, qpn);
+		mlx4_table_put(dev, &qp_table->auxc_table, qpn);
+		mlx4_table_put(dev, &qp_table->qp_table, qpn);
+	}
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
+	err = radix_tree_insert(&dev->qp_table_tree, qp->qpn & (dev->caps.num_qps - 1), qp);
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
 EXPORT_SYMBOL_GPL(mlx4_qp_alloc);
 
 void mlx4_qp_remove(struct mlx4_dev *dev, struct mlx4_qp *qp)
@@ -246,17 +317,11 @@ EXPORT_SYMBOL_GPL(mlx4_qp_remove);
 
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
 
diff --git a/drivers/net/mlx4/srq.c b/drivers/net/mlx4/srq.c
index 1377d0d..ed11f18 100644
--- a/drivers/net/mlx4/srq.c
+++ b/drivers/net/mlx4/srq.c
@@ -108,32 +108,86 @@ static int mlx4_QUERY_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 			    MLX4_CMD_TIME_CLASS_A);
 }
 
-int mlx4_srq_alloc(struct mlx4_dev *dev, u32 pdn, struct mlx4_mtt *mtt,
-		   u64 db_rec, struct mlx4_srq *srq)
+int mlx4_srq_alloc_icm(struct mlx4_dev *dev, int *srqn)
 {
 	struct mlx4_srq_table *srq_table = &mlx4_priv(dev)->srq_table;
-	struct mlx4_cmd_mailbox *mailbox;
-	struct mlx4_srq_context *srq_context;
-	u64 mtt_addr;
+	u64 out_param;
 	int err;
 
-	srq->srqn = mlx4_bitmap_alloc(&srq_table->bitmap);
-	if (srq->srqn == -1)
+	if (mlx4_is_slave(dev)) {
+		err = mlx4_cmd_imm(dev, 0, &out_param, RES_SRQ,
+						       ICM_RESERVE_AND_ALLOC,
+						       MLX4_CMD_ALLOC_RES,
+						       MLX4_CMD_TIME_CLASS_A);
+		if (err) {
+			*srqn = -1;
+			return err;
+		} else {
+			*srqn = out_param;
+			return 0;
+		}
+	}
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
+void mlx4_srq_free_icm(struct mlx4_dev *dev, int srqn)
+{
+	struct mlx4_srq_table *srq_table = &mlx4_priv(dev)->srq_table;
+	u64 in_param;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		*((u32 *) &in_param) = srqn;
+		*(((u32 *) &in_param) + 1) = 0;
+		err = mlx4_cmd(dev, in_param, RES_SRQ, ICM_RESERVE_AND_ALLOC,
+						       MLX4_CMD_FREE_RES,
+						       MLX4_CMD_TIME_CLASS_A);
+		if (err)
+			mlx4_warn(dev, "Failed freeing cq:%d\n", srqn);
+	} else {
+		mlx4_table_put(dev, &srq_table->cmpt_table, srqn);
+		mlx4_table_put(dev, &srq_table->table, srqn);
+		mlx4_bitmap_free(&srq_table->bitmap, srqn);
+	}
+}
+
+int mlx4_srq_alloc(struct mlx4_dev *dev, u32 pdn, struct mlx4_mtt *mtt,
+		   u64 db_rec, struct mlx4_srq *srq)
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
@@ -170,15 +224,8 @@ err_radix:
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
@@ -200,8 +247,7 @@ void mlx4_srq_free(struct mlx4_dev *dev, struct mlx4_srq *srq)
 		complete(&srq->free);
 	wait_for_completion(&srq->free);
 
-	mlx4_table_put(dev, &srq_table->table, srq->srqn);
-	mlx4_bitmap_free(&srq_table->bitmap, srq->srqn);
+	mlx4_srq_free_icm(dev, srq->srqn);
 }
 EXPORT_SYMBOL_GPL(mlx4_srq_free);
 
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index dda1762..dceb93f 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -120,6 +120,8 @@ enum {
 	MLX4_CMD_ACCESS_MEM	 = 0x2e,
 
 	/* virtual commands */
+	MLX4_CMD_ALLOC_RES	 = 0x50,
+	MLX4_CMD_FREE_RES	 = 0x51,
 	MLX4_CMD_GET_EVENT	 = 0x52,
 
 	/* debug commands */
-- 
1.6.1.3




