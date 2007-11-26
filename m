From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/7] [IPSEC]: Lock state when copying non-atomic fields to user-space
Date: Mon, 26 Nov 2007 19:07:21 +0800
Message-ID: <20071126110720.GA26479@gondor.apana.org.au>
References: <20071009143517.GA20486@gondor.apana.org.au> <20071009.133307.88477317.davem@davemloft.net> <20071010004822.GB25265@gondor.apana.org.au> <200711261203.46195.nakam@linux-ipv6.org> <20071126031845.GA23417@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4144 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753535AbXKZLH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 06:07:29 -0500
Content-Disposition: inline
In-Reply-To: <20071126031845.GA23417@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 11:18:45AM +0800, Herbert Xu wrote:
>
> I'm just going to revert this patch for 2.6.24 since we've lived
> with this race for so long anyway.

Actually, instead of reverting it completely I'm just going to
remove the newly added locks which should be just as effective.

This would reduce the churn in the code as we'd be putting most
of it back soon anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 3b2d864..878039b 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1015,9 +1015,7 @@ static inline struct sk_buff *pfkey_xfrm_state2msg(struct xfrm_state *x)
 {
 	struct sk_buff *skb;
 
-	spin_lock_bh(&x->lock);
 	skb = __pfkey_xfrm_state2msg(x, 1, 3);
-	spin_unlock_bh(&x->lock);
 
 	return skb;
 }
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d41588d..e75dbdc 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -507,7 +507,6 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 				    struct xfrm_usersa_info *p,
 				    struct sk_buff *skb)
 {
-	spin_lock_bh(&x->lock);
 	copy_to_user_state(x, p);
 
 	if (x->coaddr)
@@ -515,7 +514,6 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 
 	if (x->lastused)
 		NLA_PUT_U64(skb, XFRMA_LASTUSED, x->lastused);
-	spin_unlock_bh(&x->lock);
 
 	if (x->aalg)
 		NLA_PUT(skb, XFRMA_ALG_AUTH, alg_len(x->aalg), x->aalg);
