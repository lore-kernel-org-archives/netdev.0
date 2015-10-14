From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Fix suspicious RCU usage in fib_rebalance
Date: Wed, 14 Oct 2015 16:44:00 -0700
Message-ID: <1444866240-31778-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pch@ordbogen.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32888 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbbJNXoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 19:44:08 -0400
Received: by pabrc13 with SMTP id rc13so67833420pab.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 16:44:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This command:
  ip route add 192.168.1.0/24 nexthop via 10.2.1.5 dev eth1 nexthop via=
 10.2.2.5 dev eth2

generated this suspicious RCU usage message:

[ 63.249262]
[ 63.249939] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ 63.251571] [ INFO: suspicious RCU usage. ]
[ 63.253250] 4.3.0-rc3+ #298 Not tainted
[ 63.254724] -------------------------------
[ 63.256401] ../include/linux/inetdevice.h:205 suspicious rcu_dereferen=
ce_check() usage!
[ 63.259450]
[ 63.259450] other info that might help us debug this:
[ 63.259450]
[ 63.262297]
[ 63.262297] rcu_scheduler_active =3D 1, debug_locks =3D 1
[ 63.264647] 1 lock held by ip/2870:
[ 63.265896] #0: (rtnl_mutex){+.+.+.}, at: [<ffffffff813ebfb7>] rtnl_lo=
ck+0x12/0x14
[ 63.268858]
[ 63.268858] stack backtrace:
[ 63.270409] CPU: 4 PID: 2870 Comm: ip Not tainted 4.3.0-rc3+ #298
[ 63.272478] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S 1.7.5-20140531_083030-gandalf 04/01/2014
[ 63.275745] 0000000000000001 ffff8800b8c9f8b8 ffffffff8125f73c ffff880=
13afcf301
[ 63.278185] ffff8800bab7a380 ffff8800b8c9f8e8 ffffffff8107bf30 ffff880=
0bb728000
[ 63.280634] ffff880139fe9a60 0000000000000000 ffff880139fe9a00 ffff880=
0b8c9f908
[ 63.283177] Call Trace:
[ 63.283959] [<ffffffff8125f73c>] dump_stack+0x4c/0x68
[ 63.285593] [<ffffffff8107bf30>] lockdep_rcu_suspicious+0xfa/0x103
[ 63.287500] [<ffffffff8144d752>] __in_dev_get_rcu+0x48/0x4f
[ 63.289169] [<ffffffff8144d797>] fib_rebalance+0x3e/0x127
[ 63.290753] [<ffffffff8144d986>] ? rcu_read_unlock+0x3e/0x5f
[ 63.292442] [<ffffffff8144ea45>] fib_create_info+0xaf9/0xdcc
[ 63.294093] [<ffffffff8106c12f>] ? sched_clock_local+0x12/0x75
[ 63.295791] [<ffffffff8145236a>] fib_table_insert+0x8c/0x451
[ 63.297493] [<ffffffff8144bf9c>] ? fib_get_table+0x36/0x43
[ 63.299109] [<ffffffff8144c3ca>] inet_rtm_newroute+0x43/0x51
[ 63.300709] [<ffffffff813ef684>] rtnetlink_rcv_msg+0x182/0x195
[ 63.302334] [<ffffffff8107d04c>] ? trace_hardirqs_on+0xd/0xf
[ 63.303888] [<ffffffff813ebfb7>] ? rtnl_lock+0x12/0x14
[ 63.305346] [<ffffffff813ef502>] ? __rtnl_unlock+0x12/0x12
[ 63.306878] [<ffffffff81407c4c>] netlink_rcv_skb+0x3d/0x90
[ 63.308437] [<ffffffff813ec00e>] rtnetlink_rcv+0x21/0x28
[ 63.309916] [<ffffffff81407742>] netlink_unicast+0xfa/0x17f
[ 63.311447] [<ffffffff81407a5e>] netlink_sendmsg+0x297/0x2dc
[ 63.313029] [<ffffffff813c6cd4>] sock_sendmsg_nosec+0x12/0x1d
[ 63.314597] [<ffffffff813c835b>] ___sys_sendmsg+0x196/0x21b
[ 63.316125] [<ffffffff8100bf9f>] ? native_sched_clock+0x1f/0x3c
[ 63.317671] [<ffffffff8106c12f>] ? sched_clock_local+0x12/0x75
[ 63.319185] [<ffffffff8106c397>] ? sched_clock_cpu+0x9d/0xb6
[ 63.320693] [<ffffffff8107e2d7>] ? __lock_is_held+0x32/0x54
[ 63.322145] [<ffffffff81159fcb>] ? __fget_light+0x4b/0x77
[ 63.323541] [<ffffffff813c8726>] __sys_sendmsg+0x3d/0x5b
[ 63.324947] [<ffffffff813c8751>] SyS_sendmsg+0xd/0x19
[ 63.326274] [<ffffffff814c8f57>] entry_SYSCALL_64_fastpath+0x12/0x6f

It looks like all of the code paths to fib_rebalance are under rtnl.

=46ixes: 0e884c78ee19 ("ipv4: L3 hash-based multipath")
Cc: Peter N=C3=B8rlund <pch@ordbogen.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_semantics.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index af77298c8b4f..42778d9d71e5 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -545,7 +545,7 @@ static void fib_rebalance(struct fib_info *fi)
 		if (nh->nh_flags & RTNH_F_DEAD)
 			continue;
=20
-		in_dev =3D __in_dev_get_rcu(nh->nh_dev);
+		in_dev =3D __in_dev_get_rtnl(nh->nh_dev);
=20
 		if (in_dev &&
 		    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
@@ -559,7 +559,7 @@ static void fib_rebalance(struct fib_info *fi)
 	change_nexthops(fi) {
 		int upper_bound;
=20
-		in_dev =3D __in_dev_get_rcu(nexthop_nh->nh_dev);
+		in_dev =3D __in_dev_get_rtnl(nexthop_nh->nh_dev);
=20
 		if (nexthop_nh->nh_flags & RTNH_F_DEAD) {
 			upper_bound =3D -1;
--=20
1.9.1
