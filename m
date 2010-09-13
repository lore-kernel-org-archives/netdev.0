From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 5/9] net: davinci_mdio: separate out controller reset
Date: Mon, 13 Sep 2010 14:07:27 -0400
Message-ID: <1284401251-8846-6-git-send-email-cyril@ti.com>
References: <1284401251-8846-1-git-send-email-cyril@ti.com>
Cc: michael.williamson@criticallink.com, caglarakyuz@gmail.com,
	bparrot@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:50685 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754684Ab0IMSHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Sep 2010 14:07:40 -0400
In-Reply-To: <1284401251-8846-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch separates out the controller reset logic, and makes this available
via mii_bus->reset.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Michael Williamson <michael.williamson@criticallink.com>
Signed-off-by: Caglar Akyuz <caglarakyuz@gmail.com>
---
 drivers/net/davinci_mdio.c |   90 +++++++++++++++++++++++++------------------
 1 files changed, 52 insertions(+), 38 deletions(-)

diff --git a/drivers/net/davinci_mdio.c b/drivers/net/davinci_mdio.c
index d34a53a..a9fbc26 100644
--- a/drivers/net/davinci_mdio.c
+++ b/drivers/net/davinci_mdio.c
@@ -85,6 +85,57 @@ struct davinci_mdio_data {
 	bool		suspended;
 };
 
+static void __davinci_mdio_reset(struct davinci_mdio_data *data)
+{
+	u32 mdio_in, div;
+
+	mdio_in = clk_get_rate(data->clk);
+	div = (mdio_in / data->pdata.bus_freq) - 1;
+	if (div > CONTROL_MAX_DIV)
+		div = CONTROL_MAX_DIV;
+
+	/* set enable and clock divider */
+	__raw_writel(div | CONTROL_ENABLE, &data->regs->control);
+}
+
+static int davinci_mdio_reset(struct mii_bus *bus)
+{
+	struct davinci_mdio_data *data = bus->priv;
+	u32 phy_mask, ver;
+
+	__davinci_mdio_reset(data);
+
+	/*
+	 * wait for scan logic to settle:
+	 * the scan time consists of (a) a large fixed component, and (b) a
+	 * small component that varies with the mii bus frequency.  These
+	 * were estimated using measurements at 1.1 and 2.2 MHz on tnetv107x
+	 * silicon.  Since the effect of (b) was found to be largely
+	 * negligible, we keep things simple here.
+	 */
+	mdelay(1);
+
+	/* dump hardware version info */
+	ver = __raw_readl(&data->regs->version);
+	dev_info(data->dev, "davinci mdio revision %d.%d\n",
+		 (ver >> 8) & 0xff, ver & 0xff);
+
+	/* get phy mask from the alive register */
+	phy_mask = __raw_readl(&data->regs->alive);
+	if (phy_mask) {
+		/* restrict mdio bus to live phys only */
+		dev_info(data->dev, "detected phy mask %x\n", ~phy_mask);
+		phy_mask = ~phy_mask;
+	} else {
+		/* desperately scan all phys */
+		dev_warn(data->dev, "no live phy, scanning all\n");
+		phy_mask = 0;
+	}
+	data->bus->phy_mask = phy_mask;
+
+	return 0;
+}
+
 /* wait until hardware is ready for another user access */
 static inline u32 wait_for_user_access(struct davinci_mdio_data *data)
 {
@@ -163,7 +214,6 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 	struct device *dev = &pdev->dev;
 	struct davinci_mdio_data *data;
 	struct resource *res;
-	u32 mdio_in_freq, mdio_out_freq, div, phy_mask, ver;
 	struct phy_device *phy;
 	int ret, addr;
 
@@ -185,6 +235,7 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 	data->bus->name		= dev_name(dev);
 	data->bus->read		= davinci_mdio_read,
 	data->bus->write	= davinci_mdio_write,
+	data->bus->reset	= davinci_mdio_reset,
 	data->bus->parent	= dev;
 	data->bus->priv		= data;
 	snprintf(data->bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
@@ -225,43 +276,6 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 		goto bail_out;
 	}
 
-	mdio_in_freq = clk_get_rate(data->clk);
-	div = (mdio_in_freq / data->pdata.bus_freq) - 1;
-	if (div > CONTROL_MAX_DIV)
-		div = CONTROL_MAX_DIV;
-	mdio_out_freq = mdio_in_freq / (div + 1);
-
-	/* set enable and clock divider */
-	__raw_writel(div | CONTROL_ENABLE, &data->regs->control);
-
-	/*
-	 * wait for scan logic to settle:
-	 * the scan time consists of (a) a large fixed component, and (b) a
-	 * small component that varies with the mii bus frequency.  These
-	 * were estimated using measurements at 1.1 and 2.2 MHz on tnetv107x
-	 * silicon.  Since the effect of (b) was found to be largely
-	 * negligible, we keep things simple here.
-	 */
-	mdelay(1);
-
-	/* dump hardware version info */
-	ver = __raw_readl(&data->regs->version);
-	dev_info(dev, "davinci mdio revision %d.%d\n",
-			(ver >> 8) & 0xff, ver & 0xff);
-
-	/* get phy mask from the alive register */
-	phy_mask = __raw_readl(&data->regs->alive);
-	if (phy_mask) {
-		/* restrict mdio bus to live phys only */
-		dev_info(dev, "detected phy mask %x\n", ~phy_mask);
-		phy_mask = ~phy_mask;
-	} else {
-		/* desperately scan all phys */
-		dev_warn(dev, "failed to detect live phys, scanning all\n");
-		phy_mask = 0;
-	}
-	data->bus->phy_mask = phy_mask;
-
 	/* register the mii bus */
 	ret = mdiobus_register(data->bus);
 	if (ret)
-- 
1.7.0.4

