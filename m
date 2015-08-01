From: Loganaden Velvindron <logan@elandsys.com>
Subject: [PATCH] Add BQL support for 3c59x, based on patch from Tino
 Reichardt.
Date: Fri, 31 Jul 2015 23:13:13 -0700
Message-ID: <20150801061313.GA12571@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.qubic.net ([208.69.177.116]:49908 "EHLO mx.elandsys.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbbHAGaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Aug 2015 02:30:01 -0400
Received: from mx.elandsys.com (IDENT:logan@localhost [127.0.0.1])
	by mx.elandsys.com (8.14.5/8.14.5) with ESMTP id t716DDAN000352
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 23:13:14 -0700 (PDT)
Received: (from logan@localhost)
	by mx.elandsys.com (8.14.5/8.14.5/Submit) id t716DDpF001931
	for netdev@vger.kernel.org; Fri, 31 Jul 2015 23:13:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested on 3Com PCI 3c905C Tornardo by running Flent multiple times.

Signed-off-by: Loganaden Velvindron <logan@elandsys.com>
---
 drivers/net/ethernet/3com/3c59x.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 2d1ce3c..5b1b818 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1726,6 +1726,7 @@ vortex_up(struct net_device *dev)
 	if (vp->cb_fn_base)			/* The PCMCIA people are idiots.  */
 		iowrite32(0x8000, vp->cb_fn_base + 4);
 	netif_start_queue (dev);
+	netdev_reset_queue(dev);
 err_out:
 	return err;
 }
@@ -2064,6 +2065,7 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
+	int skblen = skb->len;
 
 	/* Put out the doubleword header... */
 	iowrite32(skb->len, ioaddr + TX_FIFO);
@@ -2095,6 +2097,7 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
+	netdev_sent_queue(dev, skblen);
 
 	/* Clear the Tx status stack. */
 	{
@@ -2126,6 +2129,7 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	void __iomem *ioaddr = vp->ioaddr;
 	/* Calculate the next Tx descriptor entry. */
 	int entry = vp->cur_tx % TX_RING_SIZE;
+	int skblen = skb->len;
 	struct boom_tx_desc *prev_entry = &vp->tx_ring[(vp->cur_tx-1) % TX_RING_SIZE];
 	unsigned long flags;
 	dma_addr_t dma_addr;
@@ -2231,6 +2235,8 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	vp->cur_tx++;
+	netdev_sent_queue(dev, skblen);
+
 	if (vp->cur_tx - vp->dirty_tx > TX_RING_SIZE - 1) {
 		netif_stop_queue (dev);
 	} else {					/* Clear previous interrupt enable. */
@@ -2268,6 +2274,7 @@ vortex_interrupt(int irq, void *dev_id)
 	int status;
 	int work_done = max_interrupt_work;
 	int handled = 0;
+	unsigned int bytes_compl = 0, pkts_compl = 0;	
 
 	ioaddr = vp->ioaddr;
 	spin_lock(&vp->lock);
@@ -2315,6 +2322,8 @@ vortex_interrupt(int irq, void *dev_id)
 			if (ioread16(ioaddr + Wn7_MasterStatus) & 0x1000) {
 				iowrite16(0x1000, ioaddr + Wn7_MasterStatus); /* Ack the event. */
 				pci_unmap_single(VORTEX_PCI(vp), vp->tx_skb_dma, (vp->tx_skb->len + 3) & ~3, PCI_DMA_TODEVICE);
+				pkts_compl++;
+				bytes_compl += vp->tx_skb->len;
 				dev_kfree_skb_irq(vp->tx_skb); /* Release the transferred buffer */
 				if (ioread16(ioaddr + TxFree) > 1536) {
 					/*
@@ -2359,6 +2368,7 @@ vortex_interrupt(int irq, void *dev_id)
 		iowrite16(AckIntr | IntReq | IntLatch, ioaddr + EL3_CMD);
 	} while ((status = ioread16(ioaddr + EL3_STATUS)) & (IntLatch | RxComplete));
 
+	netdev_completed_queue(dev, pkts_compl, bytes_compl);
 	spin_unlock(&vp->window_lock);
 
 	if (vortex_debug > 4)
@@ -2383,6 +2393,7 @@ boomerang_interrupt(int irq, void *dev_id)
 	int status;
 	int work_done = max_interrupt_work;
 	int handled = 0;
+	unsigned int bytes_compl = 0, pkts_compl = 0;
 
 	ioaddr = vp->ioaddr;
 
@@ -2456,6 +2467,8 @@ boomerang_interrupt(int irq, void *dev_id)
 					pci_unmap_single(VORTEX_PCI(vp),
 						le32_to_cpu(vp->tx_ring[entry].addr), skb->len, PCI_DMA_TODEVICE);
 #endif
+					pkts_compl++;
+					bytes_compl += skb->len;
 					dev_kfree_skb_irq(skb);
 					vp->tx_skbuff[entry] = NULL;
 				} else {
@@ -2496,6 +2509,7 @@ boomerang_interrupt(int irq, void *dev_id)
 			iowrite32(0x8000, vp->cb_fn_base + 4);
 
 	} while ((status = ioread16(ioaddr + EL3_STATUS)) & IntLatch);
+	netdev_completed_queue(dev, pkts_compl, bytes_compl);
 
 	if (vortex_debug > 4)
 		pr_debug("%s: exiting interrupt, status %4.4x.\n",
@@ -2697,7 +2711,8 @@ vortex_down(struct net_device *dev, int final_down)
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
 
-	netif_stop_queue (dev);
+	netdev_reset_queue(dev);
+	netif_stop_queue(dev);
 
 	del_timer_sync(&vp->rx_oom_timer);
 	del_timer_sync(&vp->timer);
-- 
2.4.5
