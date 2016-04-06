From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/17] mlxsw: reg: Add Port Prio To Buffer register
Date: Wed,  6 Apr 2016 17:10:00 +0200
Message-ID: <1459955416-23786-2-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33296 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbcDFPKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:32 -0400
Received: by mail-wm0-f66.google.com with SMTP id i204so14156076wmd.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:31 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When packets ingress the switch they are assigned a switch priority
number that dictates the packet's priority group (PG) buffer in the
port's headroom buffer.

Add the Port Prio To Buffer (PPTB) register, which configures the switch
priority to PG mapping.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 83 +++++++++++++++++++++++++++++++
 1 file changed, 83 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index ffe4c03..0995bee 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2340,6 +2340,87 @@ static inline void mlxsw_reg_ppcnt_pack(char *payload, u8 local_port)
 	mlxsw_reg_ppcnt_prio_tc_set(payload, 0);
 }
 
+/* PPTB - Port Prio To Buffer Register
+ * -----------------------------------
+ * Configures the switch priority to buffer table.
+ */
+#define MLXSW_REG_PPTB_ID 0x500B
+#define MLXSW_REG_PPTB_LEN 0x0C
+
+static const struct mlxsw_reg_info mlxsw_reg_pptb = {
+	.id = MLXSW_REG_PPTB_ID,
+	.len = MLXSW_REG_PPTB_LEN,
+};
+
+enum {
+	MLXSW_REG_PPTB_MM_UM,
+	MLXSW_REG_PPTB_MM_UNICAST,
+	MLXSW_REG_PPTB_MM_MULTICAST,
+};
+
+/* reg_pptb_mm
+ * Mapping mode.
+ * 0 - Map both unicast and multicast packets to the same buffer.
+ * 1 - Map only unicast packets.
+ * 2 - Map only multicast packets.
+ * Access: Index
+ *
+ * Note: SwitchX-2 only supports the first option.
+ */
+MLXSW_ITEM32(reg, pptb, mm, 0x00, 28, 2);
+
+/* reg_pptb_local_port
+ * Local port number.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, pptb, local_port, 0x00, 16, 8);
+
+/* reg_pptb_um
+ * Enables the update of the untagged_buf field.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, pptb, um, 0x00, 8, 1);
+
+/* reg_pptb_pm
+ * Enables the update of the prio_to_buff field.
+ * Bit <i> is a flag for updating the mapping for switch priority <i>.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, pptb, pm, 0x00, 0, 8);
+
+/* reg_pptb_prio_to_buff
+ * Mapping of switch priority <i> to one of the allocated receive port
+ * buffers.
+ * Access: RW
+ */
+MLXSW_ITEM_BIT_ARRAY(reg, pptb, prio_to_buff, 0x04, 0x04, 4);
+
+/* reg_pptb_pm_msb
+ * Enables the update of the prio_to_buff field.
+ * Bit <i> is a flag for updating the mapping for switch priority <i+8>.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, pptb, pm_msb, 0x08, 24, 8);
+
+/* reg_pptb_untagged_buff
+ * Mapping of untagged frames to one of the allocated receive port buffers.
+ * Access: RW
+ *
+ * Note: In SwitchX-2 this field must be mapped to buffer 8. Reserved for
+ * Spectrum, as it maps untagged packets based on the default switch priority.
+ */
+MLXSW_ITEM32(reg, pptb, untagged_buff, 0x08, 0, 4);
+
+#define MLXSW_REG_PPTB_ALL_PRIO 0xFF
+
+static inline void mlxsw_reg_pptb_pack(char *payload, u8 local_port)
+{
+	MLXSW_REG_ZERO(pptb, payload);
+	mlxsw_reg_pptb_mm_set(payload, MLXSW_REG_PPTB_MM_UM);
+	mlxsw_reg_pptb_local_port_set(payload, local_port);
+	mlxsw_reg_pptb_pm_set(payload, MLXSW_REG_PPTB_ALL_PRIO);
+}
+
 /* PBMC - Port Buffer Management Control Register
  * ----------------------------------------------
  * The PBMC register configures and retrieves the port packet buffer
@@ -3295,6 +3376,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "PAOS";
 	case MLXSW_REG_PPCNT_ID:
 		return "PPCNT";
+	case MLXSW_REG_PPTB_ID:
+		return "PPTB";
 	case MLXSW_REG_PBMC_ID:
 		return "PBMC";
 	case MLXSW_REG_PSPA_ID:
-- 
2.5.5
