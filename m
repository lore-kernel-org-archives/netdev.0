From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6] ipv6: Reduce timer events for addrconf_verify().
Date: Thu, 18 Mar 2010 18:01:11 +0900
Message-ID: <201003190635.o2J6Z17W016418@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:35392 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986Ab0CSGfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 02:35:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reduces timer events while keeping accuracy by rounding
our timer and/or batching several address validations in addrconf_verify().

addrconf_verify() is called at earliest timeout among interface addresses'
timeouts, but at maximum ADDR_CHECK_FREQUENCY (120 secs).

In most cases, all of timeouts of interface addresses are long enough
(e.g. several hours or days vs 2 minutes), this timer is usually called
every ADDR_CHECK_FREQUENCY, and it is okay to be lazy.
(Note this timer could be eliminated if all code paths which modifies
variables related to timeouts call us manually, but it is another story.)

However, in other least but important cases, we try keeping accuracy.

When the real interface address timeout is coming, and the timeout
is just before the rounded timeout, we accept some error.

When a timeout has been reached, we also try batching other several
events in very near future.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |   27 +++++++++++++++++++++++----
 1 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8d41abc..b716083 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -99,6 +99,10 @@
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
 #define TIME_DELTA(a,b) ((unsigned long)((long)(a) - (long)(b)))
 
+#define ADDRCONF_TIMER_FUZZ_MINUS	(HZ > 50 ? HZ/50 : 1)
+#define ADDRCONF_TIMER_FUZZ		(HZ / 4)
+#define ADDRCONF_TIMER_FUZZ_MAX		(HZ)
+
 #ifdef CONFIG_SYSCTL
 static void addrconf_sysctl_register(struct inet6_dev *idev);
 static void addrconf_sysctl_unregister(struct inet6_dev *idev);
@@ -3124,12 +3128,12 @@ int ipv6_chk_home_addr(struct net *net, struct in6_addr *addr)
 static void addrconf_verify(unsigned long foo)
 {
 	struct inet6_ifaddr *ifp;
-	unsigned long now, next;
+	unsigned long now, next, next_sec, next_sched;
 	int i;
 
 	spin_lock_bh(&addrconf_verify_lock);
 	now = jiffies;
-	next = now + ADDR_CHECK_FREQUENCY;
+	next = round_jiffies_up(now + ADDR_CHECK_FREQUENCY);
 
 	del_timer(&addr_chk_timer);
 
@@ -3147,7 +3151,8 @@ restart:
 				continue;
 
 			spin_lock(&ifp->lock);
-			age = (now - ifp->tstamp) / HZ;
+			/* We try to batch several events at once. */
+			age = (now - ifp->tstamp + ADDRCONF_TIMER_FUZZ_MINUS) / HZ;
 
 #ifdef CONFIG_IPV6_PRIVACY
 			regen_advance = ifp->idev->cnf.regen_max_retry *
@@ -3222,7 +3227,21 @@ restart:
 		read_unlock(&addrconf_hash_lock);
 	}
 
-	addr_chk_timer.expires = time_before(next, jiffies + HZ) ? jiffies + HZ : next;
+	next_sec = round_jiffies_up(next);
+	next_sched = next;
+
+	/* If rounded timeout is accurate enough, accept it. */
+	if (time_before(next_sec, next + ADDRCONF_TIMER_FUZZ))
+		next_sched = next_sec;
+
+	/* And minimum interval is ADDRCONF_TIMER_FUZZ_MAX. */
+	if (time_before(next_sched, jiffies + ADDRCONF_TIMER_FUZZ_MAX))
+		next_sched = jiffies + ADDRCONF_TIMER_FUZZ_MAX;
+
+	ADBG((KERN_DEBUG "now = %lu, schedule = %lu, rounded schedule = %lu => %lu\n",
+	      now, next, next_sec, next_sched));
+
+	addr_chk_timer.expires = next_sched;
 	add_timer(&addr_chk_timer);
 	spin_unlock_bh(&addrconf_verify_lock);
 }
-- 
1.5.6.5

