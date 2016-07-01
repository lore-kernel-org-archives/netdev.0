From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 32/42] mlxsw: reg: Add Router Algorithmic LPM Unicast Host Table Dump register
Date: Fri,  1 Jul 2016 16:05:00 +0200
Message-ID: <1467381910-3445-33-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35870 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbcGAOWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:22:39 -0400
Received: by mail-wm0-f68.google.com with SMTP id c82so5679408wme.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:22:38 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The RAUHTD register allows dumping entries from the Router Unicast Host
Table.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 147 ++++++++++++++++++++++++++++++
 1 file changed, 147 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index cc6a0b3..fcf379b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4023,6 +4023,151 @@ static inline void mlxsw_reg_rauht_pack4(char *payload,
 	mlxsw_reg_rauht_dip4_set(payload, dip);
 }
 
+/* RAUHTD - Router Algorithmic LPM Unicast Host Table Dump Register
+ * ----------------------------------------------------------------
+ * The RAUHTD register allows dumping entries from the Router Unicast Host
+ * Table. For a given session an entry is dumped no more than one time. The
+ * first RAUHTD access after reset is a new session. A session ends when the
+ * num_rec response is smaller than num_rec request or for IPv4 when the
+ * num_entries is smaller than 4. The clear activity affect the current session
+ * or the last session if a new session has not started.
+ */
+#define MLXSW_REG_RAUHTD_ID 0x8018
+#define MLXSW_REG_RAUHTD_BASE_LEN 0x20
+#define MLXSW_REG_RAUHTD_REC_LEN 0x20
+#define MLXSW_REG_RAUHTD_REC_MAX_NUM 32
+#define MLXSW_REG_RAUHTD_LEN (MLXSW_REG_RAUHTD_BASE_LEN + \
+		MLXSW_REG_RAUHTD_REC_MAX_NUM * MLXSW_REG_RAUHTD_REC_LEN)
+#define MLXSW_REG_RAUHTD_IPV4_ENT_PER_REC 4
+
+static const struct mlxsw_reg_info mlxsw_reg_rauhtd = {
+	.id = MLXSW_REG_RAUHTD_ID,
+	.len = MLXSW_REG_RAUHTD_LEN,
+};
+
+#define MLXSW_REG_RAUHTD_FILTER_A BIT(0)
+#define MLXSW_REG_RAUHTD_FILTER_RIF BIT(3)
+
+/* reg_rauhtd_filter_fields
+ * if a bit is '0' then the relevant field is ignored and dump is done
+ * regardless of the field value
+ * Bit0 - filter by activity: entry_a
+ * Bit3 - filter by entry rip: entry_rif
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rauhtd, filter_fields, 0x00, 0, 8);
+
+enum mlxsw_reg_rauhtd_op {
+	MLXSW_REG_RAUHTD_OP_DUMP,
+	MLXSW_REG_RAUHTD_OP_DUMP_AND_CLEAR,
+};
+
+/* reg_rauhtd_op
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, rauhtd, op, 0x04, 24, 2);
+
+/* reg_rauhtd_num_rec
+ * At request: number of records requested
+ * At response: number of records dumped
+ * For IPv4, each record has 4 entries at request and up to 4 entries
+ * at response
+ * Range is 0..MLXSW_REG_RAUHTD_REC_MAX_NUM
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rauhtd, num_rec, 0x04, 0, 8);
+
+/* reg_rauhtd_entry_a
+ * Dump only if activity has value of entry_a
+ * Reserved if filter_fields bit0 is '0'
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rauhtd, entry_a, 0x08, 16, 1);
+
+enum mlxsw_reg_rauhtd_type {
+	MLXSW_REG_RAUHTD_TYPE_IPV4,
+	MLXSW_REG_RAUHTD_TYPE_IPV6,
+};
+
+/* reg_rauhtd_type
+ * Dump only if record type is:
+ * 0 - IPv4
+ * 1 - IPv6
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rauhtd, type, 0x08, 0, 4);
+
+/* reg_rauhtd_entry_rif
+ * Dump only if RIF has value of entry_rif
+ * Reserved if filter_fields bit3 is '0'
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rauhtd, entry_rif, 0x0C, 0, 16);
+
+static inline void mlxsw_reg_rauhtd_pack(char *payload,
+					 enum mlxsw_reg_rauhtd_type type)
+{
+	MLXSW_REG_ZERO(rauhtd, payload);
+	mlxsw_reg_rauhtd_filter_fields_set(payload, MLXSW_REG_RAUHTD_FILTER_A);
+	mlxsw_reg_rauhtd_op_set(payload, MLXSW_REG_RAUHTD_OP_DUMP_AND_CLEAR);
+	mlxsw_reg_rauhtd_num_rec_set(payload, MLXSW_REG_RAUHTD_REC_MAX_NUM);
+	mlxsw_reg_rauhtd_entry_a_set(payload, 1);
+	mlxsw_reg_rauhtd_type_set(payload, type);
+}
+
+/* reg_rauhtd_ipv4_rec_num_entries
+ * Number of valid entries in this record:
+ * 0 - 1 valid entry
+ * 1 - 2 valid entries
+ * 2 - 3 valid entries
+ * 3 - 4 valid entries
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, rauhtd, ipv4_rec_num_entries,
+		     MLXSW_REG_RAUHTD_BASE_LEN, 28, 2,
+		     MLXSW_REG_RAUHTD_REC_LEN, 0x00, false);
+
+/* reg_rauhtd_rec_type
+ * Record type.
+ * 0 - IPv4
+ * 1 - IPv6
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, rauhtd, rec_type, MLXSW_REG_RAUHTD_BASE_LEN, 24, 2,
+		     MLXSW_REG_RAUHTD_REC_LEN, 0x00, false);
+
+#define MLXSW_REG_RAUHTD_IPV4_ENT_LEN 0x8
+
+/* reg_rauhtd_ipv4_ent_a
+ * Activity. Set for new entries. Set if a packet lookup has hit on the
+ * specific entry.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, rauhtd, ipv4_ent_a, MLXSW_REG_RAUHTD_BASE_LEN, 16, 1,
+		     MLXSW_REG_RAUHTD_IPV4_ENT_LEN, 0x00, false);
+
+/* reg_rauhtd_ipv4_ent_rif
+ * Router interface.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, rauhtd, ipv4_ent_rif, MLXSW_REG_RAUHTD_BASE_LEN, 0,
+		     16, MLXSW_REG_RAUHTD_IPV4_ENT_LEN, 0x00, false);
+
+/* reg_rauhtd_ipv4_ent_dip
+ * Destination IPv4 address.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, rauhtd, ipv4_ent_dip, MLXSW_REG_RAUHTD_BASE_LEN, 0,
+		     32, MLXSW_REG_RAUHTD_IPV4_ENT_LEN, 0x04, false);
+
+static inline void mlxsw_reg_rauhtd_ent_ipv4_unpack(char *payload,
+						    int ent_index, u16 *p_rif,
+						    u32 *p_dip)
+{
+	*p_rif = mlxsw_reg_rauhtd_ipv4_ent_rif_get(payload, ent_index);
+	*p_dip = mlxsw_reg_rauhtd_ipv4_ent_dip_get(payload, ent_index);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -4775,6 +4920,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "RALUE";
 	case MLXSW_REG_RAUHT_ID:
 		return "RAUHT";
+	case MLXSW_REG_RAUHTD_ID:
+		return "RAUHTD";
 	case MLXSW_REG_MFCR_ID:
 		return "MFCR";
 	case MLXSW_REG_MFSC_ID:
-- 
2.5.5
