From: Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: [PATCH] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Thu, 23 Mar 2017 11:25:32 +1000
Message-ID: <1490232332-19274-1-git-send-email-gerg@linux-m68k.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
To: bjorn-yOkvZcmFvRU@public.gmane.org, oneukum-IBi9RG/b67k@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add support for the net stats64 counters to the usbnet core and then to
the qmi_wwan driver.

This is a strait forward addition of 64bit counters for RX and TX packets
and byte counts. It is done in the same style as for the other net drivers
that support stats64.

The bulk of the change is to the usbnet core. Then it is trivial to use
that in the qmi_wwan.c driver. It would be very simple to extend this
support to other usbnet based drivers.

The motivation to add this is that it is not particularly difficult to
get the RX and TX byte counts to wrap on 32bit platforms.

Signed-off-by: Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c |  1 +
 drivers/net/usb/usbnet.c   | 27 +++++++++++++++++++++++++++
 include/linux/usb/usbnet.h | 12 ++++++++++++
 3 files changed, 40 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 503a9f0..eb09e79 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -328,6 +328,7 @@ static int qmi_wwan_mac_addr(struct net_device *dev, void *p)
 	.ndo_change_mtu		= usbnet_change_mtu,
 	.ndo_set_mac_address	= qmi_wwan_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_get_stats64	= usbnet_get_stats64,
 };
 
 /* using a counter to merge subdriver requests with our own into a
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3de65ea..5dc0f15 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -330,6 +330,11 @@ void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 	dev->net->stats.rx_packets++;
 	dev->net->stats.rx_bytes += skb->len;
 
+	u64_stats_update_begin(&dev->stats.syncp);
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
+	u64_stats_update_end(&dev->stats.syncp);
+
 	netif_dbg(dev, rx_status, dev->net, "< rx, len %zu, type 0x%x\n",
 		  skb->len + sizeof (struct ethhdr), skb->protocol);
 	memset (skb->cb, 0, sizeof (struct skb_data));
@@ -980,6 +985,22 @@ int usbnet_set_settings (struct net_device *net, struct ethtool_cmd *cmd)
 }
 EXPORT_SYMBOL_GPL(usbnet_set_settings);
 
+void usbnet_get_stats64(struct net_device *net, struct rtnl_link_stats64 *stats)
+{
+	struct usbnet *dev = netdev_priv(net);
+	unsigned int start;
+
+	netdev_stats_to_stats64(stats, &net->stats);
+
+	do {
+		start = u64_stats_fetch_begin_irq(&dev->stats.syncp);
+		stats->rx_packets = dev->stats.rx_packets;
+		stats->rx_bytes = dev->stats.rx_bytes;
+		stats->tx_packets = dev->stats.tx_packets;
+		stats->tx_bytes = dev->stats.tx_bytes;
+	} while (u64_stats_fetch_retry_irq(&dev->stats.syncp, start));
+}
+
 u32 usbnet_get_link (struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
@@ -1213,6 +1234,11 @@ static void tx_complete (struct urb *urb)
 	if (urb->status == 0) {
 		dev->net->stats.tx_packets += entry->packets;
 		dev->net->stats.tx_bytes += entry->length;
+
+		u64_stats_update_begin(&dev->stats.syncp);
+		dev->stats.tx_packets += entry->packets;
+		dev->stats.tx_bytes += entry->length;
+		u64_stats_update_end(&dev->stats.syncp);
 	} else {
 		dev->net->stats.tx_errors++;
 
@@ -1657,6 +1683,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 	init_timer (&dev->delay);
 	mutex_init (&dev->phy_mutex);
 	mutex_init(&dev->interrupt_mutex);
+	u64_stats_init(&dev->stats.syncp);
 	dev->interrupt_count = 0;
 
 	dev->net = net;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 6e0ce8c..f381dd8 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -22,6 +22,14 @@
 #ifndef	__LINUX_USB_USBNET_H
 #define	__LINUX_USB_USBNET_H
 
+struct usbnet_stats64 {
+	struct u64_stats_sync	syncp;
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			tx_packets;
+	u64			tx_bytes;
+};
+
 /* interface from usbnet core to each USB networking link we handle */
 struct usbnet {
 	/* housekeeping */
@@ -64,6 +72,8 @@ struct usbnet {
 	struct usb_anchor	deferred;
 	struct tasklet_struct	bh;
 
+	struct usbnet_stats64	stats;
+
 	struct work_struct	kevent;
 	unsigned long		flags;
 #		define EVENT_TX_HALT	0
@@ -265,6 +275,8 @@ extern int usbnet_get_settings(struct net_device *net,
 			       struct ethtool_cmd *cmd);
 extern int usbnet_set_settings(struct net_device *net,
 			       struct ethtool_cmd *cmd);
+extern void usbnet_get_stats64(struct net_device *dev,
+			       struct rtnl_link_stats64 *stats);
 extern u32 usbnet_get_link(struct net_device *net);
 extern u32 usbnet_get_msglevel(struct net_device *);
 extern void usbnet_set_msglevel(struct net_device *, u32);
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
