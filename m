From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Tue, 13 Jun 2006 17:55:31 -0600
Message-ID: <20060613235531.GA4191@colo.lackof.org>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:41944 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S932236AbWFMXzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 19:55:35 -0400
To: Valerie Henson <val_henson@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <20060608170120.GI8246@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2006 at 11:01:20AM -0600, Grant Grundler wrote:
> Here is a new patch that moves free_irq() into tulip_down().
> The resulting code is structured the same as cp_close().

Val,
Two details are wrong in version 2 and are fixed in v3 (appended below):

o we don't need synchronize_irq() before calling free_irq().
  (It should be removed from cp_close() too)
  Thanks to willy for pointing me at kernel/irq/manage.c.

o tulip_stop_rxtx() has to be called _after_ free_irq().
  ie. v2 patch didn't fix the original race condition
  and when under test, dies about as fast as the original code.

Tested on rx4640 (HP IA64) for several hours.
Please apply.

thanks,
grant

Change Log:
	IRQs are racing with tulip_down(). DMA can be restarted _after_
	we call tulip_stop_rxtx() and the DMA buffers are unmapped.
	The result is an MCA (hard crash on ia64) because of an
	IO TLB miss.

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -18,11 +18,11 @@
 
 #define DRV_NAME	"tulip"
 #ifdef CONFIG_TULIP_NAPI
-#define DRV_VERSION    "1.1.13-NAPI" /* Keep at least for test */
+#define DRV_VERSION    "1.1.14-NAPI" /* Keep at least for test */
 #else
-#define DRV_VERSION	"1.1.13"
+#define DRV_VERSION	"1.1.14"
 #endif
-#define DRV_RELDATE	"December 15, 2004"
+#define DRV_RELDATE	"May 6, 2006"
 
 
 #include <linux/module.h>
@@ -741,21 +741,20 @@ static void tulip_down (struct net_devic
 
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
@@ -774,7 +773,6 @@ static int tulip_close (struct net_devic
 		printk (KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
 			dev->name, ioread32 (ioaddr + CSR5));
 
-	free_irq (dev->irq, dev);
 
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
@@ -1752,7 +1752,6 @@ static int tulip_suspend (struct pci_dev
 		tulip_down(dev);
 
 	netif_device_detach(dev);
-	free_irq(dev->irq, dev);
 
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
