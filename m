From: Henri Roosen <henri.roosen@ginzinger.com>
Subject: Re: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Thu, 6 Oct 2016 12:12:12 +0200
Message-ID: <ab4f2dd2-6227-8f5b-c175-2b80e8a1c08c@ginzinger.com>
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
 <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
 <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>,
        Julia Cartwright <julia@ni.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Greg <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ginzinger.com ([31.193.165.229]:28630 "EHLO
        mail.ginzinger.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752365AbcJFKUV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 06:20:21 -0400
In-Reply-To: <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2016 09:01 AM, Koehrer Mathias (ETAS/ESW5) wrote:
> Hi all,

Hi Mathias,

>>
>> Although, to be clear, it isn't the fact that there exists 8 threads, it's that the device is
>> firing all 8 interrupts at the same time.  The time spent in hardirq context just waking
>> up all 8 of those threads (and the cyclictest wakeup) is enough to cause your
>> regression.
>>
>> netdev/igb folks-
>>
>> Under what conditions should it be expected that the i350 trigger all of the TxRx
>> interrupts simultaneously?  Any ideas here?
>>
>> See the start of this thread here:
>>
>>   http://lkml.kernel.org/r/d648628329bc446fa63b5e19d4d3fb56@FE-
>> MBX1012.de.bosch.com
>>
> Greg recommended to use "ethtool -L eth2 combined 1" to reduce the number of queues.
> I tried that. Now, I have actually only three irqs (eth2, eth2-rx-0, eth2-tx-0).
> However the issue remains the same.
>
> I ran the cyclictest again:
> # cyclictest -a -i 105 -m -n -p 80 -t 1  -b 23 -C
> (Note: When using 105us instead of 100us the long latencies seem to occur more often).
>
> Here are the final lines of the kernel trace output:
>   <idle>-0       4d...2.. 1344661649us : sched_switch: prev_comm=swapper/4 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=rcuc/4 next_pid=56 next_prio=98
> ktimerso-46      3d...2.. 1344661650us : sched_switch: prev_comm=ktimersoftd/3 prev_pid=46 prev_prio=98 prev_state=S ==> next_comm=swapper/3 next_pid=0 next_prio=120
> ktimerso-24      1d...2.. 1344661650us : sched_switch: prev_comm=ktimersoftd/1 prev_pid=24 prev_prio=98 prev_state=S ==> next_comm=swapper/1 next_pid=0 next_prio=120
> ktimerso-79      6d...2.. 1344661650us : sched_switch: prev_comm=ktimersoftd/6 prev_pid=79 prev_prio=98 prev_state=S ==> next_comm=swapper/6 next_pid=0 next_prio=120
> ktimerso-35      2d...2.. 1344661650us : sched_switch: prev_comm=ktimersoftd/2 prev_pid=35 prev_prio=98 prev_state=S ==> next_comm=swapper/2 next_pid=0 next_prio=120
>   rcuc/5-67      5d...2.. 1344661650us : sched_switch: prev_comm=rcuc/5 prev_pid=67 prev_prio=98 prev_state=S ==> next_comm=ktimersoftd/5 next_pid=68 next_prio=98
>   rcuc/7-89      7d...2.. 1344661650us : sched_switch: prev_comm=rcuc/7 prev_pid=89 prev_prio=98 prev_state=S ==> next_comm=ktimersoftd/7 next_pid=90 next_prio=98
> ktimerso-4       0d...211 1344661650us : sched_wakeup: comm=rcu_preempt pid=8 prio=98 target_cpu=000
>   rcuc/4-56      4d...2.. 1344661651us : sched_switch: prev_comm=rcuc/4 prev_pid=56 prev_prio=98 prev_state=S ==> next_comm=ktimersoftd/4 next_pid=57 next_prio=98
> ktimerso-4       0d...2.. 1344661651us : sched_switch: prev_comm=ktimersoftd/0 prev_pid=4 prev_prio=98 prev_state=S ==> next_comm=rcu_preempt next_pid=8 next_prio=98
> ktimerso-90      7d...2.. 1344661651us : sched_switch: prev_comm=ktimersoftd/7 prev_pid=90 prev_prio=98 prev_state=S ==> next_comm=swapper/7 next_pid=0 next_prio=120
> ktimerso-68      5d...2.. 1344661651us : sched_switch: prev_comm=ktimersoftd/5 prev_pid=68 prev_prio=98 prev_state=S ==> next_comm=swapper/5 next_pid=0 next_prio=120
> rcu_pree-8       0d...3.. 1344661652us : sched_wakeup: comm=rcuop/0 pid=10 prio=120 target_cpu=000
> ktimerso-57      4d...2.. 1344661652us : sched_switch: prev_comm=ktimersoftd/4 prev_pid=57 prev_prio=98 prev_state=S ==> next_comm=swapper/4 next_pid=0 next_prio=120
> rcu_pree-8       0d...2.. 1344661653us+: sched_switch: prev_comm=rcu_preempt prev_pid=8 prev_prio=98 prev_state=S ==> next_comm=kworker/0:0 next_pid=5 next_prio=120
> kworker/-5       0dN.h2.. 1344661741us : sched_wakeup: comm=cyclictest pid=6314 prio=19 target_cpu=000
> kworker/-5       0d...2.. 1344661742us : sched_switch: prev_comm=kworker/0:0 prev_pid=5 prev_prio=120 prev_state=R+ ==> next_comm=cyclictest next_pid=6314 next_prio=19
> cyclicte-6314    0d...2.. 1344661743us : sched_switch: prev_comm=cyclictest prev_pid=6314 prev_prio=19 prev_state=S ==> next_comm=rcuop/0 next_pid=10 next_prio=120
>  rcuop/0-10      0d...2.. 1344661744us!: sched_switch: prev_comm=rcuop/0 prev_pid=10 prev_prio=120 prev_state=S ==> next_comm=kworker/0:0 next_pid=5 next_prio=120
> kworker/-5       0dN.h2.. 1344661858us : sched_wakeup: comm=cyclictest pid=6314 prio=19 target_cpu=000
> kworker/-5       0d...2.. 1344661859us : sched_switch: prev_comm=kworker/0:0 prev_pid=5 prev_prio=120 prev_state=R+ ==> next_comm=cyclictest next_pid=6314 next_prio=19
> cyclicte-6314    0d...2.. 1344661860us!: sched_switch: prev_comm=cyclictest prev_pid=6314 prev_prio=19 prev_state=S ==> next_comm=kworker/0:0 next_pid=5 next_prio=120
> kworker/-5       0dN.h2.. 1344661966us : sched_wakeup: comm=cyclictest pid=6314 prio=19 target_cpu=000
> kworker/-5       0d...2.. 1344661966us : sched_switch: prev_comm=kworker/0:0 prev_pid=5 prev_prio=120 prev_state=R+ ==> next_comm=cyclictest next_pid=6314 next_prio=19
> cyclicte-6314    0d...2.. 1344661967us+: sched_switch: prev_comm=cyclictest prev_pid=6314 prev_prio=19 prev_state=S ==> next_comm=kworker/0:0 next_pid=5 next_prio=120
> kworker/-5       0dN.h2.. 1344662052us : sched_wakeup: comm=cyclictest pid=6314 prio=19 target_cpu=000
> kworker/-5       0d...2.. 1344662053us : sched_switch: prev_comm=kworker/0:0 prev_pid=5 prev_prio=120 prev_state=R+ ==> next_comm=cyclictest next_pid=6314 next_prio=19
> cyclicte-6314    0d...2.. 1344662054us!: sched_switch: prev_comm=cyclictest prev_pid=6314 prev_prio=19 prev_state=S ==> next_comm=kworker/0:0 next_pid=5 next_prio=120
> kworker/-5       0dN.h2.. 1344662168us : sched_wakeup: comm=cyclictest pid=6314 prio=19 target_cpu=000
> kworker/-5       0d...2.. 1344662168us : sched_switch: prev_comm=kworker/0:0 prev_pid=5 prev_prio=120 prev_state=R+ ==> next_comm=cyclictest next_pid=6314 next_prio=19
> cyclicte-6314    0d...2.. 1344662169us+: sched_switch: prev_comm=cyclictest prev_pid=6314 prev_prio=19 prev_state=S ==> next_comm=kworker/0:0 next_pid=5 next_prio=120
> kworker/-5       0dN.h2.. 1344662255us : sched_wakeup: comm=irq/48-eth2-tx- pid=6310 prio=49 target_cpu=000
> kworker/-5       0dN.h3.. 1344662256us : sched_wakeup: comm=irq/47-eth2-rx- pid=6309 prio=49 target_cpu=000
> kworker/-5       0d...2.. 1344662256us : sched_switch: prev_comm=kworker/0:0 prev_pid=5 prev_prio=120 prev_state=R+ ==> next_comm=irq/48-eth2-tx- next_pid=6310 next_prio=49
> irq/48-e-6310    0d...2.. 1344662259us : sched_switch: prev_comm=irq/48-eth2-tx- prev_pid=6310 prev_prio=49 prev_state=S ==> next_comm=irq/47-eth2-rx- next_pid=6309 next_prio=49
> irq/47-e-6309    0d...2.. 1344662260us+: sched_switch: prev_comm=irq/47-eth2-rx- prev_pid=6309 prev_prio=49 prev_state=S ==> next_comm=kworker/0:0 next_pid=5 next_prio=120
> kworker/-5       0dN.h2.. 1344662300us : sched_wakeup: comm=cyclictest pid=6314 prio=19 target_cpu=000
> kworker/-5       0d...2.. 1344662300us : sched_switch: prev_comm=kworker/0:0 prev_pid=5 prev_prio=120 prev_state=R+ ==> next_comm=cyclictest next_pid=6314 next_prio=19
> cyclicte-6314    0.....11 1344662306us : tracing_mark_write: hit latency threshold (39 > 23)
>
> Just before the long latency,  the irqs "48-eth2-tx" and "48-eth2-rx" are active.
> When looking at the 4th line from the bottom, the time for irq/47 is 1344662260us, for the next line (kworker) it is 1344662300us.
> Does this mean that the irq/47 took 40us for irq processing? Or is this a misinterpretation?

That is a misinterpretation: at 1344662256us there is a sched_switch
event to pid 6310 (irq/48-eth2-tx-). It completes (prev_state=S) at
1344662259us when there is a sched_switch event to pid 6309
(irq/47-eth2-rx-). That one completes at 1344662260us when there is a
sched_switch event to pid 5. So the thread for irq/48 takes 3us and
irq/47 takes 1us.

If you'd blend in the irq events (irq_handler_entry, irq_handler_exit),
you'll see the timer-irq between 1344662260us and 1344662300us (likely
close to 1344662300us) waking up the cyclictest thread.

Regards,
     Henri
