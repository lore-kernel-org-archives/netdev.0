From: kaber@trash.net
Subject: [PATCH 49/72] ipvs: create ip_vs_defrag_user
Date: Thu, 21 Oct 2010 17:19:36 +0200
Message-ID: <1287674399-31455-50-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

 	Create new function ip_vs_defrag_user to return correct
IP_DEFRAG_xxx user depending on the hooknum. It will be needed
when we add handlers in LOCAL_OUT.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |   55 ++++++++++++++++++++++++---------------
 1 files changed, 34 insertions(+), 21 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 27ecb25..f7f5283 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -543,6 +543,15 @@ __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
 }
 
+static inline enum ip_defrag_users ip_vs_defrag_user(unsigned int hooknum)
+{
+	if (NF_INET_LOCAL_IN == hooknum)
+		return IP_DEFRAG_VS_IN;
+	if (NF_INET_FORWARD == hooknum)
+		return IP_DEFRAG_VS_FWD;
+	return IP_DEFRAG_VS_OUT;
+}
+
 static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
 {
 	int err = ip_defrag(skb, user);
@@ -714,7 +723,8 @@ out:
  *	Find any that might be relevant, check against existing connections.
  *	Currently handles error types - unreachable, quench, ttl exceeded.
  */
-static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
+static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
+			  unsigned int hooknum)
 {
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
@@ -729,7 +739,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 
 	/* reassemble IP fragments */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		if (ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT))
+		if (ip_vs_gather_frags(skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
 	}
 
@@ -788,7 +798,8 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 }
 
 #ifdef CONFIG_IP_VS_IPV6
-static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
+static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
+			     unsigned int hooknum)
 {
 	struct ipv6hdr *iph;
 	struct icmp6hdr	_icmph, *ic;
@@ -804,7 +815,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
 
 	/* reassemble IP fragments */
 	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
-		if (ip_vs_gather_frags_v6(skb, IP_DEFRAG_VS_OUT))
+		if (ip_vs_gather_frags_v6(skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
 	}
 
@@ -986,7 +997,9 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
-			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
+			int related;
+			int verdict = ip_vs_out_icmp_v6(skb, &related,
+							hooknum);
 
 			if (related) {
 				if (sysctl_ip_vs_snat_reroute &&
@@ -1000,7 +1013,8 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	} else
 #endif
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
-			int related, verdict = ip_vs_out_icmp(skb, &related);
+			int related;
+			int verdict = ip_vs_out_icmp(skb, &related, hooknum);
 
 			if (related) {
 				if (sysctl_ip_vs_snat_reroute &&
@@ -1019,19 +1033,19 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	/* reassemble IP fragments */
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
-			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
-
-			if (related)
-				return verdict;
-
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
+			if (ip_vs_gather_frags_v6(skb,
+						  ip_vs_defrag_user(hooknum)))
+				return NF_STOLEN;
 		}
+
+		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 	} else
 #endif
 		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_MF|IP_OFFSET) &&
 			     !pp->dont_defrag)) {
-			if (ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT))
+			if (ip_vs_gather_frags(skb,
+					       ip_vs_defrag_user(hooknum)))
 				return NF_STOLEN;
 
 			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
@@ -1114,8 +1128,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	/* reassemble IP fragments */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		if (ip_vs_gather_frags(skb, hooknum == NF_INET_LOCAL_IN ?
-					    IP_DEFRAG_VS_IN : IP_DEFRAG_VS_FWD))
+		if (ip_vs_gather_frags(skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
 	}
 
@@ -1226,9 +1239,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	/* reassemble IP fragments */
 	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
-		if (ip_vs_gather_frags_v6(skb, hooknum == NF_INET_LOCAL_IN ?
-					       IP_DEFRAG_VS_IN :
-					       IP_DEFRAG_VS_FWD))
+		if (ip_vs_gather_frags_v6(skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
 	}
 
@@ -1349,7 +1360,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
-			int related, verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
+			int related;
+			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
 
 			if (related)
 				return verdict;
@@ -1358,7 +1370,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	} else
 #endif
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
-			int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
+			int related;
+			int verdict = ip_vs_in_icmp(skb, &related, hooknum);
 
 			if (related)
 				return verdict;
-- 
1.7.1

