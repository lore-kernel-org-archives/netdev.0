From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 9 Mar 2015 14:59:10 +0100
Message-ID: <20150309135910.GC1528@breakpoint.cc>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
 <20150309130253.GA6677@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42705 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754403AbbCIN7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 09:59:11 -0400
Content-Disposition: inline
In-Reply-To: <20150309130253.GA6677@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
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
> 
> Did you consider to implement this scratchpad area using a per-cpu
> area? I mean, something similar to what we used to have in
> ip_conntrack for events:

I see that I misread part of what you wrote.

We cannot use percpu data for nf_bridge_info; at least its not trivial
to do (I tried).

Main issues are:
- nfqueue (we have to save/restore info)
- local delivery (skb is enqueued in backlog)
- skb is dropped (we need to reset scratch data)
- DNAT mac hack (skb can be queued in qdisc).

We _can_ use percpu data for passing the original mac
header to the ip_fragment output function.  But, as mentioned,
there is a patch in netdev patchwork that adds extra output
parameter for use with OVS so it seems cleaner to (re-) use common
api in both OVS and br netfilter.

> BTW, 6/8 I think needs some ifdef to make sure NF_CONNTRACK is in
> placed.

Right, thanks for catching this.

> 7/8 needs NF_BRDIGE_MAX_MAC_HEADER_LENGTH which seems to have
> a small typo in it, well these are dependent of 4/8 anyway.

Sorry -- I'm dense -- what typo? :-)
