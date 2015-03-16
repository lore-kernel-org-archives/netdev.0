From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 16 Mar 2015 13:38:54 +0100
Message-ID: <20150316123854.GA5564@salvia>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
 <20150309130253.GA6677@salvia>
 <20150309135910.GC1528@breakpoint.cc>
 <20150314090035.GA3561@salvia>
 <20150314111325.GG14761@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150314111325.GG14761@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Sat, Mar 14, 2015 at 12:13:25PM +0100, Florian Westphal wrote:
> I think that currently it doesn't matter what solution we'll pick in the
> end, I'd first like to send all my refactoring patches.
> 
> With those patches, it reduces the nf_bridge_info content that we need
> to the physin and physout devices, plus a two-bit state in skb.
> 
> Then, if you still think that ->cb is too fragile I'd be happy to add
> the lookup table method.  For the normal case of bridge forwarding, it
> shouldn't be needed though, perhaps we could also use a hybrid approach,
> cb-based fastpath for forwarding, lookup-table slowpath for dnat and
> local delivery cases.

I think the use of skb->cb introduces another dependency between
br_netfilter and the core, which is what we should avoid.  I still
have concerns regarding future extensibility issues that this may
introduce:

1) If we want to shrink the skb->cb in size, br_netfilter would limit
   this shrink since we'll have to keep enough room for our internal
   private information, even if most people will not need this.

2) If inet or qdisc private info size needs to be increased for
   whatever reason, we may run out of space to keep the br_netfilter data
   after it. And we cannot ask David to allow us to allocate more bytes
   for skb->cb to resolve this.

I think we have to find some permanent solution to isolate this
br_netfilter code as much as possible. Then, focus on providing a
replacement including the minimal set of features for what most users
are using br_netfilter, I would say:

* nfqueue support
* transparent proxying
* some simple way to perform stateless NAT (mangle mac and IP address
  to place the packet in the right interface).

so we can point them to nf_tables to progressively migrate to a better
environment, the overall goal to me is to deprecate this br_netfilter
thing.

I think we can use the per-cpu cache + global hashtable to look up for
nf_bridge data (using skbuff as index). The forwarded traffic will
find its nf_bridge info most of the time in the cache without having
to follow the slow lookup path.

> One other solution would be to use skb->cb but not store bridge device
> pointers but the ifindexes instead (we currently don't hold any
> device refcounts either so the current method isn't 100% safe either since
> such device can be removed ...).

Good catch, I think it would be great to start by fixing this problem
first.

Let me know,
Thanks!
