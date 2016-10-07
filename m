From: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Subject: Re: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Fri, 7 Oct 2016 08:58:08 +0000
Message-ID: <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
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
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        "Sebastian Andrzej Siewior" <sebastian.siewior@linutronix.de>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        Julia Cartwright <julia@ni.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        Greg <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-v.fe.bosch.de ([139.15.237.11]:27343 "EHLO
        smtp6-v.fe.bosch.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752505AbcJGI6L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 04:58:11 -0400
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mitch,
> > >
> > > Although, to be clear, it isn't the fact that there exists 8
> > > threads, it's
> > that the device is
> > > firing all 8 interrupts at the same time.  The time spent in hardirq
> > context just waking
> > > up all 8 of those threads (and the cyclictest wakeup) is enough to
> > > cause
> > your
> > > regression.
> > >
> > > netdev/igb folks-
> > >
> > > Under what conditions should it be expected that the i350 trigger
> > > all of
> > the TxRx
> > > interrupts simultaneously?  Any ideas here?
> 
> I can answer that! I wrote that code.
> 
> We trigger the interrupts once a second because MSI and MSI-X interrupts are NOT
> guaranteed to be delivered. If this happens, the queues being serviced by this "lost"
> interrupt are completely stuck.
> 
> The device automatically masks each interrupt vector after it fires, expecting the
> ISR to re-enable the vector after processing is complete. If the interrupt is lost, the
> ISR doesn't run, so the vector ends up permanently masked. At this point, any
> queues associated with that vector are stuck. The only recovery is through the
> netdev watchdog, which initiates a reset.
> 
> During development of igb, we had several platforms with chipsets that routinely
> dropped MSI messages under stress. Things would be running fine and then, pow,
> all the traffic on a queue would stop.
> 
> So, I added code to fire each vector once per second. Just unmasking the interrupt
> isn't enough - we need to trigger the ISR to get the queues cleaned up so the device
> can work again.
> 
> Is this workaround still needed? I don't know. Modern chipsets don't break a sweat
> handling gigabit-speed traffic, and they *probably* don't drop interrupts. But I'd still
> rather have that insurance.
> 
> You could try to remove the write to the EICS registers in the watchdog task to see if
> that takes care of your problem. But I wouldn't want to remove that code
> permanently, because we have seen lost interrupts in the past.
> 
> You also could try staggering the writes so that not all vectors fire each second. But
> then you'll potentially incur a much longer delay if an interrupt does get lost, which
> means you could trigger netdev watchdog events.
> 
> -Mitch

Thanks for the explanation. Now I have switched over to kernel 4.8-rt1.
This shows the very same effect.
I modified the in-kernel's igb_main.c (function igb_watchdog_task) to comment out
the access to the EICS registers:

--- igb_main.c.orig     2016-10-07 10:43:37.855873754 +0200
+++ igb_main.c  2016-10-07 10:31:51.451346292 +0200
@@ -4613,6 +4613,7 @@ no_wait:
        }

        /* Cause software interrupt to ensure Rx ring is cleaned */
+#if 0
        if (adapter->flags & IGB_FLAG_HAS_MSIX) {
                u32 eics = 0;

@@ -4622,6 +4623,7 @@ no_wait:
        } else {
                wr32(E1000_ICS, E1000_ICS_RXDMT0);
        }
+#endif

        igb_spoof_check(adapter);
        igb_ptp_rx_hang(adapter);


The result is now slighty better, however the max latency that has been measured by
cyclictest is still much higher compared to the values of kernel 3.18.27-rt27.
I have now enabled all events, the execution of 
# cyclictest -a -i 105 -m -n -p 80 -t 1  -b 30 -C
delivers the following trace values


cyclicte-10062   0....... 10025813402us : sys_exit: NR 230 = 0
cyclicte-10062   0....... 10025813402us : sys_enter: NR 230 (1, 1, 7ffff73ff930, 0, 0, 2bd7e12e)
cyclicte-10062   0....... 10025813402us : hrtimer_init: hrtimer=ffff88040a017e18 clockid=CLOCK_MONOTONIC mode=HRTIMER_MODE_ABS
cyclicte-10062   0d...1.. 10025813403us : hrtimer_start: hrtimer=ffff88040a017e18 function=hrtimer_wakeup expires=10024735653388 softexpires=10024735653388
cyclicte-10062   0d...1.. 10025813403us : write_msr: 6e0, value 20ca630b9aef
cyclicte-10062   0d...1.. 10025813403us : rcu_utilization: Start context switch
cyclicte-10062   0d...1.. 10025813403us : rcu_utilization: End context switch
cyclicte-10062   0d...2.. 10025813404us : sched_switch: prev_comm=cyclictest prev_pid=10062 prev_prio=19 prev_state=S ==> next_comm=kworker/0:3 next_pid=1388 next_prio=120
cyclicte-10062   0d...2.. 10025813404us+: x86_fpu_regs_deactivated: x86/fpu: ffff88040c603ec0 fpregs_active: 0 fpstate_active: 1 counter: 69 xfeatures: 2 xcomp_bv: 0
kworker/-1388    0d..h... 10025813468us : irq_handler_entry: irq=48 name=eth2-tx-0
kworker/-1388    0d..h... 10025813468us : irq_handler_exit: irq=48 ret=handled
kworker/-1388    0d..h1.. 10025813469us : sched_waking: comm=irq/48-eth2-tx- pid=10057 prio=49 target_cpu=000
kworker/-1388    0dN.h2.. 10025813469us : sched_wakeup: comm=irq/48-eth2-tx- pid=10057 prio=49 target_cpu=000
kworker/-1388    0dN.h1.. 10025813470us : irq_handler_entry: irq=47 name=eth2-rx-0
kworker/-1388    0dN.h1.. 10025813470us : irq_handler_exit: irq=47 ret=handled
kworker/-1388    0dN.h2.. 10025813471us : sched_waking: comm=irq/47-eth2-rx- pid=10056 prio=49 target_cpu=000
kworker/-1388    0dN.h3.. 10025813471us : sched_wakeup: comm=irq/47-eth2-rx- pid=10056 prio=49 target_cpu=000
kworker/-1388    0dN..1.. 10025813472us : rcu_utilization: Start context switch
kworker/-1388    0dN..1.. 10025813472us : rcu_utilization: End context switch
kworker/-1388    0dN..2.. 10025813472us : sched_stat_runtime: comm=kworker/0:3 pid=1388 runtime=67566 [ns] vruntime=101216288332 [ns]
kworker/-1388    0d...2.. 10025813472us : sched_switch: prev_comm=kworker/0:3 prev_pid=1388 prev_prio=120 prev_state=R+ ==> next_comm=irq/48-eth2-tx- next_pid=10057 next_prio=49
irq/48-e-10057   0d....11 10025813473us : softirq_raise: vec=3 [action=NET_RX]
irq/48-e-10057   0.....12 10025813474us : softirq_entry: vec=3 [action=NET_RX]
irq/48-e-10057   0.....12 10025813475us : napi_poll: napi poll on napi struct ffff88040a582850 for device eth2 work 0 budget 64
irq/48-e-10057   0.....12 10025813475us : softirq_exit: vec=3 [action=NET_RX]
irq/48-e-10057   0d...1.. 10025813475us : rcu_utilization: Start context switch
irq/48-e-10057   0d...1.. 10025813476us : rcu_utilization: End context switch
irq/48-e-10057   0d...2.. 10025813476us : sched_switch: prev_comm=irq/48-eth2-tx- prev_pid=10057 prev_prio=49 prev_state=S ==> next_comm=irq/47-eth2-rx- next_pid=10056 next_prio=49
irq/47-e-10056   0d....11 10025813477us : softirq_raise: vec=3 [action=NET_RX]
irq/47-e-10056   0.....12 10025813477us : softirq_entry: vec=3 [action=NET_RX]
irq/47-e-10056   0.....12 10025813478us : napi_poll: napi poll on napi struct ffff88040a580850 for device eth2 work 0 budget 64
irq/47-e-10056   0.....12 10025813478us : softirq_exit: vec=3 [action=NET_RX]
irq/47-e-10056   0d...1.. 10025813479us : rcu_utilization: Start context switch
irq/47-e-10056   0d...1.. 10025813479us : rcu_utilization: End context switch
irq/47-e-10056   0d...2.. 10025813479us+: sched_switch: prev_comm=irq/47-eth2-rx- prev_pid=10056 prev_prio=49 prev_state=S ==> next_comm=kworker/0:3 next_pid=1388 next_prio=120
kworker/-1388    0d..h... 10025813516us : local_timer_entry: vector=239
kworker/-1388    0d..h1.. 10025813516us : hrtimer_interrupt: cpu=0 offset=-28999 curr=kworker/0:3[120] thread=cyclictest[19]
kworker/-1388    0d..h1.. 10025813517us : hrtimer_cancel: hrtimer=ffff88040a017e18
kworker/-1388    0d..h... 10025813517us : hrtimer_expire_entry: hrtimer=ffff88040a017e18 function=hrtimer_wakeup now=10024735682387
kworker/-1388    0d..h1.. 10025813517us : sched_waking: comm=cyclictest pid=10062 prio=19 target_cpu=000
kworker/-1388    0dN.h2.. 10025813517us : sched_wakeup: comm=cyclictest pid=10062 prio=19 target_cpu=000
kworker/-1388    0dN.h... 10025813517us : hrtimer_expire_exit: hrtimer=ffff88040a017e18
kworker/-1388    0dN.h1.. 10025813518us : hrtimer_interrupt: cpu=0 offset=317613 curr=kworker/0:3[120] thread=<none>[-1]
kworker/-1388    0dN.h... 10025813518us : write_msr: 6e0, value 20ca631e99f8
kworker/-1388    0dN.h... 10025813518us : local_timer_exit: vector=239
kworker/-1388    0dN..1.. 10025813518us : rcu_utilization: Start context switch
kworker/-1388    0dN..1.. 10025813518us : rcu_utilization: End context switch
kworker/-1388    0dN..2.. 10025813518us : sched_stat_runtime: comm=kworker/0:3 pid=1388 runtime=38173 [ns] vruntime=101216326505 [ns]
kworker/-1388    0d...2.. 10025813519us : sched_switch: prev_comm=kworker/0:3 prev_pid=1388 prev_prio=120 prev_state=R+ ==> next_comm=cyclictest next_pid=10062 next_prio=19
kworker/-1388    0d...2.. 10025813519us : x86_fpu_regs_activated: x86/fpu: ffff88040c603ec0 fpregs_active: 1 fpstate_active: 1 counter: 70 xfeatures: 2 xcomp_bv: 0
kworker/-1388    0d...2.. 10025813519us : write_msr: c0000100, value 7ffff7400700
cyclicte-10062   0....... 10025813519us : sys_exit: NR 230 = 0
cyclicte-10062   0....... 10025813524us : sys_enter: NR 1 (5, 7ffff7400300, 1f, 7ffff77a5460, 2, 7ffff744c99a)
cyclicte-10062   0.....11 10025813526us : tracing_mark_write: hit latency threshold (32 > 30)
cyclicte-10062   0....... 10025813526us : sys_exit: NR 1 = 31
cyclicte-10062   0....... 10025813527us : sys_enter: NR 1 (4, 4076b0, 2, 7ffff77a5460, 2, 7ffff744c99a)

Also, I notice that there is still roughly one irq every 2 seconds on irq/47 (eth2-rx-0) and irq/48 (eth2-tx-0).

Any idea or feedback on this?

Thanks

Mathias
