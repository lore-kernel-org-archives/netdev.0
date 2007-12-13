From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Fix zero return value in xfrm_lookup on error
Date: Fri, 14 Dec 2007 00:44:48 +0800
Message-ID: <20071213164448.GA7310@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2809 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758261AbXLMQov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 11:44:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

Found another silly bug in my ICMP relookup patch.

[IPSEC]: Fix zero return value in xfrm_lookup on error

Further testing shows that my ICMP relookup patch can cause xfrm_lookup
to return zero on error which isn't very nice since it leads to the caller
dying on null pointer dereference.  The bug is due to not setting err
to ENOENT just before we leave xfrm_lookup in case of no policy.

This patch moves the err setting to where it should be.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b04d88c..d2084b1 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1469,8 +1469,6 @@ restart:
 			goto dropdst;
 	}
 
-	err = -ENOENT;
-
 	if (!policy) {
 		/* To accelerate a bit...  */
 		if ((dst_orig->flags & DST_NOXFRM) ||
@@ -1492,6 +1490,7 @@ restart:
 	npols ++;
 	xfrm_nr += pols[0]->xfrm_nr;
 
+	err = -ENOENT;
 	if ((flags & XFRM_LOOKUP_ICMP) && !(policy->flags & XFRM_POLICY_ICMP))
 		goto error;
 
@@ -1657,6 +1656,7 @@ dropdst:
 	return err;
 
 nopol:
+	err = -ENOENT;
 	if (flags & XFRM_LOOKUP_ICMP)
 		goto dropdst;
 	return 0;

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
