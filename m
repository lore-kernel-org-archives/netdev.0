From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 02/10] net: Move GSO csum into SKB_GSO_CB
Date: Fri, 05 Feb 2016 15:27:37 -0800
Message-ID: <20160205232737.18529.83813.stgit@localhost.localdomain>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33543 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbcBEX1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 18:27:38 -0500
Received: by mail-pf0-f170.google.com with SMTP id w123so76623682pfb.0
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 15:27:38 -0800 (PST)
In-Reply-To: <20160205232109.18529.99816.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the checksum maintained by GSO out of skb->csum and into
the GSO context block in order to allow for us to work on outer checksums
while maintaining the inner checksum offsets in the case of the inner
checksum being offloaded, while the outer checksums will be computed.

While updating the code I also did a minor cleanu-up on gso_make_checksum.
The change is mostly to make it so that we store the values and compute the
checksum instead of computing the checksum and then storing the values we
needed to update.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/skbuff.h |   14 +++++++-------
 net/core/skbuff.c      |   16 +++++++++-------
 2 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 61b8cef73296..33c3807b618a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3549,6 +3549,7 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 struct skb_gso_cb {
 	int	mac_offset;
 	int	encap_level;
+	__wsum	csum;
 	__u16	csum_start;
 };
 #define SKB_SGO_CB_OFFSET	32
@@ -3585,15 +3586,14 @@ static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
  */
 static inline __sum16 gso_make_checksum(struct sk_buff *skb, __wsum res)
 {
-	int plen = SKB_GSO_CB(skb)->csum_start - skb_headroom(skb) -
-		   skb_transport_offset(skb);
-	__wsum partial;
+	unsigned char *csum_start = skb_transport_header(skb);
+	int plen = (skb->head + SKB_GSO_CB(skb)->csum_start) - csum_start;
+	__wsum partial = SKB_GSO_CB(skb)->csum;
 
-	partial = csum_partial(skb_transport_header(skb), plen, skb->csum);
-	skb->csum = res;
-	SKB_GSO_CB(skb)->csum_start -= plen;
+	SKB_GSO_CB(skb)->csum = res;
+	SKB_GSO_CB(skb)->csum_start = csum_start - skb->head;
 
-	return csum_fold(partial);
+	return csum_fold(csum_partial(csum_start, plen, partial));
 }
 
 static inline bool skb_is_gso(const struct sk_buff *skb)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b2df375ec9c2..02c638a643ea 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3100,11 +3100,12 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 
 		if (!sg && !nskb->remcsum_offload) {
 			nskb->ip_summed = CHECKSUM_NONE;
-			nskb->csum = skb_copy_and_csum_bits(head_skb, offset,
-							    skb_put(nskb, len),
-							    len, 0);
+			SKB_GSO_CB(nskb)->csum =
+				skb_copy_and_csum_bits(head_skb, offset,
+						       skb_put(nskb, len),
+						       len, 0);
 			SKB_GSO_CB(nskb)->csum_start =
-			    skb_headroom(nskb) + doffset;
+				skb_headroom(nskb) + doffset;
 			continue;
 		}
 
@@ -3171,11 +3172,12 @@ skip_fraglist:
 
 perform_csum_check:
 		if (!csum && !nskb->remcsum_offload) {
-			nskb->csum = skb_checksum(nskb, doffset,
-						  nskb->len - doffset, 0);
 			nskb->ip_summed = CHECKSUM_NONE;
+			SKB_GSO_CB(nskb)->csum =
+				skb_checksum(nskb, doffset,
+					     nskb->len - doffset, 0);
 			SKB_GSO_CB(nskb)->csum_start =
-			    skb_headroom(nskb) + doffset;
+				skb_headroom(nskb) + doffset;
 		}
 	} while ((offset += len) < head_skb->len);
 
