From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH v2] net: smc91x: Fix device tree based configuration so
 it's usable
Date: Wed, 27 Nov 2013 10:56:57 -0800
Message-ID: <20131127185657.GA26766@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Nicolas Pitre <nico@fluxnic.net>,
	Mark Rutland <mark.rutland@arm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-03-ewr.mailhop.org ([204.13.248.66]:53706 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757729Ab3K0S5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 13:57:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 89ce376c6bdc (drivers/net: Use of_match_ptr() macro in smc91x.c)
added minimal device tree support to smc91x, but it's not working on
many platforms because of the lack of some key configuration bits.

Fix the issue by parsing the necessary configuration like the
smc911x driver is doing. As most smc91x users seem to use 16-bit
access, let's default to that if no reg-io-width is specified.

Cc: Nicolas Pitre <nico@fluxnic.net>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: netdev@vger.kernel.org
Cc: devicetree@vger.kernel.org
Signed-off-by: Tony Lindgren <tony@atomide.com>

---

Device tree folks, any objection to using the reg-io-width property
as a mask here?

Looks like we can use reg-io-width as a mask too if needed, it seems
to play fine with combinations of 1 = 8-bit, 2 = 16-bit, 4 = 32-bit
and so on.

I would like to see this merged during the -rc cycle as this makes
my test devices behave the same way when booted in legacy platform
data mode compared to when booted with device tree.


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
@@ -2198,6 +2208,8 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
 static int smc_drv_probe(struct platform_device *pdev)
 {
 	struct smc91x_platdata *pd = dev_get_platdata(&pdev->dev);
+	struct device_node *np = pdev->dev.of_node;
+	const struct of_device_id *match = NULL;
 	struct smc_local *lp;
 	struct net_device *ndev;
 	struct resource *res, *ires;
@@ -2217,11 +2229,33 @@ static int smc_drv_probe(struct platform_device *pdev)
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
