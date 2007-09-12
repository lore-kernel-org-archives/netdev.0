From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] IPV4 : convert rt_check_expire() from softirq processing to
 workqueue
Date: Wed, 12 Sep 2007 15:34:44 +0200
Message-ID: <20070912153444.bb564a6f.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:51261 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965718AbXILNeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 09:34:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On loaded/big hosts, rt_check_expire() if of litle use, because it
generally breaks out of its main loop because of a jiffies change.

It can take a long time (read : timer invocations) to actually
scan the whole hash table, freeing unused entries.

Converting it to use a workqueue instead of softirq is a nice
move because we can allow rt_check_expire() to do the scan
it is supposed to do, without hogging the CPU.

This has an impact on the average number of entries in cache, 
reducing ram usage. Cache is more responsive to parameter
changes (/proc/sys/net/ipv4/route/gc_timeout and
/proc/sys/net/ipv4/route/gc_interval)

Note: Maybe the default value of gc_interval (60 seconds)
is too high, since this means we actually need 5 (300/60)
invocations to scan the whole table.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 396c631..006d605 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -81,6 +81,7 @@
 #include <linux/netdevice.h>
 #include <linux/proc_fs.h>
 #include <linux/init.h>
+#include <linux/workqueue.h>
 #include <linux/skbuff.h>
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
@@ -136,7 +137,8 @@ static unsigned long rt_deadline;
 #define RTprint(a...)	printk(KERN_DEBUG a)
 
 static struct timer_list rt_flush_timer;
-static struct timer_list rt_periodic_timer;
+static void rt_check_expire(struct work_struct *work);
+static DECLARE_DELAYED_WORK(expires_work, rt_check_expire);
 static struct timer_list rt_secret_timer;
 
 /*
@@ -572,20 +574,19 @@ static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 		(fl1->iif ^ fl2->iif)) == 0;
 }
 
-/* This runs via a timer and thus is always in BH context. */
-static void rt_check_expire(unsigned long dummy)
+static void rt_check_expire(struct work_struct *work)
 {
 	static unsigned int rover;
 	unsigned int i = rover, goal;
 	struct rtable *rth, **rthp;
-	unsigned long now = jiffies;
 	u64 mult;
 
 	mult = ((u64)ip_rt_gc_interval) << rt_hash_log;
 	if (ip_rt_gc_timeout > 1)
 		do_div(mult, ip_rt_gc_timeout);
 	goal = (unsigned int)mult;
-	if (goal > rt_hash_mask) goal = rt_hash_mask + 1;
+	if (goal > rt_hash_mask)
+		goal = rt_hash_mask + 1;
 	for (; goal > 0; goal--) {
 		unsigned long tmo = ip_rt_gc_timeout;
 
@@ -594,11 +595,11 @@ static void rt_check_expire(unsigned long dummy)
 
 		if (*rthp == 0)
 			continue;
-		spin_lock(rt_hash_lock_addr(i));
+		spin_lock_bh(rt_hash_lock_addr(i));
 		while ((rth = *rthp) != NULL) {
 			if (rth->u.dst.expires) {
 				/* Entry is expired even if it is in use */
-				if (time_before_eq(now, rth->u.dst.expires)) {
+				if (time_before_eq(jiffies, rth->u.dst.expires)) {
 					tmo >>= 1;
 					rthp = &rth->u.dst.rt_next;
 					continue;
@@ -613,14 +614,10 @@ static void rt_check_expire(unsigned long dummy)
 			*rthp = rth->u.dst.rt_next;
 			rt_free(rth);
 		}
-		spin_unlock(rt_hash_lock_addr(i));
-
-		/* Fallback loop breaker. */
-		if (time_after(jiffies, now))
-			break;
+		spin_unlock_bh(rt_hash_lock_addr(i));
 	}
 	rover = i;
-	mod_timer(&rt_periodic_timer, jiffies + ip_rt_gc_interval);
+	schedule_delayed_work(&expires_work, ip_rt_gc_interval);
 }
 
 /* This can run from both BH and non-BH contexts, the latter
@@ -2993,17 +2990,14 @@ int __init ip_rt_init(void)
 
 	init_timer(&rt_flush_timer);
 	rt_flush_timer.function = rt_run_flush;
-	init_timer(&rt_periodic_timer);
-	rt_periodic_timer.function = rt_check_expire;
 	init_timer(&rt_secret_timer);
 	rt_secret_timer.function = rt_secret_rebuild;
 
 	/* All the timers, started at system startup tend
 	   to synchronize. Perturb it a bit.
 	 */
-	rt_periodic_timer.expires = jiffies + net_random() % ip_rt_gc_interval +
-					ip_rt_gc_interval;
-	add_timer(&rt_periodic_timer);
+	schedule_delayed_work(&expires_work,
+		net_random() % ip_rt_gc_interval + ip_rt_gc_interval);
 
 	rt_secret_timer.expires = jiffies + net_random() % ip_rt_secret_interval +
 		ip_rt_secret_interval;
