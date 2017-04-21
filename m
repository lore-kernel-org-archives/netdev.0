From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/rose: null-ptr-deref in rose_route_frame
Date: Fri, 21 Apr 2017 15:29:45 +0200
Message-ID: <CAAeHK+wukKuG=VoZAiYQqe_8Y-VPOnE6X5g9R7GB+ZAwg+rhOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-hams@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got the following error report while fuzzing the kernel with syzkaller.

On commit 4f7d029b9bf009fbee76bb10c0c4351a1870d2f3 (4.11-rc7).

rose_xmit calls rose_route_frame(skb, ax25 = NULL), and
rose_route_frame then dereferences ax25 when doing
ax25cmp(&ax25->dest_addr, &rose_neigh->callsign).

kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 1 PID: 15 Comm: ksoftirqd/1 Not tainted 4.11.0-rc7+ #251
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88003e10adc0 task.stack: ffff88003e148000
RIP: 0010:ax25cmp+0x3f/0x150 net/ax25/ax25_addr.c:122
RSP: 0018:ffff88003e14d450 EFLAGS: 00010202
RAX: ffff88003e10adc0 RBX: ffff880069c606b8 RCX: 0000000000000002
RDX: 0000000000000100 RSI: 0000000000000007 RDI: 0000000000000017
RBP: ffff88003e14d488 R08: dffffc0000000000 R09: 0000000000000000
R10: 6a8a172cb651d699 R11: dffffc0000000000 R12: dffffc0000000000
R13: 000000000000001d R14: ffff880069c606c0 R15: 0000000000000017
FS:  0000000000000000(0000) GS:ffff88003ed00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000002044ef69 CR3: 000000005682b000 CR4: 00000000000006e0
Call Trace:
 rose_route_frame+0x3b1/0x19f0 net/rose/rose_route.c:883
 rose_xmit+0x7f/0x180 net/rose/rose_dev.c:110
 __netdev_start_xmit include/linux/netdevice.h:3980 [inline]
 netdev_start_xmit include/linux/netdevice.h:3989 [inline]
 xmit_one net/core/dev.c:2908 [inline]
 dev_hard_start_xmit+0x24e/0xac0 net/core/dev.c:2924
 __dev_queue_xmit+0x1ff8/0x2840 net/core/dev.c:3391
 dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
 bond_dev_queue_xmit+0x185/0x240 drivers/net/bonding/bond_main.c:261
 bond_xmit_slave_id+0x1fe/0x590 drivers/net/bonding/bond_main.c:3702
 bond_xmit_roundrobin drivers/net/bonding/bond_main.c:3779 [inline]
 __bond_start_xmit drivers/net/bonding/bond_main.c:4037 [inline]
 bond_start_xmit+0xb8a/0x17f0 drivers/net/bonding/bond_main.c:4071
 __netdev_start_xmit include/linux/netdevice.h:3980 [inline]
 netdev_start_xmit include/linux/netdevice.h:3989 [inline]
 xmit_one net/core/dev.c:2908 [inline]
 dev_hard_start_xmit+0x24e/0xac0 net/core/dev.c:2924
 __dev_queue_xmit+0x1ff8/0x2840 net/core/dev.c:3391
 dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
 neigh_connected_output+0x534/0x790 net/core/neighbour.c:1338
 neigh_output include/net/neighbour.h:478 [inline]
 ip6_finish_output2+0xbf8/0x2560 net/ipv6/ip6_output.c:123
 ip6_finish_output+0x302/0x960 net/ipv6/ip6_output.c:149
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip6_output+0x1cb/0x8d0 net/ipv6/ip6_output.c:163
 dst_output include/net/dst.h:486 [inline]
 NF_HOOK.constprop.39+0x115/0x650 include/linux/netfilter.h:257
 mld_sendpack+0x6fc/0xd40 net/ipv6/mcast.c:1660
 mld_send_cr net/ipv6/mcast.c:1951 [inline]
 mld_ifc_timer_expire+0x3c3/0x750 net/ipv6/mcast.c:2449
 call_timer_fn+0x23f/0x810 kernel/time/timer.c:1268
 expire_timers kernel/time/timer.c:1307 [inline]
 __run_timers+0x94e/0xcd0 kernel/time/timer.c:1601
 run_timer_softirq+0x21/0x80 kernel/time/timer.c:1614
 __do_softirq+0x2fb/0xb7d kernel/softirq.c:284
 run_ksoftirqd+0x20/0x60 kernel/softirq.c:676
 smpboot_thread_fn+0x562/0x860 kernel/smpboot.c:164
 kthread+0x35e/0x430 kernel/kthread.c:231
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
Code: 49 89 f6 49 bc 00 00 00 00 00 fc ff df 48 83 ec 10 48 89 7d c8
48 89 75 d0 e8 4e 4a 57 fd 4c 89 f9 4c 89 fe 48 c1 e9 03 83 e6 07 <42>
0f b6 0c 21 40 38 f1 7f 08 84 c9 0f 85 ef 00 00 00 4c 89 f1
RIP: ax25cmp+0x3f/0x150 net/ax25/ax25_addr.c:122 RSP: ffff88003e14d450
---[ end trace f569731c3e601819 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..
