From: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Subject: [PATCH RESEND] dm9601: don't do usb transfers of data on stack
Date: Mon, 14 Jul 2008 09:07:32 +0200
Message-ID: <87wsjp9c5n.fsf@macbook.be.48ers.dk>
References: <87mykoircs.fsf@macbook.be.48ers.dk>
	<200807111422.56406.oliver@neukum.org>
	<87mykoefy4.fsf@macbook.be.48ers.dk>
	<200807111502.20507.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200807111502.20507.david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org> (David Brownell's message of "Fri\, 11 Jul 2008 15\:02\:20 -0700")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

dm_{read,write}() were doing USB transfers of data on stack, which isn't
allowed. Fix it by kmalloc'ing a temporary buffer.
Clean up the error handling for short transfers while we're at it.

Signed-off-by: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
---

Jeff, please enqueue for 2.6.27.

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
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
