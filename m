From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv4 routing: Fixes to allow route cache entries to
	work when route caching is disabled
Date: Mon, 22 Jun 2009 14:39:55 -0400
Message-ID: <20090622183955.GC14673@hmsreliant.think-freely.org>
References: <20090622152314.GB14359@hmsreliant.think-freely.org> <20090622165145.GA2737@ami.dom.local> <20090622170327.GA14673@hmsreliant.think-freely.org> <20090622172051.GB2737@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, mbizon@freebox.fr
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40005 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbZFVSkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 14:40:06 -0400
Content-Disposition: inline
In-Reply-To: <20090622172051.GB2737@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<snip>
> > > dst_free() yet.
> > Not sure I see the advantage.  The path winds up being the same regardless, the
> > typing matches up with the rt_free call, and by using the RCU path we are given
> > the possibility to batch a bunch of spinlocks in the cache at an RCU quiesence
> > point.
> 
> IMHO it's simply misleading. I don't think call_rcu() is a proper way
> to improve cache performance.
> 
I really don't see how its misleading (at least not any more misleading than
dst_free.  I agree that avoiding the rcu point in rt_free might provide some
small performance benefit, but we still need to wait for a workqueue to run to
real the entry, which is where the major performance hit here comes in,  And
rt_free matches our typing here, so its more readable.  Bearing in mind that, if
we're in this path, then we're already (a) running in a degraded performance
mode since we're not caching routes and (b) we're doing so because running with
caching enabled is producing ostensibly poorer performance (because of constant
hash table rebuilds from extra long hash chains), I don't think the change is
worthwhile.

> > > Aren't we jumping over a spin_lock here?
> > > 
> > We are jumping over a spinlock, both the acquire and release, which is exactly
> > what we want, since when rt_caching returns false, we're not adding the route
> > cache entry into the hash table, which is what that lock protects.
> 
> +skip_hashing:
> >  	if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
> >  		int err = arp_bind_neighbour(&rt->u.dst);
> >  		if (err) {
> 
> Even if (err) is impossible here with skip_hashing I think it's
> _extremely_ unreadable. Why can't we inline these lines in the above
> 'if (!caching)' block and save one such if later?
This is a fair point, and I agree it would probably makes sense to inline the
arp binding code twice, especially given that we can streamline it in the first
instance since we don't need to do any locking and theres no point in trying to
shrink the route cache (since it should be almost empty, given that we're not
caching.

Ok, Version 2 of the patch is below.

Change Notes:

1) modified rt_intern_hash path so that arp binding code is duplicated and
inlined at each use site so as to avoid the additional branch of not doing so.
The first instance is streamlined since theres no need to do any hash table
locking and shrinking the route cache isn't usefull (due to it being empty).

Neil


Ensure that route cache entries are usable and reclaimable with caching is off

When route caching is disabled (rt_caching returns false), We still use route
cache entries that are created and passed into rt_intern_hash once.  These
routes need to be made usable for the one call path that holds a reference to
them, and they need to be reclaimed when they're finished with their use.  To be
made usable, they need to be associated with a neighbor table entry (which they
currently are not), otherwise iproute_finish2 just discards the packet, since we
don't know which L2 peer to send the packet to.  To do this binding, we need to
follow the path a bit higher up in rt_intern_hash, which calls
arp_bind_neighbour, but not assign the route entry to the hash table.
Currently, if caching is off, we simply assign the route to the rp pointer and
are reutrn success.  This patch associates us with a neighbor entry first.

Secondly, we need to make sure that any single use routes like this are known to
the garbage collector when caching is off.  If caching is off, and we try to
hash in a route, it will leak when its refcount reaches zero.  To avoid this,
this patch calls rt_free on the route cache entry passed into rt_intern_hash.
This places us on the gc list for the route cache garbage collector, so that
when its refcount reaches zero, it will be reclaimed (Thanks to Alexey for this
suggestion).

I've tested this on a local system here, and with these patches in place, I'm
able to maintain routed connectivity to remote systems, even if I set
/proc/sys/net/ipv4/rt_cache_rebuild_count to -1, which forces rt_caching to
return false.

Best
Neil

Signed-off-by: Neil Horman <nhorman@redhat.com>
Reported-by: Jarek Poplawski <jarkao2@gmail.com>
Reported-by: Maxime Bizon <mbizon@freebox.fr>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 65b3a8b..1a22631 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1076,6 +1076,7 @@ static int rt_intern_hash(unsigned hash, struct rtable *rt,
 	u32 		min_score;
 	int		chain_length;
 	int attempts = !in_softirq();
+	int caching = rt_caching(dev_net(rt->u.dst.dev));
 
 restart:
 	chain_length = 0;
@@ -1084,7 +1085,7 @@ restart:
 	candp = NULL;
 	now = jiffies;
 
-	if (!rt_caching(dev_net(rt->u.dst.dev))) {
+	if (!caching) {
 		/*
 		 * If we're not caching, just tell the caller we
 		 * were successful and don't touch the route.  The
@@ -1093,8 +1094,23 @@ restart:
 		 * If we drop it here, the callers have no way to resolve routes
 		 * when we're not caching.  Instead, just point *rp at rt, so
 		 * the caller gets a single use out of the route
+		 * Note that we do rt_free on this new route entry, so that
+		 * once its refcount hits zero, we are still able to reap it
+		 * (Thanks Alexey)
 		 */
-		goto report_and_exit;
+		rt_free(rt);
+
+
+		if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
+			int err = arp_bind_neighbour(&rt->u.dst);
+			if (err) {
+				if (net_ratelimit())
+					printk(KERN_WARNING "Neighbour table failure & not caching routes.\n");
+				rt_drop(rt);
+				return err;
+			}
+		}
+		goto skip_hashing;
 	}
 
 	rthp = &rt_hash_table[hash].chain;
@@ -1211,7 +1227,8 @@ restart:
 #if RT_CACHE_DEBUG >= 2
 	if (rt->u.dst.rt_next) {
 		struct rtable *trt;
-		printk(KERN_DEBUG "rt_cache @%02x: %pI4", hash, &rt->rt_dst);
+		printk(KERN_DEBUG "rt_cache @%02x: %pI4",
+		       hash, &rt->rt_dst);
 		for (trt = rt->u.dst.rt_next; trt; trt = trt->u.dst.rt_next)
 			printk(" . %pI4", &trt->rt_dst);
 		printk("\n");
@@ -1226,7 +1243,7 @@ restart:
 
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 
-report_and_exit:
+skip_hashing:
 	if (rp)
 		*rp = rt;
 	else
