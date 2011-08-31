From: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] netdev/of/phy: New function: of_mdio_find_bus().
Date: Wed, 31 Aug 2011 13:01:44 -0700
Message-ID: <1314820906-14004-2-git-send-email-david.daney@cavium.com>
References: <1314820906-14004-1-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1314820906-14004-1-git-send-email-david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Add of_mdio_find_bus() which allows an mii_bus to be located given its
associated the device tree node.

This is needed by the follow-on patch to add a driver for MDIO bus
multiplexers.

The of_mdiobus_register() function is modified so that the device tree
node is recorded in the mii_bus.  Then we can find it again by
iterating over all mdio_bus_class devices.

Signed-off-by: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/phy/mdio_bus.c |    3 ++-
 drivers/of/of_mdio.c       |   26 ++++++++++++++++++++++++++
 include/linux/of_mdio.h    |    2 ++
 include/linux/phy.h        |    1 +
 4 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6c58da2..227a060 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -70,10 +70,11 @@ static void mdiobus_release(struct device *d)
 	kfree(bus);
 }
 
-static struct class mdio_bus_class = {
+struct class mdio_bus_class = {
 	.name		= "mdio_bus",
 	.dev_release	= mdiobus_release,
 };
+EXPORT_SYMBOL(mdio_bus_class);
 
 /**
  * mdiobus_register - bring up all the PHYs on a given bus and attach them to bus
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index d35e300..7c28e8c 100644
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
@@ -189,3 +191,27 @@ struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 	return IS_ERR(phy) ? NULL : phy;
 }
 EXPORT_SYMBOL(of_phy_connect_fixed_link);
+
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
+struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
+{
+	struct device *d;
+
+	if (!mdio_np)
+		return NULL;
+
+	d = class_find_device(&mdio_bus_class, NULL,  mdio_np, of_phy_match);
+
+	return d ? to_mii_bus(d) : NULL;
+}
+EXPORT_SYMBOL(of_mdio_find_bus);
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
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 54fc413..e4c3844 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -528,4 +528,5 @@ int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
 
 extern struct bus_type mdio_bus_type;
+extern struct class mdio_bus_class;
 #endif /* __PHY_H */
-- 
1.7.2.3
