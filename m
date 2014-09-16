From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH] 3c59x: Add dma error checking and recovery
Date: Tue, 16 Sep 2014 10:32:17 -0400
Message-ID: <1410877937-27487-1-git-send-email-nhorman@tuxdriver.com>
References: <20140916101704.GA3792@hmsreliant.think-freely.org>
Cc: Meelis Roos <mroos@linux.ee>, linux-kernel@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140916101704.GA3792@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Noted that 3c59x has no checks on transmit for failed DMA mappings, and no
ability to unmap fragments when a single map fails in the middle of a transmit.
This patch provides error checking to ensure that dma mappings work properly,
and unrolls an skb mapping if a fragmented skb transmission has a mapping
failure to prevent leaks.

Please test this patch out.  It may fix the problem your experiencing, and, if
you enable dynamic debug in the driver, it will certainly confirm that is the
problem you are experiencing.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/ethernet/3com/3c59x.c | 50 ++++++++++++++++++++++++++++++++-------
 1 file changed, 41 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 3fe45c7..5621dab 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2129,6 +2129,7 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int entry = vp->cur_tx % TX_RING_SIZE;
 	struct boom_tx_desc *prev_entry = &vp->tx_ring[(vp->cur_tx-1) % TX_RING_SIZE];
 	unsigned long flags;
+	dma_addr_t dma_addr;
 
 	if (vortex_debug > 6) {
 		pr_debug("boomerang_start_xmit()\n");
@@ -2163,24 +2164,48 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			vp->tx_ring[entry].status = cpu_to_le32(skb->len | TxIntrUploaded | AddTCPChksum | AddUDPChksum);
 
 	if (!skb_shinfo(skb)->nr_frags) {
-		vp->tx_ring[entry].frag[0].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data,
-										skb->len, PCI_DMA_TODEVICE));
+		dma_addr = pci_map_single(VORTEX_PCI(vp), skb->data, skb->len,
+					  PCI_DMA_TODEVICE);
+		if (dma_mapping_error(&VORTEX_PCI(vp)->dev, dma_addr))
+			goto out_dma_err;
+
+		vp->tx_ring[entry].frag[0].addr = cpu_to_le32(dma_addr);
 		vp->tx_ring[entry].frag[0].length = cpu_to_le32(skb->len | LAST_FRAG);
 	} else {
 		int i;
 
-		vp->tx_ring[entry].frag[0].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data,
-										skb_headlen(skb), PCI_DMA_TODEVICE));
+		dma_addr = pci_map_single(VORTEX_PCI(vp), skb->data,
+					  skb_headlen(skb), PCI_DMA_TODEVICE);
+		if (dma_mapping_error(&VORTEX_PCI(vp)->dev, dma_addr))
+			goto out_dma_err;
+
+		vp->tx_ring[entry].frag[0].addr = cpu_to_le32(dma_addr);
 		vp->tx_ring[entry].frag[0].length = cpu_to_le32(skb_headlen(skb));
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
+			dma_addr = skb_frag_dma_map(&VORTEX_PCI(vp)->dev, frag,
+						    frag->page_offset,
+						    frag->size,
+						    DMA_TO_DEVICE);
+			if (dma_mapping_error(&VORTEX_PCI(vp)->dev, dma_addr)) {
+				for(i = i-1; i >= 0; i--)
+					dma_unmap_page(&VORTEX_PCI(vp)->dev,
+						       le32_to_cpu(vp->tx_ring[entry].frag[i+1].addr),
+						       le32_to_cpu(vp->tx_ring[entry].frag[i+1].length),
+						       DMA_TO_DEVICE);
+
+				pci_unmap_single(VORTEX_PCI(vp),
+						 le32_to_cpu(vp->tx_ring[entry].frag[0].addr),
+						 le32_to_cpu(vp->tx_ring[entry].frag[0].length),
+						 PCI_DMA_TODEVICE);
+
+				goto out_dma_err;
+			}
+
 			vp->tx_ring[entry].frag[i+1].addr =
-					cpu_to_le32(skb_frag_dma_map(
-						&VORTEX_PCI(vp)->dev,
-						frag,
-						frag->page_offset, frag->size, DMA_TO_DEVICE));
+						cpu_to_le32(dma_addr);
 
 			if (i == skb_shinfo(skb)->nr_frags-1)
 					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(skb_frag_size(frag)|LAST_FRAG);
@@ -2189,7 +2214,10 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 #else
-	vp->tx_ring[entry].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data, skb->len, PCI_DMA_TODEVICE));
+	dma_addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data, skb->len, PCI_DMA_TODEVICE));
+	if (dma_mapping_error(&VORTEX_PCI(vp)->dev, dma_addr))
+		goto out_dma_err;
+	vp->tx_ring[entry].addr = cpu_to_le32(dma_addr);
 	vp->tx_ring[entry].length = cpu_to_le32(skb->len | LAST_FRAG);
 	vp->tx_ring[entry].status = cpu_to_le32(skb->len | TxIntrUploaded);
 #endif
@@ -2217,7 +2245,11 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_tx_timestamp(skb);
 	iowrite16(DownUnstall, ioaddr + EL3_CMD);
 	spin_unlock_irqrestore(&vp->lock, flags);
+out:
 	return NETDEV_TX_OK;
+out_dma_err:
+	dev_err(&VORTEX_PCI(vp)->dev, "Error mapping dma buffer\n");
+	goto out; 
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up
-- 
1.9.3
