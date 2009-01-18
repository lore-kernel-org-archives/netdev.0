From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/3] gro: Fix merging of paged packets
Date: Sun, 18 Jan 2009 16:48:13 +1100
Message-ID: <20090118054813.GB24943@gondor.apana.org.au>
References: <20090118054616.GA24899@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56416 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753243AbZARFsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 00:48:15 -0500
Content-Disposition: inline
In-Reply-To: <20090118054616.GA24899@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The third fixes a serious bug in a previous bug fix.

gro: Fix merging of paged packets

The previous fix to paged packets broke the merging because it
reset the skb->len before we added it to the merged packet.  This
wasn't detected because it simply resulted in the truncation of
the packet while the missing bit is subsequently retransmitted.

The fix is to store skb->len before we clobber it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 65eac77..9127c47 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2588,8 +2588,9 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	struct sk_buff *nskb;
 	unsigned int headroom;
 	unsigned int hlen = p->data - skb_mac_header(p);
+	unsigned int len = skb->len;
 
-	if (hlen + p->len + skb->len >= 65536)
+	if (hlen + p->len + len >= 65536)
 		return -E2BIG;
 
 	if (skb_shinfo(p)->frag_list)
@@ -2651,9 +2652,9 @@ merge:
 
 done:
 	NAPI_GRO_CB(p)->count++;
-	p->data_len += skb->len;
-	p->truesize += skb->len;
-	p->len += skb->len;
+	p->data_len += len;
+	p->truesize += len;
+	p->len += len;
 
 	NAPI_GRO_CB(skb)->same_flow = 1;
 	return 0;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
