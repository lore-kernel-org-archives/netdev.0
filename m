From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [net-next-2.6 PATCH 1/3] mlx4_en: Adaptive moderation policy change
Date: Sun, 19 Jul 2009 16:06:44 +0300
Message-ID: <4A631A64.50804@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:39264 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753603AbZGSNIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 09:08:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the net device is identified as "sender" (number of sent packets
is higher then the number of received packets and the incoming packets are
small), set the moderation time to its low limit.
We do it because the incoming packets are acks, and we don't want to delay them

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 93f4abd..c8a24dc 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -414,6 +414,7 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 	unsigned long avg_pkt_size;
 	unsigned long rx_packets;
 	unsigned long rx_bytes;
+	unsigned long rx_byte_diff;
 	unsigned long tx_packets;
 	unsigned long tx_pkt_diff;
 	unsigned long rx_pkt_diff;
@@ -437,6 +438,8 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 	rx_pkt_diff = ((unsigned long) (rx_packets -
 					priv->last_moder_packets));
 	packets = max(tx_pkt_diff, rx_pkt_diff);
+	rx_byte_diff = rx_bytes - priv->last_moder_bytes;
+	rx_byte_diff = rx_byte_diff ? rx_byte_diff : 1;
 	rate = packets * HZ / period;
 	avg_pkt_size = packets ? ((unsigned long) (rx_bytes -
 				 priv->last_moder_bytes)) / packets : 0;
@@ -447,10 +450,13 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 		/* If tx and rx packet rates are not balanced, assume that
 		 * traffic is mainly BW bound and apply maximum moderation.
 		 * Otherwise, moderate according to packet rate */
-		if (2 * tx_pkt_diff > 3 * rx_pkt_diff ||
-		    2 * rx_pkt_diff > 3 * tx_pkt_diff) {
+		if (2 * tx_pkt_diff > 3 * rx_pkt_diff &&
+		    rx_pkt_diff / rx_byte_diff <
+		    MLX4_EN_SMALL_PKT_SIZE)
+			moder_time = priv->rx_usecs_low;
+		else if (2 * rx_pkt_diff > 3 * tx_pkt_diff)
 			moder_time = priv->rx_usecs_high;
-		} else {
+		else {
 			if (rate < priv->pkt_rate_low)
 				moder_time = priv->rx_usecs_low;
 			else if (rate > priv->pkt_rate_high)
-- 
1.6.0

