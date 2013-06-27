From: Artem Savkov <artem.savkov@gmail.com>
Subject: [BUG]: missing shinfo with netlink_alloc_large_skb
Date: Thu, 27 Jun 2013 15:44:32 +0400
Message-ID: <20130627114432.GA22103@cpv436-motbuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I ran into a bug while running trinity with write/writev syscalls. Seems like
it has been introduced by "netlink: allow large data transfers from user-space"
commit. nf_fib_input calls skb_clone which expects skb_shinfo to be allocated,
but netlink_alloc_large_skb doesn't do that, should it?.
Relevant dmesg log below.

[  894.990671] BUG: unable to handle kernel paging request at ffffc9000047b001
[  894.991034] IP: [<ffffffff81a212c4>] skb_clone+0x24/0xc0
[  894.991034] PGD 1e43c067 PUD 1e43d067 PMD 1c2fb067 PTE 0
[  894.991034] Oops: 0000 [#1] SMP 
[  894.991034] Modules linked in:
[  894.991034] CPU: 0 PID: 21014 Comm: trinity-child0 Not tainted 3.10.0-rc7-next-20130627 #96
[  894.991034] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  894.991034] task: ffff88001b110000 ti: ffff880018fba000 task.ti: ffff880018fba000
[  894.991034] RIP: 0010:[<ffffffff81a212c4>]  [<ffffffff81a212c4>] skb_clone+0x24/0xc0
[  894.991034] RSP: 0018:ffff880018fbbad8  EFLAGS: 00010286
[  894.991034] RAX: 0000000000003000 RBX: ffff880019dcc480 RCX: 00000000000050c0
[  894.991034] RDX: ffffc90000478000 RSI: 00000000000000d0 RDI: ffff880019dcc480
[  894.991034] RBP: ffff880018fbbae8 R08: 0000000000000000 R09: 0000000000000001
[  894.991034] R10: 0000000000000001 R11: 0000000000010530 R12: 00000000000000d0
[  894.991034] R13: ffff880019dcc480 R14: 0000000000000000 R15: ffff880018fbbba0
[  894.991034] FS:  00007f731abaa700(0000) GS:ffff88001f600000(0000) knlGS:0000000000000000
[  894.991034] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  894.991034] CR2: ffffc9000047b001 CR3: 0000000018f04000 CR4: 00000000000006f0
[  894.991034] Stack:
[  894.991034]  ffffffff824d5b40 ffff880019e640f8 ffff880018fbbb78 ffffffff81ad299a
[  894.991034]  ffffffff824da678 ffffffff824da660 ffff88001d740948 ffff88001e615a78
[  894.991034]  0000000000000000 ffffffff824da660 ffff880018fbbb48 ffffffff81c3b7e6
[  894.991034] Call Trace:
[  894.991034]  [<ffffffff81ad299a>] nl_fib_input+0x6a/0x240
[  894.991034]  [<ffffffff81c3b7e6>] ? _raw_read_unlock+0x26/0x40
[  894.991034]  [<ffffffff81a5f189>] netlink_unicast+0x169/0x1e0
[  894.991034]  [<ffffffff81a601e1>] netlink_sendmsg+0x251/0x3d0
[  894.991034]  [<ffffffff81a13a4d>] sock_aio_write+0x16d/0x180
[  894.991034]  [<ffffffff814f400b>] ? T.1667+0x5b/0x90
[  894.991034]  [<ffffffff81170d48>] do_sync_readv_writev+0x68/0xa0
[  894.991034]  [<ffffffff81172737>] do_readv_writev+0xd7/0x2b0
[  894.991034]  [<ffffffff8108bba8>] ? sched_clock_cpu+0xb8/0x100
[  894.991034]  [<ffffffff81a138e0>] ? sock_aio_read+0x190/0x190
[  894.991034]  [<ffffffff81c3bb1b>] ? _raw_spin_unlock_irq+0x2b/0x50
[  894.991034]  [<ffffffff81172958>] vfs_writev+0x48/0x60
[  894.991034]  [<ffffffff81172a9d>] SyS_writev+0x5d/0xd0
[  894.991034]  [<ffffffff81554cee>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  894.991034]  [<ffffffff81c44852>] system_call_fastpath+0x16/0x1b
[  894.991034] Code: e9 37 ff ff ff 66 90 55 48 89 e5 48 83 ec 10 48 89 1c 24 4c 89 64 24 08 48 89 fb 8b 87 cc 00 00 00 48 8b 97 d0 00 00 00 41 89 f4 <f6> 44 02 01 08 75 6b 0f b6 43 7d 83 e0 18 3c 08 75 3a 48 8d bb 
[  894.991034] RIP  [<ffffffff81a212c4>] skb_clone+0x24/0xc0
[  894.991034]  RSP <ffff880018fbbad8>
[  894.991034] CR2: ffffc9000047b001
[  894.991034] ---[ end trace d83aeb9c553c5c5e ]---
[  894.991034] BUG: sleeping function called from invalid context at kernel/rwsem.c:20
[  894.991034] in_atomic(): 0, irqs_disabled(): 1, pid: 21014, name: trinity-child0
[  894.991034] INFO: lockdep is turned off.
[  894.991034] irq event stamp: 33740
[  894.991034] hardirqs last  enabled at (33739): [<ffffffff81125c6d>] get_page_from_freelist+0x47d/0x940
[  894.991034] hardirqs last disabled at (33740): [<ffffffff81c3c333>] error_sti+0x5/0x6
[  894.991034] softirqs last  enabled at (33298): [<ffffffff81054ec8>] __do_softirq+0x1c8/0x3f0
[  894.991034] softirqs last disabled at (33293): [<ffffffff81055205>] irq_exit+0xa5/0xb0
[  894.991034] CPU: 0 PID: 21014 Comm: trinity-child0 Tainted: G      D      3.10.0-rc7-next-20130627 #96
[  894.991034] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  894.991034]  ffffffff8216d6a7 ffff880018fbb6e8 ffffffff81c358cc ffff880018fbb6e8
[  894.991034]  ffff88001b110000 ffff880018fbb718 ffffffff81086074 ffff880018fbb758
[  894.991034]  ffff88001b6dbc40 ffff88001b6dbca0 ffff880018fbba28 ffff880018fbb748
[  894.991034] Call Trace:
[  894.991034]  [<ffffffff81c358cc>] dump_stack+0x59/0x7d
[  894.991034]  [<ffffffff81086074>] __might_sleep+0x174/0x220
[  894.991034]  [<ffffffff81c38555>] down_read+0x25/0xa0
[  894.991034]  [<ffffffff8106382f>] exit_signals+0x1f/0x140
[  894.991034]  [<ffffffff81051987>] do_exit+0xb7/0xc80
[  894.991034]  [<ffffffff8104eb88>] ? kmsg_dump+0x1d8/0x2a0
[  894.991034]  [<ffffffff8104e9d1>] ? kmsg_dump+0x21/0x2a0
[  894.991034]  [<ffffffff81c3cce3>] oops_end+0xa3/0xf0
[  894.991034]  [<ffffffff8103f5f5>] no_context+0x115/0x2d0
[  894.991034]  [<ffffffff81125c6d>] ? get_page_from_freelist+0x47d/0x940
[  894.991034]  [<ffffffff8103f8dd>] __bad_area_nosemaphore+0x12d/0x230
[  894.991034]  [<ffffffff8103f9ee>] bad_area_nosemaphore+0xe/0x10
[  894.991034]  [<ffffffff81c3f8fe>] __do_page_fault+0x12e/0x4f0
[  894.991034]  [<ffffffff8108ba85>] ? sched_clock_local+0x25/0x90
[  894.991034]  [<ffffffff8108bba8>] ? sched_clock_cpu+0xb8/0x100
[  894.991034]  [<ffffffff81554d2d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  894.991034]  [<ffffffff81c3fcc9>] do_page_fault+0x9/0x10
[  894.991034]  [<ffffffff81c3c142>] page_fault+0x22/0x30
[  894.991034]  [<ffffffff81a212c4>] ? skb_clone+0x24/0xc0
[  894.991034]  [<ffffffff81ad299a>] nl_fib_input+0x6a/0x240
[  894.991034]  [<ffffffff81c3b7e6>] ? _raw_read_unlock+0x26/0x40
[  894.991034]  [<ffffffff81a5f189>] netlink_unicast+0x169/0x1e0
[  894.991034]  [<ffffffff81a601e1>] netlink_sendmsg+0x251/0x3d0
[  894.991034]  [<ffffffff81a13a4d>] sock_aio_write+0x16d/0x180
[  894.991034]  [<ffffffff814f400b>] ? T.1667+0x5b/0x90
[  894.991034]  [<ffffffff81170d48>] do_sync_readv_writev+0x68/0xa0
[  894.991034]  [<ffffffff81172737>] do_readv_writev+0xd7/0x2b0
[  894.991034]  [<ffffffff8108bba8>] ? sched_clock_cpu+0xb8/0x100
[  894.991034]  [<ffffffff81a138e0>] ? sock_aio_read+0x190/0x190
[  894.991034]  [<ffffffff81c3bb1b>] ? _raw_spin_unlock_irq+0x2b/0x50
[  894.991034]  [<ffffffff81172958>] vfs_writev+0x48/0x60
[  894.991034]  [<ffffffff81172a9d>] SyS_writev+0x5d/0xd0
[  894.991034]  [<ffffffff81554cee>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  894.991034]  [<ffffffff81c44852>] system_call_fastpath+0x16/0x1b

-- 
Regards,
    Artem
