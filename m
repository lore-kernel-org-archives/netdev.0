From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/16] mlxsw: reg: Add Switch Port VLAN MAC Learning register definition
Date: Fri, 16 Oct 2015 14:01:36 +0200
Message-ID: <1444996897-2708-16-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34815 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754110AbbJPMCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:02:00 -0400
Received: by wicgb1 with SMTP id gb1so6539264wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:59 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Since we currently do not support the offloading of 802.1D bridges, we
need to be able to let the device know it should not learn MAC addresses
on specific {Port, VID} pairs.

Add the SPVMLR register, which controls the learning enablement of
{Port, VID} pairs.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 67 +++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index d1c8eff..4fcba46 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1132,6 +1132,71 @@ static inline void mlxsw_reg_sfmr_pack(char *payload,
 	mlxsw_reg_sfmr_vv_set(payload, false);
 }
 
+/* SPVMLR - Switch Port VLAN MAC Learning Register
+ * -----------------------------------------------
+ * Controls the switch MAC learning policy per {Port, VID}.
+ */
+#define MLXSW_REG_SPVMLR_ID 0x2020
+#define MLXSW_REG_SPVMLR_BASE_LEN 0x04 /* base length, without records */
+#define MLXSW_REG_SPVMLR_REC_LEN 0x04 /* record length */
+#define MLXSW_REG_SPVMLR_REC_MAX_COUNT 256
+#define MLXSW_REG_SPVMLR_LEN (MLXSW_REG_SPVMLR_BASE_LEN + \
+			      MLXSW_REG_SPVMLR_REC_LEN * \
+			      MLXSW_REG_SPVMLR_REC_MAX_COUNT)
+
+static const struct mlxsw_reg_info mlxsw_reg_spvmlr = {
+	.id = MLXSW_REG_SPVMLR_ID,
+	.len = MLXSW_REG_SPVMLR_LEN,
+};
+
+/* reg_spvmlr_local_port
+ * Local ingress port.
+ * Access: Index
+ *
+ * Note: CPU port is not supported.
+ */
+MLXSW_ITEM32(reg, spvmlr, local_port, 0x00, 16, 8);
+
+/* reg_spvmlr_num_rec
+ * Number of records to update.
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, spvmlr, num_rec, 0x00, 0, 8);
+
+/* reg_spvmlr_rec_learn_enable
+ * 0 - Disable learning for {Port, VID}.
+ * 1 - Enable learning for {Port, VID}.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, spvmlr, rec_learn_enable, MLXSW_REG_SPVMLR_BASE_LEN,
+		     31, 1, MLXSW_REG_SPVMLR_REC_LEN, 0x00, false);
+
+/* reg_spvmlr_rec_vid
+ * VLAN ID to be added/removed from port or for querying.
+ * Access: Index
+ */
+MLXSW_ITEM32_INDEXED(reg, spvmlr, rec_vid, MLXSW_REG_SPVMLR_BASE_LEN, 0, 12,
+		     MLXSW_REG_SPVMLR_REC_LEN, 0x00, false);
+
+static inline void mlxsw_reg_spvmlr_pack(char *payload, u8 local_port,
+					 u16 vid_begin, u16 vid_end,
+					 bool learn_enable)
+{
+	int num_rec = vid_end - vid_begin + 1;
+	int i;
+
+	WARN_ON(num_rec < 1 || num_rec > MLXSW_REG_SPVMLR_REC_MAX_COUNT);
+
+	MLXSW_REG_ZERO(spvmlr, payload);
+	mlxsw_reg_spvmlr_local_port_set(payload, local_port);
+	mlxsw_reg_spvmlr_num_rec_set(payload, num_rec);
+
+	for (i = 0; i < num_rec; i++) {
+		mlxsw_reg_spvmlr_rec_learn_enable_set(payload, i, learn_enable);
+		mlxsw_reg_spvmlr_rec_vid_set(payload, i, vid_begin + i);
+	}
+}
+
 /* PMLP - Ports Module to Local Port Register
  * ------------------------------------------
  * Configures the assignment of modules to local ports.
@@ -2318,6 +2383,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SVPE";
 	case MLXSW_REG_SFMR_ID:
 		return "SFMR";
+	case MLXSW_REG_SPVMLR_ID:
+		return "SPVMLR";
 	case MLXSW_REG_PMLP_ID:
 		return "PMLP";
 	case MLXSW_REG_PMTU_ID:
-- 
1.9.3
