From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH 5/5] mlx5: add XDP rxhash feature for driver
 mlx5
Date: Thu, 18 May 2017 17:41:53 +0200
Message-ID: <149512211338.14733.1908296344857176060.stgit@firesoul>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43606 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933863AbdERPl5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 11:41:57 -0400
In-Reply-To: <149512205297.14733.15729847433404265933.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   98 ++++++++++++++-------
 2 files changed, 70 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e43411d232ee..3ae90dbdd3de 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3956,6 +3956,9 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
+	/* XDP_DRV_F_ENABLED is added in register_netdevice() */
+	netdev->xdp_features = XDP_DRV_F_RXHASH;
+
 	if (mlx5e_vxlan_allowed(mdev)) {
 		netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL |
 					   NETIF_F_GSO_UDP_TUNNEL_CSUM |
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index ae66fad98244..eb9d859bf09d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -514,14 +514,28 @@ static void mlx5e_lro_update_hdr(struct sk_buff *skb, struct mlx5_cqe64 *cqe,
 	}
 }
 
-static inline void mlx5e_skb_set_hash(struct mlx5_cqe64 *cqe,
-				      struct sk_buff *skb)
+u8 mlx5_htype_l3_to_xdp[4] = {
+	0,			/* 00 - none */
+	XDP_HASH_TYPE_L3_IPV4,	/* 01 - IPv4 */
+	XDP_HASH_TYPE_L3_IPV6,	/* 10 - IPv6 */
+	0,			/* 11 - Reserved */
+};
+
+u8 mlx5_htype_l4_to_xdp[4] = {
+	0,			/* 00 - none */
+	XDP_HASH_TYPE_L4_TCP,	/* 01 - TCP  */
+	XDP_HASH_TYPE_L4_UDP,	/* 10 - UDP  */
+	0,			/* 11 - IPSEC.SPI */
+};
+
+static inline void mlx5e_xdp_set_hash(struct mlx5_cqe64 *cqe,
+				      struct xdp_buff *xdp)
 {
 	u8 cht = cqe->rss_hash_type;
-	int ht = (cht & CQE_RSS_HTYPE_L4) ? PKT_HASH_TYPE_L4 :
-		 (cht & CQE_RSS_HTYPE_IP) ? PKT_HASH_TYPE_L3 :
-					    PKT_HASH_TYPE_NONE;
-	skb_set_hash(skb, be32_to_cpu(cqe->rss_hash_result), ht);
+	u32 ht = (mlx5_htype_l4_to_xdp[((cht & CQE_RSS_HTYPE_L4) >> 6)] | \
+		  mlx5_htype_l3_to_xdp[((cht & CQE_RSS_HTYPE_IP) >> 2)]);
+
+	xdp_record_hash(xdp, be32_to_cpu(cqe->rss_hash_result), ht);
 }
 
 static inline bool is_first_ethertype_ip(struct sk_buff *skb)
@@ -570,7 +584,8 @@ static inline void mlx5e_handle_csum(struct net_device *netdev,
 static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 				      u32 cqe_bcnt,
 				      struct mlx5e_rq *rq,
-				      struct sk_buff *skb)
+				      struct sk_buff *skb,
+				      struct xdp_buff *xdp)
 {
 	struct net_device *netdev = rq->netdev;
 	struct mlx5e_tstamp *tstamp = rq->tstamp;
@@ -593,8 +608,7 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 
 	skb_record_rx_queue(skb, rq->ix);
 
-	if (likely(netdev->features & NETIF_F_RXHASH))
-		mlx5e_skb_set_hash(cqe, skb);
+	xdp_set_skb_hash(xdp, skb);
 
 	if (cqe_has_vlan(cqe))
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
@@ -609,11 +623,12 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
 					 struct mlx5_cqe64 *cqe,
 					 u32 cqe_bcnt,
-					 struct sk_buff *skb)
+					 struct sk_buff *skb,
+					 struct xdp_buff *xdp)
 {
 	rq->stats.packets++;
 	rq->stats.bytes += cqe_bcnt;
-	mlx5e_build_rx_skb(cqe, cqe_bcnt, rq, skb);
+	mlx5e_build_rx_skb(cqe, cqe_bcnt, rq, skb, xdp);
 }
 
 static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_xdpsq *sq)
@@ -696,27 +711,27 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 /* returns true if packet was consumed by xdp */
 static inline int mlx5e_xdp_handle(struct mlx5e_rq *rq,
 				   struct mlx5e_dma_info *di,
-				   void *va, u16 *rx_headroom, u32 *len)
+				   struct xdp_buff *xdp, void *va,
+				   u16 *rx_headroom, u32 *len)
 {
 	const struct bpf_prog *prog = READ_ONCE(rq->xdp_prog);
-	struct xdp_buff xdp;
 	u32 act;
 
 	if (!prog)
 		return false;
 
-	xdp.data = va + *rx_headroom;
-	xdp.data_end = xdp.data + *len;
-	xdp.data_hard_start = va;
+	xdp->data = va + *rx_headroom;
+	xdp->data_end = xdp->data + *len;
+	xdp->data_hard_start = va;
 
-	act = bpf_prog_run_xdp(prog, &xdp);
+	act = bpf_prog_run_xdp(prog, xdp);
 	switch (act) {
 	case XDP_PASS:
-		*rx_headroom = xdp.data - xdp.data_hard_start;
-		*len = xdp.data_end - xdp.data;
+		*rx_headroom = xdp->data - xdp->data_hard_start;
+		*len = xdp->data_end - xdp->data;
 		return false;
 	case XDP_TX:
-		if (unlikely(!mlx5e_xmit_xdp_frame(rq, di, &xdp)))
+		if (unlikely(!mlx5e_xmit_xdp_frame(rq, di, xdp)))
 			trace_xdp_exception(rq->netdev, prog, act);
 		return true;
 	default:
@@ -731,7 +746,22 @@ static inline int mlx5e_xdp_handle(struct mlx5e_rq *rq,
 }
 
 static inline
+void mlx5_fill_xdp_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
+			    struct xdp_buff *xdp)
+{
+	struct net_device *netdev = rq->netdev;
+
+	xdp->flags = 0;
+
+	if (likely(netdev->features & NETIF_F_RXHASH))
+		mlx5e_xdp_set_hash(cqe, xdp);
+	else
+		xdp->rxhash=0; /* Due to bpf direct read */
+}
+
+static inline
 struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
+			     struct xdp_buff *xdp,
 			     u16 wqe_counter, u32 cqe_bcnt)
 {
 	struct mlx5e_dma_info *di;
@@ -756,9 +786,10 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 		mlx5e_page_release(rq, di, true);
 		return NULL;
 	}
+	mlx5_fill_xdp_rx_cqe(rq, cqe, xdp);
 
 	rcu_read_lock();
-	consumed = mlx5e_xdp_handle(rq, di, va, &rx_headroom, &cqe_bcnt);
+	consumed = mlx5e_xdp_handle(rq, di, xdp, va, &rx_headroom, &cqe_bcnt);
 	rcu_read_unlock();
 	if (consumed)
 		return NULL; /* page/packet was consumed by XDP */
@@ -784,6 +815,7 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 {
 	struct mlx5e_rx_wqe *wqe;
 	__be16 wqe_counter_be;
+	struct xdp_buff xdp;
 	struct sk_buff *skb;
 	u16 wqe_counter;
 	u32 cqe_bcnt;
@@ -793,11 +825,11 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
 	cqe_bcnt       = be32_to_cpu(cqe->byte_cnt);
 
-	skb = skb_from_cqe(rq, cqe, wqe_counter, cqe_bcnt);
+	skb = skb_from_cqe(rq, cqe, &xdp, wqe_counter, cqe_bcnt);
 	if (!skb)
 		goto wq_ll_pop;
 
-	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
+	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb, &xdp);
 	napi_gro_receive(rq->cq.napi, skb);
 
 wq_ll_pop:
@@ -811,6 +843,7 @@ void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_eswitch_rep *rep = priv->ppriv;
 	struct mlx5e_rx_wqe *wqe;
+	struct xdp_buff xdp;
 	struct sk_buff *skb;
 	__be16 wqe_counter_be;
 	u16 wqe_counter;
@@ -821,11 +854,11 @@ void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
 	cqe_bcnt       = be32_to_cpu(cqe->byte_cnt);
 
-	skb = skb_from_cqe(rq, cqe, wqe_counter, cqe_bcnt);
+	skb = skb_from_cqe(rq, cqe, &xdp, wqe_counter, cqe_bcnt);
 	if (!skb)
 		goto wq_ll_pop;
 
-	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
+	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb, &xdp);
 
 	if (rep->vlan && skb_vlan_tag_present(skb))
 		skb_vlan_pop(skb);
@@ -882,6 +915,7 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	struct mlx5e_mpw_info *wi = &rq->mpwqe.info[wqe_id];
 	struct mlx5e_rx_wqe  *wqe = mlx5_wq_ll_get_wqe(&rq->wq, wqe_id);
 	struct sk_buff *skb;
+	struct xdp_buff xdp;
 	u16 cqe_bcnt;
 
 	wi->consumed_strides += cstrides;
@@ -906,9 +940,10 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 
 	prefetch(skb->data);
 	cqe_bcnt = mpwrq_get_cqe_byte_cnt(cqe);
+	mlx5_fill_xdp_rx_cqe(rq, cqe, &xdp);
 
 	mlx5e_mpwqe_fill_rx_skb(rq, cqe, wi, cqe_bcnt, skb);
-	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
+	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb, &xdp);
 	napi_gro_receive(rq->cq.napi, skb);
 
 mpwrq_cqe_out:
@@ -1043,7 +1078,8 @@ void mlx5e_free_xdpsq_descs(struct mlx5e_xdpsq *sq)
 static inline void mlx5i_complete_rx_cqe(struct mlx5e_rq *rq,
 					 struct mlx5_cqe64 *cqe,
 					 u32 cqe_bcnt,
-					 struct sk_buff *skb)
+					 struct sk_buff *skb,
+					 struct xdp_buff *xdp)
 {
 	struct net_device *netdev = rq->netdev;
 	u8 *dgid;
@@ -1071,8 +1107,7 @@ static inline void mlx5i_complete_rx_cqe(struct mlx5e_rq *rq,
 
 	skb_record_rx_queue(skb, rq->ix);
 
-	if (likely(netdev->features & NETIF_F_RXHASH))
-		mlx5e_skb_set_hash(cqe, skb);
+	xdp_set_skb_hash(xdp, skb);
 
 	skb_reset_mac_header(skb);
 	skb_pull(skb, MLX5_IPOIB_ENCAP_LEN);
@@ -1088,6 +1123,7 @@ void mlx5i_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 {
 	struct mlx5e_rx_wqe *wqe;
 	__be16 wqe_counter_be;
+	struct xdp_buff xdp;
 	struct sk_buff *skb;
 	u16 wqe_counter;
 	u32 cqe_bcnt;
@@ -1097,11 +1133,11 @@ void mlx5i_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
 	cqe_bcnt       = be32_to_cpu(cqe->byte_cnt);
 
-	skb = skb_from_cqe(rq, cqe, wqe_counter, cqe_bcnt);
+	skb = skb_from_cqe(rq, cqe, &xdp, wqe_counter, cqe_bcnt);
 	if (!skb)
 		goto wq_ll_pop;
 
-	mlx5i_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
+	mlx5i_complete_rx_cqe(rq, cqe, cqe_bcnt, skb, &xdp);
 	napi_gro_receive(rq->cq.napi, skb);
 
 wq_ll_pop:
