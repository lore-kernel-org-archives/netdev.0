From: tom.leiming@gmail.com
Subject: [PATCH] usbnet: runtime pm: fix usb_autopm_get_interface failure
Date: Wed, 27 Oct 2010 22:45:03 +0800
Message-ID: <1288190703-3154-1-git-send-email-tom.leiming@gmail.com>
Cc: Ming Lei <tom.leiming@gmail.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Ben Hutchings <ben@decadent.org.uk>,
	Joe Perches <joe@perches.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>, stable@kernel.org
To: netdev@vger.kernel.org, oliver@neukum.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:36958 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755893Ab0J0OpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 10:45:16 -0400
Received: by qwf7 with SMTP id 7so44923qwf.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 07:45:15 -0700 (PDT)
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
 drivers/net/usb/usbnet.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ca7fc9d..765308f 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1273,6 +1273,16 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
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

