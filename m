From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/ipv6: null-ptr-deref in ip6_rt_cache_alloc
Date: Wed, 30 Nov 2016 11:58:56 +0100
Message-ID: <CAAeHK+x67byVvfiA8KdEeV=fm4C6nSvm25TtgTVCvdEsKeNQfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36781 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750749AbcK3K7B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 05:59:01 -0500
Received: by mail-lf0-f50.google.com with SMTP id t196so143897179lff.3
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 02:58:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I've got the following error report while running the syzkaller fuzzer.

On commit d8e435f3ab6fea2ea324dce72b51dd7761747523 (Nov 26).

This might be related to the crash in rt6_get_cookie that Dmitry
reported, since it also happens when accessing ort->dst:
https://groups.google.com/forum/#!msg/syzkaller/3uDn6P5bwzA/gdzgPxeYAgAJ

general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 3 PID: 5315 Comm: syz-executor6 Not tainted 4.9.0-rc6+ #468
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88003b729700 task.stack: ffff880038be8000
RIP: 0010:[<ffffffff83442c35>]  [<ffffffff83442c35>]
ip6_rt_cache_alloc+0xa5/0x580 net/ipv6/route.c:953
RSP: 0018:ffff880038bef168  EFLAGS: 00010206
RAX: ffff88003b729700 RBX: 0000000000000007 RCX: 0000000000000001
RDX: 0000000000000000 RSI: ffffc90001aa7000 RDI: 0000000000000018
RBP: ffff880038bef198 R08: 0000000000004000 R09: 0000000000000003
R10: dffffc0000000000 R11: dffffc0000000000 R12: 0000000000000000
R13: ffff880038befa60 R14: 0000000000000000 R15: ffff880069ee1a40
FS:  00007fedfbb9f700(0000) GS:ffff88006e100000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000003109cb8 CR3: 000000006c633000 CR4: 00000000000006e0
Stack:
 ffffffff8125141d ffff880069ee1a40 00000000fffd635a 1ffffffff0981200
 0000000000000000 ffff880069ee1a40 ffff880038bef310 ffffffff8344f233
 ffff880038befa60 1ffff1000717de49 ffff880038befa4f ffffffff850a0a68
Call Trace:
 [<ffffffff8344f233>] ip6_pol_route+0x13c3/0x1b20 net/ipv6/route.c:1106
 [<ffffffff8344fa4d>] ip6_pol_route_output+0x4d/0x60 net/ipv6/route.c:1190
 [<ffffffff834f606d>] fib6_rule_action+0x23d/0x740 net/ipv6/fib6_rules.c:100
 [<ffffffff82d82c36>] fib_rules_lookup+0x2b6/0x850 net/core/fib_rules.c:227
 [<ffffffff834f6b46>] fib6_rule_lookup+0xd6/0x260 net/ipv6/fib6_rules.c:44
 [<ffffffff83443426>] ip6_route_output_flags+0x276/0x310 net/ipv6/route.c:1218
 [<ffffffff83408f8d>] ip6_dst_lookup_tail+0xf9d/0x1410 net/ipv6/ip6_output.c:965
 [<ffffffff83409501>] ip6_dst_lookup_flow+0xa1/0x200 net/ipv6/ip6_output.c:1061
 [<ffffffff83488a3c>] rawv6_sendmsg+0xc0c/0x2c20 net/ipv6/raw.c:893
 [<ffffffff832a1037>] inet_sendmsg+0x317/0x4e0 net/ipv4/af_inet.c:734
 [<     inline     >] sock_sendmsg_nosec net/socket.c:621
 [<ffffffff82c9d76c>] sock_sendmsg+0xcc/0x110 net/socket.c:631
 [<ffffffff82c9f651>] ___sys_sendmsg+0x771/0x8b0 net/socket.c:1954
 [<ffffffff82ca163e>] __sys_sendmsg+0xce/0x170 net/socket.c:1988
 [<     inline     >] SYSC_sendmsg net/socket.c:1999
 [<ffffffff82ca170d>] SyS_sendmsg+0x2d/0x50 net/socket.c:1995
 [<ffffffff840f2d81>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Code: 42 80 3c 06 00 0f 85 54 04 00 00 4d 8b 64 24 40 e8 11 11 01 fe
49 8d 7c 24 18 49 ba 00 00 00 00 00 fc ff df 49 89 f9 49 c1 e9 03 <43>
80 3c 11 00 0f 85 77 04 00 00 49 8b 74 24 18 49 bf 00 00 00
RIP  [<ffffffff83442c35>] ip6_rt_cache_alloc+0xa5/0x580 net/ipv6/route.c:953
 RSP <ffff880038bef168>
---[ end trace fefbac32da74ad88 ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled
