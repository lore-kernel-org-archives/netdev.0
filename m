From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Tue, 09 Aug 2011 10:36:28 +0200
Message-ID: <1312878988.2371.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
	 <20110801181652.GB2732@nuttenaction>
	 <1312223866.2719.3.camel@edumazet-laptop>
	 <20110801.175705.2074393848482150971.davem@davemloft.net>
	 <1312866027.2531.42.camel@edumazet-laptop>
	 <7f02f2970d225cddfad74ee660f39d1d@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rui314@gmail.com,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62894 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880Ab1HIIga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 04:36:30 -0400
Received: by wyg24 with SMTP id 24so190666wyg.19
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 01:36:29 -0700 (PDT)
In-Reply-To: <7f02f2970d225cddfad74ee660f39d1d@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 ao=C3=BBt 2011 =C3=A0 10:29 +0200, Hagen Paul Pfeifer a =C3=
=A9crit :
> On Tue, 09 Aug 2011 07:00:27 +0200, Eric Dumazet wrote:
>=20
> > I tried this idea since its already an enum and all enum values are
> > handled in the switch, but all gcc versions I used still generate t=
he
> > useless compare and branch (always predicted by modern CPU, so harm=
less
> > anyway ?)
>=20
> Don't think so, the list is rather long - the CPU may not have any
> indication. But strange that your gcc generate a conditional sequence=
 of
> cmp and conditional jump instruction instead of a jump table! Look at
> commit 01f2f3f6ef4d076c, this is what I got after I refactored to an
> _dense_ enum list.

I am speaking of one single conditional branch, the one that is done fo=
r
every BPF instruction done in a filter. It's never taken, so must be
predicted by the cpu. A perf session could make sure it is  ;)

> =20
> > (But this would need to use a larger kernel_sock_filter with not an=
 u16
> > code, but the target address).
>=20
> Not sure if the benefit is worth to try it. Can we avoid any cachelin=
e
> misses? I don't think so.

We avoid some instructions (to load the address from the instruction
code), thats all, for each BPF instruction.

>=20
>=20
> > +		switch ((enum bpf_inst)fentry->code) {
>=20
> That should not differ! Eric, sure that this do the trick?

It is the way to tell gcc to make its optimizations, if they exists on
enum switch (), as David suggested.

If I add a new BPF_S_ANC_NEW_INST value in the enum list, not handled i=
n
the switch(), gcc complains correctly.

net/core/filter.c: In function =E2=80=98sk_run_filter=E2=80=99:
net/core/filter.c:130:3: warning: enumeration value =E2=80=98BPF_S_ANC_=
NEW_INST=E2=80=99
not handled in switch



