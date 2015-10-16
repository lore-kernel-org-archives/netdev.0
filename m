From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/16] mlxsw: reg: Add Switch FID Management register definition
Date: Fri, 16 Oct 2015 14:01:32 +0200
Message-ID: <1444996897-2708-12-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36779 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbbJPMBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:55 -0400
Received: by wicgb1 with SMTP id gb1so6393214wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:54 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Filtering identifiers (FIDs) are unique identifers of bridge instances
in the hardware.

Add the SFMR register, which is responsible for the creation and
configuration of these FIDs.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 87 +++++++++++++++++++++++++++++++
 1 file changed, 87 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index bb0ad09..6f4a7b0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -883,6 +883,91 @@ static inline void mlxsw_reg_spmlr_pack(char *payload, u8 local_port,
 	mlxsw_reg_spmlr_learn_mode_set(payload, mode);
 }
 
+/* SFMR - Switch FID Management Register
+ * -------------------------------------
+ * Creates and configures FIDs.
+ */
+#define MLXSW_REG_SFMR_ID 0x201F
+#define MLXSW_REG_SFMR_LEN 0x18
+
+static const struct mlxsw_reg_info mlxsw_reg_sfmr = {
+	.id = MLXSW_REG_SFMR_ID,
+	.len = MLXSW_REG_SFMR_LEN,
+};
+
+enum mlxsw_reg_sfmr_op {
+	MLXSW_REG_SFMR_OP_CREATE_FID,
+	MLXSW_REG_SFMR_OP_DESTROY_FID,
+};
+
+/* reg_sfmr_op
+ * Operation.
+ * 0 - Create or edit FID.
+ * 1 - Destroy FID.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, sfmr, op, 0x00, 24, 4);
+
+/* reg_sfmr_fid
+ * Filtering ID.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sfmr, fid, 0x00, 0, 16);
+
+/* reg_sfmr_fid_offset
+ * FID offset.
+ * Used to point into the flooding table selected by SFGC register if
+ * the table is of type FID-Offset. Otherwise, this field is reserved.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfmr, fid_offset, 0x08, 0, 16);
+
+/* reg_sfmr_vtfp
+ * Valid Tunnel Flood Pointer.
+ * If not set, then nve_tunnel_flood_ptr is reserved and considered NULL.
+ * Access: RW
+ *
+ * Note: Reserved for 802.1Q FIDs.
+ */
+MLXSW_ITEM32(reg, sfmr, vtfp, 0x0C, 31, 1);
+
+/* reg_sfmr_nve_tunnel_flood_ptr
+ * Underlay Flooding and BC Pointer.
+ * Used as a pointer to the first entry of the group based link lists of
+ * flooding or BC entries (for NVE tunnels).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfmr, nve_tunnel_flood_ptr, 0x0C, 0, 24);
+
+/* reg_sfmr_vv
+ * VNI Valid.
+ * If not set, then vni is reserved.
+ * Access: RW
+ *
+ * Note: Reserved for 802.1Q FIDs.
+ */
+MLXSW_ITEM32(reg, sfmr, vv, 0x10, 31, 1);
+
+/* reg_sfmr_vni
+ * Virtual Network Identifier.
+ * Access: RW
+ *
+ * Note: A given VNI can only be assigned to one FID.
+ */
+MLXSW_ITEM32(reg, sfmr, vni, 0x10, 0, 24);
+
+static inline void mlxsw_reg_sfmr_pack(char *payload,
+				       enum mlxsw_reg_sfmr_op op, u16 fid,
+				       u16 fid_offset)
+{
+	MLXSW_REG_ZERO(sfmr, payload);
+	mlxsw_reg_sfmr_op_set(payload, op);
+	mlxsw_reg_sfmr_fid_set(payload, fid);
+	mlxsw_reg_sfmr_fid_offset_set(payload, fid_offset);
+	mlxsw_reg_sfmr_vtfp_set(payload, false);
+	mlxsw_reg_sfmr_vv_set(payload, false);
+}
+
 /* PMLP - Ports Module to Local Port Register
  * ------------------------------------------
  * Configures the assignment of modules to local ports.
@@ -2061,6 +2146,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SFTR";
 	case MLXSW_REG_SPMLR_ID:
 		return "SPMLR";
+	case MLXSW_REG_SFMR_ID:
+		return "SFMR";
 	case MLXSW_REG_PMLP_ID:
 		return "PMLP";
 	case MLXSW_REG_PMTU_ID:
-- 
1.9.3
