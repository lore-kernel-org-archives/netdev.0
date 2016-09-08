From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 1/9] net/mlx4_en: Add branch prediction hints in RX data-path
Date: Thu,  8 Sep 2016 11:51:53 +0300
Message-ID: <1473324721-5206-2-git-send-email-tariqt@mellanox.com>
References: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55584 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932219AbcIHIxE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 04:53:04 -0400
In-Reply-To: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add likely/unlikely hints to improve branch predictions
in the RX data-path.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 2040dad8611d..f9d14ef6adc1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -72,7 +72,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 	}
 	dma = dma_map_page(priv->ddev, page, 0, PAGE_SIZE << order,
 			   frag_info->dma_dir);
-	if (dma_mapping_error(priv->ddev, dma)) {
+	if (unlikely(dma_mapping_error(priv->ddev, dma))) {
 		put_page(page);
 		return -ENOMEM;
 	}
@@ -108,7 +108,8 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
 		    ring_alloc[i].page_size)
 			continue;
 
-		if (mlx4_alloc_pages(priv, &page_alloc[i], frag_info, gfp))
+		if (unlikely(mlx4_alloc_pages(priv, &page_alloc[i],
+					      frag_info, gfp)))
 			goto out;
 	}
 
@@ -583,7 +584,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 		frag_info = &priv->frag_info[nr];
 		if (length <= frag_info->frag_prefix_size)
 			break;
-		if (!frags[nr].page)
+		if (unlikely(!frags[nr].page))
 			goto fail;
 
 		dma = be64_to_cpu(rx_desc->data[nr].addr);
@@ -623,7 +624,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 	dma_addr_t dma;
 
 	skb = netdev_alloc_skb(priv->dev, SMALL_PACKET_SIZE + NET_IP_ALIGN);
-	if (!skb) {
+	if (unlikely(!skb)) {
 		en_dbg(RX_ERR, priv, "Failed allocating skb\n");
 		return NULL;
 	}
@@ -734,7 +735,8 @@ static int get_fixed_ipv6_csum(__wsum hw_checksum, struct sk_buff *skb,
 {
 	__wsum csum_pseudo_hdr = 0;
 
-	if (ipv6h->nexthdr == IPPROTO_FRAGMENT || ipv6h->nexthdr == IPPROTO_HOPOPTS)
+	if (unlikely(ipv6h->nexthdr == IPPROTO_FRAGMENT ||
+		     ipv6h->nexthdr == IPPROTO_HOPOPTS))
 		return -1;
 	hw_checksum = csum_add(hw_checksum, (__force __wsum)htons(ipv6h->nexthdr));
 
@@ -767,7 +769,7 @@ static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
 		get_fixed_ipv4_csum(hw_checksum, skb, hdr);
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV6))
-		if (get_fixed_ipv6_csum(hw_checksum, skb, hdr))
+		if (unlikely(get_fixed_ipv6_csum(hw_checksum, skb, hdr)))
 			return -1;
 #endif
 	return 0;
@@ -794,10 +796,10 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	u64 timestamp;
 	bool l2_tunnel;
 
-	if (!priv->port_up)
+	if (unlikely(!priv->port_up))
 		return 0;
 
-	if (budget <= 0)
+	if (unlikely(budget <= 0))
 		return polled;
 
 	xdp_prog = READ_ONCE(ring->xdp_prog);
@@ -902,16 +904,16 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			case XDP_PASS:
 				break;
 			case XDP_TX:
-				if (!mlx4_en_xmit_frame(frags, dev,
+				if (likely(!mlx4_en_xmit_frame(frags, dev,
 							length, tx_index,
-							&doorbell_pending))
+							&doorbell_pending)))
 					goto consumed;
 				break;
 			default:
 				bpf_warn_invalid_xdp_action(act);
 			case XDP_ABORTED:
 			case XDP_DROP:
-				if (mlx4_en_rx_recycle(ring, frags))
+				if (likely(mlx4_en_rx_recycle(ring, frags)))
 					goto consumed;
 				goto next;
 			}
@@ -1015,7 +1017,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 
 		/* GRO not possible, complete processing here */
 		skb = mlx4_en_rx_skb(priv, rx_desc, frags, length);
-		if (!skb) {
+		if (unlikely(!skb)) {
 			ring->dropped++;
 			goto next;
 		}
-- 
1.8.3.1
