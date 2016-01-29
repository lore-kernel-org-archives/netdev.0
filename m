From: John Holland <jotihojr@gmail.com>
Subject: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using
 a device tree blob
Date: Fri, 29 Jan 2016 23:11:52 +0100
Message-ID: <56ABE3A8.4010602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	jotihojr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37675 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbcA2WLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 17:11:55 -0500
Received: by mail-wm0-f48.google.com with SMTP id l66so72455771wml.0
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 14:11:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Intel i211 LOM pcie ethernet controllers' iNVM operates as an OTP 
and has no externel EEPROM interface [1]. The following allows the 
driver to pickup the MAC address from a device tree blob when CONFIG_OF 
has been enabled.

[1] 
http://www.intel.com/content/www/us/en/embedded/products/networking/i211-ethernet-controller-datasheet.html

Signed-off-by: John Holland <jotihojr@gmail.com>
---
  drivers/net/ethernet/intel/igb/igb_main.c | 30 
++++++++++++++++++++++++++++++
  1 file changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c 
b/drivers/net/ethernet/intel/igb/igb_main.c
index 31e5f39..9c92443 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -56,6 +56,11 @@
  #include <linux/i2c.h>
  #include "igb.h"

+#ifdef defined(CONFIG_OF)
+#include <linux/of_net.h>
+#include <linux/etherdevice.h>
+#endif
+
  #define MAJ 5
  #define MIN 3
  #define BUILD 0
@@ -2217,6 +2222,26 @@ static s32 igb_init_i2c(struct igb_adapter *adapter)
  }

  /**
+ *  igb_read_mac_addr_dts - Read mac addres from the device tree blob.
+ *  @hw: pointer to the e1000 hardware structure
+ **/
+#ifdef defined(CONFIG_OF)
+static void igb_read_mac_addr_dts(struct e1000_hw *hw)
+{
+       const u8 *mac;
+       struct device_node *dn;
+
+       dn = of_find_compatible_node(NULL, NULL, "intel,i211");
+       if (!dn)
+               return;
+
+       mac = of_get_mac_address(dn);
+       if (mac)
+               ether_addr_copy(hw->mac.addr, mac);
+}
+#endif
+
+/**
   *  igb_probe - Device Initialization Routine
   *  @pdev: PCI device information struct
   *  @ent: entry in igb_pci_tbl
@@ -2420,6 +2445,11 @@ static int igb_probe(struct pci_dev *pdev, const 
struct pci_device_id *ent)
         if (hw->mac.ops.read_mac_addr(hw))
                 dev_err(&pdev->dev, "NVM Read Error\n");

+#ifdef defined(CONFIG_OF)
+       if (!is_valid_ether_addr(hw->mac.addr))
+               igb_read_mac_addr_dts(hw);
+#endif
+
         memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);

         if (!is_valid_ether_addr(netdev->dev_addr)) {
