From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Potential race in ip4_datagram_release_cb
Date: Fri, 06 Jun 2014 05:56:15 -0700
Message-ID: <1402059375.3645.284.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Alexey Preobrazhensky <preobr@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:34403 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbaFFM4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 08:56:17 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so2443673pbb.25
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 05:56:17 -0700 (PDT)
In-Reply-To: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-06 at 15:29 +0400, Alexey Preobrazhensky wrote:
> Hello,
>=20
> I=E2=80=99m working on AddressSanitizer[1] -- a tool that detects
> use-after-free and out-of-bounds bugs in kernel.
>=20
> We=E2=80=99ve encountered a heap-use-after-free in ip4_datagram_relea=
se_cb()
> in linux kernel 3.15-rc5 (revision
> 60b5f90d0fac7585f1a43ccdad06787b97eda0ab).
>=20
> It seems to be a race between dst_release() and
> ip4_datagram_release_cb() on an object from ip_dst_cache slab, all
> during the ip4_datagram_connect() call.
>=20
> This heap-use-after-free was triggered under trinity syscall fuzzer,
> so there is no reproducer.
>=20
> It would be great if someone familiar with the code took time to look
> into this report.
>=20
> Thanks,
>  Alexey
>=20
> [1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizer=
=46orKernel
>=20
>=20
> AddressSanitizer: heap-use-after-free in ipv4_dst_check
> Read of size 2 by thread T15453:
>  [<ffffffff817daa3a>] ipv4_dst_check+0x1a/0x90 ./net/ipv4/route.c:111=
6
>  [<ffffffff8175b789>] __sk_dst_check+0x89/0xe0 ./net/core/sock.c:531
>  [<ffffffff81830a36>] ip4_datagram_release_cb+0x46/0x390 ??:0
>  [<ffffffff8175eaea>] release_sock+0x17a/0x230 ./net/core/sock.c:2413
>  [<ffffffff81830882>] ip4_datagram_connect+0x462/0x5d0 ??:0
>  [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_inet=
=2Ec:534
>  [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:1701
>  [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
>  [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
> ./arch/x86/kernel/entry_64.S:629
>=20
> Freed by thread T15455:
>  [<ffffffff8178d9b8>] dst_destroy+0xa8/0x160 ./net/core/dst.c:251
>  [<ffffffff8178de25>] dst_release+0x45/0x80 ./net/core/dst.c:280
>  [<ffffffff818304c1>] ip4_datagram_connect+0xa1/0x5d0 ??:0
>  [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_inet=
=2Ec:534
>  [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:1701
>  [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
>  [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
> ./arch/x86/kernel/entry_64.S:629
>=20
> Allocated by thread T15453:
>  [<ffffffff8178d291>] dst_alloc+0x81/0x2b0 ./net/core/dst.c:171
>  [<ffffffff817db3b7>] rt_dst_alloc+0x47/0x50 ./net/ipv4/route.c:1406
>  [<     inlined    >] __ip_route_output_key+0x3e8/0xf70
> __mkroute_output ./net/ipv4/route.c:1939
>  [<ffffffff817dde08>] __ip_route_output_key+0x3e8/0xf70 ./net/ipv4/ro=
ute.c:2161
>  [<ffffffff817deb34>] ip_route_output_flow+0x14/0x30 ./net/ipv4/route=
=2Ec:2249
>  [<ffffffff81830737>] ip4_datagram_connect+0x317/0x5d0 ??:0
>  [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_inet=
=2Ec:534
>  [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:1701
>  [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
>  [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
> ./arch/x86/kernel/entry_64.S:629
>=20
> The buggy address ffff880024ff2266 is located 102 bytes inside
>  of 192-byte region [ffff880024ff2200, ffff880024ff22c0)
>=20
> Memory state around the buggy address:
>  ffff880024ff1d00: ffffffff fffrrrrr rrrrrrrr rrrrrrrr
>  ffff880024ff1e00: ffffffff ffffffff ffffffff fffrrrrr
>  ffff880024ff1f00: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
>  ffff880024ff2000: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
>  ffff880024ff2100: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
> >ffff880024ff2200: ffffffff ffffffff ffffffff rrrrrrrr
>                                 ^
>  ffff880024ff2300: rrrrrrrr rrrrrrrr ........ ........
>  ffff880024ff2400: ........ rrrrrrrr rrrrrrrr rrrrrrrr
>  ffff880024ff2500: ffffffff ffffffff ffffffff rrrrrrrr
>  ffff880024ff2600: rrrrrrrr rrrrrrrr ffffffff ffffffff
>  ffff880024ff2700: ffffffff rrrrrrrr rrrrrrrr rrrrrrrr
> Legend:
>  f - 8 freed bytes
>  r - 8 redzone bytes
>  . - 8 allocated bytes
>  x=3D1..7 - x allocated bytes + (8-x) redzone bytes
> --


Yeah, we had many reports in the past that something was wrong ...

Your nice report made me take a look, finally :(

Problem comes from

net/ipv4/udp.c:1008:                    sk_dst_set(sk, dst_clone(&rt->d=
st));

Could you try following patch ?

Thanks !

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4468e1adc094..d5e68ee63b8f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1004,8 +1004,11 @@ int udp_sendmsg(struct kiocb *iocb, struct sock =
*sk, struct msghdr *msg,
 		if ((rt->rt_flags & RTCF_BROADCAST) &&
 		    !sock_flag(sk, SOCK_BROADCAST))
 			goto out;
-		if (connected)
-			sk_dst_set(sk, dst_clone(&rt->dst));
+		if (connected) {
+			spin_lock_bh(&sk->sk_lock.slock);
+			__sk_dst_set(sk, dst_clone(&rt->dst));
+			spin_unlock_bh(&sk->sk_lock.slock);
+		}
 	}
=20
 	if (msg->msg_flags&MSG_CONFIRM)
