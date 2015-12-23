From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 15/28] of_mdio: Add "mii-bus" and address property parser
Date: Wed, 23 Dec 2015 13:56:29 +0100
Message-ID: <1450875402-20740-16-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48683 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757070AbbLWM5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:57:25 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper function for parsing an mii-bus property, which should be
a phandle to an MDIO device, and an address of a device on that bus.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/of/of_mdio.c    | 38 ++++++++++++++++++++++++++++++++++++++
 include/linux/of_mdio.h | 10 ++++++++++
 2 files changed, 48 insertions(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index a87a868fed64..3b5c961b8746 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -114,6 +114,44 @@ int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
 }
 EXPORT_SYMBOL(of_mdio_parse_addr);
 
+int of_mdio_parse_bus_and_addr(struct device *dev, const struct device_node *np,
+			       struct mii_bus **mii_bus, int *addr)
+{
+	struct device_node *bus;
+	int ret;
+
+	bus = of_parse_phandle(np, "mii-bus", 0);
+	if (!bus) {
+		dev_err(dev, "%s has invalid mii-bus property",
+			np->full_name);
+		return -EINVAL;
+	}
+
+	*mii_bus = of_mdio_find_bus(bus);
+	if (!*mii_bus) {
+		ret = -EPROBE_DEFER;
+		goto out;
+	}
+
+	ret = of_property_read_u32(np, "addr", addr);
+	if (ret < 0) {
+		dev_err(dev, "%s has invalid PHY address\n", np->full_name);
+		goto out;
+	}
+
+	/* A PHY must have a reg property in the range [0-31] */
+	if (*addr >= PHY_MAX_ADDR) {
+		dev_err(dev, "%s PHY address %i is too large\n",
+			np->full_name, *addr);
+		ret = -EINVAL;
+	}
+out:
+	of_node_put(bus);
+
+	return ret;
+}
+EXPORT_SYMBOL(of_mdio_parse_bus_and_addr);
+
 /**
  * of_mdiobus_register - Register mii_bus and create PHYs from the device tree
  * @mdio: pointer to mii_bus structure
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 8f2237eb3485..25f9440cbc49 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -25,6 +25,9 @@ struct phy_device *of_phy_attach(struct net_device *dev,
 
 extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
 extern int of_mdio_parse_addr(struct device *dev, const struct device_node *np);
+extern int of_mdio_parse_bus_and_addr(struct device *dev,
+				      const struct device_node *np,
+				      struct mii_bus **mii_bus, int *addr);
 
 #else /* CONFIG_OF */
 static inline int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
@@ -67,6 +70,13 @@ static inline int of_mdio_parse_addr(struct device *dev,
 {
 	return -ENOSYS;
 }
+
+static inline int of_mdio_parse_bus(struct device *dev,
+				    const struct device_node *np,
+				    struct mii_bus **mii_bus, int *addr)
+{
+	return -ENOSYS;
+}
 #endif /* CONFIG_OF */
 
 #if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
-- 
2.6.3
