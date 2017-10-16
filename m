From: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <mnhu@prevas.dk>
Subject: [PATCH net-next] dsa: slave: support phy devices on external MII bus
Date: Mon, 16 Oct 2017 12:45:25 +0200
Message-ID: <20171016104525.26810-1-mnhu@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <mnhu@prevas.dk>,
        <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.prevas.se ([62.95.78.3]:13430 "EHLO mail01.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751376AbdJPK4C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 06:56:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring a switch port to use an external phy, the phy is
connected to external switch MII bus:

                    +---------+
 +-----+  MII cpu   | Switch  |  MII ext   +-----+
 | CPU | ---------> |---------| ---------> | PHY |
 +-----+            | MII int |            +-----+
                    +---------+

In the device tree, the configuration looks something like this:

/ {
  /* ... */

  mdio {
    /* phy on MII cpu */
    phy0@0 {
      reg = <0>;
    };

    /* switch on MII cpu */
    switch0@1 {
      reg = <1>;

      ports {
        /* port internal phy */
        port1@1 {
          reg = <1>;
          label = "lan1";
          phy-handle <&switch0phy1>;
        };

        /* port with external phy */
        port0@0 {
          reg = <0>;
          label = "lan0";
          phy-handle <&switch0phy0>;
        };
      };

      /* internal MII */
      mdio {
        switch0phy1@1 {
          reg = <1>;
        };
      };

      /* external MII */
      mdio1 {
        switch0phy0: switch0phy0@0 {
          reg = <0>;
        };
      };
    };
  };

  /* ... */
};

When connecting port0 to switch0phy0, the current dsa code assumes the
phy to be connected to the internal MII bus, and thus fails with

    mv88e6085 f1072004.mdio-mii:02 lan0: no phy at 0
    mv88e6085 f1072004.mdio-mii:02 lan0: failed to connect to phy0: -19
    mvneta f1034000.ethernet eth2: error -19 setting up slave phy
    mv88e6085 f1072004.mdio-mii:02: Failed to create slave 0: -19

Fix this by using the phy of-handle to obtain a reference to the parent
mdio_bus, which is then used to connect the phy.

Signed-off-by: Martin Hundebøll <mnhu@prevas.dk>
---
 net/dsa/slave.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 45f4ea845c07..62ad69a728be 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -976,12 +976,16 @@ static int dsa_slave_fixed_link_update(struct net_device *dev,
 }
 
 /* slave device setup *******************************************************/
-static int dsa_slave_phy_connect(struct net_device *slave_dev, int addr)
+static int dsa_slave_phy_connect(struct net_device *slave_dev,
+				 struct mii_bus *bus, int addr)
 {
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
 	struct dsa_switch *ds = p->dp->ds;
 
-	slave_dev->phydev = mdiobus_get_phy(ds->slave_mii_bus, addr);
+	if (!bus)
+		bus = ds->slave_mii_bus;
+
+	slave_dev->phydev = mdiobus_get_phy(bus, addr);
 	if (!slave_dev->phydev) {
 		netdev_err(slave_dev, "no phy at %d\n", addr);
 		return -ENODEV;
@@ -1029,6 +1033,7 @@ static int dsa_slave_phy_setup(struct net_device *slave_dev)
 
 	if (phy_dn) {
 		int phy_id = of_mdio_parse_addr(&slave_dev->dev, phy_dn);
+		struct mii_bus *bus = of_mdio_find_bus(phy_dn->parent);
 
 		/* If this PHY address is part of phys_mii_mask, which means
 		 * that we need to divert reads and writes to/from it, then we
@@ -1037,7 +1042,7 @@ static int dsa_slave_phy_setup(struct net_device *slave_dev)
 		 */
 		if (!phy_is_fixed && phy_id >= 0 &&
 		    (ds->phys_mii_mask & (1 << phy_id))) {
-			ret = dsa_slave_phy_connect(slave_dev, phy_id);
+			ret = dsa_slave_phy_connect(slave_dev, bus, phy_id);
 			if (ret) {
 				netdev_err(slave_dev, "failed to connect to phy%d: %d\n", phy_id, ret);
 				of_node_put(phy_dn);
@@ -1061,7 +1066,7 @@ static int dsa_slave_phy_setup(struct net_device *slave_dev)
 	 * MDIO bus instead
 	 */
 	if (!slave_dev->phydev) {
-		ret = dsa_slave_phy_connect(slave_dev, p->dp->index);
+		ret = dsa_slave_phy_connect(slave_dev, NULL, p->dp->index);
 		if (ret) {
 			netdev_err(slave_dev, "failed to connect to port %d: %d\n",
 				   p->dp->index, ret);
-- 
2.14.2
