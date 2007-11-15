From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: Consolidate common parts of dm_write_*_async
Date: Thu, 15 Nov 2007 11:10:12 +0100
Message-ID: <E1Iu9pB-0002xc-6M@nanv.dk>
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.korsgaard.com ([64.79.194.204]:59339 "EHLO nanv.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506AbXKSRPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 12:15:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dm_write_async and dm_write_reg_async are almost identical.
Move common functionality to dm_write_async_helper (saves ~256b).

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |   53 +++++++++++----------------------------------
 1 files changed, 13 insertions(+), 40 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 1ffdd10..633a511 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -101,17 +101,16 @@ static void dm_write_async_callback(struct urb *urb)
 	usb_free_urb(urb);
 }
 
-static void dm_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
+static void dm_write_async_helper(struct usbnet *dev, u8 reg, u8 value,
+				  u16 length, void *data)
 {
 	struct usb_ctrlrequest *req;
 	struct urb *urb;
 	int status;
 
-	devdbg(dev, "dm_write_async() reg=0x%02x length=%d", reg, length);
-
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
-		deverr(dev, "Error allocating URB in dm_write_async!");
+		deverr(dev, "Error allocating URB in dm_write_async_helper!");
 		return;
 	}
 
@@ -123,8 +122,8 @@ static void dm_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
 	}
 
 	req->bRequestType = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
-	req->bRequest = DM_WRITE_REGS;
-	req->wValue = 0;
+	req->bRequest = length ? DM_WRITE_REGS : DM_WRITE_REG;
+	req->wValue = cpu_to_le16(value);
 	req->wIndex = cpu_to_le16(reg);
 	req->wLength = cpu_to_le16(length);
 
@@ -142,45 +141,19 @@ static void dm_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
 	}
 }
 
-static void dm_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
+static void dm_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
-	struct usb_ctrlrequest *req;
-	struct urb *urb;
-	int status;
+	devdbg(dev, "dm_write_async() reg=0x%02x length=%d", reg, length);
 
+	dm_write_async_helper(dev, reg, 0, length, data);
+}
+
+static void dm_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
+{
 	devdbg(dev, "dm_write_reg_async() reg=0x%02x value=0x%02x",
 	       reg, value);
 
-	urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!urb) {
-		deverr(dev, "Error allocating URB in dm_write_async!");
-		return;
-	}
-
-	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
-	if (!req) {
-		deverr(dev, "Failed to allocate memory for control request");
-		usb_free_urb(urb);
-		return;
-	}
-
-	req->bRequestType = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
-	req->bRequest = DM_WRITE_REG;
-	req->wValue = cpu_to_le16(value);
-	req->wIndex = cpu_to_le16(reg);
-	req->wLength = 0;
-
-	usb_fill_control_urb(urb, dev->udev,
-			     usb_sndctrlpipe(dev->udev, 0),
-			     (void *)req, NULL, 0, dm_write_async_callback, req);
-
-	status = usb_submit_urb(urb, GFP_ATOMIC);
-	if (status < 0) {
-		deverr(dev, "Error submitting the control message: status=%d",
-		       status);
-		kfree(req);
-		usb_free_urb(urb);
-	}
+	dm_write_async_helper(dev, reg, value, 0, NULL);
 }
 
 static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, u16 *value)
-- 
1.5.3.4

