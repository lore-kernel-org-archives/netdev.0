From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net v2] ip_tunnels: Use skb-len to PMTU check.
Date: Sun, 30 Jun 2013 23:30:32 -0700
Message-ID: <1372660232-12174-1-git-send-email-pshelar@nicira.com>
Cc: timo.teras@iki.fi, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:48311 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750987Ab3GAGah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 02:30:37 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr13so4451958pbb.34
        for <netdev@vger.kernel.org>; Sun, 30 Jun 2013 23:30:36 -0700 (PDT)
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
v1-v2:
 - Fix pmtu set.
 - This patch also restructures code which help couple of
   improvements I have.
---
 net/ipv4/ip_tunnel.c |   98 +++++++++++++++++++++++++++----------------------
 1 files changed, 54 insertions(+), 44 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 7fa8f08..ae5b78c 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -486,6 +486,53 @@ drop:
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
 		    const struct iphdr *tnl_params)
 {
@@ -499,7 +546,6 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	struct net_device *tdev;	/* Device to other host */
 	unsigned int max_headroom;	/* The extra header space needed */
 	__be32 dst;
-	int mtu;
 
 	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
 
@@ -579,50 +625,10 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
-	df = tnl_params->frag_off;
-
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
 
 	if (tunnel->err_count > 0) {
 		if (time_before(jiffies,
@@ -667,6 +673,10 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	iph = ip_hdr(skb);
 	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
 
+	df = tnl_params->frag_off;
+	if (skb->protocol == htons(ETH_P_IP))
+		df |= (inner_iph->frag_off&htons(IP_DF));
+
 	iph->version	=	4;
 	iph->ihl	=	sizeof(struct iphdr) >> 2;
 	iph->frag_off	=	df;
-- 
1.7.1
