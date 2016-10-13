From: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Subject: Re: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Thu, 13 Oct 2016 06:15:37 +0000
Message-ID: <e9661abf93194ad3849e3864a8361993@FE-MBX1012.de.bosch.com>
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
 <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        Greg <gvrose8192@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        "Sebastian Andrzej Siewior" <sebastian.siewior@linutronix.de>
To: Julia Cartwright <julia@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-v.fe.bosch.de ([139.15.237.11]:22206 "EHLO
        smtp6-v.fe.bosch.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754839AbcJMGR5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 02:17:57 -0400
In-Reply-To: <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julia,

thanks for the detailed analysis!
> 
> [...] 
> Okay, we finally received our wakeup event.  We were expecting to be woken up at
> 10024735653388ns, but were actually woken up at 10024735682387ns.
> 
>   10024735682387 - 10024735653388 = 28999ns
> 
> Our timer fired ~29us late!  But why...?
> 
> Sorry I don't have answers, just more questions.  I do wonder what
> kworker/0:3 was up to at the time the timer interrupt should have fired.
> 
>    Julia
I have now instrumented the igb driver to generate trace points that allows me to identify in 
more details what's going on.
This delivered interesting results!

Here are some places where I added traces:
In file igb_ptp.c:
void igb_ptp_rx_hang(struct igb_adapter *adapter)
{
        struct e1000_hw *hw = &adapter->hw;
        unsigned long rx_event;
        u32 tsyncrxctl;
        trace_igb(700);
        tsyncrxctl = rd32(E1000_TSYNCRXCTL);
        trace_igb(701);

        /* Other hardware uses per-packet timestamps */
        if (hw->mac.type != e1000_82576)
                return;
...

In file igb_main.c:
static void igb_check_lvmmc(struct igb_adapter *adapter)
{
        struct e1000_hw *hw = &adapter->hw;
        u32 lvmmc;

        trace_igb(600);
        lvmmc = rd32(E1000_LVMMC);
        trace_igb(601);
        if (lvmmc) {
...

When I run now my test, I get the following trace:
[...]
kworker/-607     0....... 107315621us+: igb: val: 700
kworker/-607     0d..h... 107315640us : irq_handler_entry: irq=47 name=eth2-rx-0
kworker/-607     0d..h... 107315640us : irq_handler_exit: irq=47 ret=handled
kworker/-607     0d..h1.. 107315640us : sched_waking: comm=irq/47-eth2-rx- pid=18009 prio=49 target_cpu=000
kworker/-607     0dN.h2.. 107315641us : sched_wakeup: comm=irq/47-eth2-rx- pid=18009 prio=49 target_cpu=000
kworker/-607     0dN.h1.. 107315643us : irq_handler_entry: irq=48 name=eth2-tx-0
kworker/-607     0dN.h1.. 107315643us : irq_handler_exit: irq=48 ret=handled
kworker/-607     0dN.h2.. 107315643us : sched_waking: comm=irq/48-eth2-tx- pid=18010 prio=49 target_cpu=000
kworker/-607     0dN.h3.. 107315644us : sched_wakeup: comm=irq/48-eth2-tx- pid=18010 prio=49 target_cpu=000
kworker/-607     0dN..1.. 107315644us : rcu_utilization: Start context switch
kworker/-607     0dN..1.. 107315644us : rcu_utilization: End context switch
kworker/-607     0dN..2.. 107315644us : sched_stat_runtime: comm=kworker/0:1 pid=607 runtime=88996 [ns] vruntime=49754678074 [ns]
kworker/-607     0d...2.. 107315645us : sched_switch: prev_comm=kworker/0:1 prev_pid=607 prev_prio=120 prev_state=R+ ==> next_comm=irq/47-eth2-rx- next_pid=18009 next_prio=49
irq/47-e-18009   0d....11 107315646us : softirq_raise: vec=3 [action=NET_RX]
irq/47-e-18009   0.....12 107315646us : softirq_entry: vec=3 [action=NET_RX]
irq/47-e-18009   0.....12 107315647us : napi_poll: napi poll on napi struct ffff88040ae58c50 for device eth2 work 0 budget 64
irq/47-e-18009   0.....12 107315647us : softirq_exit: vec=3 [action=NET_RX]
irq/47-e-18009   0d...1.. 107315648us : rcu_utilization: Start context switch
irq/47-e-18009   0d...1.. 107315648us : rcu_utilization: End context switch
irq/47-e-18009   0d...2.. 107315648us : sched_switch: prev_comm=irq/47-eth2-rx- prev_pid=18009 prev_prio=49 prev_state=S ==> next_comm=irq/48-eth2-tx- next_pid=18010 next_prio=49
irq/48-e-18010   0d....11 107315649us : softirq_raise: vec=3 [action=NET_RX]
irq/48-e-18010   0.....12 107315649us : softirq_entry: vec=3 [action=NET_RX]
irq/48-e-18010   0.....12 107315650us : napi_poll: napi poll on napi struct ffff88040ae5f450 for device eth2 work 0 budget 64
irq/48-e-18010   0.....12 107315650us : softirq_exit: vec=3 [action=NET_RX]
irq/48-e-18010   0d...1.. 107315651us : rcu_utilization: Start context switch
irq/48-e-18010   0d...1.. 107315651us : rcu_utilization: End context switch
irq/48-e-18010   0d...2.. 107315651us : sched_switch: prev_comm=irq/48-eth2-tx- prev_pid=18010 prev_prio=49 prev_state=S ==> next_comm=kworker/0:1 next_pid=607 next_prio=120
kworker/-607     0....... 107315652us : igb: val: 701
kworker/-607     0....... 107315652us : igb: val: 106
kworker/-607     0....... 107315652us : igb: val: 107
kworker/-607     0....... 107315652us+: igb: val: 600
kworker/-607     0d..h... 107315689us : local_timer_entry: vector=239
kworker/-607     0d..h1.. 107315689us : hrtimer_interrupt: cpu=0 offset=-34521 curr=kworker/0:1[120] thread=cyclictest[19]
kworker/-607     0d..h1.. 107315689us : hrtimer_cancel: hrtimer=ffff8803d42efe18
kworker/-607     0d..h... 107315689us : hrtimer_expire_entry: hrtimer=ffff8803d42efe18 function=hrtimer_wakeup now=752735681960
kworker/-607     0d..h1.. 107315689us : sched_waking: comm=cyclictest pid=18015 prio=19 target_cpu=000
kworker/-607     0dN.h2.. 107315690us : sched_wakeup: comm=cyclictest pid=18015 prio=19 target_cpu=000
kworker/-607     0dN.h... 107315690us : hrtimer_expire_exit: hrtimer=ffff8803d42efe18
kworker/-607     0dN.h1.. 107315690us : hrtimer_interrupt: cpu=0 offset=318040 curr=kworker/0:1[120] thread=<none>[-1]
kworker/-607     0dN.h... 107315690us : write_msr: 6e0, value 28096cdb9ce
kworker/-607     0dN.h... 107315690us : local_timer_exit: vector=239
kworker/-607     0dN..1.. 107315690us : rcu_utilization: Start context switch
kworker/-607     0dN..1.. 107315691us : rcu_utilization: End context switch
kworker/-607     0dN..2.. 107315691us : sched_stat_runtime: comm=kworker/0:1 pid=607 runtime=38439 [ns] vruntime=49754716513 [ns]
kworker/-607     0d...2.. 107315691us : sched_switch: prev_comm=kworker/0:1 prev_pid=607 prev_prio=120 prev_state=R+ ==> next_comm=cyclictest next_pid=18015 next_prio=19
kworker/-607     0d...2.. 107315691us : x86_fpu_regs_activated: x86/fpu: ffff8803f7f55940 fpregs_active: 1 fpstate_active: 1 counter: 99 xfeatures: 2 xcomp_bv: 0
kworker/-607     0d...2.. 107315691us : write_msr: c0000100, value 7ffff7400700
cyclicte-18015   0....... 107315692us : sys_exit: NR 230 = 0
cyclicte-18015   0....... 107315697us : sys_enter: NR 1 (5, 7ffff7400300, 1f, 7ffff77a5460, 2, 7ffff744c99a)
cyclicte-18015   0.....11 107315698us : tracing_mark_write: hit latency threshold (37 > 33)
cyclicte-18015   0....... 107315699us : sys_exit: NR 1 = 31
cyclicte-18015   0....... 107315699us : sys_enter: NR 1 (4, 4076b0, 2, 7ffff77a5460, 2, 7ffff744c99a)


Very interesting is also the trace that I get in an idle system - without cyclictest running.
When I just enable my igb tracepoint I got the following result:
[...]
kworker/-607     0....... 585779012us+: igb: val: 700
kworker/-607     0....... 585779042us : igb: val: 701
kworker/-607     0....... 585779042us : igb: val: 106
kworker/-607     0....... 585779043us : igb: val: 107
kworker/-607     0....... 585779043us+: igb: val: 600
kworker/-607     0....... 585779080us : igb: val: 601

The time between my trace points 700 and 701 is about 30us, 
the time between my trace points 600 and 601 is even 37us!!
The code in between is 
     tsyncrxctl = rd32(E1000_TSYNCRXCTL);
resp.
     lvmmc = rd32(E1000_LVMMC);   

In both cases this is a single read from a register.
I have no idea why this single read could take that much time!
Is it possible that the igb hardware is in a state that delays the read access
and this is why the whole I/O system might be delayed?

I hope this delivers more details on understanding this issue.

Thanks for any feedback!

Regards

Mathias
