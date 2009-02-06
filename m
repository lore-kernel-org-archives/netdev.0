From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Fix frag_list merging on imprecisely split packets
Date: Fri, 6 Feb 2009 14:57:28 +1100
Message-ID: <20090206035728.GA4227@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46380 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752573AbZBFD5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 22:57:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Fix frag_list merging on imprecisely split packets

The previous fix ad0f9904444de1309dedd2b9e365cae8af77d9b1 (gro:
Fix handling of imprecisely split packets) only fixed the case
of frags merging, frag_list merging in the same circumstances
were still broken.

In particular, the packet headers end up in the data stream.

This patch fixes this plus another issue where an imprecisely
split packet header may be read incorrectly (this is mostly
harmless since it'll simply cause the packet to not match and
be rejected for GRO).

Thanks to Emil Tantilov and Jeff Kirsher for helping to track
this down.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 3337cf9..247f161 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2391,7 +2391,8 @@ void *skb_gro_header(struct sk_buff *skb, unsigned int hlen)
 		return pskb_may_pull(skb, hlen) ? skb->data + offset : NULL;
 
 	return page_address(skb_shinfo(skb)->frags[0].page) +
-	       skb_shinfo(skb)->frags[0].page_offset + offset;
+	       skb_shinfo(skb)->frags[0].page_offset +
+	       offset - skb_headlen(skb);
 }
 EXPORT_SYMBOL(skb_gro_header);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e55d1ef..67f2a2f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2678,6 +2678,17 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	p = nskb;
 
 merge:
+	if (skb_gro_offset(skb) > skb_headlen(skb)) {
+		skb_shinfo(skb)->frags[0].page_offset +=
+			skb_gro_offset(skb) - skb_headlen(skb);
+		skb_shinfo(skb)->frags[0].size -=
+			skb_gro_offset(skb) - skb_headlen(skb);
+		skb_gro_reset_offset(skb);
+		skb_gro_pull(skb, skb_headlen(skb));
+	}
+
+	__skb_pull(skb, skb_gro_offset(skb));
+
 	p->prev->next = skb;
 	p->prev = skb;
 	skb_header_release(skb);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
