From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 7 Nov 2013 08:43:40 +0800
Message-ID: <20131107004339.GA28156@gondor.apana.org.au>
References: <20131103122824.GA17394@gondor.apana.org.au>
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
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40513 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753001Ab3KGAoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 19:44:10 -0500
Content-Disposition: inline
In-Reply-To: <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 11:47:21AM -0800, Eric Dumazet wrote:
> On Wed, 2013-11-06 at 22:39 +0800, Herbert Xu wrote:
> 
> > In fact, we never relied on the frag_list having headers anyway so
> > it's not hard to fix this.
> > 
> > Still totally untested but at least this has a chance of handling
> > the new virtio_net.
> 
> First try, machine doesn't crash, but things are not working.
> 
> [  433.232553] skbuff: skb_segment: illegal GSO fragment: 1514 1448
> [  433.340523] skbuff: skb_segment: illegal GSO fragment: 1514 1448skbuff: skb_segment: illegal GSO fragment: 1514 1448
> [  433.340578] skbuff: skb_segment: illegal GSO fragment: 1514 1448skbuff: skb_segment: illegal GSO fragment: 1514 1448
> [  433.340598] skbuff: skb_segment: illegal GSO fragment: 1514 1448skbuff: skb_segment: illegal GSO fragment: 1514 1448
> [  433.340620] skbuff: skb_segment: illegal GSO fragment: 1514 1448skbuff: skb_segment: illegal GSO fragment: 1514 1448
> [  433.340661] skbuff: skb_segment: illegal GSO fragment: 1514 1448<4>[  438.313019] net_ratelimit: 141 callbacks suppressed
> 
> To test this, I used a regular forwarding path between three hosts
> 
> A --->  B ----> C
> 
> I'll try a different way.
> 
> The frag_list would contain a bunch of frags, that we logically add to the bunch
> of frags found in the first skb shared_info structure.

Yeah I screwed up with the test, it needs an additional doffset
since the tail already has the headers pushed:

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3735fad..f0f85e0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2816,8 +2816,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			hsize = len;
 
 		if (!hsize && i >= nfrags) {
-			BUG_ON(fskb->len != len);
-
 			pos += len;
 			nskb = skb_clone(fskb, GFP_ATOMIC);
 			fskb = fskb->next;
@@ -2846,12 +2844,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			__skb_put(nskb, doffset);
 		}
 
-		if (segs)
-			tail->next = nskb;
-		else
-			segs = nskb;
-		tail = nskb;
-
 		__copy_skb_header(nskb, skb);
 		nskb->mac_len = skb->mac_len;
 
@@ -2861,15 +2853,62 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 						 nskb->data - tnl_hlen,
 						 doffset + tnl_hlen);
 
-		if (fskb != skb_shinfo(skb)->frag_list)
-			goto perform_csum_check;
+		if (fskb != skb_shinfo(skb)->frag_list) {
+			struct sk_buff *nsegs;
+
+			if (nskb->len == len + doffset)
+				goto perform_csum_check;
+
+			if (skb_has_frag_list(nskb)) {
+				net_warn_ratelimited(
+					"skb_segment: "
+					"nested frag_list detected\n");
+				kfree(nskb);
+				err = -EINVAL;
+				goto err;
+			}
+
+			__skb_pull(nskb, doffset);
+			skb_shinfo(nskb)->gso_size = mss;
+			nsegs = skb_segment(nskb, features);
+
+			err = PTR_ERR(nsegs);
+			if (IS_ERR(nsegs)) {
+				kfree(nskb);
+				goto err;
+			}
+			err = -ENOMEM;
+
+			if (segs)
+				tail->next = nsegs;
+			else
+				segs = nsegs;
+
+			tail = nsegs;
+			while (tail->next)
+				tail = tail->next;
+
+			if (fskb && tail->len != len + doffset) {
+				net_warn_ratelimited(
+					"skb_segment: "
+					"illegal GSO fragment: %u %u\n",
+					tail->len, len + doffset);
+				kfree(nskb);
+				err = -EINVAL;
+				goto err;
+			}
+
+			len = nskb->len;
+			kfree(nskb);
+			continue;
+		}
 
 		if (!sg) {
 			nskb->ip_summed = CHECKSUM_NONE;
 			nskb->csum = skb_copy_and_csum_bits(skb, offset,
 							    skb_put(nskb, len),
 							    len, 0);
-			continue;
+			goto add_to_segs;
 		}
 
 		frag = skb_shinfo(nskb)->frags;
@@ -2905,15 +2944,25 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		if (pos < offset + len) {
 			struct sk_buff *fskb2 = fskb;
 
-			BUG_ON(pos + fskb->len != offset + len);
+			if (pos + fskb->len != offset + len) {
+				net_warn_ratelimited(
+					"skb_segment: "
+					"illegal GSO trailer: %u %u\n",
+					pos + fskb->len, offset + len);
+				kfree(nskb);
+				err = -EINVAL;
+				goto err;
+			}
 
 			pos += fskb->len;
 			fskb = fskb->next;
 
 			if (fskb2->next) {
 				fskb2 = skb_clone(fskb2, GFP_ATOMIC);
-				if (!fskb2)
+				if (!fskb2) {
+					kfree(nskb);
 					goto err;
+				}
 			} else
 				skb_get(fskb2);
 
@@ -2932,6 +2981,13 @@ perform_csum_check:
 						  nskb->len - doffset, 0);
 			nskb->ip_summed = CHECKSUM_NONE;
 		}
+
+add_to_segs:
+		if (segs)
+			tail->next = nskb;
+		else
+			segs = nskb;
+		tail = nskb;
 	} while ((offset += len) < skb->len);
 
 	return segs;

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
