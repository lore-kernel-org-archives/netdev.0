From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH 1/3] usbnet: handle PM failure gracefully
Date: Tue, 18 Dec 2012 15:45:29 +0100
Message-ID: <1355841929-983-1-git-send-email-oliver@neukum.org>
Cc: Oliver Neukum <oliver@neukum.org>, Oliver Neukum <oneukum@suse.de>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:50903 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066Ab2LROpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 09:45:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a device fails to do remote wakeup, this is no reason
to abort an open totally. This patch just continues without
runtime PM.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/usbnet.c   |   15 ++++++++-------
 include/linux/usb/usbnet.h |    1 +
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index c04110b..50ed7ab 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -719,7 +719,8 @@ int usbnet_stop (struct net_device *net)
 	dev->flags = 0;
 	del_timer_sync (&dev->delay);
 	tasklet_kill (&dev->bh);
-	if (info->manage_power)
+	if (info->manage_power &&
+	    !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags))
 		info->manage_power(dev, 0);
 	else
 		usb_autopm_put_interface(dev->intf);
@@ -794,14 +795,14 @@ int usbnet_open (struct net_device *net)
 	tasklet_schedule (&dev->bh);
 	if (info->manage_power) {
 		retval = info->manage_power(dev, 1);
-		if (retval < 0)
-			goto done_manage_power_error;
-		usb_autopm_put_interface(dev->intf);
+		if (retval < 0) {
+			retval = 0;
+			set_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
+		} else {
+			usb_autopm_put_interface(dev->intf);
+		}
 	}
 	return retval;
-
-done_manage_power_error:
-	clear_bit(EVENT_DEV_OPEN, &dev->flags);
 done:
 	usb_autopm_put_interface(dev->intf);
 done_nopm:
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 9bbeabf..288b32a 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -69,6 +69,7 @@ struct usbnet {
 #		define EVENT_DEV_ASLEEP 6
 #		define EVENT_DEV_OPEN	7
 #		define EVENT_DEVICE_REPORT_IDLE	8
+#		define EVENT_NO_RUNTIME_PM	9
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
-- 
1.7.7
