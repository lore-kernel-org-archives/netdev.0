From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/8] net: Add frag_list support to skb_segment
Date: Sat, 13 Dec 2008 12:35:19 +1100
Message-ID: <E1LBJPb-0003YB-0e@gondolin.me.apana.org.au>
References: <20081213013420.GA13549@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53829 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753569AbYLMBfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 20:35:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net: Add frag_list support to skb_segment

This patch adds limited support for handling frag_list packets in
skb_segment.  The intention is to support GRO (Generic Receive Offload)
packets which will be constructed by chaining normal packets using
frag_list.

As such we require all frag_list members terminate on exact MSS
boundaries.  This is checked using BUG_ON.

As there should only be one producer in the kernel of such packets,
namely GRO, this requirement should not be difficult to maintain.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/skbuff.c |   73 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 59 insertions(+), 14 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d49ef83..cf05a8c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2285,6 +2285,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 {
 	struct sk_buff *segs = NULL;
 	struct sk_buff *tail = NULL;
+	struct sk_buff *fskb = skb_shinfo(skb)->frag_list;
 	unsigned int mss = skb_shinfo(skb)->gso_size;
 	unsigned int doffset = skb->data - skb_mac_header(skb);
 	unsigned int offset = doffset;
@@ -2304,7 +2305,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 		struct sk_buff *nskb;
 		skb_frag_t *frag;
 		int hsize;
-		int k;
 		int size;
 
 		len = skb->len - offset;
@@ -2317,9 +2317,36 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 		if (hsize > len || !sg)
 			hsize = len;
 
-		nskb = alloc_skb(hsize + doffset + headroom, GFP_ATOMIC);
-		if (unlikely(!nskb))
-			goto err;
+		if (!hsize && i >= nfrags) {
+			BUG_ON(fskb->len != len);
+
+			pos += len;
+			nskb = skb_clone(fskb, GFP_ATOMIC);
+			fskb = fskb->next;
+
+			if (unlikely(!nskb))
+				goto err;
+
+			hsize = skb_end_pointer(nskb) - nskb->head;
+			if (skb_cow_head(nskb, doffset + headroom)) {
+				kfree_skb(nskb);
+				goto err;
+			}
+
+			nskb->truesize += skb_end_pointer(nskb) - nskb->head -
+					  hsize;
+			skb_release_head_state(nskb);
+			__skb_push(nskb, doffset);
+		} else {
+			nskb = alloc_skb(hsize + doffset + headroom,
+					 GFP_ATOMIC);
+
+			if (unlikely(!nskb))
+				goto err;
+
+			skb_reserve(nskb, headroom);
+			__skb_put(nskb, doffset);
+		}
 
 		if (segs)
 			tail->next = nskb;
@@ -2330,13 +2357,15 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 		__copy_skb_header(nskb, skb);
 		nskb->mac_len = skb->mac_len;
 
-		skb_reserve(nskb, headroom);
 		skb_reset_mac_header(nskb);
 		skb_set_network_header(nskb, skb->mac_len);
 		nskb->transport_header = (nskb->network_header +
 					  skb_network_header_len(skb));
-		skb_copy_from_linear_data(skb, skb_put(nskb, doffset),
-					  doffset);
+		skb_copy_from_linear_data(skb, nskb->data, doffset);
+
+		if (pos >= offset + len)
+			continue;
+
 		if (!sg) {
 			nskb->ip_summed = CHECKSUM_NONE;
 			nskb->csum = skb_copy_and_csum_bits(skb, offset,
@@ -2346,14 +2375,11 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 		}
 
 		frag = skb_shinfo(nskb)->frags;
-		k = 0;
 
 		skb_copy_from_linear_data_offset(skb, offset,
 						 skb_put(nskb, hsize), hsize);
 
-		while (pos < offset + len) {
-			BUG_ON(i >= nfrags);
-
+		while (pos < offset + len && i < nfrags) {
 			*frag = skb_shinfo(skb)->frags[i];
 			get_page(frag->page);
 			size = frag->size;
@@ -2363,20 +2389,39 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 				frag->size -= offset - pos;
 			}
 
-			k++;
+			skb_shinfo(nskb)->nr_frags++;
 
 			if (pos + size <= offset + len) {
 				i++;
 				pos += size;
 			} else {
 				frag->size -= pos + size - (offset + len);
-				break;
+				goto skip_fraglist;
 			}
 
 			frag++;
 		}
 
-		skb_shinfo(nskb)->nr_frags = k;
+		if (pos < offset + len) {
+			struct sk_buff *fskb2 = fskb;
+
+			BUG_ON(pos + fskb->len != offset + len);
+
+			pos += fskb->len;
+			fskb = fskb->next;
+
+			if (fskb2->next) {
+				fskb2 = skb_clone(fskb2, GFP_ATOMIC);
+				if (!fskb2)
+					goto err;
+			} else
+				skb_get(fskb2);
+
+			BUG_ON(skb_shinfo(nskb)->frag_list);
+			skb_shinfo(nskb)->frag_list = fskb2;
+		}
+
+skip_fraglist:
 		nskb->data_len = len - hsize;
 		nskb->len += nskb->data_len;
 		nskb->truesize += nskb->data_len;
