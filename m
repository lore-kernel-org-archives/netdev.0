From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 07/11] net/mlx5e: Avoid TX CQE generation if more xmit packets expected
Date: Tue, 23 Jun 2015 17:14:18 +0300
Message-ID: <1435068862-26488-8-git-send-email-ogerlitz@mellanox.com>
References: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41234 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934073AbbFWOPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 10:15:06 -0400
In-Reply-To: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

In order to save PCI BW consumed by TX CQEs and to reduce the amount of
CPU cache misses caused by TX CQE reading, we request TX CQE generation
only when skb->xmit_more=0.

As a consequence of the above, a single TX CQE may now indicate the
transmission completion of multiple TX SKBs.

This also handles a problem introduced in commit b1b8105ebf41 "net/mlx5e:
Support NETIF_F_SG" where we didn't ask for NOP completions while the
driver didn't have the proper code to handle this case.

Fixes: b1b8105ebf41 ('net/mlx5e: Support NETIF_F_SG')
Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 57 +++++++++++++++----------
 1 file changed, 34 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index f5c7d78..a45d751 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -210,7 +210,6 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	cseg->opmod_idx_opcode	= cpu_to_be32((sq->pc << 8) | opcode);
 	cseg->qpn_ds		= cpu_to_be32((sq->sqn << 8) | ds_cnt);
-	cseg->fm_ce_se		= MLX5_WQE_CTRL_CQ_UPDATE;
 
 	sq->skb[pi] = skb;
 
@@ -225,8 +224,10 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		sq->stats.stopped++;
 	}
 
-	if (!skb->xmit_more || netif_xmit_stopped(sq->txq))
+	if (!skb->xmit_more || netif_xmit_stopped(sq->txq)) {
+		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
 		mlx5e_tx_notify_hw(sq, wqe);
+	}
 
 	/* fill sq edge with nops to avoid wqe wrap around */
 	while ((sq->pc & wq->sz_m1) > sq->edge)
@@ -280,36 +281,46 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 
 	for (i = 0; i < MLX5E_TX_CQ_POLL_BUDGET; i++) {
 		struct mlx5_cqe64 *cqe;
-		struct sk_buff *skb;
-		u16 ci;
-		int j;
+		u16 wqe_counter;
+		bool last_wqe;
 
 		cqe = mlx5e_get_cqe(cq);
 		if (!cqe)
 			break;
 
-		ci = sqcc & sq->wq.sz_m1;
-		skb = sq->skb[ci];
+		wqe_counter = be16_to_cpu(cqe->wqe_counter);
+
+		do {
+			struct sk_buff *skb;
+			u16 ci;
+			int j;
+
+			last_wqe = (sqcc == wqe_counter);
+
+			ci = sqcc & sq->wq.sz_m1;
+			skb = sq->skb[ci];
 
-		if (unlikely(!skb)) { /* nop */
-			sq->stats.nop++;
-			sqcc++;
-			continue;
-		}
+			if (unlikely(!skb)) { /* nop */
+				sq->stats.nop++;
+				sqcc++;
+				continue;
+			}
 
-		for (j = 0; j < MLX5E_TX_SKB_CB(skb)->num_dma; j++) {
-			dma_addr_t addr;
-			u32 size;
+			for (j = 0; j < MLX5E_TX_SKB_CB(skb)->num_dma; j++) {
+				dma_addr_t addr;
+				u32 size;
 
-			mlx5e_dma_get(sq, dma_fifo_cc, &addr, &size);
-			dma_fifo_cc++;
-			dma_unmap_single(sq->pdev, addr, size, DMA_TO_DEVICE);
-		}
+				mlx5e_dma_get(sq, dma_fifo_cc, &addr, &size);
+				dma_fifo_cc++;
+				dma_unmap_single(sq->pdev, addr, size,
+						 DMA_TO_DEVICE);
+			}
 
-		npkts++;
-		nbytes += MLX5E_TX_SKB_CB(skb)->num_bytes;
-		sqcc += MLX5E_TX_SKB_CB(skb)->num_wqebbs;
-		dev_kfree_skb(skb);
+			npkts++;
+			nbytes += MLX5E_TX_SKB_CB(skb)->num_bytes;
+			sqcc += MLX5E_TX_SKB_CB(skb)->num_wqebbs;
+			dev_kfree_skb(skb);
+		} while (!last_wqe);
 	}
 
 	mlx5_cqwq_update_db_record(&cq->wq);
-- 
2.3.7
