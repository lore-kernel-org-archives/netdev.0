From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec: Remove obsolete MAX_AH_AUTH_LEN
Date: Thu, 18 Sep 2014 16:38:18 +0800
Message-ID: <20140918083818.GA13056@gondor.apana.org.au>
References: <20140917045828.GA32086@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56553 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbaIRIid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 04:38:33 -0400
Content-Disposition: inline
In-Reply-To: <20140917045828.GA32086@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oops, should've sent this to Steffen:

While tracking down the MAX_AH_AUTH_LEN crash in an old kernel
I thought that this limit was rather arbitrary and we should
just get rid of it.

In fact it seems that we've already done all the work needed
to remove it apart from actually removing it.  This limit was
there in order to limit stack usage.  Since we've already
switched over to allocating scratch space using kmalloc, there
is no longer any need to limit the authentication length.

This patch kills all references to it, including the BUG_ONs
that led me here.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/net/ah.h b/include/net/ah.h
index ca95b98..4e2dfa4 100644
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -3,9 +3,6 @@
 
 #include <linux/skbuff.h>
 
-/* This is the maximum truncated ICV length that we know of. */
-#define MAX_AH_AUTH_LEN	64
-
 struct crypto_ahash;
 
 struct ah_data {
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index a2afa89..ac9a32e 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -505,8 +505,6 @@ static int ah_init_state(struct xfrm_state *x)
 	ahp->icv_full_len = aalg_desc->uinfo.auth.icv_fullbits/8;
 	ahp->icv_trunc_len = x->aalg->alg_trunc_len/8;
 
-	BUG_ON(ahp->icv_trunc_len > MAX_AH_AUTH_LEN);
-
 	if (x->props.flags & XFRM_STATE_ALIGN4)
 		x->props.header_len = XFRM_ALIGN4(sizeof(struct ip_auth_hdr) +
 						  ahp->icv_trunc_len);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 72a4930..2176893 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -713,8 +713,6 @@ static int ah6_init_state(struct xfrm_state *x)
 	ahp->icv_full_len = aalg_desc->uinfo.auth.icv_fullbits/8;
 	ahp->icv_trunc_len = x->aalg->alg_trunc_len/8;
 
-	BUG_ON(ahp->icv_trunc_len > MAX_AH_AUTH_LEN);
-
 	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) +
 					  ahp->icv_trunc_len);
 	switch (x->props.mode) {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d4db6eb..8cf382b 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -333,8 +333,7 @@ static int attach_auth_trunc(struct xfrm_algo_auth **algpp, u8 *props,
 	algo = xfrm_aalg_get_byname(ualg->alg_name, 1);
 	if (!algo)
 		return -ENOSYS;
-	if ((ualg->alg_trunc_len / 8) > MAX_AH_AUTH_LEN ||
-	    ualg->alg_trunc_len > algo->uinfo.auth.icv_fullbits)
+	if (ualg->alg_trunc_len > algo->uinfo.auth.icv_fullbits)
 		return -EINVAL;
 	*props = algo->desc.sadb_alg_id;
 
Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
