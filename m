From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Wed, 06 Apr 2005 18:32:54 +1000
Message-ID: <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net>
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: christoph@lameter.com (Christoph Lameter)
In-Reply-To: <Pine.LNX.4.58.0504051925250.21486@graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@lameter.com> wrote:
> 
> The atomic_dec_and_test is needed because as soon as the refcnt reaches
> zero the dst entry may potentially be freed by the garbage collector. Thus
> no future access to the dst entry is possible and the dec_and_test is the
> only safe way to figure out if the counter reached zero.
> 
> I hope I got it now. Thanks.

Yep you're totally correct.

In fact, the atomic_dec_and_test is really only needed for unhashed
entries (i.e., IPsec).  So we could do something like this so that
all hashed entries undergo atomic_dec.

This would only make sense if there were architectures where
atomic_dec is significantly cheaper compared to atomic_dec_and_test.

Do such beasts exist?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
--- linux-2.6/net/core/dst.c.orig	2005-04-06 18:29:00.000000000 +1000
+++ linux-2.6/net/core/dst.c	2005-04-06 18:26:46.000000000 +1000
@@ -197,20 +197,21 @@
 	kmem_cache_free(dst->ops->kmem_cachep, dst);
 
 	dst = child;
-	if (dst) {
-		int nohash = dst->flags & DST_NOHASH;
+	if (!dst)
+		return NULL;
 
+	if (dst->flags & DST_NOHASH) {
 		if (atomic_dec_and_test(&dst->__refcnt)) {
 			/* We were real parent of this dst, so kill child. */
-			if (nohash)
-				goto again;
+			goto again;
 		} else {
 			/* Child is still referenced, return it for freeing. */
-			if (nohash)
-				return dst;
-			/* Child is still in his hash table */
+			return dst;
 		}
 	}
+
+	/* Child is still in his hash table or on the GC list. */
+	atomic_dec(&dst->__refcnt);
 	return NULL;
 }
 
