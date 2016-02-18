From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 08/12] net/mlx5e: Move to checksum complete
Date: Thu, 18 Feb 2016 12:32:49 +0200
Message-ID: <1455791573-5270-9-git-send-email-saeedm@mellanox.com>
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
Received: from [193.47.165.129] ([193.47.165.129]:34216 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1425528AbcBRKmS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:42:18 -0500
In-Reply-To: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

Use checksum complete for all IP packets, unless they are HW LRO,
in which case, use checksum unnecessary.

Signed-off-by: Matt Finlay <matt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index dd959d9..519a07f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -167,14 +167,15 @@ static inline bool is_first_ethertype_ip(struct sk_buff *skb)
 static inline void mlx5e_handle_csum(struct net_device *netdev,
 				     struct mlx5_cqe64 *cqe,
 				     struct mlx5e_rq *rq,
-				     struct sk_buff *skb)
+				     struct sk_buff *skb,
+				     bool   lro)
 {
 	if (unlikely(!(netdev->features & NETIF_F_RXCSUM)))
 		goto csum_none;
 
-	if (likely(cqe->hds_ip_ext & CQE_L4_OK)) {
+	if (lro) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else if (is_first_ethertype_ip(skb)) {
+	} else if (likely(is_first_ethertype_ip(skb))) {
 		skb->ip_summed = CHECKSUM_COMPLETE;
 		skb->csum = csum_unfold((__force __sum16)cqe->check_sum);
 		rq->stats.csum_sw++;
@@ -211,7 +212,7 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 	if (unlikely(mlx5e_rx_hw_stamp(tstamp)))
 		mlx5e_fill_hwstamp(tstamp, get_cqe_ts(cqe), skb_hwtstamps(skb));
 
-	mlx5e_handle_csum(netdev, cqe, rq, skb);
+	mlx5e_handle_csum(netdev, cqe, rq, skb, !!lro_num_seg);
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
-- 
1.7.1
