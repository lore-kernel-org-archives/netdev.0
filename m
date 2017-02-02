From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/19] mlxsw: reg: Add Policy-Engine TCAM Allocation Register
Date: Thu,  2 Feb 2017 16:12:45 +0100
Message-ID: <1486048379-19237-6-git-send-email-jiri@resnulli.us>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:36003 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751875AbdBBPNI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 10:13:08 -0500
Received: by mail-wj0-f195.google.com with SMTP id kq3so1333023wjc.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 07:13:07 -0800 (PST)
In-Reply-To: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The PTAR register is used for allocation of regions in the TCAM.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 106 ++++++++++++++++++++++++++++++
 1 file changed, 106 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 5f76fbc..444f0a3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1852,6 +1852,111 @@ static inline void mlxsw_reg_pagt_acl_id_pack(char *payload, int index,
 	mlxsw_reg_pagt_acl_id_set(payload, index, acl_id);
 }
 
+/* PTAR - Policy-Engine TCAM Allocation Register
+ * ---------------------------------------------
+ * This register is used for allocation of regions in the TCAM.
+ * Note: Query method is not supported on this register.
+ */
+#define MLXSW_REG_PTAR_ID 0x3006
+#define MLXSW_REG_PTAR_BASE_LEN 0x20
+#define MLXSW_REG_PTAR_KEY_ID_LEN 1
+#define MLXSW_REG_PTAR_KEY_ID_MAX_NUM 16
+#define MLXSW_REG_PTAR_LEN (MLXSW_REG_PTAR_BASE_LEN + \
+		MLXSW_REG_PTAR_KEY_ID_MAX_NUM * MLXSW_REG_PTAR_KEY_ID_LEN)
+
+MLXSW_REG_DEFINE(ptar, MLXSW_REG_PTAR_ID, MLXSW_REG_PTAR_LEN);
+
+enum mlxsw_reg_ptar_op {
+	/* allocate a TCAM region */
+	MLXSW_REG_PTAR_OP_ALLOC,
+	/* resize a TCAM region */
+	MLXSW_REG_PTAR_OP_RESIZE,
+	/* deallocate TCAM region */
+	MLXSW_REG_PTAR_OP_FREE,
+	/* test allocation */
+	MLXSW_REG_PTAR_OP_TEST,
+};
+
+/* reg_ptar_op
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, ptar, op, 0x00, 28, 4);
+
+/* reg_ptar_action_set_type
+ * Type of action set to be used on this region.
+ * For Spectrum, this is always type 2 - "flexible"
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, ptar, action_set_type, 0x00, 16, 8);
+
+/* reg_ptar_key_type
+ * TCAM key type for the region.
+ * For Spectrum, this is always type 0x50 - "FLEX_KEY"
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, ptar, key_type, 0x00, 0, 8);
+
+/* reg_ptar_region_size
+ * TCAM region size. When allocating/resizing this is the requested size,
+ * the response is the actual size. Note that actual size may be
+ * larger than requested.
+ * Allowed range 1 .. cap_max_rules-1
+ * Reserved during op deallocate.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, ptar, region_size, 0x04, 0, 16);
+
+/* reg_ptar_region_id
+ * Region identifier
+ * Range 0 .. cap_max_regions-1
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ptar, region_id, 0x08, 0, 16);
+
+/* reg_ptar_tcam_region_info
+ * Opaque object that represents the TCAM region.
+ * Returned when allocating a region.
+ * Provided by software for ACL generation and region deallocation and resize.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, ptar, tcam_region_info, 0x10,
+	       MLXSW_REG_PXXX_TCAM_REGION_INFO_LEN);
+
+/* reg_ptar_flexible_key_id
+ * Identifier of the Flexible Key.
+ * Only valid if key_type == "FLEX_KEY"
+ * The key size will be rounded up to one of the following values:
+ * 9B, 18B, 36B, 54B.
+ * This field is reserved for in resize operation.
+ * Access: WO
+ */
+MLXSW_ITEM8_INDEXED(reg, ptar, flexible_key_id, 0x20, 0, 8,
+		    MLXSW_REG_PTAR_KEY_ID_LEN, 0x00, false);
+
+static inline void mlxsw_reg_ptar_pack(char *payload, enum mlxsw_reg_ptar_op op,
+				       u16 region_size, u16 region_id,
+				       const char *tcam_region_info)
+{
+	MLXSW_REG_ZERO(ptar, payload);
+	mlxsw_reg_ptar_op_set(payload, op);
+	mlxsw_reg_ptar_action_set_type_set(payload, 2); /* "flexible" */
+	mlxsw_reg_ptar_key_type_set(payload, 0x50); /* "FLEX_KEY" */
+	mlxsw_reg_ptar_region_size_set(payload, region_size);
+	mlxsw_reg_ptar_region_id_set(payload, region_id);
+	mlxsw_reg_ptar_tcam_region_info_memcpy_to(payload, tcam_region_info);
+}
+
+static inline void mlxsw_reg_ptar_key_id_pack(char *payload, int index,
+					      u16 key_id)
+{
+	mlxsw_reg_ptar_flexible_key_id_set(payload, index, key_id);
+}
+
+static inline void mlxsw_reg_ptar_unpack(char *payload, char *tcam_region_info)
+{
+	mlxsw_reg_ptar_tcam_region_info_memcpy_from(payload, tcam_region_info);
+}
+
 /* QPCR - QoS Policer Configuration Register
  * -----------------------------------------
  * The QPCR register is used to create policers - that limit
@@ -5531,6 +5636,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(spvmlr),
 	MLXSW_REG(pacl),
 	MLXSW_REG(pagt),
+	MLXSW_REG(ptar),
 	MLXSW_REG(qpcr),
 	MLXSW_REG(qtct),
 	MLXSW_REG(qeec),
-- 
2.7.4
