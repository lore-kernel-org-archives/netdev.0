From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: wired driver changes...
Date: Thu, 24 Jul 2008 15:06:52 +0200
Message-ID: <87myk7ph1v.fsf@macbook.be.48ers.dk>
References: <20080721.120743.171293753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.176]:61596 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755196AbYGXNG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 09:06:56 -0400
Received: by ik-out-1112.google.com with SMTP id c28so2150156ika.5
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 06:06:55 -0700 (PDT)
In-Reply-To: <20080721.120743.171293753.davem@davemloft.net> (David Miller's message of "Mon\, 21 Jul 2008 12\:07\:43 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "David" == David Miller <davem@davemloft.net> writes:

Hi,

 David> As many of you have noticed, I declared a freeze for
 David> networking bits at this point.

 David> I'm making a single exception for Jeff for driver bits because
 David> I know he has a ton of crap queued up and he was just waiting
 David> for my tree to settle down last week.

The DMA fix for dm9601 still isn't in. It's acked by the USB guys -
Anything holding it back or did it simply slip through the cracks?

>From f4321264930ba2638b5b414c3b37ee9ba181a17d Mon Sep 17 00:00:00 2001
From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Fri, 27 Jun 2008 11:12:17 +0200
Subject: [PATCH] dm9601: don't do usb transfers of data on stack

dm_{read,write}() were doing USB transfers of data on stack, which isn't
allowed. Fix it by kmalloc'ing a temporary buffer.
Clean up the error handling for short transfers while we're at it.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
Acked-by: David Brownell <dbrownell@users.sourceforge.net>
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
