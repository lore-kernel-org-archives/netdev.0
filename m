From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.19+: (and quite probably earlier) VIA Rhine hanging under high
 network load, yet again: redux
Date: Sat, 4 Apr 2015 23:05:18 +0200
Message-ID: <20150404210518.GA7698@electric-eye.fr.zoreil.com>
References: <874mov7otu.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux-Netdev <netdev@vger.kernel.org>
To: Nix <nix@esperi.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48350 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbbDDVFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 17:05:34 -0400
Content-Disposition: inline
In-Reply-To: <874mov7otu.fsf@spindle.srvr.nix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nix <nix@esperi.org.uk> :
[...]

This driver leaves holes in its receive ring under memory pressure.
It may not help.

You can try the gross patch below against v3.19. It compiles. I have to go.

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index a191afc..f58d1d5 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -471,7 +471,7 @@ struct rhine_private {
 	/* Frequently used values: keep some adjacent for cache effect. */
 	u32 quirks;
 	struct rx_desc *rx_head_desc;
-	unsigned int cur_rx, dirty_rx;	/* Producer/consumer ring indices */
+	unsigned int cur_rx;
 	unsigned int cur_tx, dirty_tx;
 	unsigned int rx_buf_sz;		/* Based on MTU+slack. */
 	struct rhine_stats rx_stats;
@@ -1218,7 +1218,7 @@ static void alloc_rbufs(struct net_device *dev)
 	dma_addr_t next;
 	int i;
 
-	rp->dirty_rx = rp->cur_rx = 0;
+	rp->cur_rx = 0;
 
 	rp->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
 	rp->rx_head_desc = &rp->rx_ring[0];
@@ -1239,8 +1239,8 @@ static void alloc_rbufs(struct net_device *dev)
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		struct sk_buff *skb = netdev_alloc_skb(dev, rp->rx_buf_sz);
 		rp->rx_skbuff[i] = skb;
-		if (skb == NULL)
-			break;
+
+		BUG_ON(skb == NULL);
 
 		rp->rx_skbuff_dma[i] =
 			dma_map_single(hwdev, skb->data, rp->rx_buf_sz,
@@ -1253,7 +1253,6 @@ static void alloc_rbufs(struct net_device *dev)
 		rp->rx_ring[i].addr = cpu_to_le32(rp->rx_skbuff_dma[i]);
 		rp->rx_ring[i].rx_status = cpu_to_le32(DescOwn);
 	}
-	rp->dirty_rx = (unsigned int)(i - RX_RING_SIZE);
 }
 
 static void free_rbufs(struct net_device* dev)
@@ -1932,13 +1931,68 @@ static inline u16 rhine_get_vlan_tci(struct sk_buff *skb, int data_size)
 	return be16_to_cpup((__be16 *)trailer);
 }
 
+static struct sk_buff *rhine_rx_copybreak(struct net_device *dev, int entry, u16 len)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	dma_addr_t mapping = rp->rx_skbuff_dma[entry];
+	struct device *hwdev = dev->dev.parent;
+	const int size = rp->rx_buf_sz;
+	struct sk_buff *new_skb;
+
+	new_skb = netdev_alloc_skb_ip_align(dev, len);
+	if (unlikely(!new_skb)) {
+		dev->stats.rx_dropped++;
+		goto sync;
+	}
+
+	dma_sync_single_for_cpu(hwdev, mapping, size, DMA_FROM_DEVICE);
+
+	skb_copy_to_linear_data(new_skb, rp->rx_skbuff[entry]->data, len);
+sync:
+	dma_sync_single_for_device(hwdev, mapping, size, DMA_FROM_DEVICE);
+
+	return new_skb;
+}
+
+static struct sk_buff *rhine_rx_swap_one(struct net_device *dev, int entry)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	struct sk_buff *skb = rp->rx_skbuff[entry];
+	struct device *hwdev = dev->dev.parent;
+	const int size = rp->rx_buf_sz;
+	struct sk_buff *new_skb;
+	dma_addr_t mapping;
+
+	new_skb = netdev_alloc_skb(dev, size);
+	if (!new_skb)
+		goto out_drop;
+
+	mapping = dma_map_single(hwdev, new_skb->data, size, DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(hwdev, mapping))) {
+		netdev_err(dev, "Rx DMA mapping failure\n");
+		goto out_kfree;
+	}
+
+	dma_unmap_single(hwdev, rp->rx_skbuff_dma[entry], size, DMA_FROM_DEVICE);
+	rp->rx_skbuff[entry] = new_skb;
+	rp->rx_skbuff_dma[entry] = mapping;
+	rp->rx_ring[entry].addr = cpu_to_le32(mapping);
+
+	return skb;
+
+out_kfree:
+	dev_kfree_skb(new_skb);
+out_drop:
+	dev->stats.rx_dropped++;
+	return NULL;
+}
+
 /* Process up to limit frames from receive ring */
 static int rhine_rx(struct net_device *dev, int limit)
 {
 	struct rhine_private *rp = netdev_priv(dev);
-	struct device *hwdev = dev->dev.parent;
-	int count;
 	int entry = rp->cur_rx % RX_RING_SIZE;
+	int count;
 
 	netif_dbg(rp, rx_status, dev, "%s(), entry %d status %08x\n", __func__,
 		  entry, le32_to_cpu(rp->rx_head_desc->rx_status));
@@ -1988,42 +2042,21 @@ static int rhine_rx(struct net_device *dev, int limit)
 				}
 			}
 		} else {
-			struct sk_buff *skb = NULL;
 			/* Length should omit the CRC */
 			int pkt_len = data_size - 4;
+			struct sk_buff *skb;
 			u16 vlan_tci = 0;
 
-			/* Check if the packet is long enough to accept without
-			   copying to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak)
-				skb = netdev_alloc_skb_ip_align(dev, pkt_len);
-			if (skb) {
-				dma_sync_single_for_cpu(hwdev,
-							rp->rx_skbuff_dma[entry],
-							rp->rx_buf_sz,
-							DMA_FROM_DEVICE);
-
-				skb_copy_to_linear_data(skb,
-						 rp->rx_skbuff[entry]->data,
-						 pkt_len);
-				skb_put(skb, pkt_len);
-				dma_sync_single_for_device(hwdev,
-							   rp->rx_skbuff_dma[entry],
-							   rp->rx_buf_sz,
-							   DMA_FROM_DEVICE);
-			} else {
-				skb = rp->rx_skbuff[entry];
-				if (skb == NULL) {
-					netdev_err(dev, "Inconsistent Rx descriptor chain\n");
-					break;
-				}
-				rp->rx_skbuff[entry] = NULL;
-				skb_put(skb, pkt_len);
-				dma_unmap_single(hwdev,
-						 rp->rx_skbuff_dma[entry],
-						 rp->rx_buf_sz,
-						 DMA_FROM_DEVICE);
-			}
+			BUG_ON(pkt_len < 0);
+
+			skb = (pkt_len < rx_copybreak) ?
+				rhine_rx_copybreak(dev, entry, pkt_len) :
+				rhine_rx_swap_one(dev, entry);
+
+			if (!skb)
+				break;
+
+			skb_put(skb, pkt_len);
 
 			if (unlikely(desc_length & DescTag))
 				vlan_tci = rhine_get_vlan_tci(skb, data_size);
@@ -2039,34 +2072,12 @@ static int rhine_rx(struct net_device *dev, int limit)
 			rp->rx_stats.packets++;
 			u64_stats_update_end(&rp->rx_stats.syncp);
 		}
+		rp->rx_ring[entry].rx_status = cpu_to_le32(DescOwn);
+
 		entry = (++rp->cur_rx) % RX_RING_SIZE;
 		rp->rx_head_desc = &rp->rx_ring[entry];
 	}
 
-	/* Refill the Rx ring buffers. */
-	for (; rp->cur_rx - rp->dirty_rx > 0; rp->dirty_rx++) {
-		struct sk_buff *skb;
-		entry = rp->dirty_rx % RX_RING_SIZE;
-		if (rp->rx_skbuff[entry] == NULL) {
-			skb = netdev_alloc_skb(dev, rp->rx_buf_sz);
-			rp->rx_skbuff[entry] = skb;
-			if (skb == NULL)
-				break;	/* Better luck next round. */
-			rp->rx_skbuff_dma[entry] =
-				dma_map_single(hwdev, skb->data,
-					       rp->rx_buf_sz,
-					       DMA_FROM_DEVICE);
-			if (dma_mapping_error(hwdev,
-					      rp->rx_skbuff_dma[entry])) {
-				dev_kfree_skb(skb);
-				rp->rx_skbuff_dma[entry] = 0;
-				break;
-			}
-			rp->rx_ring[entry].addr = cpu_to_le32(rp->rx_skbuff_dma[entry]);
-		}
-		rp->rx_ring[entry].rx_status = cpu_to_le32(DescOwn);
-	}
-
 	return count;
 }
 
