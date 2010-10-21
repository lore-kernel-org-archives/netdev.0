From: kaber@trash.net
Subject: [PATCH 43/72] ipvs: fix CHECKSUM_PARTIAL for TCP, UDP
Date: Thu, 21 Oct 2010 17:19:30 +0200
Message-ID: <1287674399-31455-44-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59999 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977Ab0JUPUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:12 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

 	Fix CHECKSUM_PARTIAL handling. Tested for IPv4 TCP,
UDP not tested because it needs network card with HW CSUM support.
May be fixes problem where IPVS can not be used in virtual boxes.
Problem appears with DNAT to local address when the local stack
sends reply in CHECKSUM_PARTIAL mode.

 	Fix tcp_dnat_handler and udp_dnat_handler to provide
vaddr and daddr in right order (old and new IP) when calling
tcp_partial_csum_update/udp_partial_csum_update (CHECKSUM_PARTIAL).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c |   10 +++++-----
 net/netfilter/ipvs/ip_vs_proto_udp.c |   10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 282d24d..318d011 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -101,15 +101,15 @@ tcp_partial_csum_update(int af, struct tcphdr *tcph,
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
 		tcph->check =
-			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+			~csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
 					 ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(tcph->check))));
+						csum_unfold(tcph->check))));
 	else
 #endif
 	tcph->check =
-		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
+		~csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
 				ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(tcph->check))));
+						csum_unfold(tcph->check))));
 }
 
 
@@ -223,7 +223,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 	 *	Adjust TCP checksums
 	 */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
+		tcp_partial_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
 					htons(oldlen),
 					htons(skb->len - tcphoff));
 	} else if (!cp->app) {
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 8553231..f929089 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -102,15 +102,15 @@ udp_partial_csum_update(int af, struct udphdr *uhdr,
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
 		uhdr->check =
-			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+			~csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
 					 ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(uhdr->check))));
+						csum_unfold(uhdr->check))));
 	else
 #endif
 	uhdr->check =
-		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
+		~csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
 				ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(uhdr->check))));
+						csum_unfold(uhdr->check))));
 }
 
 
@@ -229,7 +229,7 @@ udp_dnat_handler(struct sk_buff *skb,
 	 *	Adjust UDP checksums
 	 */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
+		udp_partial_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
 					htons(oldlen),
 					htons(skb->len - udphoff));
 	} else if (!cp->app && (udph->check != 0)) {
-- 
1.7.1

