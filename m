From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 5/10][SIT]: Use on-device stats instead of private
 ones.
Date: Tue, 20 May 2008 20:36:47 +0400
Message-ID: <4832FE1F.1030704@openvz.org>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:45626 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756420AbYETQjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:39:14 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/sit.c |   24 +++++++++---------------
 1 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 5a6fab9..b0ee961 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -578,13 +578,13 @@ static int ipip6_rcv(struct sk_buff *skb)
 
 		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
 		    !isatap_chksrc(skb, iph, tunnel)) {
-			tunnel->stat.rx_errors++;
+			tunnel->dev->stats.rx_errors++;
 			read_unlock(&ipip6_lock);
 			kfree_skb(skb);
 			return 0;
 		}
-		tunnel->stat.rx_packets++;
-		tunnel->stat.rx_bytes += skb->len;
+		tunnel->dev->stats.rx_packets++;
+		tunnel->dev->stats.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
@@ -624,7 +624,7 @@ static inline __be32 try_6to4(struct in6_addr *v6dst)
 static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct net_device_stats *stats = &tunnel->stat;
+	struct net_device_stats *stats = &tunnel->dev->stats;
 	struct iphdr  *tiph = &tunnel->parms.iph;
 	struct ipv6hdr *iph6 = ipv6_hdr(skb);
 	u8     tos = tunnel->parms.iph.tos;
@@ -638,7 +638,7 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	int addr_type;
 
 	if (tunnel->recursion++) {
-		tunnel->stat.collisions++;
+		stats->collisions++;
 		goto tx_error;
 	}
 
@@ -705,20 +705,20 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
-			tunnel->stat.tx_carrier_errors++;
+			stats->tx_carrier_errors++;
 			goto tx_error_icmp;
 		}
 	}
 	if (rt->rt_type != RTN_UNICAST) {
 		ip_rt_put(rt);
-		tunnel->stat.tx_carrier_errors++;
+		stats->tx_carrier_errors++;
 		goto tx_error_icmp;
 	}
 	tdev = rt->u.dst.dev;
 
 	if (tdev == dev) {
 		ip_rt_put(rt);
-		tunnel->stat.collisions++;
+		stats->collisions++;
 		goto tx_error;
 	}
 
@@ -728,7 +728,7 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		mtu = skb->dst ? dst_mtu(skb->dst) : dev->mtu;
 
 	if (mtu < 68) {
-		tunnel->stat.collisions++;
+		stats->collisions++;
 		ip_rt_put(rt);
 		goto tx_error;
 	}
@@ -1003,11 +1003,6 @@ done:
 	return err;
 }
 
-static struct net_device_stats *ipip6_tunnel_get_stats(struct net_device *dev)
-{
-	return &(((struct ip_tunnel*)netdev_priv(dev))->stat);
-}
-
 static int ipip6_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if (new_mtu < IPV6_MIN_MTU || new_mtu > 0xFFF8 - sizeof(struct iphdr))
@@ -1021,7 +1016,6 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->uninit		= ipip6_tunnel_uninit;
 	dev->destructor 	= free_netdev;
 	dev->hard_start_xmit	= ipip6_tunnel_xmit;
-	dev->get_stats		= ipip6_tunnel_get_stats;
 	dev->do_ioctl		= ipip6_tunnel_ioctl;
 	dev->change_mtu		= ipip6_tunnel_change_mtu;
 
-- 
1.5.3.4

