From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/6] net/mlx4_core: Add immediate activate for VGT->VST->VGT
Date: Thu,  7 Nov 2013 12:19:51 +0200
Message-ID: <1383819594-24070-4-git-send-email-amirv@mellanox.com>
References: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33156 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753777Ab3KGKUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 05:20:19 -0500
In-Reply-To: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Allow immediate activate of VGT->VST and VST->VGT transitions, without
the need of rebinding in mlx4_master_immediate_activate_vlan_qos().

Also in struct res_qp: add qp parameters (vlan_index,fvl,vlan_cntrol..)
to the saved set, in order to restore when move to VGT.
 - Clear at mlx4_RST2INIT_QP_wrapper()
 - Save at mlx4_INIT2RTR_QP_wrapper()
 - Restore at mlx4_vf_immed_vlan_work_handler()

Update mlx4_vf_immed_vlan_work_handler() to support VGT.


Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           | 34 ++++------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 79 ++++++++++++++++++----
 2 files changed, 81 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 7207dcd..1e9970d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1539,11 +1539,6 @@ out:
 	return ret;
 }
 
-static int calculate_transition(u16 oper_vlan, u16 admin_vlan)
-{
-	return (2 * (oper_vlan == MLX4_VGT) + (admin_vlan == MLX4_VGT));
-}
-
 static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 					    int slave, int port)
 {
@@ -1553,7 +1548,6 @@ static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 	struct mlx4_dev *dev = &(priv->dev);
 	int err;
 	int admin_vlan_ix = NO_INDX;
-	enum mlx4_vlan_transition vlan_trans;
 
 	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
 	vp_admin = &priv->mfunc.master.vf_admin[slave].vport[port];
@@ -1563,12 +1557,8 @@ static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 	    vp_oper->state.link_state == vp_admin->link_state)
 		return 0;
 
-	vlan_trans = calculate_transition(vp_oper->state.default_vlan,
-					  vp_admin->default_vlan);
-
 	if (!(priv->mfunc.master.slave_state[slave].active &&
-	      dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_UPDATE_QP &&
-	      vlan_trans == MLX4_VLAN_TRANSITION_VST_VST)) {
+	      dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_UPDATE_QP)) {
 		/* even if the UPDATE_QP command isn't supported, we still want
 		 * to set this VF link according to the admin directive
 		 */
@@ -1586,15 +1576,19 @@ static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 		return -ENOMEM;
 
 	if (vp_oper->state.default_vlan != vp_admin->default_vlan) {
-		err = __mlx4_register_vlan(&priv->dev, port,
-					   vp_admin->default_vlan,
-					   &admin_vlan_ix);
-		if (err) {
-			kfree(work);
-			mlx4_warn((&priv->dev),
-				  "No vlan resources slave %d, port %d\n",
-				  slave, port);
-			return err;
+		if (MLX4_VGT != vp_admin->default_vlan) {
+			err = __mlx4_register_vlan(&priv->dev, port,
+						   vp_admin->default_vlan,
+						   &admin_vlan_ix);
+			if (err) {
+				kfree(work);
+				mlx4_warn((&priv->dev),
+					  "No vlan resources slave %d, port %d\n",
+					  slave, port);
+				return err;
+			}
+		} else {
+			admin_vlan_ix = NO_INDX;
 		}
 		work->flags |= MLX4_VF_IMMED_VLAN_FLAG_VLAN;
 		mlx4_dbg((&(priv->dev)),
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index b1603e2..2f3f2bc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -110,7 +110,14 @@ struct res_qp {
 	int			local_qpn;
 	atomic_t		ref_count;
 	u32			qpc_flags;
+	/* saved qp params before VST enforcement in order to restore on VGT */
 	u8			sched_queue;
+	__be32			param3;
+	u8			vlan_control;
+	u8			fvl_rx;
+	u8			pri_path_fl;
+	u8			vlan_index;
+	u8			feup;
 };
 
 enum res_mtt_states {
@@ -2568,6 +2575,12 @@ int mlx4_RST2INIT_QP_wrapper(struct mlx4_dev *dev, int slave,
 		return err;
 	qp->local_qpn = local_qpn;
 	qp->sched_queue = 0;
+	qp->param3 = 0;
+	qp->vlan_control = 0;
+	qp->fvl_rx = 0;
+	qp->pri_path_fl = 0;
+	qp->vlan_index = 0;
+	qp->feup = 0;
 	qp->qpc_flags = be32_to_cpu(qpc->flags);
 
 	err = get_res(dev, slave, mtt_base, RES_MTT, &mtt);
@@ -3294,6 +3307,12 @@ int mlx4_INIT2RTR_QP_wrapper(struct mlx4_dev *dev, int slave,
 	int qpn = vhcr->in_modifier & 0x7fffff;
 	struct res_qp *qp;
 	u8 orig_sched_queue;
+	__be32	orig_param3 = qpc->param3;
+	u8 orig_vlan_control = qpc->pri_path.vlan_control;
+	u8 orig_fvl_rx = qpc->pri_path.fvl_rx;
+	u8 orig_pri_path_fl = qpc->pri_path.fl;
+	u8 orig_vlan_index = qpc->pri_path.vlan_index;
+	u8 orig_feup = qpc->pri_path.feup;
 
 	err = verify_qp_parameters(dev, inbox, QP_TRANS_INIT2RTR, slave);
 	if (err)
@@ -3321,9 +3340,15 @@ out:
 	 * essentially the QOS value provided by the VF. This will be useful
 	 * if we allow dynamic changes from VST back to VGT
 	 */
-	if (!err)
+	if (!err) {
 		qp->sched_queue = orig_sched_queue;
-
+		qp->param3	= orig_param3;
+		qp->vlan_control = orig_vlan_control;
+		qp->fvl_rx	=  orig_fvl_rx;
+		qp->pri_path_fl = orig_pri_path_fl;
+		qp->vlan_index  = orig_vlan_index;
+		qp->feup	= orig_feup;
+	}
 	put_res(dev, slave, qpn, RES_QP);
 	return err;
 }
@@ -4437,13 +4462,20 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 		&tracker->slave_list[work->slave].res_list[RES_QP];
 	struct res_qp *qp;
 	struct res_qp *tmp;
-	u64 qp_mask = ((1ULL << MLX4_UPD_QP_PATH_MASK_ETH_TX_BLOCK_UNTAGGED) |
+	u64 qp_path_mask_vlan_ctrl =
+		       ((1ULL << MLX4_UPD_QP_PATH_MASK_ETH_TX_BLOCK_UNTAGGED) |
 		       (1ULL << MLX4_UPD_QP_PATH_MASK_ETH_TX_BLOCK_1P) |
 		       (1ULL << MLX4_UPD_QP_PATH_MASK_ETH_TX_BLOCK_TAGGED) |
 		       (1ULL << MLX4_UPD_QP_PATH_MASK_ETH_RX_BLOCK_UNTAGGED) |
 		       (1ULL << MLX4_UPD_QP_PATH_MASK_ETH_RX_BLOCK_1P) |
-		       (1ULL << MLX4_UPD_QP_PATH_MASK_ETH_RX_BLOCK_TAGGED) |
-		       (1ULL << MLX4_UPD_QP_PATH_MASK_VLAN_INDEX) |
+		       (1ULL << MLX4_UPD_QP_PATH_MASK_ETH_RX_BLOCK_TAGGED));
+
+	u64 qp_path_mask = ((1ULL << MLX4_UPD_QP_PATH_MASK_VLAN_INDEX) |
+		       (1ULL << MLX4_UPD_QP_PATH_MASK_FVL) |
+		       (1ULL << MLX4_UPD_QP_PATH_MASK_CV) |
+		       (1ULL << MLX4_UPD_QP_PATH_MASK_ETH_HIDE_CQE_VLAN) |
+		       (1ULL << MLX4_UPD_QP_PATH_MASK_FEUP) |
+		       (1ULL << MLX4_UPD_QP_PATH_MASK_FVL_RX) |
 		       (1ULL << MLX4_UPD_QP_PATH_MASK_SCHED_QUEUE));
 
 	int err;
@@ -4475,9 +4507,7 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 			MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED;
 
 	upd_context = mailbox->buf;
-	upd_context->primary_addr_path_mask = cpu_to_be64(qp_mask);
-	upd_context->qp_context.pri_path.vlan_control = vlan_control;
-	upd_context->qp_context.pri_path.vlan_index = work->vlan_ix;
+	upd_context->qp_mask = cpu_to_be64(MLX4_UPD_QP_MASK_VSD);
 
 	spin_lock_irq(mlx4_tlock(dev));
 	list_for_each_entry_safe(qp, tmp, qp_list, com.list) {
@@ -4495,10 +4525,35 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 				spin_lock_irq(mlx4_tlock(dev));
 				continue;
 			}
-			upd_context->qp_context.pri_path.sched_queue =
-				qp->sched_queue & 0xC7;
-			upd_context->qp_context.pri_path.sched_queue |=
-				((work->qos & 0x7) << 3);
+			if (MLX4_QP_ST_RC == ((qp->qpc_flags >> 16) & 0xff))
+				upd_context->primary_addr_path_mask = cpu_to_be64(qp_path_mask);
+			else
+				upd_context->primary_addr_path_mask =
+					cpu_to_be64(qp_path_mask | qp_path_mask_vlan_ctrl);
+			if (work->vlan_id == MLX4_VGT) {
+				upd_context->qp_context.param3 = qp->param3;
+				upd_context->qp_context.pri_path.vlan_control = qp->vlan_control;
+				upd_context->qp_context.pri_path.fvl_rx = qp->fvl_rx;
+				upd_context->qp_context.pri_path.vlan_index = qp->vlan_index;
+				upd_context->qp_context.pri_path.fl = qp->pri_path_fl;
+				upd_context->qp_context.pri_path.feup = qp->feup;
+				upd_context->qp_context.pri_path.sched_queue =
+					qp->sched_queue;
+			} else {
+				upd_context->qp_context.param3 = qp->param3 & ~cpu_to_be32(MLX4_STRIP_VLAN);
+				upd_context->qp_context.pri_path.vlan_control = vlan_control;
+				upd_context->qp_context.pri_path.vlan_index = work->vlan_ix;
+				upd_context->qp_context.pri_path.fvl_rx =
+					qp->fvl_rx | MLX4_FVL_RX_FORCE_ETH_VLAN;
+				upd_context->qp_context.pri_path.fl =
+					qp->pri_path_fl | MLX4_FL_CV | MLX4_FL_ETH_HIDE_CQE_VLAN;
+				upd_context->qp_context.pri_path.feup =
+					qp->feup | MLX4_FEUP_FORCE_ETH_UP | MLX4_FVL_FORCE_ETH_VLAN;
+				upd_context->qp_context.pri_path.sched_queue =
+					qp->sched_queue & 0xC7;
+				upd_context->qp_context.pri_path.sched_queue |=
+					((work->qos & 0x7) << 3);
+			}
 
 			err = mlx4_cmd(dev, mailbox->dma,
 				       qp->local_qpn & 0xffffff,
-- 
1.8.3.4
