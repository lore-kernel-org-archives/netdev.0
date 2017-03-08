From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v4 net-next 13/13] mlx4: remove duplicate code in mlx4_en_process_rx_cq()
Date: Wed,  8 Mar 2017 08:17:18 -0800
Message-ID: <20170308161718.2867-14-edumazet@google.com>
References: <20170308161718.2867-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36785 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753855AbdCHQR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:17:58 -0500
Received: by mail-pf0-f178.google.com with SMTP id o126so16575848pfb.3
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:17:58 -0800 (PST)
In-Reply-To: <20170308161718.2867-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should keep one way to build skbs, regardless of GRO being on or off.

Note that I made sure to defer as much as possible the point we need to
pull data from the frame, so that future prefetch() we might add
are more effective.

These skb attributes derive from the CQE or ring :
 ip_summed, csum
 hash
 vlan offload
 hwtstamps
 queue_mapping

As a bonus, this patch removes mlx4 dependency on eth_get_headlen()
which is very often broken enough to give us headaches.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 209 ++++++-----------------------
 1 file changed, 41 insertions(+), 168 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 33b28278c8270197c5a8f35521fd2af5e1e6b1be..aa074e57ce06fb2842fa1faabd156c3cd2fe10f5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -526,64 +526,6 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 	return 0;
 }
 
-
-static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
-				      struct mlx4_en_rx_alloc *frags,
-				      unsigned int length)
-{
-	struct sk_buff *skb;
-	void *va;
-	int used_frags;
-	dma_addr_t dma;
-
-	skb = netdev_alloc_skb(priv->dev, SMALL_PACKET_SIZE + NET_IP_ALIGN);
-	if (unlikely(!skb)) {
-		en_dbg(RX_ERR, priv, "Failed allocating skb\n");
-		return NULL;
-	}
-	skb_reserve(skb, NET_IP_ALIGN);
-	skb->len = length;
-
-	/* Get pointer to first fragment so we could copy the headers into the
-	 * (linear part of the) skb */
-	va = page_address(frags[0].page) + frags[0].page_offset;
-
-	if (length <= SMALL_PACKET_SIZE) {
-		/* We are copying all relevant data to the skb - temporarily
-		 * sync buffers for the copy */
-
-		dma = frags[0].dma + frags[0].page_offset;
-		dma_sync_single_for_cpu(priv->ddev, dma, length,
-					DMA_FROM_DEVICE);
-		skb_copy_to_linear_data(skb, va, length);
-		skb->tail += length;
-	} else {
-		unsigned int pull_len;
-
-		/* Move relevant fragments to skb */
-		used_frags = mlx4_en_complete_rx_desc(priv, frags,
-							skb, length);
-		if (unlikely(!used_frags)) {
-			kfree_skb(skb);
-			return NULL;
-		}
-		skb_shinfo(skb)->nr_frags = used_frags;
-
-		pull_len = eth_get_headlen(va, SMALL_PACKET_SIZE);
-		/* Copy headers into the skb linear buffer */
-		memcpy(skb->data, va, pull_len);
-		skb->tail += pull_len;
-
-		/* Skip headers in first fragment */
-		skb_shinfo(skb)->frags[0].page_offset += pull_len;
-
-		/* Adjust size of first fragment */
-		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], pull_len);
-		skb->data_len = length - pull_len;
-	}
-	return skb;
-}
-
 static void validate_loopback(struct mlx4_en_priv *priv, void *va)
 {
 	const unsigned char *data = va + ETH_HLEN;
@@ -792,8 +734,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		 */
 		length = be32_to_cpu(cqe->byte_cnt);
 		length -= ring->fcs_del;
-		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
-			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
 
 		/* A bpf program gets first chance to drop the packet. It may
 		 * read bytes but not past the end of the frag.
@@ -849,122 +789,51 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		ring->bytes += length;
 		ring->packets++;
 
+		skb = napi_get_frags(&cq->napi);
+		if (!skb)
+			goto next;
+
+		if (unlikely(ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL)) {
+			timestamp = mlx4_en_get_cqe_ts(cqe);
+			mlx4_en_fill_hwtstamps(mdev, skb_hwtstamps(skb),
+					       timestamp);
+		}
+		skb_record_rx_queue(skb, cq->ring);
+
 		if (likely(dev->features & NETIF_F_RXCSUM)) {
 			if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_TCP |
 						      MLX4_CQE_STATUS_UDP)) {
 				if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
 				    cqe->checksum == cpu_to_be16(0xffff)) {
 					ip_summed = CHECKSUM_UNNECESSARY;
+					l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
+						(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
+					if (l2_tunnel)
+						skb->csum_level = 1;
 					ring->csum_ok++;
 				} else {
-					ip_summed = CHECKSUM_NONE;
-					ring->csum_none++;
+					goto csum_none;
 				}
 			} else {
 				if (priv->flags & MLX4_EN_FLAG_RX_CSUM_NON_TCP_UDP &&
 				    (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV4 |
 							       MLX4_CQE_STATUS_IPV6))) {
-					ip_summed = CHECKSUM_COMPLETE;
-					ring->csum_complete++;
+					if (check_csum(cqe, skb, va, dev->features)) {
+						goto csum_none;
+					} else {
+						ip_summed = CHECKSUM_COMPLETE;
+						ring->csum_complete++;
+					}
 				} else {
-					ip_summed = CHECKSUM_NONE;
-					ring->csum_none++;
+					goto csum_none;
 				}
 			}
 		} else {
+csum_none:
 			ip_summed = CHECKSUM_NONE;
 			ring->csum_none++;
 		}
-
-		/* This packet is eligible for GRO if it is:
-		 * - DIX Ethernet (type interpretation)
-		 * - TCP/IP (v4)
-		 * - without IP options
-		 * - not an IP fragment
-		 */
-		if (dev->features & NETIF_F_GRO) {
-			struct sk_buff *gro_skb = napi_get_frags(&cq->napi);
-			if (!gro_skb)
-				goto next;
-
-			nr = mlx4_en_complete_rx_desc(priv, frags, gro_skb,
-						      length);
-			if (!nr)
-				goto next;
-
-			if (ip_summed == CHECKSUM_COMPLETE) {
-				if (check_csum(cqe, gro_skb, va,
-					       dev->features)) {
-					ip_summed = CHECKSUM_NONE;
-					ring->csum_none++;
-					ring->csum_complete--;
-				}
-			}
-
-			skb_shinfo(gro_skb)->nr_frags = nr;
-			gro_skb->len = length;
-			gro_skb->data_len = length;
-			gro_skb->ip_summed = ip_summed;
-
-			if (l2_tunnel && ip_summed == CHECKSUM_UNNECESSARY)
-				gro_skb->csum_level = 1;
-
-			if ((cqe->vlan_my_qpn &
-			    cpu_to_be32(MLX4_CQE_CVLAN_PRESENT_MASK)) &&
-			    (dev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
-				u16 vid = be16_to_cpu(cqe->sl_vid);
-
-				__vlan_hwaccel_put_tag(gro_skb, htons(ETH_P_8021Q), vid);
-			} else if ((be32_to_cpu(cqe->vlan_my_qpn) &
-				  MLX4_CQE_SVLAN_PRESENT_MASK) &&
-				 (dev->features & NETIF_F_HW_VLAN_STAG_RX)) {
-				__vlan_hwaccel_put_tag(gro_skb,
-						       htons(ETH_P_8021AD),
-						       be16_to_cpu(cqe->sl_vid));
-			}
-
-			if (dev->features & NETIF_F_RXHASH)
-				skb_set_hash(gro_skb,
-					     be32_to_cpu(cqe->immed_rss_invalid),
-					     (ip_summed == CHECKSUM_UNNECESSARY) ?
-						PKT_HASH_TYPE_L4 :
-						PKT_HASH_TYPE_L3);
-
-			skb_record_rx_queue(gro_skb, cq->ring);
-
-			if (ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL) {
-				timestamp = mlx4_en_get_cqe_ts(cqe);
-				mlx4_en_fill_hwtstamps(mdev,
-						       skb_hwtstamps(gro_skb),
-						       timestamp);
-			}
-
-			napi_gro_frags(&cq->napi);
-			goto next;
-		}
-
-		/* GRO not possible, complete processing here */
-		skb = mlx4_en_rx_skb(priv, frags, length);
-		if (unlikely(!skb)) {
-			ring->dropped++;
-			goto next;
-		}
-
-		if (ip_summed == CHECKSUM_COMPLETE) {
-			if (check_csum(cqe, skb, va, dev->features)) {
-				ip_summed = CHECKSUM_NONE;
-				ring->csum_complete--;
-				ring->csum_none++;
-			}
-		}
-
 		skb->ip_summed = ip_summed;
-		skb->protocol = eth_type_trans(skb, dev);
-		skb_record_rx_queue(skb, cq->ring);
-
-		if (l2_tunnel && ip_summed == CHECKSUM_UNNECESSARY)
-			skb->csum_level = 1;
-
 		if (dev->features & NETIF_F_RXHASH)
 			skb_set_hash(skb,
 				     be32_to_cpu(cqe->immed_rss_invalid),
@@ -972,32 +841,36 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					PKT_HASH_TYPE_L4 :
 					PKT_HASH_TYPE_L3);
 
-		if ((be32_to_cpu(cqe->vlan_my_qpn) &
-		    MLX4_CQE_CVLAN_PRESENT_MASK) &&
+
+		if ((cqe->vlan_my_qpn &
+		     cpu_to_be32(MLX4_CQE_CVLAN_PRESENT_MASK)) &&
 		    (dev->features & NETIF_F_HW_VLAN_CTAG_RX))
-			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), be16_to_cpu(cqe->sl_vid));
-		else if ((be32_to_cpu(cqe->vlan_my_qpn) &
-			  MLX4_CQE_SVLAN_PRESENT_MASK) &&
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+					       be16_to_cpu(cqe->sl_vid));
+		else if ((cqe->vlan_my_qpn &
+			  cpu_to_be32(MLX4_CQE_SVLAN_PRESENT_MASK)) &&
 			 (dev->features & NETIF_F_HW_VLAN_STAG_RX))
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021AD),
 					       be16_to_cpu(cqe->sl_vid));
 
-		if (ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL) {
-			timestamp = mlx4_en_get_cqe_ts(cqe);
-			mlx4_en_fill_hwtstamps(mdev, skb_hwtstamps(skb),
-					       timestamp);
+		nr = mlx4_en_complete_rx_desc(priv, frags, skb, length);
+		if (likely(nr)) {
+			skb_shinfo(skb)->nr_frags = nr;
+			skb->len = length;
+			skb->data_len = length;
+			napi_gro_frags(&cq->napi);
+		} else {
+			skb->vlan_tci = 0;
+			skb_clear_hash(skb);
 		}
-
-		napi_gro_receive(&cq->napi, skb);
 next:
 		++cq->mcq.cons_index;
 		index = (cq->mcq.cons_index) & ring->size_mask;
 		cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
 		if (++polled == budget)
-			goto out;
+			break;
 	}
 
-out:
 	rcu_read_unlock();
 
 	if (polled) {
-- 
2.12.0.246.ga2ecc84866-goog
