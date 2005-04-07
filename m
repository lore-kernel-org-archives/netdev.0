From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Thu, 7 Apr 2005 21:07:24 +1000
Message-ID: <20050407110724.GA8760@gondor.apana.org.au>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net> <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="u3/rZRmxL6MmkK24"
Cc: christoph@lameter.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050406111721.3ac67605.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 06, 2005 at 11:17:21AM -0700, David S. Miller wrote:
> 
> See his other emails in this thread.  If it can be converted to
> atomic_dec() then he wants to change the counter into an array
> of counters on NUMA systems.
> 
> But his trick only works if the atomic_dec_and_test() can be eliminated
> for all cases, which we're now quite certain is not possible.

OK I've thought more about this and indeed it is possible to get rid of
atomic_dec_and_test.

As you can see from my previous patch, it is possible to restrict the
use of atomic_dec_and_test to the NOHASH path.

However, for NOHASH dst entries we know that

1) They're not in a hash table.
2) They're not on the GC list.

Therefore it is safe to look at the entry even after dropping our
reference count.

This is what the following patch does.

I added the unlikely on dst since entries with child pointers are
rare in most systems.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- linux-2.6/net/core/dst.c.orig	2005-04-07 20:48:25.000000000 +1000
+++ linux-2.6/net/core/dst.c	2005-04-07 20:57:33.000000000 +1000
@@ -169,9 +169,9 @@
 	struct neighbour *neigh;
 	struct hh_cache *hh;
 
+again:
 	smp_rmb();
 
-again:
 	neigh = dst->neighbour;
 	hh = dst->hh;
 	child = dst->child;
@@ -197,19 +197,19 @@
 	kmem_cache_free(dst->ops->kmem_cachep, dst);
 
 	dst = child;
-	if (dst) {
+	if (unlikely(dst)) {
 		int nohash = dst->flags & DST_NOHASH;
 
-		if (atomic_dec_and_test(&dst->__refcnt)) {
+		atomic_dec(&dst->__refcnt);
+
+		if (nohash) {
 			/* We were real parent of this dst, so kill child. */
-			if (nohash)
+			if (!atomic_read(&dst->__refcnt))
 				goto again;
-		} else {
 			/* Child is still referenced, return it for freeing. */
-			if (nohash)
-				return dst;
-			/* Child is still in his hash table */
+			return dst;
 		}
+		/* Child is still in his hash table or on the GC list. */
 	}
 	return NULL;
 }

--u3/rZRmxL6MmkK24--
