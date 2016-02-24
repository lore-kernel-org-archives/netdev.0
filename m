From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 7/7] net/mlx5e: Provide correct packet/bytes statistics
Date: Wed, 24 Feb 2016 13:18:53 +0200
Message-ID: <1456312733-22091-8-git-send-email-saeedm@mellanox.com>
References: <1456312733-22091-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:44424 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752512AbcBXLUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 06:20:06 -0500
In-Reply-To: <1456312733-22091-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Using the HW VPort counters for traffic (rx/tx packets/bytes)
statistics is wrong. This is because frames dropped due to steering or
out of buffer will be counted as received. To fix that, we move to use
the packet/bytes accounting done by the driver for what the netdev
reports out.

Fixes: f62b8bb8f2d3 ('net/mlx5: Extend mlx5_core to support [...]')
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   25 ++++++--------------
 1 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 02689ca..402994b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -141,6 +141,10 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 		return;
 
 	/* Collect firts the SW counters and then HW for consistency */
+	s->rx_packets		= 0;
+	s->rx_bytes		= 0;
+	s->tx_packets		= 0;
+	s->tx_bytes		= 0;
 	s->tso_packets		= 0;
 	s->tso_bytes		= 0;
 	s->tx_queue_stopped	= 0;
@@ -155,6 +159,8 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 	for (i = 0; i < priv->params.num_channels; i++) {
 		rq_stats = &priv->channel[i]->rq.stats;
 
+		s->rx_packets	+= rq_stats->packets;
+		s->rx_bytes	+= rq_stats->bytes;
 		s->lro_packets	+= rq_stats->lro_packets;
 		s->lro_bytes	+= rq_stats->lro_bytes;
 		s->rx_csum_none	+= rq_stats->csum_none;
@@ -164,6 +170,8 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 		for (j = 0; j < priv->params.num_tc; j++) {
 			sq_stats = &priv->channel[i]->sq[j].stats;
 
+			s->tx_packets		+= sq_stats->packets;
+			s->tx_bytes		+= sq_stats->bytes;
 			s->tso_packets		+= sq_stats->tso_packets;
 			s->tso_bytes		+= sq_stats->tso_bytes;
 			s->tx_queue_stopped	+= sq_stats->stopped;
@@ -225,23 +233,6 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 	s->tx_broadcast_bytes   =
 		MLX5_GET_CTR(out, transmitted_eth_broadcast.octets);
 
-	s->rx_packets =
-		s->rx_unicast_packets +
-		s->rx_multicast_packets +
-		s->rx_broadcast_packets;
-	s->rx_bytes =
-		s->rx_unicast_bytes +
-		s->rx_multicast_bytes +
-		s->rx_broadcast_bytes;
-	s->tx_packets =
-		s->tx_unicast_packets +
-		s->tx_multicast_packets +
-		s->tx_broadcast_packets;
-	s->tx_bytes =
-		s->tx_unicast_bytes +
-		s->tx_multicast_bytes +
-		s->tx_broadcast_bytes;
-
 	/* Update calculated offload counters */
 	s->tx_csum_offload = s->tx_packets - tx_offload_none;
 	s->rx_csum_good    = s->rx_packets - s->rx_csum_none -
-- 
1.7.1
