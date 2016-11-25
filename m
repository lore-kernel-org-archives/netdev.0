From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 18/19] mlxsw: reg: Add QoS Policer Configuration Register
Date: Fri, 25 Nov 2016 10:33:46 +0100
Message-ID: <1480066427-3961-19-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34855 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752916AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f68.google.com with SMTP id a20so7222643wme.2
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:34:11 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

The QPCR register is used to create and control policers.
A policer can discard or change the color of packets that are
trapped by a specific trap.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 141 ++++++++++++++++++++++++++++++
 1 file changed, 141 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 2d92e41..1357fe0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1757,6 +1757,146 @@ static inline void mlxsw_reg_spvmlr_pack(char *payload, u8 local_port,
 	}
 }
 
+/* QPCR - QoS Policer Configuration Register
+ * -----------------------------------------
+ * The QPCR register is used to create policers - that limit
+ * the rate of bytes or packets via some trap group.
+ */
+#define MLXSW_REG_QPCR_ID 0x4004
+#define MLXSW_REG_QPCR_LEN 0x28
+
+MLXSW_REG_DEFINE(qpcr, MLXSW_REG_QPCR_ID, MLXSW_REG_QPCR_LEN);
+
+enum mlxsw_reg_qpcr_g {
+	MLXSW_REG_QPCR_G_GLOBAL = 2,
+	MLXSW_REG_QPCR_G_STORM_CONTROL = 3,
+};
+
+/* reg_qpcr_g
+ * The policer type.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, qpcr, g, 0x00, 14, 2);
+
+/* reg_qpcr_pid
+ * Policer ID.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, qpcr, pid, 0x00, 0, 14);
+
+/* reg_qpcr_color_aware
+ * Is the policer aware of colors.
+ * Must be 0 (unaware) for cpu port.
+ * Access: RW for unbounded policer. RO for bounded policer.
+ */
+MLXSW_ITEM32(reg, qpcr, color_aware, 0x04, 15, 1);
+
+/* reg_qpcr_bytes
+ * Is policer limit is for bytes per sec or packets per sec.
+ * 0 - packets
+ * 1 - bytes
+ * Access: RW for unbounded policer. RO for bounded policer.
+ */
+MLXSW_ITEM32(reg, qpcr, bytes, 0x04, 14, 1);
+
+enum mlxsw_reg_qpcr_ir_units {
+	MLXSW_REG_QPCR_IR_UNITS_M,
+	MLXSW_REG_QPCR_IR_UNITS_K,
+};
+
+/* reg_qpcr_ir_units
+ * Policer's units for cir and eir fields (for bytes limits only)
+ * 1 - 10^3
+ * 0 - 10^6
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, qpcr, ir_units, 0x04, 12, 1);
+
+enum mlxsw_reg_qpcr_rate_type {
+	MLXSW_REG_QPCR_RATE_TYPE_SINGLE = 1,
+	MLXSW_REG_QPCR_RATE_TYPE_DOUBLE = 2,
+};
+
+/* reg_qpcr_rate_type
+ * Policer can have one limit (single rate) or 2 limits with specific operation
+ * for packets that exceed the lower rate but not the upper one.
+ * (For cpu port must be single rate)
+ * Access: RW for unbounded policer. RO for bounded policer.
+ */
+MLXSW_ITEM32(reg, qpcr, rate_type, 0x04, 8, 2);
+
+/* reg_qpc_cbs
+ * Policer's committed burst size.
+ * The policer is working with time slices of 50 nano sec. By default every
+ * slice is granted the proportionate share of the committed rate. If we want to
+ * allow a slice to exceed that share (while still keeping the rate per sec) we
+ * can allow burst. The burst size is between the default proportionate share
+ * (and no lower than 8) to 32Gb. (Even though giving a number higher than the
+ * committed rate will result in exceeding the rate). The burst size must be a
+ * log of 2 and will be determined by 2^cbs.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, qpcr, cbs, 0x08, 24, 6);
+
+/* reg_qpcr_cir
+ * Policer's committed rate.
+ * The rate used for sungle rate, the lower rate for double rate.
+ * For bytes limits, the rate will be this value * the unit from ir_units.
+ * (Resolution error is up to 1%).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, qpcr, cir, 0x0C, 0, 32);
+
+/* reg_qpcr_eir
+ * Policer's exceed rate.
+ * The higher rate for double rate, reserved for single rate.
+ * Lower rate for double rate policer.
+ * For bytes limits, the rate will be this value * the unit from ir_units.
+ * (Resolution error is up to 1%).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, qpcr, eir, 0x10, 0, 32);
+
+#define MLXSW_REG_QPCR_DOUBLE_RATE_ACTION 2
+
+/* reg_qpcr_exceed_action.
+ * What to do with packets between the 2 limits for double rate.
+ * Access: RW for unbounded policer. RO for bounded policer.
+ */
+MLXSW_ITEM32(reg, qpcr, exceed_action, 0x14, 0, 4);
+
+enum mlxsw_reg_qpcr_action {
+	/* Discard */
+	MLXSW_REG_QPCR_ACTION_DISCARD = 1,
+	/* Forward and set color to red.
+	 * If the packet is intended to cpu port, it will be dropped.
+	 */
+	MLXSW_REG_QPCR_ACTION_FORWARD = 2,
+};
+
+/* reg_qpcr_violate_action
+ * What to do with packets that cross the cir limit (for single rate) or the eir
+ * limit (for double rate).
+ * Access: RW for unbounded policer. RO for bounded policer.
+ */
+MLXSW_ITEM32(reg, qpcr, violate_action, 0x18, 0, 4);
+
+static inline void mlxsw_reg_qpcr_pack(char *payload, u16 pid,
+				       enum mlxsw_reg_qpcr_ir_units ir_units,
+				       bool bytes, u32 cir, u16 cbs)
+{
+	MLXSW_REG_ZERO(qpcr, payload);
+	mlxsw_reg_qpcr_pid_set(payload, pid);
+	mlxsw_reg_qpcr_g_set(payload, MLXSW_REG_QPCR_G_GLOBAL);
+	mlxsw_reg_qpcr_rate_type_set(payload, MLXSW_REG_QPCR_RATE_TYPE_SINGLE);
+	mlxsw_reg_qpcr_violate_action_set(payload,
+					  MLXSW_REG_QPCR_ACTION_DISCARD);
+	mlxsw_reg_qpcr_cir_set(payload, cir);
+	mlxsw_reg_qpcr_ir_units_set(payload, ir_units);
+	mlxsw_reg_qpcr_bytes_set(payload, bytes);
+	mlxsw_reg_qpcr_cbs_set(payload, cbs);
+}
+
 /* QTCT - QoS Switch Traffic Class Table
  * -------------------------------------
  * Configures the mapping between the packet switch priority and the
@@ -5254,6 +5394,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(svpe),
 	MLXSW_REG(sfmr),
 	MLXSW_REG(spvmlr),
+	MLXSW_REG(qpcr),
 	MLXSW_REG(qtct),
 	MLXSW_REG(qeec),
 	MLXSW_REG(pmlp),
-- 
2.7.4
