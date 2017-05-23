From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/8] mlxsw: reg: Add Management Component Query Information register
Date: Tue, 23 May 2017 21:56:24 +0200
Message-ID: <20170523195630.6460-3-jiri@resnulli.us>
References: <20170523195630.6460-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com, Yuval.Mintz@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35967 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968110AbdEWT4g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:56:36 -0400
Received: by mail-wm0-f65.google.com with SMTP id k15so40770271wmh.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:56:36 -0700 (PDT)
In-Reply-To: <20170523195630.6460-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The MCQI register queries information about firmware components. It will
be needed by the mlxfw module to query various options about the
components, such as their max size, alignment and max write size.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 84 +++++++++++++++++++++++++++++++
 1 file changed, 84 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 83b277c..adb385f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5643,6 +5643,89 @@ static inline void mlxsw_reg_mlcr_pack(char *payload, u8 local_port,
 					   MLXSW_REG_MLCR_DURATION_MAX : 0);
 }
 
+/* MCQI - Management Component Query Information
+ * ---------------------------------------------
+ * This register allows querying information about firmware components.
+ */
+#define MLXSW_REG_MCQI_ID 0x9061
+#define MLXSW_REG_MCQI_BASE_LEN 0x18
+#define MLXSW_REG_MCQI_CAP_LEN 0x14
+#define MLXSW_REG_MCQI_LEN (MLXSW_REG_MCQI_BASE_LEN + MLXSW_REG_MCQI_CAP_LEN)
+
+MLXSW_REG_DEFINE(mcqi, MLXSW_REG_MCQI_ID, MLXSW_REG_MCQI_LEN);
+
+/* reg_mcqi_component_index
+ * Index of the accessed component.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mcqi, component_index, 0x00, 0, 16);
+
+enum mlxfw_reg_mcqi_info_type {
+	MLXSW_REG_MCQI_INFO_TYPE_CAPABILITIES,
+};
+
+/* reg_mcqi_info_type
+ * Component properties set.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcqi, info_type, 0x08, 0, 5);
+
+/* reg_mcqi_offset
+ * The requested/returned data offset from the section start, given in bytes.
+ * Must be DWORD aligned.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcqi, offset, 0x10, 0, 32);
+
+/* reg_mcqi_data_size
+ * The requested/returned data size, given in bytes. If data_size is not DWORD
+ * aligned, the last bytes are zero padded.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcqi, data_size, 0x14, 0, 16);
+
+/* reg_mcqi_cap_max_component_size
+ * Maximum size for this component, given in bytes.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mcqi, cap_max_component_size, 0x20, 0, 32);
+
+/* reg_mcqi_cap_log_mcda_word_size
+ * Log 2 of the access word size in bytes. Read and write access must be aligned
+ * to the word size. Write access must be done for an integer number of words.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mcqi, cap_log_mcda_word_size, 0x24, 28, 4);
+
+/* reg_mcqi_cap_mcda_max_write_size
+ * Maximal write size for MCDA register
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mcqi, cap_mcda_max_write_size, 0x24, 0, 16);
+
+static inline void mlxsw_reg_mcqi_pack(char *payload, u16 component_index)
+{
+	MLXSW_REG_ZERO(mcqi, payload);
+	mlxsw_reg_mcqi_component_index_set(payload, component_index);
+	mlxsw_reg_mcqi_info_type_set(payload,
+				     MLXSW_REG_MCQI_INFO_TYPE_CAPABILITIES);
+	mlxsw_reg_mcqi_offset_set(payload, 0);
+	mlxsw_reg_mcqi_data_size_set(payload, MLXSW_REG_MCQI_CAP_LEN);
+}
+
+static inline void mlxsw_reg_mcqi_unpack(char *payload,
+					 u32 *p_cap_max_component_size,
+					 u8 *p_cap_log_mcda_word_size,
+					 u16 *p_cap_mcda_max_write_size)
+{
+	*p_cap_max_component_size =
+		mlxsw_reg_mcqi_cap_max_component_size_get(payload);
+	*p_cap_log_mcda_word_size =
+		mlxsw_reg_mcqi_cap_log_mcda_word_size_get(payload);
+	*p_cap_mcda_max_write_size =
+		mlxsw_reg_mcqi_cap_mcda_max_write_size_get(payload);
+}
+
 /* MPSC - Monitoring Packet Sampling Configuration Register
  * --------------------------------------------------------
  * MPSC Register is used to configure the Packet Sampling mechanism.
@@ -6221,6 +6304,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(mpar),
 	MLXSW_REG(mlcr),
 	MLXSW_REG(mpsc),
+	MLXSW_REG(mcqi),
 	MLXSW_REG(mgpc),
 	MLXSW_REG(sbpr),
 	MLXSW_REG(sbcm),
-- 
2.9.3
