From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 04/10] net/mlx4_en: Improve transmit CQ polling
Date: Thu, 15 Jun 2017 14:35:34 +0300
Message-ID: <1497526540-30028-5-git-send-email-tariqt@mellanox.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36074 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752324AbdFOLgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:36:25 -0400
In-Reply-To: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several small performance improvements in TX CQ polling,
including:
- Compiler branch predictor hints.
- Minimize variables scope.
- More proper check of cq type.
- Use boolean instead of int for a binary indication.

Performance tests:
Tested on ConnectX3Pro, Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz

Packet-rate tests for both regular stack and XDP use cases:
No noticeable gain, no degradation.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 37386abea54c..2d5e0da1de2f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -402,8 +402,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	struct mlx4_cq *mcq = &cq->mcq;
 	struct mlx4_en_tx_ring *ring = priv->tx_ring[cq->type][cq->ring];
 	struct mlx4_cqe *cqe;
-	u16 index;
-	u16 new_index, ring_index, stamp_index;
+	u16 index, ring_index, stamp_index;
 	u32 txbbs_skipped = 0;
 	u32 txbbs_stamp = 0;
 	u32 cons_index = mcq->cons_index;
@@ -418,7 +417,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	u32 last_nr_txbb;
 	u32 ring_cons;
 
-	if (!priv->port_up)
+	if (unlikely(!priv->port_up))
 		return true;
 
 	netdev_txq_bql_complete_prefetchw(ring->tx_queue);
@@ -433,6 +432,8 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	/* Process all completed CQEs */
 	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
 			cons_index & size) && (done < budget)) {
+		u16 new_index;
+
 		/*
 		 * make sure we read the CQE after we read the
 		 * ownership bit
@@ -479,7 +480,6 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 		cqe = mlx4_en_get_cqe(buf, index, priv->cqe_size) + factor;
 	}
 
-
 	/*
 	 * To prevent CQ overflow we first update CQ consumer and only then
 	 * the ring consumer.
@@ -492,7 +492,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
 	ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
 
-	if (ring->free_tx_desc == mlx4_en_recycle_tx_desc)
+	if (cq->type == TX_XDP)
 		return done < budget;
 
 	netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
@@ -504,6 +504,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 		netif_tx_wake_queue(ring->tx_queue);
 		ring->wake_queue++;
 	}
+
 	return done < budget;
 }
 
@@ -524,7 +525,7 @@ int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
 	struct mlx4_en_cq *cq = container_of(napi, struct mlx4_en_cq, napi);
 	struct net_device *dev = cq->dev;
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	int clean_complete;
+	bool clean_complete;
 
 	clean_complete = mlx4_en_process_tx_cq(dev, cq, budget);
 	if (!clean_complete)
-- 
1.8.3.1
