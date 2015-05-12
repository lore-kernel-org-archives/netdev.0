From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code
 where it belongs
Date: Tue, 12 May 2015 14:55:26 +0200
Message-ID: <20150512125526.GA3822@salvia>
References: <554FB366.7080509@plumgrid.com>
 <20150510195018.GA7877@salvia>
 <554FCE24.8020904@iogearbox.net>
 <554FD12F.2020607@iogearbox.net>
 <20150510234313.GA3176@salvia>
 <555044D8.3080606@plumgrid.com>
 <20150511133245.GA4430@salvia>
 <1431354912.566.15.camel@edumazet-glaptop2.roam.corp.google.com>
 <555134F4.80007@plumgrid.com>
 <1431387038.566.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	davem@davemloft.net, jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34994 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932467AbbELMun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 08:50:43 -0400
Content-Disposition: inline
In-Reply-To: <1431387038.566.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, May 11, 2015 at 04:30:38PM -0700, Eric Dumazet wrote:
> On Mon, 2015-05-11 at 16:02 -0700, Alexei Starovoitov wrote:
> > On 5/11/15 7:35 AM, Eric Dumazet wrote:
> > >
> > > -static inline int deliver_skb(struct sk_buff *skb,
> > > +static noinline int deliver_skb(struct sk_buff *skb,
> > >   			      struct packet_type *pt_prev,
> > >   			      struct net_device *orig_dev)
> > 
> > have tried the above only and didn't see any difference
> > for simple 'netif_receive + drop in ip_rcv' test.
> > Not sure whether it's actually worth doing. I would leave it as-is.
> 
> Yes, this was probably too aggressive.

I tested this noinline patch and I got a bit less performance here in
my 32K i-cache testbed.

> unlikely() or static_key_false() are no moving code away enough, whole
> function including unused code pollutes icache.
>
> Code size increased a lot, while L1/L2 caches on cpu are about the same
> than 6 years ago.

OK, so that explains why I'm getting more performance with the patch
that move the qdisc ingress code using the indirection, since that
helped to move code away, right?

BTW, looking at the emails, Daniel said:

[...]
> After your patch set:
>
> Samples: 50K of event 'cycles:k', Event count (approx.): 45160667741
> +   40.49%  kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb_core
> +   31.21%  kpktgend_0  [kernel.kallsyms]  [k] kfree_skb
> +    6.94%  kpktgend_0  [pktgen]           [k] pktgen_thread_worker
> +    6.63%  kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_internal
> +    6.63%  kpktgend_0  [kernel.kallsyms]  [k] ip_rcv
> +    3.30%  kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_sk
> +    3.30%  kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb
> +    0.96%  kpktgend_0  [kernel.kallsyms]  [k] __local_bh_enable_ip
> +    0.37%  kpktgend_0  [kernel.kallsyms]  [k] kthread_should_stop
> +    0.03%  kpktgend_0  [kernel.kallsyms]  [k] _cond_resched
>
> For *all* three, I reliably get ~40.0 Mpps with the benchmark.

@Daniel, Alexei: Are you getting the same numbers with the indirection?

What's the i-cache size in your testbed?

Thanks.
