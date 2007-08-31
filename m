From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/7] [PPP] generic: Call skb_cow_head before scribbling over skb
Date: Fri, 31 Aug 2007 17:11:35 +0800
Message-ID: <E1IR2XP-0007QP-00@gondolin.me.apana.org.au>
References: <20070831090625.GA28175@gondor.apana.org.au>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Herbert Xu <herbert@gondo
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3601 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759051AbXHaJLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:11:39 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IR2XQ-0004Rb-Ac
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 19:11:36 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1IR2XP-0007QP-00
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 17:11:35 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPP] generic: Call skb_cow_head before scribbling over skb

It's rude to write over data that other people are still using.  So call
skb_cow_head before PPP proceeds to modify the skb data.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/ppp_generic.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 9293c82..7e21342 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -899,17 +899,9 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Put the 2-byte PPP protocol number on the front,
 	   making sure there is room for the address and control fields. */
-	if (skb_headroom(skb) < PPP_HDRLEN) {
-		struct sk_buff *ns;
-
-		ns = alloc_skb(skb->len + dev->hard_header_len, GFP_ATOMIC);
-		if (ns == 0)
-			goto outf;
-		skb_reserve(ns, dev->hard_header_len);
-		skb_copy_bits(skb, 0, skb_put(ns, skb->len), skb->len);
-		kfree_skb(skb);
-		skb = ns;
-	}
+	if (skb_cow_head(skb, PPP_HDRLEN))
+		goto outf;
+
 	pp = skb_push(skb, 2);
 	proto = npindex_to_proto[npi];
 	pp[0] = proto >> 8;
