From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6 tunnels
Date: Wed, 3 Sep 2003 19:57:56 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309031515500.5039-100000@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0309031444190.16329-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>,
   <davem@redhat.com>, <usagi-core@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309031444190.16329-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2003, Pekka Savola wrote:

> On Wed, 3 Sep 2003, Ville Nuorvala wrote:
> >
> > The other end of the tunnel might not yet be set up to receive the packet,
> > which causes an ICMP error message to be sent back to the sender.
> >
> > Besides, RS and RA over a ipv6-in-ipv6 tunnel is a _bad_ idea. A default
> > route through a tunnel without more advanced (policy/flow/srcaddr/? based)
> > routing schemes can lead to local routing loops.
>
> Who are you to say it's a bad idea?

Someone who has been tackling with the issue of default routes through
tunnel interfaces in MIPL (our MIPv6 for Linux implementation) for quite
some time now ;)

> Users may have a lot of ideas, which some may think are bad but are OK.

Well, I did already mention routing loops (and ICMP errors caused by IPv6
encapsulated RSs on a virtual link that isn't up yet). I think that
qualifies as bad enough :(

> There is nothing wrong with RS/RA over an IPv6-over-IPv6 tunnel.  I'd
> probably be concerned myself if it wasn't possible.

Who says it isn't possible? The user who thinks he knows better can change
the accept_ra (and rtr_solicits) flag for the tunnel dev and start
receiving RAs through it.

> _However_, that doesn't make sense unless you have a more specific route
> to the destination IPv6 tunnel endpoint.

Yes, exactly. And what should the node do if it just has two default
routes, one through a tunnel and one through an ethernet interface? This
will be the case if a normal host receives RAs through both interfaces.

At least two things can go wrong:
1) A packet intended to the tunnel is sent straight through the ethernet
   device
2) A packet already encapsulated by the tunnel is rerouted through it and
   is thus dropped

Based on my own experiences, I can say things like this do happen.

> At the moment, I don't know who'd like to get a default IPv6 route over an
> IPv6 tunnel, though.. IPv6 VPN users?  MIPv6 users who restrict themselves
> to bidirectional tunneling through the home agent, maybe?

In MIPL, the MN uses a "default" ::/0 route through the IPv6 tunnel, but
it is only used for packets using the MN's home address as source. All
other traffic (including packets already encapsulated by the IPv6 tunnel,
thus having the care-of address as source) is routed normally through the
physical device.

Things like this aren't possible in the current IPv6 routing code, so I
had to modify the route lookup so it first checks the source address of
the packet, then the destination.

I sent a patch for this source address based routing, but it didn't make
it into the kernel, partly because the USAGI team has plans to introduce
IPv6 policy routing, which should also fix the problems.


-Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
