From: akpm@linux-foundation.org
Subject: [patch 06/10] tulip: fix shutdown DMA/irq race
Date: Mon, 26 Mar 2007 21:47:25 -0800
Message-ID: <200703270547.l2R5lPEk008266@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	grundler@parisc-linux.org, val_henson@linux.intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40427 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934030AbXC0FvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:51:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@parisc-linux.org>

IRQs are racing with tulip_down().  DMA can be restarted by the interrupt
handler _after_ we call tulip_stop_rxtx() and the DMA buffers are unmapped.
 The result is an MCA (hard crash on ia64) because of an IO TLB miss.  The
long-term fix is to make the interrupt handler shutdown aware.

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
Acked-by: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/tulip_core.c |   31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff -puN drivers/net/tulip/tulip_core.c~tulip-fix-shutdown-dma-irq-race drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c~tulip-fix-shutdown-dma-irq-race
+++ a/drivers/net/tulip/tulip_core.c
@@ -734,23 +734,36 @@ static void tulip_down (struct net_devic
 #endif
 	spin_lock_irqsave (&tp->lock, flags);
 
+	/*
+	  FIXME: We should really add a shutdown-in-progress flag and
+	  check it in the interrupt handler to see whether we should
+	  reenable DMA or not.  The preferred ordering here would be:
+
+	  stop DMA engine
+	  disable interrupts
+	  remove DMA resources
+	  free_irq()
+
+	  The below works but is non-obvious and doesn't match the
+	  ordering of bring-up. -VAL
+	*/
+
 	/* Disable interrupts by clearing the interrupt mask. */
 	iowrite32 (0x00000000, ioaddr + CSR7);
+	ioread32 (ioaddr + CSR7);	/* flush posted write */
 
-	/* Stop the Tx and Rx processes. */
-	tulip_stop_rxtx(tp);
+	spin_unlock_irqrestore (&tp->lock, flags);
 
-	/* prepare receive buffers */
-	tulip_refill_rx(dev);
+	free_irq (dev->irq, dev);	/* no more races after this */
+	tulip_stop_rxtx(tp);		/* Stop DMA */
 
-	/* release any unconsumed transmit buffers */
-	tulip_clean_tx_ring(tp);
+	/* Put driver back into the state we start with */
+	tulip_refill_rx(dev);		/* prepare RX buffers */
+	tulip_clean_tx_ring(tp);	/* clean up unsent TX buffers */
 
 	if (ioread32 (ioaddr + CSR6) != 0xffffffff)
 		tp->stats.rx_missed_errors += ioread32 (ioaddr + CSR8) & 0xffff;
 
-	spin_unlock_irqrestore (&tp->lock, flags);
-
 	init_timer(&tp->timer);
 	tp->timer.data = (unsigned long)dev;
 	tp->timer.function = tulip_tbl[tp->chip_id].media_timer;
@@ -776,7 +789,6 @@ static int tulip_close (struct net_devic
 		printk (KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
 			dev->name, ioread32 (ioaddr + CSR5));
 
-	free_irq (dev->irq, dev);
 
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
@@ -1747,7 +1759,6 @@ static int tulip_suspend (struct pci_dev
 		tulip_down(dev);
 
 	netif_device_detach(dev);
-	free_irq(dev->irq, dev);
 
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
_
