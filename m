From: Ming Lei <ming.lei@canonical.com>
Subject: [RFC PATCH 2/3] usbnet: apply usbnet_link_change
Date: Sun, 16 Sep 2012 01:48:18 +0800
Message-ID: <1347731299-29898-3-git-send-email-ming.lei@canonical.com>
References: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, Fink Dmitry <finik@ti.com>,
	Rafael Wysocki <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:37685 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287Ab2IORsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 13:48:50 -0400
In-Reply-To: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch applies the introduce usbnet_link_change API.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/asix_devices.c |    6 +-----
 drivers/net/usb/cdc_ether.c    |    5 +----
 drivers/net/usb/cdc_ncm.c      |    9 +++------
 drivers/net/usb/dm9601.c       |    7 +------
 drivers/net/usb/mcs7830.c      |    6 +-----
 drivers/net/usb/sierra_net.c   |    3 +--
 drivers/net/usb/usbnet.c       |    2 +-
 7 files changed, 9 insertions(+), 29 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 4fd48df..c354bb1 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -55,11 +55,7 @@ static void asix_status(struct usbnet *dev, struct urb *urb)
 	event = urb->transfer_buffer;
 	link = event->link & 0x01;
 	if (netif_carrier_ok(dev->net) != link) {
-		if (link) {
-			netif_carrier_on(dev->net);
-			usbnet_defer_kevent (dev, EVENT_LINK_RESET );
-		} else
-			netif_carrier_off(dev->net);
+		usbnet_link_change(dev, link, 1);
 		netdev_dbg(dev->net, "Link Status is: %d\n", link);
 	}
 }
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index a03de71..c6e4be5 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -406,10 +406,7 @@ void usbnet_cdc_status(struct usbnet *dev, struct urb *urb)
 	case USB_CDC_NOTIFY_NETWORK_CONNECTION:
 		netif_dbg(dev, timer, dev->net, "CDC: carrier %s\n",
 			  event->wValue ? "on" : "off");
-		if (event->wValue)
-			netif_carrier_on(dev->net);
-		else
-			netif_carrier_off(dev->net);
+		usbnet_link_change(dev, event->wValue, 0);
 		break;
 	case USB_CDC_NOTIFY_SPEED_CHANGE:	/* tx/rx rates */
 		netif_dbg(dev, timer, dev->net, "CDC: speed change (len %d)\n",
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4cd582a..f425c2c 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -593,7 +593,7 @@ advance:
 	 * (carrier is OFF) during attach, so the IP network stack does not
 	 * start IPv6 negotiation and more.
 	 */
-	netif_carrier_off(dev->net);
+	usbnet_link_change(dev, 0, 0);
 	ctx->tx_speed = ctx->rx_speed = 0;
 	return 0;
 
@@ -1131,12 +1131,9 @@ static void cdc_ncm_status(struct usbnet *dev, struct urb *urb)
 			" %sconnected\n",
 			ctx->netdev->name, ctx->connected ? "" : "dis");
 
-		if (ctx->connected)
-			netif_carrier_on(dev->net);
-		else {
-			netif_carrier_off(dev->net);
+		usbnet_link_change(dev, ctx->connected, 0);
+		if (!ctx->connected)
 			ctx->tx_speed = ctx->rx_speed = 0;
-		}
 		break;
 
 	case USB_CDC_NOTIFY_SPEED_CHANGE:
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index e0433ce..7422d5a 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -587,12 +587,7 @@ static void dm9601_status(struct usbnet *dev, struct urb *urb)
 
 	link = !!(buf[0] & 0x40);
 	if (netif_carrier_ok(dev->net) != link) {
-		if (link) {
-			netif_carrier_on(dev->net);
-			usbnet_defer_kevent (dev, EVENT_LINK_RESET);
-		}
-		else
-			netif_carrier_off(dev->net);
+		usbnet_link_change(dev, link, 1);
 		netdev_dbg(dev->net, "Link Status is: %d\n", link);
 	}
 }
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 03c2d8d..49a98b7 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -639,11 +639,7 @@ static void mcs7830_status(struct usbnet *dev, struct urb *urb)
 
 	link = !(buf[1] & 0x20);
 	if (netif_carrier_ok(dev->net) != link) {
-		if (link) {
-			netif_carrier_on(dev->net);
-			usbnet_defer_kevent(dev, EVENT_LINK_RESET);
-		} else
-			netif_carrier_off(dev->net);
+		usbnet_link_change(dev, link, 1);
 		netdev_dbg(dev->net, "Link Status is: %d\n", link);
 	}
 }
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index 7ae70e9..08ed9e5 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -414,11 +414,10 @@ static void sierra_net_handle_lsi(struct usbnet *dev, char *data,
 	if (link_up) {
 		sierra_net_set_ctx_index(priv, hh->msgspecific.byte);
 		priv->link_up = 1;
-		netif_carrier_on(dev->net);
 	} else {
 		priv->link_up = 0;
-		netif_carrier_off(dev->net);
 	}
+	usbnet_link_change(dev, link_up, 0);
 }
 
 static void sierra_net_dosync(struct usbnet *dev)
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 95a96b1..054ffd8 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1487,7 +1487,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	netif_device_attach (net);
 
 	if (dev->driver_info->flags & FLAG_LINK_INTR)
-		netif_carrier_off(net);
+		usbnet_link_change(dev, 0, 0);
 
 	return 0;
 
-- 
1.7.9.5
