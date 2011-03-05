From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 06/18] IPVS: Add sysctl_snat_reroute()
Date: Sun,  6 Mar 2011 08:45:48 +0900
Message-ID: <1299368760-14271-7-git-send-email-horms@verge.net.au>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans@schillstrom.com>,
	Simon Horman <horms@verge.net.au>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55492 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485Ab1CEXqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 18:46:18 -0500
In-Reply-To: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for not including sysctl_snat_reroute in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 299c7f3..1d8a2a2 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -599,6 +599,20 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	return NF_DROP;
 }
 
+#ifdef CONFIG_SYSCTL
+
+static int sysctl_snat_reroute(struct sk_buff *skb)
+{
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	return ipvs->sysctl_snat_reroute;
+}
+
+#else
+
+static int sysctl_snat_reroute(struct sk_buff *skb) { return 0; }
+
+#endif
+
 __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 {
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
@@ -633,15 +647,13 @@ static inline int ip_vs_gather_frags_v6(struct sk_buff *skb, u_int32_t user)
 
 static int ip_vs_route_me_harder(int af, struct sk_buff *skb)
 {
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
-
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		if (ipvs->sysctl_snat_reroute && ip6_route_me_harder(skb) != 0)
+		if (sysctl_snat_reroute(skb) && ip6_route_me_harder(skb) != 0)
 			return 1;
 	} else
 #endif
-		if ((ipvs->sysctl_snat_reroute ||
+		if ((sysctl_snat_reroute(skb) ||
 		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
 		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
 			return 1;
-- 
1.7.2.3

