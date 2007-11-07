From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/24] [IPV6]: Only set nfheader_len for top xfrm dst
Date: Wed, 07 Nov 2007 22:08:16 +0800
Message-ID: <E1IplZo-0001Fw-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3513 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757218AbXKGOIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Only set nfheader_len for top xfrm dst

We only need to set nfheader_len in the top xfrm dst.  This is because
we only ever read the nfheader_len from the top xfrm dst.

It is also easier to count nfheader_len as part of header_len which
then lets us remove the ugly wrapper functions for incrementing and
decrementing header lengths in xfrm6_policy.c.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/ip6_output.c   |    3 ++-
 net/ipv6/xfrm6_policy.c |   26 ++++----------------------
 2 files changed, 6 insertions(+), 23 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 653fc0a..6289dfc 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1096,7 +1096,8 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
-		exthdrlen = rt->u.dst.header_len + (opt ? opt->opt_flen : 0);
+		exthdrlen = rt->u.dst.header_len + (opt ? opt->opt_flen : 0) -
+			    rt->u.dst.nfheader_len;
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
 	} else {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 82e27b8..e5170bc 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -102,24 +102,6 @@ __xfrm6_bundle_addr_local(struct xfrm_state *x, struct in6_addr *addr)
 		(struct in6_addr*)&x->props.saddr;
 }
 
-static inline void
-__xfrm6_bundle_len_inc(int *len, int *nflen, struct xfrm_state *x)
-{
-	if (x->type->flags & XFRM_TYPE_NON_FRAGMENT)
-		*nflen += x->props.header_len;
-	else
-		*len += x->props.header_len;
-}
-
-static inline void
-__xfrm6_bundle_len_dec(int *len, int *nflen, struct xfrm_state *x)
-{
-	if (x->type->flags & XFRM_TYPE_NON_FRAGMENT)
-		*nflen -= x->props.header_len;
-	else
-		*len -= x->props.header_len;
-}
-
 /* Allocate chain of dst_entry's, attach known xfrm's, calculate
  * all the metrics... Shortly, bundle a bundle.
  */
@@ -142,7 +124,6 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 	int i;
 	int err = 0;
 	int header_len = 0;
-	int nfheader_len = 0;
 	int trailer_len = 0;
 
 	dst = dst_prev = NULL;
@@ -175,7 +156,9 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		dst1->next = dst_prev;
 		dst_prev = dst1;
 
-		__xfrm6_bundle_len_inc(&header_len, &nfheader_len, xfrm[i]);
+		if (xfrm[i]->type->flags & XFRM_TYPE_NON_FRAGMENT)
+			dst->nfheader_len += xfrm[i]->props.header_len;
+		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
 		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
@@ -223,7 +206,6 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		dst_prev->flags	       |= DST_HOST;
 		dst_prev->lastuse	= jiffies;
 		dst_prev->header_len	= header_len;
-		dst_prev->nfheader_len	= nfheader_len;
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
@@ -242,7 +224,7 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		x->u.rt6.rt6i_src      = rt0->rt6i_src;
 		x->u.rt6.rt6i_idev     = rt0->rt6i_idev;
 		in6_dev_hold(rt0->rt6i_idev);
-		__xfrm6_bundle_len_dec(&header_len, &nfheader_len, x->u.dst.xfrm);
+		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
 
