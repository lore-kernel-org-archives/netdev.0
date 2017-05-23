From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/8] mlxsw: reg: Add Management Component Control register
Date: Tue, 23 May 2017 21:56:25 +0200
Message-ID: <20170523195630.6460-4-jiri@resnulli.us>
References: <20170523195630.6460-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com, Yuval.Mintz@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33112 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968114AbdEWT4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:56:38 -0400
Received: by mail-wm0-f65.google.com with SMTP id b84so26154537wmh.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:56:37 -0700 (PDT)
In-Reply-To: <20170523195630.6460-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The MCC register allows controlling and querying the firmware flash state
machine (FSM).

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 83 +++++++++++++++++++++++++++++++
 1 file changed, 83 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index adb385f..f3c768c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5726,6 +5726,88 @@ static inline void mlxsw_reg_mcqi_unpack(char *payload,
 		mlxsw_reg_mcqi_cap_mcda_max_write_size_get(payload);
 }
 
+/* MCC - Management Component Control
+ * ----------------------------------
+ * Controls the firmware component and updates the FSM.
+ */
+#define MLXSW_REG_MCC_ID 0x9062
+#define MLXSW_REG_MCC_LEN 0x1C
+
+MLXSW_REG_DEFINE(mcc, MLXSW_REG_MCC_ID, MLXSW_REG_MCC_LEN);
+
+enum mlxsw_reg_mcc_instruction {
+	MLXSW_REG_MCC_INSTRUCTION_LOCK_UPDATE_HANDLE = 0x01,
+	MLXSW_REG_MCC_INSTRUCTION_RELEASE_UPDATE_HANDLE = 0x02,
+	MLXSW_REG_MCC_INSTRUCTION_UPDATE_COMPONENT = 0x03,
+	MLXSW_REG_MCC_INSTRUCTION_VERIFY_COMPONENT = 0x04,
+	MLXSW_REG_MCC_INSTRUCTION_ACTIVATE = 0x06,
+	MLXSW_REG_MCC_INSTRUCTION_CANCEL = 0x08,
+};
+
+/* reg_mcc_instruction
+ * Command to be executed by the FSM.
+ * Applicable for write operation only.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcc, instruction, 0x00, 0, 8);
+
+/* reg_mcc_component_index
+ * Index of the accessed component. Applicable only for commands that
+ * refer to components. Otherwise, this field is reserved.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mcc, component_index, 0x04, 0, 16);
+
+/* reg_mcc_update_handle
+ * Token representing the current flow executed by the FSM.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, mcc, update_handle, 0x08, 0, 24);
+
+/* reg_mcc_error_code
+ * Indicates the successful completion of the instruction, or the reason it
+ * failed
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mcc, error_code, 0x0C, 8, 8);
+
+/* reg_mcc_control_state
+ * Current FSM state
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mcc, control_state, 0x0C, 0, 4);
+
+/* reg_mcc_component_size
+ * Component size in bytes. Valid for UPDATE_COMPONENT instruction. Specifying
+ * the size may shorten the update time. Value 0x0 means that size is
+ * unspecified.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, mcc, component_size, 0x10, 0, 32);
+
+static inline void mlxsw_reg_mcc_pack(char *payload,
+				      enum mlxsw_reg_mcc_instruction instr,
+				      u16 component_index, u32 update_handle,
+				      u32 component_size)
+{
+	MLXSW_REG_ZERO(mcc, payload);
+	mlxsw_reg_mcc_instruction_set(payload, instr);
+	mlxsw_reg_mcc_component_index_set(payload, component_index);
+	mlxsw_reg_mcc_update_handle_set(payload, update_handle);
+	mlxsw_reg_mcc_component_size_set(payload, component_size);
+}
+
+static inline void mlxsw_reg_mcc_unpack(char *payload, u32 *p_update_handle,
+					u8 *p_error_code, u8 *p_control_state)
+{
+	if (p_update_handle)
+		*p_update_handle = mlxsw_reg_mcc_update_handle_get(payload);
+	if (p_error_code)
+		*p_error_code = mlxsw_reg_mcc_error_code_get(payload);
+	if (p_control_state)
+		*p_control_state = mlxsw_reg_mcc_control_state_get(payload);
+}
+
 /* MPSC - Monitoring Packet Sampling Configuration Register
  * --------------------------------------------------------
  * MPSC Register is used to configure the Packet Sampling mechanism.
@@ -6305,6 +6387,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(mlcr),
 	MLXSW_REG(mpsc),
 	MLXSW_REG(mcqi),
+	MLXSW_REG(mcc),
 	MLXSW_REG(mgpc),
 	MLXSW_REG(sbpr),
 	MLXSW_REG(sbcm),
-- 
2.9.3
