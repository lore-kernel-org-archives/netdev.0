From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH] net: mdio-sun4i: Convert to devm_* api
Date: Mon, 26 Aug 2013 21:11:57 +0800
Message-ID: <1377522717-5784-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jisheng Zhang <jszhang@marvell.com>
To: <maxime.ripard@free-electrons.com>, <davem@davemloft.net>,
	<emilio@elopez.com.ar>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use devm_ioremap_resource instead of of_iomap() and devm_kzalloc()
instead of kmalloc() to make cleanup paths simpler. This patch also
fixes the resource leak caused by missing corresponding iounamp()
of the of_iomap().

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/phy/mdio-sun4i.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/mdio-sun4i.c b/drivers/net/phy/mdio-sun4i.c
index 7f25e49..18969b3 100644
--- a/drivers/net/phy/mdio-sun4i.c
+++ b/drivers/net/phy/mdio-sun4i.c
@@ -101,6 +101,7 @@ static int sun4i_mdio_probe(struct platform_device *pdev)
 	struct device_node *np = pdev->dev.of_node;
 	struct mii_bus *bus;
 	struct sun4i_mdio_data *data;
+	struct resource *res;
 	int ret, i;
 
 	bus = mdiobus_alloc_size(sizeof(*data));
@@ -114,7 +115,8 @@ static int sun4i_mdio_probe(struct platform_device *pdev)
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii", dev_name(&pdev->dev));
 	bus->parent = &pdev->dev;
 
-	bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	bus->irq = devm_kzalloc(&pdev->dev, sizeof(int) * PHY_MAX_ADDR,
+			GFP_KERNEL);
 	if (!bus->irq) {
 		ret = -ENOMEM;
 		goto err_out_free_mdiobus;
@@ -124,10 +126,11 @@ static int sun4i_mdio_probe(struct platform_device *pdev)
 		bus->irq[i] = PHY_POLL;
 
 	data = bus->priv;
-	data->membase = of_iomap(np, 0);
-	if (!data->membase) {
-		ret = -ENOMEM;
-		goto err_out_free_mdio_irq;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	data->membase = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(data->membase)) {
+		ret = PTR_ERR(data->membase);
+		goto err_out_free_mdiobus;
 	}
 
 	data->regulator = devm_regulator_get(&pdev->dev, "phy");
@@ -139,7 +142,7 @@ static int sun4i_mdio_probe(struct platform_device *pdev)
 	} else {
 		ret = regulator_enable(data->regulator);
 		if (ret)
-			goto err_out_free_mdio_irq;
+			goto err_out_free_mdiobus;
 	}
 
 	ret = of_mdiobus_register(bus, np);
@@ -152,8 +155,6 @@ static int sun4i_mdio_probe(struct platform_device *pdev)
 
 err_out_disable_regulator:
 	regulator_disable(data->regulator);
-err_out_free_mdio_irq:
-	kfree(bus->irq);
 err_out_free_mdiobus:
 	mdiobus_free(bus);
 	return ret;
@@ -164,7 +165,6 @@ static int sun4i_mdio_remove(struct platform_device *pdev)
 	struct mii_bus *bus = platform_get_drvdata(pdev);
 
 	mdiobus_unregister(bus);
-	kfree(bus->irq);
 	mdiobus_free(bus);
 
 	return 0;
-- 
1.8.4.rc3
