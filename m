From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 4/4] via-rhine: forbid holes in the receive descriptor ring.
Date: Mon,  6 Apr 2015 20:01:52 +0200
Message-ID: <13029e01c3888b592c86544f61cd22ac7e1059b2.1428340371.git.romieu@fr.zoreil.com>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
Cc: "Nix" <nix@esperi.org.uk>, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50037 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbDFSCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 14:02:14 -0400
In-Reply-To: <cover.1428340371.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1428340371.git.romieu@fr.zoreil.com>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rationales:
- throttle work under memory pressure;
- lower receive descriptor recycling latency for the network adapter;
- lower the maintenance burden of uncommon paths.

The patch is twofold:
1. it fails early if the receive buffer ring can't be completely
   initialized at dev->open() time
2. it drops packets on the floor in the napi receive handler so as to
   keep the ring full.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c | 101 ++++++++++++++++++-----------------
 1 file changed, 52 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index ae1ab6b..94729b1 100644
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
@@ -1237,6 +1237,16 @@ static inline int rhine_skb_dma_init(struct net_device *dev,
 	return 0;
 }
 
+static void rhine_reset_rbufs(struct rhine_private *rp)
+{
+	int i;
+
+	rp->cur_rx = 0;
+
+	for (i = 0; i < RX_RING_SIZE; i++)
+		rp->rx_ring[i].rx_status = cpu_to_le32(DescOwn);
+}
+
 static inline void rhine_skb_dma_nic_store(struct rhine_private *rp,
 					   struct rhine_skb_dma *sd, int entry)
 {
@@ -1247,14 +1257,14 @@ static inline void rhine_skb_dma_nic_store(struct rhine_private *rp,
 	wmb();
 }
 
-static void alloc_rbufs(struct net_device *dev)
+static void free_rbufs(struct net_device* dev);
+
+static int alloc_rbufs(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	dma_addr_t next;
 	int rc, i;
 
-	rp->dirty_rx = rp->cur_rx = 0;
-
 	rp->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
 	rp->rx_head_desc = &rp->rx_ring[0];
 	next = rp->rx_ring_dma;
@@ -1275,14 +1285,17 @@ static void alloc_rbufs(struct net_device *dev)
 		struct rhine_skb_dma sd;
 
 		rc = rhine_skb_dma_init(dev, &sd);
-		if (rc < 0)
-			break;
+		if (rc < 0) {
+			free_rbufs(dev);
+			goto out;
+		}
 
 		rhine_skb_dma_nic_store(rp, &sd, i);
-
-		rp->rx_ring[i].rx_status = cpu_to_le32(DescOwn);
 	}
-	rp->dirty_rx = (unsigned int)(i - RX_RING_SIZE);
+
+	rhine_reset_rbufs(rp);
+out:
+	return rc;
 }
 
 static void free_rbufs(struct net_device* dev)
@@ -1692,7 +1705,10 @@ static int rhine_open(struct net_device *dev)
 	if (rc < 0)
 		goto out_free_irq;
 
-	alloc_rbufs(dev);
+	rc = alloc_rbufs(dev);
+	if (rc < 0)
+		goto out_free_ring;
+
 	alloc_tbufs(dev);
 	rhine_chip_reset(dev);
 	rhine_task_enable(rp);
@@ -1707,6 +1723,8 @@ static int rhine_open(struct net_device *dev)
 out:
 	return rc;
 
+out_free_ring:
+	free_ring(dev);
 out_free_irq:
 	free_irq(rp->irq, dev);
 	goto out;
@@ -1729,9 +1747,9 @@ static void rhine_reset_task(struct work_struct *work)
 
 	/* clear all descriptors */
 	free_tbufs(dev);
-	free_rbufs(dev);
 	alloc_tbufs(dev);
-	alloc_rbufs(dev);
+
+	rhine_reset_rbufs(rp);
 
 	/* Reinitialize the hardware. */
 	rhine_chip_reset(dev);
@@ -2021,16 +2039,18 @@ static int rhine_rx(struct net_device *dev, int limit)
 				}
 			}
 		} else {
-			struct sk_buff *skb = NULL;
 			/* Length should omit the CRC */
 			int pkt_len = data_size - 4;
+			struct sk_buff *skb;
 			u16 vlan_tci = 0;
 
 			/* Check if the packet is long enough to accept without
 			   copying to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak)
+			if (pkt_len < rx_copybreak) {
 				skb = netdev_alloc_skb_ip_align(dev, pkt_len);
-			if (skb) {
+				if (unlikely(!skb))
+					goto drop;
+
 				dma_sync_single_for_cpu(hwdev,
 							rp->rx_skbuff_dma[entry],
 							rp->rx_buf_sz,
@@ -2039,25 +2059,28 @@ static int rhine_rx(struct net_device *dev, int limit)
 				skb_copy_to_linear_data(skb,
 						 rp->rx_skbuff[entry]->data,
 						 pkt_len);
-				skb_put(skb, pkt_len);
+
 				dma_sync_single_for_device(hwdev,
 							   rp->rx_skbuff_dma[entry],
 							   rp->rx_buf_sz,
 							   DMA_FROM_DEVICE);
 			} else {
+				struct rhine_skb_dma sd;
+
+				if (unlikely(rhine_skb_dma_init(dev, &sd) < 0))
+					goto drop;
+
 				skb = rp->rx_skbuff[entry];
-				if (skb == NULL) {
-					netdev_err(dev, "Inconsistent Rx descriptor chain\n");
-					break;
-				}
-				rp->rx_skbuff[entry] = NULL;
-				skb_put(skb, pkt_len);
+
 				dma_unmap_single(hwdev,
 						 rp->rx_skbuff_dma[entry],
 						 rp->rx_buf_sz,
 						 DMA_FROM_DEVICE);
+				rhine_skb_dma_nic_store(rp, &sd, entry);
 			}
 
+			skb_put(skb, pkt_len);
+
 			if (unlikely(desc_length & DescTag))
 				vlan_tci = rhine_get_vlan_tci(skb, data_size);
 
@@ -2072,36 +2095,17 @@ static int rhine_rx(struct net_device *dev, int limit)
 			rp->rx_stats.packets++;
 			u64_stats_update_end(&rp->rx_stats.syncp);
 		}
+give_descriptor_to_nic:
+		rp->rx_ring[entry].rx_status = cpu_to_le32(DescOwn);
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
-			wmb();
-		}
-		rp->rx_ring[entry].rx_status = cpu_to_le32(DescOwn);
-	}
-
 	return count;
+
+drop:
+	dev->stats.rx_dropped++;
+	goto give_descriptor_to_nic;
 }
 
 static void rhine_restart_tx(struct net_device *dev) {
@@ -2506,9 +2510,8 @@ static int rhine_resume(struct device *device)
 	enable_mmio(rp->pioaddr, rp->quirks);
 	rhine_power_init(dev);
 	free_tbufs(dev);
-	free_rbufs(dev);
 	alloc_tbufs(dev);
-	alloc_rbufs(dev);
+	rhine_reset_rbufs(rp);
 	rhine_task_enable(rp);
 	spin_lock_bh(&rp->lock);
 	init_registers(dev);
-- 
2.1.0
