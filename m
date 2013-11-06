From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 6 Nov 2013 21:30:45 +0800
Message-ID: <20131106133045.GA20931@gondor.apana.org.au>
References: <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103122824.GA17394@gondor.apana.org.au>
 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103163103.GA18894@gondor.apana.org.au>
 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <20131106123900.GA20259@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:60542 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932088Ab3KFNax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 08:30:53 -0500
Content-Disposition: inline
In-Reply-To: <20131106123900.GA20259@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 08:39:00PM +0800, Herbert Xu wrote:
> 
> That patch obviously didn't have a chance of working since I missed
> a continue.
> 
> Here is a better version.

In order to handle malicious GSO packets that is now possible with
the use of frag_list in virtio_net, we need to remove the BUG_ONs.
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3735fad..f336e5c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2816,7 +2816,44 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			hsize = len;
 
 		if (!hsize && i >= nfrags) {
-			BUG_ON(fskb->len != len);
+			if (fskb->len != len) {
+				if (skb_has_frag_list(fskb)) {
+					net_warn_ratelimited(
+						"skb_segment: "
+						"nested frag_list detected");
+					err = -EINVAL;
+					goto err;
+				}
+
+				nskb = skb_segment(fskb, features);
+
+				err = PTR_ERR(nskb);
+				if (IS_ERR(nskb))
+					goto err;
+				err = -ENOMEM;
+
+				if (segs)
+					tail->next = nskb;
+				else
+					segs = nskb;
+
+				tail = nskb;
+				while (tail->next)
+					tail = tail->next;
+
+				if (fskb->next && tail->len != len) {
+					net_warn_ratelimited(
+						"skb_segment: "
+						"illegal GSO fragment: %u %u",
+						tail->len, len);
+					err = -EINVAL;
+					goto err;
+				}
+
+				len = fskb->len;
+				fskb = fskb->next;
+				continue;
+			}
 
 			pos += len;
 			nskb = skb_clone(fskb, GFP_ATOMIC);
@@ -2905,7 +2942,14 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		if (pos < offset + len) {
 			struct sk_buff *fskb2 = fskb;
 
-			BUG_ON(pos + fskb->len != offset + len);
+			if (pos + fskb->len != offset + len) {
+				net_warn_ratelimited(
+					"skb_segment: "
+					"illegal GSO trailer: %u %u",
+					pos + fskb->len, offset + len);
+				err = -EINVAL;
+				goto err;
+			}
 
 			pos += fskb->len;
 			fskb = fskb->next;

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
