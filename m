From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: heap out-of-bounds in ip6_fragment
Date: Thu, 2 Feb 2017 11:14:09 +0100
Message-ID: <CACT4Y+b_vMOs4Sxsqso=oCdbCr10U22tOGk6ksKkjR2LuuqPLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

The following program triggers heap out-of-bounds in ip6_fragment:
https://gist.githubusercontent.com/dvyukov/2596659b7a950d5f56f1eedfb30e2c7f/raw/b12afd119d960f7d179d220238257ba9666c6fdc/gistfile1.txt

BUG: KASAN: slab-out-of-bounds in skb_copy_from_linear_data
include/linux/skbuff.h:3165 [inline] at addr ffff8800696a7098
BUG: KASAN: slab-out-of-bounds in ip6_fragment+0x168e/0x38c0
net/ipv6/ip6_output.c:819 at addr ffff8800696a7098
Read of size 920 by task a.out/2924
CPU: 2 PID: 2924 Comm: a.out Not tainted 4.10.0-rc6+ #206
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:165
 print_address_description mm/kasan/report.c:203 [inline]
 kasan_report_error+0x17b/0x430 mm/kasan/report.c:287
 kasan_report+0x35/0x40 mm/kasan/report.c:307
 check_memory_region_inline mm/kasan/kasan.c:315 [inline]
 check_memory_region+0x139/0x190 mm/kasan/kasan.c:322
 memcpy+0x23/0x50 mm/kasan/kasan.c:357
 skb_copy_from_linear_data include/linux/skbuff.h:3165 [inline]
 ip6_fragment+0x168e/0x38c0 net/ipv6/ip6_output.c:819
 ip6_finish_output+0x319/0x950 net/ipv6/ip6_output.c:146
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip6_output+0x1cb/0x8c0 net/ipv6/ip6_output.c:162
 dst_output include/net/dst.h:501 [inline]
 ip6_local_out+0x95/0x170 net/ipv6/output_core.c:172
 ip6_send_skb+0xa1/0x340 net/ipv6/ip6_output.c:1722
 ip6_push_pending_frames+0xb3/0xe0 net/ipv6/ip6_output.c:1742
 rawv6_push_pending_frames net/ipv6/raw.c:613 [inline]
 rawv6_sendmsg+0x2d1a/0x3ec0 net/ipv6/raw.c:927
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:744
 sock_sendmsg_nosec net/socket.c:635 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:645
 ___sys_sendmsg+0x8fa/0x9f0 net/socket.c:1985
 __sys_sendmsg+0x138/0x300 net/socket.c:2019
 SYSC_sendmsg net/socket.c:2030 [inline]
 SyS_sendmsg+0x2d/0x50 net/socket.c:2026
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x435059
RSP: 002b:00007ffe2884c958 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 0000000000401db0 RCX: 0000000000435059
RDX: 0000000000040040 RSI: 00000000200c4000 RDI: 0000000000000003
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000004002b0
R13: 0000000000401db0 R14: 0000000000401e40 R15: 0000000000000000
Object at ffff8800696a7080, in cache kmalloc-512 size: 512
Allocated:
PID = 2924
[<ffffffff812b1506>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
[<ffffffff81a0cd83>] save_stack+0x43/0xd0 mm/kasan/kasan.c:502
[<ffffffff81a0d04a>] set_track mm/kasan/kasan.c:514 [inline]
[<ffffffff81a0d04a>] kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
[<ffffffff81a0a4d7>] __do_kmalloc_node mm/slab.c:3691 [inline]
[<ffffffff81a0a4d7>] __kmalloc_node_track_caller+0x47/0x70 mm/slab.c:3705
[<ffffffff83540171>] __kmalloc_reserve.isra.36+0x41/0xd0 net/core/skbuff.c:138
[<ffffffff83543da9>] __alloc_skb+0x159/0x7e0 net/core/skbuff.c:231
[<ffffffff8352f67d>] alloc_skb include/linux/skbuff.h:926 [inline]
[<ffffffff8352f67d>] sock_wmalloc+0x14d/0x1e0 net/core/sock.c:1766
[<ffffffff839a9e1a>] __ip6_append_data.isra.43+0x28ba/0x3c00
net/ipv6/ip6_output.c:1460
[<ffffffff839ab30a>] ip6_append_data+0x1aa/0x2b0 net/ipv6/ip6_output.c:1616
[<ffffffff83a36e0d>] rawv6_sendmsg+0x1efd/0x3ec0 net/ipv6/raw.c:920
[<ffffffff83883f74>] inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:744
[<ffffffff8351dd3a>] sock_sendmsg_nosec net/socket.c:635 [inline]
[<ffffffff8351dd3a>] sock_sendmsg+0xca/0x110 net/socket.c:645
[<ffffffff8352057a>] ___sys_sendmsg+0x8fa/0x9f0 net/socket.c:1985
[<ffffffff83523138>] __sys_sendmsg+0x138/0x300 net/socket.c:2019
[<ffffffff8352332d>] SYSC_sendmsg net/socket.c:2030 [inline]
[<ffffffff8352332d>] SyS_sendmsg+0x2d/0x50 net/socket.c:2026
[<ffffffff841c9f81>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Memory state around the buggy address:
 ffff8800696a7180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff8800696a7200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff8800696a7280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
                   ^
 ffff8800696a7300: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff8800696a7380: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================

On commit a2ca3d617944417e9dd5f09fc8a4549cda115f4f.
