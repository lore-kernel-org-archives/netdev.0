From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx4_en: Fix handling of dma_map failure
Date: Mon, 19 Aug 2013 09:42:22 +0300
Message-ID: <1376894542-27854-4-git-send-email-amirv@mellanox.com>
References: <1376894542-27854-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34499 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750870Ab3HSGmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:42:42 -0400
In-Reply-To: <1376894542-27854-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Result of skb_frag_dma_map() and dma_map_single() wasn't checked.
Added a check and proper handling in case of failure.
Moved the mapping to the beginning of mlx4_en_xmit(), before updating
the ring data structure to make error handling easier.


Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 94 +++++++++++++++++++-----------
 1 file changed, 59 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 157bcd1..92d7097 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -673,6 +673,64 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_info->skb = skb;
 	tx_info->nr_txbb = nr_txbb;
 
+	if (lso_header_size)
+		data = ((void *)&tx_desc->lso + ALIGN(lso_header_size + 4,
+						      DS_SIZE));
+	else
+		data = &tx_desc->data;
+
+	/* valid only for none inline segments */
+	tx_info->data_offset = (void *)data - (void *)tx_desc;
+
+	tx_info->linear = (lso_header_size < skb_headlen(skb) &&
+			   !is_inline(skb, NULL)) ? 1 : 0;
+
+	data += skb_shinfo(skb)->nr_frags + tx_info->linear - 1;
+
+	if (is_inline(skb, &fragptr)) {
+		tx_info->inl = 1;
+	} else {
+		/* Map fragments */
+		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
+			frag = &skb_shinfo(skb)->frags[i];
+			dma = skb_frag_dma_map(priv->ddev, frag,
+					       0, skb_frag_size(frag),
+					       DMA_TO_DEVICE);
+			if (dma_mapping_error(priv->ddev, dma)) {
+				for (i++; i < skb_shinfo(skb)->nr_frags; i++) {
+					frag = &skb_shinfo(skb)->frags[i];
+					en_err(priv, "DMA mapping error\n");
+					dma_unmap_page(priv->ddev,
+						       (dma_addr_t) be64_to_cpu(data[i].addr),
+						       skb_frag_size(frag), PCI_DMA_TODEVICE);
+				}
+				goto tx_drop;
+			}
+
+			data->addr = cpu_to_be64(dma);
+			data->lkey = cpu_to_be32(mdev->mr.key);
+			wmb();
+			data->byte_count = cpu_to_be32(skb_frag_size(frag));
+			--data;
+		}
+
+		/* Map linear part */
+		if (tx_info->linear) {
+			u32 byte_count = skb_headlen(skb) - lso_header_size;
+			dma = dma_map_single(priv->ddev, skb->data +
+					     lso_header_size, byte_count,
+					     PCI_DMA_TODEVICE);
+			if (dma_mapping_error(priv->ddev, dma))
+				goto tx_drop;
+
+			data->addr = cpu_to_be64(dma);
+			data->lkey = cpu_to_be32(mdev->mr.key);
+			wmb();
+			data->byte_count = cpu_to_be32(byte_count);
+		}
+		tx_info->inl = 0;
+	}
+
 	/*
 	 * For timestamping add flag to skb_shinfo and
 	 * set flag for further reference
@@ -719,8 +777,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* Copy headers;
 		 * note that we already verified that it is linear */
 		memcpy(tx_desc->lso.header, skb->data, lso_header_size);
-		data = ((void *) &tx_desc->lso +
-			ALIGN(lso_header_size + 4, DS_SIZE));
 
 		priv->port_stats.tso_packets++;
 		i = ((skb->len - lso_header_size) / skb_shinfo(skb)->gso_size) +
@@ -732,7 +788,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		op_own = cpu_to_be32(MLX4_OPCODE_SEND) |
 			((ring->prod & ring->size) ?
 			 cpu_to_be32(MLX4_EN_BIT_DESC_OWN) : 0);
-		data = &tx_desc->data;
 		tx_info->nr_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
 		ring->packets++;
 
@@ -741,38 +796,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	netdev_tx_sent_queue(ring->tx_queue, tx_info->nr_bytes);
 	AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, skb->len);
 
-
-	/* valid only for none inline segments */
-	tx_info->data_offset = (void *) data - (void *) tx_desc;
-
-	tx_info->linear = (lso_header_size < skb_headlen(skb) && !is_inline(skb, NULL)) ? 1 : 0;
-	data += skb_shinfo(skb)->nr_frags + tx_info->linear - 1;
-
-	if (!is_inline(skb, &fragptr)) {
-		/* Map fragments */
-		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
-			frag = &skb_shinfo(skb)->frags[i];
-			dma = skb_frag_dma_map(priv->ddev, frag,
-					       0, skb_frag_size(frag),
-					       DMA_TO_DEVICE);
-			data->addr = cpu_to_be64(dma);
-			data->lkey = cpu_to_be32(mdev->mr.key);
-			wmb();
-			data->byte_count = cpu_to_be32(skb_frag_size(frag));
-			--data;
-		}
-
-		/* Map linear part */
-		if (tx_info->linear) {
-			dma = dma_map_single(priv->ddev, skb->data + lso_header_size,
-					     skb_headlen(skb) - lso_header_size, PCI_DMA_TODEVICE);
-			data->addr = cpu_to_be64(dma);
-			data->lkey = cpu_to_be32(mdev->mr.key);
-			wmb();
-			data->byte_count = cpu_to_be32(skb_headlen(skb) - lso_header_size);
-		}
-		tx_info->inl = 0;
-	} else {
+	if (tx_info->inl) {
 		build_inline_wqe(tx_desc, skb, real_size, &vlan_tag, tx_ind, fragptr);
 		tx_info->inl = 1;
 	}
-- 
1.8.3.4
