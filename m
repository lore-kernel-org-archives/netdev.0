From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: general protection fault in deactivate_slab
Date: Tue, 6 Jun 2017 13:24:18 +0200
Message-ID: <CAAeHK+zKNPf+COtdjRsEKwKKRLDGM0bz-0LyKyf6HfxpG69rYg@mail.gmail.com>
References: <CACbyUSpzod2_9-gZNtMqr=Zh3kaY-9dsREP-fdjHp+cz0PWoyw@mail.gmail.com>
 <CAAeHK+zvLUfKzorLSi7upEvH9Y3VXqFVpNCPY3kEEBQuHLGR+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Gene Blue <geneblue.mail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f182.google.com ([209.85.213.182]:33838 "EHLO
        mail-yb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751384AbdFFLYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 07:24:20 -0400
Received: by mail-yb0-f182.google.com with SMTP id 4so14521796ybl.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 04:24:20 -0700 (PDT)
In-Reply-To: <CAAeHK+zvLUfKzorLSi7upEvH9Y3VXqFVpNCPY3kEEBQuHLGR+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 6, 2017 at 1:00 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Tue, Jun 6, 2017 at 12:30 PM, Gene Blue <geneblue.mail@gmail.com> wrote:
>> Hi:
>>   I got this crash when fuzzing the kernel with syzkaller.
>>
>>   My kernel version is  4.11.0-rc1 directly download from kernel.org.
>>
>>   And this crash is reproducible. Three times in total during the period of
>> fuzzing.
>
> Hi!
>
> This has already been reported and fixed:
> https://groups.google.com/forum/#!topic/syzkaller/e3I2c8X2oWo
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=232cd35d0804cc241eb887bb8d4d9b3b9881c64a

Apparently I was wrong, this is actually a different bug, the stack
trace just looks similar. I got the same report once on 4.12-rc3 which
has "ipv6: fix out of bound writes in __ip6_append_data()".

kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 1 PID: 32220 Comm: syz-executor6 Not tainted 4.12.0-rc3+ #3
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880037009700 task.stack: ffff880026ae0000
RIP: 0010:get_freepointer mm/slub.c:243 [inline]
RIP: 0010:deactivate_slab+0x63/0x5f0 mm/slub.c:2020
RSP: 0018:ffff880026ae6f40 EFLAGS: 00010006
RAX: 0000000000000000 RBX: ffffea0000e09400 RCX: 0000000000000000
RDX: 00e906298e83888b RSI: ffffea0000e09400 RDI: ffff88003e80cf40
RBP: ffff880026ae7000 R08: ffff880038253818 R09: ffff880038254018
R10: ffff880026ae7020 R11: 0000000000000001 R12: 0000000000000000
R13: 00e906298e83888b R14: ffff88003e80cf40 R15: ffff88003e80cf40
FS:  00007f34fa033700(0000) GS:ffff88003ed00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f34fa032db8 CR3: 00000000388b2000 CR4: 00000000000006e0
Call Trace:
 ___slab_alloc+0x4f0/0x550 mm/slub.c:2595
 __slab_alloc+0x51/0x90 mm/slub.c:2621
 slab_alloc_node mm/slub.c:2684 [inline]
 __kmalloc_node_track_caller+0x179/0x360 mm/slub.c:4303
 __kmalloc_reserve.isra.32+0x46/0xe0 net/core/skbuff.c:138
 __alloc_skb+0x15c/0x770 net/core/skbuff.c:231
 alloc_skb include/linux/skbuff.h:936 [inline]
 sock_wmalloc+0x156/0x1f0 net/core/sock.c:1879
 __ip_append_data.isra.48+0x1e43/0x2d80 net/ipv4/ip_output.c:1041
bond0: bcsf0 ether type (3) is different from other slaves (1), can
not enslave it
 ip_append_data.part.49+0xe3/0x160 net/ipv4/ip_output.c:1235
 ip_append_data+0x5f/0x80 net/ipv4/ip_output.c:1224
 udp_sendmsg+0x10ae/0x2ce0 net/ipv4/udp.c:1073
 inet_sendmsg+0x169/0x5c0 net/ipv4/af_inet.c:762
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xcf/0x110 net/socket.c:643
 ___sys_sendmsg+0x98a/0xa90 net/socket.c:1997
bond0: bcsf0 ether type (3) is different from other slaves (1), can
not enslave it
 __sys_sendmsg+0x13d/0x320 net/socket.c:2031
sctp: [Deprecated]: syz-executor7 (pid 32255) Use of struct
sctp_assoc_value in delayed_ack socket option.
Use struct sctp_sack_info instead
 SYSC_sendmsg net/socket.c:2042 [inline]
 SyS_sendmsg+0x32/0x50 net/socket.c:2038
sctp: [Deprecated]: syz-executor7 (pid 32255) Use of struct
sctp_assoc_value in delayed_ack socket option.
Use struct sctp_sack_info instead
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x446179
RSP: 002b:00007f34fa032c08 EFLAGS: 00000282 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 00000000000042a0 RCX: 0000000000446179
RDX: 0000000000000800 RSI: 0000000020760000 RDI: 0000000000000005
RBP: 00000000ffffffff R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000282 R12: 0000000000000005
R13: 0000000000000000 R14: 00007f34fa0339c0 R15: 00007f34fa033700
Code: 3a 48 8b 84 c7 d0 00 00 00 48 89 45 88 31 c0 4d 85 e4 0f 95 c0
83 c0 0f 48 85 d2 89 45 80 0f 84 7a 05 00 00 48 63 47 20 49 89 d5 <4c>
8b 34 02 4c 89 e2 4d 85 f6 0f 84 6b 05 00 00 48 8b 4b 18 49
RIP: get_freepointer mm/slub.c:243 [inline] RSP: ffff880026ae6f40
RIP: deactivate_slab+0x63/0x5f0 mm/slub.c:2020 RSP: ffff880026ae6f40
sctp: [Deprecated]: syz-executor7 (pid 32258) Use of struct
sctp_assoc_value in delayed_ack socket option.
Use struct sctp_sack_info instead
---[ end trace 743c7af6619c952b ]---
Kernel panic - not syncing: Fatal exception
sctp: [Deprecated]: syz-executor7 (pid 32258) Use of struct
sctp_assoc_value in delayed_ack socket option.
Use struct sctp_sack_info instead
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..


>
> I've added a note about checking whether the bug was reported
> previously to syzkaller wiki:
> https://github.com/google/syzkaller/wiki/Reporting-kernel-bugs
>
> Thanks!
>
>>
>>
>> **********************************************************************
>> kasan: GPF could be caused by NULL-ptr deref or user memory access
>> general protection fault: 0000 [#1] SMP KASAN
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Modules linked in:
>> CPU: 3 PID: 5291 Comm: syz-executor3 Not tainted 4.11.0-rc1 #7
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> task: ffff88003cc82dc0 task.stack: ffff88003df10000
>> RIP: 0010:get_freepointer mm/slub.c:243 [inline]
>> RIP: 0010:deactivate_slab+0xa8/0x550 mm/slub.c:2020
>> RSP: 0018:ffff88003df17250 EFLAGS: 00010002
>> RAX: 0000000000000001 RBX: ffff88003e80ed40 RCX: 0000000000000000
>> RDX: ffff88006d66d6c0 RSI: 0000000000000000 RDI: ffffea0001b59a00
>> RBP: ffff88003df17348 R08: 0000000000008000 R09: 0000000000008007
>> R10: ffff88006d66b410 R11: ffff88006d669018 R12: ffff88003e80ed48
>> R13: 2bcbe23c521cd9a5 R14: 2bcbe23c521cd9a5 R15: ffffea0001b59a00
>> FS:  00007fb559210700(0000) GS:ffff88006e300000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 0000000020e76fc8 CR3: 000000003c2c0000 CR4: 00000000000006e0
>> Call Trace:
>>  ___slab_alloc+0x199/0x5d0 mm/slub.c:2595
>>  __slab_alloc+0x4c/0x90 mm/slub.c:2621
>>  slab_alloc_node mm/slub.c:2684 [inline]
>>  __kmalloc_node_track_caller+0xa7/0x3a0 mm/slub.c:4303
>>  __kmalloc_reserve.isra.37+0x41/0xe0 net/core/skbuff.c:138
>>  __alloc_skb+0xf0/0x590 net/core/skbuff.c:231
>>  alloc_skb include/linux/skbuff.h:933 [inline]
>>  alloc_skb_with_frags+0xae/0x510 net/core/skbuff.c:4661
>>  sock_alloc_send_pskb+0x5e5/0x750 net/core/sock.c:1892
>>  sock_alloc_send_skb+0x32/0x40 net/core/sock.c:1909
>>  __ip6_append_data.isra.43+0x2058/0x3560 net/ipv6/ip6_output.c:1462
>>  ip6_append_data+0x1d1/0x310 net/ipv6/ip6_output.c:1628
>>  udpv6_sendmsg+0x1339/0x2550 net/ipv6/udp.c:1264
>>  inet_sendmsg+0x129/0x530 net/ipv4/af_inet.c:761
>>  sock_sendmsg_nosec net/socket.c:633 [inline]
>>  sock_sendmsg+0xcc/0x110 net/socket.c:643
>>  SYSC_sendto+0x211/0x340 net/socket.c:1685
>>  SyS_sendto+0x40/0x50 net/socket.c:1653
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>> RIP: 0033:0x4458d9
>> RSP: 002b:00007fb55920fb58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
>> RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 00000000004458d9
>> RDX: 0000000000000746 RSI: 0000000020e7a8ba RDI: 0000000000000006
>> RBP: 0000000000000046 R08: 0000000020e78000 R09: 000000000000001c
>> R10: 0000000000008800 R11: 0000000000000282 R12: 00000000006df570
>> R13: 0000000000000006 R14: 0000000000000005 R15: 0000000000000000
>> Code: 8b 57 10 49 8b 4f 18 49 89 54 35 00 48 89 4c 24 68 66 83 6c 24 68 01
>> 80 7c 24 6b 00 78 c6 0f 0b 48 63 73 20 49 8b 57 10 4d 89 f5 <49> 8b 3c 36 48
>> 85 ff 74 05 49 89 fe eb ca 4c 8b 5c 24 48 4d 8d
>> RIP: get_freepointer mm/slub.c:243 [inline] RSP: ffff88003df17250
>> RIP: deactivate_slab+0xa8/0x550 mm/slub.c:2020 RSP: ffff88003df17250
>> ---[ end trace d549158f7aadbc1f ]---
>> Kernel panic - not syncing: Fatal exception
>> ------------[ cut here ]------------
>> WARNING: CPU: 2 PID: 5279 at arch/x86/kernel/smp.c:127
>> native_smp_send_reschedule+0x80/0xa0 arch/x86/kernel/smp.c:127
>> Shutting down cpus with NMI
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Kernel Offset: disabled
>> Rebooting in 86400 seconds..
>>
