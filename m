From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 04/12] iptunnel: Generalize tunnel update pmtu
Date: Tue, 26 Sep 2017 21:57:55 -0700
Message-ID: <20170927045803.2477-5-tom@quantonium.net>
References: <20170927045803.2477-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:49835 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970863AbdI0E6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 00:58:49 -0400
Received: by mail-pg0-f51.google.com with SMTP id m30so7130803pgn.6
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 21:58:48 -0700 (PDT)
In-Reply-To: <20170927045803.2477-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __iptunnel_update_pmtu exported function which does not take
an iptunnel argument but instead includes the fields from the
iptunnel structure as arguments which are needed in the function.

iptunnel_update_pmtu was modified to call __iptunnel_update_pmtu.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/net/ip_tunnels.h |  4 ++++
 net/ipv4/ip_tunnel.c     | 30 ++++++++++++++++++++----------
 2 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 2b05ae24f4f6..be675836d35a 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -317,6 +317,10 @@ static inline struct rtable *ip_tunnel_get_route(struct net_device *dev,
 				     dst_cache, use_cache);
 }
 
+int __iptunnel_update_pmtu(struct net_device *dev, struct sk_buff *skb,
+			   struct dst_entry *dst, __be16 df,
+			   const struct iphdr *inner_iph, int hlen, u32 daddr);
+
 struct ip_tunnel_encap_ops {
 	size_t (*encap_hlen)(struct ip_tunnel_encap *e);
 	int (*build_header)(struct sk_buff *skb, struct ip_tunnel_encap *e,
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index c97525d8dff9..0ee84ca76e0f 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -506,17 +506,16 @@ int ip_tunnel_encap_setup(struct ip_tunnel *t,
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_encap_setup);
 
-static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
-			    struct rtable *rt, __be16 df,
-			    const struct iphdr *inner_iph)
+int __iptunnel_update_pmtu(struct net_device *dev, struct sk_buff *skb,
+			   struct dst_entry *dst, __be16 df,
+			   const struct iphdr *inner_iph, int hlen, u32 daddr)
 {
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-	int pkt_size = skb->len - tunnel->hlen - dev->hard_header_len;
+	int pkt_size = skb->len - hlen - dev->hard_header_len;
 	int mtu;
 
 	if (df)
-		mtu = dst_mtu(&rt->dst) - dev->hard_header_len
-					- sizeof(struct iphdr) - tunnel->hlen;
+		mtu = dst_mtu(dst) - dev->hard_header_len
+				   - sizeof(struct iphdr) - hlen;
 	else
 		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
 
@@ -538,8 +537,7 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 
 		if (rt6 && mtu < dst_mtu(skb_dst(skb)) &&
 			   mtu >= IPV6_MIN_MTU) {
-			if ((tunnel->parms.iph.daddr &&
-			    !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
+			if ((daddr && !ipv4_is_multicast(daddr)) ||
 			    rt6->rt6i_dst.plen == 128) {
 				rt6->rt6i_flags |= RTF_MODIFIED;
 				dst_metric_set(skb_dst(skb), RTAX_MTU, mtu);
@@ -555,6 +553,17 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 #endif
 	return 0;
 }
+EXPORT_SYMBOL(__iptunnel_update_pmtu);
+
+static int iptunnel_update_pmtu(struct net_device *dev, struct sk_buff *skb,
+				struct rtable *rt, __be16 df,
+				const struct iphdr *inner_iph)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	return __iptunnel_update_pmtu(dev, skb, &rt->dst, df, inner_iph,
+				      tunnel->hlen, tunnel->parms.iph.daddr);
+}
 
 void ip_md_tunnel_xmit(struct sk_buff *skb, struct net_device *dev, u8 proto)
 {
@@ -739,7 +748,8 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
-	if (tnl_update_pmtu(dev, skb, rt, tnl_params->frag_off, inner_iph)) {
+	if (iptunnel_update_pmtu(dev, skb, rt, tnl_params->frag_off,
+				 inner_iph)) {
 		ip_rt_put(rt);
 		goto tx_error;
 	}
-- 
2.11.0
