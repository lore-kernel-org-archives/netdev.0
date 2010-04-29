From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 29 Apr 2010 19:56:12 +0200
Message-ID: <1272563772.2222.301.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi>
	 <1272118252.8918.13.camel@bigi> <1272290584.19143.43.camel@edumazet-laptop>
	 <1272293707.19143.51.camel@edumazet-laptop>
	 <20100429174056.GA8044@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Andi Kleen <andi@firstfloor.org>
To: Andi Kleen <ak@gargoyle.fritz.box>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:43132 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933936Ab0D3SrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:47:04 -0400
Received: by mail-bw0-f219.google.com with SMTP id 19so311923bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 11:47:02 -0700 (PDT)
In-Reply-To: <20100429174056.GA8044@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 avril 2010 =C3=A0 19:42 +0200, Andi Kleen a =C3=A9crit :
> > Andi, what do you think of this one ?
> > Dont we have a function to send an IPI to an individual cpu instead=
 ?
>=20
> That's what this function already does. You only set a single CPU=20
> in the target mask, right?
>=20
> IPIs are unfortunately always a bit slow. Nehalem-EX systems have X2A=
PIC
> which is a bit faster for this, but that's not available in the lower
> end Nehalems. But even then it's not exactly fast.
>=20
> I don't think the IPI primitive can be optimized much. It's not a che=
ap=20
> operation.
>=20
> If it's a problem do it less often and batch IPIs.
>=20
> It's essentially the same problem as interrupt mitigation or NAPI=20
> are solving for NICs. I guess just need a suitable mitigation mechani=
sm.
>=20
> Of course that would move more work to the sending CPU again, but=20
> perhaps there's no alternative. I guess you could make it cheaper it =
by
> minimizing access to packet data.
>=20
> -Andi

Well, IPI are already batched, and rate is auto adaptative.

After various changes, it seems things are going better, maybe there is
something related to cache line trashing.

I 'solved' it by using idle=3Dpoll, but you might take a look at
clockevents_notify (acpi_idle_enter_bm) abuse of a shared and higly
contended spinlock...




    23.52%            init  [kernel.kallsyms]             [k] _raw_spin=
_lock_irqsave
                      |
                      --- _raw_spin_lock_irqsave
                         |         =20
                         |--94.74%-- clockevents_notify
                         |          lapic_timer_state_broadcast
                         |          acpi_idle_enter_bm
                         |          cpuidle_idle_call
                         |          cpu_idle
                         |          start_secondary
                         |         =20
                         |--4.10%-- tick_broadcast_oneshot_control
                         |          tick_notify
                         |          notifier_call_chain
                         |          __raw_notifier_call_chain
                         |          raw_notifier_call_chain
                         |          clockevents_do_notify
                         |          clockevents_notify
                         |          lapic_timer_state_broadcast
                         |          acpi_idle_enter_bm
                         |          cpuidle_idle_call
                         |          cpu_idle
                         |          start_secondary
                         |         =20

