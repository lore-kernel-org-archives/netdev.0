From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] net: Add net device irq siloing feature
Date: Sat, 16 Apr 2011 08:21:37 +0200
Message-ID: <1302934897.2792.6.camel@edumazet-laptop>
References: <367764507.40661.1302929544356.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Dimitris Michailidis <dm@chelsio.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Howells <dhowells@redhat.com>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63173 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab1DPGVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 02:21:43 -0400
Received: by wwa36 with SMTP id 36so3904477wwa.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 23:21:42 -0700 (PDT)
In-Reply-To: <367764507.40661.1302929544356.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 15 avril 2011 =C3=A0 21:52 -0700, Stephen Hemminger a =C3=A9=
crit :
> > On Fri, Apr 15, 2011 at 11:49:03PM +0100, Ben Hutchings wrote:
> > > On Fri, 2011-04-15 at 16:17 -0400, Neil Horman wrote:
> > > > Using the irq affinity infrastrucuture, we can now allow net
> > > > devices to call
> > > > request_irq using a new wrapper function (request_net_irq), whi=
ch
> > > > will attach a
> > > > common affinty_update handler to each requested irq. This affin=
ty
> > > > update mechanism correlates each tracked irq to the flow(s) tha=
t
> > > > said irq processes
> > > > most frequently. The highest traffic flow is noted, marked and
> > > > exported to user
> > > > space via the affinity_hint proc file for each irq. In this way=
,
> > > > utilities like
> > > > irqbalance are able to determine which cpu is recieving the mos=
t
> > > > data from each
> > > > rx queue on a given NIC, and set irq affinity accordingly.
> > > [...]
> > >
> > > Is irqbalance expected to poll the affinity hints? How often?
> > >
> > Yes, its done just that for quite some time. Intel added that abili=
ty
> > at the
> > same time they added the affinity_hint proc file. Irqbalance polls =
the
> > affinity_hint file at the same time it rebalances all irqs (every 1=
0
> > seconds). If the affinity_hint is non-zero, irqbalance just copies =
it
> > to smp_affinity for
> > the same irq. Up until now thats been just about dead code because
> > only ixgbe
> > sets affinity_hint. Thats why I added the affinity_alg file, so
> > irqbalance could do something more intellegent than just a blind co=
py.
> > With the patch that
> > I referenced I added code to irqbalance to allow it to preform
> > different balancing methods based on the output of affinity_alg.
> > Neil
>=20
> I hate the way more and more interfaces are becoming device driver
> specific. It makes it impossible to build sane management infrastruct=
ure
> and causes lots of customer and service complaints.
>=20

=46or me, the whole problem is the paradigm that we adapt IRQ to CPU we=
re
applications _were_ running in last seconds, while process scheduler
might perform other choices, ie migrate task to cpu where IRQ was
happening (the cpu calling wakeups)

We can add logic to each layer, and yet not gain perfect behavior.

Some kind of cooperation is neeed.

Irqbalance for example is of no use in the case of a network flood
happening on your machine, because we enter NAPI mode for several
minutes on a single cpu. We'll need to add special logic in NAPI loop t=
o
force an exit to reschedule an IRQ (so that another cpu can take it)



