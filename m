From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Thu, 19 Nov 2009 11:08:05 +0100
Message-ID: <20091119100805.GA22938@basil.fritz.box>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com> <87hbt0kaae.fsf@basil.nowhere.org> <65634d660911160902t677a4fb4r71602cb0d10f1cce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56702 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757462AbZKSKIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 05:08:05 -0500
Content-Disposition: inline
In-Reply-To: <65634d660911160902t677a4fb4r71602cb0d10f1cce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2009 at 09:02:32AM -0800, Tom Herbert wrote:

Sorry for the late answer.

> >> + =A0 =A0 case __constant_htons(ETH_P_IPV6):
> >> + =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, sizeof(*ip6)))
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> >> +
> >> + =A0 =A0 =A0 =A0 =A0 =A0 ip6 =3D (struct ipv6hdr *) skb->data;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 ip_proto =3D ip6->nexthdr;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 addr1 =3D ip6->saddr.s6_addr32[3];
> >> + =A0 =A0 =A0 =A0 =A0 =A0 addr2 =3D ip6->daddr.s6_addr32[3];
> >
> > Why only [3] ? Is this future proof?
> >
> No.  But it's same as inet6_ehashfn :-)

Perhaps it would be good to consolidate all these ipv6 hashes
into one place where they could be at least fixed easily.

>=20
> >> + =A0 =A0 for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_softi=
rq_cpus)) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 struct softnet_data *queue =3D &per_cpu(=
softnet_data, cpu);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 __smp_call_function_single(cpu, &queue->=
csd, 0);
> >
> > How do you get around the standard deadlocks with IPI called from
> > irq disabled section?
> >
>=20
> What are the standard deadlocks?  Looks like __send_remote_softirq
> will call __smp_call_function with irq's disabled...

The traditional deadlock (that was before the queue smp_call_function)
was

A                        B
                         grab lock
interrupts off
spin on lock                =20
                         send IPI
                         wait for specific CPU

never answers because
interrupts are off
                         hangs forever


I think with the queued smp_call_function it's better because
the locks are only hold much shorter and that particular scenario
is gone, but I'm not sure the problem has fully gone away.=20

At least there are still plenty of WARN_ON( ... irqs_disabled()) in=20
kernel/smp.c


> > It's a standard pet peeve of me, but it's quite unlikely you'll
> > get any useful entropy at this time of kernel startup.
> >
> > Normally it's always the same.
> >
> Would it make sense to just use skb_tx_hashrnd for the receive hash
> key also (renaming it to be more general)?

That has the same problem, although it's at least a bit later,
but I suspect it would be still not very random.

You could just drop it and always use a constant hash rnd?

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
