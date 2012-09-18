From: Ming Lei <ming.lei@canonical.com>
Subject: [RFC PATCH v1 1/3] usbnet: introduce usbnet_link_change API
Date: Tue, 18 Sep 2012 22:23:19 +0800
Message-ID: <1347978201-6219-2-git-send-email-ming.lei@canonical.com>
References: <1347978201-6219-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, Fink Dmitry <finik@ti.com>,
	Rafael Wysocki <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41520 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757676Ab2IROXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 10:23:51 -0400
In-Reply-To: <1347978201-6219-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the API of usbnet_link_change, so that
usbnet can trace the link change, which may help to implement
the later runtime PM triggered by usb ethernet link change.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/usbnet.c   |   13 ++++++++++++-
 include/linux/usb/usbnet.h |    2 +-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index e944109..e986e4b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -677,6 +677,18 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 	remove_wait_queue(&unlink_wakeup, &wait);
 }
 
+void usbnet_link_change(struct usbnet *dev, int link, int need_reset)
+{
+	if (link)
+		netif_carrier_on(dev->net);
+	else
+		netif_carrier_off(dev->net);
+
+	if (need_reset && link)
+		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+}
+EXPORT_SYMBOL(usbnet_link_change);
+
 int usbnet_stop (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
@@ -1591,7 +1603,6 @@ int usbnet_resume (struct usb_interface *intf)
 }
 EXPORT_SYMBOL_GPL(usbnet_resume);
 
-
 /*-------------------------------------------------------------------------*/
 
 static int __init usbnet_init(void)
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index f87cf62..1937b74 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -160,7 +160,7 @@ extern int usbnet_probe(struct usb_interface *, const struct usb_device_id *);
 extern int usbnet_suspend(struct usb_interface *, pm_message_t);
 extern int usbnet_resume(struct usb_interface *);
 extern void usbnet_disconnect(struct usb_interface *);
-
+extern void usbnet_link_change(struct usbnet *dev, int link, int need_reset);
 
 /* Drivers that reuse some of the standard USB CDC infrastructure
  * (notably, using multiple interfaces according to the CDC
-- 
1.7.9.5
