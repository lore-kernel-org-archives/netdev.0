From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv6: Delete host routes on an ifdown
Date: Thu, 21 Apr 2016 20:56:12 -0700
Message-ID: <1461297372-18796-1-git-send-email-dsa@cumulusnetworks.com>
Cc: mmanning@brocade.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33363 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbcDVD4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 23:56:34 -0400
Received: by mail-pf0-f175.google.com with SMTP id 184so37045911pff.0
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 20:56:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was a simple idea -- save IPv6 configured addresses on a link down
so that IPv6 behaves similar to IPv4. As always the devil is in the
details and the IPv6 stack as too many behavioral differences from IPv4
making the simple idea more complicated than it needs to be.

The current implementation for keeping IPv6 addresses can panic or spit
out a warning in one of many paths:

1. IPv6 route gets an IPv4 route as its 'next' which causes a panic in
   rt6_fill_node while handling a route dump request.

2. rt->dst.obsolete is set to DST_OBSOLETE_DEAD hitting the WARN_ON in
   fib6_del

3. Panic in fib6_purge_rt because rt6i_ref count is not 1.

The root cause of all these is references related to the host route for
an address that is retained.

So, this patch deletes the host route every time the ifdown loop runs.
Since the host route is deleted and will be re-generated an up there is
no longer a need for the l3mdev fix up. On the 'admin up' side move
addrconf_permanent_addr into the NETDEV_UP event handling so that it
runs only once versus on UP and CHANGE events.

All of the current panics and warnings appear to be related to
addresses on the loopback device, but given the catastrophic nature when
a bug is triggered this patch takes the conservative approach and evicts
all host routes rather than trying to determine when it can be re-used
and when it can not. That can be a later optimizaton if desired.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
Dave: I realize this goes against your preference to keep routes cached
      on a down but this patch really emphasizes my point of all the
      dark corners to be handled. 

 net/ipv6/addrconf.c | 48 +++++++++++++++---------------------------------
 1 file changed, 15 insertions(+), 33 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 23cec53b568a..8ec4b3089e20 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3176,35 +3176,9 @@ static void addrconf_gre_config(struct net_device *dev)
 }
 #endif
 
-#if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
-/* If the host route is cached on the addr struct make sure it is associated
- * with the proper table. e.g., enslavement can change and if so the cached
- * host route needs to move to the new table.
- */
-static void l3mdev_check_host_rt(struct inet6_dev *idev,
-				  struct inet6_ifaddr *ifp)
-{
-	if (ifp->rt) {
-		u32 tb_id = l3mdev_fib_table(idev->dev) ? : RT6_TABLE_LOCAL;
-
-		if (tb_id != ifp->rt->rt6i_table->tb6_id) {
-			ip6_del_rt(ifp->rt);
-			ifp->rt = NULL;
-		}
-	}
-}
-#else
-static void l3mdev_check_host_rt(struct inet6_dev *idev,
-				  struct inet6_ifaddr *ifp)
-{
-}
-#endif
-
 static int fixup_permanent_addr(struct inet6_dev *idev,
 				struct inet6_ifaddr *ifp)
 {
-	l3mdev_check_host_rt(idev, ifp);
-
 	if (!ifp->rt) {
 		struct rt6_info *rt;
 
@@ -3304,6 +3278,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			break;
 
 		if (event == NETDEV_UP) {
+			/* restore routes for permanent addresses */
+			addrconf_permanent_addr(dev);
+
 			if (!addrconf_qdisc_ok(dev)) {
 				/* device is not ready yet. */
 				pr_info("ADDRCONF(NETDEV_UP): %s: link is not ready\n",
@@ -3337,9 +3314,6 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			run_pending = 1;
 		}
 
-		/* restore routes for permanent addresses */
-		addrconf_permanent_addr(dev);
-
 		switch (dev->type) {
 #if IS_ENABLED(CONFIG_IPV6_SIT)
 		case ARPHRD_SIT:
@@ -3556,6 +3530,8 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 	INIT_LIST_HEAD(&del_list);
 	list_for_each_entry_safe(ifa, tmp, &idev->addr_list, if_list) {
+		struct rt6_info *rt = NULL;
+
 		addrconf_del_dad_work(ifa);
 
 		write_unlock_bh(&idev->lock);
@@ -3568,6 +3544,9 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 			ifa->state = 0;
 			if (!(ifa->flags & IFA_F_NODAD))
 				ifa->flags |= IFA_F_TENTATIVE;
+
+			rt = ifa->rt;
+			ifa->rt = NULL;
 		} else {
 			state = ifa->state;
 			ifa->state = INET6_IFADDR_STATE_DEAD;
@@ -3578,6 +3557,9 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 		spin_unlock_bh(&ifa->lock);
 
+		if (rt)
+			ip6_del_rt(rt);
+
 		if (state != INET6_IFADDR_STATE_DEAD) {
 			__ipv6_ifa_notify(RTM_DELADDR, ifa);
 			inet6addr_notifier_call_chain(NETDEV_DOWN, ifa);
@@ -5343,10 +5325,10 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 			if (rt)
 				ip6_del_rt(rt);
 		}
-		dst_hold(&ifp->rt->dst);
-
-		ip6_del_rt(ifp->rt);
-
+		if (ifp->rt) {
+			dst_hold(&ifp->rt->dst);
+			ip6_del_rt(ifp->rt);
+		}
 		rt_genid_bump_ipv6(net);
 		break;
 	}
-- 
2.1.4
