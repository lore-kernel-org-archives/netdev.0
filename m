From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] usbnet: rx_submit() should return an error code.
Date: Mon, 9 Aug 2010 18:37:50 -0400
Message-ID: <AANLkTimubaXzLjROeaNB0dV09thKfpLDyaEA-t_yzyV1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jason Glasgow <jglasgow-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch makes rx_submit() return an error code, and makes some call sites
that care check the return value. This is important because it lets us properly
handle cases where the device isn't ready to handle URB submissions (e.g., when
it is autosuspended under some drivers); previously, we would attempt and fail
to submit URBs and reschedule ourselves to try and fail again. This patch is
against Linus's 2.6 repo commit 45d7f32c7a43cbb9592886d38190e379e2eb2226.

Signed-Off-By: Elizabeth Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/usb/usbnet.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3b03794..82a992a 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -315,7 +315,7 @@ EXPORT_SYMBOL_GPL(usbnet_defer_kevent);

 static void rx_complete (struct urb *urb);

-static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
+static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 {
 	struct sk_buff		*skb;
 	struct skb_data		*entry;
@@ -327,7 +327,7 @@ static void rx_submit (struct usbnet *dev, struct
urb *urb, gfp_t flags)
 		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
 		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
 		usb_free_urb (urb);

-		return;
+		return -ENOMEM;
 	}
 	skb_reserve (skb, NET_IP_ALIGN);

@@ -357,6 +357,9 @@ static void rx_submit (struct usbnet *dev, struct
urb *urb, gfp_t flags)
 			netif_dbg(dev, ifdown, dev->net, "device gone\n");
 			netif_device_detach (dev->net);
 			break;
+		case -EHOSTUNREACH:
+			retval = -ENOLINK;
+			break;
 		default:
 			netif_dbg(dev, rx_err, dev->net,
 				  "rx submit, %d\n", retval);
@@ -374,6 +377,7 @@ static void rx_submit (struct usbnet *dev, struct
urb *urb, gfp_t flags)
 		dev_kfree_skb_any (skb);
 		usb_free_urb (urb);
 	}
+	return retval;
 }


@@ -912,6 +916,7 @@ fail_halt:
 	/* tasklet could resubmit itself forever if memory is tight */
 	if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
 		struct urb	*urb = NULL;
+		int resched = 1;

 		if (netif_running (dev->net))
 			urb = usb_alloc_urb (0, GFP_KERNEL);
@@ -922,10 +927,12 @@ fail_halt:
 			status = usb_autopm_get_interface(dev->intf);
 			if (status < 0)
 				goto fail_lowmem;
-			rx_submit (dev, urb, GFP_KERNEL);
+			if (rx_submit (dev, urb, GFP_KERNEL) == -ENOLINK)
+				resched = 0;
 			usb_autopm_put_interface(dev->intf);
 fail_lowmem:
-			tasklet_schedule (&dev->bh);
+			if (resched)
+				tasklet_schedule (&dev->bh);
 		}
 	}

@@ -1176,7 +1183,9 @@ static void usbnet_bh (unsigned long param)
 			for (i = 0; i < 10 && dev->rxq.qlen < qlen; i++) {
 				urb = usb_alloc_urb (0, GFP_ATOMIC);
 				if (urb != NULL)
-					rx_submit (dev, urb, GFP_ATOMIC);
+					if (rx_submit (dev, urb, GFP_ATOMIC)
+					    == -ENOLINK)
+						return;
 			}
 			if (temp != dev->rxq.qlen)
 				netif_dbg(dev, link, dev->net,
-- 
1.7.1
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
