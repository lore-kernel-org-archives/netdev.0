From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/4] tunnel: implement 64 bits statistics
Date: Thu, 12 Apr 2012 09:31:16 -0700
Message-ID: <20120412163142.441631834@vyatta.com>
References: <20120412163115.076119065@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:40223 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1762034Ab2DLQmD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 12:42:03 -0400
Content-Disposition: inline; filename=tunnel-64bit-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the per-cpu statistics kept for GRE, IPIP, and SIT tunnels
to use 64 bit statistics.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/ipip.h |    2 +
 net/ipv4/ip_gre.c  |   59 +++++++++++++++++++++++++++++++++++------------------
 net/ipv4/ipip.c    |   53 +++++++++++++++++++++++++++++++----------------
 net/ipv6/sit.c     |   52 ++++++++++++++++++++++++++++++----------------
 4 files changed, 111 insertions(+), 55 deletions(-)

--- a/include/net/ipip.h	2012-03-14 09:51:26.511060845 -0700
+++ b/include/net/ipip.h	2012-04-11 11:46:20.338815164 -0700
@@ -54,8 +54,10 @@ struct ip_tunnel_prl_entry {
 									\
 	err = ip_local_out(skb);					\
 	if (likely(net_xmit_eval(err) == 0)) {				\
+		u64_stats_update_begin(&(stats1)->syncp);		\
 		(stats1)->tx_bytes += pkt_len;				\
 		(stats1)->tx_packets++;					\
+		u64_stats_update_end(&(stats1)->syncp);			\
 	} else {							\
 		(stats2)->tx_errors++;					\
 		(stats2)->tx_aborted_errors++;				\
--- a/net/ipv4/ip_gre.c	2012-04-09 11:18:09.000000000 -0700
+++ b/net/ipv4/ip_gre.c	2012-04-11 11:46:20.338815164 -0700
@@ -169,30 +169,49 @@ struct ipgre_net {
 
 /* often modified stats are per cpu, other are shared (netdev->stats) */
 struct pcpu_tstats {
-	unsigned long	rx_packets;
-	unsigned long	rx_bytes;
-	unsigned long	tx_packets;
-	unsigned long	tx_bytes;
-} __attribute__((aligned(4*sizeof(unsigned long))));
+	u64	rx_packets;
+	u64	rx_bytes;
+	u64	tx_packets;
+	u64	tx_bytes;
+	struct u64_stats_sync	syncp;
+};
 
-static struct net_device_stats *ipgre_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *ipgre_get_stats64(struct net_device *dev,
+						   struct rtnl_link_stats64 *tot)
 {
-	struct pcpu_tstats sum = { 0 };
 	int i;
 
 	for_each_possible_cpu(i) {
 		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
+		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&tstats->syncp);
+			rx_packets = tstats->rx_packets;
+			tx_packets = tstats->tx_packets;
+			rx_bytes = tstats->rx_bytes;
+			tx_bytes = tstats->tx_bytes;
+		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
+
+		tot->rx_packets += rx_packets;
+		tot->tx_packets += tx_packets;
+		tot->rx_bytes   += rx_bytes;
+		tot->tx_bytes   += tx_bytes;
+	}
+
+	tot->multicast = dev->stats.multicast;
+	tot->rx_crc_errors = dev->stats.rx_crc_errors;
+	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
+	tot->rx_length_errors = dev->stats.rx_length_errors;
+	tot->rx_errors = dev->stats.rx_errors;
+	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
+	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
+	tot->tx_dropped = dev->stats.tx_dropped;
+	tot->tx_aborted_errors = dev->stats.tx_aborted_errors;
+	tot->tx_errors = dev->stats.tx_errors;
 
-		sum.rx_packets += tstats->rx_packets;
-		sum.rx_bytes   += tstats->rx_bytes;
-		sum.tx_packets += tstats->tx_packets;
-		sum.tx_bytes   += tstats->tx_bytes;
-	}
-	dev->stats.rx_packets = sum.rx_packets;
-	dev->stats.rx_bytes   = sum.rx_bytes;
-	dev->stats.tx_packets = sum.tx_packets;
-	dev->stats.tx_bytes   = sum.tx_bytes;
-	return &dev->stats;
+	return tot;
 }
 
 /* Given src, dst and key, find appropriate for input tunnel. */
@@ -672,8 +691,10 @@ static int ipgre_rcv(struct sk_buff *skb
 		}
 
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
+		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
+		u64_stats_update_end(&tstats->syncp);
 
 		__skb_tunnel_rx(skb, tunnel->dev);
 
@@ -1253,7 +1274,7 @@ static const struct net_device_ops ipgre
 	.ndo_start_xmit		= ipgre_tunnel_xmit,
 	.ndo_do_ioctl		= ipgre_tunnel_ioctl,
 	.ndo_change_mtu		= ipgre_tunnel_change_mtu,
-	.ndo_get_stats		= ipgre_get_stats,
+	.ndo_get_stats64	= ipgre_get_stats64,
 };
 
 static void ipgre_dev_free(struct net_device *dev)
@@ -1507,7 +1528,7 @@ static const struct net_device_ops ipgre
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= ipgre_tunnel_change_mtu,
-	.ndo_get_stats		= ipgre_get_stats,
+	.ndo_get_stats64	= ipgre_get_stats64,
 };
 
 static void ipgre_tap_setup(struct net_device *dev)
--- a/net/ipv4/ipip.c	2012-03-14 08:47:00.034845540 -0700
+++ b/net/ipv4/ipip.c	2012-04-11 11:46:20.338815164 -0700
@@ -144,30 +144,45 @@ static void ipip_dev_free(struct net_dev
 
 /* often modified stats are per cpu, other are shared (netdev->stats) */
 struct pcpu_tstats {
-	unsigned long	rx_packets;
-	unsigned long	rx_bytes;
-	unsigned long	tx_packets;
-	unsigned long	tx_bytes;
-} __attribute__((aligned(4*sizeof(unsigned long))));
+	u64	rx_packets;
+	u64	rx_bytes;
+	u64	tx_packets;
+	u64	tx_bytes;
+	struct u64_stats_sync	syncp;
+};
 
-static struct net_device_stats *ipip_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *ipip_get_stats64(struct net_device *dev,
+						  struct rtnl_link_stats64 *tot)
 {
-	struct pcpu_tstats sum = { 0 };
 	int i;
 
 	for_each_possible_cpu(i) {
 		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
+		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&tstats->syncp);
+			rx_packets = tstats->rx_packets;
+			tx_packets = tstats->tx_packets;
+			rx_bytes = tstats->rx_bytes;
+			tx_bytes = tstats->tx_bytes;
+		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
+
+		tot->rx_packets += rx_packets;
+		tot->tx_packets += tx_packets;
+		tot->rx_bytes   += rx_bytes;
+		tot->tx_bytes   += tx_bytes;
+	}
+
+	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
+	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
+	tot->tx_dropped = dev->stats.tx_dropped;
+	tot->tx_aborted_errors = dev->stats.tx_aborted_errors;
+	tot->tx_errors = dev->stats.tx_errors;
+	tot->collisions = dev->stats.collisions;
 
-		sum.rx_packets += tstats->rx_packets;
-		sum.rx_bytes   += tstats->rx_bytes;
-		sum.tx_packets += tstats->tx_packets;
-		sum.tx_bytes   += tstats->tx_bytes;
-	}
-	dev->stats.rx_packets = sum.rx_packets;
-	dev->stats.rx_bytes   = sum.rx_bytes;
-	dev->stats.tx_packets = sum.tx_packets;
-	dev->stats.tx_bytes   = sum.tx_bytes;
-	return &dev->stats;
+	return tot;
 }
 
 static struct ip_tunnel * ipip_tunnel_lookup(struct net *net,
@@ -404,8 +419,10 @@ static int ipip_rcv(struct sk_buff *skb)
 		skb->pkt_type = PACKET_HOST;
 
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
+		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
+		u64_stats_update_end(&tstats->syncp);
 
 		__skb_tunnel_rx(skb, tunnel->dev);
 
@@ -730,7 +747,7 @@ static const struct net_device_ops ipip_
 	.ndo_start_xmit	= ipip_tunnel_xmit,
 	.ndo_do_ioctl	= ipip_tunnel_ioctl,
 	.ndo_change_mtu	= ipip_tunnel_change_mtu,
-	.ndo_get_stats  = ipip_get_stats,
+	.ndo_get_stats64 = ipip_get_stats64,
 };
 
 static void ipip_dev_free(struct net_device *dev)
--- a/net/ipv6/sit.c	2012-04-09 11:18:09.685154426 -0700
+++ b/net/ipv6/sit.c	2012-04-11 11:46:20.338815164 -0700
@@ -87,31 +87,47 @@ struct sit_net {
 
 /* often modified stats are per cpu, other are shared (netdev->stats) */
 struct pcpu_tstats {
-	unsigned long	rx_packets;
-	unsigned long	rx_bytes;
-	unsigned long	tx_packets;
-	unsigned long	tx_bytes;
-} __attribute__((aligned(4*sizeof(unsigned long))));
+	u64	rx_packets;
+	u64	rx_bytes;
+	u64	tx_packets;
+	u64	tx_bytes;
+	struct u64_stats_sync	syncp;
+};
 
-static struct net_device_stats *ipip6_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *ipip6_get_stats64(struct net_device *dev,
+						   struct rtnl_link_stats64 *tot)
 {
-	struct pcpu_tstats sum = { 0 };
 	int i;
 
 	for_each_possible_cpu(i) {
 		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
+		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&tstats->syncp);
+			rx_packets = tstats->rx_packets;
+			tx_packets = tstats->tx_packets;
+			rx_bytes = tstats->rx_bytes;
+			tx_bytes = tstats->tx_bytes;
+		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
+
+		tot->rx_packets += rx_packets;
+		tot->tx_packets += tx_packets;
+		tot->rx_bytes   += rx_bytes;
+		tot->tx_bytes   += tx_bytes;
+	}
+
+	tot->rx_errors = dev->stats.rx_errors;
+	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
+	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
+	tot->tx_dropped = dev->stats.tx_dropped;
+	tot->tx_aborted_errors = dev->stats.tx_aborted_errors;
+	tot->tx_errors = dev->stats.tx_errors;
 
-		sum.rx_packets += tstats->rx_packets;
-		sum.rx_bytes   += tstats->rx_bytes;
-		sum.tx_packets += tstats->tx_packets;
-		sum.tx_bytes   += tstats->tx_bytes;
-	}
-	dev->stats.rx_packets = sum.rx_packets;
-	dev->stats.rx_bytes   = sum.rx_bytes;
-	dev->stats.tx_packets = sum.tx_packets;
-	dev->stats.tx_bytes   = sum.tx_bytes;
-	return &dev->stats;
+	return tot;
 }
+
 /*
  * Must be invoked with rcu_read_lock
  */
@@ -1126,7 +1142,7 @@ static const struct net_device_ops ipip6
 	.ndo_start_xmit	= ipip6_tunnel_xmit,
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
 	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
-	.ndo_get_stats	= ipip6_get_stats,
+	.ndo_get_stats64= ipip6_get_stats64,
 };
 
 static void ipip6_dev_free(struct net_device *dev)
