From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 6 Nov 2013 20:39:00 +0800
Message-ID: <20131106123900.GA20259@gondor.apana.org.au>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103122824.GA17394@gondor.apana.org.au>
 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103163103.GA18894@gondor.apana.org.au>
 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41207 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756440Ab3KFMjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 07:39:09 -0500
Content-Disposition: inline
In-Reply-To: <20131106013038.GA14894@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 09:30:38AM +0800, Herbert Xu wrote:
> Here is a totally untested patch that tries to trivially process
> these new frags + frag_list skbs.  It should actually be trivial
> to make this generate TSO packets by just adding a gso_ok check
> and short-circuit.

That patch obviously didn't have a chance of working since I missed
a continue.

Here is a better version.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3735fad..409bd9b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2816,7 +2816,31 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			hsize = len;
 
 		if (!hsize && i >= nfrags) {
-			BUG_ON(fskb->len != len);
+			if (fskb->len != len) {
+				SKB_FRAG_ASSERT(fskb);
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
+				BUG_ON(fskb->next && tail->len != len);
+
+				len = fskb->len;
+				fskb = fskb->next;
+				continue;
+			}
 
 			pos += len;
 			nskb = skb_clone(fskb, GFP_ATOMIC);

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
