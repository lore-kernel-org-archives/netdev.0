From: David Fries <david@fries.net>
Subject: Re: [PATCH 1/2] [PATCH] ne.c fix rmmod, platform driver improvements
Date: Sat, 13 Sep 2008 10:19:06 -0500
Message-ID: <20080913151906.GG28469@spacedout.fries.net>
References: <20080909025821.GA25019@spacedout.fries.net> <20080911.225503.59032738.anemo@mba.ocn.ne.jp> <20080913144457.GE28469@spacedout.fries.net> <20080914.001300.15242170.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.gortmaker@gmail.com, akpm@linux-foundation.org,
	p_gortmaker@yahoo.com, alan@lxorguk.ukuu.org.uk, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from SpacedOut.fries.net ([67.64.210.234]:51651 "EHLO
	SpacedOut.fries.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbYIMPUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2008 11:20:06 -0400
Content-Disposition: inline
In-Reply-To: <20080914.001300.15242170.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 14, 2008 at 12:13:00AM +0900, Atsushi Nemoto wrote:
> On Sat, 13 Sep 2008 09:44:57 -0500, David Fries <david@fries.net> wrote:
> > I reformatted your patch and added a comment.  Does this work for you?
> > 
> > diff --git a/drivers/net/ne.c b/drivers/net/ne.c
> ...
> >  	/* Update with any values found by probing. */
> > -	io[this_dev] = dev->base_addr;
> > -	irq[this_dev] = dev->irq;
> > +	if (0 <= this_dev && this_dev < MAX_NE_CARDS) {
> > +		io[this_dev] = dev->base_addr;
> > +		irq[this_dev] = dev->irq;
> > +	}
> >  	return 0;
> >  }
> 
> For now rbtx49xx ne platform devices use -1 for pdev->id, but it may
> change.  Please don't assume it.

Does this work?
-	if (0 <= this_dev && this_dev < MAX_NE_CARDS) {
+	if (!res) {

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index cd31e77..ede9b12 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -813,22 +813,37 @@ static int __init ne_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	int err, this_dev = pdev->id;
+	struct resource *res;
 
 	dev = alloc_eip_netdev();
 	if (!dev)
 		return -ENOMEM;
-	dev->base_addr = io[this_dev];
-	dev->irq = irq[this_dev];
-	dev->mem_end = bad[this_dev];
+
+	/* ne.c doesn't populate resources in platform_device, but
+	 * rbtx4927_ne_init and rbtx4938_ne_init do register devices
+	 * with resources.
+	 */
+	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
+	if (res) {
+		dev->base_addr = res->start;
+		dev->irq = platform_get_irq(pdev, 0);
+	} else {
+		dev->base_addr = io[this_dev];
+		dev->irq = irq[this_dev];
+		dev->mem_end = bad[this_dev];
+	}
 	err = do_ne_probe(dev);
 	if (err) {
 		free_netdev(dev);
 		return err;
 	}
 	platform_set_drvdata(pdev, dev);
+
 	/* Update with any values found by probing. */
-	io[this_dev] = dev->base_addr;
-	irq[this_dev] = dev->irq;
+	if (!res) {
+		io[this_dev] = dev->base_addr;
+		irq[this_dev] = dev->irq;
+	}
 	return 0;
 }
 

-- 
David Fries <david@fries.net>
http://fries.net/~david/ (PGP encryption key available)
