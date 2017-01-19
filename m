From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 07/15] net/mlx5: Expose PCAM, MCAM registers infrastructure
Date: Fri, 20 Jan 2017 00:39:00 +0200
Message-ID: <20170119223908.15924-8-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59329 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751857AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

PCAM: Ports capabilities mask register.
MCAM: Management capabilities mask register.

PCAM and MCAM registers will provide information regarding firmware
support for different features, in order to avoid cases where new driver
combined with old firmware results in syndromes (for ex. PCIe counters
before this patchset).

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/device.h   | 16 ++++++++++++
 include/linux/mlx5/driver.h   |  2 ++
 include/linux/mlx5/mlx5_ifc.h | 60 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 77 insertions(+), 1 deletion(-)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 6ac8eb5a89ca..79f38e67fe2f 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -970,6 +970,22 @@ enum mlx5_cap_type {
 	MLX5_CAP_NUM
 };
 
+enum mlx5_pcam_reg_groups {
+	MLX5_PCAM_REGS_5000_TO_507F                 = 0x0,
+};
+
+enum mlx5_pcam_feature_groups {
+	MLX5_PCAM_FEATURE_ENHANCED_FEATURES         = 0x0,
+};
+
+enum mlx5_mcam_reg_groups {
+	MLX5_MCAM_REGS_FIRST_128                    = 0x0,
+};
+
+enum mlx5_mcam_feature_groups {
+	MLX5_MCAM_FEATURE_ENHANCED_FEATURES         = 0x0,
+};
+
 /* GET Dev Caps macros */
 #define MLX5_CAP_GEN(mdev, cap) \
 	MLX5_GET(cmd_hca_cap, mdev->hca_caps_cur[MLX5_CAP_GENERAL], cap)
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index ebbc8834063b..60c2b156da8c 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -121,12 +121,14 @@ enum {
 	MLX5_REG_PVLC		 = 0x500f,
 	MLX5_REG_PCMR		 = 0x5041,
 	MLX5_REG_PMLP		 = 0x5002,
+	MLX5_REG_PCAM		 = 0x507f,
 	MLX5_REG_NODE_DESC	 = 0x6001,
 	MLX5_REG_HOST_ENDIANNESS = 0x7004,
 	MLX5_REG_MCIA		 = 0x9014,
 	MLX5_REG_MLCR		 = 0x902b,
 	MLX5_REG_MTPPS		 = 0x9053,
 	MLX5_REG_MTPPSE		 = 0x9054,
+	MLX5_REG_MCAM		 = 0x907f,
 };
 
 enum mlx5_dcbx_oper_mode {
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 6f19e4b8574f..e8061a95326a 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -826,7 +826,8 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         nic_flow_table[0x1];
 	u8         eswitch_flow_table[0x1];
 	u8	   early_vf_enable[0x1];
-	u8         reserved_at_1a9[0x2];
+	u8         mcam_reg[0x1];
+	u8         pcam_reg[0x1];
 	u8         local_ca_ack_delay[0x5];
 	u8         port_module_event[0x1];
 	u8         reserved_at_1b1[0x1];
@@ -7481,6 +7482,63 @@ struct mlx5_ifc_peir_reg_bits {
 	u8         error_type[0x8];
 };
 
+struct mlx5_ifc_pcam_enhanced_features_bits {
+	u8         reserved_at_0[0x7e];
+
+	u8         ppcnt_discard_group[0x1];
+	u8         ppcnt_statistical_group[0x1];
+};
+
+struct mlx5_ifc_pcam_reg_bits {
+	u8         reserved_at_0[0x8];
+	u8         feature_group[0x8];
+	u8         reserved_at_10[0x8];
+	u8         access_reg_group[0x8];
+
+	u8         reserved_at_20[0x20];
+
+	union {
+		u8         reserved_at_0[0x80];
+	} port_access_reg_cap_mask;
+
+	u8         reserved_at_c0[0x80];
+
+	union {
+		struct mlx5_ifc_pcam_enhanced_features_bits enhanced_features;
+		u8         reserved_at_0[0x80];
+	} feature_cap_mask;
+
+	u8         reserved_at_1c0[0xc0];
+};
+
+struct mlx5_ifc_mcam_enhanced_features_bits {
+	u8         reserved_at_0[0x7f];
+
+	u8         pcie_performance_group[0x1];
+};
+
+struct mlx5_ifc_mcam_reg_bits {
+	u8         reserved_at_0[0x8];
+	u8         feature_group[0x8];
+	u8         reserved_at_10[0x8];
+	u8         access_reg_group[0x8];
+
+	u8         reserved_at_20[0x20];
+
+	union {
+		u8         reserved_at_0[0x80];
+	} mng_access_reg_cap_mask;
+
+	u8         reserved_at_c0[0x80];
+
+	union {
+		struct mlx5_ifc_mcam_enhanced_features_bits enhanced_features;
+		u8         reserved_at_0[0x80];
+	} mng_feature_cap_mask;
+
+	u8         reserved_at_1c0[0x80];
+};
+
 struct mlx5_ifc_pcap_reg_bits {
 	u8         reserved_at_0[0x8];
 	u8         local_port[0x8];
-- 
2.11.0
