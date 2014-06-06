From: Alexey Preobrazhensky <preobr@google.com>
Subject: Potential race in ip4_datagram_release_cb
Date: Fri, 6 Jun 2014 15:29:29 +0400
Message-ID: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:54096 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbaFFLaK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 07:30:10 -0400
Received: by mail-vc0-f182.google.com with SMTP id il7so2802738vcb.13
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 04:30:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I=E2=80=99m working on AddressSanitizer[1] -- a tool that detects
use-after-free and out-of-bounds bugs in kernel.

We=E2=80=99ve encountered a heap-use-after-free in ip4_datagram_release=
_cb()
in linux kernel 3.15-rc5 (revision
60b5f90d0fac7585f1a43ccdad06787b97eda0ab).

It seems to be a race between dst_release() and
ip4_datagram_release_cb() on an object from ip_dst_cache slab, all
during the ip4_datagram_connect() call.

This heap-use-after-free was triggered under trinity syscall fuzzer,
so there is no reproducer.

It would be great if someone familiar with the code took time to look
into this report.

Thanks,
 Alexey

[1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerFo=
rKernel


AddressSanitizer: heap-use-after-free in ipv4_dst_check
Read of size 2 by thread T15453:
 [<ffffffff817daa3a>] ipv4_dst_check+0x1a/0x90 ./net/ipv4/route.c:1116
 [<ffffffff8175b789>] __sk_dst_check+0x89/0xe0 ./net/core/sock.c:531
 [<ffffffff81830a36>] ip4_datagram_release_cb+0x46/0x390 ??:0
 [<ffffffff8175eaea>] release_sock+0x17a/0x230 ./net/core/sock.c:2413
 [<ffffffff81830882>] ip4_datagram_connect+0x462/0x5d0 ??:0
 [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_inet.c=
:534
 [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:1701
 [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
 [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
=2E/arch/x86/kernel/entry_64.S:629

=46reed by thread T15455:
 [<ffffffff8178d9b8>] dst_destroy+0xa8/0x160 ./net/core/dst.c:251
 [<ffffffff8178de25>] dst_release+0x45/0x80 ./net/core/dst.c:280
 [<ffffffff818304c1>] ip4_datagram_connect+0xa1/0x5d0 ??:0
 [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_inet.c=
:534
 [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:1701
 [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
 [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
=2E/arch/x86/kernel/entry_64.S:629

Allocated by thread T15453:
 [<ffffffff8178d291>] dst_alloc+0x81/0x2b0 ./net/core/dst.c:171
 [<ffffffff817db3b7>] rt_dst_alloc+0x47/0x50 ./net/ipv4/route.c:1406
 [<     inlined    >] __ip_route_output_key+0x3e8/0xf70
__mkroute_output ./net/ipv4/route.c:1939
 [<ffffffff817dde08>] __ip_route_output_key+0x3e8/0xf70 ./net/ipv4/rout=
e.c:2161
 [<ffffffff817deb34>] ip_route_output_flow+0x14/0x30 ./net/ipv4/route.c=
:2249
 [<ffffffff81830737>] ip4_datagram_connect+0x317/0x5d0 ??:0
 [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_inet.c=
:534
 [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:1701
 [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
 [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
=2E/arch/x86/kernel/entry_64.S:629

The buggy address ffff880024ff2266 is located 102 bytes inside
 of 192-byte region [ffff880024ff2200, ffff880024ff22c0)

Memory state around the buggy address:
 ffff880024ff1d00: ffffffff fffrrrrr rrrrrrrr rrrrrrrr
 ffff880024ff1e00: ffffffff ffffffff ffffffff fffrrrrr
 ffff880024ff1f00: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
 ffff880024ff2000: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
 ffff880024ff2100: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
>ffff880024ff2200: ffffffff ffffffff ffffffff rrrrrrrr
                                ^
 ffff880024ff2300: rrrrrrrr rrrrrrrr ........ ........
 ffff880024ff2400: ........ rrrrrrrr rrrrrrrr rrrrrrrr
 ffff880024ff2500: ffffffff ffffffff ffffffff rrrrrrrr
 ffff880024ff2600: rrrrrrrr rrrrrrrr ffffffff ffffffff
 ffff880024ff2700: ffffffff rrrrrrrr rrrrrrrr rrrrrrrr
Legend:
 f - 8 freed bytes
 r - 8 redzone bytes
 . - 8 allocated bytes
 x=3D1..7 - x allocated bytes + (8-x) redzone bytes
