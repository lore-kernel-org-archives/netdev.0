From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/3] udp: move logic out of udp[46]_ufo_send_check
Date: Sat, 20 Sep 2014 14:52:29 -0700
Message-ID: <1411249950-6795-3-git-send-email-therbert@google.com>
References: <1411249950-6795-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:41676 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbaITVxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 17:53:08 -0400
Received: by mail-pd0-f180.google.com with SMTP id r10so2035402pdi.11
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 14:53:07 -0700 (PDT)
In-Reply-To: <1411249950-6795-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In udp[46]_ufo_send_check the UDP checksum initialized to the pseudo
header checksum. We can move this logic into udp[46]_ufo_fragment.
After this change udp[64]_ufo_send_check is a no-op.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp_offload.c | 37 +++++++++++++++----------------------
 net/ipv6/udp_offload.c | 40 ++++++++++++++++++----------------------
 2 files changed, 33 insertions(+), 44 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index d7c43f7..2918cc9 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -27,23 +27,6 @@ struct udp_offload_priv {
 
 static int udp4_ufo_send_check(struct sk_buff *skb)
 {
-	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
-		return -EINVAL;
-
-	if (likely(!skb->encapsulation)) {
-		const struct iphdr *iph;
-		struct udphdr *uh;
-
-		iph = ip_hdr(skb);
-		uh = udp_hdr(skb);
-
-		uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
-				IPPROTO_UDP, 0);
-		skb->csum_start = skb_transport_header(skb) - skb->head;
-		skb->csum_offset = offsetof(struct udphdr, check);
-		skb->ip_summed = CHECKSUM_PARTIAL;
-	}
-
 	return 0;
 }
 
@@ -128,8 +111,9 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	unsigned int mss;
-	int offset;
 	__wsum csum;
+	struct udphdr *uh;
+	struct iphdr *iph;
 
 	if (skb->encapsulation &&
 	    (skb_shinfo(skb)->gso_type &
@@ -138,6 +122,9 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 		goto out;
 	}
 
+	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
+		goto out;
+
 	mss = skb_shinfo(skb)->gso_size;
 	if (unlikely(skb->len <= mss))
 		goto out;
@@ -165,10 +152,16 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 	 * HW cannot do checksum of UDP packets sent as multiple
 	 * IP fragments.
 	 */
-	offset = skb_checksum_start_offset(skb);
-	csum = skb_checksum(skb, offset, skb->len - offset, 0);
-	offset += skb->csum_offset;
-	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
+
+	uh = udp_hdr(skb);
+	iph = ip_hdr(skb);
+
+	uh->check = 0;
+	csum = skb_checksum(skb, 0, skb->len, 0);
+	uh->check = udp_v4_check(skb->len, iph->saddr, iph->daddr, csum);
+	if (uh->check == 0)
+		uh->check = CSUM_MANGLED_0;
+
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* Fragment the skb. IP headers of the fragments are updated in
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index de85f80..e4af643 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -19,23 +19,6 @@
 
 static int udp6_ufo_send_check(struct sk_buff *skb)
 {
-	const struct ipv6hdr *ipv6h;
-	struct udphdr *uh;
-
-	if (!pskb_may_pull(skb, sizeof(*uh)))
-		return -EINVAL;
-
-	if (likely(!skb->encapsulation)) {
-		ipv6h = ipv6_hdr(skb);
-		uh = udp_hdr(skb);
-
-		uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
-					     IPPROTO_UDP, 0);
-		skb->csum_start = skb_transport_header(skb) - skb->head;
-		skb->csum_offset = offsetof(struct udphdr, check);
-		skb->ip_summed = CHECKSUM_PARTIAL;
-	}
-
 	return 0;
 }
 
@@ -49,7 +32,6 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 	u8 *packet_start, *prevhdr;
 	u8 nexthdr;
 	u8 frag_hdr_sz = sizeof(struct frag_hdr);
-	int offset;
 	__wsum csum;
 	int tnl_hlen;
 
@@ -83,13 +65,27 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 	    (SKB_GSO_UDP_TUNNEL|SKB_GSO_UDP_TUNNEL_CSUM))
 		segs = skb_udp_tunnel_segment(skb, features);
 	else {
+		const struct ipv6hdr *ipv6h;
+		struct udphdr *uh;
+
+		if (!pskb_may_pull(skb, sizeof(struct udphdr)))
+			goto out;
+
 		/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
 		 * do checksum of UDP packets sent as multiple IP fragments.
 		 */
-		offset = skb_checksum_start_offset(skb);
-		csum = skb_checksum(skb, offset, skb->len - offset, 0);
-		offset += skb->csum_offset;
-		*(__sum16 *)(skb->data + offset) = csum_fold(csum);
+
+		uh = udp_hdr(skb);
+		ipv6h = ipv6_hdr(skb);
+
+		uh->check = 0;
+		csum = skb_checksum(skb, 0, skb->len, 0);
+		uh->check = udp_v6_check(skb->len, &ipv6h->saddr,
+					  &ipv6h->daddr, csum);
+
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+
 		skb->ip_summed = CHECKSUM_NONE;
 
 		/* Check if there is enough headroom to insert fragment header. */
-- 
2.1.0.rc2.206.gedb03e5
