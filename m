From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Fri, 12 Sep 2003 09:06:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063354018.23778.376.camel@hades.cambridge.redhat.com>
References: <Pine.LNX.4.44.0309111928330.14358-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309111928330.14358-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-09-11 at 19:40 +0300, Pekka Savola wrote:
> > What's going to break is talking to _internal_ machines using our
> > locally-derived address. Our packets will get to them fine, over the
> > internal tunnels, but their route back to us will then be over the
> > Internet rather than through the internal tunnels, and hence it'll get
> > firewalled.
> 
> .. which is exactly why I proposed the above.  Breaking connectivity
> indicates that something is wrong.. better than communicating insecurely 
> while believing the communication is secure :-)

Er, if my workstation tries to talk to an internal machine using its
locally-derived (i.e. public) address, that _is_ going to break, since
the remote internal machine it going to send a reply which will be
routed externally, then blocked when it hits my local ingress-preventing
firewall. But you're right -- we should probably make it break earlier
if we can.

> > > Mobile IPv6 won't help with that, in practice.  That's because the binding 
> > > between care-of and home addresses must be secured.
> >  <...>
> > > So, this would create many new roundtrips, which is not really what you'd 
> > > want..
> > 
> > Well, the _initial_ connection would all be tunnelled, and the binding
> > would be set up in parallel, so that you end up routing optimally; just
> > going via the tunnel to start with. 
> 
> I don't see how that would be different from a VPN scenario, but yes; I
> guess if you deployed MIPv6 on every host, you could use it to communicate
> securely and in ad-hoc fashion between the mobile node and the home agent.  
> You could even forget about CIPE for v6. Mobile IPv6 requires IPv6
> connectivity too, though.  But I'm not sure if that buys you much in this 
> scenario.

You're right -- it would indeed be much like a VPN scenario. Except that
unlike an IPv4 VPN where your default route to a box two blocks away
goes via a transatlantic tunnel, it doesn't have to suck.

We accept the tunnelling-via-HQ overhead only for short-lived and
spurious connections; for long-term connections we ensure the remote
host to which we're talking actually updates its binding cache to know
our care-of address.

I don't really want to make every internal box do mobile-ipv6 for
_itself_, but I think it can be done by the local router on their
behalf.

The office router sits between the internal IPv6-capable hosts and the
outside world. It uses radvd to advertise the 'home' addresses, and also
takes care of setting up care-of addresses for the internal boxen, with
any remote hosts they seem to make a habit of talking to. 

That way, we get _outgoing_ packets to travel directly, while _incoming_
packets sometimes go via HQ and a tunnel, but in the cases we care
about, where we're exchanging a lot of packets with a particular remote
host, they'll end up going directly. 

All the alternatives, apart from the first 'use site-local addresses for
internal operation, global-scope addresses for external', are looking
fairly complex and fragile, to be honest.

Part of me wants to say 'Sod it', and assume that site-local scope isn't
going to actually be abolished, since doing so seems to be _such_ a bad
idea once you try to work around its absence.

-- 
dwmw2
