From: Daniel Morsing <daniel.morsing@gmail.com>
Subject: [RFC PATCH v2] net: dm9000: add support for device tree probing
Date: Sun, 14 Aug 2011 19:34:12 +0200
Message-ID: <1313343252-19634-1-git-send-email-daniel.morsing@gmail.com>
Cc: Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Ben Dooks <ben-linux@fluff.org>,
	Daniel Morsing <daniel.morsing@gmail.com>
To: devicetree-discuss@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:64330 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852Ab1HNReU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2011 13:34:20 -0400
Received: by ewy4 with SMTP id 4so1660488ewy.19
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2011 10:34:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for probing the dm9000 driver through device
trees.

The patch works by supplying its own platform_data struct when probed
via device tree. This allows us to rely on the existing options parsing
in the driver and avoid ifdeffery in the probe function.

Signed-off-by: Daniel Morsing <daniel.morsing@gmail.com>
---
Currently there are no users of this functionality, but once support for
DT on OMAP3 matures, I plan to migrate the devkit8000 board to DT.

 Changes since v1:
	- Changed the binding with input from Grant Likely.
	- Make explicit what the bindings do instead of refering
	  to linux specific flags.
	- Length check the mac address read so we don't copy random data.
	- simplify parsing of the device tree.
	- Add relevant driver maintainers to CC (sorry about that)

 Documentation/devicetree/bindings/net/dm9000.txt |   42 +++++++++++
 drivers/net/dm9000.c                             |   83 +++++++++++++++++++++-
 2 files changed, 122 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dm9000.txt

diff --git a/Documentation/devicetree/bindings/net/dm9000.txt b/Documentation/devicetree/bindings/net/dm9000.txt
new file mode 100644
index 0000000..cbbdb3d
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dm9000.txt
@@ -0,0 +1,42 @@
+Davicom DM9000 ethernet controller
+
+Required properties:
+
+ - compatible : Should be "davicom,dm9000"
+
+ - interrupts : Interrupt controller specific encoding, which specifies 1
+   or 2 interrupts. The first interrupt is for rx/tx and is required by the
+   driver to function. The second interrupt is for wake on lan support
+   and is optional.
+
+ - reg : 2 Physical address specifiers, where the first specifies the address
+   register of device, and the second specifies the data register of the device
+
+Optional properties:
+
+ - local-mac-address : Binary data specifying a mac address override
+
+ - reg-io-width : one cell specifying the width of IO operations in bits.
+   valid values are 8, 16, and 32. If this property is not specified, or has
+   an invalid value, the driver will default to 32 bits.
+
+ - phy-handle : phandle to external phy.
+
+ - no-eeprom  : Empty property specifying that no EEPROM is attached to the
+   device.
+
+ - simple-phy : Empty property specifying that the driver should use the simple
+   phy polling mode
+
+Example:
+
+ethernet@2c000000 {
+	compatible = "davicom,dm9000";
+	reg = <0x2c000000 0x04>,
+	      <0x2c000400 0x04>;
+	interrupts = <185 1>;
+	local-mac-address = [02 65 16 01 c0 09];
+	reg-io-width = <16>
+	phy-handle = <&phy0>
+	no-eeprom;
+};
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 8ef31dc..81273b7 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -35,6 +35,7 @@
 #include <linux/platform_device.h>
 #include <linux/irq.h>
 #include <linux/slab.h>
+#include <linux/of.h>
 
 #include <asm/delay.h>
 #include <asm/irq.h>
@@ -1164,10 +1165,13 @@ dm9000_open(struct net_device *dev)
 	if (netif_msg_ifup(db))
 		dev_dbg(db->dev, "enabling %s\n", dev->name);
 
-	/* If there is no IRQ type specified, default to something that
-	 * may work, and tell the user that this is a problem */
+	/*
+	 * If there is no IRQ type specified, tell the user that this is a
+	 * problem. If we were probed with device tree, we can assume that
+	 * the IRQ type is already set up, so don't emit the warning.
+	 */
 
-	if (irqflags == IRQF_TRIGGER_NONE)
+	if (!db->dev->of_node && irqflags == IRQF_TRIGGER_NONE)
 		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
 
 	irqflags |= IRQF_SHARED;
@@ -1350,6 +1354,66 @@ static const struct net_device_ops dm9000_netdev_ops = {
 #endif
 };
 
+#ifdef CONFIG_OF
+static const struct of_device_id dm9000_of_match[] = {
+	{ .compatible = "davicom,dm9000" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, dm9000_of_match);
+
+static int __devinit
+dm9000_dt_fill_platdata(struct platform_device *pdev,
+			struct dm9000_plat_data *pdata)
+{
+	struct device_node *of_node = pdev->dev.of_node, *phy_node;
+	const u8 *mac_addr;
+	u32 io_width;
+	int mac_len;
+
+	if (!of_property_read_u32(of_node, "reg-io-width", &io_width)) {
+		switch (io_width) {
+		case 8:
+			pdata->flags |= DM9000_PLATF_8BITONLY;
+			break;
+		case 16:
+			pdata->flags |= DM9000_PLATF_16BITONLY;
+			break;
+		default:
+			dev_warn(&pdev->dev,
+				"Invalid value passed in reg-io-width. Defaulting to 32 bit I/O accesses\n");
+		case 32:
+			pdata->flags |= DM9000_PLATF_32BITONLY;
+			break;
+		}
+	}
+
+	phy_node = of_parse_phandle(of_node, "phy-handle", 0);
+	if (phy_node) {
+		pdata->flags |= DM9000_PLATF_EXT_PHY;
+		of_node_put(phy_node);
+	}
+
+	if (of_find_property(of_node, "no-eeprom", NULL))
+		pdata->flags |= DM9000_PLATF_NO_EEPROM;
+	if (of_find_property(of_node, "simple-phy", NULL))
+		pdata->flags |= DM9000_PLATF_SIMPLE_PHY;
+
+	mac_addr = of_get_property(of_node, "local-mac-address", &mac_len);
+	if (mac_addr && mac_len == 6)
+		memcpy(pdata->dev_addr, mac_addr, 6);
+
+	return 0;
+}
+
+#else
+#define dm9000_of_match NULL
+static inline int dm9000_dt_fill_platdata(struct platform_device *pdev,
+					   struct dm9000_plat_data *pdata)
+{
+	return 0;
+}
+#endif /* CONFIG_OF */
+
 /*
  * Search DM9000 board, allocate space and register it
  */
@@ -1359,12 +1423,24 @@ dm9000_probe(struct platform_device *pdev)
 	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
 	struct board_info *db;	/* Point a board information structure */
 	struct net_device *ndev;
+	struct dm9000_plat_data pdata_of;
 	const unsigned char *mac_src;
 	int ret = 0;
 	int iosize;
 	int i;
 	u32 id_val;
 
+	if (pdev->dev.of_node) {
+		if (!pdata) {
+			memset(&pdata_of, 0, sizeof(pdata_of));
+			pdata = &pdata_of;
+		}
+
+		ret = dm9000_dt_fill_platdata(pdev, pdata);
+		if (ret < 0)
+			return ret;
+	}
+
 	/* Init network device */
 	ndev = alloc_etherdev(sizeof(struct board_info));
 	if (!ndev) {
@@ -1677,6 +1753,7 @@ static struct platform_driver dm9000_driver = {
 		.name    = "dm9000",
 		.owner	 = THIS_MODULE,
 		.pm	 = &dm9000_drv_pm_ops,
+		.of_match_table = dm9000_of_match,
 	},
 	.probe   = dm9000_probe,
 	.remove  = __devexit_p(dm9000_drv_remove),
-- 
1.7.6

