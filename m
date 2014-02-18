From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v4] sh_eth: add device tree support
Date: Tue, 18 Feb 2014 03:12:43 +0300
Message-ID: <201402180312.44775.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, rob@landley.net,
	linux-doc@vger.kernel.org
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	grant.likely@linaro.org, devicetree@vger.kernel.org,
	linux-sh@vger.kernel.org, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support of the device tree probing for the Renesas SH-Mobile SoCs
documenting the device tree binding as necessary.

This work is loosely based on the original patch by Nobuhiro Iwamatsu
<nobuhiro.iwamatsu.yj@renesas.com>.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against DaveM's 'net-next.git' repo but should also apply to the
recent 'renesas.git' repo's 'devel' branch. It assumes the patch documenting all
Ethernet bindings in one file to be applied as well.

Changes in version 4:
- removed devm_kfree() call from error path in sh_eth_parse_dt();
- removed error handling for of_match_device() call as it's guaranteed to
  succeed after DT probing.

Changes in version 3:
- added probing for R8A7791 and R7S72100;
- added irq_of_parse_and_map() call to read PHY IRQ from device tree;
- removed '!phy' check before reading the PHY node's "reg" property;
- replaced "phy-handle" and "phy-mode" property descriptions with references to
  the common Ethernet bindings file;
- added "clocks" required property; 
- removed "local-mac-address" optional property; 
- replaced Armadiallo800EVA board with Lager board in the binding example;
- updated driver's copyrights;
- refreshed the patch.

Changes in version 2:
- added sh_eth_match_table[] entry for "renesas,ether-r8a7778", documented it;
- clarified descriptions of the "reg" and "interrupt" properties;
- moved "interrupt-parent" from required properties to optional;
- mentioned the necessary PHY subnode to the "phy-handle" property description,
  documented the requered "#address-cells" and "#size-cells" properties;
- clarified the types/descriptions of the Renesas specific properties;
- refreshed the patch.

 Documentation/devicetree/bindings/net/sh_eth.txt |   55 ++++++++++++++++++
 drivers/net/ethernet/renesas/sh_eth.c            |   69 ++++++++++++++++++++++-
 2 files changed, 121 insertions(+), 3 deletions(-)

Index: net-next/Documentation/devicetree/bindings/net/sh_eth.txt
===================================================================
--- /dev/null
+++ net-next/Documentation/devicetree/bindings/net/sh_eth.txt
@@ -0,0 +1,55 @@
+* Renesas Electronics SH EtherMAC
+
+This file provides information on what the device node for the SH EtherMAC
+interface contains.
+
+Required properties:
+- compatible: "renesas,gether-r8a7740" if the device is a part of R8A7740 SoC.
+	      "renesas,ether-r8a7778"  if the device is a part of R8A7778 SoC.
+	      "renesas,ether-r8a7779"  if the device is a part of R8A7779 SoC.
+	      "renesas,ether-r8a7790"  if the device is a part of R8A7790 SoC.
+	      "renesas,ether-r8a7791"  if the device is a part of R8A7791 SoC.
+	      "renesas,ether-r7s72100" if the device is a part of R7S72100 SoC.
+- reg: offset and length of (1) the E-DMAC/feLic register block (required),
+       (2) the TSU register block (optional).
+- interrupts: interrupt specifier for the sole interrupt.
+- phy-mode: see ethernet.txt file in the same directory.
+- phy-handle: see ethernet.txt file in the same directory.
+- #address-cells: number of address cells for the MDIO bus, must be equal to 1.
+- #size-cells: number of size cells on the MDIO bus, must be equal to 0.
+- clocks: clock phandle and specifier pair.
+- pinctrl-0: phandle, referring to a default pin configuration node.
+
+Optional properties:
+- interrupt-parent: the phandle for the interrupt controller that services
+		    interrupts for this device.
+- pinctrl-names: pin configuration state name ("default").
+- renesas,no-ether-link: boolean, specify when a board does not provide a proper
+			 Ether LINK signal.
+- renesas,ether-link-active-low: boolean, specify when the Ether LINK signal is
+				 active-low instead of normal active-high.
+
+Example (Lager board):
+
+	ethernet@ee700000 {
+		compatible = "renesas,ether-r8a7790";
+		reg = <0 0xee700000 0 0x400>;
+		interrupt-parent = <&gic>;
+		interrupts = <0 162 IRQ_TYPE_LEVEL_HIGH>;
+		clocks = <&mstp8_clks R8A7790_CLK_ETHER>;
+		phy-mode = "rmii";
+		phy-handle = <&phy1>;
+		pinctrl-0 = <&ether_pins>;
+		pinctrl-names = "default";
+		renesas,ether-link-active-low;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		phy1: ethernet-phy@1 {
+			reg = <1>;
+			interrupt-parent = <&irqc0>;
+			interrupts = <0 IRQ_TYPE_LEVEL_LOW>;
+			pinctrl-0 = <&phy1_pins>;
+			pinctrl-names = "default";
+		};
+	};
Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1,8 +1,8 @@
 /*  SuperH Ethernet device driver
  *
  *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
- *  Copyright (C) 2008-2013 Renesas Solutions Corp.
- *  Copyright (C) 2013 Cogent Embedded, Inc.
+ *  Copyright (C) 2008-2014 Renesas Solutions Corp.
+ *  Copyright (C) 2013-2014 Cogent Embedded, Inc.
  *
  *  This program is free software; you can redistribute it and/or modify it
  *  under the terms and conditions of the GNU General Public License,
@@ -27,6 +27,10 @@
 #include <linux/platform_device.h>
 #include <linux/mdio-bitbang.h>
 #include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
 #include <linux/phy.h>
 #include <linux/cache.h>
 #include <linux/io.h>
@@ -2710,6 +2714,54 @@ static const struct net_device_ops sh_et
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
+#ifdef CONFIG_OF
+static struct sh_eth_plat_data *sh_eth_parse_dt(struct device *dev)
+{
+	struct device_node *np = dev->of_node;
+	struct sh_eth_plat_data *pdata;
+	struct device_node *phy;
+	const char *mac_addr;
+
+	pdata = devm_kzalloc(dev, sizeof(*pdata), GFP_KERNEL);
+	if (!pdata)
+		return NULL;
+
+	pdata->phy_interface = of_get_phy_mode(np);
+
+	phy = of_parse_phandle(np, "phy-handle", 0);
+	if (of_property_read_u32(phy, "reg", &pdata->phy))
+		return NULL;
+	pdata->phy_irq = irq_of_parse_and_map(phy, 0);
+
+	mac_addr = of_get_mac_address(np);
+	if (mac_addr)
+		memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
+
+	pdata->no_ether_link =
+		of_property_read_bool(np, "renesas,no-ether-link");
+	pdata->ether_link_active_low =
+		of_property_read_bool(np, "renesas,ether-link-active-low");
+
+	return pdata;
+}
+
+static const struct of_device_id sh_eth_match_table[] = {
+	{ .compatible = "renesas,gether-r8a7740", .data = &r8a7740_data },
+	{ .compatible = "renesas,ether-r8a7778", .data = &r8a777x_data },
+	{ .compatible = "renesas,ether-r8a7779", .data = &r8a777x_data },
+	{ .compatible = "renesas,ether-r8a7790", .data = &r8a779x_data },
+	{ .compatible = "renesas,ether-r8a7791", .data = &r8a779x_data },
+	{ .compatible = "renesas,ether-r7s72100", .data = &r7s72100_data },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, sh_eth_match_table);
+#else
+static inline struct sh_eth_plat_data *sh_eth_parse_dt(struct device *dev)
+{
+	return NULL;
+}
+#endif
+
 static int sh_eth_drv_probe(struct platform_device *pdev)
 {
 	int ret, devno = 0;
@@ -2763,6 +2815,8 @@ static int sh_eth_drv_probe(struct platf
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_resume(&pdev->dev);
 
+	if (pdev->dev.of_node)
+		pd = sh_eth_parse_dt(&pdev->dev);
 	if (!pd) {
 		dev_err(&pdev->dev, "no platform data\n");
 		ret = -EINVAL;
@@ -2778,7 +2832,15 @@ static int sh_eth_drv_probe(struct platf
 	mdp->ether_link_active_low = pd->ether_link_active_low;
 
 	/* set cpu data */
-	mdp->cd = (struct sh_eth_cpu_data *)id->driver_data;
+	if (id) {
+		mdp->cd = (struct sh_eth_cpu_data *)id->driver_data;
+	} else	{
+		const struct of_device_id *match;
+
+		match = of_match_device(of_match_ptr(sh_eth_match_table),
+					&pdev->dev);
+		mdp->cd = (struct sh_eth_cpu_data *)match->data;
+	}
 	mdp->reg_offset = sh_eth_get_register_offset(mdp->cd->register_type);
 	sh_eth_set_default_cpu_data(mdp->cd);
 
@@ -2920,6 +2982,7 @@ static struct platform_driver sh_eth_dri
 	.driver = {
 		   .name = CARDNAME,
 		   .pm = SH_ETH_PM_OPS,
+		   .of_match_table = of_match_ptr(sh_eth_match_table),
 	},
 };
 
