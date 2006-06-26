From: Valerie Henson <val_henson@linux.intel.com>
Subject: [PATCH] Fix tulip shutdown DMA/irq race
Date: Mon, 26 Jun 2006 15:31:58 -0700
Message-ID: <20060626223157.GH19196@goober>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <20060622004339.GO19196@goober> <20060623050029.GB23383@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:13962 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S933121AbWFZWd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 18:33:26 -0400
To: Grant Grundler <grundler@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <20060623050029.GB23383@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@parisc-linux.org>

IRQs are racing with tulip_down(). DMA can be restarted by the
interrupt handler _after_ we call tulip_stop_rxtx() and the DMA
buffers are unmapped.  The result is an MCA (hard crash on ia64)
because of an IO TLB miss.  The long-term fix is to make the interrupt
handler shutdown aware.

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
Acked-by: Valerie Henson <val_henson@linux.intel.com>

---

 tulip_core.c |   37 ++++++++++++++++++++++++-------------
 1 files changed, 24 insertions(+), 13 deletions(-)

diff -Nru a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c	2006-06-22 16:24:11 -07:00
+++ b/drivers/net/tulip/tulip_core.c	2006-06-22 16:24:11 -07:00
@@ -18,11 +18,11 @@
 
 #define DRV_NAME	"tulip"
 #ifdef CONFIG_TULIP_NAPI
-#define DRV_VERSION    "1.1.13-NAPI" /* Keep at least for test */
+#define DRV_VERSION    "1.1.14-NAPI" /* Keep at least for test */
 #else
-#define DRV_VERSION	"1.1.13"
+#define DRV_VERSION	"1.1.14"
 #endif
-#define DRV_RELDATE	"May 11, 2002"
+#define DRV_RELDATE	"May 6, 2006"
 
 
 #include <linux/module.h>
@@ -739,23 +739,36 @@
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
@@ -781,7 +794,6 @@
 		printk (KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
 			dev->name, ioread32 (ioaddr + CSR5));
 
-	free_irq (dev->irq, dev);
 
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
@@ -1752,7 +1764,6 @@
 		tulip_down(dev);
 
 	netif_device_detach(dev);
-	free_irq(dev->irq, dev);
 
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
