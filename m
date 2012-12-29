From: Andrew Vagin <avagin@parallels.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sun, 30 Dec 2012 01:07:14 +0400
Message-ID: <20121229210713.GA4350@paralelels.com>
References: <20121229092417.GA4038@paralelels.com>
 <1356789203.21409.3923.camel@edumazet-glaptop>
 <20121229145030.GA7959@paralelels.com>
 <1356802828.21409.4623.camel@edumazet-glaptop>
 <1356807516.4102.4.camel@edumazet-laptop>
 <1356810062.21409.4991.camel@edumazet-glaptop>
 <20121229200848.GA3389@paralelels.com>
 <1356812407.21409.5116.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <vvs@parallels.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:60989 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab2L2VHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 16:07:49 -0500
Content-Disposition: inline
In-Reply-To: <1356812407.21409.5116.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2012 at 12:20:07PM -0800, Eric Dumazet wrote:
> On Sun, 2012-12-30 at 00:08 +0400, Andrew Vagin wrote:
> > On Sat, Dec 29, 2012 at 11:41:02AM -0800, Eric Dumazet wrote:
> > > On Sat, 2012-12-29 at 19:58 +0100, Eric Dumazet wrote:
> > > > Le samedi 29 d=C3=A9cembre 2012 =C3=A0 09:40 -0800, Eric Dumaze=
t a =C3=A9crit :
> > > >=20
> > > > >=20
> > > > > Please post your new tcpdump then ;)
> > > > >=20
> > > > > also post "netstat -s" from root and test ns after your wgets
> > > >=20
> > > > Also try following bnx2 patch.
> > > >=20
> > > > It should help GRO / TCP coalesce
> > > >=20
> > > > bnx2 should be the last driver not using skb head_frag
> >=20
> > I don't have access to the host. I'm going to test your patch tomor=
row.
> > Thanks.
> >=20
> > >=20
> > > And of course, you should make sure all your bnx2 interrupts are =
handled
> > > by the same cpu.
> > All bnx interrupts are handled on all cpus. They are handled on the=
 same
> > cpu, if a kernel is booted with msi_disable=3D1.
> >=20
> > Is it right, that a received window will be less, if packets are no=
t sorted?
> > Looks like a bug.
> >=20
> > I want to say, that probably it works correctly, if packets are sor=
ted.
> > But I think if packets are not sorted, it should work with the same
> > speed, cpu load and memory consumption may be a bit more.
>=20
> Without veth, it doesnt really matter that IRQ are spread on multiple
> cpus, because packets are handled in NAPI, and only one cpu runs the
> eth0 NAPI handler at one time.
>=20
> But as soon as packets are queued (by netif_rx()) for 'later'
> processing, you can have dramatic performance decrease.
>=20
> Thats why you really should make sure IRQ on your eth0 device
> are handled by a single cpu.
>=20
> It will help to get better performance in most cases.

I understand this fact, but so big difference looks strange for me.

Default configuration (with the bug):
# cat /proc/interrupts  | grep eth0
  68:      10187      10188      10187      10023      10190      10185
10187      10019   PCI-MSI-edge      eth0

>=20
> echo 1 >/proc/irq/*/eth0/../smp_affinity

This doesn't help.

I tryed echo 0 > /proc/irq/68/smp_affinity_list. This doesn't help too.

>=20
> If it doesnt work, you might try instead :
>=20
> echo 1 >/proc/irq/default_smp_affinity
> <you might need to reload bnx2 module, or ifdown/ifup eth0 >

This helps, and the bug are not reproduced in this case.

# cat /proc/interrupts  | grep eth0
  68:      60777          0          0          0          0          0
0          0   PCI-MSI-edge      eth0

Thanks.
