From: Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: [PATCHv4] net: usbnet: support 64bit stats
Date: Mon,  3 Apr 2017 15:50:03 +1000
Message-ID: <1491198603-24160-1-git-send-email-gerg@linux-m68k.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
To: bjorn-yOkvZcmFvRU@public.gmane.org, oneukum-IBi9RG/b67k@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add support for the net stats64 counters to the usbnet core. With that
in place put the hooks into every usbnet driver to use it.

This is a strait forward addition of 64bit counters for RX and TX packet
and byte counts. It is done in the same style as for the other net drivers
that support stats64. Note that the other stats fields remain as 32bit
sized values (error counts, etc).

The motivation to add this is that it is not particularly difficult to
get the RX and TX byte counts to wrap on 32bit platforms.

Signed-off-by: Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
---
 drivers/net/usb/asix_devices.c    |  3 +++
 drivers/net/usb/ax88172a.c        |  1 +
 drivers/net/usb/ax88179_178a.c    |  1 +
 drivers/net/usb/cdc_mbim.c        |  1 +
 drivers/net/usb/cdc_ncm.c         |  1 +
 drivers/net/usb/dm9601.c          |  1 +
 drivers/net/usb/int51x1.c         |  1 +
 drivers/net/usb/mcs7830.c         |  1 +
 drivers/net/usb/qmi_wwan.c        |  1 +
 drivers/net/usb/rndis_host.c      |  1 +
 drivers/net/usb/sierra_net.c      |  1 +
 drivers/net/usb/smsc75xx.c        |  1 +
 drivers/net/usb/smsc95xx.c        |  1 +
 drivers/net/usb/sr9700.c          |  1 +
 drivers/net/usb/sr9800.c          |  1 +
 drivers/net/usb/usbnet.c          | 55 ++++++++++++++++++++++++++++++++++++---
 drivers/net/wireless/rndis_wlan.c |  1 +
 include/linux/usb/usbnet.h        |  4 +++
 18 files changed, 73 insertions(+), 4 deletions(-)

v2: EXPORT usbnet_get_stats64()
    rebase on top of net-next

v3: use percpu vars for stats64 counters

v4: update all usbnet drivers to use stats64

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 38456d0..a3aa0a2 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -206,6 +206,7 @@ static int ax88172_link_reset(struct usbnet *dev)
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= asix_ioctl,
@@ -591,6 +592,7 @@ static int ax88772a_hw_reset(struct usbnet *dev, int in_pm)
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address 	= asix_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= asix_ioctl,
@@ -1044,6 +1046,7 @@ static int ax88178_change_mtu(struct net_device *net, int new_mtu)
 	.ndo_stop		= usbnet_stop,
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address 	= asix_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= asix_set_multicast,
diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
index 6308386..501576f 100644
--- a/drivers/net/usb/ax88172a.c
+++ b/drivers/net/usb/ax88172a.c
@@ -143,6 +143,7 @@ static void ax88172a_remove_mdio(struct usbnet *dev)
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address	= asix_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= ax88172a_ioctl,
diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 4a0ae7c..51cf600 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -959,6 +959,7 @@ static int ax88179_set_mac_addr(struct net_device *net, void *p)
 	.ndo_stop		= usbnet_stop,
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_change_mtu		= ax88179_change_mtu,
 	.ndo_set_mac_address	= ax88179_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 3a98f37..a6b997c 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -100,6 +100,7 @@ static int cdc_mbim_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid
 	.ndo_stop             = usbnet_stop,
 	.ndo_start_xmit       = usbnet_start_xmit,
 	.ndo_tx_timeout       = usbnet_tx_timeout,
+	.ndo_get_stats64      = usbnet_get_stats64,
 	.ndo_change_mtu       = cdc_ncm_change_mtu,
 	.ndo_set_mac_address  = eth_mac_addr,
 	.ndo_validate_addr    = eth_validate_addr,
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index b6c1d3a..bb3f71f 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -753,6 +753,7 @@ int cdc_ncm_change_mtu(struct net_device *net, int new_mtu)
 	.ndo_stop	     = usbnet_stop,
 	.ndo_start_xmit	     = usbnet_start_xmit,
 	.ndo_tx_timeout	     = usbnet_tx_timeout,
+	.ndo_get_stats64     = usbnet_get_stats64,
 	.ndo_change_mtu	     = cdc_ncm_change_mtu,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr   = eth_validate_addr,
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index fea1b64..b91f92e 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -343,6 +343,7 @@ static int dm9601_set_mac_address(struct net_device *net, void *p)
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl 		= dm9601_ioctl,
 	.ndo_set_rx_mode	= dm9601_set_multicast,
diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
index 4ff70b2..5a43b77 100644
--- a/drivers/net/usb/int51x1.c
+++ b/drivers/net/usb/int51x1.c
@@ -144,6 +144,7 @@ static void int51x1_set_multicast(struct net_device *netdev)
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= int51x1_set_multicast,
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 5771ff2..5a47e55 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -475,6 +475,7 @@ static void mcs7830_get_regs(struct net_device *net, struct ethtool_regs *regs,
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl 		= mcs7830_ioctl,
 	.ndo_set_rx_mode	= mcs7830_set_multicast,
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 629fe64..adbed26 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -542,6 +542,7 @@ static int qmi_wwan_mac_addr(struct net_device *dev, void *p)
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address	= qmi_wwan_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index c5b2113..e96e2e5 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -291,6 +291,7 @@ static int rndis_query(struct usbnet *dev, struct usb_interface *intf,
 	.ndo_stop		= usbnet_stop,
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index c8f60b8..2110ab3 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -199,6 +199,7 @@ struct lsi_umts_dual {
 	.ndo_start_xmit         = usbnet_start_xmit,
 	.ndo_tx_timeout         = usbnet_tx_timeout,
 	.ndo_change_mtu         = usbnet_change_mtu,
+	.ndo_get_stats64        = usbnet_get_stats64,
 	.ndo_set_mac_address    = eth_mac_addr,
 	.ndo_validate_addr      = eth_validate_addr,
 };
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 1ab0ff4..1ce01db 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1381,6 +1381,7 @@ static int smsc75xx_reset(struct usbnet *dev)
 	.ndo_stop		= usbnet_stop,
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_change_mtu		= smsc75xx_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 4a8bf96..c2f67ce 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1248,6 +1248,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl 		= smsc95xx_ioctl,
diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
index 950a3a9..317287f 100644
--- a/drivers/net/usb/sr9700.c
+++ b/drivers/net/usb/sr9700.c
@@ -308,6 +308,7 @@ static int sr9700_set_mac_address(struct net_device *netdev, void *p)
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= sr9700_ioctl,
 	.ndo_set_rx_mode	= sr9700_set_multicast,
diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index a696b62..9277a0f 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -679,6 +679,7 @@ static int sr9800_reset(struct usbnet *dev)
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address	= sr_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= sr_ioctl,
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 13d4ec5..9890656 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -316,6 +316,7 @@ static void __usbnet_status_stop_force(struct usbnet *dev)
  */
 void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 {
+	struct pcpu_sw_netstats *stats64 = this_cpu_ptr(dev->stats64);
 	int	status;
 
 	if (test_bit(EVENT_RX_PAUSED, &dev->flags)) {
@@ -327,8 +328,10 @@ void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 	if (skb->protocol == 0)
 		skb->protocol = eth_type_trans (skb, dev->net);
 
-	dev->net->stats.rx_packets++;
-	dev->net->stats.rx_bytes += skb->len;
+	u64_stats_update_begin(&stats64->syncp);
+	stats64->rx_packets++;
+	stats64->rx_bytes += skb->len;
+	u64_stats_update_end(&stats64->syncp);
 
 	netif_dbg(dev, rx_status, dev->net, "< rx, len %zu, type 0x%x\n",
 		  skb->len + sizeof (struct ethhdr), skb->protocol);
@@ -981,6 +984,37 @@ int usbnet_set_link_ksettings(struct net_device *net,
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
@@ -1212,8 +1246,12 @@ static void tx_complete (struct urb *urb)
 	struct usbnet		*dev = entry->dev;
 
 	if (urb->status == 0) {
-		dev->net->stats.tx_packets += entry->packets;
-		dev->net->stats.tx_bytes += entry->length;
+		struct pcpu_sw_netstats *stats64 = this_cpu_ptr(dev->stats64);
+
+		u64_stats_update_begin(&stats64->syncp);
+		stats64->tx_packets += entry->packets;
+		stats64->tx_bytes += entry->length;
+		u64_stats_update_end(&stats64->syncp);
 	} else {
 		dev->net->stats.tx_errors++;
 
@@ -1570,6 +1608,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 	usb_free_urb(dev->interrupt);
 	kfree(dev->padding_pkt);
 
+	free_percpu(dev->stats64);
 	free_netdev(net);
 }
 EXPORT_SYMBOL_GPL(usbnet_disconnect);
@@ -1581,6 +1620,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_set_rx_mode	= usbnet_set_rx_mode,
 	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
@@ -1642,6 +1682,11 @@ void usbnet_disconnect (struct usb_interface *intf)
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
@@ -1781,6 +1826,8 @@ void usbnet_disconnect (struct usb_interface *intf)
 	 */
 	cancel_work_sync(&dev->kevent);
 	del_timer_sync(&dev->delay);
+	free_percpu(dev->stats64);
+out0:
 	free_netdev(net);
 out:
 	return status;
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 785334f..3b68eaf 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -3392,6 +3392,7 @@ static int bcm4320b_early_init(struct usbnet *usbdev)
 	.ndo_stop		= usbnet_stop,
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_get_stats64	= usbnet_get_stats64,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= rndis_wlan_set_multicast_list,
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
