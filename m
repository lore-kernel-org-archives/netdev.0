From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: general protection fault in deactivate_slab
Date: Tue, 6 Jun 2017 13:00:58 +0200
Message-ID: <CAAeHK+zvLUfKzorLSi7upEvH9Y3VXqFVpNCPY3kEEBQuHLGR+w@mail.gmail.com>
References: <CACbyUSpzod2_9-gZNtMqr=Zh3kaY-9dsREP-fdjHp+cz0PWoyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Gene Blue <geneblue.mail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f176.google.com ([209.85.213.176]:36433 "EHLO
        mail-yb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751404AbdFFLBA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 07:01:00 -0400
Received: by mail-yb0-f176.google.com with SMTP id o9so24110260yba.3
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 04:00:59 -0700 (PDT)
In-Reply-To: <CACbyUSpzod2_9-gZNtMqr=Zh3kaY-9dsREP-fdjHp+cz0PWoyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 6, 2017 at 12:30 PM, Gene Blue <geneblue.mail@gmail.com> wrote:
> Hi:
>   I got this crash when fuzzing the kernel with syzkaller.
>
>   My kernel version is  4.11.0-rc1 directly download from kernel.org.
>
>   And this crash is reproducible. Three times in total during the period of
> fuzzing.

Hi!

This has already been reported and fixed:
https://groups.google.com/forum/#!topic/syzkaller/e3I2c8X2oWo
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=232cd35d0804cc241eb887bb8d4d9b3b9881c64a

I've added a note about checking whether the bug was reported
previously to syzkaller wiki:
https://github.com/google/syzkaller/wiki/Reporting-kernel-bugs

Thanks!

>
>
> **********************************************************************
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 3 PID: 5291 Comm: syz-executor3 Not tainted 4.11.0-rc1 #7
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88003cc82dc0 task.stack: ffff88003df10000
> RIP: 0010:get_freepointer mm/slub.c:243 [inline]
> RIP: 0010:deactivate_slab+0xa8/0x550 mm/slub.c:2020
> RSP: 0018:ffff88003df17250 EFLAGS: 00010002
> RAX: 0000000000000001 RBX: ffff88003e80ed40 RCX: 0000000000000000
> RDX: ffff88006d66d6c0 RSI: 0000000000000000 RDI: ffffea0001b59a00
> RBP: ffff88003df17348 R08: 0000000000008000 R09: 0000000000008007
> R10: ffff88006d66b410 R11: ffff88006d669018 R12: ffff88003e80ed48
> R13: 2bcbe23c521cd9a5 R14: 2bcbe23c521cd9a5 R15: ffffea0001b59a00
> FS:  00007fb559210700(0000) GS:ffff88006e300000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020e76fc8 CR3: 000000003c2c0000 CR4: 00000000000006e0
> Call Trace:
>  ___slab_alloc+0x199/0x5d0 mm/slub.c:2595
>  __slab_alloc+0x4c/0x90 mm/slub.c:2621
>  slab_alloc_node mm/slub.c:2684 [inline]
>  __kmalloc_node_track_caller+0xa7/0x3a0 mm/slub.c:4303
>  __kmalloc_reserve.isra.37+0x41/0xe0 net/core/skbuff.c:138
>  __alloc_skb+0xf0/0x590 net/core/skbuff.c:231
>  alloc_skb include/linux/skbuff.h:933 [inline]
>  alloc_skb_with_frags+0xae/0x510 net/core/skbuff.c:4661
>  sock_alloc_send_pskb+0x5e5/0x750 net/core/sock.c:1892
>  sock_alloc_send_skb+0x32/0x40 net/core/sock.c:1909
>  __ip6_append_data.isra.43+0x2058/0x3560 net/ipv6/ip6_output.c:1462
>  ip6_append_data+0x1d1/0x310 net/ipv6/ip6_output.c:1628
>  udpv6_sendmsg+0x1339/0x2550 net/ipv6/udp.c:1264
>  inet_sendmsg+0x129/0x530 net/ipv4/af_inet.c:761
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xcc/0x110 net/socket.c:643
>  SYSC_sendto+0x211/0x340 net/socket.c:1685
>  SyS_sendto+0x40/0x50 net/socket.c:1653
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458d9
> RSP: 002b:00007fb55920fb58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
> RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 00000000004458d9
> RDX: 0000000000000746 RSI: 0000000020e7a8ba RDI: 0000000000000006
> RBP: 0000000000000046 R08: 0000000020e78000 R09: 000000000000001c
> R10: 0000000000008800 R11: 0000000000000282 R12: 00000000006df570
> R13: 0000000000000006 R14: 0000000000000005 R15: 0000000000000000
> Code: 8b 57 10 49 8b 4f 18 49 89 54 35 00 48 89 4c 24 68 66 83 6c 24 68 01
> 80 7c 24 6b 00 78 c6 0f 0b 48 63 73 20 49 8b 57 10 4d 89 f5 <49> 8b 3c 36 48
> 85 ff 74 05 49 89 fe eb ca 4c 8b 5c 24 48 4d 8d
> RIP: get_freepointer mm/slub.c:243 [inline] RSP: ffff88003df17250
> RIP: deactivate_slab+0xa8/0x550 mm/slub.c:2020 RSP: ffff88003df17250
> ---[ end trace d549158f7aadbc1f ]---
> Kernel panic - not syncing: Fatal exception
> ------------[ cut here ]------------
> WARNING: CPU: 2 PID: 5279 at arch/x86/kernel/smp.c:127
> native_smp_send_reschedule+0x80/0xa0 arch/x86/kernel/smp.c:127
> Shutting down cpus with NMI
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
