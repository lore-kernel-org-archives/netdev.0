From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/4] drivers: net: cpsw: davinci_emac: move reading mac id to common file
Date: Mon, 21 Sep 2015 15:56:50 +0530
Message-ID: <1442831213-3913-2-git-send-email-mugunthanvnm@ti.com>
References: <1442831213-3913-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-omap@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>, <devicetree@vger.kernel.org>,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:60502 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932069AbbIUK1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 06:27:39 -0400
In-Reply-To: <1442831213-3913-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moving mac address reading from ethernet driver to common
file for better maintenance and for code reusable.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw-common.c  | 58 ++++++++++++++++++++++++++++------
 drivers/net/ethernet/ti/cpsw.c         | 11 +++----
 drivers/net/ethernet/ti/cpsw.h         |  3 +-
 drivers/net/ethernet/ti/davinci_emac.c | 44 ++------------------------
 4 files changed, 57 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw-common.c b/drivers/net/ethernet/ti/cpsw-common.c
index f595094..c70417c 100644
--- a/drivers/net/ethernet/ti/cpsw-common.c
+++ b/drivers/net/ethernet/ti/cpsw-common.c
@@ -19,11 +19,38 @@
 
 #include "cpsw.h"
 
-#define AM33XX_CTRL_MAC_LO_REG(offset, id) ((offset) + 0x8 * (id))
-#define AM33XX_CTRL_MAC_HI_REG(offset, id) ((offset) + 0x8 * (id) + 0x4)
+#define CTRL_MAC_LO_REG(offset, id) ((offset) + 0x8 * (id))
+#define CTRL_MAC_HI_REG(offset, id) ((offset) + 0x8 * (id) + 0x4)
 
-int cpsw_am33xx_cm_get_macid(struct device *dev, u16 offset, int slave,
-			     u8 *mac_addr)
+static int davinci_emac_3517_get_macid(struct device *dev, u16 offset,
+				       int slave, u8 *mac_addr)
+{
+	u32 macid_lsb;
+	u32 macid_msb;
+	struct regmap *syscon;
+
+	syscon = syscon_regmap_lookup_by_phandle(dev->of_node, "syscon");
+	if (IS_ERR(syscon)) {
+		if (PTR_ERR(syscon) == -ENODEV)
+			return 0;
+		return PTR_ERR(syscon);
+	}
+
+	regmap_read(syscon, CTRL_MAC_LO_REG(offset, slave), &macid_lsb);
+	regmap_read(syscon, CTRL_MAC_HI_REG(offset, slave), &macid_msb);
+
+	mac_addr[0] = (macid_msb >> 16) & 0xff;
+	mac_addr[1] = (macid_msb >> 8)  & 0xff;
+	mac_addr[2] = macid_msb & 0xff;
+	mac_addr[3] = (macid_lsb >> 16) & 0xff;
+	mac_addr[4] = (macid_lsb >> 8)  & 0xff;
+	mac_addr[5] = macid_lsb & 0xff;
+
+	return 0;
+}
+
+static int cpsw_am33xx_cm_get_macid(struct device *dev, u16 offset, int slave,
+				    u8 *mac_addr)
 {
 	u32 macid_lo;
 	u32 macid_hi;
@@ -36,10 +63,8 @@ int cpsw_am33xx_cm_get_macid(struct device *dev, u16 offset, int slave,
 		return PTR_ERR(syscon);
 	}
 
-	regmap_read(syscon, AM33XX_CTRL_MAC_LO_REG(offset, slave),
-		    &macid_lo);
-	regmap_read(syscon, AM33XX_CTRL_MAC_HI_REG(offset, slave),
-		    &macid_hi);
+	regmap_read(syscon, CTRL_MAC_LO_REG(offset, slave), &macid_lo);
+	regmap_read(syscon, CTRL_MAC_HI_REG(offset, slave), &macid_hi);
 
 	mac_addr[5] = (macid_lo >> 8) & 0xff;
 	mac_addr[4] = macid_lo & 0xff;
@@ -50,6 +75,21 @@ int cpsw_am33xx_cm_get_macid(struct device *dev, u16 offset, int slave,
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(cpsw_am33xx_cm_get_macid);
+
+int ti_cm_get_macid(struct device *dev, int slave, u8 *mac_addr)
+{
+	if (of_machine_is_compatible("ti,am33xx"))
+		return cpsw_am33xx_cm_get_macid(dev, 0x630, slave, mac_addr);
+
+	if (of_device_is_compatible(dev->of_node, "ti,am3517-emac"))
+		return davinci_emac_3517_get_macid(dev, 0x110, slave, mac_addr);
+
+	if (of_device_is_compatible(dev->of_node, "ti,dm816-emac"))
+		return cpsw_am33xx_cm_get_macid(dev, 0x30, slave, mac_addr);
+
+	dev_err(dev, "incompatible machine/device type for reading mac address\n");
+	return -ENOENT;
+}
+EXPORT_SYMBOL_GPL(ti_cm_get_macid);
 
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c670317..75584cc 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2058,13 +2058,10 @@ no_phy_slave:
 		if (mac_addr) {
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
 		} else {
-			if (of_machine_is_compatible("ti,am33xx")) {
-				ret = cpsw_am33xx_cm_get_macid(&pdev->dev,
-							0x630, i,
-							slave_data->mac_addr);
-				if (ret)
-					return ret;
-			}
+			ret = ti_cm_get_macid(&pdev->dev, i,
+					      slave_data->mac_addr);
+			if (ret)
+				return ret;
 		}
 		if (data->dual_emac) {
 			if (of_property_read_u32(slave_node, "dual_emac_res_vlan",
diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
index ca90efa..442a703 100644
--- a/drivers/net/ethernet/ti/cpsw.h
+++ b/drivers/net/ethernet/ti/cpsw.h
@@ -41,7 +41,6 @@ struct cpsw_platform_data {
 };
 
 void cpsw_phy_sel(struct device *dev, phy_interface_t phy_mode, int slave);
-int cpsw_am33xx_cm_get_macid(struct device *dev, u16 offset, int slave,
-			     u8 *mac_addr);
+int ti_cm_get_macid(struct device *dev, int slave, u8 *mac_addr);
 
 #endif /* __CPSW_H__ */
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index a21c77b..39a54b2 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1882,51 +1882,13 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 	return  pdata;
 }
 
-static int davinci_emac_3517_get_macid(struct device *dev, u16 offset,
-				       int slave, u8 *mac_addr)
-{
-	u32 macid_lsb;
-	u32 macid_msb;
-	struct regmap *syscon;
-
-	syscon = syscon_regmap_lookup_by_phandle(dev->of_node, "syscon");
-	if (IS_ERR(syscon)) {
-		if (PTR_ERR(syscon) == -ENODEV)
-			return 0;
-		return PTR_ERR(syscon);
-	}
-
-	regmap_read(syscon, offset, &macid_lsb);
-	regmap_read(syscon, offset + 4, &macid_msb);
-
-	mac_addr[0] = (macid_msb >> 16) & 0xff;
-	mac_addr[1] = (macid_msb >> 8)  & 0xff;
-	mac_addr[2] = macid_msb & 0xff;
-	mac_addr[3] = (macid_lsb >> 16) & 0xff;
-	mac_addr[4] = (macid_lsb >> 8)  & 0xff;
-	mac_addr[5] = macid_lsb & 0xff;
-
-	return 0;
-}
-
 static int davinci_emac_try_get_mac(struct platform_device *pdev,
 				    int instance, u8 *mac_addr)
 {
-	int error = -EINVAL;
-
 	if (!pdev->dev.of_node)
-		return error;
-
-	if (of_device_is_compatible(pdev->dev.of_node, "ti,am3517-emac"))
-		error = davinci_emac_3517_get_macid(&pdev->dev, 0x110,
-						    0, mac_addr);
-	else if (of_device_is_compatible(pdev->dev.of_node,
-					 "ti,dm816-emac"))
-		error = cpsw_am33xx_cm_get_macid(&pdev->dev, 0x30,
-						 instance,
-						 mac_addr);
-
-	return error;
+		return -EINVAL;
+
+	return ti_cm_get_macid(&pdev->dev, instance, mac_addr);
 }
 
 /**
-- 
2.6.0.rc2.10.gf4d9753
