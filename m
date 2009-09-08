From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Stop using tasklets for bottom halves
Date: Tue, 8 Sep 2009 09:10:05 +0200
Message-ID: <20090908071005.GA10273@elte.hu>
References: <43e72e890909071558s637b45c7i10807587dc40e8c4@mail.gmail.com> <20090907171406.6a4b6116@nehalam> <1252376254.21261.2052.camel@gandalf.stny.rr.com> <200909080650.43181.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, Stephen Hemminger <shemminger@vyatta.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Matt Smith <Matt.Smith@atheros.com>,
	Kevin Hayes <kevin@atheros.com>,
	Bob Copeland <me@bobcopeland.com>, Jouni Malinen <j@w1.fi>,
	Ivan Seskar <Seskar@winlab.rutgers.edu>, ic.felix@gmail.com
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:41358 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753562AbZIHHKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2009 03:10:25 -0400
Content-Disposition: inline
In-Reply-To: <200909080650.43181.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Michael Buesch <mb@bu3sch.de> wrote:

> There are two things that I noticed. When looking at the "idle" 
> percentage in "top" it regressed quite a bit when using threaded 
> IRQ handlers. It shows about 8% less idle. This is with threaded 
> IRQs patched in, but without WQ TX mechanism. Applying the WQ TX 
> mechanism does not show any noticeable effect in "top".
> 
> I'm not quite sure where the 8% slowdown on threaded IRQ handlers 
> come from. I'm not really certain that it's _really_ a regression 
> and not just a statistics accounting quirk. Why does threaded IRQs 
> slow down stuff and threaded TX does not at all? That does not 
> make sense at all to me.

Do you have an x86 box to test it on?

If yes then perfcounters can be used for _much_ more precise 
measurements that you can trust. Do something like this:

   perf stat -a --repeat 3 sleep 1

The '-a/--all' option will measure all CPUs - everything: IRQ 
context, irqs-off region, etc. That output will be comparable before 
your threaded patch and after the patch.

Here's an example. I started one infinite loop on a testbox, which 
is using 100% of a single CPU. The system-wide stats look like this:

 # perf stat -a --repeat 3 sleep 1

 Performance counter stats for 'sleep 1' (3 runs):

   16003.320239  task-clock-msecs         #     15.993 CPUs    ( +-   0.044% )
             94  context-switches         #      0.000 M/sec   ( +-  11.373% )
              3  CPU-migrations           #      0.000 M/sec   ( +-  25.000% )
            170  page-faults              #      0.000 M/sec   ( +-  0.518% )
     3294001334  cycles                   #    205.832 M/sec   ( +-  0.896% )
     1088670782  instructions             #      0.331 IPC     ( +-  0.905% )
        1720926  cache-references         #      0.108 M/sec   ( +-  1.880% )
          61253  cache-misses             #      0.004 M/sec   ( +-  4.401% )

    1.000623219  seconds time elapsed   ( +-   0.002% )

the instructions count or the cycle count will go up or down, 
precisely according to how the threaded handlers. These stats are 
not time sampled but 'real', so they reflect reality and show 
whether your workload had to spend more (or less) cycles / 
instructions /etc.

I started a second loop in addition to the first one, and perf stat 
now gives me this output:

 # perf stat -a --repeat 3 sleep 1

 Performance counter stats for 'sleep 1' (3 runs):

   16003.289509  task-clock-msecs         #     15.994 CPUs    ( +-   0.046% )
             88  context-switches         #      0.000 M/sec   ( +-  15.933% )
              2  CPU-migrations           #      0.000 M/sec   ( +-  14.286% )
            188  page-faults              #      0.000 M/sec   ( +-   9.414% )
     6481963224  cycles                   #    405.039 M/sec   ( +-   0.011% )
     2152924468  instructions             #      0.332 IPC     ( +-   0.054% )
         397564  cache-references         #      0.025 M/sec   ( +-   1.217% )
          59835  cache-misses             #      0.004 M/sec   ( +-   3.732% )

    1.000576354  seconds time elapsed   ( +-   0.005% )

Compare the two results:

 before:
     6481963224  cycles                   #    405.039 M/sec   ( +-   0.011% )
     2152924468  instructions             #      0.332 IPC     ( +-   0.054% )

 after:
     3294001334  cycles                   #    205.832 M/sec   ( +-  0.896% )
     1088670782  instructions             #      0.331 IPC     ( +-  0.905% )

The cycles/sec doubled - as expected. You could do the same with 
your test and not have to rely in the very imprecise (and often 
misleading) 'top' statistics for kernel development.

The IPC (instructions per cycle) factor stayed roughly constant - 
showing that both workloads can push the same amount of instructions 
when normalized to a single CPU. If a workload becomes very 
cache-missy or executes a lot of system calls then the IPC factor 
goes down - if it becomes more optimal 'tight' code then the IPC 
factor goes up.)

(The cache-miss rate was very low in both cases - it's a simple 
infinite loop i tested.)

Furthermore the error bars in the rightmost column help you know 
whether any difference in results is statistically significant, or 
within the noise level.

Hope this helps,

	Ingo
