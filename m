From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 1/8] net: local checksum offload for
 encapsulation
Date: Thu, 11 Feb 2016 20:48:04 +0000
Message-ID: <alpine.LFD.2.20.1602112046270.15537@ec-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:39617 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751104AbcBKUsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 15:48:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The arithmetic properties of the ones-complement checksum mean that a
 correctly checksummed inner packet, including its checksum, has a ones
 complement sum depending only on whatever value was used to initialise
 the checksum field before checksumming (in the case of TCP and UDP,
 this is the ones complement sum of the pseudo header, complemented).
Consequently, if we are going to offload the inner checksum with
 CHECKSUM_PARTIAL, we can compute the outer checksum based only on the
 packed data not covered by the inner checksum, and the initial value of
 the inner checksum field.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 include/linux/skbuff.h    | 24 ++++++++++++++++++++++++
 net/ipv4/ip_tunnel_core.c | 10 +++++-----
 net/ipv4/udp.c            | 20 ++++++++++----------
 net/ipv6/ip6_checksum.c   | 14 +++++++-------
 4 files changed, 46 insertions(+), 22 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a8fc222..acc1390 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3698,5 +3698,29 @@ static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
 	return hdr_len + skb_gso_transport_seglen(skb);
 }
 
+/* Local Checksum Offload.
+ * Compute outer checksum based on the assumption that the
+ * inner checksum will be offloaded later.
+ * Fill in outer checksum adjustment (e.g. with sum of outer
+ * pseudo-header) before calling.
+ * Also ensure that inner checksum is in linear data area.
+ */
+static inline __wsum lco_csum(struct sk_buff *skb)
+{
+	char *inner_csum_field;
+	__wsum csum;
+
+	/* Start with complement of inner checksum adjustment */
+	inner_csum_field = skb->data + skb_checksum_start_offset(skb) +
+				skb->csum_offset;
+	csum = ~csum_unfold(*(__force __sum16 *)inner_csum_field);
+	/* Add in checksum of our headers (incl. outer checksum
+	 * adjustment filled in by caller)
+	 */
+	csum = skb_checksum(skb, 0, skb_checksum_start_offset(skb), csum);
+	/* The result is the checksum from skb->data to end of packet */
+	return csum;
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 859d415..d74ce93 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -166,20 +166,20 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
 		return skb;
 	}
 
-	/* If packet is not gso and we are resolving any partial checksum,
+	/* If packet is not gso and we are not offloading inner checksum,
 	 * clear encapsulation flag. This allows setting CHECKSUM_PARTIAL
 	 * on the outer header without confusing devices that implement
 	 * NETIF_F_IP_CSUM with encapsulation.
 	 */
-	if (csum_help)
-		skb->encapsulation = 0;
-
 	if (skb->ip_summed == CHECKSUM_PARTIAL && csum_help) {
+		skb->encapsulation = 0;
 		err = skb_checksum_help(skb);
 		if (unlikely(err))
 			goto error;
-	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
+	} else if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		skb->ip_summed = CHECKSUM_NONE;
+		skb->encapsulation = 0;
+	}
 
 	return skb;
 error:
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ac3cedb..a59341c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -848,16 +848,18 @@ void udp_set_csum(bool nocheck, struct sk_buff *skb,
 {
 	struct udphdr *uh = udp_hdr(skb);
 
-	if (nocheck)
+	if (nocheck) {
 		uh->check = 0;
-	else if (skb_is_gso(skb))
+	} else if (skb_is_gso(skb)) {
 		uh->check = ~udp_v4_check(len, saddr, daddr, 0);
-	else if (skb_dst(skb) && skb_dst(skb)->dev &&
-		 (skb_dst(skb)->dev->features &
-		  (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM))) {
-
-		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
-
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		uh->check = 0;
+		uh->check = udp_v4_check(len, saddr, daddr, lco_csum(skb));
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else if (skb_dst(skb) && skb_dst(skb)->dev &&
+		   (skb_dst(skb)->dev->features &
+		    (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM))) {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
@@ -865,8 +867,6 @@ void udp_set_csum(bool nocheck, struct sk_buff *skb,
 	} else {
 		__wsum csum;
 
-		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
-
 		uh->check = 0;
 		csum = skb_checksum(skb, 0, len, 0);
 		uh->check = udp_v4_check(len, saddr, daddr, csum);
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index 9a4d732..4924bd7 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -98,11 +98,13 @@ void udp6_set_csum(bool nocheck, struct sk_buff *skb,
 		uh->check = 0;
 	else if (skb_is_gso(skb))
 		uh->check = ~udp_v6_check(len, saddr, daddr, 0);
-	else if (skb_dst(skb) && skb_dst(skb)->dev &&
-		 (skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM)) {
-
-		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
-
+	else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		uh->check = 0;
+		uh->check = udp_v6_check(len, saddr, daddr, lco_csum(skb));
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else if (skb_dst(skb) && skb_dst(skb)->dev &&
+		   (skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM)) {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
@@ -110,8 +112,6 @@ void udp6_set_csum(bool nocheck, struct sk_buff *skb,
 	} else {
 		__wsum csum;
 
-		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
-
 		uh->check = 0;
 		csum = skb_checksum(skb, 0, len, 0);
 		uh->check = udp_v6_check(len, saddr, daddr, csum);
