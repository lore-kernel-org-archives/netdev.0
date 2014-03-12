From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH v6] sh_eth: update OF PHY registeration
Date: Wed, 12 Mar 2014 17:47:40 +0000
Message-ID: <1394646460-18170-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: devicetree@vger.kernel.org, magnus.damm@opensource.se,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	horms+renesas@verge.net.au, linux-kernel@lists.codethink.co.uk,
	Ben Dooks <ben.dooks@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-68-191-81.dsl.posilan.com ([82.68.191.81]:37804 "EHLO
	rainbowdash.ducie.codethink.co.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755870AbaCLRrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 13:47:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the sh_eth device is registered using OF, then the driver
should call of_mdiobus_register() to register the PHYs described
in the devicetree and then use of_phy_connect() to connect the
PHYs to the device.

This ensures that any PHYs registered in the device tree are
appropriately connected to the parent devices nodes so that
the PHY drivers can access their OF properties.

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

--
v2:
	- allocate mdio->irq array at init time
	- set devdata after succesful mdio registration
v3:
	- do not parse phy->irq in of setup (done by of_mdiobus)
	- use of_phy_connect to connect phy
v4:
	- fix review comments on code
	- reword patch description
	- change if to be two way in mdio init code
v5:
	- fix comment duplication
	- move error to out of mdio init
	- updated patch description
	- add copyright codethink to header
v6:
	- minor messages and comment fixes for Sergei
---
 drivers/net/ethernet/renesas/sh_eth.c | 59 +++++++++++++++++++++++------------
 1 file changed, 39 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index a18cbe1..be7211d 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -3,6 +3,7 @@
  *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
  *  Copyright (C) 2008-2014 Renesas Solutions Corp.
  *  Copyright (C) 2013-2014 Cogent Embedded, Inc.
+ *  Copyright (C) 2014 Codethink Limited
  *
  *  This program is free software; you can redistribute it and/or modify it
  *  under the terms and conditions of the GNU General Public License,
@@ -40,6 +41,7 @@
 #include <linux/if_vlan.h>
 #include <linux/clk.h>
 #include <linux/sh_eth.h>
+#include <linux/of_mdio.h>
 
 #include "sh_eth.h"
 
@@ -1761,22 +1763,37 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 /* PHY init function */
 static int sh_eth_phy_init(struct net_device *ndev)
 {
+	struct device_node *np = ndev->dev.parent->of_node;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	char phy_id[MII_BUS_ID_SIZE + 3];
 	struct phy_device *phydev = NULL;
 
-	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
-		 mdp->mii_bus->id, mdp->phy_id);
-
 	mdp->link = 0;
 	mdp->speed = 0;
 	mdp->duplex = -1;
 
 	/* Try connect to PHY */
-	phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
-			     mdp->phy_interface);
+	if (np) {
+		struct device_node *pn;
+
+		pn = of_parse_phandle(np, "phy-handle", 0);
+		phydev = of_phy_connect(ndev, pn,
+					sh_eth_adjust_link, 0,
+					mdp->phy_interface);
+
+		if (!phydev)
+			phydev = ERR_PTR(-ENOENT);
+	} else {
+		char phy_id[MII_BUS_ID_SIZE + 3];
+
+		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
+			 mdp->mii_bus->id, mdp->phy_id);
+
+		phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
+				     mdp->phy_interface);
+	}
+
 	if (IS_ERR(phydev)) {
-		dev_err(&ndev->dev, "phy_connect failed\n");
+		dev_err(&ndev->dev, "failed to connect PHY\n");
 		return PTR_ERR(phydev);
 	}
 
@@ -2638,13 +2655,19 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 		goto out_free_bus;
 	}
 
-	for (i = 0; i < PHY_MAX_ADDR; i++)
-		mdp->mii_bus->irq[i] = PHY_POLL;
-	if (pd->phy_irq > 0)
-		mdp->mii_bus->irq[pd->phy] = pd->phy_irq;
-
 	/* register mdio bus */
-	ret = mdiobus_register(mdp->mii_bus);
+	if (ndev->dev.parent->of_node) {
+		ret = of_mdiobus_register(mdp->mii_bus,
+					  ndev->dev.parent->of_node);
+	} else {
+		for (i = 0; i < PHY_MAX_ADDR; i++)
+			mdp->mii_bus->irq[i] = PHY_POLL;
+		if (pd->phy_irq > 0)
+			mdp->mii_bus->irq[pd->phy] = pd->phy_irq;
+
+		ret = mdiobus_register(mdp->mii_bus);
+	}
+
 	if (ret)
 		goto out_free_bus;
 
@@ -2719,7 +2742,6 @@ static struct sh_eth_plat_data *sh_eth_parse_dt(struct device *dev)
 {
 	struct device_node *np = dev->of_node;
 	struct sh_eth_plat_data *pdata;
-	struct device_node *phy;
 	const char *mac_addr;
 
 	pdata = devm_kzalloc(dev, sizeof(*pdata), GFP_KERNEL);
@@ -2728,11 +2750,6 @@ static struct sh_eth_plat_data *sh_eth_parse_dt(struct device *dev)
 
 	pdata->phy_interface = of_get_phy_mode(np);
 
-	phy = of_parse_phandle(np, "phy-handle", 0);
-	if (of_property_read_u32(phy, "reg", &pdata->phy))
-		return NULL;
-	pdata->phy_irq = irq_of_parse_and_map(phy, 0);
-
 	mac_addr = of_get_mac_address(np);
 	if (mac_addr)
 		memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
@@ -2896,8 +2913,10 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 
 	/* mdio bus init */
 	ret = sh_mdio_init(ndev, pdev->id, pd);
-	if (ret)
+	if (ret) {
+		dev_err(&ndev->dev, "failed to initialise MDIO\n");
 		goto out_unregister;
+	}
 
 	/* print device information */
 	pr_info("Base address at 0x%x, %pM, IRQ %d.\n",
-- 
1.9.0
