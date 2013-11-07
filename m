From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/3] gso: Add to segs at end of loop in skb_segment
Date: Thu, 7 Nov 2013 15:03:37 +0800
Message-ID: <20131107070335.GA31638@gondor.apana.org.au>
References: <20131103163103.GA18894@gondor.apana.org.au>
 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <20131106123900.GA20259@gondor.apana.org.au>
 <20131106133045.GA20931@gondor.apana.org.au>
 <20131106143927.GA21604@gondor.apana.org.au>
 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107004339.GA28156@gondor.apana.org.au>
 <20131107062234.GA31156@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50754 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751642Ab3KGHDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 02:03:46 -0500
Content-Disposition: inline
In-Reply-To: <20131107062234.GA31156@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the addition to the segs list to the end of the
loop in skb_segment.  This is to allow the following patch to add
a list to segs without including nskb.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3735fad..88b7dc6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2846,12 +2846,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
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
 
@@ -2869,7 +2863,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			nskb->csum = skb_copy_and_csum_bits(skb, offset,
 							    skb_put(nskb, len),
 							    len, 0);
-			continue;
+			goto add_to_segs;
 		}
 
 		frag = skb_shinfo(nskb)->frags;
@@ -2912,8 +2906,10 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 			if (fskb2->next) {
 				fskb2 = skb_clone(fskb2, GFP_ATOMIC);
-				if (!fskb2)
+				if (!fskb2) {
+					kfree(nskb);
 					goto err;
+				}
 			} else
 				skb_get(fskb2);
 
@@ -2932,6 +2928,13 @@ perform_csum_check:
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
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
