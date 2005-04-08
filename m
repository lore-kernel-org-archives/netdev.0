From: Christoph Lameter <christoph@lameter.com>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Thu, 7 Apr 2005 22:45:02 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504072221190.11242@graphe.net>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net>
 <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net>
 <20050407110724.GA8760@gondor.apana.org.au> <Pine.LNX.4.58.0504070842420.29731@graphe.net>
 <20050407212504.GA4939@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        pravins@calsoftinc.com, shai@scalesx86.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050407212504.GA4939@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Apr 2005, Herbert Xu wrote:

> I never said that it is better to treat them differently.  I wrote
> it like this earlier because I still had atomic_dec_and_test.
>
> > if ((dst->flags & DST_NOHASH)) {
> > 	/* dst not on hash and also not on gc list */
> > 	atomic_dec(&dst->__refcnt);
> > 	if (!atomic_read(&dst->refcnt))
> > 		/* We were the only reference kill child */
> > 		goto again;
> > 	/* return child to put it on the gc list */
> > 	return dst;
> > }
>
> BTW this patch is missing a barrier.

That was just some C code to explain what I meant. Here is a patch
against 2.6.12-rc2 with explanations as to what exactly is going on with
__refcnt so that we can avoid future confusion about this piece of code.
It removes the atomic_dec_and_test like the initial patch. I hope this
is acceptable now.

Signed-off-by: Christoph Lameter <christoph@lameter.com>

Index: linux-2.6.11/net/core/dst.c
===================================================================
--- linux-2.6.11.orig/net/core/dst.c	2005-03-01 23:38:12.000000000 -0800
+++ linux-2.6.11/net/core/dst.c	2005-04-07 22:39:09.000000000 -0700
@@ -191,23 +191,47 @@ again:
 		dst->ops->destroy(dst);
 	if (dst->dev)
 		dev_put(dst->dev);
-#if RT_CACHE_DEBUG >= 2
+#if RT_CACHE_DEBUG >= 2
 	atomic_dec(&dst_total);
 #endif
 	kmem_cache_free(dst->ops->kmem_cachep, dst);

 	dst = child;
 	if (dst) {
-		if (atomic_dec_and_test(&dst->__refcnt)) {
-			/* We were real parent of this dst, so kill child. */
-			if (dst->flags&DST_NOHASH)
+		/*
+		 * Note that the check for NO_HASH must be done before
+		 * decrementing the __refcnt. If __refcnt reaches zero
+		 * then the dst entry may be freed immediately by the gc
+		 * running on another cpu. Therefore no field of the dst
+		 * entry may be accessed after decrementing __refcnt
+		 */
+		if (dst->flags&DST_NOHASH) {
+			/*
+			 * The child is not on a hash table or on the gc list.
+			 * We are the owner and are the only ones who could
+			 * free the dst. There is no possibility of racing
+			 * with the gc code.
+			 */
+			atomic_dec(&dst->__refcnt);
+			smp_mb__after_atomic_dec();
+			if (!atomic_read(&dst->__refcnt))
+				/*
+				 * There are no other references and therefore
+				 * the dst can be freed now
+				 */
 				goto again;
-		} else {
-			/* Child is still referenced, return it for freeing. */
-			if (dst->flags&DST_NOHASH)
-				return dst;
-			/* Child is still in his hash table */
+
+			/*
+			 * Child is still referenced and will be put on the gc
+			 * list by the function invoking dst_destroy.
+			 */
+			return dst;
 		}
+
+		/*
+		 * Child is on the hash table. Just decrement the use counter.
+		 */
+		atomic_dec(&dst->__refcnt);
 	}
 	return NULL;
 }
