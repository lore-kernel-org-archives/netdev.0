From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] net: add init-regs for of_phy support
Date: Mon, 17 Feb 2014 13:08:04 +0000
Message-ID: <1392642484-19938-2-git-send-email-ben.dooks@codethink.co.uk>
References: <1392642484-19938-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: linux-sh@vger.kernel.org, Ben Dooks <ben.dooks@codethink.co.uk>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1392642484-19938-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add new init-regs field for of_phy nodes and make sure these
get applied when the phy is configured.

This allows any phy node in an fdt to initialise registers
that may not be set as standard by the driver at initialisation
time, such as LED controls.

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
 Documentation/devicetree/bindings/net/phy.txt | 12 ++++++
 drivers/net/phy/phy_device.c                  | 59 ++++++++++++++++++++++++++-
 2 files changed, 70 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index 58307d0..48d8ded 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -20,6 +20,8 @@ Optional Properties:
   assume clause 22. The compatible list may also contain other
   elements.
 - max-speed: Maximum PHY supported speed (10, 100, 1000...)
+- init-regs: Set of registers to modify at initialisation as a
+    a set of <register set clear>
 
 Example:
 
@@ -29,3 +31,13 @@ ethernet-phy@0 {
 	interrupts = <35 1>;
 	reg = <0>;
 };
+
+ethernet-phy@0 {
+	compatible = "ethernet-phy-ieee802.3-c22";
+	interrupt-parent = <40000>;
+	interrupts = <35 1>;
+	reg = <0>;
+
+	/* set KSZ8041 LED mode bits correctly */
+	init-reg = <0x1e 0x4000 0xc000>;
+};
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 82514e7..6741cdb 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -33,6 +33,7 @@
 #include <linux/mdio.h>
 #include <linux/io.h>
 #include <linux/uaccess.h>
+#include <linux/of.h>
 
 #include <asm/irq.h>
 
@@ -532,6 +533,57 @@ static int phy_poll_reset(struct phy_device *phydev)
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static int of_phy_configure(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->dev;
+	struct device_node *of_node = dev->of_node;
+	struct property *prop;
+	const __be32 *ptr;
+	u32 reg, set, clear;
+	int len;
+	int val;
+
+	if (!of_node)
+		of_node = dev->parent->of_node;
+	if (!of_node)
+		return 0;
+
+	prop = of_find_property(of_node, "init-regs", &len);
+	if (prop) {
+		if (len % (sizeof(__be32) * 3)) {
+			dev_err(dev, "init-regs not multiple of 3 entries\n");
+			return -EINVAL;
+		}
+
+		ptr = of_prop_next_u32(prop, ptr, &reg);
+		while (ptr != NULL) {
+			ptr = of_prop_next_u32(prop, ptr, &reg);
+			ptr = of_prop_next_u32(prop, ptr, &set);
+			ptr = of_prop_next_u32(prop, ptr, &clear);
+
+			val = phy_read(phydev, reg);
+			if (val < 0) {
+				dev_err(dev, "failed to read %d\n", reg);
+				return val;
+			}
+
+			val &= ~clear;
+			val |= set;
+			phy_write(phydev, reg, val);
+
+			dev_info(dev, "set d to %04x\n", reg, val);
+
+			ptr = of_prop_next_u32(prop, ptr, &reg);
+		}
+	}
+
+	return 0;
+}
+#else
+static inline int of_phy_configure(struct phy_device *phydev) { return 0; }
+#endif
+
 int phy_init_hw(struct phy_device *phydev)
 {
 	int ret;
@@ -551,7 +603,12 @@ int phy_init_hw(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	return phydev->drv->config_init(phydev);
+	ret = phydev->drv->config_init(phydev);
+
+	if (ret == 0)
+		ret = of_phy_configure(phydev);
+
+	return ret;
 }
 EXPORT_SYMBOL(phy_init_hw);
 
-- 
1.8.5.3

