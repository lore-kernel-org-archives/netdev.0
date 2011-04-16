From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/3] net: Add net device irq siloing feature
Date: Sat, 16 Apr 2011 07:55:34 -0400
Message-ID: <20110416115534.GA2085@neilslaptop.think-freely.org>
References: <367764507.40661.1302929544356.JavaMail.root@tahiti.vyatta.com>
 <1302934897.2792.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	Dimitris Michailidis <dm@chelsio.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Howells <dhowells@redhat.com>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56037 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759325Ab1DPL41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 07:56:27 -0400
Content-Disposition: inline
In-Reply-To: <1302934897.2792.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 16, 2011 at 08:21:37AM +0200, Eric Dumazet wrote:
> Le vendredi 15 avril 2011 =E0 21:52 -0700, Stephen Hemminger a =E9cri=
t :
> > > On Fri, Apr 15, 2011 at 11:49:03PM +0100, Ben Hutchings wrote:
> > > > On Fri, 2011-04-15 at 16:17 -0400, Neil Horman wrote:
> > > > > Using the irq affinity infrastrucuture, we can now allow net
> > > > > devices to call
> > > > > request_irq using a new wrapper function (request_net_irq), w=
hich
> > > > > will attach a
> > > > > common affinty_update handler to each requested irq. This aff=
inty
> > > > > update mechanism correlates each tracked irq to the flow(s) t=
hat
> > > > > said irq processes
> > > > > most frequently. The highest traffic flow is noted, marked an=
d
> > > > > exported to user
> > > > > space via the affinity_hint proc file for each irq. In this w=
ay,
> > > > > utilities like
> > > > > irqbalance are able to determine which cpu is recieving the m=
ost
> > > > > data from each
> > > > > rx queue on a given NIC, and set irq affinity accordingly.
> > > > [...]
> > > >
> > > > Is irqbalance expected to poll the affinity hints? How often?
> > > >
> > > Yes, its done just that for quite some time. Intel added that abi=
lity
> > > at the
> > > same time they added the affinity_hint proc file. Irqbalance poll=
s the
> > > affinity_hint file at the same time it rebalances all irqs (every=
 10
> > > seconds). If the affinity_hint is non-zero, irqbalance just copie=
s it
> > > to smp_affinity for
> > > the same irq. Up until now thats been just about dead code becaus=
e
> > > only ixgbe
> > > sets affinity_hint. Thats why I added the affinity_alg file, so
> > > irqbalance could do something more intellegent than just a blind =
copy.
> > > With the patch that
> > > I referenced I added code to irqbalance to allow it to preform
> > > different balancing methods based on the output of affinity_alg.
> > > Neil
> >=20
> > I hate the way more and more interfaces are becoming device driver
> > specific. It makes it impossible to build sane management infrastru=
cture
> > and causes lots of customer and service complaints.
> >=20
>=20
> For me, the whole problem is the paradigm that we adapt IRQ to CPU we=
re
> applications _were_ running in last seconds, while process scheduler
> might perform other choices, ie migrate task to cpu where IRQ was
> happening (the cpu calling wakeups)
>=20
> We can add logic to each layer, and yet not gain perfect behavior.
>=20
> Some kind of cooperation is neeed.
>=20
> Irqbalance for example is of no use in the case of a network flood
> happening on your machine, because we enter NAPI mode for several
> minutes on a single cpu. We'll need to add special logic in NAPI loop=
 to
> force an exit to reschedule an IRQ (so that another cpu can take it)
>=20
Would you consider an approach whereby we, instead of updating irq affi=
nity to
match the process that consumes data from a given irq, bias the schedul=
er such
that process which consume data from a given irq not be moved away from=
 the same
core/l2 cache being fed by that flow?  Do you have a suggestion for how=
 best to
communicate that to the scheduler?  It would seem that interrogating th=
e RFS
table from the scheduler might not be well received.

Best
Neil

>=20
>=20
>=20
