From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and statistics via rtnetlink
Date: Tue, 31 May 2005 15:17:47 +0200
Message-ID: <20050531131747.GF15391@postel.suug.ch>
References: <20050527141023.GP15391@postel.suug.ch> <1117205822.6383.68.camel@localhost.localdomain> <20050527151608.GZ15391@postel.suug.ch> <1117209411.6383.104.camel@localhost.localdomain> <20050527163516.GB15391@postel.suug.ch> <1117244567.6251.34.camel@localhost.localdomain> <20050528120731.GP15391@postel.suug.ch> <1117533847.6134.32.camel@localhost.localdomain> <20050531114251.GC15391@postel.suug.ch> <1117543711.6134.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117543711.6134.48.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117543711.6134.48.camel@localhost.localdomain> 2005-05-31 08:48
> The neighbor code ought not be aware of devices; but whoever is
> configuring must be. By configuring i mean "stiching together" the
> different blocks (as in some netlink based program in user space). the
> idevxxx is a "stiching"  construct - and therefore it may be aware of
> many other things that a standalone block doesnt. One could argue that
> the ifindex in a netdevice is also under the same class. The ARP, NDISC,
> netdevice, filters etc are the blocks being sown together. 
> Most of the times these blocks are built together in a topology that a
> packet flows through. 

OK, so your idevxxx is a kind of container for various configurable
blocks that logically belong to a inetdevice and a device specific
parameter set for a neighbour table would one of these blocks?

I think this is appropriate for NDTA_PARMS, e.g. there might be
multiple of such neighbour table parameter blocks per inetdevice
identified by the name of the neighbour table. You certainly have
a good point there, I see two minor drawbacks though: a) where
do we put these parameter blocks if it doesn't belong to a
inetdevice? and b) it makes collecting the complete configuration
of a neighbour table complicated. Nevertheless, I think I can
agree on this.

> I agree that we should leave the neighbor table-specific knobs out of
> devconfig.  

OK, so we leave RTM_NEIGHTBL_* as-is but move the device specific
parameter sets into devconfig? i.e. RTM_NEIGHTBL_* will cover:

 * the core neighbour table configuration (key-len, entry-size,
   last-flush, gc thresholds, gc interval, hash settings, etc.)
 * the default parameter set
 * neighbour table statistics


> It will help, though, for devconfig to have a single reference to the
> "instance" of the table(perhaps a name or a even a 32 bit pointer
> address) that a device uses (thefore maintaining the abstraction); but
> since there is only one table for v4 and v6 anyways i suppose it is
> implicitly assumed to be that one table.

This kind of breaks the architecture, i'd rather have it the other
way around, i.e. we hold a netdevice reference in each parameter set
and when lookup a parameter set for a specific idevxxx we iterate
through all neighbour tables and their paremter sets and compare
ifindex.
