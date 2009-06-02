From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 5/8] mlx4_en: Coalescing target is equal for all mtu's
Date: Tue, 02 Jun 2009 12:23:13 +0300
Message-ID: <4A24EF81.4060104@mellanox.co.il>
References: <4A0AB34A.10100@mellanox.co.il><4A1948D7.8010504@mellanox.co.il><4A1A57AA.1080209@mellanox.co.il> <20090525.014435.203274473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:40021 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760172AbZFBIcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 04:32:32 -0400
In-Reply-To: <20090525.014435.203274473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt moderation should not depend on number of incoming
bytes, but on number of incoming packets.
The previous scheme caused very high interrupts rate for small
messages when big MTU was configured.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_ethtool.c |    3 +--
 drivers/net/mlx4/en_netdev.c  |    2 +-
 drivers/net/mlx4/mlx4_en.h    |    4 ++--
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index 91d8116..091f990 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -268,8 +268,7 @@ static int mlx4_en_set_coalesce(struct net_device *dev,
 
 	priv->rx_frames = (coal->rx_max_coalesced_frames ==
 			   MLX4_EN_AUTO_CONF) ?
-				MLX4_EN_RX_COAL_TARGET /
-				priv->dev->mtu + 1 :
+				MLX4_EN_RX_COAL_TARGET :
 				coal->rx_max_coalesced_frames;
 	priv->rx_usecs = (coal->rx_coalesce_usecs ==
 			  MLX4_EN_AUTO_CONF) ?
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index fea65e7..16a634f 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -372,7 +372,7 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 	 *   satisfy our coelsing target.
 	 * - moder_time is set to a fixed value.
 	 */
-	priv->rx_frames = MLX4_EN_RX_COAL_TARGET / priv->dev->mtu + 1;
+	priv->rx_frames = MLX4_EN_RX_COAL_TARGET;
 	priv->rx_usecs = MLX4_EN_RX_COAL_TIME;
 	en_dbg(INTR, priv, "Default coalesing params for mtu:%d - "
 			   "rx_frames:%d rx_usecs:%d\n",
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 174ae86..fcbfcfc 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -143,8 +143,8 @@ enum {
 #define MLX4_EN_DEF_TX_RING_SIZE	1024
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
 
-/* Target number of bytes to coalesce with interrupt moderation */
-#define MLX4_EN_RX_COAL_TARGET	0x20000
+/* Target number of packets to coalesce with interrupt moderation */
+#define MLX4_EN_RX_COAL_TARGET	44
 #define MLX4_EN_RX_COAL_TIME	0x10
 
 #define MLX4_EN_TX_COAL_PKTS	5
-- 
1.6.0


