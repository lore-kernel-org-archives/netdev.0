From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Wed, 06 Apr 2005 07:45:06 +1000
Message-ID: <E1DIvr8-0002yy-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.58.0504051155260.13697@server.graphe.net>
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: christoph@lameter.com (Christoph Lameter)
In-Reply-To: <Pine.LNX.4.58.0504051155260.13697@server.graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@lameter.com> wrote:
> 
> Index: linux-2.6.11/net/core/dst.c
> ===================================================================
> --- linux-2.6.11.orig/net/core/dst.c    2005-03-01 23:38:12.000000000 -0800
> +++ linux-2.6.11/net/core/dst.c 2005-04-05 11:04:41.000000000 -0700
> @@ -198,7 +198,8 @@ again:
> 
>        dst = child;
>        if (dst) {
> -               if (atomic_dec_and_test(&dst->__refcnt)) {
> +               atomic_dec(&dst->__refcnt);
> +               if (!atomic_read(&dst->__refcnt)) {
>                        /* We were real parent of this dst, so kill child. */
>                        if (dst->flags&DST_NOHASH)
>                                goto again;

This is racy (albeit very unlikely) because dst may be freed by
dst_run_gc after the atomic_dec.

When we are not the real parent of the dst (e.g., when we're xfrm_dst
and the child is an rtentry), it may already be on the GC list.

In fact the current code is buggy to, we need to check dst->flags
before the dec as dst may no longer be valid afterwards.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/core/dst.c 1.28 vs edited =====
--- 1.28/net/core/dst.c	2005-02-16 09:23:10 +11:00
+++ edited/net/core/dst.c	2005-04-06 07:41:02 +10:00
@@ -198,13 +198,15 @@
 
 	dst = child;
 	if (dst) {
+		int nohash = dst->flags & DST_NOHASH;
+
 		if (atomic_dec_and_test(&dst->__refcnt)) {
 			/* We were real parent of this dst, so kill child. */
-			if (dst->flags&DST_NOHASH)
+			if (nohash)
 				goto again;
 		} else {
 			/* Child is still referenced, return it for freeing. */
-			if (dst->flags&DST_NOHASH)
+			if (nohash)
 				return dst;
 			/* Child is still in his hash table */
 		}
