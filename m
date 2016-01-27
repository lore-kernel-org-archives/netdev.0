From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Bypass at packet-page level (Was: Optimizing instruction-cache,
 more packets at each stage)
Date: Wed, 27 Jan 2016 21:47:50 +0100
Message-ID: <20160127214750.51fe2392@redhat.com>
References: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	<20160121122730.6330a84b@redhat.com>
	<20160121.105401.1793719917762270884.davem@davemloft.net>
	<20160124152814.2ea5e99b@redhat.com>
	<20160124163846-mutt-send-email-mst@redhat.com>
	<56A509C4.3030706@gmail.com>
	<20160125141516.795f3eb7@redhat.com>
	<CALx6S37EmUh7SXmVSjTN9DLMTicr6-VwL-i25VV1fM=V2E6giQ@mail.gmail.com>
	<56A66058.1090308@gmail.com>
	<20160125231016.4f0d2cd5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Vladislav Yasevich <vyasevich@gmail.com>, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934971AbcA0UsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 15:48:01 -0500
In-Reply-To: <20160125231016.4f0d2cd5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Jan 2016 23:10:16 +0100
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Mon, 25 Jan 2016 09:50:16 -0800 John Fastabend <john.fastabend@gmail.com> wrote:
> 
> > On 16-01-25 09:09 AM, Tom Herbert wrote:  
> > > On Mon, Jan 25, 2016 at 5:15 AM, Jesper Dangaard Brouer
> > > <brouer@redhat.com> wrote:    
> > >>  
> [...]
> > >>
> > >> There are two ideas, getting mixed up here.  (1) bundling from the
> > >> RX-ring, (2) allowing to pick up the "packet-page" directly.
> > >>
> > >> Bundling (1) is something that seems natural, and which help us
> > >> amortize the cost between layers (and utilizes icache better). Lets
> > >> keep that in another thread.
> > >>
> > >> This (2) direct forward of "packet-pages" is a fairly extreme idea,
> > >> BUT it have the potential of being an new integration point for
> > >> "selective" bypass-solutions and bringing RAW/af_packet (RX) up-to
> > >> speed with bypass-solutions.  
> >  
> [...]
> > 
> > Jesper, at least for you (2) case what are we missing with the
> > bifurcated/queue splitting work? Are you really after systems
> > without SR-IOV support or are you trying to get this on the order
> > of queues instead of VFs.  
> 
> I'm not saying something is missing for bifurcated/queue splitting work.
> I'm not trying to work-around SR-IOV.
> 
> This an extreme idea, which I got while looking at the lowest RX layer.
> 
> 
> Before working any further on this idea/path, I need/want to evaluate
> if it makes sense from a performance point of view.  I need to evaluate
> if "pulling" out these "packet-pages" is fast enough to compete with
> DPDK/netmap.  Else it makes no sense to work on this path.
> 
> As a first step to evaluate this lowest RX layer, I'm simply hacking
> the drivers (ixgbe and mlx5) to drop/discard packets within-the-driver.
> For now, simply replacing napi_gro_receive() with dev_kfree_skb(), and
> measuring the "RX-drop" performance.
> 
> Next step was to avoid the skb alloc+free calls, but doing so is more
> complicated that I first anticipated, as the SKB is tied in fairly
> heavily.  Thus, right now I'm instead hooking in my bulk alloc+free
> API, as that will remove/mitigate most of the overhead of the
> kmem_cache/slab-allocators.

I've tried to deduct that kind of speeds we can achieve, at this lowest
RX layer. By in the mlx5/100G driver drop packets directly in the driver.
Just replacing replacing napi_gro_receive() with dev_kfree_skb(), was
fairly depressing, showing only 6.2Mpps (6253970 pps => 159.9 ns) (single core).

Looking at the perf report showed major cache-miss in eth_type_trans(29%/47ns).

And driver is hitting the SLUB slowpath quite badly (because it
prealloc SKBs and binds to RX ring, usually this test case would hits
SLUB "recycle" fastpath):

Group-report: kmem_cache/SLUB allocator functions ::
  5.00 % ~=  8.0 ns <= __slab_free
  4.91 % ~=  7.9 ns <= cmpxchg_double_slab.isra.65
  4.22 % ~=  6.7 ns <= kmem_cache_alloc
  1.68 % ~=  2.7 ns <= kmem_cache_free
  1.10 % ~=  1.8 ns <= ___slab_alloc
  0.93 % ~=  1.5 ns <= __cmpxchg_double_slab.isra.54
  0.65 % ~=  1.0 ns <= __slab_alloc.isra.74
  0.26 % ~=  0.4 ns <= put_cpu_partial
 Sum: 18.75 % => calc: 30.0 ns (sum: 30.0 ns) => Total: 159.9 ns

To get around the cache-miss in eth_type_trans(), I created a
"icache-loop" in mlx5e_poll_rx_cq() and pull all RX-ring packets "out",
before calling eth_type_trans(), reducing cost to 2.45%.

To mitigate the SLUB slowpath, I used my slab + SKB-napi bulk API .  And
also tuned SLUB (with slub_nomerge slub_min_objects=128) to get bigger
slab-pages, thus bigger bulk opportunities.

This helped a lot, I can now drop 12Mpps (12,088,767 => 82.7 ns).

Group-report: kmem_cache/SLUB allocator functions ::
  4.99 % ~=  4.1 ns <= kmem_cache_alloc_bulk
  2.87 % ~=  2.4 ns <= kmem_cache_free_bulk
  0.24 % ~=  0.2 ns <= ___slab_alloc
  0.23 % ~=  0.2 ns <= __slab_free
  0.21 % ~=  0.2 ns <= __cmpxchg_double_slab.isra.54
  0.17 % ~=  0.1 ns <= cmpxchg_double_slab.isra.65
  0.07 % ~=  0.1 ns <= put_cpu_partial
  0.04 % ~=  0.0 ns <= unfreeze_partials.isra.71
  0.03 % ~=  0.0 ns <= get_partial_node.isra.72
 Sum:  8.85 % => calc: 7.3 ns (sum: 7.3 ns) => Total: 82.7 ns

Full perf report output below signature, is from optimized case.

SKB related cost is 22.9 ns.  However 51.7% (11.84ns) cost originates
from memset of the SKB.

Group-report: related to pattern "skb" ::
 17.92 % ~= 14.8 ns <= __napi_alloc_skb   <== 80% memset(0) / rep stos
  3.29 % ~=  2.7 ns <= skb_release_data
  2.20 % ~=  1.8 ns <= napi_consume_skb
  1.86 % ~=  1.5 ns <= skb_release_head_state
  1.20 % ~=  1.0 ns <= skb_put
  1.14 % ~=  0.9 ns <= skb_release_all
  0.02 % ~=  0.0 ns <= __kfree_skb_flush
 Sum: 27.63 % => calc: 22.9 ns (sum: 22.9 ns) => Total: 82.7 ns

Doing a crude extrapolation, 82.7 ns subtract, SLUB (7.3 ns) and SKB
(22.9 ns) related => 52.5 ns -> extrapolate 19 Mpps would be the
maximum speed we can pull off packet-pages from the RX ring.

I don't know if 19Mpps (52.5 ns "overhead") is fast enough, to compete
with just mapping a RX HW queue/ring to netmap or via SR-IOV to DPDK(?)

But it was interesting to see how the lowest RX layer performs...
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


Perf-report script:
 * https://github.com/netoptimizer/network-testing/blob/master/bin/perf_report_pps_stats.pl

Report: ALL functions ::
 19.71 % ~= 16.3 ns <= mlx5e_poll_rx_cq
 17.92 % ~= 14.8 ns <= __napi_alloc_skb
  9.54 % ~=  7.9 ns <= __free_page_frag
  7.16 % ~=  5.9 ns <= mlx5e_get_cqe
  6.37 % ~=  5.3 ns <= mlx5e_post_rx_wqes
  4.99 % ~=  4.1 ns <= kmem_cache_alloc_bulk
  3.70 % ~=  3.1 ns <= __alloc_page_frag
  3.29 % ~=  2.7 ns <= skb_release_data
  2.87 % ~=  2.4 ns <= kmem_cache_free_bulk
  2.45 % ~=  2.0 ns <= eth_type_trans
  2.43 % ~=  2.0 ns <= get_page_from_freelist
  2.36 % ~=  2.0 ns <= swiotlb_map_page
  2.20 % ~=  1.8 ns <= napi_consume_skb
  1.86 % ~=  1.5 ns <= skb_release_head_state
  1.25 % ~=  1.0 ns <= free_pages_prepare
  1.20 % ~=  1.0 ns <= skb_put
  1.14 % ~=  0.9 ns <= skb_release_all
  0.77 % ~=  0.6 ns <= __free_pages_ok
  0.59 % ~=  0.5 ns <= get_pfnblock_flags_mask
  0.59 % ~=  0.5 ns <= swiotlb_dma_mapping_error
  0.59 % ~=  0.5 ns <= unmap_single
  0.58 % ~=  0.5 ns <= _raw_spin_lock_irqsave
  0.57 % ~=  0.5 ns <= free_one_page
  0.56 % ~=  0.5 ns <= swiotlb_unmap_page
  0.52 % ~=  0.4 ns <= _raw_spin_lock
  0.46 % ~=  0.4 ns <= __mod_zone_page_state
  0.36 % ~=  0.3 ns <= __rmqueue
  0.36 % ~=  0.3 ns <= net_rx_action
  0.34 % ~=  0.3 ns <= __alloc_pages_nodemask
  0.31 % ~=  0.3 ns <= __zone_watermark_ok
  0.27 % ~=  0.2 ns <= mlx5e_napi_poll
  0.24 % ~=  0.2 ns <= ___slab_alloc
  0.23 % ~=  0.2 ns <= __slab_free
  0.22 % ~=  0.2 ns <= __list_del_entry
  0.21 % ~=  0.2 ns <= __cmpxchg_double_slab.isra.54
  0.21 % ~=  0.2 ns <= next_zones_zonelist
  0.20 % ~=  0.2 ns <= __list_add
  0.17 % ~=  0.1 ns <= __do_softirq
  0.17 % ~=  0.1 ns <= cmpxchg_double_slab.isra.65
  0.16 % ~=  0.1 ns <= __inc_zone_state
  0.12 % ~=  0.1 ns <= _raw_spin_unlock
  0.12 % ~=  0.1 ns <= zone_statistics
 (Percent limit(0.1%) stop at "mlx5e_poll_tx_cq")
 Sum: 99.45 % => calc: 82.3 ns (sum: 82.3 ns) => Total: 82.7 ns

Group-report: related to pattern "eth_type_trans|mlx5|ixgbe|__iowrite64_copy" ::
 (Driver related)
  19.71 % ~= 16.3 ns <= mlx5e_poll_rx_cq
  7.16 % ~=  5.9 ns <= mlx5e_get_cqe
  6.37 % ~=  5.3 ns <= mlx5e_post_rx_wqes
  2.45 % ~=  2.0 ns <= eth_type_trans
  0.27 % ~=  0.2 ns <= mlx5e_napi_poll
  0.09 % ~=  0.1 ns <= mlx5e_poll_tx_cq
 Sum: 36.05 % => calc: 29.8 ns (sum: 29.8 ns) => Total: 82.7 ns

Group-report: DMA functions ::
  2.36 % ~=  2.0 ns <= swiotlb_map_page
  0.59 % ~=  0.5 ns <= unmap_single
  0.59 % ~=  0.5 ns <= swiotlb_dma_mapping_error
  0.56 % ~=  0.5 ns <= swiotlb_unmap_page
 Sum:  4.10 % => calc: 3.4 ns (sum: 3.4 ns) => Total: 82.7 ns

Group-report: page_frag_cache functions ::
  9.54 % ~=  7.9 ns <= __free_page_frag
  3.70 % ~=  3.1 ns <= __alloc_page_frag
  2.43 % ~=  2.0 ns <= get_page_from_freelist
  1.25 % ~=  1.0 ns <= free_pages_prepare
  0.77 % ~=  0.6 ns <= __free_pages_ok
  0.59 % ~=  0.5 ns <= get_pfnblock_flags_mask
  0.57 % ~=  0.5 ns <= free_one_page
  0.46 % ~=  0.4 ns <= __mod_zone_page_state
  0.36 % ~=  0.3 ns <= __rmqueue
  0.34 % ~=  0.3 ns <= __alloc_pages_nodemask
  0.31 % ~=  0.3 ns <= __zone_watermark_ok
  0.21 % ~=  0.2 ns <= next_zones_zonelist
  0.16 % ~=  0.1 ns <= __inc_zone_state
  0.12 % ~=  0.1 ns <= zone_statistics
  0.02 % ~=  0.0 ns <= mod_zone_page_state
 Sum: 20.83 % => calc: 17.2 ns (sum: 17.2 ns) => Total: 82.7 ns

Group-report: kmem_cache/SLUB allocator functions ::
  4.99 % ~=  4.1 ns <= kmem_cache_alloc_bulk
  2.87 % ~=  2.4 ns <= kmem_cache_free_bulk
  0.24 % ~=  0.2 ns <= ___slab_alloc
  0.23 % ~=  0.2 ns <= __slab_free
  0.21 % ~=  0.2 ns <= __cmpxchg_double_slab.isra.54
  0.17 % ~=  0.1 ns <= cmpxchg_double_slab.isra.65
  0.07 % ~=  0.1 ns <= put_cpu_partial
  0.04 % ~=  0.0 ns <= unfreeze_partials.isra.71
  0.03 % ~=  0.0 ns <= get_partial_node.isra.72
 Sum:  8.85 % => calc: 7.3 ns (sum: 7.3 ns) => Total: 82.7 ns

 Group-report: related to pattern "skb" ::
 17.92 % ~= 14.8 ns <= __napi_alloc_skb   <== 80% memset(0) / rep stos
  3.29 % ~=  2.7 ns <= skb_release_data
  2.20 % ~=  1.8 ns <= napi_consume_skb
  1.86 % ~=  1.5 ns <= skb_release_head_state
  1.20 % ~=  1.0 ns <= skb_put
  1.14 % ~=  0.9 ns <= skb_release_all
  0.02 % ~=  0.0 ns <= __kfree_skb_flush
 Sum: 27.63 % => calc: 22.9 ns (sum: 22.9 ns) => Total: 82.7 ns

Group-report: Core network-stack functions ::
  0.36 % ~=  0.3 ns <= net_rx_action
  0.17 % ~=  0.1 ns <= __do_softirq
  0.02 % ~=  0.0 ns <= __raise_softirq_irqoff
  0.01 % ~=  0.0 ns <= run_ksoftirqd
  0.00 % ~=  0.0 ns <= run_timer_softirq
  0.00 % ~=  0.0 ns <= ksoftirqd_should_run
  0.00 % ~=  0.0 ns <= raise_softirq
 Sum:  0.56 % => calc: 0.5 ns (sum: 0.5 ns) => Total: 82.7 ns

Group-report: GRO network-stack functions ::
 Sum:  0.00 % => calc: 0.0 ns (sum: 0.0 ns) => Total: 82.7 ns

Group-report: related to pattern "spin_.*lock|mutex" ::
  0.58 % ~=  0.5 ns <= _raw_spin_lock_irqsave
  0.52 % ~=  0.4 ns <= _raw_spin_lock
  0.12 % ~=  0.1 ns <= _raw_spin_unlock
  0.01 % ~=  0.0 ns <= _raw_spin_unlock_irqrestore
  0.00 % ~=  0.0 ns <= __mutex_lock_slowpath
  0.00 % ~=  0.0 ns <= _raw_spin_lock_irq
 Sum:  1.23 % => calc: 1.0 ns (sum: 1.0 ns) => Total: 82.7 ns

 Negative Report: functions NOT included in group reports::
  0.22 % ~=  0.2 ns <= __list_del_entry
  0.20 % ~=  0.2 ns <= __list_add
  0.07 % ~=  0.1 ns <= list_del
  0.05 % ~=  0.0 ns <= native_sched_clock
  0.04 % ~=  0.0 ns <= irqtime_account_irq
  0.02 % ~=  0.0 ns <= rcu_bh_qs
  0.01 % ~=  0.0 ns <= task_tick_fair
  0.01 % ~=  0.0 ns <= net_rps_action_and_irq_enable.isra.112
  0.01 % ~=  0.0 ns <= perf_event_task_tick
  0.01 % ~=  0.0 ns <= apic_timer_interrupt
  0.01 % ~=  0.0 ns <= lapic_next_deadline
  0.01 % ~=  0.0 ns <= rcu_check_callbacks
  0.01 % ~=  0.0 ns <= smpboot_thread_fn
  0.01 % ~=  0.0 ns <= irqtime_account_process_tick.isra.3
  0.00 % ~=  0.0 ns <= intel_bts_enable_local
  0.00 % ~=  0.0 ns <= kthread_should_park
  0.00 % ~=  0.0 ns <= native_apic_mem_write
  0.00 % ~=  0.0 ns <= hrtimer_forward
  0.00 % ~=  0.0 ns <= get_work_pool
  0.00 % ~=  0.0 ns <= cpu_startup_entry
  0.00 % ~=  0.0 ns <= acct_account_cputime
  0.00 % ~=  0.0 ns <= set_next_entity
  0.00 % ~=  0.0 ns <= worker_thread
  0.00 % ~=  0.0 ns <= dbs_timer_handler
  0.00 % ~=  0.0 ns <= delay_tsc
  0.00 % ~=  0.0 ns <= idle_cpu
  0.00 % ~=  0.0 ns <= timerqueue_add
  0.00 % ~=  0.0 ns <= hrtimer_interrupt
  0.00 % ~=  0.0 ns <= dbs_work_handler
  0.00 % ~=  0.0 ns <= dequeue_entity
  0.00 % ~=  0.0 ns <= update_cfs_shares
  0.00 % ~=  0.0 ns <= update_fast_timekeeper
  0.00 % ~=  0.0 ns <= smp_trace_apic_timer_interrupt
  0.00 % ~=  0.0 ns <= __update_cpu_load
  0.00 % ~=  0.0 ns <= cpu_needs_another_gp
  0.00 % ~=  0.0 ns <= ret_from_intr
  0.00 % ~=  0.0 ns <= __intel_pmu_enable_all
  0.00 % ~=  0.0 ns <= trigger_load_balance
  0.00 % ~=  0.0 ns <= __schedule
  0.00 % ~=  0.0 ns <= nsecs_to_jiffies64
  0.00 % ~=  0.0 ns <= account_entity_dequeue
  0.00 % ~=  0.0 ns <= worker_enter_idle
  0.00 % ~=  0.0 ns <= __hrtimer_get_next_event
  0.00 % ~=  0.0 ns <= rcu_irq_exit
  0.00 % ~=  0.0 ns <= rb_erase
  0.00 % ~=  0.0 ns <= __intel_pmu_disable_all
  0.00 % ~=  0.0 ns <= tick_sched_do_timer
  0.00 % ~=  0.0 ns <= cpuacct_account_field
  0.00 % ~=  0.0 ns <= update_wall_time
  0.00 % ~=  0.0 ns <= notifier_call_chain
  0.00 % ~=  0.0 ns <= timekeeping_update
  0.00 % ~=  0.0 ns <= ktime_get_update_offsets_now
  0.00 % ~=  0.0 ns <= rb_next
  0.00 % ~=  0.0 ns <= rcu_all_qs
  0.00 % ~=  0.0 ns <= x86_pmu_disable
  0.00 % ~=  0.0 ns <= _cond_resched
  0.00 % ~=  0.0 ns <= __rcu_read_lock
  0.00 % ~=  0.0 ns <= __local_bh_enable
  0.00 % ~=  0.0 ns <= update_cpu_load_active
  0.00 % ~=  0.0 ns <= x86_pmu_enable
  0.00 % ~=  0.0 ns <= insert_work
  0.00 % ~=  0.0 ns <= ktime_get
  0.00 % ~=  0.0 ns <= __usecs_to_jiffies
  0.00 % ~=  0.0 ns <= __acct_update_integrals
  0.00 % ~=  0.0 ns <= scheduler_tick
  0.00 % ~=  0.0 ns <= update_vsyscall
  0.00 % ~=  0.0 ns <= memcpy_erms
  0.00 % ~=  0.0 ns <= get_cpu_idle_time_us
  0.00 % ~=  0.0 ns <= sched_clock_cpu
  0.00 % ~=  0.0 ns <= tick_do_update_jiffies64
  0.00 % ~=  0.0 ns <= hrtimer_active
  0.00 % ~=  0.0 ns <= profile_tick
  0.00 % ~=  0.0 ns <= __hrtimer_run_queues
  0.00 % ~=  0.0 ns <= kthread_should_stop
  0.00 % ~=  0.0 ns <= run_posix_cpu_timers
  0.00 % ~=  0.0 ns <= read_tsc
  0.00 % ~=  0.0 ns <= __remove_hrtimer
  0.00 % ~=  0.0 ns <= calc_global_load_tick
  0.00 % ~=  0.0 ns <= hrtimer_run_queues
  0.00 % ~=  0.0 ns <= irq_work_tick
  0.00 % ~=  0.0 ns <= cpuacct_charge
  0.00 % ~=  0.0 ns <= clockevents_program_event
  0.00 % ~=  0.0 ns <= update_blocked_averages
 Sum:  0.68 % => calc: 0.6 ns (sum: 0.6 ns) => Total: 82.7 ns
