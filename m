From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 11:53:58 +0200
Message-ID: <48FDA6B6.70905@cosmosbay.com>
References: <20081020190922.7dd6510a@extreme>	<48FD6E8A.6060304@cosmosbay.com> <18685.37380.34636.316536@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.17]:26338 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751904AbYJUJyK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 05:54:10 -0400
In-Reply-To: <18685.37380.34636.316536@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Olsson a =E9crit :
> Eric Dumazet writes:
>  > Stephen Hemminger a =E9crit :
>  > > Add support for recycling tx buffers into receive buffers.
>  > > This is experimental at this point.
>  > >=20
>  >=20
>  > I really like this skb recycling
>=20
> Hi,
>=20
> Well the best and cleanest thing would be if the "global" recycler sl=
ab/slub=20
> was fast enough. Historically it seems like every time the link speed=
 increases=20
> (now to 10g) alloc/kfree pops up on the profiles but that challenge h=
as sofar
> been handled by slab/slub folks. Maybe we should consult them first..=
=2E

Yes, but typical problem is inbalance :

One CPU does the allocations, (interrupts handled by a given CPU)
Another CPU(s) do(es) the freeing

Such scenario is hard for slab/slub because it needs inter-CPU communic=
ation, while
slub/slab are optimized to deal with per CPU queues/structures (fast pa=
th)

skb recycling is an interesting technique because typical NIC handles R=
X & TX completion
in one CPU at the same time, thus we can reduce this slab/slub inter-CP=
U handling.

>=20
> Also there was some discussions to have packet objects in slab.
>

skb recycling has a (nice ?) side effect on NUMA platforms, not for for=
warding workloads,
(which are IMHO not the majority of linux machines workloads) but typic=
al servers.

Current NIC drivers actually allocate their RX rings using the memory n=
ode
close to the device.

With RX recycling, we are re-using skb that were allocated by the proce=
ss itself,
and this process is likely the one that will process received frames.

On loaded machines, I am not sure that NIC having to access to remote n=
odes is
the limiting factor, especially considering modern coalescing/mitigatio=
n that tends to
delay interrupts anyway (and thus notification to host)




