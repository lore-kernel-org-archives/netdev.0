From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] forcedeth: fix dma api mismatches
Date: Thu, 18 Jun 2009 09:17:59 +0200
Message-ID: <4A39EA27.3020404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53825 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbZFRHSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 03:18:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David & Ayaz

Please find following patch, candidate for stable, but alas not tested
since I dont have the hardware. I hit this on a 2.6.30 kernel on a machine
I dont have access anymore.

Thank you

[PATCH] forcedeth: fix dma api mismatches

forcedeth doesnt use properly dma api in its tx completion path
and in nv_loopback_test()

pci_map_single() should be paired with pci_unmap_single()
pci_map_page() should be paired with pci_unmap_page()

forcedeth xmit path uses pci_map_single() & pci_map_page(),
but tx completion path only uses pci_unmap_single()

nv_loopback_test() uses pci_map_single() & pci_unmap_page()

Add a dma_single field in struct nv_skb_map, and
define a helper function nv_unmap_txskb

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Ayaz Abdulla <aabdulla@nvidia.com>
---
 drivers/net/forcedeth.c |   46 ++++++++++++++++++++++----------------
 1 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index b60a304..1094d29 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -719,7 +719,8 @@ static const struct register_test nv_registers_test[] = {
 struct nv_skb_map {
 	struct sk_buff *skb;
 	dma_addr_t dma;
-	unsigned int dma_len;
+	unsigned int dma_len:31;
+	unsigned int dma_single:1;
 	struct ring_desc_ex *first_tx_desc;
 	struct nv_skb_map *next_tx_ctx;
 };
@@ -1912,6 +1913,7 @@ static void nv_init_tx(struct net_device *dev)
 		np->tx_skb[i].skb = NULL;
 		np->tx_skb[i].dma = 0;
 		np->tx_skb[i].dma_len = 0;
+		np->tx_skb[i].dma_single = 0;
 		np->tx_skb[i].first_tx_desc = NULL;
 		np->tx_skb[i].next_tx_ctx = NULL;
 	}
@@ -1930,23 +1932,30 @@ static int nv_init_ring(struct net_device *dev)
 		return nv_alloc_rx_optimized(dev);
 }
 
-static int nv_release_txskb(struct net_device *dev, struct nv_skb_map* tx_skb)
+static void nv_unmap_txskb(struct fe_priv *np, struct nv_skb_map *tx_skb)
 {
-	struct fe_priv *np = netdev_priv(dev);
-
 	if (tx_skb->dma) {
-		pci_unmap_page(np->pci_dev, tx_skb->dma,
-			       tx_skb->dma_len,
-			       PCI_DMA_TODEVICE);
+		if (tx_skb->dma_single)
+			pci_unmap_single(np->pci_dev, tx_skb->dma,
+					 tx_skb->dma_len,
+					 PCI_DMA_TODEVICE);
+		else
+			pci_unmap_page(np->pci_dev, tx_skb->dma,
+				       tx_skb->dma_len,
+				       PCI_DMA_TODEVICE);
 		tx_skb->dma = 0;
 	}
+}
+
+static int nv_release_txskb(struct fe_priv *np, struct nv_skb_map *tx_skb)
+{
+	nv_unmap_txskb(np, tx_skb);
 	if (tx_skb->skb) {
 		dev_kfree_skb_any(tx_skb->skb);
 		tx_skb->skb = NULL;
 		return 1;
-	} else {
-		return 0;
 	}
+	return 0;
 }
 
 static void nv_drain_tx(struct net_device *dev)
@@ -1964,10 +1973,11 @@ static void nv_drain_tx(struct net_device *dev)
 			np->tx_ring.ex[i].bufhigh = 0;
 			np->tx_ring.ex[i].buflow = 0;
 		}
-		if (nv_release_txskb(dev, &np->tx_skb[i]))
+		if (nv_release_txskb(np, &np->tx_skb[i]))
 			dev->stats.tx_dropped++;
 		np->tx_skb[i].dma = 0;
 		np->tx_skb[i].dma_len = 0;
+		np->tx_skb[i].dma_single = 0;
 		np->tx_skb[i].first_tx_desc = NULL;
 		np->tx_skb[i].next_tx_ctx = NULL;
 	}
@@ -2171,6 +2181,7 @@ static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
 						PCI_DMA_TODEVICE);
 		np->put_tx_ctx->dma_len = bcnt;
+		np->put_tx_ctx->dma_single = 1;
 		put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
 		put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 
@@ -2196,6 +2207,7 @@ static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
 							   PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
+			np->put_tx_ctx->dma_single = 0;
 			put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
 			put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 
@@ -2291,6 +2303,7 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
 						PCI_DMA_TODEVICE);
 		np->put_tx_ctx->dma_len = bcnt;
+		np->put_tx_ctx->dma_single = 1;
 		put_tx->bufhigh = cpu_to_le32(dma_high(np->put_tx_ctx->dma));
 		put_tx->buflow = cpu_to_le32(dma_low(np->put_tx_ctx->dma));
 		put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
@@ -2317,6 +2330,7 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
 							   PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
+			np->put_tx_ctx->dma_single = 0;
 			put_tx->bufhigh = cpu_to_le32(dma_high(np->put_tx_ctx->dma));
 			put_tx->buflow = cpu_to_le32(dma_low(np->put_tx_ctx->dma));
 			put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
@@ -2434,10 +2448,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 		dprintk(KERN_DEBUG "%s: nv_tx_done: flags 0x%x.\n",
 					dev->name, flags);
 
-		pci_unmap_page(np->pci_dev, np->get_tx_ctx->dma,
-			       np->get_tx_ctx->dma_len,
-			       PCI_DMA_TODEVICE);
-		np->get_tx_ctx->dma = 0;
+		nv_unmap_txskb(np, np->get_tx_ctx);
 
 		if (np->desc_ver == DESC_VER_1) {
 			if (flags & NV_TX_LASTPACKET) {
@@ -2502,10 +2513,7 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 		dprintk(KERN_DEBUG "%s: nv_tx_done_optimized: flags 0x%x.\n",
 					dev->name, flags);
 
-		pci_unmap_page(np->pci_dev, np->get_tx_ctx->dma,
-			       np->get_tx_ctx->dma_len,
-			       PCI_DMA_TODEVICE);
-		np->get_tx_ctx->dma = 0;
+		nv_unmap_txskb(np, np->get_tx_ctx);
 
 		if (flags & NV_TX2_LASTPACKET) {
 			if (!(flags & NV_TX2_ERROR))
@@ -5091,7 +5099,7 @@ static int nv_loopback_test(struct net_device *dev)
 		dprintk(KERN_DEBUG "%s: loopback - did not receive test packet\n", dev->name);
 	}
 
-	pci_unmap_page(np->pci_dev, test_dma_addr,
+	pci_unmap_single(np->pci_dev, test_dma_addr,
 		       (skb_end_pointer(tx_skb) - tx_skb->data),
 		       PCI_DMA_TODEVICE);
 	dev_kfree_skb_any(tx_skb);
