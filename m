From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] fix ref counting in __xfrm4_bundle_create()
Date: Sat, 29 May 2004 13:27:13 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BTuV7-0002m2-00@gondolin.me.apana.org.au>
References: <20040529001450.GA647@gate.ebshome.net>
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ebs@ebshome.net (Eugene Surovegin)
In-Reply-To: <20040529001450.GA647@gate.ebshome.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eugene Surovegin <ebs@ebshome.net> wrote:
> 
> Unfortunately, error path in __xfrm4_bundle_create() also calls xfrm_state_put() 
> (indirectly through dst_free() -> ... -> xfrm_dst_destroy()) and we end up 
> calling xfrm_state_put() _twice_.

Well spotted.  Hopefully this should finally put an end to all these
xfrm_state bug reports :)

However, can you see if the following patch fixes this problem as well?
It moves the dst->xfrm assignment to a spot where errors cannot occur.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/ipv4/xfrm4_policy.c 1.8 vs edited =====
--- 1.8/net/ipv4/xfrm4_policy.c	2004-03-20 14:35:32 +11:00
+++ edited/net/ipv4/xfrm4_policy.c	2004-05-29 13:01:39 +10:00
@@ -90,7 +90,6 @@
 			goto error;
 		}
 
-		dst1->xfrm = xfrm[i];
 		if (!dst)
 			dst = dst1;
 		else {
@@ -120,10 +119,12 @@
 		dst_hold(&rt->u.dst);
 	}
 	dst_prev->child = &rt->u.dst;
+	i = 0;
 	for (dst_prev = dst; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
 		x->u.rt.fl = *fl;
 
+		dst_prev->xfrm = xfrm[i++];
 		dst_prev->dev = rt->u.dst.dev;
 		if (rt->u.dst.dev)
 			dev_hold(rt->u.dst.dev);
===== net/ipv6/xfrm6_policy.c 1.16 vs edited =====
--- 1.16/net/ipv6/xfrm6_policy.c	2004-03-20 14:35:32 +11:00
+++ edited/net/ipv6/xfrm6_policy.c	2004-05-29 13:01:51 +10:00
@@ -107,7 +107,6 @@
 			goto error;
 		}
 
-		dst1->xfrm = xfrm[i];
 		if (!dst)
 			dst = dst1;
 		else {
@@ -139,9 +138,11 @@
 		dst_hold(&rt->u.dst);
 	}
 	dst_prev->child = &rt->u.dst;
+	i = 0;
 	for (dst_prev = dst; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
 
+		dst_prev->xfrm = xfrm[i++];
 		dst_prev->dev = rt->u.dst.dev;
 		if (rt->u.dst.dev)
 			dev_hold(rt->u.dst.dev);
===== net/xfrm/xfrm_policy.c 1.50 vs edited =====
--- 1.50/net/xfrm/xfrm_policy.c	2004-05-23 06:35:06 +10:00
+++ edited/net/xfrm/xfrm_policy.c	2004-05-29 12:52:41 +10:00
@@ -1017,6 +1017,8 @@
 
 static void xfrm_dst_destroy(struct dst_entry *dst)
 {
+	if (!dst->xfrm)
+		return;
 	xfrm_state_put(dst->xfrm);
 	dst->xfrm = NULL;
 }
