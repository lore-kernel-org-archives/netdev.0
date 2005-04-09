From: Christoph Lameter <christoph@lameter.com>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Sat, 9 Apr 2005 08:28:13 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504090827230.15777@graphe.net>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net>
 <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net>
 <20050407110724.GA8760@gondor.apana.org.au> <Pine.LNX.4.58.0504070842420.29731@graphe.net>
 <20050407212504.GA4939@gondor.apana.org.au> <Pine.LNX.4.58.0504072221190.11242@graphe.net>
 <20050408054831.GA569@gondor.apana.org.au> <Pine.LNX.4.58.0504080803520.22345@graphe.net>
 <20050408214529.GA29716@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050408214529.GA29716@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 9 Apr 2005, Herbert Xu wrote:

> Anyway, here is my last patch again.

And here is my fixed up one:

Index: linux-2.6.11/net/core/dst.c
===================================================================
--- linux-2.6.11.orig/net/core/dst.c	2005-03-01 23:38:12.000000000 -0800
+++ linux-2.6.11/net/core/dst.c	2005-04-09 08:25:13.000000000 -0700
@@ -169,9 +169,8 @@ struct dst_entry *dst_destroy(struct dst
 	struct neighbour *neigh;
 	struct hh_cache *hh;

-	smp_rmb();
-
 again:
+	smp_rmb();
 	neigh = dst->neighbour;
 	hh = dst->hh;
 	child = dst->child;
@@ -191,23 +190,46 @@ again:
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
