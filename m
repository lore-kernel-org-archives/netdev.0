From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Thu, 11 Sep 2003 10:49:08 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309111000110.9818-100000@netcore.fi>
References: <1063233839.7869.385.camel@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063233839.7869.385.camel@imladris.demon.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Sep 2003, David Woodhouse wrote:
> On Thu, 2003-09-11 at 00:42 +0300, Pekka Savola wrote:
> > Yep, but it has some fatal flaws (ambiguity, leading to a lots of
> > difficult issues), and in the end, it's just not any more secure method
> > than filtering.
> 
> S'true -- it wasn't any more secure. But it was more obviously secure :)
>

I'm not sure of that; I'd agree if you said "it _seems_ more obviously 
secure", but I don't think that's real..

> It's just multihoming with non-publicly-routable addresses used for the
> unfirewalled internal communication, and real public addresses used for
> external communication. But unlike 'just' multihoming, the fact that the
> dichotomy between site-scope and global-scope was fundamental to IPv6
> make it nice and easy to separate 'site' and 'global' and consider them
> separately.

Yep, but once you break into just one box w/ global addresses, all of the 
site-internal infrastructure is open to you.  This seems like a high price 
to pay, with many points of failure.

But from the operational perspective, I certainly agree that having one 
range of local addesses (well, they can even be global addresses) would 
simplify the management for internal communications, especially if the 
real IPv6 addresses tend to change (leading to internal renumbering events 
etc.).  That's something that should be avoided.
 
> Of course, you can do much the same thing manually, but showing that
> it's secure is, to use Piagetian terms, much more of a formal operation
> than a concrete one. :)

Yes; but I fail to see how much more secure using "local addressing" is 
than by just ensuring in your border routers (or other firewalls) that the 
addresses meant for local communications don't leak out, AND that nobody 
uses your internal source addresses in the packets coming from the 
Internet. (Rather basic site perimeter protections.)

> > How many multiple locations are out there?  Which methods you use locally, 
> > are Ethernet switches and VLAN's being used (if so, does a location have 
> > multiple VLAN's, e.g. for engineering, marketing etc.)?  
> 
> I'd guess at 20-30 offices worldwide, many more individual remote
> employees on point-to-point CIPE links.

Ok.
 
> Using global IPv6 addresses obtained locally at each site, we'd end up
> having to keep a big list of IPv6 subnets which are 'ours', and the
> corresponding internal IPv4 address to which they should be routed --
> over the CIPE to ensure encryption and also to bypass the firewalls
> which will prevent ingress to each site from other external machines.

Does each site also have IPv4 Internet connectivity in addition to the 
private addresses?

If not ("some smaller ones go through a larger site"), this may not be a 
problem.

If yes, there may be a need to run an IPv6 routing protocol between the 
sites; this would easily keep track of local prefixes, but this would not 
work for access lists and firewall filters.

One possible solution is to pick one (or a couple of) major sites which 
provide "internal connectivity addresses".  For example, assume you have 
the big HQ in the US.  Deploy on each node:

 - IPv6 connectivity addresses, obtained using 6to4 or the like, and
 - IPv6 addesses from the HQ block.

The latter are only used for internal connectivity through CIPE tunnels;  
the former would be used to reach IPv6 Internet (without a need to go
through the HQ and from there to the Internet).

The potential issue here is the source address selection, so that the 
hosts don't pick the HQ addresses when they try to reach to IPv6 sites in 
the Big Internet (so that the packets don't route back through the HQ).
 
> > Note that 6to4 specification explicitly disallows the use of 6to4 on
> > private addresses.  No such checks have been added to Linux kernel (should
> > be..), but you're likely to face more or less trouble if you do so.
> 
> You mean 2002:ac10::/28 et al.? As long as they remain private (to the
> same networks where we actually have 172.16/12 IPv4, there shouldn't be
> any _practical_ problem. 
> 
> After all, it's just a configuration-shorthand for the 2^20 explicit
> IPv6-in-IPv4 tunnels which would do the same thing, surely?

It's a bit more than that, even though Linux kernel only implements the 
very basics of the specification.  See RFC3056 section 9 last paragraph.
 
> > > Then we configure them such that for communicating with other hosts in
> > > 2002:ac10::/28 they use that address, and for communicating with 'real'
> > > hosts, they use the 'real' address. How feasible is that?
> > 
> > IPv6 default address selection, implemented and merged in 2.4 kernels, 
> > should already do that.  In principle, there is the policy table and and 
> > longest prefix match, which should be able to achieve something like this 
> > without a problem.
> > 
> > One problem may be the destination address selection of getaddrinfo().  
> > Glibc might not implement default address selection (RFC3484) yet.
> 
> Hmmm. That sounds reasonable. But I'd be accepting the complexity of
> multihoming, for the benefit of avoiding the explicit per-site tunnel
> configuration. To be honest, I think I'd rather take the exponential
> per-site configuration, and use unique global IPv6 addresses. At least
> that's only monkey-work, and the failure modes are simpler and more
> obvious.

Ok.
 
> I wonder if Mobile-IPv6 can give us something more conceptually simple.
> 
> The reason we don't just assign a 'real' IPv6 subnet to headquarters,
> and run it all over a network of tunnels internally, is because latency
> to a site just down the road would suck, since the IPv6 packets would
> cross the Atlantic twice -- across the tunnel in the CIPE link to HQ and
> then back out again.

Right, you need to optimize the latency, no need to circulate everything 
through the HQ.
 
> If we were to start that way, but then add real IPv6 connectivity to
> individual sites, then use the direct IPv6 addresses as 'care-of'
> addresses for Mobile-IP, I wonder if we could keep the nice simple "We
> own this network and it's not firewalled for internal use and it's
> tunnelled over CIPE" concept, while keeping fairly sane routing for
> connections to the outside world?
> 
> I think I need to actually read the Mobile-IP documentation in the
> morning, and see whether the above makes any sense at all.

Mobile IPv6 could be leveraged for you, sure.  However, you seem to
require just one basic feature of MIPv6: tunneling back to Home (Agent).  
The same can be established through CIPE tunnels.  This is similar to my
thought, above, of deploying both IPv6 Internet connectivity ("care-of
address") and local HQ addressing ("home address") to all the nodes.

For security, you would then have to ensure that the "local HQ addresses" 
don't leak and are properly firewalled.
 
> > Note that one could do a 6to4 router per site, per global address; 
> > obtaining  such connectivity might be easier than "real", but one would 
> > still not run it over CIPE tunnels.
> 
> True. But even if we could solve the _actual_ security problem that
> entails, by enforcing use of IPSEC on such links, it wouldn't fly...
> CIPE good and trusted; Internet bad. 

Agree.

> > > Better suggestions are welcomed.
> 
> Hmmm. Much useful information there; thanks. I don't think I can do it
> justice tonight so I'll take a closer look in the morning. Certainly
> there are plans beginning to come together, using global IPv6 addresses
> and an explicit mesh of tunnels. And falling back to 2002:ac10::/28 or
> ISATAP where global IPv6 addresses aren't (yet) obtainable at individual
> sites.

It should be easy to get global IPv6 addresses at most individual sites, 
because it only requires a public IPv4 address to activate 6to4, which is 
enough.  Other connectivity is also of course possible, and even desirable 
in the long term, especially for bigger sites.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
