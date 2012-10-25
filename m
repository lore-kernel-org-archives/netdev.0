From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v2 04/11] usbnet: dm9601: apply introduced usb command APIs
Date: Thu, 25 Oct 2012 13:46:57 +0800
Message-ID: <1351144024-16596-5-git-send-email-ming.lei@canonical.com>
References: <1351144024-16596-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:36615 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112Ab2JYFsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 01:48:22 -0400
In-Reply-To: <1351144024-16596-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Oliver Neukum <oneukum@suse.de>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/dm9601.c |  107 +++++++---------------------------------------
 1 file changed, 15 insertions(+), 92 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index e0433ce..3f554c1 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -56,27 +56,12 @@
 
 static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
-	void *buf;
-	int err = -ENOMEM;
-
-	netdev_dbg(dev->net, "dm_read() reg=0x%02x length=%d\n", reg, length);
-
-	buf = kmalloc(length, GFP_KERNEL);
-	if (!buf)
-		goto out;
-
-	err = usb_control_msg(dev->udev,
-			      usb_rcvctrlpipe(dev->udev, 0),
-			      DM_READ_REGS,
-			      USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-			      0, reg, buf, length, USB_CTRL_SET_TIMEOUT);
-	if (err == length)
-		memcpy(data, buf, length);
-	else if (err >= 0)
+	int err;
+	err = usbnet_read_cmd(dev, DM_READ_REGS,
+			       USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			       0, reg, data, length);
+	if(err != length && err >= 0)
 		err = -EINVAL;
-	kfree(buf);
-
- out:
 	return err;
 }
 
@@ -87,91 +72,29 @@ static int dm_read_reg(struct usbnet *dev, u8 reg, u8 *value)
 
 static int dm_write(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
-	void *buf = NULL;
-	int err = -ENOMEM;
-
-	netdev_dbg(dev->net, "dm_write() reg=0x%02x, length=%d\n", reg, length);
+	int err;
+	err = usbnet_write_cmd(dev, DM_WRITE_REGS,
+				USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+				0, reg, data, length);
 
-	if (data) {
-		buf = kmemdup(data, length, GFP_KERNEL);
-		if (!buf)
-			goto out;
-	}
-
-	err = usb_control_msg(dev->udev,
-			      usb_sndctrlpipe(dev->udev, 0),
-			      DM_WRITE_REGS,
-			      USB_DIR_OUT | USB_TYPE_VENDOR |USB_RECIP_DEVICE,
-			      0, reg, buf, length, USB_CTRL_SET_TIMEOUT);
-	kfree(buf);
 	if (err >= 0 && err < length)
 		err = -EINVAL;
- out:
 	return err;
 }
 
 static int dm_write_reg(struct usbnet *dev, u8 reg, u8 value)
 {
-	netdev_dbg(dev->net, "dm_write_reg() reg=0x%02x, value=0x%02x\n",
-		   reg, value);
-	return usb_control_msg(dev->udev,
-			       usb_sndctrlpipe(dev->udev, 0),
-			       DM_WRITE_REG,
-			       USB_DIR_OUT | USB_TYPE_VENDOR |USB_RECIP_DEVICE,
-			       value, reg, NULL, 0, USB_CTRL_SET_TIMEOUT);
-}
-
-static void dm_write_async_callback(struct urb *urb)
-{
-	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
-	int status = urb->status;
-
-	if (status < 0)
-		printk(KERN_DEBUG "dm_write_async_callback() failed with %d\n",
-		       status);
-
-	kfree(req);
-	usb_free_urb(urb);
+	return usbnet_write_cmd(dev, DM_WRITE_REGS,
+				USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+				value, reg, NULL, 0);
 }
 
 static void dm_write_async_helper(struct usbnet *dev, u8 reg, u8 value,
 				  u16 length, void *data)
 {
-	struct usb_ctrlrequest *req;
-	struct urb *urb;
-	int status;
-
-	urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!urb) {
-		netdev_err(dev->net, "Error allocating URB in dm_write_async_helper!\n");
-		return;
-	}
-
-	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
-	if (!req) {
-		netdev_err(dev->net, "Failed to allocate memory for control request\n");
-		usb_free_urb(urb);
-		return;
-	}
-
-	req->bRequestType = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
-	req->bRequest = length ? DM_WRITE_REGS : DM_WRITE_REG;
-	req->wValue = cpu_to_le16(value);
-	req->wIndex = cpu_to_le16(reg);
-	req->wLength = cpu_to_le16(length);
-
-	usb_fill_control_urb(urb, dev->udev,
-			     usb_sndctrlpipe(dev->udev, 0),
-			     (void *)req, data, length,
-			     dm_write_async_callback, req);
-
-	status = usb_submit_urb(urb, GFP_ATOMIC);
-	if (status < 0) {
-		netdev_err(dev->net, "Error submitting the control message: status=%d\n",
-			   status);
-		kfree(req);
-		usb_free_urb(urb);
-	}
+	usbnet_write_cmd_async(dev, DM_WRITE_REGS,
+			       USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			       value, reg, data, length);
 }
 
 static void dm_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
-- 
1.7.9.5
