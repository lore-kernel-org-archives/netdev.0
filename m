From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] ipv6: fix race between ipv6_del_addr and DAD timer
Date: Tue, 08 Jul 2008 12:55:24 +0400
Message-ID: <48732B7C.70802@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Andrey Vagin <avagin@parallels.com>
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57913 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbYGHI6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 04:58:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Vagin <avagin@parallels.com>

Consider the following scenario:

ipv6_del_addr(ifp)
  ipv6_ifa_notify(RTM_DELADDR, ifp)
    ip6_del_rt(ifp->rt)

after returning from the ipv6_ifa_notify and enabling BH-s
back, but *before* calling the addrconf_del_timer the 
ifp->timer fires and:

addrconf_dad_timer(ifp)
  addrconf_dad_completed(ifp)
    ipv6_ifa_notify(RTM_NEWADDR, ifp)
      ip6_ins_rt(ifp->rt)

then return back to the ipv6_del_addr and:

in6_ifa_put(ifp)
  inet6_ifa_finish_destroy(ifp)
    dst_release(&ifp->rt->u.dst)

After this we have an ifp->rt inserted into fib6 lists, but 
queued for gc, which in turn can result in oopses in the
fib6_run_gc. Maybe some other nasty things, but we caught 
only the oops in gc so far.

The solution is to disarm the ifp->timer before flushing the
rt from it.

Signed-off-by: Andrey Vagin <avagin@parallels.com>
Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 147588f..ff61a5c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -749,12 +749,12 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	}
 	write_unlock_bh(&idev->lock);
 
+	addrconf_del_timer(ifp);
+
 	ipv6_ifa_notify(RTM_DELADDR, ifp);
 
 	atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifp);
 
-	addrconf_del_timer(ifp);
-
 	/*
 	 * Purge or update corresponding prefix
 	 *
