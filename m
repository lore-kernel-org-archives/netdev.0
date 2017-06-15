From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 03/10] net/mlx4_en: Improve receive data-path
Date: Thu, 15 Jun 2017 14:35:33 +0300
Message-ID: <1497526540-30028-4-git-send-email-tariqt@mellanox.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36075 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752393AbdFOLgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:36:25 -0400
In-Reply-To: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several small performance improvements in RX datapath,
including:
- Compiler branch predictor hints.
- Replace a multiplication with a shift operation.
- Minimize variables scope.
- Write-prefetch for packet header.
- Avoid trinary-operator ("?") when value can be preset in a matching
  branch.
- Save a branch by updating RX ring doorbell within
  mlx4_en_refill_rx_buffers(), which now returns void.

Performance tests:
Tested on ConnectX3Pro, Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
Single queue no-RSS optimization ON
(enable by ethtool -L <interface> rx 1).

XDP_DROP packet rate:
Same (28.1 Mpps), lower CPU utilization (from ~100% to ~92%).

Drop packets in TC:
-------------------------------------
     | Before    | After     | Gain |
IPv4 | 4.14 Mpps | 4.18 Mpps |   1% |
-------------------------------------

XDP_TX packet rate:
-------------------------------------
     | Before    | After     | Gain |
IPv4 | 10.1 Mpps | 10.3 Mpps |   2% |
IPv6 | 10.1 Mpps | 10.3 Mpps |   2% |
-------------------------------------

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 73 ++++++++++++++++--------------
 1 file changed, 39 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c4edae854f1b..507c48ef2674 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -134,10 +134,11 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 				   struct mlx4_en_rx_ring *ring, int index,
 				   gfp_t gfp)
 {
-	struct mlx4_en_rx_desc *rx_desc = ring->buf + (index * ring->stride);
+	struct mlx4_en_rx_desc *rx_desc = ring->buf +
+		(index << ring->log_stride);
 	struct mlx4_en_rx_alloc *frags = ring->rx_info +
 					(index << priv->log_rx_info);
-	if (ring->page_cache.index > 0) {
+	if (likely(ring->page_cache.index > 0)) {
 		/* XDP uses a single page per frame */
 		if (!frags->page) {
 			ring->page_cache.index--;
@@ -178,6 +179,7 @@ static void mlx4_en_free_rx_desc(const struct mlx4_en_priv *priv,
 	}
 }
 
+/* Function not in fast-path */
 static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
 {
 	struct mlx4_en_rx_ring *ring;
@@ -539,14 +541,14 @@ static void validate_loopback(struct mlx4_en_priv *priv, void *va)
 	priv->loopback_ok = 1;
 }
 
-static bool mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
+static void mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
 				      struct mlx4_en_rx_ring *ring)
 {
 	u32 missing = ring->actual_size - (ring->prod - ring->cons);
 
 	/* Try to batch allocations, but not too much. */
 	if (missing < 8)
-		return false;
+		return;
 	do {
 		if (mlx4_en_prepare_rx_desc(priv, ring,
 					    ring->prod & ring->size_mask,
@@ -554,9 +556,9 @@ static bool mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
 					    __GFP_MEMALLOC))
 			break;
 		ring->prod++;
-	} while (--missing);
+	} while (likely(--missing));
 
-	return true;
+	mlx4_en_update_rx_prod_db(ring);
 }
 
 /* When hardware doesn't strip the vlan, we need to calculate the checksum
@@ -637,21 +639,14 @@ static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
 int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int budget)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
-	struct mlx4_cqe *cqe;
-	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
-	struct mlx4_en_rx_alloc *frags;
+	int factor = priv->cqe_factor;
+	struct mlx4_en_rx_ring *ring;
 	struct bpf_prog *xdp_prog;
+	int cq_ring = cq->ring;
 	int doorbell_pending;
-	struct sk_buff *skb;
-	int index;
-	int nr;
-	unsigned int length;
+	struct mlx4_cqe *cqe;
 	int polled = 0;
-	int ip_summed;
-	int factor = priv->cqe_factor;
-	u64 timestamp;
-	bool l2_tunnel;
+	int index;
 
 	if (unlikely(!priv->port_up))
 		return 0;
@@ -659,6 +654,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	if (unlikely(budget <= 0))
 		return polled;
 
+	ring = priv->rx_ring[cq_ring];
+
 	/* Protect accesses to: ring->xdp_prog, priv->mac_hash list */
 	rcu_read_lock();
 	xdp_prog = rcu_dereference(ring->xdp_prog);
@@ -673,10 +670,17 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	/* Process all completed CQEs */
 	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
 		    cq->mcq.cons_index & cq->size)) {
+		struct mlx4_en_rx_alloc *frags;
+		enum pkt_hash_types hash_type;
+		struct sk_buff *skb;
+		unsigned int length;
+		int ip_summed;
 		void *va;
+		int nr;
 
 		frags = ring->rx_info + (index << priv->log_rx_info);
 		va = page_address(frags[0].page) + frags[0].page_offset;
+		prefetchw(va);
 		/*
 		 * make sure we read the CQE after we read the ownership bit
 		 */
@@ -768,7 +772,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				break;
 			case XDP_TX:
 				if (likely(!mlx4_en_xmit_frame(ring, frags, dev,
-							length, cq->ring,
+							length, cq_ring,
 							&doorbell_pending))) {
 					frags[0].page = NULL;
 					goto next;
@@ -790,24 +794,27 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		ring->packets++;
 
 		skb = napi_get_frags(&cq->napi);
-		if (!skb)
+		if (unlikely(!skb))
 			goto next;
 
 		if (unlikely(ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL)) {
-			timestamp = mlx4_en_get_cqe_ts(cqe);
-			mlx4_en_fill_hwtstamps(mdev, skb_hwtstamps(skb),
+			u64 timestamp = mlx4_en_get_cqe_ts(cqe);
+
+			mlx4_en_fill_hwtstamps(priv->mdev, skb_hwtstamps(skb),
 					       timestamp);
 		}
-		skb_record_rx_queue(skb, cq->ring);
+		skb_record_rx_queue(skb, cq_ring);
 
 		if (likely(dev->features & NETIF_F_RXCSUM)) {
 			if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_TCP |
 						      MLX4_CQE_STATUS_UDP)) {
 				if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
 				    cqe->checksum == cpu_to_be16(0xffff)) {
-					ip_summed = CHECKSUM_UNNECESSARY;
-					l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
+					bool l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
 						(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
+
+					ip_summed = CHECKSUM_UNNECESSARY;
+					hash_type = PKT_HASH_TYPE_L4;
 					if (l2_tunnel)
 						skb->csum_level = 1;
 					ring->csum_ok++;
@@ -822,6 +829,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 						goto csum_none;
 					} else {
 						ip_summed = CHECKSUM_COMPLETE;
+						hash_type = PKT_HASH_TYPE_L3;
 						ring->csum_complete++;
 					}
 				} else {
@@ -831,16 +839,14 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		} else {
 csum_none:
 			ip_summed = CHECKSUM_NONE;
+			hash_type = PKT_HASH_TYPE_L3;
 			ring->csum_none++;
 		}
 		skb->ip_summed = ip_summed;
 		if (dev->features & NETIF_F_RXHASH)
 			skb_set_hash(skb,
 				     be32_to_cpu(cqe->immed_rss_invalid),
-				     (ip_summed == CHECKSUM_UNNECESSARY) ?
-					PKT_HASH_TYPE_L4 :
-					PKT_HASH_TYPE_L3);
-
+				     hash_type);
 
 		if ((cqe->vlan_my_qpn &
 		     cpu_to_be32(MLX4_CQE_CVLAN_PRESENT_MASK)) &&
@@ -867,13 +873,13 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		++cq->mcq.cons_index;
 		index = (cq->mcq.cons_index) & ring->size_mask;
 		cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
-		if (++polled == budget)
+		if (unlikely(++polled == budget))
 			break;
 	}
 
 	rcu_read_unlock();
 
-	if (polled) {
+	if (likely(polled)) {
 		if (doorbell_pending)
 			mlx4_en_xmit_doorbell(priv->tx_ring[TX_XDP][cq->ring]);
 
@@ -883,8 +889,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	}
 	AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
 
-	if (mlx4_en_refill_rx_buffers(priv, ring))
-		mlx4_en_update_rx_prod_db(ring);
+	mlx4_en_refill_rx_buffers(priv, ring);
 
 	return polled;
 }
@@ -936,7 +941,7 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 			done--;
 	}
 	/* Done for now */
-	if (napi_complete_done(napi, done))
+	if (likely(napi_complete_done(napi, done)))
 		mlx4_en_arm_cq(priv, cq);
 	return done;
 }
-- 
1.8.3.1
