From: <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/1] netxen: add vlan accel support
Date: Fri, 5 Aug 2011 01:59:56 -0700
Message-ID: <1312534796-21033-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ameen.rahman@qlogic.com>,
	Rajesh K Borundia <rajeshk@dut4145.unminc.com>,
	Rajesh K Borundia <rajesh.borundia@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe001.messaging.microsoft.com ([213.199.154.139]:56181
	"EHLO DB3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755414Ab1HEJKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 05:10:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh K Borundia <rajeshk@dut4145.unminc.com>

o This increases performance on vlan interface.
o In case of fw reset, need to reprogram the ip addresses.
o Support LRO on vlan interface.

Signed-off-by: Rajesh K Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h      |    2 +
 drivers/net/netxen/netxen_nic_init.c |   22 ++++++++++++
 drivers/net/netxen/netxen_nic_main.c |   63 +++++++++++++++++++++++++++++----
 3 files changed, 79 insertions(+), 8 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index f744d29..b37cf4e 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -44,6 +44,7 @@
 #include <linux/timer.h>
 
 #include <linux/vmalloc.h>
+#include <linux/if_vlan.h>
 
 #include <asm/io.h>
 #include <asm/byteorder.h>
@@ -1212,6 +1213,7 @@ struct netxen_adapter {
 
 	u8 mac_addr[ETH_ALEN];
 
+	unsigned long vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct netxen_adapter_stats stats;
 
 	struct netxen_recv_context recv_ctx;
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index e8993a7..132d8fe 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -25,6 +25,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/delay.h>
+#include <linux/if_vlan.h>
 #include <linux/slab.h>
 #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
@@ -1558,7 +1559,9 @@ netxen_process_rcv(struct netxen_adapter *adapter,
 	struct netxen_rx_buffer *buffer;
 	struct sk_buff *skb;
 	struct nx_host_rds_ring *rds_ring;
+	struct ethhdr *eth_hdr;
 	int index, length, cksum, pkt_offset;
+	u16 vid = 0xffff;
 
 	if (unlikely(ring >= adapter->max_rds_rings))
 		return NULL;
@@ -1588,8 +1591,16 @@ netxen_process_rcv(struct netxen_adapter *adapter,
 	if (pkt_offset)
 		skb_pull(skb, pkt_offset);
 
+	if (!__vlan_get_tag(skb, &vid)) {
+		eth_hdr = (struct ethhdr *) skb->data;
+		memmove(skb->data + VLAN_HLEN, eth_hdr, ETH_ALEN * 2);
+		skb_pull(skb, VLAN_HLEN);
+	}
+
 	skb->protocol = eth_type_trans(skb, netdev);
 
+	if (vid != 0xffff)
+		__vlan_hwaccel_put_tag(skb, vid);
 	napi_gro_receive(&sds_ring->napi, skb);
 
 	adapter->stats.rx_pkts++;
@@ -1614,10 +1625,12 @@ netxen_process_lro(struct netxen_adapter *adapter,
 	struct nx_host_rds_ring *rds_ring;
 	struct iphdr *iph;
 	struct tcphdr *th;
+	struct ethhdr *eth_hdr;
 	bool push, timestamp;
 	int l2_hdr_offset, l4_hdr_offset;
 	int index;
 	u16 lro_length, length, data_offset;
+	u16 vid = 0xffff;
 	u32 seq_number;
 
 	if (unlikely(ring > adapter->max_rds_rings))
@@ -1650,6 +1663,13 @@ netxen_process_lro(struct netxen_adapter *adapter,
 	skb_put(skb, lro_length + data_offset);
 
 	skb_pull(skb, l2_hdr_offset);
+
+	if (!__vlan_get_tag(skb, &vid)) {
+		eth_hdr = (struct ethhdr *) skb->data;
+		memmove(skb->data + VLAN_HLEN, eth_hdr, ETH_ALEN * 2);
+		skb_pull(skb, VLAN_HLEN);
+	}
+
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	iph = (struct iphdr *)skb->data;
@@ -1664,6 +1684,8 @@ netxen_process_lro(struct netxen_adapter *adapter,
 
 	length = skb->len;
 
+	if (vid != 0xffff)
+		__vlan_hwaccel_put_tag(skb, vid);
 	netif_receive_skb(skb);
 
 	adapter->stats.lro_pkts++;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f574edf..a6d6860 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -91,7 +91,11 @@ static irqreturn_t netxen_intr(int irq, void *data);
 static irqreturn_t netxen_msi_intr(int irq, void *data);
 static irqreturn_t netxen_msix_intr(int irq, void *data);
 
-static void netxen_config_indev_addr(struct net_device *dev, unsigned long);
+static void netxen_restore_indev_addr(struct net_device *dev, unsigned long);
+#ifdef CONFIG_INET
+static void netxen_config_indev_addr(struct netxen_adapter *,
+				struct net_device *, unsigned long);
+#endif
 static struct rtnl_link_stats64 *netxen_nic_get_stats(struct net_device *dev,
 						      struct rtnl_link_stats64 *stats);
 static int netxen_nic_set_mac(struct net_device *netdev, void *p);
@@ -517,6 +521,25 @@ static int netxen_set_features(struct net_device *dev, u32 features)
 	return 0;
 }
 
+static void
+netxen_vlan_rx_add(struct net_device *netdev, u16 vid)
+{
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+	set_bit(vid, adapter->vlans);
+}
+
+static void
+netxen_vlan_rx_del(struct net_device *netdev, u16 vid)
+{
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+	struct net_device *dev;
+
+	dev = __vlan_find_dev_deep(netdev, vid);
+	if (dev)
+		netxen_config_indev_addr(adapter, dev, NETDEV_DOWN);
+	clear_bit(vid, adapter->vlans);
+}
+
 static const struct net_device_ops netxen_netdev_ops = {
 	.ndo_open	   = netxen_nic_open,
 	.ndo_stop	   = netxen_nic_close,
@@ -529,6 +552,8 @@ static const struct net_device_ops netxen_netdev_ops = {
 	.ndo_tx_timeout	   = netxen_tx_timeout,
 	.ndo_fix_features = netxen_fix_features,
 	.ndo_set_features = netxen_set_features,
+	.ndo_vlan_rx_add_vid	= netxen_vlan_rx_add,
+	.ndo_vlan_rx_kill_vid	= netxen_vlan_rx_del,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = netxen_nic_poll_controller,
 #endif
@@ -1259,6 +1284,9 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 	if (adapter->capabilities & NX_FW_CAPABILITY_FVLANTX)
 		netdev->hw_features |= NETIF_F_HW_VLAN_TX;
 
+	netdev->hw_features |= NETIF_F_HW_VLAN_RX;
+	netdev->hw_features |= NETIF_F_HW_VLAN_FILTER;
+
 	if (adapter->capabilities & NX_FW_CAPABILITY_HW_LRO)
 		netdev->hw_features |= NETIF_F_LRO;
 
@@ -1563,7 +1591,7 @@ static int netxen_nic_attach_func(struct pci_dev *pdev)
 		if (err)
 			goto err_out_detach;
 
-		netxen_config_indev_addr(netdev, NETDEV_UP);
+		netxen_restore_indev_addr(netdev, NETDEV_UP);
 	}
 
 	netif_device_attach(netdev);
@@ -2374,7 +2402,7 @@ netxen_attach_work(struct work_struct *work)
 			goto done;
 		}
 
-		netxen_config_indev_addr(netdev, NETDEV_UP);
+		netxen_restore_indev_addr(netdev, NETDEV_UP);
 	}
 
 	netif_device_attach(netdev);
@@ -2848,10 +2876,10 @@ netxen_destip_supported(struct netxen_adapter *adapter)
 }
 
 static void
-netxen_config_indev_addr(struct net_device *dev, unsigned long event)
+netxen_config_indev_addr(struct netxen_adapter *adapter,
+		struct net_device *dev, unsigned long event)
 {
 	struct in_device *indev;
-	struct netxen_adapter *adapter = netdev_priv(dev);
 
 	if (!netxen_destip_supported(adapter))
 		return;
@@ -2878,6 +2906,24 @@ netxen_config_indev_addr(struct net_device *dev, unsigned long event)
 	in_dev_put(indev);
 }
 
+static void
+netxen_restore_indev_addr(struct net_device *netdev, unsigned long event)
+
+{
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+	struct net_device *dev;
+	u16 vid;
+
+	netxen_config_indev_addr(adapter, netdev, event);
+
+	for_each_set_bit(vid, adapter->vlans, VLAN_N_VID) {
+		dev = __vlan_find_dev_deep(netdev, vid);
+		if (!dev)
+			continue;
+		netxen_config_indev_addr(adapter, dev, event);
+	}
+}
+
 static int netxen_netdev_event(struct notifier_block *this,
 				 unsigned long event, void *ptr)
 {
@@ -2904,7 +2950,7 @@ recheck:
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
 		goto done;
 
-	netxen_config_indev_addr(dev, event);
+	netxen_config_indev_addr(adapter, dev, event);
 done:
 	return NOTIFY_DONE;
 }
@@ -2921,7 +2967,7 @@ netxen_inetaddr_event(struct notifier_block *this,
 	dev = ifa->ifa_dev ? ifa->ifa_dev->dev : NULL;
 
 recheck:
-	if (dev == NULL || !netif_running(dev))
+	if (dev == NULL)
 		goto done;
 
 	if (dev->priv_flags & IFF_802_1Q_VLAN) {
@@ -2964,8 +3010,9 @@ static struct notifier_block netxen_inetaddr_cb = {
 };
 #else
 static void
-netxen_config_indev_addr(struct net_device *dev, unsigned long event)
+netxen_restore_indev_addr(struct net_device *dev, unsigned long event)
 { }
+static void
 #endif
 
 static struct pci_error_handlers netxen_err_handler = {
-- 
1.7.3.3


