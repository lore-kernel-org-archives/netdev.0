From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] mlx4: fix potential divide by 0 in
 mlx4_en_auto_moderation()
Date: Thu, 16 Feb 2017 15:23:27 -0800
Message-ID: <1487287407.1311.69.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
         <1487165355.1311.2.camel@edumazet-glaptop3.roam.corp.google.com>
         <1487167443.1311.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8WHJYQFEsxU39jgpMDFHPkHuDX6VU7vOcd+wqBedonfA@mail.gmail.com>
         <1487260187.1311.53.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG_w2m9p3OQxi9c9=Y-RVKKLyce1b-WjoSvLUVGcWHNwYA@mail.gmail.com>
         <1487286833.1311.63.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, jackm@mellanox.com
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36118 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933685AbdBPXX3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 18:23:29 -0500
Received: by mail-pg0-f65.google.com with SMTP id a123so369400pgc.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 15:23:29 -0800 (PST)
In-Reply-To: <1487286833.1311.63.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

1) In the case where rate == priv->pkt_rate_low == priv->pkt_rate_high,
mlx4_en_auto_moderation() does a divide by zero.

2) We want to properly change the moderation parameters if rx_frames
was changed (like in ethtool -C eth0 rx-frames 16)
 
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   24 ++++++++-------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 3b4961a8e8e44d6987ebd23f9239e747c7fc6cd5..ab3801d724ede4ab19958b2a1a214cfbe901c370 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1384,6 +1384,7 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 {
 	unsigned long period = (unsigned long) (jiffies - priv->last_moder_jiffies);
+	u32 pkt_rate_high, pkt_rate_low;
 	struct mlx4_en_cq *cq;
 	unsigned long packets;
 	unsigned long rate;
@@ -1397,37 +1398,40 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 	if (!priv->adaptive_rx_coal || period < priv->sample_interval * HZ)
 		return;
 
+	pkt_rate_low = READ_ONCE(priv->pkt_rate_low);
+	pkt_rate_high = READ_ONCE(priv->pkt_rate_high);
+
 	for (ring = 0; ring < priv->rx_ring_num; ring++) {
 		rx_packets = READ_ONCE(priv->rx_ring[ring]->packets);
 		rx_bytes = READ_ONCE(priv->rx_ring[ring]->bytes);
 
-		rx_pkt_diff = ((unsigned long) (rx_packets -
-				priv->last_moder_packets[ring]));
+		rx_pkt_diff = rx_packets - priv->last_moder_packets[ring];
 		packets = rx_pkt_diff;
 		rate = packets * HZ / period;
-		avg_pkt_size = packets ? ((unsigned long) (rx_bytes -
-				priv->last_moder_bytes[ring])) / packets : 0;
+		avg_pkt_size = packets ? (rx_bytes -
+				priv->last_moder_bytes[ring]) / packets : 0;
 
 		/* Apply auto-moderation only when packet rate
 		 * exceeds a rate that it matters */
 		if (rate > (MLX4_EN_RX_RATE_THRESH / priv->rx_ring_num) &&
 		    avg_pkt_size > MLX4_EN_AVG_PKT_SMALL) {
-			if (rate < priv->pkt_rate_low)
+			if (rate <= pkt_rate_low)
 				moder_time = priv->rx_usecs_low;
-			else if (rate > priv->pkt_rate_high)
+			else if (rate >= pkt_rate_high)
 				moder_time = priv->rx_usecs_high;
 			else
-				moder_time = (rate - priv->pkt_rate_low) *
+				moder_time = (rate - pkt_rate_low) *
 					(priv->rx_usecs_high - priv->rx_usecs_low) /
-					(priv->pkt_rate_high - priv->pkt_rate_low) +
+					(pkt_rate_high - pkt_rate_low) +
 					priv->rx_usecs_low;
 		} else {
 			moder_time = priv->rx_usecs_low;
 		}
 
-		if (moder_time != priv->last_moder_time[ring]) {
+		cq = priv->rx_cq[ring];
+		if (moder_time != priv->last_moder_time[ring] ||
+		    cq->moder_cnt != priv->rx_frames) {
 			priv->last_moder_time[ring] = moder_time;
-			cq = priv->rx_cq[ring];
 			cq->moder_time = moder_time;
 			cq->moder_cnt = priv->rx_frames;
 			err = mlx4_en_set_cq_moder(priv, cq);
