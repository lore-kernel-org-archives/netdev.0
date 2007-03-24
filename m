From: David Miller <davem@davemloft.net>
Subject: Re: [6/6] 2.6.21-rc4: known regressions
Date: Sat, 24 Mar 2007 12:50:46 -0700 (PDT)
Message-ID: <20070324.125046.112613933.davem@davemloft.net>
References: <Pine.LNX.4.64.0703160925270.26106@woody.linux-foundation.org>
	<20070318184938.GZ752@stusta.de>
	<20070319.193829.102575512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, lenb@kernel.org,
	netdev@vger.kernel.org
To: bunk@stusta.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753336AbXCXVfG@vger.kernel.org>
In-Reply-To: <20070319.193829.102575512.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 19 Mar 2007 19:38:29 -0700 (PDT)

> From: Adrian Bunk <bunk@stusta.de>
> Date: Sun, 18 Mar 2007 19:49:38 +0100
> 
> > Subject    : ipv6 crash
> > References : http://lkml.org/lkml/2007/3/10/2
> > Submitter  : Len Brown <lenb@kernel.org>
> > Status     : unknown
> 
> This is caused by some problem in the router round-robin code in
> net/ipv6/route.c:rt6_select()
 ...
> I'll see if I can come up with something to fix this properly.

Here is the fix I came up with and just posted to netdev for
a quick review, I'll push this to the appropriate places soon
if nobody spots any problems in it.

commit 4c68db63b8314df3cf30b7fe595a1b8935bb2cb0
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Sat Mar 24 12:06:32 2007 -0700

    [IPV6]: Fix routing round-robin locking.
    
    As per RFC2461, section 6.3.6, item #2, when no routers on the
    matching list are known to be reachable or probably reachable we
    do round robin on those available routes so that we make sure
    to probe as many of them as possible to detect when one becomes
    reachable faster.
    
    Each routing table has a rwlock protecting the tree and the linked
    list of routes at each leaf.  The round robin code executes during
    lookup and thus with the rwlock taken as a reader.  A small local
    spinlock tries to provide protection but this does not work at all
    for two reasons:
    
    1) The round-robin list manipulation, as coded, goes like this (with
       read lock held):
    
    	walk routes finding head and tail
    
    	spin_lock();
    	rotate list using head and tail
    	spin_unlock();
    
       While one thread is rotating the list, another thread can
       end up with stale values of head and tail and then proceed
       to corrupt the list when it gets the lock.  This ends up causing
       the OOPS in fib6_add() later onthat many people have been hitting.
    
    2) All the other code paths that run with the rwlock held as
       a reader do not expect the list to change on them, they
       expect it to remain completely fixed while they hold the
       lock in that way.
    
    So, simply stated, it is impossible to implement this correctly using
    a manipulation of the list without violating the rwlock locking
    semantics.
    
    Reimplement using a per-fib6_node round-robin pointer.  This way we
    don't need to manipulate the list at all, and since the round-robin
    pointer can only ever point to real existing entries we don't need
    to perform any locking on the changing of the round-robin pointer
    itself.  We only need to reset the round-robin pointer to NULL when
    the entry it is pointing to is removed.
    
    The idea is from Thomas Graf and it is very similar to how this
    was implemented before the advanced router selection code when in.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 9eda572..cf355a3 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -58,6 +58,7 @@ struct fib6_node
 	__u16			fn_bit;		/* bit key */
 	__u16			fn_flags;
 	__u32			fn_sernum;
+	struct rt6_info		*rr_ptr;
 };
 
 #ifndef CONFIG_IPV6_SUBTREES
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index f4d7be7..c46f909 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1109,6 +1109,10 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 	rt6_stats.fib_rt_entries--;
 	rt6_stats.fib_discarded_routes++;
 
+	/* Reset round-robin state, if necessary */
+	if (fn->rr_ptr == rt)
+		fn->rr_ptr = NULL;
+
 	/* Adjust walkers */
 	read_lock(&fib6_walker_lock);
 	FOR_WALKERS(w) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a6b3117..3931b33 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -363,55 +363,76 @@ static int rt6_score_route(struct rt6_info *rt, int oif,
 	return m;
 }
 
-static struct rt6_info *rt6_select(struct rt6_info **head, int oif,
-				   int strict)
+static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
+				   int *mpri, struct rt6_info *match)
 {
-	struct rt6_info *match = NULL, *last = NULL;
-	struct rt6_info *rt, *rt0 = *head;
-	u32 metric;
+	int m;
+
+	if (rt6_check_expired(rt))
+		goto out;
+
+	m = rt6_score_route(rt, oif, strict);
+	if (m < 0)
+		goto out;
+
+	if (m > *mpri) {
+		if (strict & RT6_LOOKUP_F_REACHABLE)
+			rt6_probe(match);
+		*mpri = m;
+		match = rt;
+	} else if (strict & RT6_LOOKUP_F_REACHABLE) {
+		rt6_probe(rt);
+	}
+
+out:
+	return match;
+}
+
+static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
+				     struct rt6_info *rr_head,
+				     u32 metric, int oif, int strict)
+{
+	struct rt6_info *rt, *match;
 	int mpri = -1;
 
-	RT6_TRACE("%s(head=%p(*head=%p), oif=%d)\n",
-		  __FUNCTION__, head, head ? *head : NULL, oif);
+	match = NULL;
+	for (rt = rr_head; rt && rt->rt6i_metric == metric;
+	     rt = rt->u.dst.rt6_next)
+		match = find_match(rt, oif, strict, &mpri, match);
+	for (rt = fn->leaf; rt && rt != rr_head && rt->rt6i_metric == metric;
+	     rt = rt->u.dst.rt6_next)
+		match = find_match(rt, oif, strict, &mpri, match);
 
-	for (rt = rt0, metric = rt0->rt6i_metric;
-	     rt && rt->rt6i_metric == metric && (!last || rt != rt0);
-	     rt = rt->u.dst.rt6_next) {
-		int m;
+	return match;
+}
 
-		if (rt6_check_expired(rt))
-			continue;
+static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
+{
+	struct rt6_info *match, *rt0;
 
-		last = rt;
+	RT6_TRACE("%s(fn->leaf=%p, oif=%d)\n",
+		  __FUNCTION__, fn->leaf, oif);
 
-		m = rt6_score_route(rt, oif, strict);
-		if (m < 0)
-			continue;
+	rt0 = fn->rr_ptr;
+	if (!rt0)
+		fn->rr_ptr = rt0 = fn->leaf;
 
-		if (m > mpri) {
-			if (strict & RT6_LOOKUP_F_REACHABLE)
-				rt6_probe(match);
-			match = rt;
-			mpri = m;
-		} else if (strict & RT6_LOOKUP_F_REACHABLE) {
-			rt6_probe(rt);
-		}
-	}
+	match = find_rr_leaf(fn, rt0, rt0->rt6i_metric, oif, strict);
 
 	if (!match &&
-	    (strict & RT6_LOOKUP_F_REACHABLE) &&
-	    last && last != rt0) {
+	    (strict & RT6_LOOKUP_F_REACHABLE)) {
+		struct rt6_info *next = rt0->u.dst.rt6_next;
+
 		/* no entries matched; do round-robin */
-		static DEFINE_SPINLOCK(lock);
-		spin_lock(&lock);
-		*head = rt0->u.dst.rt6_next;
-		rt0->u.dst.rt6_next = last->u.dst.rt6_next;
-		last->u.dst.rt6_next = rt0;
-		spin_unlock(&lock);
+		if (!next || next->rt6i_metric != rt0->rt6i_metric)
+			next = fn->leaf;
+
+		if (next != rt0)
+			fn->rr_ptr = next;
 	}
 
-	RT6_TRACE("%s() => %p, score=%d\n",
-		  __FUNCTION__, match, mpri);
+	RT6_TRACE("%s() => %p\n",
+		  __FUNCTION__, match);
 
 	return (match ? match : &ip6_null_entry);
 }
@@ -657,7 +678,7 @@ restart_2:
 	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 
 restart:
-	rt = rt6_select(&fn->leaf, fl->iif, strict | reachable);
+	rt = rt6_select(fn, fl->iif, strict | reachable);
 	BACKTRACK(&fl->fl6_src);
 	if (rt == &ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
@@ -752,7 +773,7 @@ restart_2:
 	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 
 restart:
-	rt = rt6_select(&fn->leaf, fl->oif, strict | reachable);
+	rt = rt6_select(fn, fl->oif, strict | reachable);
 	BACKTRACK(&fl->fl6_src);
 	if (rt == &ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
