From: Tore Anderson <tore@fud.no>
Subject: Re: [PATCH net-next] ipv6: =?UTF-8?Q?RTAX=5FFEATURE=5FALLFRAG=20c?=  =?UTF-8?Q?auses=20inefficient=20TCP=20segment=20sizing?=
Date: Wed, 25 Apr 2012 11:20:01 +0200
Message-ID: <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
References: <1335289058.5205.165.camel@edumazet-glaptop>
 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
 <1335298228.5205.168.camel@edumazet-glaptop>
 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
 <1335331960.5205.180.camel@edumazet-glaptop>
 <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:55619 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757474Ab2DYJlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 05:41:19 -0400
In-Reply-To: <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Maciej =C5=BBenczykowski

>> But we chose to _not_ decrease mtu and adhere to the specs.
>
> I get that we _choose_ to behave such, and I agree this adheres to
> specs.

"Chose" (past), not "choose" (present). ;-)

This patch does not make this choice. This patch merely fixes a bug in
the implementation of the choice that was made a long time ago.

> But I'm not convinced that (even though this is allowed per RFC) this
> is the right choice.

That is a different issue entirely, but I don't disagree with you. A
"min_pmtu" sysctl or something like that would be useful.

> Also note that IPv6 prefers to see fragmentation happen at the end
> hosts, and not at the routers.
> Although of course it doesn't treat a tunnel end point as a router.

Actually, in IPv6, fragmentation *must* be performed by end hosts,
routers (including tunnel end points) *cannot* fragment.

However, the use case for the allfrag feature is not handling tunnels,
but IPv4<->IPv6 translation. The issue is that a IPv6 host may very=20
well
receive an ICMPv6 Packet Too Big indicating a PMTU of <1280 that was
originally transmitted by an IPv4 router (as an ICMPv4 Need To=20
=46ragment)
and underwent translation to IPv6.

In this case, the IPv6 node does not need to reduce the PMTU to <1280
(Linux does not), but it is not invalid to have a <1280 MTU link in the
IPv4 internet either, so something else must be done for the
communication to work. The solution is then to include the IPv6=20
=46ragment
extension header, so that the translator have a suitable Identification
value to copy into the translated IPv4 header, and may therefore clear
the Don't Fragment flag, so that the IPv4 router will fragment the
packet as it is forwarded onto the low-MTU link.

In case you're interested, I have a slide deck below that explains the
use case for IPv4<->IPv6 translation. Slide 25 is about the particular
corner case where the allfrag feature is necessary. URL:

http://fud.no/talks/20120417-RIPE64-The_Case_for_IPv6_Only_Data_Centres=
=2Epdf

Tore
