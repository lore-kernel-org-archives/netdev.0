From: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2] net: smc91x: Fix device tree based configuration so
 it's usable
Date: Wed, 11 Dec 2013 13:22:11 -0800
Message-ID: <20131211212211.GQ3448@atomide.com>
References: <20131127185657.GA26766@atomide.com>
 <52A8ADE6.8010209@ti.com>
 <20131211.154426.2252395344655389568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nm-l0cyMroinI0@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131211.154426.2252395344655389568.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> [131211 12:45]:
> From: Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>
> > please feel free to add my:
> > Acked-by: Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>
> > 
> > Also tested on SDP2430:
> > http://pastebin.mozilla.org/3756403
> 
> That patch needs changes, it adds a warning when CONFIG_OF is disabled
> because the variable 'np' only gets used in the CONFIG_OF protected
> code block yet is declared unconditionally.

Oops, sorry about that I thought I had tested it with omap1_defconfig
that's using the legacy booting.

Below is a fixed version, I kept Nishant's ack as the change was to
just to move np to be within the CONFIG_OF block.

Regards,

Tony

8< --------------------------------
From: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
Date: Wed, 11 Dec 2013 13:04:27 -0800
Subject: [PATCH] net: smc91x: Fix device tree based configuration so it's usable

Commit 89ce376c6bdc (drivers/net: Use of_match_ptr() macro in smc91x.c)
added minimal device tree support to smc91x, but it's not working on
many platforms because of the lack of some key configuration bits.

Fix the issue by parsing the necessary configuration like the
smc911x driver is doing. As most smc91x users seem to use 16-bit
access, let's default to that if no reg-io-width is specified.

Cc: Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Acked-by: Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>
Signed-off-by: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>

--- a/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
+++ b/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
@@ -8,3 +8,7 @@ Required properties:
 Optional properties:
 - phy-device : phandle to Ethernet phy
 - local-mac-address : Ethernet mac address to use
+- reg-io-width : Mask of sizes (in bytes) of the IO accesses that
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
@@ -2184,6 +2185,15 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
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
@@ -2198,6 +2208,7 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
 static int smc_drv_probe(struct platform_device *pdev)
 {
 	struct smc91x_platdata *pd = dev_get_platdata(&pdev->dev);
+	const struct of_device_id *match = NULL;
 	struct smc_local *lp;
 	struct net_device *ndev;
 	struct resource *res, *ires;
@@ -2217,11 +2228,34 @@ static int smc_drv_probe(struct platform_device *pdev)
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
+		struct device_node *np = pdev->dev.of_node;
+		u32 val;
+
+		/* Combination of IO widths supported, default to 16-bit */
+		if (!of_property_read_u32(np, "reg-io-width", &val)) {
+			if (val & 1)
+				lp->cfg.flags |= SMC91X_USE_8BIT;
+			if ((val == 0) || (val & 2))
+				lp->cfg.flags |= SMC91X_USE_16BIT;
+			if (val & 4)
+				lp->cfg.flags |= SMC91X_USE_32BIT;
+		} else {
+			lp->cfg.flags |= SMC91X_USE_16BIT;
+		}
+	}
+#endif
+
+	if (!pd && !match) {
 		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
@@ -2370,15 +2404,6 @@ static int smc_drv_resume(struct device *dev)
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
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
