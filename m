From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 29 Apr 2010 21:12:27 +0200
Message-ID: <1272568347.2209.11.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi>
	 <1272118252.8918.13.camel@bigi> <1272290584.19143.43.camel@edumazet-laptop>
	 <1272293707.19143.51.camel@edumazet-laptop>
	 <20100429174056.GA8044@gargoyle.fritz.box>
	 <1272563772.2222.301.camel@edumazet-laptop>
	 <20100429182347.GA8512@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	lenb@kernel.org, arjan@infradead.org
To: Andi Kleen <ak@gargoyle.fritz.box>,
	Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:34345 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932437Ab0D3Rk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:40:28 -0400
Received: by bwz19 with SMTP id 19so280394bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 10:40:26 -0700 (PDT)
In-Reply-To: <20100429182347.GA8512@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 avril 2010 =C3=A0 20:23 +0200, Andi Kleen a =C3=A9crit :
> On Thu, Apr 29, 2010 at 07:56:12PM +0200, Eric Dumazet wrote:
> > Le jeudi 29 avril 2010 =C3=A0 19:42 +0200, Andi Kleen a =C3=A9crit =
:
> > > > Andi, what do you think of this one ?
> > > > Dont we have a function to send an IPI to an individual cpu ins=
tead ?
> > >=20
> > > That's what this function already does. You only set a single CPU=
=20
> > > in the target mask, right?
> > >=20
> > > IPIs are unfortunately always a bit slow. Nehalem-EX systems have=
 X2APIC
> > > which is a bit faster for this, but that's not available in the l=
ower
> > > end Nehalems. But even then it's not exactly fast.
> > >=20
> > > I don't think the IPI primitive can be optimized much. It's not a=
 cheap=20
> > > operation.
> > >=20
> > > If it's a problem do it less often and batch IPIs.
> > >=20
> > > It's essentially the same problem as interrupt mitigation or NAPI=
=20
> > > are solving for NICs. I guess just need a suitable mitigation mec=
hanism.
> > >=20
> > > Of course that would move more work to the sending CPU again, but=
=20
> > > perhaps there's no alternative. I guess you could make it cheaper=
 it by
> > > minimizing access to packet data.
> > >=20
> > > -Andi
> >=20
> > Well, IPI are already batched, and rate is auto adaptative.
> >=20
> > After various changes, it seems things are going better, maybe ther=
e is
> > something related to cache line trashing.
> >=20
> > I 'solved' it by using idle=3Dpoll, but you might take a look at
> > clockevents_notify (acpi_idle_enter_bm) abuse of a shared and higly
> > contended spinlock...
>=20
> acpi_idle_enter_bm should not be executed on a Nehalem, it's obsolete=
=2E
> If it does on your system something is wrong.
>=20
> Ahh, that triggers a bell. There's one issue that if the remote CPU i=
s in a very
> deep idle state it could take a long time to wake it up. Nehalem has =
deeper
> sleep states than earlier CPUs. When this happens the IPI sender will=
 be slow
> too I believe.
>=20
> Are the target CPUs idle?=20
>=20

Yes, mostly, but about 200.000 wakeups per second I would say...

If a cpu in deep state receives an IPI, process a softirq, should it
come back to deep state immediately, or should it wait for some
milliseconds ?

> Perhaps need to feed some information to cpuidle's governour to preve=
nt this problem.
>=20
> idle=3Dpoll is very drastic, better to limit to C1=20
>=20

How can I do this ?

Thanks !


