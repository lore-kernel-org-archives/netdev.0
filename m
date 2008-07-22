From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/5] netns: dont alloc ipv6 fib timer list
Date: Tue, 22 Jul 2008 14:29:28 -0700
Message-ID: <20080722212951.551812845@vyatta.com>
References: <20080722212927.937523165@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34391 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755261AbYGVVbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 17:31:05 -0400
Content-Disposition: inline; filename=ipv6-timer-alloc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FIB timer list is a trivial size structure, avoid indirection and just
put it in existing ns.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 patch against current net-2.6 tree

--- a/net/ipv6/ip6_fib.c	2008-07-22 09:21:36.000000000 -0700
+++ b/net/ipv6/ip6_fib.c	2008-07-22 13:48:21.000000000 -0700
@@ -661,16 +661,16 @@ static int fib6_add_rt2node(struct fib6_
 
 static __inline__ void fib6_start_gc(struct net *net, struct rt6_info *rt)
 {
-	if (!timer_pending(net->ipv6.ip6_fib_timer) &&
+	if (!timer_pending(&net->ipv6.ip6_fib_timer) &&
 	    (rt->rt6i_flags & (RTF_EXPIRES|RTF_CACHE)))
-		mod_timer(net->ipv6.ip6_fib_timer,
+		mod_timer(&net->ipv6.ip6_fib_timer,
 			  jiffies + net->ipv6.sysctl.ip6_rt_gc_interval);
 }
 
 void fib6_force_start_gc(struct net *net)
 {
-	if (!timer_pending(net->ipv6.ip6_fib_timer))
-		mod_timer(net->ipv6.ip6_fib_timer,
+	if (!timer_pending(&net->ipv6.ip6_fib_timer))
+		mod_timer(&net->ipv6.ip6_fib_timer,
 			  jiffies + net->ipv6.sysctl.ip6_rt_gc_interval);
 }
 
@@ -1449,7 +1449,7 @@ void fib6_run_gc(unsigned long expires, 
 	} else {
 		local_bh_disable();
 		if (!spin_trylock(&fib6_gc_lock)) {
-			mod_timer(net->ipv6.ip6_fib_timer, jiffies + HZ);
+			mod_timer(&net->ipv6.ip6_fib_timer, jiffies + HZ);
 			local_bh_enable();
 			return;
 		}
@@ -1462,12 +1462,10 @@ void fib6_run_gc(unsigned long expires, 
 	fib6_clean_all(net, fib6_age, 0, NULL);
 
 	if (gc_args.more)
-		mod_timer(net->ipv6.ip6_fib_timer, jiffies +
+		mod_timer(&net->ipv6.ip6_fib_timer, jiffies +
 			  net->ipv6.sysctl.ip6_rt_gc_interval);
-	else {
-		del_timer(net->ipv6.ip6_fib_timer);
-		net->ipv6.ip6_fib_timer->expires = 0;
-	}
+	else
+		del_timer(&net->ipv6.ip6_fib_timer);
 	spin_unlock_bh(&fib6_gc_lock);
 }
 
@@ -1478,16 +1476,7 @@ static void fib6_gc_timer_cb(unsigned lo
 
 static int fib6_net_init(struct net *net)
 {
-	int ret;
-	struct timer_list *timer;
-
-	ret = -ENOMEM;
-	timer = kzalloc(sizeof(*timer), GFP_KERNEL);
-	if (!timer)
-		goto out;
-
-	setup_timer(timer, fib6_gc_timer_cb, (unsigned long)net);
-	net->ipv6.ip6_fib_timer = timer;
+	setup_timer(&net->ipv6.ip6_fib_timer, fib6_gc_timer_cb, (unsigned long)net);
 
 	net->ipv6.rt6_stats = kzalloc(sizeof(*net->ipv6.rt6_stats), GFP_KERNEL);
 	if (!net->ipv6.rt6_stats)
@@ -1521,9 +1510,7 @@ static int fib6_net_init(struct net *net
 #endif
 	fib6_tables_init(net);
 
-	ret = 0;
-out:
-	return ret;
+	return 0;
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 out_fib6_main_tbl:
@@ -1534,15 +1521,14 @@ out_fib_table_hash:
 out_rt6_stats:
 	kfree(net->ipv6.rt6_stats);
 out_timer:
-	kfree(timer);
-	goto out;
+	return -ENOMEM;
  }
 
 static void fib6_net_exit(struct net *net)
 {
 	rt6_ifdown(net, NULL);
-	del_timer_sync(net->ipv6.ip6_fib_timer);
-	kfree(net->ipv6.ip6_fib_timer);
+	del_timer_sync(&net->ipv6.ip6_fib_timer);
+
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	kfree(net->ipv6.fib6_local_tbl);
 #endif
--- a/include/net/netns/ipv6.h	2008-07-22 09:21:35.000000000 -0700
+++ b/include/net/netns/ipv6.h	2008-07-22 13:46:51.000000000 -0700
@@ -39,7 +39,7 @@ struct netns_ipv6 {
 #endif
 	struct rt6_info         *ip6_null_entry;
 	struct rt6_statistics   *rt6_stats;
-	struct timer_list       *ip6_fib_timer;
+	struct timer_list       ip6_fib_timer;
 	struct hlist_head       *fib_table_hash;
 	struct fib6_table       *fib6_main_tbl;
 	struct dst_ops		*ip6_dst_ops;

-- 

