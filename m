From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Tue, 29 Aug 2006 16:00:22 -0700
Message-ID: <20060829160022.552d46e0@dxpl.pdx.osdl.net>
References: <20060828230748.827712918@localhost.localdomain>
	<20060828230915.587544687@localhost.localdomain>
	<20060829152816.GA24283@ms2.inr.ac.ru>
	<20060829112204.0cf5e866@localhost.localdomain>
	<20060829211722.GA27855@ms2.inr.ac.ru>
	<20060829144608.012f0d60@dxpl.pdx.osdl.net>
	<20060829221606.GA10285@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45707 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964960AbWH2XA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 19:00:56 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060829221606.GA10285@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is the full version of neigh_lookup_rcu().

The race of interest is what happens when neigh_lookup_rcu() returns a table
entry and it gets deleted at the same time. See Documentation/RCU/listRCU.txt
for more info.

There are a couple different scenario's.

1) update or reader looking at dead entry.  The neighbour entry is queued on the
   rcu callback list, and will not be invoked until all cpu's have cleared
   the barrier.  The reader's do see stale data but it is harmless.
   After reader has cleared critical section, the neigh_rcu_release is run
   and that calls neigh_release which sees last reference and calls neigh_destroy.

   neigh_lookup_rcu checks for dead entries, but this is racy and can miss.
   It is just an attempt to close the window slightly.

2) caller wants to create or update entry (__neigh_lookup).  caller gets
   just deleted entry (refcount still 1), then grabs refcount (now 2).
   Similar to above, but the actual neigh_destroy() happens either
   from rcu callback or neigh_release() in caller, which ever is last.


This should not be any more racy than the existing code.

---
 drivers/infiniband/core/addr.c |    7 -
 drivers/net/wireless/strip.c   |   11 +-
 include/net/neighbour.h        |   43 +++++---
 net/core/neighbour.c           |  197 ++++++++++++++++++++++-------------------
 net/ipv4/arp.c                 |   10 +-
 net/ipv6/ndisc.c               |    7 -
 6 files changed, 155 insertions(+), 120 deletions(-)

--- net-2.6.19.orig/include/net/neighbour.h
+++ net-2.6.19/include/net/neighbour.h
@@ -108,6 +108,7 @@ struct neighbour
 	struct sk_buff_head	arp_queue;
 	struct timer_list	timer;
 	struct neigh_ops	*ops;
+	struct rcu_head		rcu;
 	u8			primary_key[0];
 };
 
@@ -126,6 +127,7 @@ struct pneigh_entry
 {
 	struct hlist_node	hlist;
 	struct net_device	*dev;
+	struct rcu_head		rcu;
 	u8			key[0];
 };
 
@@ -157,7 +159,7 @@ struct neigh_table
 	struct timer_list 	proxy_timer;
 	struct sk_buff_head	proxy_queue;
 	atomic_t		entries;
-	rwlock_t		lock;
+	spinlock_t		lock;
 	unsigned long		last_rand;
 	kmem_cache_t		*kmem_cachep;
 	struct neigh_statistics	*stats;
@@ -181,9 +183,9 @@ struct neigh_table
 extern void			neigh_table_init(struct neigh_table *tbl);
 extern void			neigh_table_init_no_netlink(struct neigh_table *tbl);
 extern int			neigh_table_clear(struct neigh_table *tbl);
-extern struct neighbour *	neigh_lookup(struct neigh_table *tbl,
-					     const void *pkey,
-					     struct net_device *dev);
+extern struct neighbour *	neigh_lookup_rcu(struct neigh_table *tbl,
+						 const void *pkey,
+						 const struct net_device *dev);
 extern struct neighbour *	neigh_lookup_nodev(struct neigh_table *tbl,
 						   const void *pkey);
 extern struct neighbour *	neigh_create(struct neigh_table *tbl,
@@ -313,27 +315,38 @@ static inline int neigh_event_send(struc
 
 static inline struct neighbour *__neigh_lookup(struct neigh_table *tbl,
 					       const void *pkey,
-					       struct net_device *dev, int creat)
+					       struct net_device *dev,
+					       int creat)
 {
-	struct neighbour *n = neigh_lookup(tbl, pkey, dev);
-
-	if (n || !creat)
-		return n;
+	struct neighbour *n;
 
-	n = neigh_create(tbl, pkey, dev);
-	return IS_ERR(n) ? NULL : n;
+	rcu_read_lock();
+	n = neigh_lookup_rcu(tbl, pkey, dev);
+	if (n)
+		neigh_hold(n);
+	else if (creat) {
+		n = neigh_create(tbl, pkey, dev);
+		if (IS_ERR(n))
+			n = NULL;
+	}
+	rcu_read_unlock();
+	return n;
 }
 
 static inline struct neighbour *__neigh_lookup_errno(struct neigh_table *tbl,
 						     const void *pkey,
 						     struct net_device *dev)
 {
-	struct neighbour *n = neigh_lookup(tbl, pkey, dev);
+	struct neighbour *n;
 
+	rcu_read_lock();
+	n = neigh_lookup_rcu(tbl, pkey, dev);
 	if (n)
-		return n;
-
-	return neigh_create(tbl, pkey, dev);
+		neigh_hold(n);
+	else
+		n = neigh_create(tbl, pkey, dev);
+	rcu_read_unlock();
+	return n;
 }
 
 struct neighbour_cb {
--- net-2.6.19.orig/net/core/neighbour.c
+++ net-2.6.19/net/core/neighbour.c
@@ -67,9 +67,10 @@ static struct file_operations neigh_stat
 #endif
 
 /*
-   Neighbour hash table buckets are protected with rwlock tbl->lock.
+   Neighbour hash table buckets are protected with lock tbl->lock.
 
-   - All the scans/updates to hash buckets MUST be made under this lock.
+   - All the scans of hash buckes must be made with RCU read lock (nopreempt)
+   - updates to hash buckets MUST be made under this lock.
    - NOTHING clever should be made under this lock: no callbacks
      to protocol backends, no attempts to send something to network.
      It will result in deadlocks, if backend/driver wants to use neighbour
@@ -116,6 +117,17 @@ unsigned long neigh_rand_reach_time(unsi
 	return (base ? (net_random() % base) + (base >> 1) : 0);
 }
 
+/*
+ * After all readers have finished this read-side critical section
+ * decrement ref count and free. If reader raced with us they
+ * may still have harmless dead reference.
+ */
+static void neigh_rcu_release(struct rcu_head *head)
+{
+	struct neighbour *neigh = container_of(head, struct neighbour, rcu);
+
+	neigh_release(neigh);
+}
 
 static int neigh_forced_gc(struct neigh_table *tbl)
 {
@@ -124,7 +136,7 @@ static int neigh_forced_gc(struct neigh_
 
 	NEIGH_CACHE_STAT_INC(tbl, forced_gc_runs);
 
-	write_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 	for (i = 0; i <= tbl->hash_mask; i++) {
 		struct neighbour *n;
 		struct hlist_node *node, *tmp;
@@ -138,11 +150,11 @@ static int neigh_forced_gc(struct neigh_
 			write_lock(&n->lock);
 			if (atomic_read(&n->refcnt) == 1 &&
 			    !(n->nud_state & NUD_PERMANENT)) {
-				hlist_del(&n->hlist);
+				hlist_del_rcu(&n->hlist);
 				n->dead = 1;
 				shrunk	= 1;
 				write_unlock(&n->lock);
-				neigh_release(n);
+				call_rcu(&n->rcu, neigh_rcu_release);
 				continue;
 			}
 			write_unlock(&n->lock);
@@ -151,7 +163,7 @@ static int neigh_forced_gc(struct neigh_
 
 	tbl->last_flush = jiffies;
 
-	write_unlock_bh(&tbl->lock);
+	spin_unlock_bh(&tbl->lock);
 
 	return shrunk;
 }
@@ -189,10 +201,10 @@ static void neigh_flush_dev(struct neigh
 			if (dev && n->dev != dev)
 				continue;
 
-			hlist_del(&n->hlist);
 			write_lock(&n->lock);
-			neigh_del_timer(n);
+			hlist_del_rcu(&n->hlist);
 			n->dead = 1;
+			neigh_del_timer(n);
 
 			if (atomic_read(&n->refcnt) != 1) {
 				/* The most unpleasant situation.
@@ -213,24 +225,25 @@ static void neigh_flush_dev(struct neigh
 				NEIGH_PRINTK2("neigh %p is stray.\n", n);
 			}
 			write_unlock(&n->lock);
-			neigh_release(n);
+
+			call_rcu(&n->rcu, neigh_rcu_release);
 		}
 	}
 }
 
 void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev)
 {
-	write_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 	neigh_flush_dev(tbl, dev);
-	write_unlock_bh(&tbl->lock);
+	spin_unlock_bh(&tbl->lock);
 }
 
 int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 {
-	write_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 	neigh_flush_dev(tbl, dev);
 	pneigh_ifdown(tbl, dev);
-	write_unlock_bh(&tbl->lock);
+	spin_unlock_bh(&tbl->lock);
 
 	del_timer_sync(&tbl->proxy_timer);
 	pneigh_queue_purge(&tbl->proxy_queue);
@@ -326,8 +339,8 @@ static void neigh_hash_grow(struct neigh
 			unsigned int hash_val = tbl->hash(n->primary_key, n->dev);
 
 			hash_val &= new_hash_mask;
-			hlist_del(&n->hlist);
-			hlist_add_head(&n->hlist, &new_hash[hash_val]);
+			__hlist_del(&n->hlist);
+			hlist_add_head_rcu(&n->hlist, &new_hash[hash_val]);
 		}
 	}
 	tbl->hash_buckets = new_hash;
@@ -336,8 +349,12 @@ static void neigh_hash_grow(struct neigh
 	neigh_hash_free(old_hash, old_entries);
 }
 
-struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
-			       struct net_device *dev)
+/*
+ * Lookup device and key in neighbour table.
+ * Assumed rcu_read_lock is held
+ */
+struct neighbour *neigh_lookup_rcu(struct neigh_table *tbl, const void *pkey,
+				   const struct net_device *dev)
 {
 	struct neighbour *n;
 	struct hlist_node *tmp;
@@ -346,18 +363,14 @@ struct neighbour *neigh_lookup(struct ne
 	
 	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
-	read_lock_bh(&tbl->lock);
-	hlist_for_each_entry(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
-		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
-			neigh_hold(n);
+	hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
+		if (!n->dead && dev == n->dev
+		    && !memcmp(n->primary_key, pkey, key_len)) {
 			NEIGH_CACHE_STAT_INC(tbl, hits);
-			goto found;
+			return n;
 		}
 	}
-	n = NULL;
-found:
-	read_unlock_bh(&tbl->lock);
-	return n;
+	return NULL;
 }
 
 struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, const void *pkey)
@@ -369,9 +382,9 @@ struct neighbour *neigh_lookup_nodev(str
 
 	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
-	read_lock_bh(&tbl->lock);
-	hlist_for_each_entry(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
-		if (!memcmp(n->primary_key, pkey, key_len)) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
+		if (!n->dead && !memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
 			goto found;
@@ -379,7 +392,7 @@ struct neighbour *neigh_lookup_nodev(str
 	}
 	n = NULL;
 found:
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 	return n;
 }
 
@@ -416,7 +429,7 @@ struct neighbour *neigh_create(struct ne
 
 	n->confirmed = jiffies - (n->parms->base_reachable_time << 1);
 
-	write_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 
 	if (atomic_read(&tbl->entries) > (tbl->hash_mask + 1))
 		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
@@ -436,21 +449,22 @@ struct neighbour *neigh_create(struct ne
 		}
 	}
 
-	hlist_add_head(&n->hlist, &tbl->hash_buckets[hash_val]);
 	n->dead = 0;
 	neigh_hold(n);
-	write_unlock_bh(&tbl->lock);
+	hlist_add_head_rcu(&n->hlist, &tbl->hash_buckets[hash_val]);
+	spin_unlock_bh(&tbl->lock);
 	NEIGH_PRINTK2("neigh %p is created.\n", n);
 	rc = n;
 out:
 	return rc;
 out_tbl_unlock:
-	write_unlock_bh(&tbl->lock);
+	spin_unlock_bh(&tbl->lock);
 out_neigh_release:
 	neigh_release(n);
 	goto out;
 }
 
+/* Assumes rcu_read_lock is held */
 struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl, const void *pkey,
 				    struct net_device *dev, int creat)
 {
@@ -464,16 +478,14 @@ struct pneigh_entry * pneigh_lookup(stru
 	hash_val ^= hash_val >> 4;
 	hash_val &= PNEIGH_HASHMASK;
 
-	read_lock_bh(&tbl->lock);
-
-	hlist_for_each_entry(n, tmp, &tbl->phash_buckets[hash_val], hlist) {
+	hlist_for_each_entry_rcu(n, tmp, &tbl->phash_buckets[hash_val], hlist) {
 		if (!memcmp(n->key, pkey, key_len) &&
 		    (n->dev == dev || !n->dev)) {
-			read_unlock_bh(&tbl->lock);
+			rcu_read_unlock();
 			goto out;
 		}
 	}
-	read_unlock_bh(&tbl->lock);
+
 	n = NULL;
 	if (!creat)
 		goto out;
@@ -495,13 +507,18 @@ struct pneigh_entry * pneigh_lookup(stru
 		goto out;
 	}
 
-	write_lock_bh(&tbl->lock);
-	hlist_add_head(&n->hlist, &tbl->phash_buckets[hash_val]);
-	write_unlock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
+	hlist_add_head_rcu(&n->hlist, &tbl->phash_buckets[hash_val]);
+	spin_unlock_bh(&tbl->lock);
 out:
 	return n;
 }
 
+static void pneigh_destroy(struct rcu_head *head)
+{
+	struct pneigh_entry *n = container_of(head, struct pneigh_entry, rcu);
+	kfree(n);
+}
 
 int pneigh_delete(struct neigh_table *tbl, const void *pkey,
 		  struct net_device *dev)
@@ -516,20 +533,20 @@ int pneigh_delete(struct neigh_table *tb
 	hash_val ^= hash_val >> 4;
 	hash_val &= PNEIGH_HASHMASK;
 
-	write_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 	hlist_for_each_entry(n, tmp, &tbl->phash_buckets[hash_val], hlist) {
 		if (!memcmp(n->key, pkey, key_len) && n->dev == dev) {
-			hlist_del(&n->hlist);
-			write_unlock_bh(&tbl->lock);
+			hlist_del_rcu(&n->hlist);
+			spin_unlock_bh(&tbl->lock);
 			if (tbl->pdestructor)
 				tbl->pdestructor(n);
 			if (n->dev)
 				dev_put(n->dev);
-			kfree(n);
+			call_rcu(&n->rcu, pneigh_destroy);
 			return 0;
 		}
 	}
-	write_unlock_bh(&tbl->lock);
+	spin_unlock_bh(&tbl->lock);
 	return -ENOENT;
 }
 
@@ -543,7 +560,7 @@ static int pneigh_ifdown(struct neigh_ta
 
 		hlist_for_each_entry_safe(n, tmp, nxt, &tbl->phash_buckets[h], hlist) {
 			if (!dev || n->dev == dev) {
-				hlist_del(&n->hlist);
+				hlist_del_rcu(&n->hlist);
 				if (tbl->pdestructor)
 					tbl->pdestructor(n);
 				if (n->dev)
@@ -644,7 +661,7 @@ static void neigh_periodic_timer(unsigne
 
 	NEIGH_CACHE_STAT_INC(tbl, periodic_gc_runs);
 
-	write_lock(&tbl->lock);
+	spin_lock(&tbl->lock);
 
 	/*
 	 *	periodically recompute ReachableTime from random function
@@ -676,7 +693,7 @@ static void neigh_periodic_timer(unsigne
 		if (atomic_read(&n->refcnt) == 1 &&
 		    (state == NUD_FAILED ||
 		     time_after(now, n->used + n->parms->gc_staletime))) {
-			hlist_del(&n->hlist);
+			hlist_del_rcu(&n->hlist);
 			n->dead = 1;
 			write_unlock(&n->lock);
 			neigh_release(n);
@@ -697,7 +714,7 @@ static void neigh_periodic_timer(unsigne
 
  	mod_timer(&tbl->gc_timer, now + expire);
 
-	write_unlock(&tbl->lock);
+	spin_unlock(&tbl->lock);
 }
 
 static __inline__ int neigh_max_probes(struct neighbour *n)
@@ -1285,10 +1302,10 @@ struct neigh_parms *neigh_parms_alloc(st
 			p->dev = dev;
 		}
 		p->sysctl_table = NULL;
-		write_lock_bh(&tbl->lock);
+		spin_lock_bh(&tbl->lock);
 		p->next		= tbl->parms.next;
 		tbl->parms.next = p;
-		write_unlock_bh(&tbl->lock);
+		spin_unlock_bh(&tbl->lock);
 	}
 	return p;
 }
@@ -1307,19 +1324,19 @@ void neigh_parms_release(struct neigh_ta
 
 	if (!parms || parms == &tbl->parms)
 		return;
-	write_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 	for (p = &tbl->parms.next; *p; p = &(*p)->next) {
 		if (*p == parms) {
 			*p = parms->next;
 			parms->dead = 1;
-			write_unlock_bh(&tbl->lock);
+			spin_unlock_bh(&tbl->lock);
 			if (parms->dev)
 				dev_put(parms->dev);
 			call_rcu(&parms->rcu_head, neigh_rcu_free_parms);
 			return;
 		}
 	}
-	write_unlock_bh(&tbl->lock);
+	spin_unlock_bh(&tbl->lock);
 	NEIGH_PRINTK1("neigh_parms_release: not found\n");
 }
 
@@ -1365,7 +1382,7 @@ void neigh_table_init_no_netlink(struct 
 
 	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
 
-	rwlock_init(&tbl->lock);
+	spin_lock_init(&tbl->lock);
 	init_timer(&tbl->gc_timer);
 	tbl->gc_timer.data     = (unsigned long)tbl;
 	tbl->gc_timer.function = neigh_periodic_timer;
@@ -1463,7 +1480,8 @@ int neigh_delete(struct sk_buff *skb, st
 		if (dev == NULL)
 			goto out_dev_put;
 
-		neigh = neigh_lookup(tbl, nla_data(dst_attr), dev);
+		rcu_read_lock();
+		neigh = neigh_lookup_rcu(tbl, nla_data(dst_attr), dev);
 		if (neigh == NULL) {
 			err = -ENOENT;
 			goto out_dev_put;
@@ -1472,7 +1490,7 @@ int neigh_delete(struct sk_buff *skb, st
 		err = neigh_update(neigh, NULL, NUD_FAILED,
 				   NEIGH_UPDATE_F_OVERRIDE |
 				   NEIGH_UPDATE_F_ADMIN);
-		neigh_release(neigh);
+		rcu_read_unlock();
 		goto out_dev_put;
 	}
 	err = -EAFNOSUPPORT;
@@ -1537,7 +1555,7 @@ int neigh_add(struct sk_buff *skb, struc
 		if (dev == NULL)
 			goto out_dev_put;
 
-		neigh = neigh_lookup(tbl, dst, dev);
+		neigh = neigh_lookup_rcu(tbl, dst, dev);
 		if (neigh == NULL) {
 			if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
 				err = -ENOENT;
@@ -1552,16 +1570,15 @@ int neigh_add(struct sk_buff *skb, struc
 		} else {
 			if (nlh->nlmsg_flags & NLM_F_EXCL) {
 				err = -EEXIST;
-				neigh_release(neigh);
 				goto out_dev_put;
 			}
 
+			neigh_hold(neigh);
 			if (!(nlh->nlmsg_flags & NLM_F_REPLACE))
 				flags &= ~NEIGH_UPDATE_F_OVERRIDE;
 		}
 
 		err = neigh_update(neigh, lladdr, ndm->ndm_state, flags);
-		neigh_release(neigh);
 		goto out_dev_put;
 	}
 
@@ -1620,7 +1637,7 @@ static int neightbl_fill_info(struct sk_
 
 	ndtmsg = nlmsg_data(nlh);
 
-	read_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 	ndtmsg->ndtm_family = tbl->family;
 	ndtmsg->ndtm_pad1   = 0;
 	ndtmsg->ndtm_pad2   = 0;
@@ -1680,11 +1697,11 @@ static int neightbl_fill_info(struct sk_
 	if (neightbl_fill_parms(skb, &tbl->parms) < 0)
 		goto nla_put_failure;
 
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 	return nlmsg_cancel(skb, nlh);
 }
 
@@ -1703,7 +1720,7 @@ static int neightbl_fill_param_info(stru
 
 	ndtmsg = nlmsg_data(nlh);
 
-	read_lock_bh(&tbl->lock);
+	rcu_read_lock();		/* this maybe unnecessary */
 	ndtmsg->ndtm_family = tbl->family;
 	ndtmsg->ndtm_pad1   = 0;
 	ndtmsg->ndtm_pad2   = 0;
@@ -1712,10 +1729,10 @@ static int neightbl_fill_param_info(stru
 	    neightbl_fill_parms(skb, parms) < 0)
 		goto errout;
 
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 	return nlmsg_end(skb, nlh);
 errout:
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 	return nlmsg_cancel(skb, nlh);
 }
  
@@ -1793,7 +1810,7 @@ int neightbl_set(struct sk_buff *skb, st
 	 * We acquire tbl->lock to be nice to the periodic timers and
 	 * make sure they always see a consistent set of values.
 	 */
-	write_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 
 	if (tb[NDTA_PARMS]) {
 		struct nlattr *tbp[NDTPA_MAX+1];
@@ -1874,7 +1891,7 @@ int neightbl_set(struct sk_buff *skb, st
 	err = 0;
 
 errout_tbl_lock:
-	write_unlock_bh(&tbl->lock);
+	spin_unlock_bh(&tbl->lock);
 errout_locked:
 	rcu_read_unlock();
 errout:
@@ -1890,7 +1907,7 @@ int neightbl_dump_info(struct sk_buff *s
 
 	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
 
-	rcu_read_lock();
+	rcu_read_lock_bh();
 	list_for_each_entry_rcu(tbl, &neigh_tables, list) {
 		struct neigh_parms *p;
 
@@ -1986,20 +2003,20 @@ static int neigh_dump_table(struct neigh
 			continue;
 		if (h > s_h)
 			s_idx = 0;
-		read_lock_bh(&tbl->lock);
+		rcu_read_lock();
 		idx = 0;
-		hlist_for_each_entry(n, tmp, &tbl->hash_buckets[h], hlist) {
+		hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[h], hlist) {
 			if (idx >= s_idx &&
 			    neigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
 					    cb->nlh->nlmsg_seq,
 					    RTM_NEWNEIGH, NLM_F_MULTI) <= 0) {
-				read_unlock_bh(&tbl->lock);
+				rcu_read_unlock();
 				rc = -1;
 				goto out;
 			}
 			++idx;
 		}
-		read_unlock_bh(&tbl->lock);
+		rcu_read_unlock();
 	}
 	rc = skb->len;
 out:
@@ -2039,14 +2056,15 @@ void neigh_for_each(struct neigh_table *
 {
 	int chain;
 
-	read_lock_bh(&tbl->lock);
+	rcu_read_lock();
 	for (chain = 0; chain <= tbl->hash_mask; chain++) {
+		struct neighbour *n;
 		struct hlist_node *p;
 
-		hlist_for_each(p, &tbl->hash_buckets[chain])
-			cb(hlist_entry(p, struct neighbour, hlist), cookie);
+		hlist_for_each_entry_rcu(n, p, &tbl->hash_buckets[chain], hlist)
+			cb(n, cookie);
 	}
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL(neigh_for_each);
 
@@ -2067,12 +2085,12 @@ void __neigh_for_each_release(struct nei
 			write_lock(&n->lock);
 			release = cb(n);
 			if (release) {
-				hlist_del(&n->hlist);
+				hlist_del_rcu(&n->hlist);
 				n->dead = 1;
 			}
 			write_unlock(&n->lock);
 			if (release)
-				neigh_release(n);
+				call_rcu(&n->rcu, neigh_rcu_release);
 		}
 	}
 }
@@ -2116,7 +2134,7 @@ found:
 
 static struct neighbour *next_neigh(struct hlist_node *node)
 {
-	if (node)
+	if (rcu_dereference(node))
 		return hlist_entry(node, struct neighbour, hlist);
 	else
 		return NULL;
@@ -2191,7 +2209,7 @@ static struct pneigh_entry *pneigh_get_f
 
 	state->flags |= NEIGH_SEQ_IS_PNEIGH;
 	for (bucket = 0; bucket <= PNEIGH_HASHMASK; bucket++) {
-		pn = tbl->phash_buckets[bucket].first;
+		pn = rcu_dereference(tbl->phash_buckets[bucket].first);
 		if (pn)
 			break;
 	}
@@ -2208,12 +2226,12 @@ static struct pneigh_entry *pneigh_get_n
 	struct neigh_table *tbl = state->tbl;
 	struct hlist_node *tmp = &pn->hlist;
 
-	tmp = tmp->next;
+	tmp = rcu_dereference(tmp->next);
 	if (tmp)
 		goto found;
 
 	while (++state->bucket < PNEIGH_HASHMASK) {
-		tmp = tbl->phash_buckets[state->bucket].first;
+		tmp = rcu_dereference(tbl->phash_buckets[state->bucket].first);
 		if (tmp)
 			goto found;
 	}
@@ -2261,7 +2279,7 @@ void *neigh_seq_start(struct seq_file *s
 	state->bucket = 0;
 	state->flags = (neigh_seq_flags & ~NEIGH_SEQ_IS_PNEIGH);
 
-	read_lock_bh(&tbl->lock);
+	rcu_read_lock();
 
 	pos_minus_one = *pos - 1;
 	return *pos ? neigh_get_idx_any(seq, &pos_minus_one) : SEQ_START_TOKEN;
@@ -2297,10 +2315,7 @@ EXPORT_SYMBOL(neigh_seq_next);
 
 void neigh_seq_stop(struct seq_file *seq, void *v)
 {
-	struct neigh_seq_state *state = seq->private;
-	struct neigh_table *tbl = state->tbl;
-
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL(neigh_seq_stop);
 
@@ -2731,7 +2746,7 @@ EXPORT_SYMBOL(neigh_destroy);
 EXPORT_SYMBOL(neigh_dump_info);
 EXPORT_SYMBOL(neigh_event_ns);
 EXPORT_SYMBOL(neigh_ifdown);
-EXPORT_SYMBOL(neigh_lookup);
+EXPORT_SYMBOL(neigh_lookup_rcu);
 EXPORT_SYMBOL(neigh_lookup_nodev);
 EXPORT_SYMBOL(neigh_parms_alloc);
 EXPORT_SYMBOL(neigh_parms_release);
--- net-2.6.19.orig/drivers/infiniband/core/addr.c
+++ net-2.6.19/drivers/infiniband/core/addr.c
@@ -165,10 +165,11 @@ static int addr_resolve_remote(struct so
 		goto put;
 	}
 
-	neigh = neigh_lookup(&arp_tbl, &rt->rt_gateway, rt->idev->dev);
+	rcu_read_lock();
+	neigh = neigh_lookup_rcu(&arp_tbl, &rt->rt_gateway, rt->idev->dev);
 	if (!neigh) {
 		ret = -ENODATA;
-		goto put;
+		goto release;
 	}
 
 	if (!(neigh->nud_state & NUD_VALID)) {
@@ -183,7 +184,7 @@ static int addr_resolve_remote(struct so
 
 	ret = copy_addr(addr, neigh->dev, neigh->ha);
 release:
-	neigh_release(neigh);
+	rcu_read_unlock();
 put:
 	ip_rt_put(rt);
 out:
--- net-2.6.19.orig/drivers/net/wireless/strip.c
+++ net-2.6.19/drivers/net/wireless/strip.c
@@ -467,17 +467,20 @@ static int arp_query(unsigned char *hadd
 		     struct net_device *dev)
 {
 	struct neighbour *neighbor_entry;
+	int ret = 0;
 
-	neighbor_entry = neigh_lookup(&arp_tbl, &paddr, dev);
+	rcu_read_lock();
+	neighbor_entry = neigh_lookup_rcu(&arp_tbl, &paddr, dev);
 
-	if (neighbor_entry != NULL) {
+	if (neighbor_entry) {
 		neighbor_entry->used = jiffies;
 		if (neighbor_entry->nud_state & NUD_VALID) {
 			memcpy(haddr, neighbor_entry->ha, dev->addr_len);
-			return 1;
+			ret = 1;
 		}
 	}
-	return 0;
+	rcu_read_unlock();
+	return ret;
 }
 
 static void DumpData(char *msg, struct strip *strip_info, __u8 * ptr,
--- net-2.6.19.orig/net/ipv4/arp.c
+++ net-2.6.19/net/ipv4/arp.c
@@ -1067,7 +1067,8 @@ static int arp_req_get(struct arpreq *r,
 	struct neighbour *neigh;
 	int err = -ENXIO;
 
-	neigh = neigh_lookup(&arp_tbl, &ip, dev);
+	rcu_read_lock();
+	neigh = neigh_lookup_rcu(&arp_tbl, &ip, dev);
 	if (neigh) {
 		read_lock_bh(&neigh->lock);
 		memcpy(r->arp_ha.sa_data, neigh->ha, dev->addr_len);
@@ -1075,9 +1076,9 @@ static int arp_req_get(struct arpreq *r,
 		read_unlock_bh(&neigh->lock);
 		r->arp_ha.sa_family = dev->type;
 		strlcpy(r->arp_dev, dev->name, sizeof(r->arp_dev));
-		neigh_release(neigh);
 		err = 0;
 	}
+	rcu_read_unlock();
 	return err;
 }
 
@@ -1118,14 +1119,15 @@ static int arp_req_delete(struct arpreq 
 			return -EINVAL;
 	}
 	err = -ENXIO;
-	neigh = neigh_lookup(&arp_tbl, &ip, dev);
+	rcu_read_lock();
+	neigh = neigh_lookup_rcu(&arp_tbl, &ip, dev);
 	if (neigh) {
 		if (neigh->nud_state&~NUD_NOARP)
 			err = neigh_update(neigh, NULL, NUD_FAILED, 
 					   NEIGH_UPDATE_F_OVERRIDE|
 					   NEIGH_UPDATE_F_ADMIN);
-		neigh_release(neigh);
 	}
+	rcu_read_unlock();
 	return err;
 }
 
--- net-2.6.19.orig/net/ipv6/ndisc.c
+++ net-2.6.19/net/ipv6/ndisc.c
@@ -944,8 +944,9 @@ static void ndisc_recv_na(struct sk_buff
 		in6_ifa_put(ifp);
 		return;
 	}
-	neigh = neigh_lookup(&nd_tbl, &msg->target, dev);
 
+	rcu_read_lock();
+	neigh = neigh_lookup_rcu(&nd_tbl, &msg->target, dev);
 	if (neigh) {
 		u8 old_flags = neigh->flags;
 
@@ -969,9 +970,9 @@ static void ndisc_recv_na(struct sk_buff
 				ip6_del_rt(rt);
 		}
 
-out:
-		neigh_release(neigh);
 	}
+out:
+	rcu_read_unlock();
 }
 
 static void ndisc_recv_rs(struct sk_buff *skb)
