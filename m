From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH] net: of_mdio: scan mdiobus for PHYs without reg property
Date: Sun,  7 Apr 2013 13:09:48 +0200
Message-ID: <1365332988-9053-2-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1365332988-9053-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Florian Fainelli <florian@openwrt.org>,
	devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365332988-9053-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using DT for mdiobus and ethernet-phy requires to know the PHY address, which
is hard to guess if you don't know it. This patch extends of_mdiobus_register
to scan mdiobus for PHYs if reg property of the corresponding node is not set.
This also allows to have phy nodes in SoC DT files where the reg property can
be overwritten in the board file later. To encourage people to finally set the
actual phy address, the mdiobus scan is noisier than required.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Florian Fainelli <florian@openwrt.org>
Cc: devicetree-discuss@lists.ozlabs.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/of/of_mdio.c |   64 +++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 58 insertions(+), 6 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index e3a8b22..23049ae 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -34,7 +34,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 {
 	struct phy_device *phy;
 	struct device_node *child;
-	int rc, i;
+	const __be32 *paddr;
+	u32 addr;
+	bool is_c45, scanphys = false;
+	int rc, i, len;
 
 	/* Mask out all PHYs from auto probing.  Instead the PHYs listed in
 	 * the device tree are populated after the bus has been registered */
@@ -54,14 +57,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 
 	/* Loop over the child nodes and register a phy_device for each one */
 	for_each_available_child_of_node(np, child) {
-		const __be32 *paddr;
-		u32 addr;
-		int len;
-		bool is_c45;
-
 		/* A PHY must have a reg property in the range [0-31] */
 		paddr = of_get_property(child, "reg", &len);
 		if (!paddr || len < sizeof(*paddr)) {
+			scanphys = true;
 			dev_err(&mdio->dev, "%s has invalid PHY address\n",
 				child->full_name);
 			continue;
@@ -111,6 +110,59 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 			child->name, addr);
 	}
 
+	if (!scanphys)
+		return 0;
+
+	/* auto scan for PHYs with empty reg property */
+	for_each_available_child_of_node(np, child) {
+		/* Skip PHYs with reg property set */
+		paddr = of_get_property(child, "reg", &len);
+		if (paddr)
+			continue;
+
+		is_c45 = of_device_is_compatible(child,
+						 "ethernet-phy-ieee802.3-c45");
+
+		for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
+			/* skip already registered PHYs */
+			if (mdio->phy_map[addr])
+				continue;
+
+			/* be noisy to encourage people to set reg property */
+			dev_info(&mdio->dev, "scan phy %s at address %i\n",
+				 child->name, addr);
+
+			phy = get_phy_device(mdio, addr, is_c45);
+			if (!phy || IS_ERR(phy))
+				continue;
+
+			if (mdio->irq) {
+				mdio->irq[addr] =
+					irq_of_parse_and_map(child, 0);
+				if (!mdio->irq[addr])
+					mdio->irq[addr] = PHY_POLL;
+			}
+
+			/* Associate the OF node with the device structure so it
+			 * can be looked up later */
+			of_node_get(child);
+			phy->dev.of_node = child;
+
+			/* All data is now stored in the phy struct;
+			 * register it */
+			rc = phy_device_register(phy);
+			if (rc) {
+				phy_device_free(phy);
+				of_node_put(child);
+				continue;
+			}
+
+			dev_info(&mdio->dev, "registered phy %s at address %i\n",
+				 child->name, addr);
+			break;
+		}
+	}
+
 	return 0;
 }
 EXPORT_SYMBOL(of_mdiobus_register);
-- 
1.7.10.4
