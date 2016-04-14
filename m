From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/18] mlxsw: reg: Add Shared Buffer Status register definition
Date: Thu, 14 Apr 2016 18:19:26 +0200
Message-ID: <1460650770-19382-15-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35807 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964802AbcDNQTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:53 -0400
Received: by mail-wm0-f50.google.com with SMTP id a140so154843992wma.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:52 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This register allows to query HW for current and maximal buffer usage.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 100 ++++++++++++++++++++++++++++++
 1 file changed, 100 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index fce5a96..656466a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3722,6 +3722,104 @@ static inline void mlxsw_reg_sbmm_pack(char *payload, u8 prio, u32 min_buff,
 	mlxsw_reg_sbmm_pool_set(payload, pool);
 }
 
+/* SBSR - Shared Buffer Status Register
+ * ------------------------------------
+ * The SBSR register retrieves the shared buffer occupancy according to
+ * Port-Pool. Note that this register enables reading a large amount of data.
+ * It is the user's responsibility to limit the amount of data to ensure the
+ * response can match the maximum transfer unit. In case the response exceeds
+ * the maximum transport unit, it will be truncated with no special notice.
+ */
+#define MLXSW_REG_SBSR_ID 0xB005
+#define MLXSW_REG_SBSR_BASE_LEN 0x5C /* base length, without records */
+#define MLXSW_REG_SBSR_REC_LEN 0x8 /* record length */
+#define MLXSW_REG_SBSR_REC_MAX_COUNT 120
+#define MLXSW_REG_SBSR_LEN (MLXSW_REG_SBSR_BASE_LEN +	\
+			    MLXSW_REG_SBSR_REC_LEN *	\
+			    MLXSW_REG_SBSR_REC_MAX_COUNT)
+
+static const struct mlxsw_reg_info mlxsw_reg_sbsr = {
+	.id = MLXSW_REG_SBSR_ID,
+	.len = MLXSW_REG_SBSR_LEN,
+};
+
+/* reg_sbsr_clr
+ * Clear Max Buffer Occupancy. When this bit is set, the max_buff_occupancy
+ * field is cleared (and a new max value is tracked from the time the clear
+ * was performed).
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, sbsr, clr, 0x00, 31, 1);
+
+/* reg_sbsr_ingress_port_mask
+ * Bit vector for all ingress network ports.
+ * Indicates which of the ports (for which the relevant bit is set)
+ * are affected by the set operation. Configuration of any other port
+ * does not change.
+ * Access: Index
+ */
+MLXSW_ITEM_BIT_ARRAY(reg, sbsr, ingress_port_mask, 0x10, 0x20, 1);
+
+/* reg_sbsr_pg_buff_mask
+ * Bit vector for all switch priority groups.
+ * Indicates which of the priorities (for which the relevant bit is set)
+ * are affected by the set operation. Configuration of any other priority
+ * does not change.
+ * Range is 0..cap_max_pg_buffers - 1
+ * Access: Index
+ */
+MLXSW_ITEM_BIT_ARRAY(reg, sbsr, pg_buff_mask, 0x30, 0x4, 1);
+
+/* reg_sbsr_egress_port_mask
+ * Bit vector for all egress network ports.
+ * Indicates which of the ports (for which the relevant bit is set)
+ * are affected by the set operation. Configuration of any other port
+ * does not change.
+ * Access: Index
+ */
+MLXSW_ITEM_BIT_ARRAY(reg, sbsr, egress_port_mask, 0x34, 0x20, 1);
+
+/* reg_sbsr_tclass_mask
+ * Bit vector for all traffic classes.
+ * Indicates which of the traffic classes (for which the relevant bit is
+ * set) are affected by the set operation. Configuration of any other
+ * traffic class does not change.
+ * Range is 0..cap_max_tclass - 1
+ * Access: Index
+ */
+MLXSW_ITEM_BIT_ARRAY(reg, sbsr, tclass_mask, 0x54, 0x8, 1);
+
+static inline void mlxsw_reg_sbsr_pack(char *payload, bool clr)
+{
+	MLXSW_REG_ZERO(sbsr, payload);
+	mlxsw_reg_sbsr_clr_set(payload, clr);
+}
+
+/* reg_sbsr_rec_buff_occupancy
+ * Current buffer occupancy in cells.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, sbsr, rec_buff_occupancy, MLXSW_REG_SBSR_BASE_LEN,
+		     0, 24, MLXSW_REG_SBSR_REC_LEN, 0x00, false);
+
+/* reg_sbsr_rec_max_buff_occupancy
+ * Maximum value of buffer occupancy in cells monitored. Cleared by
+ * writing to the clr field.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, sbsr, rec_max_buff_occupancy, MLXSW_REG_SBSR_BASE_LEN,
+		     0, 24, MLXSW_REG_SBSR_REC_LEN, 0x04, false);
+
+static inline void mlxsw_reg_sbsr_rec_unpack(char *payload, int rec_index,
+					     u32 *p_buff_occupancy,
+					     u32 *p_max_buff_occupancy)
+{
+	*p_buff_occupancy =
+		mlxsw_reg_sbsr_rec_buff_occupancy_get(payload, rec_index);
+	*p_max_buff_occupancy =
+		mlxsw_reg_sbsr_rec_max_buff_occupancy_get(payload, rec_index);
+}
+
 static inline const char *mlxsw_reg_id_str(u16 reg_id)
 {
 	switch (reg_id) {
@@ -3817,6 +3915,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SBPM";
 	case MLXSW_REG_SBMM_ID:
 		return "SBMM";
+	case MLXSW_REG_SBSR_ID:
+		return "SBSR";
 	default:
 		return "*UNKNOWN*";
 	}
-- 
2.5.5
