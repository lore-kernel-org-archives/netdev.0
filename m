From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: [PATCH] AT91: MACB support
Date: Wed,  7 Feb 2007 16:40:44 +0100
Message-ID: <1170862844979-git-send-email-hskinnemoen@atmel.com>
Cc: netdev@vger.kernel.org,
	Patrice Vilchez <patrice.vilchez@rfo.atmel.com>,
	Andrew Victor <andrew@sanpeople.com>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:63034 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161358AbXBGPvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 10:51:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Victor <andrew@sanpeople.com>

The Atmel MACB Ethernet peripheral is also integrated in the AT91SAM9260
and AT91SAM9263 processors.  The differences from the AVR32 version are:
      * Single peripheral clock.
      * MII/RMII selection bit is inverted.
      * Clock enable bit.

Original patch from Patrice Vilchez.

Signed-off-by: Andrew Victor <andrew@sanpeople.com>
Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
---
 drivers/net/Kconfig |    2 +-
 drivers/net/macb.c  |   25 +++++++++++++++++++++++--
 drivers/net/macb.h  |    8 +++++++-
 3 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8aa8dd0..3318f30 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -190,7 +190,7 @@ config MII
 
 config MACB
 	tristate "Atmel MACB support"
-	depends on NET_ETHERNET && AVR32
+	depends on NET_ETHERNET && (AVR32 || ARCH_AT91SAM9260 || ARCH_AT91SAM9263)
 	select MII
 	help
 	  The Atmel MACB ethernet interface is found on many AT32 and AT91
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 25b559b..5eb7a35 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1046,6 +1046,14 @@ static int __devinit macb_probe(struct platform_device *pdev)
 
 	spin_lock_init(&bp->lock);
 
+#if defined(CONFIG_ARCH_AT91)
+	bp->pclk = clk_get(&pdev->dev, "macb_clk");
+	if (IS_ERR(bp->pclk)) {
+		dev_err(&pdev->dev, "failed to get macb_clk\n");
+		goto err_out_free_dev;
+	}
+	clk_enable(bp->pclk);
+#else
 	bp->pclk = clk_get(&pdev->dev, "pclk");
 	if (IS_ERR(bp->pclk)) {
 		dev_err(&pdev->dev, "failed to get pclk\n");
@@ -1059,6 +1067,7 @@ static int __devinit macb_probe(struct platform_device *pdev)
 
 	clk_enable(bp->pclk);
 	clk_enable(bp->hclk);
+#endif
 
 	bp->regs = ioremap(regs->start, regs->end - regs->start + 1);
 	if (!bp->regs) {
@@ -1119,9 +1128,17 @@ static int __devinit macb_probe(struct platform_device *pdev)
 
 	pdata = pdev->dev.platform_data;
 	if (pdata && pdata->is_rmii)
+#if defined(CONFIG_ARCH_AT91)
+		macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)) );
+#else
 		macb_writel(bp, USRIO, 0);
+#endif
 	else
+#if defined(CONFIG_ARCH_AT91)
+		macb_writel(bp, USRIO, MACB_BIT(CLKEN));
+#else
 		macb_writel(bp, USRIO, MACB_BIT(MII));
+#endif
 
 	bp->tx_pending = DEF_TX_RING_PENDING;
 
@@ -1148,9 +1165,11 @@ err_out_free_irq:
 err_out_iounmap:
 	iounmap(bp->regs);
 err_out_disable_clocks:
+#ifndef CONFIG_ARCH_AT91
 	clk_disable(bp->hclk);
-	clk_disable(bp->pclk);
 	clk_put(bp->hclk);
+#endif
+	clk_disable(bp->pclk);
 err_out_put_pclk:
 	clk_put(bp->pclk);
 err_out_free_dev:
@@ -1173,9 +1192,11 @@ static int __devexit macb_remove(struct platform_device *pdev)
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
 		iounmap(bp->regs);
+#ifndef CONFIG_ARCH_AT91
 		clk_disable(bp->hclk);
-		clk_disable(bp->pclk);
 		clk_put(bp->hclk);
+#endif
+		clk_disable(bp->pclk);
 		clk_put(bp->pclk);
 		free_netdev(dev);
 		platform_set_drvdata(pdev, NULL);
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index 27bf0ae..b3bb218 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -200,7 +200,7 @@
 #define MACB_SOF_OFFSET				30
 #define MACB_SOF_SIZE				2
 
-/* Bitfields in USRIO */
+/* Bitfields in USRIO (AVR32) */
 #define MACB_MII_OFFSET				0
 #define MACB_MII_SIZE				1
 #define MACB_EAM_OFFSET				1
@@ -210,6 +210,12 @@
 #define MACB_TX_PAUSE_ZERO_OFFSET		3
 #define MACB_TX_PAUSE_ZERO_SIZE			1
 
+/* Bitfields in USRIO (AT91) */
+#define MACB_RMII_OFFSET			0
+#define MACB_RMII_SIZE				1
+#define MACB_CLKEN_OFFSET			1
+#define MACB_CLKEN_SIZE				1
+
 /* Bitfields in WOL */
 #define MACB_IP_OFFSET				0
 #define MACB_IP_SIZE				16
-- 
1.4.4.3

