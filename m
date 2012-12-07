From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/2] caif_usb: Make the driver name check more
 efficient
Date: Fri, 7 Dec 2012 16:20:27 +0000
Message-ID: <1354897227.2707.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8635 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161012Ab2LGQUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 11:20:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the device model to get just the name, rather than using the
ethtool API to get all driver information.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Compile-tested only.  I'm assuming that the strncmp() is not really
necessary, but perhaps there is some OOT variant of cdc_ncm that is also
supposed to be supported?

Ben.

 net/caif/caif_usb.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index 582f80c..3ebc8cb 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -128,17 +128,10 @@ static int cfusbl_device_notify(struct notifier_block *me, unsigned long what,
 	struct cflayer *layer, *link_support;
 	struct usbnet *usbnet;
 	struct usb_device *usbdev;
-	struct ethtool_drvinfo drvinfo;
 
-	/*
-	 * Quirks: High-jack ethtool to find if we have a NCM device,
-	 * and find it's VID/PID.
-	 */
-	if (dev->ethtool_ops == NULL || dev->ethtool_ops->get_drvinfo == NULL)
-		return 0;
-
-	dev->ethtool_ops->get_drvinfo(dev, &drvinfo);
-	if (strncmp(drvinfo.driver, "cdc_ncm", 7) != 0)
+	/* Check whether we have a NCM device, and find its VID/PID. */
+	if (!(dev->dev.parent && dev->dev.parent->driver &&
+	      strcmp(dev->dev.parent->driver->name, "cdc_ncm") == 0))
 		return 0;
 
 	usbnet = netdev_priv(dev);
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
