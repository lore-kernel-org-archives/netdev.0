From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: add __rcu annotations to routes.c
Date: Tue, 26 Oct 2010 09:02:07 +0200
Message-ID: <1288076527.3296.88.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40428 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755624Ab0JZHCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 03:02:14 -0400
Received: by wyf28 with SMTP id 28so4262799wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 00:02:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __rcu annotations to :
        (struct dst_entry)->rt_next
        (struct rt_hash_bucket)->chain

And use appropriate rcu primitives to reduce sparse warnings if
CONFIG_SPARSE_RCU_POINTER=y

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/dst.h |    2 -
 net/ipv4/route.c  |   75 ++++++++++++++++++++++++++------------------
 2 files changed, 47 insertions(+), 30 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index a217c83..ffe9cb7 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -95,7 +95,7 @@ struct dst_entry {
 	unsigned long		lastuse;
 	union {
 		struct dst_entry *next;
-		struct rtable    *rt_next;
+		struct rtable __rcu *rt_next;
 		struct rt6_info   *rt6_next;
 		struct dn_route  *dn_next;
 	};
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d6cb2bf..987bf9a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -198,7 +198,7 @@ const __u8 ip_tos2prio[16] = {
  */
 
 struct rt_hash_bucket {
-	struct rtable	*chain;
+	struct rtable __rcu	*chain;
 };
 
 #if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK) || \
@@ -280,7 +280,7 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
 	struct rtable *r = NULL;
 
 	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
-		if (!rt_hash_table[st->bucket].chain)
+		if (!rcu_dereference_raw(rt_hash_table[st->bucket].chain))
 			continue;
 		rcu_read_lock_bh();
 		r = rcu_dereference_bh(rt_hash_table[st->bucket].chain);
@@ -300,17 +300,17 @@ static struct rtable *__rt_cache_get_next(struct seq_file *seq,
 {
 	struct rt_cache_iter_state *st = seq->private;
 
-	r = r->dst.rt_next;
+	r = rcu_dereference_bh(r->dst.rt_next);
 	while (!r) {
 		rcu_read_unlock_bh();
 		do {
 			if (--st->bucket < 0)
 				return NULL;
-		} while (!rt_hash_table[st->bucket].chain);
+		} while (!rcu_dereference_raw(rt_hash_table[st->bucket].chain));
 		rcu_read_lock_bh();
-		r = rt_hash_table[st->bucket].chain;
+		r = rcu_dereference_bh(rt_hash_table[st->bucket].chain);
 	}
-	return rcu_dereference_bh(r);
+	return r;
 }
 
 static struct rtable *rt_cache_get_next(struct seq_file *seq,
@@ -721,19 +721,23 @@ static void rt_do_flush(int process_context)
 	for (i = 0; i <= rt_hash_mask; i++) {
 		if (process_context && need_resched())
 			cond_resched();
-		rth = rt_hash_table[i].chain;
+		rth = rcu_dereference_raw(rt_hash_table[i].chain);
 		if (!rth)
 			continue;
 
 		spin_lock_bh(rt_hash_lock_addr(i));
 #ifdef CONFIG_NET_NS
 		{
-		struct rtable ** prev, * p;
+		struct rtable __rcu **prev;
+		struct rtable *p;
 
-		rth = rt_hash_table[i].chain;
+		rth = rcu_dereference_protected(rt_hash_table[i].chain,
+			lockdep_is_held(rt_hash_lock_addr(i)));
 
 		/* defer releasing the head of the list after spin_unlock */
-		for (tail = rth; tail; tail = tail->dst.rt_next)
+		for (tail = rth; tail;
+		     tail = rcu_dereference_protected(tail->dst.rt_next,
+				lockdep_is_held(rt_hash_lock_addr(i))))
 			if (!rt_is_expired(tail))
 				break;
 		if (rth != tail)
@@ -741,8 +745,12 @@ static void rt_do_flush(int process_context)
 
 		/* call rt_free on entries after the tail requiring flush */
 		prev = &rt_hash_table[i].chain;
-		for (p = *prev; p; p = next) {
-			next = p->dst.rt_next;
+		for (p = rcu_dereference_protected(*prev,
+				lockdep_is_held(rt_hash_lock_addr(i)));
+		     p != NULL;
+		     p = next) {
+			next = rcu_dereference_protected(p->dst.rt_next,
+				lockdep_is_held(rt_hash_lock_addr(i)));
 			if (!rt_is_expired(p)) {
 				prev = &p->dst.rt_next;
 			} else {
@@ -752,14 +760,15 @@ static void rt_do_flush(int process_context)
 		}
 		}
 #else
-		rth = rt_hash_table[i].chain;
-		rt_hash_table[i].chain = NULL;
+		rth = rcu_dereference_protected(rt_hash_table[i].chain,
+			lockdep_is_held(rt_hash_lock_addr(i)));
+		rcu_assign_pointer(rt_hash_table[i].chain, NULL);
 		tail = NULL;
 #endif
 		spin_unlock_bh(rt_hash_lock_addr(i));
 
 		for (; rth != tail; rth = next) {
-			next = rth->dst.rt_next;
+			next = rcu_dereference_protected(rth->dst.rt_next, 1);
 			rt_free(rth);
 		}
 	}
@@ -790,7 +799,7 @@ static int has_noalias(const struct rtable *head, const struct rtable *rth)
 	while (aux != rth) {
 		if (compare_hash_inputs(&aux->fl, &rth->fl))
 			return 0;
-		aux = aux->dst.rt_next;
+		aux = rcu_dereference_protected(aux->dst.rt_next, 1);
 	}
 	return ONE;
 }
@@ -799,7 +808,8 @@ static void rt_check_expire(void)
 {
 	static unsigned int rover;
 	unsigned int i = rover, goal;
-	struct rtable *rth, **rthp;
+	struct rtable *rth;
+	struct rtable __rcu **rthp;
 	unsigned long samples = 0;
 	unsigned long sum = 0, sum2 = 0;
 	unsigned long delta;
@@ -825,11 +835,12 @@ static void rt_check_expire(void)
 
 		samples++;
 
-		if (*rthp == NULL)
+		if (rcu_dereference_raw(*rthp) == NULL)
 			continue;
 		length = 0;
 		spin_lock_bh(rt_hash_lock_addr(i));
-		while ((rth = *rthp) != NULL) {
+		while ((rth = rcu_dereference_protected(*rthp,
+					lockdep_is_held(rt_hash_lock_addr(i)))) != NULL) {
 			prefetch(rth->dst.rt_next);
 			if (rt_is_expired(rth)) {
 				*rthp = rth->dst.rt_next;
@@ -941,7 +952,8 @@ static int rt_garbage_collect(struct dst_ops *ops)
 	static unsigned long last_gc;
 	static int rover;
 	static int equilibrium;
-	struct rtable *rth, **rthp;
+	struct rtable *rth;
+	struct rtable __rcu **rthp;
 	unsigned long now = jiffies;
 	int goal;
 	int entries = dst_entries_get_fast(&ipv4_dst_ops);
@@ -995,7 +1007,8 @@ static int rt_garbage_collect(struct dst_ops *ops)
 			k = (k + 1) & rt_hash_mask;
 			rthp = &rt_hash_table[k].chain;
 			spin_lock_bh(rt_hash_lock_addr(k));
-			while ((rth = *rthp) != NULL) {
+			while ((rth = rcu_dereference_protected(*rthp,
+					lockdep_is_held(rt_hash_lock_addr(k)))) != NULL) {
 				if (!rt_is_expired(rth) &&
 					!rt_may_expire(rth, tmo, expire)) {
 					tmo >>= 1;
@@ -1071,7 +1084,7 @@ static int slow_chain_length(const struct rtable *head)
 
 	while (rth) {
 		length += has_noalias(head, rth);
-		rth = rth->dst.rt_next;
+		rth = rcu_dereference_protected(rth->dst.rt_next, 1);
 	}
 	return length >> FRACT_BITS;
 }
@@ -1079,9 +1092,9 @@ static int slow_chain_length(const struct rtable *head)
 static int rt_intern_hash(unsigned hash, struct rtable *rt,
 			  struct rtable **rp, struct sk_buff *skb, int ifindex)
 {
-	struct rtable	*rth, **rthp;
+	struct rtable	*rth, *cand;
+	struct rtable __rcu **rthp, **candp;
 	unsigned long	now;
-	struct rtable *cand, **candp;
 	u32 		min_score;
 	int		chain_length;
 	int attempts = !in_softirq();
@@ -1128,7 +1141,8 @@ restart:
 	rthp = &rt_hash_table[hash].chain;
 
 	spin_lock_bh(rt_hash_lock_addr(hash));
-	while ((rth = *rthp) != NULL) {
+	while ((rth = rcu_dereference_protected(*rthp,
+			lockdep_is_held(rt_hash_lock_addr(hash)))) != NULL) {
 		if (rt_is_expired(rth)) {
 			*rthp = rth->dst.rt_next;
 			rt_free(rth);
@@ -1324,12 +1338,14 @@ EXPORT_SYMBOL(__ip_select_ident);
 
 static void rt_del(unsigned hash, struct rtable *rt)
 {
-	struct rtable **rthp, *aux;
+	struct rtable __rcu **rthp;
+	struct rtable *aux;
 
 	rthp = &rt_hash_table[hash].chain;
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	ip_rt_put(rt);
-	while ((aux = *rthp) != NULL) {
+	while ((aux = rcu_dereference_protected(*rthp,
+			lockdep_is_held(rt_hash_lock_addr(hash)))) != NULL) {
 		if (aux == rt || rt_is_expired(aux)) {
 			*rthp = aux->dst.rt_next;
 			rt_free(aux);
@@ -1346,7 +1362,8 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 {
 	int i, k;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	struct rtable *rth, **rthp;
+	struct rtable *rth;
+	struct rtable __rcu **rthp;
 	__be32  skeys[2] = { saddr, 0 };
 	int  ikeys[2] = { dev->ifindex, 0 };
 	struct netevent_redirect netevent;
@@ -1379,7 +1396,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 			unsigned hash = rt_hash(daddr, skeys[i], ikeys[k],
 						rt_genid(net));
 
-			rthp=&rt_hash_table[hash].chain;
+			rthp = &rt_hash_table[hash].chain;
 
 			while ((rth = rcu_dereference(*rthp)) != NULL) {
 				struct rtable *rt;


