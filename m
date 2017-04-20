From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/xfrm: stack-out-of-bounds in xfrm_state_find
Date: Thu, 20 Apr 2017 19:30:27 +0200
Message-ID: <CAAeHK+yAwS0ttN3hQFTgc8AyBx93UGtFm_nJUky0wKR+K6BRRg@mail.gmail.com>
References: <CAAeHK+xGJF-at3B6qRb8TFqCgufpus4USu8m4tXFJKo7UsFZiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f169.google.com ([209.85.213.169]:32987 "EHLO
        mail-yb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943101AbdDTRa3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 13:30:29 -0400
Received: by mail-yb0-f169.google.com with SMTP id 81so33634058ybp.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 10:30:29 -0700 (PDT)
In-Reply-To: <CAAeHK+xGJF-at3B6qRb8TFqCgufpus4USu8m4tXFJKo7UsFZiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 6:47 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On linux-next commit 4f7d029b9bf009fbee76bb10c0c4351a1870d2f3 (4.11-rc7).
>
> A reproducer and .config are attached.
>
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in xfrm_state_find+0x2ce7/0x2f70 at
> addr ffff88006654f790
> Read of size 4 by task a.out/4065
> page:ffffea00019953c0 count:0 mapcount:0 mapping:          (null) index:0x0
> flags: 0x100000000000000()
> raw: 0100000000000000 0000000000000000 0000000000000000 00000000ffffffff
> raw: 0000000000000000 ffffea00019953e0 0000000000000000 0000000000000000
> page dumped because: kasan: bad access detected
> CPU: 1 PID: 4065 Comm: a.out Not tainted 4.11.0-rc7+ #251
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16
>  dump_stack+0x292/0x398 lib/dump_stack.c:52
>  kasan_report_error mm/kasan/report.c:212
>  kasan_report+0x4d8/0x510 mm/kasan/report.c:347
>  __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:367
>  xfrm_state_find+0x2ce7/0x2f70 net/xfrm/xfrm_state.c:897

I'm not sure if the line numbers in the report are correct.

My guess is that the guilty line is actually this one:

h = xfrm_dst_hash(net, daddr, saddr, tmpl->reqid, encap_family);

but I might be wrong.

>  xfrm_tmpl_resolve_one net/xfrm/xfrm_policy.c:1470
>  xfrm_tmpl_resolve+0x308/0xc90 net/xfrm/xfrm_policy.c:1514
>  xfrm_resolve_and_create_bundle+0x16e/0x2590 net/xfrm/xfrm_policy.c:1889
>  xfrm_lookup+0xd72/0x1170 net/xfrm/xfrm_policy.c:2253
>  xfrm_lookup_route+0x39/0x1a0 net/xfrm/xfrm_policy.c:2375
>  ip_route_output_flow+0x7f/0xa0 net/ipv4/route.c:2483
>  udp_sendmsg+0x1565/0x2cd0 net/ipv4/udp.c:1015
>  udpv6_sendmsg+0x8af/0x3500 net/ipv6/udp.c:1083
>  inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:762
>  sock_sendmsg_nosec net/socket.c:633
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  SYSC_sendto+0x660/0x810 net/socket.c:1696
>  SyS_sendto+0x40/0x50 net/socket.c:1664
>  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:204
> RIP: 0033:0x7f3daefd0b79
> RSP: 002b:00007ffdb39bb0b8 EFLAGS: 00000206 ORIG_RAX: 000000000000002c
> RAX: ffffffffffffffda RBX: 00007ffdb39bb210 RCX: 00007f3daefd0b79
> RDX: 0000000000000000 RSI: 0000000020001000 RDI: 0000000000000003
> RBP: 00000000004004a0 R08: 0000000020013ff0 R09: 0000000000000010
> R10: 0000000020000000 R11: 0000000000000206 R12: 0000000000000000
> R13: 00007ffdb39bb210 R14: 0000000000000000 R15: 0000000000000000
> Memory state around the buggy address:
>  ffff88006654f680: f1 f1 f1 00 f2 f2 f2 f2 f2 f2 f2 f8 f2 f2 f2 f2
>  ffff88006654f700: f2 f2 f2 00 00 00 00 f2 f2 f2 f2 00 00 00 00 00
>>ffff88006654f780: 00 00 f2 f2 f2 f2 f2 00 00 00 00 00 00 00 00 00
>                          ^
>  ffff88006654f800: f2 f2 f2 f3 f3 f3 f3 00 00 00 00 00 00 00 00 00
>  ffff88006654f880: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ==================================================================
