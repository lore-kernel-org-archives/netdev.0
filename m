From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Thu, 11 Sep 2003 00:42:50 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309110009430.4932-100000@netcore.fi>
References: <1063226945.7869.325.camel@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063226945.7869.325.camel@imladris.demon.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Sep 2003, David Woodhouse wrote:
> On Wed, 2003-09-10 at 21:52 +0300, Pekka Savola wrote:
> > Please don't do this, this is an ambomination.  Moreover, some time ago 
> > the IETF decided to Deprecate Site-local addresses completely, because of 
> > their problems.
> 
> Hmmm; bugger. 
> 
> I thought the site-local address concept was great. It was going to
> allow us to keep external connectivity issues completely separate from
> internal ones.

Yep, but it has some fatal flaws (ambiguity, leading to a lots of
difficult issues), and in the end, it's just not any more secure method
than filtering.
 
> So is there still a range of IPv6 addresses analogous to the RFC1918
> IPv4 ranges, which are purely internal-only? Or is everyone expected to
> just use 'real' IPv6 addresses, and firewall appropriately?

There are no RFC1918 analogous addresses at the moment.  Current status is 
that there is work in progress to figure out the requirements for local 
communications, and one potential outcome of that might be a globally 
unique or near-unique addressing, meant for local use only.

But in the meantime (and still), I think it's better to go with globals if 
at all possible.  That's what IPv6 was for, anyway.. :-)
 
> I'll lay our our situation in a bit more detail... I don't think it's
> too uncommon. 
> 
> We have a corporate IPv4 network. Multiple locations each have 'real'
> IPv4 connections to local ISPs; we have a network of CIPE tunnels
> between physical locations, over which we run the 172.16/12 IPv4
> network. Internal boxen communicating to the outside world go via local
> NAT, of course.

How many multiple locations are out there?  Which methods you use locally, 
are Ethernet switches and VLAN's being used (if so, does a location have 
multiple VLAN's, e.g. for engineering, marketing etc.)?  
 
> We want to deploy IPv6 internally. We have no overriding corporate
> reason for doing this; for getting the IT people to spend their time on
> it and overhaul all the CIPE boxes to be IPv6-capable, etc. It'll just
> be useful for testing purposes, and because -- let's face it -- we're
> geeks and we want IPv6 :)

Right.
 
> Our criteria are these:
>  - To connect between two internal hosts by IPv6 should not be
>    noticeably less reliable, or slower, than the existing IPv4.
> 
>  - The setup should be as simple as possible, and to as large an extent
>    as possible should not require infrastructure changes.
> 
>  - Connectivity to the _outside_ should go as directly as possible;
>    not all via a single tunnel endpoint in headquarters. 
> 
>  - Security must be obvious. The IT people don't have time to spend on
>    it; that includes auditing. Using site-local addresses and then doing
>    NAT to the outside world, or using public addresses arranged
>    individually for each location and then connection-tracking to allow
>    only outgoing connections as _if_ it were behind NAT, is obviously
>    correct. Anything else is significantly less obvious.
> 
> Using 6to4 for internal site-scope addresses would have given us direct
> connection between individual machines -- no points of failure which
> aren't already a point of failure for IPv4; unlike a scenario where we
> have a single tunnel-concentrator somewhere. This gives us the speed and
> reliability required in our first criterion, and also a trivial
> configuration. No big lists of tunnel endpoints, etc. 
> 
> Then global addresses could just have been arranged with an appropriate
> connection in each location and a connection-tracking firewall.
> 
> It was all nice and simple...
> 
> Now I'm going back to the drawing-board. If the distinction between
> site-scope and global-scope is gone, then I suppose one possibility is
> to muck around with destination-based source address selection to
> achieve the same effect. Something like giving each internal machine two
> global IPv6 addresses -- one in the 2002:ac10::/28 range, and one 'real'
> globally-routable address. 

Note that 6to4 specification explicitly disallows the use of 6to4 on
private addresses.  No such checks have been added to Linux kernel (should
be..), but you're likely to face more or less trouble if you do so.
 
> Then we configure them such that for communicating with other hosts in
> 2002:ac10::/28 they use that address, and for communicating with 'real'
> hosts, they use the 'real' address. How feasible is that?

IPv6 default address selection, implemented and merged in 2.4 kernels, 
should already do that.  In principle, there is the policy table and and 
longest prefix match, which should be able to achieve something like this 
without a problem.

One problem may be the destination address selection of getaddrinfo().  
Glibc might not implement default address selection (RFC3484) yet.
 
> We may end up with the internal hosts sticking packets for 'real'
> 2002::/16 6to4 addresses inside IPv4 packets and sending them somewhere,
> but since we control '$somewhere' and it's not hard-coded to 
> 192.88.99.1 we can deal with that -- as long as they're correctly using
> their 'real' IPv6 addresses as the source. 
> 
> My main objection to this, although I think it can work and be secure,
> is that it requires _thought_ to show it's secure. It really needs to be
> obvious.
> 
> A second possibility, perhaps, would be to just get 'real' IPv6 networks
> in all the locations, and route that publicly with connection-tracking
> firewalls on the public-facing machines. Then to effectively punch holes
> in those firewalls for 'internal' communication, by using
> explicitly-configured tunnels to bypass the firewalls.

Right.
 
> That one seems nicer, but has the severe disadvantage that we can't just
> start doing it internally over the existing IPv4 network -- we have to
> actually make changes to the network infrastructure, which means getting
> real time (and downtime) allocated for it up front. Which is unlikely
> for what's effectively a Skunkworks project.

Note that one could do a 6to4 router per site, per global address; 
obtaining  such connectivity might be easier than "real", but one would 
still not run it over CIPE tunnels.
 
> Better suggestions are welcomed.

First of all, if the number of participating sites would be relatively 
low, one could set up one "tunnel router" in each location, which would 
have:
 a) optionally global IPv6 connectivity, if desired, and
 b) manually configured tunnels to the other tunnel routers, over CIPE 
private address infrastructure

It would not need to be a full mesh, only to such a degree that the 
traffic would be rather optimal, and it would not create more failure 
modes (e.g. do that on the same boxes as CIPE tunneling).

After that, what you'd be left with is how to deal with IPv6 connectivity 
internally in each of these sites.  Depending on what kind of routers you 
use this could be trivial (e.g. if linux, just turn on IPv6, radvd and 
such) or not.

You might do this with global IPv6 addresses, obtained from an ISP, a 
6bone party, or derived from 6to4 addresses of one or more of your public 
IP's (for example, every site could have one global address).

The security properties are straightforward.  In all of your border 
routers/firewalls, block ip-protocol-41 (used for IPv6-in-IPv4 tunneling). 
As you don't have native IPv6 connectivity to your ISPs, those are the 
only ways someone might gain IPv6 access to your enterprise Internal 
network.

But you want to refine that; it could be done by IPv6 firewalling at the 
routers which you specifically allow through from your border 
"ip-protocol-41 denied" -check.  By ensuring you've proper controls in 
place in those networks, there is no leakage.

One another option is to deploy ISATAP, which I mentioned earlier (note:  
requires patches to the kernel and iputils).  This is useful because it's
a tunneling method like 6to4, but aimed mainly for host-to-host internal
connectivity, also working over private addresses.  By deployingISATAP
within your enterprise, you would not need "tunnel routers" described
above, except for global IPv6 Internet connectivity (when desired), or
native IPv6 deployment (or something) within the geographical sites.

FWIW, Microsoft's internal network is using ISATAP heavily to enable IPv6 
access.

To summarize, I think there are several tradeoffs to consider, including:
 - the difficulty of deploying IPv6 within a geographical site, given that 
such a site would somehow get IPv6 connectivity,
 - the number of geographical sites which need to be connected in a meshed 
fashion (number is probably the same or a bit less than the number of your 
CIPE tunnels,
 - the time how quickly you want to get started, and how easy it should be 
for anyone at all to start using IPv6 (ISATAP could be the quickest fix)
 - the duration how long-lived solution you're desiring (ISATAP is 
short-term fix only, tunnel routers and native IPv6 inside sites is closer 
to what mid-long term goals, and
 - how much global IPv6 connectivity you desire (IPv6 firewalling 
requirements..), and how optimized it should be.

As for how we're doing it in a 150+ person, single site enterprise 
consisting of multiple networks -- we employ "tunnel router" method and to 
some degreee Ethernet VLAN's to inject IPv6 to the physical segments.
We use only global IPv6 addresses, and the reachability is obtained from 
the national research network we run (native IPv6).  We use some IPv6 
firewalling; not much on typical users' networks (those computers don't 
have many services listening for IPv6!), and stricter filters on 
administrators' network.

HTH

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
