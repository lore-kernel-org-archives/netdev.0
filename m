From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Sun, 08 Jun 2003 23:56:22 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030608.235622.38700262.davem@redhat.com>
References: <001501c32e4b$35d67d60$4a00000a@badass>
	<20030608.230332.48514434.davem@redhat.com>
	<20030609065211.GB20613@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: sim@netnation.com
In-Reply-To: <20030609065211.GB20613@netnation.com>
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Sun, 8 Jun 2003 23:52:11 -0700

   On Sun, Jun 08, 2003 at 11:03:32PM -0700, David S. Miller wrote:
   
   > Here is a simple idea, make the routing cache miss case steal
   > an entry sitting at the end of the hash chain this new one will
   > map to.  It only steals entries which have not been recently used.
   
   I just asked whether this was possible in a previous email, but you must
   have missed it.  I am seeing a lot of memory management stuff in
   profiles, so I think recycling routing cache entries (if only when the
   table is full and the garbage collector would otherwise need to run)
   would be very helpful.

Yes, indeed.
   
   Is it possible to get a good guess of what cache entry to recycle without
   walking for a while or without some kind of LRU?

This is what my (and therefore your) suggested scheme is trying to
do.

We have to walk the entire destination hash chain _ANYWAYS_ to verify
that a matching entry has not been put into the cache while we were
procuring the new one.  During this walk we can also choose a
candidate rtcache entry to free.

Something like the patch at the end of this email, doesn't compile
it's just a work in progress.  The trick is picking TIMEOUT1 and
TIMEOUT2 :)

Another point is that the default ip_rt_gc_min_interval is
absolutely horrible for DoS like attacks.  When DoS traffic
can fill the rtcache multiple times per second, using a GC
interval of 5 seconds is the worst possible choice. :)

When I see things like this, I can only come to the conclusion
that the tuning Alexey originally did when coding up the rtcache
merely needs to be scaled up to modern day packet rates.

--- net/ipv4/route.c.~1~	Sun Jun  8 23:28:00 2003
+++ net/ipv4/route.c	Sun Jun  8 23:45:47 2003
@@ -717,14 +717,15 @@
 
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
-	struct rtable	*rth, **rthp;
-	unsigned long	now = jiffies;
+	struct rtable	*rth, **rthp, *cand, **candp;
+	unsigned long	now = jiffies, cand_use = now;
 	int attempts = !in_softirq();
 
 restart:
 	rthp = &rt_hash_table[hash].chain;
 
 	spin_lock_bh(&rt_hash_table[hash].lock);
+	cand = NULL;
 	while ((rth = *rthp) != NULL) {
 		if (compare_keys(&rth->fl, &rt->fl)) {
 			/* Put it first */
@@ -753,7 +754,21 @@
 			return 0;
 		}
 
+		if (rt_may_expire(rth, TIMEOUT1, TIMEOUT2)) {
+			unsigned long this_use = rth->u.dst.lastuse;
+
+			if (time_before_eq(this_use, cand_use)) {
+				cand = rth;
+				candp = rthp;
+				cand_use = this_use;
+			}
+		}
 		rthp = &rth->u.rt_next;
+	}
+
+	if (cand) {
+		*candp = cand->u.rt_next;
+		rt_free(cand);
 	}
 
 	/* Try to bind route to arp only if it is output
