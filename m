From: wang.bo116@zte.com.cn
Subject: [PATCH net] net/sched: Fix use of wild pointer in mq_destroy() when
 qdisc_alloc fail
Date: Fri, 24 Oct 2014 16:34:53 +0800
Message-ID: <OF7A403C69.2C35464E-ON48257D7B.002E24AA-48257D7B.002F2A62@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, cui.yunfeng@zte.com.cn
To: davem@davemloft.net, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx7.zte.com.cn ([202.103.147.169]:60453 "EHLO zte.com.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750964AbaJXIvK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 04:51:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello:
	In mq_destroy() we should set pointer priv->qdiscs to null after free it.
	When attach_default_qdiscs -> qdisc_create_dflt -> mq_init -> qdisc_create_dflt fail -> qdisc_alloc fail,
mq_destroy() will called twice, the first time called in mq_init, and the second time called by qdisc_destroy -> mq_destroy,
if priv->qdiscs not set null after free, the second time to go into mq_destroy() will use wild pointer, becasuse if(!priv->qdiscs) not work.

The problem happend in my machine when ifconfig alloc memory failed:

ifconfig: page allocation failure. order:0, mode:0xd0, oom_adj:0
[<c0211a00>] (unwind_backtrace+0x0/0xd4) from [<c060dc14>] (dump_stack+0x18/0x1c)
[<c060dc14>] (dump_stack+0x18/0x1c) from [<c02a64f0>] (__alloc_pages_nodemask+0x910/0x9dc)
[<c02a64f0>] (__alloc_pages_nodemask+0x910/0x9dc) from [<c02cf0b4>] (cache_alloc_refill+0x364/0x788)
[<c02cf0b4>] (cache_alloc_refill+0x364/0x788) from [<c02cf7f4>] (__kmalloc+0x134/0x1e8)
[<c02cf7f4>] (__kmalloc+0x134/0x1e8) from [<c054b540>] (qdisc_alloc+0x24/0xbc)
[<c054b540>] (qdisc_alloc+0x24/0xbc) from [<c054b5f8>] (qdisc_create_dflt+0x20/0x60)
[<c054b5f8>] (qdisc_create_dflt+0x20/0x60) from [<c054c008>] (mq_init+0x8c/0xf4)
[<c054c008>] (mq_init+0x8c/0xf4) from [<c054b61c>] (qdisc_create_dflt+0x44/0x60)
[<c054b61c>] (qdisc_create_dflt+0x44/0x60) from [<c054b7b4>] (dev_activate+0xac/0x150)
[<c054b7b4>] (dev_activate+0xac/0x150) from [<c053a298>] (dev_open+0xf0/0x120)
[<c053a298>] (dev_open+0xf0/0x120) from [<c0539e08>] (dev_change_flags+0x94/0x164)
[<c0539e08>] (dev_change_flags+0x94/0x164) from [<c05804d8>] (devinet_ioctl+0x300/0x684)
[<c05804d8>] (devinet_ioctl+0x300/0x684) from [<c0581a4c>] (inet_ioctl+0xd0/0x104)
[<c0581a4c>] (inet_ioctl+0xd0/0x104) from [<c0526d0c>] (sock_ioctl+0x200/0x250)
[<c0526d0c>] (sock_ioctl+0x200/0x250) from [<c02e2010>] (vfs_ioctl+0x34/0xb4)
[<c02e2010>] (vfs_ioctl+0x34/0xb4) from [<c02e2b6c>] (do_vfs_ioctl+0x56c/0x5d8)
[<c02e2b6c>] (do_vfs_ioctl+0x56c/0x5d8) from [<c02e2c18>] (sys_ioctl+0x40/0x64)
[<c02e2c18>] (sys_ioctl+0x40/0x64) from [<c0209a60>] (ret_fast_syscall+0x0/0x38)

Unable to handle kernel paging request at virtual address 6b6b6b73
pgd = c1e70000
[6b6b6b73] *pgd=00000000
Internal error: Oops: 15 [#1] PREEMPT
last sysfs file:
Modules linked in:
CPU: 0    Tainted: G        W   (2.6.32.61-EMBSYS-CGEL-4.03.20.P3.F0.B5MAXCNF #2)
PC is at qdisc_destroy+0xc/0xb4
LR is at mq_destroy+0x34/0x60
pc : [<c054b084>]    lr : [<c054bf50>]    psr: 20000213
sp : c191bd80  ip : c191bd98  fp : c191bd94
r10: 00000000  r9 : c191be70  r8 : c1bff40c
r7 : c1c2e000  r6 : c1f3e140  r5 : 00000000  r4 : c1f3e0a0
r3 : f2266ea0  r2 : 00000000  r1 : c1f3e0cc  r0 : 6b6b6b6b
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 12c5387d  Table: 01e70019  DAC: 55555555
Process ifconfig (pid: 391, stack limit = 0xc191a2e8)
Stack: (0xc191bd80 to 0xc191c000)
[<c054b084>] (qdisc_destroy+0xc/0xb4) from [<c054bf50>] (mq_destroy+0x34/0x60)
[<c054bf50>] (mq_destroy+0x34/0x60) from [<c054b0ec>] (qdisc_destroy+0x74/0xb4)
[<c054b0ec>] (qdisc_destroy+0x74/0xb4) from [<c054b62c>] (qdisc_create_dflt+0x54/0x60)
[<c054b62c>] (qdisc_create_dflt+0x54/0x60) from [<c054b7b4>] (dev_activate+0xac/0x150)
[<c054b7b4>] (dev_activate+0xac/0x150) from [<c053a298>] (dev_open+0xf0/0x120)
[<c053a298>] (dev_open+0xf0/0x120) from [<c0539e08>] (dev_change_flags+0x94/0x164)
[<c0539e08>] (dev_change_flags+0x94/0x164) from [<c05804d8>] (devinet_ioctl+0x300/0x684)
[<c05804d8>] (devinet_ioctl+0x300/0x684) from [<c0581a4c>] (inet_ioctl+0xd0/0x104)
[<c0581a4c>] (inet_ioctl+0xd0/0x104) from [<c0526d0c>] (sock_ioctl+0x200/0x250)
[<c0526d0c>] (sock_ioctl+0x200/0x250) from [<c02e2010>] (vfs_ioctl+0x34/0xb4)
[<c02e2010>] (vfs_ioctl+0x34/0xb4) from [<c02e2b6c>] (do_vfs_ioctl+0x56c/0x5d8)
[<c02e2b6c>] (do_vfs_ioctl+0x56c/0x5d8) from [<c02e2c18>] (sys_ioctl+0x40/0x64)
[<c02e2c18>] (sys_ioctl+0x40/0x64) from [<c0209a60>] (ret_fast_syscall+0x0/0x38)
Code: e89da8f0 e1a0c00d e92dd830 e24cb004 (e5903008)
---[ end trace 8e66b5118c0bea77 ]---
Kernel panic - not syncing: Fatal exception

--------------------------------------------------------------------------------

This patch  fix this problem, base on linux 3.18-rc-1:

Signed-off-by: Wang Bo <wang.bo116@zte.com.cn>
Tested-by: Ma Chenggong <ma.chenggong@zte.com.cn>
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 42f72f1..a0c90e7 100755
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -33,6 +33,7 @@ static void mq_destroy(struct Qdisc *sch)
 	for (ntx = 0; ntx < dev->num_tx_queues && priv->qdiscs[ntx]; ntx++)
 		qdisc_destroy(priv->qdiscs[ntx]);
 	kfree(priv->qdiscs);
+	priv->qdiscs = NULL;
 }

 static int mq_init(struct Qdisc *sch, struct nlattr *opt)
