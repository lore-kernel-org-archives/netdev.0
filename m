From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/8] net: local checksum offload for encapsulation
Date: Fri, 8 Jan 2016 19:45:24 +0000
Message-ID: <569011D4.60002@solarflare.com>
References: <56901197.8040808@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.com>, <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:12752 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755885AbcAHTpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 14:45:31 -0500
In-Reply-To: <56901197.8040808@solarflare.com>
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
 include/linux/skbuff.h  | 24 ++++++++++++++++++++++++
 net/ipv4/udp.c          | 20 ++++++++++----------
 net/ipv6/ip6_checksum.c | 14 +++++++-------
 3 files changed, 41 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6b6bd42..ee063ff 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3665,5 +3665,29 @@ static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
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
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8841e98..f9bd5db 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -767,16 +767,18 @@ void udp_set_csum(bool nocheck, struct sk_buff *skb,
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
+		uh->check = ~udp_v4_check(len, saddr, daddr, lco_csum(skb));
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else if (skb_dst(skb) && skb_dst(skb)->dev &&
+		   (skb_dst(skb)->dev->features &
+		    (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM))) {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
@@ -784,8 +786,6 @@ void udp_set_csum(bool nocheck, struct sk_buff *skb,
 	} else {
 		__wsum csum;
 
-		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
-
 		uh->check = 0;
 		csum = skb_checksum(skb, 0, len, 0);
 		uh->check = udp_v4_check(len, saddr, daddr, csum);
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index 9a4d732..eba525d 100644
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
+		uh->check = ~udp_v6_check(len, saddr, daddr, csum_fold(lco_csum(skb));
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else if (skb_dst(skb) && skb_dst(skb)->dev &&
+		   (skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM) {
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
