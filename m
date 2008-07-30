From: akpm@linux-foundation.org
Subject: [patch 09/12] pegasus: add blacklist support to fix Belkin bluetooth dongle.
Date: Wed, 30 Jul 2008 12:39:02 -0700
Message-ID: <200807301939.m6UJd2PA012599@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	ben.collins@canonical.com, david-b@pacbell.net, gregkh@suse.de,
	stefan.bader@canonical.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51233 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754025AbYG3TyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:54:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Collins <ben.collins@canonical.com>

Reference: https://launchpad.net/bugs/140511

The Belkin bluetooth dongle unfortunately shares the vendor and device id
with the network adapter which causes lockups whenever the bluetooth
dongle is inserted.

Signed-off-by: Stefan Bader <stefan.bader@canonical.com>
Signed-off-by: Ben Collins <ben.collins@canonical.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: David Brownell <david-b@pacbell.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/usb/pegasus.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff -puN drivers/net/usb/pegasus.c~pegasus-add-blacklist-support-to-fix-belkin-bluetooth-dongle drivers/net/usb/pegasus.c
--- a/drivers/net/usb/pegasus.c~pegasus-add-blacklist-support-to-fix-belkin-bluetooth-dongle
+++ a/drivers/net/usb/pegasus.c
@@ -1285,6 +1285,21 @@ static void check_carrier(struct work_st
 	}
 }
 
+static int pegasus_blacklisted(struct usb_device *udev)
+{
+	struct usb_device_descriptor *udd = &udev->descriptor;
+
+	/* Special quirk to keep the driver from handling the Belkin Bluetooth
+	 * dongle which happens to have the same ID.
+	 */
+	if ((udd->idVendor == VENDOR_BELKIN && udd->idProduct == 0x0121) &&
+	    (udd->bDeviceClass == USB_CLASS_WIRELESS_CONTROLLER) &&
+	    (udd->bDeviceProtocol == 1))
+		return 1;
+
+	return 0;
+}
+
 static int pegasus_probe(struct usb_interface *intf,
 			 const struct usb_device_id *id)
 {
@@ -1296,6 +1311,12 @@ static int pegasus_probe(struct usb_inte
 	DECLARE_MAC_BUF(mac);
 
 	usb_get_dev(dev);
+
+	if (pegasus_blacklisted(dev)) {
+		res = -ENODEV;
+		goto out;
+	}
+
 	net = alloc_etherdev(sizeof(struct pegasus));
 	if (!net) {
 		dev_err(&intf->dev, "can't allocate %s\n", "device");
_
