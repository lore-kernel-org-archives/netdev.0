From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/30] ipvs: Handle inverse and icmp headers in ip_vs_leave
Date: Tue, 22 Sep 2015 11:13:53 +0200
Message-ID: <1442913260-3925-4-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34928 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757588AbbIVJHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 05:07:46 -0400
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Gartrell <agartrell@fb.com>

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |   33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f5d3d1..bb998d4 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -519,6 +519,17 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	return cp;
 }
 
+#ifdef CONFIG_SYSCTL
+static inline int ip_vs_addr_is_unicast(struct net *net, int af,
+					union nf_inet_addr *addr)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		return ipv6_addr_type(&addr->in6) & IPV6_ADDR_UNICAST;
+#endif
+	return (inet_addr_type(net, addr->ip) == RTN_UNICAST);
+}
+#endif
 
 /*
  *  Pass or drop the packet.
@@ -528,33 +539,28 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph)
 {
-	__be16 _ports[2], *pptr;
+	__be16 _ports[2], *pptr, dport;
 #ifdef CONFIG_SYSCTL
 	struct net *net;
 	struct netns_ipvs *ipvs;
-	int unicast;
 #endif
 
 	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
-	if (pptr == NULL) {
+	if (!pptr)
 		return NF_DROP;
-	}
+	dport = likely(!ip_vs_iph_inverse(iph)) ? pptr[1] : pptr[0];
 
 #ifdef CONFIG_SYSCTL
 	net = skb_net(skb);
 
-#ifdef CONFIG_IP_VS_IPV6
-	if (svc->af == AF_INET6)
-		unicast = ipv6_addr_type(&iph->daddr.in6) & IPV6_ADDR_UNICAST;
-	else
-#endif
-		unicast = (inet_addr_type(net, iph->daddr.ip) == RTN_UNICAST);
 
 	/* if it is fwmark-based service, the cache_bypass sysctl is up
 	   and the destination is a non-local unicast, then create
 	   a cache_bypass connection entry */
 	ipvs = net_ipvs(net);
-	if (ipvs->sysctl_cache_bypass && svc->fwmark && unicast) {
+	if (ipvs->sysctl_cache_bypass && svc->fwmark &&
+	    !(iph->hdr_flags & (IP_VS_HDR_INVERSE | IP_VS_HDR_ICMP)) &&
+	    ip_vs_addr_is_unicast(net, svc->af, &iph->daddr)) {
 		int ret;
 		struct ip_vs_conn *cp;
 		unsigned int flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
@@ -598,9 +604,12 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	 * listed in the ipvs table), pass the packets, because it is
 	 * not ipvs job to decide to drop the packets.
 	 */
-	if ((svc->port == FTPPORT) && (pptr[1] != FTPPORT))
+	if (svc->port == FTPPORT && dport != FTPPORT)
 		return NF_ACCEPT;
 
+	if (unlikely(ip_vs_iph_icmp(iph)))
+		return NF_DROP;
+
 	/*
 	 * Notify the client that the destination is unreachable, and
 	 * release the socket buffer.
-- 
1.7.10.4
