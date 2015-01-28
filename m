From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH 1/3] net: cpsw: Add a minimal cpsw-common module for shared code
Date: Wed, 28 Jan 2015 11:33:04 -0800
Message-ID: <1422473586-18100-2-git-send-email-tony@atomide.com>
References: <1422473586-18100-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1422473586-18100-1-git-send-email-tony@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like davinci_emac and cpsw can share some code although the
device registers have a different layout.

At least the code for getting the MAC address using syscon can
be shared by passing the register offset. Let's start with that
and set up a minimal shared cpsw-shared.c.

Cc: Brian Hutchinson <b.hutchman@gmail.com>
Cc: Felipe Balbi <balbi@ti.com>
Signed-off-by: Tony Lindgren <tony@atomide.com>
---
 drivers/net/ethernet/ti/Makefile      |  3 ++
 drivers/net/ethernet/ti/cpsw-common.c | 53 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw.c        | 35 ++---------------------
 drivers/net/ethernet/ti/cpsw.h        |  2 ++
 4 files changed, 60 insertions(+), 33 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpsw-common.c

diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
index 465d03d..7fa47f6 100644
--- a/drivers/net/ethernet/ti/Makefile
+++ b/drivers/net/ethernet/ti/Makefile
@@ -2,6 +2,9 @@
 # Makefile for the TI network device drivers.
 #
 
+obj-$(CONFIG_TI_CPSW) += cpsw-common.o
+obj-$(CONFIG_TI_DAVINCI_EMAC) += cpsw-common.o
+
 obj-$(CONFIG_TLAN) += tlan.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
diff --git a/drivers/net/ethernet/ti/cpsw-common.c b/drivers/net/ethernet/ti/cpsw-common.c
new file mode 100644
index 0000000..763ada1
--- /dev/null
+++ b/drivers/net/ethernet/ti/cpsw-common.c
@@ -0,0 +1,53 @@
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/regmap.h>
+#include <linux/mfd/syscon.h>
+
+#define AM33XX_CTRL_MAC_LO_REG(offset, id) ((offset) + 0x8 * (id))
+#define AM33XX_CTRL_MAC_HI_REG(offset, id) ((offset) + 0x8 * (id) + 0x4)
+
+int cpsw_am33xx_cm_get_macid(struct device *dev, u16 offset, int slave,
+			     u8 *mac_addr)
+{
+	u32 macid_lo;
+	u32 macid_hi;
+	struct regmap *syscon;
+
+	syscon = syscon_regmap_lookup_by_phandle(dev->of_node, "syscon");
+	if (IS_ERR(syscon)) {
+		if (PTR_ERR(syscon) == -ENODEV)
+			return 0;
+		return PTR_ERR(syscon);
+	}
+
+	regmap_read(syscon, AM33XX_CTRL_MAC_LO_REG(offset, slave),
+		    &macid_lo);
+	regmap_read(syscon, AM33XX_CTRL_MAC_HI_REG(offset, slave),
+		    &macid_hi);
+
+	mac_addr[5] = (macid_lo >> 8) & 0xff;
+	mac_addr[4] = macid_lo & 0xff;
+	mac_addr[3] = (macid_hi >> 24) & 0xff;
+	mac_addr[2] = (macid_hi >> 16) & 0xff;
+	mac_addr[1] = (macid_hi >> 8) & 0xff;
+	mac_addr[0] = macid_hi & 0xff;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(cpsw_am33xx_cm_get_macid);
+
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 2b9d404..7d8dd0d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -33,8 +33,6 @@
 #include <linux/of_net.h>
 #include <linux/of_device.h>
 #include <linux/if_vlan.h>
-#include <linux/mfd/syscon.h>
-#include <linux/regmap.h>
 
 #include <linux/pinctrl/consumer.h>
 
@@ -1936,36 +1934,6 @@ static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
 	slave->port_vlan = data->dual_emac_res_vlan;
 }
 
-#define AM33XX_CTRL_MAC_LO_REG(id) (0x630 + 0x8 * id)
-#define AM33XX_CTRL_MAC_HI_REG(id) (0x630 + 0x8 * id + 0x4)
-
-static int cpsw_am33xx_cm_get_macid(struct device *dev, int slave,
-		u8 *mac_addr)
-{
-	u32 macid_lo;
-	u32 macid_hi;
-	struct regmap *syscon;
-
-	syscon = syscon_regmap_lookup_by_phandle(dev->of_node, "syscon");
-	if (IS_ERR(syscon)) {
-		if (PTR_ERR(syscon) == -ENODEV)
-			return 0;
-		return PTR_ERR(syscon);
-	}
-
-	regmap_read(syscon, AM33XX_CTRL_MAC_LO_REG(slave), &macid_lo);
-	regmap_read(syscon, AM33XX_CTRL_MAC_HI_REG(slave), &macid_hi);
-
-	mac_addr[5] = (macid_lo >> 8) & 0xff;
-	mac_addr[4] = macid_lo & 0xff;
-	mac_addr[3] = (macid_hi >> 24) & 0xff;
-	mac_addr[2] = (macid_hi >> 16) & 0xff;
-	mac_addr[1] = (macid_hi >> 8) & 0xff;
-	mac_addr[0] = macid_hi & 0xff;
-
-	return 0;
-}
-
 static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			 struct platform_device *pdev)
 {
@@ -2090,7 +2058,8 @@ no_phy_slave:
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
 		} else {
 			if (of_machine_is_compatible("ti,am33xx")) {
-				ret = cpsw_am33xx_cm_get_macid(&pdev->dev, i,
+				ret = cpsw_am33xx_cm_get_macid(&pdev->dev,
+							0x630, i,
 							slave_data->mac_addr);
 				if (ret)
 					return ret;
diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
index 1b71067..ca90efa 100644
--- a/drivers/net/ethernet/ti/cpsw.h
+++ b/drivers/net/ethernet/ti/cpsw.h
@@ -41,5 +41,7 @@ struct cpsw_platform_data {
 };
 
 void cpsw_phy_sel(struct device *dev, phy_interface_t phy_mode, int slave);
+int cpsw_am33xx_cm_get_macid(struct device *dev, u16 offset, int slave,
+			     u8 *mac_addr);
 
 #endif /* __CPSW_H__ */
-- 
2.1.4

