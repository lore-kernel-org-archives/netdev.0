From: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCHv6] usbnet: Resubmit interrupt URB if device is open
Date: Tue, 19 Apr 2011 10:44:12 -0700
Message-ID: <20110422161813.55A0D20334@glenhelen.mtv.corp.google.com>
References: <Pine.LNX.4.44L0.1104221129530.1877-100000@iolanthe.rowland.org>
Cc: stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1104221129530.1877-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Resubmit interrupt URB if device is open.  Use a flag set in
usbnet_open() to determine this state.  Also kill and free
interrupt URB in usbnet_disconnect().

Signed-off-by: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/usb/usbnet.c   |   11 +++++++++++
 include/linux/usb/usbnet.h |    1 +
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 02d25c7..b4572c3 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -643,6 +643,7 @@ static int usbnet_open (struct net_device *net)
 		}
 	}
 
+	set_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_start_queue (net);
 	if (netif_msg_ifup (dev)) {
 		char	*framing;
@@ -1105,6 +1106,9 @@ void usbnet_disconnect (struct usb_interface *intf)
 	if (dev->driver_info->unbind)
 		dev->driver_info->unbind (dev, intf);
 
+	usb_kill_urb(dev->interrupt);
+	usb_free_urb(dev->interrupt);
+
 	free_netdev(net);
 	usb_put_dev (xdev);
 }
@@ -1285,6 +1289,9 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		 * wake the device
 		 */
 		netif_device_attach (dev->net);
+
+		/* Stop interrupt URBs */
+		usb_kill_urb(dev->interrupt);
 	}
 	return 0;
 }
@@ -1297,6 +1304,10 @@ int usbnet_resume (struct usb_interface *intf)
 	if (!--dev->suspend_count)
 		tasklet_schedule (&dev->bh);
 
+		/* resume interrupt URBs */
+		if (test_bit(EVENT_DEV_OPEN, &dev->flags))
+			usb_submit_urb(dev->interrupt, GFP_NOIO);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_resume);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index ba09fe8..d148cca 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -64,6 +64,7 @@ struct usbnet {
 #		define EVENT_RX_MEMORY	2
 #		define EVENT_STS_SPLIT	3
 #		define EVENT_LINK_RESET	4
+#		define EVENT_DEV_OPEN	5
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
-- 
1.7.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
