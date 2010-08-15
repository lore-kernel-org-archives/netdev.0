From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Sun, 15 Aug 2010 12:55:22 +0200
Message-ID: <1281869722.2942.20.camel@edumazet-laptop>
References: <20100812.161050.246523792.davem@davemloft.net>
	 <AANLkTinGy+-ELbVx_2WJ1wOJCsz4Rez26Q2Baisws9+C@mail.gmail.com>
	 <20100814.220945.232761341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:48002 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128Ab0HOQZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 12:25:31 -0400
Received: by wwf26 with SMTP id 26so3244519wwf.1
        for <netdev@vger.kernel.org>; Sun, 15 Aug 2010 09:25:30 -0700 (PDT)
In-Reply-To: <20100814.220945.232761341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 14 ao=C3=BBt 2010 =C3=A0 22:09 -0700, David Miller a =C3=A9cr=
it :
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sat, 14 Aug 2010 11:05:54 -0700
>=20
> > Anyway, the lock warning I do get seems to be networking-related, a=
nd
> > is appended. Does this ring any bells? It could easily be something
> > old: I turn on lock debugging only when I look for bugs (or when
> > people point out bugs that I've created :^/ )
>=20
> This is a false positive but I have no idea how we can annotate
> this to not trigger in lockdep.
>=20
> These are per-cpu locks for counter management.
>=20
> The get_counters() code knows that the locks for other cpu's counters
> can only be taken in software interrupt context of that other cpu.  S=
o
> it is legal to turn software interrupts back on when grabbing their
> locks in base context.
>=20
> CC:'ing Eric Dumazet since he put the code the way it is now :-)
> Via commit 24b36f0193467fa727b85b4c004016a8dae999b9
> ("netfilter: {ip,ip6,arp}_tables: dont block bottom half more than ne=
cessary")

Hmm... thats right.

We have one lock per cpu, and only one cpu can possibly lock its
associated lock under softirq. So the usual lockdep check, warning a
lock is taken with BH enabled, while same lock was taken inside softirq
handler is triggering a false positive here.

I believe no existing lockdep annotation can instruct lockdep this use
is OK, I guess we have following choice :

1) Mask BH again, using xt_info_wrlock_lockdep(cpu) instead of
xt_info_wrlock(cpu).

xt_info_wrlock_lockdep() being a variant, that disables BH in case
CONFIG_PROVE_LOCKING=3Dy

2) temporally switch off lockdep in get_counters(), using a
lockdep_off()/lockdep_on() pair, and a comment why this is necessary.

I'll provide a patch with either way, just tell me which one you
prefer !

Thanks


