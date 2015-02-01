From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Sun, 1 Feb 2015 14:26:11 +0200
Message-ID: <20150201122611.GA8883@redhat.com>
References: <20100413145944.GA7716@redhat.com>
 <4BC48F79.5090409@siemens.com>
 <1271176838.16881.537.camel@edumazet-laptop>
 <20100413173919.GC26011@redhat.com>
 <1271183463.16881.545.camel@edumazet-laptop>
 <20100414005822.GD18044@gondor.apana.org.au>
 <1422789633.11044.18.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Moore <paul.moore@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qemu-devel <qemu-devel@nongnu.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422789633.11044.18.camel@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 01, 2015 at 11:20:33AM +0000, David Woodhouse wrote:
> On Wed, 2010-04-14 at 08:58 +0800, Herbert Xu wrote:
> > On Tue, Apr 13, 2010 at 08:31:03PM +0200, Eric Dumazet wrote:
> > >
> > > Herbert Acked your patch, so I guess its OK, but I think it can b=
e
> > > dangerous.
> >=20
> > The tun socket accounting was never designed to stop it from
> > flooding another tun interface.  It's there to stop it from
> > transmitting above a destination interface TX bandwidth and
> > cause unnecessary packet drops.  It also limits the total amount
> > of kernel memory that can be pinned down by a single tun interface.
> >=20
> > In this case, all we're doing is shifting the accounting from the
> > "hardware" queue to the qdisc queue.
> >=20
> > So your ability to flood a tun interface is essentially unchanged.
>=20
> I've just been looking at VPN performance, using netperf to flood an
> openconnect/ocserv connection over GigE and profiling my VPN client.
>=20
> If I run netperf over the *unencrypted* link, it only sends 1Gb/s of
> packets =E2=80=94 because the packets are correctly accounted to netp=
erf's UDP
> socket until the moment they're actually transmitted on the wire, and
> the backpressure works correctly.
>=20
> When I run over the VPN, netperf thinks it sent 2=C2=BD times the amo=
unt of
> TX traffic.

At some level, it's expected: netperf's manual actually says:
	A UDP_STREAM test has no end-to-end flow control - UDP provides none a=
nd
	neither does netperf. However, if you wish, you can configure netperf
	with --enable-intervals=3Dyes to enable the global command-line -b and=
 -w
	options to pace bursts of traffic onto the network.

> Packets are being dropped by the tun device before even
> feeding them up to the VPN client to be sent =E2=80=94 presumably bec=
ause of
> this skb_orphan() call. (The client itself should do the right thing,
> and only suck packets out of the tun at the rate it can shove them ou=
t
> *its* UDP socket.)

A simple work-around is to limit the rate using a non work conservig qd=
isc.

> Did we ever look at the alternative solution of taking ownership only
> after a timeout, or on demand when we need to shut down the device?

I've been thinking about this on and off, but didn't find a good
safe solution yet.

=46or timeout, the difficulty is to find a good timer value,
low enough to avoid DOS attacks but high enough to avoid
spurious packet drops (and expensive timer interrupts).

--=20
MST
