From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [2.6 patch] net/phy/fixed.c: fix a use-after-free
Date: Sun, 3 Feb 2008 17:21:23 +0300
Message-ID: <20080203142123.GA6573@localhost.localdomain>
References: <20080202211502.GC9375@cs181133002.pp.htv.fi>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Vitaly Bordug <vitb@kernel.crashing.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:41700 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752782AbYBCOVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 09:21:34 -0500
Content-Disposition: inline
In-Reply-To: <20080202211502.GC9375@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 02, 2008 at 11:15:02PM +0200, Adrian Bunk wrote:
> This patch fixes a use-after-free introduced by
> commit a79d8e93d300adb84cccc38ac396cfb118c238ad and spotted by the 
> Coverity checker.

Nice catch.

We didn't encounter this bug because fixed.c is bool, so
module_exit isn't used. Thus, technically, we can remove it
completely.

But I prefer your patch, because later, we might want to create
library versions of the fixed_mdio_bus_{init,exit}. To use, for
example, with PCI ethernet card that might have MDIO-less PHY,
i.e. configuration is hardwired in the eeprom, but driver still
want to use phylib framework.

Thanks,

> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 20c51455b2faed63c3026fd4d7139e5a6a917d31 
> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
> index 73b6d39..ca9b040 100644
> --- a/drivers/net/phy/fixed.c
> +++ b/drivers/net/phy/fixed.c
> @@ -236,12 +236,12 @@ module_init(fixed_mdio_bus_init);
>  static void __exit fixed_mdio_bus_exit(void)
>  {
>  	struct fixed_mdio_bus *fmb = &platform_fmb;
> -	struct fixed_phy *fp;
> +	struct fixed_phy *fp, *tmp;
>  
>  	mdiobus_unregister(&fmb->mii_bus);
>  	platform_device_unregister(pdev);
>  
> -	list_for_each_entry(fp, &fmb->phys, node) {
> +	list_for_each_entry_safe(fp, tmp, &fmb->phys, node) {
>  		list_del(&fp->node);
>  		kfree(fp);
>  	}
> 
> 

-- 
Anton Vorontsov
email: cbou@mail.ru
backup email: ya-cbou@yandex.ru
irc://irc.freenode.net/bd2
