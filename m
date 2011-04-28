From: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCHv8] usbnet: Resubmit interrupt URB if device is open
Date: Thu, 28 Apr 2011 08:43:37 -0700
Message-ID: <20110428155227.A7B412031F@glenhelen.mtv.corp.google.com>
References: <20110427.230011.59678907.davem@davemloft.net>
Cc: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110427.230011.59678907.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Resubmit interrupt URB if device is open.  Use a flag set in
usbnet_open() to determine this state.  Also kill and free
interrupt URB in usbnet_disconnect().

[Rebased off git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git]

Signed-off-by: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/usb/usbnet.c   |    8 ++++++++
 include/linux/usb/usbnet.h |    1 +
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 069c1cf..009bba3 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -736,6 +736,7 @@ int usbnet_open (struct net_device *net)
 		}
 	}
 
+	set_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_start_queue (net);
 	netif_info(dev, ifup, dev->net,
 		   "open: enable queueing (rx %d, tx %d) mtu %d %s framing\n",
@@ -1259,6 +1260,9 @@ void usbnet_disconnect (struct usb_interface *intf)
 	if (dev->driver_info->unbind)
 		dev->driver_info->unbind (dev, intf);
 
+	usb_kill_urb(dev->interrupt);
+	usb_free_urb(dev->interrupt);
+
 	free_netdev(net);
 	usb_put_dev (xdev);
 }
@@ -1498,6 +1502,10 @@ int usbnet_resume (struct usb_interface *intf)
 	int                     retval;
 
 	if (!--dev->suspend_count) {
+		/* resume interrupt URBs */
+		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
+			usb_submit_urb(dev->interrupt, GFP_NOIO);
+
 		spin_lock_irq(&dev->txq.lock);
 		while ((res = usb_get_from_anchor(&dev->deferred))) {
 
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 0e18550..605b0aa 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -68,6 +68,7 @@ struct usbnet {
 #		define EVENT_RX_PAUSED	5
 #		define EVENT_DEV_WAKING 6
 #		define EVENT_DEV_ASLEEP 7
+#		define EVENT_DEV_OPEN	8
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
-- 
1.7.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
