From: John Holland <jotihojr@gmail.com>
Subject: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using
 a device tree blob V2
Date: Sat, 13 Feb 2016 23:04:45 +0100
Message-ID: <56BFA87D.1010609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38595 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbcBMWEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 17:04:48 -0500
Received: by mail-wm0-f53.google.com with SMTP id a4so10531149wme.1
        for <netdev@vger.kernel.org>; Sat, 13 Feb 2016 14:04:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The Intel i211 LOM pcie ethernet controllers' iNVM operates as an OTP 
and has no externel EEPROM interface [1]. The following allows the 
driver to pickup the MAC address from a device tree blob when CONFIG_OF 
has been enabled.

[1] 
http://www.intel.com/content/www/us/en/embedded/products/networking/i211-ethernet-controller-datasheet.html

Changes V2
- Restrict searching for compatible devices to current pci device.

Signed-off-by: John Holland <jotihojr@gmail.com>
---

  drivers/net/ethernet/intel/igb/igb_main.c | 30 
++++++++++++++++++++++++++++++
  1 file changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c 
b/drivers/net/ethernet/intel/igb/igb_main.c
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
+       const u8 *mac;
+       struct device_node *dn;
+
+       dn = of_find_compatible_node(dev->of_node, NULL, "intel,i210");
+       if (dn) {
+               mac = of_get_mac_address(dn);
+               if (mac)
+                       ether_addr_copy(mac_addr, mac);
+       }
+}
+#endif
+
  /**
   *  igb_probe - Device Initialization Routine
   *  @pdev: PCI device information struct
@@ -2420,6 +2445,11 @@ static int igb_probe(struct pci_dev *pdev, const 
struct pci_device_id *ent)
         if (hw->mac.ops.read_mac_addr(hw))
                 dev_err(&pdev->dev, "NVM Read Error\n");

+#ifdef CONFIG_OF
+       if (!is_valid_ether_addr(hw->mac.addr))
+               igb_read_mac_addr_dts(&pdev->dev, hw->mac.addr);
+#endif
+
         memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);

         if (!is_valid_ether_addr(netdev->dev_addr)) {
