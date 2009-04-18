From: "Peter Holik" <peter@holik.at>
Subject: [PATCH 1/2] usb driver for intellon int51x1 based PLC like devolo
     dlan duo
Date: Sat, 18 Apr 2009 18:43:02 +0200 (CEST)
Message-ID: <88ce751a4a75e257bb8de8e97ddca5d1.squirrel@webmail.it-technology.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Netdev" <netdev@vger.kernel.org>, linux-usb@vger.kernel.org
To: "LKML" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.it-technology.at ([62.99.145.147]:41200 "EHLO
	mail.it-technology.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbZDRQnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 12:43:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

because of using the same function get_ethernet_addr as cdc_ether.c
i export usbnet_get_ethernet_addr from usbnet and fixed cdc_ether
(suggested by Oliver Neukum).

Signed-off-by: Peter Holik <peter@holik.at>
---
 drivers/net/usb/cdc_ether.c |   33 +--------------------------------
 drivers/net/usb/usbnet.c    |   31 +++++++++++++++++++++++++++++++
 include/linux/usb/usbnet.h  |    1 +
 3 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 55e8ecc..01fd528 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -25,7 +25,6 @@
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/ctype.h>
 #include <linux/ethtool.h>
 #include <linux/workqueue.h>
 #include <linux/mii.h>
@@ -389,36 +388,6 @@ static void cdc_status(struct usbnet *dev, struct urb *urb)
 	}
 }

-static u8 nibble(unsigned char c)
-{
-	if (likely(isdigit(c)))
-		return c - '0';
-	c = toupper(c);
-	if (likely(isxdigit(c)))
-		return 10 + c - 'A';
-	return 0;
-}
-
-static inline int
-get_ethernet_addr(struct usbnet *dev, struct usb_cdc_ether_desc *e)
-{
-	int 		tmp, i;
-	unsigned char	buf [13];
-
-	tmp = usb_string(dev->udev, e->iMACAddress, buf, sizeof buf);
-	if (tmp != 12) {
-		dev_dbg(&dev->udev->dev,
-			"bad MAC string %d fetch, %d\n", e->iMACAddress, tmp);
-		if (tmp >= 0)
-			tmp = -EINVAL;
-		return tmp;
-	}
-	for (i = tmp = 0; i < 6; i++, tmp += 2)
-		dev->net->dev_addr [i] =
-			(nibble(buf [tmp]) << 4) + nibble(buf [tmp + 1]);
-	return 0;
-}
-
 static int cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int				status;
@@ -428,7 +397,7 @@ static int cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 	if (status < 0)
 		return status;

-	status = get_ethernet_addr(dev, info->ether);
+	status = usbnet_get_ethernet_addr(dev, info->ether->iMACAddress);
 	if (status < 0) {
 		usb_set_intfdata(info->data, NULL);
 		usb_driver_release_interface(driver_of(intf), info->data);
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f3a2fce..976e646 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -37,6 +37,7 @@
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/ctype.h>
 #include <linux/ethtool.h>
 #include <linux/workqueue.h>
 #include <linux/mii.h>
@@ -156,6 +157,36 @@ int usbnet_get_endpoints(struct usbnet *dev, struct usb_interface *intf)
 }
 EXPORT_SYMBOL_GPL(usbnet_get_endpoints);

+static u8 nibble(unsigned char c)
+{
+	if (likely(isdigit(c)))
+		return c - '0';
+	c = toupper(c);
+	if (likely(isxdigit(c)))
+		return 10 + c - 'A';
+	return 0;
+}
+
+int usbnet_get_ethernet_addr(struct usbnet *dev, int iMACAddress)
+{
+	int 		tmp, i;
+	unsigned char	buf [13];
+
+	tmp = usb_string(dev->udev, iMACAddress, buf, sizeof buf);
+	if (tmp != 12) {
+		dev_dbg(&dev->udev->dev,
+			"bad MAC string %d fetch, %d\n", iMACAddress, tmp);
+		if (tmp >= 0)
+			tmp = -EINVAL;
+		return tmp;
+	}
+	for (i = tmp = 0; i < 6; i++, tmp += 2)
+		dev->net->dev_addr [i] =
+			(nibble(buf [tmp]) << 4) + nibble(buf [tmp + 1]);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(usbnet_get_ethernet_addr);
+
 static void intr_complete (struct urb *urb);

 static int init_status (struct usbnet *dev, struct usb_interface *intf)
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 36fabb9..5d44059 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -183,6 +183,7 @@ extern void usbnet_tx_timeout (struct net_device *net);
 extern int usbnet_change_mtu (struct net_device *net, int new_mtu);

 extern int usbnet_get_endpoints(struct usbnet *, struct usb_interface *);
+extern int usbnet_get_ethernet_addr(struct usbnet *, int);
 extern void usbnet_defer_kevent (struct usbnet *, int);
 extern void usbnet_skb_return (struct usbnet *, struct sk_buff *);
 extern void usbnet_unlink_rx_urbs(struct usbnet *);
-- 
1.6.2.1




