From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and statistics via rtnetlink
Date: Fri, 27 May 2005 18:35:16 +0200
Message-ID: <20050527163516.GB15391@postel.suug.ch>
References: <20050526185306.GW15391@postel.suug.ch> <20050526185526.GZ15391@postel.suug.ch> <1117192464.6688.3.camel@localhost.localdomain> <20050527121503.GN15391@postel.suug.ch> <1117201853.6383.29.camel@localhost.localdomain> <20050527141023.GP15391@postel.suug.ch> <1117205822.6383.68.camel@localhost.localdomain> <20050527151608.GZ15391@postel.suug.ch> <1117209411.6383.104.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117209411.6383.104.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117209411.6383.104.camel@localhost.localdomain> 2005-05-27 11:56
> On Fri, 2005-27-05 at 17:16 +0200, Thomas Graf wrote:
> > Sorry but this is just one big hack:
> 
> It maybe in the user space representation, but not in the kernel 
> abstraction which is what i was refering to.
> In other words look at struct in_device;

Yes, it references the arp device specific parameters and so
does inet6_dev for the ndisc cache. But this repsents only the
current state, we might have neighbour table parameter sets
which are not bound to inetdevs in the future. However, I
regard this as minor and I can agree on moving the device
specific parameters into a inetdev based architecture but
I do NOT agree on moving gc_ into this architecture as well,
it doesn't belong there.

Nitpicking for a bit, although inet6_dev and in_device hold
reference to the their arp respectively ndisc parameter set,
the sysctl interface does not use this reference but stores
the ifindex of the netdevice, _which_ is correct I think
because parameter sets are _not_ limited to inetdevs in terms
of architecture but only in terms of current use.

> The deafult can be overriden by devX. So they dont need to sync.
> But this is a separate topic

I was not talking about in-sync but rather that gc_* only
appears in default/ but not in devX/. What I expect is that
every default parameter can be overwritten in devX which
is not true for gc_*. Which is the reason why I implemented
them outside of the NDTPA_PARMS nested TLV.

> I am afraid you are looking at this from the wrong angle (user space),
> Thomas ;-> 
> The abstraction in the kernel is proper.
> 
> To redraw that model again with the exact structure names:
> 
> netdevice ->
>   L2 config stuff
>   config stuff
>   more config stuff
>   ..
>   ..
>   netdevice protocol config:
>    -> v4 specific (struct in_device)
>    ----> IPV4 addresses (ifa_list), ARP params(arp_parms),etc
>    -> v6 specific (struct inet6_dev)
>    ----> IPV6 addresses(addr_list), ndisc params (nd_parms), etc
>  
> There are a few more items but i am leaving them out for brevity.
> I hope it makes more sense now.

I understand your architecture and if we follow this thought
we'd have a "default" netdevice which repesents all default
settings. I do agree with this architecture but the problematic
question remains: Do we want parameters in "default" which are
not available in devX? I think this question is what it gets
down to in the end. If we say, yes we do want this, then we
can implement all generic settings, such as tcp_, using this
scheme as well. I don't disagree with this completely but I
find it not very intuitive from a user perspective.
