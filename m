From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH 3/5] sh_eth: Simplify MDIO bus initialization and release
Date: Thu, 20 Mar 2014 15:00:33 +0100
Message-ID: <1395324035-22918-4-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1395324035-22918-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Cc: linux-sh@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perceval.ideasonboard.com ([95.142.166.194]:33932 "EHLO
	perceval.ideasonboard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758075AbaCTN6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 09:58:53 -0400
In-Reply-To: <1395324035-22918-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network device passed to the sh_mdio_init and sh_mdio_release
functions is only used to access the sh_eth_private instance. Pass it
directly to those functions.

Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/renesas/sh_eth.c | 30 +++++++++++-------------------
 1 file changed, 11 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 443f14f..e9224f2 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2583,29 +2583,24 @@ static void sh_eth_tsu_init(struct sh_eth_private *mdp)
 }
 
 /* MDIO bus release function */
-static int sh_mdio_release(struct net_device *ndev)
+static int sh_mdio_release(struct sh_eth_private *mdp)
 {
-	struct mii_bus *bus = dev_get_drvdata(&ndev->dev);
-
 	/* unregister mdio bus */
-	mdiobus_unregister(bus);
-
-	/* remove mdio bus info from net_device */
-	dev_set_drvdata(&ndev->dev, NULL);
+	mdiobus_unregister(mdp->mii_bus);
 
 	/* free bitbang info */
-	free_mdio_bitbang(bus);
+	free_mdio_bitbang(mdp->mii_bus);
 
 	return 0;
 }
 
 /* MDIO bus init function */
-static int sh_mdio_init(struct net_device *ndev, int id,
+static int sh_mdio_init(struct sh_eth_private *mdp,
 			struct sh_eth_plat_data *pd)
 {
 	int ret, i;
 	struct bb_info *bitbang;
-	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct platform_device *pdev = mdp->pdev;
 	struct device *dev = &mdp->pdev->dev;
 
 	/* create bit control struct for PHY */
@@ -2635,7 +2630,7 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 	mdp->mii_bus->name = "sh_mii";
 	mdp->mii_bus->parent = dev;
 	snprintf(mdp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		 mdp->pdev->name, id);
+		 pdev->name, pdev->id);
 
 	/* PHY IRQ */
 	mdp->mii_bus->irq = devm_kzalloc(dev, sizeof(int) * PHY_MAX_ADDR,
@@ -2645,10 +2640,9 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 		goto out_free_bus;
 	}
 
-	/* register mdio bus */
-	if (ndev->dev.parent->of_node) {
-		ret = of_mdiobus_register(mdp->mii_bus,
-					  ndev->dev.parent->of_node);
+	/* register MDIO bus */
+	if (dev->of_node) {
+		ret = of_mdiobus_register(mdp->mii_bus, dev->of_node);
 	} else {
 		for (i = 0; i < PHY_MAX_ADDR; i++)
 			mdp->mii_bus->irq[i] = PHY_POLL;
@@ -2661,8 +2655,6 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 	if (ret)
 		goto out_free_bus;
 
-	dev_set_drvdata(&ndev->dev, mdp->mii_bus);
-
 	return 0;
 
 out_free_bus:
@@ -2907,7 +2899,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		goto out_napi_del;
 
 	/* mdio bus init */
-	ret = sh_mdio_init(ndev, pdev->id, pd);
+	ret = sh_mdio_init(mdp, pd);
 	if (ret) {
 		dev_err(&ndev->dev, "failed to initialise MDIO\n");
 		goto out_unregister;
@@ -2941,7 +2933,7 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
-	sh_mdio_release(ndev);
+	sh_mdio_release(mdp);
 	unregister_netdev(ndev);
 	netif_napi_del(&mdp->napi);
 	pm_runtime_disable(&pdev->dev);
-- 
1.8.3.2
