From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] net: refactor __netif_receive_skb_core
Date: Thu, 16 Apr 2015 06:49:05 +0100
Message-ID: <20150416054904.GC3285@acer.localdomain>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <1428668142-4006-2-git-send-email-pablo@netfilter.org>
 <5527D476.6030306@iogearbox.net>
 <20150415180927.4592eb6e@brouer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jesper Dangaard Brouer <netdev@brouer.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150415180927.4592eb6e@brouer.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.04, Jesper Dangaard Brouer wrote:
> > Out of curiosity, what is actually the performance impact on all
> > of this? We were just arguing on a different matter on two more
> > instructions in the fast-path, here it's refactoring the whole
> > function into several ones, I presume gcc won't inline it.
> 
> Pablo asked me to performance test this change.  Full test report below.
> 
> The performance effect (of this patch) depend on the Gcc compiler
> version.
> 
> Two tests:
>  1. IP-forwarding (unloaded netfilter modules)
>  2. Early drop in iptables "raw" table
> 
> With GCC 4.4.7, which does not inline the new functions
> (__netif_receive_skb_ingress and __netif_receive_skb_finish) the
> performance impact/regression is definitly measurable.
> 
> With GCC 4.4.7:
>  1. IP-forwarding: +25.18 ns (slower) (-27776 pps)
>  2. Early-drop   :  +7.55 ns (slower) (-66577 pps)
> 
> With GCC 4.9.1, the new functions gets inlined, thus the refactor
> splitup of __netif_receive_skb_core() is basically "cancled".
> Strangly there is a small improvement for forwarding, likely due to
> some lucky assember reordering that give less icache/fetch-misses.
> The early-drop improvement is below accuracy levels, can cannot be
> trusted.
> 
> With GCC 4.9.1:
>  1. IP-forwarding: -10.05ns (faster) (+17532 pps)
>  2. Early-drop   :  -1.54ns (faster) (+16216 pps) below accuracy levels
> 
> I don't know what to conclude, as the result depend on the compiler
> version... but these kind of change do affect performance, and should
> be tested/measured.

Thanks Jesper. This effect without inlinging was to be expected I guess.
The interesting question would be a patch that uses nf_hook() without okfn
callback, moves the ingress qdisc to register with the netfilter ingress
hook and moves the TTL tracking of ing_filter() to the ingress qdisc,
where it belongs.

My expectation would be that this would result in an overall performance
gain.
