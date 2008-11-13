From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Thu, 13 Nov 2008 14:08:24 -0800 (PST)
Message-ID: <20081113.140824.156293734.davem@davemloft.net>
References: <20081112.041143.11487260.davem@davemloft.net>
	<1226494179.6834.64.camel@localhost.localdomain>
	<1226566222.6834.76.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36090
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752781AbYKMWIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 17:08:24 -0500
In-Reply-To: <1226566222.6834.76.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Thu, 13 Nov 2008 09:50:22 +0100

> Another bug... while unloading the niu module.
> 
> During my testing I'm unloading/loading the niu module, I usually take
> down the interfaces _before_ unloading the module, but I forgot one
> time, and got the following BUG in the kern log.
> 
> niu: niu_put_parent: port[3]
> niu 0000:0b:00.3: PCI INT D disabled
> niu: niu_put_parent: port[2]
> niu 0000:0b:00.2: PCI INT C disabled
> niu: niu_put_parent: port[1]
> niu 0000:0b:00.1: PCI INT B disabled
> ------------[ cut here ]------------
> kernel BUG at drivers/pci/msi.c:630!

Weird.  When the module is unloaded, unregister_netdev() will
do a dev_close() which will invoke dev->stop() which is
niu_close().

And niu_close() will call free_irq() on every MSI interrupt
registered in niu_open().

So I can't see how this can happen but obviously it is happening.

I suspect that something might be changing np->num_ldg, but
anyways the following debugging patch should provide some
clues.  Please reproduce this and send the logs it generates.

Thanks.

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index d8463b1..c0eedd3 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -5600,12 +5600,20 @@ static int niu_request_irq(struct niu *np)
 	int i, j, err;
 
 	err = 0;
+#if 1
+	dev_err(np->device, PFX "%s: niu_request_irq() num_ldg[%d]\n",
+		np->dev->name, np->num_ldg);
+#endif
 	for (i = 0; i < np->num_ldg; i++) {
 		struct niu_ldg *lp = &np->ldg[i];
 
 		err = request_irq(lp->irq, niu_interrupt,
 				  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
 				  np->dev->name, lp);
+#if 1
+		dev_err(np->device, PFX "%s: Request IRQ %u, lp(%p), err=%d\n",
+			np->dev->name, lp->irq, lp, err);
+#endif
 		if (err)
 			goto out_free_irqs;
 
@@ -5617,6 +5625,11 @@ out_free_irqs:
 	for (j = 0; j < i; j++) {
 		struct niu_ldg *lp = &np->ldg[j];
 
+#if 1
+		dev_err(np->device, PFX "%s: out_free_irqs, "
+			"free IRQ %u, lp(%p)\n",
+			np->dev->name, lp->irq, lp);
+#endif
 		free_irq(lp->irq, lp);
 	}
 	return err;
@@ -5626,9 +5639,17 @@ static void niu_free_irq(struct niu *np)
 {
 	int i;
 
+#if 1
+	dev_err(np->device, PFX "%s: niu_free_irq() num_ldg[%d]\n",
+		np->dev->name, np->num_ldg);
+#endif
 	for (i = 0; i < np->num_ldg; i++) {
 		struct niu_ldg *lp = &np->ldg[i];
 
+#if 1
+		dev_err(np->device, PFX "%s: free IRQ %u, lp(%p)\n",
+			np->dev->name, lp->irq, lp);
+#endif
 		free_irq(lp->irq, lp);
 	}
 }
