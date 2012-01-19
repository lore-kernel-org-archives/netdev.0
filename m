From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net V1 1/6] mlx4_en: clear all eth statistics when port goes
 up
Date: Thu, 19 Jan 2012 21:42:37 +0200
Message-ID: <4F18722D.2010402@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:40322 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932810Ab2ASTmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 14:42:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

Bug fix: Not all stats fields were cleared.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petriln <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   36 ++++++++++++++++--------
 1 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 72fa807..be3f415 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -807,37 +807,49 @@ static void mlx4_en_restart(struct work_struct *work)
 	mutex_unlock(&mdev->state_lock);
 }
 
-
-static int mlx4_en_open(struct net_device *dev)
+static void mlx4_en_clear_stats(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int i;
-	int err = 0;
-
-	mutex_lock(&mdev->state_lock);
-
-	if (!mdev->device_up) {
-		en_err(priv, "Cannot open - device down/disabled\n");
-		err = -EBUSY;
-		goto out;
-	}
 
-	/* Reset HW statistics and performance counters */
 	if (mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 1))
 		en_dbg(HW, priv, "Failed dumping statistics\n");
 
 	memset(&priv->stats, 0, sizeof(priv->stats));
 	memset(&priv->pstats, 0, sizeof(priv->pstats));
+	memset(&priv->pkstats, 0, sizeof(priv->pkstats));
+	memset(&priv->port_stats, 0, sizeof(priv->port_stats));
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		priv->tx_ring[i].bytes = 0;
 		priv->tx_ring[i].packets = 0;
+		priv->tx_ring[i].tx_csum = 0;
 	}
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		priv->rx_ring[i].bytes = 0;
 		priv->rx_ring[i].packets = 0;
+		priv->rx_ring[i].csum_ok = 0;
+		priv->rx_ring[i].csum_none = 0;
 	}
+}
+
+static int mlx4_en_open(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int err = 0;
+
+	mutex_lock(&mdev->state_lock);
+
+	if (!mdev->device_up) {
+		en_err(priv, "Cannot open - device down/disabled\n");
+		err = -EBUSY;
+		goto out;
+	}
+
+	/* Reset HW statistics and SW counters */
+	mlx4_en_clear_stats(dev);
 
 	err = mlx4_en_start_port(dev);
 	if (err)
-- 
1.5.4.3
