From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Tue, 29 Oct 2013 07:20:22 -0400
Message-ID: <20131029112022.GA24477@neilslaptop.think-freely.org>
References: <20131014202854.GH26880@hmsreliant.think-freely.org>
 <1381785560.2045.11.camel@edumazet-glaptop.roam.corp.google.com>
 <1381789127.2045.22.camel@edumazet-glaptop.roam.corp.google.com>
 <20131017003421.GA31470@hmsreliant.think-freely.org>
 <20131017084121.GC22705@gmail.com>
 <20131028160131.GA31048@hmsreliant.think-freely.org>
 <20131028162438.GB14350@gmail.com>
 <20131028174630.GB31048@hmsreliant.think-freely.org>
 <20131028182913.GD31048@hmsreliant.think-freely.org>
 <20131029082542.GA24625@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131029082542.GA24625@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 09:25:42AM +0100, Ingo Molnar wrote:
> 
> * Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > Heres my data for running the same test with taskset restricting 
> > execution to only cpu0.  I'm not quite sure whats going on here, 
> > but doing so resulted in a 10x slowdown of the runtime of each 
> > iteration which I can't explain.  As before however, both the 
> > parallel alu run and the prefetch run resulted in speedups, but 
> > the two together were not in any way addative.  I'm going to keep 
> > playing with the prefetch stride, unless you have an alternate 
> > theory.
> 
> Could you please cite the exact command-line you used for running 
> the test?
> 
> Thanks,
> 
> 	Ingo
> 

Sure it was this:
for i in `seq 0 1 3`
do
echo $i > /sys/module/csum_test/parameters/module_test_mode
taskset -c 0 perf stat --repeat 20 -C 0 -ddd perf bench sched messaging -- /root/test.sh
done >> counters.txt 2>&1

where test.sh is:
#!/bin/sh
echo 1 > /sys/module/csum_test/parameters/test_fire


As before, module_test_mode selects a case in a switch statement I added in
do_csum to test one of the 4 csum variants we've been discusing (base, prefetch,
parallel ALU or both), and test_fire is a callback trigger I use in the test
module to run 100000 iterations of a checksum operation.  As you requested, I
ran the above on cpu 0 (-C 0 on perf and -c 0 on taskset), and I removed all irq
affinity to cpu 0.

Regards
Neil
