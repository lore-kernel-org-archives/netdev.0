From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 5/6] net/mlx5e: Add DCBX control interface
Date: Tue, 30 Aug 2016 14:29:54 +0300
Message-ID: <1472556595-9286-6-git-send-email-saeedm@mellanox.com>
References: <1472556595-9286-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56739 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758382AbcH3Lak (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 07:30:40 -0400
In-Reply-To: <1472556595-9286-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

1. Use setdcbx interface to set the DCBX mode to firmware or os.
   If setdcbx is called with mode value of zero, the DCBX mode
   is set to firmware.

2. Add private ethtool flag "qos_with_dcbx_by_fw". When this
   flag is "On", the DCBX is forced to firmware mode.

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 24 ++++++++++++++++++++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 25 ++++++++++++++++++++++
 3 files changed, 50 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 806f5e8..501b1e4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -158,10 +158,12 @@ struct mlx5e_umr_wqe {
 
 static const char mlx5e_priv_flags[][ETH_GSTRING_LEN] = {
 	"rx_cqe_moder",
+	"qos_with_dcbx_by_fw",
 };
 
 enum mlx5e_priv_flag {
 	MLX5E_PFLAG_RX_CQE_BASED_MODER = (1 << 0),
+	MLX5E_PFLAG_QOS_WITH_DCBX_BY_FW = (1 << 1),
 };
 
 #define MLX5E_SET_PRIV_FLAG(priv, pflag, enable)    \
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 5d1b402..6c739c1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -54,6 +54,9 @@ static inline bool mlx5e_dcbnl_is_allowed(struct mlx5e_priv *priv)
 	if (dcbx->mode == MLX5E_DCBX_PARAM_VER_OPER_HOST)
 		return true;
 
+	if (priv->pflags & MLX5E_PFLAG_QOS_WITH_DCBX_BY_FW)
+		return true;
+
 	if (mlx5e_dcbnl_set_dcbx_mode(priv, MLX5E_DCBX_PARAM_VER_OPER_HOST))
 		return false;
 
@@ -283,13 +286,32 @@ static int mlx5e_dcbnl_ieee_setpfc(struct net_device *dev,
 
 static u8 mlx5e_dcbnl_getdcbx(struct net_device *dev)
 {
-	return DCB_CAP_DCBX_HOST |
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5e_dcbx *dcbx = &priv->dcbx;
+	u8 mode = 0;
+
+	if (dcbx->mode == MLX5E_DCBX_PARAM_VER_OPER_HOST)
+		mode = DCB_CAP_DCBX_HOST;
+
+	return mode |
 	       DCB_CAP_DCBX_VER_IEEE |
 	       DCB_CAP_DCBX_VER_CEE;
 }
 
 static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 {
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5e_dcbx *dcbx = &priv->dcbx;
+
+	if ((!mode) && MLX5_CAP_GEN(priv->mdev, dcbx)) {
+		/* set dcbx to fw controlled */
+		if (dcbx->mode == MLX5E_DCBX_PARAM_VER_OPER_HOST)
+			if (!mlx5e_dcbnl_set_dcbx_mode(priv, MLX5E_DCBX_PARAM_VER_OPER_AUTO))
+				dcbx->mode = MLX5E_DCBX_PARAM_VER_OPER_AUTO;
+
+		return 0;
+	}
+
 	if (!mlx5e_dcbnl_is_allowed(netdev_priv(dev)))
 		return 1;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index d1cd156..9bc26cd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1460,6 +1460,25 @@ static int mlx5e_handle_pflag(struct net_device *netdev,
 	return 0;
 }
 
+#ifdef CONFIG_MLX5_CORE_EN_DCB
+static int qos_with_dcbx_by_fw_handler(struct net_device *netdev, bool enable)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	if (!MLX5_CAP_GEN(priv->mdev, dcbx))
+		return -EPERM;
+
+	if (!enable)
+		return 0;
+
+	/* Not allow to turn on the flag if the dcbx mode is host */
+	if (priv->dcbx.mode == MLX5E_DCBX_PARAM_VER_OPER_HOST)
+		return -EPERM;
+
+	return 0;
+}
+#endif
+
 static int mlx5e_set_priv_flags(struct net_device *netdev, u32 pflags)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
@@ -1471,6 +1490,12 @@ static int mlx5e_set_priv_flags(struct net_device *netdev, u32 pflags)
 				 MLX5E_PFLAG_RX_CQE_BASED_MODER,
 				 set_pflag_rx_cqe_based_moder);
 
+#ifdef CONFIG_MLX5_CORE_EN_DCB
+	err  = mlx5e_handle_pflag(netdev, pflags,
+				  MLX5E_PFLAG_QOS_WITH_DCBX_BY_FW,
+				  qos_with_dcbx_by_fw_handler);
+#endif
+
 	mutex_unlock(&priv->state_lock);
 	return err ? -EINVAL : 0;
 }
-- 
2.7.4
