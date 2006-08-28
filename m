From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/6] neighbour: convert neighbour hash table to hlist
Date: Mon, 28 Aug 2006 16:07:50 -0700
Message-ID: <20060828230915.156826305@localhost.localdomain>
References: <20060828230748.827712918@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20866 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964868AbWH1XMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 19:12:54 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=hlist1.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the neighbour table hash list to hlist from list.h
to allow for easier later conversion to RCU.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 include/net/neighbour.h |    6 -
 net/core/neighbour.c    |  160 +++++++++++++++++++++++++-----------------------
 2 files changed, 88 insertions(+), 78 deletions(-)

--- net-2.6.19.orig/include/net/neighbour.h
+++ net-2.6.19/include/net/neighbour.h
@@ -88,10 +88,10 @@ struct neigh_statistics
 
 struct neighbour
 {
-	struct neighbour	*next;
+	struct hlist_node	hlist;
 	struct neigh_table	*tbl;
 	struct neigh_parms	*parms;
-	struct net_device		*dev;
+	struct net_device	*dev;
 	unsigned long		used;
 	unsigned long		confirmed;
 	unsigned long		updated;
@@ -161,7 +161,7 @@ struct neigh_table
 	unsigned long		last_rand;
 	kmem_cache_t		*kmem_cachep;
 	struct neigh_statistics	*stats;
-	struct neighbour	**hash_buckets;
+	struct hlist_head	*hash_buckets;
 	unsigned int		hash_mask;
 	__u32			hash_rnd;
 	unsigned int		hash_chain_gc;
--- net-2.6.19.orig/net/core/neighbour.c
+++ net-2.6.19/net/core/neighbour.c
@@ -126,10 +126,11 @@ static int neigh_forced_gc(struct neigh_
 
 	write_lock_bh(&tbl->lock);
 	for (i = 0; i <= tbl->hash_mask; i++) {
-		struct neighbour *n, **np;
+		struct neighbour *n;
+		struct hlist_node *node, *tmp;
 
-		np = &tbl->hash_buckets[i];
-		while ((n = *np) != NULL) {
+		hlist_for_each_entry_safe(n, node, tmp,
+					  &tbl->hash_buckets[i], hlist) {
 			/* Neighbour record may be discarded if:
 			 * - nobody refers to it.
 			 * - it is not permanent
@@ -137,7 +138,7 @@ static int neigh_forced_gc(struct neigh_
 			write_lock(&n->lock);
 			if (atomic_read(&n->refcnt) == 1 &&
 			    !(n->nud_state & NUD_PERMANENT)) {
-				*np	= n->next;
+				hlist_del(&n->hlist);
 				n->dead = 1;
 				shrunk	= 1;
 				write_unlock(&n->lock);
@@ -145,7 +146,6 @@ static int neigh_forced_gc(struct neigh_
 				continue;
 			}
 			write_unlock(&n->lock);
-			np = &n->next;
 		}
 	}
 
@@ -181,14 +181,15 @@ static void neigh_flush_dev(struct neigh
 	int i;
 
 	for (i = 0; i <= tbl->hash_mask; i++) {
-		struct neighbour *n, **np = &tbl->hash_buckets[i];
+		struct hlist_node *node, *tmp;
+		struct neighbour *n;
 
-		while ((n = *np) != NULL) {
-			if (dev && n->dev != dev) {
-				np = &n->next;
+		hlist_for_each_entry_safe(n, node, tmp,
+					  &tbl->hash_buckets[i], hlist) {
+			if (dev && n->dev != dev)
 				continue;
-			}
-			*np = n->next;
+
+			hlist_del(&n->hlist);
 			write_lock(&n->lock);
 			neigh_del_timer(n);
 			n->dead = 1;
@@ -279,23 +280,20 @@ out_entries:
 	goto out;
 }
 
-static struct neighbour **neigh_hash_alloc(unsigned int entries)
+static struct hlist_head *neigh_hash_alloc(unsigned int entries)
 {
-	unsigned long size = entries * sizeof(struct neighbour *);
-	struct neighbour **ret;
+	unsigned long size = entries * sizeof(struct hlist_head);
 
-	if (size <= PAGE_SIZE) {
-		ret = kzalloc(size, GFP_ATOMIC);
-	} else {
-		ret = (struct neighbour **)
+	if (size <= PAGE_SIZE)
+		return kzalloc(size, GFP_ATOMIC);
+	else
+		return (struct hlist_head *)
 		      __get_free_pages(GFP_ATOMIC|__GFP_ZERO, get_order(size));
-	}
-	return ret;
 }
 
-static void neigh_hash_free(struct neighbour **hash, unsigned int entries)
+static void neigh_hash_free(struct hlist_head *hash, unsigned int entries)
 {
-	unsigned long size = entries * sizeof(struct neighbour *);
+	unsigned long size = entries * sizeof(struct hlist_head);
 
 	if (size <= PAGE_SIZE)
 		kfree(hash);
@@ -305,7 +303,7 @@ static void neigh_hash_free(struct neigh
 
 static void neigh_hash_grow(struct neigh_table *tbl, unsigned long new_entries)
 {
-	struct neighbour **new_hash, **old_hash;
+	struct hlist_head *new_hash, *old_hash;
 	unsigned int i, new_hash_mask, old_entries;
 
 	NEIGH_CACHE_STAT_INC(tbl, hash_grows);
@@ -321,16 +319,15 @@ static void neigh_hash_grow(struct neigh
 
 	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
 	for (i = 0; i < old_entries; i++) {
-		struct neighbour *n, *next;
+		struct neighbour *n;
+		struct hlist_node *node, *tmp;
 
-		for (n = old_hash[i]; n; n = next) {
+		hlist_for_each_entry_safe(n, node, tmp, &old_hash[i], hlist) {
 			unsigned int hash_val = tbl->hash(n->primary_key, n->dev);
 
 			hash_val &= new_hash_mask;
-			next = n->next;
-
-			n->next = new_hash[hash_val];
-			new_hash[hash_val] = n;
+			hlist_del(&n->hlist);
+			hlist_add_head(&n->hlist, &new_hash[hash_val]);
 		}
 	}
 	tbl->hash_buckets = new_hash;
@@ -343,19 +340,22 @@ struct neighbour *neigh_lookup(struct ne
 			       struct net_device *dev)
 {
 	struct neighbour *n;
+	struct hlist_node *tmp;
 	int key_len = tbl->key_len;
 	u32 hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
 	
 	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
 	read_lock_bh(&tbl->lock);
-	for (n = tbl->hash_buckets[hash_val]; n; n = n->next) {
+	hlist_for_each_entry(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
 		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
-			break;
+			goto found;
 		}
 	}
+	n = NULL;
+found:
 	read_unlock_bh(&tbl->lock);
 	return n;
 }
@@ -363,19 +363,22 @@ struct neighbour *neigh_lookup(struct ne
 struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, const void *pkey)
 {
 	struct neighbour *n;
+	struct hlist_node *tmp;
 	int key_len = tbl->key_len;
 	u32 hash_val = tbl->hash(pkey, NULL) & tbl->hash_mask;
 
 	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
 	read_lock_bh(&tbl->lock);
-	for (n = tbl->hash_buckets[hash_val]; n; n = n->next) {
+	hlist_for_each_entry(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
 		if (!memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
-			break;
+			goto found;
 		}
 	}
+	n = NULL;
+found:
 	read_unlock_bh(&tbl->lock);
 	return n;
 }
@@ -387,6 +390,7 @@ struct neighbour *neigh_create(struct ne
 	int key_len = tbl->key_len;
 	int error;
 	struct neighbour *n1, *rc, *n = neigh_alloc(tbl);
+	struct hlist_node *tmp;
 
 	if (!n) {
 		rc = ERR_PTR(-ENOBUFS);
@@ -424,7 +428,7 @@ struct neighbour *neigh_create(struct ne
 		goto out_tbl_unlock;
 	}
 
-	for (n1 = tbl->hash_buckets[hash_val]; n1; n1 = n1->next) {
+	hlist_for_each_entry(n1, tmp, &tbl->hash_buckets[hash_val], hlist) {
 		if (dev == n1->dev && !memcmp(n1->primary_key, pkey, key_len)) {
 			neigh_hold(n1);
 			rc = n1;
@@ -432,8 +436,7 @@ struct neighbour *neigh_create(struct ne
 		}
 	}
 
-	n->next = tbl->hash_buckets[hash_val];
-	tbl->hash_buckets[hash_val] = n;
+	hlist_add_head(&n->hlist, &tbl->hash_buckets[hash_val]);
 	n->dead = 0;
 	neigh_hold(n);
 	write_unlock_bh(&tbl->lock);
@@ -635,7 +638,9 @@ static void neigh_connect(struct neighbo
 static void neigh_periodic_timer(unsigned long arg)
 {
 	struct neigh_table *tbl = (struct neigh_table *)arg;
-	struct neighbour *n, **np;
+	struct neighbour *n;
+	struct hlist_head *head;
+	struct hlist_node *node, *tmp;
 	unsigned long expire, now = jiffies;
 
 	NEIGH_CACHE_STAT_INC(tbl, periodic_gc_runs);
@@ -654,19 +659,17 @@ static void neigh_periodic_timer(unsigne
 				neigh_rand_reach_time(p->base_reachable_time);
 	}
 
-	np = &tbl->hash_buckets[tbl->hash_chain_gc];
+	head = &tbl->hash_buckets[tbl->hash_chain_gc];
 	tbl->hash_chain_gc = ((tbl->hash_chain_gc + 1) & tbl->hash_mask);
 
-	while ((n = *np) != NULL) {
+	hlist_for_each_entry_safe(n, node, tmp, head, hlist) {
 		unsigned int state;
 
 		write_lock(&n->lock);
 
 		state = n->nud_state;
-		if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
-			write_unlock(&n->lock);
+		if (state & (NUD_PERMANENT | NUD_IN_TIMER))
 			goto next_elt;
-		}
 
 		if (time_before(n->used, n->confirmed))
 			n->used = n->confirmed;
@@ -674,16 +677,14 @@ static void neigh_periodic_timer(unsigne
 		if (atomic_read(&n->refcnt) == 1 &&
 		    (state == NUD_FAILED ||
 		     time_after(now, n->used + n->parms->gc_staletime))) {
-			*np = n->next;
+			hlist_del(&n->hlist);
 			n->dead = 1;
 			write_unlock(&n->lock);
 			neigh_release(n);
 			continue;
 		}
+	next_elt:
 		write_unlock(&n->lock);
-
-next_elt:
-		np = &n->next;
 	}
 
  	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
@@ -1976,27 +1977,29 @@ nla_put_failure:
 static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			    struct netlink_callback *cb)
 {
-	struct neighbour *n;
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];
 
 	for (h = 0; h <= tbl->hash_mask; h++) {
+		struct neighbour *n;
+		struct hlist_node *tmp;
+
 		if (h < s_h)
 			continue;
 		if (h > s_h)
 			s_idx = 0;
 		read_lock_bh(&tbl->lock);
-		for (n = tbl->hash_buckets[h], idx = 0; n; n = n->next, idx++) {
-			if (idx < s_idx)
-				continue;
-			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
+		idx = 0;
+		hlist_for_each_entry(n, tmp, &tbl->hash_buckets[h], hlist) {
+			if (idx >= s_idx &&
+			    neigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
 					    cb->nlh->nlmsg_seq,
-					    RTM_NEWNEIGH,
-					    NLM_F_MULTI) <= 0) {
+					    RTM_NEWNEIGH, NLM_F_MULTI) <= 0) {
 				read_unlock_bh(&tbl->lock);
 				rc = -1;
 				goto out;
 			}
+			++idx;
 		}
 		read_unlock_bh(&tbl->lock);
 	}
@@ -2040,10 +2043,10 @@ void neigh_for_each(struct neigh_table *
 
 	read_lock_bh(&tbl->lock);
 	for (chain = 0; chain <= tbl->hash_mask; chain++) {
-		struct neighbour *n;
+		struct hlist_node *p;
 
-		for (n = tbl->hash_buckets[chain]; n; n = n->next)
-			cb(n, cookie);
+		hlist_for_each(p, &tbl->hash_buckets[chain])
+			cb(hlist_entry(p, struct neighbour, hlist), cookie);
 	}
 	read_unlock_bh(&tbl->lock);
 }
@@ -2056,19 +2059,19 @@ void __neigh_for_each_release(struct nei
 	int chain;
 
 	for (chain = 0; chain <= tbl->hash_mask; chain++) {
-		struct neighbour *n, **np;
+		struct neighbour *n;
+		struct hlist_node *tmp, *next;
 
-		np = &tbl->hash_buckets[chain];
-		while ((n = *np) != NULL) {
+		hlist_for_each_entry_safe(n, tmp, next,
+					  &tbl->hash_buckets[chain], hlist) {
 			int release;
 
 			write_lock(&n->lock);
 			release = cb(n);
 			if (release) {
-				*np = n->next;
+				hlist_del(&n->hlist);
 				n->dead = 1;
-			} else
-				np = &n->next;
+			}
 			write_unlock(&n->lock);
 			if (release)
 				neigh_release(n);
@@ -2088,33 +2091,39 @@ static struct neighbour *neigh_get_first
 
 	state->flags &= ~NEIGH_SEQ_IS_PNEIGH;
 	for (bucket = 0; bucket <= tbl->hash_mask; bucket++) {
-		n = tbl->hash_buckets[bucket];
+		struct hlist_node *tmp;
 
-		while (n) {
+		hlist_for_each_entry(n, tmp, &tbl->hash_buckets[bucket], hlist) {
 			if (state->neigh_sub_iter) {
 				loff_t fakep = 0;
 				void *v;
 
 				v = state->neigh_sub_iter(state, n, &fakep);
 				if (!v)
-					goto next;
+					continue;
 			}
+
 			if (!(state->flags & NEIGH_SEQ_SKIP_NOARP))
-				break;
+				goto found;
 			if (n->nud_state & ~NUD_NOARP)
-				break;
-		next:
-			n = n->next;
+				goto found;
 		}
-
-		if (n)
-			break;
+		n = NULL;
 	}
+found:
 	state->bucket = bucket;
 
 	return n;
 }
 
+static struct neighbour *next_neigh(struct hlist_node *node)
+{
+	if (node)
+		return hlist_entry(node, struct neighbour, hlist);
+	else
+		return NULL;
+}
+
 static struct neighbour *neigh_get_next(struct seq_file *seq,
 					struct neighbour *n,
 					loff_t *pos)
@@ -2127,7 +2136,8 @@ static struct neighbour *neigh_get_next(
 		if (v)
 			return n;
 	}
-	n = n->next;
+
+	n = next_neigh(n->hlist.next);
 
 	while (1) {
 		while (n) {
@@ -2143,7 +2153,7 @@ static struct neighbour *neigh_get_next(
 			if (n->nud_state & ~NUD_NOARP)
 				break;
 		next:
-			n = n->next;
+			n = next_neigh(n->hlist.next);
 		}
 
 		if (n)
@@ -2152,7 +2162,7 @@ static struct neighbour *neigh_get_next(
 		if (++state->bucket > tbl->hash_mask)
 			break;
 
-		n = tbl->hash_buckets[state->bucket];
+		n = next_neigh(tbl->hash_buckets[state->bucket].first);
 	}
 
 	if (n && pos)

--
Stephen Hemminger <shemminger@osdl.org>


