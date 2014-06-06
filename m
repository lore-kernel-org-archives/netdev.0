From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Potential race in ip4_datagram_release_cb
Date: Fri, 6 Jun 2014 10:44:02 -0700
Message-ID: <CAADnVQL47b+nFo+WUJGw=oCEVwRHtK98poe8SJqw4F-jAUXoyw@mail.gmail.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	<1402059375.3645.284.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQL=D_KF2iRLO1Ufoih3Rg-WtSA9UYuU0OjOZebGBryVHA@mail.gmail.com>
	<1402071367.3645.305.camel@edumazet-glaptop2.roam.corp.google.com>
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
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	dormando <dormando@rydia.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:45423 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbaFFRoE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 13:44:04 -0400
Received: by mail-qg0-f45.google.com with SMTP id z60so5141482qgd.32
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 10:44:02 -0700 (PDT)
In-Reply-To: <1402071367.3645.305.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 6, 2014 at 9:16 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Fri, 2014-06-06 at 08:59 -0700, Alexei Starovoitov wrote:
>> On Fri, Jun 6, 2014 at 5:56 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> > On Fri, 2014-06-06 at 15:29 +0400, Alexey Preobrazhensky wrote:
>> >> Hello,
>> >>
>> >> I=E2=80=99m working on AddressSanitizer[1] -- a tool that detects
>> >> use-after-free and out-of-bounds bugs in kernel.
>> >>
>> >> We=E2=80=99ve encountered a heap-use-after-free in ip4_datagram_r=
elease_cb()
>> >> in linux kernel 3.15-rc5 (revision
>> >> 60b5f90d0fac7585f1a43ccdad06787b97eda0ab).
>> >>
>> >> It seems to be a race between dst_release() and
>> >> ip4_datagram_release_cb() on an object from ip_dst_cache slab, al=
l
>> >> during the ip4_datagram_connect() call.
>> >>
>> >> This heap-use-after-free was triggered under trinity syscall fuzz=
er,
>> >> so there is no reproducer.
>> >>
>> >> It would be great if someone familiar with the code took time to =
look
>> >> into this report.
>> >>
>> >> Thanks,
>> >>  Alexey
>> >>
>> >> [1] https://code.google.com/p/address-sanitizer/wiki/AddressSanit=
izerForKernel
>> >>
>> >>
>> >> AddressSanitizer: heap-use-after-free in ipv4_dst_check
>> >> Read of size 2 by thread T15453:
>> >>  [<ffffffff817daa3a>] ipv4_dst_check+0x1a/0x90 ./net/ipv4/route.c=
:1116
>> >>  [<ffffffff8175b789>] __sk_dst_check+0x89/0xe0 ./net/core/sock.c:=
531
>> >>  [<ffffffff81830a36>] ip4_datagram_release_cb+0x46/0x390 ??:0
>> >>  [<ffffffff8175eaea>] release_sock+0x17a/0x230 ./net/core/sock.c:=
2413
>> >>  [<ffffffff81830882>] ip4_datagram_connect+0x462/0x5d0 ??:0
>> >>  [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_=
inet.c:534
>> >>  [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:170=
1
>> >>  [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
>> >>  [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
>> >> ./arch/x86/kernel/entry_64.S:629
>> >>
>> >> Freed by thread T15455:
>> >>  [<ffffffff8178d9b8>] dst_destroy+0xa8/0x160 ./net/core/dst.c:251
>> >>  [<ffffffff8178de25>] dst_release+0x45/0x80 ./net/core/dst.c:280
>> >>  [<ffffffff818304c1>] ip4_datagram_connect+0xa1/0x5d0 ??:0
>> >>  [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_=
inet.c:534
>> >>  [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:170=
1
>> >>  [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
>> >>  [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
>> >> ./arch/x86/kernel/entry_64.S:629
>> >>
>> >> Allocated by thread T15453:
>> >>  [<ffffffff8178d291>] dst_alloc+0x81/0x2b0 ./net/core/dst.c:171
>> >>  [<ffffffff817db3b7>] rt_dst_alloc+0x47/0x50 ./net/ipv4/route.c:1=
406
>> >>  [<     inlined    >] __ip_route_output_key+0x3e8/0xf70
>> >> __mkroute_output ./net/ipv4/route.c:1939
>> >>  [<ffffffff817dde08>] __ip_route_output_key+0x3e8/0xf70 ./net/ipv=
4/route.c:2161
>> >>  [<ffffffff817deb34>] ip_route_output_flow+0x14/0x30 ./net/ipv4/r=
oute.c:2249
>> >>  [<ffffffff81830737>] ip4_datagram_connect+0x317/0x5d0 ??:0
>> >>  [<ffffffff81846d06>] inet_dgram_connect+0x76/0xd0 ./net/ipv4/af_=
inet.c:534
>> >>  [<ffffffff817580ac>] SYSC_connect+0x15c/0x1c0 ./net/socket.c:170=
1
>> >>  [<ffffffff817596ce>] SyS_connect+0xe/0x10 ./net/socket.c:1682
>> >>  [<ffffffff818b0a29>] system_call_fastpath+0x16/0x1b
>> >> ./arch/x86/kernel/entry_64.S:629
>> >>
>> >> The buggy address ffff880024ff2266 is located 102 bytes inside
>> >>  of 192-byte region [ffff880024ff2200, ffff880024ff22c0)
>> >>
>> >> Memory state around the buggy address:
>> >>  ffff880024ff1d00: ffffffff fffrrrrr rrrrrrrr rrrrrrrr
>> >>  ffff880024ff1e00: ffffffff ffffffff ffffffff fffrrrrr
>> >>  ffff880024ff1f00: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
>> >>  ffff880024ff2000: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
>> >>  ffff880024ff2100: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
>> >> >ffff880024ff2200: ffffffff ffffffff ffffffff rrrrrrrr
>> >>                                 ^
>> >>  ffff880024ff2300: rrrrrrrr rrrrrrrr ........ ........
>> >>  ffff880024ff2400: ........ rrrrrrrr rrrrrrrr rrrrrrrr
>> >>  ffff880024ff2500: ffffffff ffffffff ffffffff rrrrrrrr
>> >>  ffff880024ff2600: rrrrrrrr rrrrrrrr ffffffff ffffffff
>> >>  ffff880024ff2700: ffffffff rrrrrrrr rrrrrrrr rrrrrrrr
>> >> Legend:
>> >>  f - 8 freed bytes
>> >>  r - 8 redzone bytes
>> >>  . - 8 allocated bytes
>> >>  x=3D1..7 - x allocated bytes + (8-x) redzone bytes
>> >> --
>> >
>> >
>> > Yeah, we had many reports in the past that something was wrong ...
>> >
>> > Your nice report made me take a look, finally :(
>> >
>> > Problem comes from
>> >
>> > net/ipv4/udp.c:1008:                    sk_dst_set(sk, dst_clone(&=
rt->dst));
>> >
>> > Could you try following patch ?
>> >
>> > Thanks !
>> >
>> > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> > index 4468e1adc094..d5e68ee63b8f 100644
>> > --- a/net/ipv4/udp.c
>> > +++ b/net/ipv4/udp.c
>> > @@ -1004,8 +1004,11 @@ int udp_sendmsg(struct kiocb *iocb, struct =
sock *sk, struct msghdr *msg,
>> >                 if ((rt->rt_flags & RTCF_BROADCAST) &&
>> >                     !sock_flag(sk, SOCK_BROADCAST))
>> >                         goto out;
>> > -               if (connected)
>> > -                       sk_dst_set(sk, dst_clone(&rt->dst));
>> > +               if (connected) {
>> > +                       spin_lock_bh(&sk->sk_lock.slock);
>> > +                       __sk_dst_set(sk, dst_clone(&rt->dst));
>> > +                       spin_unlock_bh(&sk->sk_lock.slock);
>> > +               }
>>
>> Nice catch.
>> Should then we change sk_dst_set() itself to do spin_lock_bh uncondi=
tionally?
>> Seems overhead is smaller, than checking all possible callsites manu=
ally.
>>
>> cc-ing Dormando as well.
>
>
> Real problem is that sk_dst_set() uses a different lock. I never
> understood how this was supposed to work.

we probably need to test the assumption in the sk_dst_set() comment:
/* This can be called while sk is owned by the caller only */
I don't understand why this piece of code doesn't do:
old_dst =3D rcu_dereference_check(sk->sk_dst_cache,
sock_owned_by_user(sk) || lockdep_is_held(&sk->sk_lock.slock));
like sk_dst_get does...

If I'm reading the code correctly, at the time of sk_dst_set() call
from udp_sendmsg()
the sk_lock.slock is not held and sock_owned_by_user(sk) is false as we=
ll.
Same not held condition is in the first sk_dst_reset() call from
ip4_datagram_connect().

Though the lock is properly held from release_sock()->ip4_datagram_rele=
ase_cb()
Cannot agree more with Eric "how is it supposed to work?"

> We should either :
>
> 1) use xchg() and no lock at all to change sk_dst_cache, as we did fo=
r
> sk_rx_dst ( cf udp_sk_rx_dst_set() )
>
> 2) No longer use sk_dst_lock, and always use the socket lock
> (sk->sk_lock.slock) instead.

Probably needs some combination of both.
sk_dst_lock seems useless for ipv4.
What the following suppose to do in ipv6_update_options() ?!
                spin_lock(&sk->sk_dst_lock);
                opt =3D xchg(&inet6_sk(sk)->opt, opt);
                spin_unlock(&sk->sk_dst_lock);
seems ipv6 is reusing the same lock for completely different reason.

>
>
