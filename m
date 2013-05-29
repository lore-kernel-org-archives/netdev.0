From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] vxlan: do real refcnt for vn_sock
Date: Wed, 29 May 2013 16:39:40 +0800
Message-ID: <1369816780.12227.21.camel@cr0>
References: <1369739242-5944-1-git-send-email-amwang@redhat.com>
	 <20130528214142.4e41db6f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60062 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965080Ab3E2Ijx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 04:39:53 -0400
In-Reply-To: <20130528214142.4e41db6f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-28 at 21:41 -0700, Stephen Hemminger wrote:
> Why not just fix the requirement to drop rtnl when calling igmp.
> The code comes out cleaner and safer as well.

Besides you forget to lock the socket before calling _ip_mc_join_group()
(and also the order is very important too), your patch doesn't fix the
problem I met. The full backtrace is below:

[  114.134123] BUG: unable to handle kernel NULL pointer dereference at
0000000000000068
[  114.136065] IP: [<ffffffff810a1061>] __lock_acquire+0x9c/0x45d
[  114.136065] PGD 71721067 PUD 70e11067 PMD 0 
[  114.136065] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  114.136065] CPU: 0 PID: 707 Comm: ip Not tainted 3.10.0-rc2+ #1075
[  114.136065] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  114.136065] task: ffff88006fce2480 ti: ffff88006d9ec000 task.ti:
ffff88006d9ec000
[  114.136065] RIP: 0010:[<ffffffff810a1061>]  [<ffffffff810a1061>]
__lock_acquire+0x9c/0x45d
[  114.136065] RSP: 0018:ffff88006d9ed6a8  EFLAGS: 00010046
[  114.136065] RAX: 0000000000000068 RBX: 0000000000000000 RCX:
0000000000000000
[  114.136065] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
0000000000000068
[  114.136065] RBP: ffff88006d9ed708 R08: 0000000000000002 R09:
0000000000000000
[  114.136065] R10: ffffffff8104f0bb R11: ffffffff8107632b R12:
ffff88006fce2480
[  114.136065] R13: 0000000000000000 R14: 0000000000000002 R15:
0000000000000000
[  114.136065] FS:  00007fc30cd89740(0000) GS:ffff88007f600000(0000)
knlGS:0000000000000000
[  114.136065] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  114.136065] CR2: 0000000000000068 CR3: 000000006f3a2000 CR4:
00000000000006f0
[  114.136065] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[  114.136065] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[  114.136065] Stack:
[  114.136065]  ffff88006d9ed6b8 ffffffff00000000 ffff880000000000
000000006fce2480
[  114.136065]  ffffffff00000000 0000000000000068 ffffffff825063d2
0000000000000000
[  114.136065]  ffff88006fce2480 ffffffff81757759 0000000000000002
0000000000000000
[  114.136065] Call Trace:
[  114.136065]  [<ffffffff81757759>] ? lock_sock_nested+0x3c/0x97
[  114.136065]  [<ffffffff810a2162>] lock_acquire+0xfa/0x140
[  114.136065]  [<ffffffff81757759>] ? lock_sock_nested+0x3c/0x97
[  114.136065]  [<ffffffff810a06d4>] ? trace_softirqs_off+0x3b/0xf3
[  114.136065]  [<ffffffff81976a1f>] _raw_spin_lock_bh+0x4a/0x7d
[  114.136065]  [<ffffffff81757759>] ? lock_sock_nested+0x3c/0x97
[  114.136065]  [<ffffffff810798db>] ? should_resched+0x9/0x28
[  114.136065]  [<ffffffff81757759>] lock_sock_nested+0x3c/0x97
[  114.136065]  [<ffffffff815e13a1>] vxlan_leave_group+0xc4/0x111
[  114.136065]  [<ffffffff81054dfc>] ? local_bh_enable_ip+0xe/0x10
[  114.136065]  [<ffffffff815e142d>] vxlan_stop+0x3f/0xaa
[  114.136065]  [<ffffffff817659ff>] __dev_close_many+0x9c/0xc4
[  114.136065]  [<ffffffff81765af3>] dev_close_many+0x70/0xd8
[  114.136065]  [<ffffffff817697f6>] rollback_registered_many+0xa2/0x1a7
[  114.136065]  [<ffffffff81769a4e>] unregister_netdevice_many+0x19/0x51
[  114.136065]  [<ffffffff817738b5>] rtnl_dellink+0xd0/0xfb
[  114.136065]  [<ffffffff81058754>] ? ns_capable+0x4d/0x66
[  114.136065]  [<ffffffff81774aaf>] rtnetlink_rcv_msg+0x19c/0x1ab
[  114.136065]  [<ffffffff81774913>] ? __rtnl_unlock+0x17/0x17
[  114.136065]  [<ffffffff817bc7d8>] netlink_rcv_skb+0x42/0x8d
[  114.136065]  [<ffffffff817748f5>] rtnetlink_rcv+0x26/0x2d
[  114.136065]  [<ffffffff817bb001>] netlink_unicast+0xb7/0x138
[  114.136065]  [<ffffffff817bba6b>] netlink_sendmsg+0x2b8/0x2f2
[  114.136065]  [<ffffffff81752e3e>] sock_sendmsg+0x7f/0xa0
[  114.136065]  [<ffffffff8111ee4d>] ? might_fault+0xa5/0xac
[  114.136065]  [<ffffffff8111ee04>] ? might_fault+0x5c/0xac
[  114.136065]  [<ffffffff817527ba>] ? move_addr_to_kernel+0x41/0x5a
[  114.136065]  [<ffffffff8175db77>] ? verify_iovec+0x5b/0xac
[  114.136065]  [<ffffffff81753064>] __sys_sendmsg+0x205/0x2a1
[  114.136065]  [<ffffffff8102c172>] ? __do_page_fault+0x2ee/0x38b
[  114.136065]  [<ffffffff8107507a>] ? up_read+0x29/0x2e
[  114.136065]  [<ffffffff8116794f>] ? fcheck_files+0xa3/0xe1
[  114.136065]  [<ffffffff81168915>] ? fget_light+0x3a/0xa4
[  114.136065]  [<ffffffff81753f91>] SyS_sendmsg+0x42/0x60
[  114.136065]  [<ffffffff819781c2>] system_call_fastpath+0x16/0x1b
[  114.136065] Code: 00 00 83 3d c1 46 d7 01 00 0f 85 cb 03 00 00 48 c7
c1 1c ef d5 81 48 c7 c2 67 5f d5 81 be fb 0b 00 00 e9 1b 02 00 00 48 8b
45 c8 <48> 81 38 a0 f5 52 82 b8 01 00 00 00 44 0f 44 f0 83 fe 01 77 10 
[  114.136065] RIP  [<ffffffff810a1061>] __lock_acquire+0x9c/0x45d
[  114.136065]  RSP <ffff88006d9ed6a8>
[  114.136065] CR2: 0000000000000068
[  114.136065] ---[ end trace 92078b41edbc404d ]---
[  114.136065] Kernel panic - not syncing: Fatal exception in interrupt
