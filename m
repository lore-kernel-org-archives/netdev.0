From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/3] gso: Handle new frag_list of frags GRO packets
Date: Thu, 7 Nov 2013 15:06:47 +0800
Message-ID: <20131107070647.GB31638@gondor.apana.org.au>
References: <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <20131106123900.GA20259@gondor.apana.org.au>
 <20131106133045.GA20931@gondor.apana.org.au>
 <20131106143927.GA21604@gondor.apana.org.au>
 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107004339.GA28156@gondor.apana.org.au>
 <20131107062234.GA31156@gondor.apana.org.au>
 <20131107070335.GA31638@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:36969 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752010Ab3KGHGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 02:06:54 -0500
Content-Disposition: inline
In-Reply-To: <20131107070335.GA31638@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently GRO started generating packets with frag_lists of frags.
This was not handled by GSO, thus leading to a crash.

Thankfully these packets are of a regular form and are easy to
handle.  This patch handles them by calling skb_segment for each 
frag_list entry.  The depth of recursion is limited to just one.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 88b7dc6..bcc3f1c 100644
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
@@ -2855,8 +2853,40 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
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
+			SKB_FRAG_ASSERT(nskb);
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
+			BUG_ON(fskb && tail->len != len + doffset);
+
+			len = nskb->len;
+			kfree(nskb);
+			continue;
+		}
 
 		if (!sg) {
 			nskb->ip_summed = CHECKSUM_NONE;
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
