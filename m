From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Thu, 15 Jan 2004 10:46:26 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401150843320.28594@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0401150745390.9658-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yoshfuji@linux-ipv6.org, davem@redhat.com, usagi-core@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0401150745390.9658-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2004, Pekka Savola wrote:

> > The current proxy ND implementation in the kernel only captures multicast
> > NS messages. A unicast NS (i.e. a NUD probe) won't be captured by the
> > proxy, in stead it tries to _route_ it to the proxied node.
>
> Practically all ND packets should be proxied, I think.

Currently the specification (RFC 2461) only talks about NS packets, but I
agree. It seems logical for a proxy to handle all ND messages.

Whats the status of RFC 2461bis? Can we still ask for further
clarifications about the proxy behavior?

> [...]
> > The traditional proxy described in RFC 2461 is a router, what Thaler
> > describes is closer to a bridge. The protocol described in Thaler's draft
> > can't rely on routing for what it is doing, in stead it must AFAICS bypass
> > the routing altogether, either inside the kernel, or by pushing the
> > traffic through user space.
>
> No, Thaler's ND proxy is *not* a bridge; functionally, it's quite
> close, but from the implementation perspective, it's not.  All the
> communication terminates (at the IP layer) at the ND proxy (and that's
> why the TTL won't decrease, because practically the same request is
> replicated on the other links with TTL=255).  Therefore, it can act as
> a "router"  between two physical links, and the users of the links can
> still use e.g. link-local addresses.

I was talking about it from the functional point of view (and I didn't
actually call it a bridge ;)

My reasoning here is that Thaler's proxy passes IPv6 packets (except ND
etc) unchanged from one physical link to another, therefore it isn't a
router, but closer to a bridge.

The point is just that. We can't use the *routing* functionality to pass
the packet from one physical segment to another.

As I mentioned routing link-locals isn't possible, neither is routing of
multicast packets (at this moment), a router just forwards a packet to one
interface, not all of them, and last but not least, a router decreases the
hop limit of a forwarded packet.

This means we need some other mechanism than *routing* to achieve the
functionality in Thaler's draft.

> ND proxy doesn't "route" between physical segments, because by
> definition, all the physical segments share a subnet, and there are no
> specifics. On the other hand, it duplicates all ICMPv6 ND packets
> across the links (unless there is a mapping in a cache), and expands
> the IP layer subnet (even, the link-local address domain!) to span
> multiple links.

Exactly! Thaler's proxy doesn't route traffic, the MIPv6 proxy does. They
are not the same thing. My change allows a router (MIPv6 HA) to
correctly signal that it can't *route* a link-local packet.

There are IMO two different uses of proxy ND, which are quite different
from each other:

We have the Thaler proxy, with its "bridge" like behavior. It acts as a
proxy for *any* address on the subnet (if needed), and passes IP packets
between the interfaces unchanged.

Then we have the router (for example HA) acting as a proxy for a
*particular* node (for example MN) *routing* packets to it.

> Proxying link-locals break fully ND proxying.  I grant you that it may
> not work out of the box at the moment (because it hasn't been
> implemented! :-) but we shouldn't be making steps in the wrong
> direction here.. :-)

AFAICS a Thaler proxy would forward the packet using some other path than
ip6_forward(), therefore it wouldn't trigger the ICMP error message.

I'm not sure how proxy ARP is done in Linux, but I don't know if the
current proxy ND code is of any use for Thaler proxy.

The proxied addresses are explicitly stored in the nd_tbl and the proxy
relies on routing to get the packets delivered to the proxied node. This
is exactly what a HA should do, but it doesn't fit well into the Thaler
model.

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
