From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 05/12] net/mlx5e: Move mlx5e_rq struct declaration
Date: Sat, 25 Mar 2017 00:52:07 +0300
Message-ID: <20170324215214.25711-6-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35756 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936487AbdCXVwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:35 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move struct mlx5e_rq and friends to appear after mlx5e_sq declaration in
en.h.

We will need this for next patch to move the mlx5e_sq instance into
mlx5e_rq struct for XDP SQs.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h | 213 +++++++++++++--------------
 1 file changed, 105 insertions(+), 108 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index fce0eca0701c..8d789a25a1c0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -297,19 +297,113 @@ struct mlx5e_cq {
 	struct mlx5_frag_wq_ctrl   wq_ctrl;
 } ____cacheline_aligned_in_smp;
 
-struct mlx5e_rq;
-typedef void (*mlx5e_fp_handle_rx_cqe)(struct mlx5e_rq *rq,
-				       struct mlx5_cqe64 *cqe);
-typedef int (*mlx5e_fp_alloc_wqe)(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,
-				  u16 ix);
+struct mlx5e_tx_wqe_info {
+	u32 num_bytes;
+	u8  num_wqebbs;
+	u8  num_dma;
+};
+
+enum mlx5e_dma_map_type {
+	MLX5E_DMA_MAP_SINGLE,
+	MLX5E_DMA_MAP_PAGE
+};
+
+struct mlx5e_sq_dma {
+	dma_addr_t              addr;
+	u32                     size;
+	enum mlx5e_dma_map_type type;
+};
+
+enum {
+	MLX5E_SQ_STATE_ENABLED,
+};
+
+struct mlx5e_sq_wqe_info {
+	u8  opcode;
+	u8  num_wqebbs;
+};
 
-typedef void (*mlx5e_fp_dealloc_wqe)(struct mlx5e_rq *rq, u16 ix);
+enum mlx5e_sq_type {
+	MLX5E_SQ_TXQ,
+	MLX5E_SQ_ICO,
+	MLX5E_SQ_XDP
+};
+
+struct mlx5e_sq {
+	/* data path */
+
+	/* dirtied @completion */
+	u16                        cc;
+	u32                        dma_fifo_cc;
+
+	/* dirtied @xmit */
+	u16                        pc ____cacheline_aligned_in_smp;
+	u32                        dma_fifo_pc;
+	struct mlx5e_sq_stats      stats;
+
+	struct mlx5e_cq            cq;
+
+	/* pointers to per tx element info: write@xmit, read@completion */
+	union {
+		struct {
+			struct sk_buff           **skb;
+			struct mlx5e_sq_dma       *dma_fifo;
+			struct mlx5e_tx_wqe_info  *wqe_info;
+		} txq;
+		struct mlx5e_sq_wqe_info *ico_wqe;
+		struct {
+			struct mlx5e_sq_wqe_info  *wqe_info;
+			struct mlx5e_dma_info     *di;
+			bool                       doorbell;
+		} xdp;
+	} db;
+
+	/* read only */
+	struct mlx5_wq_cyc         wq;
+	u32                        dma_fifo_mask;
+	void __iomem              *uar_map;
+	struct netdev_queue       *txq;
+	u32                        sqn;
+	u16                        max_inline;
+	u8                         min_inline_mode;
+	u16                        edge;
+	struct device             *pdev;
+	struct mlx5e_tstamp       *tstamp;
+	__be32                     mkey_be;
+	unsigned long              state;
+
+	/* control path */
+	struct mlx5_wq_ctrl        wq_ctrl;
+	struct mlx5e_channel      *channel;
+	int                        tc;
+	u32                        rate_limit;
+	u8                         type;
+} ____cacheline_aligned_in_smp;
+
+static inline bool mlx5e_sq_has_room_for(struct mlx5e_sq *sq, u16 n)
+{
+	return (((sq->wq.sz_m1 & (sq->cc - sq->pc)) >= n) ||
+		(sq->cc  == sq->pc));
+}
 
 struct mlx5e_dma_info {
 	struct page	*page;
 	dma_addr_t	addr;
 };
 
+struct mlx5e_umr_dma_info {
+	__be64                *mtt;
+	dma_addr_t             mtt_addr;
+	struct mlx5e_dma_info  dma_info[MLX5_MPWRQ_PAGES_PER_WQE];
+	struct mlx5e_umr_wqe   wqe;
+};
+
+struct mlx5e_mpw_info {
+	struct mlx5e_umr_dma_info umr;
+	u16 consumed_strides;
+	u16 skbs_frags[MLX5_MPWRQ_PAGES_PER_WQE];
+};
+
 struct mlx5e_rx_am_stats {
 	int ppms; /* packets per msec */
 	int epms; /* events per msec */
@@ -346,6 +440,11 @@ struct mlx5e_page_cache {
 	struct mlx5e_dma_info page_cache[MLX5E_CACHE_SIZE];
 };
 
+struct mlx5e_rq;
+typedef void (*mlx5e_fp_handle_rx_cqe)(struct mlx5e_rq*, struct mlx5_cqe64*);
+typedef int (*mlx5e_fp_alloc_wqe)(struct mlx5e_rq*, struct mlx5e_rx_wqe*, u16);
+typedef void (*mlx5e_fp_dealloc_wqe)(struct mlx5e_rq*, u16);
+
 struct mlx5e_rq {
 	/* data path */
 	struct mlx5_wq_ll      wq;
@@ -393,108 +492,6 @@ struct mlx5e_rq {
 	struct mlx5_core_mkey  umr_mkey;
 } ____cacheline_aligned_in_smp;
 
-struct mlx5e_umr_dma_info {
-	__be64                *mtt;
-	dma_addr_t             mtt_addr;
-	struct mlx5e_dma_info  dma_info[MLX5_MPWRQ_PAGES_PER_WQE];
-	struct mlx5e_umr_wqe   wqe;
-};
-
-struct mlx5e_mpw_info {
-	struct mlx5e_umr_dma_info umr;
-	u16 consumed_strides;
-	u16 skbs_frags[MLX5_MPWRQ_PAGES_PER_WQE];
-};
-
-struct mlx5e_tx_wqe_info {
-	u32 num_bytes;
-	u8  num_wqebbs;
-	u8  num_dma;
-};
-
-enum mlx5e_dma_map_type {
-	MLX5E_DMA_MAP_SINGLE,
-	MLX5E_DMA_MAP_PAGE
-};
-
-struct mlx5e_sq_dma {
-	dma_addr_t              addr;
-	u32                     size;
-	enum mlx5e_dma_map_type type;
-};
-
-enum {
-	MLX5E_SQ_STATE_ENABLED,
-};
-
-struct mlx5e_sq_wqe_info {
-	u8  opcode;
-	u8  num_wqebbs;
-};
-
-enum mlx5e_sq_type {
-	MLX5E_SQ_TXQ,
-	MLX5E_SQ_ICO,
-	MLX5E_SQ_XDP
-};
-
-struct mlx5e_sq {
-	/* data path */
-
-	/* dirtied @completion */
-	u16                        cc;
-	u32                        dma_fifo_cc;
-
-	/* dirtied @xmit */
-	u16                        pc ____cacheline_aligned_in_smp;
-	u32                        dma_fifo_pc;
-	struct mlx5e_sq_stats      stats;
-
-	struct mlx5e_cq            cq;
-
-	/* pointers to per tx element info: write@xmit, read@completion */
-	union {
-		struct {
-			struct sk_buff           **skb;
-			struct mlx5e_sq_dma       *dma_fifo;
-			struct mlx5e_tx_wqe_info  *wqe_info;
-		} txq;
-		struct mlx5e_sq_wqe_info *ico_wqe;
-		struct {
-			struct mlx5e_sq_wqe_info  *wqe_info;
-			struct mlx5e_dma_info     *di;
-			bool                       doorbell;
-		} xdp;
-	} db;
-
-	/* read only */
-	struct mlx5_wq_cyc         wq;
-	u32                        dma_fifo_mask;
-	void __iomem              *uar_map;
-	struct netdev_queue       *txq;
-	u32                        sqn;
-	u16                        max_inline;
-	u8                         min_inline_mode;
-	u16                        edge;
-	struct device             *pdev;
-	struct mlx5e_tstamp       *tstamp;
-	__be32                     mkey_be;
-	unsigned long              state;
-
-	/* control path */
-	struct mlx5_wq_ctrl        wq_ctrl;
-	struct mlx5e_channel      *channel;
-	int                        tc;
-	u32                        rate_limit;
-	u8                         type;
-} ____cacheline_aligned_in_smp;
-
-static inline bool mlx5e_sq_has_room_for(struct mlx5e_sq *sq, u16 n)
-{
-	return (((sq->wq.sz_m1 & (sq->cc - sq->pc)) >= n) ||
-		(sq->cc  == sq->pc));
-}
-
 enum channel_flags {
 	MLX5E_CHANNEL_NAPI_SCHED = 1,
 };
-- 
2.11.0
