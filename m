From: jamal <hadi@cyberus.ca>
Subject: Re: tunneling in linux (was: Re: [PATCH][RFC] etherip:
	Ethernet-in-IPv4 tunneling)
Date: 16 Jan 2005 18:09:05 -0500
Message-ID: <1105916945.1091.1039.camel@jzny.localdomain>
References: <20050112222437.GC14280@xi.wantstofly.org>
	 <Pine.LNX.4.61.0501130944270.19573@netcore.fi>
	 <20050113092351.GA23170@xi.wantstofly.org>
	 <1105897020.1091.736.camel@jzny.localdomain>
	 <20050116185553.GA21739@xi.wantstofly.org>
	 <1105905745.1097.858.camel@jzny.localdomain>
	 <20050116202041.GC22165@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Pekka Savola <pekkas@netcore.fi>, shemminger@osdl.org,
        shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050116202041.GC22165@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-16 at 15:20, Lennert Buytenhek wrote:
> On Sun, Jan 16, 2005 at 03:02:26PM -0500, jamal wrote:

> Sure, but, the argument in favor of etherip would be interoperability
> with existing implementations.  If at least OpenBSD gets it wrong (and
> the proposed patch for NetBSD seems to also use the wrong value) then
> this argument isn't all that strong anymore.
> 

Is 0x300 owned by anything? Maybe thats what it should be from now on
and an update to be issued agains the RFC ;->

> > BTW, in one of your emails i
> > noticed you cced the authors of that RFC - did they respond? Whats their
> > deployment experiences?
> 
> The @rsa.. address bounces, the other address is still in the CC list
> and I didn't hear from him yet :-)

Hopefully we'll hear from them
 
> > the dev->type is intended precisely for that. So if this needs a new
> > type then you should introduce a new ARPHRD type for it and set it at
> > device creation time.
> 
> Bridges present themselves as ARPHRD_ETHER, even though they are not
> 'real' ethernet devices as such.  Should they have their own type?

some devices are "ethernet like" - meaning they operate on ethernet
headers, so its fine to use that. I would think bridges would fall under
that category.

> What about ethertap devices?

They are ethernet like as well. OTOH, if you look at tuntap you may find
one of the modes is not ethernet-like. Infact it doesnt have a header at
all;-> (ARPHRD_NONE). rule of thumb: Whats the header like?

> If we create ARPHRD_ETHERTUNNEL for ethernet tunnels instead of using
> ARPHRD_ETHER, we'd have to make modifications all over the place to
> teach other code that ARPHRD_ETHERTUNNEL is basically just another type
> of ethernet device.  

IANA actually keeps track of these iftype numbers - they dont seem to
match with Linux - I wonder why we havent heard some SNMP weenie
bitching about this:
http://www.iana.org/assignments/ianaiftype-mib
So, yes, should be able to add ARPHRD_ETHERTUNNEL in some free number
and i am pretty sure youd hear from them someday;->
If i have time i will sneak a look at net-snmp

> For example, we'd have to modify net/bridge/*
> because it will only enslave devices which are ARPHRD_ETHER.  But even
> more modifications would be needed in userland -- we'd have to adapt
> ifconfig, ip route, etc.

You probably want net/bridge to enslave _only_ ethernet like type
netdevices. Otherwise it gets confused trying to see where the fsck dst
MAC is to be found.

> The issue is "We can not blindly issue SIOCGETTUNNEL to ARPHRD_ETHER
> devices like we do for ARPHRD_{TUNNEL,IPGRE,SIT} because on _ETHER, it
> might alias with another ioctl (SIOCDEVPRIVATE)."

I dont think it will be an issue with proper dev->type.

You know theres another way to do this:
Write this as a simple action. If all you are doing is slapping headers
back and forth then you want:

ingress:
	match protocol 0x3000
		action: etherip decap, format, --> netif_rx
egress:
	
outgoing: 
	match someIP
		action: etherip encap, format --> out we go

All very simple to control with netlink. And would be an excuse to
finaly get you to look at this stuff ;->
 

> > Introducing the new type should help. Also the iflink is typically set
> > to the mother netdevice. So that should go a long way to give you
> > details.
> 
> There is no 'mother' device for a tunnel -- there might be no route to
> the remote host at creation time, and that route might change over time
> due to routing changes too.
> 

I thought you should be able to specify _exactly_ what the physical
device is ("ip tunnel ... dev eth0" or something along those lines) . I
could be wrong. 


> > Why is this first instance needed? Its not like theres a bus that is
> > scanned at boot time and we need to create at that discovery time.
> 
> This first instance is used for sending ioctls to to create subsequent
> tunnel devices.  Doing something netlink-based would be fine with me.
> 

Yes, that would kill need for those devices.. 2.6.x is now fine and
should handle all that fine with no need for ioctls - backward comapt
maybe an issue.

> 
> > > - Tunneling over IPv6 should be implemented.
> > 
> > sit? or v6-v6?
> 
> Basically, 'ip tunnel' should accept v6 addresses for 'local' and
> 'remote'.  Having GRE-over-v6 would then imply v6-over-v6, v4-over-v6,
> ethernet-over-v6, etc.
> 

At the moment you specify the mode - is that the only painful thing?
Didnt quiet follow

> 
> > BTW, have you looked at any of the L2VPN stuff? browse the ietf web
> > page. Some interesting stuff there.
> 
> The L2TP RFC (RFC 2661, is that the same thing?) is 170kB, which scared
> me off somewhat.
> 
> At least the GRE RFC fits in 16kB.

No meant L2VPNs - purely layer 2 and then somewhere along the path
carried by MPLS. 
start here: http://www.ietf.org/html.charters/l2vpn-charter.html

cheers,
jamal
