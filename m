From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx4_en: Enable open-lldp DCB support
Date: Thu,  4 Apr 2013 17:26:14 +0300
Message-ID: <1365085574-12057-4-git-send-email-ogerlitz@mellanox.com>
References: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Sagi Grimberg <sagig@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:36277 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761666Ab3DDO03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:26:29 -0400
In-Reply-To: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sagi Grimberg <sagig@mellanox.com>

The lldpad daemon queries the driver caps via the getcaps and getstate
routines. Added the prpoer dbcnl_ops entries to support that.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |   37 +++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    4 ++-
 3 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index b7dc59f..f9f9164 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -36,6 +36,31 @@
 
 #include "mlx4_en.h"
 
+static u8 mlx4_en_dcbnl_getcap(struct net_device *dev, int capid, u8 *cap)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	switch (capid) {
+	case DCB_CAP_ATTR_PFC:
+		*cap = true;
+		break;
+	case DCB_CAP_ATTR_UP2TC:
+		if (priv->mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_SET_ETH_SCHED)
+			*cap = true;
+		else
+			*cap = false;
+		break;
+	case DCB_CAP_ATTR_DCBX:
+		*cap = priv->dcbx_cap;
+		break;
+	default:
+		*cap = false;
+		break;
+	}
+
+	return 0;
+}
+
 static int mlx4_en_dcbnl_ieee_getets(struct net_device *dev,
 				   struct ieee_ets *ets)
 {
@@ -217,6 +242,13 @@ static int mlx4_en_dcbnl_ieee_getmaxrate(struct net_device *dev,
 	return 0;
 }
 
+static u8 mlx4_en_dcbnl_get_state(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	return !!(priv->flags & MLX4_EN_FLAG_DCB_ENABLED);
+}
+
 static int mlx4_en_dcbnl_ieee_setmaxrate(struct net_device *dev,
 		struct ieee_maxrate *maxrate)
 {
@@ -243,18 +275,21 @@ static int mlx4_en_dcbnl_ieee_setmaxrate(struct net_device *dev,
 }
 
 const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops = {
+	.getstate       = mlx4_en_dcbnl_get_state,
 	.ieee_getets	= mlx4_en_dcbnl_ieee_getets,
 	.ieee_setets	= mlx4_en_dcbnl_ieee_setets,
 	.ieee_getmaxrate = mlx4_en_dcbnl_ieee_getmaxrate,
 	.ieee_setmaxrate = mlx4_en_dcbnl_ieee_setmaxrate,
 	.ieee_getpfc	= mlx4_en_dcbnl_ieee_getpfc,
 	.ieee_setpfc	= mlx4_en_dcbnl_ieee_setpfc,
-
+	.getcap		= mlx4_en_dcbnl_getcap,
 	.getdcbx	= mlx4_en_dcbnl_getdcbx,
 	.setdcbx	= mlx4_en_dcbnl_setdcbx,
 };
 
 const struct dcbnl_rtnl_ops mlx4_en_dcbnl_pfc_ops = {
+	.getstate       = mlx4_en_dcbnl_get_state,
 	.ieee_getpfc	= mlx4_en_dcbnl_ieee_getpfc,
 	.ieee_setpfc	= mlx4_en_dcbnl_ieee_setpfc,
+	.getcap		= mlx4_en_dcbnl_getcap,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 62795b5..a390de0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2013,6 +2013,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
 	INIT_DELAYED_WORK(&priv->stats_task, mlx4_en_do_get_stats);
 #ifdef CONFIG_MLX4_EN_DCB
+	priv->dcbx_cap = DCB_CAP_DCBX_HOST;
+	priv->flags |= MLX4_EN_FLAG_DCB_ENABLED;
 	if (!mlx4_is_slave(priv->mdev->dev)) {
 		if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_SET_ETH_SCHED) {
 			dev->dcbnl_ops = &mlx4_en_dcbnl_ops;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index d4cb5d3..71960b1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -440,7 +440,8 @@ enum {
 	MLX4_EN_FLAG_ENABLE_HW_LOOPBACK	= (1 << 2),
 	/* whether we need to drop packets that hardware loopback-ed */
 	MLX4_EN_FLAG_RX_FILTER_NEEDED	= (1 << 3),
-	MLX4_EN_FLAG_FORCE_PROMISC	= (1 << 4)
+	MLX4_EN_FLAG_FORCE_PROMISC	= (1 << 4),
+	MLX4_EN_FLAG_DCB_ENABLED	= (1 << 5)
 };
 
 #define MLX4_EN_MAC_HASH_SIZE (1 << BITS_PER_BYTE)
@@ -529,6 +530,7 @@ struct mlx4_en_priv {
 #ifdef CONFIG_MLX4_EN_DCB
 	struct ieee_ets ets;
 	u16 maxrate[IEEE_8021QAZ_MAX_TCS];
+	u8 dcbx_cap;
 #endif
 #ifdef CONFIG_RFS_ACCEL
 	spinlock_t filters_lock;
-- 
1.7.1
