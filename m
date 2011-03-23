From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH v2 03/16] mlx4_en: optimize adaptive moderation algorithm
 for better latency
Date: Wed, 23 Mar 2011 10:37:36 +0200
Message-ID: <4D89B150.1080907@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:58031 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753475Ab1CWIhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:37:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |   18 +++++-------------
 drivers/net/mlx4/mlx4_en.h   |    1 +
 2 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 56627c2..b1180dd 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -417,7 +417,6 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 	unsigned long avg_pkt_size;
 	unsigned long rx_packets;
 	unsigned long rx_bytes;
-	unsigned long rx_byte_diff;
 	unsigned long tx_packets;
 	unsigned long tx_pkt_diff;
 	unsigned long rx_pkt_diff;
@@ -441,25 +440,20 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 	rx_pkt_diff = ((unsigned long) (rx_packets -
 					priv->last_moder_packets));
 	packets = max(tx_pkt_diff, rx_pkt_diff);
-	rx_byte_diff = rx_bytes - priv->last_moder_bytes;
-	rx_byte_diff = rx_byte_diff ? rx_byte_diff : 1;
 	rate = packets * HZ / period;
 	avg_pkt_size = packets ? ((unsigned long) (rx_bytes -
 				 priv->last_moder_bytes)) / packets : 0;
 
 	/* Apply auto-moderation only when packet rate exceeds a rate that
 	 * it matters */
-	if (rate > MLX4_EN_RX_RATE_THRESH) {
+	if (rate > MLX4_EN_RX_RATE_THRESH && avg_pkt_size > MLX4_EN_AVG_PKT_SMALL) {
 		/* If tx and rx packet rates are not balanced, assume that
 		 * traffic is mainly BW bound and apply maximum moderation.
 		 * Otherwise, moderate according to packet rate */
-		if (2 * tx_pkt_diff > 3 * rx_pkt_diff &&
-		    rx_pkt_diff / rx_byte_diff <
-		    MLX4_EN_SMALL_PKT_SIZE)
-			moder_time = priv->rx_usecs_low;
-		else if (2 * rx_pkt_diff > 3 * tx_pkt_diff)
+		if (2 * tx_pkt_diff > 3 * rx_pkt_diff ||
+		    2 * rx_pkt_diff > 3 * tx_pkt_diff) {
 			moder_time = priv->rx_usecs_high;
-		else {
+		} else {
 			if (rate < priv->pkt_rate_low)
 				moder_time = priv->rx_usecs_low;
 			else if (rate > priv->pkt_rate_high)
@@ -471,9 +465,7 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 					priv->rx_usecs_low;
 		}
 	} else {
-		/* When packet rate is low, use default moderation rather than
-		 * 0 to prevent interrupt storms if traffic suddenly increases */
-		moder_time = priv->rx_usecs;
+		moder_time = priv->rx_usecs_low;
 	}
 
 	en_dbg(INTR, priv, "tx rate:%lu rx_rate:%lu\n",
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index dfed6a0..5387c4e 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -124,6 +124,7 @@ enum {
 #define MLX4_EN_RX_SIZE_THRESH		1024
 #define MLX4_EN_RX_RATE_THRESH		(1000000 / MLX4_EN_RX_COAL_TIME_HIGH)
 #define MLX4_EN_SAMPLE_INTERVAL		0
+#define MLX4_EN_AVG_PKT_SMALL		256
 
 #define MLX4_EN_AUTO_CONF	0xffff
 
-- 
1.6.0.2





