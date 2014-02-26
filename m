From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH v3] sh_eth: call of_mdiobus_register() to register phys
Date: Wed, 26 Feb 2014 11:57:53 +0000
Message-ID: <1393415873-10520-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: linux-sh@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	nobuhiro.iwamatsu.yj@renesas.com
To: ben.dooks@codethink.co.uk, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the sh_eth device is registered using OF, then the driver
should call of_mdiobus_register() to register any PHYs connected
to the system.

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

--
v2:
	- allocate mdio->irq array at init time
	- set devdata after succesful mdio registration
v3:
	- do not parse phy->irq in of setup (done by of_mdiobus)
	- use of_phy_connect to connect phy
---
 drivers/net/ethernet/renesas/sh_eth.c | 46 ++++++++++++++++++++++++++---------
 1 file changed, 34 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index a18cbe1..6d14abf 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -40,6 +40,7 @@
 #include <linux/if_vlan.h>
 #include <linux/clk.h>
 #include <linux/sh_eth.h>
+#include <linux/of_mdio.h>
 
 #include "sh_eth.h"
 
@@ -1764,17 +1765,31 @@ static int sh_eth_phy_init(struct net_device *ndev)
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	char phy_id[MII_BUS_ID_SIZE + 3];
 	struct phy_device *phydev = NULL;
-
-	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
-		 mdp->mii_bus->id, mdp->phy_id);
+	struct device_node *np = ndev->dev.parent->of_node;
 
 	mdp->link = 0;
 	mdp->speed = 0;
 	mdp->duplex = -1;
 
-	/* Try connect to PHY */
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
+			phydev = ERR_PTR(ENOENT);
+	} else {
+		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
+			 mdp->mii_bus->id, mdp->phy_id);
+
+		/* Try connect to PHY */
+		phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
+				     mdp->phy_interface);
+	}
+
 	if (IS_ERR(phydev)) {
 		dev_err(&ndev->dev, "phy_connect failed\n");
 		return PTR_ERR(phydev);
@@ -2638,6 +2653,18 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 		goto out_free_bus;
 	}
 
+	if (ndev->dev.parent->of_node) {
+		ret = of_mdiobus_register(mdp->mii_bus,
+					  ndev->dev.parent->of_node);
+		if (ret != 0) {
+			dev_err(&ndev->dev, "of_mdiobus_register() failed\n");
+			goto out_free_bus;
+		}
+
+		dev_set_drvdata(&ndev->dev, mdp->mii_bus);
+		return 0;
+	}
+
 	for (i = 0; i < PHY_MAX_ADDR; i++)
 		mdp->mii_bus->irq[i] = PHY_POLL;
 	if (pd->phy_irq > 0)
@@ -2719,7 +2746,6 @@ static struct sh_eth_plat_data *sh_eth_parse_dt(struct device *dev)
 {
 	struct device_node *np = dev->of_node;
 	struct sh_eth_plat_data *pdata;
-	struct device_node *phy;
 	const char *mac_addr;
 
 	pdata = devm_kzalloc(dev, sizeof(*pdata), GFP_KERNEL);
@@ -2727,11 +2753,7 @@ static struct sh_eth_plat_data *sh_eth_parse_dt(struct device *dev)
 		return NULL;
 
 	pdata->phy_interface = of_get_phy_mode(np);
-
-	phy = of_parse_phandle(np, "phy-handle", 0);
-	if (of_property_read_u32(phy, "reg", &pdata->phy))
-		return NULL;
-	pdata->phy_irq = irq_of_parse_and_map(phy, 0);
+	pdata->phy_irq = PHY_POLL;
 
 	mac_addr = of_get_mac_address(np);
 	if (mac_addr)
-- 
1.8.5.3

