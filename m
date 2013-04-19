From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] bonding: change xmit hash functions to use skb_flow_dissect
Date: Sat, 20 Apr 2013 01:02:25 +0200
Message-ID: <1366412545-10829-1-git-send-email-nikolay@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933977Ab3DSXFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 19:05:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Eric suggested earlier, bonding hash functions can make good use of
skb_flow_dissect. The old use cases should have the same results, but
there should be good improvement for tunnel users mostly over IPv4.
I've kept the IPv6 address hashing algorithm and thus if a tunnel is
used over IPv6 then the addresses will be the same but there still can be
improvement because the ports from skb_flow_dissect will be mixed in.
This also fixes a problem with protocol == ETH_P_8021Q load balancing.
In case of non-dissectable packet, the algorithms fall back to L2
hashing.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 114 ++++++++++++++++++----------------------
 1 file changed, 50 insertions(+), 64 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5e22126..722d8c1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -77,6 +77,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/pkt_sched.h>
+#include <net/flow_keys.h>
 #include "bonding.h"
 #include "bond_3ad.h"
 #include "bond_alb.h"
@@ -3271,94 +3272,79 @@ static struct notifier_block bond_netdev_notifier = {
 
 /*---------------------------- Hashing Policies -----------------------------*/
 
-/*
- * Hash for the output device based upon layer 2 data
- */
-static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
+/* Ethernet/IPv4/IPv6 hash helpers */
+static inline u32 bond_eth_hash(struct sk_buff *skb)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 
-	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
-		return (data->h_dest[5] ^ data->h_source[5]) % count;
+	return data->h_dest[5] ^ data->h_source[5];
+}
 
-	return 0;
+static inline u32 bond_ipv4_hash(struct flow_keys *flow)
+{
+	return ntohl(flow->src ^ flow->dst) & 0xffff;
 }
 
-/*
- * Hash for the output device based upon layer 2 and layer 3 data. If
- * the packet is not IP, fall back on bond_xmit_hash_policy_l2()
- */
-static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
+static inline u32 bond_ipv6_hash(struct sk_buff *skb)
 {
-	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph;
 	struct ipv6hdr *ipv6h;
-	u32 v6hash;
+	u32 v6hash = 0;
 	__be32 *s, *d;
 
-	if (skb->protocol == htons(ETH_P_IP) &&
-	    skb_network_header_len(skb) >= sizeof(*iph)) {
-		iph = ip_hdr(skb);
-		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
-			(data->h_dest[5] ^ data->h_source[5])) % count;
-	} else if (skb->protocol == htons(ETH_P_IPV6) &&
-		   skb_network_header_len(skb) >= sizeof(*ipv6h)) {
+	if (pskb_network_may_pull(skb, sizeof(*ipv6h))) {
 		ipv6h = ipv6_hdr(skb);
 		s = &ipv6h->saddr.s6_addr32[0];
 		d = &ipv6h->daddr.s6_addr32[0];
 		v6hash = (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
 		v6hash ^= (v6hash >> 24) ^ (v6hash >> 16) ^ (v6hash >> 8);
-		return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
 	}
 
-	return bond_xmit_hash_policy_l2(skb, count);
+	return v6hash;
 }
 
-/*
- * Hash for the output device based upon layer 3 and layer 4 data. If
- * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
- * altogether not IP, fall back on bond_xmit_hash_policy_l2()
+/* Hash for the output device based upon layer 2 data */
+static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
+{
+	if (likely(skb_headlen(skb) >= offsetof(struct ethhdr, h_proto)))
+		return bond_eth_hash(skb) % count;
+
+	return 0;
+}
+
+/* Hash for the output device based upon layer 2 and layer 3 data. If
+ * the packet is not dissectable, fall back on bond_xmit_hash_policy_l2()
+ */
+static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
+{
+	struct flow_keys flow;
+
+	if (!skb_flow_dissect(skb, &flow))
+		return bond_xmit_hash_policy_l2(skb, count);
+
+	if (skb->protocol == htons(ETH_P_IPV6))
+		return (bond_ipv6_hash(skb) ^ bond_eth_hash(skb)) % count;
+	else
+		return (bond_ipv4_hash(&flow) ^ bond_eth_hash(skb)) % count;
+}
+
+/* Hash for the output device based upon layer 3 and layer 4 data. If
+ * the packet is not TCP or UDP, just use layer 3 data.  If it is
+ * altogether not dissectable, fall back on bond_xmit_hash_policy_l2()
  */
 static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
 {
+	struct flow_keys flow;
 	u32 layer4_xor = 0;
-	struct iphdr *iph;
-	struct ipv6hdr *ipv6h;
-	__be32 *s, *d;
-	__be16 *layer4hdr;
-
-	if (skb->protocol == htons(ETH_P_IP) &&
-	    skb_network_header_len(skb) >= sizeof(*iph)) {
-		iph = ip_hdr(skb);
-		if (!ip_is_fragment(iph) &&
-		    (iph->protocol == IPPROTO_TCP ||
-		     iph->protocol == IPPROTO_UDP) &&
-		    (skb_headlen(skb) - skb_network_offset(skb) >=
-		     iph->ihl * sizeof(u32) + sizeof(*layer4hdr) * 2)) {
-			layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
-			layer4_xor = ntohs(*layer4hdr ^ *(layer4hdr + 1));
-		}
-		return (layer4_xor ^
-			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
-	} else if (skb->protocol == htons(ETH_P_IPV6) &&
-		   skb_network_header_len(skb) >= sizeof(*ipv6h)) {
-		ipv6h = ipv6_hdr(skb);
-		if ((ipv6h->nexthdr == IPPROTO_TCP ||
-		     ipv6h->nexthdr == IPPROTO_UDP) &&
-		    (skb_headlen(skb) - skb_network_offset(skb) >=
-		     sizeof(*ipv6h) + sizeof(*layer4hdr) * 2)) {
-			layer4hdr = (__be16 *)(ipv6h + 1);
-			layer4_xor = ntohs(*layer4hdr ^ *(layer4hdr + 1));
-		}
-		s = &ipv6h->saddr.s6_addr32[0];
-		d = &ipv6h->daddr.s6_addr32[0];
-		layer4_xor ^= (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
-		layer4_xor ^= (layer4_xor >> 24) ^ (layer4_xor >> 16) ^
-			       (layer4_xor >> 8);
-		return layer4_xor % count;
-	}
 
-	return bond_xmit_hash_policy_l2(skb, count);
+	if (!skb_flow_dissect(skb, &flow))
+		return bond_xmit_hash_policy_l2(skb, count);
+
+	layer4_xor = ntohs(flow.port16[0] ^ flow.port16[1]);
+
+	if (skb->protocol == htons(ETH_P_IPV6))
+		return (layer4_xor ^ bond_ipv6_hash(skb)) % count;
+	else
+		return (layer4_xor ^ bond_ipv4_hash(&flow)) % count;
 }
 
 /*-------------------------- Device entry points ----------------------------*/
-- 
1.8.1.4
