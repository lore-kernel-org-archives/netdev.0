From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH v4 1/3] netdev/of/phy: New function: of_mdio_find_bus().
Date: Tue, 17 Apr 2012 10:32:44 -0700
Message-ID: <1334683966-12112-2-git-send-email-ddaney.cavm@gmail.com>
References: <1334683966-12112-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	afleming@gmail.com, galak@kernel.crashing.org,
	David Daney <david.daney@cavium.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>
To: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	devicetree-discuss@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:53327 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031Ab2DQRdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 13:33:10 -0400
In-Reply-To: <1334683966-12112-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

Add of_mdio_find_bus() which allows an mii_bus to be located given its
associated the device tree node.

This is needed by the follow-on patch to add a driver for MDIO bus
multiplexers.

The of_mdiobus_register() function is modified so that the device tree
node is recorded in the mii_bus.  Then we can find it again by
iterating over all mdio_bus_class devices.

Because the OF device tree has now become an integral part of the
kernel, this can live in mdio_bus.c (which contains the needed
mdio_bus_class structure) instead of of_mdio.c.

Signed-off-by: David Daney <david.daney@cavium.com>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/phy/mdio_bus.c |   32 ++++++++++++++++++++++++++++++++
 drivers/of/of_mdio.c       |    2 ++
 include/linux/of_mdio.h    |    2 ++
 3 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 8985cc6..83d5c9f 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -88,6 +88,38 @@ static struct class mdio_bus_class = {
 	.dev_release	= mdiobus_release,
 };
 
+#ifdef CONFIG_OF_MDIO
+/* Helper function for of_mdio_find_bus */
+static int of_mdio_bus_match(struct device *dev, void *mdio_bus_np)
+{
+	return dev->of_node == mdio_bus_np;
+}
+/**
+ * of_mdio_find_bus - Given an mii_bus node, find the mii_bus.
+ * @mdio_np: Pointer to the mii_bus.
+ *
+ * Returns a pointer to the mii_bus, or NULL if none found.
+ *
+ * Because the association of a device_node and mii_bus is made via
+ * of_mdiobus_register(), the mii_bus cannot be found before it is
+ * registered with of_mdiobus_register().
+ *
+ */
+struct mii_bus *of_mdio_find_bus(struct device_node *mdio_bus_np)
+{
+	struct device *d;
+
+	if (!mdio_bus_np)
+		return NULL;
+
+	d = class_find_device(&mdio_bus_class, NULL,  mdio_bus_np,
+			      of_mdio_bus_match);
+
+	return d ? to_mii_bus(d) : NULL;
+}
+EXPORT_SYMBOL(of_mdio_find_bus);
+#endif
+
 /**
  * mdiobus_register - bring up all the PHYs on a given bus and attach them to bus
  * @bus: target mii_bus
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 483c0ad..2574abd 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -45,6 +45,8 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 		for (i=0; i<PHY_MAX_ADDR; i++)
 			mdio->irq[i] = PHY_POLL;
 
+	mdio->dev.of_node = np;
+
 	/* Register the MDIO bus */
 	rc = mdiobus_register(mdio);
 	if (rc)
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 53b94e0..912c27a 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -22,4 +22,6 @@ extern struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 					 void (*hndlr)(struct net_device *),
 					 phy_interface_t iface);
 
+extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
+
 #endif /* __LINUX_OF_MDIO_H */
-- 
1.7.2.3
