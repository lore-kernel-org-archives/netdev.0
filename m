From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [RFC PATCH 1/3] usbnet: introduce usbnet_link_change API
Date: Sun, 16 Sep 2012 01:48:17 +0800
Message-ID: <1347731299-29898-2-git-send-email-ming.lei@canonical.com>
References: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, Fink Dmitry <finik-l0cyMroinI0@public.gmane.org>,
	Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347731299-29898-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch introduces the API of usbnet_link_change, so that
usbnet can trace the link change, which may help to implement
the later runtime PM triggered by usb ethernet link change.

Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/usbnet.c   |   11 +++++++++++
 include/linux/usb/usbnet.h |    2 +-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index e944109..95a96b1 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1591,6 +1591,17 @@ int usbnet_resume (struct usb_interface *intf)
 }
 EXPORT_SYMBOL_GPL(usbnet_resume);
 
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
+EXPORT_SYMBOL_GPL(usbnet_link_change);
 
 /*-------------------------------------------------------------------------*/
 
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index f87cf62..1937b74 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -160,7 +160,7 @@ extern int usbnet_probe(struct usb_interface *, const struct usb_device_id *);
 extern int usbnet_suspend(struct usb_interface *, pm_message_t);
 extern int usbnet_resume(struct usb_interface *);
 extern void usbnet_disconnect(struct usb_interface *);
