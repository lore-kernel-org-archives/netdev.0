From: Florian Westphal <fw@strlen.de>
Subject: Re: 4.9 conntrack performance issues
Date: Sun, 15 Jan 2017 00:53:33 +0100
Message-ID: <20170114235333.GA13421@breakpoint.cc>
References: <1a71d807acf63135bb037c7144fcd8d9@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guillaume Nault <g.nault@alphalink.fr>,
        Netfilter Devel <netfilter-devel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        nicolas.dichtel@6wind.com
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46238 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750743AbdANXxs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 18:53:48 -0500
Content-Disposition: inline
In-Reply-To: <1a71d807acf63135bb037c7144fcd8d9@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko <nuclearcat@nuclearcat.com> wrote:

[ CC Nicolas since he also played with gc heuristics in the past ]

> Sorry if i added someone wrongly to CC, please let me know, if i should
> remove.
> I just run successfully 4.9 on my nat several days ago, and seems panic
> issue disappeared. But i started to face another issue, it seems garbage
> collector is hogging one of CPU's.
>
> It was handling load very well at 4.8 and below, it might be still fine, but
> i suspect queues that belong to hogged cpu might experience issues.

The worker doesn't grab locks for long and calls scheduler for every
bucket to give a chance for other threads to run.

It also doesn't block softinterrupts.

> Is there anything can be done to improve cpu load distribution or reduce
> single core load?

No, I am afraid we don't export any of the heuristics as tuneables so
far.

You could try changing defaults in net/netfilter/nf_conntrack_core.c:

#define GC_MAX_BUCKETS_DIV      64u
/* upper bound of scan intervals */
#define GC_INTERVAL_MAX         (2 * HZ)
/* maximum conntracks to evict per gc run */
#define GC_MAX_EVICTS           256u

(the first two result in ~2 minute worst case timeout detection
 on a fully idle system).

For instance you could use

GC_MAX_BUCKETS_DIV -> 128
GC_INTERVAL_MAX    -> 30 * HZ

(This means that it takes one hour for a dead connection to be picked
 up on an idle system, but thats only relevant in case you use
 conntrack events to log when connection went down and need more precise
 accounting).

I suspect you might also have to change

1011         } else if (expired_count) {
1012                 gc_work->next_gc_run /= 2U;
1013                 next_run = msecs_to_jiffies(1);
1014         } else {

line 2013 to
	next_run = msecs_to_jiffies(HZ / 2);

or something like this to not have frequent rescans.

The gc is also done from the packet path (i.e. accounted
towards (k)softirq).

How many total connections is the machine handling on average?
And how many new/delete events happen per second?

>     88.98%     0.00%  kworker/24:1  [kernel.kallsyms]       [k]
> process_one_work
>             |
>             ---process_one_work
>                |
>                |--54.65%--gc_worker
>                |          |
>                |           --3.58%--nf_ct_gc_expired
>                |                     |
>                |                     |--1.90%--nf_ct_delete

I'd be interested to see how often that shows up on other cores
(from packet path).
