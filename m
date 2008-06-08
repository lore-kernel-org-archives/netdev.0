From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: pppoe: Unshare skb before anything else
Date: Sun, 8 Jun 2008 16:29:13 +1000
Message-ID: <20080608062913.GA20871@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54150 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753030AbYFHG3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2008 02:29:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

I noticed that my last patch to move the unshare in pppoe missed
the other spot which did the same thing:

pppoe: Unshare skb before anything else

We need to unshare the skb first as otherwise pskb_may_pull may
write to a shared skb which could be bad.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 58a26a4..3586d4a 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -427,12 +427,12 @@ static int pppoe_disc_rcv(struct sk_buff *skb,
 	if (dev_net(dev) != &init_net)
 		goto abort;
 
-	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
-		goto abort;
-
 	if (!(skb = skb_share_check(skb, GFP_ATOMIC)))
 		goto out;
 
+	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
+		goto abort;
+
 	ph = pppoe_hdr(skb);
 	if (ph->code != PADT_CODE)
 		goto abort;
