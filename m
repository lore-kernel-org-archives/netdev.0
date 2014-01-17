From: Matthew Garrett <matthew.garrett@nebula.com>
Subject: [PATCH V3] net/dt: Add support for overriding phy configuration from device tree
Date: Fri, 17 Jan 2014 17:57:39 -0500
Message-ID: <1389999459-9483-1-git-send-email-matthew.garrett@nebula.com>
References: <7510122.cayuQ6qt8r@wuerfel>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	kishon@ti.com, Matthew Garrett <matthew.garrett@nebula.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7510122.cayuQ6qt8r@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some hardware may be broken in interesting and board-specific ways, such
that various bits of functionality don't work. This patch provides a
mechanism for overriding mii registers during init based on the contents of
the device tree data, allowing board-specific fixups without having to
pollute generic code.

Signed-off-by: Matthew Garrett <matthew.garrett@nebula.com>
---

V3: Break the main function out into some helper functions and store the
values in some structs.

 Documentation/devicetree/bindings/net/phy.txt | 21 +++++++
 drivers/net/phy/phy_device.c                  | 29 ++++++++-
 drivers/of/of_net.c                           | 87 +++++++++++++++++++++++++++
 include/linux/of_net.h                        | 12 ++++
 4 files changed, 148 insertions(+), 1 deletion(-)

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
index 8f9be2e..75751b7 100644
--- a/drivers/of/of_net.c
+++ b/drivers/of/of_net.c
@@ -93,3 +93,90 @@ const void *of_get_mac_address(struct device_node *np)
 	return NULL;
 }
 EXPORT_SYMBOL(of_get_mac_address);
+
+struct mii_override {
+	char *prop;
+	u32 supported;
+	u16 value;
+};
+
+static struct mii_override mii_advertise_override[] = {
+	{ "phy-mii-advertise-10half", SUPPORTED_10baseT_Half,
+	  ADVERTISE_10HALF },
+	{ "phy-mii-advertise-10full", SUPPORTED_10baseT_Full,
+	  ADVERTISE_10FULL },
+	{ "phy-mii-advertise-100half", SUPPORTED_100baseT_Half,
+	  ADVERTISE_100HALF },
+	{ "phy-mii-advertise-100full", SUPPORTED_100baseT_Full,
+	  ADVERTISE_100FULL },
+	{ "phy-mii-advertise-100base4", 0, ADVERTISE_100BASE4 },
+	{ NULL },
+};
+
+static struct mii_override mii_gigabit_override[] = {
+	{ "phy-mii-advertise-1000half", SUPPORTED_1000baseT_Half,
+	  ADVERTISE_1000HALF },
+	{ "phy-mii-advertise-1000full", SUPPORTED_1000baseT_Full,
+	  ADVERTISE_1000FULL },
+	{ "phy-mii-as-master", 0, CTL1000_AS_MASTER },
+	{ "phy-mii-manual-master", 0, CTL1000_ENABLE_MASTER },
+	{ NULL },
+};
+
+static void mii_handle_override(struct mii_override *override_list,
+				struct phy_device *phydev, u16 *val, u16 *mask)
+{
+	struct device *dev = &phydev->dev;
+	struct device_node *np = dev->of_node;
+	struct mii_override *override;
+	u32 tmp;
+
+	if (!np && dev->parent->of_node)
+		np = dev->parent->of_node;
+
+	if (!np)
+		return;
+
+	for (override = &override_list[0]; override->prop != NULL; override++) {
+		if (!of_property_read_u32(np, override->prop, &tmp)) {
+			if (tmp) {
+				*val |= override->value;
+				phydev->advertising |= override->supported;
+			} else {
+				phydev->advertising &= ~(override->supported);
+			}
+
+			*mask |= override->value;
+		}
+	}
+
+	return;
+}
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
+	*val = 0;
+	*mask = 0;
+
+	switch (reg) {
+	case MII_ADVERTISE:
+		mii_handle_override(mii_advertise_override, phydev, val, mask);
+		break;
+
+	case MII_CTRL1000:
+		mii_handle_override(mii_gigabit_override, phydev, val, mask);
+		break;
+
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
