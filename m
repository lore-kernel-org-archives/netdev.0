From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Fix catch-22 with algorithm IDs above 31
Date: Tue, 22 Apr 2008 15:43:04 +0800
Message-ID: <20080422074304.GA18385@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Joy Latten <latten@us.ibm.com>,
	Tyler C Hicks <tchicks@us.ibm.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54448 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756112AbYDVHnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 03:43:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

[IPSEC]: Fix catch-22 with algorithm IDs above 31

As it stands it's impossible to use any authentication algorithms
with an ID above 31 portably.  It just happens to work on x86 but
fails miserably on ppc64.

The reason is that we're using a bit mask to check the algorithm
ID but the mask is only 32 bits wide.

After looking at how this is used in the field, I have concluded
that in the long term we should phase out state matching by IDs
because this is made superfluous by the reqid feature.  For current
applications, the best solution IMHO is to allow all algorithms when
the bit masks are all ~0.

The following patch does exactly that.

This bug was identified by IBM when testing on the ppc64 platform
using the NULL authentication algorithm which has an ID of 251.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b56b6a1..baa9f37 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -436,6 +436,9 @@ struct xfrm_tmpl
 /* May skip this transfomration if no SA is found */
 	__u8			optional;
 
+/* Skip aalgos/ealgos/calgos checks. */
+	__u8			allalgs;
+
 /* Bit mask of algos allowed for acquisition */
 	__u32			aalgos;
 	__u32			ealgos;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1fb0fe4..81a8e52 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1907,7 +1907,7 @@ parse_ipsecrequest(struct xfrm_policy *xp, struct sadb_x_ipsecrequest *rq)
 		t->encap_family = xp->family;
 
 	/* No way to set this via kame pfkey */
-	t->aalgos = t->ealgos = t->calgos = ~0;
+	t->allalgs = 1;
 	xp->xfrm_nr++;
 	return 0;
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ab4d0e5..e0c0390 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1819,7 +1819,7 @@ xfrm_state_ok(struct xfrm_tmpl *tmpl, struct xfrm_state *x,
 		(x->id.spi == tmpl->id.spi || !tmpl->id.spi) &&
 		(x->props.reqid == tmpl->reqid || !tmpl->reqid) &&
 		x->props.mode == tmpl->mode &&
-		((tmpl->aalgos & (1<<x->props.aalgo)) ||
+		(tmpl->allalgs || (tmpl->aalgos & (1<<x->props.aalgo)) ||
 		 !(xfrm_id_proto_match(tmpl->id.proto, IPSEC_PROTO_ANY))) &&
 		!(x->props.mode != XFRM_MODE_TRANSPORT &&
 		  xfrm_state_addr_cmp(tmpl, x, family));
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1810f56..22a30ae 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -981,6 +981,8 @@ static void copy_templates(struct xfrm_policy *xp, struct xfrm_user_tmpl *ut,
 		t->aalgos = ut->aalgos;
 		t->ealgos = ut->ealgos;
 		t->calgos = ut->calgos;
+		/* If all masks are ~0, then we allow all algorithms. */
+		t->allalgs = !~(t->aalgos & t->ealgos & t->calgos);
 		t->encap_family = ut->family;
 	}
 }
