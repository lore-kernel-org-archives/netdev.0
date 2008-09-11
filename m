From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 1/2] [PATCH] ne.c fix rmmod, platform driver
 improvements
Date: Thu, 11 Sep 2008 22:55:03 +0900 (JST)
Message-ID: <20080911.225503.59032738.anemo@mba.ocn.ne.jp>
References: <20080909025434.GB28469@spacedout.fries.net>
	<20080909025821.GA25019@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@gmail.com, akpm@linux-foundation.org,
	p_gortmaker@yahoo.com, alan@lxorguk.ukuu.org.uk, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: david@fries.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:57581 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752521AbYIKNy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2008 09:54:56 -0400
In-Reply-To: <20080909025821.GA25019@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Sep 2008 21:58:21 -0500, David Fries <david@fries.net> wrote:
>  static int __init ne_drv_probe(struct platform_device *pdev)
>  {
>  	struct net_device *dev;
> -	struct resource *res;
> -	int err, irq;
> -
> -	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
> -	irq = platform_get_irq(pdev, 0);
> -	if (!res || irq < 0)
> -		return -ENODEV;
> +	int err, this_dev = pdev->id;
>  
>  	dev = alloc_eip_netdev();
>  	if (!dev)
>  		return -ENOMEM;
> -	dev->irq = irq;
> -	dev->base_addr = res->start;
> +	dev->base_addr = io[this_dev];
> +	dev->irq = irq[this_dev];
> +	dev->mem_end = bad[this_dev];
>  	err = do_ne_probe(dev);

This breaks current users of ne platform driver.  Here is a quick fix
upon your patch.

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 221e188..8b08433 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -813,10 +813,26 @@ static int __init ne_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	int err, this_dev = pdev->id;
+	struct resource *res;
 
 	dev = alloc_eip_netdev();
 	if (!dev)
 		return -ENOMEM;
+	
+	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
+	if (res) {
+		dev->base_addr = res->start;
+		dev->irq = platform_get_irq(pdev, 0);
+		err = do_ne_probe(dev);
+		if (err) {
+			free_netdev(dev);
+			return err;
+		}
+		platform_set_drvdata(pdev, dev);
+		return 0;
+	}
+	if (this_dev < 0 || this_dev >= MAX_NE_CARDS)
+		return -EINVAL;
 	dev->base_addr = io[this_dev];
 	dev->irq = irq[this_dev];
 	dev->mem_end = bad[this_dev];
