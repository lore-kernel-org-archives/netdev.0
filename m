From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 6/6] tunnels: Use IP Tunnel stats APIs.
Date: Wed, 13 Mar 2013 15:48:50 -0700
Message-ID: <1363214930-3417-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:48143 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934342Ab3CMWt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:49:29 -0400
Received: by mail-pb0-f70.google.com with SMTP id un1so2787151pbc.5
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 15:49:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use common function to calculate rtnl_link_stats64 stats.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/Kconfig   |    1 +
 net/ipv4/ip_vti.c  |   40 +---------------------------------------
 net/ipv6/Kconfig   |    2 ++
 net/ipv6/ip6_gre.c |   42 +-----------------------------------------
 net/ipv6/sit.c     |   37 +------------------------------------
 5 files changed, 6 insertions(+), 116 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 053b53e..8603ca8 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -319,6 +319,7 @@ config SYN_COOKIES
 config NET_IPVTI
 	tristate "Virtual (secure) IP: tunneling"
 	select INET_TUNNEL
+	select NET_IP_TUNNEL
 	depends on INET_XFRM_MODE_TUNNEL
 	---help---
 	  Tunneling means encapsulating data of one protocol type within
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 6a628fb..9d2bdb2 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -82,44 +82,6 @@ static int vti_tunnel_bind_dev(struct net_device *dev);
 } while (0)
 
 
-static struct rtnl_link_stats64 *vti_get_stats64(struct net_device *dev,
-						 struct rtnl_link_stats64 *tot)
-{
-	int i;
-
-	for_each_possible_cpu(i) {
-		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
-		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
-		unsigned int start;
-
-		do {
-			start = u64_stats_fetch_begin_bh(&tstats->syncp);
-			rx_packets = tstats->rx_packets;
-			tx_packets = tstats->tx_packets;
-			rx_bytes = tstats->rx_bytes;
-			tx_bytes = tstats->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
-
-		tot->rx_packets += rx_packets;
-		tot->tx_packets += tx_packets;
-		tot->rx_bytes   += rx_bytes;
-		tot->tx_bytes   += tx_bytes;
-	}
-
-	tot->multicast = dev->stats.multicast;
-	tot->rx_crc_errors = dev->stats.rx_crc_errors;
-	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
-	tot->rx_length_errors = dev->stats.rx_length_errors;
-	tot->rx_errors = dev->stats.rx_errors;
-	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
-	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
-	tot->tx_dropped = dev->stats.tx_dropped;
-	tot->tx_aborted_errors = dev->stats.tx_aborted_errors;
-	tot->tx_errors = dev->stats.tx_errors;
-
-	return tot;
-}
-
 static struct ip_tunnel *vti_tunnel_lookup(struct net *net,
 					   __be32 remote, __be32 local)
 {
@@ -597,7 +559,7 @@ static const struct net_device_ops vti_netdev_ops = {
 	.ndo_start_xmit	= vti_tunnel_xmit,
 	.ndo_do_ioctl	= vti_tunnel_ioctl,
 	.ndo_change_mtu	= vti_tunnel_change_mtu,
-	.ndo_get_stats64 = vti_get_stats64,
+	.ndo_get_stats64 = ip_tunnel_get_stats64,
 };
 
 static void vti_dev_free(struct net_device *dev)
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index ed0b9e2..11b13ea 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -156,6 +156,7 @@ config INET6_XFRM_MODE_ROUTEOPTIMIZATION
 config IPV6_SIT
 	tristate "IPv6: IPv6-in-IPv4 tunnel (SIT driver)"
 	select INET_TUNNEL
+	select NET_IP_TUNNEL
 	select IPV6_NDISC_NODETYPE
 	default y
 	---help---
@@ -201,6 +202,7 @@ config IPV6_TUNNEL
 config IPV6_GRE
 	tristate "IPv6: GRE tunnel"
 	select IPV6_TUNNEL
+	select NET_IP_TUNNEL
 	---help---
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index af4a5e2..499a545 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -111,46 +111,6 @@ static u32 HASH_ADDR(const struct in6_addr *addr)
 #define tunnels_l	tunnels[1]
 #define tunnels_wc	tunnels[0]
 
-static struct rtnl_link_stats64 *ip6gre_get_stats64(struct net_device *dev,
-		struct rtnl_link_stats64 *tot)
-{
-	int i;
-
-	for_each_possible_cpu(i) {
-		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
-		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
-		unsigned int start;
-
-		do {
-			start = u64_stats_fetch_begin_bh(&tstats->syncp);
-			rx_packets = tstats->rx_packets;
-			tx_packets = tstats->tx_packets;
-			rx_bytes = tstats->rx_bytes;
-			tx_bytes = tstats->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
-
-		tot->rx_packets += rx_packets;
-		tot->tx_packets += tx_packets;
-		tot->rx_bytes   += rx_bytes;
-		tot->tx_bytes   += tx_bytes;
-	}
-
-	tot->multicast = dev->stats.multicast;
-	tot->rx_crc_errors = dev->stats.rx_crc_errors;
-	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
-	tot->rx_length_errors = dev->stats.rx_length_errors;
-	tot->rx_frame_errors = dev->stats.rx_frame_errors;
-	tot->rx_errors = dev->stats.rx_errors;
-
-	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
-	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
-	tot->tx_dropped = dev->stats.tx_dropped;
-	tot->tx_aborted_errors = dev->stats.tx_aborted_errors;
-	tot->tx_errors = dev->stats.tx_errors;
-
-	return tot;
-}
-
 /* Given src, dst and key, find appropriate for input tunnel. */
 
 static struct ip6_tnl *ip6gre_tunnel_lookup(struct net_device *dev,
@@ -1257,7 +1217,7 @@ static const struct net_device_ops ip6gre_netdev_ops = {
 	.ndo_start_xmit		= ip6gre_tunnel_xmit,
 	.ndo_do_ioctl		= ip6gre_tunnel_ioctl,
 	.ndo_change_mtu		= ip6gre_tunnel_change_mtu,
-	.ndo_get_stats64	= ip6gre_get_stats64,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
 };
 
 static void ip6gre_dev_free(struct net_device *dev)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index ee4fc57..35f28d0 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -87,41 +87,6 @@ struct sit_net {
 	struct net_device *fb_tunnel_dev;
 };
 
-static struct rtnl_link_stats64 *ipip6_get_stats64(struct net_device *dev,
-						   struct rtnl_link_stats64 *tot)
-{
-	int i;
-
-	for_each_possible_cpu(i) {
-		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
-		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
-		unsigned int start;
-
-		do {
-			start = u64_stats_fetch_begin_bh(&tstats->syncp);
-			rx_packets = tstats->rx_packets;
-			tx_packets = tstats->tx_packets;
-			rx_bytes = tstats->rx_bytes;
-			tx_bytes = tstats->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
-
-		tot->rx_packets += rx_packets;
-		tot->tx_packets += tx_packets;
-		tot->rx_bytes   += rx_bytes;
-		tot->tx_bytes   += tx_bytes;
-	}
-
-	tot->rx_errors = dev->stats.rx_errors;
-	tot->rx_frame_errors = dev->stats.rx_frame_errors;
-	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
-	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
-	tot->tx_dropped = dev->stats.tx_dropped;
-	tot->tx_aborted_errors = dev->stats.tx_aborted_errors;
-	tot->tx_errors = dev->stats.tx_errors;
-
-	return tot;
-}
-
 /*
  * Must be invoked with rcu_read_lock
  */
@@ -1202,7 +1167,7 @@ static const struct net_device_ops ipip6_netdev_ops = {
 	.ndo_start_xmit	= ipip6_tunnel_xmit,
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
 	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
-	.ndo_get_stats64= ipip6_get_stats64,
+	.ndo_get_stats64 = ip_tunnel_get_stats64,
 };
 
 static void ipip6_dev_free(struct net_device *dev)
-- 
1.7.1
