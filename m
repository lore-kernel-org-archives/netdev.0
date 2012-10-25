From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v2 10/11] usbnet: smsc75xx: apply introduced usb command APIs
Date: Thu, 25 Oct 2012 13:47:03 +0800
Message-ID: <1351144024-16596-11-git-send-email-ming.lei@canonical.com>
References: <1351144024-16596-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351144024-16596-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Acked-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
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
