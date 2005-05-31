From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and
	statistics via rtnetlink
Date: Tue, 31 May 2005 10:59:21 -0400
Message-ID: <1117551561.6279.2.camel@localhost.localdomain>
References: <20050527141023.GP15391@postel.suug.ch>
	 <1117205822.6383.68.camel@localhost.localdomain>
	 <20050527151608.GZ15391@postel.suug.ch>
	 <1117209411.6383.104.camel@localhost.localdomain>
	 <20050527163516.GB15391@postel.suug.ch>
	 <1117244567.6251.34.camel@localhost.localdomain>
	 <20050528120731.GP15391@postel.suug.ch>
	 <1117533847.6134.32.camel@localhost.localdomain>
	 <20050531114251.GC15391@postel.suug.ch>
	 <1117543711.6134.48.camel@localhost.localdomain>
	 <20050531131747.GF15391@postel.suug.ch>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050531131747.GF15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-31-05 at 15:17 +0200, Thomas Graf wrote: 
> 
> OK, so your idevxxx is a kind of container for various configurable
> blocks that logically belong to a inetdevice and a device specific
> parameter set for a neighbour table would one of these blocks?
> 

Essentialy just in_device and  inet6_dev

> I think this is appropriate for NDTA_PARMS, e.g. there might be
> multiple of such neighbour table parameter blocks per inetdevice
> identified by the name of the neighbour table. You certainly have
> a good point there, I see two minor drawbacks though: a) where
> do we put these parameter blocks if it doesn't belong to a
> inetdevice? and b) it makes collecting the complete configuration
> of a neighbour table complicated. Nevertheless, I think I can
> agree on this.
> 

To recap:

netdevice ->
  L2 config stuff
  config stuff
  more config stuff
  even more config stuff
  ..
  ..
  netdevice protocol config:
   -> v4 specific (struct in_device)
   ----> IPV4 addresses (ifa_list), ARP params(arp_parms),etc
   -> v6 specific (struct inet6_dev)
   ----> IPV6 addresses(addr_list), ndisc params (nd_parms), etc

I think we are agreeing _not_ to configure ifa_list,  arp_parms etc
via devconfig. Leave these to their already existing config paths.
In the case of devconfig:
What i am suggesting is to put some identifier that can be used
to access lets say one or more arp_parms. This way when i dump
the devconfig i should be able to see "connected to arp table 1".
I should then be able to say dump arp table 1.
If it is too complex an idea we can drop it.
The defaults should stay as you say (and as they exist today) in the
arp block.

> > I agree that we should leave the neighbor table-specific knobs out of
> > devconfig.  
> 
> OK, so we leave RTM_NEIGHTBL_* as-is but move the device specific
> parameter sets into devconfig? i.e. RTM_NEIGHTBL_* will cover:
> 
>  * the core neighbour table configuration (key-len, entry-size,
>    last-flush, gc thresholds, gc interval, hash settings, etc.)
>  * the default parameter set
>  * neighbour table statistics
> 

Sounds reasonable.
And per device arp/ndisc is of course one of many
configurable parameters via devconfig.

> 
> > It will help, though, for devconfig to have a single reference to the
> > "instance" of the table(perhaps a name or a even a 32 bit pointer
> > address) that a device uses (thefore maintaining the abstraction); but
> > since there is only one table for v4 and v6 anyways i suppose it is
> > implicitly assumed to be that one table.
> 
> This kind of breaks the architecture, i'd rather have it the other
> way around, i.e. we hold a netdevice reference in each parameter set
> and when lookup a parameter set for a specific idevxxx we iterate
> through all neighbour tables and their paremter sets and compare
> ifindex.

The directionality as i see it is:

netdevice --> arp/ndisc table(s)

[And the binding/stiching of those tables is via inxx_devyy].

I dont have issues with arp pointing to netdevice as well, but I
thought ARP/ndisc already have ifindex reference?

cheers,
jamal
