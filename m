From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH 06/11] net: ll_temac: Fix mdio initialization
Date: Thu,  4 Oct 2012 20:14:52 +0200
Message-ID: <1349374497-9540-6-git-send-email-monstr@monstr.eu>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Cc: linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current driver required to have phy-node directly in
the driver. After this fixed we can use standard structure.

DTS fragment:

phy-handle = <&phy0>;
mdio {
	#address-cells = <1>;
	#size-cells = <0>;
	phy0: phy@7 {
		compatible = "marvell,88e1111";
		device_type = "ethernet-phy";
		reg = <7>;
	} ;
} ;

Signed-off-by: Michal Simek <monstr@monstr.eu>
CC: Anirudha Sarangi <anirudh@xilinx.com>
CC: John Linn <John.Linn@xilinx.com>
CC: Grant Likely <grant.likely@secretlab.ca>
CC: Rob Herring <rob.herring@calxeda.com>
CC: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |   11 ++++++-----
 drivers/net/ethernet/xilinx/ll_temac_mdio.c |    5 +++--
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index f8e3518..482b572 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1108,14 +1108,15 @@ static int __devinit temac_of_probe(struct platform_device *op)
 	}
 	temac_set_mac_address(ndev, (void *)addr);
 
-	rc = temac_mdio_setup(lp, op->dev.of_node);
-	if (rc)
-		dev_warn(&op->dev, "error registering MDIO bus\n");
-
 	lp->phy_node = of_parse_phandle(op->dev.of_node, "phy-handle", 0);
-	if (lp->phy_node)
+	if (lp->phy_node) {
 		dev_dbg(lp->dev, "using PHY node %s (%p)\n", np->full_name, np);
 
+		rc = temac_mdio_setup(lp, op->dev.of_node);
+		if (rc)
+			dev_warn(&op->dev, "error registering MDIO bus\n");
+	}
+
 	/* Add the device attributes */
 	rc = sysfs_create_group(&lp->dev->kobj, &temac_attr_group);
 	if (rc) {
diff --git a/drivers/net/ethernet/xilinx/ll_temac_mdio.c b/drivers/net/ethernet/xilinx/ll_temac_mdio.c
index 8cf9d4f..634d898 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_mdio.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_mdio.c
@@ -63,6 +63,7 @@ int temac_mdio_setup(struct temac_local *lp, struct device_node *np)
 	int clk_div;
 	int rc, size;
 	struct resource res;
+	struct device_node *np1 = of_get_parent(lp->phy_node);
 
 	/* Calculate a reasonable divisor for the clock rate */
 	clk_div = 0x3f; /* worst-case default setting */
@@ -85,7 +86,7 @@ int temac_mdio_setup(struct temac_local *lp, struct device_node *np)
 	if (!bus)
 		return -ENOMEM;
 
-	of_address_to_resource(np, 0, &res);
+	of_address_to_resource(np1, 0, &res);
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
 		 (unsigned long long)res.start);
 	bus->priv = lp;
@@ -97,7 +98,7 @@ int temac_mdio_setup(struct temac_local *lp, struct device_node *np)
 
 	lp->mii_bus = bus;
 
-	rc = of_mdiobus_register(bus, np);
+	rc = of_mdiobus_register(bus, np1);
 	if (rc)
 		goto err_register;
 
-- 
1.7.0.4
