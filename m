From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: tunneling in linux (was: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling)
Date: Sun, 16 Jan 2005 21:20:41 +0100
Message-ID: <20050116202041.GC22165@xi.wantstofly.org>
References: <20050112222437.GC14280@xi.wantstofly.org> <Pine.LNX.4.61.0501130944270.19573@netcore.fi> <20050113092351.GA23170@xi.wantstofly.org> <1105897020.1091.736.camel@jzny.localdomain> <20050116185553.GA21739@xi.wantstofly.org> <1105905745.1097.858.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Pekka Savola <pekkas@netcore.fi>, shemminger@osdl.org,
        shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105905745.1097.858.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 16, 2005 at 03:02:26PM -0500, jamal wrote:

> > Another argument against etherip would be that OpenBSD apparently
> > mis-implemented etherip by putting the etherip version nibble in the
> > second nibble of the etherip header instead of the first, which would
> > probably prevent the linux and OpenBSD versions from interoperating,
> > negating the advantage of using etherip in the first place.
> 
> Should be pretty easy for them to fix, no?

Sure, but, the argument in favor of etherip would be interoperability
with existing implementations.  If at least OpenBSD gets it wrong (and
the proposed patch for NetBSD seems to also use the wrong value) then
this argument isn't all that strong anymore.


> > All I personally care about is that when I install a random linux distro
> > two years from now, that ethernet-over-IP tunneling will simply work, using
> > whatever protocol -- I don't care about which.
> > 
> > Any opinions?
> 
> My opinion is it doesnt harm to have it in.

We'd need to sort out the ARPHRD_* issue in any case -- see below.


> BTW, in one of your emails i
> noticed you cced the authors of that RFC - did they respond? Whats their
> deployment experiences?

The @rsa.. address bounces, the other address is still in the CC list
and I didn't hear from him yet :-)


> > If we do end up using GRE for ethernet tunneling, there's some work that
> > needs to be done.  For one, ip_gre in its current form would need a certain
> > amount of hacking for tunneling ethernet frames instead of IPv4/IPv6 as
> > it does now.  We might as rename it to plain 'gre' and move it out of
> > net/ipv4/ to net/core/ or something while we're at it.
> > 
> > The way we currently use (f.e. in iproute2) for finding out whether a
> > given netdevice is a tunnel or not is by looking at ARPHRD_*, but this
> > scheme breaks down for ethernet tunnels,
> 
> the dev->type is intended precisely for that. So if this needs a new
> type then you should introduce a new ARPHRD type for it and set it at
> device creation time.

Bridges present themselves as ARPHRD_ETHER, even though they are not
'real' ethernet devices as such.  Should they have their own type?
What about ethertap devices?

If we create ARPHRD_ETHERTUNNEL for ethernet tunnels instead of using
ARPHRD_ETHER, we'd have to make modifications all over the place to
teach other code that ARPHRD_ETHERTUNNEL is basically just another type
of ethernet device.  For example, we'd have to modify net/bridge/*
because it will only enslave devices which are ARPHRD_ETHER.  But even
more modifications would be needed in userland -- we'd have to adapt
ifconfig, ip route, etc.

The issue is "We can not blindly issue SIOCGETTUNNEL to ARPHRD_ETHER
devices like we do for ARPHRD_{TUNNEL,IPGRE,SIT} because on _ETHER, it
might alias with another ioctl (SIOCDEVPRIVATE)."


> >  since there is no other way of
> > distinguishing them from regular ethernet devices.  We could issue
> > SIOCGETTUNNEL and see if that succeeds, but that unfortunately aliases
> > with SIOCDEVPRIVATE which aliases to BOND_ENSLAVE_OLD, SIOCGMSTATS,
> > EQL_ENSLAVE, FRAD_GET_CONF, SIOCDEVPLIP, SIOCGPPPSTATS and a million
> > others, so you never know if the netdevice really interpreted it as
> > SIOCGETTUNNEL or no.
> 
> Introducing the new type should help. Also the iflink is typically set
> to the mother netdevice. So that should go a long way to give you
> details.

There is no 'mother' device for a tunnel -- there might be no route to
the remote host at creation time, and that route might change over time
due to routing changes too.


> > Other things that suck about tunneling?
> > - If we're going to overhaul the way tunneling works, we should try to
> >   remove the need for the gre0 interface as well.
> 
> Why is this first instance needed? Its not like theres a bus that is
> scanned at boot time and we need to create at that discovery time.

This first instance is used for sending ioctls to to create subsequent
tunnel devices.  Doing something netlink-based would be fine with me.


> > - Tunneling over IPv6 should be implemented.
> 
> sit? or v6-v6?

Basically, 'ip tunnel' should accept v6 addresses for 'local' and
'remote'.  Having GRE-over-v6 would then imply v6-over-v6, v4-over-v6,
ethernet-over-v6, etc.


> BTW, have you looked at any of the L2VPN stuff? browse the ietf web
> page. Some interesting stuff there.

The L2TP RFC (RFC 2661, is that the same thing?) is 170kB, which scared
me off somewhat.

At least the GRE RFC fits in 16kB.


--L
