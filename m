From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] SFQ planned changes
Date: Wed, 04 Jan 2012 09:17:25 +0100
Message-ID: <1325665045.30256.28.camel@edumazet-laptop>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	 <21734335.uCtjXOcSpA@alaris>
	 <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	 <1325587235.2320.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw5T10PHD+YQQjy_r=LHKVbYeiWerwM0ou7HANGoenFRKw@mail.gmail.com>
	 <1325595036.2320.43.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325606918.2320.84.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw427XZj17CtAavJCiZDgPqYu4S5v_fZzoYuZ+p5KbyWAg@mail.gmail.com>
	 <1325636098.30256.12.camel@edumazet-laptop>
	 <CAA93jw6g1se3pfC8qzvDKnp9N8x0wRhdBActr0Og8rHaHvdAMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:56902 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754425Ab2ADIRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 03:17:31 -0500
Received: by lahd3 with SMTP id d3so3963107lah.19
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 00:17:30 -0800 (PST)
In-Reply-To: <CAA93jw6g1se3pfC8qzvDKnp9N8x0wRhdBActr0Og8rHaHvdAMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 04 janvier 2012 =C3=A0 08:56 +0100, Dave Taht a =C3=A9crit =
:

> I find puzzling that my baseline ping time is nearly 3x yours.
>=20
> I guess this is the price I pay for a 680mhz box on the other end.
>=20

Hmm... maybe... but this seems strange. A ping handler should be a
matter of 1 to 10 us at most. not 100 us.

Checkout on receiver  machine rx coalescing params : ethtool -c eth0

Here : the sender is a normal link (not trunk mode)

# ethtool -c eth3
Coalesce parameters for eth3:
Adaptive RX: off  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 24
rx-frames: 0
rx-usecs-irq: 0
rx-frames-irq: 0

tx-usecs: 48
tx-frames: 0
tx-usecs-irq: 0
tx-frames-irq: 0


And on my 2nd server, receiver of the ping request, (but also 2 switche=
s
are crossed between these machines). This eth2 is part of a bond0
device, and trunk (vlan) activated on this link.

$ ethtool -c eth2
Coalesce parameters for eth2:
Adaptive RX: off  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 20
rx-frames: 5
rx-usecs-irq: 0
rx-frames-irq: 5

tx-usecs: 72
tx-frames: 53
tx-usecs-irq: 0
tx-frames-irq: 5

So I have a 20us delay at rx time before NIC sends an interrupt to the
Host to 'deliver' the incoming packet.

If I change it to 1 us :

ethtool -C eth2 rx-usecs 1

then pings are even better, but a given load should generate more
interrupts.

# ping 192.168.20.110
PING 192.168.20.110 (192.168.20.110) 56(84) bytes of data.
64 bytes from 192.168.20.110: icmp_req=3D1 ttl=3D64 time=3D0.067 ms
64 bytes from 192.168.20.110: icmp_req=3D2 ttl=3D64 time=3D0.061 ms
64 bytes from 192.168.20.110: icmp_req=3D3 ttl=3D64 time=3D0.064 ms
64 bytes from 192.168.20.110: icmp_req=3D4 ttl=3D64 time=3D0.064 ms
64 bytes from 192.168.20.110: icmp_req=3D5 ttl=3D64 time=3D0.061 ms
64 bytes from 192.168.20.110: icmp_req=3D6 ttl=3D64 time=3D0.061 ms
64 bytes from 192.168.20.110: icmp_req=3D7 ttl=3D64 time=3D0.062 ms
64 bytes from 192.168.20.110: icmp_req=3D8 ttl=3D64 time=3D0.060 ms
64 bytes from 192.168.20.110: icmp_req=3D9 ttl=3D64 time=3D0.062 ms
64 bytes from 192.168.20.110: icmp_req=3D10 ttl=3D64 time=3D0.062 ms
64 bytes from 192.168.20.110: icmp_req=3D11 ttl=3D64 time=3D0.062 ms
64 bytes from 192.168.20.110: icmp_req=3D12 ttl=3D64 time=3D0.062 ms
64 bytes from 192.168.20.110: icmp_req=3D13 ttl=3D64 time=3D0.058 ms
64 bytes from 192.168.20.110: icmp_req=3D14 ttl=3D64 time=3D0.062 ms
64 bytes from 192.168.20.110: icmp_req=3D15 ttl=3D64 time=3D0.063 ms
64 bytes from 192.168.20.110: icmp_req=3D16 ttl=3D64 time=3D0.063 ms
64 bytes from 192.168.20.110: icmp_req=3D17 ttl=3D64 time=3D0.059 ms
64 bytes from 192.168.20.110: icmp_req=3D18 ttl=3D64 time=3D0.062 ms
^C
--- 192.168.20.110 ping statistics ---
18 packets transmitted, 18 received, 0% packet loss, time 16999ms
rtt min/avg/max/mdev =3D 0.058/0.061/0.067/0.010 ms
