From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Sat, 9 Apr 2005 07:45:29 +1000
Message-ID: <20050408214529.GA29716@gondor.apana.org.au>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net> <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net> <20050407110724.GA8760@gondor.apana.org.au> <Pine.LNX.4.58.0504070842420.29731@graphe.net> <20050407212504.GA4939@gondor.apana.org.au> <Pine.LNX.4.58.0504072221190.11242@graphe.net> <20050408054831.GA569@gondor.apana.org.au> <Pine.LNX.4.58.0504080803520.22345@graphe.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="tKW2IUtsqtDRztdT"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@lameter.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0504080803520.22345@graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Apr 08, 2005 at 08:05:00AM -0700, Christoph Lameter wrote:
> On Fri, 8 Apr 2005, Herbert Xu wrote:
> 
> > This is wrong.  The barrier needs to be after the atomic_read.
> > Please see my patch to Dave.
> 
> Ok. How does one get onto the netdev list? The personal cc's of my mail

echo subscribe netdev | mail majordomo@oss.sgi.com

> to you also always bounces with admin prohibition.

Strange.  I'm getting your direct emails just fine.  In fact I'm
replying to it now.

Anyway, here is my last patch again.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--tKW2IUtsqtDRztdT
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

--tKW2IUtsqtDRztdT--
