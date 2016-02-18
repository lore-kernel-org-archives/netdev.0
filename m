From: John Holland <jotihojr@gmail.com>
Subject: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using
 a device tree blob V5
Date: Thu, 18 Feb 2016 12:10:52 +0100
Message-ID: <56C5A6BC.6030708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36879 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425558AbcBRLKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 06:10:55 -0500
Received: by mail-wm0-f47.google.com with SMTP id g62so20061383wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 03:10:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The Intel i211 LOM PCIe Ethernet controllers' iNVM operates as an OTP
and has no external EEPROM interface [1]. The following allows the
driver to pickup the MAC address from a device tree blob when CONFIG_OF
has been enabled.

[1] 
http://www.intel.com/content/www/us/en/embedded/products/networking/i211-ethernet-controller-datasheet.html

Changes V2
- Restrict searching for compatible devices to current pci device.

Changes V3
- Add device tree binding documentation.

Changes V4
- Rebase patch.

Changes V5
- Use eth_platform_get_mac_address() to resolve MAC specified in a dtb.
- Remove now invalid device tree binding documentation specified in V3
   und V4.

Signed-off-by: John Holland<jotihojr@gmail.com>
---
  drivers/net/ethernet/intel/igb/igb_main.c | 9 ++++++---
  1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c 
b/drivers/net/ethernet/intel/igb/igb_main.c
index a98f418..d3e8228 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -50,6 +50,7 @@
  #include <linux/aer.h>
  #include <linux/prefetch.h>
  #include <linux/pm_runtime.h>
+#include <linux/etherdevice.h>
  #ifdef CONFIG_IGB_DCA
  #include <linux/dca.h>
  #endif
@@ -2507,9 +2508,11 @@ static int igb_probe(struct pci_dev *pdev, const 
struct pci_device_id *ent)
                 break;
         }

-       /* copy the MAC address out of the NVM */
-       if (hw->mac.ops.read_mac_addr(hw))
-               dev_err(&pdev->dev, "NVM Read Error\n");
+       if (eth_platform_get_mac_address(&pdev->dev, hw->mac.addr)) {
+               /* copy the MAC address out of the NVM */
+               if (hw->mac.ops.read_mac_addr(hw))
+                       dev_err(&pdev->dev, "NVM Read Error\n");
+       }

         memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);
