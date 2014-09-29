From: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH RESEND v6 5/7] net: cpsw: Add am33xx MACID readout
Date: Mon, 29 Sep 2014 08:53:17 +0200
Message-ID: <1411973599-18908-6-git-send-email-mpa@pengutronix.de>
References: <1411973599-18908-1-git-send-email-mpa@pengutronix.de>
Cc: =?UTF-8?q?Beno=C3=AEt=20Cousson?= <bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
	Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
	Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
	linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411973599-18908-1-git-send-email-mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a function to get the MACIDs from the am33xx SoC
control module registers which hold unique vendor MACIDs. This is only
used if of_get_mac_address() fails to get a valid mac address.

Signed-off-by: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Reviewed-by: Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>
Tested-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Acked-by: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
---

Notes:
    Changes in v6:
     - Move machine check outside of cpsw_am33xx_cm_get_macid()
    
    Changes in v5:
     - Fixed indention

 Documentation/devicetree/bindings/net/cpsw.txt |  4 +++
 drivers/net/ethernet/ti/Kconfig                |  2 ++
 drivers/net/ethernet/ti/cpsw.c                 | 42 +++++++++++++++++++++++++-
 3 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 107caf174a0e..33fe8462edf4 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -24,6 +24,8 @@ Optional properties:
 - ti,hwmods		: Must be "cpgmac0"
 - no_bd_ram		: Must be 0 or 1
 - dual_emac		: Specifies Switch to act as Dual EMAC
+- syscon		: Phandle to the system control device node, which is
+			  the control module device of the am33x
 
 Slave Properties:
 Required properties:
@@ -57,6 +59,7 @@ Examples:
 		active_slave = <0>;
 		cpts_clock_mult = <0x80000000>;
 		cpts_clock_shift = <29>;
+		syscon = <&cm>;
 		cpsw_emac0: slave@0 {
 			phy_id = <&davinci_mdio>, <0>;
 			phy-mode = "rgmii-txid";
@@ -85,6 +88,7 @@ Examples:
 		active_slave = <0>;
 		cpts_clock_mult = <0x80000000>;
 		cpts_clock_shift = <29>;
+		syscon = <&cm>;
 		cpsw_emac0: slave@0 {
 			phy_id = <&davinci_mdio>, <0>;
 			phy-mode = "rgmii-txid";
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 1769700a6070..5d8cb7956113 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -62,6 +62,8 @@ config TI_CPSW
 	select TI_DAVINCI_CPDMA
 	select TI_DAVINCI_MDIO
 	select TI_CPSW_PHY_SEL
+	select MFD_SYSCON
+	select REGMAP
 	---help---
 	  This driver supports TI's CPSW Ethernet Switch.
 
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 0bc2c2a2c236..12497d921fa6 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -33,6 +33,8 @@
 #include <linux/of_net.h>
 #include <linux/of_device.h>
 #include <linux/if_vlan.h>
+#include <linux/mfd/syscon.h>
+#include <linux/regmap.h>
 
 #include <linux/pinctrl/consumer.h>
 
@@ -1816,6 +1818,36 @@ static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
 	slave->port_vlan = data->dual_emac_res_vlan;
 }
 
+#define AM33XX_CTRL_MAC_LO_REG(id) (0x630 + 0x8 * id)
+#define AM33XX_CTRL_MAC_HI_REG(id) (0x630 + 0x8 * id + 0x4)
+
+static int cpsw_am33xx_cm_get_macid(struct device *dev, int slave,
+		u8 *mac_addr)
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
+	regmap_read(syscon, AM33XX_CTRL_MAC_LO_REG(slave), &macid_lo);
+	regmap_read(syscon, AM33XX_CTRL_MAC_HI_REG(slave), &macid_hi);
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
+
 static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			 struct platform_device *pdev)
 {
@@ -1928,8 +1960,16 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			 PHY_ID_FMT, mdio->name, phyid);
 
 		mac_addr = of_get_mac_address(slave_node);
-		if (mac_addr)
+		if (mac_addr) {
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
+		} else {
+			if (of_machine_is_compatible("ti,am33xx")) {
+				ret = cpsw_am33xx_cm_get_macid(&pdev->dev, i,
+							slave_data->mac_addr);
+				if (ret)
+					return ret;
+			}
+		}
 
 		slave_data->phy_if = of_get_phy_mode(slave_node);
 		if (slave_data->phy_if < 0) {
-- 
2.1.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
