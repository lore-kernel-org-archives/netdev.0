From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/7] usbnet: remove EVENT_DEV_OPEN flag
Date: Tue, 12 Jun 2012 09:19:42 +0800
Message-ID: <1339463985-9006-5-git-send-email-tom.leiming@gmail.com>
References: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1339463985-9006-1-git-send-email-tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

EVENT_DEV_OPEN is introduced to mark if the interface is opened or
not, but we already have IFF_UP to handle it, so just
remove the flag and use IFF_UP.

Also the patch may fix one bug in failure path of usbnet_open:
it may return failure but EVENT_DEV_OPEN is not cleared. After
this convering, dev->net->flags & IFF_UP always return consistent
status of the interface.

Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/usbnet.c   |    6 ++----
 include/linux/usb/usbnet.h |    1 -
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 022c1e7..96f8a08 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -686,7 +686,6 @@ int usbnet_stop (struct net_device *net)
 	struct driver_info	*info = dev->driver_info;
 	int			retval;
 
-	clear_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_stop_queue (net);
 
 	netif_info(dev, ifdown, dev->net,
@@ -778,7 +777,6 @@ int usbnet_open (struct net_device *net)
 		}
 	}
 
-	set_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_start_queue (net);
 	netif_info(dev, ifup, dev->net,
 		   "open: enable queueing (rx %d, tx %d) mtu %d %s framing\n",
@@ -1542,7 +1540,7 @@ int usbnet_resume (struct usb_interface *intf)
 
 	if (!--dev->suspend_count) {
 		/* resume interrupt URBs */
-		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
+		if (dev->interrupt && (dev->net->flags & IFF_UP))
 			usb_submit_urb(dev->interrupt, GFP_NOIO);
 
 		spin_lock_irq(&dev->txq.lock);
@@ -1564,7 +1562,7 @@ int usbnet_resume (struct usb_interface *intf)
 		clear_bit(EVENT_DEV_ASLEEP, &dev->flags);
 		spin_unlock_irq(&dev->txq.lock);
 
-		if (test_bit(EVENT_DEV_OPEN, &dev->flags)) {
+		if (dev->net->flags & IFF_UP) {
 			if (!(dev->txq.qlen >= TX_QLEN(dev)))
 				netif_tx_wake_all_queues(dev->net);
 			tasklet_schedule (&dev->bh);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 76f4396..f15a729 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -68,7 +68,6 @@ struct usbnet {
 #		define EVENT_RX_PAUSED	5
 #		define EVENT_DEV_WAKING 6
 #		define EVENT_DEV_ASLEEP 7
-#		define EVENT_DEV_OPEN	8
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
