From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v3 7/8] net: mvmdio: Use devm_* API to simplify the code
Date: Thu, 22 May 2014 20:07:02 -0300
Message-ID: <1400800023-1562-8-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49732 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753217AbaEVXIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 19:08:18 -0400
In-Reply-To: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit makes use of devm_kmalloc_array() for memory allocation and the
recently introduced devm_mdiobus_alloc() API to simplify driver's code.
While here, remove a redundant out of memory error message.

Acked-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 9d5ced2..fc2fb25 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -195,11 +195,10 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	bus = mdiobus_alloc_size(sizeof(struct orion_mdio_dev));
-	if (!bus) {
-		dev_err(&pdev->dev, "Cannot allocate MDIO bus\n");
+	bus = devm_mdiobus_alloc_size(&pdev->dev,
+				      sizeof(struct orion_mdio_dev));
+	if (!bus)
 		return -ENOMEM;
-	}
 
 	bus->name = "orion_mdio_bus";
 	bus->read = orion_mdio_read;
@@ -208,11 +207,10 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		 dev_name(&pdev->dev));
 	bus->parent = &pdev->dev;
 
-	bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
-	if (!bus->irq) {
-		mdiobus_free(bus);
+	bus->irq = devm_kmalloc_array(&pdev->dev, PHY_MAX_ADDR, sizeof(int),
+				      GFP_KERNEL);
+	if (!bus->irq)
 		return -ENOMEM;
-	}
 
 	for (i = 0; i < PHY_MAX_ADDR; i++)
 		bus->irq[i] = PHY_POLL;
@@ -264,8 +262,6 @@ static int orion_mdio_probe(struct platform_device *pdev)
 out_mdio:
 	if (!IS_ERR(dev->clk))
 		clk_disable_unprepare(dev->clk);
-	kfree(bus->irq);
-	mdiobus_free(bus);
 	return ret;
 }
 
@@ -276,8 +272,6 @@ static int orion_mdio_remove(struct platform_device *pdev)
 
 	writel(0, dev->regs + MVMDIO_ERR_INT_MASK);
 	mdiobus_unregister(bus);
-	kfree(bus->irq);
-	mdiobus_free(bus);
 	if (!IS_ERR(dev->clk))
 		clk_disable_unprepare(dev->clk);
 
-- 
1.9.1
