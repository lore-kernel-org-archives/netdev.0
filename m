From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Wed, 10 Sep 2003 23:43:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063233839.7869.385.camel@imladris.demon.co.uk>
References: <Pine.LNX.4.44.0309110009430.4932-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309110009430.4932-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-09-11 at 00:42 +0300, Pekka Savola wrote:
> Yep, but it has some fatal flaws (ambiguity, leading to a lots of
> difficult issues), and in the end, it's just not any more secure method
> than filtering.

S'true -- it wasn't any more secure. But it was more obviously secure :)

It's just multihoming with non-publicly-routable addresses used for the
unfirewalled internal communication, and real public addresses used for
external communication. But unlike 'just' multihoming, the fact that the
dichotomy between site-scope and global-scope was fundamental to IPv6
make it nice and easy to separate 'site' and 'global' and consider them
separately.

Of course, you can do much the same thing manually, but showing that
it's secure is, to use Piagetian terms, much more of a formal operation
than a concrete one. :)

> But in the meantime (and still), I think it's better to go with globals if 
> at all possible.  That's what IPv6 was for, anyway.. :-)

Ok... that may well be the way ahead.
 
> How many multiple locations are out there?  Which methods you use locally, 
> are Ethernet switches and VLAN's being used (if so, does a location have 
> multiple VLAN's, e.g. for engineering, marketing etc.)?  

I'd guess at 20-30 offices worldwide, many more individual remote
employees on point-to-point CIPE links.

Using global IPv6 addresses obtained locally at each site, we'd end up
having to keep a big list of IPv6 subnets which are 'ours', and the
corresponding internal IPv4 address to which they should be routed --
over the CIPE to ensure encryption and also to bypass the firewalls
which will prevent ingress to each site from other external machines.

I was trying to avoid that, since we have sufficient sites that it would
be a pain.

> Note that 6to4 specification explicitly disallows the use of 6to4 on
> private addresses.  No such checks have been added to Linux kernel (should
> be..), but you're likely to face more or less trouble if you do so.

You mean 2002:ac10::/28 et al.? As long as they remain private (to the
same networks where we actually have 172.16/12 IPv4, there shouldn't be
any _practical_ problem. 

After all, it's just a configuration-shorthand for the 2^20 explicit
IPv6-in-IPv4 tunnels which would do the same thing, surely?

We just have to make sure we don't leak those addresses to the outside
world -- but that's why the boxes with 'real' IPv6 are multihomed and
that's why we care about appropriate source address selection for them.
And hence why we care that site-scope went away, which would have made
it a no-brainer.

> > Then we configure them such that for communicating with other hosts in
> > 2002:ac10::/28 they use that address, and for communicating with 'real'
> > hosts, they use the 'real' address. How feasible is that?
> 
> IPv6 default address selection, implemented and merged in 2.4 kernels, 
> should already do that.  In principle, there is the policy table and and 
> longest prefix match, which should be able to achieve something like this 
> without a problem.
> 
> One problem may be the destination address selection of getaddrinfo().  
> Glibc might not implement default address selection (RFC3484) yet.

Hmmm. That sounds reasonable. But I'd be accepting the complexity of
multihoming, for the benefit of avoiding the explicit per-site tunnel
configuration. To be honest, I think I'd rather take the exponential
per-site configuration, and use unique global IPv6 addresses. At least
that's only monkey-work, and the failure modes are simpler and more
obvious.

I wonder if Mobile-IPv6 can give us something more conceptually simple.

The reason we don't just assign a 'real' IPv6 subnet to headquarters,
and run it all over a network of tunnels internally, is because latency
to a site just down the road would suck, since the IPv6 packets would
cross the Atlantic twice -- across the tunnel in the CIPE link to HQ and
then back out again.

If we were to start that way, but then add real IPv6 connectivity to
individual sites, then use the direct IPv6 addresses as 'care-of'
addresses for Mobile-IP, I wonder if we could keep the nice simple "We
own this network and it's not firewalled for internal use and it's
tunnelled over CIPE" concept, while keeping fairly sane routing for
connections to the outside world?

I think I need to actually read the Mobile-IP documentation in the
morning, and see whether the above makes any sense at all.

> Note that one could do a 6to4 router per site, per global address; 
> obtaining  such connectivity might be easier than "real", but one would 
> still not run it over CIPE tunnels.

True. But even if we could solve the _actual_ security problem that
entails, by enforcing use of IPSEC on such links, it wouldn't fly...
CIPE good and trusted; Internet bad. 
 
> > Better suggestions are welcomed.

Hmmm. Much useful information there; thanks. I don't think I can do it
justice tonight so I'll take a closer look in the morning. Certainly
there are plans beginning to come together, using global IPv6 addresses
and an explicit mesh of tunnels. And falling back to 2002:ac10::/28 or
ISATAP where global IPv6 addresses aren't (yet) obtainable at individual
sites.

-- 
dwmw2
