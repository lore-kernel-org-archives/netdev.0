From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/8] net/mlx4_core: Prevent VF from changing port configuration
Date: Thu, 30 Oct 2014 18:06:49 +0200
Message-ID: <1414685216-28907-2-git-send-email-ogerlitz@mellanox.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39616 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759251AbaJ3QHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 12:07:01 -0400
In-Reply-To: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Added wrapper to the ACCESS_REG command for handling guest HW
registers access, preventing write operations, but do allow reads.

This will prevent SRIOV guests to change port PTYS configuration,
such as speed/advertised link modes.

Fixes: adbc7ac5c15e ('net/mlx4_core: Introduce ACCESS_REG CMD [...]')
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  |    2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c   |   30 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    5 ++++
 3 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 916459e..1312ccf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1345,7 +1345,7 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.out_is_imm = false,
 		.encode_slave_id = false,
 		.verify = NULL,
-		.wrapper = NULL,
+		.wrapper = mlx4_ACCESS_REG_wrapper,
 	},
 	/* Native multicast commands are not available for guests */
 	{
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 72289ef..e7639e3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -2220,7 +2220,7 @@ static int mlx4_ACCESS_REG(struct mlx4_dev *dev, u16 reg_id,
 	memcpy(inbuf->reg_data, reg_data, reg_len);
 	err = mlx4_cmd_box(dev, inbox->dma, outbox->dma, 0, 0,
 			   MLX4_CMD_ACCESS_REG, MLX4_CMD_TIME_CLASS_C,
-			   MLX4_CMD_NATIVE);
+			   MLX4_CMD_WRAPPED);
 	if (err)
 		goto out;
 
@@ -2263,3 +2263,31 @@ int mlx4_ACCESS_PTYS_REG(struct mlx4_dev *dev,
 			       method, sizeof(*ptys_reg), ptys_reg);
 }
 EXPORT_SYMBOL_GPL(mlx4_ACCESS_PTYS_REG);
+
+int mlx4_ACCESS_REG_wrapper(struct mlx4_dev *dev, int slave,
+			    struct mlx4_vhcr *vhcr,
+			    struct mlx4_cmd_mailbox *inbox,
+			    struct mlx4_cmd_mailbox *outbox,
+			    struct mlx4_cmd_info *cmd)
+{
+	struct mlx4_access_reg *inbuf = inbox->buf;
+	u8 method = inbuf->method & MLX4_ACCESS_REG_METHOD_MASK;
+	u16 reg_id = be16_to_cpu(inbuf->reg_id);
+
+	if (slave != mlx4_master_func_num(dev) &&
+	    method == MLX4_ACCESS_REG_WRITE)
+		return -EPERM;
+
+	if (reg_id == MLX4_REG_ID_PTYS) {
+		struct mlx4_ptys_reg *ptys_reg =
+			(struct mlx4_ptys_reg *)inbuf->reg_data;
+
+		ptys_reg->local_port =
+			mlx4_slave_convert_port(dev, slave,
+						ptys_reg->local_port);
+	}
+
+	return mlx4_cmd_box(dev, inbox->dma, outbox->dma, vhcr->in_modifier,
+			    0, MLX4_CMD_ACCESS_REG, MLX4_CMD_TIME_CLASS_C,
+			    MLX4_CMD_NATIVE);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index de10dbb..254ec7b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1273,6 +1273,11 @@ int mlx4_QP_FLOW_STEERING_DETACH_wrapper(struct mlx4_dev *dev, int slave,
 					 struct mlx4_cmd_mailbox *inbox,
 					 struct mlx4_cmd_mailbox *outbox,
 					 struct mlx4_cmd_info *cmd);
+int mlx4_ACCESS_REG_wrapper(struct mlx4_dev *dev, int slave,
+			    struct mlx4_vhcr *vhcr,
+			    struct mlx4_cmd_mailbox *inbox,
+			    struct mlx4_cmd_mailbox *outbox,
+			    struct mlx4_cmd_info *cmd);
 
 int mlx4_get_mgm_entry_size(struct mlx4_dev *dev);
 int mlx4_get_qp_per_mgm(struct mlx4_dev *dev);
-- 
1.7.1
