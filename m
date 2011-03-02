From: kaber@trash.net
Subject: [PATCH 08/13] ipvs: remove extra lookups for ICMP packets
Date: Wed,  2 Mar 2011 13:12:48 +0100
Message-ID: <1299067973-15977-9-git-send-email-kaber@trash.net>
References: <1299067973-15977-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32949 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757272Ab1CBMNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 07:13:00 -0500
In-Reply-To: <1299067973-15977-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

 	Remove code that should not be called anymore.
Now when ip_vs_out handles replies for local clients at
LOCAL_IN hook we do not need to call conn_out_get and
handle_response_icmp from ip_vs_in_icmp* because such
lookups were already performed for the ICMP packet and no
connection was found.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |   28 +++-------------------------
 1 files changed, 3 insertions(+), 25 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4d06617..2d1f932 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -729,7 +729,7 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
 #endif
 
 /* Handle relevant response ICMP messages - forward to the right
- * destination host. Used for NAT and local client.
+ * destination host.
  */
 static int handle_response_icmp(int af, struct sk_buff *skb,
 				union nf_inet_addr *snet,
@@ -979,7 +979,6 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
 }
 
 /* Handle response packets: rewrite addresses and send away...
- * Used for NAT and local client.
  */
 static unsigned int
 handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
@@ -1280,7 +1279,6 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	unsigned int offset, ihl, verdict;
-	union nf_inet_addr snet;
 
 	*related = 1;
 
@@ -1339,17 +1337,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
 	cp = pp->conn_in_get(AF_INET, skb, &ciph, offset, 1);
-	if (!cp) {
-		/* The packet could also belong to a local client */
-		cp = pp->conn_out_get(AF_INET, skb, &ciph, offset, 1);
-		if (cp) {
-			snet.ip = iph->saddr;
-			return handle_response_icmp(AF_INET, skb, &snet,
-						    cih->protocol, cp, pp,
-						    offset, ihl);
-		}
+	if (!cp)
 		return NF_ACCEPT;
-	}
 
 	verdict = NF_DROP;
 
@@ -1395,7 +1384,6 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	unsigned int offset, verdict;
-	union nf_inet_addr snet;
 	struct rt6_info *rt;
 
 	*related = 1;
@@ -1455,18 +1443,8 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
 	cp = pp->conn_in_get(AF_INET6, skb, &ciph, offset, 1);
-	if (!cp) {
-		/* The packet could also belong to a local client */
-		cp = pp->conn_out_get(AF_INET6, skb, &ciph, offset, 1);
-		if (cp) {
-			ipv6_addr_copy(&snet.in6, &iph->saddr);
-			return handle_response_icmp(AF_INET6, skb, &snet,
-						    cih->nexthdr,
-						    cp, pp, offset,
-						    sizeof(struct ipv6hdr));
-		}
+	if (!cp)
 		return NF_ACCEPT;
-	}
 
 	verdict = NF_DROP;
 
-- 
1.7.4

