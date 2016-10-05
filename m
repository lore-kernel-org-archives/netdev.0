From: Julia Cartwright <julia@ni.com>
Subject: Re: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Wed, 5 Oct 2016 10:59:59 -0500
Message-ID: <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
References: <c91ce66d47ff470a94e10e2347eafe4a@FE-MBX1012.de.bosch.com>
 <ac1207c12ad34059956c2729ccf31e97@FE-MBX1012.de.bosch.com>
 <20160923123224.odybv2uos6tot6it@linutronix.de>
 <ae35c863cdf246ac8da94277418921ef@FE-MBX1012.de.bosch.com>
 <20160923144140.5tkzeymamrb5qnsv@linutronix.de>
 <a5ea146cf078457ab001131ca0886b0b@FE-MBX1012.de.bosch.com>
 <20160928194519.GA32423@jcartwri.amer.corp.natinst.com>
 <487032ca81f84e70bdacc39a024eff5e@FE-MBX1012.de.bosch.com>
 <20161004193445.GF10625@jcartwri.amer.corp.natinst.com>
 <584755c2766e4b94a604ece16760fe14@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <584755c2766e4b94a604ece16760fe14@FE-MBX1012.de.bosch.com>
Content-Disposition: inline
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 05, 2016 at 07:02:21AM +0000, Koehrer Mathias (ETAS/ESW5) wrote:
> Hi Julia,
> 
> > > In the meanwhile I have detected another finding which might be relevant:
> > >
> > > With the 3.18 kernel the igb driver comes with two interrupts per
> > > NIC (e.g. eth2 and eth2-TxRx0) with the 4.6. kernel the igb driver
> > > comes with 9 (!) interrupts per NIC: eth2, and eth2-TxRx-0,
> > > eth2-TxRx-1, ... , eth2-TxRx-7.
> > >
> > > As I have used initially the same kernel configuration from 3.18 also
> > > for the 4.6. kernel I wonder where this comes from and if there is any
> > > kernel option I may use to disable these many interrupts and to reduce
> > > it to 2 again.
> > 
> > If it's all of these interrupts that are firing and being handled at the same time, that
> > can account for the latencies you were seeing.  As I suggested before, having a
> > trace with the sched_wakeup event enabled can help confirm that it's these
> > interrupts causing problems.
> > 
> > If it is true, then the question is: why is the device triggering all of these interrupts all
> > at once?  Is that expected?  These are questions for netdev folks, I think.
> > 
> >    Julia
> 
> OK - I ran again the cyclictest. This time I used the -C option:
> # cyclictest -a -i 100 -m -n -p 80 -t 1 -b 21 -C
> 
> And the last output lines of the trace are:
> cyclicte-5887    0d...2.. 1504647266us!: sched_switch: prev_comm=cyclictest prev_pid=5887 prev_prio=19 prev_state=S ==> next_comm=kworker/0:0 next_pid=5 next_prio=120
> kworker/-5       0dN.h2.. 1504647372us : sched_wakeup: comm=cyclictest pid=5887 prio=19 target_cpu=000
> kworker/-5       0dN.h3.. 1504647374us : sched_wakeup: comm=irq/54-eth2-TxR pid=5883 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647375us : sched_wakeup: comm=irq/53-eth2-TxR pid=5882 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647377us : sched_wakeup: comm=irq/52-eth2-TxR pid=5881 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647378us : sched_wakeup: comm=irq/51-eth2-TxR pid=5880 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647380us : sched_wakeup: comm=irq/50-eth2-TxR pid=5879 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647381us : sched_wakeup: comm=irq/49-eth2-TxR pid=5878 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647382us : sched_wakeup: comm=irq/48-eth2-TxR pid=5877 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1504647383us : sched_wakeup: comm=irq/47-eth2-TxR pid=5876 prio=49 target_cpu=000
> kworker/-5       0d...2.. 1504647384us : sched_switch: prev_comm=kworker/0:0 prev_pid=5 prev_prio=120 prev_state=R+ ==> next_comm=cyclictest next_pid=5887 next_prio=19
> cyclicte-5887    0.....11 1504647389us : tracing_mark_write: hit latency threshold (28 > 21)
> 
> The attached trace-extract.gz shows some more lines.
> It actually looks to me as if the the many irq threads from igb are causing the issue.

Yes, I think so.

Although, to be clear, it isn't the fact that there exists 8 threads,
it's that the device is firing all 8 interrupts at the same time.  The
time spent in hardirq context just waking up all 8 of those threads (and
the cyclictest wakeup) is enough to cause your regression.

netdev/igb folks-

Under what conditions should it be expected that the i350 trigger all of
the TxRx interrupts simultaneously?  Any ideas here?

See the start of this thread here:

  http://lkml.kernel.org/r/d648628329bc446fa63b5e19d4d3fb56@FE-MBX1012.de.bosch.com

   Julia
