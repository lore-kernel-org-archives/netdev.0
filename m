From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 2/8] macb: detect hclk presence from platform data
Date: Thu, 10 Mar 2011 10:10:37 +0000
Message-ID: <1299751843-9743-3-git-send-email-jamie@jamieiles.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42407 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab1CJKKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 05:10:53 -0500
Received: by mail-ww0-f44.google.com with SMTP id 36so1752924wwa.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 02:10:53 -0800 (PST)
In-Reply-To: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than detecting whether we need to do a clk_get() and enable on
the "hclk" based on the kernel configuration, add an extra field to the
platform data.  This makes it cleaner to add more supported
architectures without lots of ifdeffery.

This requires that all instantiations of the device have platform data
defined but that is the case currently anyway.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 arch/avr32/mach-at32ap/at32ap700x.c |    2 +
 drivers/net/macb.c                  |   77 ++++++++++++++++++-----------------
 include/linux/platform_data/macb.h  |    1 +
 3 files changed, 43 insertions(+), 37 deletions(-)

diff --git a/arch/avr32/mach-at32ap/at32ap700x.c b/arch/avr32/mach-at32ap/at32ap700x.c
index 2747cde..2abcafd 100644
--- a/arch/avr32/mach-at32ap/at32ap700x.c
+++ b/arch/avr32/mach-at32ap/at32ap700x.c
@@ -1088,6 +1088,8 @@ at32_add_device_eth(unsigned int id, struct eth_platform_data *data)
 	struct platform_device *pdev;
 	u32 pin_mask;
 
+	data->have_hclk = 1;
+
 	switch (id) {
 	case 0:
 		pdev = &macb0_device;
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index bfd3601..ae98fee 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -246,9 +246,7 @@ static int macb_mii_init(struct macb *bp)
 	bp->mii_bus->parent = &bp->dev->dev;
 	pdata = bp->pdev->dev.platform_data;
 
-	if (pdata)
-		bp->mii_bus->phy_mask = pdata->phy_mask;
-
+	bp->mii_bus->phy_mask = pdata->phy_mask;
 	bp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (!bp->mii_bus->irq) {
 		err = -ENOMEM;
@@ -1103,9 +1101,14 @@ static const struct net_device_ops macb_netdev_ops = {
 #endif
 };
 
+#ifdef CONFIG_ARCH_AT91
+#define PCLK_NAME	"macb_clk"
+#else /* CONFIG_ARCH_AT91 */
+#define PCLK_NAME	"pclk"
+#endif
+
 static int __init macb_probe(struct platform_device *pdev)
 {
-	struct eth_platform_data *pdata;
 	struct resource *regs;
 	struct net_device *dev;
 	struct macb *bp;
@@ -1113,6 +1116,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	unsigned long pclk_hz;
 	u32 config;
 	int err = -ENXIO;
+	struct eth_platform_data *pdata;
 
 	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!regs) {
@@ -1120,6 +1124,13 @@ static int __init macb_probe(struct platform_device *pdev)
 		goto err_out;
 	}
 
+	err = -EINVAL;
+	pdata = dev_get_platdata(&pdev->dev);
+	if (!pdata) {
+		dev_err(&pdev->dev, "no platform data present\n");
+		goto err_out;
+	}
+
 	err = -ENOMEM;
 	dev = alloc_etherdev(sizeof(*bp));
 	if (!dev) {
@@ -1138,28 +1149,22 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	spin_lock_init(&bp->lock);
 
-#if defined(CONFIG_ARCH_AT91)
-	bp->pclk = clk_get(&pdev->dev, "macb_clk");
+	bp->pclk = clk_get(&pdev->dev, PCLK_NAME);
 	if (IS_ERR(bp->pclk)) {
 		dev_err(&pdev->dev, "failed to get macb_clk\n");
 		goto err_out_free_dev;
 	}
 	clk_enable(bp->pclk);
-#else
-	bp->pclk = clk_get(&pdev->dev, "pclk");
-	if (IS_ERR(bp->pclk)) {
-		dev_err(&pdev->dev, "failed to get pclk\n");
-		goto err_out_free_dev;
-	}
-	bp->hclk = clk_get(&pdev->dev, "hclk");
-	if (IS_ERR(bp->hclk)) {
-		dev_err(&pdev->dev, "failed to get hclk\n");
-		goto err_out_put_pclk;
+
+	if (pdata->have_hclk) {
+		bp->hclk = clk_get(&pdev->dev, "hclk");
+		if (IS_ERR(bp->hclk)) {
+			dev_err(&pdev->dev, "failed to get hclk\n");
+			goto err_out_put_pclk;
+		}
+		clk_enable(bp->hclk);
 	}
 
-	clk_enable(bp->pclk);
-	clk_enable(bp->hclk);
-#endif
 
 	bp->regs = ioremap(regs->start, regs->end - regs->start + 1);
 	if (!bp->regs) {
@@ -1197,9 +1202,8 @@ static int __init macb_probe(struct platform_device *pdev)
 	macb_writel(bp, NCFGR, config);
 
 	macb_get_hwaddr(bp);
-	pdata = pdev->dev.platform_data;
 
-	if (pdata && pdata->is_rmii)
+	if (pdata->is_rmii)
 #if defined(CONFIG_ARCH_AT91)
 		macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)) );
 #else
@@ -1243,14 +1247,12 @@ err_out_free_irq:
 err_out_iounmap:
 	iounmap(bp->regs);
 err_out_disable_clocks:
-#ifndef CONFIG_ARCH_AT91
-	clk_disable(bp->hclk);
-	clk_put(bp->hclk);
-#endif
+	if (pdata->have_hclk) {
+		clk_disable(bp->hclk);
+		clk_put(bp->hclk);
+	}
 	clk_disable(bp->pclk);
-#ifndef CONFIG_ARCH_AT91
 err_out_put_pclk:
-#endif
 	clk_put(bp->pclk);
 err_out_free_dev:
 	free_netdev(dev);
@@ -1263,6 +1265,7 @@ static int __exit macb_remove(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct macb *bp;
+	struct eth_platform_data *pdata = dev_get_platdata(&pdev->dev);
 
 	dev = platform_get_drvdata(pdev);
 
@@ -1276,10 +1279,10 @@ static int __exit macb_remove(struct platform_device *pdev)
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
 		iounmap(bp->regs);
-#ifndef CONFIG_ARCH_AT91
-		clk_disable(bp->hclk);
-		clk_put(bp->hclk);
-#endif
+		if (pdata->have_hclk) {
+			clk_disable(bp->hclk);
+			clk_put(bp->hclk);
+		}
 		clk_disable(bp->pclk);
 		clk_put(bp->pclk);
 		free_netdev(dev);
@@ -1294,12 +1297,12 @@ static int macb_suspend(struct platform_device *pdev, pm_message_t state)
 {
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct macb *bp = netdev_priv(netdev);
+	struct eth_platform_data *pdata = dev_get_platdata(&pdev->dev);
 
 	netif_device_detach(netdev);
 
-#ifndef CONFIG_ARCH_AT91
-	clk_disable(bp->hclk);
-#endif
+	if (pdata->have_hclk)
+		clk_disable(bp->hclk);
 	clk_disable(bp->pclk);
 
 	return 0;
@@ -1309,11 +1312,11 @@ static int macb_resume(struct platform_device *pdev)
 {
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct macb *bp = netdev_priv(netdev);
+	struct eth_platform_data *pdata = dev_get_platdata(&pdev->dev);
 
 	clk_enable(bp->pclk);
-#ifndef CONFIG_ARCH_AT91
-	clk_enable(bp->hclk);
-#endif
+	if (pdata->have_hclk)
+		clk_enable(bp->hclk);
 
 	netif_device_attach(netdev);
 
diff --git a/include/linux/platform_data/macb.h b/include/linux/platform_data/macb.h
index beddfd3..ae18579 100644
--- a/include/linux/platform_data/macb.h
+++ b/include/linux/platform_data/macb.h
@@ -5,6 +5,7 @@ struct eth_platform_data {
 	u32		phy_mask;
 	u8		phy_irq_pin;	/* PHY IRQ */
 	u8		is_rmii;	/* using RMII interface? */
+	int		have_hclk;	/* have hclk as well as pclk */
 };
 
 #endif /* __MACB_PDATA_H__ */
-- 
1.7.4

