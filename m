From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: code cleanups
Date: Thu, 30 Sep 2010 08:31:39 +0200
Message-ID: <1285828299.5211.806.camel@edumazet-laptop>
References: <1285813497-7384-1-git-send-email-xiaosuo@gmail.com>
	 <1285823808.5211.627.camel@edumazet-laptop>
	 <AANLkTimVngrNU+PLbaf8r42J3HrvURpY8KUPa+--KvLC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62940 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554Ab0I3Gbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 02:31:46 -0400
Received: by wyb28 with SMTP id 28so1545050wyb.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 23:31:45 -0700 (PDT)
In-Reply-To: <AANLkTimVngrNU+PLbaf8r42J3HrvURpY8KUPa+--KvLC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 30 septembre 2010 =C3=A0 14:09 +0800, Changli Gao a =C3=A9crit=
 :
> On Thu, Sep 30, 2010 at 1:16 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le jeudi 30 septembre 2010 =C3=A0 10:24 +0800, Changli Gao a =C3=A9=
crit :
> >> Compare operations are more readable, and compilers generate the s=
ame code
> >> for the both.
> >>
> >
> > You have a buggy compiler then.
>=20
> gcc version 4.4.3 (Gentoo 4.4.3-r2 p1.2)
>=20
>              rth =3D rcu_dereference(rth->dst.rt_next)) {
>                 if ((((__force u32)rth->fl.fl4_dst ^ (__force u32)dad=
dr) |
>                      ((__force u32)rth->fl.fl4_src ^ (__force u32)sad=
dr) |
>                      (rth->fl.iif ^ iif) |
>     2f12:       44 3b 80 dc 00 00 00    cmp    0xdc(%rax),%r8d
>     2f19:       0f 85 a2 00 00 00       jne    2fc1 <ip_route_input_c=
ommon+0x145
> >
>                      rth->fl.oif |
>     2f1f:       83 b8 d8 00 00 00 00    cmpl   $0x0,0xd8(%rax)
>     2f26:       0f 85 95 00 00 00       jne    2fc1 <ip_route_input_c=
ommon+0x145
> >
>         tos &=3D IPTOS_RT_MASK;
>         hash =3D rt_hash(daddr, saddr, iif, rt_genid(net));
>=20
>         for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
>              rth =3D rcu_dereference(rth->dst.rt_next)) {
>                 if ((((__force u32)rth->fl.fl4_dst ^ (__force u32)dad=
dr) |
>     2f2c:       44 3b b8 e4 00 00 00    cmp    0xe4(%rax),%r15d
>     2f33:       0f 85 88 00 00 00       jne    2fc1
> <ip_route_input_common+0x145>
>                      ((__force u32)rth->fl.fl4_src ^ (__force u32)sad=
dr) |
>     2f39:       44 3b b0 e8 00 00 00    cmp    0xe8(%rax),%r14d
>     2f40:       75 7f                   jne    2fc1
> <ip_route_input_common+0x145>
>=20
>=20
> >
> > I know this code is ugly, but please keep it as is, dont add condit=
ional
> > branches on hot paths.
> >
>=20
> If the compiler doesn't generate conditional branches, we have to
> touch every necessary field of all the cache entries in one hash
> bucket. Is it better than condition branch? I think the compiler
> developers know it better.

Last famous words.

Are you aware of cache lines (64 bytes at least on typical cpus), and
that all fields are already in CPU L1 cache ? I (and others) worked har=
d
in the past.

>=20
> And the compiler reorders the conditional branches, is it expected?
>=20

Your compiler added conditional branches on a code not wanting them,
only because on _your_ cpu, these conditional branches might be cheap.

Now, try to compile for an i686 target and see the difference.

If there was no difference, your compiler would be _buggy_, because not
generating optimal assembly.

Here I get :

c141dda9:       8b 55 e8                mov    -0x18(%ebp),%edx
c141ddac:       8b 81 9c 00 00 00       mov    0x9c(%ecx),%eax
c141ddb2:       33 91 a0 00 00 00       xor    0xa0(%ecx),%edx
c141ddb8:       31 f0                   xor    %esi,%eax
c141ddba:       09 d0                   or     %edx,%eax
c141ddbc:       8b 55 e0                mov    -0x20(%ebp),%edx
c141ddbf:       33 91 94 00 00 00       xor    0x94(%ecx),%edx
c141ddc5:       09 d0                   or     %edx,%eax
c141ddc7:       0f b6 55 e7             movzbl -0x19(%ebp),%edx
c141ddcb:       0b 81 90 00 00 00       or     0x90(%ecx),%eax
c141ddd1:       32 91 a4 00 00 00       xor    0xa4(%ecx),%dl
c141ddd7:       0f b6 d2                movzbl %dl,%edx
c141ddda:       09 d0                   or     %edx,%eax
c141dddc:       0f 85 9d 00 00 00       jne    c141de7f <ip_route_input=
_common+0x1b4>

As you can see, only one conditional branch.

Your patch is not welcomed, thanks.


