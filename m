From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH]  bridge: per-cpu packet statistics (v2)
Date: Tue, 2 Mar 2010 09:58:31 -0800
Message-ID: <20100302095831.151c8bb5@nehalam>
References: <20100301161658.5a61143b@nehalam>
	<1267520579.2964.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37493 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752738Ab0CBR64 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 12:58:56 -0500
In-Reply-To: <1267520579.2964.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The shared packet statistics are a potential source of slow down
on bridged traffic. Convert to per-cpu array, but only keep those
statistics which change per-packet.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Take Eric's bug fix changes. But keep the per cpu transmit
per cpu statistics.  There is no point in going multiqueue for
a pseudo-interface which is lockless and queue less.

 net/bridge/br_device.c  |   43 ++++++++++++++++++++++++++++++++++++++-----
 net/bridge/br_if.c      |    6 ++++++
 net/bridge/br_input.c   |    5 +++--
 net/bridge/br_private.h |    8 ++++++++
 4 files changed, 55 insertions(+), 7 deletions(-)

--- a/net/bridge/br_device.c	2010-03-02 09:26:23.208191713 -0800
+++ b/net/bridge/br_device.c	2010-03-02 09:29:38.811818410 -0800
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
@@ -81,6 +82,31 @@ static int br_dev_stop(struct net_device
 	return 0;
 }
 
+static struct net_device_stats *br_get_stats(struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct br_cpu_netstats sum = { 0 };
+	unsigned int cpu;
+
+	for_each_possible_cpu(cpu) {
+		const struct br_cpu_netstats *bstats
+			= per_cpu_ptr(br->stats, cpu);
+
+		sum.tx_bytes   += bstats->tx_bytes;
+		sum.tx_packets += bstats->tx_packets;
+		sum.rx_bytes   += bstats->rx_bytes;
+		sum.rx_packets += bstats->rx_packets;
+	}
+
+	stats->tx_bytes   = sum.tx_bytes;
+	stats->tx_packets = sum.tx_packets;
+	stats->rx_bytes   = sum.rx_bytes;
+	stats->rx_packets = sum.rx_packets;
+
+	return stats;
+}
+
 static int br_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct net_bridge *br = netdev_priv(dev);
@@ -180,19 +206,28 @@ static const struct net_device_ops br_ne
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
+	free_netdev(dev);
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
--- a/net/bridge/br_if.c	2010-03-02 09:26:23.188192219 -0800
+++ b/net/bridge/br_if.c	2010-03-02 09:31:19.801199305 -0800
@@ -185,6 +185,12 @@ static struct net_device *new_bridge_dev
 	br = netdev_priv(dev);
 	br->dev = dev;
 
+	br->stats = alloc_percpu(struct br_cpu_netstats);
+	if (!br->stats) {
+		free_netdev(dev);
+		return NULL;
+	}
+
 	spin_lock_init(&br->lock);
 	INIT_LIST_HEAD(&br->port_list);
 	spin_lock_init(&br->hash_lock);
--- a/net/bridge/br_input.c	2010-03-02 09:26:23.196192436 -0800
+++ b/net/bridge/br_input.c	2010-03-02 09:27:04.424067504 -0800
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
--- a/net/bridge/br_private.h	2010-03-02 09:26:23.180193181 -0800
+++ b/net/bridge/br_private.h	2010-03-02 09:27:04.424067504 -0800
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
