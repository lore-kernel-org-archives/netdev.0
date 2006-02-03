From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables --
 proto.sockets_allocated
Date: Thu, 2 Feb 2006 19:16:00 -0800
Message-ID: <20060202191600.3bf3a64a.akpm@osdl.org>
References: <20060126185649.GB3651@localhost.localdomain>
	<20060126190357.GE3651@localhost.localdomain>
	<43D9DFA1.9070802@cosmosbay.com>
	<20060127195227.GA3565@localhost.localdomain>
	<20060127121602.18bc3f25.akpm@osdl.org>
	<20060127224433.GB3565@localhost.localdomain>
	<20060127150106.38b9e041.akpm@osdl.org>
	<20060203030547.GB3612@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com, bcrl@kvack.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964875AbWBCDRP@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
In-Reply-To: <20060203030547.GB3612@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
>
> On Fri, Jan 27, 2006 at 03:01:06PM -0800, Andrew Morton wrote:
> > Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
> > 
> > 
> > > > 
> > > > If the benchmarks say that we need to.  If we cannot observe any problems
> > > > in testing of existing code and if we can't demonstrate any benefit from
> > > > the patched code then one option is to go off and do something else ;)
> > > 
> > > We first tried plain per-CPU counters for memory_allocated, found that reads
> > > on memory_allocated was causing cacheline transfers, and then
> > > switched over to batching.  So batching reads is useful.  To avoid
> > > inaccuracy, we can maybe change percpu_counter_init to:
> > > 
> > > void percpu_counter_init(struct percpu_counter *fbc, int maxdev)
> > > 
> > > the percpu batching limit would then be maxdev/num_possible_cpus.  One would
> > > use batching counters only when both reads and writes are frequent.  With
> > > the above scheme, we would go fetch cachelines from other cpus for read
> > > often only on large cpu counts, which is not any worse than the global
> > > counter alternative, but it would still be beneficial on smaller machines,
> > > without sacrificing a pre-set deviation.  
> > > 
> > > Comments?
> > 
> > Sounds sane.
> >
> 
> Here's an implementation which delegates tuning of batching to the user.  We
> don't really need local_t at all as percpu_counter_mod is not safe against
> interrupts and softirqs  as it is.  If we have a counter which could be
> modified in process context and irq/bh context, we just have to use a
> wrapper like percpu_counter_mod_bh which will just disable and enable bottom
> halves.  Reads on the counters are safe as they are atomic_reads, and the
> cpu local variables are always accessed by that cpu only.
> 
> (PS: the maxerr for ext2/ext3 is just guesstimate)

Well that's the problem.  We need to choose production-quality values for
use in there.

> Comments?

Using num_possible_cpus() in that header file is just asking for build
errors.  Probably best to uninline the function rather than adding the
needed include of cpumask.h.
