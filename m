From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC 4/7] net neighbour: convert to RCU
Date: Mon, 14 Aug 2006 14:20:08 -0700
Message-ID: <20060814212143.629926092@localhost.localdomain>
References: <20060814212004.606140865@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18666 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964967AbWHNVYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:24:45 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=rcu-neigh.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use RCU to allow for lock less access to the neighbour table.
This should speedup the send path because no atomic operations
will be needed to lookup ARP entries, etc.


Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 include/net/neighbour.h |    4 -
 net/core/neighbour.c    |  158 +++++++++++++++++++++++++-----------------------
 2 files changed, 87 insertions(+), 75 deletions(-)

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
@@ -117,6 +118,13 @@ unsigned long neigh_rand_reach_time(unsi
 }
 
 
+static void neigh_rcu_release(struct rcu_head *head)
+{
+	struct neighbour *neigh = container_of(head, struct neighbour, rcu);
+
+	neigh_release(neigh);
+}
+
 static int neigh_forced_gc(struct neigh_table *tbl)
 {
 	int shrunk = 0;
@@ -124,7 +132,7 @@ static int neigh_forced_gc(struct neigh_
 
 	NEIGH_CACHE_STAT_INC(tbl, forced_gc_runs);
 
-	write_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 	for (i = 0; i <= tbl->hash_mask; i++) {
 		struct neighbour *n;
 		struct hlist_node *node, *tmp;
@@ -138,11 +146,11 @@ static int neigh_forced_gc(struct neigh_
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
@@ -151,7 +159,7 @@ static int neigh_forced_gc(struct neigh_
 
 	tbl->last_flush = jiffies;
 
-	write_unlock_bh(&tbl->lock);
+	spin_unlock_bh(&tbl->lock);
 
 	return shrunk;
 }
@@ -189,7 +197,7 @@ static void neigh_flush_dev(struct neigh
 			if (dev && n->dev != dev)
 				continue;
 
-			hlist_del(&n->hlist);
+			hlist_del_rcu(&n->hlist);
 			write_lock(&n->lock);
 			neigh_del_timer(n);
 			n->dead = 1;
@@ -220,17 +228,17 @@ static void neigh_flush_dev(struct neigh
 
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
@@ -326,8 +334,8 @@ static void neigh_hash_grow(struct neigh
 			unsigned int hash_val = tbl->hash(n->primary_key, n->dev);
 
 			hash_val &= new_hash_mask;
-			hlist_del(&n->hlist);
-			hlist_add_head(&n->hlist, &new_hash[hash_val]);
+			__hlist_del(&n->hlist);
+			hlist_add_head_rcu(&n->hlist, &new_hash[hash_val]);
 		}
 	}
 	tbl->hash_buckets = new_hash;
@@ -346,8 +354,8 @@ struct neighbour *neigh_lookup(struct ne
 	
 	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
-	read_lock_bh(&tbl->lock);
-	hlist_for_each_entry(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
 		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
@@ -356,7 +364,7 @@ struct neighbour *neigh_lookup(struct ne
 	}
 	n = NULL;
 found:
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 	return n;
 }
 
@@ -369,8 +377,8 @@ struct neighbour *neigh_lookup_nodev(str
 
 	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
-	read_lock_bh(&tbl->lock);
-	hlist_for_each_entry(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
 		if (!memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
@@ -379,7 +387,7 @@ struct neighbour *neigh_lookup_nodev(str
 	}
 	n = NULL;
 found:
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 	return n;
 }
 
@@ -416,7 +424,7 @@ struct neighbour *neigh_create(struct ne
 
 	n->confirmed = jiffies - (n->parms->base_reachable_time << 1);
 
-	write_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 
 	if (atomic_read(&tbl->entries) > (tbl->hash_mask + 1))
 		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
@@ -436,21 +444,22 @@ struct neighbour *neigh_create(struct ne
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
@@ -464,16 +473,14 @@ struct pneigh_entry * pneigh_lookup(stru
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
@@ -495,13 +502,18 @@ struct pneigh_entry * pneigh_lookup(stru
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
@@ -516,20 +528,20 @@ int pneigh_delete(struct neigh_table *tb
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
 
@@ -543,7 +555,7 @@ static int pneigh_ifdown(struct neigh_ta
 
 		hlist_for_each_entry_safe(n, tmp, nxt, &tbl->phash_buckets[h], hlist) {
 			if (!dev || n->dev == dev) {
-				hlist_del(&n->hlist);
+				hlist_del_rcu(&n->hlist);
 				if (tbl->pdestructor)
 					tbl->pdestructor(n);
 				if (n->dev)
@@ -644,7 +656,7 @@ static void neigh_periodic_timer(unsigne
 
 	NEIGH_CACHE_STAT_INC(tbl, periodic_gc_runs);
 
-	write_lock(&tbl->lock);
+	spin_lock(&tbl->lock);
 
 	/*
 	 *	periodically recompute ReachableTime from random function
@@ -676,7 +688,7 @@ static void neigh_periodic_timer(unsigne
 		if (atomic_read(&n->refcnt) == 1 &&
 		    (state == NUD_FAILED ||
 		     time_after(now, n->used + n->parms->gc_staletime))) {
-			hlist_del(&n->hlist);
+			hlist_del_rcu(&n->hlist);
 			n->dead = 1;
 			write_unlock(&n->lock);
 			neigh_release(n);
@@ -697,7 +709,7 @@ static void neigh_periodic_timer(unsigne
 
  	mod_timer(&tbl->gc_timer, now + expire);
 
-	write_unlock(&tbl->lock);
+	spin_unlock(&tbl->lock);
 }
 
 static __inline__ int neigh_max_probes(struct neighbour *n)
@@ -1285,10 +1297,10 @@ struct neigh_parms *neigh_parms_alloc(st
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
@@ -1307,19 +1319,19 @@ void neigh_parms_release(struct neigh_ta
 
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
 
@@ -1369,7 +1381,7 @@ void neigh_table_init_no_netlink(struct 
 
 	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
 
-	rwlock_init(&tbl->lock);
+	spin_lock_init(&tbl->lock);
 	init_timer(&tbl->gc_timer);
 	tbl->gc_timer.data     = (unsigned long)tbl;
 	tbl->gc_timer.function = neigh_periodic_timer;
@@ -1624,7 +1636,7 @@ static int neightbl_fill_info(struct sk_
 
 	ndtmsg = nlmsg_data(nlh);
 
-	read_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 	ndtmsg->ndtm_family = tbl->family;
 	ndtmsg->ndtm_pad1   = 0;
 	ndtmsg->ndtm_pad2   = 0;
@@ -1684,11 +1696,11 @@ static int neightbl_fill_info(struct sk_
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
 
@@ -1707,7 +1719,7 @@ static int neightbl_fill_param_info(stru
 
 	ndtmsg = nlmsg_data(nlh);
 
-	read_lock_bh(&tbl->lock);
+	rcu_read_lock();		/* this maybe unnecessary */
 	ndtmsg->ndtm_family = tbl->family;
 	ndtmsg->ndtm_pad1   = 0;
 	ndtmsg->ndtm_pad2   = 0;
@@ -1716,10 +1728,10 @@ static int neightbl_fill_param_info(stru
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
  
@@ -1797,7 +1809,7 @@ int neightbl_set(struct sk_buff *skb, st
 	 * We acquire tbl->lock to be nice to the periodic timers and
 	 * make sure they always see a consistent set of values.
 	 */
-	write_lock_bh(&tbl->lock);
+	spin_lock_bh(&tbl->lock);
 
 	if (tb[NDTA_PARMS]) {
 		struct nlattr *tbp[NDTPA_MAX+1];
@@ -1878,7 +1890,7 @@ int neightbl_set(struct sk_buff *skb, st
 	err = 0;
 
 errout_tbl_lock:
-	write_unlock_bh(&tbl->lock);
+	spin_unlock_bh(&tbl->lock);
 errout_locked:
 	rcu_read_unlock();
 errout:
@@ -1894,7 +1906,7 @@ int neightbl_dump_info(struct sk_buff *s
 
 	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
 
-	rcu_read_lock();
+	rcu_read_lock_bh();
 	list_for_each_entry_rcu(tbl, &neigh_tables, list) {
 		struct neigh_parms *p;
 
@@ -1990,20 +2002,20 @@ static int neigh_dump_table(struct neigh
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
@@ -2043,14 +2055,15 @@ void neigh_for_each(struct neigh_table *
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
 
@@ -2071,12 +2084,12 @@ void __neigh_for_each_release(struct nei
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
@@ -2120,7 +2133,7 @@ found:
 
 static struct neighbour *next_neigh(struct hlist_node *node)
 {
-	if (node)
+	if (rcu_dereference(node))
 		return hlist_entry(node, struct neighbour, hlist);
 	else
 		return NULL;
@@ -2195,7 +2208,7 @@ static struct pneigh_entry *pneigh_get_f
 
 	state->flags |= NEIGH_SEQ_IS_PNEIGH;
 	for (bucket = 0; bucket <= PNEIGH_HASHMASK; bucket++) {
-		pn = tbl->phash_buckets[bucket].first;
+		pn = rcu_dereference(tbl->phash_buckets[bucket].first);
 		if (pn)
 			break;
 	}
@@ -2212,12 +2225,12 @@ static struct pneigh_entry *pneigh_get_n
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
@@ -2265,7 +2278,7 @@ void *neigh_seq_start(struct seq_file *s
 	state->bucket = 0;
 	state->flags = (neigh_seq_flags & ~NEIGH_SEQ_IS_PNEIGH);
 
-	read_lock_bh(&tbl->lock);
+	rcu_read_lock();
 
 	pos_minus_one = *pos - 1;
 	return *pos ? neigh_get_idx_any(seq, &pos_minus_one) : SEQ_START_TOKEN;
@@ -2301,10 +2314,7 @@ EXPORT_SYMBOL(neigh_seq_next);
 
 void neigh_seq_stop(struct seq_file *seq, void *v)
 {
-	struct neigh_seq_state *state = seq->private;
-	struct neigh_table *tbl = state->tbl;
-
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL(neigh_seq_stop);
 

--

