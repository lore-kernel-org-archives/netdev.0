From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 1/8] net: smc91x: Fix device tree based configuration
 so it's usable
Date: Sat, 16 Nov 2013 07:16:40 -0800
Message-ID: <20131116151640.GJ10317@atomide.com>
References: <1384396537-3486-1-git-send-email-tony@atomide.com>
 <1384396537-3486-2-git-send-email-tony@atomide.com>
 <20131114110324.GC16396@e106331-lin.cambridge.arm.com>
 <20131114160813.GC10317@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:22426 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035Ab3KPPQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 10:16:46 -0500
Content-Disposition: inline
In-Reply-To: <20131114160813.GC10317@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Tony Lindgren <tony@atomide.com> [131114 08:09]:
> * Mark Rutland <mark.rutland@arm.com> [131114 03:04]:
> > 
> > In the driver the supported access sizes are not mutually exclusive.  It
> > would be nice for the binding to have the same property.
> 
> Hmm indeed. How about we add reg-io-width-mask:
> 
> 	1 = 8-bit access
> 	2 = 16-bit access
> 	4 = 32-bit access
> 	...
> 
> So for a driver to support 8, 16 and 32-bit access the mask would
> be:
> 	reg-io-width-mask = <7>;
> 
> Although the values for reg-io-width would support masks too, it
> might be better to have reg-io-width-mask to avoid confusion.
> 
> Or do you have any better ideas?
>  
> > > +- smsc,nowait : Setup for fast register access with no waits
> > 
> > I'm confused by what this means. When would this be selected, and when
> > wouldn't it be?
> 
> The driver has a module parameter for it and the comments say:
> 
> "nowait  = 0 for normal wait states, 1 eliminates additional wait states"
> 
> Most platforms seem to set it, but the default is to not set it.
> I guess we could that be a module parameter for now as that's a
> timing optimization.

Here's what I was thinking with the reg-io-width-mask. Anybody
have comments on using reg-io-width vs reg-io-width-mask?

Regards,

Tony


From: Tony Lindgren <tony@atomide.com>
Date: Wed, 13 Nov 2013 16:36:37 -0800
Subject: [PATCH] net: smc91x: Fix device tree based configuration so it's usable

Commit 89ce376c6bdc (drivers/net: Use of_match_ptr() macro in smc91x.c)
added minimal device tree support to smc91x, but it's not working on
many platforms because of the lack of some key configuration bits.

Fix the issue by parsing the necessary configuration like the
smc911x driver is doing.

Cc: Nicolas Pitre <nico@fluxnic.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: devicetree@vger.kernel.org
Signed-off-by: Tony Lindgren <tony@atomide.com>

--- a/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
+++ b/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
@@ -8,3 +8,7 @@ Required properties:
 Optional properties:
 - phy-device : phandle to Ethernet phy
 - local-mac-address : Ethernet mac address to use
+- reg-io-width-mask : Mask of sizes (in bytes) of the IO accesses that
+  are supported on the device.  Valid value for SMSC LAN91c111 are
+  1, 2 or 4.  If it's omitted or invalid, the size would be 2 meaning
+  16-bit access only.
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -82,6 +82,7 @@ static const char version[] =
 #include <linux/mii.h>
 #include <linux/workqueue.h>
 #include <linux/of.h>
+#include <linux/of_device.h>
 
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -2189,6 +2190,15 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
 	}
 }
 
+#if IS_BUILTIN(CONFIG_OF)
+static const struct of_device_id smc91x_match[] = {
+	{ .compatible = "smsc,lan91c94", },
+	{ .compatible = "smsc,lan91c111", },
+	{},
+};
+MODULE_DEVICE_TABLE(of, smc91x_match);
+#endif
+
 /*
  * smc_init(void)
  *   Input parameters:
@@ -2203,6 +2213,8 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
 static int smc_drv_probe(struct platform_device *pdev)
 {
 	struct smc91x_platdata *pd = dev_get_platdata(&pdev->dev);
+	struct device_node *np = pdev->dev.of_node;
+	const struct of_device_id *match = NULL;
 	struct smc_local *lp;
 	struct net_device *ndev;
 	struct resource *res, *ires;
@@ -2222,11 +2234,31 @@ static int smc_drv_probe(struct platform_device *pdev)
 	 */
 
 	lp = netdev_priv(ndev);
+	lp->cfg.flags = 0;
 
 	if (pd) {
 		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
 		lp->io_shift = SMC91X_IO_SHIFT(lp->cfg.flags);
-	} else {
+	}
+
+#if IS_BUILTIN(CONFIG_OF)
+	match = of_match_device(of_match_ptr(smc91x_match), &pdev->dev);
+	if (match) {
+		u32 val;
+
+		of_property_read_u32(np, "reg-io-width", &val);
+		if (val == 0)
+			lp->cfg.flags |= SMC91X_USE_16BIT;
+		if (val & 1)
+			lp->cfg.flags |= SMC91X_USE_8BIT;
+		if (val & 2)
+			lp->cfg.flags |= SMC91X_USE_16BIT;
+		if (val & 4)
+			lp->cfg.flags |= SMC91X_USE_32BIT;
+	}
+#endif
+
+	if (!pd && !match) {
 		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
@@ -2375,15 +2407,6 @@ static int smc_drv_resume(struct device *dev)
 	return 0;
 }
 
-#ifdef CONFIG_OF
-static const struct of_device_id smc91x_match[] = {
-	{ .compatible = "smsc,lan91c94", },
-	{ .compatible = "smsc,lan91c111", },
-	{},
-};
-MODULE_DEVICE_TABLE(of, smc91x_match);
-#endif
-
 static struct dev_pm_ops smc_drv_pm_ops = {
 	.suspend	= smc_drv_suspend,
 	.resume		= smc_drv_resume,
