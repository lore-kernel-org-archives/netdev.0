From: Tomasz Figa <tomasz.figa@gmail.com>
Subject: [PATCH] net: dm9000: Allow instantiation using device tree
Date: Sun, 19 May 2013 01:03:14 +0200
Message-ID: <1368918194-24030-1-git-send-email-tomasz.figa@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>, s.hauer@pengutronix.de,
	Tomasz Figa <tomasz.figa@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:46717 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429Ab3ERXDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 19:03:37 -0400
Received: by mail-ea0-f181.google.com with SMTP id a11so3096230eae.26
        for <netdev@vger.kernel.org>; Sat, 18 May 2013 16:03:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds Device Tree support to dm9000 driver.

Signed-off-by: Tomasz Figa <tomasz.figa@gmail.com>
---
 .../devicetree/bindings/net/davicom-dm9000.txt     | 27 ++++++++++
 .../devicetree/bindings/vendor-prefixes.txt        |  1 +
 drivers/net/ethernet/davicom/dm9000.c              | 60 ++++++++++++++++++++++
 3 files changed, 88 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/davicom-dm9000.txt

diff --git a/Documentation/devicetree/bindings/net/davicom-dm9000.txt b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
new file mode 100644
index 0000000..d2902db
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
@@ -0,0 +1,27 @@
+Davicom DM9000 Fast Ethernet controller
+
+Required properties:
+- compatible = "davicom,dm9000";
+- reg : physical addresses and sizes of registers, must contain 2 entries:
+    first entry : address register,
+    second entry : address register.
+- interrupt-parent : interrupt controller to which the device is connected
+- interrupts : interrupt specifier specific to interrupt controller
+
+Optional properties:
+- local-mac-address : A bytestring of 6 bytes specifying Ethernet MAC address
+    to use (from firmware or bootloader)
+- davicom,no-eeprom : Configuration EEPROM is not available
+- davicom,ext-phy : Use external PHY
+- davicom,simple-phy : Use NSR to find LinkStatus
+
+Example:
+
+	ethernet@18000000 {
+		compatible = "davicom,dm9000";
+		reg = <0x18000000 0x2 0x18000004 0x2>;
+		interrupt-parent = <&gpn>;
+		interrupts = <7 4>;
+		local-mac-address = [00 00 de ad be ef];
+		davicom,no-eeprom;
+	};
diff --git a/Documentation/devicetree/bindings/vendor-prefixes.txt b/Documentation/devicetree/bindings/vendor-prefixes.txt
index 6931c43..2fe74e6 100644
--- a/Documentation/devicetree/bindings/vendor-prefixes.txt
+++ b/Documentation/devicetree/bindings/vendor-prefixes.txt
@@ -18,6 +18,7 @@ chrp	Common Hardware Reference Platform
 cirrus	Cirrus Logic, Inc.
 cortina	Cortina Systems, Inc.
 dallas	Maxim Integrated Products (formerly Dallas Semiconductor)
+davicom	DAVICOM Semiconductor, Inc.
 denx	Denx Software Engineering
 emmicro	EM Microelectronic
 epson	Seiko Epson Corp.
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 9105465..6c91708 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -29,6 +29,7 @@
 #include <linux/spinlock.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
+#include <linux/of.h>
 #include <linux/ethtool.h>
 #include <linux/dm9000.h>
 #include <linux/delay.h>
@@ -1358,6 +1359,50 @@ static const struct net_device_ops dm9000_netdev_ops = {
 #endif
 };
 
+#ifdef CONFIG_OF
+static struct dm9000_plat_data *dm9000_parse_dt(struct device *dev)
+{
+	struct dm9000_plat_data *pdata;
+	struct device_node *np = dev->of_node;
+	const void *prop;
+	int len;
+
+	if (!np)
+		return NULL;
+
+	pdata = devm_kzalloc(dev, sizeof(*pdata), GFP_KERNEL);
+	if (!pdata) {
+		dev_err(dev, "failed to allocate platform data struct\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	if (of_find_property(np, "davicom,ext-phy", NULL))
+		pdata->flags |= DM9000_PLATF_EXT_PHY;
+	if (of_find_property(np, "davicom,no-eeprom", NULL))
+		pdata->flags |= DM9000_PLATF_NO_EEPROM;
+	if (of_find_property(np, "davicom,simple-phy", NULL))
+		pdata->flags |= DM9000_PLATF_SIMPLE_PHY;
+
+	prop = of_get_property(np, "local-mac-address", &len);
+	if (!prop)
+		return pdata;
+
+	if (len < sizeof(pdata->dev_addr)) {
+		dev_err(dev, "invalid length of local-mac-address property\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	memcpy(pdata->dev_addr, prop, sizeof(pdata->dev_addr));
+
+	return pdata;
+}
+#else
+static struct dm9000_plat_data *dm9000_parse_dt(struct device *unused)
+{
+	return NULL;
+}
+#endif
+
 /*
  * Search DM9000 board, allocate space and register it
  */
@@ -1373,6 +1418,12 @@ dm9000_probe(struct platform_device *pdev)
 	int i;
 	u32 id_val;
 
+	if (!pdata) {
+		pdata = dm9000_parse_dt(&pdev->dev);
+		if (IS_ERR(pdata))
+			return PTR_ERR(pdata);
+	}
+
 	/* Init network device */
 	ndev = alloc_etherdev(sizeof(struct board_info));
 	if (!ndev)
@@ -1683,11 +1734,20 @@ dm9000_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static const struct of_device_id dm9000_of_matches[] = {
+	{ .compatible = "davicom,dm9000", },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, dm9000_of_matches);
+#endif
+
 static struct platform_driver dm9000_driver = {
 	.driver	= {
 		.name    = "dm9000",
 		.owner	 = THIS_MODULE,
 		.pm	 = &dm9000_drv_pm_ops,
+		.of_match_table = of_match_ptr(dm9000_of_matches),
 	},
 	.probe   = dm9000_probe,
 	.remove  = dm9000_drv_remove,
-- 
1.8.2.1
