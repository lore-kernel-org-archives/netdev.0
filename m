From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 12/12] net/mlx5e: Add tx inner packet counters
Date: Thu, 18 Feb 2016 12:32:53 +0200
Message-ID: <1455791573-5270-13-git-send-email-saeedm@mellanox.com>
References: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34178 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1945990AbcBRKly (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:41:54 -0500
In-Reply-To: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

Add TSO and TX checksum counters for tunneled, inner packets

Signed-off-by: Matt Finlay <matt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   16 ++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    8 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |   20 +++++++++++---------
 3 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index a700c57..1dca3dc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -103,12 +103,15 @@ static const char vport_strings[][ETH_GSTRING_LEN] = {
 	/* SW counters */
 	"tso_packets",
 	"tso_bytes",
+	"tso_inner_packets",
+	"tso_inner_bytes",
 	"lro_packets",
 	"lro_bytes",
 	"rx_csum_good",
 	"rx_csum_none",
 	"rx_csum_sw",
 	"tx_csum_offload",
+	"tx_csum_inner",
 	"tx_queue_stopped",
 	"tx_queue_wake",
 	"tx_queue_dropped",
@@ -141,18 +144,21 @@ struct mlx5e_vport_stats {
 	/* SW counters */
 	u64 tso_packets;
 	u64 tso_bytes;
+	u64 tso_inner_packets;
+	u64 tso_inner_bytes;
 	u64 lro_packets;
 	u64 lro_bytes;
 	u64 rx_csum_good;
 	u64 rx_csum_none;
 	u64 rx_csum_sw;
 	u64 tx_csum_offload;
+	u64 tx_csum_inner;
 	u64 tx_queue_stopped;
 	u64 tx_queue_wake;
 	u64 tx_queue_dropped;
 	u64 rx_wqe_err;
 
-#define NUM_VPORT_COUNTERS     32
+#define NUM_VPORT_COUNTERS     35
 };
 
 static const char pport_strings[][ETH_GSTRING_LEN] = {
@@ -252,7 +258,10 @@ static const char sq_stats_strings[][ETH_GSTRING_LEN] = {
 	"packets",
 	"tso_packets",
 	"tso_bytes",
+	"tso_inner_packets",
+	"tso_inner_bytes",
 	"csum_offload_none",
+	"csum_offload_inner",
 	"stopped",
 	"wake",
 	"dropped",
@@ -263,12 +272,15 @@ struct mlx5e_sq_stats {
 	u64 packets;
 	u64 tso_packets;
 	u64 tso_bytes;
+	u64 tso_inner_packets;
+	u64 tso_inner_bytes;
 	u64 csum_offload_none;
+	u64 csum_offload_inner;
 	u64 stopped;
 	u64 wake;
 	u64 dropped;
 	u64 nop;
-#define NUM_SQ_STATS 8
+#define NUM_SQ_STATS 11
 };
 
 struct mlx5e_stats {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 3a31e27..95046fd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -145,9 +145,12 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 	/* Collect firts the SW counters and then HW for consistency */
 	s->tso_packets		= 0;
 	s->tso_bytes		= 0;
+	s->tso_inner_packets	= 0;
+	s->tso_inner_bytes	= 0;
 	s->tx_queue_stopped	= 0;
 	s->tx_queue_wake	= 0;
 	s->tx_queue_dropped	= 0;
+	s->tx_csum_inner	= 0;
 	tx_offload_none		= 0;
 	s->lro_packets		= 0;
 	s->lro_bytes		= 0;
@@ -168,9 +171,12 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 
 			s->tso_packets		+= sq_stats->tso_packets;
 			s->tso_bytes		+= sq_stats->tso_bytes;
+			s->tso_inner_packets	+= sq_stats->tso_inner_packets;
+			s->tso_inner_bytes	+= sq_stats->tso_inner_bytes;
 			s->tx_queue_stopped	+= sq_stats->stopped;
 			s->tx_queue_wake	+= sq_stats->wake;
 			s->tx_queue_dropped	+= sq_stats->dropped;
+			s->tx_csum_inner	+= sq_stats->csum_offload_inner;
 			tx_offload_none		+= sq_stats->csum_offload_none;
 		}
 	}
@@ -245,7 +251,7 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 		s->tx_broadcast_bytes;
 
 	/* Update calculated offload counters */
-	s->tx_csum_offload = s->tx_packets - tx_offload_none;
+	s->tx_csum_offload = s->tx_packets - tx_offload_none - s->tx_csum_inner;
 	s->rx_csum_good    = s->rx_packets - s->rx_csum_none -
 			       s->rx_csum_sw;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 6ce2884..a05c070 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -187,11 +187,13 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		eseg->cs_flags = MLX5_ETH_WQE_L3_CSUM;
-		if (skb->encapsulation)
+		if (skb->encapsulation) {
 			eseg->cs_flags |= MLX5_ETH_WQE_L3_INNER_CSUM |
 					  MLX5_ETH_WQE_L4_INNER_CSUM;
-		else
+			sq->stats.csum_offload_inner++;
+		} else {
 			eseg->cs_flags |= MLX5_ETH_WQE_L4_CSUM;
+		}
 	} else
 		sq->stats.csum_offload_none++;
 
@@ -201,21 +203,21 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	}
 
 	if (skb_is_gso(skb)) {
-		u32 payload_len;
-
 		eseg->mss    = cpu_to_be16(skb_shinfo(skb)->gso_size);
 		opcode       = MLX5_OPCODE_LSO;
 
-		if (skb->encapsulation)
+		if (skb->encapsulation) {
 			ihs = skb_inner_transport_offset(skb) + inner_tcp_hdrlen(skb);
-		else
+			sq->stats.tso_inner_packets++;
+			sq->stats.tso_inner_bytes += skb->len - ihs;
+		} else {
 			ihs = skb_transport_offset(skb) + tcp_hdrlen(skb);
+			sq->stats.tso_packets++;
+			sq->stats.tso_bytes += skb->len - ihs;
+		}
 
-		payload_len   = skb->len - ihs;
 		wi->num_bytes = skb->len +
 				(skb_shinfo(skb)->gso_segs - 1) * ihs;
-		sq->stats.tso_packets++;
-		sq->stats.tso_bytes += payload_len;
 	} else {
 		bf = sq->bf_budget &&
 		     !skb->xmit_more &&
-- 
1.7.1
