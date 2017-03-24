From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 02/12] net/mlx5e: Xmit, no write combining
Date: Sat, 25 Mar 2017 00:52:04 +0300
Message-ID: <20170324215214.25711-3-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35745 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936485AbdCXVwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:35 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx5e netdev Blue Flame (write combining) support demands a lot of
overhead for a little latency gain for some special cases, this overhead
is hurting the common case.

Here we remove xmit Blue Flame support by creating all bfregs with no
write combining for all SQs, and we remove a lot of BF logic and
conditions from xmit data path.

Simplify mlx5e_tx_notify_hw (doorbell function) by removing BF related
code and by removing one memory barrier needed for WC mapped SQ doorbell
buffers, which no longer exist.

Performance improvement:
System: Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz

Test case                   Before      Now      improvement
---------------------------------------------------------------
TX packets (24 threads)     50Mpps      54Mpps    8%

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 20 ++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  6 +---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  4 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 42 ++---------------------
 4 files changed, 9 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index dc52053128bc..85261e9ccf4a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -111,7 +111,6 @@
 #define MLX5E_MAX_NUM_SQS              (MLX5E_MAX_NUM_CHANNELS * MLX5E_MAX_NUM_TC)
 #define MLX5E_TX_CQ_POLL_BUDGET        128
 #define MLX5E_UPDATE_STATS_INTERVAL    200 /* msecs */
-#define MLX5E_SQ_BF_BUDGET             16
 
 #define MLX5E_ICOSQ_MAX_WQEBBS \
 	(DIV_ROUND_UP(sizeof(struct mlx5e_umr_wqe), MLX5_SEND_WQE_BB))
@@ -426,7 +425,6 @@ struct mlx5e_sq_dma {
 
 enum {
 	MLX5E_SQ_STATE_ENABLED,
-	MLX5E_SQ_STATE_BF_ENABLE,
 };
 
 struct mlx5e_sq_wqe_info {
@@ -450,9 +448,6 @@ struct mlx5e_sq {
 	/* dirtied @xmit */
 	u16                        pc ____cacheline_aligned_in_smp;
 	u32                        dma_fifo_pc;
-	u16                        bf_offset;
-	u16                        prev_cc;
-	u8                         bf_budget;
 	struct mlx5e_sq_stats      stats;
 
 	struct mlx5e_cq            cq;
@@ -478,7 +473,6 @@ struct mlx5e_sq {
 	void __iomem              *uar_map;
 	struct netdev_queue       *txq;
 	u32                        sqn;
-	u16                        bf_buf_size;
 	u16                        max_inline;
 	u8                         min_inline_mode;
 	u16                        edge;
@@ -818,11 +812,9 @@ void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params,
 				 u8 cq_period_mode);
 void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type);
 
-static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
-				      struct mlx5_wqe_ctrl_seg *ctrl, int bf_sz)
+static inline void
+mlx5e_tx_notify_hw(struct mlx5e_sq *sq, struct mlx5_wqe_ctrl_seg *ctrl)
 {
-	u16 ofst = sq->bf_offset;
-
 	/* ensure wqe is visible to device before updating doorbell record */
 	dma_wmb();
 
@@ -832,14 +824,8 @@ static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 	 * doorbell
 	 */
 	wmb();
-	if (bf_sz)
-		__iowrite64_copy(sq->uar_map + ofst, ctrl, bf_sz);
-	else
-		mlx5_write64((__be32 *)ctrl, sq->uar_map + ofst, NULL);
-	/* flush the write-combining mapped buffer */
-	wmb();
 
-	sq->bf_offset ^= sq->bf_buf_size;
+	mlx5_write64((__be32 *)ctrl, sq->uar_map, NULL);
 }
 
 static inline void mlx5e_cq_arm(struct mlx5e_cq *cq)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index ddd7464c6b45..f9bcbd277adb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1017,7 +1017,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	sq->channel   = c;
 	sq->tc        = tc;
 
-	err = mlx5_alloc_bfreg(mdev, &sq->bfreg, MLX5_CAP_GEN(mdev, bf), false);
+	err = mlx5_alloc_bfreg(mdev, &sq->bfreg, false, false);
 	if (err)
 		return err;
 
@@ -1030,10 +1030,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 		goto err_unmap_free_uar;
 
 	sq->wq.db       = &sq->wq.db[MLX5_SND_DBR];
-	if (sq->bfreg.wc)
-		set_bit(MLX5E_SQ_STATE_BF_ENABLE, &sq->state);
 
-	sq->bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
 	sq->max_inline  = param->max_inline;
 	sq->min_inline_mode = param->min_inline_mode;
 
@@ -1050,7 +1047,6 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	}
 
 	sq->edge = (sq->wq.sz_m1 + 1) - mlx5e_sq_get_max_wqebbs(sq->type);
-	sq->bf_budget = MLX5E_SQ_BF_BUDGET;
 
 	return 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index bafcb349a50c..873b3085756c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -353,7 +353,7 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 	sq->db.ico_wqe[pi].opcode = MLX5_OPCODE_UMR;
 	sq->db.ico_wqe[pi].num_wqebbs = num_wqebbs;
 	sq->pc += num_wqebbs;
-	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
+	mlx5e_tx_notify_hw(sq, &wqe->ctrl);
 }
 
 static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
@@ -646,7 +646,7 @@ static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
 	wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
 
 	wqe->ctrl.fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
+	mlx5e_tx_notify_hw(sq, &wqe->ctrl);
 }
 
 static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 57f5e2d7ebd1..eec4354208ee 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -57,7 +57,7 @@ void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
 
 	if (notify_hw) {
 		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-		mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
+		mlx5e_tx_notify_hw(sq, &wqe->ctrl);
 	}
 }
 
@@ -175,25 +175,6 @@ static inline unsigned int mlx5e_calc_min_inline(enum mlx5_inline_modes mode,
 	}
 }
 
-static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
-					    struct sk_buff *skb, bool bf)
-{
-	/* Some NIC TX decisions, e.g loopback, are based on the packet
-	 * headers and occur before the data gather.
-	 * Therefore these headers must be copied into the WQE
-	 */
-	if (bf) {
-		u16 ihs = skb_headlen(skb);
-
-		if (skb_vlan_tag_present(skb))
-			ihs += VLAN_HLEN;
-
-		if (ihs <= sq->max_inline)
-			return skb_headlen(skb);
-	}
-	return mlx5e_calc_min_inline(sq->min_inline_mode, skb);
-}
-
 static inline void mlx5e_tx_skb_pull_inline(unsigned char **skb_data,
 					    unsigned int *skb_len,
 					    unsigned int len)
@@ -235,7 +216,6 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	u8  opcode = MLX5_OPCODE_SEND;
 	dma_addr_t dma_addr = 0;
 	unsigned int num_bytes;
-	bool bf = false;
 	u16 headlen;
 	u16 ds_cnt;
 	u16 ihs;
@@ -255,11 +235,6 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	} else
 		sq->stats.csum_none++;
 
-	if (sq->cc != sq->prev_cc) {
-		sq->prev_cc = sq->cc;
-		sq->bf_budget = (sq->cc == sq->pc) ? MLX5E_SQ_BF_BUDGET : 0;
-	}
-
 	if (skb_is_gso(skb)) {
 		eseg->mss    = cpu_to_be16(skb_shinfo(skb)->gso_size);
 		opcode       = MLX5_OPCODE_LSO;
@@ -277,10 +252,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		sq->stats.packets += skb_shinfo(skb)->gso_segs;
 		num_bytes = skb->len + (skb_shinfo(skb)->gso_segs - 1) * ihs;
 	} else {
-		bf = sq->bf_budget &&
-		     !skb->xmit_more &&
-		     !skb_shinfo(skb)->nr_frags;
-		ihs = mlx5e_get_inline_hdr_size(sq, skb, bf);
+		ihs = mlx5e_calc_min_inline(sq->min_inline_mode, skb);
 		sq->stats.packets++;
 		num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
 	}
@@ -366,13 +338,8 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	sq->stats.xmit_more += skb->xmit_more;
 	if (!skb->xmit_more || netif_xmit_stopped(sq->txq)) {
-		int bf_sz = 0;
-
-		if (bf && test_bit(MLX5E_SQ_STATE_BF_ENABLE, &sq->state))
-			bf_sz = wi->num_wqebbs << 3;
-
 		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-		mlx5e_tx_notify_hw(sq, &wqe->ctrl, bf_sz);
+		mlx5e_tx_notify_hw(sq, &wqe->ctrl);
 	}
 
 	/* fill sq edge with nops to avoid wqe wrap around */
@@ -381,9 +348,6 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		mlx5e_send_nop(sq, false);
 	}
 
-	if (bf)
-		sq->bf_budget--;
-
 	return NETDEV_TX_OK;
 
 dma_unmap_wqe_err:
-- 
2.11.0
