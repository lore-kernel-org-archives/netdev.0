From: Stefan Bader <stefan.bader@canonical.com>
Subject: [PATCH] Enhanced matching code for pegasus driver (was blacklist
 support)
Date: Thu, 10 Apr 2008 18:27:18 -0400
Message-ID: <47FE9446.7010404@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030900070207000704050708"
Cc: Petko Manolov <petkan@nucleusys.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:57261 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbYDJW1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 18:27:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030900070207000704050708
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

I have reworked the patch from using a blacklist to using the enhanced
matching macros. While certainly going into the right direction I got
one problem: although this certainly will prevent the bluetooth adapter
from loading I cannot tell (due to missing hardware) whether this will
not prevent the ethernet dongle from working.
So question is a) does the approach look good and b) has somebode a
Belkin usb ethernet adapter to verify the class, subclass and protocol?

Regards,
Stefan

> I have been working on a problem which arose from the fact that (at
> least one vendor) some vendors use the same vendor and model number for
> different pieces of hardware.
> In this case the Belkin bluetooth dongle uses the same numbers as the
> network adapter which causes machines to lock up as soon as the
> bluetooth dongle gets inserted.
> As far as I found there had been discussions about adding some sort of
> blacklisting support to the pegasus module before but I have not found
> any code doing so.
> This is what the attached patch does. There is possibly much room for
> improvement but at least it seems to work. Would it be possible to
> include something like this in the mainline driver?


--------------030900070207000704050708
Content-Type: text/x-diff;
 name="pegasus4.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pegasus4.diff"

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index d1ed68a..61f4f72 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -62,17 +62,23 @@ static char *devid=NULL;
 static struct usb_eth_dev usb_dev_id[] = {
 #define	PEGASUS_DEV(pn, vid, pid, flags)	\
 	{.name = pn, .vendor = vid, .device = pid, .private = flags},
+#define PEGASUS_DEVINT(pn, vid, pid, flags, cl, sc, pr) \
+	PEGASUS_DEV(pn, vid, pid, flags)
 #include "pegasus.h"
 #undef	PEGASUS_DEV
+#undef	PEGASUS_DEVINT
 	{NULL, 0, 0, 0},
 	{NULL, 0, 0, 0}
 };
 
 static struct usb_device_id pegasus_ids[] = {
 #define	PEGASUS_DEV(pn, vid, pid, flags) \
-	{.match_flags = USB_DEVICE_ID_MATCH_DEVICE, .idVendor = vid, .idProduct = pid},
+	{USB_DEVICE(vid, pid)},
+#define PEGASUS_DEVINT(pn, vid, pid, flags, cl, sc, pr) \
+	{USB_DEVICE_AND_INTERFACE_INFO(vid, pid, cl, sc, pr)},
 #include "pegasus.h"
 #undef	PEGASUS_DEV
+#undef	PEGASUS_DEVINT
 	{},
 	{}
 };
diff --git a/drivers/net/usb/pegasus.h b/drivers/net/usb/pegasus.h
index c746782..a7000ed 100644
--- a/drivers/net/usb/pegasus.h
+++ b/drivers/net/usb/pegasus.h
@@ -202,8 +202,8 @@ PEGASUS_DEV( "AEI USB Fast Ethernet Adapter", VENDOR_AEILAB, 0x1701,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Allied Telesyn Int. AT-USB100", VENDOR_ALLIEDTEL, 0xb100,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
-PEGASUS_DEV( "Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121,
-		DEFAULT_GPIO_RESET | PEGASUS_II )
+PEGASUS_DEVINT( "Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121,
+		DEFAULT_GPIO_RESET | PEGASUS_II, 0xff, 0xff, 0xff )
 PEGASUS_DEV( "Billionton USB-100", VENDOR_BILLIONTON, 0x0986,
 		DEFAULT_GPIO_RESET )
 PEGASUS_DEV( "Billionton USBLP-100", VENDOR_BILLIONTON, 0x0987,

--------------030900070207000704050708--
