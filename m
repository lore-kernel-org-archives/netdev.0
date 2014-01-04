From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] macvlan: fix oops with vlan-on-top and HW_VLAN_CTAG_TX
 lowerdev
Date: Sat, 4 Jan 2014 14:51:32 +0100
Message-ID: <20140104135132.GA2106@breakpoint.cc>
References: <20131230102712.GO29632@breakpoint.cc>
 <20131231.162448.1656983197554902144.davem@davemloft.net>
 <20140103113904.GB28854@breakpoint.cc>
 <20140103.153352.166630160016412696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45528 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753152AbaADNvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 08:51:36 -0500
Content-Disposition: inline
In-Reply-To: <20140103.153352.166630160016412696.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Fri, 3 Jan 2014 12:39:04 +0100
> 
> >> +static const struct header_ops vlan_passthru_header_ops = {
> >> +	.create	 = vlan_passthru_hard_header,
> >> +	.rebuild = dev_rebuild_header,
> > 
> > Doesn't that result in infinite recursion when invoking
> > dev_rebuild_header() on skb whose dev->header_ops is
> > vlan_passthru_header_ops?
> 
> The skb->dev should be the real_dev at this point, no?

Oh, this is fun.

I grep'd for invocations of ->rebuild() because I wanted to understand
when/where it is used.

I only found one single instance, namely

neigh_compat_output() in net/core/neighbour.c

It does
        struct net_device *dev = skb->dev;
        __skb_pull(skb, skb_network_offset(skb));
       if (dev_hard_header(skb, dev, ntohs(skb->protocol), NULL, NULL, skb->len) < 0 &&
            dev->header_ops->rebuild(skb))
               return 0;

So I thought, if skb->dev is the vlan device, we would invoke
dev_rebuild_header(), which grabs skb->dev again and invokes
dev_rebuild_header again, etc. etc.

But: neigh_compat_output (suspicious name...) is only wired up in
net/ipv4/arp.c, in 'static const struct neigh_ops arp_broken_ops'.
... and arp_broken_ops is only set if dev->type is one of
ARPHRD_ROSE, ARPHRD_AX25, ARPHRD_NETROM.

Could it be that ->rebuild() is completely obsolete and could be removed
from almost all drivers (except above types)?

Archeology exercise #1 digs up 3b04ddde02c in linux.git, which
creats header_ops->rebuild, from the old  dev->rebuild_header.

Exercise #2 then finds commit 275513d2e1c78 in netdev-vger-cvs.git tree.
Quote from commit message:

        - dev->rebuild_header WILL DISAPPEAR. All the code
          relying on its existance is wrong, though still works.

Alexey calling from 1997 ;-)

I'll do some more digging before working on this.

I've placed a BUG() in eth_rebuild_header on my workstation, lets see if
it dies 8-}
