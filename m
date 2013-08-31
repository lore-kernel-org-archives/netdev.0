From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: add device tree support
Date: Sat, 31 Aug 2013 04:29:33 +0400
Message-ID: <201308310429.34856.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org,
	rob@landley.net, linux-doc@vger.kernel.org
To: netdev@vger.kernel.org, rob.herring@calxeda.com,
	pawel.moll@arm.com, mark.rutland@arm.com, swarren@wwwdotorg.org,
	ian.campbell@citrix.com, grant.likely@linaro.org,
	devicetree@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support of the device tree probing for the Renesas SH-Mobile SoCs.

This work is loosely based on an original patch by Nobuhiro Iwamatsu
<nobuhiro.iwamatsu.yj@renesas.com>.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against Dave's 'net-next.git' repo.

 Documentation/devicetree/bindings/net/sh_eth.txt |   40 +++++++++++++
 drivers/net/ethernet/renesas/sh_eth.c            |   66 ++++++++++++++++++++++-
 2 files changed, 105 insertions(+), 1 deletion(-)

Index: net-next/Documentation/devicetree/bindings/net/sh_eth.txt
===================================================================
--- /dev/null
+++ net-next/Documentation/devicetree/bindings/net/sh_eth.txt
@@ -0,0 +1,40 @@
+* Renesas Electronics SH EtherMAC
+
+This file provides information on what the device node for the SH EtherMAC
+interface contains.
+
+Required properties:
+- compatible: "renesas,gether-r8a7740" if the device is a part of R8A7740 SoC.
+	      "renesas,ether-r8a7779" if the device is a part of R8A7778/9 SoCs.
+	      "renesas,ether-r8a7790" if the device is a part of R8A7790/1 SoCs.
+- reg: offset and length of the register set for the device; if the device has
+       TSU registers, you need to specify two register sets here.
+- interrupt-parent: the phandle for the interrupt controller that services
+		    interrupts for this device.
+- interrupts: interrupt mapping for the interrupt source.
+- phy-mode: string, operation mode of the PHY interface (a string that
+	    of_get_phy_mode() can understand).
+- phy-handle: phandle of the PHY device.
+
+Optional properties:
+- local-mac-address: 6 bytes, MAC address.
+- renesas,no-ether-link: specify when a board does not provide a proper LINK
+			 signal.
+- renesas,ether-link-active-low: specify when the LINK signal is active-low.
+
+Example (Armadillo800EVA board):
+
+	ethernet@e9a00000 {
+		compatible = "renesas,gether-r8a7740";
+		reg = <0xe9a00000 0x800>, <0xe9a01800 0x800>;
+		interrupt-parent = <&gic>;
+		interrupts = <0 142 0x4>;
+		phy-mode = "mii";
+		phy-handle = <&phy0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		phy0: ethernet-phy@0 {
+			reg = <0>;
+		};
+	};
Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -32,6 +32,9 @@
 #include <linux/platform_device.h>
 #include <linux/mdio-bitbang.h>
 #include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_net.h>
 #include <linux/phy.h>
 #include <linux/cache.h>
 #include <linux/io.h>
@@ -2600,6 +2603,52 @@ static const struct net_device_ops sh_et
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
+	if (!phy || of_property_read_u32(phy, "reg", &pdata->phy)) {
+		devm_kfree(dev, pdata);
+		return NULL;
+	}
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
+	{ .compatible = "renesas,ether-r8a7779", .data = &r8a777x_data },
+	{ .compatible = "renesas,ether-r8a7790", .data = &r8a7790_data },
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
@@ -2653,6 +2702,8 @@ static int sh_eth_drv_probe(struct platf
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_resume(&pdev->dev);
 
+	if (pdev->dev.of_node)
+		pd = sh_eth_parse_dt(&pdev->dev);
 	if (!pd) {
 		dev_err(&pdev->dev, "no platform data\n");
 		ret = -EINVAL;
@@ -2668,7 +2719,19 @@ static int sh_eth_drv_probe(struct platf
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
+		if (!match) {
+			ret = -EINVAL;
+			goto out_release;
+		}
+		mdp->cd = (struct sh_eth_cpu_data *)match->data;
+	}
 	mdp->reg_offset = sh_eth_get_register_offset(mdp->cd->register_type);
 	sh_eth_set_default_cpu_data(mdp->cd);
 
@@ -2809,6 +2872,7 @@ static struct platform_driver sh_eth_dri
 	.driver = {
 		   .name = CARDNAME,
 		   .pm = SH_ETH_PM_OPS,
+		   .of_match_table = of_match_ptr(sh_eth_match_table),
 	},
 };
 
