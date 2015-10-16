From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/16] mlxsw: reg: Add Switch FDB Notification register definition
Date: Fri, 16 Oct 2015 14:01:29 +0200
Message-ID: <1444996897-2708-9-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:34638 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbbJPMBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:52 -0400
Received: by wicgb1 with SMTP id gb1so6534773wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:51 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add SFN register which is used to poll for newly added and aged-out FDB
entries.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 101 ++++++++++++++++++++++++++++++
 1 file changed, 101 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index c0cc5f1..8afa2b6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -371,6 +371,105 @@ mlxsw_reg_sfd_uc_unpack(char *payload, int rec_index,
 	*p_local_port = mlxsw_reg_sfd_uc_system_port_get(payload, rec_index);
 }
 
+/* SFN - Switch FDB Notification Register
+ * -------------------------------------------
+ * The switch provides notifications on newly learned FDB entries and
+ * aged out entries. The notifications can be polled by software.
+ */
+#define MLXSW_REG_SFN_ID 0x200B
+#define MLXSW_REG_SFN_BASE_LEN 0x10 /* base length, without records */
+#define MLXSW_REG_SFN_REC_LEN 0x10 /* record length */
+#define MLXSW_REG_SFN_REC_MAX_COUNT 64
+#define MLXSW_REG_SFN_LEN (MLXSW_REG_SFN_BASE_LEN +	\
+			   MLXSW_REG_SFN_REC_LEN * MLXSW_REG_SFN_REC_MAX_COUNT)
+
+static const struct mlxsw_reg_info mlxsw_reg_sfn = {
+	.id = MLXSW_REG_SFN_ID,
+	.len = MLXSW_REG_SFN_LEN,
+};
+
+/* reg_sfn_swid
+ * Switch partition ID.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sfn, swid, 0x00, 24, 8);
+
+/* reg_sfn_num_rec
+ * Request: Number of learned notifications and aged-out notification
+ * records requested.
+ * Response: Number of notification records returned (must be smaller
+ * than or equal to the value requested)
+ * Ranges 0..64
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, sfn, num_rec, 0x04, 0, 8);
+
+static inline void mlxsw_reg_sfn_pack(char *payload)
+{
+	MLXSW_REG_ZERO(sfn, payload);
+	mlxsw_reg_sfn_swid_set(payload, 0);
+	mlxsw_reg_sfn_num_rec_set(payload, MLXSW_REG_SFN_REC_MAX_COUNT);
+}
+
+/* reg_sfn_rec_swid
+ * Switch partition ID.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, sfn, rec_swid, MLXSW_REG_SFN_BASE_LEN, 24, 8,
+		     MLXSW_REG_SFN_REC_LEN, 0x00, false);
+
+enum mlxsw_reg_sfn_rec_type {
+	/* MAC addresses learned on a regular port. */
+	MLXSW_REG_SFN_REC_TYPE_LEARNED_MAC = 0x5,
+	/* Aged-out MAC address on a regular port */
+	MLXSW_REG_SFN_REC_TYPE_AGED_OUT_MAC = 0x7,
+};
+
+/* reg_sfn_rec_type
+ * Notification record type.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, sfn, rec_type, MLXSW_REG_SFN_BASE_LEN, 20, 4,
+		     MLXSW_REG_SFN_REC_LEN, 0x00, false);
+
+/* reg_sfn_rec_mac
+ * MAC address.
+ * Access: RO
+ */
+MLXSW_ITEM_BUF_INDEXED(reg, sfn, rec_mac, MLXSW_REG_SFN_BASE_LEN, 6,
+		       MLXSW_REG_SFN_REC_LEN, 0x02);
+
+/* reg_sfd_mac_sub_port
+ * VEPA channel on the local port.
+ * 0 if multichannel VEPA is not enabled.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, sfn, mac_sub_port, MLXSW_REG_SFN_BASE_LEN, 16, 8,
+		     MLXSW_REG_SFN_REC_LEN, 0x08, false);
+
+/* reg_sfd_mac_fid
+ * Filtering identifier.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, sfn, mac_fid, MLXSW_REG_SFN_BASE_LEN, 0, 16,
+		     MLXSW_REG_SFN_REC_LEN, 0x08, false);
+
+/* reg_sfd_mac_system_port
+ * Unique port identifier for the final destination of the packet.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, sfn, mac_system_port, MLXSW_REG_SFN_BASE_LEN, 0, 16,
+		     MLXSW_REG_SFN_REC_LEN, 0x0C, false);
+
+static inline void mlxsw_reg_sfn_mac_unpack(char *payload, int rec_index,
+					    char *mac, u16 *p_vid,
+					    u8 *p_local_port)
+{
+	mlxsw_reg_sfn_rec_mac_memcpy_from(payload, rec_index, mac);
+	*p_vid = mlxsw_reg_sfn_mac_fid_get(payload, rec_index);
+	*p_local_port = mlxsw_reg_sfn_mac_system_port_get(payload, rec_index);
+}
+
 /* SPMS - Switch Port MSTP/RSTP State Register
  * -------------------------------------------
  * Configures the spanning tree state of a physical port.
@@ -1467,6 +1566,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SSPR";
 	case MLXSW_REG_SFD_ID:
 		return "SFD";
+	case MLXSW_REG_SFN_ID:
+		return "SFN";
 	case MLXSW_REG_SPMS_ID:
 		return "SPMS";
 	case MLXSW_REG_SFGC_ID:
-- 
1.9.3
