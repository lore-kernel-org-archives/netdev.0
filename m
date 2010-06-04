From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soon as
  possible after transfer
Date: Fri, 04 Jun 2010 06:05:54 +0200
Message-ID: <1275624354.2533.121.camel@edumazet-laptop>
References: <1275536881.18536.5.camel@eight.analog.com>
	 <AANLkTik4aWREeblhnbI3DU7a_CE11Rx0GvXi56O2yHzy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:39834 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab0FDEF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 00:05:59 -0400
Received: by wwb28 with SMTP id 28so582035wwb.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 21:05:57 -0700 (PDT)
In-Reply-To: <AANLkTik4aWREeblhnbI3DU7a_CE11Rx0GvXi56O2yHzy@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 juin 2010 =C3=A0 11:29 +0800, Sonic Zhang a =C3=A9crit :
> David,
>=20
> Any comments?
>=20
> Thanks
>=20
> Sonic
>=20
> On Thu, Jun 3, 2010 at 11:48 AM, sonic zhang <sonic.adi@gmail.com> wr=
ote:
> > >From 40560ae9e8db42e2d2259b791ace160534c9a0f2 Mon Sep 17 00:00:00 =
2001
> > From: Sonic Zhang <sonic.zhang@analog.com>
> > Date: Thu, 3 Jun 2010 11:44:33 +0800
> > Subject: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soo=
n as possible after transfer
> >
> > SKBs hold onto resources that can't be held indefinitely, such as T=
CP
> > socket references and netfilter conntrack state.  So if a packet is=
 left
> > in TX ring for a long time, there might be a TCP socket that cannot=
 be
> > closed and freed up.
> >
> > Current blackfin EMAC driver always reclaim and free used tx skbs i=
n future
> > transfers. The problem is that future transfer may not come as soon=
 as
> > possible. This patch start a timer after transfer to reclaim and fr=
ee skb.
> > There is nearly no performance drop with this patch.
> >
> > TX interrupt is not enabled for 2 reasons:
> >
> > 1) If Blackfin EMAC TX transfer control is turned on, endless TX
> > interrupts are triggered no matter if TX DMA is enabled. Since DMA =
walks
> > down the ring automatically, TX transfer control can't be turned of=
f in the
> > middle. The only way is to disable TX interrupt completely.
> >
> > 2) skb can not be freed from interrupt context. A work queue or tas=
klet
> > has to be created, which introduce more overhead than timer only so=
lution.
> >

Could you elaborate on this second point ?

skb can be freed from interrupt context using appropriate API :

1) If from NAPI context, no special care is needed and use
dev_kfree_skb().

2) If from hard irq context, use dev_kfree_skb_irq() :

With recent changes, skb is probably already orphaned and can be freed
immediately.

In the unlikely case it is not yet orphaned, skb is queued in
softnet_data.completion_queue.



