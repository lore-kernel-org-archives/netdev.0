From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 04/10] net/mlx4_core: Adjust command timeouts to conform to the firmware spec
Date: Tue, 27 Jan 2015 11:32:53 +0200
Message-ID: <1422351179-27284-5-git-send-email-amirv@mellanox.com>
References: <1422351179-27284-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:56305 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751895AbbA0Jdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 04:33:37 -0500
In-Reply-To: <1422351179-27284-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The firmware spec states that the timeout for all commands should be 60 seconds.

In the past, the spec indicated that there were several classes of timeout
(short, medium, and long).  The driver has these different timeout classes.
We leave the class differentiation in the driver as-is (to protect against any
future spec changes), but set the timeout for all classes to be 60 seconds.

In addition, we fix a few commands which had hard-coded numeric timeouts specified.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 19 ++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/mr.c |  4 ++--
 include/linux/mlx4/cmd.h                |  6 +++---
 3 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 2aa7c23..0c90d10 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1774,8 +1774,8 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 		MLX4_PUT(inbox, parser_params,	INIT_HCA_VXLAN_OFFSET);
 	}
 
-	err = mlx4_cmd(dev, mailbox->dma, 0, 0, MLX4_CMD_INIT_HCA, 10000,
-		       MLX4_CMD_NATIVE);
+	err = mlx4_cmd(dev, mailbox->dma, 0, 0, MLX4_CMD_INIT_HCA,
+		       MLX4_CMD_TIME_CLASS_C, MLX4_CMD_NATIVE);
 
 	if (err)
 		mlx4_err(dev, "INIT_HCA returns %d\n", err);
@@ -2029,7 +2029,7 @@ int mlx4_CLOSE_PORT_wrapper(struct mlx4_dev *dev, int slave,
 	if (dev->caps.port_mask[port] != MLX4_PORT_TYPE_IB) {
 		if (priv->mfunc.master.init_port_ref[port] == 1) {
 			err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT,
-				       1000, MLX4_CMD_NATIVE);
+				       MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 			if (err)
 				return err;
 		}
@@ -2040,7 +2040,7 @@ int mlx4_CLOSE_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			if (!priv->mfunc.master.qp0_state[port].qp0_active &&
 			    priv->mfunc.master.qp0_state[port].port_active) {
 				err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT,
-					       1000, MLX4_CMD_NATIVE);
+					       MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 				if (err)
 					return err;
 				priv->mfunc.master.slave_state[slave].init_port_mask &= ~(1 << port);
@@ -2055,15 +2055,15 @@ int mlx4_CLOSE_PORT_wrapper(struct mlx4_dev *dev, int slave,
 
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port)
 {
-	return mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT, 1000,
-			MLX4_CMD_WRAPPED);
+	return mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT,
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 EXPORT_SYMBOL_GPL(mlx4_CLOSE_PORT);
 
 int mlx4_CLOSE_HCA(struct mlx4_dev *dev, int panic)
 {
-	return mlx4_cmd(dev, 0, 0, panic, MLX4_CMD_CLOSE_HCA, 1000,
-			MLX4_CMD_NATIVE);
+	return mlx4_cmd(dev, 0, 0, panic, MLX4_CMD_CLOSE_HCA,
+			MLX4_CMD_TIME_CLASS_C, MLX4_CMD_NATIVE);
 }
 
 struct mlx4_config_dev {
@@ -2202,7 +2202,8 @@ int mlx4_SET_ICM_SIZE(struct mlx4_dev *dev, u64 icm_size, u64 *aux_pages)
 int mlx4_NOP(struct mlx4_dev *dev)
 {
 	/* Input modifier of 0x1f means "finish as soon as possible." */
-	return mlx4_cmd(dev, 0, 0x1f, 0, MLX4_CMD_NOP, 100, MLX4_CMD_NATIVE);
+	return mlx4_cmd(dev, 0, 0x1f, 0, MLX4_CMD_NOP, MLX4_CMD_TIME_CLASS_A,
+			MLX4_CMD_NATIVE);
 }
 
 int mlx4_get_phys_port_id(struct mlx4_dev *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 8dbdf1d..d21e884 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -1155,7 +1155,7 @@ EXPORT_SYMBOL_GPL(mlx4_fmr_free);
 
 int mlx4_SYNC_TPT(struct mlx4_dev *dev)
 {
-	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_SYNC_TPT, 1000,
-			MLX4_CMD_NATIVE);
+	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_SYNC_TPT,
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 }
 EXPORT_SYMBOL_GPL(mlx4_SYNC_TPT);
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index c989442..ae95adc 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -165,9 +165,9 @@ enum {
 };
 
 enum {
-	MLX4_CMD_TIME_CLASS_A	= 10000,
-	MLX4_CMD_TIME_CLASS_B	= 10000,
-	MLX4_CMD_TIME_CLASS_C	= 10000,
+	MLX4_CMD_TIME_CLASS_A	= 60000,
+	MLX4_CMD_TIME_CLASS_B	= 60000,
+	MLX4_CMD_TIME_CLASS_C	= 60000,
 };
 
 enum {
-- 
1.9.3
