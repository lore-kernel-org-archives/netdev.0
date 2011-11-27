From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH V2 5/7] net/mlx4_en: fix WOL handlers were always looking
 at port2 capability bit
Date: Sun, 27 Nov 2011 07:55:15 +0200
Message-ID: <4ED1D0C3.4030004@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:35714 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753584Ab1K0ITu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 03:19:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oren Duer <oren@mellanox.co.il>

There are 2 capability bits for WOL, one for each port.
WOL handlers were looking only on the second bit, regardless of the port.

Signed-off-by: Oren Duer <oren@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   20 ++++++++++++++++++--
 include/linux/mlx4/device.h                     |    3 ++-
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index ee637a2..7dbc6a2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -106,8 +106,17 @@ static void mlx4_en_get_wol(struct net_device *netdev,
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
 	int err = 0;
 	u64 config = 0;
+	u64 mask;
 
-	if (!(priv->mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_WOL)) {
+	if ((priv->port < 1) || (priv->port > 2)) {
+		en_err(priv, "Failed to get WoL information\n");
+		return;
+	}
+
+	mask = (priv->port == 1) ? MLX4_DEV_CAP_FLAG_WOL_PORT1 :
+		MLX4_DEV_CAP_FLAG_WOL_PORT2;
+
+	if (!(priv->mdev->dev->caps.flags & mask)) {
 		wol->supported = 0;
 		wol->wolopts = 0;
 		return;
@@ -136,8 +145,15 @@ static int mlx4_en_set_wol(struct net_device *netdev,
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
 	u64 config = 0;
 	int err = 0;
+	u64 mask;
+
+	if ((priv->port < 1) || (priv->port > 2))
+		return -EOPNOTSUPP;
+
+	mask = (priv->port == 1) ? MLX4_DEV_CAP_FLAG_WOL_PORT1 :
+		MLX4_DEV_CAP_FLAG_WOL_PORT2;
 
-	if (!(priv->mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_WOL))
+	if (!(priv->mdev->dev->caps.flags & mask))
 		return -EOPNOTSUPP;
 
 	if (wol->supported & ~WAKE_MAGIC)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 84b0b18..ca2c397 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -77,7 +77,8 @@ enum {
 	MLX4_DEV_CAP_FLAG_IBOE		= 1LL << 30,
 	MLX4_DEV_CAP_FLAG_UC_LOOPBACK	= 1LL << 32,
 	MLX4_DEV_CAP_FLAG_FCS_KEEP	= 1LL << 34,
-	MLX4_DEV_CAP_FLAG_WOL		= 1LL << 38,
+	MLX4_DEV_CAP_FLAG_WOL_PORT1	= 1LL << 37,
+	MLX4_DEV_CAP_FLAG_WOL_PORT2	= 1LL << 38,
 	MLX4_DEV_CAP_FLAG_UDP_RSS	= 1LL << 40,
 	MLX4_DEV_CAP_FLAG_VEP_UC_STEER	= 1LL << 41,
 	MLX4_DEV_CAP_FLAG_VEP_MC_STEER	= 1LL << 42,
-- 
1.7.7
