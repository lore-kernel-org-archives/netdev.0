From: Dan Murphy <dmurphy@ti.com>
Subject: [PATCH] usbnet: smsc95xx: Add device tree input for MAC address
Date: Fri, 4 Oct 2013 13:25:56 -0500
Message-ID: <1380911156-14112-1-git-send-email-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<mugunthanvnm@ti.com>, Dan Murphy <dmurphy@ti.com>
To: <steve.glendinning@shawell.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the smsc95xx does not have a valid MAC address stored within
the eeprom then a random number is generated.  The MAC can also
be set by uBoot but the smsc95xx does not have a way to read this.

Create the binding for the smsc95xx so that uBoot can set the MAC
and the code can retrieve the MAC from the modified DTB file.

Signed-off-by: Dan Murphy <dmurphy@ti.com>
---
 Documentation/devicetree/bindings/net/smsc95xx.txt |   17 ++++++++++++++
 drivers/net/usb/smsc95xx.c                         |   24 ++++++++++++++++++++
 2 files changed, 41 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/smsc95xx.txt

diff --git a/Documentation/devicetree/bindings/net/smsc95xx.txt b/Documentation/devicetree/bindings/net/smsc95xx.txt
new file mode 100644
index 0000000..4c37280
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/smsc95xx.txt
@@ -0,0 +1,17 @@
+* Smart Mixed-Signal Connectivity (SMSC) 95xx Controller
+
+Required properties:
+None
+
+Optional properties:
+- mac-address - Read the mac address that was stored by uBoot
+- local-address - Read the mac address that was stored by uBoot
+- address - Read the mac address that was stored by uBoot
+
+Examples:
+
+smsc0: smsc95xx@0 {
+	/* Filled in by U-Boot */
+	mac-address = [ 00 00 00 00 00 00 ];
+};
+
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 3f38ba8..baee0bd 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -31,6 +31,9 @@
 #include <linux/crc32.h>
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+
 #include "smsc95xx.h"
 
 #define SMSC_CHIPNAME			"smsc95xx"
@@ -62,6 +65,8 @@
 #define SUSPEND_ALLMODES		(SUSPEND_SUSPEND0 | SUSPEND_SUSPEND1 | \
 					 SUSPEND_SUSPEND2 | SUSPEND_SUSPEND3)
 
+#define SMSC95XX_OF_NAME 	"/smsc95xx@"
+
 struct smsc95xx_priv {
 	u32 mac_cr;
 	u32 hash_hi;
@@ -767,6 +772,25 @@ static int smsc95xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 
 static void smsc95xx_init_mac_address(struct usbnet *dev)
 {
+
+#ifdef CONFIG_OF
+	struct device_node *ap;
+	const char *mac = NULL;
+	char *of_name = SMSC95XX_OF_NAME;
+
+	sprintf(of_name, "%s%i", SMSC95XX_OF_NAME, dev->udev->dev.id);
+	ap = of_find_node_by_path(of_name);
+	if (ap) {
+		mac = of_get_mac_address(ap);
+		if (is_valid_ether_addr(mac)) {
+			/* Device tree has a mac for this so use that */
+			memcpy(dev->net->dev_addr, mac, ETH_ALEN);
+			netif_dbg(dev, ifup, dev->net, "MAC address read from DTB\n");
+			return;
+		}
+	}
+#endif
+
 	/* try reading mac address from EEPROM */
 	if (smsc95xx_read_eeprom(dev, EEPROM_MAC_OFFSET, ETH_ALEN,
 			dev->net->dev_addr) == 0) {
-- 
1.7.9.5
