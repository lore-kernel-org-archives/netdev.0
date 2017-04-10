From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 6/6] net: mvmdio: allow up to three clocks to be specified for
 orion-mdio
Date: Mon, 10 Apr 2017 16:28:31 +0100
Message-ID: <E1cxbF1-0006gf-54@rmk-PC.armlinux.org.uk>
References: <20170410152728.GT17774@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:37706 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753339AbdDJP2n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:28:43 -0400
In-Reply-To: <20170410152728.GT17774@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow up to three clocks to be specified and enabled for the orion-mdio
interface, which are required for this interface to be accessible on
Armada 8k platforms.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c | 33 ++++++++++++++++++++++++---------
 1 file changed, 24 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 614dfde657fe..90a60b98c28e 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -53,7 +53,7 @@
 struct orion_mdio_dev {
 	struct mutex lock;
 	void __iomem *regs;
-	struct clk *clk;
+	struct clk *clk[3];
 	/*
 	 * If we have access to the error interrupt pin (which is
 	 * somewhat misnamed as it not only reflects internal errors
@@ -187,7 +187,7 @@ static int orion_mdio_probe(struct platform_device *pdev)
 	struct resource *r;
 	struct mii_bus *bus;
 	struct orion_mdio_dev *dev;
-	int ret;
+	int i, ret;
 
 	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!r) {
@@ -216,9 +216,12 @@ static int orion_mdio_probe(struct platform_device *pdev)
 
 	init_waitqueue_head(&dev->smi_busy_wait);
 
-	dev->clk = devm_clk_get(&pdev->dev, NULL);
-	if (!IS_ERR(dev->clk))
-		clk_prepare_enable(dev->clk);
+	for (i = 0; i < ARRAY_SIZE(dev->clk); i++) {
+		dev->clk[i] = of_clk_get(pdev->dev.of_node, i);
+		if (IS_ERR(dev->clk[i]))
+			break;
+		clk_prepare_enable(dev->clk[i]);
+	}
 
 	dev->err_interrupt = platform_get_irq(pdev, 0);
 	if (dev->err_interrupt > 0 &&
@@ -259,8 +262,14 @@ static int orion_mdio_probe(struct platform_device *pdev)
 out_mdio:
 	if (dev->err_interrupt > 0)
 		writel(0, dev->regs + MVMDIO_ERR_INT_MASK);
-	if (!IS_ERR(dev->clk))
-		clk_disable_unprepare(dev->clk);
+
+	for (i = 0; i < ARRAY_SIZE(dev->clk); i++) {
+		if (IS_ERR(dev->clk[i]))
+			break;
+		clk_disable_unprepare(dev->clk[i]);
+		clk_put(dev->clk[i]);
+	}
+
 	return ret;
 }
 
@@ -268,12 +277,18 @@ static int orion_mdio_remove(struct platform_device *pdev)
 {
 	struct mii_bus *bus = platform_get_drvdata(pdev);
 	struct orion_mdio_dev *dev = bus->priv;
+	int i;
 
 	if (dev->err_interrupt > 0)
 		writel(0, dev->regs + MVMDIO_ERR_INT_MASK);
 	mdiobus_unregister(bus);
-	if (!IS_ERR(dev->clk))
-		clk_disable_unprepare(dev->clk);
+
+	for (i = 0; i < ARRAY_SIZE(dev->clk); i++) {
+		if (IS_ERR(dev->clk[i]))
+			break;
+		clk_disable_unprepare(dev->clk[i]);
+		clk_put(dev->clk[i]);
+	}
 
 	return 0;
 }
-- 
2.7.4
