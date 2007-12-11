From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Fix potential dst leak in xfrm_lookup
Date: Tue, 11 Dec 2007 20:07:29 +0800
Message-ID: <20071211120729.GA14088@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2745 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751638AbXLKMHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 07:07:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This patch fixes a possible dst leak that has existed for years.

[IPSEC]: Fix potential dst leak in xfrm_lookup

If we get an error during the actual policy lookup we don't free the
original dst while the caller expects us to always free the original
dst in case of error.

This patch fixes that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0cb3e8c..265c679 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1464,8 +1464,9 @@ restart:
 
 	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
 		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
+		err = PTR_ERR(policy);
 		if (IS_ERR(policy))
-			return PTR_ERR(policy);
+			goto dropdst;
 	}
 
 	if (!policy) {
@@ -1476,8 +1477,9 @@ restart:
 
 		policy = flow_cache_lookup(fl, dst_orig->ops->family,
 					   dir, xfrm_policy_lookup);
+		err = PTR_ERR(policy);
 		if (IS_ERR(policy))
-			return PTR_ERR(policy);
+			goto dropdst;
 	}
 
 	if (!policy)
@@ -1642,8 +1644,9 @@ restart:
 	return 0;
 
 error:
-	dst_release(dst_orig);
 	xfrm_pols_put(pols, npols);
+dropdst:
+	dst_release(dst_orig);
 	*dst_p = NULL;
 	return err;
 }

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
