From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [Fwd: Re: [PATCH v2 2/2] x86: add prefetching to do_csum]
Date: Wed, 13 Nov 2013 14:08:32 +0100
Message-ID: <20131113130832.GB22140@gmail.com>
References: <1384220542.4771.23.camel@joe-AO722>
 <20131112171239.GC19780@hmsreliant.think-freely.org>
 <1384277615.3665.10.camel@joe-AO722>
 <20131112195005.GD19780@hmsreliant.think-freely.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B740E@saturn3.aculab.com>
 <20131113123010.GB2993@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>,
	Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org,
	sebastien.dugue@bull.net, Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131113123010.GB2993@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Neil Horman <nhorman@tuxdriver.com> wrote:

> On Wed, Nov 13, 2013 at 10:09:51AM -0000, David Laight wrote:
> > > Sure, I modified the code so that we only prefetched 2 cache lines ahead, but
> > > only if the overall length of the input buffer is more than 2 cache lines.
> > > Below are the results (all counts are the average of 1000000 iterations of the
> > > csum operation, as previous tests were, I just omitted that column).
> > 
> > Hmmm.... averaging over 100000 iterations means that all the code
> > is in the i-cache and the branch predictor will be correctly primed.
> > 
> > For short checksum requests I'd guess that the relevant data
> > has just been written and is already in the cpu cache (unless
> > there has been a process and cpu switch).
> > So prefetch is likely to be unnecessary.
> > 
> > If you assume that the checksum code isn't in the i-cache then
> > small requests are likely to be dominated by the code size.
> 
> I'm not sure, whats the typical capacity for the branch predictors 
> ability to remember code paths?  I ask because the most likely use of 
> do_csum will be in the receive path of the networking stack 
> (specifically in the softirq handler). So if we run do_csum once, we're 
> likely to run it many more times, as we clean out an adapters receive 
> queue.

For such simple single-target branches it goes near or over a thousand for 
recent Intel and AMD microarchitectures. Thousands for really recent CPUs.

Note that branch prediction caches are hierarchical and are typically 
attached to cache hierarchies (where the uops are fetched from), so the 
first level BTB is typically shared between SMT CPUs that share an icache 
and L2 BTBs (which is larger and more associative) are shared by all cores 
in a package.

So it's possible for some other task on another (sibling) CPU to keep 
pressure on your BTB, but I'd say it's relatively rare, it's hard to do it 
at a really high rate that blows away all the cache all the time. (PeterZ 
has written some artificial pseudorandom branching monster just to be able 
to generate cache misses and validate perf's branch stats - but even if 
deliberately want to it's pretty hard to beat that cache.)

I'd definitely not worry about the prediction accuracy of repetitive loops 
like csum routines, they'll be cached well.

Thanks,

	Ingo
