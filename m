From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 3/4] net: Store checksum result for offloaded GSO
 checksums
Date: Wed, 13 Jan 2016 21:12:14 -0800
Message-ID: <20160114051214.5119.63241.stgit@localhost.localdomain>
References: <20160114045532.5119.56124.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: ecree@solarflare.com, netdev@vger.kernel.org, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33780 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbcANFMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 00:12:17 -0500
Received: by mail-pf0-f172.google.com with SMTP id e65so93650521pfe.0
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 21:12:16 -0800 (PST)
In-Reply-To: <20160114045532.5119.56124.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes it so that we can offload the checksums for a packet up
to a certain point and then begin computing the checksums via software.
Setting this up is fairly straight forward as all we need to do is reset
the values stored in csum and csum_start for the GSO context block.

One complication for this is remote checksum offload.  In order to allow
the inner checksums to be offloaded while computing the outer checksum
manually we needed to have some way of indicating that the offload wasn't
real.  In order to do that I replaced CHECKSUM_PARTIAL with
CHECKSUM_UNNECESSARY in the case of us computing checksums for the outer
header while skipping computing checksums for the inner headers.  We clean
up the ip_summed flag and set it to either CHECKSUM_PARTIAL or
CHECKSUM_NONE once we hand the packet off to the next lower level.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/skbuff.h |   13 +++++++++++++
 net/core/skbuff.c      |    8 ++++----
 net/ipv4/tcp_offload.c |    8 ++++++--
 net/ipv4/udp_offload.c |    1 +
 4 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0150abb81929..8a73cb4c7e5a 100644
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
@@ -3558,6 +3563,14 @@ static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
 	return 0;
 }
 
+static inline void gso_reset_checksum(struct sk_buff *skb, __wsum res)
+{
+	unsigned char *csum_start = skb_checksum_start(skb);
+
+	SKB_GSO_CB(skb)->csum = res;
+	SKB_GSO_CB(skb)->csum_start = csum_start - skb->head;
+}
+
 /* Compute the checksum for a gso segment. First compute the checksum value
  * from the start of transport header to SKB_GSO_CB(skb)->csum_start, and
  * then add in skb->csum (checksum from csum_start to end of packet).
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 58ff3afdf79a..25ce87932cb9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3099,8 +3099,8 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 			goto perform_csum_check;
 
 		if (!sg) {
-			if (!nskb->remcsum_offload)
-				nskb->ip_summed = CHECKSUM_NONE;
+			nskb->ip_summed = nskb->remcsum_offload ?
+					  CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
 			SKB_GSO_CB(nskb)->csum =
 				skb_copy_and_csum_bits(head_skb, offset,
 						       skb_put(nskb, len),
@@ -3173,8 +3173,8 @@ skip_fraglist:
 
 perform_csum_check:
 		if (!csum) {
-			if (!nskb->remcsum_offload)
-				nskb->ip_summed = CHECKSUM_NONE;
+			nskb->ip_summed = nskb->remcsum_offload ?
+					  CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
 			SKB_GSO_CB(nskb)->csum =
 				skb_checksum(nskb, doffset,
 					     nskb->len - doffset, 0);
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 9864a2dbadce..894f87b23094 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -135,7 +135,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 		th->fin = th->psh = 0;
 		th->check = newcheck;
 
-		if (skb->ip_summed != CHECKSUM_PARTIAL)
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			gso_reset_checksum(skb, ~th->check);
+		else if (skb->ip_summed != CHECKSUM_UNNECESSARY)
 			th->check = gso_make_checksum(skb, ~th->check);
 
 		seq += mss;
@@ -169,7 +171,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 		      skb->data_len);
 	th->check = ~csum_fold((__force __wsum)((__force u32)th->check +
 				(__force u32)delta));
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		gso_reset_checksum(skb, ~th->check);
+	else if (skb->ip_summed != CHECKSUM_UNNECESSARY)
 		th->check = gso_make_checksum(skb, ~th->check);
 out:
 	return segs;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index ab7531b4dd24..45824f9b81c4 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -115,6 +115,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 			skb->ip_summed = CHECKSUM_PARTIAL;
 			skb->csum_start = skb_transport_header(skb) - skb->head;
 			skb->csum_offset = offsetof(struct udphdr, check);
+			gso_reset_checksum(skb, ~uh->check);
 		} else {
 			uh->check = gso_make_checksum(skb, ~uh->check);
 
