From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 10/14] mlx4_en: get/set ringsize uses actual ring size
Date: Tue, 24 Aug 2010 16:46:34 +0300
Message-ID: <4C73CD3A.4060206@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50156 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751660Ab0HXNqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:46:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case that the rings were not fully filled, the report in Ethtool
should be according to the actual size that was filled.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_ethtool.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index 13e20c6..acdcda8 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -394,8 +394,9 @@ static int mlx4_en_set_ringparam(struct net_device *dev,
 	tx_size = max_t(u32, tx_size, MLX4_EN_MIN_TX_SIZE);
 	tx_size = min_t(u32, tx_size, MLX4_EN_MAX_TX_SIZE);
 
-	if (rx_size == priv->prof->rx_ring_size &&
-	    tx_size == priv->prof->tx_ring_size)
+	if (rx_size == (priv->port_up ? priv->rx_ring[0].actual_size :
+					priv->rx_ring[0].size) &&
+	    tx_size == priv->tx_ring[0].size)
 		return 0;
 
 	mutex_lock(&mdev->state_lock);
@@ -429,13 +430,13 @@ static void mlx4_en_get_ringparam(struct net_device *dev,
 				  struct ethtool_ringparam *param)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
 
 	memset(param, 0, sizeof(*param));
 	param->rx_max_pending = MLX4_EN_MAX_RX_SIZE;
 	param->tx_max_pending = MLX4_EN_MAX_TX_SIZE;
-	param->rx_pending = mdev->profile.prof[priv->port].rx_ring_size;
-	param->tx_pending = mdev->profile.prof[priv->port].tx_ring_size;
+	param->rx_pending = priv->port_up ?
+		priv->rx_ring[0].actual_size : priv->rx_ring[0].size;
+	param->tx_pending = priv->tx_ring[0].size;
 }
 
 static int mlx4_ethtool_op_set_flags(struct net_device *dev, u32 data)
-- 
1.6.1.3


