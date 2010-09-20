From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: rx_dropped accounting
Date: Mon, 20 Sep 2010 12:12:11 +0200
Message-ID: <1284977531.3420.137.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37538 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755570Ab0ITKMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 06:12:15 -0400
Received: by wyf22 with SMTP id 22so4130293wyf.19
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 03:12:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under load, netif_rx() can drop incoming packets but administrators dont
have a chance to spot which device needs some tuning (RPS activation for
example)

This patch adds rx_dropped accounting in vlans and tunnels.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan.h      |    2 ++
 net/8021q/vlan_dev.c  |    9 +++++++--
 net/ipv4/ip_gre.c     |    6 ++++--
 net/ipv4/ipip.c       |    5 ++++-
 net/ipv6/ip6_tunnel.c |    5 ++++-
 net/ipv6/ip6mr.c      |    4 +++-
 net/ipv6/sit.c        |    5 ++++-
 7 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 8d9503a..b26ce34 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -25,6 +25,7 @@ struct vlan_priority_tci_mapping {
  *	@rx_multicast: number of received multicast packets
  *	@syncp: synchronization point for 64bit counters
  *	@rx_errors: number of errors
+ *	@rx_dropped: number of dropped packets
  */
 struct vlan_rx_stats {
 	u64			rx_packets;
@@ -32,6 +33,7 @@ struct vlan_rx_stats {
 	u64			rx_multicast;
 	struct u64_stats_sync	syncp;
 	unsigned long		rx_errors;
+	unsigned long		rx_dropped;
 };
 
 /**
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 3bccdd1..94a1fed 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -225,7 +225,10 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	netif_rx(skb);
+	if (unlikely(netif_rx(skb) == NET_RX_DROP)) {
+		if (rx_stats)
+			rx_stats->rx_dropped++;
+	}
 	rcu_read_unlock();
 	return NET_RX_SUCCESS;
 
@@ -843,13 +846,15 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, st
 			accum.rx_packets += rxpackets;
 			accum.rx_bytes   += rxbytes;
 			accum.rx_multicast += rxmulticast;
-			/* rx_errors is an ulong, not protected by syncp */
+			/* rx_errors, rx_dropped are ulong, not protected by syncp */
 			accum.rx_errors  += p->rx_errors;
+			accum.rx_dropped += p->rx_dropped;
 		}
 		stats->rx_packets = accum.rx_packets;
 		stats->rx_bytes   = accum.rx_bytes;
 		stats->rx_errors  = accum.rx_errors;
 		stats->multicast  = accum.rx_multicast;
+		stats->rx_dropped = accum.rx_dropped;
 	}
 	return stats;
 }
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fc20e68..8d53362 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -647,9 +647,11 @@ static int ipgre_rcv(struct sk_buff *skb)
 		skb_reset_network_header(skb);
 		ipgre_ecn_decapsulate(iph, skb);
 
-		netif_rx(skb);
+		if (netif_rx(skb) == NET_RX_DROP)
+			stats->rx_dropped++;
+
 		rcu_read_unlock();
-		return(0);
+		return 0;
 	}
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 8de8888..babd252 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -377,7 +377,10 @@ static int ipip_rcv(struct sk_buff *skb)
 		skb_tunnel_rx(skb, tunnel->dev);
 
 		ipip_ecn_decapsulate(iph, skb);
-		netif_rx(skb);
+
+		if (netif_rx(skb) == NET_RX_DROP)
+			tunnel->dev->stats.rx_dropped++;
+
 		rcu_read_unlock();
 		return 0;
 	}
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9289cec..f6d9f68 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -725,7 +725,10 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		skb_tunnel_rx(skb, t->dev);
 
 		dscp_ecn_decapsulate(t, ipv6h, skb);
-		netif_rx(skb);
+
+		if (netif_rx(skb) == NET_RX_DROP)
+			t->dev->stats.rx_dropped++;
+
 		rcu_read_unlock();
 		return 0;
 	}
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 66078da..2640c9b 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -666,7 +666,9 @@ static int pim6_rcv(struct sk_buff *skb)
 
 	skb_tunnel_rx(skb, reg_dev);
 
-	netif_rx(skb);
+	if (netif_rx(skb) == NET_RX_DROP)
+		reg_dev->stats.rx_dropped++;
+
 	dev_put(reg_dev);
 	return 0;
  drop:
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 6822481..8a03998 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -564,7 +564,10 @@ static int ipip6_rcv(struct sk_buff *skb)
 		skb_tunnel_rx(skb, tunnel->dev);
 
 		ipip6_ecn_decapsulate(iph, skb);
-		netif_rx(skb);
+
+		if (netif_rx(skb) == NET_RX_DROP)
+			tunnel->dev->stats.rx_dropped++;
+
 		rcu_read_unlock();
 		return 0;
 	}


