From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V3 10/11] net/mlx5e: Delay skb->data access
Date: Wed, 20 Apr 2016 22:02:18 +0300
Message-ID: <1461178939-20687-11-git-send-email-saeedm@mellanox.com>
References: <1461178939-20687-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59502 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751790AbcDTTD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 15:03:56 -0400
In-Reply-To: <1461178939-20687-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move mlx5e_handle_csum and eth_type_trans to the end of
mlx5e_build_rx_skb to gain some more time before accessing
skb->data, to reduce cache misses.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 5bdcc0b..ee5fa16 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -573,10 +573,6 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 	if (unlikely(mlx5e_rx_hw_stamp(tstamp)))
 		mlx5e_fill_hwstamp(tstamp, get_cqe_ts(cqe), skb_hwtstamps(skb));
 
-	mlx5e_handle_csum(netdev, cqe, rq, skb, !!lro_num_seg);
-
-	skb->protocol = eth_type_trans(skb, netdev);
-
 	skb_record_rx_queue(skb, rq->ix);
 
 	if (likely(netdev->features & NETIF_F_RXHASH))
@@ -587,6 +583,9 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 				       be16_to_cpu(cqe->vlan_info));
 
 	skb->mark = be32_to_cpu(cqe->sop_drop_qpn) & MLX5E_TC_FLOW_ID_MASK;
+
+	mlx5e_handle_csum(netdev, cqe, rq, skb, !!lro_num_seg);
+	skb->protocol = eth_type_trans(skb, netdev);
 }
 
 static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
-- 
1.7.1
