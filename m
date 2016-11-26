From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 05/10] net/mlx5e: ConnectX-4 firmware support for DCBX
Date: Sat, 26 Nov 2016 16:18:29 +0200
Message-ID: <1480169914-22347-6-git-send-email-saeedm@mellanox.com>
References: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41840 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751660AbcKZOTb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 09:19:31 -0500
In-Reply-To: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

This patch sets up the infrastructure to support the new
DCBX firmware.

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 92 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 26 +-----
 3 files changed, 95 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 60aa13b..6c954cd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -234,6 +234,7 @@ enum {
 };
 
 struct mlx5e_dcbx {
+	enum mlx5_dcbx_oper_mode   mode;
 	struct mlx5e_cee_config    cee_cfg; /* pending configuration */
 
 	/* The only setting that cannot be read from FW */
@@ -843,6 +844,7 @@ extern const struct ethtool_ops mlx5e_ethtool_ops;
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 extern const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops;
 int mlx5e_dcbnl_ieee_setets_core(struct mlx5e_priv *priv, struct ieee_ets *ets);
+void mlx5e_dcbnl_initialize(struct mlx5e_priv *priv);
 #endif
 
 #ifndef CONFIG_RFS_ACCEL
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 8f6b5a7..2e94717 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -41,6 +41,43 @@
 #define MLX5E_CEE_STATE_UP    1
 #define MLX5E_CEE_STATE_DOWN  0
 
+/* If dcbx mode is non-host set the dcbx mode to host.
+ */
+static int mlx5e_dcbnl_set_dcbx_mode(struct mlx5e_priv *priv,
+				     enum mlx5_dcbx_oper_mode mode)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u32 param[MLX5_ST_SZ_DW(dcbx_param)];
+	int err;
+
+	err = mlx5_query_port_dcbx_param(mdev, param);
+	if (err)
+		return err;
+
+	MLX5_SET(dcbx_param, param, version_admin, mode);
+	if (mode != MLX5E_DCBX_PARAM_VER_OPER_HOST)
+		MLX5_SET(dcbx_param, param, willing_admin, 1);
+
+	return mlx5_set_port_dcbx_param(mdev, param);
+}
+
+static int mlx5e_dcbnl_switch_to_host_mode(struct mlx5e_priv *priv)
+{
+	struct mlx5e_dcbx *dcbx = &priv->dcbx;
+
+	if (!MLX5_CAP_GEN(priv->mdev, dcbx))
+		return 0;
+
+	if (dcbx->mode == MLX5E_DCBX_PARAM_VER_OPER_HOST)
+		return 0;
+
+	if (mlx5e_dcbnl_set_dcbx_mode(priv, MLX5E_DCBX_PARAM_VER_OPER_HOST))
+		return 1;
+
+	dcbx->mode = MLX5E_DCBX_PARAM_VER_OPER_HOST;
+	return 0;
+}
+
 static int mlx5e_dcbnl_ieee_getets(struct net_device *netdev,
 				   struct ieee_ets *ets)
 {
@@ -199,6 +236,9 @@ static int mlx5e_dcbnl_ieee_setets(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	int err;
 
+	if (!MLX5_CAP_GEN(priv->mdev, ets))
+		return -ENOTSUPP;
+
 	err = mlx5e_dbcnl_validate_ets(netdev, ets);
 	if (err)
 		return err;
@@ -255,6 +295,9 @@ static u8 mlx5e_dcbnl_getdcbx(struct net_device *dev)
 
 static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 {
+	if (mlx5e_dcbnl_switch_to_host_mode(netdev_priv(dev)))
+		return 1;
+
 	if ((mode & DCB_CAP_DCBX_LLD_MANAGED) ||
 	    !(mode & DCB_CAP_DCBX_VER_CEE) ||
 	    !(mode & DCB_CAP_DCBX_VER_IEEE) ||
@@ -634,3 +677,52 @@ const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops = {
 	.getpfcstate    = mlx5e_dcbnl_getpfcstate,
 	.setpfcstate    = mlx5e_dcbnl_setpfcstate,
 };
+
+static void mlx5e_dcbnl_query_dcbx_mode(struct mlx5e_priv *priv,
+					enum mlx5_dcbx_oper_mode *mode)
+{
+	u32 out[MLX5_ST_SZ_DW(dcbx_param)];
+
+	*mode = MLX5E_DCBX_PARAM_VER_OPER_HOST;
+
+	if (!mlx5_query_port_dcbx_param(priv->mdev, out))
+		*mode = MLX5_GET(dcbx_param, out, version_oper);
+
+	/* From driver's point of view, we only care if the mode
+	 * is host (HOST) or non-host (AUTO)
+	 */
+	if (*mode != MLX5E_DCBX_PARAM_VER_OPER_HOST)
+		*mode = MLX5E_DCBX_PARAM_VER_OPER_AUTO;
+}
+
+static void mlx5e_ets_init(struct mlx5e_priv *priv)
+{
+	int i;
+	struct ieee_ets ets;
+
+	memset(&ets, 0, sizeof(ets));
+	ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
+	for (i = 0; i < ets.ets_cap; i++) {
+		ets.tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
+		ets.tc_tsa[i] = IEEE_8021QAZ_TSA_VENDOR;
+		ets.prio_tc[i] = i;
+	}
+
+	memcpy(priv->dcbx.tc_tsa, ets.tc_tsa, sizeof(ets.tc_tsa));
+
+	/* tclass[prio=0]=1, tclass[prio=1]=0, tclass[prio=i]=i (for i>1) */
+	ets.prio_tc[0] = 1;
+	ets.prio_tc[1] = 0;
+
+	mlx5e_dcbnl_ieee_setets_core(priv, &ets);
+}
+
+void mlx5e_dcbnl_initialize(struct mlx5e_priv *priv)
+{
+	struct mlx5e_dcbx *dcbx = &priv->dcbx;
+
+	if (MLX5_CAP_GEN(priv->mdev, dcbx))
+		mlx5e_dcbnl_query_dcbx_mode(priv, &dcbx->mode);
+
+	mlx5e_ets_init(priv);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9743c4c..f5b93c2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3325,30 +3325,6 @@ u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev)
 	       2 /*sizeof(mlx5e_tx_wqe.inline_hdr_start)*/;
 }
 
-#ifdef CONFIG_MLX5_CORE_EN_DCB
-static void mlx5e_ets_init(struct mlx5e_priv *priv)
-{
-	int i;
-	struct ieee_ets ets;
-
-	memset(&ets, 0, sizeof(ets));
-	ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
-	for (i = 0; i < ets.ets_cap; i++) {
-		ets.tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
-		ets.tc_tsa[i] = IEEE_8021QAZ_TSA_VENDOR;
-		ets.prio_tc[i] = i;
-	}
-
-	memcpy(priv->dcbx.tc_tsa, ets.tc_tsa, sizeof(ets.tc_tsa));
-
-	/* tclass[prio=0]=1, tclass[prio=1]=0, tclass[prio=i]=i (for i>1) */
-	ets.prio_tc[0] = 1;
-	ets.prio_tc[1] = 0;
-
-	mlx5e_dcbnl_ieee_setets_core(priv, &ets);
-}
-#endif
-
 void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 				   u32 *indirection_rqt, int len,
 				   int num_channels)
@@ -3791,7 +3767,7 @@ static int mlx5e_init_nic_tx(struct mlx5e_priv *priv)
 	}
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
-	mlx5e_ets_init(priv);
+	mlx5e_dcbnl_initialize(priv);
 #endif
 	return 0;
 }
-- 
2.7.4
