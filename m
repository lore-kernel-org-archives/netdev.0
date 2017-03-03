From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/ipv4: division by 0 in tcp_select_window
Date: Fri, 3 Mar 2017 19:10:10 +0100
Message-ID: <CACT4Y+Y+dL6EzkfDahjQUyyT4YMhDin7UPY5RQYbNH0n0DJ5xA@mail.gmail.com>
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
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:36769 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752037AbdCCSfT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 13:35:19 -0500
Received: by mail-ua0-f172.google.com with SMTP id 72so125057466uaf.3
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 10:34:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The following program triggers division by 0 in tcp_select_window:

https://gist.githubusercontent.com/dvyukov/ef28c0fd2ab57a655508ef7621b12e6c/raw/079011e2a9523a390b0621cbc1e5d9d5e637fd6d/gistfile1.txt

divide error: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.10.0+ #270
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006c236340 task.stack: ffff88006c248000
RIP: 0010:__tcp_select_window+0x6db/0x920 net/ipv4/tcp_output.c:2585
RSP: 0018:ffff88006cf86b40 EFLAGS: 00010206
RAX: 00000000000000c4 RBX: ffff88006cf86cd8 RCX: dffffc0000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8800686228bd
RBP: ffff88006cf86d00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000004 R11: ffffed000d9f0e18 R12: 00000000000000c4
R13: 000000000000a700 R14: ffff880068622040 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88006cf80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020e5cff8 CR3: 0000000005021000 CR4: 00000000001406e0
Call Trace:
 <IRQ>
 tcp_select_window net/ipv4/tcp_output.c:270 [inline]
 tcp_transmit_skb+0xc35/0x3460 net/ipv4/tcp_output.c:1014
 tcp_xmit_probe_skb+0x36d/0x440 net/ipv4/tcp_output.c:3528
 tcp_write_wakeup+0x23b/0x6d0 net/ipv4/tcp_output.c:3577
 tcp_send_probe0+0xbf/0x5d0 net/ipv4/tcp_output.c:3593
 tcp_probe_timer net/ipv4/tcp_timer.c:362 [inline]
 tcp_write_timer_handler+0x849/0x9d0 net/ipv4/tcp_timer.c:578
 tcp_write_timer+0x164/0x180 net/ipv4/tcp_timer.c:592
 call_timer_fn+0x241/0x820 kernel/time/timer.c:1266
 expire_timers kernel/time/timer.c:1305 [inline]
 __run_timers+0x960/0xcf0 kernel/time/timer.c:1599
 run_timer_softirq+0x21/0x80 kernel/time/timer.c:1612
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
 invoke_softirq kernel/softirq.c:364 [inline]
 irq_exit+0x1cc/0x200 kernel/softirq.c:405
 exiting_irq arch/x86/include/asm/apic.h:658 [inline]
 smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
 apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:487
RIP: 0010:native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:53
RSP: 0018:ffff88006c24fc10 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff10
RAX: dffffc0000000000 RBX: 1ffff1000d849f85 RCX: 0000000000000000
RDX: 1ffffffff0a18ebc RSI: 0000000000000001 RDI: ffffffff850c75e0
RBP: ffff88006c24fc10 R08: ffff88007fff70dc R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 1ffff1000d849fa9
R13: ffff88006c24fcc8 R14: ffffffff856972b8 R15: ffff88006c24fe68
 </IRQ>
 arch_safe_halt arch/x86/include/asm/paravirt.h:98 [inline]
 default_idle+0xbf/0x440 arch/x86/kernel/process.c:271
 arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:262
 default_idle_call+0x36/0x90 kernel/sched/idle.c:96
 cpuidle_idle_call kernel/sched/idle.c:154 [inline]
 do_idle+0x373/0x520 kernel/sched/idle.c:243
 cpu_startup_entry+0x18/0x20 kernel/sched/idle.c:345
 start_secondary+0x36c/0x460 arch/x86/kernel/smpboot.c:272
 start_cpu+0x14/0x14 arch/x86/kernel/head_64.S:306
Code: 5d c3 e8 99 0d e5 fd 45 85 ff 44 89 bd 74 fe ff ff 0f 8f 14 fc
ff ff 45 31 e4 eb 93 e8 7f 0d e5 fd 8b b5 74 fe ff ff 44 89 e0 99 <f7>
fe 41 89 c4 44 0f af e6 e9 71 ff ff ff e8 62 0d e5 fd 4c 89
RIP: __tcp_select_window+0x6db/0x920 net/ipv4/tcp_output.c:2585 RSP:
ffff88006cf86b40
---[ end trace 5efcbe8231e36800 ]---

On commit c82be9d2244aacea9851c86f4fb74694c99cd874.

The guy that resets mss seems to be
inet_csk_listen_start->inet_csk_delack_init. After that the timer
fires and divides by icsk->icsk_ack.rcv_mss==0.
