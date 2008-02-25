From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [patch 2.6.25-rc3] smc91x section fix
Date: Mon, 25 Feb 2008 07:02:20 +0100
Message-ID: <20080225060220.GA12459@uranus.ravnborg.org>
References: <20080225033411.941C328DEAA@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:59335 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752250AbYBYGCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 01:02:08 -0500
Content-Disposition: inline
In-Reply-To: <20080225033411.941C328DEAA@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 24, 2008 at 07:34:11PM -0800, David Brownell wrote:
> Section fixup:
> 
> WARNING: drivers/net/built-in.o(.text+0x1a2c): Section mismatch
> 	in reference from the function smc_drv_probe()
> 	to the function .init.text:smc_probe()
> The function smc_drv_probe() references
> the function __init smc_probe().
> This is often because smc_drv_probe lacks a __init
> annotation or the annotation of smc_probe is wrong.
> 
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> ---
>  drivers/net/smc91x.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/drivers/net/smc91x.c	2008-02-24 18:50:32.000000000 -0800
> +++ b/drivers/net/smc91x.c	2008-02-24 19:16:29.000000000 -0800
> @@ -2121,7 +2121,7 @@ static void smc_release_datacs(struct pl
>   *	0 --> there is a device
>   *	anything else, error
>   */
> -static int smc_drv_probe(struct platform_device *pdev)
> +static int __init smc_drv_probe(struct platform_device *pdev)
>  {
>  	struct net_device *ndev;
>  	struct resource *res, *ires;

>From a quick look this is wrong.
smc_drv_probe is assined the .probe member so it is used during
hotplug and thus should be __devinit.
Likewise smc_probe is used by smc_drv_probe and thus smc_probe
should be __devinit too.

So something like the appended. On my way out of the door so
not even build tested!


	Sam

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 4020e9e..640bca5 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1775,7 +1775,7 @@ static int __init smc_findirq(void __iomem *ioaddr)
  * o  actually GRAB the irq.
  * o  GRAB the region
  */
-static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr,
+static int __devinit smc_probe(struct net_device *dev, void __iomem *ioaddr,
 			    unsigned long irq_flags)
 {
 	struct smc_local *lp = netdev_priv(dev);
@@ -2121,7 +2121,7 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
  *	0 --> there is a device
  *	anything else, error
  */
-static int smc_drv_probe(struct platform_device *pdev)
+static int __devinit smc_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct resource *res, *ires;
