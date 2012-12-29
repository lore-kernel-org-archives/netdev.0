From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sat, 29 Dec 2012 12:20:07 -0800
Message-ID: <1356812407.21409.5116.camel@edumazet-glaptop>
References: <20121229092417.GA4038@paralelels.com>
	 <1356789203.21409.3923.camel@edumazet-glaptop>
	 <20121229145030.GA7959@paralelels.com>
	 <1356802828.21409.4623.camel@edumazet-glaptop>
	 <1356807516.4102.4.camel@edumazet-laptop>
	 <1356810062.21409.4991.camel@edumazet-glaptop>
	 <20121229200848.GA3389@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vvs@parallels.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:62525 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106Ab2L2UUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 15:20:09 -0500
Received: by mail-da0-f48.google.com with SMTP id k18so5239823dae.35
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 12:20:09 -0800 (PST)
In-Reply-To: <20121229200848.GA3389@paralelels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-12-30 at 00:08 +0400, Andrew Vagin wrote:
> On Sat, Dec 29, 2012 at 11:41:02AM -0800, Eric Dumazet wrote:
> > On Sat, 2012-12-29 at 19:58 +0100, Eric Dumazet wrote:
> > > Le samedi 29 d=C3=A9cembre 2012 =C3=A0 09:40 -0800, Eric Dumazet =
a =C3=A9crit :
> > >=20
> > > >=20
> > > > Please post your new tcpdump then ;)
> > > >=20
> > > > also post "netstat -s" from root and test ns after your wgets
> > >=20
> > > Also try following bnx2 patch.
> > >=20
> > > It should help GRO / TCP coalesce
> > >=20
> > > bnx2 should be the last driver not using skb head_frag
>=20
> I don't have access to the host. I'm going to test your patch tomorro=
w.
> Thanks.
>=20
> >=20
> > And of course, you should make sure all your bnx2 interrupts are ha=
ndled
> > by the same cpu.
> All bnx interrupts are handled on all cpus. They are handled on the s=
ame
> cpu, if a kernel is booted with msi_disable=3D1.
>=20
> Is it right, that a received window will be less, if packets are not =
sorted?
> Looks like a bug.
>=20
> I want to say, that probably it works correctly, if packets are sorte=
d.
> But I think if packets are not sorted, it should work with the same
> speed, cpu load and memory consumption may be a bit more.

Without veth, it doesnt really matter that IRQ are spread on multiple
cpus, because packets are handled in NAPI, and only one cpu runs the
eth0 NAPI handler at one time.

But as soon as packets are queued (by netif_rx()) for 'later'
processing, you can have dramatic performance decrease.

Thats why you really should make sure IRQ on your eth0 device
are handled by a single cpu.

It will help to get better performance in most cases.

echo 1 >/proc/irq/*/eth0/../smp_affinity

If it doesnt work, you might try instead :

echo 1 >/proc/irq/default_smp_affinity
<you might need to reload bnx2 module, or ifdown/ifup eth0 >
