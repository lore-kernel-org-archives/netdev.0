From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] ipv6: ensure message length for raw socket is at least sizeof(ipv6hdr)
Date: Wed, 26 Apr 2017 15:00:15 +0200
Message-ID: <CAG_fn=U--Ctc7mzy6J7Cvzie-ieysco0mWnPP8H+L_BO=Ci+-Q@mail.gmail.com>
References: <20170425131827.66498-1-glider@google.com> <20170425.135543.1706004185593424024.davem@davemloft.net>
 <CAG_fn=Xw-WTn4AsyNaaLMRaW1xqo1QOyp7JpYOW=z+hqpWdwLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        LKML <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:36565 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2993739AbdDZNAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:00:17 -0400
Received: by mail-qt0-f175.google.com with SMTP id g60so165265325qtd.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 06:00:16 -0700 (PDT)
In-Reply-To: <CAG_fn=Xw-WTn4AsyNaaLMRaW1xqo1QOyp7JpYOW=z+hqpWdwLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 10:54 AM, Alexander Potapenko <glider@google.com> w=
rote:
> On Tue, Apr 25, 2017 at 7:55 PM, David Miller <davem@davemloft.net> wrote=
:
>> From: Alexander Potapenko <glider@google.com>
>> Date: Tue, 25 Apr 2017 15:18:27 +0200
>>
>>> rawv6_send_hdrinc() expects that the buffer copied from the userspace
>>> contains the IPv6 header, so if too few bytes are copied parts of the
>>> header may remain uninitialized.
>>>
>>> This bug has been detected with KMSAN.
>>>
>>> Signed-off-by: Alexander Potapenko <glider@google.com>
>>
>> Hmmm, ipv4 seems to lack this check as well.
>>
>> I think we need to be careful here and fully understand why KMSAN doesn'=
t
>> seem to be triggering in the ipv4 case but for ipv6 it is before I apply
>> this.
> Maybe I just couldn't come up with a decent test case for ipv4 yet.
> syzkaller generated the equivalent of the following program for ipv6:
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> #define _GNU_SOURCE
>
> #include <netinet/in.h>
> #include <string.h>
> #include <sys/socket.h>
> #include <error.h>
>
> int main()
> {
>   int sock =3D socket(PF_INET6, SOCK_RAW, IPPROTO_RAW);
>   struct sockaddr_in6 dest_addr;
>   memset(&dest_addr, 0, sizeof(dest_addr));
>   dest_addr.sin6_family =3D AF_INET6;
>   inet_pton(AF_INET6, "ff00::", &dest_addr.sin6_addr);
>   int err =3D sendto(sock, 0, 0, 0, &dest_addr, sizeof(dest_addr));
>   if (err =3D=3D -1)
>     perror("sendto");
>   return 0;
> }
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> I attempted to replace INET6 and such with INET and provide a legal
> IPv4 address to inet_pton(), but couldn't trigger the warning.
syzkaller reports the following errors in the wild (although there's
no stable repro):

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BUG: KMSAN: use of unitialized memory in raw_send_hdrinc
net/ipv4/raw.c:407 [inline]
BUG: KMSAN: use of unitialized memory in raw_sendmsg+0x2c8b/0x3400
net/ipv4/raw.c:640
inter: 0
CPU: 3 PID: 2853 Comm: syz-executor1 Not tainted 4.11.0-rc5+ #2445
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/201=
1
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x143/0x1b0 lib/dump_stack.c:52
 kmsan_report+0x16b/0x1e0 mm/kmsan/kmsan.c:1078
 __kmsan_warning_32+0x5c/0xa0 mm/kmsan/kmsan_instr.c:510
 raw_send_hdrinc net/ipv4/raw.c:407 [inline]
 raw_sendmsg+0x2c8b/0x3400 net/ipv4/raw.c:640
 inet_sendmsg+0x3f8/0x6d0 net/ipv4/af_inet.c:762
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg net/socket.c:643 [inline]
 ___sys_sendmsg+0xd4b/0x10f0 net/socket.c:1997
 __sys_sendmsg net/socket.c:2031 [inline]
 SYSC_sendmsg+0x2c6/0x3f0 net/socket.c:2042
 SyS_sendmsg+0x87/0xb0 net/socket.c:2038
 entry_SYSCALL_64_fastpath+0x13/0x94
RIP: 0033:0x44a669
RSP: 002b:00007f08d06edb58 EFLAGS: 00000286 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 000000000044a669
RDX: 0000000000000000 RSI: 0000000020007fc8 RDI: 0000000000000017
RBP: 0000000000005080 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 00000000006e4140
R13: 0000000020b22000 R14: 0000000000000000 R15: 0000000000000000
origin: 00000000cb200085
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 kmsan_save_stack_with_flags mm/kmsan/kmsan.c:362 [inline]
 kmsan_internal_poison_shadow+0xb1/0x1a0 mm/kmsan/kmsan.c:257
 kmsan_poison_shadow+0x6d/0xc0 mm/kmsan/kmsan.c:270
 slab_alloc_node mm/slub.c:2735 [inline]
 __kmalloc_node_track_caller+0x1f4/0x390 mm/slub.c:4341
 __kmalloc_reserve net/core/skbuff.c:138 [inline]
 __alloc_skb+0x2cd/0x740 net/core/skbuff.c:231
 alloc_skb include/linux/skbuff.h:933 [inline]
 alloc_skb_with_frags+0x209/0xbc0 net/core/skbuff.c:4678
 sock_alloc_send_pskb+0x9ff/0xe00 net/core/sock.c:1903
 sock_alloc_send_skb+0xe4/0x100 net/core/sock.c:1920
 raw_send_hdrinc net/ipv4/raw.c:366 [inline]
 raw_sendmsg+0x1db4/0x3400 net/ipv4/raw.c:640
 inet_sendmsg+0x3f8/0x6d0 net/ipv4/af_inet.c:762
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg net/socket.c:643 [inline]
 ___sys_sendmsg+0xd4b/0x10f0 net/socket.c:1997
 __sys_sendmsg net/socket.c:2031 [inline]
 SYSC_sendmsg+0x2c6/0x3f0 net/socket.c:2042
 SyS_sendmsg+0x87/0xb0 net/socket.c:2038
 entry_SYSCALL_64_fastpath+0x13/0x94
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D


>
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
