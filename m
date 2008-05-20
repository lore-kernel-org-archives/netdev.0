From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 4/10][IPIP]: Use on-device stats instead of private
 ones.
Date: Tue, 20 May 2008 20:36:00 +0400
Message-ID: <4832FDF0.6050607@openvz.org>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33862 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753578AbYETQi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:38:27 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ipip.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 149111f..26c85c2 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -496,8 +496,8 @@ static int ipip_rcv(struct sk_buff *skb)
 		skb->protocol = htons(ETH_P_IP);
 		skb->pkt_type = PACKET_HOST;
 
-		tunnel->stat.rx_packets++;
-		tunnel->stat.rx_bytes += skb->len;
+		tunnel->dev->stats.rx_packets++;
+		tunnel->dev->stats.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
@@ -520,7 +520,7 @@ static int ipip_rcv(struct sk_buff *skb)
 static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct net_device_stats *stats = &tunnel->stat;
+	struct net_device_stats *stats = &tunnel->dev->stats;
 	struct iphdr  *tiph = &tunnel->parms.iph;
 	u8     tos = tunnel->parms.iph.tos;
 	__be16 df = tiph->frag_off;
@@ -533,7 +533,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	int    mtu;
 
 	if (tunnel->recursion++) {
-		tunnel->stat.collisions++;
+		stats->collisions++;
 		goto tx_error;
 	}
 
@@ -546,7 +546,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!dst) {
 		/* NBMA tunnel */
 		if ((rt = skb->rtable) == NULL) {
-			tunnel->stat.tx_fifo_errors++;
+			stats->tx_fifo_errors++;
 			goto tx_error;
 		}
 		if ((dst = rt->rt_gateway) == 0)
@@ -561,7 +561,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 						.tos = RT_TOS(tos) } },
 				    .proto = IPPROTO_IPIP };
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
-			tunnel->stat.tx_carrier_errors++;
+			stats->tx_carrier_errors++;
 			goto tx_error_icmp;
 		}
 	}
@@ -569,7 +569,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (tdev == dev) {
 		ip_rt_put(rt);
-		tunnel->stat.collisions++;
+		stats->collisions++;
 		goto tx_error;
 	}
 
@@ -579,7 +579,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		mtu = skb->dst ? dst_mtu(skb->dst) : dev->mtu;
 
 	if (mtu < 68) {
-		tunnel->stat.collisions++;
+		stats->collisions++;
 		ip_rt_put(rt);
 		goto tx_error;
 	}
@@ -813,11 +813,6 @@ done:
 	return err;
 }
 
-static struct net_device_stats *ipip_tunnel_get_stats(struct net_device *dev)
-{
-	return &(((struct ip_tunnel*)netdev_priv(dev))->stat);
-}
-
 static int ipip_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if (new_mtu < 68 || new_mtu > 0xFFF8 - sizeof(struct iphdr))
@@ -830,7 +825,6 @@ static void ipip_tunnel_setup(struct net_device *dev)
 {
 	dev->uninit		= ipip_tunnel_uninit;
 	dev->hard_start_xmit	= ipip_tunnel_xmit;
-	dev->get_stats		= ipip_tunnel_get_stats;
 	dev->do_ioctl		= ipip_tunnel_ioctl;
 	dev->change_mtu		= ipip_tunnel_change_mtu;
 	dev->destructor		= free_netdev;
-- 
1.5.3.4

