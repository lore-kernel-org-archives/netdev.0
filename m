From: Oliver Neukum <oliver@neukum.org>
Subject: [RFT] testers for CDC-EEM devices wanted
Date: Mon, 27 Aug 2012 09:23:03 +0200
Message-ID: <2118057.L1dQ5hZKaY@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:44771 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610Ab2H0HYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 03:24:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am looking for people who have a cdc-eem device that emits power
management hints and would be willig to test this patch.

	Regards
		Oliver

>From 499bcc977f13b899cd49a6474843ed3c9086cc0b Mon Sep 17 00:00:00 2001
From: Oliver Neukum <oliver@neukum.org>
Date: Sun, 26 Aug 2012 17:12:06 +0200
Subject: [PATCH] usbnet: Support devices reporting idleness

Some device types support a form of power management in which
the device suggests to the host that the device may be suspended
now. Support for that is best located in usbnet.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/cdc_eem.c  |    4 ++++
 drivers/net/usb/usbnet.c   |   17 +++++++++++++++++
 include/linux/usb/usbnet.h |    2 ++
 3 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 434d5af..c81e278 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -244,8 +244,12 @@ static int eem_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			 *  - suspend: peripheral ready to suspend
 			 *  - response: suggest N millisec polling
 			 *  - response complete: suggest N sec polling
+			 *
+			 * Suspend is reported and maybe heeded.
 			 */
 			case 2:		/* Suspend hint */
+				usbnet_device_suggests_idle(dev);
+				continue;
 			case 3:		/* Response hint */
 			case 4:		/* Response complete hint */
 				continue;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index fd4b26d..38c534a 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1580,10 +1580,27 @@ int usbnet_resume (struct usb_interface *intf)
 			tasklet_schedule (&dev->bh);
 		}
 	}
+
+	if (test_and_clear_bit(EVENT_DEVICE_REPORT_IDLE, &dev->flags))
+		usb_autopm_get_interface_no_resume(intf);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_resume);
 
+/*
+ * Either a subdriver implements manage_power, then it is assumed to always
+ * be ready to be suspended or it reports the readiness to be suspended
+ * explicitly
+ */
+void usbnet_device_suggests_idle(struct usbnet *dev)
+{
+	if (!test_and_set_bit(EVENT_DEVICE_REPORT_IDLE, &dev->flags)) {
+		dev->intf->needs_remote_wakeup = 1;
+		usb_autopm_put_interface_async(dev->intf);
+	}		
+}
+EXPORT_SYMBOL(usbnet_device_suggests_idle);
 
 /*-------------------------------------------------------------------------*/
 
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index f87cf62..ddbbb7d 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -68,6 +68,7 @@ struct usbnet {
 #		define EVENT_RX_PAUSED	5
 #		define EVENT_DEV_ASLEEP 6
 #		define EVENT_DEV_OPEN	7
+#		define EVENT_DEVICE_REPORT_IDLE	8
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
@@ -160,6 +161,7 @@ extern int usbnet_probe(struct usb_interface *, const struct usb_device_id *);
 extern int usbnet_suspend(struct usb_interface *, pm_message_t);
 extern int usbnet_resume(struct usb_interface *);
 extern void usbnet_disconnect(struct usb_interface *);
+extern void usbnet_device_suggests_idle(struct usbnet *dev);
 
 
 /* Drivers that reuse some of the standard USB CDC infrastructure
-- 
1.7.7
