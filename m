From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Page allocator order-0 optimizations merged
Date: Mon, 27 Mar 2017 13:28:16 +0100
Message-ID: <20170327122816.dvnfxkyqxasfiknj@techsingularity.net>
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
 <d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
 <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
 <20170322234004.kffsce4owewgpqnm@techsingularity.net>
 <20170323144347.1e6f29de@redhat.com>
 <20170323145133.twzt4f5ci26vdyut@techsingularity.net>
 <779ab72d-94b9-1a28-c192-377e91383b4e@gmail.com>
 <1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
 <2123321554.7161128.1490599967015.JavaMail.zimbra@redhat.com>
 <20170327105514.1ed5b1ba@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Pankaj Gupta <pagupta@redhat.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20170327105514.1ed5b1ba@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 27, 2017 at 10:55:14AM +0200, Jesper Dangaard Brouer wrote:
> On Mon, 27 Mar 2017 03:32:47 -0400 (EDT)
> Pankaj Gupta <pagupta@redhat.com> wrote:
> 
> > Hello,
> > 
> > It looks like a race with softirq and normal process context.
> > 
> > Just thinking if we really want allocations from 'softirqs' to be
> > done using per cpu list? 
> 
> Yes, softirq need fast page allocs. The softirq use-case is refilling
> the DMA RX rings, which is time critical, especially for NIC drivers.
> For this reason most drivers implement different page recycling tricks.
> 
> > Or we can have some check in  'free_hot_cold_page' for softirqs 
> > to check if we are on a path of returning from hard interrupt don't
> > allocate from per cpu list.
> 
> A possible solution, would be use the local_bh_{disable,enable} instead
> of the {preempt_disable,enable} calls.  But it is slower, using numbers
> from [1] (19 vs 11 cycles), thus the expected cycles saving is 38-19=19.
> 
> The problematic part of using local_bh_enable is that this adds a
> softirq/bottom-halves rescheduling point (as it checks for pending
> BHs).  Thus, this might affects real workloads.
> 
> 
> I'm unsure what the best option is.  I'm leaning towards partly
> reverting[1] and go back to doing the slower local_irq_save +
> local_irq_restore as before.
> 
> Afterwards we can add a bulk page alloc+free call, that can amortize
> this 38 cycles cost (of local_irq_{save,restore}).  Or add a function
> call that MUST only be called from contexts with IRQs enabled, which
> allow using the unconditionally local_irq_{disable,enable} as it only
> costs 7 cycles.
> 

It's possible to have a separate list for hard/soft IRQ that are protected
although great care is needed to drain properly. I have a partial prototype
lying around marked as "interesting if we ever need it" but it needs more
work. It's sufficiently complex that I couldn't rush it as a fix with the
time I currently have available. For 4.11, it's safer to revert and try
again later bearing in mind that softirqs are in the critical allocation
path for some drivers.

I'll prepare a patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
