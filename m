From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 06/10] net/mlx5e: Add DCBX control interface
Date: Sat, 26 Nov 2016 16:18:30 +0200
Message-ID: <1480169914-22347-7-git-send-email-saeedm@mellanox.com>
References: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41853 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751532AbcKZOTb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 09:19:31 -0500
In-Reply-To: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Use setdcbx interface to set the DCBX mode to firmware or os.
If setdcbx is called with mode value of zero, the DCBX mode
is set to firmware.

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 27 +++++++++++++++++++---
 1 file changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 2e94717..64c45e9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -288,13 +288,34 @@ static int mlx5e_dcbnl_ieee_setpfc(struct net_device *dev,
 
 static u8 mlx5e_dcbnl_getdcbx(struct net_device *dev)
 {
-	return DCB_CAP_DCBX_HOST |
-	       DCB_CAP_DCBX_VER_IEEE |
-	       DCB_CAP_DCBX_VER_CEE;
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5e_dcbx *dcbx = &priv->dcbx;
+	u8 mode = DCB_CAP_DCBX_VER_IEEE | DCB_CAP_DCBX_VER_CEE;
+
+	if (dcbx->mode == MLX5E_DCBX_PARAM_VER_OPER_HOST)
+		mode |= DCB_CAP_DCBX_HOST;
+
+	return mode;
 }
 
 static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 {
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5e_dcbx *dcbx = &priv->dcbx;
+
+	if ((!mode) && MLX5_CAP_GEN(priv->mdev, dcbx)) {
+		if (dcbx->mode == MLX5E_DCBX_PARAM_VER_OPER_AUTO)
+			return 0;
+
+		/* set dcbx to fw controlled */
+		if (!mlx5e_dcbnl_set_dcbx_mode(priv, MLX5E_DCBX_PARAM_VER_OPER_AUTO)) {
+			dcbx->mode = MLX5E_DCBX_PARAM_VER_OPER_AUTO;
+			return 0;
+		}
+
+		return 1;
+	}
+
 	if (mlx5e_dcbnl_switch_to_host_mode(netdev_priv(dev)))
 		return 1;
 
-- 
2.7.4
