From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Do xfrm_state_check_space before encapsulation
Date: Wed, 19 Dec 2007 14:12:10 +0800
Message-ID: <20071219061210.GA6731@gondor.apana.org.au>
References: <4768A7CA.4090503@taca.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, usagi-core@linux-ipv6.org,
	netdev@vger.kernel.org
To: Kazunori MIYAZAWA <miyazawa@taca.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4226 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750878AbXLSGMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 01:12:22 -0500
Content-Disposition: inline
In-Reply-To: <4768A7CA.4090503@taca.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 19, 2007 at 02:10:34PM +0900, Kazunori MIYAZAWA wrote:
>
> Dec 19 11:31:44 hawaii kernel: ip6_rcv_finish: head=f7505000(**)
> Dec 19 11:31:44 hawaii kernel: ip6_rcv_finish: data=f7505020(**)
> Dec 19 11:31:44 hawaii kernel: xfrm6_tunnel_output: head=f7505000
> Dec 19 11:31:44 hawaii kernel: xfrm6_tunnel_output: data=f7505020

Sorry I introduced this bug when I moved the encapsulation output
function to the top of the loop.  Here's the fix.

[IPSEC]: Do xfrm_state_check_space before encapsulation

While merging the IPsec output path I moved the encapsulation output
operation to the top of the loop so that it sits outside of the locked
section.  Unfortunately in doing so it now sits in front of the space
check as well which could be a fatal error.

This patch rearranges the calls so that the space check happens as
the thing on the output path.

This patch also fixes an incorrect goto should the encapsulation output
fail.

Thanks to Kazunori MIYAZAWA for finding this bug.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 3c277a4..26fa0cb 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -33,16 +33,6 @@ static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
 	return 0;
 }
 
-static int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb)
-{
-	int err = xfrm_state_check_expire(x);
-	if (err < 0)
-		goto err;
-	err = xfrm_state_check_space(x, skb);
-err:
-	return err;
-}
-
 static int xfrm_output_one(struct sk_buff *skb, int err)
 {
 	struct dst_entry *dst = skb->dst;
@@ -52,12 +42,16 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		goto resume;
 
 	do {
+		err = xfrm_state_check_space(x, skb);
+		if (err)
+			goto error_nolock;
+
 		err = x->outer_mode->output(x, skb);
 		if (err)
-			goto error;
+			goto error_nolock;
 
 		spin_lock_bh(&x->lock);
-		err = xfrm_state_check(x, skb);
+		err = xfrm_state_check_expire(x);
 		if (err)
 			goto error;
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
