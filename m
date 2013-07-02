From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] ip_tunnels: Use skb-len to PMTU check.
Date: Tue,  2 Jul 2013 10:57:33 -0700
Message-ID: <1372787853-12382-1-git-send-email-pshelar@nicira.com>
Cc: davem@davemloft.net, timo.teras@iki.fi,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:33856 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752060Ab3GBR55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 13:57:57 -0400
Received: by mail-pa0-f42.google.com with SMTP id rl6so6582026pac.29
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 10:57:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In path mtu check, ip header total length works for gre device
but not for gre-tap device.  Use skb len which is consistent
for all tunneling types.  This is old bug in gre.
This also fixes mtu calculation bug introduced by
commit c54419321455631079c7d (GRE: Refactor GRE tunneling code).

Reported-by: Timo Teras <timo.teras@iki.fi>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_tunnel.c |   99 ++++++++++++++++++++++++++++----------------------
 1 files changed, 55 insertions(+), 44 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 394cebc..945734b 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -472,6 +472,54 @@ drop:
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_rcv);
 
+static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
+			    struct rtable *rt, __be16 df)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int pkt_size = skb->len - tunnel->hlen;
+	int mtu;
+
+	if (df)
+		mtu = dst_mtu(&rt->dst) - dev->hard_header_len
+					- sizeof(struct iphdr) - tunnel->hlen;
+	else
+		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
+
+	if (skb_dst(skb))
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		if (!skb_is_gso(skb) &&
+		    (df & htons(IP_DF)) && mtu < pkt_size) {
+			memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
+			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
+			return -E2BIG;
+		}
+	}
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
+
+		if (rt6 && mtu < dst_mtu(skb_dst(skb)) &&
+			   mtu >= IPV6_MIN_MTU) {
+			if ((tunnel->parms.iph.daddr &&
+			    !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
+			    rt6->rt6i_dst.plen == 128) {
+				rt6->rt6i_flags |= RTF_MODIFIED;
+				dst_metric_set(skb_dst(skb), RTAX_MTU, mtu);
+			}
+		}
+
+		if (!skb_is_gso(skb) && mtu >= IPV6_MIN_MTU &&
+					mtu < pkt_size) {
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+			return -E2BIG;
+		}
+	}
+#endif
+	return 0;
+}
+
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, const u8 protocol)
 {
@@ -483,7 +531,6 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	struct rtable *rt;		/* Route to the other host */
 	unsigned int max_headroom;	/* The extra header space needed */
 	__be32 dst;
-	int mtu;
 	int err;
 
 	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
@@ -560,51 +607,11 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		dev->stats.collisions++;
 		goto tx_error;
 	}
-	df = tnl_params->frag_off;
 
-	if (df)
-		mtu = dst_mtu(&rt->dst) - dev->hard_header_len
-					- sizeof(struct iphdr);
-	else
-		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
-
-	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-
-	if (skb->protocol == htons(ETH_P_IP)) {
-		df |= (inner_iph->frag_off&htons(IP_DF));
-
-		if (!skb_is_gso(skb) &&
-		    (inner_iph->frag_off&htons(IP_DF)) &&
-		     mtu < ntohs(inner_iph->tot_len)) {
-			memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
-			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-			ip_rt_put(rt);
-			goto tx_error;
-		}
-	}
-#if IS_ENABLED(CONFIG_IPV6)
-	else if (skb->protocol == htons(ETH_P_IPV6)) {
-		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
-
-		if (rt6 && mtu < dst_mtu(skb_dst(skb)) &&
-		    mtu >= IPV6_MIN_MTU) {
-			if ((tunnel->parms.iph.daddr &&
-			    !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
-			    rt6->rt6i_dst.plen == 128) {
-				rt6->rt6i_flags |= RTF_MODIFIED;
-				dst_metric_set(skb_dst(skb), RTAX_MTU, mtu);
-			}
-		}
-
-		if (!skb_is_gso(skb) && mtu >= IPV6_MIN_MTU &&
-		    mtu < skb->len) {
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-			ip_rt_put(rt);
-			goto tx_error;
-		}
+	if (tnl_update_pmtu(dev, skb, rt, tnl_params->frag_off)) {
+		ip_rt_put(rt);
+		goto tx_error;
 	}
-#endif
 
 	if (tunnel->net != dev_net(dev))
 		skb_scrub_packet(skb);
@@ -631,6 +638,10 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 			ttl = ip4_dst_hoplimit(&rt->dst);
 	}
 
+	df = tnl_params->frag_off;
+	if (skb->protocol == htons(ETH_P_IP))
+		df |= (inner_iph->frag_off&htons(IP_DF));
+
 	max_headroom = LL_RESERVED_SPACE(rt->dst.dev) + sizeof(struct iphdr)
 			+ rt->dst.header_len;
 	if (max_headroom > dev->needed_headroom) {
-- 
1.7.1
