From: Stephen Hemminger <shemminger@vyatta.com>
Subject: OFT - reserving CPU's for networking
Date: Thu, 29 Apr 2010 11:10:47 -0700
Message-ID: <20100429111047.031eeff9@nehalam>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	<1272014825.7895.7851.camel@edumazet-laptop>
	<1272060153.8918.8.camel@bigi>
	<1272118252.8918.13.camel@bigi>
	<1272290584.19143.43.camel@edumazet-laptop>
	<1272293707.19143.51.camel@edumazet-laptop>
	<20100429174056.GA8044@gargoyle.fritz.box>
	<1272563772.2222.301.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <ak@gargoyle.fritz.box>, netdev@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56166 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757939Ab0D3RFY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:05:24 -0400
In-Reply-To: <1272563772.2222.301.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Le jeudi 29 avril 2010 =C3=A0 19:42 +0200, Andi Kleen a =C3=A9crit :
> > > Andi, what do you think of this one ?
> > > Dont we have a function to send an IPI to an individual cpu inste=
ad ? =20
> >=20
> > That's what this function already does. You only set a single CPU=20
> > in the target mask, right?
> >=20
> > IPIs are unfortunately always a bit slow. Nehalem-EX systems have X=
2APIC
> > which is a bit faster for this, but that's not available in the low=
er
> > end Nehalems. But even then it's not exactly fast.
> >=20
> > I don't think the IPI primitive can be optimized much. It's not a c=
heap=20
> > operation.
> >=20
> > If it's a problem do it less often and batch IPIs.
> >=20
> > It's essentially the same problem as interrupt mitigation or NAPI=20
> > are solving for NICs. I guess just need a suitable mitigation mecha=
nism.
> >=20
> > Of course that would move more work to the sending CPU again, but=20
> > perhaps there's no alternative. I guess you could make it cheaper i=
t by
> > minimizing access to packet data.
> >=20
> > -Andi =20
>=20
> Well, IPI are already batched, and rate is auto adaptative.
>=20
> After various changes, it seems things are going better, maybe there =
is
> something related to cache line trashing.
>=20
> I 'solved' it by using idle=3Dpoll, but you might take a look at
> clockevents_notify (acpi_idle_enter_bm) abuse of a shared and higly
> contended spinlock...
>=20
>=20
>=20
>=20
>     23.52%            init  [kernel.kallsyms]             [k] _raw_sp=
in_lock_irqsave
>                       |
>                       --- _raw_spin_lock_irqsave
>                          |         =20
>                          |--94.74%-- clockevents_notify
>                          |          lapic_timer_state_broadcast
>                          |          acpi_idle_enter_bm
>                          |          cpuidle_idle_call
>                          |          cpu_idle
>                          |          start_secondary
>                          |         =20
>                          |--4.10%-- tick_broadcast_oneshot_control
>                          |          tick_notify
>                          |          notifier_call_chain
>                          |          __raw_notifier_call_chain
>                          |          raw_notifier_call_chain
>                          |          clockevents_do_notify
>                          |          clockevents_notify
>                          |          lapic_timer_state_broadcast
>                          |          acpi_idle_enter_bm
>                          |          cpuidle_idle_call
>                          |          cpu_idle
>                          |          start_secondary
>                          |         =20
>=20


I keep getting asked about taking some core's away from clock and sched=
uler
to be reserved just for network processing. Seeing this kind of stuff
makes me wonder if maybe that isn't a half bad idea.


--=20
