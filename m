From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v2] net/mlx5e: Support bpf_xdp_adjust_head()
Date: Tue, 17 Jan 2017 22:06:07 -0800
Message-ID: <1484719567-2774431-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44710 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750703AbdARGGM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 01:06:12 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v0I62b5i002068
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 22:06:11 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 281x0t8g2u-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 22:06:11 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 3433b34edd4411e6891b0002c9521c9e-94bf9a50 for <netdev@vger.kernel.org>;        Tue,
 17 Jan 2017 22:06:08 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds bpf_xdp_adjust_head() support to mlx5e.

1. rx_headroom is added to struct mlx5e_rq.  It uses
   an existing 4 byte hole in the struct.
2. The adjusted data length is checked against
   MLX5E_XDP_MIN_INLINE and MLX5E_SW2HW_MTU(rq->netdev->mtu).
3. The macro MLX5E_SW2HW_MTU is moved from en_main.c to en.h.
   MLX5E_HW2SW_MTU is also moved to en.h for symmetric reason
   but it is not a must.

v2:
- Keep the xdp specific logic in mlx5e_xdp_handle()
- Update dma_len after the sanity checks in mlx5e_xmit_xdp_frame()

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  4 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 18 ++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 47 ++++++++++++++---------
 3 files changed, 40 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index a473cea10c16..0d9dd860a295 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -51,6 +51,9 @@
 
 #define MLX5_SET_CFG(p, f, v) MLX5_SET(create_flow_group_in, p, f, v)
 
+#define MLX5E_HW2SW_MTU(hwmtu) ((hwmtu) - (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
+#define MLX5E_SW2HW_MTU(swmtu) ((swmtu) + (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
+
 #define MLX5E_MAX_NUM_TC	8
 
 #define MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE                0x6
@@ -369,6 +372,7 @@ struct mlx5e_rq {
 
 	unsigned long          state;
 	int                    ix;
+	u16                    rx_headroom;
 
 	struct mlx5e_rx_am     am; /* Adaptive Moderation */
 	struct bpf_prog       *xdp_prog;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f74ba73c55c7..aba3691e0919 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -343,9 +343,6 @@ static void mlx5e_disable_async_events(struct mlx5e_priv *priv)
 	synchronize_irq(mlx5_get_msix_vec(priv->mdev, MLX5_EQ_VEC_ASYNC));
 }
 
-#define MLX5E_HW2SW_MTU(hwmtu) (hwmtu - (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
-#define MLX5E_SW2HW_MTU(swmtu) (swmtu + (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
-
 static inline int mlx5e_get_wqe_mtt_sz(void)
 {
 	/* UMR copies MTTs in units of MLX5_UMR_MTT_ALIGNMENT bytes.
@@ -534,9 +531,13 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 		goto err_rq_wq_destroy;
 	}
 
-	rq->buff.map_dir = DMA_FROM_DEVICE;
-	if (rq->xdp_prog)
+	if (rq->xdp_prog) {
 		rq->buff.map_dir = DMA_BIDIRECTIONAL;
+		rq->rx_headroom = XDP_PACKET_HEADROOM;
+	} else {
+		rq->buff.map_dir = DMA_FROM_DEVICE;
+		rq->rx_headroom = MLX5_RX_HEADROOM;
+	}
 
 	switch (priv->params.rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
@@ -586,7 +587,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 		byte_count = rq->buff.wqe_sz;
 
 		/* calc the required page order */
-		frag_sz = MLX5_RX_HEADROOM +
+		frag_sz = rq->rx_headroom +
 			  byte_count /* packet data */ +
 			  SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 		frag_sz = SKB_DATA_ALIGN(frag_sz);
@@ -3153,11 +3154,6 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 	bool reset, was_opened;
 	int i;
 
-	if (prog && prog->xdp_adjust_head) {
-		netdev_err(netdev, "Does not support bpf_xdp_adjust_head()\n");
-		return -EOPNOTSUPP;
-	}
-
 	mutex_lock(&priv->state_lock);
 
 	if ((netdev->features & NETIF_F_LRO) && prog) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 0e2fb3ed1790..20f116f8c457 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -264,7 +264,7 @@ int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 	if (unlikely(mlx5e_page_alloc_mapped(rq, di)))
 		return -ENOMEM;
 
-	wqe->data.addr = cpu_to_be64(di->addr + MLX5_RX_HEADROOM);
+	wqe->data.addr = cpu_to_be64(di->addr + rq->rx_headroom);
 	return 0;
 }
 
@@ -646,8 +646,7 @@ static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
 
 static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 					struct mlx5e_dma_info *di,
-					unsigned int data_offset,
-					int len)
+					const struct xdp_buff *xdp)
 {
 	struct mlx5e_sq          *sq   = &rq->channel->xdp_sq;
 	struct mlx5_wq_cyc       *wq   = &sq->wq;
@@ -659,9 +658,16 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
 	struct mlx5_wqe_data_seg *dseg;
 
+	ptrdiff_t data_offset = xdp->data - xdp->data_hard_start;
 	dma_addr_t dma_addr  = di->addr + data_offset + MLX5E_XDP_MIN_INLINE;
-	unsigned int dma_len = len - MLX5E_XDP_MIN_INLINE;
-	void *data           = page_address(di->page) + data_offset;
+	unsigned int dma_len = xdp->data_end - xdp->data;
+
+	if (unlikely(dma_len < MLX5E_XDP_MIN_INLINE ||
+		     MLX5E_SW2HW_MTU(rq->netdev->mtu) < dma_len)) {
+		rq->stats.xdp_drop++;
+		mlx5e_page_release(rq, di, true);
+		return;
+	}
 
 	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_XDP_TX_WQEBBS))) {
 		if (sq->db.xdp.doorbell) {
@@ -674,13 +680,14 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 		return;
 	}
 
+	dma_len -= MLX5E_XDP_MIN_INLINE;
 	dma_sync_single_for_device(sq->pdev, dma_addr, dma_len,
 				   PCI_DMA_TODEVICE);
 
 	memset(wqe, 0, sizeof(*wqe));
 
 	/* copy the inline part */
-	memcpy(eseg->inline_hdr_start, data, MLX5E_XDP_MIN_INLINE);
+	memcpy(eseg->inline_hdr_start, xdp->data, MLX5E_XDP_MIN_INLINE);
 	eseg->inline_hdr_sz = cpu_to_be16(MLX5E_XDP_MIN_INLINE);
 
 	dseg = (struct mlx5_wqe_data_seg *)cseg + (MLX5E_XDP_TX_DS_COUNT - 1);
@@ -703,25 +710,29 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 }
 
 /* returns true if packet was consumed by xdp */
-static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
-				    const struct bpf_prog *prog,
-				    struct mlx5e_dma_info *di,
-				    void *data, u16 len)
+static inline int mlx5e_xdp_handle(struct mlx5e_rq *rq,
+				   struct mlx5e_dma_info *di,
+				   void *va, u16 *rx_headroom, u32 *len)
 {
+	const struct bpf_prog *prog = READ_ONCE(rq->xdp_prog);
 	struct xdp_buff xdp;
 	u32 act;
 
 	if (!prog)
 		return false;
 
-	xdp.data = data;
-	xdp.data_end = xdp.data + len;
+	xdp.data = va + *rx_headroom;
+	xdp.data_end = xdp.data + *len;
+	xdp.data_hard_start = va;
+
 	act = bpf_prog_run_xdp(prog, &xdp);
 	switch (act) {
 	case XDP_PASS:
+		*rx_headroom = xdp.data - xdp.data_hard_start;
+		*len = xdp.data_end - xdp.data;
 		return false;
 	case XDP_TX:
-		mlx5e_xmit_xdp_frame(rq, di, MLX5_RX_HEADROOM, len);
+		mlx5e_xmit_xdp_frame(rq, di, &xdp);
 		return true;
 	default:
 		bpf_warn_invalid_xdp_action(act);
@@ -740,15 +751,16 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 	struct mlx5e_dma_info *di;
 	struct sk_buff *skb;
 	void *va, *data;
+	u16 rx_headroom = rq->rx_headroom;
 	bool consumed;
 
 	di             = &rq->dma_info[wqe_counter];
 	va             = page_address(di->page);
-	data           = va + MLX5_RX_HEADROOM;
+	data           = va + rx_headroom;
 
 	dma_sync_single_range_for_cpu(rq->pdev,
 				      di->addr,
-				      MLX5_RX_HEADROOM,
+				      rx_headroom,
 				      rq->buff.wqe_sz,
 				      DMA_FROM_DEVICE);
 	prefetch(data);
@@ -760,8 +772,7 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 	}
 
 	rcu_read_lock();
-	consumed = mlx5e_xdp_handle(rq, READ_ONCE(rq->xdp_prog), di, data,
-				    cqe_bcnt);
+	consumed = mlx5e_xdp_handle(rq, di, va, &rx_headroom, &cqe_bcnt);
 	rcu_read_unlock();
 	if (consumed)
 		return NULL; /* page/packet was consumed by XDP */
@@ -777,7 +788,7 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 	page_ref_inc(di->page);
 	mlx5e_page_release(rq, di, true);
 
-	skb_reserve(skb, MLX5_RX_HEADROOM);
+	skb_reserve(skb, rx_headroom);
 	skb_put(skb, cqe_bcnt);
 
 	return skb;
-- 
2.5.1
