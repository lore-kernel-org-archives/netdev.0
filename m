From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: looking for testers for CDC EEM runtime power management
Date: Sat, 25 Dec 2010 14:29:29 +0100
Message-ID: <201012251429.29343.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this patch implements runtime power management for CDC EEM.
I lack the hardware and need testers.

	Regards
		Oliver

>From b9e2ecb3a81c122d37528af4283d9e2ebbb43d23 Mon Sep 17 00:00:00 2001
From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date: Sat, 25 Dec 2010 14:25:45 +0100
Subject: [PATCH] cdc_eem: runtime power management

This patch grants CDC EEM devices which request to be suspended
their wish.

Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
---
 drivers/net/usb/cdc_eem.c  |    2 ++
 drivers/net/usb/usbnet.c   |   20 ++++++++++++++++++++
 include/linux/usb/usbnet.h |    2 ++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 5f3b976..be319bd 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -245,6 +245,8 @@ static int eem_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			 *  - response complete: suggest N sec polling
 			 */
 			case 2:		/* Suspend hint */
+				usbnet_notify_idle(dev);
+				continue;
 			case 3:		/* Response hint */
 			case 4:		/* Response complete hint */
 				continue;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index c04d49e..95727a7 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1201,6 +1201,24 @@ static void usbnet_bh (unsigned long param)
 	}
 }
 
+/*-------------------------------------------------------------------------*/
+
+/*
+ * Some devices notify the host of an idle condition
+ * this makes use of this information
+ */
+
+void usbnet_notify_idle(struct usbnet *dev)
+{
+	int r;
+
+	if (!test_and_set_bit(EVENT_REP_IDLE, &dev->flags)) {
+		r = usb_autopm_get_interface_async(dev->intf);
+		if (r < 0)
+			clear_bit(EVENT_REP_IDLE, &dev->flags);
+	}
+}
+EXPORT_SYMBOL_GPL(usbnet_notify_idle);
 
 /*-------------------------------------------------------------------------
  *
@@ -1495,6 +1513,8 @@ int usbnet_resume (struct usb_interface *intf)
 		spin_unlock_irq(&dev->txq.lock);
 		if (!(dev->txq.qlen >= TX_QLEN(dev)))
 			netif_start_queue(dev->net);
+		if (test_and_clear_bit(EVENT_REP_IDLE, &dev->flags))
+			usb_autopm_get_interface_no_resume(intf);
 		tasklet_schedule (&dev->bh);
 	}
 	return 0;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 7ae27a4..1cb929a 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -68,6 +68,7 @@ struct usbnet {
 #		define EVENT_RX_PAUSED	5
 #		define EVENT_DEV_WAKING 6
 #		define EVENT_DEV_ASLEEP 7
+#		define EVENT_REP_IDLE	8
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
@@ -205,6 +206,7 @@ extern void usbnet_unlink_rx_urbs(struct usbnet *);
 extern void usbnet_pause_rx(struct usbnet *);
 extern void usbnet_resume_rx(struct usbnet *);
 extern void usbnet_purge_paused_rxq(struct usbnet *);
+extern void usbnet_notify_idle(struct usbnet *);
 
 extern int usbnet_get_settings(struct net_device *net,
 			       struct ethtool_cmd *cmd);
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
