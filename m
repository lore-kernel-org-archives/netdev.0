From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH net-next] softirq: reduce latencies
Date: Thu, 03 Jan 2013 14:41:15 -0800
Message-ID: <1357252875.21409.26390.camel@edumazet-glaptop>
References: <1357216132.21409.24107.camel@edumazet-glaptop>
	 <20130103124608.136fd65b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:36991 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021Ab3ACWlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 17:41:18 -0500
In-Reply-To: <20130103124608.136fd65b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-03 at 12:46 -0800, Andrew Morton wrote:
> On Thu, 03 Jan 2013 04:28:52 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > In various network workloads, __do_softirq() latencies can be up
> > to 20 ms if HZ=1000, and 200 ms if HZ=100.
> > 
> > This is because we iterate 10 times in the softirq dispatcher,
> > and some actions can consume a lot of cycles.
> 
> hm, where did that "20 ms" come from?  What caused it?  Is it simply
> the case that you happened to have actions which consume 2ms if HZ=1000
> and 20ms if HZ=100?

net_rx_action() has such behavior yes.

In the worst/busy case, we spend 2 ticks per call, and even more
in some cases you dont want to know about (like triggering a IPv6 route
garbage collect)

> 
> > This patch changes the fallback to ksoftirqd condition to :
> > 
> > - A time limit of 2 ms.
> > - need_resched() being set on current task
> >
> > When one of this condition is met, we wakeup ksoftirqd for further
> > softirq processing if we still have pending softirqs.
> 
> Do we need both tests?  The need_resched() test alone might be
> sufficient?
> 

I tried a need_resched() only, but could trigger watchdog faults and
reboots, in case a cpu was dedicated to softirq and all other tasks run
on other cpus.

In other cases, the following RCU splat was triggered :

(need_resched() doesnt know the current cpu is blocking RCU )

Jan  2 21:33:40 lpq83 kernel: [  311.678050] INFO: rcu_sched self-detected stall on CPU { 2}  (t=21000 jiffies g=11416 c=11415 q=2665)
Jan  2 21:33:40 lpq83 kernel: [  311.687314] Pid: 1460, comm: simple-watchdog Not tainted 3.8.0-smp-DEV #63
Jan  2 21:33:40 lpq83 kernel: [  311.687316] Call Trace:
Jan  2 21:33:40 lpq83 kernel: [  311.687317]  <IRQ>  [<ffffffff81100e92>] rcu_check_callbacks+0x212/0x7a0
Jan  2 21:33:40 lpq83 kernel: [  311.687326]  [<ffffffff81097018>] update_process_times+0x48/0x90
Jan  2 21:33:40 lpq83 kernel: [  311.687329]  [<ffffffff810cfe31>] tick_sched_timer+0x81/0xd0
Jan  2 21:33:40 lpq83 kernel: [  311.687332]  [<ffffffff810ad69d>] __run_hrtimer+0x7d/0x220
Jan  2 21:33:40 lpq83 kernel: [  311.687333]  [<ffffffff810cfdb0>] ? tick_nohz_handler+0x100/0x100
Jan  2 21:33:40 lpq83 kernel: [  311.687337]  [<ffffffff810ca02c>] ? ktime_get_update_offsets+0x4c/0xd0
Jan  2 21:33:40 lpq83 kernel: [  311.687339]  [<ffffffff810adfa7>] hrtimer_interrupt+0xf7/0x230
Jan  2 21:33:40 lpq83 kernel: [  311.687343]  [<ffffffff815b7089>] smp_apic_timer_interrupt+0x69/0x99
Jan  2 21:33:40 lpq83 kernel: [  311.687345]  [<ffffffff815b630a>] apic_timer_interrupt+0x6a/0x70
Jan  2 21:33:40 lpq83 kernel: [  311.687348]  [<ffffffffa01a1b66>] ? ipt_do_table+0x106/0x5b0 [ip_tables]
Jan  2 21:33:40 lpq83 kernel: [  311.687352]  [<ffffffff810fb357>] ? handle_edge_irq+0x77/0x130
Jan  2 21:33:40 lpq83 kernel: [  311.687354]  [<ffffffff8108e9c9>] ? irq_exit+0x79/0xb0
Jan  2 21:33:40 lpq83 kernel: [  311.687356]  [<ffffffff815b6fa3>] ? do_IRQ+0x63/0xe0
Jan  2 21:33:40 lpq83 kernel: [  311.687359]  [<ffffffffa004a0d3>] iptable_filter_hook+0x33/0x64 [iptable_filter]
Jan  2 21:33:40 lpq83 kernel: [  311.687362]  [<ffffffff81523dff>] nf_iterate+0x8f/0xd0
Jan  2 21:33:40 lpq83 kernel: [  311.687364]  [<ffffffff81529fc0>] ? ip_rcv_finish+0x360/0x360
Jan  2 21:33:40 lpq83 kernel: [  311.687366]  [<ffffffff81523ebd>] nf_hook_slow+0x7d/0x150
Jan  2 21:33:40 lpq83 kernel: [  311.687368]  [<ffffffff81529fc0>] ? ip_rcv_finish+0x360/0x360
Jan  2 21:33:40 lpq83 kernel: [  311.687370]  [<ffffffff8152a39e>] ip_local_deliver+0x5e/0xa0
Jan  2 21:33:40 lpq83 kernel: [  311.687372]  [<ffffffff81529d79>] ip_rcv_finish+0x119/0x360
Jan  2 21:33:40 lpq83 kernel: [  311.687374]  [<ffffffff8152a631>] ip_rcv+0x251/0x300
Jan  2 21:33:40 lpq83 kernel: [  311.687377]  [<ffffffff814f4c72>] __netif_receive_skb+0x582/0x820
Jan  2 21:33:40 lpq83 kernel: [  311.687379]  [<ffffffff81560697>] ? inet_gro_receive+0x197/0x200
Jan  2 21:33:40 lpq83 kernel: [  311.687381]  [<ffffffff814f50ad>] netif_receive_skb+0x2d/0x90
Jan  2 21:33:40 lpq83 kernel: [  311.687383]  [<ffffffff814f5943>] napi_gro_frags+0xf3/0x2a0
Jan  2 21:33:40 lpq83 kernel: [  311.687387]  [<ffffffffa01aa87c>] mlx4_en_process_rx_cq+0x6cc/0x7b0 [mlx4_en]
Jan  2 21:33:40 lpq83 kernel: [  311.687390]  [<ffffffffa01aa9ff>] mlx4_en_poll_rx_cq+0x3f/0x80 [mlx4_en]
Jan  2 21:33:40 lpq83 kernel: [  311.687392]  [<ffffffff814f53c1>] net_rx_action+0x111/0x210
Jan  2 21:33:40 lpq83 kernel: [  311.687393]  [<ffffffff814f3a51>] ? net_tx_action+0x81/0x1d0


> 
> With this change, there is a possibility that a rapidly-rescheduling
> task will cause softirq starvation?
> 

Only if this task has higher priority than ksoftirqd, but then, people
wanting/playing with high priority tasks know what they do ;)

> 
> Can this change cause worsened latencies in some situations?  Say there
> are a large number of short-running actions queued.  Presently we'll
> dispatch ten of them and return.  With this change we'll dispatch many
> more of them - however many consume 2ms.  So worst-case latency
> increases from "10 * not-much" to "2 ms".

I tried to reproduce such workload but couldnt. 2 ms (or more exactly 1
to 2 ms given the jiffies/HZ granularity) is about the time needed to
process 1000 frames on current hardware.

Certainly, this patch will increase number of scheduler calls in some
situations. But with the increase of cores, it seems a bit odd to allow
softirq to be a bad guy. The current logic was more suited for the !SMP
age.
