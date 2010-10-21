From: kaber@trash.net
Subject: [PATCH 47/72] ipvs: stop ICMP from FORWARD to local
Date: Thu, 21 Oct 2010 17:19:34 +0200
Message-ID: <1287674399-31455-48-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

 	Delivering locally ICMP from FORWARD hook is not supported.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 0090d6d..27ecb25 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -48,6 +48,7 @@
 #ifdef CONFIG_IP_VS_IPV6
 #include <net/ipv6.h>
 #include <linux/netfilter_ipv6.h>
+#include <net/ip6_route.h>
 #endif
 
 #include <net/ip_vs.h>
@@ -1191,7 +1192,14 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
 		offset += 2 * sizeof(__u16);
 	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset);
-	/* do not touch skb anymore */
+	/* LOCALNODE from FORWARD hook is not supported */
+	if (verdict == NF_ACCEPT && hooknum == NF_INET_FORWARD &&
+	    skb_rtable(skb)->rt_flags & RTCF_LOCAL) {
+		IP_VS_DBG(1, "%s(): "
+			  "local delivery to %pI4 but in FORWARD\n",
+			  __func__, &skb_rtable(skb)->rt_dst);
+		verdict = NF_DROP;
+	}
 
   out:
 	__ip_vs_conn_put(cp);
@@ -1212,6 +1220,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct ip_vs_protocol *pp;
 	unsigned int offset, verdict;
 	union nf_inet_addr snet;
+	struct rt6_info *rt;
 
 	*related = 1;
 
@@ -1290,7 +1299,15 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	    IPPROTO_SCTP == cih->nexthdr)
 		offset += 2 * sizeof(__u16);
 	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset);
-	/* do not touch skb anymore */
+	/* LOCALNODE from FORWARD hook is not supported */
+	if (verdict == NF_ACCEPT && hooknum == NF_INET_FORWARD &&
+	    (rt = (struct rt6_info *) skb_dst(skb)) &&
+	    rt->rt6i_dev && rt->rt6i_dev->flags & IFF_LOOPBACK) {
+		IP_VS_DBG(1, "%s(): "
+			  "local delivery to %pI6 but in FORWARD\n",
+			  __func__, &rt->rt6i_dst);
+		verdict = NF_DROP;
+	}
 
 	__ip_vs_conn_put(cp);
 
-- 
1.7.1

