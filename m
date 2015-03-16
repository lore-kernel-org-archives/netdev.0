From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 16 Mar 2015 14:41:15 +0100
Message-ID: <20150316134115.GB1524@breakpoint.cc>
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
> I think the use of skb->cb introduces another dependency between
> br_netfilter and the core, which is what we should avoid.  I still
> have concerns regarding future extensibility issues that this may
> introduce:

One more thing (sorry, forgot to mention this).
We CANNOT avoid dependency between br_netfilter and the core.

Its just a matter of what this dependency looks like, and how
much of a buren it is wrt. to maintenance and debugability.

Currently the dependency is skb->nf_bridge pointer.

I proposed to replace this pointer with smaller state + place
rest of info in skb->cb, with all the problems that this entails.

Using your 'external table' will also require some interaction,
I don't see how you'd remove entries from such table except some
callback function sitting in kfree_skb path, so we'd have to replace
current nf_bridge_put() call with something like

if (skb->nf_bridge_state && nf_bridge_info_destructor_hook)
	nf_bridge_info_destructor_hook(skb);

in kfree_skb.

We'd also still need the refcounting and figure out a way to handle
skb_clone properly (although I *think* we only have to care about those
spots where the bridge clones skbs and don't need a generic solution).

I admit that your proposal has less 'hidden' dependencies compared
to skb->cb based solutions, though.
