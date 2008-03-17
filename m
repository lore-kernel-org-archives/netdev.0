From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
Date: Mon, 17 Mar 2008 23:31:53 +0100
Message-ID: <20080317223153.GA3462@electric-eye.fr.zoreil.com>
References: <200803052345.06610.florian.fainelli@telecomint.eu> <200803081905.46020.florian.fainelli@telecomint.eu> <20080310223007.GA2887@electric-eye.fr.zoreil.com> <200803131155.28164.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, Felix Fietkau <nbd@openwrt.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43457 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752441AbYCQWuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 18:50:23 -0400
Content-Disposition: inline
In-Reply-To: <200803131155.28164.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <florian.fainelli@telecomint.eu> :
[...]
> Thanks for your comments, here is a third try which adresses the
> mentionned problems.

Sorry for the delay.

1. skb_new->dev = dev; in korina_rx() is useless. eth_type_trans() will
   do it anyway.

2. skb->dev = dev; in korina_init() is useless as well.

3. korina_rx() still drops the received skb each time dev_alloc_skb fails.
   This is far from optimal.

4. The value returned from korina_init() is now checked. That's fine.
   It is carefully overwritten with -ENOMEM when korina_init() fails
   while it could/should simply propagate the error code returned from
   korina_init() (which currentl equals -ENOMEM btw).

5. I would add some korina_{alloc/free}_ring() helpers to remove
   dev_kfree_skb_any() and dev_alloc_skb from korina_init(), then release
   the ring when it is really needed (i.e. in korina_restart() instead of
   korina_init()).

6. korina_open() leaks memory allocated in korina_init() if any of the
   request_irq() fails...

7. ... and if none of the request_irq fails, it should probably skip the
   error path :o)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 04ce894..f866fe4 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -956,59 +956,57 @@ static int korina_open(struct net_device *dev)
 	if (korina_init(dev) < 0) {
 		printk(KERN_ERR DRV_NAME "%s: cannot open device\n", dev->name);
 		ret = -ENOMEM;
-		goto err_rx_irq;
+		goto out;
 	}
 
 	/* Install the interrupt handler
 	 * that handles the Done Finished
 	 * Ovr and Und Events */
-	if (request_irq(lp->rx_irq, &korina_rx_dma_interrupt,
-		IRQF_SHARED | IRQF_DISABLED,
-			"Korina ethernet Rx", dev)) {
+	ret = request_irq(lp->rx_irq, &korina_rx_dma_interrupt,
+		IRQF_SHARED | IRQF_DISABLED, "Korina ethernet Rx", dev);
+	if (ret < 0) {
 		printk(KERN_ERR DRV_NAME "%s: unable to get Rx DMA IRQ %d\n",
 		    dev->name, lp->rx_irq);
-		ret = -ENXIO;
-		goto err_rx_irq;
+		goto err_release_0;
 	}
-	if (request_irq(lp->tx_irq, &korina_tx_dma_interrupt,
-		IRQF_SHARED | IRQF_DISABLED,
-			"Korina ethernet Tx", dev)) {
+
+	ret = request_irq(lp->tx_irq, &korina_tx_dma_interrupt,
+		IRQF_SHARED | IRQF_DISABLED, "Korina ethernet Tx", dev);
+	if (ret < 0) {
 		printk(KERN_ERR DRV_NAME "%s: unable to get Tx DMA IRQ %d\n",
 		    dev->name, lp->tx_irq);
-		free_irq(lp->rx_irq, dev);
-		ret = -ENXIO;
-		goto err_tx_irq;
+		goto err_free_rx_irq_1;
 	}
 
 	/* Install handler for overrun error. */
-	if (request_irq(lp->ovr_irq, &korina_ovr_interrupt,
-			IRQF_SHARED | IRQF_DISABLED,
-			"Ethernet Overflow", dev)) {
+	ret = request_irq(lp->ovr_irq, &korina_ovr_interrupt,
+			IRQF_SHARED | IRQF_DISABLED, "Ethernet Overflow", dev);
+	if (ret < 0) {
 		printk(KERN_ERR DRV_NAME"%s: unable to get OVR IRQ %d\n",
 		    dev->name, lp->ovr_irq);
-		ret = -ENXIO;
-		goto err_ovr_irq;
+		goto err_free_tx_irq_2;
 	}
 
 	/* Install handler for underflow error. */
-	if (request_irq(lp->und_irq, &korina_und_interrupt,
-			IRQF_SHARED | IRQF_DISABLED,
-			"Ethernet Underflow", dev)) {
+	ret = request_irq(lp->und_irq, &korina_und_interrupt,
+			IRQF_SHARED | IRQF_DISABLED, "Ethernet Underflow", dev);
+	if (ret < 0)
 		printk(KERN_ERR DRV_NAME "%s: unable to get UND IRQ %d\n",
 		    dev->name, lp->und_irq);
-		ret = -ENXIO;
-		goto err_und_irq;
+		goto err_free_out_irq_3;
 	}
+out:
+	return ret;
 
-err_und_irq:
+err_free_ovr_irq_3:
 	free_irq(lp->ovr_irq, dev);
-err_ovr_irq:
+err_free_tx_irq_2:
 	free_irq(lp->tx_irq, dev);
-err_tx_irq:
+err_free_rx_irq_1:
 	free_irq(lp->rx_irq, dev);
-err_rx_irq:
-
-	return ret;
+err_release_0:
+	// Help me, I'm leaking memory allocated in korina_init().
+	goto out;
 }
 
 static int korina_close(struct net_device *dev)


8. korinal_close() leaks the memory allocated in korina_init().

9. The void * casts in korina_remove() are useless.

10. The casts from void * to struct net_device * are not needed in 
    korina_tx_dma_interrupt, korina_und_interrupt and korina_ovr_interrupt
    either.

11. Same thing as 10 with platform_data and (struct korina_device *) in
    korina_probe. You could use platform_get_drvdata btw.

12. I am not sure that the unbalanced use of disable_irq() in korina_close()
    is really polite when one of the irq is shared.

13. Add a "FIXME: check korina_restart returned status code" somewhere.

14. Remove kfree(lp) and kfree(bif->dev) from korina_remove(). free_netdev()
    will clean the allocated device.

15. Nit: there are a few EOL tabs and tabs after space.

-- 
Ueimor
