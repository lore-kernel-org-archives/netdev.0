From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 03/12] net/mlx5: Introduce physical port TC/prio access functions
Date: Mon, 22 Feb 2016 18:17:25 +0200
Message-ID: <1456157854-12750-4-git-send-email-saeedm@mellanox.com>
References: <1456157854-12750-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:42185 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752370AbcBVQS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 11:18:26 -0500
In-Reply-To: <1456157854-12750-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add access functions to set and query a physical port TC groups
and prio parameters.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/port.c |   76 ++++++++++++++++++++++++
 include/linux/mlx5/driver.h                    |    2 +
 include/linux/mlx5/mlx5_ifc.h                  |   49 +++++++++++++++-
 include/linux/mlx5/port.h                      |    6 ++
 4 files changed, 132 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index dae7050..569100d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -405,3 +405,79 @@ int mlx5_query_port_pfc(struct mlx5_core_dev *dev, u8 *pfc_en_tx, u8 *pfc_en_rx)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_pfc);
+
+int mlx5_max_tc(struct mlx5_core_dev *mdev)
+{
+	u8 num_tc = MLX5_CAP_GEN(mdev, max_tc) ? : 8;
+
+	return num_tc - 1;
+}
+
+int mlx5_set_port_prio_tc(struct mlx5_core_dev *mdev, u8 *prio_tc)
+{
+	u32 in[MLX5_ST_SZ_DW(qtct_reg)];
+	u32 out[MLX5_ST_SZ_DW(qtct_reg)];
+	int err;
+	int i;
+
+	memset(in, 0, sizeof(in));
+	for (i = 0; i < 8; i++) {
+		if (prio_tc[i] > mlx5_max_tc(mdev))
+			return -EINVAL;
+
+		MLX5_SET(qtct_reg, in, prio, i);
+		MLX5_SET(qtct_reg, in, tclass, prio_tc[i]);
+
+		err = mlx5_core_access_reg(mdev, in, sizeof(in), out,
+					   sizeof(out), MLX5_REG_QTCT, 0, 1);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx5_set_port_prio_tc);
+
+static int mlx5_set_port_qetcr_reg(struct mlx5_core_dev *mdev, u32 *in,
+				   int inlen)
+{
+	u32 out[MLX5_ST_SZ_DW(qtct_reg)];
+
+	if (!MLX5_CAP_GEN(mdev, ets))
+		return -ENOTSUPP;
+
+	return mlx5_core_access_reg(mdev, in, inlen, out, sizeof(out),
+				    MLX5_REG_QETCR, 0, 1);
+}
+
+int mlx5_set_port_tc_group(struct mlx5_core_dev *mdev, u8 *tc_group)
+{
+	u32 in[MLX5_ST_SZ_DW(qetc_reg)];
+	int i;
+
+	memset(in, 0, sizeof(in));
+
+	for (i = 0; i <= mlx5_max_tc(mdev); i++) {
+		MLX5_SET(qetc_reg, in, tc_configuration[i].g, 1);
+		MLX5_SET(qetc_reg, in, tc_configuration[i].group, tc_group[i]);
+	}
+
+	return mlx5_set_port_qetcr_reg(mdev, in, sizeof(in));
+}
+EXPORT_SYMBOL_GPL(mlx5_set_port_tc_group);
+
+int mlx5_set_port_tc_bw_alloc(struct mlx5_core_dev *mdev, u8 *tc_bw)
+{
+	u32 in[MLX5_ST_SZ_DW(qetc_reg)];
+	int i;
+
+	memset(in, 0, sizeof(in));
+
+	for (i = 0; i <= mlx5_max_tc(mdev); i++) {
+		MLX5_SET(qetc_reg, in, tc_configuration[i].b, 1);
+		MLX5_SET(qetc_reg, in, tc_configuration[i].bw_allocation, tc_bw[i]);
+	}
+
+	return mlx5_set_port_qetcr_reg(mdev, in, sizeof(in));
+}
+EXPORT_SYMBOL_GPL(mlx5_set_port_tc_bw_alloc);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 02adc67..a815da9 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -99,6 +99,8 @@ enum {
 };
 
 enum {
+	MLX5_REG_QETCR		 = 0x4005,
+	MLX5_REG_QTCT		 = 0x400a,
 	MLX5_REG_PCAP		 = 0x5001,
 	MLX5_REG_PMTU		 = 0x5003,
 	MLX5_REG_PTYS		 = 0x5004,
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index fcc4373..ecbdbbf 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -729,7 +729,9 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 
 	u8         reserved_at_1bf[0x3];
 	u8         log_max_msg[0x5];
-	u8         reserved_at_1c7[0x18];
+	u8         reserved_at_1c7[0x4];
+	u8         max_tc[0x4];
+	u8         reserved_at_1cf[0x10];
 
 	u8         stat_rate_support[0x10];
 	u8         reserved_at_1ef[0xc];
@@ -7061,4 +7063,49 @@ struct mlx5_ifc_modify_flow_table_in_bits {
 	u8         reserved_at_100[0x100];
 };
 
+struct mlx5_ifc_ets_tcn_config_reg_bits {
+	u8         g[0x1];
+	u8         b[0x1];
+	u8         r[0x1];
+	u8         reserved_at_3[0x9];
+	u8         group[0x4];
+	u8         reserved_at_10[0x9];
+	u8         bw_allocation[0x7];
+
+	u8         reserved_at_20[0xc];
+	u8         max_bw_units[0x4];
+	u8         reserved_at_30[0x8];
+	u8         max_bw_value[0x8];
+};
+
+struct mlx5_ifc_ets_global_config_reg_bits {
+	u8         reserved_at_0[0x2];
+	u8         r[0x1];
+	u8         reserved_at_3[0x1d];
+
+	u8         reserved_at_20[0xc];
+	u8         max_bw_units[0x4];
+	u8         reserved_at_30[0x8];
+	u8         max_bw_value[0x8];
+};
+
+struct mlx5_ifc_qetc_reg_bits {
+	u8                                         reserved_at_0[0x8];
+	u8                                         port_number[0x8];
+	u8                                         reserved_at_10[0x30];
+
+	struct mlx5_ifc_ets_tcn_config_reg_bits    tc_configuration[0x8];
+	struct mlx5_ifc_ets_global_config_reg_bits global_configuration;
+};
+
+struct mlx5_ifc_qtct_reg_bits {
+	u8         reserved_at_0[0x8];
+	u8         port_number[0x8];
+	u8         reserved_at_10[0xd];
+	u8         prio[0x3];
+
+	u8         reserved_at_20[0x1d];
+	u8         tclass[0x3];
+};
+
 #endif /* MLX5_IFC_H */
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index 4b3644c..0c67e69 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -70,4 +70,10 @@ int mlx5_set_port_pfc(struct mlx5_core_dev *dev, u8 pfc_en_tx, u8 pfc_en_rx);
 int mlx5_query_port_pfc(struct mlx5_core_dev *dev, u8 *pfc_en_tx,
 			u8 *pfc_en_rx);
 
+int mlx5_max_tc(struct mlx5_core_dev *mdev);
+
+int mlx5_set_port_prio_tc(struct mlx5_core_dev *mdev, u8 *prio_tc);
+int mlx5_set_port_tc_group(struct mlx5_core_dev *mdev, u8 *tc_group);
+int mlx5_set_port_tc_bw_alloc(struct mlx5_core_dev *mdev, u8 *tc_bw);
+
 #endif /* __MLX5_PORT_H__ */
-- 
1.7.1
