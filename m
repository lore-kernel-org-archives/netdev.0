From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH net-next v3 06/07] 3c59x: Support for byte queue limits
Date: Sun, 20 Oct 2013 21:23:10 +0200
Message-ID: <1382296991-20289-7-git-send-email-milky-kernel@mcmilk.de>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:49861 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751513Ab3JTTX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 15:23:28 -0400
In-Reply-To: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to 3c59x driver to use byte queue limits.


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/3com/3c59x.c | 47 ++++++++++++++++++++++++++++++++++-----
 1 file changed, 41 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index ad5272b..6a7b77d 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -795,6 +795,7 @@ static int global_options = -1;
 static int global_full_duplex = -1;
 static int global_enable_wol = -1;
 static int global_use_mmio = -1;
+static bool bql_disable;
 
 /* Variables to work-around the Compaq PCI BIOS32 problem. */
 static int compaq_ioaddr, compaq_irq, compaq_device_id = 0x5900;
@@ -819,6 +820,8 @@ module_param(compaq_device_id, int, 0);
 module_param(watchdog, int, 0);
 module_param(global_use_mmio, int, 0);
 module_param_array(use_mmio, int, NULL, 0);
+module_param(bql_disable, bool, 0);
+
 MODULE_PARM_DESC(debug, "3c59x debug level (0-6)");
 MODULE_PARM_DESC(options, "3c59x: Bits 0-3: media type, bit 4: bus mastering, bit 9: full duplex");
 MODULE_PARM_DESC(global_options, "3c59x: same as options, but applies to all NICs if options is unset");
@@ -836,6 +839,7 @@ MODULE_PARM_DESC(compaq_device_id, "3c59x PCI device ID (Compaq BIOS problem wor
 MODULE_PARM_DESC(watchdog, "3c59x transmit timeout in milliseconds");
 MODULE_PARM_DESC(global_use_mmio, "3c59x: same as use_mmio, but applies to all NICs if options is unset");
 MODULE_PARM_DESC(use_mmio, "3c59x: use memory-mapped PCI I/O resource (0-1)");
+MODULE_PARM_DESC(bql_disable, "3c59x: Disable Byte Queue Limits functionality (default: false)");
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_vortex(struct net_device *dev)
@@ -1726,6 +1730,9 @@ vortex_up(struct net_device *dev)
 	iowrite16(vp->intr_enable, ioaddr + EL3_CMD);
 	if (vp->cb_fn_base)			/* The PCMCIA people are idiots.  */
 		iowrite32(0x8000, vp->cb_fn_base + 4);
+
+	if (unlikely(bql_disable))
+		netdev_reset_queue(dev);
 	netif_start_queue (dev);
 err_out:
 	return err;
@@ -2080,10 +2087,15 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		spin_unlock_irq(&vp->window_lock);
 		vp->tx_skb = skb;
 		iowrite16(StartDMADown, ioaddr + EL3_CMD);
+		if (unlikely(bql_disable))
+			netdev_sent_queue(dev, len);
 		/* netif_wake_queue() will be called at the DMADone interrupt. */
 	} else {
 		/* ... and the packet rounded to a doubleword. */
-		iowrite32_rep(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
+		int len = (skb->len + 3) >> 2;
+		iowrite32_rep(ioaddr + TX_FIFO, skb->data, len);
+		if (unlikely(bql_disable))
+			netdev_sent_queue(dev, len);
 		dev_kfree_skb (skb);
 		if (ioread16(ioaddr + TxFree) > 1536) {
 			netif_start_queue (dev);	/* AKPM: redundant? */
@@ -2094,7 +2106,6 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-
 	/* Clear the Tx status stack. */
 	{
 		int tx_status;
@@ -2164,12 +2175,14 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		vp->tx_ring[entry].frag[0].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data,
 										skb->len, PCI_DMA_TODEVICE));
 		vp->tx_ring[entry].frag[0].length = cpu_to_le32(skb->len | LAST_FRAG);
+		netdev_sent_queue(dev, skb->len);
 	} else {
-		int i;
+		int i, len;
 
 		vp->tx_ring[entry].frag[0].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data,
 										skb_headlen(skb), PCI_DMA_TODEVICE));
 		vp->tx_ring[entry].frag[0].length = cpu_to_le32(skb_headlen(skb));
+		len = skb_headlen(skb);
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
@@ -2180,16 +2193,21 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 						(void *)skb_frag_address(frag),
 						skb_frag_size(frag), PCI_DMA_TODEVICE));
 
-			if (i == skb_shinfo(skb)->nr_frags-1)
+			if (i == skb_shinfo(skb)->nr_frags - 1) {
 					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(skb_frag_size(frag)|LAST_FRAG);
-			else
+					len += skb_frag_size(frag) | LAST_FRAG;
+			} else {
 					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(skb_frag_size(frag));
+					len += skb_frag_size(frag);
+			}
 		}
+		netdev_sent_queue(dev, len);
 	}
 #else
 	vp->tx_ring[entry].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data, skb->len, PCI_DMA_TODEVICE));
 	vp->tx_ring[entry].length = cpu_to_le32(skb->len | LAST_FRAG);
 	vp->tx_ring[entry].status = cpu_to_le32(skb->len | TxIntrUploaded);
+	netdev_sent_queue(dev, skb->len | LAST_FRAG);
 #endif
 
 	spin_lock_irqsave(&vp->lock, flags);
@@ -2234,6 +2252,7 @@ vortex_interrupt(int irq, void *dev_id)
 	int status;
 	int work_done = max_interrupt_work;
 	int handled = 0;
+	unsigned bytes_compl = 0, pkts_compl = 0;
 
 	ioaddr = vp->ioaddr;
 	spin_lock(&vp->lock);
@@ -2279,8 +2298,12 @@ vortex_interrupt(int irq, void *dev_id)
 
 		if (status & DMADone) {
 			if (ioread16(ioaddr + Wn7_MasterStatus) & 0x1000) {
+				int len;
 				iowrite16(0x1000, ioaddr + Wn7_MasterStatus); /* Ack the event. */
-				pci_unmap_single(VORTEX_PCI(vp), vp->tx_skb_dma, (vp->tx_skb->len + 3) & ~3, PCI_DMA_TODEVICE);
+				len = (vp->tx_skb->len + 3) & ~3;
+				pci_unmap_single(VORTEX_PCI(vp), vp->tx_skb_dma, len, PCI_DMA_TODEVICE);
+				bytes_compl += len;
+				pkts_compl++;
 				dev_kfree_skb_irq(vp->tx_skb); /* Release the transferred buffer */
 				if (ioread16(ioaddr + TxFree) > 1536) {
 					/*
@@ -2327,6 +2350,9 @@ vortex_interrupt(int irq, void *dev_id)
 
 	spin_unlock(&vp->window_lock);
 
+	if (unlikely(bql_disable))
+		netdev_completed_queue(dev, pkts_compl, bytes_compl);
+
 	if (vortex_debug > 4)
 		pr_debug("%s: exiting interrupt, status %4.4x.\n",
 			   dev->name, status);
@@ -2348,6 +2374,7 @@ boomerang_interrupt(int irq, void *dev_id)
 	void __iomem *ioaddr;
 	int status;
 	int work_done = max_interrupt_work;
+	unsigned bytes_compl = 0, pkts_compl = 0;
 
 	ioaddr = vp->ioaddr;
 
@@ -2420,6 +2447,8 @@ boomerang_interrupt(int irq, void *dev_id)
 					pci_unmap_single(VORTEX_PCI(vp),
 						le32_to_cpu(vp->tx_ring[entry].addr), skb->len, PCI_DMA_TODEVICE);
 #endif
+					bytes_compl += skb->len;
+					pkts_compl++;
 					dev_kfree_skb_irq(skb);
 					vp->tx_skbuff[entry] = NULL;
 				} else {
@@ -2467,6 +2496,10 @@ boomerang_interrupt(int irq, void *dev_id)
 handler_exit:
 	vp->handling_irq = 0;
 	spin_unlock(&vp->lock);
+
+	if (unlikely(bql_disable))
+		netdev_completed_queue(dev, pkts_compl, bytes_compl);
+
 	return IRQ_HANDLED;
 }
 
@@ -2660,6 +2693,8 @@ vortex_down(struct net_device *dev, int final_down)
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
 
+	if (unlikely(bql_disable))
+		netdev_reset_queue(dev);
 	netif_stop_queue (dev);
 
 	del_timer_sync(&vp->rx_oom_timer);
-- 
1.8.4.1
