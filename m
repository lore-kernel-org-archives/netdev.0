From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Thu, 11 Sep 2003 19:40:04 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309111928330.14358-100000@netcore.fi>
References: <1063288826.23778.243.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063288826.23778.243.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Sep 2003, David Woodhouse wrote:
> On Thu, 2003-09-11 at 16:20 +0300, Pekka Savola wrote:
> > > That's why we'd want outgoing-connections-only for all the internal IPv6
> > > machines, just as they have in the IPv4 world by virtue of being behind
> > > NAT.
> > 
> > Right.  (This is a bit tricker with Linux IPv6 firewalling as it doesn't
> > support connection tracking, but still roughly doable.)
> 
> This is a fundamental requirement before we will be permitted allow
> connectivity to the outside world, I think.

Yep.
 
> > > In fact, we don't have to get it 100% correct -- as long as we ensure
> > > that the failure mode where we route to internal hosts using our
> > > non-HQ-derived IPv6 address isn't going to happen, 
> > 
> > This is a bit tricky.  There are two ways to hack around this:
> > 
> >  1) at your HQ, create an inbound firewall filter, so that you'll disallow 
> > any incoming packets to the "internal blocks" from the Internet.  If a 
> > host happens to start fall back to using global connectivity, the 
> > connectivity fails utterly.
> 
> Nono, talking to the outside world using HQ-derived addresses is _OK_.
> It's just a bit slower than using the locally-derived addresses, since
> we go through the tunnels.
> 
> What's going to break is talking to _internal_ machines using our
> locally-derived address. Our packets will get to them fine, over the
> internal tunnels, but their route back to us will then be over the
> Internet rather than through the internal tunnels, and hence it'll get
> firewalled.

.. which is exactly why I proposed the above.  Breaking connectivity
indicates that something is wrong.. better than communicating insecurely 
while believing the communication is secure :-)
 
> It's just a source-address-selection issue. If our HQ-assigned network
> is 2001:200:0::/48 and we are both 2001:200:0:8002::<EUI-64> and some
> other locally-obtained address, then we MUST use our 2001:200:0::
> (internal) address as source for all destinations in 2001:200:0::/48. It
> would be _nice_ if we use the other address for all other destinations,
> but it's not imperative.
> 
> AFAICT Rule 8 of RFC2484 is going to give us that anyway, and isn't
> going to be superseded by Rules 1-7 either. It should be fine.

Note that there is still the problem with destination address selection
(or not, if you follow good DNS naming conventions), and those (old)
versions that don't implement the source address selection.

> >  2) at your edge sites, make a firewall filter which prevents reaching
> > "internal blocks" through the Internet (automated installation could be
> > achieved using any number of mechanisms, whichever you're using).
> 
> We'll be routing 'internal' addresses through our tunnels rather than
> out the site's IPv6 link to the Internet anyway.

Right, this is just a safeguard to prevent your internal stuff going out 
over the internet by mistake.
 
> > .. in addition, up-to-date source address selection in the kernel should 
> > ensure that does not happen when you'd use only "internal addresses" in 
> > your DNS, or give internal addresses as command-line.  
> > 
> > Destination address selection is a bit trickier (hence the methods above) 
> > because if you'd get "internal address" and "external address" from the 
> > DNS, and the glibc getaddrinfo() implementation would pick one at random, 
> > this would lead to using the external connectivity half of the times, 
> > unless prevented with e.g. those filters or by administration (about the 
> > DNS names)
> 
> We can avoid this question entirely. The 'company.internal' domain would
> have only the HQ-derived addresses in it. The IPv6 addresses obtained
> for external connectivity at each site are irrelevant for internal
> communication. 

Agreed.
 
> Likewise, since ingress from the public Internet isn't going to be
> permitted, there's no real need for there to be AAAA records for the
> site-derived addresses in the 'company.com' domain.
> 
> It's only source-address selection which we need to care about, and that
> should be fine.

In your particular case, should be, yes (but I'd still keep the safeguards 
in place :-).
 
> > Kernel looks up all the v4 broadcast addresses from all the interfaces..?  
> > Should be pretty doable.
> 
> Oh, it knows its _own_ and shouldn't actually send a broadcast IPv4
> packet after decapsulating a 6to4 packet -- but it's also supposed to
> magically know not to encapsulate into IPv4 a packet with an IPv4
> address encoded which _happens_ to be a subnet broadcast elsewhere. It
> can't know that.

Of course, that cannot be known .. and I don't think the document even 
claims so.
 
> > > Do you reckon there are boxen out there which will refuse to
> > > route for 2002:c35c:f9ff::1 just as some refuse to route for
> > > 195.92.249.255?
> > 
> > I'm not sure if such implementations exist, but if they don't, there are 
> > specific threats (though minor) if such check are implemented.
> 
> That was a valid IPv4 address; it just happens to have a 255 in its last
> octet. There _are_ some people who can't route to it though, because
> some router in between thinks it's a subnet broadcast.

Right.
 
> > Mobile IPv6 won't help with that, in practice.  That's because the binding 
> > between care-of and home addresses must be secured.
>  <...>
> > So, this would create many new roundtrips, which is not really what you'd 
> > want..
> 
> Well, the _initial_ connection would all be tunnelled, and the binding
> would be set up in parallel, so that you end up routing optimally; just
> going via the tunnel to start with. 

I don't see how that would be different from a VPN scenario, but yes; I
guess if you deployed MIPv6 on every host, you could use it to communicate
securely and in ad-hoc fashion between the mobile node and the home agent.  
You could even forget about CIPE for v6. Mobile IPv6 requires IPv6
connectivity too, though.  But I'm not sure if that buys you much in this 
scenario.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
