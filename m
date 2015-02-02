From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Mon, 2 Feb 2015 16:23:43 +0100
Message-ID: <20150202152343.GA15880@orbit.nwl.cc>
References: <1422797630.11044.32.camel@infradead.org>
 <20150201.121948.998046471405758397.davem@davemloft.net>
 <1422826183.11044.72.camel@infradead.org>
 <20150201.210716.588479604128207372.davem@davemloft.net>
 <1422862030.11044.86.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	jan.kiszka@siemens.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qemu-devel@nongnu.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422862030.11044.86.camel@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Feb 02, 2015 at 07:27:10AM +0000, David Woodhouse wrote:
> On Sun, 2015-02-01 at 21:07 -0800, David Miller wrote:
> > From: David Woodhouse <dwmw2@infradead.org>
> > Date: Sun, 01 Feb 2015 21:29:43 +0000
> >=20
> > > I really was looking for some way to push down something like an =
XFRM
> > > state into the tun device and just say "shove them out here until=
 I tell
> > > you otherwise".
> >=20
> > People decided to use TUN and push VPN stuff back into userspace,
> > and there are repercussions for that decision.
> >=20
> > I'm not saying this to be mean or whatever, but I was very
> > disappointed when userland IPSEC solutions using TUN started showin=
g
> > up.
>=20
> Yeah. That's a valid criticism of vpnc, certainly. I never did
> understand why it reimplemented the IPSec stack.
>=20
> For my OpenConnect client it's somewhat more justified though =E2=80=94=
 the
> initial data transport there is over TLS, which the kernel doesn't
> support. And if we *can* establish UDP communication, that's over DTL=
S
> which the kernel doesn't support either. It's not even the *standard*
> version of DTLS because Cisco are still using a pre-RFC4347 version o=
f
> the protocol. And we also need to probe the UDP connectivity and do
> keepalives and manage the fallback to using the TCP data transport.
>=20
> It's not like vpnc where it really is just a case of setting up the E=
SP
> context and letting it run.
>=20
> It's only now I've added Juniper support, which uses ESP-in-UDP for t=
he
> data transport, that I'm doing something that the kernel supports at
> all. And now I'm looking at how to make use of that.
>=20
> > We might as well have not have implemented the IPSEC stack at all,
> > because as a result of the userland VPN stuff our IPSEC stack is
> > largely unused except by a very narrow group of users.
>=20
> Well, I'd love to make better use of it if I can. I do suspect it mak=
es
> most sense for userspace to continue to manage the probing of UDP
> connectivity, and the fallback to TCP mode =E2=80=94 and I suspect it=
 also makes
> sense to continue to use tun for passing packets up to the VPN client
> when it's using the TCP transport.
>=20
> So the question would be how we handle redirecting the packet flow to
> the optional UDP transport, when the VPN client determines that it's
> available. For the sake of the user setting up firewall and routing
> rules, I do think it's important that it continues to appear to
> userspace as the *same* device for the entire lifetime of the session=
,
> regardless of which transport the packets happen to be using at a giv=
en
> moment in time. It doesn't *have* to be tun, though.=20

Since you want to provide connectivity over HTTPS which is not possible
in kernel space, you are stuck with keeping the tun device. So the
packet flow in that case is identical to how e.g. OpenVPN does it:

- tunX holds default route
- OpenConnect then:
  - receives packets on /dev/tun
  - holds TCP socket to VPN concentrator
  - does encapsulation into TLS

Speaking of optimisation, the interesting part is the alternative flow
via IPsec in UDP. AFAICT, it should be possible to setup an ESP in UDP
tunnel using XFRM (see ip-xfrm(8) for reference), although I didn't try
that myself. The funny thing with XFRM is, it applies before the routin=
g
decision does: If my IPsec policy matches, the packet goes that way no
matter what the routing table says about the original destination. This
can be used to override the default route provided via tun0 in the abov=
e
case.

Of course, OpenConnect has to manage all the XFRM/policy stuff on it's
own, since switching from ESP in UDP back to TLS would mean to tear dow=
n
the XFRM tunnel. OpenConnect would have to setup (a limited) XFRM and
send test traffic to decide whether to set it up fully (if limited) or
tear it down (if unlimited) again so traffic arrives at tunX again.

In my opinion, this might work. The whole setup is probably about as
intuitive as the fact that kernel IPsec tunnel mode does not naturally
provide an own interface. Firewall setup on top of that might become a
matter of try-and-error. Maybe having a VTI interface and merely moving
the default route instead of fiddling with policies all the time might
make things a little easier to comprehend, but surely adds some
performance overhead.

Cheers, Phil
