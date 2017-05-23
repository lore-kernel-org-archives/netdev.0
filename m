From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/9] mlxsw: spectrum: Add the needed callbacks for mlxfw integration
Date: Tue, 23 May 2017 08:52:57 +0200
Message-ID: <20170523065301.1091-6-jiri@resnulli.us>
References: <20170523065301.1091-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33633 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761633AbdEWGxM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 02:53:12 -0400
Received: by mail-wr0-f193.google.com with SMTP id w50so9044926wrc.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 23:53:11 -0700 (PDT)
In-Reply-To: <20170523065301.1091-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The mlxfw module defines several needed callbacks in order to flash the
device's firmware. As the mlxfw module is shared between several different
drivers, those callbacks are the glue functionality that is responsible
for hardware interaction. Add those callbacks using the MCQI, MCC, MCDA
registers.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 166 +++++++++++++++++++++++++
 1 file changed, 166 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 8a165bb..b533a53 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -68,6 +68,7 @@
 #include "txheader.h"
 #include "spectrum_cnt.h"
 #include "spectrum_dpipe.h"
+#include "../mlxfw/mlxfw.h"
 
 static const char mlxsw_sp_driver_name[] = "mlxsw_spectrum";
 static const char mlxsw_sp_driver_version[] = "1.0";
@@ -140,6 +141,171 @@ MLXSW_ITEM32(tx, hdr, fid, 0x08, 0, 16);
  */
 MLXSW_ITEM32(tx, hdr, type, 0x0C, 0, 4);
 
+struct mlxsw_sp_mlxfw_dev {
+	struct mlxfw_dev mlxfw_dev;
+	struct mlxsw_sp *mlxsw_sp;
+};
+
+static int mlxsw_sp_component_query(struct mlxfw_dev *mlxfw_dev,
+				    u16 component_index, u32 *p_max_size,
+				    u8 *p_align_bits, u16 *p_max_write_size)
+{
+	struct mlxsw_sp_mlxfw_dev *mlxsw_sp_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlxsw_sp_mlxfw_dev, mlxfw_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_mlxfw_dev->mlxsw_sp;
+	char mcqi_pl[MLXSW_REG_MCQI_LEN];
+	int err;
+
+	mlxsw_reg_mcqi_pack(mcqi_pl, component_index);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(mcqi), mcqi_pl);
+	if (err)
+		return err;
+	mlxsw_reg_mcqi_unpack(mcqi_pl, p_max_size, p_align_bits,
+			      p_max_write_size);
+
+	*p_align_bits = max_t(u8, *p_align_bits, 2);
+	*p_max_write_size = min_t(u16, *p_max_write_size,
+				  MLXSW_REG_MCDA_MAX_DATA_LEN);
+	return 0;
+}
+
+static int mlxsw_sp_fsm_lock(struct mlxfw_dev *mlxfw_dev, u32 *fwhandle)
+{
+	struct mlxsw_sp_mlxfw_dev *mlxsw_sp_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlxsw_sp_mlxfw_dev, mlxfw_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_mlxfw_dev->mlxsw_sp;
+	char mcc_pl[MLXSW_REG_MCC_LEN];
+	u8 control_state;
+	int err;
+
+	mlxsw_reg_mcc_pack(mcc_pl, 0, 0, 0, 0);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(mcc), mcc_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_mcc_unpack(mcc_pl, fwhandle, NULL, &control_state);
+	if (control_state != MLXFW_FSM_STATE_IDLE)
+		return -EBUSY;
+
+	mlxsw_reg_mcc_pack(mcc_pl,
+			   MLXSW_REG_MCC_INSTRUCTION_LOCK_UPDATE_HANDLE,
+			   0, *fwhandle, 0);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mcc), mcc_pl);
+}
+
+static int mlxsw_sp_fsm_component_update(struct mlxfw_dev *mlxfw_dev,
+					 u32 fwhandle, u16 component_index,
+					 u32 component_size)
+{
+	struct mlxsw_sp_mlxfw_dev *mlxsw_sp_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlxsw_sp_mlxfw_dev, mlxfw_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_mlxfw_dev->mlxsw_sp;
+	char mcc_pl[MLXSW_REG_MCC_LEN];
+
+	mlxsw_reg_mcc_pack(mcc_pl, MLXSW_REG_MCC_INSTRUCTION_UPDATE_COMPONENT,
+			   component_index, fwhandle, component_size);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mcc), mcc_pl);
+}
+
+static int mlxsw_sp_fsm_block_download(struct mlxfw_dev *mlxfw_dev,
+				       u32 fwhandle, u8 *data, u16 size,
+				       u32 offset)
+{
+	struct mlxsw_sp_mlxfw_dev *mlxsw_sp_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlxsw_sp_mlxfw_dev, mlxfw_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_mlxfw_dev->mlxsw_sp;
+	char mcda_pl[MLXSW_REG_MCDA_LEN];
+
+	mlxsw_reg_mcda_pack(mcda_pl, fwhandle, offset, size, data);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mcda), mcda_pl);
+}
+
+static int mlxsw_sp_fsm_component_verify(struct mlxfw_dev *mlxfw_dev,
+					 u32 fwhandle, u16 component_index)
+{
+	struct mlxsw_sp_mlxfw_dev *mlxsw_sp_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlxsw_sp_mlxfw_dev, mlxfw_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_mlxfw_dev->mlxsw_sp;
+	char mcc_pl[MLXSW_REG_MCC_LEN];
+
+	mlxsw_reg_mcc_pack(mcc_pl, MLXSW_REG_MCC_INSTRUCTION_VERIFY_COMPONENT,
+			   component_index, fwhandle, 0);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mcc), mcc_pl);
+}
+
+static int mlxsw_sp_fsm_activate(struct mlxfw_dev *mlxfw_dev, u32 fwhandle)
+{
+	struct mlxsw_sp_mlxfw_dev *mlxsw_sp_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlxsw_sp_mlxfw_dev, mlxfw_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_mlxfw_dev->mlxsw_sp;
+	char mcc_pl[MLXSW_REG_MCC_LEN];
+
+	mlxsw_reg_mcc_pack(mcc_pl, MLXSW_REG_MCC_INSTRUCTION_ACTIVATE, 0,
+			   fwhandle, 0);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mcc), mcc_pl);
+}
+
+static int mlxsw_sp_fsm_query_state(struct mlxfw_dev *mlxfw_dev, u32 fwhandle,
+				    enum mlxfw_fsm_state *fsm_state,
+				    enum mlxfw_fsm_state_err *fsm_state_err)
+{
+	struct mlxsw_sp_mlxfw_dev *mlxsw_sp_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlxsw_sp_mlxfw_dev, mlxfw_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_mlxfw_dev->mlxsw_sp;
+	char mcc_pl[MLXSW_REG_MCC_LEN];
+	u8 control_state;
+	u8 error_code;
+	int err;
+
+	mlxsw_reg_mcc_pack(mcc_pl, 0, 0, fwhandle, 0);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(mcc), mcc_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_mcc_unpack(mcc_pl, NULL, &error_code, &control_state);
+	*fsm_state = control_state;
+	*fsm_state_err = min_t(enum mlxfw_fsm_state_err, error_code,
+			       MLXFW_FSM_STATE_ERR_MAX);
+	return 0;
+}
+
+static void mlxsw_sp_fsm_cancel(struct mlxfw_dev *mlxfw_dev, u32 fwhandle)
+{
+	struct mlxsw_sp_mlxfw_dev *mlxsw_sp_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlxsw_sp_mlxfw_dev, mlxfw_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_mlxfw_dev->mlxsw_sp;
+	char mcc_pl[MLXSW_REG_MCC_LEN];
+
+	mlxsw_reg_mcc_pack(mcc_pl, MLXSW_REG_MCC_INSTRUCTION_CANCEL, 0,
+			   fwhandle, 0);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mcc), mcc_pl);
+}
+
+static void mlxsw_sp_fsm_release(struct mlxfw_dev *mlxfw_dev, u32 fwhandle)
+{
+	struct mlxsw_sp_mlxfw_dev *mlxsw_sp_mlxfw_dev =
+		container_of(mlxfw_dev, struct mlxsw_sp_mlxfw_dev, mlxfw_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_mlxfw_dev->mlxsw_sp;
+	char mcc_pl[MLXSW_REG_MCC_LEN];
+
+	mlxsw_reg_mcc_pack(mcc_pl,
+			   MLXSW_REG_MCC_INSTRUCTION_RELEASE_UPDATE_HANDLE, 0,
+			   fwhandle, 0);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mcc), mcc_pl);
+}
+
+static const struct mlxfw_dev_ops mlxsw_sp_mlxfw_dev_ops = {
+	.component_query	= mlxsw_sp_component_query,
+	.fsm_lock		= mlxsw_sp_fsm_lock,
+	.fsm_component_update	= mlxsw_sp_fsm_component_update,
+	.fsm_block_download	= mlxsw_sp_fsm_block_download,
+	.fsm_component_verify	= mlxsw_sp_fsm_component_verify,
+	.fsm_activate		= mlxsw_sp_fsm_activate,
+	.fsm_query_state	= mlxsw_sp_fsm_query_state,
+	.fsm_cancel		= mlxsw_sp_fsm_cancel,
+	.fsm_release		= mlxsw_sp_fsm_release
+};
+
 int mlxsw_sp_flow_counter_get(struct mlxsw_sp *mlxsw_sp,
 			      unsigned int counter_index, u64 *packets,
 			      u64 *bytes)
-- 
2.9.3
