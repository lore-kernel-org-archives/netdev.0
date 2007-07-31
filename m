From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [BUG] ISIC + 2.6.22 (via-rhine)
Date: Tue, 31 Jul 2007 14:23:33 -0700
Message-ID: <1185917013.2766.12.camel@laptopd505.fenrus.org>
References: <46AFA576.1060902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Xose Vazquez Perez <xose.vazquez@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51764 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757147AbXGaVXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 17:23:53 -0400
In-Reply-To: <46AFA576.1060902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> =================================
> [ INFO: inconsistent lock state ]
> 2.6.22 #1
> ---------------------------------
> inconsistent {in-hardirq-W} -> {hardirq-on-W} usage.
> swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
>   (&rp->lock){++..}, at: [<f8c890db>] rhine_tx_timeout+0x6f/0xf4 [via_rhine]



this is a case of homegrown locking: the via-rhine driver does

        /* protect against concurrent rx interrupts */
        disable_irq(rp->pdev->irq);

        spin_lock(&rp->lock);

        /* clear all descriptors */
        free_tbufs(dev);
        free_rbufs(dev);
        alloc_tbufs(dev);
        alloc_rbufs(dev);

        /* Reinitialize the hardware. */
        rhine_chip_reset(dev);
        init_registers(dev);  

        spin_unlock(&rp->lock);
        enable_irq(rp->pdev->irq);


as a way to protect code against interrupts... rather than using the
normal mechanism.


the annotation is pretty simple (untested, not even compiled):

--- linux-2.6.22/drivers/net/via-rhine.c.org	2007-07-31 14:22:06.000000000 -0700
+++ linux-2.6.22/drivers/net/via-rhine.c	2007-07-31 14:22:26.000000000 -0700
@@ -1191,7 +1191,7 @@
 	       mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
 
 	/* protect against concurrent rx interrupts */
-	disable_irq(rp->pdev->irq);
+	disable_irq_lockdep(rp->pdev->irq);
 
 	spin_lock(&rp->lock);
 
@@ -1206,7 +1206,7 @@
 	init_registers(dev);
 
 	spin_unlock(&rp->lock);
-	enable_irq(rp->pdev->irq);
+	enable_irq_lockdep(rp->pdev->irq);
 
 	dev->trans_start = jiffies;
 	rp->stats.tx_errors++;


