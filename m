From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bonding, GRO and tcp_reordering
Date: Tue, 30 Nov 2010 17:04:33 +0100
Message-ID: <1291133073.2904.128.camel@edumazet-laptop>
References: <20101130135549.GA22688@verge.net.au>
	 <1291131776.21077.27.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48442 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169Ab0K3QEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 11:04:38 -0500
Received: by wyb28 with SMTP id 28so5840879wyb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 08:04:37 -0800 (PST)
In-Reply-To: <1291131776.21077.27.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 15:42 +0000, Ben Hutchings a =C3=A9cri=
t :
> On Tue, 2010-11-30 at 22:55 +0900, Simon Horman wrote:

> > The only other parameter that seemed to have significant effect was=
 to
> > increase the mtu.  In the case of MTU=3D9000, GRO seemed to have a =
negative
> > impact on throughput, though a significant positive effect on CPU
> > utilisation.
> [...]
>=20
> Increasing MTU also increases the interval between packets on a TCP f=
low
> using maximum segment size so that it is more likely to exceed the
> difference in delay.
>=20

GRO really is operational _if_ we receive in same NAPI run several
packets for the same flow.

As soon as we exit NAPI mode, GRO packets are flushed.

Big MTU --> bigger delays between packets, so big chance that GRO canno=
t
trigger at all, since NAPI runs for one packet only.

One possibility with big MTU is to tweak "ethtool -c eth0" params
rx-usecs: 20
rx-frames: 5
rx-usecs-irq: 0
rx-frames-irq: 5
so that "rx-usecs" is bigger than the delay between two MTU full sized
packets.

Gigabit speed means 1 nano second per bit, and MTU=3D9000 means 72 us
delay between packets.

So try :

ethtool -C eth0 rx-usecs 100

to get chance that several packets are delivered at once by NIC.

Unfortunately, this also add some latency, so it helps bulk transferts,
and slowdown interactive traffic=20


