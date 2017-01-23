From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv6: Check that idev is non-NULL in rt6_fill_node
Date: Sun, 22 Jan 2017 20:08:00 -0800
Message-ID: <1485144480-4460-1-git-send-email-dsa@cumulusnetworks.com>
Cc: xiaolong.ye@intel.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33929 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750712AbdAWEIG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 23:08:06 -0500
Received: by mail-pg0-f50.google.com with SMTP id 14so41066431pgg.1
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 20:08:06 -0800 (PST)
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

The ipv6 route dump code passes ip6_null_entry to rt6_fill_node. This
route uses the loopback device but does not have idev set. When the
loopback is set down, the netif_running check added by a1a22c1206 fails
and the fill_node descends to checking rt->rt6i_idev for
ignore_routes_with_linkdown. Since idev is null for the ip6_null_entry
route it triggers the BUG.

Fixes: a1a22c1206("net: ipv6: Keep nexthop of multipath route on admin down")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5585c501a540..9a7cc7558104 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3218,7 +3218,8 @@ static int rt6_fill_node(struct net *net,
 	rtm->rtm_flags = 0;
 	if (!netif_carrier_ok(rt->dst.dev)) {
 		rtm->rtm_flags |= RTNH_F_LINKDOWN;
-		if (rt->rt6i_idev->cnf.ignore_routes_with_linkdown)
+		if (rt->rt6i_idev &&
+		    rt->rt6i_idev->cnf.ignore_routes_with_linkdown)
 			rtm->rtm_flags |= RTNH_F_DEAD;
 	}
 	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
-- 
2.1.4
