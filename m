From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 6/9] net/mlx5e: Add ethtool counter for TX xmit_more
Date: Mon, 29 Aug 2016 01:13:47 +0300
Message-ID: <1472422430-21583-7-git-send-email-saeedm@mellanox.com>
References: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53048 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756205AbcH1WOh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 18:14:37 -0400
In-Reply-To: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Add a counter in ethtool for the number of times that
TX xmit_more was used.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    | 1 +
 3 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 297781a..2459c7f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -155,6 +155,7 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 			s->tx_queue_stopped	+= sq_stats->stopped;
 			s->tx_queue_wake	+= sq_stats->wake;
 			s->tx_queue_dropped	+= sq_stats->dropped;
+			s->tx_xmit_more		+= sq_stats->xmit_more;
 			s->tx_csum_partial_inner += sq_stats->csum_partial_inner;
 			tx_offload_none		+= sq_stats->csum_none;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 7b9d8a9..499487c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -70,6 +70,7 @@ struct mlx5e_sw_stats {
 	u64 tx_queue_stopped;
 	u64 tx_queue_wake;
 	u64 tx_queue_dropped;
+	u64 tx_xmit_more;
 	u64 rx_wqe_err;
 	u64 rx_mpwqe_filler;
 	u64 rx_mpwqe_frag;
@@ -101,6 +102,7 @@ static const struct counter_desc sw_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_stopped) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_wake) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_dropped) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_xmit_more) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_wqe_err) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_mpwqe_filler) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_mpwqe_frag) },
@@ -298,6 +300,7 @@ struct mlx5e_sq_stats {
 	/* commonly accessed in data path */
 	u64 packets;
 	u64 bytes;
+	u64 xmit_more;
 	u64 tso_packets;
 	u64 tso_bytes;
 	u64 tso_inner_packets;
@@ -324,6 +327,7 @@ static const struct counter_desc sq_stats_desc[] = {
 	{ MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, stopped) },
 	{ MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, wake) },
 	{ MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, dropped) },
+	{ MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, xmit_more) },
 };
 
 #define NUM_SW_COUNTERS			ARRAY_SIZE(sw_stats_desc)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 5f209ad..988eca9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -375,6 +375,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	sq->stats.packets++;
 	sq->stats.bytes += num_bytes;
+	sq->stats.xmit_more += skb->xmit_more;
 	return NETDEV_TX_OK;
 
 dma_unmap_wqe_err:
-- 
2.7.4
