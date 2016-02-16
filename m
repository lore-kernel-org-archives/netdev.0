From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 06/12] net/mlx5e: Implement DCBNL IEEE max rate
Date: Tue, 16 Feb 2016 22:09:55 +0200
Message-ID: <1455653401-9808-7-git-send-email-saeedm@mellanox.com>
References: <1455653401-9808-1-git-send-email-saeedm@mellanox.com>
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
Received: from [193.47.165.129] ([193.47.165.129]:59241 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752696AbcBPULJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:11:09 -0500
In-Reply-To: <1455653401-9808-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Add support for DCBNL IEEE get/set max rate.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |   73 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |   63 +++++++++++++++++
 include/linux/mlx5/device.h                        |    6 ++
 include/linux/mlx5/port.h                          |    6 ++
 4 files changed, 148 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 8b791e7..ddb5371 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -35,6 +35,9 @@
 
 #define MLX5E_MAX_PRIORITY 8
 
+#define MLX5E_100MB (100000)
+#define MLX5E_1GB   (1000000)
+
 static int mlx5e_dcbnl_ieee_getets(struct net_device *netdev,
 				   struct ieee_ets *ets)
 {
@@ -213,9 +216,79 @@ static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 	return 0;
 }
 
+static int mlx5e_dcbnl_ieee_getmaxrate(struct net_device *netdev,
+				       struct ieee_maxrate *maxrate)
+{
+	struct mlx5e_priv *priv    = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u8 max_bw_value[IEEE_8021QAZ_MAX_TCS];
+	u8 max_bw_unit[IEEE_8021QAZ_MAX_TCS];
+	int err;
+	int i;
+
+	err = mlx5_query_port_ets_rate_limit(mdev, max_bw_value, max_bw_unit);
+	if (err)
+		return err;
+
+	memset(maxrate->tc_maxrate, 0, sizeof(maxrate->tc_maxrate));
+
+	for (i = 0; i <= mlx5_max_tc(mdev); i++) {
+		switch (max_bw_unit[i]) {
+		case MLX5_100_MBPS_UNIT:
+			maxrate->tc_maxrate[i] = max_bw_value[i] * MLX5E_100MB;
+			break;
+		case MLX5_GBPS_UNIT:
+			maxrate->tc_maxrate[i] = max_bw_value[i] * MLX5E_1GB;
+			break;
+		case MLX5_BW_NO_LIMIT:
+			break;
+		default:
+			WARN(true, "non-supported BW unit");
+			break;
+		}
+	}
+
+	return 0;
+}
+
+static int mlx5e_dcbnl_ieee_setmaxrate(struct net_device *netdev,
+				       struct ieee_maxrate *maxrate)
+{
+	struct mlx5e_priv *priv    = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u8 max_bw_value[IEEE_8021QAZ_MAX_TCS];
+	u8 max_bw_unit[IEEE_8021QAZ_MAX_TCS];
+	__u64 upper_limit_mbps = roundup(255 * MLX5E_100MB, MLX5E_1GB);
+	int i;
+
+	memset(max_bw_value, 0, sizeof(max_bw_value));
+	memset(max_bw_unit, 0, sizeof(max_bw_unit));
+
+	for (i = 0; i <= mlx5_max_tc(mdev); i++) {
+		if (!maxrate->tc_maxrate[i]) {
+			max_bw_unit[i]  = MLX5_BW_NO_LIMIT;
+			continue;
+		}
+		if (maxrate->tc_maxrate[i] < upper_limit_mbps) {
+			max_bw_value[i] = div_u64(maxrate->tc_maxrate[i],
+						  MLX5E_100MB);
+			max_bw_value[i] = max_bw_value[i] ? max_bw_value[i] : 1;
+			max_bw_unit[i]  = MLX5_100_MBPS_UNIT;
+		} else {
+			max_bw_value[i] = div_u64(maxrate->tc_maxrate[i],
+						  MLX5E_1GB);
+			max_bw_unit[i]  = MLX5_GBPS_UNIT;
+		}
+	}
+
+	return mlx5_modify_port_ets_rate_limit(mdev, max_bw_value, max_bw_unit);
+}
+
 const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops = {
 	.ieee_getets	= mlx5e_dcbnl_ieee_getets,
 	.ieee_setets	= mlx5e_dcbnl_ieee_setets,
+	.ieee_getmaxrate = mlx5e_dcbnl_ieee_getmaxrate,
+	.ieee_setmaxrate = mlx5e_dcbnl_ieee_setmaxrate,
 	.ieee_getpfc	= mlx5e_dcbnl_ieee_getpfc,
 	.ieee_setpfc	= mlx5e_dcbnl_ieee_setpfc,
 	.getdcbx	= mlx5e_dcbnl_getdcbx,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 87e80db..cff1798 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -447,6 +447,17 @@ static int mlx5_set_port_qetcr_reg(struct mlx5_core_dev *mdev, u32 *in,
 				    MLX5_REG_QETCR, 0, 1);
 }
 
+static int mlx5_query_port_qetcr_reg(struct mlx5_core_dev *mdev, u32 *out,
+				     int outlen)
+{
+	u32 in[MLX5_ST_SZ_DW(qtct_reg)];
+
+	memset(in, 0, sizeof(in));
+
+	return mlx5_core_access_reg(mdev, in, sizeof(in), out, outlen,
+				    MLX5_REG_QETCR, 0, 0);
+}
+
 int mlx5_set_port_tc_group(struct mlx5_core_dev *mdev, u8 *tc_group)
 {
 	u32 in[MLX5_ST_SZ_DW(qetc_reg)];
@@ -478,3 +489,55 @@ int mlx5_set_port_tc_bw_alloc(struct mlx5_core_dev *mdev, u8 *tc_bw)
 	return mlx5_set_port_qetcr_reg(mdev, in, sizeof(in));
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_tc_bw_alloc);
+
+int mlx5_modify_port_ets_rate_limit(struct mlx5_core_dev *mdev,
+				    u8 *max_bw_value,
+				    u8 *max_bw_units)
+{
+	u32 in[MLX5_ST_SZ_DW(qetc_reg)];
+	void *ets_tcn_conf;
+	int i;
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(qetc_reg, in, port_number, 1);
+
+	for (i = 0; i <= mlx5_max_tc(mdev); i++) {
+		ets_tcn_conf = MLX5_ADDR_OF(qetc_reg, in, tc_configuration[i]);
+
+		MLX5_SET(ets_tcn_config_reg, ets_tcn_conf, r, 1);
+		MLX5_SET(ets_tcn_config_reg, ets_tcn_conf, max_bw_units,
+			 max_bw_units[i]);
+		MLX5_SET(ets_tcn_config_reg, ets_tcn_conf, max_bw_value,
+			 max_bw_value[i]);
+	}
+
+	return mlx5_set_port_qetcr_reg(mdev, in, sizeof(in));
+}
+EXPORT_SYMBOL_GPL(mlx5_modify_port_ets_rate_limit);
+
+int mlx5_query_port_ets_rate_limit(struct mlx5_core_dev *mdev,
+				   u8 *max_bw_value,
+				   u8 *max_bw_units)
+{
+	u32 out[MLX5_ST_SZ_DW(qetc_reg)];
+	void *ets_tcn_conf;
+	int err;
+	int i;
+
+	err = mlx5_query_port_qetcr_reg(mdev, out, sizeof(out));
+	if (err)
+		return err;
+
+	for (i = 0; i <= mlx5_max_tc(mdev); i++) {
+		ets_tcn_conf = MLX5_ADDR_OF(qetc_reg, out, tc_configuration[i]);
+
+		max_bw_value[i] = MLX5_GET(ets_tcn_config_reg, ets_tcn_conf,
+					   max_bw_value);
+		max_bw_units[i] = MLX5_GET(ets_tcn_config_reg, ets_tcn_conf,
+					   max_bw_units);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_ets_rate_limit);
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 987764a..bfc1ab0 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -351,6 +351,12 @@ enum {
 };
 
 enum {
+	MLX5_BW_NO_LIMIT   = 0,
+	MLX5_100_MBPS_UNIT = 3,
+	MLX5_GBPS_UNIT	   = 4,
+};
+
+enum {
 	MLX5_MAX_PAGE_SHIFT		= 31
 };
 
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index e18fc95..66dbd1a 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -75,5 +75,11 @@ int mlx5_max_tc(struct mlx5_core_dev *mdev);
 int mlx5_set_port_prio_tc(struct mlx5_core_dev *mdev, u8 *prio_tc);
 int mlx5_set_port_tc_group(struct mlx5_core_dev *mdev, u8 *tc_group);
 int mlx5_set_port_tc_bw_alloc(struct mlx5_core_dev *mdev, u8 *tc_bw);
+int mlx5_modify_port_ets_rate_limit(struct mlx5_core_dev *mdev,
+				    u8 *max_bw_value,
+				    u8 *max_bw_unit);
+int mlx5_query_port_ets_rate_limit(struct mlx5_core_dev *mdev,
+				   u8 *max_bw_value,
+				   u8 *max_bw_unit);
 
 #endif /* __MLX5_PORT_H__ */
-- 
1.7.1
