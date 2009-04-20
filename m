From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 5/5] mlx4_en: Move to SW counters for total bytes and packets
Date: Mon, 20 Apr 2009 17:34:38 +0300
Message-ID: <49EC87FE.4010000@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il> <49EC87AB.1070009@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:39930 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755816AbZDTOfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 10:35:41 -0400
In-Reply-To: <49EC87AB.1070009@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The per ring counters are implemented in SW. Now moving to have the total
counters as the sum of all rings. This way the numbers will always be consistent
and we no longer depend on HW buffer size limitations for those counters
that can be insufficient in some cases.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_port.c |   45 ++++++++++++-------------------------------
 1 files changed, 13 insertions(+), 32 deletions(-)

diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index c5a4c03..a29abe8 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -151,6 +151,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	struct mlx4_cmd_mailbox *mailbox;
 	u64 in_mod = reset << 8 | port;
 	int err;
+	int i;

 	mailbox = mlx4_alloc_cmd_mailbox(mdev->dev);
 	if (IS_ERR(mailbox))
@@ -165,38 +166,18 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)

 	spin_lock_bh(&priv->stats_lock);

-	stats->rx_packets = be32_to_cpu(mlx4_en_stats->RTOTFRMS) -
-			    be32_to_cpu(mlx4_en_stats->RDROP);
-	stats->tx_packets = be64_to_cpu(mlx4_en_stats->TTOT_prio_0) +
-			    be64_to_cpu(mlx4_en_stats->TTOT_prio_1) +
-			    be64_to_cpu(mlx4_en_stats->TTOT_prio_2) +
-			    be64_to_cpu(mlx4_en_stats->TTOT_prio_3) +
-			    be64_to_cpu(mlx4_en_stats->TTOT_prio_4) +
-			    be64_to_cpu(mlx4_en_stats->TTOT_prio_5) +
-			    be64_to_cpu(mlx4_en_stats->TTOT_prio_6) +
-			    be64_to_cpu(mlx4_en_stats->TTOT_prio_7) +
-			    be64_to_cpu(mlx4_en_stats->TTOT_novlan) +
-			    be64_to_cpu(mlx4_en_stats->TTOT_loopbk);
-	stats->rx_bytes = be64_to_cpu(mlx4_en_stats->ROCT_prio_0) +
-			  be64_to_cpu(mlx4_en_stats->ROCT_prio_1) +
-			  be64_to_cpu(mlx4_en_stats->ROCT_prio_2) +
-			  be64_to_cpu(mlx4_en_stats->ROCT_prio_3) +
-			  be64_to_cpu(mlx4_en_stats->ROCT_prio_4) +
-			  be64_to_cpu(mlx4_en_stats->ROCT_prio_5) +
-			  be64_to_cpu(mlx4_en_stats->ROCT_prio_6) +
-			  be64_to_cpu(mlx4_en_stats->ROCT_prio_7) +
-			  be64_to_cpu(mlx4_en_stats->ROCT_novlan);
-
-	stats->tx_bytes = be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_0) +
-			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_1) +
-			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_2) +
-			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_3) +
-			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_4) +
-			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_5) +
-			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_6) +
-			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_7) +
-			  be64_to_cpu(mlx4_en_stats->TTTLOCT_novlan) +
-			  be64_to_cpu(mlx4_en_stats->TTTLOCT_loopbk);
+	stats->rx_packets = 0;
+	stats->rx_bytes = 0;
+	for (i = 0; i < priv->rx_ring_num; i++) {
+		stats->rx_packets += priv->rx_ring[i].packets;
+		stats->rx_bytes += priv->rx_ring[i].bytes;
+	}
+	stats->tx_packets = 0;
+	stats->tx_bytes = 0;
+	for (i = 0; i <= priv->tx_ring_num; i++) {
+		stats->tx_packets += priv->tx_ring[i].packets;
+		stats->tx_bytes += priv->tx_ring[i].bytes;
+	}

 	stats->rx_errors = be64_to_cpu(mlx4_en_stats->PCS) +
 			   be32_to_cpu(mlx4_en_stats->RdropLength) +
-- 
1.5.4


