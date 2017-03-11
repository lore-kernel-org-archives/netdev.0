From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] usbnet: smsc95xx: Reduce logging noise
Date: Fri, 10 Mar 2017 17:45:21 -0800
Message-ID: <1489196721-12888-1-git-send-email-linux@roeck-us.net>
Cc: UNGLinuxDriver@microchip.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
        Guenter Roeck <linux@roeck-us.net>
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An insert/remove stress test generated the following log message sequence.

usb 7-1.1: New USB device found, idVendor=0424, idProduct=ec00
usb 7-1.1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
smsc95xx 7-1.1:1.0 (unnamed net_device) (uninitialized):
				Failed to read reg index 0x00000114: -22
smsc95xx 7-1.1:1.0 (unnamed net_device) (uninitialized):
				Error reading MII_ACCESS
smsc95xx 7-1.1:1.0 (unnamed net_device) (uninitialized):
				MII is busy in smsc95xx_mdio_read

... repeat 100+ times ...

smsc95xx 7-1.1:1.0 (unnamed net_device) (uninitialized):
				MII is busy in smsc95xx_mdio_read
smsc95xx 7-1.1:1.0 (unnamed net_device) (uninitialized):
				timeout on PHY Reset
smsc95xx 7-1.1:1.0 (unnamed net_device) (uninitialized):
				Failed to init PHY
smsc95xx 7-1.1:1.0 (unnamed net_device) (uninitialized):
				Failed to read reg index 0x00000000: -22
smsc95xx: probe of 7-1.1:1.0 failed with error -22
usb usb7: USB disconnect, device number 1
usb 7-1: USB disconnect, device number 2
usb 7-1.1: USB disconnect, device number 3

Use netdev_dbg() instead of netdev_warn() for the repeating messages
to reduce logging noise.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/usb/smsc95xx.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 831aa33d078a..f69e9e031973 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -100,8 +100,8 @@ static int __must_check __smsc95xx_read_reg(struct usbnet *dev, u32 index,
 		 | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		 0, index, &buf, 4);
 	if (unlikely(ret < 0)) {
-		netdev_warn(dev->net, "Failed to read reg index 0x%08x: %d\n",
-			    index, ret);
+		netdev_dbg(dev->net, "Failed to read reg index 0x%08x: %d\n",
+			   index, ret);
 		return ret;
 	}
 
@@ -174,7 +174,7 @@ static int __must_check __smsc95xx_phy_wait_not_busy(struct usbnet *dev,
 	do {
 		ret = __smsc95xx_read_reg(dev, MII_ADDR, &val, in_pm);
 		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading MII_ACCESS\n");
+			netdev_dbg(dev->net, "Error reading MII_ACCESS\n");
 			return ret;
 		}
 
@@ -197,7 +197,7 @@ static int __smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx,
 	/* confirm MII not busy */
 	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
 	if (ret < 0) {
-		netdev_warn(dev->net, "MII is busy in smsc95xx_mdio_read\n");
+		netdev_dbg(dev->net, "MII is busy in smsc95xx_mdio_read\n");
 		goto done;
 	}
 
-- 
2.7.4
