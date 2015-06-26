From: Dave Jones <davej@codemonkey.org.uk>
Subject: 4.1+ use after free in netlink_broadcast_filtered
Date: Fri, 26 Jun 2015 00:44:50 -0400
Message-ID: <20150626044450.GA21864@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:48599 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbFZEo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 00:44:58 -0400
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1Z8LVS-0003vy-Go
	for netdev@vger.kernel.org; Fri, 26 Jun 2015 05:44:51 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I taught Trinity about NETLINK_LISTEN_ALL_NSID and NETLINK_LIST_MEMBERSHIPS
yesterday, and this evening, this fell out..

general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC 
CPU: 1 PID: 9130 Comm: kworker/1:1 Not tainted 4.1.0-gelk-debug+ #1
Workqueue: sock_diag_events sock_diag_broadcast_destroy_work
task: ffff8800b94e4c40 ti: ffff8800352ec000 task.ti: ffff8800352ec000
RIP: 0010:[<ffffffff845c82e4>]  [<ffffffff845c82e4>] netlink_broadcast_filtered+0x24/0x3b0
RSP: 0000:ffff8800352efd08  EFLAGS: 00010292
RAX: ffff8800ab903d80 RBX: 0000000000000003 RCX: 0000000000000003
RDX: 0000000000000000 RSI: 00000000000000d0 RDI: ffff8800b9c586c0
RBP: ffff8800352efd78 R08: 00000000000000d0 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000220 R12: 0000000000000000
R13: 6b6b6b6b6b6b6b6b R14: 0000000000000003 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8800bf700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000002121ff8 CR3: 0000000030169000 CR4: 00000000000007e0
DR0: 00007fe1f0454000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Stack:
 ffff8800b9c586c0 ffff8800b9c586c0 ffff8800ac4692c0 ffff8800936d4a90
 ffff8800352efd38 ffffffff8469a93e ffff8800352efd98 ffffffffc09b9b90
 ffff8800352efd78 ffff8800ac4692c0 ffff8800b9c586c0 ffff8800831b6ab8
Call Trace:
 [<ffffffff8469a93e>] ? mutex_unlock+0xe/0x10
 [<ffffffffc09b9b90>] ? inet_diag_handler_get_info+0x110/0x1fb [inet_diag]
 [<ffffffff845c868d>] netlink_broadcast+0x1d/0x20
 [<ffffffff8469a93e>] ? mutex_unlock+0xe/0x10
 [<ffffffff845b2bf5>] sock_diag_broadcast_destroy_work+0xd5/0x160
 [<ffffffff8408ea97>] process_one_work+0x147/0x420
 [<ffffffff8408f0f9>] worker_thread+0x69/0x470
 [<ffffffff8409fda3>] ? preempt_count_sub+0xa3/0xf0
 [<ffffffff8408f090>] ? rescuer_thread+0x320/0x320
 [<ffffffff84093cd7>] kthread+0x107/0x120
 [<ffffffff84093bd0>] ? kthread_create_on_node+0x1b0/0x1b0
 [<ffffffff8469d31f>] ret_from_fork+0x3f/0x70
 [<ffffffff84093bd0>] ? kthread_create_on_node+0x1b0/0x1b0
Code: 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 41 57 41 56 41 55 49 89 fd 48 89 f7 44 89 c6 41 54 41 89 d4 53 89 cb 48 83 ec 48 <49> 8b 45 30 44 89 45 a4 4c 89 4d 98 48 89 45 c0 e8 07 f6 ff ff 
RIP  [<ffffffff845c82e4>] netlink_broadcast_filtered+0x24/0x3b0
 RSP <ffff8800352efd08>
---[ end trace e2d8a07893775a9e ]---
 

r13 looks like slab poison, and the decoded instruction shows..


int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid,
        u32 group, gfp_t allocation,
        int (*filter)(struct sock *dsk, struct sk_buff *skb, void *data),
        void *filter_data)
{
    1b70:       e8 00 00 00 00          callq  1b75 <netlink_broadcast_filtered+0x5>
    1b75:       55                      push   %rbp
    1b76:       48 89 e5                mov    %rsp,%rbp
    1b79:       41 57                   push   %r15
    1b7b:       41 56                   push   %r14
    1b7d:       41 55                   push   %r13
    1b7f:       49 89 fd                mov    %rdi,%r13
    1b82:       48 89 f7                mov    %rsi,%rdi
    1b85:       44 89 c6                mov    %r8d,%esi
    1b88:       41 54                   push   %r12
    1b8a:       41 89 d4                mov    %edx,%r12d
    1b8d:       53                      push   %rbx
    1b8e:       89 cb                   mov    %ecx,%ebx
    1b90:       48 83 ec 48             sub    $0x48,%rsp
    1b94:       49 8b 45 30             mov    0x30(%r13),%rax    <--  trapping instruction
    1b98:       44 89 45 a4             mov    %r8d,-0x5c(%rbp)
    1b9c:       4c 89 4d 98             mov    %r9,-0x68(%rbp)
    1ba0:       48 89 45 c0             mov    %rax,-0x40(%rbp)
        struct net *net = sock_net(ssk);


So it looks like the ssk we passed in was already freed.
I'll dig into this some more next week, and try to find a better
reproducer.

	Dave
