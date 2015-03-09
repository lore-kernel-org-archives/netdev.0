From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 9 Mar 2015 14:13:56 +0100
Message-ID: <20150309131356.GB28039@breakpoint.cc>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
 <20150309130253.GA6677@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, azhou@nicira.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42608 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753885AbbCINN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 09:13:58 -0400
Content-Disposition: inline
In-Reply-To: <20150309130253.GA6677@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> wrote:

[ CC Andy, see below for ip_fragment api discussion ]

> > Lets start untangling bridge, bridge netfilter, and the
> > rest of the ip stack (esp. ip_fragment).
> > 
> > This changes ip_fragment() so that bridge netfilter
> > can pass in the required information as arguments instead
> > of using skb->nf_bridge to pass some extra information to it.
> > 
> > Another problem with br_netfilter and the way its plumbed to
> > ip/ip6-tables (physdev match) is skb->nf_bridge.
> > 
> > nf_bridge is kmalloced blob with some extra information, including
> > the bridge in and outports (mainly for iptables' physdev match).
> > It also has various state bits so we know what manipulations
> > have been performed by bridge netfilter on the skb (e.g.
> > ppp header stripping).
> >
> > nf_bridge also provides scratch space where br_netfilter saves
> > (and later restores) various things, e.g. ipv4 address for
> > dnat detection, mac address to fix up ip fragmented skbs, etc.
> > 
> > But in almost all cases we can avoid using ->data completely.
> 
> I think one of the goals of this patchset is to prepare the removal of
> that nf_bridge pointer from sk_buff which sounds as a good idea to me.

The 2nd (and last half) of the set folds nf_bridge_info into skbuff,
at the end (where its not initialized at allocation time).

The struct is a lot smaller by then (16 bytes on 64bit, 12 on 32bit)
so we'd increase skbuff size only by 8.

> Did you consider to implement this scratchpad area using a per-cpu
> area? I mean, something similar to what we used to have in
> ip_conntrack for events:
> 
> http://www.cs.fsu.edu/~baker/devices/lxr/http/source/linux/net/netfilter/nf_conntrack_ecache.c?v=2.6.25#L65
> 
> Following that approach, I think we could avoid changing the
> ip_fragment() interface.

Yes, I had a patch that used a percpu area.  BUT, please see conflicting
patch:

http://patchwork.ozlabs.org/patch/447939/

So if OVS needs such an interface I thought it makes no sense to work
around current API using percpu data.

Andy, it looks like I could either wait for your patches to hit
net-next, or you could refactor your changes based on my ip_fragment
changes; AFAICS the use cases are pretty much the same so both
ovs and bridge netfilter could use one unified ip_fragment().

> My concern is that these changes are too
> specific of br_netfilter, which is not a good reference client of it
> given all its design problems.

I agree that change just for br_netfilter sake sucks but please also
keep in mind that right now we have 'extra signalling' into ip_frament
via skb->nf_bridge pointer which I dislike even more.

> I'm preparing a new net-next batch, I can quickly take these three if
> you agree:
> 
> 1/8 bridge: move mac header copying into br_netfilter
> 2/8 netfilter: bridge: move nf_bridge_update_protocol to where its used
> 4/8 netfilter: bridge: refactor conditional in br_nf_dev_queue_xmit

Sure.  I can then submit the entire series (i.e. part1 without these 3
plus part2).  I have no further br netfilter changes after that.

> Regarding 3/8, I think we can move that code to br_netfilter.c so we
> reduce ifdef pollution a bit and keep as much of this monster code
> fenced under that file. Please, see patch attached.

Sure.

> BTW, 6/8 I think needs some ifdef to make sure NF_CONNTRACK is in
> placed. 7/8 needs NF_BRDIGE_MAX_MAC_HEADER_LENGTH which seems to have
> a small typo in it, well these are dependent of 4/8 anyway.

Seems you're right, I'll look at it, thanks Pablo!
