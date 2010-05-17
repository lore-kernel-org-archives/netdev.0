From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: Introduce skb_tunnel_rx() helper
Date: Tue, 18 May 2010 00:50:36 +0200
Message-ID: <1274136636.2567.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:33574 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab0EQWuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 18:50:40 -0400
Received: by wwi17 with SMTP id 17so71650wwi.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 15:50:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb rxhash should be cleared when a skb is handled by a tunnel before
being delivered again, so that correct packet steering can take place.

There are other cleanups and accounting that we can factorize in a new
helper, skb_tunnel_rx()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/dst.h     |   20 ++++++++++++++++++++
 net/ipv4/ip_gre.c     |    9 +--------
 net/ipv4/ipip.c       |    7 ++-----
 net/ipv4/ipmr.c       |    8 +++-----
 net/ipv6/ip6_tunnel.c |    8 ++------
 net/ipv6/ip6mr.c      |    8 +++-----
 net/ipv6/sit.c        |    8 +++-----
 7 files changed, 34 insertions(+), 34 deletions(-)
diff --git a/include/net/dst.h b/include/net/dst.h
index aac5a5f..d708c22 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -184,6 +184,26 @@ static inline void skb_dst_drop(struct sk_buff *skb)
 	skb->_skb_dst = 0UL;
 }
 
+
+/**
+ *	skb_tunnel_rx - prepare skb for rx reinsert
+ *	@skb: buffer
+ *	@dev: tunnel device
+ *
+ *	After decapsulation, packet is going to re-enter (netif_rx()) our stack,
+ *	so make some cleanups, and perform accounting.
+ */
+static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
+{
+	skb->dev = dev;
+	/* TODO : stats should be SMP safe */
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
+	skb->rxhash = 0;
+	skb_dst_drop(skb);
+	nf_reset(skb);
+}
+
 /* Children define the path of the packet through the
  * Linux networking.  Thus, destinations are stackable.
  */
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fe381d1..498cf69 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -538,7 +538,6 @@ static int ipgre_rcv(struct sk_buff *skb)
 	struct ip_tunnel *tunnel;
 	int    offset = 4;
 	__be16 gre_proto;
-	unsigned int len;
 
 	if (!pskb_may_pull(skb, 16))
 		goto drop_nolock;
@@ -629,8 +628,6 @@ static int ipgre_rcv(struct sk_buff *skb)
 			tunnel->i_seqno = seqno + 1;
 		}
 
-		len = skb->len;
-
 		/* Warning: All skb pointers will be invalidated! */
 		if (tunnel->dev->type == ARPHRD_ETHER) {
 			if (!pskb_may_pull(skb, ETH_HLEN)) {
@@ -644,11 +641,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 		}
 
-		stats->rx_packets++;
-		stats->rx_bytes += len;
-		skb->dev = tunnel->dev;
-		skb_dst_drop(skb);
-		nf_reset(skb);
+		skb_tunnel_rx(skb, tunnel->dev);
 
 		skb_reset_network_header(skb);
 		ipgre_ecn_decapsulate(iph, skb);
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 0b27b14..7fd6367 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -374,11 +374,8 @@ static int ipip_rcv(struct sk_buff *skb)
 		skb->protocol = htons(ETH_P_IP);
 		skb->pkt_type = PACKET_HOST;
 
-		tunnel->dev->stats.rx_packets++;
-		tunnel->dev->stats.rx_bytes += skb->len;
-		skb->dev = tunnel->dev;
-		skb_dst_drop(skb);
-		nf_reset(skb);
+		skb_tunnel_rx(skb, tunnel->dev);
+
 		ipip_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
 		rcu_read_unlock();
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 7a7ee1c..217ebe0 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1831,14 +1831,12 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 	skb->mac_header = skb->network_header;
 	skb_pull(skb, (u8*)encap - skb->data);
 	skb_reset_network_header(skb);
-	skb->dev = reg_dev;
 	skb->protocol = htons(ETH_P_IP);
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
-	skb_dst_drop(skb);
-	reg_dev->stats.rx_bytes += skb->len;
-	reg_dev->stats.rx_packets++;
-	nf_reset(skb);
+
+	skb_tunnel_rx(skb, reg_dev);
+
 	netif_rx(skb);
 	dev_put(reg_dev);
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2599870..8f39893 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -723,14 +723,10 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		skb->protocol = htons(protocol);
 		skb->pkt_type = PACKET_HOST;
 		memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
-		skb->dev = t->dev;
-		skb_dst_drop(skb);
-		nf_reset(skb);
 
-		dscp_ecn_decapsulate(t, ipv6h, skb);
+		skb_tunnel_rx(skb, t->dev);
 
-		t->dev->stats.rx_packets++;
-		t->dev->stats.rx_bytes += skb->len;
+		dscp_ecn_decapsulate(t, ipv6h, skb);
 		netif_rx(skb);
 		rcu_read_unlock();
 		return 0;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 163850e..bd9e7d3 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -658,14 +658,12 @@ static int pim6_rcv(struct sk_buff *skb)
 	skb->mac_header = skb->network_header;
 	skb_pull(skb, (u8 *)encap - skb->data);
 	skb_reset_network_header(skb);
-	skb->dev = reg_dev;
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
-	skb_dst_drop(skb);
-	reg_dev->stats.rx_bytes += skb->len;
-	reg_dev->stats.rx_packets++;
-	nf_reset(skb);
+
+	skb_tunnel_rx(skb, reg_dev);
+
 	netif_rx(skb);
 	dev_put(reg_dev);
 	return 0;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 5abae10..e51e650 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -566,11 +566,9 @@ static int ipip6_rcv(struct sk_buff *skb)
 			kfree_skb(skb);
 			return 0;
 		}
-		tunnel->dev->stats.rx_packets++;
-		tunnel->dev->stats.rx_bytes += skb->len;
-		skb->dev = tunnel->dev;
-		skb_dst_drop(skb);
-		nf_reset(skb);
+
+		skb_tunnel_rx(skb, tunnel->dev);
+
 		ipip6_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
 		rcu_read_unlock();


