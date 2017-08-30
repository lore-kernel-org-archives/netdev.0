From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 02/11] net/mlx5e: Fix DCB_CAP_ATTR_DCBX capability for DCBNL getcap.
Date: Thu, 31 Aug 2017 01:21:01 +0300
Message-ID: <20170830222110.15737-3-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53226 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751127AbdH3WVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:32 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Current code doesn't report DCB_CAP_DCBX_HOST capability when query
through getcap. User space lldptool expects capability to have HOST mode
set when it wants to configure DCBX CEE mode. In absence of HOST mode
capability, lldptool fails to switch to CEE mode.

This fix returns DCB_CAP_DCBX_HOST capability when port's DCBX
controlled mode is under software control.

Fixes: 3a6a931dfb8e ("net/mlx5e: Support DCBX CEE API")
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Reviewed-by: Parav Pandit <parav@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 21 ++++++++++++---------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 0039b4725405..2f26fb34d741 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -263,6 +263,7 @@ struct mlx5e_dcbx {
 
 	/* The only setting that cannot be read from FW */
 	u8                         tc_tsa[IEEE_8021QAZ_MAX_TCS];
+	u8                         cap;
 };
 #endif
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 810b51029c7f..c1d384fca4dc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -288,13 +288,8 @@ static int mlx5e_dcbnl_ieee_setpfc(struct net_device *dev,
 static u8 mlx5e_dcbnl_getdcbx(struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	struct mlx5e_dcbx *dcbx = &priv->dcbx;
-	u8 mode = DCB_CAP_DCBX_VER_IEEE | DCB_CAP_DCBX_VER_CEE;
-
-	if (dcbx->mode == MLX5E_DCBX_PARAM_VER_OPER_HOST)
-		mode |= DCB_CAP_DCBX_HOST;
 
-	return mode;
+	return priv->dcbx.cap;
 }
 
 static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
@@ -312,6 +307,7 @@ static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 		/* set dcbx to fw controlled */
 		if (!mlx5e_dcbnl_set_dcbx_mode(priv, MLX5E_DCBX_PARAM_VER_OPER_AUTO)) {
 			dcbx->mode = MLX5E_DCBX_PARAM_VER_OPER_AUTO;
+			dcbx->cap &= ~DCB_CAP_DCBX_HOST;
 			return 0;
 		}
 
@@ -324,6 +320,8 @@ static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 	if (mlx5e_dcbnl_switch_to_host_mode(netdev_priv(dev)))
 		return 1;
 
+	dcbx->cap = mode;
+
 	return 0;
 }
 
@@ -628,9 +626,9 @@ static u8 mlx5e_dcbnl_getcap(struct net_device *netdev,
 		*cap = false;
 		break;
 	case DCB_CAP_ATTR_DCBX:
-		*cap = (DCB_CAP_DCBX_LLD_MANAGED |
-			DCB_CAP_DCBX_VER_CEE |
-			DCB_CAP_DCBX_STATIC);
+		*cap = priv->dcbx.cap |
+		       DCB_CAP_DCBX_VER_CEE |
+		       DCB_CAP_DCBX_VER_IEEE;
 		break;
 	default:
 		*cap = 0;
@@ -760,5 +758,10 @@ void mlx5e_dcbnl_initialize(struct mlx5e_priv *priv)
 	if (MLX5_CAP_GEN(priv->mdev, dcbx))
 		mlx5e_dcbnl_query_dcbx_mode(priv, &dcbx->mode);
 
+	priv->dcbx.cap = DCB_CAP_DCBX_VER_CEE |
+			 DCB_CAP_DCBX_VER_IEEE;
+	if (priv->dcbx.mode == MLX5E_DCBX_PARAM_VER_OPER_HOST)
+		priv->dcbx.cap |= DCB_CAP_DCBX_HOST;
+
 	mlx5e_ets_init(priv);
 }
-- 
2.13.0
