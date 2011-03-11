From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: [PATCH] macb: detect IP version to determin if we are on at91 or avr32
Date: Fri, 11 Mar 2011 18:13:05 +0100
Message-ID: <1299863585-17263-1-git-send-email-plagnioj@jcrosoft.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jamie Iles <jamie@jamieiles.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 64.mail-out.ovh.net ([91.121.185.65]:46203 "HELO
	64.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751678Ab1CKRSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 12:18:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this will make macb soc generic and will allow to use it on other arch

Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Cc: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/macb.c |   96 +++++++++++++++++++++++++---------------------------
 drivers/net/macb.h |    9 +++++
 2 files changed, 55 insertions(+), 50 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index f251866..58cebf2 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -22,7 +22,6 @@
 #include <linux/phy.h>
 
 #include <mach/board.h>
-#include <mach/cpu.h>
 
 #include "macb.h"
 
@@ -1140,28 +1139,30 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	spin_lock_init(&bp->lock);
 
-#if defined(CONFIG_ARCH_AT91)
-	bp->pclk = clk_get(&pdev->dev, "macb_clk");
-	if (IS_ERR(bp->pclk)) {
-		dev_err(&pdev->dev, "failed to get macb_clk\n");
-		goto err_out_free_dev;
-	}
-	clk_enable(bp->pclk);
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
-	}
+	bp->version = macb_readl(bp, VERSION);
 
-	clk_enable(bp->pclk);
-	clk_enable(bp->hclk);
-#endif
+	if (macb_is_at91(bp)) {
+		bp->pclk = clk_get(&pdev->dev, "macb_clk");
+		if (IS_ERR(bp->pclk)) {
+			dev_err(&pdev->dev, "failed to get macb_clk\n");
+			goto err_out_free_dev;
+		}
+		clk_enable(bp->pclk);
+	} else {
+		bp->pclk = clk_get(&pdev->dev, "pclk");
+		if (IS_ERR(bp->pclk)) {
+			dev_err(&pdev->dev, "failed to get pclk\n");
+			goto err_out_free_dev;
+		}
+		bp->hclk = clk_get(&pdev->dev, "hclk");
+		if (IS_ERR(bp->hclk)) {
+			dev_err(&pdev->dev, "failed to get hclk\n");
+			goto err_out_put_pclk;
+		}
+
+		clk_enable(bp->pclk);
+		clk_enable(bp->hclk);
+	}
 
 	bp->regs = ioremap(regs->start, regs->end - regs->start + 1);
 	if (!bp->regs) {
@@ -1191,18 +1192,17 @@ static int __init macb_probe(struct platform_device *pdev)
 	macb_get_hwaddr(bp);
 	pdata = pdev->dev.platform_data;
 
-	if (pdata && pdata->is_rmii)
-#if defined(CONFIG_ARCH_AT91)
-		macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)) );
-#else
-		macb_writel(bp, USRIO, 0);
-#endif
-	else
-#if defined(CONFIG_ARCH_AT91)
-		macb_writel(bp, USRIO, MACB_BIT(CLKEN));
-#else
-		macb_writel(bp, USRIO, MACB_BIT(MII));
-#endif
+	if (pdata && pdata->is_rmii) {
+		if (macb_is_at91(bp))
+			macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)));
+		else
+			macb_writel(bp, USRIO, 0);
+	} else {
+		if (macb_is_at91(bp))
+			macb_writel(bp, USRIO, MACB_BIT(CLKEN));
+		else
+			macb_writel(bp, USRIO, MACB_BIT(MII));
+	}
 
 	bp->tx_pending = DEF_TX_RING_PENDING;
 
@@ -1245,14 +1245,12 @@ err_out_unregister_netdev:
 err_out_iounmap:
 	iounmap(bp->regs);
 err_out_disable_clocks:
-#ifndef CONFIG_ARCH_AT91
-	clk_disable(bp->hclk);
-	clk_put(bp->hclk);
-#endif
+	if (!macb_is_at91(bp)) {
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
@@ -1278,10 +1276,10 @@ static int __exit macb_remove(struct platform_device *pdev)
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
 		iounmap(bp->regs);
-#ifndef CONFIG_ARCH_AT91
-		clk_disable(bp->hclk);
-		clk_put(bp->hclk);
-#endif
+		if (!macb_is_at91(bp)) {
+			clk_disable(bp->hclk);
+			clk_put(bp->hclk);
+		}
 		clk_disable(bp->pclk);
 		clk_put(bp->pclk);
 		free_netdev(dev);
@@ -1299,9 +1297,8 @@ static int macb_suspend(struct platform_device *pdev, pm_message_t state)
 
 	netif_device_detach(netdev);
 
-#ifndef CONFIG_ARCH_AT91
-	clk_disable(bp->hclk);
-#endif
+	if (!macb_is_at91(bp))
+		clk_disable(bp->hclk);
 	clk_disable(bp->pclk);
 
 	return 0;
@@ -1313,9 +1310,8 @@ static int macb_resume(struct platform_device *pdev)
 	struct macb *bp = netdev_priv(netdev);
 
 	clk_enable(bp->pclk);
-#ifndef CONFIG_ARCH_AT91
-	clk_enable(bp->hclk);
-#endif
+	if (!macb_is_at91(bp))
+		clk_enable(bp->hclk);
 
 	netif_device_attach(netdev);
 
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index d3212f6..56a4fcb 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -59,6 +59,7 @@
 #define MACB_TPQ				0x00bc
 #define MACB_USRIO				0x00c0
 #define MACB_WOL				0x00c4
+#define MACB_VERSION				0x00fc
 
 /* Bitfields in NCR */
 #define MACB_LB_OFFSET				0
@@ -389,6 +390,14 @@ struct macb {
 	unsigned int 		link;
 	unsigned int 		speed;
 	unsigned int 		duplex;
+
+	uint32_t		version;
 };
 
+#define MACB_VERSION_MASK	0xffff0000
+#define macb_is_at91(bp)	\
+	(((bp)->version & MACB_VERSION_MASK) == 0x06010000)
+#define macb_is_avr32(bp)	\
+	(((bp)->version & MACB_VERSION_MASK) == 0x00010000)
+
 #endif /* _MACB_H */
-- 
1.7.4.1

