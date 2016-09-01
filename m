From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 1/2] net: smsc911x: Fix register_netdev, phy startup, driver unload ordering
Date: Thu,  1 Sep 2016 11:25:40 -0500
Message-ID: <1472747141-15886-2-git-send-email-jeremy.linton@arm.com>
References: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
Cc: steve.glendinning@shawell.net, sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:35048 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754875AbcIAQZm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 12:25:42 -0400
In-Reply-To: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move phy startup/shutdown into the smsc911x_open/stop routines. This
allows the module to be unloaded because phy_connect_direct is no longer
always holding the module use count. This one change also resolves a
number of other problems.

The link status of a downed interface no longer reflects a stale state.
Errors caused by the net device being opened before the mdio/phy was
configured. There is also a potential power savings as the phy's don't
remain powered when the interface isn't running.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 51 ++++++++++++++++++++----------------
 1 file changed, 28 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index ca31345..6d6dcfe 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1099,15 +1099,8 @@ static int smsc911x_mii_init(struct platform_device *pdev,
 		goto err_out_free_bus_2;
 	}
 
-	if (smsc911x_mii_probe(dev) < 0) {
-		SMSC_WARN(pdata, probe, "Error registering mii bus");
-		goto err_out_unregister_bus_3;
-	}
-
 	return 0;
 
-err_out_unregister_bus_3:
-	mdiobus_unregister(pdata->mii_bus);
 err_out_free_bus_2:
 	mdiobus_free(pdata->mii_bus);
 err_out_1:
@@ -1520,17 +1513,22 @@ static int smsc911x_open(struct net_device *dev)
 	unsigned int timeout;
 	unsigned int temp;
 	unsigned int intcfg;
+	int retval;
 
-	/* if the phy is not yet registered, retry later*/
+	/* find and start the given phy */
 	if (!dev->phydev) {
-		SMSC_WARN(pdata, hw, "phy_dev is NULL");
-		return -EAGAIN;
+		if (smsc911x_mii_probe(dev) < 0) {
+			SMSC_WARN(pdata, probe, "Error starting phy");
+			retval = -EAGAIN;
+			goto out;
+		}
 	}
 
 	/* Reset the LAN911x */
 	if (smsc911x_soft_reset(pdata)) {
 		SMSC_WARN(pdata, hw, "soft reset failed");
-		return -EIO;
+		retval = -EIO;
+		goto mii_free_out;
 	}
 
 	smsc911x_reg_write(pdata, HW_CFG, 0x00050000);
@@ -1600,7 +1598,8 @@ static int smsc911x_open(struct net_device *dev)
 	if (!pdata->software_irq_signal) {
 		netdev_warn(dev, "ISR failed signaling test (IRQ %d)\n",
 			    dev->irq);
-		return -ENODEV;
+		retval = -ENODEV;
+		goto mii_free_out;
 	}
 	SMSC_TRACE(pdata, ifup, "IRQ handler passed test using IRQ %d",
 		   dev->irq);
@@ -1646,6 +1645,12 @@ static int smsc911x_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 	return 0;
+
+mii_free_out:
+	phy_disconnect(dev->phydev);
+	dev->phydev = NULL;
+out:
+	return retval;
 }
 
 /* Entry point for stopping the interface */
@@ -1668,8 +1673,11 @@ static int smsc911x_stop(struct net_device *dev)
 	smsc911x_tx_update_txcounters(dev);
 
 	/* Bring the PHY down */
-	if (dev->phydev)
+	if (dev->phydev) {
 		phy_stop(dev->phydev);
+		phy_disconnect(dev->phydev);
+		dev->phydev = NULL;
+	}
 
 	SMSC_TRACE(pdata, ifdown, "Interface stopped");
 	return 0;
@@ -2291,11 +2299,10 @@ static int smsc911x_drv_remove(struct platform_device *pdev)
 	pdata = netdev_priv(dev);
 	BUG_ON(!pdata);
 	BUG_ON(!pdata->ioaddr);
-	BUG_ON(!dev->phydev);
+	WARN_ON(dev->phydev);
 
 	SMSC_TRACE(pdata, ifdown, "Stopping driver");
 
-	phy_disconnect(dev->phydev);
 	mdiobus_unregister(pdata->mii_bus);
 	mdiobus_free(pdata->mii_bus);
 
@@ -2494,6 +2501,12 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 
 	netif_carrier_off(dev);
 
+	retval = smsc911x_mii_init(pdev, dev);
+	if (retval) {
+		SMSC_WARN(pdata, probe, "Error %i initialising mii", retval);
+		goto out_free_irq;
+	}
+
 	retval = register_netdev(dev);
 	if (retval) {
 		SMSC_WARN(pdata, probe, "Error %i registering device", retval);
@@ -2503,12 +2516,6 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 			   "Network interface: \"%s\"", dev->name);
 	}
 
-	retval = smsc911x_mii_init(pdev, dev);
-	if (retval) {
-		SMSC_WARN(pdata, probe, "Error %i initialising mii", retval);
-		goto out_unregister_netdev_5;
-	}
-
 	spin_lock_irq(&pdata->mac_lock);
 
 	/* Check if mac address has been specified when bringing interface up */
@@ -2544,8 +2551,6 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 
 	return 0;
 
-out_unregister_netdev_5:
-	unregister_netdev(dev);
 out_free_irq:
 	free_irq(dev->irq, dev);
 out_disable_resources:
-- 
2.5.5
