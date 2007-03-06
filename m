From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 6 Mar 2007 10:11:12 +0100
Message-ID: <20070306091112.GA12365@wotan.suse.de>
References: <20070305.202632.74752497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dada1@cosmosbay.com,
	robert.olsson@its.uu.se, Paul McKenney <paulmck@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:40129 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933166AbXCFJLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 04:11:25 -0500
Content-Disposition: inline
In-Reply-To: <20070305.202632.74752497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 08:26:32PM -0800, David Miller wrote:
> 
> This is essentially a "port" of Nick Piggin's dcache hash table
> patches to the routing cache.  It solves the locking issues
> during table grow/shrink that I couldn't handle properly last
> time I tried to code up a patch like this.
> 
> But one of the core issues of this kind of change still remains.
> There is a conflict between the desire of routing cache garbage
> collection to reach a state of equilibrium and the hash table
> grow code's desire to match the table size to the current state
> of affairs.
> 
> Actually, more accurately, the conflict exists in how this GC
> logic is implemented.  The core issue is that hash table size
> guides the GC processing, and hash table growth therefore
> modifies those GC goals.  So with the patch below we'll just
> keep growing the hash table instead of giving GC some time to
> try to keep the working set in equilibrium before doing the
> hash grow.
> 
> One idea is to put the hash grow check in the garbage collector,
> and put the hash shrink check in rt_del().
> 
> In fact, it would be a good time to perhaps hack up some entirely
> new passive GC logic for the routing cache.
> 
> BTW, another thing that plays into this is that Robert's TRASH work
> could make this patch not necessary :-)
> 
> Finally, I know that (due to some of Nick's helpful comments the
> other day) that I'm missing some rcu_assign_pointer()'s in here.
> Fixes in this area are most welcome.

Cool! I have some fixes for the rcu barrier issues, with some C-style
comments and questions :)

I was going to send you a fix first for the rcu barriers, then a
second to convert the read-side to a barrier-less one that I described,
however considering that your patch is a WIP in progress anyway, I
won't worry too much about the normal protocol.

I _think_ my reasoning regarding the rcu barriers and grace periods
is correct. I'll keep thinking about it though. (Paul cc'ed).

I'm not so familiar with this code, so I have sprinkled around a lot
of comments that could be pure crap ;) They are mainly just to help
you ensure that you cover all bases... compile tested only at this
stage.

--
Index: linux-2.6/net/ipv4/route.c
===================================================================
--- linux-2.6.orig/net/ipv4/route.c
+++ linux-2.6/net/ipv4/route.c
@@ -311,6 +311,8 @@ static void rthash_free(struct rt_hash_b
 static unsigned int rt_hash_code(struct rt_hash *hashtable,
 				 u32 daddr, u32 saddr)
 {
+	/* BUG_ON(!rcu_read_protected()) */
+
 	return (jhash_2words(daddr, saddr, rt_hash_rnd)
 		& hashtable->mask);
 }
@@ -343,11 +345,16 @@ static void rt_hash_resize_work(struct w
 
 	old_rt_hash = rt_hash;
 	/*
-	 * ensure that if the reader sees the new dentry_hash,
-	 * then they will also see the old_dentry_hash assignment,
-	 * above.
+	 * ensure that if the reader sees the new rt_hash, then they will also
+	 * see the old_rt_hash assignment, above. synchronize_rcu() is used
+	 * rather than smp_wmb(), in order to avoid the smp_rmb() in the
+	 * read-sidde. However synchronize_rcu() also implies a smp_wmb(), so
+	 * that also means we can skip rcu_assign_pointer().
+	 *
+	 * The readers can then also skip rcu_dereference, because a grace
+	 * period implies that all readers have performed memory barriers.
 	 */
-	smp_wmb();
+	synchronize_rcu();
 	rt_hash = new_hash;
 	synchronize_rcu();
 
@@ -1100,6 +1107,8 @@ static int rt_intern_hash(struct rt_hash
 	int		chain_length;
 	int attempts = !in_softirq();
 
+	/* BUG_ON(!rcu_read_protected()) */
+
 restart:
 	chain_length = 0;
 	min_score = ~(u32)0;
@@ -1286,6 +1295,8 @@ static void rt_del(struct rt_hash *h, un
 {
 	struct rtable **rthp;
 
+	/* BUG_ON(!rcu_read_protected()) */
+
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	ip_rt_put(rt);
 	for (rthp = &h->table[hash].chain; *rthp;
@@ -1328,12 +1339,24 @@ void ip_rt_redirect(__be32 old_gw, __be3
 
 	for (i = 0; i < 2; i++) {
 		for (k = 0; k < 2; k++) {
-			struct rt_hash *h = rt_hash;
-			unsigned hash = rt_hashfn(h, daddr, skeys[i], ikeys[k]);
+			struct rt_hash *h;
+			unsigned hash;
+
+			/*
+			 * rcu_read_lock() must cover the load of rt_hash, in
+			 * order to satisfy our RCU protected dynamic hash
+			 * sizing scheme; and it must also cover the hash list
+			 * traversal, to satisfy our RCU protected lockless
+			 * hash entry lookups.
+			 *
+			 * This note applies throughout the file.
+			 */
+			rcu_read_lock();
+			h = rt_hash;
+			hash = rt_hashfn(h, daddr, skeys[i], ikeys[k]);
 
 			rthp=&h->table[hash].chain;
 
-			rcu_read_lock();
 			while ((rth = rcu_dereference(*rthp)) != NULL) {
 				struct rtable *rt;
 
@@ -1449,6 +1472,12 @@ static struct dst_entry *ipv4_negative_a
 					  "%u.%u.%u.%u/%02x dropped\n",
 				NIPQUAD(rt->rt_dst), rt->fl.fl4_tos);
 #endif
+			/* XXX:
+			 * What if rt does not exist in rt_hash, but is in
+			 * old_rt_hash? Don't we have to also check there?
+			 * Similar questions for a couple of other places that
+			 * look at rt_hash, but not old_rt_hash.
+			 */
 			rt_del(h, hash, rt);
 			ret = NULL;
 		}
@@ -1587,10 +1616,13 @@ unsigned short ip_rt_frag_needed(struct 
 		return 0;
 
 	for (i = 0; i < 2; i++) {
-		struct rt_hash *h = rt_hash;
-		unsigned hash = rt_hashfn(h, daddr, skeys[i], 0);
+		struct rt_hash *h;
+		unsigned hash;
 
 		rcu_read_lock();
+		h = rt_hash;
+		hash = rt_hashfn(h, daddr, skeys[i], 0);
+
 		for (rth = rcu_dereference(h->table[hash].chain); rth;
 		     rth = rcu_dereference(rth->u.dst.rt_next)) {
 			if (rth->fl.fl4_dst == daddr &&
@@ -2269,6 +2301,8 @@ static int __input_find(struct rt_hash *
 	unsigned int hash = rt_hashfn(h, daddr, saddr, iif);
 	struct rtable *rth;
 
+	/* BUG_ON(!rcu_read_protected()) */
+
 	for (rth = rcu_dereference(h->table[hash].chain); rth;
 	     rth = rcu_dereference(rth->u.dst.rt_next)) {
 		if (rth->fl.fl4_dst == daddr &&
@@ -2301,7 +2335,6 @@ int ip_route_input(struct sk_buff *skb, 
 
 	rcu_read_lock();
 	htab = rt_hash;
-	smp_rmb();
 	old_htab = old_rt_hash;
 	if (unlikely(old_htab)) {
 		unsigned long seq;
@@ -2768,6 +2801,8 @@ static int __output_find(struct rt_hash 
 	unsigned int hash = rt_hashfn(h, flp->fl4_dst, flp->fl4_src, flp->oif);
 	struct rtable *rth;
 
+	/* BUG_ON(!rcu_read_protected()) */
+
 	for (rth = rcu_dereference(h->table[hash].chain); rth;
 		rth = rcu_dereference(rth->u.dst.rt_next)) {
 		if (rth->fl.fl4_dst == flp->fl4_dst &&
@@ -2807,7 +2842,6 @@ int __ip_route_output_key(struct rtable 
 
 	rcu_read_lock_bh();
 	htab = rt_hash;
-	smp_rmb();
 	old_htab = old_rt_hash;
 	if (unlikely(old_htab)) {
 		unsigned long seq;
@@ -3048,18 +3082,20 @@ errout_free:
 
 int ip_rt_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct rt_hash *htab = rt_hash;
+	struct rt_hash *htab;
 	struct rtable *rt;
 	int h, s_h;
 	int idx, s_idx;
 
 	s_h = cb->args[0];
 	s_idx = idx = cb->args[1];
+
+	rcu_read_lock_bh();
+	htab = rt_hash;
 	for (h = 0; h <= htab->mask; h++) {
 		if (h < s_h) continue;
 		if (h > s_h)
 			s_idx = 0;
-		rcu_read_lock_bh();
 		for (rt = rcu_dereference(htab->table[h].chain), idx = 0; rt;
 		     rt = rcu_dereference(rt->u.dst.rt_next), idx++) {
 			if (idx < s_idx)
@@ -3069,15 +3105,14 @@ int ip_rt_dump(struct sk_buff *skb, stru
 					 cb->nlh->nlmsg_seq, RTM_NEWROUTE,
 					 1, NLM_F_MULTI) <= 0) {
 				dst_release(xchg(&skb->dst, NULL));
-				rcu_read_unlock_bh();
 				goto done;
 			}
 			dst_release(xchg(&skb->dst, NULL));
 		}
-		rcu_read_unlock_bh();
 	}
-
 done:
+	rcu_read_unlock_bh();
+
 	cb->args[0] = h;
 	cb->args[1] = idx;
 	return skb->len;
