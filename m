From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next V2 5/6] net/mlx5e: XDP Tx, no inline copy on ConnectX-5
Date: Tue,  7 Feb 2017 01:38:28 +0200
Message-ID: <20170206233829.29716-6-saeedm@mellanox.com>
References: <20170206233829.29716-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52047 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751524AbdBFXjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 18:39:01 -0500
In-Reply-To: <20170206233829.29716-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ConnectX-5 and later HW generations will report min inline mode ==
MLX5_INLINE_MODE_NONE, which means driver is not required to copy packet
headers to inline fields of TX WQE.

Avoid copy to inline segment in XDP TX routine when HW inline mode doesn't
require it.

This will improve CPU utilization and boost XDP TX performance.

Tested with xdp2 single flow:
CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
HCA: Mellanox Technologies MT28800 Family [ConnectX-5 Ex]

Before: 7.4Mpps
After:  7.8Mpps
Improvement: 5%

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  3 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  3 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 20 +++++++++++++-------
 3 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 9b23d3329847..8be4b12b5545 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -120,8 +120,7 @@
 #define MLX5E_XDP_IHS_DS_COUNT \
 	DIV_ROUND_UP(MLX5E_XDP_MIN_INLINE - 2, MLX5_SEND_WQE_DS)
 #define MLX5E_XDP_TX_DS_COUNT \
-	(MLX5E_XDP_IHS_DS_COUNT + \
-	 (sizeof(struct mlx5e_tx_wqe) / MLX5_SEND_WQE_DS) + 1 /* SG DS */)
+	((sizeof(struct mlx5e_tx_wqe) / MLX5_SEND_WQE_DS) + 1 /* SG DS */)
 #define MLX5E_XDP_TX_WQEBBS \
 	DIV_ROUND_UP(MLX5E_XDP_TX_DS_COUNT, MLX5_SEND_WQEBB_NUM_DS)
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9cd38401fdc9..ed230757d9c5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1806,8 +1806,7 @@ static void mlx5e_build_xdpsq_param(struct mlx5e_priv *priv,
 	MLX5_SET(wq, wq, log_wq_sz,     priv->params.log_sq_size);
 
 	param->max_inline = priv->params.tx_max_inline;
-	/* FOR XDP SQs will support only L2 inline mode */
-	param->min_inline_mode = MLX5_INLINE_MODE_NONE;
+	param->min_inline_mode = priv->params.tx_min_inline_mode;
 	param->type = MLX5E_SQ_XDP;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 965e69e9ff1e..b039b87742a6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -657,9 +657,10 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 	struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
 	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
 	struct mlx5_wqe_data_seg *dseg;
+	u8 ds_cnt = MLX5E_XDP_TX_DS_COUNT;
 
 	ptrdiff_t data_offset = xdp->data - xdp->data_hard_start;
-	dma_addr_t dma_addr  = di->addr + data_offset + MLX5E_XDP_MIN_INLINE;
+	dma_addr_t dma_addr  = di->addr + data_offset;
 	unsigned int dma_len = xdp->data_end - xdp->data;
 
 	if (unlikely(dma_len < MLX5E_XDP_MIN_INLINE ||
@@ -680,17 +681,22 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 		return false;
 	}
 
-	dma_len -= MLX5E_XDP_MIN_INLINE;
 	dma_sync_single_for_device(sq->pdev, dma_addr, dma_len,
 				   PCI_DMA_TODEVICE);
 
 	memset(wqe, 0, sizeof(*wqe));
 
-	/* copy the inline part */
-	memcpy(eseg->inline_hdr.start, xdp->data, MLX5E_XDP_MIN_INLINE);
-	eseg->inline_hdr.sz = cpu_to_be16(MLX5E_XDP_MIN_INLINE);
+	dseg = (struct mlx5_wqe_data_seg *)eseg + 1;
+	/* copy the inline part if required */
+	if (sq->min_inline_mode != MLX5_INLINE_MODE_NONE) {
+		memcpy(eseg->inline_hdr.start, xdp->data, MLX5E_XDP_MIN_INLINE);
+		eseg->inline_hdr.sz = cpu_to_be16(MLX5E_XDP_MIN_INLINE);
+		dma_len  -= MLX5E_XDP_MIN_INLINE;
+		dma_addr += MLX5E_XDP_MIN_INLINE;
 
-	dseg = (struct mlx5_wqe_data_seg *)cseg + (MLX5E_XDP_TX_DS_COUNT - 1);
+		ds_cnt   += MLX5E_XDP_IHS_DS_COUNT;
+		dseg++;
+	}
 
 	/* write the dma part */
 	dseg->addr       = cpu_to_be64(dma_addr);
@@ -698,7 +704,7 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 	dseg->lkey       = sq->mkey_be;
 
 	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | MLX5_OPCODE_SEND);
-	cseg->qpn_ds = cpu_to_be32((sq->sqn << 8) | MLX5E_XDP_TX_DS_COUNT);
+	cseg->qpn_ds = cpu_to_be32((sq->sqn << 8) | ds_cnt);
 
 	sq->db.xdp.di[pi] = *di;
 	wi->opcode     = MLX5_OPCODE_SEND;
-- 
2.11.0
