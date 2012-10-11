From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 02/11] usbnet: asix: apply introduced usb command APIs
Date: Thu, 11 Oct 2012 20:39:20 +0800
Message-ID: <1349959169-9432-3-git-send-email-ming.lei@canonical.com>
References: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:44313 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755925Ab2JKMkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 08:40:07 -0400
In-Reply-To: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/asix_common.c |  117 +++++------------------------------------
 1 file changed, 13 insertions(+), 104 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 774d9ce..50d1673 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -25,121 +25,30 @@
 int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 		  u16 size, void *data)
 {
-	void *buf;
-	int err = -ENOMEM;
-
-	netdev_dbg(dev->net, "asix_read_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
-		   cmd, value, index, size);
-
-	buf = kmalloc(size, GFP_KERNEL);
-	if (!buf)
-		goto out;
-
-	err = usb_control_msg(
-		dev->udev,
-		usb_rcvctrlpipe(dev->udev, 0),
-		cmd,
-		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		value,
-		index,
-		buf,
-		size,
-		USB_CTRL_GET_TIMEOUT);
-	if (err == size)
-		memcpy(data, buf, size);
-	else if (err >= 0)
-		err = -EINVAL;
-	kfree(buf);
+	int ret;
+	ret = usbnet_read_cmd(dev, cmd,
+			       USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			       value, index, data, size);
 
-out:
-	return err;
+	if (ret != size && ret >= 0)
+		return -EINVAL;
+	return ret;
 }
 
 int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 		   u16 size, void *data)
 {
-	void *buf = NULL;
-	int err = -ENOMEM;
-
-	netdev_dbg(dev->net, "asix_write_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
-		   cmd, value, index, size);
-
-	if (data) {
-		buf = kmemdup(data, size, GFP_KERNEL);
-		if (!buf)
-			goto out;
-	}
-
-	err = usb_control_msg(
-		dev->udev,
-		usb_sndctrlpipe(dev->udev, 0),
-		cmd,
-		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		value,
-		index,
-		buf,
-		size,
-		USB_CTRL_SET_TIMEOUT);
-	kfree(buf);
-
-out:
-	return err;
-}
-
-static void asix_async_cmd_callback(struct urb *urb)
-{
-	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
-	int status = urb->status;
-
-	if (status < 0)
-		printk(KERN_DEBUG "asix_async_cmd_callback() failed with %d",
-			status);
-
-	kfree(req);
-	usb_free_urb(urb);
+	return usbnet_write_cmd(dev, cmd,
+				USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+				value, index, data, size);
 }
 
 void asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			  u16 size, void *data)
 {
-	struct usb_ctrlrequest *req;
-	int status;
-	struct urb *urb;
-
-	netdev_dbg(dev->net, "asix_write_cmd_async() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
-		   cmd, value, index, size);
-
-	urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!urb) {
-		netdev_err(dev->net, "Error allocating URB in write_cmd_async!\n");
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
-	req->bRequest = cmd;
-	req->wValue = cpu_to_le16(value);
-	req->wIndex = cpu_to_le16(index);
-	req->wLength = cpu_to_le16(size);
-
-	usb_fill_control_urb(urb, dev->udev,
-			     usb_sndctrlpipe(dev->udev, 0),
-			     (void *)req, data, size,
-			     asix_async_cmd_callback, req);
-
-	status = usb_submit_urb(urb, GFP_ATOMIC);
-	if (status < 0) {
-		netdev_err(dev->net, "Error submitting the control message: status=%d\n",
-			   status);
-		kfree(req);
-		usb_free_urb(urb);
-	}
+	usbnet_write_cmd_async(dev, cmd,
+			       USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			       value, index, data, size);
 }
 
 int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
-- 
1.7.9.5
