From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_core: Add UPDATE_QP SRIOV wrapper support
Date: Thu, 15 May 2014 15:29:27 +0300
Message-ID: <1400156968-29633-2-git-send-email-ogerlitz@mellanox.com>
References: <1400156968-29633-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, matanb@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40649 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753550AbaEOM3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 08:29:34 -0400
In-Reply-To: <1400156968-29633-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

This patch adds UPDATE_QP SRIOV wrapper support.

The mechanism is a general one, but currently only source MAC
index changes are allowed for VFs.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    6 ++
 drivers/net/ethernet/mellanox/mlx4/qp.c            |   35 +++++++++++++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   54 ++++++++++++++++++++
 include/linux/mlx4/qp.h                            |   11 ++++
 5 files changed, 108 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 78099ea..92d3249 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1253,12 +1253,12 @@ static struct mlx4_cmd_info cmd_info[] = {
 	},
 	{
 		.opcode = MLX4_CMD_UPDATE_QP,
-		.has_inbox = false,
+		.has_inbox = true,
 		.has_outbox = false,
 		.out_is_imm = false,
 		.encode_slave_id = false,
 		.verify = NULL,
-		.wrapper = mlx4_CMD_EPERM_wrapper
+		.wrapper = mlx4_UPDATE_QP_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_GET_OP_REQ,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index f9c4651..212cea4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1195,6 +1195,12 @@ int mlx4_QP_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 			   struct mlx4_cmd_mailbox *outbox,
 			   struct mlx4_cmd_info *cmd);
 
+int mlx4_UPDATE_QP_wrapper(struct mlx4_dev *dev, int slave,
+			   struct mlx4_vhcr *vhcr,
+			   struct mlx4_cmd_mailbox *inbox,
+			   struct mlx4_cmd_mailbox *outbox,
+			   struct mlx4_cmd_info *cmd);
+
 int mlx4_PROMISC_wrapper(struct mlx4_dev *dev, int slave,
 			 struct mlx4_vhcr *vhcr,
 			 struct mlx4_cmd_mailbox *inbox,
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 61d64eb..fbd32af 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -389,6 +389,41 @@ err_icm:
 
 EXPORT_SYMBOL_GPL(mlx4_qp_alloc);
 
+#define MLX4_UPDATE_QP_SUPPORTED_ATTRS MLX4_UPDATE_QP_SMAC
+int mlx4_update_qp(struct mlx4_dev *dev, struct mlx4_qp *qp,
+		   enum mlx4_update_qp_attr attr,
+		   struct mlx4_update_qp_params *params)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_update_qp_context *cmd;
+	u64 pri_addr_path_mask = 0;
+	int err = 0;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	cmd = (struct mlx4_update_qp_context *)mailbox->buf;
+
+	if (!attr || (attr & ~MLX4_UPDATE_QP_SUPPORTED_ATTRS))
+		return -EINVAL;
+
+	if (attr & MLX4_UPDATE_QP_SMAC) {
+		pri_addr_path_mask |= 1ULL << MLX4_UPD_QP_PATH_MASK_MAC_INDEX;
+		cmd->qp_context.pri_path.grh_mylmc = params->smac_index;
+	}
+
+	cmd->primary_addr_path_mask = cpu_to_be64(pri_addr_path_mask);
+
+	err = mlx4_cmd(dev, mailbox->dma, qp->qpn & 0xffffff, 0,
+		       MLX4_CMD_UPDATE_QP, MLX4_CMD_TIME_CLASS_A,
+		       MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx4_update_qp);
+
 void mlx4_qp_remove(struct mlx4_dev *dev, struct mlx4_qp *qp)
 {
 	struct mlx4_qp_table *qp_table = &mlx4_priv(dev)->qp_table;
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 1c3fdd4..8f1254a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3895,6 +3895,60 @@ static int add_eth_header(struct mlx4_dev *dev, int slave,
 
 }
 
+#define MLX4_UPD_QP_PATH_MASK_SUPPORTED (1ULL << MLX4_UPD_QP_PATH_MASK_MAC_INDEX)
+int mlx4_UPDATE_QP_wrapper(struct mlx4_dev *dev, int slave,
+			   struct mlx4_vhcr *vhcr,
+			   struct mlx4_cmd_mailbox *inbox,
+			   struct mlx4_cmd_mailbox *outbox,
+			   struct mlx4_cmd_info *cmd_info)
+{
+	int err;
+	u32 qpn = vhcr->in_modifier & 0xffffff;
+	struct res_qp *rqp;
+	u64 mac;
+	unsigned port;
+	u64 pri_addr_path_mask;
+	struct mlx4_update_qp_context *cmd;
+	int smac_index;
+
+	cmd = (struct mlx4_update_qp_context *)inbox->buf;
+
+	pri_addr_path_mask = be64_to_cpu(cmd->primary_addr_path_mask);
+	if (cmd->qp_mask || cmd->secondary_addr_path_mask ||
+	    (pri_addr_path_mask & ~MLX4_UPD_QP_PATH_MASK_SUPPORTED))
+		return -EPERM;
+
+	/* Just change the smac for the QP */
+	err = get_res(dev, slave, qpn, RES_QP, &rqp);
+	if (err) {
+		mlx4_err(dev, "Updating qpn 0x%x for slave %d rejected\n", qpn, slave);
+		return err;
+	}
+
+	port = (rqp->sched_queue >> 6 & 1) + 1;
+	smac_index = cmd->qp_context.pri_path.grh_mylmc;
+	err = mac_find_smac_ix_in_slave(dev, slave, port,
+					smac_index, &mac);
+	if (err) {
+		mlx4_err(dev, "Failed to update qpn 0x%x, MAC is invalid. smac_ix: %d\n",
+			 qpn, smac_index);
+		goto err_mac;
+	}
+
+	err = mlx4_cmd(dev, inbox->dma,
+		       vhcr->in_modifier, 0,
+		       MLX4_CMD_UPDATE_QP, MLX4_CMD_TIME_CLASS_A,
+		       MLX4_CMD_NATIVE);
+	if (err) {
+		mlx4_err(dev, "Failed to update qpn on qpn 0x%x, command failed\n", qpn);
+		goto err_mac;
+	}
+
+err_mac:
+	put_res(dev, slave, qpn, RES_QP);
+	return err;
+}
+
 int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 					 struct mlx4_vhcr *vhcr,
 					 struct mlx4_cmd_mailbox *inbox,
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index b66e761..7040dc9 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -421,6 +421,17 @@ struct mlx4_wqe_inline_seg {
 	__be32			byte_count;
 };
 
+enum mlx4_update_qp_attr {
+	MLX4_UPDATE_QP_SMAC		= 1 << 0,
+};
+
+struct mlx4_update_qp_params {
+	u8	smac_index;
+};
+
+int mlx4_update_qp(struct mlx4_dev *dev, struct mlx4_qp *qp,
+		   enum mlx4_update_qp_attr attr,
+		   struct mlx4_update_qp_params *params);
 int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		   enum mlx4_qp_state cur_state, enum mlx4_qp_state new_state,
 		   struct mlx4_qp_context *context, enum mlx4_qp_optpar optpar,
-- 
1.7.1
