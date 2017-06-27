From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/16] net/mlx5: FPGA, Add SBU bypass and reset flows
Date: Tue, 27 Jun 2017 17:28:50 +0300
Message-ID: <20170627142856.9448-11-saeedm@mellanox.com>
References: <20170627142856.9448-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50415 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753188AbdF0OaR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 10:30:17 -0400
In-Reply-To: <20170627142856.9448-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

The Innova FPGA includes shell hardware and Sandbox-Unit (SBU) hardware.
The shell hardware is handled by mlx5_core itself, while the SBU is
handled by a client driver.

Reset the SBU to a well-known initial state when initializing a new
device, and set the FPGA to bypass mode when uninitializing a device.
This allows the client driver to assume that its device has been
reset when a new device is detected.

During SBU reset, the FPGA is put into SBU-bypass mode. In this mode
packets do not pass through the SBU, so it cannot affect the network
data stream at all.

A factory-image does not have an SBU, so skip these flows.

Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c | 11 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h |  1 +
 .../net/ethernet/mellanox/mlx5/core/fpga/core.c    | 40 ++++++++++++++++++++++
 include/linux/mlx5/mlx5_ifc_fpga.h                 |  9 +++++
 4 files changed, 61 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c
index 8308ccbad85a..a5fdb4cf0b9c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c
@@ -47,6 +47,17 @@ int mlx5_fpga_caps(struct mlx5_core_dev *dev, u32 *caps)
 				    MLX5_REG_FPGA_CAP, 0, 0);
 }
 
+int mlx5_fpga_ctrl_op(struct mlx5_core_dev *dev, u8 op)
+{
+	u32 in[MLX5_ST_SZ_DW(fpga_ctrl)] = {0};
+	u32 out[MLX5_ST_SZ_DW(fpga_ctrl)];
+
+	MLX5_SET(fpga_ctrl, in, operation, op);
+
+	return mlx5_core_access_reg(dev, in, sizeof(in), out, sizeof(out),
+				    MLX5_REG_FPGA_CTRL, 0, true);
+}
+
 int mlx5_fpga_query(struct mlx5_core_dev *dev, struct mlx5_fpga_query *query)
 {
 	u32 in[MLX5_ST_SZ_DW(fpga_ctrl)] = {0};
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h
index b851580d846f..8943056163f3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h
@@ -67,6 +67,7 @@ struct mlx5_fpga_qp_counters {
 
 int mlx5_fpga_caps(struct mlx5_core_dev *dev, u32 *caps);
 int mlx5_fpga_query(struct mlx5_core_dev *dev, struct mlx5_fpga_query *query);
+int mlx5_fpga_ctrl_op(struct mlx5_core_dev *dev, u8 op);
 
 int mlx5_fpga_create_qp(struct mlx5_core_dev *dev, void *fpga_qpc,
 			u32 *fpga_qpn);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c b/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c
index 7f859a3ad5d2..31e5a2627eb8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c
@@ -102,6 +102,29 @@ static int mlx5_fpga_device_load_check(struct mlx5_fpga_device *fdev)
 	return 0;
 }
 
+int mlx5_fpga_device_brb(struct mlx5_fpga_device *fdev)
+{
+	int err;
+	struct mlx5_core_dev *mdev = fdev->mdev;
+
+	err = mlx5_fpga_ctrl_op(mdev, MLX5_FPGA_CTRL_OPERATION_SANDBOX_BYPASS_ON);
+	if (err) {
+		mlx5_fpga_err(fdev, "Failed to set bypass on: %d\n", err);
+		return err;
+	}
+	err = mlx5_fpga_ctrl_op(mdev, MLX5_FPGA_CTRL_OPERATION_RESET_SANDBOX);
+	if (err) {
+		mlx5_fpga_err(fdev, "Failed to reset SBU: %d\n", err);
+		return err;
+	}
+	err = mlx5_fpga_ctrl_op(mdev, MLX5_FPGA_CTRL_OPERATION_SANDBOX_BYPASS_OFF);
+	if (err) {
+		mlx5_fpga_err(fdev, "Failed to set bypass off: %d\n", err);
+		return err;
+	}
+	return 0;
+}
+
 int mlx5_fpga_device_start(struct mlx5_core_dev *mdev)
 {
 	struct mlx5_fpga_device *fdev = mdev->fpga;
@@ -135,8 +158,17 @@ int mlx5_fpga_device_start(struct mlx5_core_dev *mdev)
 	if (err)
 		goto err_rsvd_gid;
 
+	if (fdev->last_oper_image == MLX5_FPGA_IMAGE_USER) {
+		err = mlx5_fpga_device_brb(fdev);
+		if (err)
+			goto err_conn_init;
+	}
+
 	goto out;
 
+err_conn_init:
+	mlx5_fpga_conn_device_cleanup(fdev);
+
 err_rsvd_gid:
 	mlx5_core_unreserve_gids(mdev, max_num_qps);
 out:
@@ -172,6 +204,7 @@ void mlx5_fpga_device_stop(struct mlx5_core_dev *mdev)
 	struct mlx5_fpga_device *fdev = mdev->fpga;
 	unsigned int max_num_qps;
 	unsigned long flags;
+	int err;
 
 	if (!fdev)
 		return;
@@ -184,6 +217,13 @@ void mlx5_fpga_device_stop(struct mlx5_core_dev *mdev)
 	fdev->state = MLX5_FPGA_STATUS_NONE;
 	spin_unlock_irqrestore(&fdev->state_lock, flags);
 
+	if (fdev->last_oper_image == MLX5_FPGA_IMAGE_USER) {
+		err = mlx5_fpga_ctrl_op(mdev, MLX5_FPGA_CTRL_OPERATION_SANDBOX_BYPASS_ON);
+		if (err)
+			mlx5_fpga_err(fdev, "Failed to re-set SBU bypass on: %d\n",
+				      err);
+	}
+
 	mlx5_fpga_conn_device_cleanup(fdev);
 	max_num_qps = MLX5_CAP_FPGA(mdev, shell_caps.max_num_qps);
 	mlx5_core_unreserve_gids(mdev, max_num_qps);
diff --git a/include/linux/mlx5/mlx5_ifc_fpga.h b/include/linux/mlx5/mlx5_ifc_fpga.h
index 30d4b697fab6..0694077c9634 100644
--- a/include/linux/mlx5/mlx5_ifc_fpga.h
+++ b/include/linux/mlx5/mlx5_ifc_fpga.h
@@ -108,6 +108,15 @@ struct mlx5_ifc_fpga_cap_bits {
 	u8         reserved_at_500[0x300];
 };
 
+enum {
+	MLX5_FPGA_CTRL_OPERATION_LOAD                = 0x1,
+	MLX5_FPGA_CTRL_OPERATION_RESET               = 0x2,
+	MLX5_FPGA_CTRL_OPERATION_FLASH_SELECT        = 0x3,
+	MLX5_FPGA_CTRL_OPERATION_SANDBOX_BYPASS_ON   = 0x4,
+	MLX5_FPGA_CTRL_OPERATION_SANDBOX_BYPASS_OFF  = 0x5,
+	MLX5_FPGA_CTRL_OPERATION_RESET_SANDBOX       = 0x6,
+};
+
 struct mlx5_ifc_fpga_ctrl_bits {
 	u8         reserved_at_0[0x8];
 	u8         operation[0x8];
-- 
2.11.0
