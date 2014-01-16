From: Matthew Garrett <matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V2] net/dt: Add support for overriding phy configuration from device tree
Date: Thu, 16 Jan 2014 09:47:11 -0500
Message-ID: <1389883631-1480-1-git-send-email-matthew.garrett@nebula.com>
References: <20140116135905.GV20094@book.gsilab.sittig.org>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kishon-l0cyMroinI0@public.gmane.org, Matthew Garrett <matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140116135905.GV20094-kDjWylLy9wD0K7fsECOQyeGNnDKD8DIp@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some hardware may be broken in interesting and board-specific ways, such
that various bits of functionality don't work. This patch provides a
mechanism for overriding mii registers during init based on the contents of
the device tree data, allowing board-specific fixups without having to
pollute generic code.

Signed-off-by: Matthew Garrett <matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>
---
 Documentation/devicetree/bindings/net/phy.txt |  21 +++++
 drivers/net/phy/phy_device.c                  |  29 +++++-
 drivers/of/of_net.c                           | 124 ++++++++++++++++++++++++++
 include/linux/of_net.h                        |  12 +++
 4 files changed, 185 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index 7cd18fb..fc50f02 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -23,6 +23,21 @@ Optional Properties:
   assume clause 22. The compatible list may also contain other
   elements.
 
+The following properties may be added to either the phy node or the parent
+ethernet device. If not present, the hardware defaults will be used.
+
+- phy-mii-advertise-10half: 1 to advertise half-duplex 10MBit, 0 to disable
+- phy-mii-advertise-10full: 1 to advertise full-duplex 10MBit, 0 to disable
+- phy-mii-advertise-100half: 1 to advertise half-duplex 100MBit, 0 to disable
+- phy-mii-advertise-100full: 1 to advertise full-duplex 100MBit, 0 to disable
+- phy-mii-advertise-100base4: 1 to advertise 100base4, 0 to disable
+- phy-mii-advertise-1000half: 1 to advertise half-duplex 1000MBit, 0 to disable
+- phy-mii-advertise-1000full: 1 to advertise full-duplex 1000MBit, 0 to disable
+- phy-mii-manual-master: 1 to enable manual master/slave configuration, 0
+  to disable manual master/slave configuration
+- phy-mii-as-master: 1 to configure phy to act as master, 0 to configure phy
+  to act as slave. Ignored if manual master/slave configuration is not enabled.
+
 Example:
 
 ethernet-phy@0 {
@@ -32,4 +47,10 @@ ethernet-phy@0 {
 	interrupts = <35 1>;
 	reg = <0>;
 	device_type = "ethernet-phy";
+	// Disable advertising of full duplex 1000MBit
+	phy-mii-advertise-1000full = <0>;
+	// Force manual phy master/slave configuration
+	phy-mii-manual-master = <1>;
+	// Forcibly configure phy as slave
+	phy-mii-as-master = <0>;
 };
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index d6447b3..91793bc 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -33,6 +33,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/of_net.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -497,6 +498,28 @@ void phy_disconnect(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_disconnect);
 
+int phy_override_from_of(struct phy_device *phydev)
+{
+	int reg, regval;
+	u16 val, mask;
+
+	/* Check for phy register overrides from OF */
+	for (reg = 0; reg < 16; reg++) {
+		if (!of_get_mii_register(phydev, reg, &val, &mask)) {
+			if (!mask)
+				continue;
+			regval = phy_read(phydev, reg);
+			if (regval < 0)
+				continue;
+			regval &= ~mask;
+			regval |= val;
+			phy_write(phydev, reg, regval);
+		}
+	}
+
+	return 0;
+}
+
 int phy_init_hw(struct phy_device *phydev)
 {
 	int ret;
@@ -508,7 +531,11 @@ int phy_init_hw(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	return phydev->drv->config_init(phydev);
+	ret = phydev->drv->config_init(phydev);
+	if (ret < 0)
+		return ret;
+
+	return phy_override_from_of(phydev);
 }
 
 /**
diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
index 8f9be2e..4545608 100644
--- a/drivers/of/of_net.c
+++ b/drivers/of/of_net.c
@@ -93,3 +93,127 @@ const void *of_get_mac_address(struct device_node *np)
 	return NULL;
 }
 EXPORT_SYMBOL(of_get_mac_address);
+
+/**
+ * Provide phy register overrides from the device tree. Some hardware may
+ * be broken in interesting and board-specific ways, so we want a mechanism
+ * for the board data to provide overrides for default values. This should be
+ * called during phy init.
+ */
+int of_get_mii_register(struct phy_device *phydev, int reg, u16 *val,
+			u16 *mask)
+{
+	u32 tmp;
+	struct device *dev = &phydev->dev;
+	struct device_node *np = dev->of_node;
+
+	*val = 0;
+	*mask = 0;
+
+	if (!np && dev->parent->of_node)
+		np = dev->parent->of_node;
+
+	if (!np)
+		return 0;
+
+	switch (reg) {
+	case MII_ADVERTISE:
+		if (!of_property_read_u32(np, "phy-mii-advertise-10half",
+					   &tmp)) {
+			if (tmp) {
+				*val |= ADVERTISE_10HALF;
+				phydev->advertising |= SUPPORTED_10baseT_Half;
+			} else {
+				phydev->advertising &=
+					~(SUPPORTED_10baseT_Half);
+			}
+
+			*mask |= ADVERTISE_10HALF;
+		}
+		if (!of_property_read_u32(np, "phy-mii-advertise-10full",
+					   &tmp)) {
+			if (tmp) {
+				*val |= ADVERTISE_10FULL;
+				phydev->advertising |= SUPPORTED_10baseT_Full;
+			} else {
+				phydev->advertising &=
+					~(SUPPORTED_10baseT_Full);
+			}
+
+			*mask |= ADVERTISE_10FULL;
+		}
+		if (!of_property_read_u32(np, "phy-mii-advertise-100half",
+					   &tmp)) {
+			if (tmp) {
+				*val |= ADVERTISE_100HALF;
+				phydev->advertising |= SUPPORTED_100baseT_Half;
+			} else {
+				phydev->advertising &=
+					~(SUPPORTED_100baseT_Half);
+			}
+
+			*mask |= ADVERTISE_100HALF;
+		}
+		if (!of_property_read_u32(np, "phy-mii-advertise-100full",
+					   &tmp)) {
+			if (tmp) {
+				*val |= ADVERTISE_100FULL;
+				phydev->advertising |= SUPPORTED_100baseT_Full;
+			} else {
+				phydev->advertising &=
+					~(SUPPORTED_100baseT_Full);
+			}
+
+			*mask |= ADVERTISE_100FULL;
+		}
+		if (!of_property_read_u32(np, "phy-mii-advertise-100base4",
+					   &tmp)) {
+			if (tmp)
+				*val |= ADVERTISE_100BASE4;
+			*mask |= ADVERTISE_100BASE4;
+		}
+		break;
+	case MII_CTRL1000:
+		if (!of_property_read_u32(np, "phy-mii-advertise-1000full",
+					   &tmp)) {
+			if (tmp) {
+				*val |= ADVERTISE_1000FULL;
+				phydev->advertising |= SUPPORTED_1000baseT_Full;
+			} else {
+				phydev->advertising &=
+					~(SUPPORTED_1000baseT_Full);
+			}
+
+			*mask |= ADVERTISE_1000FULL;
+		}
+		if (!of_property_read_u32(np, "phy-mii-advertise-1000half",
+					   &tmp)) {
+			if (tmp) {
+				*val |= ADVERTISE_1000HALF;
+				phydev->advertising |= SUPPORTED_1000baseT_Half;
+			} else {
+				phydev->advertising &=
+					~(SUPPORTED_1000baseT_Half);
+			}
+
+			*mask |= ADVERTISE_1000HALF;
+		}
+		if (!of_property_read_u32(np, "phy-mii-as-master",
+					   &tmp)) {
+			if (tmp)
+				*val |= CTL1000_AS_MASTER;
+			*mask |= CTL1000_AS_MASTER;
+		}
+		if (!of_property_read_u32(np, "phy-mii-manual-master",
+					   &tmp)) {
+			if (tmp)
+				*val |= CTL1000_ENABLE_MASTER;
+			*mask |= CTL1000_ENABLE_MASTER;
+		}
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(of_get_mii_register);
diff --git a/include/linux/of_net.h b/include/linux/of_net.h
index 34597c8..2e478bc 100644
--- a/include/linux/of_net.h
+++ b/include/linux/of_net.h
@@ -7,10 +7,14 @@
 #ifndef __LINUX_OF_NET_H
 #define __LINUX_OF_NET_H
 
+#include <linux/phy.h>
+
 #ifdef CONFIG_OF_NET
 #include <linux/of.h>
 extern int of_get_phy_mode(struct device_node *np);
 extern const void *of_get_mac_address(struct device_node *np);
+extern int of_get_mii_register(struct phy_device *np, int reg, u16 *val,
+			       u16 *mask);
 #else
 static inline int of_get_phy_mode(struct device_node *np)
 {
@@ -21,6 +25,14 @@ static inline const void *of_get_mac_address(struct device_node *np)
 {
 	return NULL;
 }
+static inline int of_get_mii_register(struct phy_device *np, int reg, u16 *val,
+				      u16 *mask)
+{
+	*val = 0;
+	*mask = 0;
+
+	return -EINVAL;
+}
 #endif
 
 #endif /* __LINUX_OF_NET_H */
-- 
1.8.4.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
