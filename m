From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH]  bridge: per-cpu packet statistics
Date: Mon, 1 Mar 2010 16:16:58 -0800
Message-ID: <20100301161658.5a61143b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49774 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415Ab0CBARG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 19:17:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The shared packet statistics are a potential source of slow down
on bridged traffic. Convert to per-cpu array, but only keep those
statistics which change per-packet.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---

 net/bridge/br_device.c  |   43 ++++++++++++++++++++++++++++++++++++++-----
 net/bridge/br_if.c      |    6 ++++++
 net/bridge/br_input.c   |    5 +++--
 net/bridge/br_private.h |    8 ++++++++
 4 files changed, 55 insertions(+), 7 deletions(-)

--- a/net/bridge/br_device.c	2010-03-01 08:22:23.476657998 -0800
+++ b/net/bridge/br_device.c	2010-03-01 15:31:36.737227465 -0800
@@ -26,11 +26,12 @@ netdev_tx_t br_dev_xmit(struct sk_buff *
 	const unsigned char *dest = skb->data;
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
+	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
 
-	BR_INPUT_SKB_CB(skb)->brdev = dev;
+	brstats->tx_packets++;
+	brstats->tx_bytes += skb->len;
 
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
+	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
@@ -81,6 +82,28 @@ static int br_dev_stop(struct net_device
 	return 0;
 }
 
+static struct net_device_stats *br_get_stats(struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	unsigned int cpu;
+
+	stats->tx_bytes = stats->tx_packets = 0;
+	stats->rx_bytes = stats->rx_packets = 0;
+
+	for_each_online_cpu(cpu) {
+		const struct br_cpu_netstats *bstats
+			= per_cpu_ptr(br->stats, cpu);
+
+		stats->tx_bytes   += bstats->tx_bytes;
+		stats->tx_packets += bstats->tx_packets;
+		stats->rx_bytes   += bstats->rx_bytes;
+		stats->rx_packets += bstats->rx_packets;
+	}
+
+	return stats;
+}
+
 static int br_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct net_bridge *br = netdev_priv(dev);
@@ -180,19 +203,27 @@ static const struct net_device_ops br_ne
 	.ndo_open		 = br_dev_open,
 	.ndo_stop		 = br_dev_stop,
 	.ndo_start_xmit		 = br_dev_xmit,
+	.ndo_get_stats		 = br_get_stats,
 	.ndo_set_mac_address	 = br_set_mac_address,
 	.ndo_set_multicast_list	 = br_dev_set_multicast_list,
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
 };
 
+static void br_dev_free(struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	free_percpu(br->stats);
+}
+
 void br_dev_setup(struct net_device *dev)
 {
 	random_ether_addr(dev->dev_addr);
 	ether_setup(dev);
 
 	dev->netdev_ops = &br_netdev_ops;
-	dev->destructor = free_netdev;
+	dev->destructor = br_dev_free;
 	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
 	dev->tx_queue_len = 0;
 	dev->priv_flags = IFF_EBRIDGE;
--- a/net/bridge/br_if.c	2010-03-01 08:22:23.476657998 -0800
+++ b/net/bridge/br_if.c	2010-03-01 15:30:47.733227819 -0800
@@ -185,6 +185,12 @@ static struct net_device *new_bridge_dev
 	br = netdev_priv(dev);
 	br->dev = dev;
 
+	br->stats = alloc_percpu(sizeof(struct br_cpu_netstats));
+	if (!br->stats) {
+		free_netdev(dev);
+		return NULL;
+	}
+
 	spin_lock_init(&br->lock);
 	INIT_LIST_HEAD(&br->port_list);
 	spin_lock_init(&br->hash_lock);
--- a/net/bridge/br_input.c	2010-03-01 08:22:23.476657998 -0800
+++ b/net/bridge/br_input.c	2010-03-01 15:32:45.882471626 -0800
@@ -23,9 +23,11 @@ const u8 br_group_address[ETH_ALEN] = { 
 static int br_pass_frame_up(struct sk_buff *skb)
 {
 	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
+	struct net_bridge *br = netdev_priv(brdev);
+	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
 
-	brdev->stats.rx_packets++;
-	brdev->stats.rx_bytes += skb->len;
+	brstats->rx_packets++;
+	brstats->rx_bytes += skb->len;
 
 	indev = skb->dev;
 	skb->dev = brdev;
--- a/net/bridge/br_private.h	2010-03-01 08:22:23.476657998 -0800
+++ b/net/bridge/br_private.h	2010-03-01 15:31:03.437228864 -0800
@@ -135,6 +135,14 @@ struct net_bridge
 	spinlock_t			lock;
 	struct list_head		port_list;
 	struct net_device		*dev;
+
+	struct br_cpu_netstats __percpu {
+		unsigned long	rx_packets;
+		unsigned long	tx_packets;
+		unsigned long	rx_bytes;
+		unsigned long	tx_bytes;
+	} *stats;
+
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 	unsigned long			feature_mask;
