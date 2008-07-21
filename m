From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/6] ipv6: use timer pending
Date: Mon, 21 Jul 2008 12:28:35 -0700
Message-ID: <20080721192919.971385103@vyatta.com>
References: <20080721192834.221648982@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:38855 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754612AbYGUTbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 15:31:04 -0400
Content-Disposition: inline; filename=ipv6-timer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the bridge reference count problem and cleanups ipv6 FIB timer management.
Don't use expires field, because it is not a proper way to test,
instead use timer_pending().

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv6/ip6_fib.c	2008-07-21 11:25:23.000000000 -0700
+++ b/net/ipv6/ip6_fib.c	2008-07-21 11:42:30.000000000 -0700
@@ -661,17 +661,17 @@ static int fib6_add_rt2node(struct fib6_
 
 static __inline__ void fib6_start_gc(struct net *net, struct rt6_info *rt)
 {
-	if (net->ipv6.ip6_fib_timer->expires == 0 &&
+	if (!timer_pending(net->ipv6.ip6_fib_timer) &&
 	    (rt->rt6i_flags & (RTF_EXPIRES|RTF_CACHE)))
-		mod_timer(net->ipv6.ip6_fib_timer, jiffies +
-			  net->ipv6.sysctl.ip6_rt_gc_interval);
+		mod_timer(net->ipv6.ip6_fib_timer,
+			  jiffies + net->ipv6.sysctl.ip6_rt_gc_interval);
 }
 
 void fib6_force_start_gc(struct net *net)
 {
-	if (net->ipv6.ip6_fib_timer->expires == 0)
-		mod_timer(net->ipv6.ip6_fib_timer, jiffies +
-			  net->ipv6.sysctl.ip6_rt_gc_interval);
+	if (!timer_pending(net->ipv6.ip6_fib_timer))
+		mod_timer(net->ipv6.ip6_fib_timer,
+			  jiffies + net->ipv6.sysctl.ip6_rt_gc_interval);
 }
 
 /*

-- 

