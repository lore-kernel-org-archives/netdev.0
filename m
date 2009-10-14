From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
	sockets, and for IPv4 multicast forwarding
Date: Wed, 14 Oct 2009 11:33:39 -0700
Message-ID: <55a4f86e0910141133y4decdeb4v43d9168687bbb724@mail.gmail.com>
References: <20091007.223928.34412707.davem@davemloft.net>
	 <55a4f86e0910140051v69441b09gd364b32f8e2d0c68@mail.gmail.com>
	 <20091014072319.GA12095@fogou.chygwyn.com>
	 <20091014.021505.181431380.davem@davemloft.net>
	 <55a4f86e0910140250o45532dabr33707c025dfa25f9@mail.gmail.com>
	 <20091014092743.GA13374@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, atis@mikrotik.com,
	netdev@vger.kernel.org, panther@balabit.hu, eric.dumazet@gmail.com,
	brian.haley@hp.com
To: steve@chygwyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:61857 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756482AbZJNSeQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 14:34:16 -0400
Received: by fxm27 with SMTP id 27so74935fxm.17
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 11:33:39 -0700 (PDT)
In-Reply-To: <20091014092743.GA13374@fogou.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't agree. There are two route lookups with a tunnel, the
> internal one and the tunnel one. Here is an example of what I'm
> thinking:
>
> 1. Look up a route which points at a remote ip addres via a tunnel de=
vice.
> =C2=A0 The "setmark" on this route sets the skb mark

imho, this is much better done by having the mark setting performed
explicitly by the tunnel device itself.
That's also were we set ttl and qos (or inherit) on the outgoing packet=
).

> 2. Look up a route on the tunnel itself (i.e. the tunnel endpoint not
> =C2=A0 the socket endpoint) using the mark from the initial lookup. T=
his
> =C2=A0 route can depend on the previous lookup (if there are multiple
> =C2=A0 routes for multiple marks) and also set the mark to use.

we would get the mark set by the tunneling module here.

> The default would be to inherit the mark over a route lookup, in
> case that no "setmark" had been specified for that route. In
> other words, it would be the same as it is now.

I'm not saying your solution wouldn't work, but I think it's less
clean.  I don't think marking should be inherited (in the general
case) in case of packet wrapping (whether via gre, ipip, sit, or other
methods).

> The mark is supposed to be a generic thing, not just for routing
> lookups, it can be used for classification, etc as well. I would
> expect to see such a thing used for maybe specifying a VLAN or
> a reference to an MPLS label stack, or something similar too,

Right, the mark can currently (as far as I know) be set in one of two
ways - either from the mangle table (and it can also be matched on in
netfilter) or by using setsockopt(SO_MARK).

Imagine a situation where you have a machine with routing already
configured (pretty complex setup, tunnels, firewalls, etc) and you
want to run a user space application that verifies (health-checks)
some remote host (or something).  As part of the health check you want
to verify a particular route to the destination.  This requires
per-socket routing, which can (almost) be achieved by having proper
routing (on fwmark) setup and using setsockopt(SO_MARK) on the health
check socket in order to force specific routing.  These health checks
may then of course be feedback into the routing system (ie. if they
fail the routing rules get modified).  Note, that in particular we may
want to be healthchecking routes that aren't even available in the
default routing table (because they've currently been removed from the
default table, because previous health checks failed).

Maciej
