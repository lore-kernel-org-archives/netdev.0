From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v2 06/10] net/faraday: Helper functions to create or destroy MDIO interface
Date: Fri, 15 Jul 2016 20:44:16 +1000
Message-ID: <1468579460-13768-7-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:64048 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932562AbcGOKvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 06:51:01 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6FAnEWE125646
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 06:51:00 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 246jxgjrht-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 06:51:00 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 15 Jul 2016 20:50:57 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 8A2D53578053
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 20:50:55 +1000 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6FAotMO19988626
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 20:50:55 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6FAosX2001017
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 20:50:55 +1000
In-Reply-To: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces two helper functions to create or destroy MDIO
interface. No logical changes introduced except the proper MDIO
names are given when having more than one MDIO bus.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 95 ++++++++++++++++++++------------
 1 file changed, 60 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index e7cf313..9b09493 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1146,6 +1146,60 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
 	.ndo_do_ioctl		= ftgmac100_do_ioctl,
 };
 
+static int ftgmac100_setup_mdio(struct net_device *netdev)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
+	struct platform_device *pdev = to_platform_device(priv->dev);
+	int i, err = 0;
+
+	/* initialize mdio bus */
+	priv->mii_bus = mdiobus_alloc();
+	if (!priv->mii_bus)
+		return -EIO;
+
+	priv->mii_bus->name = "ftgmac100_mdio";
+	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%s-%d",
+		 pdev->name, pdev->id);
+	priv->mii_bus->priv = priv->netdev;
+	priv->mii_bus->read = ftgmac100_mdiobus_read;
+	priv->mii_bus->write = ftgmac100_mdiobus_write;
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		priv->mii_bus->irq[i] = PHY_POLL;
+
+	err = mdiobus_register(priv->mii_bus);
+	if (err) {
+		dev_err(priv->dev, "Cannot register MDIO bus!\n");
+		goto err_register_mdiobus;
+	}
+
+	err = ftgmac100_mii_probe(priv);
+	if (err) {
+		dev_err(priv->dev, "MII Probe failed!\n");
+		goto err_mii_probe;
+	}
+
+	return 0;
+
+err_mii_probe:
+	mdiobus_unregister(priv->mii_bus);
+err_register_mdiobus:
+	mdiobus_free(priv->mii_bus);
+	return err;
+}
+
+static void ftgmac100_destroy_mdio(struct net_device *netdev)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
+
+	if (!netdev->phydev)
+		return;
+
+	phy_disconnect(netdev->phydev);
+	mdiobus_unregister(priv->mii_bus);
+	mdiobus_free(priv->mii_bus);
+}
+
 /******************************************************************************
  * struct platform_driver functions
  *****************************************************************************/
@@ -1211,31 +1265,9 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	priv->irq = irq;
 
-	/* initialize mdio bus */
-	priv->mii_bus = mdiobus_alloc();
-	if (!priv->mii_bus) {
-		err = -EIO;
-		goto err_alloc_mdiobus;
-	}
-
-	priv->mii_bus->name = "ftgmac100_mdio";
-	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "ftgmac100_mii");
-
-	priv->mii_bus->priv = netdev;
-	priv->mii_bus->read = ftgmac100_mdiobus_read;
-	priv->mii_bus->write = ftgmac100_mdiobus_write;
-
-	err = mdiobus_register(priv->mii_bus);
-	if (err) {
-		dev_err(&pdev->dev, "Cannot register MDIO bus!\n");
-		goto err_register_mdiobus;
-	}
-
-	err = ftgmac100_mii_probe(priv);
-	if (err) {
-		dev_err(&pdev->dev, "MII Probe failed!\n");
-		goto err_mii_probe;
-	}
+	err = ftgmac100_setup_mdio(netdev);
+	if (err)
+		goto err_setup_mdio;
 
 	/* register network device */
 	err = register_netdev(netdev);
@@ -1255,12 +1287,8 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	return 0;
 
 err_register_netdev:
-	phy_disconnect(netdev->phydev);
-err_mii_probe:
-	mdiobus_unregister(priv->mii_bus);
-err_register_mdiobus:
-	mdiobus_free(priv->mii_bus);
-err_alloc_mdiobus:
+	ftgmac100_destroy_mdio(netdev);
+err_setup_mdio:
 	iounmap(priv->base);
 err_ioremap:
 	release_resource(priv->res);
@@ -1280,10 +1308,7 @@ static int __exit ftgmac100_remove(struct platform_device *pdev)
 	priv = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
-
-	phy_disconnect(netdev->phydev);
-	mdiobus_unregister(priv->mii_bus);
-	mdiobus_free(priv->mii_bus);
+	ftgmac100_destroy_mdio(netdev);
 
 	iounmap(priv->base);
 	release_resource(priv->res);
-- 
2.1.0
