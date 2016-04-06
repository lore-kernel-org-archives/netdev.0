From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/17] mlxsw: reg: Add QoS ETS Element Configuration register
Date: Wed,  6 Apr 2016 17:10:06 +0200
Message-ID: <1459955416-23786-8-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33443 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359AbcDFPKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:40 -0400
Received: by mail-wm0-f68.google.com with SMTP id i204so14157168wmd.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:33 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We are going to introduce support for DCB, so we need to be able to
configure the traffic selection algorithm (TSA) used by each traffic
class (TC), as well as the bandwidth percentage allocated to each TC in
case of ETS.

Add the QoS ETS Element Configuration register, which controls the
above parameters.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 127 ++++++++++++++++++++++++++++++
 1 file changed, 127 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 370914e..bc08f8b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1805,6 +1805,131 @@ static inline void mlxsw_reg_spvmlr_pack(char *payload, u8 local_port,
 	}
 }
 
+/* QEEC - QoS ETS Element Configuration Register
+ * ---------------------------------------------
+ * Configures the ETS elements.
+ */
+#define MLXSW_REG_QEEC_ID 0x400D
+#define MLXSW_REG_QEEC_LEN 0x1C
+
+static const struct mlxsw_reg_info mlxsw_reg_qeec = {
+	.id = MLXSW_REG_QEEC_ID,
+	.len = MLXSW_REG_QEEC_LEN,
+};
+
+/* reg_qeec_local_port
+ * Local port number.
+ * Access: Index
+ *
+ * Note: CPU port is supported.
+ */
+MLXSW_ITEM32(reg, qeec, local_port, 0x00, 16, 8);
+
+enum mlxsw_reg_qeec_hr {
+	MLXSW_REG_QEEC_HIERARCY_PORT,
+	MLXSW_REG_QEEC_HIERARCY_GROUP,
+	MLXSW_REG_QEEC_HIERARCY_SUBGROUP,
+	MLXSW_REG_QEEC_HIERARCY_TC,
+};
+
+/* reg_qeec_element_hierarchy
+ * 0 - Port
+ * 1 - Group
+ * 2 - Subgroup
+ * 3 - Traffic Class
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, qeec, element_hierarchy, 0x04, 16, 4);
+
+/* reg_qeec_element_index
+ * The index of the element in the hierarchy.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, qeec, element_index, 0x04, 0, 8);
+
+/* reg_qeec_next_element_index
+ * The index of the next (lower) element in the hierarchy.
+ * Access: RW
+ *
+ * Note: Reserved for element_hierarchy 0.
+ */
+MLXSW_ITEM32(reg, qeec, next_element_index, 0x08, 0, 8);
+
+enum {
+	MLXSW_REG_QEEC_BYTES_MODE,
+	MLXSW_REG_QEEC_PACKETS_MODE,
+};
+
+/* reg_qeec_pb
+ * Packets or bytes mode.
+ * 0 - Bytes mode
+ * 1 - Packets mode
+ * Access: RW
+ *
+ * Note: Used for max shaper configuration. For Spectrum, packets mode
+ * is supported only for traffic classes of CPU port.
+ */
+MLXSW_ITEM32(reg, qeec, pb, 0x0C, 28, 1);
+
+/* reg_qeec_mase
+ * Max shaper configuration enable. Enables configuration of the max
+ * shaper on this ETS element.
+ * 0 - Disable
+ * 1 - Enable
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, qeec, mase, 0x10, 31, 1);
+
+/* A large max rate will disable the max shaper. */
+#define MLXSW_REG_QEEC_MAS_DIS	200000000	/* Kbps */
+
+/* reg_qeec_max_shaper_rate
+ * Max shaper information rate.
+ * For CPU port, can only be configured for port hierarchy.
+ * When in bytes mode, value is specified in units of 1000bps.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, qeec, max_shaper_rate, 0x10, 0, 28);
+
+/* reg_qeec_de
+ * DWRR configuration enable. Enables configuration of the dwrr and
+ * dwrr_weight.
+ * 0 - Disable
+ * 1 - Enable
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, qeec, de, 0x18, 31, 1);
+
+/* reg_qeec_dwrr
+ * Transmission selection algorithm to use on the link going down from
+ * the ETS element.
+ * 0 - Strict priority
+ * 1 - DWRR
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, qeec, dwrr, 0x18, 15, 1);
+
+/* reg_qeec_dwrr_weight
+ * DWRR weight on the link going down from the ETS element. The
+ * percentage of bandwidth guaranteed to an ETS element within
+ * its hierarchy. The sum of all weights across all ETS elements
+ * within one hierarchy should be equal to 100. Reserved when
+ * transmission selection algorithm is strict priority.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, qeec, dwrr_weight, 0x18, 0, 8);
+
+static inline void mlxsw_reg_qeec_pack(char *payload, u8 local_port,
+				       enum mlxsw_reg_qeec_hr hr, u8 index,
+				       u8 next_index)
+{
+	MLXSW_REG_ZERO(qeec, payload);
+	mlxsw_reg_qeec_local_port_set(payload, local_port);
+	mlxsw_reg_qeec_element_hierarchy_set(payload, hr);
+	mlxsw_reg_qeec_element_index_set(payload, index);
+	mlxsw_reg_qeec_next_element_index_set(payload, next_index);
+}
+
 /* PMLP - Ports Module to Local Port Register
  * ------------------------------------------
  * Configures the assignment of modules to local ports.
@@ -3366,6 +3491,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SFMR";
 	case MLXSW_REG_SPVMLR_ID:
 		return "SPVMLR";
+	case MLXSW_REG_QEEC_ID:
+		return "QEEC";
 	case MLXSW_REG_PMLP_ID:
 		return "PMLP";
 	case MLXSW_REG_PMTU_ID:
-- 
2.5.5
