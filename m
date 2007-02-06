From: akpm@linux-foundation.org
Subject: [patch 01/11] user of the jiffies rounding code: Networking
Date: Mon, 05 Feb 2007 16:30:52 -0800
Message-ID: <200702060031.l160VtQ3004618@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	arjan@linux.intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41436 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933034AbXBFAcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:32:01 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@linux.intel.com>

This patch introduces users of the round_jiffies() function in the networking
code.

These timers all were of the "about once a second" or "about once every X
seconds" variety and several showed up in the "what wakes the cpu up" profiles
that the tickless patches provide.  Some timers are highly dynamic based on
network load; but even on low activity systems they still show up so the
rounding is done only in cases of low activity, allowing higher frequency
timers in the high activity case.

The various hardware watchdogs are an obvious case; they run every 2 seconds
but aren't otherwise specific of exactly when they need to run.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e1000/e1000_main.c |    6 +++---
 net/core/dst.c                 |    9 ++++++++-
 net/core/neighbour.c           |    5 ++++-
 net/sched/sch_generic.c        |    2 +-
 4 files changed, 16 insertions(+), 6 deletions(-)

diff -puN drivers/net/e1000/e1000_main.c~user-of-the-jiffies-rounding-code-networking drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c~user-of-the-jiffies-rounding-code-networking
+++ a/drivers/net/e1000/e1000_main.c
@@ -2652,7 +2652,7 @@ e1000_watchdog(unsigned long data)
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
-			mod_timer(&adapter->phy_info_timer, jiffies + 2 * HZ);
+			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
 			adapter->smartspeed = 0;
 		} else {
 			/* make sure the receive unit is started */
@@ -2669,7 +2669,7 @@ e1000_watchdog(unsigned long data)
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
-			mod_timer(&adapter->phy_info_timer, jiffies + 2 * HZ);
+			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
 
 			/* 80003ES2LAN workaround--
 			 * For packet buffer work-around on link down event;
@@ -2721,7 +2721,7 @@ e1000_watchdog(unsigned long data)
 		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);
 
 	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
 }
 
 enum latency_range {
diff -puN net/core/dst.c~user-of-the-jiffies-rounding-code-networking net/core/dst.c
--- a/net/core/dst.c~user-of-the-jiffies-rounding-code-networking
+++ a/net/core/dst.c
@@ -99,7 +99,14 @@ static void dst_run_gc(unsigned long dum
 	printk("dst_total: %d/%d %ld\n",
 	       atomic_read(&dst_total), delayed,  dst_gc_timer_expires);
 #endif
-	mod_timer(&dst_gc_timer, jiffies + dst_gc_timer_expires);
+	/* if the next desired timer is more than 4 seconds in the future
+	 * then round the timer to whole seconds
+	 */
+	if (dst_gc_timer_expires > 4*HZ)
+		mod_timer(&dst_gc_timer,
+			round_jiffies(jiffies + dst_gc_timer_expires));
+	else
+		mod_timer(&dst_gc_timer, jiffies + dst_gc_timer_expires);
 
 out:
 	spin_unlock(&dst_lock);
diff -puN net/core/neighbour.c~user-of-the-jiffies-rounding-code-networking net/core/neighbour.c
--- a/net/core/neighbour.c~user-of-the-jiffies-rounding-code-networking
+++ a/net/core/neighbour.c
@@ -696,7 +696,10 @@ next_elt:
 	if (!expire)
 		expire = 1;
 
- 	mod_timer(&tbl->gc_timer, now + expire);
+	if (expire>HZ)
+		mod_timer(&tbl->gc_timer, round_jiffies(now + expire));
+	else
+	 	mod_timer(&tbl->gc_timer, now + expire);
 
 	write_unlock(&tbl->lock);
 }
diff -puN net/sched/sch_generic.c~user-of-the-jiffies-rounding-code-networking net/sched/sch_generic.c
--- a/net/sched/sch_generic.c~user-of-the-jiffies-rounding-code-networking
+++ a/net/sched/sch_generic.c
@@ -209,7 +209,7 @@ static void dev_watchdog(unsigned long a
 				       dev->name);
 				dev->tx_timeout(dev);
 			}
-			if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
+			if (!mod_timer(&dev->watchdog_timer, round_jiffies(jiffies + dev->watchdog_timeo)))
 				dev_hold(dev);
 		}
 	}
_
