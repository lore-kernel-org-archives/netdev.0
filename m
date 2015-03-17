From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 nf-next 1/6] net: untangle ip_fragment and bridge
 netfilter
Date: Tue, 17 Mar 2015 21:40:28 +0100
Message-ID: <20150317204028.GC26394@breakpoint.cc>
References: <20150316225545.GA4454@salvia>
 <20150317.004224.595812379252826772.davem@davemloft.net>
 <20150317101152.GB26394@breakpoint.cc>
 <20150317.131250.1794140944101735383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, azhou@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150317.131250.1794140944101735383.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Tue, 17 Mar 2015 11:11:52 +0100
> 
> > And doing route lookups will break things for some people, we have zero
> > guarantee that a bridge has the needed routing information,
> > its valid to not even configure a default gateway on a bridge.
> 
> Then without a proper route you absolutely cannot choose an
> appropriate MTU from which to perform fragmentation.

Just to clarify, this ip_fragment call is done only for frames that
are forwarded by the bridge, i.e. not routed.

All interfaces have the same MTU.

So why would we need to chose an MTU different than the device
mtu, or larger than the largest reassembled packet?

Ideally, the bridge would re-create the original fragments it received
on 1:1 basis to make it fully transparent, and to make the bridge behave
as if it would not do the defrag layering violations in the first place.

> Just accept that basic fact.

For a router I'd agree, but, then again, we're a bridge.  Normally we
would not fragment at all.  The bridge defragmentation should not be
observable by external entity.  No increase, no decrease of mtu, 1:1
fragment passthrough illusion.

I can leave ip_fragment alone and, when skb->nf_bridge goes away,
just replace

#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
        if (skb->nf_bridge)
	      mtu -= nf_bridge_mtu_reduction(skb);
#endif
and

ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, nf_bridge_pad(skb));

With a functionally equivalent "solution".
But I'd really prefer to move these kludges out of the ip stack for good.
