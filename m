From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] neigh: Force garbage collection if an entry is
 deleted administratively
Date: Mon, 18 Nov 2013 11:08:43 +0100
Message-ID: <20131118100843.GY31491@secunet.com>
References: <20131112085714.GU31491@secunet.com>
 <20131114.022356.1095983243221745109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34286 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157Ab3KRKIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 05:08:45 -0500
Content-Disposition: inline
In-Reply-To: <20131114.022356.1095983243221745109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 02:23:56AM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Tue, 12 Nov 2013 09:57:14 +0100
> 
> > Since git commit 2724680 ("neigh: Keep neighbour cache entries if number
> > of them is small enough."), we keep all neighbour cache entries if the
> > number is below a threshold. But if we now delete an entry administratively
> > and then try to replace this by a permanent one, we get -EEXIST because the
> > old entry ist still in the table (in NUD_FAILED state).
> > 
> > So lets force a garbage collect if we delete an entry administratively.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> I don't think this is a sufficient fix.

Yes, looks like that.

> 
> If some entity refers to this entry (refcnt != 1) then the forced
> GC won't do anything, and this is very much possible.
> 
> It is the difficult situation mentioned in a comment in
> neigh_flush_dev() below the "refcnt != 1" test there.

We ensured that an entry will go away if the refcount got to 1
by cyclic garbage collecting. Now we do this only if the cached
entries are above a threshold, so we have to handle this somehow
different if the cached entries are below this threshold.

Currently we do cyclic rescheduling of the gc worker but the worker
exits immediately if cached entries are below the threshold.
I'm testing an approach where we schedule the gc worker only if
the entries are above the threshold or if there is an administrative
change.

The patch I'm testing is below. It is pure RFC at the moment,
but I would be grateful for comments on the approach.


Subject: [PATCH RFC] neigh: Fix garbage collection if the cached entries are
 below the threshold

Since git commit 2724680 ("neigh: Keep neighbour cache entries if number
of them is small enough."), we keep all neighbour cache entries if the
number is below a threshold. But if we now delete an entry administratively
and then try to replace this by a permanent one, we get -EEXIST because the
old entry ist still in the table (in NUD_FAILED state).

So remove the threshold check in neigh_periodic_work() and schedule the
gc_work only when needed, i.e. if gc_thresh1 is reached or if there is
an administrative change. We reschedule gc_work either if the number of
cache entries is still above gc_thresh1 or if there are invalid entries
with "refcnt != 1" cached.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/core/neighbour.c |   29 ++++++++++++++++++++---------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ca15f32..39c2a24 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -239,6 +239,9 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 				else
 					n->nud_state = NUD_NONE;
 				neigh_dbg(2, "neigh %p is stray\n", n);
+				schedule_delayed_work(&tbl->gc_work,
+						      tbl->parms.base_reachable_time >> 1);
+
 			}
 			write_unlock(&n->lock);
 			neigh_cleanup_and_release(n);
@@ -282,6 +285,9 @@ static struct neighbour *neigh_alloc(struct neigh_table *tbl, struct net_device
 			goto out_entries;
 	}
 
+	if (entries >= tbl->gc_thresh1)
+		schedule_delayed_work(&tbl->gc_work, 0);
+
 	n = kzalloc(tbl->entry_size + dev->neigh_priv_len, GFP_ATOMIC);
 	if (!n)
 		goto out_entries;
@@ -757,6 +763,7 @@ static void neigh_periodic_work(struct work_struct *work)
 	struct neighbour __rcu **np;
 	unsigned int i;
 	struct neigh_hash_table *nht;
+	bool schedule = false;
 
 	NEIGH_CACHE_STAT_INC(tbl, periodic_gc_runs);
 
@@ -764,9 +771,6 @@ static void neigh_periodic_work(struct work_struct *work)
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
 
-	if (atomic_read(&tbl->entries) < tbl->gc_thresh1)
-		goto out;
-
 	/*
 	 *	periodically recompute ReachableTime from random function
 	 */
@@ -785,6 +789,7 @@ static void neigh_periodic_work(struct work_struct *work)
 		while ((n = rcu_dereference_protected(*np,
 				lockdep_is_held(&tbl->lock))) != NULL) {
 			unsigned int state;
+			int refcnt;
 
 			write_lock(&n->lock);
 
@@ -797,7 +802,8 @@ static void neigh_periodic_work(struct work_struct *work)
 			if (time_before(n->used, n->confirmed))
 				n->used = n->confirmed;
 
-			if (atomic_read(&n->refcnt) == 1 &&
+			refcnt = atomic_read(&n->refcnt);
+			if (refcnt == 1 &&
 			    (state == NUD_FAILED ||
 			     time_after(jiffies, n->used + n->parms->gc_staletime))) {
 				*np = n->next;
@@ -805,7 +811,8 @@ static void neigh_periodic_work(struct work_struct *work)
 				write_unlock(&n->lock);
 				neigh_cleanup_and_release(n);
 				continue;
-			}
+			} else if (refcnt != 1 && !(state & NUD_VALID))
+				schedule = true;
 			write_unlock(&n->lock);
 
 next_elt:
@@ -821,13 +828,15 @@ next_elt:
 		nht = rcu_dereference_protected(tbl->nht,
 						lockdep_is_held(&tbl->lock));
 	}
-out:
-	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
+
+	/* Cycle through all hash buckets every base_reachable_time/2 ticks
+	 * as long as we have more than gc_thresh1 entries cached.
 	 * ARP entry timeouts range from 1/2 base_reachable_time to 3/2
 	 * base_reachable_time.
 	 */
-	schedule_delayed_work(&tbl->gc_work,
-			      tbl->parms.base_reachable_time >> 1);
+	if (schedule == true || atomic_read(&tbl->entries) >= tbl->gc_thresh1)
+		schedule_delayed_work(&tbl->gc_work,
+				      tbl->parms.base_reachable_time >> 1);
 	write_unlock_bh(&tbl->lock);
 }
 
@@ -1659,6 +1668,8 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 				   NEIGH_UPDATE_F_OVERRIDE |
 				   NEIGH_UPDATE_F_ADMIN);
 		neigh_release(neigh);
+
+		schedule_delayed_work(&tbl->gc_work, 0);
 		goto out;
 	}
 	read_unlock(&neigh_tbl_lock);
-- 
1.7.9.5
