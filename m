From: Heiko Schocher <hs@denx.de>
Subject: [RFC PATCH 4/7] ARM: davinci: net: davinci_emac: add OF support
Date: Mon, 23 Jan 2012 09:56:04 +0100
Message-ID: <1327308967-8092-5-git-send-email-hs@denx.de>
References: <1327308967-8092-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs@denx.de>, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Sekhar Nori <nsekhar@ti.com>, Wolfgang Denk <wd@denx.de>
To: davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:34682 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab2AWI4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 03:56:17 -0500
In-Reply-To: <1327308967-8092-1-git-send-email-hs@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add of support for the davinci_emac driver.

Signed-off-by: Heiko Schocher <hs@denx.de>
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: linux-arm-kernel@lists.infradead.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: netdev@vger.kernel.org
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Wolfgang Denk <wd@denx.de>
---
 .../bindings/arm/davinci/davinci_emac.txt          |   46 ++++++++
 drivers/net/ethernet/ti/davinci_emac.c             |  111 +++++++++++++++++++-
 2 files changed, 156 insertions(+), 1 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt

diff --git a/Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt b/Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
new file mode 100644
index 0000000..4e5dc8d
--- /dev/null
+++ b/Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
@@ -0,0 +1,46 @@
+* Texas Instruments Davinci EMAC
+
+This file provides information, what the davice node
+for the davinci_emac interface contain.
+
+Required properties:
+- compatible: "ti,davinci-emac";
+- reg: Offset and length of the register set for the device
+- ctrl_reg_offset: offset to control register
+- ctrl_mod_reg_offset: offset to control module register
+- ctrl_ram_offset: offset to control module ram
+- hw_ram_addr: hardware ram addr
+- ctrl_ram_size: size of control module ram
+- version: 1 (EMAC_VERSION_1 for DM644x)
+           2 (EMAC_VERSION_2 for DM646x)
+- phy-handle: Contains a phandle to an Ethernet PHY.
+              if not, davinci_emac driver defaults to 100/FULL
+- interrupts: interrupt mapping for the davinci emac interrupts sources:
+              4 sources: <Receive Threshold Interrupt
+			  Receive Interrupt
+			  Transmit Interrupt
+			  Miscellaneous Interrupt>
+- pinmux-handle: Contains a handle to configure the pinmux settings.
+
+Optional properties:
+- local-mac-address : 6 bytes, mac address
+
+Example (enbw_cmc board):
+	eth0: emac@1e20000 {
+		compatible = "ti,davinci-emac";
+		reg = <0x220000 0x4000>;
+		ctrl_reg_offset = <0x3000>;
+		ctrl_mod_reg_offset = <0x2000>;
+		ctrl_ram_offset = <0>;
+		hw_ram_addr = <0>;
+		ctrl_ram_size = <0x2000>;
+		version = <1>;
+		local-mac-address = [ 00 00 00 00 00 00 ];
+		interrupts = <33
+				34
+				35
+				36
+				>;
+		interrupt-parent = <&intc>;
+		pinmux-handle = <&emac_pins>;
+	};
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 794ac30..cad7a96 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -58,6 +58,12 @@
 #include <linux/io.h>
 #include <linux/uaccess.h>
 #include <linux/davinci_emac.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
+
+#include <mach/mux.h>
 
 #include <asm/irq.h>
 #include <asm/page.h>
@@ -339,6 +345,9 @@ struct emac_priv {
 	u32 rx_addr_type;
 	atomic_t cur_tx;
 	const char *phy_id;
+#ifdef CONFIG_OF
+	struct device_node *phy_node;
+#endif
 	struct phy_device *phydev;
 	spinlock_t lock;
 	/*platform specific members*/
@@ -1582,6 +1591,7 @@ static int emac_dev_open(struct net_device *ndev)
 	cpdma_ctlr_start(priv->dma);
 
 	priv->phydev = NULL;
+
 	/* use the first phy on the bus if pdata did not give us a phy id */
 	if (!priv->phy_id) {
 		struct device *phy;
@@ -1759,6 +1769,104 @@ static const struct net_device_ops emac_netdev_ops = {
 #endif
 };
 
+#ifdef CONFIG_OF
+static struct emac_platform_data
+	*davinci_emac_of_get_pdata(struct platform_device *pdev,
+	struct emac_priv *priv)
+{
+	struct device_node *np;
+	struct device_node *pinmux_np;
+	struct emac_platform_data *pdata = NULL;
+	const u8 *mac_addr;
+	u32 data;
+	int ret;
+	struct resource temp_res;
+	int irq;
+	int index = 0;
+
+	np = of_find_compatible_node(NULL, NULL, "ti,davinci-emac");
+	if (!np)
+		goto nodata;
+
+	pdata = pdev->dev.platform_data;
+	if (!pdata) {
+		pdata = kzalloc(sizeof(struct emac_platform_data), GFP_KERNEL);
+		if (!pdata)
+			goto nodata;
+	}
+
+	mac_addr = of_get_mac_address(np);
+	if (mac_addr)
+		memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
+
+	ret = of_property_read_u32(np, "ctrl_reg_offset", &data);
+	if (!ret)
+		pdata->ctrl_reg_offset = data;
+
+	ret = of_property_read_u32(np, "ctrl_mod_reg_offset", &data);
+	if (!ret)
+		pdata->ctrl_mod_reg_offset = data;
+
+	ret = of_property_read_u32(np, "ctrl_ram_offset", &data);
+	if (!ret)
+		pdata->ctrl_ram_offset = data;
+
+	ret = of_property_read_u32(np, "hw_ram_addr", &data);
+	if (!ret)
+		pdata->hw_ram_addr = data;
+
+	ret = of_property_read_u32(np, "ctrl_ram_size", &data);
+	if (!ret)
+		pdata->ctrl_ram_size = data;
+
+	ret = of_property_read_u32(np, "rmii_en", &data);
+	if (!ret)
+		pdata->rmii_en = data;
+
+	ret = of_property_read_u32(np, "version", &data);
+	if (!ret)
+		pdata->version = data;
+
+	ret = of_property_read_u32(np, "no_bd_ram", &data);
+	if (!ret)
+		pdata->ctrl_mod_reg_offset = data;
+
+	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
+	if (!priv->phy_node)
+		pdata->phy_id = "";
+
+	if (!of_address_to_resource(np, 0, &temp_res))
+		memcpy(&pdev->resource[0], &temp_res, sizeof(struct resource));
+
+	index = 0;
+	while (index < 4) {
+		irq = irq_of_parse_and_map(np, index);
+		if (irq > 0) {
+			temp_res.start = irq;
+			temp_res.end = irq;
+			temp_res.flags = IORESOURCE_IRQ;
+			memcpy(&pdev->resource[index + 1], &temp_res,
+				sizeof(struct resource));
+		}
+		index++;
+	}
+
+	pinmux_np = of_parse_phandle(np, "pinmux-handle", 0);
+	if (pinmux_np)
+		davinci_cfg_reg_of(pinmux_np);
+
+	pdev->dev.platform_data = pdata;
+nodata:
+	return  pdata;
+}
+#else
+static struct emac_platform_data
+	*davinci_emac_of_get_pdata(struct platform_device *pdev,
+	struct emac_priv *priv)
+{
+	return  pdev->dev.platform_data;
+}
+#endif
 /**
  * davinci_emac_probe: EMAC device probe
  * @pdev: The DaVinci EMAC device that we are removing
@@ -1802,7 +1910,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	spin_lock_init(&priv->lock);
 
-	pdata = pdev->dev.platform_data;
+	pdata = davinci_emac_of_get_pdata(pdev, priv);
 	if (!pdata) {
 		dev_err(&pdev->dev, "no platform data\n");
 		rc = -ENODEV;
@@ -1811,6 +1919,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	/* MAC addr and PHY mask , RMII enable info from platform_data */
 	memcpy(priv->mac_addr, pdata->mac_addr, 6);
+
 	priv->phy_id = pdata->phy_id;
 	priv->rmii_en = pdata->rmii_en;
 	priv->version = pdata->version;
-- 
1.7.7.5
