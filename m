From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: macb: Probe MDIO bus before registering netdev
Date: Mon,  2 May 2016 18:38:45 -0700
Message-ID: <1462239525-22723-1-git-send-email-f.fainelli@gmail.com>
Cc: nicolas.ferre@atmel.com, davem@davemloft.net,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34026 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755235AbcECBiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 21:38:50 -0400
Received: by mail-pa0-f44.google.com with SMTP id r5so2856398pag.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 18:38:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current sequence makes us register for a network device prior to
registering and probing the MDIO bus which could lead to some unwanted
consequences, like a thread of execution calling into ndo_open before
register_netdev() returns, while the MDIO bus is not ready yet.

Rework the sequence to register for the MDIO bus, and therefore attach
to a PHY prior to calling register_netdev(), which implies reworking the
error path a bit.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Tracking down the exact commit which started doing that was a little
difficult, so I can't really provide a proper Fixes tag yet that does
not reference 4-5 commits

 drivers/net/ethernet/cadence/macb.c | 31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 48a7d7dee846..e9b470a5ddd0 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -441,7 +441,7 @@ static int macb_mii_init(struct macb *bp)
 	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
 		bp->pdev->name, bp->pdev->id);
 	bp->mii_bus->priv = bp;
-	bp->mii_bus->parent = &bp->dev->dev;
+	bp->mii_bus->parent = &bp->pdev->dev;
 	pdata = dev_get_platdata(&bp->pdev->dev);
 
 	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
@@ -3019,29 +3019,36 @@ static int macb_probe(struct platform_device *pdev)
 	if (err)
 		goto err_out_free_netdev;
 
+	err = macb_mii_init(bp);
+	if (err)
+		goto err_out_free_netdev;
+
+	phydev = bp->phy_dev;
+
+	netif_carrier_off(dev);
+
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_unregister_netdev;
+		goto err_out_unregister_mdio;
 	}
 
-	err = macb_mii_init(bp);
-	if (err)
-		goto err_out_unregister_netdev;
-
-	netif_carrier_off(dev);
+	phy_attached_info(phydev);
 
 	netdev_info(dev, "Cadence %s rev 0x%08x at 0x%08lx irq %d (%pM)\n",
 		    macb_is_gem(bp) ? "GEM" : "MACB", macb_readl(bp, MID),
 		    dev->base_addr, dev->irq, dev->dev_addr);
 
-	phydev = bp->phy_dev;
-	phy_attached_info(phydev);
-
 	return 0;
 
-err_out_unregister_netdev:
-	unregister_netdev(dev);
+err_out_unregister_mdio:
+	phy_disconnect(bp->phy_dev);
+	mdiobus_unregister(bp->mii_bus);
+	mdiobus_free(bp->mii_bus);
+
+	/* Shutdown the PHY if there is a GPIO reset */
+	if (bp->reset_gpio)
+		gpiod_set_value(bp->reset_gpio, 0);
 
 err_out_free_netdev:
 	free_netdev(dev);
-- 
2.1.0
