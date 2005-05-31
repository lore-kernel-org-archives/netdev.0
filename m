From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and statistics via rtnetlink
Date: Tue, 31 May 2005 18:13:15 +0200
Message-ID: <20050531161315.GH15391@postel.suug.ch>
References: <20050527151608.GZ15391@postel.suug.ch> <1117209411.6383.104.camel@localhost.localdomain> <20050527163516.GB15391@postel.suug.ch> <1117244567.6251.34.camel@localhost.localdomain> <20050528120731.GP15391@postel.suug.ch> <1117533847.6134.32.camel@localhost.localdomain> <20050531114251.GC15391@postel.suug.ch> <1117543711.6134.48.camel@localhost.localdomain> <20050531131747.GF15391@postel.suug.ch> <1117551561.6279.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@znyx.com>
Content-Disposition: inline
In-Reply-To: <1117551561.6279.2.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jamal Hadi Salim <1117551561.6279.2.camel@localhost.localdomain> 2005-05-31 10:59
> netdevice ->
>   L2 config stuff
>   config stuff
>   more config stuff
>   even more config stuff
>   ..
>   ..
>   netdevice protocol config:
>    -> v4 specific (struct in_device)
>    ----> IPV4 addresses (ifa_list), ARP params(arp_parms),etc
>    -> v6 specific (struct inet6_dev)
>    ----> IPV6 addresses(addr_list), ndisc params (nd_parms), etc

Absolutely.

> I think we are agreeing _not_ to configure ifa_list,  arp_parms etc
> via devconfig. Leave these to their already existing config paths.

arp_parms is just a reference to the corresponding device specific
parameter set of the "arp_cache" neighbour table. Maybe I've been
misunderstanding you throughout all your posts or maybe I've a
wrong understanding of the neighbour code in general. As far as I
understand it:

1) The actual neighbour implementation registers a new neighbour
   table by calling neigh_table_init() with the proposed default
   configuration for this table. This also includes the default
   parameter set used to derive device specific parameter sets
   later on, e.g. arp_tbl.

2) Upon the creation of a inet_device/... a new parameter set
   is allocated that derives the initial parameter values from
   the default parameter set. This parameter set is stored
   in in_dev->arp_parms and linked in a list of parameter sets
   in the neighbour table (neightbl->parms).

3) When a new neighbour is created the core neighbour code
   will assign the default parameter set of the table to
   the neighbour and increments its refcnt. It then calls
   the constructor of arp,ndisc,... which replaces the
   parameter set just assigned with the one in
   in_dev->arp_parms which is the parameter set.

So what I propose is to have the neighbour table parameters,
e.g. everything in arp_tbl be distributed over RTM_NEIGHTBL
and put the device specific parameters into devconfig,
e.g. in_dev->arp_parms.

> In the case of devconfig:
> What i am suggesting is to put some identifier that can be used
> to access lets say one or more arp_parms. This way when i dump
> the devconfig i should be able to see "connected to arp table 1".
> I should then be able to say dump arp table 1.

OK, this is possible with either way. I don't worry about this.

> The directionality as i see it is:
> 
> netdevice --> arp/ndisc table(s)

> [And the binding/stiching of those tables is via inxx_devyy].

Absolutely, more specific:

netdevice -> inet_device -> parameter set -> neighbour table
or:
neighbour table -> list of parameter sets -> netdevice

both ways are possible right now.
