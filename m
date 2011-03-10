From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 4/8] macb: initial support for Cadence GEM
Date: Thu, 10 Mar 2011 10:10:39 +0000
Message-ID: <1299751843-9743-5-git-send-email-jamie@jamieiles.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42407 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307Ab1CJKK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 05:10:57 -0500
Received: by mail-ww0-f44.google.com with SMTP id 36so1752924wwa.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 02:10:57 -0800 (PST)
In-Reply-To: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Cadence GEM is based on the MACB Ethernet controller but has a few
small changes with regards to register and bitfield placement.  This
patch adds a new platform driver for gem which sets allows the driver to
tell at runtime whether it is targetting a GEM device.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/Kconfig |    8 ++++--
 drivers/net/macb.c  |   53 ++++++++++++++++++++++++++++++++++++++++++--------
 drivers/net/macb.h  |   18 +++++++++++++++++
 3 files changed, 67 insertions(+), 12 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6bd5caa..6de335a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -223,12 +223,14 @@ menuconfig NET_ETHERNET
 if NET_ETHERNET
 
 config MACB
-	tristate "Atmel MACB support"
+	tristate "Cadence MACB/GEM support"
 	depends on HAVE_NET_MACB
 	select PHYLIB
 	help
-	  The Atmel MACB ethernet interface is found on many AT32 and AT91
-	  parts. Say Y to include support for the MACB chip.
+	  The Cadence MACB ethernet interface is found on many Atmel AT32 and
+	  AT91 parts.  This driver also supports the Cadence GEM (Gigabit
+	  Ethernet MAC found in some ARM SoC devices).  Note: the Gigabit mode
+	  is not yet supported.  Say Y to include support for the MACB/GEM chip.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called macb.
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 5d676ad..204afa6 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1,5 +1,5 @@
 /*
- * Atmel MACB Ethernet Controller driver
+ * Cadence MACB/GEM Ethernet Controller driver
  *
  * Copyright (C) 2004-2006 Atmel Corporation
  *
@@ -7,7 +7,6 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
 #define pr_fmt(fmt) "macb: " fmt
 #include <linux/clk.h>
 #include <linux/module.h>
@@ -1108,7 +1107,7 @@ static const struct net_device_ops macb_netdev_ops = {
 #define PCLK_NAME	"pclk"
 #endif
 
-static int __init macb_probe(struct platform_device *pdev)
+static int __macb_probe(struct platform_device *pdev, int is_gem)
 {
 	struct resource *regs;
 	struct net_device *dev;
@@ -1147,6 +1146,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	bp = netdev_priv(dev);
 	bp->pdev = pdev;
 	bp->dev = dev;
+	bp->is_gem = is_gem;
 
 	spin_lock_init(&bp->lock);
 
@@ -1230,8 +1230,9 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dev);
 
-	pr_info("%s: Atmel MACB at 0x%08lx irq %d (%pM)\n",
-		dev->name, dev->base_addr, dev->irq, dev->dev_addr);
+	pr_info("%s: Cadence %s at 0x%08lx irq %d (%pM)\n",
+		dev->name, bp->is_gem ? "GEM" : "MACB", dev->base_addr,
+		dev->irq, dev->dev_addr);
 
 	phydev = bp->phy_dev;
 	pr_info("%s: attached PHY driver [%s] "
@@ -1261,7 +1262,17 @@ err_out:
 	return err;
 }
 
-static int __exit macb_remove(struct platform_device *pdev)
+static int __devinit macb_probe(struct platform_device *pdev)
+{
+	return __macb_probe(pdev, 0);
+}
+
+static int __devinit gem_probe(struct platform_device *pdev)
+{
+	return __macb_probe(pdev, 1);
+}
+
+static int __devexit macb_remove(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct macb *bp;
@@ -1328,7 +1339,8 @@ static int macb_resume(struct platform_device *pdev)
 #endif
 
 static struct platform_driver macb_driver = {
-	.remove		= __exit_p(macb_remove),
+	.probe		= macb_probe,
+	.remove		= __devexit_p(macb_remove),
 	.suspend	= macb_suspend,
 	.resume		= macb_resume,
 	.driver		= {
@@ -1337,20 +1349,43 @@ static struct platform_driver macb_driver = {
 	},
 };
 
+static struct platform_driver gem_driver = {
+	.probe		= gem_probe,
+	.remove		= __devexit_p(macb_remove),
+	.suspend	= macb_suspend,
+	.resume		= macb_resume,
+	.driver		= {
+		.name		= "gem",
+		.owner	= THIS_MODULE,
+	},
+};
+
 static int __init macb_init(void)
 {
-	return platform_driver_probe(&macb_driver, macb_probe);
+	int ret;
+
+	ret = platform_driver_register(&macb_driver);
+	if (ret)
+		return ret;
+
+	ret = platform_driver_register(&gem_driver);
+	if (ret)
+		platform_driver_unregister(&macb_driver);
+
+	return ret;
+
 }
 
 static void __exit macb_exit(void)
 {
 	platform_driver_unregister(&macb_driver);
+	platform_driver_unregister(&gem_driver);
 }
 
 module_init(macb_init);
 module_exit(macb_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("Atmel MACB Ethernet driver");
+MODULE_DESCRIPTION("Cadence MACB/GEM Ethernet driver");
 MODULE_AUTHOR("Haavard Skinnemoen <hskinnemoen@atmel.com>");
 MODULE_ALIAS("platform:macb");
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index d3212f6..f838615 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -254,11 +254,28 @@
 		    << MACB_##name##_OFFSET))		\
 	 | MACB_BF(name,value))
 
+#define GEM_BIT(name)					\
+	(1 << GEM_##name##_OFFSET)
+#define GEM_BF(name,value)				\
+	(((value) & ((1 << GEM_##name##_SIZE) - 1))	\
+	 << GEM_##name##_OFFSET)
+#define GEM_BFEXT(name,value)\
+	(((value) >> GEM_##name##_OFFSET)		\
+	 & ((1 << GEM_##name##_SIZE) - 1))
+#define GEM_BFINS(name,value,old)			\
+	(((old) & ~(((1 << GEM_##name##_SIZE) - 1)	\
+		    << GEM_##name##_OFFSET))		\
+	 | GEM_BF(name,value))
+
 /* Register access macros */
 #define macb_readl(port,reg)				\
 	__raw_readl((port)->regs + MACB_##reg)
 #define macb_writel(port,reg,value)			\
 	__raw_writel((value), (port)->regs + MACB_##reg)
+#define gem_readl(port,reg)				\
+	__raw_readl((port)->regs + GEM_##reg)
+#define gem_writel(port,reg,value)			\
+	__raw_writel((value), (port)->regs + GEM_##reg)
 
 struct dma_desc {
 	u32	addr;
@@ -360,6 +377,7 @@ struct macb_stats {
 
 struct macb {
 	void __iomem		*regs;
+	int			is_gem;
 
 	unsigned int		rx_tail;
 	struct dma_desc		*rx_ring;
-- 
1.7.4

