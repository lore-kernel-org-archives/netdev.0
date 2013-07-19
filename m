From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] skbuff: ensure to reset dev in skb_scrub_packet()
Date: Fri, 19 Jul 2013 16:41:31 +0200
Message-ID: <1374244891-7030-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:48427 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509Ab3GSOmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 10:42:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because this function is used to scrub a packet when it cross netns, we must
ensure that skb->dev points to the new netns.

This was done by eth_type_trans() in dev_forward_skb(), but it's also needed
for ip tunnels.

I take the opportunity to move the call of skb_scrub_packet() after
eth_type_trans(), to be sure that pkt_type is set to PACKET_HOST.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/skbuff.h | 3 ++-
 net/core/dev.c         | 6 +++---
 net/core/skbuff.c      | 3 ++-
 net/ipv4/ip_tunnel.c   | 9 +++++----
 net/ipv6/sit.c         | 4 ++--
 5 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5afefa01a13c..620ecce0a717 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2385,7 +2385,8 @@ extern void	       skb_split(struct sk_buff *skb,
 				 struct sk_buff *skb1, const u32 len);
 extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
 				 int shiftlen);
-extern void	       skb_scrub_packet(struct sk_buff *skb);
+extern void	       skb_scrub_packet(struct sk_buff *skb,
+					struct net_device *dev);
 
 extern struct sk_buff *skb_segment(struct sk_buff *skb,
 				   netdev_features_t features);
diff --git a/net/core/dev.c b/net/core/dev.c
index 26755dd40daa..6f789b99331b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1691,13 +1691,13 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
-	skb_scrub_packet(skb);
 	skb->protocol = eth_type_trans(skb, dev);
 
 	/* eth_type_trans() can set pkt_type.
-	 * clear pkt_type _after_ calling eth_type_trans()
+	 * call skb_scrub_packet() after it to clear pkt_type _after_ calling
+	 * eth_type_trans().
 	 */
-	skb->pkt_type = PACKET_HOST;
+	skb_scrub_packet(skb, dev);
 
 	return netif_rx(skb);
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 20e02d2605ec..5f4701f89af8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3507,13 +3507,14 @@ EXPORT_SYMBOL(skb_try_coalesce);
  * another namespace. We have to clear all information in the skb that
  * could impact namespace isolation.
  */
-void skb_scrub_packet(struct sk_buff *skb)
+void skb_scrub_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	skb_orphan(skb);
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->skb_iif = 0;
 	skb_dst_drop(skb);
+	skb->dev = dev;
 	skb->mark = 0;
 	secpath_reset(skb);
 	nf_reset(skb);
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index ca1cb2d5f6e2..2e88321c7f23 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -454,15 +454,16 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	tstats->rx_bytes += skb->len;
 	u64_stats_update_end(&tstats->syncp);
 
-	if (tunnel->net != dev_net(tunnel->dev))
-		skb_scrub_packet(skb);
-
 	if (tunnel->dev->type == ARPHRD_ETHER) {
 		skb->protocol = eth_type_trans(skb, tunnel->dev);
 		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 	} else {
 		skb->dev = tunnel->dev;
 	}
+
+	if (tunnel->net != dev_net(tunnel->dev))
+		skb_scrub_packet(skb, tunnel->dev);
+
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
 
@@ -614,7 +615,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (tunnel->net != dev_net(dev))
-		skb_scrub_packet(skb);
+		skb_scrub_packet(skb, rt->dst.dev);
 
 	if (tunnel->err_count > 0) {
 		if (time_before(jiffies,
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a3437a4cd07e..dc2d01f90b81 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -622,7 +622,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 		tstats->rx_bytes += skb->len;
 
 		if (tunnel->net != dev_net(tunnel->dev))
-			skb_scrub_packet(skb);
+			skb_scrub_packet(skb, tunnel->dev);
 		netif_rx(skb);
 
 		return 0;
@@ -861,7 +861,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	if (tunnel->net != dev_net(dev))
-		skb_scrub_packet(skb);
+		skb_scrub_packet(skb, tdev);
 
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
-- 
1.8.2.1
