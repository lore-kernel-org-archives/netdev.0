From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Thu, 15 Jan 2004 11:27:26 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401151053410.11998-100000@netcore.fi>
References: <Pine.LNX.4.58.0401150843320.28594@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yoshfuji@linux-ipv6.org, <davem@redhat.com>, <usagi-core@linux-ipv6.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0401150843320.28594@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2004, Ville Nuorvala wrote:
> On Thu, 15 Jan 2004, Pekka Savola wrote:
> 
> > > The current proxy ND implementation in the kernel only captures multicast
> > > NS messages. A unicast NS (i.e. a NUD probe) won't be captured by the
> > > proxy, in stead it tries to _route_ it to the proxied node.
> >
> > Practically all ND packets should be proxied, I think.
> 
> Currently the specification (RFC 2461) only talks about NS packets, but I
> agree. It seems logical for a proxy to handle all ND messages.
> 
> Whats the status of RFC 2461bis? Can we still ask for further
> clarifications about the proxy behavior?

It's still at the starting phase -- now would be an excellent time to 
bring this up.

> My reasoning here is that Thaler's proxy passes IPv6 packets (except ND
> etc) unchanged from one physical link to another, therefore it isn't a
> router, but closer to a bridge.

Router only modifies the TTL.  Bridges do not respond to any Neighbor
Discovery (RFC2461) packets.. so it's not as clear as that.
 
> The point is just that. We can't use the *routing* functionality to pass
> the packet from one physical segment to another.

Yep.
 
> As I mentioned routing link-locals isn't possible, neither is routing of
> multicast packets (at this moment), a router just forwards a packet to one
> interface, not all of them, and last but not least, a router decreases the
> hop limit of a forwarded packet.
> 
> This means we need some other mechanism than *routing* to achieve the
> functionality in Thaler's draft.

Totally agree here.
 
> > ND proxy doesn't "route" between physical segments, because by
> > definition, all the physical segments share a subnet, and there are no
> > specifics. On the other hand, it duplicates all ICMPv6 ND packets
> > across the links (unless there is a mapping in a cache), and expands
> > the IP layer subnet (even, the link-local address domain!) to span
> > multiple links.
> 
> Exactly! Thaler's proxy doesn't route traffic, the MIPv6 proxy does. They
> are not the same thing. My change allows a router (MIPv6 HA) to
> correctly signal that it can't *route* a link-local packet.

The change may allow that signalling, but breaks the correct behaviour 
in general.

Note that MIPv6 spec just states that link-locals MUST NOT be
_tunneled_ to the mobile node, and site-locals SHOULD NOT.  It's still
fine to proxy for them (but discard them).  With L bit set, the HA is
just performing "DAD protection" for the address, with the intent to
discard the traffic.  Without L bit set, the HA is not supposed to do
even that.  As a matter of fact, it doesn't know the link-local
address of the MN in the first place.

So, it seems to be that the MIPv6 proxy should get the IP address to
proxy as an argument (put in nd_tbl or whatever), and it would just
proxy those addresses, and no change (like the one you proposed,
disallowing link-local proxying) would be needed.   So, with MIPv6 L=0 
link locals would not be entered in nd_tbl, so they would not be 
proxied; with MIPv6 L=1, link-locals would be entered in nd_tbl, but 
the packets would get discarded before they end up being tunneled to 
the MN.

Right?

> There are IMO two different uses of proxy ND, which are quite different
> from each other:
> 
> We have the Thaler proxy, with its "bridge" like behavior. It acts as a
> proxy for *any* address on the subnet (if needed), and passes IP packets
> between the interfaces unchanged.
> 
> Then we have the router (for example HA) acting as a proxy for a
> *particular* node (for example MN) *routing* packets to it.
> 
> > Proxying link-locals break fully ND proxying.  I grant you that it may
> > not work out of the box at the moment (because it hasn't been
> > implemented! :-) but we shouldn't be making steps in the wrong
> > direction here.. :-)
> 
> AFAICS a Thaler proxy would forward the packet using some other path than
> ip6_forward(), therefore it wouldn't trigger the ICMP error message.

It can give back ICMP error messages, if necessary.  I don't know 
which path a Thaler proxy would use though.

> I'm not sure how proxy ARP is done in Linux, but I don't know if the
> current proxy ND code is of any use for Thaler proxy.

It's a start, I think :-)
 
> The proxied addresses are explicitly stored in the nd_tbl and the proxy
> relies on routing to get the packets delivered to the proxied node. This
> is exactly what a HA should do, but it doesn't fit well into the Thaler
> model.

Yep, because there is no more specific route -- in the Thaler case, 
"querying whether the node exists on other physical links" gives the
more specific information ("route" of a kind). It's not really that 
different in my eyes..

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
