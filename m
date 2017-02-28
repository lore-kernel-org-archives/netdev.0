From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/atm: vcc_sendmsg calls kmem_cache_alloc in non-blocking context
Date: Tue, 28 Feb 2017 16:26:38 +0100
Message-ID: <CACT4Y+abEEVtX1eMTQdApx7RFHt02NPNApuM2XUw=seSx=MqVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Al Viro <viro@zeniv.linux.org.uk>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've got the following WARNING while running syzkaller fuzzer:

------------[ cut here ]------------
WARNING: CPU: 0 PID: 9197 at kernel/sched/core.c:6149
__might_sleep+0x149/0x1a0 kernel/sched/core.c:6144
do not call blocking ops when !TASK_RUNNING; state=1 set at
[<ffffffff813fa422>] prepare_to_wait+0x182/0x530
kernel/sched/wait.c:178
Kernel panic - not syncing: panic_on_warn set ...

CPU: 0 PID: 9197 Comm: syz-executor2 Not tainted 4.10.0+ #54
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x292/0x398 lib/dump_stack.c:51
 panic+0x1cb/0x3a9 kernel/panic.c:179
 __warn+0x1c4/0x1e0 kernel/panic.c:540
 warn_slowpath_fmt+0xc5/0x110 kernel/panic.c:563
 __might_sleep+0x149/0x1a0 kernel/sched/core.c:6144
 slab_pre_alloc_hook mm/slab.h:432 [inline]
 slab_alloc_node mm/slub.c:2644 [inline]
 kmem_cache_alloc_node+0x14a/0x280 mm/slub.c:2754
 __alloc_skb+0x10f/0x770 net/core/skbuff.c:219
 alloc_skb include/linux/skbuff.h:932 [inline]
 alloc_tx net/atm/common.c:75 [inline]
 vcc_sendmsg+0x5e8/0x1010 net/atm/common.c:609
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 ___sys_sendmsg+0x9d2/0xae0 net/socket.c:1985
 __sys_sendmsg+0x138/0x320 net/socket.c:2019
 SYSC_sendmsg net/socket.c:2030 [inline]
 SyS_sendmsg+0x2d/0x50 net/socket.c:2026
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458b9
RSP: 002b:00007f20dd37ab58 EFLAGS: 00000286 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458b9
RDX: 0000000000000000 RSI: 0000000020000000 RDI: 0000000000000005
RBP: 00000000006e1af0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 0000000000708000
R13: 0000000000000005 R14: 0000000020000ff8 R15: 0000000000000008

On commit 86292b33d4b79ee03e2f43ea0381ef85f077c760
