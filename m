From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 01/11] usbnet: introduce usbnet_link_change API
Date: Thu, 11 Apr 2013 22:40:30 +0800
Message-ID: <1365691240-816-2-git-send-email-ming.lei@canonical.com>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:38527 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932712Ab3DKOlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:41:01 -0400
In-Reply-To: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the API of usbnet_link_change, so that
usbnet can handle link change centrally, which may help to
implement killing traffic URBs for saving USB bus bandwidth
and host controller power.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/usbnet.c   |   13 +++++++++++++
 include/linux/usb/usbnet.h |    1 +
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 51f3192..40e4237 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1653,6 +1653,19 @@ int usbnet_manage_power(struct usbnet *dev, int on)
 }
 EXPORT_SYMBOL(usbnet_manage_power);
 
+void usbnet_link_change(struct usbnet *dev, bool link, bool need_reset)
+{
+	/* update link after link is reseted */
+	if (link && !need_reset)
+		netif_carrier_on(dev->net);
+	else
+		netif_carrier_off(dev->net);
+
+	if (need_reset && link)
+		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+}
+EXPORT_SYMBOL(usbnet_link_change);
+
 /*-------------------------------------------------------------------------*/
 static int __usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 			     u16 value, u16 index, void *data, u16 size)
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 0e5ac93..eb021b8 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -245,5 +245,6 @@ extern void usbnet_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
 extern int usbnet_nway_reset(struct net_device *net);
 
 extern int usbnet_manage_power(struct usbnet *, int);
+extern void usbnet_link_change(struct usbnet *, bool, bool);
 
 #endif /* __LINUX_USB_USBNET_H */
-- 
1.7.9.5
