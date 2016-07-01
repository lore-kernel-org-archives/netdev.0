From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 31/42] mlxsw: reg: Add Router Algorithmic LPM Unicast Host Table register
Date: Fri,  1 Jul 2016 16:04:59 +0200
Message-ID: <1467381910-3445-32-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33674 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbcGAOY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:24:57 -0400
Received: by mail-wm0-f65.google.com with SMTP id r201so5700228wme.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:24:02 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The RAUHT register is used to configure and query the Unicast Host Table
in devices that implement the Algorithmic LPM. In other words, it is
used to configure neighbour entries in the device.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 141 ++++++++++++++++++++++++++++++
 1 file changed, 141 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 9280d96..cc6a0b3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4,6 +4,7 @@
  * Copyright (c) 2015-2016 Ido Schimmel <idosch@mellanox.com>
  * Copyright (c) 2015 Elad Raz <eladr@mellanox.com>
  * Copyright (c) 2015-2016 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2016 Yotam Gigi <yotamg@mellanox.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
@@ -3884,6 +3885,144 @@ mlxsw_reg_ralue_act_ip2me_pack(char *payload)
 					MLXSW_REG_RALUE_ACTION_TYPE_IP2ME);
 }
 
+/* RAUHT - Router Algorithmic LPM Unicast Host Table Register
+ * ----------------------------------------------------------
+ * The RAUHT register is used to configure and query the Unicast Host table in
+ * devices that implement the Algorithmic LPM.
+ */
+#define MLXSW_REG_RAUHT_ID 0x8014
+#define MLXSW_REG_RAUHT_LEN 0x74
+
+static const struct mlxsw_reg_info mlxsw_reg_rauht = {
+	.id = MLXSW_REG_RAUHT_ID,
+	.len = MLXSW_REG_RAUHT_LEN,
+};
+
+enum mlxsw_reg_rauht_type {
+	MLXSW_REG_RAUHT_TYPE_IPV4,
+	MLXSW_REG_RAUHT_TYPE_IPV6,
+};
+
+/* reg_rauht_type
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rauht, type, 0x00, 24, 2);
+
+enum mlxsw_reg_rauht_op {
+	MLXSW_REG_RAUHT_OP_QUERY_READ = 0,
+	/* Read operation */
+	MLXSW_REG_RAUHT_OP_QUERY_CLEAR_ON_READ = 1,
+	/* Clear on read operation. Used to read entry and clear
+	 * activity bit.
+	 */
+	MLXSW_REG_RAUHT_OP_WRITE_ADD = 0,
+	/* Add. Used to write a new entry to the table. All R/W fields are
+	 * relevant for new entry. Activity bit is set for new entries.
+	 */
+	MLXSW_REG_RAUHT_OP_WRITE_UPDATE = 1,
+	/* Update action. Used to update an existing route entry and
+	 * only update the following fields:
+	 * trap_action, trap_id, mac, counter_set_type, counter_index
+	 */
+	MLXSW_REG_RAUHT_OP_WRITE_CLEAR_ACTIVITY = 2,
+	/* Clear activity. A bit is cleared for the entry. */
+	MLXSW_REG_RAUHT_OP_WRITE_DELETE = 3,
+	/* Delete entry */
+	MLXSW_REG_RAUHT_OP_WRITE_DELETE_ALL = 4,
+	/* Delete all host entries on a RIF. In this command, dip
+	 * field is reserved.
+	 */
+};
+
+/* reg_rauht_op
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, rauht, op, 0x00, 20, 3);
+
+/* reg_rauht_a
+ * Activity. Set for new entries. Set if a packet lookup has hit on
+ * the specific entry.
+ * To clear the a bit, use "clear activity" op.
+ * Enabled by activity_dis in RGCR
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, rauht, a, 0x00, 16, 1);
+
+/* reg_rauht_rif
+ * Router Interface
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rauht, rif, 0x00, 0, 16);
+
+/* reg_rauht_dip*
+ * Destination address.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rauht, dip4, 0x1C, 0x0, 32);
+
+enum mlxsw_reg_rauht_trap_action {
+	MLXSW_REG_RAUHT_TRAP_ACTION_NOP,
+	MLXSW_REG_RAUHT_TRAP_ACTION_TRAP,
+	MLXSW_REG_RAUHT_TRAP_ACTION_MIRROR_TO_CPU,
+	MLXSW_REG_RAUHT_TRAP_ACTION_MIRROR,
+	MLXSW_REG_RAUHT_TRAP_ACTION_DISCARD_ERRORS,
+};
+
+/* reg_rauht_trap_action
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rauht, trap_action, 0x60, 28, 4);
+
+enum mlxsw_reg_rauht_trap_id {
+	MLXSW_REG_RAUHT_TRAP_ID_RTR_EGRESS0,
+	MLXSW_REG_RAUHT_TRAP_ID_RTR_EGRESS1,
+};
+
+/* reg_rauht_trap_id
+ * Trap ID to be reported to CPU.
+ * Trap-ID is RTR_EGRESS0 or RTR_EGRESS1.
+ * For trap_action of NOP, MIRROR and DISCARD_ERROR,
+ * trap_id is reserved.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rauht, trap_id, 0x60, 0, 9);
+
+/* reg_rauht_counter_set_type
+ * Counter set type for flow counters
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rauht, counter_set_type, 0x68, 24, 8);
+
+/* reg_rauht_counter_index
+ * Counter index for flow counters
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rauht, counter_index, 0x68, 0, 24);
+
+/* reg_rauht_mac
+ * MAC address.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, rauht, mac, 0x6E, 6);
+
+static inline void mlxsw_reg_rauht_pack(char *payload,
+					enum mlxsw_reg_rauht_op op, u16 rif,
+					const char *mac)
+{
+	MLXSW_REG_ZERO(rauht, payload);
+	mlxsw_reg_rauht_op_set(payload, op);
+	mlxsw_reg_rauht_rif_set(payload, rif);
+	mlxsw_reg_rauht_mac_memcpy_to(payload, mac);
+}
+
+static inline void mlxsw_reg_rauht_pack4(char *payload,
+					 enum mlxsw_reg_rauht_op op, u16 rif,
+					 const char *mac, u32 dip)
+{
+	mlxsw_reg_rauht_pack(payload, op, rif, mac);
+	mlxsw_reg_rauht_dip4_set(payload, dip);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -4634,6 +4773,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "RALTB";
 	case MLXSW_REG_RALUE_ID:
 		return "RALUE";
+	case MLXSW_REG_RAUHT_ID:
+		return "RAUHT";
 	case MLXSW_REG_MFCR_ID:
 		return "MFCR";
 	case MLXSW_REG_MFSC_ID:
-- 
2.5.5
