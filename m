From: Greg Ungerer <gerg@linux-m68k.org>
Subject: [PATCHv3] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Fri, 31 Mar 2017 16:26:01 +1000
Message-ID: <1490941561-20502-1-git-send-email-gerg@linux-m68k.org>
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        Greg Ungerer <gerg@linux-m68k.org>
To: bjorn@mork.no, oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out5.external.iinet.net.au ([203.59.1.221]:37530
        "EHLO icp-osb-irony-out5.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752898AbdCaG0I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 02:26:08 -0400
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

Note that the old 32bit stats counters are still incremented as well -
to cater for other driver users of the usbnet core. When all users are
upgraded to use 64bit stats we can remove the code to increment those.

The motivation to add this is that it is not particularly difficult to
get the RX and TX byte counts to wrap on 32bit platforms.

Signed-off-by: Greg Ungerer <gerg@linux-m68k.org>
---
 drivers/net/usb/qmi_wwan.c |  1 +
 drivers/net/usb/usbnet.c   | 52 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/usb/usbnet.h |  4 ++++
 3 files changed, 57 insertions(+)

v2: EXPORT usbnet_get_stats64()
    rebase on top of net-next

v3: use percpu vars for stats64 counters

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 629fe64..dd2b65e 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -544,6 +544,7 @@ static int qmi_wwan_mac_addr(struct net_device *dev, void *p)
 	.ndo_change_mtu		= usbnet_change_mtu,
 	.ndo_set_mac_address	= qmi_wwan_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_get_stats64	= usbnet_get_stats64,
 };
 
 /* using a counter to merge subdriver requests with our own into a
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 13d4ec5..6618a67 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -316,6 +316,7 @@ static void __usbnet_status_stop_force(struct usbnet *dev)
  */
 void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 {
+	struct pcpu_sw_netstats *stats64 = this_cpu_ptr(dev->stats64);
 	int	status;
 
 	if (test_bit(EVENT_RX_PAUSED, &dev->flags)) {
@@ -330,6 +331,11 @@ void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 	dev->net->stats.rx_packets++;
 	dev->net->stats.rx_bytes += skb->len;
 
+	u64_stats_update_begin(&stats64->syncp);
+	stats64->rx_packets++;
+	stats64->rx_bytes += skb->len;
+	u64_stats_update_end(&stats64->syncp);
+
 	netif_dbg(dev, rx_status, dev->net, "< rx, len %zu, type 0x%x\n",
 		  skb->len + sizeof (struct ethhdr), skb->protocol);
 	memset (skb->cb, 0, sizeof (struct skb_data));
@@ -981,6 +987,37 @@ int usbnet_set_link_ksettings(struct net_device *net,
 }
 EXPORT_SYMBOL_GPL(usbnet_set_link_ksettings);
 
+void usbnet_get_stats64(struct net_device *net, struct rtnl_link_stats64 *stats)
+{
+	struct usbnet *dev = netdev_priv(net);
+	unsigned int start;
+	int cpu;
+
+	netdev_stats_to_stats64(stats, &net->stats);
+
+	for_each_possible_cpu(cpu) {
+		struct pcpu_sw_netstats *stats64;
+		u64 rx_packets, rx_bytes;
+		u64 tx_packets, tx_bytes;
+
+		stats64 = per_cpu_ptr(dev->stats64, cpu);
+
+		do {
+			start = u64_stats_fetch_begin_irq(&stats64->syncp);
+			rx_packets = stats64->rx_packets;
+			rx_bytes = stats64->rx_bytes;
+			tx_packets = stats64->tx_packets;
+			tx_bytes = stats64->tx_bytes;
+		} while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
+
+		stats->rx_packets += rx_packets;
+		stats->rx_bytes += rx_bytes;
+		stats->tx_packets += tx_packets;
+		stats->tx_bytes += tx_bytes;
+	}
+}
+EXPORT_SYMBOL_GPL(usbnet_get_stats64);
+
 u32 usbnet_get_link (struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
@@ -1212,8 +1249,15 @@ static void tx_complete (struct urb *urb)
 	struct usbnet		*dev = entry->dev;
 
 	if (urb->status == 0) {
+		struct pcpu_sw_netstats *stats64 = this_cpu_ptr(dev->stats64);
+
 		dev->net->stats.tx_packets += entry->packets;
 		dev->net->stats.tx_bytes += entry->length;
+
+		u64_stats_update_begin(&stats64->syncp);
+		stats64->tx_packets += entry->packets;
+		stats64->tx_bytes += entry->length;
+		u64_stats_update_end(&stats64->syncp);
 	} else {
 		dev->net->stats.tx_errors++;
 
@@ -1570,6 +1614,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 	usb_free_urb(dev->interrupt);
 	kfree(dev->padding_pkt);
 
+	free_percpu(dev->stats64);
 	free_netdev(net);
 }
 EXPORT_SYMBOL_GPL(usbnet_disconnect);
@@ -1642,6 +1687,11 @@ void usbnet_disconnect (struct usb_interface *intf)
 	dev->intf = udev;
 	dev->driver_info = info;
 	dev->driver_name = name;
+
+	dev->stats64 = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
+	if (!dev->stats64)
+		goto out0;
+
 	dev->msg_enable = netif_msg_init (msg_level, NETIF_MSG_DRV
 				| NETIF_MSG_PROBE | NETIF_MSG_LINK);
 	init_waitqueue_head(&dev->wait);
@@ -1781,6 +1831,8 @@ void usbnet_disconnect (struct usb_interface *intf)
 	 */
 	cancel_work_sync(&dev->kevent);
 	del_timer_sync(&dev->delay);
+	free_percpu(dev->stats64);
+out0:
 	free_netdev(net);
 out:
 	return status;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index e2b5691..7dffa56 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -64,6 +64,8 @@ struct usbnet {
 	struct usb_anchor	deferred;
 	struct tasklet_struct	bh;
 
+	struct pcpu_sw_netstats __percpu *stats64;
+
 	struct work_struct	kevent;
 	unsigned long		flags;
 #		define EVENT_TX_HALT	0
@@ -278,5 +280,7 @@ extern int usbnet_set_link_ksettings(struct net_device *net,
 extern void usbnet_status_stop(struct usbnet *dev);
 
 extern void usbnet_update_max_qlen(struct usbnet *dev);
+extern void usbnet_get_stats64(struct net_device *dev,
+			       struct rtnl_link_stats64 *stats);
 
 #endif /* __LINUX_USB_USBNET_H */
-- 
1.9.1
