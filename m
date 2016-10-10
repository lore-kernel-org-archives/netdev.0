From: Julia Cartwright <julia@ni.com>
Subject: Re: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Mon, 10 Oct 2016 14:39:58 -0500
Message-ID: <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
References: <20160923144140.5tkzeymamrb5qnsv@linutronix.de>
 <a5ea146cf078457ab001131ca0886b0b@FE-MBX1012.de.bosch.com>
 <20160928194519.GA32423@jcartwri.amer.corp.natinst.com>
 <487032ca81f84e70bdacc39a024eff5e@FE-MBX1012.de.bosch.com>
 <20161004193445.GF10625@jcartwri.amer.corp.natinst.com>
 <584755c2766e4b94a604ece16760fe14@FE-MBX1012.de.bosch.com>
 <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
 <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
 <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        Greg <gvrose8192@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:49505 "EHLO ni.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751375AbcJJTkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 15:40:16 -0400
In-Reply-To: <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Mathias-

On Fri, Oct 07, 2016 at 08:58:08AM +0000, Koehrer Mathias (ETAS/ESW5) wrote:
[..]
> I modified the in-kernel's igb_main.c (function igb_watchdog_task) to comment out
> the access to the EICS registers:
> 
> --- igb_main.c.orig     2016-10-07 10:43:37.855873754 +0200
> +++ igb_main.c  2016-10-07 10:31:51.451346292 +0200
> @@ -4613,6 +4613,7 @@ no_wait:
>         }
> 
>         /* Cause software interrupt to ensure Rx ring is cleaned */
> +#if 0
>         if (adapter->flags & IGB_FLAG_HAS_MSIX) {
>                 u32 eics = 0;
> 
> @@ -4622,6 +4623,7 @@ no_wait:
>         } else {
>                 wr32(E1000_ICS, E1000_ICS_RXDMT0);
>         }
> +#endif
> 
>         igb_spoof_check(adapter);
>         igb_ptp_rx_hang(adapter);
> 
> 
> The result is now slighty better, however the max latency that has been measured by
> cyclictest is still much higher compared to the values of kernel 3.18.27-rt27.
> I have now enabled all events, the execution of 
> # cyclictest -a -i 105 -m -n -p 80 -t 1  -b 30 -C
> delivers the following trace values

There is something still fishy with these traces...

> cyclicte-10062   0....... 10025813402us : sys_exit: NR 230 = 0
> cyclicte-10062   0....... 10025813402us : sys_enter: NR 230 (1, 1, 7ffff73ff930, 0, 0, 2bd7e12e)
> cyclicte-10062   0....... 10025813402us : hrtimer_init: hrtimer=ffff88040a017e18 clockid=CLOCK_MONOTONIC mode=HRTIMER_MODE_ABS
> cyclicte-10062   0d...1.. 10025813403us : hrtimer_start: hrtimer=ffff88040a017e18 function=hrtimer_wakeup expires=10024735653388 softexpires=10024735653388

cyclictest thread sleeps waiting for wakeup at 10024735653388.

> cyclicte-10062   0d...1.. 10025813403us : write_msr: 6e0, value 20ca630b9aef
> cyclicte-10062   0d...1.. 10025813403us : rcu_utilization: Start context switch
> cyclicte-10062   0d...1.. 10025813403us : rcu_utilization: End context switch
> cyclicte-10062   0d...2.. 10025813404us : sched_switch: prev_comm=cyclictest prev_pid=10062 prev_prio=19 prev_state=S ==> next_comm=kworker/0:3 next_pid=1388 next_prio=120
> cyclicte-10062   0d...2.. 10025813404us+: x86_fpu_regs_deactivated: x86/fpu: ffff88040c603ec0 fpregs_active: 0 fpstate_active: 1 counter: 69 xfeatures: 2 xcomp_bv: 0
> kworker/-1388    0d..h... 10025813468us : irq_handler_entry: irq=48 name=eth2-tx-0
> kworker/-1388    0d..h... 10025813468us : irq_handler_exit: irq=48 ret=handled
> kworker/-1388    0d..h1.. 10025813469us : sched_waking: comm=irq/48-eth2-tx- pid=10057 prio=49 target_cpu=000
> kworker/-1388    0dN.h2.. 10025813469us : sched_wakeup: comm=irq/48-eth2-tx- pid=10057 prio=49 target_cpu=000
> kworker/-1388    0dN.h1.. 10025813470us : irq_handler_entry: irq=47 name=eth2-rx-0
> kworker/-1388    0dN.h1.. 10025813470us : irq_handler_exit: irq=47 ret=handled
> kworker/-1388    0dN.h2.. 10025813471us : sched_waking: comm=irq/47-eth2-rx- pid=10056 prio=49 target_cpu=000
> kworker/-1388    0dN.h3.. 10025813471us : sched_wakeup: comm=irq/47-eth2-rx- pid=10056 prio=49 target_cpu=000

So, kworker/0:3 was busy doing something, and we received both tx and rx
interrupts from eth2, waking up the relevant threads.

> kworker/-1388    0dN..1.. 10025813472us : rcu_utilization: Start context switch
> kworker/-1388    0dN..1.. 10025813472us : rcu_utilization: End context switch
> kworker/-1388    0dN..2.. 10025813472us : sched_stat_runtime: comm=kworker/0:3 pid=1388 runtime=67566 [ns] vruntime=101216288332 [ns]
> kworker/-1388    0d...2.. 10025813472us : sched_switch: prev_comm=kworker/0:3 prev_pid=1388 prev_prio=120 prev_state=R+ ==> next_comm=irq/48-eth2-tx- next_pid=10057 next_prio=49
> irq/48-e-10057   0d....11 10025813473us : softirq_raise: vec=3 [action=NET_RX]
> irq/48-e-10057   0.....12 10025813474us : softirq_entry: vec=3 [action=NET_RX]
> irq/48-e-10057   0.....12 10025813475us : napi_poll: napi poll on napi struct ffff88040a582850 for device eth2 work 0 budget 64

Hmm, the irq/48-eth2-tx- thread is raising NET_RX?  That seems...wrong.

> irq/48-e-10057   0.....12 10025813475us : softirq_exit: vec=3 [action=NET_RX]
> irq/48-e-10057   0d...1.. 10025813475us : rcu_utilization: Start context switch
> irq/48-e-10057   0d...1.. 10025813476us : rcu_utilization: End context switch
> irq/48-e-10057   0d...2.. 10025813476us : sched_switch: prev_comm=irq/48-eth2-tx- prev_pid=10057 prev_prio=49 prev_state=S ==> next_comm=irq/47-eth2-rx- next_pid=10056 next_prio=49
> irq/47-e-10056   0d....11 10025813477us : softirq_raise: vec=3 [action=NET_RX]
> irq/47-e-10056   0.....12 10025813477us : softirq_entry: vec=3 [action=NET_RX]
> irq/47-e-10056   0.....12 10025813478us : napi_poll: napi poll on napi struct ffff88040a580850 for device eth2 work 0 budget 64
> irq/47-e-10056   0.....12 10025813478us : softirq_exit: vec=3 [action=NET_RX]

Oh, then we do the same thing again?  Hrmph...why?

> irq/47-e-10056   0d...1.. 10025813479us : rcu_utilization: Start context switch
> irq/47-e-10056   0d...1.. 10025813479us : rcu_utilization: End context switch
> irq/47-e-10056   0d...2.. 10025813479us+: sched_switch: prev_comm=irq/47-eth2-rx- prev_pid=10056 prev_prio=49 prev_state=S ==> next_comm=kworker/0:3 next_pid=1388 next_prio=120

Done handling the two interrupts.  Back to whatever kworker/0:3 was up
to...

> kworker/-1388    0d..h... 10025813516us : local_timer_entry: vector=239
> kworker/-1388    0d..h1.. 10025813516us : hrtimer_interrupt: cpu=0 offset=-28999 curr=kworker/0:3[120] thread=cyclictest[19]
> kworker/-1388    0d..h1.. 10025813517us : hrtimer_cancel: hrtimer=ffff88040a017e18
> kworker/-1388    0d..h... 10025813517us : hrtimer_expire_entry: hrtimer=ffff88040a017e18 function=hrtimer_wakeup now=10024735682387

Okay, we finally received our wakeup event.  We were expecting to be
woken up at 10024735653388ns, but were actually woken up at 10024735682387ns.

  10024735682387 - 10024735653388 = 28999ns

Our timer fired ~29us late!  But why...?

Sorry I don't have answers, just more questions.  I do wonder what
kworker/0:3 was up to at the time the timer interrupt should have fired.

   Julia
