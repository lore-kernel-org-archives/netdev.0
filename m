From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gso: Handle new frag_list of frags GRO packets
Date: Tue, 12 Nov 2013 02:52:07 +0800
Message-ID: <20131111185207.GA12277@gondor.apana.org.au>
References: <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <20131106123900.GA20259@gondor.apana.org.au>
 <20131106133045.GA20931@gondor.apana.org.au>
 <20131106143927.GA21604@gondor.apana.org.au>
 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107004339.GA28156@gondor.apana.org.au>
 <20131107062234.GA31156@gondor.apana.org.au>
 <20131107070335.GA31638@gondor.apana.org.au>
 <20131107070647.GB31638@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:43056 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754941Ab3KKSwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 13:52:15 -0500
Content-Disposition: inline
In-Reply-To: <20131107070647.GB31638@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently GRO started generating packets with frag_lists of frags.
This was not handled by GSO, thus leading to a crash.

Thankfully these packets are of a regular form and are easy to
handle.  This patch handles them in two ways.  For completely
non-linear frag_list entries, we simply continue to iterate over
the frag_list frags once we exhaust the normal frags.  For frag_list
entries with linear parts, we call pskb_trim on the first part
of the frag_list skb, and then process the rest of the frags in
the usual way.

This patch also kills a chunk of dead frag_list code that has
obviously never ever been run since it ends up generating a bogus
GSO-segmented packet with a frag_list entry.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3735fad..557e1a5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2776,6 +2776,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	struct sk_buff *segs = NULL;
 	struct sk_buff *tail = NULL;
 	struct sk_buff *fskb = skb_shinfo(skb)->frag_list;
+	skb_frag_t *skb_frag = skb_shinfo(skb)->frags;
 	unsigned int mss = skb_shinfo(skb)->gso_size;
 	unsigned int doffset = skb->data - skb_mac_header(skb);
 	unsigned int offset = doffset;
@@ -2815,16 +2816,38 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		if (hsize > len || !sg)
 			hsize = len;
 
-		if (!hsize && i >= nfrags) {
-			BUG_ON(fskb->len != len);
+		if (!hsize && i >= nfrags && skb_headlen(fskb) &&
+		    (skb_headlen(fskb) == len || sg)) {
+			BUG_ON(skb_headlen(fskb) > len);
+
+			i = 0;
+			nfrags = skb_shinfo(fskb)->nr_frags;
+			skb_frag = skb_shinfo(fskb)->frags;
+			pos += skb_headlen(fskb);
+
+			while (pos < offset + len) {
+				BUG_ON(i >= nfrags);
+
+				size = skb_frag_size(skb_frag);
+				if (pos + size > offset + len)
+					break;
+
+				i++;
+				pos += size;
+				skb_frag++;
+			}
 
-			pos += len;
 			nskb = skb_clone(fskb, GFP_ATOMIC);
 			fskb = fskb->next;
 
 			if (unlikely(!nskb))
 				goto err;
 
+			if (unlikely(pskb_trim(nskb, len))) {
+				kfree_skb(nskb);
+				goto err;
+			}
+
 			hsize = skb_end_offset(nskb);
 			if (skb_cow_head(nskb, doffset + headroom)) {
 				kfree_skb(nskb);
@@ -2861,7 +2884,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 						 nskb->data - tnl_hlen,
 						 doffset + tnl_hlen);
 
-		if (fskb != skb_shinfo(skb)->frag_list)
+		if (nskb->len == len + doffset)
 			goto perform_csum_check;
 
 		if (!sg) {
@@ -2879,8 +2902,28 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 		skb_shinfo(nskb)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
 
-		while (pos < offset + len && i < nfrags) {
-			*frag = skb_shinfo(skb)->frags[i];
+		while (pos < offset + len) {
+			if (i >= nfrags) {
+				BUG_ON(skb_headlen(fskb));
+
+				i = 0;
+				nfrags = skb_shinfo(fskb)->nr_frags;
+				skb_frag = skb_shinfo(fskb)->frags;
+
+				BUG_ON(!nfrags);
+
+				fskb = fskb->next;
+			}
+
+			if (unlikely(skb_shinfo(nskb)->nr_frags >=
+				     MAX_SKB_FRAGS)) {
+				net_warn_ratelimited(
+					"skb_segment: too many frags: %u %u\n",
+					pos, mss);
+				goto err;
+			}
+
+			*frag = *skb_frag;
 			__skb_frag_ref(frag);
 			size = skb_frag_size(frag);
 
@@ -2893,6 +2936,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 			if (pos + size <= offset + len) {
 				i++;
+				skb_frag++;
 				pos += size;
 			} else {
 				skb_frag_size_sub(frag, pos + size - (offset + len));
@@ -2902,25 +2946,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
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
 skip_fraglist:
 		nskb->data_len = len - hsize;
 		nskb->len += nskb->data_len;

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
