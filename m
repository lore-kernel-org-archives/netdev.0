From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 1/2] of: of_mdio: Factor out fixed-link parsing
Date: Sat, 12 Mar 2016 00:08:45 +0100
Message-ID: <1457737726-23907-2-git-send-email-andrew@lunn.ch>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55228 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbcCKXJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 18:09:07 -0500
In-Reply-To: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn the parsing of the fixed link properties into a helper function,
and export it for others to use.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/of/of_mdio.c    | 34 +++++++++++++++++++++-------------
 include/linux/of_mdio.h | 11 ++++++++++-
 2 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 5e7838290998..e9ad328174ff 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -397,6 +397,23 @@ bool of_phy_is_fixed_link(struct device_node *np)
 }
 EXPORT_SYMBOL(of_phy_is_fixed_link);
 
+int of_phy_parse_fixed_link(struct device_node *np,
+			    struct fixed_phy_status *status,
+			    int *link_gpio)
+{
+	status->link = 1;
+	status->duplex = of_property_read_bool(np, "full-duplex");
+	if (of_property_read_u32(np, "speed", &status->speed))
+		return -EINVAL;
+	status->pause = of_property_read_bool(np, "pause");
+	status->asym_pause = of_property_read_bool(np, "asym-pause");
+	*link_gpio = of_get_named_gpio_flags(np, "link-gpios", 0, NULL);
+	if (*link_gpio == -EPROBE_DEFER)
+		return -EPROBE_DEFER;
+	return 0;
+}
+EXPORT_SYMBOL(of_phy_parse_fixed_link);
+
 int of_phy_register_fixed_link(struct device_node *np)
 {
 	struct fixed_phy_status status = {};
@@ -419,20 +436,11 @@ int of_phy_register_fixed_link(struct device_node *np)
 	/* New binding */
 	fixed_link_node = of_get_child_by_name(np, "fixed-link");
 	if (fixed_link_node) {
-		status.link = 1;
-		status.duplex = of_property_read_bool(fixed_link_node,
-						      "full-duplex");
-		if (of_property_read_u32(fixed_link_node, "speed", &status.speed))
-			return -EINVAL;
-		status.pause = of_property_read_bool(fixed_link_node, "pause");
-		status.asym_pause = of_property_read_bool(fixed_link_node,
-							  "asym-pause");
-		link_gpio = of_get_named_gpio_flags(fixed_link_node,
-						    "link-gpios", 0, NULL);
+		err = of_phy_parse_fixed_link(fixed_link_node, &status,
+					      &link_gpio);
 		of_node_put(fixed_link_node);
-		if (link_gpio == -EPROBE_DEFER)
-			return -EPROBE_DEFER;
-
+		if (err)
+			return err;
 		phy = fixed_phy_register(PHY_POLL, &status, link_gpio, np);
 		return IS_ERR(phy) ? PTR_ERR(phy) : 0;
 	}
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 8f2237eb3485..1286a76dbcf0 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -10,6 +10,7 @@
 #define __LINUX_OF_MDIO_H
 
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include <linux/of.h>
 
 #ifdef CONFIG_OF
@@ -25,7 +26,6 @@ struct phy_device *of_phy_attach(struct net_device *dev,
 
 extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
 extern int of_mdio_parse_addr(struct device *dev, const struct device_node *np);
-
 #else /* CONFIG_OF */
 static inline int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 {
@@ -72,6 +72,9 @@ static inline int of_mdio_parse_addr(struct device *dev,
 #if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
 extern int of_phy_register_fixed_link(struct device_node *np);
 extern bool of_phy_is_fixed_link(struct device_node *np);
+extern int of_phy_parse_fixed_link(struct device_node *np,
+				   struct fixed_phy_status *status,
+				   int *link_gpio);
 #else
 static inline int of_phy_register_fixed_link(struct device_node *np)
 {
@@ -81,6 +84,12 @@ static inline bool of_phy_is_fixed_link(struct device_node *np)
 {
 	return false;
 }
+static inline int of_phy_parse_fixed_link(struct device_node *np,
+				   struct fixed_phy_status *status,
+				   int *link_gpio)
+{
+	return -ENOSYS;
+}
 #endif
 
 
-- 
2.7.0
