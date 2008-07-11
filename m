From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH RESEND] dm9601: don't do usb transfers of data on stack
Date: Fri, 11 Jul 2008 14:57:39 +0200
Message-ID: <87mykoefy4.fsf@macbook.be.48ers.dk>
References: <87mykoircs.fsf@macbook.be.48ers.dk>
	<200807111400.38312.oliver@neukum.org>
	<87vdzcehs9.fsf@macbook.be.48ers.dk>
	<200807111422.56406.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:30049 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbYGKM5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 08:57:42 -0400
Received: by wr-out-0506.google.com with SMTP id 69so2808384wri.5
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2008 05:57:41 -0700 (PDT)
In-Reply-To: <200807111422.56406.oliver@neukum.org> (Oliver Neukum's message of "Fri\, 11 Jul 2008 14\:22\:55 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dm_{read,write}() were doing USB transfers of data on stack, which isn't
allowed. Fix it by kmalloc'ing a temporary buffer.
Clean up the error handling for short transfers while we're at it.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |   52 +++++++++++++++++++++++++++++++++++++--------
 1 files changed, 42 insertions(+), 10 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index f7319d3..78df2be 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -55,12 +55,28 @@
 
 static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
+	void *buf;
+	int err = -ENOMEM;
+
 	devdbg(dev, "dm_read() reg=0x%02x length=%d", reg, length);
-	return usb_control_msg(dev->udev,
-			       usb_rcvctrlpipe(dev->udev, 0),
-			       DM_READ_REGS,
-			       USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-			       0, reg, data, length, USB_CTRL_SET_TIMEOUT);
+
+	buf = kmalloc(length, GFP_KERNEL);
+	if (!buf)
+		goto out;
+
+	err = usb_control_msg(dev->udev,
+			      usb_rcvctrlpipe(dev->udev, 0),
+			      DM_READ_REGS,
+			      USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			      0, reg, buf, length, USB_CTRL_SET_TIMEOUT);
+	if (err == length)
+		memcpy(data, buf, length);
+	else if (err >= 0)
+		err = -EINVAL;
+	kfree(buf);
+
+ out:
+	return err;
 }
 
 static int dm_read_reg(struct usbnet *dev, u8 reg, u8 *value)
@@ -70,12 +86,28 @@ static int dm_read_reg(struct usbnet *dev, u8 reg, u8 *value)
 
 static int dm_write(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
+	void *buf = NULL;
+	int err = -ENOMEM;
+
 	devdbg(dev, "dm_write() reg=0x%02x, length=%d", reg, length);
-	return usb_control_msg(dev->udev,
-			       usb_sndctrlpipe(dev->udev, 0),
-			       DM_WRITE_REGS,
-			       USB_DIR_OUT | USB_TYPE_VENDOR |USB_RECIP_DEVICE,
-			       0, reg, data, length, USB_CTRL_SET_TIMEOUT);
+
+	if (data) {
+		buf = kmalloc(length, GFP_KERNEL);
+		if (!buf)
+			goto out;
+		memcpy(buf, data, length);
+	}
+
+	err = usb_control_msg(dev->udev,
+			      usb_sndctrlpipe(dev->udev, 0),
+			      DM_WRITE_REGS,
+			      USB_DIR_OUT | USB_TYPE_VENDOR |USB_RECIP_DEVICE,
+			      0, reg, buf, length, USB_CTRL_SET_TIMEOUT);
+	kfree(buf);
+	if (err >= 0 && err < length)
+		err = -EINVAL;
+ out:
+	return err;
 }
 
 static int dm_write_reg(struct usbnet *dev, u8 reg, u8 value)
-- 
1.5.6.2


-- 
Bye, Peter Korsgaard
