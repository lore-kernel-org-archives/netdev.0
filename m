From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 11/12] usbnet: smsc95xx: apply introduced usb command APIs
Date: Tue,  2 Oct 2012 14:51:22 +0800
Message-ID: <1349160684-6627-12-git-send-email-ming.lei@canonical.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1349160684-6627-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/smsc95xx.c |  115 +++++++++++---------------------------------
 1 file changed, 27 insertions(+), 88 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 7479a57..1730f75 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -65,11 +65,6 @@ struct smsc95xx_priv {
 	spinlock_t mac_cr_lock;
 };
 
-struct usb_context {
-	struct usb_ctrlrequest req;
-	struct usbnet *dev;
-};
-
 static bool turbo_mode = true;
 module_param(turbo_mode, bool, 0644);
 MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
@@ -77,25 +72,20 @@ MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
 static int __must_check smsc95xx_read_reg(struct usbnet *dev, u32 index,
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
 		netdev_warn(dev->net, "Failed to read register index 0x%08x\n", index);
 
-	le32_to_cpus(buf);
-	*data = *buf;
-	kfree(buf);
+	le32_to_cpus(&buf);
+	*data = buf;
 
 	return ret;
 }
@@ -103,27 +93,22 @@ static int __must_check smsc95xx_read_reg(struct usbnet *dev, u32 index,
 static int __must_check smsc95xx_write_reg(struct usbnet *dev, u32 index,
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
+	buf = data;
+	cpu_to_le32s(&buf);
 
-	ret = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
-		USB_VENDOR_REQUEST_WRITE_REGISTER,
-		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		00, index, buf, 4, USB_CTRL_SET_TIMEOUT);
 
+	ret = usbnet_write_cmd(dev, USB_VENDOR_REQUEST_WRITE_REGISTER,
+			       USB_DIR_OUT | USB_TYPE_VENDOR |
+			       USB_RECIP_DEVICE,
+			       0, index, &buf, 4);
 	if (unlikely(ret < 0))
 		netdev_warn(dev->net, "Failed to write register index 0x%08x\n", index);
 
-	kfree(buf);
-
 	return ret;
 }
 
@@ -132,11 +117,8 @@ static int smsc95xx_set_feature(struct usbnet *dev, u32 feature)
 	if (WARN_ON_ONCE(!dev))
 		return -EINVAL;
 
-	cpu_to_le32s(&feature);
-
-	return usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
-		USB_REQ_SET_FEATURE, USB_RECIP_DEVICE, feature, 0, NULL, 0,
-		USB_CTRL_SET_TIMEOUT);
+	return usbnet_write_cmd(dev, USB_REQ_SET_FEATURE,
+				USB_RECIP_DEVICE, feature, 0, NULL, 0);
 }
 
 static int smsc95xx_clear_feature(struct usbnet *dev, u32 feature)
@@ -144,11 +126,8 @@ static int smsc95xx_clear_feature(struct usbnet *dev, u32 feature)
 	if (WARN_ON_ONCE(!dev))
 		return -EINVAL;
 
-	cpu_to_le32s(&feature);
-
-	return usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
-		USB_REQ_CLEAR_FEATURE, USB_RECIP_DEVICE, feature, 0, NULL, 0,
-		USB_CTRL_SET_TIMEOUT);
+	return usbnet_write_cmd(dev, USB_REQ_CLEAR_FEATURE,
+				USB_RECIP_DEVICE, feature, 0, NULL, 0);
 }
 
 /* Loop until the read is completed with timeout
@@ -350,60 +329,20 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	return 0;
 }
 
-static void smsc95xx_async_cmd_callback(struct urb *urb)
-{
-	struct usb_context *usb_context = urb->context;
-	struct usbnet *dev = usb_context->dev;
-	int status = urb->status;
-
-	check_warn(status, "async callback failed with %d\n", status);
-
-	kfree(usb_context);
-	usb_free_urb(urb);
-}
-
 static int __must_check smsc95xx_write_reg_async(struct usbnet *dev, u16 index,
 						 u32 *data)
 {
-	struct usb_context *usb_context;
-	int status;
-	struct urb *urb;
 	const u16 size = 4;
+	int ret;
 
-	urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!urb) {
-		netdev_warn(dev->net, "Error allocating URB\n");
-		return -ENOMEM;
-	}
-
-	usb_context = kmalloc(sizeof(struct usb_context), GFP_ATOMIC);
-	if (usb_context == NULL) {
-		netdev_warn(dev->net, "Error allocating control msg\n");
-		usb_free_urb(urb);
-		return -ENOMEM;
-	}
-
-	usb_context->req.bRequestType =
-		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
-	usb_context->req.bRequest = USB_VENDOR_REQUEST_WRITE_REGISTER;
-	usb_context->req.wValue = 00;
-	usb_context->req.wIndex = cpu_to_le16(index);
-	usb_context->req.wLength = cpu_to_le16(size);
-
-	usb_fill_control_urb(urb, dev->udev, usb_sndctrlpipe(dev->udev, 0),
-		(void *)&usb_context->req, data, size,
-		smsc95xx_async_cmd_callback,
-		(void *)usb_context);
-
-	status = usb_submit_urb(urb, GFP_ATOMIC);
-	if (status < 0) {
-		netdev_warn(dev->net, "Error submitting control msg, sts=%d\n",
-			    status);
-		kfree(usb_context);
-		usb_free_urb(urb);
-	}
