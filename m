From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 4/4] tunnel: drop packet if ECN present with not-ECT
Date: Mon, 24 Sep 2012 21:12:26 -0700
Message-ID: <20120925041259.337491375@vyatta.com>
References: <20120925041222.056704869@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:44182 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714Ab2IYEQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 00:16:27 -0400
Content-Disposition: inline; filename=gre-rfc-6040.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux tunnels were written before RFC6040 and therefore never
implemented the corner case of ECN getting set in the outer header
and the inner header not being ready for it.

Section 4.2.  Default Tunnel Egress Behaviour.
 The new code addresses:
 o If the inner ECN field is Not-ECT, the decapsulator MUST NOT
      propagate any other ECN codepoint onwards.  This is because the
      inner Not-ECT marking is set by transports that rely on dropped
      packets as an indication of congestion and would not understand or
      respond to any other ECN codepoint [RFC4774].  Specifically:

      *  If the inner ECN field is Not-ECT and the outer ECN field is
         CE, the decapsulator MUST drop the packet.

      *  If the inner ECN field is Not-ECT and the outer ECN field is
         Not-ECT, ECT(0), or ECT(1), the decapsulator MUST forward the
         outgoing packet with the ECN field cleared to Not-ECT.

Overloads rx_frame_error to keep track of this error.
This was caught by Chris Wright while reviewing the new VXLAN tunnel.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Note: supersedes earlier patch which only did Ipv4 GRE.

 net/ipv4/ip_gre.c            |   23 +++++++++++------
 net/ipv4/ipip.c              |   19 ++++++++------
 net/ipv4/xfrm4_mode_tunnel.c |   12 +++++---
 net/ipv6/ip6_gre.c           |   58 +++++++++++++++++++++++--------------------
 4 files changed, 67 insertions(+), 45 deletions(-)

--- a/net/ipv4/ip_gre.c	2012-09-24 18:11:52.000000000 -0700
+++ b/net/ipv4/ip_gre.c	2012-09-24 18:13:13.098719907 -0700
@@ -204,7 +204,9 @@ static struct rtnl_link_stats64 *ipgre_g
 	tot->rx_crc_errors = dev->stats.rx_crc_errors;
 	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
 	tot->rx_length_errors = dev->stats.rx_length_errors;
+	tot->rx_frame_errors = dev->stats.rx_frame_errors;
 	tot->rx_errors = dev->stats.rx_errors;
+
 	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
 	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
 	tot->tx_dropped = dev->stats.tx_dropped;
@@ -587,15 +589,16 @@ static void ipgre_err(struct sk_buff *sk
 	t->err_time = jiffies;
 }
 
-static inline void ipgre_ecn_decapsulate(const struct iphdr *iph, struct sk_buff *skb)
+static int ipgre_ecn_decapsulate(const struct iphdr *iph, struct sk_buff *skb)
 {
 	if (INET_ECN_is_ce(iph->tos)) {
 		if (skb->protocol == htons(ETH_P_IP)) {
-			IP_ECN_set_ce(ip_hdr(skb));
+			return IP_ECN_set_ce(ip_hdr(skb));
 		} else if (skb->protocol == htons(ETH_P_IPV6)) {
-			IP6_ECN_set_ce(ipv6_hdr(skb));
+			return IP6_ECN_set_ce(ipv6_hdr(skb));
 		}
 	}
+	return 1;
 }
 
 static inline u8
@@ -723,17 +726,21 @@ static int ipgre_rcv(struct sk_buff *skb
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 		}
 
+		__skb_tunnel_rx(skb, tunnel->dev);
+
+		skb_reset_network_header(skb);
+		if (!ipgre_ecn_decapsulate(iph, skb)) {
+			++tunnel->dev->stats.rx_frame_errors;
+			++tunnel->dev->stats.rx_errors;
+			goto drop;
+		}
+
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 		u64_stats_update_end(&tstats->syncp);
 
-		__skb_tunnel_rx(skb, tunnel->dev);
-
-		skb_reset_network_header(skb);
-		ipgre_ecn_decapsulate(iph, skb);
-
 		netif_rx(skb);
 
 		return 0;
--- a/net/ipv4/ipip.c	2012-09-24 18:12:33.000000000 -0700
+++ b/net/ipv4/ipip.c	2012-09-24 18:13:13.098719907 -0700
@@ -400,13 +400,14 @@ out:
 	return err;
 }
 
-static inline void ipip_ecn_decapsulate(const struct iphdr *outer_iph,
-					struct sk_buff *skb)
+static int ipip_ecn_decapsulate(const struct iphdr *outer_iph,
+				struct sk_buff *skb)
 {
 	struct iphdr *inner_iph = ip_hdr(skb);
 
 	if (INET_ECN_is_ce(outer_iph->tos))
-		IP_ECN_set_ce(inner_iph);
+		return IP_ECN_set_ce(inner_iph);
+	return 1;
 }
 
 static int ipip_rcv(struct sk_buff *skb)
@@ -430,16 +431,20 @@ static int ipip_rcv(struct sk_buff *skb)
 		skb->protocol = htons(ETH_P_IP);
 		skb->pkt_type = PACKET_HOST;
 
+		__skb_tunnel_rx(skb, tunnel->dev);
+
+		if (!ipip_ecn_decapsulate(iph, skb)) {
+			++tunnel->dev->stats.rx_frame_errors;
+			++tunnel->dev->stats.rx_errors;
+			return 0;
+		}
+
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 		u64_stats_update_end(&tstats->syncp);
 
-		__skb_tunnel_rx(skb, tunnel->dev);
-
-		ipip_ecn_decapsulate(iph, skb);
-
 		netif_rx(skb);
 		return 0;
 	}
--- a/net/ipv6/ip6_gre.c	2012-09-24 18:12:00.783449055 -0700
+++ b/net/ipv6/ip6_gre.c	2012-09-24 18:13:13.098719907 -0700
@@ -149,7 +149,9 @@ static struct rtnl_link_stats64 *ip6gre_
 	tot->rx_crc_errors = dev->stats.rx_crc_errors;
 	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
 	tot->rx_length_errors = dev->stats.rx_length_errors;
+	tot->rx_frame_errors = dev->stats.rx_frame_errors;
 	tot->rx_errors = dev->stats.rx_errors;
+
 	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
 	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
 	tot->tx_dropped = dev->stats.tx_dropped;
@@ -489,26 +491,28 @@ static void ip6gre_err(struct sk_buff *s
 	t->err_time = jiffies;
 }
 
-static inline void ip6gre_ecn_decapsulate_ipv4(const struct ip6_tnl *t,
-		const struct ipv6hdr *ipv6h, struct sk_buff *skb)
-{
-	__u8 dsfield = ipv6_get_dsfield(ipv6h) & ~INET_ECN_MASK;
-
-	if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
-		ipv4_change_dsfield(ip_hdr(skb), INET_ECN_MASK, dsfield);
-
-	if (INET_ECN_is_ce(dsfield))
-		IP_ECN_set_ce(ip_hdr(skb));
-}
+static int ip6gre_ecn_decapsulate(const struct ip6_tnl *t,
+				  const struct ipv6hdr *ipv6h,
+				  struct sk_buff *skb)
+{
+	__u8 dsfield = ipv6_get_dsfield(ipv6h);
+	if (skb->protocol == htons(ETH_P_IP)) {
+		dsfield  &= ~INET_ECN_MASK;
+
+		if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
+			ipv4_change_dsfield(ip_hdr(skb), INET_ECN_MASK,
+					    dsfield);
+		if (INET_ECN_is_ce(dsfield))
+			return IP_ECN_set_ce(ip_hdr(skb));
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
+			ipv6_copy_dscp(dsfield, ipv6_hdr(skb));
 
-static inline void ip6gre_ecn_decapsulate_ipv6(const struct ip6_tnl *t,
-		const struct ipv6hdr *ipv6h, struct sk_buff *skb)
-{
-	if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
-		ipv6_copy_dscp(ipv6_get_dsfield(ipv6h), ipv6_hdr(skb));
+		if (INET_ECN_is_ce(ipv6_get_dsfield(ipv6h)))
+			return IP6_ECN_set_ce(ipv6_hdr(skb));
+	}
 
-	if (INET_ECN_is_ce(ipv6_get_dsfield(ipv6h)))
-		IP6_ECN_set_ce(ipv6_hdr(skb));
+	return 1;
 }
 
 static int ip6gre_rcv(struct sk_buff *skb)
@@ -625,20 +629,22 @@ static int ip6gre_rcv(struct sk_buff *sk
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 		}
 
+		__skb_tunnel_rx(skb, tunnel->dev);
+
+		skb_reset_network_header(skb);
+
+		if (!ip6gre_ecn_decapsulate(tunnel, ipv6h, skb)) {
+			++tunnel->dev->stats.rx_frame_errors;
+			++tunnel->dev->stats.rx_errors;
+			goto drop;
+		}
+
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 		u64_stats_update_end(&tstats->syncp);
 
-		__skb_tunnel_rx(skb, tunnel->dev);
-
-		skb_reset_network_header(skb);
-		if (skb->protocol == htons(ETH_P_IP))
-			ip6gre_ecn_decapsulate_ipv4(tunnel, ipv6h, skb);
-		else if (skb->protocol == htons(ETH_P_IPV6))
-			ip6gre_ecn_decapsulate_ipv6(tunnel, ipv6h, skb);
-
 		netif_rx(skb);
 
 		return 0;
