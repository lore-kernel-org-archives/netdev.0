From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Mon, 13 Jan 2014 02:11:46 +0100
Message-ID: <20140113011146.GG6586@order.stressinduktion.org>
References: <1389538427.32032.YahooMailBasic@web125505.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59201 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaAMBLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 20:11:48 -0500
Content-Disposition: inline
In-Reply-To: <1389538427.32032.YahooMailBasic@web125505.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Sun, Jan 12, 2014 at 06:53:47AM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> On Sat, 1/11/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wr=
ote:
>=20
> > On Sat, Jan 11, 2014 at 05:38:27PM +0400, Alexey Kuznetsov wrote:
> > > On Sat, Jan 11, 2014 at 5:06 PM, Fran=C3=A7ois-Xavier Le Bail
> > > <fx.lebail@yahoo.com> wrote:
> > > > Many DNS root-servers use TCP with anycast (IPv4 and IPV6).
> > >=20
> > > Actually, I was alerted by reset processing in your patch, it can=
not be right.
> > >=20
> > > Do not you think this must not be enabled for common use? At leas=
t
> > > some separate sysctl disabled by default.
>=20
> > The idea I had, was, that if a socket does knowingly bind to an any=
cast
> > address, it is allowed to do so and process queries on it with both=
 TCP and
> > UDP. I don't think we need a sysctl for that? Anycast addresses are=
 either
> > pre-defined (e.g. the subnet router anycast address) or specified b=
y a flag
> > when the administrator adds one. Currently one can only add anycast=
 addresses
> > either by forwarding and gets the per-subnet anycast address or wit=
h a
> > setsockopt IPV6_JOIN_ANYCAST.
>=20
> > So the problem is what should be allowed when the socket listens on=
 an any
> > address? Maybe this should be protected by a sysctl?
>=20
> TCP case:
> With my two patches (the one for bind and this one for tcp), when a
> SOCK_STREAM socket listen to in6addr_any, the server is able to=20
> send TCP reply with unicast or anycast source address,=C2=A0according
> to the destination address used by the client.
>=20
> dest request unicast =3D> src reply unicast (current behavior)
> dest resquet anycast =3D> src reply anycast (new)
>=20
> So, I don't think there is a need for a sysctl.

I am still thinking about the RST-case and am a bit unsure here. But I
currently don't see any problems.

> UDP case:
> By default (no socket option), the server program don't know the
> destination address of the request. The ipv6_dev_get_saddr() is=20
> used for choosing the unicast source address of the reply.
>=20
> I am not sure a change is needed here.

If the socket did bind to anycast address, we may well send packets fro=
m
anycast source without switching a sysctl IMHO.

If not bound we need to keep current behaviour, yes. As DNS-Servers
normally do accept a list of addresses where to bind to, I find this
acceptable. RFC6724 additionally now allowes the selection of anycast
as source address, so we may think about this and maybe integrate this
with ip addrlabel and such).

We also need to check the implications to icmp here (error reporting if
an UDP packets is sent to an anycast address). Also we have to check fo=
r
icmps generated because of forwarding errors and their source selection=
=2E

> When using IPV6_RECVPKTINFO, a server is able to know
> the destination address of the request and can use it as source
> address for the reply.
> To enable anycast for this (don't get EINVAL), there is need for
> a patch like the one I posted ("IPv6: add option to use anycast
> addresses as source addresses for datagrams").
> I am working on a v2.

Ack.

> With the appropriate change:
> dest request unicast =3D> src reply unicast (current behavior)
> dest resquet anycast =3D> src reply anycast (new)
>=20
> I don't think, there either, there is a need for a sysctl.

I agree here.

Greetings,

  Hannes
