From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V5 8/8] net/mlx4_en: Set max rate-limit for a TC
Date: Tue,  3 Apr 2012 14:10:07 +0300
Message-ID: <1333451407-5293-9-git-send-email-amirv@mellanox.com>
References: <1333451407-5293-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:49477 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752293Ab2DCLKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 07:10:24 -0400
In-Reply-To: <1333451407-5293-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is using the DCB netlink to set rate limit per ETS TC
Values are accepted in Kbps and rounded up to the nearest multiply of 100Mbps.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |   45 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    1 +
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 6892320..0cc6c96 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -100,6 +100,7 @@ static int mlx4_en_config_port_scheduler(struct mlx4_en_priv *priv,
 	__u8 pg[IEEE_8021QAZ_MAX_TCS] = { 0 };
 
 	ets = ets ?: &priv->ets;
+	ratelimit = ratelimit ?: priv->maxrate;
 
 	/* higher TC means higher priority => lower pg */
 	for (i = IEEE_8021QAZ_MAX_TCS - 1; i >= 0; i--) {
@@ -198,9 +199,53 @@ static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 	return 0;
 }
 
+#define MLX4_RATELIMIT_UNITS_IN_KB 100000 /* rate-limit HW unit in Kbps */
+static int mlx4_en_dcbnl_ieee_getmaxrate(struct net_device *dev,
+				   struct ieee_maxrate *maxrate)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int i;
+
+	if (!priv->maxrate)
+		return -EINVAL;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		maxrate->tc_maxrate[i] =
+			priv->maxrate[i] * MLX4_RATELIMIT_UNITS_IN_KB;
+
+	return 0;
+}
+
+static int mlx4_en_dcbnl_ieee_setmaxrate(struct net_device *dev,
+		struct ieee_maxrate *maxrate)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	u16 tmp[IEEE_8021QAZ_MAX_TCS];
+	int i, err;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		/* Convert from Kbps into HW units, rounding result up.
+		 * Setting to 0, means unlimited BW.
+		 */
+		tmp[i] =
+			(maxrate->tc_maxrate[i] + MLX4_RATELIMIT_UNITS_IN_KB -
+			 1) / MLX4_RATELIMIT_UNITS_IN_KB;
+	}
+
+	err = mlx4_en_config_port_scheduler(priv, NULL, tmp);
+	if (err)
+		return err;
+
+	memcpy(priv->maxrate, tmp, sizeof(*priv->maxrate));
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
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 97d4f35..3879c5e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -499,6 +499,7 @@ struct mlx4_en_priv {
 
 #ifdef CONFIG_MLX4_EN_DCB
 	struct ieee_ets ets;
+	u16 maxrate[IEEE_8021QAZ_MAX_TCS];
 #endif
 };
 
-- 
1.7.8.2
