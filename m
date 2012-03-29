From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V4 8/8] net/mlx4_en: Set max rate-limit for a TC
Date: Thu, 29 Mar 2012 17:03:38 +0200
Message-ID: <1333033418-1669-9-git-send-email-amirv@mellanox.com>
References: <1333033418-1669-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:43493 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759410Ab2C2PEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 11:04:02 -0400
In-Reply-To: <1333033418-1669-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is using the DCB netlink to set rate limit per ETS TC

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |   31 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    7 +++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 +-
 3 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 5bf0106..0f92b2e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -100,6 +100,7 @@ static int mlx4_en_config_port_scheduler(struct mlx4_en_priv *priv,
 	__u8 pg[IEEE_8021QAZ_MAX_TCS] = { 0 };
 
 	ets = ets ?: priv->mlx4_en_ieee_ets;
+	ratelimit = ratelimit ?: priv->maxrate->tc_maxrate;
 
 	/* higher TC means higher priority => lower pg */
 	for (i = IEEE_8021QAZ_MAX_TCS - 1; i >= 0; i--) {
@@ -200,9 +201,39 @@ static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 	return 0;
 }
 
+static int mlx4_en_dcbnl_ieee_getmaxrate(struct net_device *dev,
+				   struct ieee_maxrate *maxrate)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	if (!priv->maxrate)
+		return -EINVAL;
+
+	memcpy(maxrate, priv->maxrate, sizeof(maxrate));
+
+	return 0;
+}
+
+static int mlx4_en_dcbnl_ieee_setmaxrate(struct net_device *dev,
+		struct ieee_maxrate *maxrate)
+{
+	int err;
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	err = mlx4_en_config_port_scheduler(priv, NULL, maxrate->tc_maxrate);
+	if (err)
+		return err;
+
+	memcpy(priv->maxrate, maxrate, sizeof(priv->maxrate));
+
+	return 0;
+}
+
 const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops = {
 	.ieee_getets	= mlx4_en_dcbnl_ieee_getets,
 	.ieee_setets	= mlx4_en_dcbnl_ieee_setets,
+	.ieee_getmaxrate = mlx4_en_dcbnl_ieee_getmaxrate,
+	.ieee_setmaxrate = mlx4_en_dcbnl_ieee_setmaxrate,
 	.ieee_getpfc	= mlx4_en_dcbnl_ieee_getpfc,
 	.ieee_setpfc	= mlx4_en_dcbnl_ieee_setpfc,
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 44dbe1f..be7ffbf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -978,6 +978,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 
 #ifdef CONFIG_MLX4_EN_DCB
 	vfree(priv->mlx4_en_ieee_ets);
+	vfree(priv->maxrate);
 #endif
 
 	free_netdev(dev);
@@ -1103,6 +1104,12 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			err = -ENOMEM;
 			goto out;
 		}
+
+		priv->maxrate = vzalloc(sizeof(struct ieee_maxrate));
+		if (!priv->maxrate) {
+			err = -ENOMEM;
+			goto out;
+		}
 	}
 #endif
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index fa09792..d1f5ac2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -420,7 +420,6 @@ struct mlx4_en_frag_info {
 #define MLX4_EN_BW_MAX 100 /* Utilize 100% of the line */
 
 #define MLX4_EN_TC_ETS 7
-
 #endif
 
 struct mlx4_en_priv {
@@ -499,6 +498,7 @@ struct mlx4_en_priv {
 
 #ifdef CONFIG_MLX4_EN_DCB
 	struct ieee_ets *mlx4_en_ieee_ets;
+	struct ieee_maxrate *maxrate;
 #endif
 };
 
-- 
1.7.8.2
