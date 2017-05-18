From: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Thu, 18 May 2017 14:59:05 +0200
Message-ID: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
Cc: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If an Ethernet PHY is initialized before the interrupt controller it is
connected to, a message like the following is printed:

    irq: no irq domain found for /interrupt-controller@e61c0000 !

However, the actual error is ignored, leading to a non-functional (-1)
PHY interrupt later:

    Micrel KSZ8041RNLI ee700000.ethernet-ffffffff:01: attached PHY driver [Micrel KSZ8041RNLI] (mii_bus:phy_addr=ee700000.ethernet-ffffffff:01, irq=-1)

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

Signed-off-by: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
---
Seen on r8a7791/koelsch when using the new CPG/MSSR clock driver.
I assume it always happened on RZ/G1 in mainline.
---
 drivers/of/of_mdio.c | 39 +++++++++++++++++++++++++++------------
 1 file changed, 27 insertions(+), 12 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 7e4c80f9b6cda0d3..f9ac2893f56184be 100644
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
 
 int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
@@ -242,9 +248,11 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
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
@@ -265,12 +273,19 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
