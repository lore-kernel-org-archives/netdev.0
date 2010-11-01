From: tom.leiming@gmail.com
Subject: [PATCH] usbnet: fix usb_autopm_get_interface failure(v1)
Date: Mon,  1 Nov 2010 22:05:49 +0800
Message-ID: <1288620349-9769-1-git-send-email-tom.leiming@gmail.com>
Cc: Ming Lei <tom.leiming@gmail.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Ben Hutchings <ben@decadent.org.uk>,
	Joe Perches <joe@perches.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>, stable@kernel.org
To: netdev@vger.kernel.org, oliver@neukum.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51492 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756428Ab0KAOGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 10:06:09 -0400
Received: by iwn10 with SMTP id 10so7075165iwn.19
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 07:06:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <tom.leiming@gmail.com>

Since usbnet already took usb runtime pm, we have to
enable runtime pm for usb interface of usbnet, otherwise
usb_autopm_get_interface may return failure and cause
'ifconfig usb0 up' failed if USB_SUSPEND(RUNTIME_PM) is
enabled.

Cc: David Brownell <dbrownell@users.sourceforge.net>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: Joe Perches <joe@perches.com>
Cc: Oliver Neukum <oliver@neukum.org>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: stable@kernel.org
Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
v1: include header file

---
 drivers/net/usb/usbnet.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ca7fc9d..06b1dee 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -45,6 +45,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
 #include <linux/kernel.h>
+#include <linux/pm_runtime.h>
 
 #define DRIVER_VERSION		"22-Aug-2005"
 
@@ -1273,6 +1274,16 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	struct usb_device		*xdev;
 	int				status;
 	const char			*name;
+	struct usb_driver 	*driver = to_usb_driver(udev->dev.driver);
+
+	/*usbnet already took usb runtime pm, so have to enable the feature
+ 	* for usb interface, otherwise usb_autopm_get_interface may return
+ 	* failure if USB_SUSPEND(RUNTIME_PM) is enabled.
+ 	* */
+	if (!driver->supports_autosuspend) {
+		driver->supports_autosuspend = 1;
+		pm_runtime_enable(&udev->dev);
+	}
 
 	name = udev->dev.driver->name;
 	info = (struct driver_info *) prod->driver_info;
-- 
1.7.3

