From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/16] mlxsw: reg: Add Switch VID to FID Allocation register definition
Date: Fri, 16 Oct 2015 14:01:33 +0200
Message-ID: <1444996897-2708-13-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33363 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbbJPMB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:56 -0400
Received: by wijp11 with SMTP id p11so6936236wij.0
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:55 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

An incoming packet can be classified into a filtering identifer (FID)
based on its VID or incoming port and VID ({Port, VID}).

Add the SVFA register, which controls this mapping.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 95 +++++++++++++++++++++++++++++++
 1 file changed, 95 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 6f4a7b0..5a97707 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -883,6 +883,99 @@ static inline void mlxsw_reg_spmlr_pack(char *payload, u8 local_port,
 	mlxsw_reg_spmlr_learn_mode_set(payload, mode);
 }
 
+/* SVFA - Switch VID to FID Allocation Register
+ * --------------------------------------------
+ * Controls the VID to FID mapping and {Port, VID} to FID mapping for
+ * virtualized ports.
+ */
+#define MLXSW_REG_SVFA_ID 0x201C
+#define MLXSW_REG_SVFA_LEN 0x10
+
+static const struct mlxsw_reg_info mlxsw_reg_svfa = {
+	.id = MLXSW_REG_SVFA_ID,
+	.len = MLXSW_REG_SVFA_LEN,
+};
+
+/* reg_svfa_swid
+ * Switch partition ID.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, svfa, swid, 0x00, 24, 8);
+
+/* reg_svfa_local_port
+ * Local port number.
+ * Access: Index
+ *
+ * Note: Reserved for 802.1Q FIDs.
+ */
+MLXSW_ITEM32(reg, svfa, local_port, 0x00, 16, 8);
+
+enum mlxsw_reg_svfa_mt {
+	MLXSW_REG_SVFA_MT_VID_TO_FID,
+	MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
+};
+
+/* reg_svfa_mapping_table
+ * Mapping table:
+ * 0 - VID to FID
+ * 1 - {Port, VID} to FID
+ * Access: Index
+ *
+ * Note: Reserved for SwitchX-2.
+ */
+MLXSW_ITEM32(reg, svfa, mapping_table, 0x00, 8, 3);
+
+/* reg_svfa_v
+ * Valid.
+ * Valid if set.
+ * Access: RW
+ *
+ * Note: Reserved for SwitchX-2.
+ */
+MLXSW_ITEM32(reg, svfa, v, 0x00, 0, 1);
+
+/* reg_svfa_fid
+ * Filtering ID.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, svfa, fid, 0x04, 16, 16);
+
+/* reg_svfa_vid
+ * VLAN ID.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, svfa, vid, 0x04, 0, 12);
+
+/* reg_svfa_counter_set_type
+ * Counter set type for flow counters.
+ * Access: RW
+ *
+ * Note: Reserved for SwitchX-2.
+ */
+MLXSW_ITEM32(reg, svfa, counter_set_type, 0x08, 24, 8);
+
+/* reg_svfa_counter_index
+ * Counter index for flow counters.
+ * Access: RW
+ *
+ * Note: Reserved for SwitchX-2.
+ */
+MLXSW_ITEM32(reg, svfa, counter_index, 0x08, 0, 24);
+
+static inline void mlxsw_reg_svfa_pack(char *payload, u8 local_port,
+				       enum mlxsw_reg_svfa_mt mt, bool valid,
+				       u16 fid, u16 vid)
+{
+	MLXSW_REG_ZERO(svfa, payload);
+	local_port = mt == MLXSW_REG_SVFA_MT_VID_TO_FID ? 0 : local_port;
+	mlxsw_reg_svfa_swid_set(payload, 0);
+	mlxsw_reg_svfa_local_port_set(payload, local_port);
+	mlxsw_reg_svfa_mapping_table_set(payload, mt);
+	mlxsw_reg_svfa_v_set(payload, valid);
+	mlxsw_reg_svfa_fid_set(payload, fid);
+	mlxsw_reg_svfa_vid_set(payload, vid);
+}
+
 /* SFMR - Switch FID Management Register
  * -------------------------------------
  * Creates and configures FIDs.
@@ -2146,6 +2239,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SFTR";
 	case MLXSW_REG_SPMLR_ID:
 		return "SPMLR";
+	case MLXSW_REG_SVFA_ID:
+		return "SVFA";
 	case MLXSW_REG_SFMR_ID:
 		return "SFMR";
 	case MLXSW_REG_PMLP_ID:
-- 
1.9.3
