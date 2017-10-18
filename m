From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v2] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Wed, 18 Oct 2017 13:54:03 +0200
Message-ID: <1508327643-3579-1-git-send-email-geert+renesas@glider.be>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If an Ethernet PHY is initialized before the interrupt controller it is
connected to, a message like the following is printed:

    irq: no irq domain found for /interrupt-controller@e61c0000 !

However, the actual error is ignored, leading to a non-functional (POLL)
PHY interrupt later:

    Micrel KSZ8041RNLI ee700000.ethernet-ffffffff:01: attached PHY driver [Micrel KSZ8041RNLI] (mii_bus:phy_addr=ee700000.ethernet-ffffffff:01, irq=POLL)

Depending on whether the PHY driver will fall back to polling, Ethernet
may or may not work.

To fix this:
  1. Switch of_mdiobus_register_phy() from irq_of_parse_and_map() to
     of_irq_get().
     Unlike the former, the latter returns -EPROBE_DEFER if the
     interrupt controller is not yet available, so this condition can be
     detected.
     Other errors are handled the same as before, i.e. use the passed
     mdio->irq[addr] as interrupt.
  2. Propagate and handle errors from of_mdiobus_register_phy() and
     of_mdiobus_register_device().

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
Seen on e.g. r8a7791/koelsch when using the new CPG/MSSR clock driver,
which will hit upstream in v4.15.  I assume it always happened on RZ/G1
in mainline.

The actual patch is unchanged since v1, sent on May 18.  Obviously I
still cannot test it on a system with multiple PHYs, just like v1.

How can we proceed?

Note that if you are worried about the MDIO subsystem not handling
(partial) teardown and reprobe correctly in the presence of multiple
PHYs, that can already be triggered since commit a5597008dbc23087 ("phy:
fixed_phy: Add gpio to determine link up/down."), which handles
EPROBE_DEFER for GPIOs.

Thanks!

v2:
  - Update for non-functional interrupts being printed as "POLL" instead
    of "-1" since commit 5e369aefdce4818c ("net: stmmac: Delete dead
    code for MDIO registration").
---
 drivers/of/of_mdio.c | 39 +++++++++++++++++++++++++++------------
 1 file changed, 27 insertions(+), 12 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index d94dd8b77abd5140..98258583abb0b405 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -44,7 +44,7 @@ static int of_get_phy_id(struct device_node *device, u32 *phy_id)
 	return -EINVAL;
 }
 
-static void of_mdiobus_register_phy(struct mii_bus *mdio,
+static int of_mdiobus_register_phy(struct mii_bus *mdio,
 				    struct device_node *child, u32 addr)
 {
 	struct phy_device *phy;
@@ -60,9 +60,13 @@ static void of_mdiobus_register_phy(struct mii_bus *mdio,
 	else
 		phy = get_phy_device(mdio, addr, is_c45);
 	if (IS_ERR(phy))
-		return;
+		return PTR_ERR(phy);
 
-	rc = irq_of_parse_and_map(child, 0);
+	rc = of_irq_get(child, 0);
+	if (rc == -EPROBE_DEFER) {
+		phy_device_free(phy);
+		return rc;
+	}
 	if (rc > 0) {
 		phy->irq = rc;
 		mdio->irq[addr] = rc;
@@ -84,22 +88,23 @@ static void of_mdiobus_register_phy(struct mii_bus *mdio,
 	if (rc) {
 		phy_device_free(phy);
 		of_node_put(child);
-		return;
+		return rc;
 	}
 
 	dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
 		child->name, addr);
+	return 0;
 }
 
-static void of_mdiobus_register_device(struct mii_bus *mdio,
-				       struct device_node *child, u32 addr)
+static int of_mdiobus_register_device(struct mii_bus *mdio,
+				      struct device_node *child, u32 addr)
 {
 	struct mdio_device *mdiodev;
 	int rc;
 
 	mdiodev = mdio_device_create(mdio, addr);
 	if (IS_ERR(mdiodev))
-		return;
+		return PTR_ERR(mdiodev);
 
 	/* Associate the OF node with the device structure so it
 	 * can be looked up later.
@@ -112,11 +117,12 @@ static void of_mdiobus_register_device(struct mii_bus *mdio,
 	if (rc) {
 		mdio_device_free(mdiodev);
 		of_node_put(child);
-		return;
+		return rc;
 	}
 
 	dev_dbg(&mdio->dev, "registered mdio device %s at address %i\n",
 		child->name, addr);
+	return 0;
 }
 
 /* The following is a list of PHY compatible strings which appear in
@@ -219,9 +225,11 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 		}
 
 		if (of_mdiobus_child_is_phy(child))
-			of_mdiobus_register_phy(mdio, child, addr);
+			rc = of_mdiobus_register_phy(mdio, child, addr);
 		else
-			of_mdiobus_register_device(mdio, child, addr);
+			rc = of_mdiobus_register_device(mdio, child, addr);
+		if (rc)
+			goto unregister;
 	}
 
 	if (!scanphys)
@@ -242,12 +250,19 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 			dev_info(&mdio->dev, "scan phy %s at address %i\n",
 				 child->name, addr);
 
-			if (of_mdiobus_child_is_phy(child))
-				of_mdiobus_register_phy(mdio, child, addr);
+			if (of_mdiobus_child_is_phy(child)) {
+				rc = of_mdiobus_register_phy(mdio, child, addr);
+				if (rc)
+					goto unregister;
+			}
 		}
 	}
 
 	return 0;
+
+unregister:
+	mdiobus_unregister(mdio);
+	return rc;
 }
 EXPORT_SYMBOL(of_mdiobus_register);
 
-- 
2.7.4
