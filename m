From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net: use for_each_netdev_safe() in rtnl_group_changelink()
Date: Mon, 23 Mar 2015 16:31:09 -0700
Message-ID: <1427153469-32542-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34318 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbCWXbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 19:31:25 -0400
Received: by pdbni2 with SMTP id ni2so202188557pdb.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 16:31:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we move the whole dev group to another netns,
we should call for_each_netdev_safe(), otherwise we get
a soft lockup:

 NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [ip:798]
 irq event stamp: 255424
 hardirqs last  enabled at (255423): [<ffffffff81a2aa95>] restore_args+0x0/0x30
 hardirqs last disabled at (255424): [<ffffffff81a2ad5a>] apic_timer_interrupt+0x6a/0x80
 softirqs last  enabled at (255422): [<ffffffff81079ebc>] __do_softirq+0x2c1/0x3a9
 softirqs last disabled at (255417): [<ffffffff8107a190>] irq_exit+0x41/0x95
 CPU: 0 PID: 798 Comm: ip Not tainted 4.0.0-rc4+ #881
 Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 task: ffff8800d1b88000 ti: ffff880119530000 task.ti: ffff880119530000
 RIP: 0010:[<ffffffff810cad11>]  [<ffffffff810cad11>] debug_lockdep_rcu_enabled+0x28/0x30
 RSP: 0018:ffff880119533778  EFLAGS: 00000246
 RAX: ffff8800d1b88000 RBX: 0000000000000002 RCX: 0000000000000038
 RDX: 0000000000000000 RSI: ffff8800d1b888c8 RDI: ffff8800d1b888c8
 RBP: ffff880119533778 R08: 0000000000000000 R09: 0000000000000000
 R10: 0000000000000000 R11: 000000000000b5c2 R12: 0000000000000246
 R13: ffff880119533708 R14: 00000000001d5a40 R15: ffff88011a7d5a40
 FS:  00007fc01315f740(0000) GS:ffff88011a600000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 CR2: 00007f367a120988 CR3: 000000011849c000 CR4: 00000000000007f0
 Stack:
  ffff880119533798 ffffffff811ac868 ffffffff811ac831 ffffffff811ac828
  ffff8801195337c8 ffffffff811ac8c9 ffff8801195339b0 ffff8801197633e0
  0000000000000000 ffff8801195339b0 ffff8801195337d8 ffffffff811ad2d7
 Call Trace:
  [<ffffffff811ac868>] rcu_read_lock+0x37/0x6e
  [<ffffffff811ac831>] ? rcu_read_unlock+0x5f/0x5f
  [<ffffffff811ac828>] ? rcu_read_unlock+0x56/0x5f
  [<ffffffff811ac8c9>] __fget+0x2a/0x7a
  [<ffffffff811ad2d7>] fget+0x13/0x15
  [<ffffffff811be732>] proc_ns_fget+0xe/0x38
  [<ffffffff817c7714>] get_net_ns_by_fd+0x11/0x59
  [<ffffffff817df359>] rtnl_link_get_net+0x33/0x3e
  [<ffffffff817df3d7>] do_setlink+0x73/0x87b
  [<ffffffff810b28ce>] ? trace_hardirqs_off+0xd/0xf
  [<ffffffff81a2aa95>] ? retint_restore_args+0xe/0xe
  [<ffffffff817e0301>] rtnl_newlink+0x40c/0x699
  [<ffffffff817dffe0>] ? rtnl_newlink+0xeb/0x699
  [<ffffffff81a29246>] ? _raw_spin_unlock+0x28/0x33
  [<ffffffff8143ed1e>] ? security_capable+0x18/0x1a
  [<ffffffff8107da51>] ? ns_capable+0x4d/0x65
  [<ffffffff817de5ce>] rtnetlink_rcv_msg+0x181/0x194
  [<ffffffff817de407>] ? rtnl_lock+0x17/0x19
  [<ffffffff817de407>] ? rtnl_lock+0x17/0x19
  [<ffffffff817de44d>] ? __rtnl_unlock+0x17/0x17
  [<ffffffff818327c6>] netlink_rcv_skb+0x4d/0x93
  [<ffffffff817de42f>] rtnetlink_rcv+0x26/0x2d
  [<ffffffff81830f18>] netlink_unicast+0xcb/0x150
  [<ffffffff8183198e>] netlink_sendmsg+0x501/0x523
  [<ffffffff8115cba9>] ? might_fault+0x59/0xa9
  [<ffffffff817b5398>] ? copy_from_user+0x2a/0x2c
  [<ffffffff817b7b74>] sock_sendmsg+0x34/0x3c
  [<ffffffff817b7f6d>] ___sys_sendmsg+0x1b8/0x255
  [<ffffffff8115c5eb>] ? handle_pte_fault+0xbd5/0xd4a
  [<ffffffff8100a2b0>] ? native_sched_clock+0x35/0x37
  [<ffffffff8109e94b>] ? sched_clock_local+0x12/0x72
  [<ffffffff8109eb9c>] ? sched_clock_cpu+0x9e/0xb7
  [<ffffffff810cadbf>] ? rcu_read_lock_held+0x3b/0x3d
  [<ffffffff811ac1d8>] ? __fcheck_files+0x4c/0x58
  [<ffffffff811ac946>] ? __fget_light+0x2d/0x52
  [<ffffffff817b8adc>] __sys_sendmsg+0x42/0x60
  [<ffffffff817b8b0c>] SyS_sendmsg+0x12/0x1c
  [<ffffffff81a29e32>] system_call_fastpath+0x12/0x17

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/rtnetlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ee0608b..7ebed55 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1932,10 +1932,10 @@ static int rtnl_group_changelink(const struct sk_buff *skb,
 		struct ifinfomsg *ifm,
 		struct nlattr **tb)
 {
-	struct net_device *dev;
+	struct net_device *dev, *aux;
 	int err;
 
-	for_each_netdev(net, dev) {
+	for_each_netdev_safe(net, dev, aux) {
 		if (dev->group == group) {
 			err = do_setlink(skb, dev, ifm, tb, NULL, 0);
 			if (err < 0)
-- 
1.8.3.1
