From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Fri, 18 Oct 2013 08:43:21 +0200
Message-ID: <20131018064321.GG14264@gmail.com>
References: <1381510298-20572-1-git-send-email-nhorman@tuxdriver.com>
 <20131012172124.GA18241@gmail.com>
 <20131014202854.GH26880@hmsreliant.think-freely.org>
 <1381785560.2045.11.camel@edumazet-glaptop.roam.corp.google.com>
 <1381789127.2045.22.camel@edumazet-glaptop.roam.corp.google.com>
 <20131017003421.GA31470@hmsreliant.think-freely.org>
 <20131017084121.GC22705@gmail.com>
 <52602A29.506@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52602A29.506@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* H. Peter Anvin <hpa@zytor.com> wrote:

> On 10/17/2013 01:41 AM, Ingo Molnar wrote:
> > 
> > To correctly simulate the workload you'd have to:
> > 
> >  - allocate a buffer larger than your L2 cache.
> > 
> >  - to measure the effects of the prefetches you'd also have to randomize
> >    the individual buffer positions. See how 'perf bench numa' implements a
> >    random walk via --data_rand_walk, in tools/perf/bench/numa.c.
> >    Otherwise the CPU might learn your simplistic stream direction and the
> >    L2 cache might hw-prefetch your data, interfering with any explicit 
> >    prefetches the code does. In many real-life usecases packet buffers are
> >    scattered.
> > 
> > Also, it would be nice to see standard deviation noise numbers when two 
> > averages are close to each other, to be able to tell whether differences 
> > are statistically significant or not.
> 
> 
> Seriously, though, how much does it matter?  All the above seems likely 
> to do is to drown the signal by adding noise.

I think it matters a lot and I don't think it 'adds' noise - it measures 
something else (cache cold behavior - which is the common case for 
first-time csum_partial() use for network packets), which was not measured 
before, and that that is by its nature has different noise patterns.

I've done many cache-cold measurements myself and had no trouble achieving 
statistically significant results and high precision.

> If the parallel (threaded) checksumming is faster, which theory says it 
> should and microbenchmarking confirms, how important are the 
> macrobenchmarks?

Microbenchmarks can be totally blind to things like the ideal prefetch 
window size. (or whether a prefetch should be done at all: some CPUs will 
throw away prefetches if enough regular fetches arrive.)

Also, 'naive' single-threaded algorithms can occasionally be better in the 
cache-cold case because a linear, predictable stream of memory accesses 
might saturate the memory bus better than a somewhat random looking, 
interleaved web of accesses that might not harmonize with buffer depths.

I _think_ if correctly tuned then the parallel algorithm should be better 
in the cache cold case, I just don't know with what parameters (and the 
algorithm has at least one free parameter: the prefetch window size), and 
I don't know how significant the effect is.

Also, more fundamentally, I absolutely detest doing no measurements or 
measuring the wrong thing - IMHO there are too many 'blind' optimization 
commits in the kernel with little to no observational data attached.

Thanks,

	Ingo
