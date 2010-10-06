From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] neigh: RCU conversion of struct neighbour
Date: Wed, 06 Oct 2010 17:54:16 +0200
Message-ID: <1286380456.9417.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51194 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932465Ab0JFPyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 11:54:24 -0400
Received: by fxm4 with SMTP id 4so1243366fxm.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 08:54:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second step for neighbour RCU conversion.

(first was commit d6bf7817 : RCU conversion of neigh hash table)

neigh_lookup() becomes lockless, but still take a reference on found
neighbour. (no more read_lock()/read_unlock() on tbl->lock)

struct neighbour gets an additional rcu_head field and is freed after an
RCU grace period.

Future work would need to eventually not take a reference on neighbour
for temporary dst (DST_NOCACHE), but this would need dst->_neighbour to
use a noref bit like we did for skb->_dst.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/neighbour.h |    5 -
 net/core/neighbour.c    |  137 +++++++++++++++++++++++---------------
 2 files changed, 88 insertions(+), 54 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 37845da..a4538d5 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -91,7 +91,7 @@ struct neigh_statistics {
 #define NEIGH_CACHE_STAT_INC(tbl, field) this_cpu_inc((tbl)->stats->field)
 
 struct neighbour {
-	struct neighbour	*next;
+	struct neighbour __rcu	*next;
 	struct neigh_table	*tbl;
 	struct neigh_parms	*parms;
 	struct net_device	*dev;
@@ -111,6 +111,7 @@ struct neighbour {
 	struct sk_buff_head	arp_queue;
 	struct timer_list	timer;
 	const struct neigh_ops	*ops;
+	struct rcu_head		rcu;
 	u8			primary_key[0];
 };
 
@@ -139,7 +140,7 @@ struct pneigh_entry {
  */
 
 struct neigh_hash_table {
-	struct neighbour	**hash_buckets;
+	struct neighbour __rcu	**hash_buckets;
 	unsigned int		hash_mask;
 	__u32			hash_rnd;
 	struct rcu_head		rcu;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index dd8920e..2445af2 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -139,10 +139,12 @@ static int neigh_forced_gc(struct neigh_table *tbl)
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
 	for (i = 0; i <= nht->hash_mask; i++) {
-		struct neighbour *n, **np;
+		struct neighbour *n;
+		struct neighbour __rcu **np;
 
 		np = &nht->hash_buckets[i];
-		while ((n = *np) != NULL) {
+		while ((n = rcu_dereference_protected(*np,
+					lockdep_is_held(&tbl->lock))) != NULL) {
 			/* Neighbour record may be discarded if:
 			 * - nobody refers to it.
 			 * - it is not permanent
@@ -150,7 +152,9 @@ static int neigh_forced_gc(struct neigh_table *tbl)
 			write_lock(&n->lock);
 			if (atomic_read(&n->refcnt) == 1 &&
 			    !(n->nud_state & NUD_PERMANENT)) {
-				*np	= n->next;
+				rcu_assign_pointer(*np,
+					rcu_dereference_protected(n->next,
+						  lockdep_is_held(&tbl->lock)));
 				n->dead = 1;
 				shrunk	= 1;
 				write_unlock(&n->lock);
@@ -208,14 +212,18 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 					lockdep_is_held(&tbl->lock));
 
 	for (i = 0; i <= nht->hash_mask; i++) {
-		struct neighbour *n, **np = &nht->hash_buckets[i];
+		struct neighbour *n;
+		struct neighbour __rcu **np = &nht->hash_buckets[i];
 
-		while ((n = *np) != NULL) {
+		while ((n = rcu_dereference_protected(*np,
+					lockdep_is_held(&tbl->lock))) != NULL) {
 			if (dev && n->dev != dev) {
 				np = &n->next;
 				continue;
 			}
-			*np = n->next;
+			rcu_assign_pointer(*np,
+				   rcu_dereference_protected(n->next,
+						lockdep_is_held(&tbl->lock)));
 			write_lock(&n->lock);
 			neigh_del_timer(n);
 			n->dead = 1;
@@ -323,7 +331,7 @@ static struct neigh_hash_table *neigh_hash_alloc(unsigned int entries)
 		kfree(ret);
 		return NULL;
 	}
-	ret->hash_buckets = buckets;
+	rcu_assign_pointer(ret->hash_buckets, buckets);
 	ret->hash_mask = entries - 1;
 	get_random_bytes(&ret->hash_rnd, sizeof(ret->hash_rnd));
 	return ret;
@@ -362,17 +370,22 @@ static struct neigh_hash_table *neigh_hash_grow(struct neigh_table *tbl,
 	for (i = 0; i <= old_nht->hash_mask; i++) {
 		struct neighbour *n, *next;
 
-		for (n = old_nht->hash_buckets[i];
+		for (n = rcu_dereference_protected(old_nht->hash_buckets[i],
+						   lockdep_is_held(&tbl->lock));
 		     n != NULL;
 		     n = next) {
 			hash = tbl->hash(n->primary_key, n->dev,
 					 new_nht->hash_rnd);
 
 			hash &= new_nht->hash_mask;
-			next = n->next;
-
-			n->next = new_nht->hash_buckets[hash];
-			new_nht->hash_buckets[hash] = n;
+			next = rcu_dereference_protected(n->next,
+						lockdep_is_held(&tbl->lock));
+
+			rcu_assign_pointer(n->next,
+					   rcu_dereference_protected(
+						new_nht->hash_buckets[hash],
+						lockdep_is_held(&tbl->lock)));
+			rcu_assign_pointer(new_nht->hash_buckets[hash], n);
 		}
 	}
 
@@ -394,15 +407,18 @@ struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
 	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) & nht->hash_mask;
-	read_lock(&tbl->lock);
-	for (n = nht->hash_buckets[hash_val]; n; n = n->next) {
+
+	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
+	     n != NULL;
+	     n = rcu_dereference_bh(n->next)) {
 		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
-			neigh_hold(n);
+			if (!atomic_inc_not_zero(&n->refcnt))
+				n = NULL;
 			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
 		}
 	}
-	read_unlock(&tbl->lock);
+
 	rcu_read_unlock_bh();
 	return n;
 }
@@ -421,16 +437,19 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
 	hash_val = tbl->hash(pkey, NULL, nht->hash_rnd) & nht->hash_mask;
-	read_lock(&tbl->lock);
-	for (n = nht->hash_buckets[hash_val]; n; n = n->next) {
+
+	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
+	     n != NULL;
+	     n = rcu_dereference_bh(n->next)) {
 		if (!memcmp(n->primary_key, pkey, key_len) &&
 		    net_eq(dev_net(n->dev), net)) {
-			neigh_hold(n);
+			if (!atomic_inc_not_zero(&n->refcnt))
+				n = NULL;
 			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
 		}
 	}
-	read_unlock(&tbl->lock);
+
 	rcu_read_unlock_bh();
 	return n;
 }
@@ -483,7 +502,11 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 		goto out_tbl_unlock;
 	}
 
-	for (n1 = nht->hash_buckets[hash_val]; n1; n1 = n1->next) {
+	for (n1 = rcu_dereference_protected(nht->hash_buckets[hash_val],
+					    lockdep_is_held(&tbl->lock));
+	     n1 != NULL;
+	     n1 = rcu_dereference_protected(n1->next,
+			lockdep_is_held(&tbl->lock))) {
 		if (dev == n1->dev && !memcmp(n1->primary_key, pkey, key_len)) {
 			neigh_hold(n1);
 			rc = n1;
@@ -491,10 +514,12 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 		}
 	}
 
-	n->next = nht->hash_buckets[hash_val];
-	nht->hash_buckets[hash_val] = n;
 	n->dead = 0;
 	neigh_hold(n);
+	rcu_assign_pointer(n->next,
+			   rcu_dereference_protected(nht->hash_buckets[hash_val],
+						     lockdep_is_held(&tbl->lock)));
+	rcu_assign_pointer(nht->hash_buckets[hash_val], n);
 	write_unlock_bh(&tbl->lock);
 	NEIGH_PRINTK2("neigh %p is created.\n", n);
 	rc = n;
@@ -651,6 +676,12 @@ static inline void neigh_parms_put(struct neigh_parms *parms)
 		neigh_parms_destroy(parms);
 }
 
+static void neigh_destroy_rcu(struct rcu_head *head)
+{
+	struct neighbour *neigh = container_of(head, struct neighbour, rcu);
+
+	kmem_cache_free(neigh->tbl->kmem_cachep, neigh);
+}
 /*
  *	neighbour must already be out of the table;
  *
@@ -690,7 +721,7 @@ void neigh_destroy(struct neighbour *neigh)
 	NEIGH_PRINTK2("neigh %p is destroyed.\n", neigh);
 
 	atomic_dec(&neigh->tbl->entries);
-	kmem_cache_free(neigh->tbl->kmem_cachep, neigh);
+	call_rcu(&neigh->rcu, neigh_destroy_rcu);
 }
 EXPORT_SYMBOL(neigh_destroy);
 
@@ -731,7 +762,8 @@ static void neigh_connect(struct neighbour *neigh)
 static void neigh_periodic_work(struct work_struct *work)
 {
 	struct neigh_table *tbl = container_of(work, struct neigh_table, gc_work.work);
-	struct neighbour *n, **np;
+	struct neighbour *n;
+	struct neighbour __rcu **np;
 	unsigned int i;
 	struct neigh_hash_table *nht;
 
@@ -756,7 +788,8 @@ static void neigh_periodic_work(struct work_struct *work)
 	for (i = 0 ; i <= nht->hash_mask; i++) {
 		np = &nht->hash_buckets[i];
 
-		while ((n = *np) != NULL) {
+		while ((n = rcu_dereference_protected(*np,
+				lockdep_is_held(&tbl->lock))) != NULL) {
 			unsigned int state;
 
 			write_lock(&n->lock);
@@ -1213,8 +1246,8 @@ static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst,
 }
 
 /* This function can be used in contexts, where only old dev_queue_xmit
-   worked, f.e. if you want to override normal output path (eql, shaper),
-   but resolution is not made yet.
+ * worked, f.e. if you want to override normal output path (eql, shaper),
+ * but resolution is not made yet.
  */
 
 int neigh_compat_output(struct sk_buff *skb)
@@ -2123,7 +2156,7 @@ static void neigh_update_notify(struct neighbour *neigh)
 static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			    struct netlink_callback *cb)
 {
-	struct net * net = sock_net(skb->sk);
+	struct net *net = sock_net(skb->sk);
 	struct neighbour *n;
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];
@@ -2132,13 +2165,14 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
 
-	read_lock(&tbl->lock);
 	for (h = 0; h <= nht->hash_mask; h++) {
 		if (h < s_h)
 			continue;
 		if (h > s_h)
 			s_idx = 0;
-		for (n = nht->hash_buckets[h], idx = 0; n; n = n->next) {
+		for (n = rcu_dereference_bh(nht->hash_buckets[h]), idx = 0;
+		     n != NULL;
+		     n = rcu_dereference_bh(n->next)) {
 			if (!net_eq(dev_net(n->dev), net))
 				continue;
 			if (idx < s_idx)
@@ -2150,13 +2184,12 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 				rc = -1;
 				goto out;
 			}
-		next:
+next:
 			idx++;
 		}
 	}
 	rc = skb->len;
 out:
-	read_unlock(&tbl->lock);
 	rcu_read_unlock_bh();
 	cb->args[1] = h;
 	cb->args[2] = idx;
@@ -2195,11 +2228,13 @@ void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
 
-	read_lock(&tbl->lock);
+	read_lock(&tbl->lock); /* avoid resizes */
 	for (chain = 0; chain <= nht->hash_mask; chain++) {
 		struct neighbour *n;
 
-		for (n = nht->hash_buckets[chain]; n; n = n->next)
+		for (n = rcu_dereference_bh(nht->hash_buckets[chain]);
+		     n != NULL;
+		     n = rcu_dereference_bh(n->next))
 			cb(n, cookie);
 	}
 	read_unlock(&tbl->lock);
@@ -2217,16 +2252,20 @@ void __neigh_for_each_release(struct neigh_table *tbl,
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
 	for (chain = 0; chain <= nht->hash_mask; chain++) {
-		struct neighbour *n, **np;
+		struct neighbour *n;
+		struct neighbour __rcu **np;
 
 		np = &nht->hash_buckets[chain];
-		while ((n = *np) != NULL) {
+		while ((n = rcu_dereference_protected(*np,
+					lockdep_is_held(&tbl->lock))) != NULL) {
 			int release;
 
 			write_lock(&n->lock);
 			release = cb(n);
 			if (release) {
-				*np = n->next;
+				rcu_assign_pointer(*np,
+					rcu_dereference_protected(n->next,
+						lockdep_is_held(&tbl->lock)));
 				n->dead = 1;
 			} else
 				np = &n->next;
@@ -2250,7 +2289,7 @@ static struct neighbour *neigh_get_first(struct seq_file *seq)
 
 	state->flags &= ~NEIGH_SEQ_IS_PNEIGH;
 	for (bucket = 0; bucket <= nht->hash_mask; bucket++) {
-		n = nht->hash_buckets[bucket];
+		n = rcu_dereference_bh(nht->hash_buckets[bucket]);
 
 		while (n) {
 			if (!net_eq(dev_net(n->dev), net))
@@ -2267,8 +2306,8 @@ static struct neighbour *neigh_get_first(struct seq_file *seq)
 				break;
 			if (n->nud_state & ~NUD_NOARP)
 				break;
-		next:
-			n = n->next;
+next:
+			n = rcu_dereference_bh(n->next);
 		}
 
 		if (n)
@@ -2292,7 +2331,7 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 		if (v)
 			return n;
 	}
-	n = n->next;
+	n = rcu_dereference_bh(n->next);
 
 	while (1) {
 		while (n) {
@@ -2309,8 +2348,8 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 
 			if (n->nud_state & ~NUD_NOARP)
 				break;
-		next:
-			n = n->next;
+next:
+			n = rcu_dereference_bh(n->next);
 		}
 
 		if (n)
@@ -2319,7 +2358,7 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 		if (++state->bucket > nht->hash_mask)
 			break;
 
-		n = nht->hash_buckets[state->bucket];
+		n = rcu_dereference_bh(nht->hash_buckets[state->bucket]);
 	}
 
 	if (n && pos)
@@ -2417,7 +2456,6 @@ static void *neigh_get_idx_any(struct seq_file *seq, loff_t *pos)
 }
 
 void *neigh_seq_start(struct seq_file *seq, loff_t *pos, struct neigh_table *tbl, unsigned int neigh_seq_flags)
-	__acquires(tbl->lock)
 	__acquires(rcu_bh)
 {
 	struct neigh_seq_state *state = seq->private;
@@ -2428,7 +2466,7 @@ void *neigh_seq_start(struct seq_file *seq, loff_t *pos, struct neigh_table *tbl
 
 	rcu_read_lock_bh();
 	state->nht = rcu_dereference_bh(tbl->nht);
-	read_lock(&tbl->lock);
+
 	return *pos ? neigh_get_idx_any(seq, pos) : SEQ_START_TOKEN;
 }
 EXPORT_SYMBOL(neigh_seq_start);
@@ -2461,13 +2499,8 @@ out:
 EXPORT_SYMBOL(neigh_seq_next);
 
 void neigh_seq_stop(struct seq_file *seq, void *v)
-	__releases(tbl->lock)
 	__releases(rcu_bh)
 {
-	struct neigh_seq_state *state = seq->private;
-	struct neigh_table *tbl = state->tbl;
-
-	read_unlock(&tbl->lock);
 	rcu_read_unlock_bh();
 }
 EXPORT_SYMBOL(neigh_seq_stop);


