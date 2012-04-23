From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 1/3] mlx4_en: Added Ethtool support for TX Interrupt
 coalescing
Date: Mon, 23 Apr 2012 15:18:33 +0300
Message-ID: <4F954899.5010009@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:43505 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754462Ab2DWMSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 08:18:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   19 +++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    6 ++++--
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 70346fd..136e06c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -359,8 +359,8 @@ static int mlx4_en_get_coalesce(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
-	coal->tx_coalesce_usecs = 0;
-	coal->tx_max_coalesced_frames = 0;
+	coal->tx_coalesce_usecs = priv->tx_usecs;
+	coal->tx_max_coalesced_frames = priv->tx_frames;
 	coal->rx_coalesce_usecs = priv->rx_usecs;
 	coal->rx_max_coalesced_frames = priv->rx_frames;
 
@@ -388,6 +388,21 @@ static int mlx4_en_set_coalesce(struct net_device *dev,
 				MLX4_EN_RX_COAL_TIME :
 				coal->rx_coalesce_usecs;
 
+	/* Setting TX coalescing parameters */
+	if (coal->tx_coalesce_usecs != priv->tx_usecs ||
+	    coal->tx_max_coalesced_frames != priv->tx_frames) {
+		priv->tx_usecs = coal->tx_coalesce_usecs;
+		priv->tx_frames = coal->tx_max_coalesced_frames;
+		for (i = 0; i < priv->tx_ring_num; i++) {
+			priv->tx_cq[i].moder_cnt = priv->tx_frames;
+			priv->tx_cq[i].moder_time = priv->tx_usecs;
+			if (mlx4_en_set_cq_moder(priv, &priv->tx_cq[i])) {
+				en_warn(priv, "Failed changing moderation "
+					      "for TX cq %d\n", i);
+			}
+		}
+	}
+
 	/* Set adaptive coalescing params */
 	priv->pkt_rate_low = coal->pkt_rate_low;
 	priv->rx_usecs_low = coal->rx_coalesce_usecs_low;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 35003ad..bfcfd8a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -429,6 +429,8 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 	 */
 	priv->rx_frames = MLX4_EN_RX_COAL_TARGET;
 	priv->rx_usecs = MLX4_EN_RX_COAL_TIME;
+	priv->tx_frames = MLX4_EN_TX_COAL_PKTS;
+	priv->tx_usecs = MLX4_EN_TX_COAL_TIME;
 	en_dbg(INTR, priv, "Default coalesing params for mtu:%d - "
 			   "rx_frames:%d rx_usecs:%d\n",
 		 priv->dev->mtu, priv->rx_frames, priv->rx_usecs);
@@ -445,8 +447,8 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		cq = &priv->tx_cq[i];
-		cq->moder_cnt = MLX4_EN_TX_COAL_PKTS;
-		cq->moder_time = MLX4_EN_TX_COAL_TIME;
+		cq->moder_cnt = priv->tx_frames;
+		cq->moder_time = priv->tx_usecs;
 	}
 
 	/* Reset auto-moderation params */
-- 
1.7.7
