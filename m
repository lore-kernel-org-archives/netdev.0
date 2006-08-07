From: Kyle McMartin <kyle@parisc-linux.org>
Subject: [PATCH 6/9] [TULIP] Fix IRQ/DMA race
Date: Mon, 07 Aug 2006 20:53:29 +0000
Message-ID: <11549840343640-git-send-email-kyle@parisc-linux.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org> <11549840321096-git-send-email-kyle@parisc-linux.org> <1154984032324-git-send-email-kyle@parisc-linux.org> <115498403384-git-send-email-kyle@parisc-linux.org> <11549840341728-git-send-email-kyle@parisc-linux.org>
Reply-To: Kyle McMartin <kyle@parisc-linux.org>
Cc: grundler@parisc-linux.org, val_henson@linux.intel.com,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:8681 "EHLO hera.kernel.org")
	by vger.kernel.org with ESMTP id S932360AbWHGUx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 16:53:58 -0400
To: netdev@vger.kernel.org
In-Reply-To: <11549840341728-git-send-email-kyle@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@parisc-linux.org>

IRQs are racing with tulip_down().
DMA can be restarted by tulip_interrupt() _after_ we call
tulip_stop_rxtx() and the DMA buffers are unmapped.  The result
is an MCA (hard crash on ia64) because of an IO TLB miss.

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
---
 drivers/net/tulip/interrupt.c  |    4 ++++
 drivers/net/tulip/tulip_core.c |   17 +++++++----------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 99ccf2e..19faa0e 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -87,6 +87,10 @@ int tulip_refill_rx(struct net_device *d
 		}
 		tp->rx_ring[entry].status = cpu_to_le32(DescOwned);
 	}
+
+/* FIXME: restarting DMA breaks tulip_down() code path.
+   tulip_down() will unmap the RX and TX descriptors.
+ */
 	if(tp->chip_id == LC82C168) {
 		if(((ioread32(tp->base_addr + CSR5)>>17)&0x07) == 4) {
 			/* Rx stopped due to out of buffers,
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 81905f4..363e5f6 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -742,21 +742,20 @@ #endif
 
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
@@ -782,7 +781,6 @@ static int tulip_close (struct net_devic
 		printk (KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
 			dev->name, ioread32 (ioaddr + CSR5));
 
-	free_irq (dev->irq, dev);
 
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
@@ -1752,7 +1750,6 @@ static int tulip_suspend (struct pci_dev
 		tulip_down(dev);
 
 	netif_device_detach(dev);
-	free_irq(dev->irq, dev);
 
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
-- 
1.4.1.1

