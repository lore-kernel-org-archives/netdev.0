From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Potential race in ip4_datagram_release_cb
Date: Fri, 06 Jun 2014 09:16:07 -0700
Message-ID: <1402071367.3645.305.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	 <1402059375.3645.284.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQL=D_KF2iRLO1Ufoih3Rg-WtSA9UYuU0OjOZebGBryVHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Preobrazhensky <preobr@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	dormando <dormando@rydia.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:50387 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbaFFQQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 12:16:09 -0400
Received: by mail-pb0-f44.google.com with SMTP id rq2so2669970pbb.3
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 09:16:08 -0700 (PDT)
In-Reply-To: <CAADnVQL=D_KF2iRLO1Ufoih3Rg-WtSA9UYuU0OjOZebGBryVHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-06 at 08:59 -0700, Alexei Starovoitov wrote:
> On Fri, Jun 6, 2014 at 5:56 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > On Fri, 2014-06-06 at 15:29 +0400, Alexey Preobrazhensky wrote:
> >> Hello,
> >>
> >> I=E2=80=99m working on AddressSanitizer[1] -- a tool that detects
> >> use-after-free and out-of-bounds bugs in kernel.
> >>
> >> We=E2=80=99ve encountered a heap-use-after-free in ip4_datagram_re=
lease_cb()
> >> in linux kernel 3.15-rc5 (revision
> >> 60b5f90d0fac7585f1a43ccdad06787b97eda0ab).
> >>
> >> It seems to be a race between dst_release() and
> >> ip4_datagram_release_cb() on an object from ip_dst_cache slab, all
> >> during the ip4_datagram_connect() call.
> >>
> >> This heap-use-after-free was triggered under trinity syscall fuzze=
r,
> >> so there is no reproducer.
> >>
> >> It would be great if someone familiar with the code took time to l=
ook
> >> into this report.
> >>
> >> Thanks,
> >>  Alexey
> >>
> >> [1] https://code.google.com/p/address-sanitizer/wiki/AddressSaniti=
zerForKernel
> >>
> >>
> >> AddressSanitizer: heap-use-after-free in ipv4_dst_check
> >> Read of size 2 by thread T15453:
> >>  [<ffffffff817daa3a>] ipv4_dst_check+0x1a/0x90 ./net/ipv4/route.c:=
1116
> >>  [<ffffffff8175b789>] __sk_dst_check+0x89/0xe0 ./net/core/sock.c:5=
31
> >>  [<ffffffff81830a36>] ip4_datagram_release_cb+0x46/0x390 ??:0
> >>  [<ffffffff8175eaea>] release_sock+0x17a/0x230 ./net/core/sock.c:2=
413
> >>  [<ffffffff81830882>] ip4_datagram_connect+0x462/0x5d0 ??:0
> >>  [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_i=
net.c:534
> >>  [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:1701
> >>  [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
> >>  [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
> >> ./arch/x86/kernel/entry_64.S:629
> >>
> >> Freed by thread T15455:
> >>  [<ffffffff8178d9b8>] dst_destroy+0xa8/0x160 ./net/core/dst.c:251
> >>  [<ffffffff8178de25>] dst_release+0x45/0x80 ./net/core/dst.c:280
> >>  [<ffffffff818304c1>] ip4_datagram_connect+0xa1/0x5d0 ??:0
> >>  [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_i=
net.c:534
> >>  [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:1701
> >>  [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
> >>  [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
> >> ./arch/x86/kernel/entry_64.S:629
> >>
> >> Allocated by thread T15453:
> >>  [<ffffffff8178d291>] dst_alloc+0x81/0x2b0 ./net/core/dst.c:171
> >>  [<ffffffff817db3b7>] rt_dst_alloc+0x47/0x50 ./net/ipv4/route.c:14=
06
> >>  [<     inlined    >] __ip_route_output_key+0x3e8/0xf70
> >> __mkroute_output ./net/ipv4/route.c:1939
> >>  [<ffffffff817dde08>] __ip_route_output_key+0x3e8/0xf70 ./net/ipv4=
/route.c:2161
> >>  [<ffffffff817deb34>] ip_route_output_flow+0x14/0x30 ./net/ipv4/ro=
ute.c:2249
> >>  [<ffffffff81830737>] ip4_datagram_connect+0x317/0x5d0 ??:0
> >>  [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_i=
net.c:534
> >>  [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:1701
> >>  [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
> >>  [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
> >> ./arch/x86/kernel/entry_64.S:629
> >>
> >> The buggy address ffff880024ff2266 is located 102 bytes inside
> >>  of 192-byte region [ffff880024ff2200, ffff880024ff22c0)
> >>
> >> Memory state around the buggy address:
> >>  ffff880024ff1d00: ffffffff fffrrrrr rrrrrrrr rrrrrrrr
> >>  ffff880024ff1e00: ffffffff ffffffff ffffffff fffrrrrr
> >>  ffff880024ff1f00: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
> >>  ffff880024ff2000: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
> >>  ffff880024ff2100: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
> >> >ffff880024ff2200: ffffffff ffffffff ffffffff rrrrrrrr
> >>                                 ^
> >>  ffff880024ff2300: rrrrrrrr rrrrrrrr ........ ........
> >>  ffff880024ff2400: ........ rrrrrrrr rrrrrrrr rrrrrrrr
> >>  ffff880024ff2500: ffffffff ffffffff ffffffff rrrrrrrr
> >>  ffff880024ff2600: rrrrrrrr rrrrrrrr ffffffff ffffffff
> >>  ffff880024ff2700: ffffffff rrrrrrrr rrrrrrrr rrrrrrrr
> >> Legend:
> >>  f - 8 freed bytes
> >>  r - 8 redzone bytes
> >>  . - 8 allocated bytes
> >>  x=3D1..7 - x allocated bytes + (8-x) redzone bytes
> >> --
> >
> >
> > Yeah, we had many reports in the past that something was wrong ...
> >
> > Your nice report made me take a look, finally :(
> >
> > Problem comes from
> >
> > net/ipv4/udp.c:1008:                    sk_dst_set(sk, dst_clone(&r=
t->dst));
> >
> > Could you try following patch ?
> >
> > Thanks !
> >
> > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > index 4468e1adc094..d5e68ee63b8f 100644
> > --- a/net/ipv4/udp.c
> > +++ b/net/ipv4/udp.c
> > @@ -1004,8 +1004,11 @@ int udp_sendmsg(struct kiocb *iocb, struct s=
ock *sk, struct msghdr *msg,
> >                 if ((rt->rt_flags & RTCF_BROADCAST) &&
> >                     !sock_flag(sk, SOCK_BROADCAST))
> >                         goto out;
> > -               if (connected)
> > -                       sk_dst_set(sk, dst_clone(&rt->dst));
> > +               if (connected) {
> > +                       spin_lock_bh(&sk->sk_lock.slock);
> > +                       __sk_dst_set(sk, dst_clone(&rt->dst));
> > +                       spin_unlock_bh(&sk->sk_lock.slock);
> > +               }
>=20
> Nice catch.
> Should then we change sk_dst_set() itself to do spin_lock_bh uncondit=
ionally?
> Seems overhead is smaller, than checking all possible callsites manua=
lly.
>=20
> cc-ing Dormando as well.


Real problem is that sk_dst_set() uses a different lock. I never
understood how this was supposed to work.

We should either :

1) use xchg() and no lock at all to change sk_dst_cache, as we did for
sk_rx_dst ( cf udp_sk_rx_dst_set() )

2) No longer use sk_dst_lock, and always use the socket lock
(sk->sk_lock.slock) instead.
