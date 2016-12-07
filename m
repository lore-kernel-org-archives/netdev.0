From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/50] ipvs: Decrement ttl
Date: Wed,  7 Dec 2016 22:52:08 +0100
Message-ID: <1481147576-5690-3-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dwip Banerjee <dwip@linux.vnet.ibm.com>

We decrement the IP ttl in all the modes in order to prevent infinite
route loops. The changes were done based on Julian Anastasov's
suggestions in a prior thread.

The ttl based check/discard and the actual decrement are done in
__ip_vs_get_out_rt() and in __ip_vs_get_out_rt_v6(), for the IPv6
case. decrement_ttl() implements the actual functionality for the
two cases.

Signed-off-by: Dwip Banerjee <dwip@linux.vnet.ibm.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 54 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 01d3d894de46..4e1a98fcc8c3 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -254,6 +254,54 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
 	return true;
 }
 
+static inline bool decrement_ttl(struct netns_ipvs *ipvs,
+				 int skb_af,
+				 struct sk_buff *skb)
+{
+	struct net *net = ipvs->net;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb_af == AF_INET6) {
+		struct dst_entry *dst = skb_dst(skb);
+
+		/* check and decrement ttl */
+		if (ipv6_hdr(skb)->hop_limit <= 1) {
+			/* Force OUTPUT device used as source address */
+			skb->dev = dst->dev;
+			icmpv6_send(skb, ICMPV6_TIME_EXCEED,
+				    ICMPV6_EXC_HOPLIMIT, 0);
+			__IP6_INC_STATS(net, ip6_dst_idev(dst),
+					IPSTATS_MIB_INHDRERRORS);
+
+			return false;
+		}
+
+		/* don't propagate ttl change to cloned packets */
+		if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
+			return false;
+
+		ipv6_hdr(skb)->hop_limit--;
+	} else
+#endif
+	{
+		if (ip_hdr(skb)->ttl <= 1) {
+			/* Tell the sender its packet died... */
+			__IP_INC_STATS(net, IPSTATS_MIB_INHDRERRORS);
+			icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
+			return false;
+		}
+
+		/* don't propagate ttl change to cloned packets */
+		if (!skb_make_writable(skb, sizeof(struct iphdr)))
+			return false;
+
+		/* Decrease ttl */
+		ip_decrease_ttl(ip_hdr(skb));
+	}
+
+	return true;
+}
+
 /* Get route to destination or remote server */
 static int
 __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
@@ -326,6 +374,9 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		return local;
 	}
 
+	if (!decrement_ttl(ipvs, skb_af, skb))
+		goto err_put;
+
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL))) {
 		mtu = dst_mtu(&rt->dst);
 	} else {
@@ -473,6 +524,9 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		return local;
 	}
 
+	if (!decrement_ttl(ipvs, skb_af, skb))
+		goto err_put;
+
 	/* MTU checking */
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL)))
 		mtu = dst_mtu(&rt->dst);
-- 
2.1.4

