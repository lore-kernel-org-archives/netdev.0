From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCH 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 8 Jun 2006 11:01:20 -0600
Message-ID: <20060608170120.GI8246@colo.lackof.org>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Val Henson <val.henson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:54495 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S964912AbWFHRBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 13:01:22 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <44883778.8000209@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2006 at 10:43:04AM -0400, Jeff Garzik wrote:
...
> Perhaps cp_close() in 8139cp.c could be an example of a good ordering? 
> It stops the chip, syncs irqs, frees irq, then frees [thus unmapping] 
> the rings.

Here is a new patch that moves free_irq() into tulip_down().
The resulting code is structured the same as cp_close().

While I believe the code is correct, I'm not real happy
that tulip_up() and tulip_down() don't both deal with IRQs.
(ie not symetrical). Oh well, I can submit another patch
for that if Val doesn't want to wrangle that herself.

This is compile tested only.
I'll drop it on ia64/parisc servers later and retest.

thanks,
grant


Index: drivers/net/tulip/tulip_core.c
===================================================================
RCS file: /var/cvs/linux-2.6/drivers/net/tulip/tulip_core.c,v
retrieving revision 1.35
diff -u -p -r1.35 tulip_core.c
--- drivers/net/tulip/tulip_core.c	23 Apr 2006 15:18:28 -0000	1.35
+++ drivers/net/tulip/tulip_core.c	8 Jun 2006 16:25:43 -0000
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
@@ -743,6 +745,11 @@ static void tulip_down (struct net_devic
 	/* Stop the Tx and Rx processes. */
 	tulip_stop_rxtx(tp);
 
+	spin_unlock_irqrestore (&tp->lock, flags);
+
+	synchronize_irq(dev->irq);
+	free_irq (dev->irq, dev);
+
 	/* prepare receive buffers */
 	tulip_refill_rx(dev);
 
@@ -752,7 +759,6 @@ static void tulip_down (struct net_devic
 	if (ioread32 (ioaddr + CSR6) != 0xffffffff)
 		tp->stats.rx_missed_errors += ioread32 (ioaddr + CSR8) & 0xffff;
 
-	spin_unlock_irqrestore (&tp->lock, flags);
 
 	init_timer(&tp->timer);
 	tp->timer.data = (unsigned long)dev;
@@ -774,14 +780,13 @@ static int tulip_close (struct net_devic
 	int i;
 
 	netif_stop_queue (dev);
 
 	tulip_down (dev);
 
 	if (tulip_debug > 1)
 		printk (KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
 			dev->name, ioread32 (ioaddr + CSR5));
 
-	free_irq (dev->irq, dev);
 
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
@@ -1750,7 +1757,6 @@ static int tulip_suspend (struct pci_dev
 		tulip_down(dev);
 
 	netif_device_detach(dev);
-	free_irq(dev->irq, dev);
 
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
