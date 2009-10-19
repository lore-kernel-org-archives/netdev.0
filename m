From: steve@chygwyn.com
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
	sockets, and for IPv4 multicast forwarding
Date: Mon, 19 Oct 2009 09:20:33 +0100
Message-ID: <20091019082033.GB27230@fogou.chygwyn.com>
References: <20091007.223928.34412707.davem@davemloft.net> <55a4f86e0910140051v69441b09gd364b32f8e2d0c68@mail.gmail.com> <20091014072319.GA12095@fogou.chygwyn.com> <20091014.021505.181431380.davem@davemloft.net> <55a4f86e0910140250o45532dabr33707c025dfa25f9@mail.gmail.com> <20091014092743.GA13374@fogou.chygwyn.com> <55a4f86e0910141133y4decdeb4v43d9168687bbb724@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, atis@mikrotik.com,
	netdev@vger.kernel.org, panther@balabit.hu, eric.dumazet@gmail.com,
	brian.haley@hp.com
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:42941 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755908AbZJSJ0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 05:26:25 -0400
Content-Disposition: inline
In-Reply-To: <55a4f86e0910141133y4decdeb4v43d9168687bbb724@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Oct 14, 2009 at 11:33:39AM -0700, Maciej =C5=BBenczykowski wrot=
e:
> > I don't agree. There are two route lookups with a tunnel, the
> > internal one and the tunnel one. Here is an example of what I'm
> > thinking:
> >
> > 1. Look up a route which points at a remote ip addres via a tunnel =
device.
> > =C2=A0 The "setmark" on this route sets the skb mark
>=20
> imho, this is much better done by having the mark setting performed
> explicitly by the tunnel device itself.
> That's also were we set ttl and qos (or inherit) on the outgoing pack=
et).
>
Yes, I think (having looked at the code a bit more in the mean time)
that there is an argument for doing that. Although I still think that
setting the mark via the routing table would be a useful feature too.

=20
> > 2. Look up a route on the tunnel itself (i.e. the tunnel endpoint n=
ot
> > =C2=A0 the socket endpoint) using the mark from the initial lookup.=
 This
> > =C2=A0 route can depend on the previous lookup (if there are multip=
le
> > =C2=A0 routes for multiple marks) and also set the mark to use.
>=20
> we would get the mark set by the tunneling module here.
>=20
> > The default would be to inherit the mark over a route lookup, in
> > case that no "setmark" had been specified for that route. In
> > other words, it would be the same as it is now.
>=20
> I'm not saying your solution wouldn't work, but I think it's less
> clean.  I don't think marking should be inherited (in the general
> case) in case of packet wrapping (whether via gre, ipip, sit, or othe=
r
> methods).
>
I guess we could say that inheriting the mark would not be the default
if the packet has gone through a device (whether virtual or physical)
then. That still seems ok to me since its basically what happens curren=
tly
I think.
=20
> > The mark is supposed to be a generic thing, not just for routing
> > lookups, it can be used for classification, etc as well. I would
> > expect to see such a thing used for maybe specifying a VLAN or
> > a reference to an MPLS label stack, or something similar too,
>=20
> Right, the mark can currently (as far as I know) be set in one of two
> ways - either from the mangle table (and it can also be matched on in
> netfilter) or by using setsockopt(SO_MARK).
>=20
> Imagine a situation where you have a machine with routing already
> configured (pretty complex setup, tunnels, firewalls, etc) and you
> want to run a user space application that verifies (health-checks)
> some remote host (or something).  As part of the health check you wan=
t
> to verify a particular route to the destination.  This requires
> per-socket routing, which can (almost) be achieved by having proper
> routing (on fwmark) setup and using setsockopt(SO_MARK) on the health
> check socket in order to force specific routing.  These health checks
> may then of course be feedback into the routing system (ie. if they
> fail the routing rules get modified).  Note, that in particular we ma=
y
> want to be healthchecking routes that aren't even available in the
> default routing table (because they've currently been removed from th=
e
> default table, because previous health checks failed).
>=20
> Maciej

Yes, thats a good use case. I think there are a lot of other potential
use cases too though. A while back when I was looking into MPLS I wonde=
red
about using the mark to index into a set of outgoing label stacks. That
was the original reason that I thought setting the mark via the routing
table would be useful. I've not really had the time to continue my
MPLS investigations recently though :(

Another potential use case would be to segregate traffic into different
routing domains (and thus being able to change the mark when moving fro=
m
one routing domain to another might be useful).

Steve.

