From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 3/10][IPGRE]: Use on-device stats instead of private
 ones.
Date: Tue, 20 May 2008 20:34:48 +0400
Message-ID: <4832FDA8.3020608@openvz.org>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33851 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643AbYETQhP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:37:15 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just switch from tunnel->stat to tunnel->dev->stats. The ip_tunnel->stat
member intself will be removed after I fix its other users (very soon).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_gre.c |   32 ++++++++++++++------------------
 1 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2ada033..eede36e 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -617,6 +617,8 @@ static int ipgre_rcv(struct sk_buff *skb)
 	read_lock(&ipgre_lock);
 	if ((tunnel = ipgre_tunnel_lookup(dev_net(skb->dev),
 					iph->saddr, iph->daddr, key)) != NULL) {
+		struct net_device_stats *stats = &tunnel->dev->stats;
+
 		secpath_reset(skb);
 
 		skb->protocol = *(__be16*)(h + 2);
@@ -641,28 +643,28 @@ static int ipgre_rcv(struct sk_buff *skb)
 			/* Looped back packet, drop it! */
 			if (skb->rtable->fl.iif == 0)
 				goto drop;
-			tunnel->stat.multicast++;
+			stats->multicast++;
 			skb->pkt_type = PACKET_BROADCAST;
 		}
 #endif
 
 		if (((flags&GRE_CSUM) && csum) ||
 		    (!(flags&GRE_CSUM) && tunnel->parms.i_flags&GRE_CSUM)) {
-			tunnel->stat.rx_crc_errors++;
-			tunnel->stat.rx_errors++;
+			stats->rx_crc_errors++;
+			stats->rx_errors++;
 			goto drop;
 		}
 		if (tunnel->parms.i_flags&GRE_SEQ) {
 			if (!(flags&GRE_SEQ) ||
 			    (tunnel->i_seqno && (s32)(seqno - tunnel->i_seqno) < 0)) {
-				tunnel->stat.rx_fifo_errors++;
-				tunnel->stat.rx_errors++;
+				stats->rx_fifo_errors++;
+				stats->rx_errors++;
 				goto drop;
 			}
 			tunnel->i_seqno = seqno + 1;
 		}
-		tunnel->stat.rx_packets++;
-		tunnel->stat.rx_bytes += skb->len;
+		stats->rx_packets++;
+		stats->rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
@@ -684,7 +686,7 @@ drop_nolock:
 static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct net_device_stats *stats = &tunnel->stat;
+	struct net_device_stats *stats = &tunnel->dev->stats;
 	struct iphdr  *old_iph = ip_hdr(skb);
 	struct iphdr  *tiph;
 	u8     tos;
@@ -698,7 +700,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	int    mtu;
 
 	if (tunnel->recursion++) {
-		tunnel->stat.collisions++;
+		stats->collisions++;
 		goto tx_error;
 	}
 
@@ -714,7 +716,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* NBMA tunnel */
 
 		if (skb->dst == NULL) {
-			tunnel->stat.tx_fifo_errors++;
+			stats->tx_fifo_errors++;
 			goto tx_error;
 		}
 
@@ -765,7 +767,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 						.tos = RT_TOS(tos) } },
 				    .proto = IPPROTO_GRE };
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
-			tunnel->stat.tx_carrier_errors++;
+			stats->tx_carrier_errors++;
 			goto tx_error;
 		}
 	}
@@ -773,7 +775,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (tdev == dev) {
 		ip_rt_put(rt);
-		tunnel->stat.collisions++;
+		stats->collisions++;
 		goto tx_error;
 	}
 
@@ -1098,11 +1100,6 @@ done:
 	return err;
 }
 
-static struct net_device_stats *ipgre_tunnel_get_stats(struct net_device *dev)
-{
-	return &(((struct ip_tunnel*)netdev_priv(dev))->stat);
-}
-
 static int ipgre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
@@ -1228,7 +1225,6 @@ static void ipgre_tunnel_setup(struct net_device *dev)
 	dev->uninit		= ipgre_tunnel_uninit;
 	dev->destructor 	= free_netdev;
 	dev->hard_start_xmit	= ipgre_tunnel_xmit;
-	dev->get_stats		= ipgre_tunnel_get_stats;
 	dev->do_ioctl		= ipgre_tunnel_ioctl;
 	dev->change_mtu		= ipgre_tunnel_change_mtu;
 
-- 
1.5.3.4

