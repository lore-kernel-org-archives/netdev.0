From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 10/11] usbnet: smsc75xx: apply introduced usb command APIs
Date: Thu, 11 Oct 2012 20:39:28 +0800
Message-ID: <1349959169-9432-11-git-send-email-ming.lei@canonical.com>
References: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:54337 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743Ab2JKMmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 08:42:16 -0400
In-Reply-To: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/smsc75xx.c |   39 ++++++++++++++-------------------------
 1 file changed, 14 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index b77ae76..1baa53a 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -85,26 +85,21 @@ MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
 static int __must_check smsc75xx_read_reg(struct usbnet *dev, u32 index,
 					  u32 *data)
 {
-	u32 *buf = kmalloc(4, GFP_KERNEL);
+	u32 buf;
 	int ret;
 
 	BUG_ON(!dev);
 
-	if (!buf)
-		return -ENOMEM;
-
-	ret = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
-		USB_VENDOR_REQUEST_READ_REGISTER,
-		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		00, index, buf, 4, USB_CTRL_GET_TIMEOUT);
-
+	ret = usbnet_read_cmd(dev, USB_VENDOR_REQUEST_READ_REGISTER,
+			      USB_DIR_IN | USB_TYPE_VENDOR |
+			      USB_RECIP_DEVICE,
+			      0, index, &buf, 4);
 	if (unlikely(ret < 0))
 		netdev_warn(dev->net,
 			"Failed to read reg index 0x%08x: %d", index, ret);
 
-	le32_to_cpus(buf);
-	*data = *buf;
-	kfree(buf);
+	le32_to_cpus(&buf);
+	*data = buf;
 
 	return ret;
 }
@@ -112,28 +107,22 @@ static int __must_check smsc75xx_read_reg(struct usbnet *dev, u32 index,
 static int __must_check smsc75xx_write_reg(struct usbnet *dev, u32 index,
 					   u32 data)
 {
-	u32 *buf = kmalloc(4, GFP_KERNEL);
+	u32 buf;
 	int ret;
 
 	BUG_ON(!dev);
 
-	if (!buf)
-		return -ENOMEM;
-
-	*buf = data;
-	cpu_to_le32s(buf);
-
-	ret = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
-		USB_VENDOR_REQUEST_WRITE_REGISTER,
-		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		00, index, buf, 4, USB_CTRL_SET_TIMEOUT);
+	buf = data;
+	cpu_to_le32s(&buf);
 
+	ret = usbnet_write_cmd(dev, USB_VENDOR_REQUEST_WRITE_REGISTER,
+			       USB_DIR_OUT | USB_TYPE_VENDOR |
+			       USB_RECIP_DEVICE,
+			       0, index, &buf, 4);
 	if (unlikely(ret < 0))
 		netdev_warn(dev->net,
 			"Failed to write reg index 0x%08x: %d", index, ret);
 
-	kfree(buf);
-
 	return ret;
 }
 
-- 
1.7.9.5
