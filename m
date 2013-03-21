From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 3/3] sh_eth: use managed device API
Date: Thu, 21 Mar 2013 23:41:11 +0300
Message-ID: <201303212341.11657.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:40450 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263Ab3CUTjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 15:39:52 -0400
Received: by mail-la0-f54.google.com with SMTP id gw10so5944273lab.27
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 12:39:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch the driver to the managed device API by replacing ioremap() calls with
devm_ioremap_resource() (that will also result in calling request_mem_region()
which the driver forgot to do until now) and k[mz]alloc() with devm_kzalloc() --
this permits to simplify driver's probe()/remove() method cleanup. We can now
remove the ioremap() error messages since the error messages are printed by
 devm_ioremap_resource() itself. We can also remove the 'bitbang' field from
'struct sh_eth_private' as we don't need it anymore in order to free the memory
behind it...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   47 +++++++++-------------------------
 drivers/net/ethernet/renesas/sh_eth.h |    1 
 2 files changed, 13 insertions(+), 35 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2215,7 +2215,6 @@ static void sh_eth_tsu_init(struct sh_et
 /* MDIO bus release function */
 static int sh_mdio_release(struct net_device *ndev)
 {
-	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct mii_bus *bus = dev_get_drvdata(&ndev->dev);
 
 	/* unregister mdio bus */
@@ -2224,15 +2223,9 @@ static int sh_mdio_release(struct net_de
 	/* remove mdio bus info from net_device */
 	dev_set_drvdata(&ndev->dev, NULL);
 
-	/* free interrupts memory */
-	kfree(bus->irq);
-
 	/* free bitbang info */
 	free_mdio_bitbang(bus);
 
-	/* free bitbang memory */
-	kfree(mdp->bitbang);
-
 	return 0;
 }
 
@@ -2245,7 +2238,8 @@ static int sh_mdio_init(struct net_devic
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
 	/* create bit control struct for PHY */
-	bitbang = kzalloc(sizeof(struct bb_info), GFP_KERNEL);
+	bitbang = devm_kzalloc(&ndev->dev, sizeof(struct bb_info),
+			       GFP_KERNEL);
 	if (!bitbang) {
 		ret = -ENOMEM;
 		goto out;
@@ -2261,11 +2255,10 @@ static int sh_mdio_init(struct net_devic
 	bitbang->ctrl.ops = &bb_ops;
 
 	/* MII controller setting */
-	mdp->bitbang = bitbang;
 	mdp->mii_bus = alloc_mdio_bitbang(&bitbang->ctrl);
 	if (!mdp->mii_bus) {
 		ret = -ENOMEM;
-		goto out_free_bitbang;
+		goto out;
 	}
 
 	/* Hook up MII support for ethtool */
@@ -2275,7 +2268,9 @@ static int sh_mdio_init(struct net_devic
 		mdp->pdev->name, id);
 
 	/* PHY IRQ */
-	mdp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	mdp->mii_bus->irq = devm_kzalloc(&ndev->dev,
+					 sizeof(int) * PHY_MAX_ADDR,
+					 GFP_KERNEL);
 	if (!mdp->mii_bus->irq) {
 		ret = -ENOMEM;
 		goto out_free_bus;
@@ -2287,21 +2282,15 @@ static int sh_mdio_init(struct net_devic
 	/* register mdio bus */
 	ret = mdiobus_register(mdp->mii_bus);
 	if (ret)
-		goto out_free_irq;
+		goto out_free_bus;
 
 	dev_set_drvdata(&ndev->dev, mdp->mii_bus);
 
 	return 0;
 
-out_free_irq:
-	kfree(mdp->mii_bus->irq);
-
 out_free_bus:
 	free_mdio_bitbang(mdp->mii_bus);
 
-out_free_bitbang:
-	kfree(bitbang);
-
 out:
 	return ret;
 }
@@ -2389,10 +2378,9 @@ static int sh_eth_drv_probe(struct platf
 	mdp = netdev_priv(ndev);
 	mdp->num_tx_ring = TX_RING_SIZE;
 	mdp->num_rx_ring = RX_RING_SIZE;
-	mdp->addr = ioremap(res->start, resource_size(res));
-	if (mdp->addr == NULL) {
-		ret = -ENOMEM;
-		dev_err(&pdev->dev, "ioremap failed.\n");
+	mdp->addr = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(mdp->addr)) {
+		ret = PTR_ERR(mdp->addr);
 		goto out_release;
 	}
 
@@ -2438,11 +2426,9 @@ static int sh_eth_drv_probe(struct platf
 			ret = -ENODEV;
 			goto out_release;
 		}
-		mdp->tsu_addr = ioremap(rtsu->start,
-					resource_size(rtsu));
-		if (mdp->tsu_addr == NULL) {
-			ret = -ENOMEM;
-			dev_err(&pdev->dev, "TSU ioremap failed.\n");
+		mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
+		if (IS_ERR(mdp->tsu_addr)) {
+			ret = PTR_ERR(mdp->tsu_addr);
 			goto out_release;
 		}
 		mdp->port = devno % 2;
@@ -2483,10 +2469,6 @@ out_unregister:
 
 out_release:
 	/* net_dev free */
-	if (mdp && mdp->addr)
-		iounmap(mdp->addr);
-	if (mdp && mdp->tsu_addr)
-		iounmap(mdp->tsu_addr);
 	if (ndev)
 		free_netdev(ndev);
 
@@ -2499,12 +2481,9 @@ static int sh_eth_drv_remove(struct plat
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
-	if (mdp->cd->tsu)
-		iounmap(mdp->tsu_addr);
 	sh_mdio_release(ndev);
 	unregister_netdev(ndev);
 	pm_runtime_disable(&pdev->dev);
-	iounmap(mdp->addr);
 	free_netdev(ndev);
 	platform_set_drvdata(pdev, NULL);
 
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -705,7 +705,6 @@ struct sh_eth_private {
 	const u16 *reg_offset;
 	void __iomem *addr;
 	void __iomem *tsu_addr;
-	struct bb_info *bitbang;
 	u32 num_rx_ring;
 	u32 num_tx_ring;
 	dma_addr_t rx_desc_dma;
