From: Greg Ungerer <gerg@linux-m68k.org>
Subject: [PATCHv2] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Fri, 24 Mar 2017 11:27:30 +1000
Message-ID: <1490318850-23252-1-git-send-email-gerg@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        Greg Ungerer <gerg@linux-m68k.org>
To: bjorn@mork.no, oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out9.external.iinet.net.au ([203.59.1.226]:54906
        "EHLO icp-osb-irony-out9.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754132AbdCXB1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 21:27:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Signed-off-by: Greg Ungerer <gerg@linux-m68k.org>
---
 drivers/net/usb/qmi_wwan.c |  1 +
 drivers/net/usb/usbnet.c   | 28 ++++++++++++++++++++++++++++
 include/linux/usb/usbnet.h | 12 ++++++++++++
 3 files changed, 41 insertions(+)

v2: EXPORT symbol usbnet_get_stats64()
    rebase on top of net-next

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 8056745..db12a66 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -251,6 +251,7 @@ static int qmi_wwan_mac_addr(struct net_device *dev, void *p)
 	.ndo_change_mtu		= usbnet_change_mtu,
 	.ndo_set_mac_address	= qmi_wwan_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_get_stats64	= usbnet_get_stats64,
 };
 
 /* using a counter to merge subdriver requests with our own into a
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 13d4ec5..4499d89 100644
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
@@ -981,6 +986,23 @@ int usbnet_set_link_ksettings(struct net_device *net,
 }
 EXPORT_SYMBOL_GPL(usbnet_set_link_ksettings);
 
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
+EXPORT_SYMBOL_GPL(usbnet_get_stats64);
+
 u32 usbnet_get_link (struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
@@ -1214,6 +1236,11 @@ static void tx_complete (struct urb *urb)
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
 
@@ -1658,6 +1685,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 	init_timer (&dev->delay);
 	mutex_init (&dev->phy_mutex);
 	mutex_init(&dev->interrupt_mutex);
+	u64_stats_init(&dev->stats.syncp);
 	dev->interrupt_count = 0;
 
 	dev->net = net;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index e2b5691..d1501b8 100644
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
@@ -278,5 +288,7 @@ extern int usbnet_set_link_ksettings(struct net_device *net,
 extern void usbnet_status_stop(struct usbnet *dev);
 
 extern void usbnet_update_max_qlen(struct usbnet *dev);
+extern void usbnet_get_stats64(struct net_device *dev,
+			       struct rtnl_link_stats64 *stats);
 
 #endif /* __LINUX_USB_USBNET_H */
-- 
1.9.1
