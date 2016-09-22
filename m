From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 6/9] net/mlx5e: Refactor retrival of skb from rx completion element (cqe)
Date: Thu, 22 Sep 2016 20:01:46 +0300
Message-ID: <1474563709-17943-7-git-send-email-saeedm@mellanox.com>
References: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirv@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48996 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S964998AbcIVRCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:02:16 -0400
In-Reply-To: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Factor the relevant code into a static inline helper (skb_from_cqe)
doing that.

Move the call to napi_gro_receive to be carried out just
after mlx5e_complete_rx_cqe returns.

Both changes are to be used for the VF representor as well
in the next commit.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 41 +++++++++++++++++--------
 1 file changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 0a81bd3..e836e47 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -629,7 +629,6 @@ static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
 	rq->stats.packets++;
 	rq->stats.bytes += cqe_bcnt;
 	mlx5e_build_rx_skb(cqe, cqe_bcnt, rq, skb);
-	napi_gro_receive(rq->cq.napi, skb);
 }
 
 static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
@@ -733,20 +732,15 @@ static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
 	}
 }
 
-void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
+static inline
+struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
+			     u16 wqe_counter, u32 cqe_bcnt)
 {
 	struct bpf_prog *xdp_prog = READ_ONCE(rq->xdp_prog);
 	struct mlx5e_dma_info *di;
-	struct mlx5e_rx_wqe *wqe;
-	__be16 wqe_counter_be;
 	struct sk_buff *skb;
-	u16 wqe_counter;
 	void *va, *data;
-	u32 cqe_bcnt;
 
-	wqe_counter_be = cqe->wqe_counter;
-	wqe_counter    = be16_to_cpu(wqe_counter_be);
-	wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
 	di             = &rq->dma_info[wqe_counter];
 	va             = page_address(di->page);
 	data           = va + MLX5_RX_HEADROOM;
@@ -757,22 +751,21 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 				      rq->buff.wqe_sz,
 				      DMA_FROM_DEVICE);
 	prefetch(data);
-	cqe_bcnt = be32_to_cpu(cqe->byte_cnt);
 
 	if (unlikely((cqe->op_own >> 4) != MLX5_CQE_RESP_SEND)) {
 		rq->stats.wqe_err++;
 		mlx5e_page_release(rq, di, true);
-		goto wq_ll_pop;
+		return NULL;
 	}
 
 	if (mlx5e_xdp_handle(rq, xdp_prog, di, data, cqe_bcnt))
-		goto wq_ll_pop; /* page/packet was consumed by XDP */
+		return NULL; /* page/packet was consumed by XDP */
 
 	skb = build_skb(va, RQ_PAGE_SIZE(rq));
 	if (unlikely(!skb)) {
 		rq->stats.buff_alloc_err++;
 		mlx5e_page_release(rq, di, true);
-		goto wq_ll_pop;
+		return NULL;
 	}
 
 	/* queue up for recycling ..*/
@@ -782,7 +775,28 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	skb_reserve(skb, MLX5_RX_HEADROOM);
 	skb_put(skb, cqe_bcnt);
 
+	return skb;
+}
+
+void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
+{
+	struct mlx5e_rx_wqe *wqe;
+	__be16 wqe_counter_be;
+	struct sk_buff *skb;
+	u16 wqe_counter;
+	u32 cqe_bcnt;
+
+	wqe_counter_be = cqe->wqe_counter;
+	wqe_counter    = be16_to_cpu(wqe_counter_be);
+	wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
+	cqe_bcnt       = be32_to_cpu(cqe->byte_cnt);
+
+	skb = skb_from_cqe(rq, cqe, wqe_counter, cqe_bcnt);
+	if (!skb)
+		goto wq_ll_pop;
+
 	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
+	napi_gro_receive(rq->cq.napi, skb);
 
 wq_ll_pop:
 	mlx5_wq_ll_pop(&rq->wq, wqe_counter_be,
@@ -861,6 +875,7 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 
 	mlx5e_mpwqe_fill_rx_skb(rq, cqe, wi, cqe_bcnt, skb);
 	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
+	napi_gro_receive(rq->cq.napi, skb);
 
 mpwrq_cqe_out:
 	if (likely(wi->consumed_strides < rq->mpwqe_num_strides))
-- 
2.7.4
