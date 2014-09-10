From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 4/4] net/mlx4: Set vlan stripping policy by the right command
Date: Wed, 10 Sep 2014 16:41:56 +0300
Message-ID: <1410356516-23594-5-git-send-email-ogerlitz@mellanox.com>
References: <1410356516-23594-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45901 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750935AbaIJNmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 09:42:09 -0400
In-Reply-To: <1410356516-23594-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Changing the vlan stripping policy of the QP isn't supported by older
firmware versions for the INIT2RTR command. Nevertheless, we've used it.

Fix that by doing this policy change using INIT2RTR only if the firmware
supports it, otherwise, we call UPDATE_QP command to do the task.

Fixes: 7677fc9 ('net/mlx4: Strengthen VLAN tags/priorities enforcement in VST mode')
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c                  |    2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c            |   12 ++++++++++--
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   18 ++++++++++++++++--
 include/linux/mlx4/device.h                        |    1 +
 include/linux/mlx4/qp.h                            |   12 ++++++++++--
 5 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index af82563..162b82c 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1680,7 +1680,7 @@ static void mlx4_ib_update_qps(struct mlx4_ib_dev *ibdev,
 			goto unlock;
 
 		update_params.smac_index = new_smac_index;
-		if (mlx4_update_qp(ibdev->dev, &qp->mqp, MLX4_UPDATE_QP_SMAC,
+		if (mlx4_update_qp(ibdev->dev, qp->mqp.qpn, MLX4_UPDATE_QP_SMAC,
 				   &update_params)) {
 			release_mac = new_smac;
 			goto unlock;
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 0dc31d8..2301365 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -390,13 +390,14 @@ err_icm:
 EXPORT_SYMBOL_GPL(mlx4_qp_alloc);
 
 #define MLX4_UPDATE_QP_SUPPORTED_ATTRS MLX4_UPDATE_QP_SMAC
-int mlx4_update_qp(struct mlx4_dev *dev, struct mlx4_qp *qp,
+int mlx4_update_qp(struct mlx4_dev *dev, u32 qpn,
 		   enum mlx4_update_qp_attr attr,
 		   struct mlx4_update_qp_params *params)
 {
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_update_qp_context *cmd;
 	u64 pri_addr_path_mask = 0;
+	u64 qp_mask = 0;
 	int err = 0;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
@@ -413,9 +414,16 @@ int mlx4_update_qp(struct mlx4_dev *dev, struct mlx4_qp *qp,
 		cmd->qp_context.pri_path.grh_mylmc = params->smac_index;
 	}
 
+	if (attr & MLX4_UPDATE_QP_VSD) {
+		qp_mask |= 1ULL << MLX4_UPD_QP_MASK_VSD;
+		if (params->flags & MLX4_UPDATE_QP_PARAMS_FLAGS_VSD_ENABLE)
+			cmd->qp_context.param3 |= cpu_to_be32(MLX4_STRIP_VLAN);
+	}
+
 	cmd->primary_addr_path_mask = cpu_to_be64(pri_addr_path_mask);
+	cmd->qp_mask = cpu_to_be64(qp_mask);
 
-	err = mlx4_cmd(dev, mailbox->dma, qp->qpn & 0xffffff, 0,
+	err = mlx4_cmd(dev, mailbox->dma, qpn & 0xffffff, 0,
 		       MLX4_CMD_UPDATE_QP, MLX4_CMD_TIME_CLASS_A,
 		       MLX4_CMD_NATIVE);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 2fe61b6..5d2498d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -702,11 +702,13 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 	struct mlx4_qp_context	*qpc = inbox->buf + 8;
 	struct mlx4_vport_oper_state *vp_oper;
 	struct mlx4_priv *priv;
+	u32 qp_type;
 	int port;
 
 	port = (qpc->pri_path.sched_queue & 0x40) ? 2 : 1;
 	priv = mlx4_priv(dev);
 	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
+	qp_type	= (be32_to_cpu(qpc->flags) >> 16) & 0xff;
 
 	if (MLX4_VGT != vp_oper->state.default_vlan) {
 		/* the reserved QPs (special, proxy, tunnel)
@@ -715,8 +717,20 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 		if (mlx4_is_qp_reserved(dev, qpn))
 			return 0;
 
-		/* force strip vlan by clear vsd */
-		qpc->param3 &= ~cpu_to_be32(MLX4_STRIP_VLAN);
+		/* force strip vlan by clear vsd, MLX QP refers to Raw Ethernet */
+		if (qp_type == MLX4_QP_ST_UD ||
+		    (qp_type == MLX4_QP_ST_MLX && mlx4_is_eth(dev, port))) {
+			if (dev->caps.bmme_flags & MLX4_BMME_FLAG_VSD_INIT2RTR) {
+				*(__be32 *)inbox->buf =
+					cpu_to_be32(be32_to_cpu(*(__be32 *)inbox->buf) |
+					MLX4_QP_OPTPAR_VLAN_STRIPPING);
+				qpc->param3 &= ~cpu_to_be32(MLX4_STRIP_VLAN);
+			} else {
+				struct mlx4_update_qp_params params = {.flags = 0};
+
+				mlx4_update_qp(dev, qpn, MLX4_UPDATE_QP_VSD, &params);
+			}
+		}
 
 		if (vp_oper->state.link_state == IFLA_VF_LINK_STATE_DISABLE &&
 		    dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_UPDATE_QP) {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 511c6e0..a5b7d7c 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -209,6 +209,7 @@ enum {
 	MLX4_BMME_FLAG_TYPE_2_WIN	= 1 <<  9,
 	MLX4_BMME_FLAG_RESERVED_LKEY	= 1 << 10,
 	MLX4_BMME_FLAG_FAST_REG_WR	= 1 << 11,
+	MLX4_BMME_FLAG_VSD_INIT2RTR	= 1 << 28,
 };
 
 enum mlx4_event {
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 7040dc9..5f4e36c 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -56,7 +56,8 @@ enum mlx4_qp_optpar {
 	MLX4_QP_OPTPAR_RNR_RETRY		= 1 << 13,
 	MLX4_QP_OPTPAR_ACK_TIMEOUT		= 1 << 14,
 	MLX4_QP_OPTPAR_SCHED_QUEUE		= 1 << 16,
-	MLX4_QP_OPTPAR_COUNTER_INDEX		= 1 << 20
+	MLX4_QP_OPTPAR_COUNTER_INDEX		= 1 << 20,
+	MLX4_QP_OPTPAR_VLAN_STRIPPING		= 1 << 21,
 };
 
 enum mlx4_qp_state {
@@ -423,13 +424,20 @@ struct mlx4_wqe_inline_seg {
 
 enum mlx4_update_qp_attr {
 	MLX4_UPDATE_QP_SMAC		= 1 << 0,
+	MLX4_UPDATE_QP_VSD		= 1 << 2,
+	MLX4_UPDATE_QP_SUPPORTED_ATTRS	= (1 << 2) - 1
+};
+
+enum mlx4_update_qp_params_flags {
+	MLX4_UPDATE_QP_PARAMS_FLAGS_VSD_ENABLE		= 1 << 0,
 };
 
 struct mlx4_update_qp_params {
 	u8	smac_index;
+	u32	flags;
 };
 
-int mlx4_update_qp(struct mlx4_dev *dev, struct mlx4_qp *qp,
+int mlx4_update_qp(struct mlx4_dev *dev, u32 qpn,
 		   enum mlx4_update_qp_attr attr,
 		   struct mlx4_update_qp_params *params);
 int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
-- 
1.7.1
