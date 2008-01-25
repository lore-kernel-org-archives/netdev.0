From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 05/11][NETNS][IPV6] ip6_fib - dynamically allocate the gc_timer
Date: Fri, 25 Jan 2008 17:50:13 +0100
Message-ID: <20080125170811.983744160@localhost.localdomain>
References: <20080125165008.317745745@localhost.localdomain>
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:37024 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071AbYAYRLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 12:11:44 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0PHBWxB480212
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:32 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0PHBXIC5103792
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:33 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0PHBSq2031482
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:29 GMT
Content-Disposition: inline; filename=ip6-fib-dynamically-allocate-gc-timer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip6_fib_timer gc timer is dynamically allocated and initialized in
the ip6 fib init function. There are no more references to a
static global variable. That will allow to make multiple instance
of the garbage collecting timer and make them per namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/ip6_fib.c |   33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

Index: net-2.6.25/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.25.orig/net/ipv6/ip6_fib.c
+++ net-2.6.25/net/ipv6/ip6_fib.c
@@ -95,8 +95,7 @@ static __u32 rt_sernum;
 
 static void fib6_gc_timer_cb(unsigned long arg);
 
-static DEFINE_TIMER(ip6_fib_timer, fib6_gc_timer_cb, 0,
-		    (unsigned long)&init_net);
+static struct timer_list *ip6_fib_timer;
 
 static struct fib6_walker_t fib6_walker_list = {
 	.prev	= &fib6_walker_list,
@@ -666,16 +665,16 @@ static int fib6_add_rt2node(struct fib6_
 
 static __inline__ void fib6_start_gc(struct rt6_info *rt)
 {
-	if (ip6_fib_timer.expires == 0 &&
+	if (ip6_fib_timer->expires == 0 &&
 	    (rt->rt6i_flags & (RTF_EXPIRES|RTF_CACHE)))
-		mod_timer(&ip6_fib_timer, jiffies +
+		mod_timer(ip6_fib_timer, jiffies +
 			  init_net.ipv6.sysctl.ip6_rt_gc_interval);
 }
 
 void fib6_force_start_gc(void)
 {
-	if (ip6_fib_timer.expires == 0)
-		mod_timer(&ip6_fib_timer, jiffies +
+	if (ip6_fib_timer->expires == 0)
+		mod_timer(ip6_fib_timer, jiffies +
 			  init_net.ipv6.sysctl.ip6_rt_gc_interval);
 }
 
@@ -1444,7 +1443,7 @@ void fib6_run_gc(unsigned long expires, 
 	} else {
 		local_bh_disable();
 		if (!spin_trylock(&fib6_gc_lock)) {
-			mod_timer(&ip6_fib_timer, jiffies + HZ);
+			mod_timer(ip6_fib_timer, jiffies + HZ);
 			local_bh_enable();
 			return;
 		}
@@ -1457,11 +1456,11 @@ void fib6_run_gc(unsigned long expires, 
 	fib6_clean_all(net, fib6_age, 0, NULL);
 
 	if (gc_args.more)
-		mod_timer(&ip6_fib_timer, jiffies +
+		mod_timer(ip6_fib_timer, jiffies +
 			  net->ipv6.sysctl.ip6_rt_gc_interval);
 	else {
-		del_timer(&ip6_fib_timer);
-		ip6_fib_timer.expires = 0;
+		del_timer(ip6_fib_timer);
+		ip6_fib_timer->expires = 0;
 	}
 	spin_unlock_bh(&fib6_gc_lock);
 }
@@ -1541,9 +1540,16 @@ int __init fib6_init(void)
 	if (!fib6_node_kmem)
 		goto out;
 
+	ret = -ENOMEM;
+	ip6_fib_timer = kzalloc(sizeof(*ip6_fib_timer), GFP_KERNEL);
+	if (!ip6_fib_timer)
+		goto out_kmem_cache_create;
+
+	setup_timer(ip6_fib_timer, fib6_gc_timer_cb, (unsigned long)&init_net);
+
 	ret = register_pernet_subsys(&fib6_net_ops);
 	if (ret)
-		goto out_kmem_cache_create;
+		goto out_timer;
 
 	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
 	if (ret)
@@ -1553,6 +1559,8 @@ out:
 
 out_unregister_subsys:
 	unregister_pernet_subsys(&fib6_net_ops);
+out_timer:
+	kfree(ip6_fib_timer);
 out_kmem_cache_create:
 	kmem_cache_destroy(fib6_node_kmem);
 	goto out;
@@ -1560,7 +1568,8 @@ out_kmem_cache_create:
 
 void fib6_gc_cleanup(void)
 {
-	del_timer(&ip6_fib_timer);
+	del_timer(ip6_fib_timer);
+	kfree(ip6_fib_timer);
 	unregister_pernet_subsys(&fib6_net_ops);
 	kmem_cache_destroy(fib6_node_kmem);
 }

-- 
