From: Gal Pressman <galp@mellanox.com>
Subject: [RFC PATCH net-next 3/3] net/mlx5e: Expose link down reason to ethtool
Date: Wed, 21 Jun 2017 16:04:46 +0300
Message-ID: <1498050286-17141-4-git-send-email-galp@mellanox.com>
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
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34774 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751865AbdFUNFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 09:05:34 -0400
In-Reply-To: <1498050286-17141-1-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new ethtool link down reason api, and expose troubleshooting
info regarding the link status.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 107 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   4 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  25 +++++
 3 files changed, 136 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index ab46061..a5e9f1f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -135,6 +135,88 @@ void mlx5e_build_ptys2ethtool_map(void)
 				       ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT);
 }
 
+static const struct {
+	u16 pddr;
+	u32 ethtool;
+} pddr2ethtool_table[] = {
+	{
+		.pddr    = MLX5_LINK_NO_ISSUE_OBSERVED,
+		.ethtool = ETHTOOL_LINK_NO_ISSUE,
+	},
+	{
+		.pddr    = MLX5_LINK_PORT_CLOSED,
+		.ethtool = ETHTOOL_LINK_ADMIN_DOWN,
+	},
+	{
+		.pddr    = MLX5_LINK_AN_FAILURE,
+		.ethtool = ETHTOOL_LINK_AN_FAILED,
+	},
+	{
+		.pddr    = MLX5_LINK_TRAINING_FAILURE,
+		.ethtool = ETHTOOL_LINK_TRAINING_FAILED,
+	},
+	{
+		.pddr    = MLX5_LINK_REMOTE_FAULT_INDICATION,
+		.ethtool = ETHTOOL_LINK_RMT_FAULT,
+	},
+	{
+		.pddr    = MLX5_LINK_BAD_SIGNAL_INTEGRITY,
+		.ethtool = ETHTOOL_LINK_BAD_SIGNAL_INTEGRITY,
+	},
+	{
+		.pddr    = MLX5_LINK_CABLE_COMPLIANCE_CODE_MISMATCH,
+		.ethtool = ETHTOOL_LINK_CABLE_MISMATCH,
+	},
+	{
+		.pddr    = MLX5_LINK_INTERNAL_ERR,
+		.ethtool = ETHTOOL_LINK_INTERNAL_ERR,
+	},
+	{
+		.pddr    = MLX5_LINK_INFO_NOT_AVAIL,
+		.ethtool = ETHTOOL_LINK_REASON_UNKNOWN,
+	},
+	{
+		.pddr    = MLX5_LINK_CABLE_UNPLUGGED,
+		.ethtool = ETHTOOL_LINK_CABLE_UNPLUGGED,
+	},
+	{
+		.pddr    = MLX5_LINK_LONG_RANGE_FOR_NON_MLX_CABLE,
+		.ethtool = ETHTOOL_LINK_UNSUPP_MODULE,
+	},
+	{
+		.pddr    = MLX5_LINK_BUS_STUCK,
+		.ethtool = ETHTOOL_LINK_I2C_BUS_ERR,
+	},
+	{
+		.pddr    = MLX5_LINK_UNSUPP_EEPROM,
+		.ethtool = ETHTOOL_LINK_UNSUPP_EEPROM,
+	},
+	{
+		.pddr    = MLX5_LINK_MODULE_TEMP_SHUTDOWN,
+		.ethtool = ETHTOOL_LINK_OVERTEMP,
+	},
+	{
+		.pddr    = MLX5_LINK_POWER_BUDGET_EXCEEDED,
+		.ethtool = ETHTOOL_LINK_PWR_BUDGET_EXC,
+	},
+	{
+		.pddr    = MLX5_LINK_MNG_FORCED_DOWN,
+		.ethtool = ETHTOOL_LINK_MODULE_ADMIN_DOWN,
+	},
+};
+
+static u32 mlx5e_pddr2ethtool(u16 pddr)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(pddr2ethtool_table); i++) {
+		if (pddr2ethtool_table[i].pddr == pddr)
+			return pddr2ethtool_table[i].ethtool;
+	}
+
+	return ETHTOOL_LINK_VENDOR_SPECIFIC;
+}
+
 static unsigned long mlx5e_query_pfc_combined(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -1795,6 +1877,30 @@ static int mlx5e_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return err;
 }
 
+static int mlx5e_get_link_down_reason(struct net_device *netdev,
+				      struct ethtool_link_down_reason *ldr)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	u16 monitor_opcode;
+	int err;
+
+	if (!netif_running(netdev)) {
+		ldr->reason = ETHTOOL_LINK_NETDEV_CARRIER_DOWN;
+		return 0;
+	}
+
+	err = mlx5_query_pddr_troubleshooting_info(priv->mdev,
+						   &monitor_opcode, NULL);
+	if (err)
+		return err;
+
+	ldr->reason = mlx5e_pddr2ethtool(monitor_opcode);
+	if (ldr->reason == ETHTOOL_LINK_VENDOR_SPECIFIC)
+		ldr->vendor_reason = monitor_opcode;
+
+	return 0;
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -1828,4 +1934,5 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_priv_flags    = mlx5e_get_priv_flags,
 	.set_priv_flags    = mlx5e_set_priv_flags,
 	.self_test         = mlx5e_self_test,
+	.get_link_down_reason = mlx5e_get_link_down_reason,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index cbb6a0e..b4cbaa0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -147,6 +147,10 @@ int mlx5_query_pcam_reg(struct mlx5_core_dev *dev, u32 *pcam, u8 feature_group,
 int mlx5_query_mcam_reg(struct mlx5_core_dev *dev, u32 *mcap, u8 feature_group,
 			u8 access_reg_group);
 
+int mlx5_query_pddr_troubleshooting_info(struct mlx5_core_dev *mdev,
+					 u16 *monitor_opcode,
+					 u8 *status_message);
+
 void mlx5_lag_add(struct mlx5_core_dev *dev, struct net_device *netdev);
 void mlx5_lag_remove(struct mlx5_core_dev *dev);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 38e97b2..b9e053c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -803,6 +803,31 @@ static int mlx5_query_pddr(struct mlx5_core_dev *mdev,
 	return mlx5_core_access_reg(mdev, in, sizeof(in), out, outlen, MLX5_REG_PDDR, 0, 0);
 }
 
+int mlx5_query_pddr_troubleshooting_info(struct mlx5_core_dev *mdev,
+					 u16 *monitor_opcode,
+					 u8 *status_message)
+{
+	int outlen = MLX5_ST_SZ_BYTES(pddr_reg);
+	u32 out[MLX5_ST_SZ_DW(pddr_reg)] = {0};
+	int err;
+
+	err = mlx5_query_pddr(mdev, MLX5_PDDR_TROUBLESHOOTING_INFO_PAGE,
+			      out, outlen);
+	if (err)
+		return err;
+
+	if (monitor_opcode)
+		*monitor_opcode = MLX5_GET(pddr_reg, out,
+					   page_data.troubleshooting_info_page.status_opcode.monitor_opcodes);
+
+	if (status_message)
+		memcpy(status_message,
+		       MLX5_ADDR_OF(pddr_reg, out, page_data.troubleshooting_info_page.status_message),
+		       ETH_GSTRING_LEN);
+
+	return 0;
+}
+
 static int mlx5_query_ports_check(struct mlx5_core_dev *mdev, u32 *out,
 				  int outlen)
 {
-- 
2.7.4
