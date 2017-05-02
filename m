From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net] net: ipv6: Do not duplicate DAD on link up
Date: Tue,  2 May 2017 14:43:44 -0700
Message-ID: <1493761424-17407-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, dvyukov@google.com, andreyknvl@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35270 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751074AbdEBVnw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 17:43:52 -0400
Received: by mail-pg0-f68.google.com with SMTP id i63so5179450pgd.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 14:43:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey reported a warning triggered by the rcu code:

------------[ cut here ]------------
WARNING: CPU: 1 PID: 5911 at lib/debugobjects.c:289
debug_print_object+0x175/0x210
ODEBUG: activate active (active state 1) object type: rcu_head hint:
        (null)
Modules linked in:
CPU: 1 PID: 5911 Comm: a.out Not tainted 4.11.0-rc8+ #271
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x192/0x22d lib/dump_stack.c:52
 __warn+0x19f/0x1e0 kernel/panic.c:549
 warn_slowpath_fmt+0xe0/0x120 kernel/panic.c:564
 debug_print_object+0x175/0x210 lib/debugobjects.c:286
 debug_object_activate+0x574/0x7e0 lib/debugobjects.c:442
 debug_rcu_head_queue kernel/rcu/rcu.h:75
 __call_rcu.constprop.76+0xff/0x9c0 kernel/rcu/tree.c:3229
 call_rcu_sched+0x12/0x20 kernel/rcu/tree.c:3288
 rt6_rcu_free net/ipv6/ip6_fib.c:158
 rt6_release+0x1ea/0x290 net/ipv6/ip6_fib.c:188
 fib6_del_route net/ipv6/ip6_fib.c:1461
 fib6_del+0xa42/0xdc0 net/ipv6/ip6_fib.c:1500
 __ip6_del_rt+0x100/0x160 net/ipv6/route.c:2174
 ip6_del_rt+0x140/0x1b0 net/ipv6/route.c:2187
 __ipv6_ifa_notify+0x269/0x780 net/ipv6/addrconf.c:5520
 addrconf_ifdown+0xe60/0x1a20 net/ipv6/addrconf.c:3672
...

Andrey's reproducer program runs in a very tight loop, calling
'unshare -n' and then spawning 2 sets of 14 threads running random ioctl
calls. The relevant networking sequence:

1. New network namespace created via unshare -n
- ip6tnl0 device is created in down state

2. address added to ip6tnl0
- equivalent to ip -6 addr add dev ip6tnl0 fd00::bb/1
- DAD is started on the address and when it completes the host
  route is inserted into the FIB

3. ip6tnl0 is brought up
- the new fixup_permanent_addr function restarts DAD on the address

4. exit namespace
- teardown / cleanup sequence starts
- once in a blue moon, lo teardown appears to happen BEFORE teardown
  of ip6tunl0
  + down on 'lo' removes the host route from the FIB since the dst->dev
    for the route is loobback
  + host route added to rcu callback list
    * rcu callback has not run yet, so rt is NOT on the gc list so it has
      NOT been marked obsolete

5. in parallel to 4. worker_thread runs addrconf_dad_completed
- DAD on the address on ip6tnl0 completes
- calls ipv6_ifa_notify which inserts the host route

All of that happens very quickly. The result is that a host route that
has been deleted from the IPv6 FIB and added to the RCU list is re-inserted
into the FIB.

The exit namespace eventually gets to cleaning up ip6tnl0 which removes the
host route from the FIB again, calls the rcu function for cleanup -- and
triggers the double rcu trace.

The root cause is duplicate DAD on the address -- steps 2 and 3. Arguably,
DAD should not be started in step 2. The interface is in the down state,
so it can not really send out requests for the address which makes starting
DAD pointless.

Since the second DAD was introduced by a recent change, seems appropriate
to use it for the Fixes tag and have the fixup function only start DAD for
addresses in the PREDAD state which occurs in addrconf_ifdown if the
address is retained.

Big thanks to Andrey for isolating a reliable reproducer for this problem.
Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv6/addrconf.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 67ec87ea5fb6..4fc4e8634e65 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3306,7 +3306,8 @@ static int fixup_permanent_addr(struct inet6_dev *idev,
 				      idev->dev, 0, 0);
 	}
 
-	addrconf_dad_start(ifp);
+	if (ifp->state == INET6_IFADDR_STATE_PREDAD)
+		addrconf_dad_start(ifp);
 
 	return 0;
 }
@@ -3656,7 +3657,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		    !addr_is_local(&ifa->addr)) {
 			/* set state to skip the notifier below */
 			state = INET6_IFADDR_STATE_DEAD;
-			ifa->state = 0;
+			ifa->state = INET6_IFADDR_STATE_PREDAD;
 			if (!(ifa->flags & IFA_F_NODAD))
 				ifa->flags |= IFA_F_TENTATIVE;
 
-- 
2.1.4
