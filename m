From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Sat, 27 Feb 2016 12:13:57 -0800
Message-ID: <1456604037.648.29.camel@edumazet-ThinkPad-T530>
References: <56D1E8B6.6090003@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56D1E8B6.6090003@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On sam., 2016-02-27 at 10:19 -0800, Peter Hurley wrote:
> Hi Eric,
> 
> For a while now, we've been struggling to understand why we've been
> observing missed uart rx DMA.
> 
> Because both the uart driver (omap8250) and the dmaengine driver
> (edma) were (relatively) new, we assumed there was some race between
> starting a new rx DMA and processing the previous one.
> 
> However, after instrumenting both the uart driver and the dmaengine
> driver, what we've observed is huge anomalous latencies between receiving
> the DMA interrupt and servicing the DMA tasklet.
> 
> For example, at 3Mbaud we recorded the following distribution of
> softirq[TASKLET] service latency for this specific DMA channel:
> 
> root@black:/sys/kernel/debug/edma# cat 35
> latency(us):   0+   20+   40+   60+   80+  100+  120+  140+  160+  180+  200+  220+  240+  260+  280+  300+  320+  340+  360+  380+
>            195681    33    53    15     7     4     3     1     0     0     0     1     4     6     1     0     0     0     0     0
> 
> As you can see, the vast majority of tasklet service happens immediately,
> tapering off to 140+us.
> 
> However, note the island of distribution at 220~300 [latencies beyond 300+
> are not recorded because the uart fifo has filled again by this point and
> dma must be aborted].
> 
> So I cribbed together a latency tracer to catch what was happening at
> the extreme, and what it caught was a priority inversion stemming from
> your commit:
> 
>    commit c10d73671ad30f54692f7f69f0e09e75d3a8926a
>    Author: Eric Dumazet <edumazet@google.com>
>    Date:   Thu Jan 10 15:26:34 2013 -0800
> 
>        softirq: reduce latencies
>     
>        In various network workloads, __do_softirq() latencies can be up
>        to 20 ms if HZ=1000, and 200 ms if HZ=100.
>     
>        This is because we iterate 10 times in the softirq dispatcher,
>        and some actions can consume a lot of cycles.
> 
> 
> In the trace below [1], the trace begins in the edma completion interrupt
> handler when the tasklet is scheduled; the edma interrupt has occurred during
> NET_RX softirq context.
> 
> However, instead of causing a restart of the softirq loop to process the
> tasklet _which occurred before sshd was scheduled_, the softirq loop is
> aborted and deferred for ksoftirqd. The tasklet is not serviced for 521us,
> which is way too long, so DMA was aborted.
> 
> Your patch has effectively inverted the priority of tasklets with normal
> pri/nice processes that have merely received a network packet.
> 
> ISTM, the problem you're trying to solve here was caused by NET_RX softirq
> to begin with, and maybe that thing needs a diet.
> 
> But rather than outright reverting your patch, what if more selective
> conditions are used to abort the softirq restart? What would those conditions
> be? In the netperf benchmark you referred to in that commit, is it just
> NET_TX/NET_RX softirqs that are causing scheduling latencies?
> 
> It just doesn't make sense to special case for a workload that isn't
> even running.
> 
> 
> Regards,
> Peter Hurley
> 
> 
> [1] softirq tasklet latency trace  (apologies that it's only events - full
>     function trace introduces too much overhead)
> 
> # tracer: latency
> #
> # latency latency trace v1.1.5 on 4.5.0-rc2+
> # --------------------------------------------------------------------
> # latency: 476 us, #59/59, CPU#0 | (M:preempt VP:0, KP:0, SP:0 HP:0)
> #    -----------------
> #    | task: sshd-750 (uid:1000 nice:0 policy:0 rt_prio:0)
> #    -----------------
> #  => started at: __tasklet_schedule  
> #  => ended at:   tasklet_action
> #
> #
> #                  _------=> CPU#
> #                 / _-----=> irqs-off 
> #                | / _----=> need-resched
> #                || / _---=> hardirq/softirq
> #                ||| / _--=> preempt-depth
> #                |||| /     delay
> #  cmd     pid   ||||| time  |   caller
> #     \   /      |||||  \    |   /
>   <idle>-0       0d.H3    1us : __tasklet_schedule
>   <idle>-0       0d.H4    3us : softirq_raise: vec=6 [action=TASKLET]
>   <idle>-0       0d.H3    6us : irq_handler_exit: irq=20 ret=handled
>   <idle>-0       0..s2   15us : kmem_cache_alloc: call_site=c08378e4 ptr=de55d7c0 bytes_req=192 bytes_alloc=192 gfp_flags=GFP_ATOMIC
>   <idle>-0       0..s2   23us : netif_receive_skb_entry: dev=eth0 napi_id=0x0 queue_mapping=0 skbaddr=dca04400 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x000
> 0 protocol=0x0800 ip_summed=0 hash=0x00000000 l4_hash=0 len=88 data_len=0 truesize=1984 mac_header_valid=1 mac_header=-14 nr_frags=0 gso_size=0 gso_type=0x0
>   <idle>-0       0..s2   30us+: netif_receive_skb: dev=eth0 skbaddr=dca04400 len=88
>   <idle>-0       0d.s5   98us : sched_waking: comm=sshd pid=750 prio=120 target_cpu=000
>   <idle>-0       0d.s6  105us : sched_stat_sleep: comm=sshd pid=750 delay=3125230447 [ns]
>   <idle>-0       0dns6  110us+: sched_wakeup: comm=sshd pid=750 prio=120 target_cpu=000
>   <idle>-0       0dns4  123us+: timer_start: timer=dc940e9c function=tcp_delack_timer expires=9746 [timeout=10] flags=0x00000000
>   <idle>-0       0dnH3  150us : irq_handler_entry: irq=176 name=4a100000.ethernet
>   <idle>-0       0dnH3  153us : softirq_raise: vec=3 [action=NET_RX]
>   <idle>-0       0dnH3  155us : irq_handler_exit: irq=176 ret=handled
>   <idle>-0       0dnH3  160us : irq_handler_entry: irq=20 name=49000000.edma_ccint
>   <idle>-0       0dnH3  163us : irq_handler_exit: irq=20 ret=handled
>   <idle>-0       0.ns2  169us : napi_poll: napi poll on napi struct de465c30 for device eth0
>   <idle>-0       0.ns2  171us : softirq_exit: vec=3 [action=NET_RX]
>   <idle>-0       0dns3  175us : sched_waking: comm=ksoftirqd/0 pid=3 prio=120 target_cpu=000
>   <idle>-0       0dns4  178us : sched_stat_sleep: comm=ksoftirqd/0 pid=3 delay=19371625 [ns]
>   <idle>-0       0dns4  180us : sched_wakeup: comm=ksoftirqd/0 pid=3 prio=120 target_cpu=000
>   <idle>-0       0.n.3  186us : gpio_value: 55 set 1
>   <idle>-0       0dn.3  191us : hrtimer_cancel: hrtimer=c0e2af80
>   <idle>-0       0dn.3  196us : hrtimer_start: hrtimer=c0e2af80 function=tick_sched_timer expires=338948000000 softexpires=338948000000
>   <idle>-0       0dn.2  199us : rcu_utilization: Start context switch
>   <idle>-0       0dn.2  202us : rcu_utilization: End context switch
>   <idle>-0       0dn.3  206us : sched_stat_wait: comm=sshd pid=750 delay=74042 [ns]
>   <idle>-0       0d..3  209us+: sched_switch: prev_comm=swapper prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=sshd next_pid=750 next_prio=120
>     sshd-750     0...1  252us : sys_exit: NR 142 = 1
>     sshd-750     0...1  257us+: sys_select -> 0x1
>     sshd-750     0...1  273us : sys_enter: NR 175 (0, be9cc238, be9cc1b8, 8, be9cc1b8, 0)
>     sshd-750     0...1  276us : sys_rt_sigprocmask(how: 0, nset: be9cc238, oset: be9cc1b8, sigsetsize: 8)
>     sshd-750     0...1  285us : sys_exit: NR 175 = 0
>     sshd-750     0...1  287us : sys_rt_sigprocmask -> 0x0
>     sshd-750     0...1  289us : sys_enter: NR 175 (2, be9cc1b8, 0, 8, 0, 2)
>     sshd-750     0...1  290us : sys_rt_sigprocmask(how: 2, nset: be9cc1b8, oset: 0, sigsetsize: 8)
>     sshd-750     0...1  292us : sys_exit: NR 175 = 0
>     sshd-750     0...1  293us : sys_rt_sigprocmask -> 0x0
>     sshd-750     0...1  299us : sys_enter: NR 263 (1, be9cc270, 801b25e8, 0, 7f60e3b0, 7f60ee7c)
>     sshd-750     0...1  301us : sys_clock_gettime(which_clock: 1, tp: be9cc270)
>     sshd-750     0...1  307us : sys_exit: NR 263 = 0
>     sshd-750     0d.h2  313us+: irq_handler_entry: irq=160 name=481aa000.serial
>     sshd-750     0d.h3  327us : omap_8250_rx_dma_flush: 481aa000.serial: ret:22 iir:0xc4 seq:19389 last:19388 elapsed:446292
>     sshd-750     0d.h3  335us : __dma_rx_do_complete: 481aa000.serial: cmplt: iir=c4 count=48
>     sshd-750     0d.h4  341us : workqueue_queue_work: work struct=de41239c function=flush_to_ldisc workqueue=de1bef00 req_cpu=1 cpu=4294967295
>     sshd-750     0d.h4  343us : workqueue_activate_work: work struct de41239c
>     sshd-750     0d.h5  346us : sched_waking: comm=kworker/u2:2 pid=763 prio=120 target_cpu=000
>     sshd-750     0d.h6  350us : sched_stat_sleep: comm=kworker/u2:2 pid=763 delay=442250 [ns]
>     sshd-750     0d.h6  359us : sched_wakeup: comm=kworker/u2:2 pid=763 prio=120 target_cpu=000
>     sshd-750     0d.h3  366us : kfree: call_site=c05a88f0 ptr=de6ba940
>     sshd-750     0d.h3  367us+: kfree: call_site=c05a88f0 ptr=de6f5640
>     sshd-750     0d.h4  445us : kmalloc: call_site=c05aa6d0 ptr=de6f5640 bytes_req=132 bytes_alloc=192 gfp_flags=GFP_ATOMIC|GFP_ZERO
>     sshd-750     0d.h2  455us : irq_handler_exit: irq=160 ret=handled
>     sshd-750     0..s2  460us : softirq_entry: vec=3 [action=NET_RX]
>     sshd-750     0..s2  469us : napi_poll: napi poll on napi struct de465c30 for device eth0
>     sshd-750     0..s2  470us : softirq_exit: vec=3 [action=NET_RX]
>     sshd-750     0..s2  472us : softirq_entry: vec=6 [action=TASKLET]
>     sshd-750     0..s1  475us : tasklet_action
>     sshd-750     0d.s1  478us+: tasklet_action <-tasklet_action
>     sshd-750     0d.s1  521us : <stack trace>
>  => irq_exit
>  => __handle_domain_irq
>  => omap_intc_handle_irq
>  => __irq_svc
>  => ftrace_syscall_exit
>  => ftrace_syscall_exit
>  => syscall_trace_exit
>  => __sys_trace_return


Nothing in the linux kernel will make sure softirq are always processed
under the higher prio.

You are pointing out my patch but the real problem for you is having
ksoftirqd in the first place.

You need RT variant I guess, or a better hardware.
