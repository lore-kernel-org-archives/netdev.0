From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] Fix neighbour tbl->entries race
Date: Sun, 7 Nov 2004 19:08:39 +1100
Message-ID: <20041107080839.GA26158@gondor.apana.org.au>
References: <20041102112651.GA8633@gondor.apana.org.au> <1099404823.1021.15.camel@jzny.localdomain> <20041102203720.GA12108@gondor.apana.org.au> <20041102210259.GA12642@gondor.apana.org.au> <20041102220603.GA13312@gondor.apana.org.au> <20041103155438.07a219ad.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041103155438.07a219ad.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Nov 03, 2004 at 03:54:38PM -0800, David S. Miller wrote:
> 
> Can you cook up a 2.4.x version of this Herbert?  The new neighbour
> code is now there too.

Sure.  BTW this bug is a lot older than the new neighbours code.
It's in the very first revision of neighbour.c :)

Here is a patch for 2.4.  I simply used atomic_read instead of
doing atomic_inc_return as in 2.6 since I thought that the
downside of going a bit over gc_thresh3 wasn't worth the
trouble of back-porting all the atomic_*_return work.

Of course if that ever gets backported then we can do what 2.6
does here too.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/neighbour.h 1.4 vs edited =====
--- 1.4/include/net/neighbour.h	2004-10-06 04:22:37 +10:00
+++ edited/include/net/neighbour.h	2004-11-07 19:03:05 +11:00
@@ -174,7 +174,7 @@
 	struct timer_list 	gc_timer;
 	struct timer_list 	proxy_timer;
 	struct sk_buff_head	proxy_queue;
-	int			entries;
+	atomic_t		entries;
 	rwlock_t		lock;
 	unsigned long		last_rand;
 	struct neigh_parms	*parms_list;
===== net/core/neighbour.c 1.14 vs edited =====
--- 1.14/net/core/neighbour.c	2004-10-06 04:40:25 +10:00
+++ edited/net/core/neighbour.c	2004-11-07 19:04:24 +11:00
@@ -257,11 +257,11 @@
 	struct neighbour *n;
 	unsigned long now = jiffies;
 
-	if (tbl->entries > tbl->gc_thresh3 ||
-	    (tbl->entries > tbl->gc_thresh2 &&
+	if (atomic_read(&tbl->entries) > tbl->gc_thresh3 ||
+	    (atomic_read(&tbl->entries) > tbl->gc_thresh2 &&
 	     now - tbl->last_flush > 5*HZ)) {
 		if (neigh_forced_gc(tbl) == 0 &&
-		    tbl->entries > tbl->gc_thresh3)
+		    atomic_read(&tbl->entries) > tbl->gc_thresh3)
 			return NULL;
 	}
 
@@ -282,7 +282,7 @@
 	n->timer.data = (unsigned long)n;
 	NEIGH_CACHE_STAT_INC(tbl, allocs);
 	neigh_glbl_allocs++;
-	tbl->entries++;
+	atomic_inc(&tbl->entries);
 	n->tbl = tbl;
 	atomic_set(&n->refcnt, 1);
 	n->dead = 1;
@@ -428,7 +428,7 @@
 	hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
 
 	write_lock_bh(&tbl->lock);
-	if (tbl->entries > (tbl->hash_mask + 1))
+	if (atomic_read(&tbl->entries) > (tbl->hash_mask + 1))
 		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
 	for (n1 = tbl->hash_buckets[hash_val]; n1; n1 = n1->next) {
 		if (dev == n1->dev &&
@@ -583,7 +583,7 @@
 	NEIGH_PRINTK2("neigh %p is destroyed.\n", neigh);
 
 	neigh_glbl_allocs--;
-	neigh->tbl->entries--;
+	atomic_dec(&neigh->tbl->entries);
 	kmem_cache_free(neigh->tbl->kmem_cachep, neigh);
 }
 
@@ -1306,7 +1306,7 @@
 	del_timer_sync(&tbl->proxy_timer);
 	pneigh_queue_purge(&tbl->proxy_queue);
 	neigh_ifdown(tbl, NULL);
-	if (tbl->entries)
+	if (atomic_read(&tbl->entries))
 		printk(KERN_CRIT "neighbour leakage\n");
 	write_lock(&neigh_tbl_lock);
 	for (tp = &neigh_tables; *tp; tp = &(*tp)->next) {
@@ -1858,7 +1858,7 @@
 
 	seq_printf(seq, "%08x  %08lx %08lx %08lx  %08lx %08lx  %08lx  "
 			"%08lx %08lx  %08lx %08lx\n",
-		   tbl->entries,
+		   atomic_read(&tbl->entries),
 
 		   st->allocs,
 		   st->destroys,

--HlL+5n6rz5pIUxbD--
