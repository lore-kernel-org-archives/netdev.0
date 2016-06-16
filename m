From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 2/2] net: smsc911x: Fix register_netdev, phy startup ordering and driver unload
Date: Thu, 16 Jun 2016 10:54:40 -0500
Message-ID: <1466092480-21005-1-git-send-email-jeremy.linton@arm.com>
Cc: steve.glendinning@shawell.net, andrew@lunn.ch,
	sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:44798 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893AbcFPPyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 11:54:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously the mdio and phy's were started in the drv probe following
register_netdev(). This could lead to a situation where if the netdev was
opened before the mdio/phys were configured, it would fail with a
EAGAIN.

Also, the use of phy_connect_direct() in the drv_probe
routine results in a situation where the module use count would never
decrease sufficiently to unload the driver.

With this patch the mdio bus is allocated/configured before
register_netdev(), and the phy's are brought online/started in the
ndo_open and stopped in the ndo_stop. Because of this, the behavior
of ethtool changes a little if the interface is stopped. Before the
phy's would remain up, and their last state would be displayed with
ethtool. Now ethtool reports link has been severed/Link detected: no
when the net dev is stopped.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 48 +++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index b5ab5e1..abb1842 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1100,15 +1100,8 @@ static int smsc911x_mii_init(struct platform_device *pdev,
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
@@ -1516,10 +1509,12 @@ static int smsc911x_open(struct net_device *dev)
 	unsigned int temp;
 	unsigned int intcfg;
 
-	/* if the phy is not yet registered, retry later*/
+	/* find and start the given phy */
 	if (!pdata->phy_dev) {
-		SMSC_WARN(pdata, hw, "phy_dev is NULL");
-		return -EAGAIN;
+		if (smsc911x_mii_probe(dev) < 0) {
+			SMSC_WARN(pdata, probe, "Error starting phy");
+			return -EAGAIN;
+		}
 	}
 
 	/* Reset the LAN911x */
@@ -1663,8 +1658,11 @@ static int smsc911x_stop(struct net_device *dev)
 	smsc911x_tx_update_txcounters(dev);
 
 	/* Bring the PHY down */
-	if (pdata->phy_dev)
+	if (pdata->phy_dev) {
 		phy_stop(pdata->phy_dev);
+		phy_disconnect(pdata->phy_dev);
+		pdata->phy_dev = NULL;
+	}
 
 	SMSC_TRACE(pdata, ifdown, "Interface stopped");
 	return 0;
@@ -1917,8 +1915,12 @@ smsc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 
+	if (!netif_running(dev) || !pdata->phy_dev)
+		return -ENOLINK;
+
 	cmd->maxtxpkt = 1;
 	cmd->maxrxpkt = 1;
+
 	return phy_ethtool_gset(pdata->phy_dev, cmd);
 }
 
@@ -1927,6 +1929,9 @@ smsc911x_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 
+	if (!netif_running(dev) || !pdata->phy_dev)
+		return -ENOLINK;
+
 	return phy_ethtool_sset(pdata->phy_dev, cmd);
 }
 
@@ -1943,6 +1948,9 @@ static int smsc911x_ethtool_nwayreset(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 
+	if (!netif_running(dev) || !pdata->phy_dev)
+		return -ENOLINK;
+
 	return phy_start_aneg(pdata->phy_dev);
 }
 
@@ -2308,12 +2316,10 @@ static int smsc911x_drv_remove(struct platform_device *pdev)
 	pdata = netdev_priv(dev);
 	BUG_ON(!pdata);
 	BUG_ON(!pdata->ioaddr);
-	BUG_ON(!pdata->phy_dev);
+	WARN_ON(pdata->phy_dev);
 
 	SMSC_TRACE(pdata, ifdown, "Stopping driver");
 
-	phy_disconnect(pdata->phy_dev);
-	pdata->phy_dev = NULL;
 	mdiobus_unregister(pdata->mii_bus);
 	mdiobus_free(pdata->mii_bus);
 
@@ -2512,6 +2518,12 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 
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
@@ -2521,12 +2533,6 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
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
@@ -2562,8 +2568,6 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 
 	return 0;
 
-out_unregister_netdev_5:
-	unregister_netdev(dev);
 out_free_irq:
 	free_irq(dev->irq, dev);
 out_disable_resources:
-- 
2.5.5
