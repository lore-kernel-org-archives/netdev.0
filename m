From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Mon, 11 Nov 2013 22:36:02 +0800
Message-ID: <20131111143602.GA10284@gondor.apana.org.au>
References: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
 <20131107.161755.355597965034457889.davem@davemloft.net>
 <20131107213111.GA6885@gondor.apana.org.au>
 <1383861288.9412.89.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131108035949.GA14325@gondor.apana.org.au>
 <1383884730.9412.175.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131110140540.GA1413@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:34445 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753345Ab3KKOgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 09:36:13 -0500
Content-Disposition: inline
In-Reply-To: <20131110140540.GA1413@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 10, 2013 at 10:05:41PM +0800, Herbert Xu wrote:
> 
> The main assumptions are that virtio_net frag_list is always non-
> linear and GRO frag_list may only contain a linear head part that
> is exactly MSS bytes long.

OK that assumption didn't work too well.  GRO frag_list can indeed
have a linear part followed by non-linear bits.  Instead we can
assume that the linear part is always less than our target size.

The following patch passes my tests and I will clean it up for
submission.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3735fad..3b3ad8b 100644
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
@@ -2815,16 +2816,29 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		if (hsize > len || !sg)
 			hsize = len;
 
-		if (!hsize && i >= nfrags) {
-			BUG_ON(fskb->len != len);
+		if (!hsize && i >= nfrags && skb_headlen(fskb)) {
+			BUG_ON(skb_headlen(fskb) > len);
+
+			i = 0;
+			nfrags = skb_shinfo(fskb)->nr_frags;
+			skb_frag = skb_shinfo(fskb)->frags;
+
+			for (pos += skb_headlen(fskb); pos < offset + len;
+			     i++, pos += skb_frag_size(skb_frag++))
+				BUG_ON(pos > offset + len ||
+				       i >= nfrags);
 
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
@@ -2861,7 +2875,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 						 nskb->data - tnl_hlen,
 						 doffset + tnl_hlen);
 
-		if (fskb != skb_shinfo(skb)->frag_list)
+		if (nskb->len == len + doffset)
 			goto perform_csum_check;
 
 		if (!sg) {
@@ -2879,8 +2893,28 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
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
 
@@ -2893,6 +2927,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 			if (pos + size <= offset + len) {
 				i++;
+				skb_frag++;
 				pos += size;
 			} else {
 				skb_frag_size_sub(frag, pos + size - (offset + len));
@@ -2902,25 +2937,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
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
