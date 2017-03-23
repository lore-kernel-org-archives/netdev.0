From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/sched: GPF in qdisc_hash_add
Date: Thu, 23 Mar 2017 17:06:19 +0100
Message-ID: <CACT4Y+bemisEVj1nFmyFPuJZxh3oa8QOf-qDZmjRyPZBG4y7ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've hit the following GPF while running syzkaller on commit
093b995e3b55a0ae0670226ddfcb05bfbf0099ae.  Note the preceding injected
kmalloc failure, most likely it's the root cause.

FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
CPU: 2 PID: 12732 Comm: syz-executor6 Not tainted 4.11.0-rc3+ #365
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x1b8/0x28d lib/dump_stack.c:52
 fail_dump lib/fault-inject.c:52 [inline]
 should_fail+0x804/0x8c0 lib/fault-inject.c:154
 should_failslab+0xec/0x120 mm/failslab.c:31
 slab_pre_alloc_hook mm/slab.h:434 [inline]
 slab_alloc_node mm/slab.c:3315 [inline]
 kmem_cache_alloc_node_trace+0x200/0x720 mm/slab.c:3679
 __do_kmalloc_node mm/slab.c:3699 [inline]
 __kmalloc_node+0x33/0x70 mm/slab.c:3707
 kmalloc_node include/linux/slab.h:532 [inline]
 kzalloc_node include/linux/slab.h:674 [inline]
 qdisc_alloc+0xf4/0x670 net/sched/sch_generic.c:604
 qdisc_create_dflt+0x59/0x160 net/sched/sch_generic.c:652
 attach_one_default_qdisc net/sched/sch_generic.c:767 [inline]
 netdev_for_each_tx_queue include/linux/netdevice.h:1948 [inline]
 attach_default_qdiscs net/sched/sch_generic.c:786 [inline]
 dev_activate+0x58d/0x920 net/sched/sch_generic.c:829
 __dev_open+0x25b/0x360 net/core/dev.c:1348
 __dev_change_flags+0x159/0x3d0 net/core/dev.c:6460
 dev_change_flags+0x88/0x140 net/core/dev.c:6525
 dev_ifsioc+0x51f/0x9b0 net/core/dev_ioctl.c:254
 dev_ioctl+0x1fe/0x1030 net/core/dev_ioctl.c:532
 sock_do_ioctl+0x94/0xb0 net/socket.c:902
 sock_ioctl+0x2c2/0x440 net/socket.c:993
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1af/0x16d0 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x445b79
RSP: 002b:00007f68665cf858 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 0000000000445b79
RDX: 0000000020000000 RSI: 0000000000008914 RDI: 0000000000000019
RBP: 0000000000000086 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 00000000004a7e31
R13: 0000000000000000 R14: 00007f68665cf618 R15: 00007f68665cf788
kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 2 PID: 12732 Comm: syz-executor6 Not tainted 4.11.0-rc3+ #365
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880062b7a2c0 task.stack: ffff880033480000
RIP: 0010:qdisc_hash_add.part.19+0xb6/0x3c0 net/sched/sch_api.c:280
RSP: 0018:ffff880033487820 EFLAGS: 00010202
RAX: dffffc0000000000 RBX: ffffffff85357e00 RCX: ffffc90002b24000
RDX: 000000000000007a RSI: ffffffff835a523a RDI: 00000000000003d0
RBP: ffff8800334878b8 R08: fffffbfff0a6afeb R09: fffffbfff0a6afeb
R10: 0000000000000001 R11: fffffbfff0a6afea R12: ffffffff85357e48
R13: 1ffff10006690f06 R14: ffff880033487890 R15: 0000000000000000
FS:  00007f68665d0700(0000) GS:ffff88006e200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004c2d44 CR3: 000000003c6f8000 CR4: 00000000000026e0
Call Trace:
 qdisc_hash_add+0x76/0x90 net/sched/sch_api.c:279
 attach_default_qdiscs net/sched/sch_generic.c:798 [inline]
 dev_activate+0x6ca/0x920 net/sched/sch_generic.c:829
 __dev_open+0x25b/0x360 net/core/dev.c:1348
 __dev_change_flags+0x159/0x3d0 net/core/dev.c:6460
 dev_change_flags+0x88/0x140 net/core/dev.c:6525
 dev_ifsioc+0x51f/0x9b0 net/core/dev_ioctl.c:254
 dev_ioctl+0x1fe/0x1030 net/core/dev_ioctl.c:532
 sock_do_ioctl+0x94/0xb0 net/socket.c:902
 sock_ioctl+0x2c2/0x440 net/socket.c:993
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1af/0x16d0 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x445b79
RSP: 002b:00007f68665cf858 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 0000000000445b79
RDX: 0000000020000000 RSI: 0000000000008914 RDI: 0000000000000019
RBP: 0000000000000086 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 00000000004a7e31
R13: 0000000000000000 R14: 00007f68665cf618 R15: 00007f68665cf788
Code: 89 fa 48 c1 ea 03 80 3c 02 00 0f 85 5a 02 00 00 4d 8b 3f 48 b8
00 00 00 00 00 fc ff df 49 8d bf d0 03 00 00 48 89 fa 48 c1 ea 03 <80>
3c 02 00 0f 85 c2 02 00 00 49 81 bf d0 03 00 00 00 7e 35 85
RIP: qdisc_hash_add.part.19+0xb6/0x3c0 net/sched/sch_api.c:280 RSP:
ffff880033487820
---[ end trace 1529d12967754f9c ]---
