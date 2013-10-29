From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Tue, 29 Oct 2013 13:52:33 +0100
Message-ID: <20131029125233.GA17449@gmail.com>
References: <20131017003421.GA31470@hmsreliant.think-freely.org>
 <20131017084121.GC22705@gmail.com>
 <20131028160131.GA31048@hmsreliant.think-freely.org>
 <20131028162438.GB14350@gmail.com>
 <20131028174630.GB31048@hmsreliant.think-freely.org>
 <20131028182913.GD31048@hmsreliant.think-freely.org>
 <20131029082542.GA24625@gmail.com>
 <20131029112022.GA24477@neilslaptop.think-freely.org>
 <20131029113031.GA16897@gmail.com>
 <20131029114907.GE24477@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131029114907.GE24477@neilslaptop.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Neil Horman <nhorman@tuxdriver.com> wrote:

> On Tue, Oct 29, 2013 at 12:30:31PM +0100, Ingo Molnar wrote:
> > 
> > * Neil Horman <nhorman@tuxdriver.com> wrote:
> > 
> > > Sure it was this:
> > > for i in `seq 0 1 3`
> > > do
> > > echo $i > /sys/module/csum_test/parameters/module_test_mode
> > > taskset -c 0 perf stat --repeat 20 -C 0 -ddd perf bench sched messaging -- /root/test.sh
> > > done >> counters.txt 2>&1
> > > 
> > > where test.sh is:
> > > #!/bin/sh
> > > echo 1 > /sys/module/csum_test/parameters/test_fire
> > 
> > What does '-- /root/test.sh' do?
> > 
> > Unless I'm missing something, the line above will run:
> > 
> >   perf bench sched messaging -- /root/test.sh
> > 
> > which should be equivalent to:
> > 
> >   perf bench sched messaging
> > 
> > i.e. /root/test.sh won't be run.
> 
> According to the perf man page, I'm supposed to be able to use -- 
> to separate perf command line parameters from the command I want 
> to run.  And it definately executed test.sh, I added an echo to 
> stdout in there as a test run and observed them get captured in 
> counters.txt

Well, '--' can be used to delineate the command portion for cases 
where it's ambiguous.

Here's it's unambiguous though. This:

  perf stat --repeat 20 -C 0 -ddd perf bench sched messaging -- /root/test.sh

stops parsing a valid option after the -ddd option, so in theory it 
should execute 'perf bench sched messaging -- /root/test.sh' where 
'-- /root/test.sh' is simply a parameter to 'perf bench' and is thus 
ignored.

The message output you provided seems to suggest that to be the 
case:

 Performance counter stats for 'perf bench sched messaging -- bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

See how the command executed by perf stat was 'perf bench ...'.

Did you want to run:

  perf stat --repeat 20 -C 0 -ddd /root/test.sh

?

Thanks,

	Ingo
