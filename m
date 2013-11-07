From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/3] gso: Handle malicious GRO packets without crashing
Date: Thu, 7 Nov 2013 15:08:47 +0800
Message-ID: <20131107070847.GC31638@gondor.apana.org.au>
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
Received: from ringil.hengli.com.au ([178.18.16.133]:52855 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752198Ab3KGHIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 02:08:54 -0500
Content-Disposition: inline
In-Reply-To: <20131107070647.GB31638@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As virtio_net can now generate GRO frag_list packets without
sufficient verification, we need to handle malicious GRO packets
thrown at us.

This patch converts to affected BUG_ONs in skb_segment to rate-
limited warnings.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bcc3f1c..fb1106d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2881,7 +2881,15 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			while (tail->next)
 				tail = tail->next;
 
-			BUG_ON(fskb && tail->len != len + doffset);
+			if (fskb && tail->len != len + doffset) {
+				net_warn_ratelimited(
+					"skb_segment: "
+					"illegal GSO fragment: %u %u\n",
+					tail->len, len + doffset);
+				kfree(nskb);
+				err = -EINVAL;
+				goto err;
+			}
 
 			len = nskb->len;
 			kfree(nskb);
@@ -2929,7 +2937,15 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
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
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
