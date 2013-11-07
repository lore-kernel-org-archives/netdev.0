From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 16:15:21 -0800
Message-ID: <1383783321.2878.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:65178 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908Ab3KGAPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 19:15:24 -0500
Received: by mail-pa0-f42.google.com with SMTP id kp14so425171pab.29
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 16:15:24 -0800 (PST)
In-Reply-To: <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 11:47 -0800, Eric Dumazet wrote:
> I'll try a different way.
> 
> The frag_list would contain a bunch of frags, that we logically add to the bunch
> of frags found in the first skb shared_info structure.

Here is the patch I came into (I tested it and it works very fine)

The theory is that in GRO stack, all skbs use the head_frag trick,
so even if one NIC pulled some payload into skb->head, we do not have to
copy anything. Outside of GRO stack, we are not supposed to provide data
in skb->head (I am speaking of the skb found on the frag_list extension,
not the skb_head)

I put a fallback code, just in case, with a WARN_ON_ONCE() so that we
can catch the offenders (if any) to fix them.

I renamed @skb to @skb_head to more clearly document this code.
Same for @i renamed to @cur_frag

 net/core/skbuff.c |  187 ++++++++++++++++++++++----------------------
 1 file changed, 94 insertions(+), 93 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3735fad..0aeefd1 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2771,80 +2771,60 @@ EXPORT_SYMBOL_GPL(skb_pull_rcsum);
  *	a pointer to the first in a list of new skbs for the segments.
  *	In case of error it returns ERR_PTR(err).
  */
-struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
+struct sk_buff *skb_segment(struct sk_buff *head_skb, netdev_features_t features)
 {
 	struct sk_buff *segs = NULL;
 	struct sk_buff *tail = NULL;
-	struct sk_buff *fskb = skb_shinfo(skb)->frag_list;
-	unsigned int mss = skb_shinfo(skb)->gso_size;
-	unsigned int doffset = skb->data - skb_mac_header(skb);
-	unsigned int offset = doffset;
-	unsigned int tnl_hlen = skb_tnl_header_len(skb);
+	struct sk_buff *cskb = head_skb;
+	unsigned int mss = skb_shinfo(head_skb)->gso_size;
+	unsigned int doffset = head_skb->data - skb_mac_header(head_skb);
+	unsigned int tot_len = doffset; /* should reach head_skb->len at the end */
+	unsigned int offset = doffset; /* offset in cskb->data */
+	unsigned int tnl_hlen = skb_tnl_header_len(head_skb);
 	unsigned int headroom;
 	unsigned int len;
 	__be16 proto;
 	bool csum;
 	int sg = !!(features & NETIF_F_SG);
-	int nfrags = skb_shinfo(skb)->nr_frags;
+	int cur_frag = 0, nfrags = skb_shinfo(cskb)->nr_frags;
+	unsigned int data_len, cur_frag_offset = 0;
 	int err = -ENOMEM;
-	int i = 0;
 	int pos;
 
-	proto = skb_network_protocol(skb);
+	proto = skb_network_protocol(head_skb);
 	if (unlikely(!proto))
 		return ERR_PTR(-EINVAL);
 
 	csum = !!can_checksum_protocol(features, proto);
-	__skb_push(skb, doffset);
-	headroom = skb_headroom(skb);
-	pos = skb_headlen(skb);
+	__skb_push(head_skb, doffset);
+	headroom = skb_headroom(head_skb);
+	pos = skb_headlen(head_skb);
 
-	do {
+	for (; tot_len < head_skb->len; tot_len += len) {
 		struct sk_buff *nskb;
 		skb_frag_t *frag;
 		int hsize;
 		int size;
 
-		len = skb->len - offset;
+		len = cskb->len - offset;
 		if (len > mss)
 			len = mss;
 
-		hsize = skb_headlen(skb) - offset;
+		hsize = skb_headlen(cskb) - offset;
 		if (hsize < 0)
 			hsize = 0;
 		if (hsize > len || !sg)
 			hsize = len;
 
-		if (!hsize && i >= nfrags) {
-			BUG_ON(fskb->len != len);
-
-			pos += len;
-			nskb = skb_clone(fskb, GFP_ATOMIC);
-			fskb = fskb->next;
+		nskb = __alloc_skb(hsize + doffset + headroom,
+				   GFP_ATOMIC, skb_alloc_rx_flag(head_skb),
+				   NUMA_NO_NODE);
 
-			if (unlikely(!nskb))
-				goto err;
-
-			hsize = skb_end_offset(nskb);
-			if (skb_cow_head(nskb, doffset + headroom)) {
-				kfree_skb(nskb);
-				goto err;
-			}
+		if (unlikely(!nskb))
+			goto err;
 
-			nskb->truesize += skb_end_offset(nskb) - hsize;
-			skb_release_head_state(nskb);
-			__skb_push(nskb, doffset);
-		} else {
-			nskb = __alloc_skb(hsize + doffset + headroom,
-					   GFP_ATOMIC, skb_alloc_rx_flag(skb),
-					   NUMA_NO_NODE);
-
-			if (unlikely(!nskb))
-				goto err;
-
-			skb_reserve(nskb, headroom);
-			__skb_put(nskb, doffset);
-		}
+		skb_reserve(nskb, headroom);
+		__skb_put(nskb, doffset);
 
 		if (segs)
 			tail->next = nskb;
@@ -2852,94 +2832,115 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			segs = nskb;
 		tail = nskb;
 
-		__copy_skb_header(nskb, skb);
-		nskb->mac_len = skb->mac_len;
+		__copy_skb_header(nskb, head_skb);
+		nskb->mac_len = head_skb->mac_len;
 
 		skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);
 
-		skb_copy_from_linear_data_offset(skb, -tnl_hlen,
+		skb_copy_from_linear_data_offset(head_skb, -tnl_hlen,
 						 nskb->data - tnl_hlen,
 						 doffset + tnl_hlen);
 
-		if (fskb != skb_shinfo(skb)->frag_list)
-			goto perform_csum_check;
-
 		if (!sg) {
 			nskb->ip_summed = CHECKSUM_NONE;
-			nskb->csum = skb_copy_and_csum_bits(skb, offset,
+			nskb->csum = skb_copy_and_csum_bits(head_skb, tot_len,
 							    skb_put(nskb, len),
 							    len, 0);
+			offset += len;
 			continue;
 		}
 
 		frag = skb_shinfo(nskb)->frags;
 
-		skb_copy_from_linear_data_offset(skb, offset,
+		skb_copy_from_linear_data_offset(cskb, offset,
 						 skb_put(nskb, hsize), hsize);
+		offset += hsize;
 
-		skb_shinfo(nskb)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
+		data_len = 0;
+		nskb->data_len = len - hsize;
+		nskb->len += nskb->data_len;
+		nskb->truesize += nskb->data_len;
 
-		while (pos < offset + len && i < nfrags) {
-			*frag = skb_shinfo(skb)->frags[i];
-			__skb_frag_ref(frag);
-			size = skb_frag_size(frag);
+		skb_shinfo(nskb)->tx_flags = skb_shinfo(head_skb)->tx_flags & SKBTX_SHARED_FRAG;
+
+		while (data_len < nskb->data_len) {
+			int remain = nskb->data_len - data_len;
 
-			if (pos < offset) {
-				frag->page_offset += offset - pos;
-				skb_frag_size_sub(frag, offset - pos);
+			if (unlikely(cur_frag >= nfrags)) {
+				if (cskb == head_skb)
+					cskb = skb_shinfo(head_skb)->frag_list;
+				else
+					cskb = cskb->next;
+				if (!cskb) {
+					WARN_ON_ONCE(1);
+					goto err;
+				}
+				cur_frag = 0;
+				cur_frag_offset = 0;
+				nfrags = skb_shinfo(cskb)->nr_frags;
+				offset = 0;
+				if (skb_headlen(cskb)) {
+					char *data;
+					struct page *page;
+
+					remain = min_t(int, remain, skb_headlen(cskb));
+					if (likely(cskb->head_frag)) {
+						data = cskb->data;
+						page = virt_to_head_page(data);
+						get_page(page);
+					} else {
+						data = __netdev_alloc_frag(SKB_DATA_ALIGN(remain),
+									   GFP_ATOMIC);
+						/* Really this should not happen, fix the caller ! */
+						WARN_ON_ONCE(1);
+						if (!data)
+							goto err;
+						memcpy(data, cskb->data, remain);
+						page = virt_to_head_page(data);
+					}
+					frag->page.p = page;
+					frag->page_offset = data - (char *)page_address(page);
+					skb_frag_size_set(frag, remain);
+					frag++;
+					offset = remain;
+					continue;
+				}
 			}
+			*frag = skb_shinfo(cskb)->frags[cur_frag];
+			__skb_frag_ref(frag);
+
+			frag->page_offset += cur_frag_offset;
+			skb_frag_size_sub(frag, cur_frag_offset);
+			size = skb_frag_size(frag);
 
 			skb_shinfo(nskb)->nr_frags++;
 
-			if (pos + size <= offset + len) {
-				i++;
-				pos += size;
+			if (size <= remain) {
+				cur_frag++;
+				cur_frag_offset = 0;
+				data_len += size;
 			} else {
-				skb_frag_size_sub(frag, pos + size - (offset + len));
-				goto skip_fraglist;
+				skb_frag_size_set(frag, remain);
+				data_len += remain;
+				cur_frag_offset += remain;
 			}
 
 			frag++;
 		}
 
-		if (pos < offset + len) {
-			struct sk_buff *fskb2 = fskb;
-
-			BUG_ON(pos + fskb->len != offset + len);
-
-			pos += fskb->len;
-			fskb = fskb->next;
-
-			if (fskb2->next) {
-				fskb2 = skb_clone(fskb2, GFP_ATOMIC);
-				if (!fskb2)
-					goto err;
-			} else
-				skb_get(fskb2);
-
-			SKB_FRAG_ASSERT(nskb);
-			skb_shinfo(nskb)->frag_list = fskb2;
-		}
-
-skip_fraglist:
-		nskb->data_len = len - hsize;
-		nskb->len += nskb->data_len;
-		nskb->truesize += nskb->data_len;
-
-perform_csum_check:
 		if (!csum) {
 			nskb->csum = skb_checksum(nskb, doffset,
 						  nskb->len - doffset, 0);
 			nskb->ip_summed = CHECKSUM_NONE;
 		}
-	} while ((offset += len) < skb->len);
+	}
 
 	return segs;
 
 err:
-	while ((skb = segs)) {
-		segs = skb->next;
-		kfree_skb(skb);
+	while ((cskb = segs)) {
+		segs = cskb->next;
+		kfree_skb(cskb);
 	}
 	return ERR_PTR(err);
 }
