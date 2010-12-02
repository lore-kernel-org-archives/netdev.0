From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: add a security check at install
 time
Date: Thu, 02 Dec 2010 14:14:01 +0100
Message-ID: <1291295641.2871.65.camel@edumazet-laptop>
References: <1291227893.2856.1039.camel@edumazet-laptop>
	 <20101201.104450.183053379.davem@davemloft.net>
	 <1291232937.2856.1042.camel@edumazet-laptop>
	 <20101201.122312.229751364.davem@davemloft.net>
	 <1291236342.2856.1057.camel@edumazet-laptop>
	 <AANLkTikK=dy6U0QBjkJxZXeqYXVHwZqjmRhnmYBH-22r@mail.gmail.com>
	 <1291272384.2856.1074.camel@edumazet-laptop>
	 <AANLkTim8+9AA61HwcCQp3p7cSjzaTqerdd4Wtm-28kAt@mail.gmail.com>
	 <1291280000.2871.16.camel@edumazet-laptop>
	 <1291280402.2871.20.camel@edumazet-laptop>
	 <AANLkTikQOY7Nh7XOFT9wXDYpn1faVS9xH2Y-x67hiu7S@mail.gmail.com>
	 <1291283693.2871.48.camel@edumazet-laptop>
	 <AANLkTikkeQNzTMs_AifJFFU3oEKAmMBaCO9PCRWLRTSo@mail.gmail.com>
	 <1291288548.2871.51.camel@edumazet-laptop>
	 <AANLkTimZgiYi3KE7DC8DMWEzgSx7+cUaOurEHSo864AP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hagen@jauu.net,
	wirelesser@gmail.com, netdev@vger.kernel.org,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43540 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358Ab0LBNOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 08:14:06 -0500
Received: by wyb28 with SMTP id 28so8187304wyb.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 05:14:04 -0800 (PST)
In-Reply-To: <AANLkTimZgiYi3KE7DC8DMWEzgSx7+cUaOurEHSo864AP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 d=C3=A9cembre 2010 =C3=A0 19:29 +0800, Changli Gao a =C3=A9=
crit :
> On Thu, Dec 2, 2010 at 7:15 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> >
> > Their scratch memory is not on stack but part of the filter, so no
> > security problem (You can only read previous values of scratch regi=
sters
> > written by your own filter on handling a previous packet.)
> >
>=20
> The code I checked is the newest in SVN. The scratch memory is really=
 on stack.
>=20

> u_int
> bpf_filter(const struct bpf_insn *pc, u_char *p, u_int wirelen, u_int=
 buflen)
> {
>         u_int32_t A =3D 0, X =3D 0;
>         bpf_u_int32 k;
>         u_int32_t mem[BPF_MEMWORDS];
>=20
>=20
>=20

This legacy code is not used on x86 now they have JIT by default ?

My remark about SMP 'problem' was about their JIT implementation.

net/bpf_jitter.h
/* Structure describing a native filtering program created by the jitte=
r. */

typedef struct bpf_jit_filter {
        /* The native filtering binary, in the form of a bpf_filter_fun=
c. */
        bpf_filter_func func;

        int             mem[BPF_MEMWORDS];      /* Scratch memory */
} bpf_jit_filter;

Apparently they use locking around this stuff

BPFD_LOCK(d);
=2E..
   bf =3D bpf_jitter_enable !=3D 0 ? d->bd_bfilter : NULL;
   if (bf !=3D NULL)
	slen =3D (*(bf->func))(pkt, pktlen, pktlen);=20
   else
	slen =3D bpf_filter(d->bd_rfilter, pkt, pktlen, pktlen);

BPFD_UNLOCK(d);



