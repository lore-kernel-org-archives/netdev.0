From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 12/15] net/mlx5: Add mlxfw callbacks
Date: Fri, 23 Jun 2017 17:26:19 +0300
Message-ID: <20170623142622.16565-13-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54109 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754229AbdFWO1z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:55 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add mlx5 implementation for the ones defined by the mlxfw
shared module to be used while flashing the device firmware.

The callbacks do their job through the MCQI, MCC and MCDA registers.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       | 154 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   3 +
 2 files changed, 157 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index 3a3c4fbc7168..fa33d59ab485 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -34,6 +34,7 @@
 #include <linux/mlx5/cmd.h>
 #include <linux/module.h>
 #include "mlx5_core.h"
+#include "../../mlxfw/mlxfw.h"
 
 static int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev, u32 *out,
 				  int outlen)
@@ -337,3 +338,156 @@ static int mlx5_reg_mcqi_query(struct mlx5_core_dev *dev,
 out:
 	return err;
 }
+
+struct mlx5_mlxfw_dev {
+	struct mlxfw_dev mlxfw_dev;
+	struct mlx5_core_dev *mlx5_core_dev;
+};
+
+static int mlx5_component_query(struct mlxfw_dev *mlxfw_dev,
+				u16 component_index, u32 *p_max_size,
+				u8 *p_align_bits, u16 *p_max_write_size)
+{
+	struct mlx5_mlxfw_dev *mlx5_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlx5_mlxfw_dev, mlxfw_dev);
+	struct mlx5_core_dev *dev = mlx5_mlxfw_dev->mlx5_core_dev;
+
+	return mlx5_reg_mcqi_query(dev, component_index, p_max_size,
+				   p_align_bits, p_max_write_size);
+}
+
+static int mlx5_fsm_lock(struct mlxfw_dev *mlxfw_dev, u32 *fwhandle)
+{
+	struct mlx5_mlxfw_dev *mlx5_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlx5_mlxfw_dev, mlxfw_dev);
+	struct mlx5_core_dev *dev = mlx5_mlxfw_dev->mlx5_core_dev;
+	u8 control_state, error_code;
+	int err;
+
+	*fwhandle = 0;
+	err = mlx5_reg_mcc_query(dev, fwhandle, &error_code, &control_state);
+	if (err)
+		return err;
+
+	if (control_state != MLXFW_FSM_STATE_IDLE)
+		return -EBUSY;
+
+	return mlx5_reg_mcc_set(dev, MLX5_REG_MCC_INSTRUCTION_LOCK_UPDATE_HANDLE,
+				0, *fwhandle, 0);
+}
+
+static int mlx5_fsm_component_update(struct mlxfw_dev *mlxfw_dev, u32 fwhandle,
+				     u16 component_index, u32 component_size)
+{
+	struct mlx5_mlxfw_dev *mlx5_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlx5_mlxfw_dev, mlxfw_dev);
+	struct mlx5_core_dev *dev = mlx5_mlxfw_dev->mlx5_core_dev;
+
+	return mlx5_reg_mcc_set(dev, MLX5_REG_MCC_INSTRUCTION_UPDATE_COMPONENT,
+				component_index, fwhandle, component_size);
+}
+
+static int mlx5_fsm_block_download(struct mlxfw_dev *mlxfw_dev, u32 fwhandle,
+				   u8 *data, u16 size, u32 offset)
+{
+	struct mlx5_mlxfw_dev *mlx5_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlx5_mlxfw_dev, mlxfw_dev);
+	struct mlx5_core_dev *dev = mlx5_mlxfw_dev->mlx5_core_dev;
+
+	return mlx5_reg_mcda_set(dev, fwhandle, offset, size, data);
+}
+
+static int mlx5_fsm_component_verify(struct mlxfw_dev *mlxfw_dev, u32 fwhandle,
+				     u16 component_index)
+{
+	struct mlx5_mlxfw_dev *mlx5_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlx5_mlxfw_dev, mlxfw_dev);
+	struct mlx5_core_dev *dev = mlx5_mlxfw_dev->mlx5_core_dev;
+
+	return mlx5_reg_mcc_set(dev, MLX5_REG_MCC_INSTRUCTION_VERIFY_COMPONENT,
+				component_index, fwhandle, 0);
+}
+
+static int mlx5_fsm_activate(struct mlxfw_dev *mlxfw_dev, u32 fwhandle)
+{
+	struct mlx5_mlxfw_dev *mlx5_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlx5_mlxfw_dev, mlxfw_dev);
+	struct mlx5_core_dev *dev = mlx5_mlxfw_dev->mlx5_core_dev;
+
+	return mlx5_reg_mcc_set(dev, MLX5_REG_MCC_INSTRUCTION_ACTIVATE,	0,
+				fwhandle, 0);
+}
+
+static int mlx5_fsm_query_state(struct mlxfw_dev *mlxfw_dev, u32 fwhandle,
+				enum mlxfw_fsm_state *fsm_state,
+				enum mlxfw_fsm_state_err *fsm_state_err)
+{
+	struct mlx5_mlxfw_dev *mlx5_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlx5_mlxfw_dev, mlxfw_dev);
+	struct mlx5_core_dev *dev = mlx5_mlxfw_dev->mlx5_core_dev;
+	u8 control_state, error_code;
+	int err;
+
+	err = mlx5_reg_mcc_query(dev, &fwhandle, &error_code, &control_state);
+	if (err)
+		return err;
+
+	*fsm_state = control_state;
+	*fsm_state_err = min_t(enum mlxfw_fsm_state_err, error_code,
+			       MLXFW_FSM_STATE_ERR_MAX);
+	return 0;
+}
+
+static void mlx5_fsm_cancel(struct mlxfw_dev *mlxfw_dev, u32 fwhandle)
+{
+	struct mlx5_mlxfw_dev *mlx5_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlx5_mlxfw_dev, mlxfw_dev);
+	struct mlx5_core_dev *dev = mlx5_mlxfw_dev->mlx5_core_dev;
+
+	mlx5_reg_mcc_set(dev, MLX5_REG_MCC_INSTRUCTION_CANCEL, 0, fwhandle, 0);
+}
+
+static void mlx5_fsm_release(struct mlxfw_dev *mlxfw_dev, u32 fwhandle)
+{
+	struct mlx5_mlxfw_dev *mlx5_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlx5_mlxfw_dev, mlxfw_dev);
+	struct mlx5_core_dev *dev = mlx5_mlxfw_dev->mlx5_core_dev;
+
+	mlx5_reg_mcc_set(dev, MLX5_REG_MCC_INSTRUCTION_RELEASE_UPDATE_HANDLE, 0,
+			 fwhandle, 0);
+}
+
+static const struct mlxfw_dev_ops mlx5_mlxfw_dev_ops = {
+	.component_query	= mlx5_component_query,
+	.fsm_lock		= mlx5_fsm_lock,
+	.fsm_component_update	= mlx5_fsm_component_update,
+	.fsm_block_download	= mlx5_fsm_block_download,
+	.fsm_component_verify	= mlx5_fsm_component_verify,
+	.fsm_activate		= mlx5_fsm_activate,
+	.fsm_query_state	= mlx5_fsm_query_state,
+	.fsm_cancel		= mlx5_fsm_cancel,
+	.fsm_release		= mlx5_fsm_release
+};
+
+int mlx5_firmware_flash(struct mlx5_core_dev *dev,
+			const struct firmware *firmware)
+{
+	struct mlx5_mlxfw_dev mlx5_mlxfw_dev = {
+		.mlxfw_dev = {
+			.ops = &mlx5_mlxfw_dev_ops,
+			.psid = dev->board_id,
+			.psid_size = strlen(dev->board_id),
+		},
+		.mlx5_core_dev = dev
+	};
+
+	if (!MLX5_CAP_GEN(dev, mcam_reg)  ||
+	    !MLX5_CAP_MCAM_REG(dev, mcqi) ||
+	    !MLX5_CAP_MCAM_REG(dev, mcc)  ||
+	    !MLX5_CAP_MCAM_REG(dev, mcda)) {
+		pr_info("%s flashing isn't supported by the running FW\n", __func__);
+		return -EOPNOTSUPP;
+	}
+
+	return mlxfw_firmware_flash(&mlx5_mlxfw_dev.mlxfw_dev, firmware);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 5ccdf43e58a6..6a3d6bef7dd4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -37,6 +37,7 @@
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/if_link.h>
+#include <linux/firmware.h>
 
 #define DRIVER_NAME "mlx5_core"
 #define DRIVER_VERSION "5.0-0"
@@ -153,6 +154,8 @@ int mlx5_set_mtpps(struct mlx5_core_dev *mdev, u32 *mtpps, u32 mtpps_size);
 int mlx5_query_mtppse(struct mlx5_core_dev *mdev, u8 pin, u8 *arm, u8 *mode);
 int mlx5_set_mtppse(struct mlx5_core_dev *mdev, u8 pin, u8 arm, u8 mode);
 
+int mlx5_firmware_flash(struct mlx5_core_dev *dev, const struct firmware *fw);
+
 void mlx5e_init(void);
 void mlx5e_cleanup(void);
 
-- 
2.11.0
