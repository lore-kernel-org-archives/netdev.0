From: "Christian Eggers" <ceggers@gmx.de>
Subject: [PATCH] usb/mcs7830: Don't use buffers from stack for USB transfers
Date: Tue, 20 Jan 2009 21:29:21 +0100 (CET)
Message-ID: <34115.192.168.0.40.1232483361.squirrel@server>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout3.freenet.de ([195.4.92.93]:44937 "EHLO mout3.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756090AbZATU31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 15:29:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Eggers <christian.eggers@kathrein.de>

mcs7830_set_reg() and mcs7830_get_reg() are called with buffers
from stack which must not be used directly for USB transfers.
This causes corruption of the stack particulary on non x86
architectures because DMA may be used for these transfers.

Signed-off-by: Christian Eggers <christian.eggers@kathrein.de>
---

This is my first patch submission for Linux. I hope everything is fine.

diff -uprN linux-2.6.28.1.orig/drivers/net/usb/mcs7830.c linux-2.6.28.1/drivers/net/usb/mcs7830.c
--- linux-2.6.28.1.orig/drivers/net/usb/mcs7830.c       2009-01-18 19:45:37.000000000 +0100
+++ linux-2.6.28.1/drivers/net/usb/mcs7830.c    2009-01-20 20:53:59.000000000 +0100
@@ -94,10 +94,18 @@ static int mcs7830_get_reg(struct usbnet
 {
        struct usb_device *xdev = dev->udev;
        int ret;
+       void *buffer;
+
+       buffer = kmalloc(size, GFP_NOIO);
+       if (buffer == NULL)
+               return -ENOMEM;

        ret = usb_control_msg(xdev, usb_rcvctrlpipe(xdev, 0), MCS7830_RD_BREQ,
-                             MCS7830_RD_BMREQ, 0x0000, index, data,
+                             MCS7830_RD_BMREQ, 0x0000, index, buffer,
                              size, MCS7830_CTRL_TIMEOUT);
+       memcpy(data, buffer, size);
+       kfree(buffer);
+
        return ret;
 }

@@ -105,10 +113,18 @@ static int mcs7830_set_reg(struct usbnet
 {
        struct usb_device *xdev = dev->udev;
        int ret;
+       void *buffer;
+
+       buffer = kmalloc(size, GFP_NOIO);
+       if (buffer == NULL)
+               return -ENOMEM;
+
+       memcpy(buffer, data, size);

        ret = usb_control_msg(xdev, usb_sndctrlpipe(xdev, 0), MCS7830_WR_BREQ,
-                             MCS7830_WR_BMREQ, 0x0000, index, data,
+                             MCS7830_WR_BMREQ, 0x0000, index, buffer,
                              size, MCS7830_CTRL_TIMEOUT);
+       kfree(buffer);
        return ret;
 }


