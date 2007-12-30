From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Fix double free on skb on async output
Date: Sun, 30 Dec 2007 23:36:04 +1100
Message-ID: <20071230123603.GA24629@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1759 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752146AbXL3MgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2007 07:36:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

Here's a fix for a silly bug on the async output path for IPsec.

[IPSEC]: Fix double free on skb on async output

When the output transform returns EINPROGRESS due to async operation we'll
free the skb the straight away as if it were an error.  This patch fixes
that so that the skb is freed when the async operation completes.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index c1ba63e..81ad8eb 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -78,6 +78,8 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		spin_unlock_bh(&x->lock);
 
 		err = x->type->output(x, skb);
+		if (err == -EINPROGRESS)
+			goto out_exit;
 
 resume:
 		if (err) {

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
