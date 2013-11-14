From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH 1/8] net: smc91x: Fix device tree based configuration so it's usable
Date: Wed, 13 Nov 2013 18:35:30 -0800
Message-ID: <1384396537-3486-2-git-send-email-tony@atomide.com>
References: <1384396537-3486-1-git-send-email-tony@atomide.com>
Cc: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-03-ewr.mailhop.org ([204.13.248.66]:46301 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751617Ab3KNCfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 21:35:44 -0500
In-Reply-To: <1384396537-3486-1-git-send-email-tony@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---

If this looks OK, I'd like to merge this as a fix via arm-soc tree
along with the other patches in this series as my later patches
depend on patches in this series.

---
 .../devicetree/bindings/net/smsc-lan91c111.txt     |  4 ++
 drivers/net/ethernet/smsc/smc91x.c                 | 52 +++++++++++++++++-----
 2 files changed, 46 insertions(+), 10 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/smsc-lan91c111.txt b/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
index 953049b..53d69e3 100644
--- a/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
+++ b/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
@@ -8,3 +8,7 @@ Required properties:
 Optional properties:
 - phy-device : phandle to Ethernet phy
 - local-mac-address : Ethernet mac address to use
+- reg-io-width : Specify the size (in bytes) of the IO accesses that
+  should be performed on the device.  Valid value for SMSC LAN is
+  1, 2 or 4.  If it's omitted or invalid, the size would be 2.
+- smsc,nowait : Setup for fast register access with no waits
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 73be7f3..93d4b7d 100644
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
@@ -2222,11 +2234,40 @@ static int smc_drv_probe(struct platform_device *pdev)
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
+		switch (val) {
+		case 1:
+			lp->cfg.flags |= SMC91X_USE_8BIT;
+			break;
+		case 2:
+			lp->cfg.flags |= SMC91X_USE_16BIT;
+			break;
+		case 4:
+			lp->cfg.flags |= SMC91X_USE_32BIT;
+			break;
+		default:
+			lp->cfg.flags |= SMC91X_USE_16BIT;
+			break;
+		}
+
+		if (of_get_property(np, "smsc,nowait", NULL))
+			lp->cfg.flags |= SMC91X_NOWAIT;
+	}
+#endif
+
+	if (!pd && !match) {
 		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
@@ -2375,15 +2416,6 @@ static int smc_drv_resume(struct device *dev)
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
1.8.1.1
