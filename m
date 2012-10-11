From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v1 06/11] usbnet: mcs7830: apply introduced usb command APIs
Date: Thu, 11 Oct 2012 20:39:24 +0800
Message-ID: <1349959169-9432-7-git-send-email-ming.lei@canonical.com>
References: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1349959169-9432-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/mcs7830.c |   85 ++++-----------------------------------------
 1 file changed, 6 insertions(+), 79 deletions(-)

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 03c2d8d..db46a68 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -123,93 +123,20 @@ static const char driver_name[] = "MOSCHIP usb-ethernet driver";
 
 static int mcs7830_get_reg(struct usbnet *dev, u16 index, u16 size, void *data)
 {
-	struct usb_device *xdev = dev->udev;
-	int ret;
-	void *buffer;
-
-	buffer = kmalloc(size, GFP_NOIO);
-	if (buffer == NULL)
-		return -ENOMEM;
-
-	ret = usb_control_msg(xdev, usb_rcvctrlpipe(xdev, 0), MCS7830_RD_BREQ,
-			      MCS7830_RD_BMREQ, 0x0000, index, buffer,
-			      size, MCS7830_CTRL_TIMEOUT);
-	memcpy(data, buffer, size);
-	kfree(buffer);
-
-	return ret;
+	return usbnet_read_cmd(dev, MCS7830_RD_BREQ, MCS7830_RD_BMREQ,
+				0x0000, index, data, size);
 }
 
 static int mcs7830_set_reg(struct usbnet *dev, u16 index, u16 size, const void *data)
 {
-	struct usb_device *xdev = dev->udev;
-	int ret;
-	void *buffer;
-
-	buffer = kmemdup(data, size, GFP_NOIO);
-	if (buffer == NULL)
-		return -ENOMEM;
-
-	ret = usb_control_msg(xdev, usb_sndctrlpipe(xdev, 0), MCS7830_WR_BREQ,
-			      MCS7830_WR_BMREQ, 0x0000, index, buffer,
-			      size, MCS7830_CTRL_TIMEOUT);
-	kfree(buffer);
-	return ret;
-}
-
-static void mcs7830_async_cmd_callback(struct urb *urb)
-{
-	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
-	int status = urb->status;
-
-	if (status < 0)
-		printk(KERN_DEBUG "%s() failed with %d\n",
-		       __func__, status);
-
-	kfree(req);
-	usb_free_urb(urb);
+	return usbnet_write_cmd(dev, MCS7830_WR_BREQ, MCS7830_WR_BMREQ,
+				0x0000, index, data, size);
 }
 
 static void mcs7830_set_reg_async(struct usbnet *dev, u16 index, u16 size, void *data)
 {
-	struct usb_ctrlrequest *req;
-	int ret;
-	struct urb *urb;
-
-	urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!urb) {
-		dev_dbg(&dev->udev->dev,
-			"Error allocating URB in write_cmd_async!\n");
-		return;
-	}
-
-	req = kmalloc(sizeof *req, GFP_ATOMIC);
-	if (!req) {
-		dev_err(&dev->udev->dev,
-			"Failed to allocate memory for control request\n");
-		goto out;
-	}
-	req->bRequestType = MCS7830_WR_BMREQ;
-	req->bRequest = MCS7830_WR_BREQ;
-	req->wValue = 0;
-	req->wIndex = cpu_to_le16(index);
-	req->wLength = cpu_to_le16(size);
-
-	usb_fill_control_urb(urb, dev->udev,
-			     usb_sndctrlpipe(dev->udev, 0),
-			     (void *)req, data, size,
-			     mcs7830_async_cmd_callback, req);
