From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Tue, 11 Mar 2008 14:15:30 -0400
Message-ID: <170fa0d20803111115n3e8eb438s9b1ad7fff2fb8672@mail.gmail.com>
References: <47BDBC23.10605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"linux kernel" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "Christoph Lameter" <clameter@sgi.com>,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	"Peter Zijlstra" <a.p.zijlstra@chello.nl>, stable@kernel.org
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:39785 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758AbYCKSPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 14:15:42 -0400
Received: by wf-out-1314.google.com with SMTP id 28so2532611wff.4
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2008 11:15:39 -0700 (PDT)
In-Reply-To: <47BDBC23.10605@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/21/08, Eric Dumazet <dada1@cosmosbay.com> wrote:
> Some oprofile results obtained while using tbench on a 2x2 cpu machine
>  were very surprising.
>
>  For example, loopback_xmit() function was using high number of cpu
>  cycles to perform
>  the statistic updates, supposed to be real cheap since they use percpu data
>
>         pcpu_lstats = netdev_priv(dev);
>         lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
>         lb_stats->packets++;  /* HERE : serious contention */
>         lb_stats->bytes += skb->len;
>
>
>  struct pcpu_lstats is a small structure containing two longs. It appears
>  that on my 32bits platform,
>  alloc_percpu(8) allocates a single cache line,  instead of giving to
>  each cpu a separate
>  cache line.
>
>  Using the following patch gave me impressive boost in various benchmarks
>  ( 6 % in tbench)
>  (all percpu_counters hit this bug too)
>
>  Long term fix (ie >= 2.6.26) would be to let each CPU allocate their own
>  block of memory, so that we
>  dont need to roudup sizes to L1_CACHE_BYTES, or merging the SGI stuff of
>  course...
>
>  Note : SLUB vs SLAB is important here to *show* the improvement, since
>  they dont have the same minimum
>  allocation sizes (8 bytes vs 32 bytes).
>  This could very well explain regressions some guys reported when they
>  switched to SLUB.


I see that this fix was committed to mainline as commit
be852795e1c8d3829ddf3cb1ce806113611fa555

The commit didn't "Cc: <stable@kernel.org>", and it doesn't appear to
be queued for 2.6.24.x.  Should it be?

If I understand you correctly, SLAB doesn't create this particular
cache thrashing on 32bit systems?  Is SLAB ok on other architectures
too?  Can you (or others) comment on the importance of this fix
relative to x86_64 (64byte cacheline) and SLAB?

I'm particularly interested in this given the use of percpu_counters
with the per bdi write throttling.

Mike
