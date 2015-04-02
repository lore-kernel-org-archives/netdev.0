From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 14/18] net/mlx4: Add SET_PORT opcode modifiers enumeration
Date: Thu,  2 Apr 2015 16:31:19 +0300
Message-ID: <1427981483-19317-15-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45715 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752796AbbDBNcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:04 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

The calls to SET_PORT used hard-code numbers, when supplying command's
opcode modifiers, fix that to use well defined constants.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c         |   11 +++++----
 drivers/net/ethernet/mellanox/mlx4/cmd.c  |    3 +-
 drivers/net/ethernet/mellanox/mlx4/port.c |   36 +++++++++++++++++------------
 include/linux/mlx4/cmd.h                  |    8 +++++-
 4 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index b972c0b..976bea7 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -587,8 +587,9 @@ static int mlx4_ib_SET_PORT(struct mlx4_ib_dev *dev, u8 port, int reset_qkey_vio
 		((__be32 *) mailbox->buf)[1] = cpu_to_be32(cap_mask);
 	}
 
-	err = mlx4_cmd(dev->dev, mailbox->dma, port, 0, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
+	err = mlx4_cmd(dev->dev, mailbox->dma, port, MLX4_SET_PORT_IB_OPCODE,
+		       MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
+		       MLX4_CMD_WRAPPED);
 
 	mlx4_free_cmd_mailbox(dev->dev, mailbox);
 	return err;
@@ -1525,8 +1526,8 @@ static void update_gids_task(struct work_struct *work)
 	memcpy(gids, gw->gids, sizeof gw->gids);
 
 	err = mlx4_cmd(dev, mailbox->dma, MLX4_SET_PORT_GID_TABLE << 8 | gw->port,
-		       1, MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
-		       MLX4_CMD_WRAPPED);
+		       MLX4_SET_PORT_ETH_OPCODE, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 	if (err)
 		pr_warn("set port command failed\n");
 	else
@@ -1564,7 +1565,7 @@ static void reset_gids_task(struct work_struct *work)
 				    IB_LINK_LAYER_ETHERNET) {
 		err = mlx4_cmd(dev, mailbox->dma,
 			       MLX4_SET_PORT_GID_TABLE << 8 | gw->port,
-			       1, MLX4_CMD_SET_PORT,
+			       MLX4_SET_PORT_ETH_OPCODE, MLX4_CMD_SET_PORT,
 			       MLX4_CMD_TIME_CLASS_B,
 			       MLX4_CMD_WRAPPED);
 		if (err)
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index bfc3584..0403fc0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -726,7 +726,8 @@ static int mlx4_cmd_wait(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 		 * specific command/input_mod/opcode_mod/fw-status to be debug.
 		 */
 		if (op == MLX4_CMD_SET_PORT && in_modifier == 1 &&
-		    op_modifier == 0 && context->fw_status == CMD_STAT_BAD_SIZE)
+		    op_modifier == MLX4_SET_PORT_IB_OPCODE &&
+		    context->fw_status == CMD_STAT_BAD_SIZE)
 			mlx4_dbg(dev, "command 0x%x failed: fw status = 0x%x\n",
 				 op, context->fw_status);
 		else
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 6a53d42..ca4488e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -123,8 +123,9 @@ static int mlx4_set_port_mac_table(struct mlx4_dev *dev, u8 port,
 
 	in_mod = MLX4_SET_PORT_MAC_TABLE << 8 | port;
 
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, MLX4_SET_PORT_ETH_OPCODE,
+		       MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
+		       MLX4_CMD_NATIVE);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
@@ -337,8 +338,9 @@ static int mlx4_set_port_vlan_table(struct mlx4_dev *dev, u8 port,
 
 	memcpy(mailbox->buf, entries, MLX4_VLAN_TABLE_SIZE);
 	in_mod = MLX4_SET_PORT_VLAN_TABLE << 8 | port;
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, MLX4_SET_PORT_ETH_OPCODE,
+		       MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
+		       MLX4_CMD_NATIVE);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 
@@ -625,9 +627,9 @@ static int mlx4_reset_roce_port_gids(struct mlx4_dev *dev, int slave,
 		       MLX4_ROCE_GID_ENTRY_SIZE);
 
 	err = mlx4_cmd(dev, mailbox->dma,
-		       ((u32)port) | (MLX4_SET_PORT_GID_TABLE << 8), 1,
-		       MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
-		       MLX4_CMD_NATIVE);
+		       ((u32)port) | (MLX4_SET_PORT_GID_TABLE << 8),
+		       MLX4_SET_PORT_ETH_OPCODE, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 	mutex_unlock(&(priv->port[port].gid_table.mutex));
 	return err;
 }
@@ -941,8 +943,9 @@ int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port, int pkey_tbl_sz)
 			(pkey_tbl_flag << MLX4_CHANGE_PORT_PKEY_TBL_SZ) |
 			(dev->caps.port_ib_mtu[port] << MLX4_SET_PORT_MTU_CAP) |
 			(vl_cap << MLX4_SET_PORT_VL_CAP));
-		err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_PORT,
-				MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
+		err = mlx4_cmd(dev, mailbox->dma, port,
+			       MLX4_SET_PORT_IB_OPCODE, MLX4_CMD_SET_PORT,
+			       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 		if (err != -ENOMEM)
 			break;
 	}
@@ -971,8 +974,9 @@ int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 	context->pfcrx = pfcrx;
 
 	in_mod = MLX4_SET_PORT_GENERAL << 8 | port;
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B,  MLX4_CMD_WRAPPED);
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, MLX4_SET_PORT_ETH_OPCODE,
+		       MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
+		       MLX4_CMD_WRAPPED);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
@@ -1008,8 +1012,9 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	context->vlan_miss = MLX4_VLAN_MISS_IDX;
 
 	in_mod = MLX4_SET_PORT_RQP_CALC << 8 | port;
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B,  MLX4_CMD_WRAPPED);
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, MLX4_SET_PORT_ETH_OPCODE,
+		       MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
+		       MLX4_CMD_WRAPPED);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
@@ -1050,8 +1055,9 @@ int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering, int enable)
 	context->steering  = steering;
 
 	in_mod = MLX4_SET_PORT_VXLAN << 8 | port;
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, MLX4_SET_PORT_ETH_OPCODE,
+		       MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
+		       MLX4_CMD_NATIVE);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index a788839..62c4d4d 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -188,7 +188,13 @@ enum {
 };
 
 enum {
-	/* set port opcode modifiers */
+	/* Set port opcode modifiers */
+	MLX4_SET_PORT_IB_OPCODE		= 0x0,
+	MLX4_SET_PORT_ETH_OPCODE	= 0x1,
+};
+
+enum {
+	/* Set port Ethernet input modifiers */
 	MLX4_SET_PORT_GENERAL   = 0x0,
 	MLX4_SET_PORT_RQP_CALC  = 0x1,
 	MLX4_SET_PORT_MAC_TABLE = 0x2,
-- 
1.7.1
