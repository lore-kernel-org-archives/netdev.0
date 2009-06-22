From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv4 routing: Fixes to allow route cache entries to
	work when route caching is disabled
Date: Mon, 22 Jun 2009 16:18:53 -0400
Message-ID: <20090622201853.GA16295@hmsreliant.think-freely.org>
References: <20090622152314.GB14359@hmsreliant.think-freely.org> <20090622165145.GA2737@ami.dom.local> <20090622170327.GA14673@hmsreliant.think-freely.org> <20090622172051.GB2737@ami.dom.local> <20090622183955.GC14673@hmsreliant.think-freely.org> <20090622195712.GC2737@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, mbizon@freebox.fr
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51145 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152AbZFVUS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 16:18:58 -0400
Content-Disposition: inline
In-Reply-To: <20090622195712.GC2737@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, Version 3 of the patch, with Jareks cosmetic changes in place:


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


 route.c |   26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)


diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 65b3a8b..badb536 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1093,8 +1093,27 @@ restart:
 		 * If we drop it here, the callers have no way to resolve routes
 		 * when we're not caching.  Instead, just point *rp at rt, so
 		 * the caller gets a single use out of the route
+		 * Note that we do rt_free on this new route entry, so that
+		 * once its refcount hits zero, we are still able to reap it
+		 * (Thanks Alexey)
+		 * Note also the rt_free uses call_rcu.  We don't actually
+		 * need rcu protection here, this is just our path to get
+		 * on the route gc list.
 		 */
-		goto report_and_exit;
+
+		if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
+			int err = arp_bind_neighbour(&rt->u.dst);
+			if (err) {
+				if (net_ratelimit())
+					printk(KERN_WARNING
+					    "Neighbour table failure & not caching routes.\n");
+				rt_drop(rt);
+				return err;
+			}
+		}
+
+		rt_free(rt);
+		goto skip_hashing;
 	}
 
 	rthp = &rt_hash_table[hash].chain;
@@ -1211,7 +1230,8 @@ restart:
 #if RT_CACHE_DEBUG >= 2
 	if (rt->u.dst.rt_next) {
 		struct rtable *trt;
-		printk(KERN_DEBUG "rt_cache @%02x: %pI4", hash, &rt->rt_dst);
+		printk(KERN_DEBUG "rt_cache @%02x: %pI4",
+		       hash, &rt->rt_dst);
 		for (trt = rt->u.dst.rt_next; trt; trt = trt->u.dst.rt_next)
 			printk(" . %pI4", &trt->rt_dst);
 		printk("\n");
@@ -1226,7 +1246,7 @@ restart:
 
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 
-report_and_exit:
+skip_hashing:
 	if (rp)
 		*rp = rt;
 	else
