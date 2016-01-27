From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 02/11] mlxsw: reg: Add the Switch Filtering DB Flush register
Date: Wed, 27 Jan 2016 15:20:17 +0100
Message-ID: <1453904426-4960-3-git-send-email-jiri@resnulli.us>
References: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38190 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbcA0OUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:33 -0500
Received: by mail-wm0-f52.google.com with SMTP id p63so28693913wmp.1
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:32 -0800 (PST)
In-Reply-To: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When removing a net device from a bridge we should flush the FDB entries
associated with this net device. Up until now, we relied upon bridge
code to do that for us, but it is possible for user to prevent hardware
from syncing with the software bridge (learning_sync=0), so we need to
flush overselves.

Add the Switch Filtering DB Flush (SFDF) register that is used to flush
FDB entries according to different parameters (per-port, per-FID etc).

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 88 +++++++++++++++++++++++++++++++
 1 file changed, 88 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 0c52372..815e5df 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1044,6 +1044,92 @@ static inline void mlxsw_reg_sftr_pack(char *payload,
 	mlxsw_reg_sftr_port_mask_set(payload, port, 1);
 }
 
+/* SFDF - Switch Filtering DB Flush
+ * --------------------------------
+ * The switch filtering DB flush register is used to flush the FDB.
+ * Note that FDB notifications are flushed as well.
+ */
+#define MLXSW_REG_SFDF_ID 0x2013
+#define MLXSW_REG_SFDF_LEN 0x14
+
+static const struct mlxsw_reg_info mlxsw_reg_sfdf = {
+	.id = MLXSW_REG_SFDF_ID,
+	.len = MLXSW_REG_SFDF_LEN,
+};
+
+/* reg_sfdf_swid
+ * Switch partition ID.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sfdf, swid, 0x00, 24, 8);
+
+enum mlxsw_reg_sfdf_flush_type {
+	MLXSW_REG_SFDF_FLUSH_PER_SWID,
+	MLXSW_REG_SFDF_FLUSH_PER_FID,
+	MLXSW_REG_SFDF_FLUSH_PER_PORT,
+	MLXSW_REG_SFDF_FLUSH_PER_PORT_AND_FID,
+	MLXSW_REG_SFDF_FLUSH_PER_LAG,
+	MLXSW_REG_SFDF_FLUSH_PER_LAG_AND_FID,
+};
+
+/* reg_sfdf_flush_type
+ * Flush type.
+ * 0 - All SWID dynamic entries are flushed.
+ * 1 - All FID dynamic entries are flushed.
+ * 2 - All dynamic entries pointing to port are flushed.
+ * 3 - All FID dynamic entries pointing to port are flushed.
+ * 4 - All dynamic entries pointing to LAG are flushed.
+ * 5 - All FID dynamic entries pointing to LAG are flushed.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfdf, flush_type, 0x04, 28, 4);
+
+/* reg_sfdf_flush_static
+ * Static.
+ * 0 - Flush only dynamic entries.
+ * 1 - Flush both dynamic and static entries.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfdf, flush_static, 0x04, 24, 1);
+
+static inline void mlxsw_reg_sfdf_pack(char *payload,
+				       enum mlxsw_reg_sfdf_flush_type type)
+{
+	MLXSW_REG_ZERO(sfdf, payload);
+	mlxsw_reg_sfdf_flush_type_set(payload, type);
+	mlxsw_reg_sfdf_flush_static_set(payload, true);
+}
+
+/* reg_sfdf_fid
+ * FID to flush.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfdf, fid, 0x0C, 0, 16);
+
+/* reg_sfdf_system_port
+ * Port to flush.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfdf, system_port, 0x0C, 0, 16);
+
+/* reg_sfdf_port_fid_system_port
+ * Port to flush, pointed to by FID.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfdf, port_fid_system_port, 0x08, 0, 16);
+
+/* reg_sfdf_lag_id
+ * LAG ID to flush.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfdf, lag_id, 0x0C, 0, 10);
+
+/* reg_sfdf_lag_fid_lag_id
+ * LAG ID to flush, pointed to by FID.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfdf, lag_fid_lag_id, 0x08, 0, 10);
+
 /* SLDR - Switch LAG Descriptor Register
  * -----------------------------------------
  * The switch LAG descriptor register is populated by LAG descriptors.
@@ -3121,6 +3207,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SFGC";
 	case MLXSW_REG_SFTR_ID:
 		return "SFTR";
+	case MLXSW_REG_SFDF_ID:
+		return "SFDF";
 	case MLXSW_REG_SLDR_ID:
 		return "SLDR";
 	case MLXSW_REG_SLCR_ID:
-- 
1.9.3
