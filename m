From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Sat, 23 Feb 2008 20:23:51 +1100
Message-ID: <200802232023.52352.nickpiggin@yahoo.com.au>
References: <47BDBC23.10605@cosmosbay.com> <1203632765.6112.20.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Christoph Lameter <clameter@sgi.com>,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764864AbYBWJY0@vger.kernel.org>
In-Reply-To: <1203632765.6112.20.camel@lappy>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 22 February 2008 09:26, Peter Zijlstra wrote:
> On Thu, 2008-02-21 at 19:00 +0100, Eric Dumazet wrote:
> > Some oprofile results obtained while using tbench on a 2x2 cpu machine
> > were very surprising.
> >
> > For example, loopback_xmit() function was using high number of cpu
> > cycles to perform the statistic updates, supposed to be real cheap
> > since they use percpu data
> >
> >         pcpu_lstats = netdev_priv(dev);
> >         lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
> >         lb_stats->packets++;  /* HERE : serious contention */
> >         lb_stats->bytes += skb->len;
> >
> >
> > struct pcpu_lstats is a small structure containing two longs. It
> > appears that on my 32bits platform, alloc_percpu(8) allocates a single
> > cache line,  instead of giving to each cpu a separate cache line.
> >
> > Using the following patch gave me impressive boost in various
> > benchmarks ( 6 % in tbench) (all percpu_counters hit this bug too)
> >
> > Long term fix (ie >= 2.6.26) would be to let each CPU allocate their
> > own block of memory, so that we dont need to roudup sizes to
> > L1_CACHE_BYTES, or merging the SGI stuff of course...
> >
> > Note : SLUB vs SLAB is important here to *show* the improvement, since
> > they dont have the same minimum allocation sizes (8 bytes vs 32
> > bytes). This could very well explain regressions some guys reported
> > when they switched to SLUB.
>
> I've complained about this false sharing as well, so until we get the
> new and improved percpu allocators,

What I don't understand is why the slab allocators have something like
this in it:

        if ((flags & SLAB_HWCACHE_ALIGN) &&
                        size > cache_line_size() / 2)
                return max_t(unsigned long, align, cache_line_size());

If you ask for HWCACHE_ALIGN, then you should get it. I don't
understand, why do they think they knows better than the caller?
Things like this are just going to lead to very difficult to track
performance problems. Possibly correctness problems in rare cases.

There could be another flag for "maybe align".
