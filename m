From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 15/15] net/mlx5: Add fast unload support in shutdown flow
Date: Fri, 16 Jun 2017 00:42:52 +0300
Message-ID: <20170615214252.30140-16-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
        Maor Gottlieb <maorg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32953 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752323AbdFOVnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:06 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Adding a support to flush all HW resources with one FW command and
skip all the heavy unload flows of the driver on kernel shutdown.
There's no need to free all the SW context since a new fresh kernel
will be loaded afterwards.

Regarding the FW resources, they should be closed, otherwise we will
have leakage in the FW. To accelerate this flow, we execute one command
in the beginning that tells the FW that the driver isn't going to close
any of the FW resources and asks the FW to clean up everything.
Once the commands complete, it's safe to close the PCI resources and
finish the routine.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       | 28 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  4 +--
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 32 ++++++++++++++++++++--
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  3 +-
 include/linux/mlx5/mlx5_ifc.h                      | 14 ++++++++--
 5 files changed, 73 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index 1bc14d0fded8..e9489e8d08bb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -195,3 +195,31 @@ int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev)
 	MLX5_SET(teardown_hca_in, in, opcode, MLX5_CMD_OP_TEARDOWN_HCA);
 	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
 }
+
+int mlx5_cmd_force_teardown_hca(struct mlx5_core_dev *dev)
+{
+	u32 out[MLX5_ST_SZ_DW(teardown_hca_out)] = {0};
+	u32 in[MLX5_ST_SZ_DW(teardown_hca_in)] = {0};
+	int force_state;
+	int ret;
+
+	if (!MLX5_CAP_GEN(dev, force_teardown)) {
+		mlx5_core_dbg(dev, "force teardown is not supported in the firmware\n");
+		return -EOPNOTSUPP;
+	}
+
+	MLX5_SET(teardown_hca_in, in, opcode, MLX5_CMD_OP_TEARDOWN_HCA);
+	MLX5_SET(teardown_hca_in, in, profile, MLX5_TEARDOWN_HCA_IN_PROFILE_FORCE_CLOSE);
+
+	ret = mlx5_cmd_exec_polling(dev, in, sizeof(in), out, sizeof(out));
+	if (ret)
+		return ret;
+
+	force_state = MLX5_GET(teardown_hca_out, out, force_state);
+	if (force_state == MLX5_TEARDOWN_HCA_OUT_FORCE_STATE_FAIL) {
+		mlx5_core_err(dev, "teardown with force mode failed\n");
+		return -EIO;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index c6679b21884e..0648a659b21d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -111,14 +111,14 @@ static int in_fatal(struct mlx5_core_dev *dev)
 	return 0;
 }
 
-void mlx5_enter_error_state(struct mlx5_core_dev *dev)
+void mlx5_enter_error_state(struct mlx5_core_dev *dev, bool force)
 {
 	mutex_lock(&dev->intf_state_mutex);
 	if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR)
 		goto unlock;
 
 	mlx5_core_err(dev, "start\n");
-	if (pci_channel_offline(dev->pdev) || in_fatal(dev)) {
+	if (pci_channel_offline(dev->pdev) || in_fatal(dev) || force) {
 		dev->state = MLX5_DEVICE_STATE_INTERNAL_ERROR;
 		trigger_cmd_completions(dev);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 39e7e523a0dd..715eeab59999 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1418,7 +1418,7 @@ static pci_ers_result_t mlx5_pci_err_detected(struct pci_dev *pdev,
 
 	dev_info(&pdev->dev, "%s was called\n", __func__);
 
-	mlx5_enter_error_state(dev);
+	mlx5_enter_error_state(dev, false);
 	mlx5_unload_one(dev, priv, false);
 	/* In case of kernel call drain the health wq */
 	if (state) {
@@ -1505,15 +1505,43 @@ static const struct pci_error_handlers mlx5_err_handler = {
 	.resume		= mlx5_pci_resume
 };
 
+static int mlx5_try_fast_unload(struct mlx5_core_dev *dev)
+{
+	int ret;
+
+	if (!MLX5_CAP_GEN(dev, force_teardown)) {
+		mlx5_core_dbg(dev, "force teardown is not supported in the firmware\n");
+		return -EOPNOTSUPP;
+	}
+
+	if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
+		mlx5_core_dbg(dev, "Device in internal error state, giving up\n");
+		return -EAGAIN;
+	}
+
+	ret = mlx5_cmd_force_teardown_hca(dev);
+	if (ret) {
+		mlx5_core_dbg(dev, "Firmware couldn't do fast unload error: %d\n", ret);
+		return ret;
+	}
+
+	mlx5_enter_error_state(dev, true);
+
+	return 0;
+}
+
 static void shutdown(struct pci_dev *pdev)
 {
 	struct mlx5_core_dev *dev  = pci_get_drvdata(pdev);
 	struct mlx5_priv *priv = &dev->priv;
+	int err;
 
 	dev_info(&pdev->dev, "Shutdown was called\n");
 	/* Notify mlx5 clients that the kernel is being shut down */
 	set_bit(MLX5_INTERFACE_STATE_SHUTDOWN, &dev->intf_state);
-	mlx5_unload_one(dev, priv, false);
+	err = mlx5_try_fast_unload(dev);
+	if (err)
+		mlx5_unload_one(dev, priv, false);
 	mlx5_pci_disable_device(dev);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 1fd279c0338d..5ccdf43e58a6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -83,12 +83,13 @@ int mlx5_query_hca_caps(struct mlx5_core_dev *dev);
 int mlx5_query_board_id(struct mlx5_core_dev *dev);
 int mlx5_cmd_init_hca(struct mlx5_core_dev *dev);
 int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev);
+int mlx5_cmd_force_teardown_hca(struct mlx5_core_dev *dev);
 void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
 		     unsigned long param);
 void mlx5_core_page_fault(struct mlx5_core_dev *dev,
 			  struct mlx5_pagefault *pfault);
 void mlx5_port_module_event(struct mlx5_core_dev *dev, struct mlx5_eqe *eqe);
-void mlx5_enter_error_state(struct mlx5_core_dev *dev);
+void mlx5_enter_error_state(struct mlx5_core_dev *dev, bool force);
 void mlx5_disable_device(struct mlx5_core_dev *dev);
 void mlx5_recover_device(struct mlx5_core_dev *dev);
 int mlx5_sriov_init(struct mlx5_core_dev *dev);
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 1fd144662491..e86ef880a149 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -801,7 +801,8 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         max_indirection[0x8];
 	u8         fixed_buffer_size[0x1];
 	u8         log_max_mrw_sz[0x7];
-	u8         reserved_at_110[0x2];
+	u8         force_teardown[0x1];
+	u8         reserved_at_111[0x1];
 	u8         log_max_bsf_list_size[0x6];
 	u8         umr_extended_translation_offset[0x1];
 	u8         null_mkey[0x1];
@@ -3094,18 +3095,25 @@ struct mlx5_ifc_tsar_element_bits {
 	u8         reserved_at_10[0x10];
 };
 
+enum {
+	MLX5_TEARDOWN_HCA_OUT_FORCE_STATE_SUCCESS = 0x0,
+	MLX5_TEARDOWN_HCA_OUT_FORCE_STATE_FAIL = 0x1,
+};
+
 struct mlx5_ifc_teardown_hca_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
 
 	u8         syndrome[0x20];
 
-	u8         reserved_at_40[0x40];
+	u8         reserved_at_40[0x3f];
+
+	u8         force_state[0x1];
 };
 
 enum {
 	MLX5_TEARDOWN_HCA_IN_PROFILE_GRACEFUL_CLOSE  = 0x0,
-	MLX5_TEARDOWN_HCA_IN_PROFILE_PANIC_CLOSE     = 0x1,
+	MLX5_TEARDOWN_HCA_IN_PROFILE_FORCE_CLOSE     = 0x1,
 };
 
 struct mlx5_ifc_teardown_hca_in_bits {
-- 
2.11.0
