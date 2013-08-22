From: Boris BREZILLON <b.brezillon@overkiz.com>
Subject: [PATCH 1/2] net/cadence/macb: add support for dt phy definition
Date: Thu, 22 Aug 2013 17:57:28 +0200
Message-ID: <1377187048-21944-1-git-send-email-b.brezillon@overkiz.com>
References: <1377186980-21902-1-git-send-email-b.brezillon@overkiz.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	Boris BREZILLON <b.brezillon@overkiz.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Russell King <linux@arm.linux.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 4.mo3.mail-out.ovh.net ([178.33.46.10]:37934 "EHLO
	mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753683Ab3HVP6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 11:58:13 -0400
Received: from mail96.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo3.mail-out.ovh.net (Postfix) with SMTP id 15CEAFF8C7A
	for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 17:58:12 +0200 (CEST)
In-Reply-To: <1377186980-21902-1-git-send-email-b.brezillon@overkiz.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macb driver only handle PHY description through platform_data
(macb_platform_data).
Thus, when using dt you cannot define phy properties like phy address or
phy irq pin.

This patch makes use of the of_mdiobus_register to add support for
phy device definition using dt.
A fallback to the autoscan procedure is added in case there is no phy
devices defined in dt.

Signed-off-by: Boris BREZILLON <b.brezillon@overkiz.com>
---
 drivers/net/ethernet/cadence/macb.c |   41 +++++++++++++++++++++++++++++------
 1 file changed, 34 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e866608..fe06ab0 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -27,6 +27,7 @@
 #include <linux/phy.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/of_mdio.h>
 #include <linux/of_net.h>
 #include <linux/pinctrl/consumer.h>
 
@@ -314,6 +315,7 @@ static int macb_mii_probe(struct net_device *dev)
 int macb_mii_init(struct macb *bp)
 {
 	struct macb_platform_data *pdata;
+	struct device_node *np;
 	int err = -ENXIO, i;
 
 	/* Enable management port */
@@ -335,21 +337,46 @@ int macb_mii_init(struct macb *bp)
 	bp->mii_bus->parent = &bp->dev->dev;
 	pdata = bp->pdev->dev.platform_data;
 
-	if (pdata)
-		bp->mii_bus->phy_mask = pdata->phy_mask;
-
 	bp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (!bp->mii_bus->irq) {
 		err = -ENOMEM;
 		goto err_out_free_mdiobus;
 	}
 
-	for (i = 0; i < PHY_MAX_ADDR; i++)
-		bp->mii_bus->irq[i] = PHY_POLL;
-
 	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
 
-	if (mdiobus_register(bp->mii_bus))
+	np = bp->pdev->dev.of_node;
+	if (np) {
+		/* try dt phy registration */
+		err = of_mdiobus_register(bp->mii_bus, np);
+
+		/* fallback to standard phy registration if no phy were
+		   found during dt phy registration */
+		if (!err && !phy_find_first(bp->mii_bus)) {
+			for (i = 0; i < PHY_MAX_ADDR; i++) {
+				struct phy_device *phydev;
+
+				phydev = mdiobus_scan(bp->mii_bus, i);
+				if (IS_ERR(phydev)) {
+					err = PTR_ERR(phydev);
+					break;
+				}
+			}
+
+			if (err)
+				goto err_out_unregister_bus;
+		}
+	} else {
+		for (i = 0; i < PHY_MAX_ADDR; i++)
+			bp->mii_bus->irq[i] = PHY_POLL;
+
+		if (pdata)
+			bp->mii_bus->phy_mask = pdata->phy_mask;
+
+		err = mdiobus_register(bp->mii_bus);
+	}
+
+	if (err)
 		goto err_out_free_mdio_irq;
 
 	if (macb_mii_probe(bp->dev) != 0) {
-- 
1.7.9.5
