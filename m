From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 05/12] net/mlx5e: Support DCBNL IEEE PFC
Date: Mon, 22 Feb 2016 18:17:27 +0200
Message-ID: <1456157854-12750-6-git-send-email-saeedm@mellanox.com>
References: <1456157854-12750-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:42239 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752513AbcBVQSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 11:18:44 -0500
In-Reply-To: <1456157854-12750-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Implement the set/get DCBNL IEEE PFC callbacks.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |   39 ++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 4f097da..39d8069 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -166,6 +166,43 @@ static int mlx5e_dcbnl_ieee_setets(struct net_device *netdev,
 	return 0;
 }
 
+static int mlx5e_dcbnl_ieee_getpfc(struct net_device *dev,
+				   struct ieee_pfc *pfc)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+
+	pfc->pfc_cap = mlx5_max_tc(mdev) + 1;
+
+	return mlx5_query_port_pfc(mdev, &pfc->pfc_en, NULL);
+}
+
+static int mlx5e_dcbnl_ieee_setpfc(struct net_device *dev,
+				   struct ieee_pfc *pfc)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	enum mlx5_port_status ps;
+	u8 curr_pfc_en;
+	int ret;
+
+	mlx5_query_port_pfc(mdev, &curr_pfc_en, NULL);
+
+	if (pfc->pfc_en == curr_pfc_en)
+		return 0;
+
+	mlx5_query_port_admin_status(mdev, &ps);
+	if (ps == MLX5_PORT_UP)
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN);
+
+	ret = mlx5_set_port_pfc(mdev, pfc->pfc_en, pfc->pfc_en);
+
+	if (ps == MLX5_PORT_UP)
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_UP);
+
+	return ret;
+}
+
 static u8 mlx5e_dcbnl_getdcbx(struct net_device *dev)
 {
 	return DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
@@ -185,6 +222,8 @@ static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops = {
 	.ieee_getets	= mlx5e_dcbnl_ieee_getets,
 	.ieee_setets	= mlx5e_dcbnl_ieee_setets,
+	.ieee_getpfc	= mlx5e_dcbnl_ieee_getpfc,
+	.ieee_setpfc	= mlx5e_dcbnl_ieee_setpfc,
 	.getdcbx	= mlx5e_dcbnl_getdcbx,
 	.setdcbx	= mlx5e_dcbnl_setdcbx,
 };
-- 
1.7.1
