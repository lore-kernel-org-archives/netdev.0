From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] cx82310_eth: wait for firmware to become ready
Date: Sat, 21 Mar 2015 11:29:37 +0100
Message-ID: <1426933777-19260-1-git-send-email-linux@rainbow-software.org>
Cc: Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the device is powered up, some (older) firmware versions fail to work
properly if we send commands before the boot is complete (everything is OK
when the device is hot-plugged). The firmware indicates its ready status by
putting the link up.
Newer firmwares delay the first command so they don't suffer from this problem.
They also report the link being always up.

Wait for firmware to become ready (link up) before sending any commands and/or
data.

This also allows lowering CMD_TIMEOUT value to a reasonable time.

Tested with 4.1.0.9 (old) and 4.1.0.30 (new) firmware versions.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/usb/cx82310_eth.c |   30 ++++++++++++++++++++++++------
 1 file changed, 24 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cx82310_eth.c b/drivers/net/usb/cx82310_eth.c
index fe48f4c..1762ad3 100644
--- a/drivers/net/usb/cx82310_eth.c
+++ b/drivers/net/usb/cx82310_eth.c
@@ -46,8 +46,7 @@ enum cx82310_status {
 };
 
 #define CMD_PACKET_SIZE	64
-/* first command after power on can take around 8 seconds */
-#define CMD_TIMEOUT	15000
+#define CMD_TIMEOUT	100
 #define CMD_REPLY_RETRY 5
 
 #define CX82310_MTU	1514
@@ -78,8 +77,9 @@ static int cx82310_cmd(struct usbnet *dev, enum cx82310_cmd cmd, bool reply,
 	ret = usb_bulk_msg(udev, usb_sndbulkpipe(udev, CMD_EP), buf,
 			   CMD_PACKET_SIZE, &actual_len, CMD_TIMEOUT);
 	if (ret < 0) {
-		dev_err(&dev->udev->dev, "send command %#x: error %d\n",
-			cmd, ret);
+		if (cmd != CMD_GET_LINK_STATUS)
+			dev_err(&dev->udev->dev, "send command %#x: error %d\n",
+				cmd, ret);
 		goto end;
 	}
 
@@ -90,8 +90,10 @@ static int cx82310_cmd(struct usbnet *dev, enum cx82310_cmd cmd, bool reply,
 					   buf, CMD_PACKET_SIZE, &actual_len,
 					   CMD_TIMEOUT);
 			if (ret < 0) {
-				dev_err(&dev->udev->dev,
-					"reply receive error %d\n", ret);
+				if (cmd != CMD_GET_LINK_STATUS)
+					dev_err(&dev->udev->dev,
+						"reply receive error %d\n",
+						ret);
 				goto end;
 			}
 			if (actual_len > 0)
@@ -134,6 +136,8 @@ static int cx82310_bind(struct usbnet *dev, struct usb_interface *intf)
 	int ret;
 	char buf[15];
 	struct usb_device *udev = dev->udev;
+	u8 link[3];
+	int timeout = 50;
 
 	/* avoid ADSL modems - continue only if iProduct is "USB NET CARD" */
 	if (usb_string(udev, udev->descriptor.iProduct, buf, sizeof(buf)) > 0
@@ -160,6 +164,20 @@ static int cx82310_bind(struct usbnet *dev, struct usb_interface *intf)
 	if (!dev->partial_data)
 		return -ENOMEM;
 
+	/* wait for firmware to become ready (indicated by the link being up) */
+	while (--timeout) {
+		ret = cx82310_cmd(dev, CMD_GET_LINK_STATUS, true, NULL, 0,
+				  link, sizeof(link));
+		/* the command can time out during boot - it's not an error */
+		if (!ret && link[0] == 1 && link[2] == 1)
+			break;
+		msleep(500);
+	};
+	if (!timeout) {
+		dev_err(&udev->dev, "firmware not ready in time\n");
+		return -ETIMEDOUT;
+	}
+
 	/* enable ethernet mode (?) */
 	ret = cx82310_cmd(dev, CMD_ETHERNET_MODE, true, "\x01", 1, NULL, 0);
 	if (ret) {
-- 
Ondrej Zary
