From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH] net/smscx5xx: use the device tree for mac address
Date: Fri, 29 Apr 2016 09:05:59 +0200
Message-ID: <1461913559-15902-1-git-send-email-lkundrak@v3.sk>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Arnd Bergmann <arnd@arndb.de>, Lubomir Rintel <lkundrak@v3.sk>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shell.v3.sk ([92.60.52.57]:43530 "EHLO shell.v3.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522AbcD2HGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2016 03:06:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

This takes the MAC address for smsc75xx/smsc95xx USB network devices
from a the device tree. This is required to get a usable persistent
address on the popular beagleboard, whose hardware designers
accidentally forgot that an ethernet device really requires an a
MAC address to be functional.

The Raspberry Pi also ships smsc9514 without a serial EEPROM, stores
the MAC address in ROM accessible via VC4 firmware.

The smsc75xx and smsc95xx drivers are just two copies of the
same code, so better fix both.

[lkundrak@v3.sk: updated to use of_get_property() as per suggestion from
Arnd, reworded the message and comments a bit]

Tested-by: Lubomir Rintel <lkundrak@v3.sk>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
---
Changes since v2:
  - Prefer DT address to EEPROM address. No practical difference since
    the devices are not supposed to have both, but aligned with existing
    practice (ixgbe, dm9000).

Changes since v1:
  - Made use of_get_property()
  - Amended comments/commit message a bit

 drivers/net/usb/smsc75xx.c | 12 +++++++++++-
 drivers/net/usb/smsc95xx.c | 12 +++++++++++-
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 30033db..c369db9 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -29,6 +29,7 @@
 #include <linux/crc32.h>
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
+#include <linux/of_net.h>
 #include "smsc75xx.h"
 
 #define SMSC_CHIPNAME			"smsc75xx"
@@ -761,6 +762,15 @@ static int smsc75xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 
 static void smsc75xx_init_mac_address(struct usbnet *dev)
 {
+	const u8 *mac_addr;
+
+	/* maybe the boot loader passed the MAC address in devicetree */
+	mac_addr = of_get_mac_address(dev->udev->dev.of_node);
+	if (mac_addr) {
+		memcpy(dev->net->dev_addr, mac_addr, ETH_ALEN);
+		return;
+	}
+
 	/* try reading mac address from EEPROM */
 	if (smsc75xx_read_eeprom(dev, EEPROM_MAC_OFFSET, ETH_ALEN,
 			dev->net->dev_addr) == 0) {
@@ -772,7 +782,7 @@ static void smsc75xx_init_mac_address(struct usbnet *dev)
 		}
 	}
 
-	/* no eeprom, or eeprom values are invalid. generate random MAC */
+	/* no useful static MAC address found. generate a random one */
 	eth_hw_addr_random(dev->net);
 	netif_dbg(dev, ifup, dev->net, "MAC address set to eth_random_addr\n");
 }
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 66b3ab9..2edc2bc 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -29,6 +29,7 @@
 #include <linux/crc32.h>
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
+#include <linux/of_net.h>
 #include "smsc95xx.h"
 
 #define SMSC_CHIPNAME			"smsc95xx"
@@ -765,6 +766,15 @@ static int smsc95xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 
 static void smsc95xx_init_mac_address(struct usbnet *dev)
 {
+	const u8 *mac_addr;
+
+	/* maybe the boot loader passed the MAC address in devicetree */
+	mac_addr = of_get_mac_address(dev->udev->dev.of_node);
+	if (mac_addr) {
+		memcpy(dev->net->dev_addr, mac_addr, ETH_ALEN);
+		return;
+	}
+
 	/* try reading mac address from EEPROM */
 	if (smsc95xx_read_eeprom(dev, EEPROM_MAC_OFFSET, ETH_ALEN,
 			dev->net->dev_addr) == 0) {
@@ -775,7 +785,7 @@ static void smsc95xx_init_mac_address(struct usbnet *dev)
 		}
 	}
 
-	/* no eeprom, or eeprom values are invalid. generate random MAC */
+	/* no useful static MAC address found. generate a random one */
 	eth_hw_addr_random(dev->net);
 	netif_dbg(dev, ifup, dev->net, "MAC address set to eth_random_addr\n");
 }
-- 
2.7.4
