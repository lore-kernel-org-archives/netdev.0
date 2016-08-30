From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 2/4] net: smc91x: add external clock support
Date: Tue, 30 Aug 2016 11:52:40 +0100
Message-ID: <E1begem-00076w-Ef@rmk-PC.armlinux.org.uk>
References: <20160830105117.GM1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Nicolas Pitre <nico@fluxnic.net>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:36582 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758140AbcH3Kwo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 06:52:44 -0400
In-Reply-To: <20160830105117.GM1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The smc91x can be operated with either a directly attached crystal, or
an externally supplied clock.  When used with an externally supplied
clock, this clock may require some configuration or control.  Add calls
to the driver to lookup, enable and disable this optional clock.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/smsc/smc91x.c | 38 ++++++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/smsc/smc91x.h |  1 +
 2 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 503a3b6dce91..43dbc1c7b9a5 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -73,6 +73,7 @@ static const char version[] =
 #include <linux/irq.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
+#include <linux/clk.h>
 #include <linux/crc32.h>
 #include <linux/platform_device.h>
 #include <linux/spinlock.h>
@@ -2284,6 +2285,18 @@ static int smc_drv_probe(struct platform_device *pdev)
 		}
 	}
 
+	/*
+	 * Some platforms drive the xtal input from an external clock
+	 * source which may require some control.  Request the clock,
+	 * but allow probing to continue if no clock is specified.
+	 */
+	lp->xtal = devm_clk_get(&pdev->dev, NULL);
+	if (IS_ERR(lp->xtal)) {
+		if (PTR_ERR(lp->xtal) != -ENOENT)
+			return PTR_ERR(lp->xtal);
+		lp->xtal = NULL;
+	}
+
 #if IS_BUILTIN(CONFIG_OF)
 	match = of_match_device(of_match_ptr(smc91x_match), &pdev->dev);
 	if (match) {
@@ -2375,15 +2388,20 @@ static int smc_drv_probe(struct platform_device *pdev)
 	if (machine_is_assabet() && machine_has_neponset())
 		neponset_ncr_set(NCR_ENET_OSC_EN);
 #endif
+	if (lp->xtal) {
+		ret = clk_prepare_enable(lp->xtal);
+		if (ret)
+			goto out_release_attrib;
+	}
 	platform_set_drvdata(pdev, ndev);
 	ret = smc_enable_device(pdev);
 	if (ret)
-		goto out_release_attrib;
+		goto out_disable_xtal;
 
 	addr = ioremap(res->start, SMC_IO_EXTENT);
 	if (!addr) {
 		ret = -ENOMEM;
-		goto out_release_attrib;
+		goto out_disable_xtal;
 	}
 
 #ifdef CONFIG_ARCH_PXA
@@ -2407,6 +2425,9 @@ static int smc_drv_probe(struct platform_device *pdev)
 	iounmap(addr);
  out_release_attrib:
 	smc_release_attrib(pdev, ndev);
+ out_disable_xtal:
+	if (lp->xtal)
+		clk_disable_unprepare(lp->xtal);
  out_release_io:
 	release_mem_region(res->start, SMC_IO_EXTENT);
  out_free_netdev:
@@ -2441,6 +2462,9 @@ static int smc_drv_remove(struct platform_device *pdev)
 		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, SMC_IO_EXTENT);
 
+	if (lp->xtal)
+		clk_disable_unprepare(lp->xtal);
+
 	free_netdev(ndev);
 
 	return 0;
@@ -2453,9 +2477,14 @@ static int smc_drv_suspend(struct device *dev)
 
 	if (ndev) {
 		if (netif_running(ndev)) {
+			struct smc_local *lp = netdev_priv(ndev);
+
 			netif_device_detach(ndev);
 			smc_shutdown(ndev);
 			smc_phy_powerdown(ndev);
+
+			if (lp->xtal)
+				clk_disable_unprepare(lp->xtal);
 		}
 	}
 	return 0;
@@ -2468,6 +2497,11 @@ static int smc_drv_resume(struct device *dev)
 
 	if (ndev) {
 		struct smc_local *lp = netdev_priv(ndev);
+		if (lp->xtal) {
+			int ret = clk_prepare_enable(lp->xtal);
+			if (ret)
+				return ret;
+		}
 		smc_enable_device(pdev);
 		if (netif_running(ndev)) {
 			smc_reset(ndev);
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index e17671c9d1b0..5377c2e1b8b9 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -266,6 +266,7 @@ struct smc_local {
 
 	struct gpio_desc *power_gpio;
 	struct gpio_desc *reset_gpio;
+	struct clk *xtal;
 
 	/* version/revision of the SMC91x chip */
 	int	version;
-- 
2.1.0
