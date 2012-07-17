From: Anatolij Gustschin <agust@denx.de>
Subject: [net-next PATCH v7] net: ethernet: davinci_emac: add OF support
Date: Tue, 17 Jul 2012 12:34:24 +0200
Message-ID: <1342521264-18466-1-git-send-email-agust@denx.de>
Cc: David Miller <davem@davemloft.net>, Heiko Schocher <hs@denx.de>,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Sekhar Nori <nsekhar@ti.com>, Wolfgang Denk <wd@denx.de>,
	Anatoly Sivov <mm05@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:32992 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431Ab2GQKee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 06:34:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Schocher <hs@denx.de>

add OF support for the davinci_emac driver.

Signed-off-by: Heiko Schocher <hs@denx.de>
Acked-by: Sekhar Nori <nsekhar@ti.com>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
Cc: netdev@vger.kernel.org
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: linux-arm-kernel@lists.infradead.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Wolfgang Denk <wd@denx.de>
Cc: Anatoly Sivov <mm05@mail.ru>
Cc: David Miller <davem@davemloft.net>
---
- changes for v2:
  - add comment from Anatoly Sivov
    - fix typo in davinci_emac.txt
  - add comment from Grant Likely:
    - add prefix "ti,davinci-" to davinci specific property names
    - remove version property
    - use compatible name "ti,davinci-dm6460-emac"
    - use devm_kzalloc()
    - use of_match_ptr()
    - document all new properties
    - remove of_address_to_resource() and do not overwrite
      resource table
    - whitespace fixes
    - remove hw_ram_addr as it is not used in current
      board code
- no changes for v3
- changes for v4:
  add comments from Nori Sekhar:
  - move devictree documentation to:
    Documentation/devicetree/bindings/net/davinci_emac.txt
  - fix typo in it
  - rename compatible property to "ti,davinci-dm6467-emac"
  - remove pinmux-handle
  - set version directly in pdata->version
- no changes for v5
- changes for v6:
  add comment from Nori, Sekhar:
  - use mac address in DT data only if no valid address is passed
    through platform data
  - added Acked-by from Sekhar Nori
  - changes Subject line from "ARM: davinci: net:" to
    "net, ethernet, davinci_emac:"
  - add David Miller to Cc
- changes for v7:
  - rebased to apply on current net-next tree
  - slightly change the subject line and commit log

 .../devicetree/bindings/net/davinci_emac.txt       |   41 +++++++++
 drivers/net/ethernet/ti/davinci_emac.c             |   89 +++++++++++++++++++-
 2 files changed, 129 insertions(+), 1 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/davinci_emac.txt

diff --git a/Documentation/devicetree/bindings/net/davinci_emac.txt b/Documentation/devicetree/bindings/net/davinci_emac.txt
new file mode 100644
index 0000000..48b259e
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/davinci_emac.txt
@@ -0,0 +1,41 @@
+* Texas Instruments Davinci EMAC
+
+This file provides information, what the device node
+for the davinci_emac interface contains.
+
+Required properties:
+- compatible: "ti,davinci-dm6467-emac";
+- reg: Offset and length of the register set for the device
+- ti,davinci-ctrl-reg-offset: offset to control register
+- ti,davinci-ctrl-mod-reg-offset: offset to control module register
+- ti,davinci-ctrl-ram-offset: offset to control module ram
+- ti,davinci-ctrl-ram-size: size of control module ram
+- ti,davinci-rmii-en: use RMII
+- ti,davinci-no-bd-ram: has the emac controller BD RAM
+- phy-handle: Contains a phandle to an Ethernet PHY.
+              if not, davinci_emac driver defaults to 100/FULL
+- interrupts: interrupt mapping for the davinci emac interrupts sources:
+              4 sources: <Receive Threshold Interrupt
+			  Receive Interrupt
+			  Transmit Interrupt
+			  Miscellaneous Interrupt>
+
+Optional properties:
+- local-mac-address : 6 bytes, mac address
+
+Example (enbw_cmc board):
+	eth0: emac@1e20000 {
+		compatible = "ti,davinci-dm6467-emac";
+		reg = <0x220000 0x4000>;
+		ti,davinci-ctrl-reg-offset = <0x3000>;
+		ti,davinci-ctrl-mod-reg-offset = <0x2000>;
+		ti,davinci-ctrl-ram-offset = <0>;
+		ti,davinci-ctrl-ram-size = <0x2000>;
+		local-mac-address = [ 00 00 00 00 00 00 ];
+		interrupts = <33
+				34
+				35
+				36
+				>;
+		interrupt-parent = <&intc>;
+	};
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index ab0bbb7..b298ab0 100644
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
@@ -1760,6 +1769,77 @@ static const struct net_device_ops emac_netdev_ops = {
 #endif
 };
 
+#ifdef CONFIG_OF
+static struct emac_platform_data
+	*davinci_emac_of_get_pdata(struct platform_device *pdev,
+	struct emac_priv *priv)
+{
+	struct device_node *np;
+	struct emac_platform_data *pdata = NULL;
+	const u8 *mac_addr;
+	u32 data;
+	int ret;
+
+	pdata = pdev->dev.platform_data;
+	if (!pdata) {
+		pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
+		if (!pdata)
+			goto nodata;
+	}
+
+	np = pdev->dev.of_node;
+	if (!np)
+		goto nodata;
+	else
+		pdata->version = EMAC_VERSION_2;
+
+	if (!is_valid_ether_addr(pdata->mac_addr)) {
+		mac_addr = of_get_mac_address(np);
+		if (mac_addr)
+			memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
+	}
+
+	ret = of_property_read_u32(np, "ti,davinci-ctrl-reg-offset", &data);
+	if (!ret)
+		pdata->ctrl_reg_offset = data;
+
+	ret = of_property_read_u32(np, "ti,davinci-ctrl-mod-reg-offset",
+		&data);
+	if (!ret)
+		pdata->ctrl_mod_reg_offset = data;
+
+	ret = of_property_read_u32(np, "ti,davinci-ctrl-ram-offset", &data);
+	if (!ret)
+		pdata->ctrl_ram_offset = data;
+
+	ret = of_property_read_u32(np, "ti,davinci-ctrl-ram-size", &data);
+	if (!ret)
+		pdata->ctrl_ram_size = data;
+
+	ret = of_property_read_u32(np, "ti,davinci-rmii-en", &data);
+	if (!ret)
+		pdata->rmii_en = data;
+
+	ret = of_property_read_u32(np, "ti,davinci-no-bd-ram", &data);
+	if (!ret)
+		pdata->no_bd_ram = data;
+
+	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
+	if (!priv->phy_node)
+		pdata->phy_id = "";
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
  * davinci_emac_probe - EMAC device probe
  * @pdev: The DaVinci EMAC device that we are removing
@@ -1802,7 +1882,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	spin_lock_init(&priv->lock);
 
-	pdata = pdev->dev.platform_data;
+	pdata = davinci_emac_of_get_pdata(pdev, priv);
 	if (!pdata) {
 		dev_err(&pdev->dev, "no platform data\n");
 		rc = -ENODEV;
@@ -2013,12 +2093,19 @@ static const struct dev_pm_ops davinci_emac_pm_ops = {
 	.resume		= davinci_emac_resume,
 };
 
+static const struct of_device_id davinci_emac_of_match[] = {
+	{.compatible = "ti,davinci-dm6467-emac", },
+	{},
+};
+MODULE_DEVICE_TABLE(of, davinci_emac_of_match);
+
 /* davinci_emac_driver: EMAC platform driver structure */
 static struct platform_driver davinci_emac_driver = {
 	.driver = {
 		.name	 = "davinci_emac",
 		.owner	 = THIS_MODULE,
 		.pm	 = &davinci_emac_pm_ops,
+		.of_match_table = of_match_ptr(davinci_emac_of_match),
 	},
 	.probe = davinci_emac_probe,
 	.remove = __devexit_p(davinci_emac_remove),
-- 
1.7.1
