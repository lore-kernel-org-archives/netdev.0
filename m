From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC net-next] of: mdio: Honor hints from MDIO bus drivers
Date: Mon, 10 Apr 2017 14:42:58 -0700
Message-ID: <20170410214258.9409-1-f.fainelli@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:OPEN FIRMWARE AND FLATTENED
        DEVICE TREE), linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A MDIO bus driver can set phy_mask to indicate which PHYs should be
probed and which should not. Right now, of_mdiobus_register() always
sets mdio->phy_mask to ~0 which means: don't probe anything yourself,
and let the Device Tree scanning do it based on the availability of
child nodes.

When MDIO buses are stacked together (on purpose, as is done by DSA), we
run into possible double probing which is, at best unnecessary, and at
worse, can cause problems if that's not expected (e.g: during probe
deferral).

Fix this by remember the original mdio->phy_mask, and make sure that if
it was set to all 0xF, we set it to zero internally in order not to
influence how the child PHY/MDIO device registration is going to behave.
When the original mdio->phy_mask is set to something non-zero, we honor
this value and utilize it as a hint to register only the child nodes
that we have both found, and indicated to be necessary.

Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Sending this as RFC because a quick look at the current tree makes
me think we are fine, but I would appreciate some review/feedback
before this gets merged.

Thank you!

 drivers/of/of_mdio.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 0b2979816dbf..6bfbf00623cb 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -209,6 +209,7 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 {
 	struct device_node *child;
 	bool scanphys = false;
+	u32 orig_phy_mask;
 	int addr, rc;
 
 	/* Do not continue if the node is disabled */
@@ -217,8 +218,15 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 
 	/* Mask out all PHYs from auto probing.  Instead the PHYs listed in
 	 * the device tree are populated after the bus has been registered */
+	orig_phy_mask = mdio->phy_mask;
 	mdio->phy_mask = ~0;
 
+	/* If the original phy_mask was all 0xf, we make it zero here in order
+	 * to get child Device Tree nodes to be probed successfully
+	 */
+	if (orig_phy_mask == mdio->phy_mask)
+		orig_phy_mask = 0;
+
 	mdio->dev.of_node = np;
 
 	/* Register the MDIO bus */
@@ -234,6 +242,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 			continue;
 		}
 
+		/* Honor hints from the mdio bus */
+		if (orig_phy_mask & BIT(addr))
+			continue;
+
 		if (of_mdiobus_child_is_phy(child))
 			of_mdiobus_register_phy(mdio, child, addr);
 		else
-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
