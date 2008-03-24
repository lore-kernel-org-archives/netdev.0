From: Stefan Bader <stefan.bader@canonical.com>
Subject: [PATCH] Adding blacklist support to the pegasus driver
Date: Mon, 24 Mar 2008 12:10:14 -0400
Message-ID: <47E7D266.8050500@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080103070407090509070504"
Cc: petkan@users.sourceforge.net
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:42052 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440AbYCXQhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 12:37:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080103070407090509070504
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

I have been working on a problem which arose from the fact that (at
least one vendor) some vendors use the same vendor and model number for
different pieces of hardware.
In this case the Belkin bluetooth dongle uses the same numbers as the
network adapter which causes machines to lock up as soon as the
bluetooth dongle gets inserted.
As far as I found there had been discussions about adding some sort of
blacklisting support to the pegasus module before but I have not found
any code doing so.
This is what the attached patch does. There is possibly much room for
improvement but at least it seems to work. Would it be possible to
include something like this in the mainline driver?
Please keep me cc'ed on replies, since I am not subscribed to the
mailing lists. Thanks.

Stefan

--------------080103070407090509070504
Content-Type: text/x-diff;
 name="0001-Add-blacklisting-support-to-pegasus-u.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-Add-blacklisting-support-to-pegasus-u.patch"

>From 840b9f950175a27173a2e65a10332eb74c4654fc Mon Sep 17 00:00:00 2001
From: Stefan Bader <stefan.bader@canonical.com>
Date: Mon, 24 Mar 2008 11:49:40 -0400
Subject: [PATCH] Add blacklisting support to pegasus usb driver.

Belkin uses the same vendor id for both the ethernet and the bluetooth
device, but the pegasus driver only checks for the vendor id to decide
whether to drive a device or not. This locks up computers that are using
the bluetooth dongle.

Signed-off-by: Stefan Bader <stefan.bader@canonical.com>
---
 drivers/net/usb/pegasus.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index d1ed68a..198f518 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1289,6 +1289,24 @@ static void check_carrier(struct work_struct *work)
 	}
 }
 
+static int pegasus_blacklisted(struct usb_device *udev)
+{
+	struct usb_device_descriptor *udd = &udev->descriptor;
+
+	/* Special quirk to keep the driver from handling the Belkin Bluetooth
+	 * dongle which happens to have the same ID as the network dongle.
+	 */
+	if (udd->idVendor == VENDOR_BELKIN && udd->idProduct == 0x0121) {
+		if (udd->bDeviceClass == USB_CLASS_WIRELESS_CONTROLLER) {
+			if (udd->bDeviceProtocol == 1) {
+				return 1;
+			}
+		}
+	}
+
+	return 0;
+}
+
 static int pegasus_probe(struct usb_interface *intf,
 			 const struct usb_device_id *id)
 {
@@ -1300,6 +1318,12 @@ static int pegasus_probe(struct usb_interface *intf,
 	DECLARE_MAC_BUF(mac);
 
 	usb_get_dev(dev);
+
+	if (pegasus_blacklisted(dev)) {
+			res = -ENODEV;
+			goto out;
+	}
+
 	net = alloc_etherdev(sizeof(struct pegasus));
 	if (!net) {
 		dev_err(&intf->dev, "can't allocate %s\n", "device");
-- 
1.5.4.3


--------------080103070407090509070504--
