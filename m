From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 11:38:30 +0200
Message-ID: <1335346710.3274.24.camel@edumazet-glaptop>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	 <1335298228.5205.168.camel@edumazet-glaptop>
	 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
	 <1335331960.5205.180.camel@edumazet-glaptop>
	 <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
	 <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:36594 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756991Ab2DYJig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 05:38:36 -0400
Received: by eaaq12 with SMTP id q12so428327eaa.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 02:38:34 -0700 (PDT)
In-Reply-To: <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-25 at 11:20 +0200, Tore Anderson wrote:
> * Maciej =C5=BBenczykowski
>=20
> >> But we chose to _not_ decrease mtu and adhere to the specs.
> >
> > I get that we _choose_ to behave such, and I agree this adheres to
> > specs.
>=20
> "Chose" (past), not "choose" (present). ;-)
>=20
> This patch does not make this choice. This patch merely fixes a bug i=
n
> the implementation of the choice that was made a long time ago.
>=20
> > But I'm not convinced that (even though this is allowed per RFC) th=
is
> > is the right choice.
>=20
> That is a different issue entirely, but I don't disagree with you. A
> "min_pmtu" sysctl or something like that would be useful.
>=20
> > Also note that IPv6 prefers to see fragmentation happen at the end
> > hosts, and not at the routers.
> > Although of course it doesn't treat a tunnel end point as a router.
>=20
> Actually, in IPv6, fragmentation *must* be performed by end hosts,
> routers (including tunnel end points) *cannot* fragment.
>=20
> However, the use case for the allfrag feature is not handling tunnels=
,
> but IPv4<->IPv6 translation. The issue is that a IPv6 host may very=20
> well
> receive an ICMPv6 Packet Too Big indicating a PMTU of <1280 that was
> originally transmitted by an IPv4 router (as an ICMPv4 Need To=20
> Fragment)
> and underwent translation to IPv6.
>=20
> In this case, the IPv6 node does not need to reduce the PMTU to <1280
> (Linux does not), but it is not invalid to have a <1280 MTU link in t=
he
> IPv4 internet either, so something else must be done for the
> communication to work. The solution is then to include the IPv6=20
> Fragment
> extension header, so that the translator have a suitable Identificati=
on
> value to copy into the translated IPv4 header, and may therefore clea=
r
> the Don't Fragment flag, so that the IPv4 router will fragment the
> packet as it is forwarded onto the low-MTU link.
>=20
> In case you're interested, I have a slide deck below that explains th=
e
> use case for IPv4<->IPv6 translation. Slide 25 is about the particula=
r
> corner case where the allfrag feature is necessary. URL:
>=20
> http://fud.no/talks/20120417-RIPE64-The_Case_for_IPv6_Only_Data_Centr=
es.pdf


Hmm, but what if we change linux to choice a) instead of b) ?

That is, not cap mtu to minimum value 1280 (and not use anymore
RTAX_FEATURE_ALLFRAG) : dst_allfrag() would be always false.

In this case, do we still need to send the frag header ?

I ask this because some TSO6 implementations probably dont cope very
well with this added header (untested path)
