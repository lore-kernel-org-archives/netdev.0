From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 2/6] via-rhine: add allocation helpers.
Date: Wed,  8 Apr 2015 00:40:49 +0200
Message-ID: <1708368df54f8e75c866d8a470de052f03b5cd88.1428445141.git.romieu@fr.zoreil.com>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
Cc: "Nix" <nix@esperi.org.uk>, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54402 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbbDGWlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 18:41:03 -0400
In-Reply-To: <cover.1428445141.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1428445141.git.romieu@fr.zoreil.com>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c | 57 +++++++++++++++++++++++++++---------
 1 file changed, 43 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 88b45c7..aa398ea 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1213,12 +1213,47 @@ static void free_ring(struct net_device* dev)
 
 }
 
-static void alloc_rbufs(struct net_device *dev)
+struct rhine_skb_dma {
+	struct sk_buff *skb;
+	dma_addr_t dma;
+};
+
+static inline int rhine_skb_dma_init(struct net_device *dev,
+				     struct rhine_skb_dma *sd)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	struct device *hwdev = dev->dev.parent;
+	const int size = rp->rx_buf_sz;
+
+	sd->skb = netdev_alloc_skb(dev, size);
+	if (!sd->skb)
+		return -ENOMEM;
+
+	sd->dma = dma_map_single(hwdev, sd->skb->data, size, DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(hwdev, sd->dma))) {
+		netif_err(rp, drv, dev, "Rx DMA mapping failure\n");
+		dev_kfree_skb_any(sd->skb);
+		return -EIO;
+	}
+
+	return 0;
+}
+
+static inline void rhine_skb_dma_nic_store(struct rhine_private *rp,
+					   struct rhine_skb_dma *sd, int entry)
+{
+	rp->rx_skbuff_dma[entry] = sd->dma;
+	rp->rx_skbuff[entry] = sd->skb;
+
+	rp->rx_ring[entry].addr = cpu_to_le32(sd->dma);
+	dma_wmb();
+}
+
+static void alloc_rbufs(struct net_device *dev)
+{
+	struct rhine_private *rp = netdev_priv(dev);
 	dma_addr_t next;
-	int i;
+	int rc, i;
 
 	rp->dirty_rx = rp->cur_rx = 0;
 
@@ -1239,20 +1274,14 @@ static void alloc_rbufs(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = netdev_alloc_skb(dev, rp->rx_buf_sz);
-		rp->rx_skbuff[i] = skb;
-		if (skb == NULL)
-			break;
+		struct rhine_skb_dma sd;
 
-		rp->rx_skbuff_dma[i] =
-			dma_map_single(hwdev, skb->data, rp->rx_buf_sz,
-				       DMA_FROM_DEVICE);
-		if (dma_mapping_error(hwdev, rp->rx_skbuff_dma[i])) {
-			rp->rx_skbuff_dma[i] = 0;
-			dev_kfree_skb(skb);
+		rc = rhine_skb_dma_init(dev, &sd);
+		if (rc < 0)
 			break;
-		}
-		rp->rx_ring[i].addr = cpu_to_le32(rp->rx_skbuff_dma[i]);
+
+		rhine_skb_dma_nic_store(rp, &sd, i);
+
 		rp->rx_ring[i].rx_status = cpu_to_le32(DescOwn);
 	}
 	rp->dirty_rx = (unsigned int)(i - RX_RING_SIZE);
-- 
2.1.0
