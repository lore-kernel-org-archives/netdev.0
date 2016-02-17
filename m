From: John Holland <jotihojr@gmail.com>
Subject: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using
 a device tree blob V3
Date: Wed, 17 Feb 2016 07:43:07 +0100
Message-ID: <56C4167B.7080705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34033 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756418AbcBQGnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 01:43:10 -0500
Received: by mail-wm0-f45.google.com with SMTP id b205so141401391wmb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 22:43:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The Intel i211 LOM pcie ethernet controllers' iNVM operates as an OTP
and has no externel EEPROM interface [1]. The following allows the
driver to pickup the MAC address from a device tree blob when CONFIG_OF
has been enabled.

[1]http://www.intel.com/content/www/us/en/embedded/products/networking/i211-ethernet-controller-datasheet.html

Changes V2
- Restrict searching for compatible devices to current pci device.

Changes V3
- Add device tree binding documentation.

Signed-off-by: John Holland<jotihojr@gmail.com>
---

  Documentation/devicetree/bindings/net/intel,i210.txt | 36 ++++++++++++++++++++++++++++++++++++
  drivers/net/ethernet/intel/igb/igb_main.c            | 30 ++++++++++++++++++++++++++++++
  2 files changed, 66 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/intel,i210.txt b/Documentation/devicetree/bindings/net/intel,i210.txt
new file mode 100644
index 0000000..d6ac8d3
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/intel,i210.txt
@@ -0,0 +1,36 @@
+* Intel I210, I211 PCIe bus controller
+
+Required properties:
+- compatible: must be "intel,i210" as described in
+  Documentation/devicetree/bindings/net/phy.txt;
+
+Optional properties:
+- local-mac-address: as described in
+  Documentation/devicetree/bindings/net/ethernet.txt;
+- mac-address: as described in
+  Documentation/devicetree/bindings/net/ethernet.txt;
+
+Child nodes of this PCIe bus controller node are a subset
+of the standard Ethernet PHY device nodes.
+
+Example:
+
+/*
+ * Set a valid MAC address from the u-boot environment variable eth1addr.
+ * The resulting value may be viewed under
+ * <sysfs>/firmware/devicetree/base/soc/pcie@0x01000000/i211@bus1/
+ */
+
+#include "imx6q.dtsi";
+
+/ {
+	aliases {
+		ethernet1 = &eth1;
+	};
+};
+
+&pcie {
+	eth1: i211@bus1 {
+		compatible = "intel,i210";
+	};
+};
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 31e5f39..f7788fa 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -56,6 +56,11 @@
  #include <linux/i2c.h>
  #include "igb.h"
  
+#ifdef CONFIG_OF
+#include <linux/of_net.h>
+#include <linux/etherdevice.h>
+#endif
+
  #define MAJ 5
  #define MIN 3
  #define BUILD 0
@@ -2216,6 +2221,26 @@ static s32 igb_init_i2c(struct igb_adapter *adapter)
  	return status;
  }
  
+#ifdef CONFIG_OF
+/**
+ *  igb_read_mac_addr_dts - Read mac address from the device tree blob
+ *  @dev: pointer to device structure
+ *  @mac_addr: pointer to found mac address
+ **/
+static void igb_read_mac_addr_dts(const struct device *dev, u8 *mac_addr)
+{
+	const u8 *mac;
+	struct device_node *dn;
+
+	dn = of_find_compatible_node(dev->of_node, NULL, "intel,i210");
+	if (dn) {
+		mac = of_get_mac_address(dn);
+		if (mac)
+			ether_addr_copy(mac_addr, mac);
+	}
+}
+#endif
+
  /**
   *  igb_probe - Device Initialization Routine
   *  @pdev: PCI device information struct
@@ -2420,6 +2445,11 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
  	if (hw->mac.ops.read_mac_addr(hw))
  		dev_err(&pdev->dev, "NVM Read Error\n");
  
+#ifdef CONFIG_OF
+	if (!is_valid_ether_addr(hw->mac.addr))
+		igb_read_mac_addr_dts(&pdev->dev, hw->mac.addr);
+#endif
+
  	memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);
  
  	if (!is_valid_ether_addr(netdev->dev_addr)) {
