From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Thu, 11 Sep 2003 13:48:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063284516.23778.152.camel@hades.cambridge.redhat.com>
References: <Pine.LNX.4.44.0309111000110.9818-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309111000110.9818-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-09-11 at 10:49 +0300, Pekka Savola wrote:
> > S'true -- it wasn't any more secure. But it was more obviously secure :)
> 
> I'm not sure of that; I'd agree if you said "it _seems_ more obviously 
> secure", but I don't think that's real..

That's what I meant to say. It's the difference between "Can we do
this?" "Yes go ahead." and "Can we do this?" "Er, not sure. Hence no."

> Yep, but once you break into just one box w/ global addresses, all of the 
> site-internal infrastructure is open to you.  This seems like a high price 
> to pay, with many points of failure.

Well yes, but that's _already_ the cases for boxen on the internal
RFC1918 IPv4 network. If you own one, you have access to them all. 

That's why we'd want outgoing-connections-only for all the internal IPv6
machines, just as they have in the IPv4 world by virtue of being behind
NAT.

We don't _need_ public IPv6 addresses for them; if we could NAT for them
at each site to that site's publicly-routable IPv6 address range, that
would be fine. 

> One possible solution is to pick one (or a couple of) major sites which 
> provide "internal connectivity addresses".  For example, assume you have 
> the big HQ in the US.  Deploy on each node:
> 
>  - IPv6 connectivity addresses, obtained using 6to4 or the like, and
>  - IPv6 addesses from the HQ block.
> 
> The latter are only used for internal connectivity through CIPE tunnels;  
> the former would be used to reach IPv6 Internet (without a need to go
> through the HQ and from there to the Internet).

That works, and is one of the more promising options at the moment.

But we don't want to have to manually configure each host to be
multihomed -- assuming that HQ gets assigned the 2001:200:0:8002::/64
network, and our local site has 2001:200:0:8002:1234::/80 from that,
along with 
2002:c35c:f9ff::/48 from 6to4 with its IPv4 Internet address... is there
a way to configure radvd or dhcpv6 so it tells each host:

 "You are 2001:200:0:8002:1234:<EUI-64> and should route packets
  to 2001:200:0:8002::/64 using that source address.
 "You are also 2002:c55c:f9ff:1234:<EUI-64> and should route
  packets to 2000::/3 using _that_ source address."

In fact, we don't have to get it 100% correct -- as long as we ensure
that the failure mode where we route to internal hosts using our
non-HQ-derived IPv6 address isn't going to happen, it's OK to allow the
failure mode where we route to external hosts using our HQ-derived IPv6
address; that's only going to make it a bit slower, not actually make it
break.

> The potential issue here is the source address selection, so that the 
> hosts don't pick the HQ addresses when they try to reach to IPv6 sites in 
> the Big Internet (so that the packets don't route back through the HQ).

Unless they go out bearing the HQ-derived address, but with a 'care-of'
option pointing at the local IPv6-connectivity address? 

> > > Note that 6to4 specification explicitly disallows the use of 6to4 on
> > > private addresses.  No such checks have been added to Linux kernel (should
> > > be..), but you're likely to face more or less trouble if you do so.
> > 
> It's a bit more than that, even though Linux kernel only implements the 
> very basics of the specification.  See RFC3056 section 9 last paragraph.

Hmmm. I wonder how it's supposed to know which are subnet-broadcast
addresses? Do you reckon there are boxen out there which will refuse to
route for 2002:c35c:f9ff::1 just as some refuse to route for
195.92.249.255?

> Mobile IPv6 could be leveraged for you, sure.  However, you seem to
> require just one basic feature of MIPv6: tunneling back to Home (Agent).  
> The same can be established through CIPE tunnels.  This is similar to my
> thought, above, of deploying both IPv6 Internet connectivity ("care-of
> address") and local HQ addressing ("home address") to all the nodes.
> 
> For security, you would then have to ensure that the "local HQ addresses" 
> don't leak and are properly firewalled.

I was trying to avoid the tunnelling altogether, at least for the common
case. I thought that Mobile-IPv6 avoided the 'triangular routing'
problem that IPv4 has, by introducing a way for the correspondent node
to know about the mobile node's care-of address.

If a host in a remote (i.e. non-HQ) site has an HQ-derived address and a
locally-derived IPv6 address, it treats the former as a 'home address'
and the latter as a 'temporary address'. It sends packets ostensibly
from the 'home address' but using the locally-derived address as its
'care-of' address, so not only do _outgoing_ packets go directly over
the local IPv6 connection, but return packets _also_ come in that way.

-- 
dwmw2
