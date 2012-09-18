From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [RFC PATCH v1 2/3] usbnet: apply usbnet_link_change
Date: Tue, 18 Sep 2012 22:23:20 +0800
Message-ID: <1347978201-6219-3-git-send-email-ming.lei@canonical.com>
References: <1347978201-6219-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, Fink Dmitry <finik-l0cyMroinI0@public.gmane.org>,
	Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347978201-6219-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch applies the introduce usbnet_link_change API.

Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
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
index e986e4b..dc4ff47 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1499,7 +1499,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	netif_device_attach (net);
 
 	if (dev->driver_info->flags & FLAG_LINK_INTR)
-		netif_carrier_off(net);
+		usbnet_link_change(dev, 0, 0);
 
 	return 0;
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
