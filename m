From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] Fix neighbour tbl->entries race
Date: Wed, 3 Nov 2004 09:06:03 +1100
Message-ID: <20041102220603.GA13312@gondor.apana.org.au>
References: <20041102112651.GA8633@gondor.apana.org.au> <1099404823.1021.15.camel@jzny.localdomain> <20041102203720.GA12108@gondor.apana.org.au> <20041102210259.GA12642@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zhXaljGHf11kAtnf"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20041102210259.GA12642@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Nov 03, 2004 at 08:02:59AM +1100, herbert wrote:
> 
> In fact, we can make it a bit more effective/fair by checking the
> previous entries count as well.

Call me a flip-flop :) This extra check is silly because in the
cases where it is done it is very unlikely to succeed.  So here
is yet another update without that check.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/neighbour.h 1.24 vs edited =====
--- 1.24/include/net/neighbour.h	2004-10-22 14:51:12 +10:00
+++ edited/include/net/neighbour.h	2004-11-03 07:56:07 +11:00
@@ -189,7 +189,7 @@
 	struct timer_list 	gc_timer;
 	struct timer_list 	proxy_timer;
 	struct sk_buff_head	proxy_queue;
-	int			entries;
+	atomic_t		entries;
 	rwlock_t		lock;
 	unsigned long		last_rand;
 	struct neigh_parms	*parms_list;
===== net/core/neighbour.c 1.54 vs edited =====
--- 1.54/net/core/neighbour.c	2004-10-06 04:37:37 +10:00
+++ edited/net/core/neighbour.c	2004-11-03 09:02:19 +11:00
@@ -254,18 +254,20 @@
 {
 	struct neighbour *n = NULL;
 	unsigned long now = jiffies;
+	int entries;
 
-	if (tbl->entries > tbl->gc_thresh3 ||
-	    (tbl->entries > tbl->gc_thresh2 &&
+	entries = atomic_inc_return(&tbl->entries) - 1;
+	if (entries >= tbl->gc_thresh3 ||
+	    (entries >= tbl->gc_thresh2 &&
 	     time_after(now, tbl->last_flush + 5 * HZ))) {
 		if (!neigh_forced_gc(tbl) &&
-		    tbl->entries > tbl->gc_thresh3)
-			goto out;
+		    entries >= tbl->gc_thresh3)
+			goto out_entries;
 	}
 
 	n = kmem_cache_alloc(tbl->kmem_cachep, SLAB_ATOMIC);
 	if (!n)
-		goto out;
+		goto out_entries;
 
 	memset(n, 0, tbl->entry_size);
 
@@ -281,12 +283,15 @@
 
 	NEIGH_CACHE_STAT_INC(tbl, allocs);
 	neigh_glbl_allocs++;
-	tbl->entries++;
 	n->tbl		  = tbl;
 	atomic_set(&n->refcnt, 1);
 	n->dead		  = 1;
 out:
 	return n;
+
+out_entries:
+	atomic_dec(&tbl->entries);
+	goto out;
 }
 
 static struct neighbour **neigh_hash_alloc(unsigned int entries)
@@ -427,7 +432,7 @@
 
 	write_lock_bh(&tbl->lock);
 
-	if (tbl->entries > (tbl->hash_mask + 1))
+	if (atomic_read(&tbl->entries) > (tbl->hash_mask + 1))
 		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
 
 	hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
@@ -608,7 +613,7 @@
 	NEIGH_PRINTK2("neigh %p is destroyed.\n", neigh);
 
 	neigh_glbl_allocs--;
-	neigh->tbl->entries--;
+	atomic_dec(&neigh->tbl->entries);
 	kmem_cache_free(neigh->tbl->kmem_cachep, neigh);
 }
 
@@ -1394,7 +1399,7 @@
 	del_timer_sync(&tbl->proxy_timer);
 	pneigh_queue_purge(&tbl->proxy_queue);
 	neigh_ifdown(tbl, NULL);
-	if (tbl->entries)
+	if (atomic_read(&tbl->entries))
 		printk(KERN_CRIT "neighbour leakage\n");
 	write_lock(&neigh_tbl_lock);
 	for (tp = &neigh_tables; *tp; tp = &(*tp)->next) {
@@ -1951,7 +1956,7 @@
 
 	seq_printf(seq, "%08x  %08lx %08lx %08lx  %08lx %08lx  %08lx  "
 			"%08lx %08lx  %08lx %08lx\n",
-		   tbl->entries,
+		   atomic_read(&tbl->entries),
 
 		   st->allocs,
 		   st->destroys,

--zhXaljGHf11kAtnf--
