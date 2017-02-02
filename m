From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net] ipv6: sr: remove cleanup flag and fix HMAC computation
Date: Thu, 2 Feb 2017 11:29:38 +0100
Message-ID: <1486031378-3899-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:49205 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdBBK2d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:28:33 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id 3E31867DCCF
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 11:28:23 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the latest version of the IPv6 Segment Routing IETF draft [1] the
cleanup flag is removed and the flags field length is shrunk from 16 bits
to 8 bits. As a consequence, the input of the HMAC computation is modified
in a non-backward compatible way by covering the whole octet of flags
instead of only the cleanup bit. As such, if an implementation compatible
with the latest draft computes the HMAC of an SRH who has other flags set
to 1, then the HMAC result would differ from the current implementation.

This patch carries those modifications to prevent conflict with other
implementations of IPv6 SR.

[1] https://tools.ietf.org/html/draft-ietf-6man-segment-routing-header-05

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/uapi/linux/seg6.h |  9 +++------
 net/ipv6/exthdrs.c        | 31 +++----------------------------
 net/ipv6/seg6_hmac.c      |  8 ++++----
 3 files changed, 10 insertions(+), 38 deletions(-)

diff --git a/include/uapi/linux/seg6.h b/include/uapi/linux/seg6.h
index 3349659..61df8d3 100644
--- a/include/uapi/linux/seg6.h
+++ b/include/uapi/linux/seg6.h
@@ -25,14 +25,12 @@ struct ipv6_sr_hdr {
 	__u8	type;
 	__u8	segments_left;
 	__u8	first_segment;
-	__u8	flag_1;
-	__u8	flag_2;
-	__u8	reserved;
+	__u8	flags;
+	__u16	reserved;
 
 	struct in6_addr segments[0];
 };
 
-#define SR6_FLAG1_CLEANUP	(1 << 7)
 #define SR6_FLAG1_PROTECTED	(1 << 6)
 #define SR6_FLAG1_OAM		(1 << 5)
 #define SR6_FLAG1_ALERT		(1 << 4)
@@ -44,8 +42,7 @@ struct ipv6_sr_hdr {
 #define SR6_TLV_PADDING		4
 #define SR6_TLV_HMAC		5
 
-#define sr_has_cleanup(srh) ((srh)->flag_1 & SR6_FLAG1_CLEANUP)
-#define sr_has_hmac(srh) ((srh)->flag_1 & SR6_FLAG1_HMAC)
+#define sr_has_hmac(srh) ((srh)->flags & SR6_FLAG1_HMAC)
 
 struct sr6_tlv {
 	__u8 type;
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index e419850..275cac6 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -327,7 +327,6 @@ static int ipv6_srh_rcv(struct sk_buff *skb)
 	struct ipv6_sr_hdr *hdr;
 	struct inet6_dev *idev;
 	struct in6_addr *addr;
-	bool cleanup = false;
 	int accept_seg6;
 
 	hdr = (struct ipv6_sr_hdr *)skb_transport_header(skb);
@@ -351,11 +350,7 @@ static int ipv6_srh_rcv(struct sk_buff *skb)
 #endif
 
 looped_back:
-	if (hdr->segments_left > 0) {
-		if (hdr->nexthdr != NEXTHDR_IPV6 && hdr->segments_left == 1 &&
-		    sr_has_cleanup(hdr))
-			cleanup = true;
-	} else {
+	if (hdr->segments_left == 0) {
 		if (hdr->nexthdr == NEXTHDR_IPV6) {
 			int offset = (hdr->hdrlen + 1) << 3;
 
@@ -418,21 +413,6 @@ static int ipv6_srh_rcv(struct sk_buff *skb)
 
 	ipv6_hdr(skb)->daddr = *addr;
 
-	if (cleanup) {
-		int srhlen = (hdr->hdrlen + 1) << 3;
-		int nh = hdr->nexthdr;
-
-		skb_pull_rcsum(skb, sizeof(struct ipv6hdr) + srhlen);
-		memmove(skb_network_header(skb) + srhlen,
-			skb_network_header(skb),
-			(unsigned char *)hdr - skb_network_header(skb));
-		skb->network_header += srhlen;
-		ipv6_hdr(skb)->nexthdr = nh;
-		ipv6_hdr(skb)->payload_len = htons(skb->len -
-						   sizeof(struct ipv6hdr));
-		skb_push_rcsum(skb, sizeof(struct ipv6hdr));
-	}
-
 	skb_dst_drop(skb);
 
 	ip6_route_input(skb);
@@ -453,13 +433,8 @@ static int ipv6_srh_rcv(struct sk_buff *skb)
 		}
 		ipv6_hdr(skb)->hop_limit--;
 
-		/* be sure that srh is still present before reinjecting */
-		if (!cleanup) {
-			skb_pull(skb, sizeof(struct ipv6hdr));
-			goto looped_back;
-		}
-		skb_set_transport_header(skb, sizeof(struct ipv6hdr));
-		IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
+		skb_pull(skb, sizeof(struct ipv6hdr));
+		goto looped_back;
 	}
 
 	dst_input(skb);
diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
index b274f1d..f950cb5 100644
--- a/net/ipv6/seg6_hmac.c
+++ b/net/ipv6/seg6_hmac.c
@@ -174,7 +174,7 @@ int seg6_hmac_compute(struct seg6_hmac_info *hinfo, struct ipv6_sr_hdr *hdr,
 	 * hash function (RadioGatun) with up to 1216 bits
 	 */
 
-	/* saddr(16) + first_seg(1) + cleanup(1) + keyid(4) + seglist(16n) */
+	/* saddr(16) + first_seg(1) + flags(1) + keyid(4) + seglist(16n) */
 	plen = 16 + 1 + 1 + 4 + (hdr->first_segment + 1) * 16;
 
 	/* this limit allows for 14 segments */
@@ -186,7 +186,7 @@ int seg6_hmac_compute(struct seg6_hmac_info *hinfo, struct ipv6_sr_hdr *hdr,
 	 *
 	 * 1. Source IPv6 address (128 bits)
 	 * 2. first_segment value (8 bits)
-	 * 3. cleanup flag (8 bits: highest bit is cleanup value, others are 0)
+	 * 3. Flags (8 bits)
 	 * 4. HMAC Key ID (32 bits)
 	 * 5. All segments in the segments list (n * 128 bits)
 	 */
@@ -202,8 +202,8 @@ int seg6_hmac_compute(struct seg6_hmac_info *hinfo, struct ipv6_sr_hdr *hdr,
 	/* first_segment value */
 	*off++ = hdr->first_segment;
 
-	/* cleanup flag */
-	*off++ = !!(sr_has_cleanup(hdr)) << 7;
+	/* flags */
+	*off++ = hdr->flags;
 
 	/* HMAC Key ID */
 	memcpy(off, &hmackeyid, 4);
-- 
2.7.3
