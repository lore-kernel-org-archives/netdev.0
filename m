From: John Eaglesham <linux@8192.net>
Subject: [PATCH v4 1/2] Add support for IPv6 and bounds checking to transmit hashing functions.
Date: Sun,  1 Jul 2012 00:01:38 -0700
Message-ID: <9814878c9da75aaadfd70e0ea45b29c3ee8869a0.1341125875.git.linux@8192.net>
References: <cover.1341125875.git.linux@8192.net>
Cc: John Eaglesham <linux@8192.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp171.dfw.emailsrvr.com ([67.192.241.171]:49044 "EHLO
	smtp171.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab2GAHCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 03:02:33 -0400
In-Reply-To: <cover.1341125875.git.linux@8192.net>
In-Reply-To: <cover.1341125875.git.linux@8192.net>
References: <cover.1341125875.git.linux@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/bonding/bond_main.c | 91 +++++++++++++++++++++++++++++------------
 1 file changed, 64 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f5a40b9..b138d84 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3345,56 +3345,93 @@ static struct notifier_block bond_netdev_notifier = {
 /*---------------------------- Hashing Policies -----------------------------*/
 
 /*
+ * Hash for the output device based upon layer 2 data
+ */
+static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
+{
+	struct ethhdr *data = (struct ethhdr *)skb->data;
+
+	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
+		return (data->h_dest[5] ^ data->h_source[5]) % count;
+
+	return 0;
+}
+
+/*
  * Hash for the output device based upon layer 2 and layer 3 data. If
- * the packet is not IP mimic bond_xmit_hash_policy_l2()
+ * the packet is not IP, fall back on bond_xmit_hash_policy_l2()
  */
 static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph = ip_hdr(skb);
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6h;
+	u32 v6hash;
 
-	if (skb->protocol == htons(ETH_P_IP)) {
+	if (skb->protocol == htons(ETH_P_IP) &&
+		skb_network_header_len(skb) >= sizeof(struct iphdr)) {
+		iph = ip_hdr(skb);
 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
 			(data->h_dest[5] ^ data->h_source[5])) % count;
-	}
-
-	return (data->h_dest[5] ^ data->h_source[5]) % count;
+	} else if (skb->protocol == htons(ETH_P_IPV6) &&
+		skb_network_header_len(skb) >= sizeof(struct ipv6hdr)) {
+		ipv6h = ipv6_hdr(skb);
+		v6hash =
+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);
+		v6hash = (v6hash >> 16) ^ (v6hash >> 8) ^ v6hash;
+		return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
+	}
+
+	return bond_xmit_hash_policy_l2(skb, count);
 }
 
 /*
  * Hash for the output device based upon layer 3 and layer 4 data. If
  * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
- * altogether not IP, mimic bond_xmit_hash_policy_l2()
+ * altogether not IP, fall back on bond_xmit_hash_policy_l2()
  */
 static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
 {
-	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph = ip_hdr(skb);
-	__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
-	int layer4_xor = 0;
+	u32 layer4_xor = 0;
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6h;
 
 	if (skb->protocol == htons(ETH_P_IP)) {
+		iph = ip_hdr(skb);
 		if (!ip_is_fragment(iph) &&
-		    (iph->protocol == IPPROTO_TCP ||
-		     iph->protocol == IPPROTO_UDP)) {
+			(iph->protocol == IPPROTO_TCP ||
+			iph->protocol == IPPROTO_UDP)) {
+			__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
+			if (iph->ihl * sizeof(u32) + sizeof(__be16) * 2 >
+				skb_headlen(skb) - skb_network_offset(skb))
+				goto short_header;
 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
+		} else if (skb_network_header_len(skb) < sizeof(struct iphdr)) {
+			goto short_header;
 		}
-		return (layer4_xor ^
-			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
-
+		return (layer4_xor ^ ((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		ipv6h = ipv6_hdr(skb);
+		if (ipv6h->nexthdr == IPPROTO_TCP || ipv6h->nexthdr == IPPROTO_UDP) {
+			__be16 *layer4hdrv6 = (__be16 *)((u8 *)ipv6h + sizeof(struct ipv6hdr));
+			if (sizeof(struct ipv6hdr) + sizeof(__be16) * 2 >
+				skb_headlen(skb) - skb_network_offset(skb))
+				goto short_header;
+			layer4_xor = (*layer4hdrv6 ^ *(layer4hdrv6 + 1));
+		} else if (skb_network_header_len(skb) < sizeof(struct ipv6hdr)) {
+			goto short_header;
+		}
+		layer4_xor ^=
+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);
+		return ((layer4_xor >> 16) ^ (layer4_xor >> 8) ^ layer4_xor) % count;
 	}
 
-	return (data->h_dest[5] ^ data->h_source[5]) % count;
-}
-
-/*
- * Hash for the output device based upon layer 2 data
- */
-static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
-{
-	struct ethhdr *data = (struct ethhdr *)skb->data;
-
-	return (data->h_dest[5] ^ data->h_source[5]) % count;
+short_header:
+	return bond_xmit_hash_policy_l2(skb, count);
 }
 
 /*-------------------------- Device entry points ----------------------------*/
-- 
1.7.11
