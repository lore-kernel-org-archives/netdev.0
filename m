From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Thu, 11 Sep 2003 16:20:17 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309111555310.12750-100000@netcore.fi>
References: <1063284516.23778.152.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063284516.23778.152.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Sep 2003, David Woodhouse wrote:
> On Thu, 2003-09-11 at 10:49 +0300, Pekka Savola wrote:
> > Yep, but once you break into just one box w/ global addresses, all of the 
> > site-internal infrastructure is open to you.  This seems like a high price 
> > to pay, with many points of failure.
> 
> Well yes, but that's _already_ the cases for boxen on the internal
> RFC1918 IPv4 network. If you own one, you have access to them all. 

Ok.. now you have the chance to improve security by doing IPv6 (.. and 
having to put in internal filters as well, in the process) :-)

> That's why we'd want outgoing-connections-only for all the internal IPv6
> machines, just as they have in the IPv4 world by virtue of being behind
> NAT.

Right.  (This is a bit tricker with Linux IPv6 firewalling as it doesn't
support connection tracking, but still roughly doable.)
 
> > One possible solution is to pick one (or a couple of) major sites which 
> > provide "internal connectivity addresses".  For example, assume you have 
> > the big HQ in the US.  Deploy on each node:
> > 
> >  - IPv6 connectivity addresses, obtained using 6to4 or the like, and
> >  - IPv6 addesses from the HQ block.
> > 
> > The latter are only used for internal connectivity through CIPE tunnels;  
> > the former would be used to reach IPv6 Internet (without a need to go
> > through the HQ and from there to the Internet).
> 
> That works, and is one of the more promising options at the moment.

Ok.
 
> But we don't want to have to manually configure each host to be
> multihomed -- assuming that HQ gets assigned the 2001:200:0:8002::/64
> network, and our local site has 2001:200:0:8002:1234::/80 from that,

Please don't: get a /48, so you can give each subnet a /64.  Giving less 
than /80 breaks so many things (like stateless address autoconfiguration).

> along with 
> 2002:c35c:f9ff::/48 from 6to4 with its IPv4 Internet address... is there
> a way to configure radvd or dhcpv6 so it tells each host:
> 
>  "You are 2001:200:0:8002:1234:<EUI-64> and should route packets
>   to 2001:200:0:8002::/64 using that source address.
>  "You are also 2002:c55c:f9ff:1234:<EUI-64> and should route
>   packets to 2000::/3 using _that_ source address."

Not possible, that I'm aware of.
 
> In fact, we don't have to get it 100% correct -- as long as we ensure
> that the failure mode where we route to internal hosts using our
> non-HQ-derived IPv6 address isn't going to happen, 

This is a bit tricky.  There are two ways to hack around this:

 1) at your HQ, create an inbound firewall filter, so that you'll disallow 
any incoming packets to the "internal blocks" from the Internet.  If a 
host happens to start fall back to using global connectivity, the 
connectivity fails utterly.

and:

 2) at your edge sites, make a firewall filter which prevents reaching
"internal blocks" through the Internet (automated installation could be
achieved using any number of mechanisms, whichever you're using).

.. in addition, up-to-date source address selection in the kernel should 
ensure that does not happen when you'd use only "internal addresses" in 
your DNS, or give internal addresses as command-line.  

Destination address selection is a bit trickier (hence the methods above) 
because if you'd get "internal address" and "external address" from the 
DNS, and the glibc getaddrinfo() implementation would pick one at random, 
this would lead to using the external connectivity half of the times, 
unless prevented with e.g. those filters or by administration (about the 
DNS names)

> it's OK to allow the
> failure mode where we route to external hosts using our HQ-derived IPv6
> address; that's only going to make it a bit slower, not actually make it
> break.

Right.

> > The potential issue here is the source address selection, so that the 
> > hosts don't pick the HQ addresses when they try to reach to IPv6 sites in 
> > the Big Internet (so that the packets don't route back through the HQ).
> 
> Unless they go out bearing the HQ-derived address, but with a 'care-of'
> option pointing at the local IPv6-connectivity address? 

Mobile IPv6 is quite a bit more complicated than that nowadays.. :-/
 
> > > > Note that 6to4 specification explicitly disallows the use of 6to4 on
> > > > private addresses.  No such checks have been added to Linux kernel (should
> > > > be..), but you're likely to face more or less trouble if you do so.
> > > 
> > It's a bit more than that, even though Linux kernel only implements the 
> > very basics of the specification.  See RFC3056 section 9 last paragraph.
> 
> Hmmm. I wonder how it's supposed to know which are subnet-broadcast
> addresses? 

Kernel looks up all the v4 broadcast addresses from all the interfaces..?  
Should be pretty doable.

> Do you reckon there are boxen out there which will refuse to
> route for 2002:c35c:f9ff::1 just as some refuse to route for
> 195.92.249.255?

I'm not sure if such implementations exist, but if they don't, there are 
specific threats (though minor) if such check are implemented.
 
> > Mobile IPv6 could be leveraged for you, sure.  However, you seem to
> > require just one basic feature of MIPv6: tunneling back to Home (Agent).  
> > The same can be established through CIPE tunnels.  This is similar to my
> > thought, above, of deploying both IPv6 Internet connectivity ("care-of
> > address") and local HQ addressing ("home address") to all the nodes.
> > 
> > For security, you would then have to ensure that the "local HQ addresses" 
> > don't leak and are properly firewalled.
> 
> I was trying to avoid the tunnelling altogether, at least for the common
> case. I thought that Mobile-IPv6 avoided the 'triangular routing'
> problem that IPv4 has, by introducing a way for the correspondent node
> to know about the mobile node's care-of address.

Mobile IPv6 won't help with that, in practice.  That's because the binding 
between care-of and home addresses must be secured. The only way that can 
be done, in general, is to use a return routability procedure, that is: 
the node a host communicates with ("correspondent node") sends a packet to 
the home address and the care-of address of the host with a cookie (and 
other stuff), and makes sure the host reflects them back at it, thus 
verifying that it is in fact reachable at both addresses.

So, this would create many new roundtrips, which is not really what you'd 
want..

Hope this helps..

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
