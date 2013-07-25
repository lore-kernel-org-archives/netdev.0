From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 1/2] USBNET: centralize computing of max rx/tx qlen
Date: Thu, 25 Jul 2013 13:47:53 +0800
Message-ID: <1374731274-27415-2-git-send-email-ming.lei@canonical.com>
References: <1374731274-27415-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:56913 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab3GYFs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 01:48:26 -0400
In-Reply-To: <1374731274-27415-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch centralizes computing of max rx/tx qlen, because:

- RX_QLEN()/TX_QLEN() is called in hot path
- computing depends on device's usb speed, now we have ls/fs, hs, ss,
so more checks need to be involved
- in fact, max rx/tx qlen should not only depend on device USB
speed, but also depend on ethernet link speed, so we need to
consider that in future.
- if SG support is done, max tx qlen may need change too

Generally, hard_mtu and rx_urb_size are changed in bind(), reset()
and link_reset() callback, and change mtu network operation, this
patches introduces the API of usbnet_update_max_qlen(), and calls
it in above path.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/asix_devices.c |    3 +++
 drivers/net/usb/ax88179_178a.c |    3 +++
 drivers/net/usb/usbnet.c       |   45 +++++++++++++++++++++++++++++++++-------
 include/linux/usb/usbnet.h     |    3 +++
 4 files changed, 46 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index ad5d1e4..b96ad4f 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -778,6 +778,9 @@ static int ax88178_change_mtu(struct net_device *net, int new_mtu)
 	dev->hard_mtu = net->mtu + net->hard_header_len;
 	ax88178_set_mfb(dev);
 
+	/* max qlen depend on hard_mtu and rx_urb_size */
+	usbnet_update_max_qlen(dev);
+
 	return 0;
 }
 
diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 2bc87e3..5a468f3 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -688,6 +688,9 @@ static int ax88179_change_mtu(struct net_device *net, int new_mtu)
 				  2, 2, &tmp16);
 	}
 
+	/* max qlen depend on hard_mtu and rx_urb_size */
+	usbnet_update_max_qlen(dev);
+
 	return 0;
 }
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 06ee82f..d74de07 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -59,15 +59,13 @@
  * For high speed, each frame comfortably fits almost 36 max size
  * Ethernet packets (so queues should be bigger).
  *
- * REVISIT qlens should be members of 'struct usbnet'; the goal is to
- * let the USB host controller be busy for 5msec or more before an irq
- * is required, under load.  Jumbograms change the equation.
+ * The goal is to let the USB host controller be busy for 5msec or
+ * more before an irq is required, under load.  Jumbograms change
+ * the equation.
  */
-#define RX_MAX_QUEUE_MEMORY (60 * 1518)
-#define	RX_QLEN(dev) (((dev)->udev->speed == USB_SPEED_HIGH) ? \
-			(RX_MAX_QUEUE_MEMORY/(dev)->rx_urb_size) : 4)
-#define	TX_QLEN(dev) (((dev)->udev->speed == USB_SPEED_HIGH) ? \
-			(RX_MAX_QUEUE_MEMORY/(dev)->hard_mtu) : 4)
+#define	MAX_QUEUE_MEMORY	(60 * 1518)
+#define	RX_QLEN(dev)		((dev)->rx_qlen)
+#define	TX_QLEN(dev)		((dev)->tx_qlen)
 
 // reawaken network queue this soon after stopping; else watchdog barks
 #define TX_TIMEOUT_JIFFIES	(5*HZ)
@@ -347,6 +345,22 @@ void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(usbnet_skb_return);
 
+/* must be called if hard_mtu or rx_urb_size changed */
+void usbnet_update_max_qlen(struct usbnet *dev)
+{
+	enum usb_device_speed speed = dev->udev->speed;
+
+	switch (speed) {
+	case USB_SPEED_HIGH:
+		dev->rx_qlen = MAX_QUEUE_MEMORY / dev->rx_urb_size;
+		dev->tx_qlen = MAX_QUEUE_MEMORY / dev->hard_mtu;
+		break;
+	default:
+		dev->rx_qlen = dev->tx_qlen = 4;
+	}
+}
+EXPORT_SYMBOL_GPL(usbnet_update_max_qlen);
+
 
 /*-------------------------------------------------------------------------
  *
@@ -375,6 +389,9 @@ int usbnet_change_mtu (struct net_device *net, int new_mtu)
 			usbnet_unlink_rx_urbs(dev);
 	}
 
+	/* max qlen depend on hard_mtu and rx_urb_size */
+	usbnet_update_max_qlen(dev);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_change_mtu);
@@ -843,6 +860,9 @@ int usbnet_open (struct net_device *net)
 		goto done;
 	}
 
+	/* hard_mtu or rx_urb_size may change in reset() */
+	usbnet_update_max_qlen(dev);
+
 	// insist peer be connected
 	if (info->check_connect && (retval = info->check_connect (dev)) < 0) {
 		netif_dbg(dev, ifup, dev->net, "can't open; %d\n", retval);
@@ -927,6 +947,9 @@ int usbnet_set_settings (struct net_device *net, struct ethtool_cmd *cmd)
 	if (dev->driver_info->link_reset)
 		dev->driver_info->link_reset(dev);
 
+	/* hard_mtu or rx_urb_size may change in link_reset() */
+	usbnet_update_max_qlen(dev);
+
 	return retval;
 
 }
@@ -1020,6 +1043,9 @@ static void __handle_link_change(struct usbnet *dev)
 		tasklet_schedule(&dev->bh);
 	}
 
+	/* hard_mtu or rx_urb_size may change during link change */
+	usbnet_update_max_qlen(dev);
+
 	clear_bit(EVENT_LINK_CHANGE, &dev->flags);
 }
 
@@ -1599,6 +1625,9 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	if ((dev->driver_info->flags & FLAG_WWAN) != 0)
 		SET_NETDEV_DEVTYPE(net, &wwan_type);
 
+	/* initialize max rx_qlen and tx_qlen */
+	usbnet_update_max_qlen(dev);
+
 	status = register_netdev (net);
 	if (status)
 		goto out4;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index f18d641..8fbc008 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -34,6 +34,7 @@ struct usbnet {
 	struct mutex		phy_mutex;
 	unsigned char		suspend_count;
 	unsigned char		pkt_cnt, pkt_err;
+	unsigned short		rx_qlen, tx_qlen;
 
 	/* i/o info: pipes etc */
 	unsigned		in, out;
@@ -253,4 +254,6 @@ extern void usbnet_link_change(struct usbnet *, bool, bool);
 extern int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags);
 extern void usbnet_status_stop(struct usbnet *dev);
 
+extern void usbnet_update_max_qlen(struct usbnet *dev);
+
 #endif /* __LINUX_USB_USBNET_H */
-- 
1.7.9.5
