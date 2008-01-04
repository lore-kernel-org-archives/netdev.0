From: Chris Rankin <rankincj@yahoo.com>
Subject: [PATCH] (Revised) USB VID/PID clash between pegasus and hci_usb drivers
Date: Fri, 4 Jan 2008 11:07:40 +0000 (GMT)
Message-ID: <130968.6446.qm@web52904.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-1253408481-1199444860=:6446"
Content-Transfer-Encoding: 8bit
Cc: marcel@holtmann.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52904.mail.re2.yahoo.com ([206.190.49.14]:34025 "HELO
	web52904.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751015AbYADLHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:07:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0-1253408481-1199444860=:6446
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Content-Id: 
Content-Disposition: inline

Hi,

I have surprisingly managed to track down the USB device descriptor for the wired Belkin network
adapter, and it looks as if the device class is actually 0x00 instead of 0xFF. I originally used
0xFF because that is what my 3com device used (for some reason) and so I was hoping that Belkin
would also use 0xFF for the same reason.

But anyway, here is the new patch.

Cheers,
Chris



      __________________________________________________________
Sent from Yahoo! Mail - a smarter inbox http://uk.mail.yahoo.com

--0-1253408481-1199444860=:6446
Content-Type: text/x-patch; name="PEGASUS.diff"
Content-Description: 984420339-PEGASUS.diff
Content-Disposition: inline; filename="PEGASUS.diff"

--- linux-2.6.23/drivers/net/usb/pegasus.h.orig	2007-12-31 12:54:44.000000000 +0000
+++ linux-2.6.23/drivers/net/usb/pegasus.h	2007-12-31 13:06:18.000000000 +0000
@@ -202,8 +202,12 @@
 		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Allied Telesyn Int. AT-USB100", VENDOR_ALLIEDTEL, 0xb100,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
-PEGASUS_DEV( "Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121,
-		DEFAULT_GPIO_RESET | PEGASUS_II )
+/*
+ * Distinguish between this Belkin adaptor and the Belkin bluetooth adaptors
+ * with the same product IDs by checking the device class too.
+ */
+PEGASUS_DEV_CLASS( "Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121, 0x00,
+		   DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Billionton USB-100", VENDOR_BILLIONTON, 0x0986,
 		DEFAULT_GPIO_RESET )
 PEGASUS_DEV( "Billionton USBLP-100", VENDOR_BILLIONTON, 0x0987,
--- linux-2.6.23/drivers/net/usb/pegasus.c.orig	2007-12-31 12:54:44.000000000 +0000
+++ linux-2.6.23/drivers/net/usb/pegasus.c	2007-12-31 13:04:35.000000000 +0000
@@ -62,8 +62,11 @@
 static struct usb_eth_dev usb_dev_id[] = {
 #define	PEGASUS_DEV(pn, vid, pid, flags)	\
 	{.name = pn, .vendor = vid, .device = pid, .private = flags},
+#define PEGASUS_DEV_CLASS(pn, vid, pid, dclass, flags) \
+	PEGASUS_DEV(pn, vid, pid, flags)
 #include "pegasus.h"
 #undef	PEGASUS_DEV
+#undef  PEGASUS_DEV_CLASS
 	{NULL, 0, 0, 0},
 	{NULL, 0, 0, 0}
 };
@@ -71,8 +74,18 @@
 static struct usb_device_id pegasus_ids[] = {
 #define	PEGASUS_DEV(pn, vid, pid, flags) \
 	{.match_flags = USB_DEVICE_ID_MATCH_DEVICE, .idVendor = vid, .idProduct = pid},
+/*
+ * The Belkin F8T012xx1 bluetooth adaptor has the same vendor and product
+ * IDs as the Belkin F5D5050, so we need to teach the pegasus driver to
+ * ignore adaptors belonging to the "Wireless" class 0xE0. For this one
+ * case anyway, seeing as the pegasus is for "Wired" adaptors.
+ */
+#define PEGASUS_DEV_CLASS(pn, vid, pid, dclass, flags) \
+	{.match_flags = (USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATCH_DEV_CLASS), \
+	 .idVendor = vid, .idProduct = pid, .bDeviceClass = dclass},
 #include "pegasus.h"
 #undef	PEGASUS_DEV
+#undef  PEGASUS_DEV_CLASS
 	{},
 	{}
 };

Signed-off-by: Chris Rankin <rankincj@yahoo.com>


--0-1253408481-1199444860=:6446--
