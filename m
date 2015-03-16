From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 16 Mar 2015 14:01:10 +0100
Message-ID: <20150316130110.GA1524@breakpoint.cc>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
 <20150309130253.GA6677@salvia>
 <20150309135910.GC1528@breakpoint.cc>
 <20150314090035.GA3561@salvia>
 <20150314111325.GG14761@breakpoint.cc>
 <20150316123854.GA5564@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150316123854.GA5564@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Sat, Mar 14, 2015 at 12:13:25PM +0100, Florian Westphal wrote:
> > I think that currently it doesn't matter what solution we'll pick in the
> > end, I'd first like to send all my refactoring patches.
> > 
> > With those patches, it reduces the nf_bridge_info content that we need
> > to the physin and physout devices, plus a two-bit state in skb.
> > 
> > Then, if you still think that ->cb is too fragile I'd be happy to add
> > the lookup table method.  For the normal case of bridge forwarding, it
> > shouldn't be needed though, perhaps we could also use a hybrid approach,
> > cb-based fastpath for forwarding, lookup-table slowpath for dnat and
> > local delivery cases.
> 
> I think the use of skb->cb introduces another dependency between
> br_netfilter and the core, which is what we should avoid.  I still
> have concerns regarding future extensibility issues that this may
> introduce:
> 
> 1) If we want to shrink the skb->cb in size, br_netfilter would limit
>    this shrink since we'll have to keep enough room for our internal
>    private information, even if most people will not need this.

Given the size of tcp and gro this shouldn't be an issue.
We'd still fit into 40 bytes cb, and, if that would be a problem we
could still go with (more complex) external storage scheme.

> 2) If inet or qdisc private info size needs to be increased for
>    whatever reason, we may run out of space to keep the br_netfilter data
>    after it. And we cannot ask David to allow us to allocate more bytes
>    for skb->cb to resolve this.

Sure, absolutely.  skb->cb increase is out of question.

I don't think its a problem though, qdisc private info could even be
reduced to 16 (2 pointers on 64bit which I think is a reasonable size to
provide for qdiscs).  Infiniband has similar hack.

And tcp cb has to embed  inet/inet6 as well.

We wouldn't even need to pull of this stunt actually, we could just zap
the skb instead of reinjection... But that would induce e.g. a syn
retransmit which I want to avoid.

> I think we have to find some permanent solution to isolate this
> br_netfilter code as much as possible. Then, focus on providing a
> replacement including the minimal set of features for what most users
> are using br_netfilter, I would say:
> 
> * nfqueue support
> * transparent proxying
> * some simple way to perform stateless NAT (mangle mac and IP address
>   to place the packet in the right interface).

Please not stateless (IP) nat, it usually bites users due to lack
of helpers...  I've no problem with mac mangling.

> so we can point them to nf_tables to progressively migrate to a better
> environment, the overall goal to me is to deprecate this br_netfilter
> thing.

Yes, but it will be a long time before we can remove this thing.

> I think we can use the per-cpu cache + global hashtable to look up for
> nf_bridge data (using skbuff as index). The forwarded traffic will
> find its nf_bridge info most of the time in the cache without having
> to follow the slow lookup path.

I'm still not convinced we even need lookups in the forward case since
the skb can never leave br_netfilter context.

And we only need to store the physin/out ports, nothing else, so its a
bit sad that we need to add such lookup stuff in the first place :-/

I agree that it would still be better than the skb->nf_bridge
indirection, though.

> > One other solution would be to use skb->cb but not store bridge device
> > pointers but the ifindexes instead (we currently don't hold any
> > device refcounts either so the current method isn't 100% safe either since
> > such device can be removed ...).
> 
> Good catch, I think it would be great to start by fixing this problem
> first.

I don't see how this is easily fixable, sorry -- it would mean we'd have
to dev_hold right after allocation of nf_bridge_info struct...

We can store ifindexes of physin/physout and re-lookup, sure.

I'll start on the central storage infrastructure.
Do you want me to base it on the current patches i have or on plain
nf-next?

Thanks.
