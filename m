From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: ipv6: ignore null_entry on route dumps
Date: Thu, 26 Jan 2017 13:54:08 -0800
Message-ID: <1485467648-27922-1-git-send-email-dsa@cumulusnetworks.com>
Cc: xiaolong.ye@intel.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36162 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753754AbdAZVyP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 16:54:15 -0500
Received: by mail-pf0-f174.google.com with SMTP id 189so68164281pfu.3
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 13:54:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lkp-robot reported a BUG:
[   10.151226] BUG: unable to handle kernel NULL pointer dereference at 00000198
[   10.152525] IP: rt6_fill_node+0x164/0x4b8
[   10.153307] *pdpt = 0000000012ee5001 *pde = 0000000000000000
[   10.153309]
[   10.154492] Oops: 0000 [#1]
[   10.154987] CPU: 0 PID: 909 Comm: netifd Not tainted 4.10.0-rc4-00722-g41e8c70ee162-dirty #10
[   10.156482] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   10.158254] task: d0deb000 task.stack: d0e0c000
[   10.159059] EIP: rt6_fill_node+0x164/0x4b8
[   10.159780] EFLAGS: 00010296 CPU: 0
[   10.160404] EAX: 00000000 EBX: d10c2358 ECX: c1f7c6cc EDX: c1f6ff44
[   10.161469] ESI: 00000000 EDI: c2059900 EBP: d0e0dc4c ESP: d0e0dbe4
[   10.162534]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[   10.163482] CR0: 80050033 CR2: 00000198 CR3: 10d94660 CR4: 000006b0
[   10.164535] Call Trace:
[   10.164993]  ? paravirt_sched_clock+0x9/0xd
[   10.165727]  ? sched_clock+0x9/0xc
[   10.166329]  ? sched_clock_cpu+0x19/0xe9
[   10.166991]  ? lock_release+0x13e/0x36c
[   10.167652]  rt6_dump_route+0x4c/0x56
[   10.168276]  fib6_dump_node+0x1d/0x3d
[   10.168913]  fib6_walk_continue+0xab/0x167
[   10.169611]  fib6_walk+0x2a/0x40
[   10.170182]  inet6_dump_fib+0xfb/0x1e0
[   10.170855]  netlink_dump+0xcd/0x21f

This happens when the loopback device is set down and a ipv6 fib route
dump is requested.

ip6_null_entry is the root of all ipv6 fib tables making it integrated
into the table and hence passed to the ipv6 route dump code. The
null_entry route uses the loopback device for dst.dev but may not have
rt6i_idev set because of the order in which initializations are done --
ip6_route_net_init is run before addrconf_init has initialized the
loopback device. Fixing the initialization order is a much bigger problem
with no obvious solution thus far.

The BUG is triggered when the loopback is set down and the netif_running
check added by a1a22c1206 fails. The fill_node descends to checking
rt->rt6i_idev for ignore_routes_with_linkdown and since rt6i_idev is
NULL it faults.

The null_entry route should not be processed in a dump request. Catch
and ignore. This check is done in rt6_dump_route as it is the highest
place in the callchain with knowledge of both the route and the network
namespace.

Fixes: a1a22c1206("net: ipv6: Keep nexthop of multipath route on admin down")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- updated commit message; no code change

Dave: per last email you suggested putting this in fib6_dump_node, but
      fib6_dump_node does not have knowledge of the network namespace
      because of the way the fib_walker works. I could put
      struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) w->args;
      into fib6_dump_node to get the net pointer from it but did not
      want to duplicate the typecast.

 net/ipv6/route.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4b1f0f98a0e9..47499ed429da 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3320,6 +3320,10 @@ static int rt6_fill_node(struct net *net,
 int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 {
 	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
+	struct net *net = arg->net;
+
+	if (rt == net->ipv6.ip6_null_entry)
+		return 0;
 
 	if (nlmsg_len(arg->cb->nlh) >= sizeof(struct rtmsg)) {
 		struct rtmsg *rtm = nlmsg_data(arg->cb->nlh);
@@ -3332,7 +3336,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 		}
 	}
 
-	return rt6_fill_node(arg->net,
+	return rt6_fill_node(net,
 		     arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).portid, arg->cb->nlh->nlmsg_seq,
 		     NLM_F_MULTI);
-- 
2.1.4
