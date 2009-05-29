From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 4/4 v2] netdev: bfin_mac: add Blackfin MII bus to platform bus to allow DSA access
Date: Fri, 29 May 2009 09:41:48 -0400
Message-ID: <1243604508-27284-1-git-send-email-vapier@gentoo.org>
References: <20090529.021042.184273147.davem@davemloft.net>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Graf Yang <graf.yang@analog.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:33434 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758973AbZE2Nlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 09:41:52 -0400
In-Reply-To: <20090529.021042.184273147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graf Yang <graf.yang@analog.com>

When we register the MII bus to the platfrom bus, the Distributed Switch
Architecture can hook in transparently.

Signed-off-by: Graf Yang <graf.yang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
v2
	- squash patches 4 & 5 in previous series

 drivers/net/bfin_mac.c |  117 ++++++++++++++++++++++++++++++++++-------------
 1 files changed, 84 insertions(+), 33 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index f0f1eb9..955a469 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -971,7 +971,8 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct bfin_mac_local *lp;
-	int rc, i;
+	struct platform_device *pd;
+	int rc;
 
 	ndev = alloc_etherdev(sizeof(struct bfin_mac_local));
 	if (!ndev) {
@@ -996,13 +997,6 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 		goto out_err_probe_mac;
 	}
 
-	/* set the GPIO pins to Ethernet mode */
-	rc = peripheral_request_list(pin_req, DRV_NAME);
-	if (rc) {
-		dev_err(&pdev->dev, "Requesting peripherals failed!\n");
-		rc = -EFAULT;
-		goto out_err_setup_pin_mux;
-	}
 
 	/*
 	 * Is it valid? (Did bootloader initialize it?)
@@ -1018,26 +1012,14 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 
 	setup_mac_addr(ndev->dev_addr);
 
-	/* MDIO bus initial */
-	lp->mii_bus = mdiobus_alloc();
-	if (lp->mii_bus == NULL)
-		goto out_err_mdiobus_alloc;
-
-	lp->mii_bus->priv = ndev;
-	lp->mii_bus->read = bfin_mdiobus_read;
-	lp->mii_bus->write = bfin_mdiobus_write;
-	lp->mii_bus->reset = bfin_mdiobus_reset;
-	lp->mii_bus->name = "bfin_mac_mdio";
-	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "0");
-	lp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-	for (i = 0; i < PHY_MAX_ADDR; ++i)
-		lp->mii_bus->irq[i] = PHY_POLL;
-
-	rc = mdiobus_register(lp->mii_bus);
-	if (rc) {
-		dev_err(&pdev->dev, "Cannot register MDIO bus!\n");
-		goto out_err_mdiobus_register;
+	if (!pdev->dev.platform_data) {
+		dev_err(&pdev->dev, "Cannot get platform device bfin_mii_bus!\n");
+		rc = -ENODEV;
+		goto out_err_probe_mac;
 	}
+	pd = pdev->dev.platform_data;
+	lp->mii_bus = platform_get_drvdata(pd);
+	lp->mii_bus->priv = ndev;
 
 	rc = mii_probe(ndev);
 	if (rc) {
@@ -1079,11 +1061,8 @@ out_err_reg_ndev:
 out_err_request_irq:
 out_err_mii_probe:
 	mdiobus_unregister(lp->mii_bus);
-out_err_mdiobus_register:
 	mdiobus_free(lp->mii_bus);
-out_err_mdiobus_alloc:
 	peripheral_free_list(pin_req);
-out_err_setup_pin_mux:
 out_err_probe_mac:
 	platform_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
@@ -1098,8 +1077,7 @@ static int __devexit bfin_mac_remove(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, NULL);
 
-	mdiobus_unregister(lp->mii_bus);
-	mdiobus_free(lp->mii_bus);
+	lp->mii_bus->priv = NULL;
 
 	unregister_netdev(ndev);
 
@@ -1137,6 +1115,74 @@ static int bfin_mac_resume(struct platform_device *pdev)
 #define bfin_mac_resume NULL
 #endif	/* CONFIG_PM */
 
+static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
+{
+	struct mii_bus *miibus;
+	int rc, i;
+
+	/*
+	 * We are setting up a network card,
+	 * so set the GPIO pins to Ethernet mode
+	 */
+	rc = peripheral_request_list(pin_req, DRV_NAME);
+	if (rc) {
+		dev_err(&pdev->dev, "Requesting peripherals failed!\n");
+		return rc;
+	}
+
+	rc = -ENOMEM;
+	miibus = mdiobus_alloc();
+	if (miibus == NULL)
+		goto out_err_alloc;
+	miibus->read = bfin_mdiobus_read;
+	miibus->write = bfin_mdiobus_write;
+	miibus->reset = bfin_mdiobus_reset;
+
+	miibus->parent = &pdev->dev;
+	miibus->name = "bfin_mii_bus";
+	snprintf(miibus->id, MII_BUS_ID_SIZE, "0");
+	miibus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	if (miibus->irq == NULL)
+		goto out_err_alloc;
+	for (i = 0; i < PHY_MAX_ADDR; ++i)
+		miibus->irq[i] = PHY_POLL;
+
+	rc = mdiobus_register(miibus);
+	if (rc) {
+		dev_err(&pdev->dev, "Cannot register MDIO bus!\n");
+		goto out_err_mdiobus_register;
+	}
+
+	platform_set_drvdata(pdev, miibus);
+	return 0;
+
+out_err_mdiobus_register:
+	mdiobus_free(miibus);
+out_err_alloc:
+	peripheral_free_list(pin_req);
+
+	return rc;
+}
+
+static int __devexit bfin_mii_bus_remove(struct platform_device *pdev)
+{
+	struct mii_bus *miibus = platform_get_drvdata(pdev);
+	platform_set_drvdata(pdev, NULL);
+	mdiobus_unregister(miibus);
+	mdiobus_free(miibus);
+	peripheral_free_list(pin_req);
+	return 0;
+}
+
+static struct platform_driver bfin_mii_bus_driver = {
+	.probe = bfin_mii_bus_probe,
+	.remove = __devexit_p(bfin_mii_bus_remove),
+	.driver = {
+		.name = "bfin_mii_bus",
+		.owner	= THIS_MODULE,
+	},
+};
+
 static struct platform_driver bfin_mac_driver = {
 	.probe = bfin_mac_probe,
 	.remove = __devexit_p(bfin_mac_remove),
@@ -1150,7 +1196,11 @@ static struct platform_driver bfin_mac_driver = {
 
 static int __init bfin_mac_init(void)
 {
-	return platform_driver_register(&bfin_mac_driver);
+	int ret;
+	ret = platform_driver_register(&bfin_mii_bus_driver);
+	if (!ret)
+		return platform_driver_register(&bfin_mac_driver);
+	return -ENODEV;
 }
 
 module_init(bfin_mac_init);
@@ -1158,6 +1208,7 @@ module_init(bfin_mac_init);
 static void __exit bfin_mac_cleanup(void)
 {
 	platform_driver_unregister(&bfin_mac_driver);
+	platform_driver_unregister(&bfin_mii_bus_driver);
 }
 
 module_exit(bfin_mac_cleanup);
-- 
1.6.3.1

