From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 1/2] net: local checksum offload for encapsulation
Date: Mon, 11 Jan 2016 09:06:05 -0800
Message-ID: <20160111170605.5210.69312.stgit@localhost.localdomain>
References: <20160111165937.5210.61555.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, alexander.duyck@gmail.com
To: ecree@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35358 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933658AbcAKRGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:06:08 -0500
Received: by mail-pa0-f51.google.com with SMTP id ho8so63269159pac.2
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:06:07 -0800 (PST)
In-Reply-To: <20160111165937.5210.61555.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

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
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/skbuff.h    |   30 ++++++++++++++++++++++++++++++
 net/ipv4/ip_tunnel_core.c |    4 +++-
 net/ipv4/udp.c            |   24 ++++++------------------
 net/ipv6/ip6_checksum.c   |   23 ++++++-----------------
 4 files changed, 45 insertions(+), 36 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6b6bd42d6134..538cee5b8eb6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2161,6 +2161,11 @@ static inline int skb_checksum_start_offset(const struct sk_buff *skb)
 	return skb->csum_start - skb_headroom(skb);
 }
 
+static inline unsigned char *skb_checksum_start(const struct sk_buff *skb)
+{
+	return skb->head + skb->csum_start;
+}
+
 static inline int skb_transport_offset(const struct sk_buff *skb)
 {
 	return skb_transport_header(skb) - skb->data;
@@ -3578,6 +3583,31 @@ static inline __sum16 gso_make_checksum(struct sk_buff *skb, __wsum res)
 	return csum_fold(partial);
 }
 
+/* Local Checksum Offload.
+ * Compute outer checksum based on the assumption that the
+ * inner checksum will be offloaded later.
+ * See Documentation/networking/tx-offloads.txt for
+ * explanation of how this works.
+ * Fill in outer checksum adjustment (e.g. with sum of outer
+ * pseudo-header) before calling.
+ * Also ensure that inner checksum is in linear data area.
+ */
+static inline __wsum lco_csum(struct sk_buff *skb)
+{
+	unsigned char *csum_start = skb_checksum_start(skb);
+	unsigned char *l4_hdr = skb_transport_header(skb);
+	__wsum partial;
+
+	/* Start with complement of inner checksum adjustment */
+	partial = ~csum_unfold(*(__force __sum16 *)(csum_start +
+						    skb->csum_offset));
+
+	/* Add in checksum of our headers (incl. outer checksum
+	 * adjustment filled in by caller) and return result.
+	 */
+	return csum_partial(l4_hdr, csum_start - l4_hdr, partial);
+}
+
 static inline bool skb_is_gso(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->gso_size;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index eb52ce950c27..ab10c1ed70a6 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -178,8 +178,10 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
 		err = skb_checksum_help(skb);
 		if (unlikely(err))
 			goto error;
-	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
+	} else if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		skb->encapsulation = 0;
 		skb->ip_summed = CHECKSUM_NONE;
+	}
 
 	return skb;
 error:
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 3a66731e3af6..71e4a6d70a49 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -842,28 +842,16 @@ void udp_set_csum(bool nocheck, struct sk_buff *skb,
 		uh->check = 0;
 	else if (skb_is_gso(skb))
 		uh->check = ~udp_v4_check(len, saddr, daddr, 0);
-	else if (skb_dst(skb) && skb_dst(skb)->dev &&
-		 (skb_dst(skb)->dev->features &
-		  (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM))) {
-
-		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
-
+	else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		uh->check = 0;
+		uh->check = udp_v4_check(len, saddr, daddr, lco_csum(skb));
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
 		uh->check = ~udp_v4_check(len, saddr, daddr, 0);
-	} else {
-		__wsum csum;
-
-		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
-
-		uh->check = 0;
-		csum = skb_checksum(skb, 0, len, 0);
-		uh->check = udp_v4_check(len, saddr, daddr, csum);
-		if (uh->check == 0)
-			uh->check = CSUM_MANGLED_0;
-
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 }
 EXPORT_SYMBOL(udp_set_csum);
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index 9a4d7322fb22..8f920580976f 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -98,27 +98,16 @@ void udp6_set_csum(bool nocheck, struct sk_buff *skb,
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
+	} else {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
 		uh->check = ~udp_v6_check(len, saddr, daddr, 0);
-	} else {
-		__wsum csum;
-
-		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
-
-		uh->check = 0;
-		csum = skb_checksum(skb, 0, len, 0);
-		uh->check = udp_v6_check(len, saddr, daddr, csum);
-		if (uh->check == 0)
-			uh->check = CSUM_MANGLED_0;
-
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 }
 EXPORT_SYMBOL(udp6_set_csum);
