From: Gal Pressman <galp@mellanox.com>
Subject: [RFC PATCH net-next 2/3] net/mlx5: Add PDDR register infrastructure
Date: Wed, 21 Jun 2017 16:04:45 +0300
Message-ID: <1498050286-17141-3-git-send-email-galp@mellanox.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com,
        Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34757 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751106AbdFUNFY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 09:05:24 -0400
In-Reply-To: <1498050286-17141-1-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PDDR (Port Diagnostics Database Register) is used to read the physical
layer debug database, which contains helpful troubleshooting information
regarding the state of the link.

PDDR register can only be queried when PCAM register reports it as
supported in its register mask. A new helper macro was added to
the MLX5_CAP_* infrastructure in order to access this mask.

Expose query functions for PDDR register which will be used in the
following patch.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    | 29 ++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     | 14 ++++++
 include/linux/mlx5/device.h                        |  3 ++
 include/linux/mlx5/driver.h                        |  1 +
 include/linux/mlx5/mlx5_ifc.h                      | 51 ++++++++++++++++++++++
 5 files changed, 98 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 5ccdf43..cbb6a0e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -79,6 +79,35 @@ enum {
 	MLX5_DRIVER_SYND = 0xbadd00de,
 };
 
+enum mlx5_pddr_page_select {
+	MLX5_PDDR_OPERATIONAL_INFO_PAGE            = 0x0,
+	MLX5_PDDR_TROUBLESHOOTING_INFO_PAGE        = 0x1,
+	MLX5_PDDR_MODULE_INFO_PAGE                 = 0x3,
+};
+
+enum mlx5_pddr_monitor_opcodes {
+	MLX5_LINK_NO_ISSUE_OBSERVED                = 0x0,
+	MLX5_LINK_PORT_CLOSED                      = 0x1,
+	MLX5_LINK_AN_FAILURE                       = 0x2,
+	MLX5_LINK_TRAINING_FAILURE                 = 0x5,
+	MLX5_LINK_LOGICAL_MISMATCH                 = 0x9,
+	MLX5_LINK_REMOTE_FAULT_INDICATION          = 0xe,
+	MLX5_LINK_BAD_SIGNAL_INTEGRITY             = 0xf,
+	MLX5_LINK_CABLE_COMPLIANCE_CODE_MISMATCH   = 0x10,
+	MLX5_LINK_INTERNAL_ERR                     = 0x17,
+	MLX5_LINK_INFO_NOT_AVAIL                   = 0x3ff,
+	MLX5_LINK_CABLE_UNPLUGGED                  = 0x400,
+	MLX5_LINK_LONG_RANGE_FOR_NON_MLX_CABLE     = 0x401,
+	MLX5_LINK_BUS_STUCK                        = 0x402,
+	MLX5_LINK_UNSUPP_EEPROM                    = 0x403,
+	MLX5_LINK_PART_NUM_LIST                    = 0x404,
+	MLX5_LINK_UNSUPP_CABLE                     = 0x405,
+	MLX5_LINK_MODULE_TEMP_SHUTDOWN             = 0x406,
+	MLX5_LINK_SHORTED_CABLE                    = 0x407,
+	MLX5_LINK_POWER_BUDGET_EXCEEDED            = 0x408,
+	MLX5_LINK_MNG_FORCED_DOWN                  = 0x409,
+};
+
 int mlx5_query_hca_caps(struct mlx5_core_dev *dev);
 int mlx5_query_board_id(struct mlx5_core_dev *dev);
 int mlx5_cmd_init_hca(struct mlx5_core_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 1975d43..38e97b2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -789,6 +789,20 @@ int mlx5_query_port_wol(struct mlx5_core_dev *mdev, u8 *wol_mode)
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_wol);
 
+static int mlx5_query_pddr(struct mlx5_core_dev *mdev,
+			   int page_select, u32 *out, int outlen)
+{
+	u32 in[MLX5_ST_SZ_DW(pddr_reg)] = {0};
+
+	if (!MLX5_CAP_PCAM_REG(mdev, pddr))
+		return -EOPNOTSUPP;
+
+	MLX5_SET(pddr_reg, in, local_port, 1);
+	MLX5_SET(pddr_reg, in, page_select, page_select);
+
+	return mlx5_core_access_reg(mdev, in, sizeof(in), out, outlen, MLX5_REG_PDDR, 0, 0);
+}
+
 static int mlx5_query_ports_check(struct mlx5_core_dev *mdev, u32 *out,
 				  int outlen)
 {
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index b26a478..b70b283 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1094,6 +1094,9 @@ enum mlx5_mcam_feature_groups {
 #define MLX5_CAP_PCAM_FEATURE(mdev, fld) \
 	MLX5_GET(pcam_reg, (mdev)->caps.pcam, feature_cap_mask.enhanced_features.fld)
 
+#define MLX5_CAP_PCAM_REG(mdev, reg) \
+	MLX5_GET(pcam_reg, (mdev)->caps.pcam, port_access_reg_cap_mask.regs_5000_to_507f.reg)
+
 #define MLX5_CAP_MCAM_FEATURE(mdev, fld) \
 	MLX5_GET(mcam_reg, (mdev)->caps.mcam, mng_feature_cap_mask.enhanced_features.fld)
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index bf15e87..876056f 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -121,6 +121,7 @@ enum {
 	MLX5_REG_PMPE		 = 0x5010,
 	MLX5_REG_PELC		 = 0x500e,
 	MLX5_REG_PVLC		 = 0x500f,
+	MLX5_REG_PDDR		 = 0x5031,
 	MLX5_REG_PCMR		 = 0x5041,
 	MLX5_REG_PMLP		 = 0x5002,
 	MLX5_REG_PCAM		 = 0x507f,
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index e86ef88..cdb2435 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -7465,6 +7465,45 @@ struct mlx5_ifc_ppcnt_reg_bits {
 	union mlx5_ifc_eth_cntrs_grp_data_layout_auto_bits counter_set;
 };
 
+struct mlx5_ifc_monitor_opcodes_layout_bits {
+	u8         reserved_at_0[0x10];
+	u8         monitor_opcode[0x10];
+};
+
+union mlx5_ifc_pddr_status_opcode_bits {
+	struct mlx5_ifc_monitor_opcodes_layout_bits monitor_opcodes;
+	u8         reserved_at_0[0x20];
+};
+
+struct mlx5_ifc_troubleshooting_info_page_layout_bits {
+	u8         reserved_at_0[0x10];
+	u8         group_opcode[0x10];
+
+	union mlx5_ifc_pddr_status_opcode_bits status_opcode;
+
+	u8         user_feedback_data[0x10];
+	u8         user_feedback_index[0x10];
+
+	u8         status_message[0x760];
+};
+
+union mlx5_ifc_pddr_page_data_bits {
+	struct mlx5_ifc_troubleshooting_info_page_layout_bits troubleshooting_info_page;
+	u8         reserved_at_0[0x7c0];
+};
+
+struct mlx5_ifc_pddr_reg_bits {
+	u8         reserved_at_0[0x8];
+	u8         local_port[0x8];
+	u8         pnat[0x2];
+	u8         reserved_at_12[0xe];
+
+	u8         reserved_at_20[0x18];
+	u8         page_select[0x8];
+
+	union mlx5_ifc_pddr_page_data_bits page_data;
+};
+
 struct mlx5_ifc_mpcnt_reg_bits {
 	u8         reserved_at_0[0x8];
 	u8         pcie_index[0x8];
@@ -7715,6 +7754,17 @@ struct mlx5_ifc_pcam_enhanced_features_bits {
 	u8         ppcnt_statistical_group[0x1];
 };
 
+struct mlx5_ifc_pcam_regs_5000_to_507f_bits {
+	u8         port_access_reg_cap_mask_127_to_96[0x20];
+	u8         port_access_reg_cap_mask_95_to_64[0x20];
+
+	u8         reserved_at_40[0xe];
+	u8         pddr[0x1];
+	u8         reserved_at_4f[0x11];
+
+	u8         port_access_reg_cap_mask_31_to_0[0x20];
+};
+
 struct mlx5_ifc_pcam_reg_bits {
 	u8         reserved_at_0[0x8];
 	u8         feature_group[0x8];
@@ -7724,6 +7774,7 @@ struct mlx5_ifc_pcam_reg_bits {
 	u8         reserved_at_20[0x20];
 
 	union {
+		struct mlx5_ifc_pcam_regs_5000_to_507f_bits regs_5000_to_507f;
 		u8         reserved_at_0[0x80];
 	} port_access_reg_cap_mask;
 
-- 
2.7.4
