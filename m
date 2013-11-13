From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Handle new frag_list of frags GRO packets
Date: Wed, 13 Nov 2013 22:26:15 +0800
Message-ID: <20131113142615.GA1851@gondor.apana.org.au>
References: <20131107062234.GA31156@gondor.apana.org.au>
 <20131107070335.GA31638@gondor.apana.org.au>
 <20131107070647.GB31638@gondor.apana.org.au>
 <20131111185207.GA12277@gondor.apana.org.au>
 <1384305223.28458.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131113012920.GA27897@gondor.apana.org.au>
 <1384309034.28458.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131113022243.GA28204@gondor.apana.org.au>
 <20131113022525.GA28236@gondor.apana.org.au>
 <1384310704.28458.79.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:57046 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755161Ab3KMO0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 09:26:24 -0500
Content-Disposition: inline
In-Reply-To: <1384310704.28458.79.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 12, 2013 at 06:45:04PM -0800, Eric Dumazet wrote:
> On Wed, 2013-11-13 at 10:25 +0800, Herbert Xu wrote:
> 
> > So a better test for the time being would be to test with TSO
> > disabled in both cases.
> > 
> 
> GRO on, TSO off, little difference between two cases :
> 
> (Note some small things run in background, so these numbers are not
> ultra precise)

OK looks pretty sane.
 
> > In the mean time I'm cooking up a patch to generate TSO packets.
> 
> That would be very nice !

It's failing on my machine but I'm not certain whether it's a bug
in my patch or a bug in my NIC's TSO code.  So I'd appreciate it
if you can give this a spin on your mlx4.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 557e1a5..1302515 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2786,6 +2786,8 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	__be16 proto;
 	bool csum;
 	int sg = !!(features & NETIF_F_SG);
+	int gso_type = 0;
+	int gso_size = 0;
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	int err = -ENOMEM;
 	int i = 0;
@@ -2795,6 +2797,11 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	if (unlikely(!proto))
 		return ERR_PTR(-EINVAL);
 
+	if (net_gso_ok(gso_type, features)) {
+		gso_type = skb_shinfo(skb)->gso_type & ~SKB_GSO_DODGY;
+		gso_size = mss;
+	}
+
 	csum = !!can_checksum_protocol(features, proto);
 	__skb_push(skb, doffset);
 	headroom = skb_headroom(skb);
@@ -2807,7 +2814,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		int size;
 
 		len = skb->len - offset;
-		if (len > mss)
+		if (!gso_size && len > mss)
 			len = mss;
 
 		hsize = skb_headlen(skb) - offset;
@@ -2819,6 +2826,26 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		if (!hsize && i >= nfrags && skb_headlen(fskb) &&
 		    (skb_headlen(fskb) == len || sg)) {
 			BUG_ON(skb_headlen(fskb) > len);
+			SKB_FRAG_ASSERT(fskb);
+
+			nskb = skb_clone(fskb, GFP_ATOMIC);
+			if (unlikely(!nskb))
+				goto err;
+
+			if (gso_size) {
+				len = nskb->len;
+				pos += len;
+
+				skb_shinfo(nskb)->gso_segs = len / mss;
+
+				/*
+				 * Original GRO packet boundaries must
+				 * have been preserved.
+				 */
+				BUG_ON(fskb->next && len % mss);
+
+				goto skip_trim;
+			}
 
 			i = 0;
 			nfrags = skb_shinfo(fskb)->nr_frags;
@@ -2837,17 +2864,14 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 				skb_frag++;
 			}
 
-			nskb = skb_clone(fskb, GFP_ATOMIC);
-			fskb = fskb->next;
-
-			if (unlikely(!nskb))
-				goto err;
-
 			if (unlikely(pskb_trim(nskb, len))) {
 				kfree_skb(nskb);
 				goto err;
 			}
 
+skip_trim:
+			fskb = fskb->next;
+
 			hsize = skb_end_offset(nskb);
 			if (skb_cow_head(nskb, doffset + headroom)) {
 				kfree_skb(nskb);
@@ -2880,6 +2904,9 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 		skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);
 
+		skb_shinfo(nskb)->gso_size = gso_size;
+		skb_shinfo(nskb)->gso_type = gso_type;
+
 		skb_copy_from_linear_data_offset(skb, -tnl_hlen,
 						 nskb->data - tnl_hlen,
 						 doffset + tnl_hlen);
@@ -2902,6 +2929,41 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 		skb_shinfo(nskb)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
 
+		/*
+		 * virtio-net misery:
+		 *
+		 * Do a trial run for hardware GSO to get the proper length.
+		 */
+		if (pos < offset + len && gso_size) {
+			int j;
+
+			len = hsize - (offset - pos);
+
+			for (j = i; j < nfrags; j++)
+				len += skb_frag_size(skb_frag + j);
+
+			if (fskb && !skb_headlen(fskb)) {
+				j = min_t(int,
+					  skb_shinfo(fskb)->nr_frags,
+					  MAX_SKB_FRAGS - nfrags + i);
+
+				while (--j >= 0)
+					len += skb_frag_size(
+						skb_shinfo(fskb)->frags + j);
+			}
+
+			if (len < mss && offset + len < skb->len)
+				goto too_many_frags;
+
+			skb_shinfo(nskb)->gso_segs = len / mss;
+			if (len % mss) {
+				if (offset + len >= skb->len)
+					skb_shinfo(nskb)->gso_segs++;
+				else
+					len -= len % mss;
+			}
+		}
+
 		while (pos < offset + len) {
 			if (i >= nfrags) {
 				BUG_ON(skb_headlen(fskb));
@@ -2917,6 +2979,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 			if (unlikely(skb_shinfo(nskb)->nr_frags >=
 				     MAX_SKB_FRAGS)) {
+too_many_frags:
 				net_warn_ratelimited(
 					"skb_segment: too many frags: %u %u\n",
 					pos, mss);

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
