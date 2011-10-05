From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Tue, 04 Oct 2011 23:35:11 -0400
Message-ID: <6.2.5.6.2.20111004214105.03a9d9f0@binnacle.cx>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=====================_-1956235454==_"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Joe Perches <joe@perches.com>, Christoph Lameter <cl@gentwo.org>,
	Serge Belyshev <belyshev@depni.sinp.msu.ru>,
	Con Kolivas <kernel@kolivas.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=====================_-1956235454==_
Content-Type: text/plain; charset="us-ascii"

At 12:38 PM 10/4/2011 -0700, Joe Perches wrote:
>On Tue, 2011-10-04 at 14:16 -0500, Christoph Lameter wrote:
>> On Mon, 3 Oct 2011, starlight@binnacle.cx wrote:
>> > I've come to the conclusion that Eric is right
>> > and the primary issue is an increase in the
>> > cost of scheduler context switches.  Have
>> > been watching this number and it has held
>> > pretty close to 200k/sec under all scenarios
>> > and kernel versions, so it has to be
>> > a longer code-path, bigger cache pressure
>> > or both in the scheduler.  Sadly this makes
>> > newer kernels a no-go for us.
>>
>> We had similar experiences. Basically latency
>> constantly gets screwed up by the new fancy
>> features being added to the scheduler and network
>> subsystem (most notorious is the new "fair"
>> scheduler, 2.6.23 made a big step down).
>
>Idly curious, have you compared bfs performance?
>http://ck.kolivas.org/patches/bfs/bfs-faq.txt

Gave it a try.  The application runs with a
large thread pool and the O(N) aspect of
BFS does not like that.  CPU was 30-50%
higher.  Wouldn't fly in production.

HOWEVER, when the application is run in its
small thread-pool mode total CPU consumption
with the BFS patched 2.6.39.4 kernel was just
5% greater than with the 2.6.18(rhel5) kernel.

This result is certainly interesting and
suggests that the more complex scheduler in
the newer kernels is to blame for the loss
of performance.

The picture is not perfectly clear as the reported
balance of user and system CPU is dramatically 
different.  In the 2.6.18(rhel5) kernel the
percent of CPU attributed to system overhead
is 23% and the IRQ rate was 33k with a context
switch rate of about 200k.  With the
2.6.39.4(bfs) kernel system overhead was
reported as just 3% of the application total,
with user time exceeding the 2.6.18(rhel5)
total of both user and system.  IRQs ran
at a much higher 160k and context switches
at a significantly lower 110k.  The above user/sys
numbers were calculated from the /proc/<pid>/stat
values for the application.  The number
of active threads was 13 and the number
of cores was 12.

Another observation  is that the CPU numbers
reported by 'top' and 'vmstat' diverge
more than usual.  'top' steadily reported
600ish percent (of the 1200% possible) while
'vmstat' was showing numbers all over the map
including near zero utilization.  Apparently
an extreme case of clock-tick histogram
measurement aliasing effects.

I'm attaching the 'perf' report for this run.
Should provide some interesting comparisons
with the 'perf' from the unmodified 2.6.39.4
kernel test run earlier in this thread, though
note that that test was run with the large
thread pool with about 140 active threads.
The config is attached as well.

-----

Anyway this is academic for us and the
production kernel will be 2.6.18(rhel5) for
some time.

When core counts start getting up into the
hundreds or thousands the newer-kernel doubling
of system overhead probably won't matter if
that's what it takes to make it run well.
Will be interesting to see if the Tile-GX
100-core CPU shows up soon and works even
remotely as well as they say it will.
--=====================_-1956235454==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="perf_report_bfs_pool0.txt"

# Events: 10M cycles
#
# Overhead       Command                  Shared Object                                                                                                                                                                              Symbol
# ........  ............  .............................  ..................................................................................................................................................................................
#
    16.71%           app  app                            [.] 
     7.32%       swapper  [kernel.kallsyms]              [k] native_safe_halt
     5.68%           app  app                            [.] 
     2.47%           app  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     2.27%           app  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     2.09%       swapper  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     1.90%           app  app                            [.] 
     1.82%           app  libc-2.12.so                   [.] __strncmp_sse2
     1.59%           app  app                            [.] 
     1.49%           app  libc-2.12.so                   [.] _int_free
     1.35%           app  app                            [.] 
     1.23%           app  app                            [.] 
     1.15%           app  [kernel.kallsyms]              [k] copy_user_generic_string
     1.01%           app  app                            [.] 
     1.00%           app  app                            [.] 
     0.87%           app  [kernel.kallsyms]              [k] _raw_spin_lock
     0.84%           app  libpthread-2.12.so             [.] __pthread_mutex_lock_internal
     0.81%           app  app                            [.] 
     0.80%           app  libc-2.12.so                   [.] _int_malloc
     0.79%           app  app                            [.] 
     0.71%           app  app                            [.] 
     0.68%           app  [kernel.kallsyms]              [k] schedule
     0.65%           app  app                            [.] 
     0.64%           app  app                            [.] 
     0.61%           app  [kernel.kallsyms]              [k] system_call
     0.61%           app  app                            [.] 
     0.58%           app  [kernel.kallsyms]              [k] __skb_recv_datagram
     0.56%       swapper  [kernel.kallsyms]              [k] schedule
     0.52%           app  app                            [.] 
     0.51%           app  app                            [.] 
     0.50%       swapper  [kernel.kallsyms]              [k] ktime_get
     0.49%           app  [kernel.kallsyms]              [k] kfree
     0.48%           app  [kernel.kallsyms]              [k] __phys_addr
     0.48%           app  app                            [.] 
     0.48%           app  libc-2.12.so                   [.] __GI_memset
     0.48%           app  [kernel.kallsyms]              [k] memcpy
     0.44%           app  app                            [.] 
     0.44%           app  app                            [.] 
     0.43%           app  app                            [.] 
     0.43%           app  [kernel.kallsyms]              [k] skb_release_data
     0.42%           app  [kernel.kallsyms]              [k] futex_wake
     0.42%           app  app                            [.] 
     0.42%           app  [kernel.kallsyms]              [k] __copy_skb_header
     0.41%           app  libpthread-2.12.so             [.] __pthread_mutex_unlock
     0.40%           app  [e1000e]                       [k] e1000_clean_rx_irq
     0.39%           app  [kernel.kallsyms]              [k] resched_task
     0.39%           app  [kernel.kallsyms]              [k] kmem_cache_free
     0.36%           app  [kernel.kallsyms]              [k] find_next_bit
     0.35%           app  [kernel.kallsyms]              [k] __bitmap_and
     0.35%           app  [kernel.kallsyms]              [k] sysret_check
     0.34%           app  app                            [.] 
     0.33%           app  app                            [.] 
     0.32%           app  app                            [.] 
     0.31%           app  app                            [.] 
     0.31%           app  app                            [.] 
     0.31%           app  app                            [.] 
     0.31%           app  libc-2.12.so                   [.] __GI_strnlen
     0.31%           app  [kernel.kallsyms]              [k] net_rx_action
     0.30%           app  app                            [.] 
     0.30%           app  app                            [.] 
     0.29%           app  app                            [.] 
     0.29%           app  app                            [.] 
     0.29%           app  [kernel.kallsyms]              [k] sock_def_readable
     0.29%           app  [kernel.kallsyms]              [k] __list_add
     0.28%           app  [kernel.kallsyms]              [k] activate_task
     0.28%           app  app                            [.] 
     0.28%           app  [kernel.kallsyms]              [k] ktime_get
     0.27%           app  app                            [.] 
     0.26%           app  libc-2.12.so                   [.] __memchr
     0.26%       swapper  [kernel.kallsyms]              [k] memcpy
     0.25%       swapper  [kernel.kallsyms]              [k] __copy_skb_header
     0.25%           app  libc-2.12.so                   [.] __GI___libc_malloc
     0.25%       swapper  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.25%           app  [kernel.kallsyms]              [k] do_futex
     0.25%           app  app                            [.] 
     0.25%       swapper  [e1000e]                       [k] e1000_clean_rx_irq
     0.25%           app  app                            [.] 
     0.25%           app  app                            [.] 
     0.23%           app  app                            [.] 
     0.23%           app  app                            [.] 
     0.23%           app  app                            [.] 
     0.23%           app  [kernel.kallsyms]              [k] __switch_to
     0.22%           app  app                            [.] 
     0.22%           app  [kernel.kallsyms]              [k] memcpy_toiovec
     0.22%           app  app                            [.] 
     0.22%           app  [e1000e]                       [k] e1000_intr_msi
     0.21%           app  [kernel.kallsyms]              [k] __netif_receive_skb
     0.21%       swapper  [kernel.kallsyms]              [k] reschedule_interrupt
     0.20%           app  app                            [.] 
     0.19%           app  app                            [.] 
     0.19%           app  app                            [.] 
     0.19%           app  app                            [.] 
     0.19%       swapper  [kernel.kallsyms]              [k] sched_clock_local
     0.19%           app  app                            [.] 
     0.18%           app  [kernel.kallsyms]              [k] dma_issue_pending_all
     0.18%       swapper  [kernel.kallsyms]              [k] set_task_cpu
     0.18%           app  [kernel.kallsyms]              [k] enqueue_task
     0.18%           app  [kernel.kallsyms]              [k] resched_best_mask
     0.17%           app  app                            [.] 
     0.17%           app  libc-2.12.so                   [.] __cfree
     0.17%           app  app                            [.] 
     0.16%           app  app                            [.] 
     0.16%       swapper  [kernel.kallsyms]              [k] tick_nohz_stop_sched_tick
     0.16%           app  [kernel.kallsyms]              [k] hash_futex
     0.16%           app  [kernel.kallsyms]              [k] packet_recvmsg
     0.16%           app  [kernel.kallsyms]              [k] packet_rcv
     0.15%           app  [kernel.kallsyms]              [k] vfs_read
     0.15%           app  [kernel.kallsyms]              [k] skb_release_head_state
     0.14%           app  [kernel.kallsyms]              [k] futex_wait
     0.14%           app  [kernel.kallsyms]              [k] get_futex_key
     0.14%           app  app                            [.] 
     0.14%           app  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.14%           app  app                            [.] 
     0.14%           app  [kernel.kallsyms]              [k] sys_futex
     0.14%           app  [kernel.kallsyms]              [k] __bitmap_empty
     0.14%           app  [kernel.kallsyms]              [k] default_send_IPI_mask_sequence_phys
     0.14%           app  libpthread-2.12.so             [.] __read
     0.13%           app  [kernel.kallsyms]              [k] fget_light
     0.13%       swapper  [kernel.kallsyms]              [k] sock_def_readable
     0.13%           app  [kernel.kallsyms]              [k] futex_wait_setup
     0.13%           app  libc-2.12.so                   [.] memcpy
     0.13%           app  app                            [.] 
     0.13%           app  [kernel.kallsyms]              [k] fsnotify
     0.13%       swapper  [kernel.kallsyms]              [k] read_tsc
     0.12%           app  app                            [.] 
     0.12%           app  [kernel.kallsyms]              [k] smp_invalidate_interrupt
     0.12%           app  [kernel.kallsyms]              [k] getnstimeofday
     0.12%           app  [kernel.kallsyms]              [k] update_cpu_clock
     0.12%           app  app                            [.] 
     0.12%           app  libpthread-2.12.so             [.] _L_unlock_657
     0.12%       swapper  [kernel.kallsyms]              [k] __netif_receive_skb
     0.12%           app  [kernel.kallsyms]              [k] gart_map_page
     0.12%       swapper  [kernel.kallsyms]              [k] __switch_to
     0.12%           app  app                            [.] 
     0.12%           app  [kernel.kallsyms]              [k] futex_wait_queue_me
     0.12%           app  libc-2.12.so                   [.] __memcmp_sse2
     0.12%           app  libc-2.12.so                   [.] _L_unlock_5126
     0.12%       swapper  [kernel.kallsyms]              [k] _raw_spin_lock
     0.12%           app  [kernel.kallsyms]              [k] sched_clock_local
     0.11%           app  app                            [.] 
     0.11%           app  app                            [.] 
     0.11%       swapper  [kernel.kallsyms]              [k] __list_add
     0.11%           app  app                            [.] 
     0.11%           app  app                            [.] 
     0.11%           app  app                            [.] 
     0.11%       swapper  [kernel.kallsyms]              [k] update_cpu_clock
     0.11%       swapper  [kernel.kallsyms]              [k] __hrtimer_start_range_ns
     0.11%           app  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.10%       swapper  [kernel.kallsyms]              [k] ip_rcv
     0.10%           app  libpthread-2.12.so             [.] _L_lock_870
     0.10%           app  libc-2.12.so                   [.] _L_lock_5001
     0.10%           app  [kernel.kallsyms]              [k] skb_copy_datagram_iovec
     0.10%           app  app                            [.] 
     0.10%           app  [kernel.kallsyms]              [k] sched_clock_cpu
     0.10%       swapper  [kernel.kallsyms]              [k] net_rx_action
     0.10%           app  libc-2.12.so                   [.] __GI_ioctl
     0.10%           app  [kernel.kallsyms]              [k] __alloc_skb
     0.10%           app  app                            [.] 
     0.10%       swapper  [kernel.kallsyms]              [k] native_read_tsc
     0.09%           app  app                            [.] 
     0.09%           app  [kernel.kallsyms]              [k] kmem_cache_alloc_node_trace
     0.09%           app  app                            [.] 
     0.09%           app  app                            [.] 
     0.09%       swapper  [kernel.kallsyms]              [k] packet_rcv
     0.09%       swapper  [kernel.kallsyms]              [k] notifier_call_chain
     0.09%           app  app                            [.] 
     0.09%           app  [kernel.kallsyms]              [k] do_sync_read
     0.09%       swapper  [kernel.kallsyms]              [k] rcu_enter_nohz
     0.09%           app  [kernel.kallsyms]              [k] pc_user_time
     0.08%           app  [kernel.kallsyms]              [k] wake_futex
     0.08%           app  app                            [.] 
     0.08%       swapper  [e1000e]                       [k] e1000_clean
     0.08%           app  [kernel.kallsyms]              [k] ip_route_input_common
     0.08%           app  libc-2.12.so                   [.] __lll_lock_wait_private
     0.08%           app  [kernel.kallsyms]              [k] sock_aio_read
     0.08%           app  [kernel.kallsyms]              [k] ip_rcv
     0.08%       swapper  [e1000e]                       [k] e1000_intr_msi
     0.08%           app  app                            [.] 
     0.08%           app  [kernel.kallsyms]              [k] set_task_cpu
     0.08%           app  [kernel.kallsyms]              [k] skb_put
     0.08%           app  app                            [.] 
     0.08%           app  app                            [.] 
     0.08%           app  [kernel.kallsyms]              [k] __fsnotify_parent
     0.08%           app  [kernel.kallsyms]              [k] __kfree_skb
     0.07%       swapper  [kernel.kallsyms]              [k] getnstimeofday
     0.07%       swapper  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.07%           app  [kernel.kallsyms]              [k] flush_tlb_others_ipi
     0.07%           app  app                            [.] 
     0.07%           app  [kernel.kallsyms]              [k] clear_page_c
     0.07%           app  [kernel.kallsyms]              [k] ip_rcv_finish
     0.07%           app  [kernel.kallsyms]              [k] native_sched_clock
     0.07%           app  libpthread-2.12.so             [.] __lll_lock_wait
     0.07%           app  libpthread-2.12.so             [.] __pthread_disable_asynccancel
     0.07%           app  [kernel.kallsyms]              [k] kmem_cache_alloc_node
     0.07%           app  [kernel.kallsyms]              [k] dev_gro_receive
     0.07%           app  [kernel.kallsyms]              [k] try_preempt
     0.07%           app  [kernel.kallsyms]              [k] system_call_after_swapgs
     0.07%           app  [kernel.kallsyms]              [k] sys_read
     0.07%           app  [kernel.kallsyms]              [k] try_to_wake_up
     0.07%           app  libpthread-2.12.so             [.] __pthread_cond_wait
     0.07%           app  [kernel.kallsyms]              [k] eth_type_trans
     0.07%       swapper  [kernel.kallsyms]              [k] cpu_idle
     0.07%           app  app                            [.] 
     0.07%       swapper  [kernel.kallsyms]              [k] tick_do_update_jiffies64
     0.07%           app  [kernel.kallsyms]              [k] native_flush_tlb
     0.07%       swapper  [kernel.kallsyms]              [k] tick_check_idle
     0.06%           app  [kernel.kallsyms]              [k] rw_verify_area
     0.06%       swapper  [kernel.kallsyms]              [k] default_idle
     0.06%           app  [kernel.kallsyms]              [k] __unqueue_futex
     0.06%       swapper  [kernel.kallsyms]              [k] tick_nohz_restart_sched_tick
     0.06%           app  [e1000e]                       [k] e1000_alloc_rx_buffers
     0.06%           app  [kernel.kallsyms]              [k] sys_ioctl
     0.06%           app  [kernel.kallsyms]              [k] plist_del
     0.06%       swapper  [kernel.kallsyms]              [k] gart_map_page
     0.06%           app  app                            [.] 
     0.06%           app  app                            [.] 
     0.06%           app  [kernel.kallsyms]              [k] __next_cpu
     0.06%           app  [kernel.kallsyms]              [k] ret_from_sys_call
     0.06%       swapper  [kernel.kallsyms]              [k] ip_route_input_common
     0.06%           app  [kernel.kallsyms]              [k] __skb_clone
     0.06%           app  libc-2.12.so                   [.] _L_unlock_9183
     0.06%           app  [kernel.kallsyms]              [k] skb_free_datagram
     0.06%           app  app                            [.] 
     0.06%           app  [kernel.kallsyms]              [k] sock_ioctl
     0.05%           app  [kernel.kallsyms]              [k] drop_futex_key_refs
     0.05%           app  app                            [.] 
     0.05%       swapper  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.05%           app  [kernel.kallsyms]              [k] transfer_objects
     0.05%       swapper  [kernel.kallsyms]              [k] __bitmap_empty
     0.05%           app  app                            [.] 
     0.05%       swapper  [kernel.kallsyms]              [k] smp_invalidate_interrupt
     0.05%       swapper  [kernel.kallsyms]              [k] kmem_cache_alloc_node_trace
     0.05%           app  [kernel.kallsyms]              [k] native_read_tsc
     0.05%       swapper  [kernel.kallsyms]              [k] find_next_bit
     0.05%           app  app                            [.] 
     0.05%           app  app                            [.] 
     0.05%           app  app                            [.] 
     0.05%       swapper  [kernel.kallsyms]              [k] rcu_exit_nohz
     0.05%           app  [kernel.kallsyms]              [k] do_vfs_ioctl
     0.05%       swapper  [kernel.kallsyms]              [k] __alloc_skb
     0.05%           app  app                            [.] 
     0.05%           app  [kernel.kallsyms]              [k] sock_rfree
     0.05%           app  [kernel.kallsyms]              [k] irq_entries_start
     0.05%       swapper  [kernel.kallsyms]              [k] dma_issue_pending_all
     0.05%           app  app                            [.] 
     0.05%           app  app                            [.] 
     0.05%           app  [kernel.kallsyms]              [k] ttwu_activate
     0.05%           app  [e1000e]                       [k] e1000_clean
     0.05%           app  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.05%           app  libc-2.12.so                   [.] _L_lock_9164
     0.05%           app  [kernel.kallsyms]              [k] __math_state_restore
     0.05%           app  [kernel.kallsyms]              [k] security_file_permission
     0.05%           app  app                            [.] 
     0.04%       swapper  [kernel.kallsyms]              [k] ip_rcv_finish
     0.04%       swapper  [kernel.kallsyms]              [k] native_sched_clock
     0.04%           app  [kernel.kallsyms]              [k] gart_unmap_page
     0.04%           app  [e1000e]                       [k] e1000_receive_skb
     0.04%           app  app                            [.] 
     0.04%       swapper  [kernel.kallsyms]              [k] skb_put
     0.04%           app  app                            [.] 
     0.04%       swapper  [kernel.kallsyms]              [k] rb_erase
     0.04%       swapper  [kernel.kallsyms]              [k] rcu_irq_exit
     0.04%       swapper  [kernel.kallsyms]              [k] __remove_hrtimer
     0.04%           app  libpthread-2.12.so             [.] __pthread_cond_signal
     0.04%           app  app                            [.] 
     0.04%           app  app                            [.] 
     0.04%       swapper  [kernel.kallsyms]              [k] timerqueue_add
     0.04%           app  app                            [.] 
     0.04%       swapper  [kernel.kallsyms]              [k] kmem_cache_alloc_node
     0.04%       swapper  [kernel.kallsyms]              [k] native_write_msr_safe
     0.04%           app  [kernel.kallsyms]              [k] native_write_cr0
     0.04%           app  app                            [.] 
     0.04%       swapper  [kernel.kallsyms]              [k] sched_clock_cpu
     0.04%       swapper  [kernel.kallsyms]              [k] dev_gro_receive
     0.04%           app  [kernel.kallsyms]              [k] fput
     0.04%       swapper  [kernel.kallsyms]              [k] rb_insert_color
     0.04%       swapper  [kernel.kallsyms]              [k] __phys_addr
     0.04%       swapper  [kernel.kallsyms]              [k] eth_type_trans
     0.04%           app  app                            [.] 
     0.04%           app  libc-2.12.so                   [.] __lll_unlock_wake_private
     0.04%           app  [kernel.kallsyms]              [k] __bitmap_subset
     0.04%       swapper  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.04%       swapper  [e1000e]                       [k] e1000_alloc_rx_buffers
     0.04%       swapper  [kernel.kallsyms]              [k] kmem_cache_free
     0.03%       swapper  [kernel.kallsyms]              [k] dequeue_task
     0.03%           app  [kernel.kallsyms]              [k] dequeue_task
     0.03%       swapper  [kernel.kallsyms]              [k] get_next_timer_interrupt
     0.03%           app  [kernel.kallsyms]              [k] packet_ioctl
     0.03%           app  app                            [.] 
     0.03%           app  app                            [.] 
     0.03%           app  [kernel.kallsyms]              [k] __bitmap_intersects
     0.03%           app  libpthread-2.12.so             [.] __pthread_enable_asynccancel
     0.03%           app  [kernel.kallsyms]              [k] inet_gro_receive
     0.03%           app  [kernel.kallsyms]              [k] consume_skb
     0.03%           app  app                            [.] 
     0.03%           app  [kernel.kallsyms]              [k] skb_gro_reset_offset
     0.03%           app  app                            [.] 
     0.03%           app  libpthread-2.12.so             [.] __lll_unlock_wake
     0.03%       swapper  [kernel.kallsyms]              [k] hrtimer_try_to_cancel
     0.03%           app  app                            [.] 
     0.03%       swapper  [e1000e]                       [k] e1000_receive_skb
     0.03%           app  [kernel.kallsyms]              [k] read_tsc
     0.03%           app  [kernel.kallsyms]              [k] plist_add
     0.03%           app  [kernel.kallsyms]              [k] _cond_resched
     0.03%           app  [kernel.kallsyms]              [k] __kmalloc_node_track_caller
     0.03%       swapper  [kernel.kallsyms]              [k] apic_timer_interrupt
     0.03%           app  app                            [.] 
     0.03%           app  [kernel.kallsyms]              [k] schedule_timeout
     0.03%           app  [kernel.kallsyms]              [k] sock_get_timestamp
     0.03%       swapper  [kernel.kallsyms]              [k] update_ts_time_stats
     0.03%       swapper  [kernel.kallsyms]              [k] __skb_clone
     0.03%       swapper  [kernel.kallsyms]              [k] atomic_notifier_call_chain
     0.03%           app  [kernel.kallsyms]              [k] kfree_skb
     0.03%           app  app                            [.] 
     0.03%           app  app                            [.] 
     0.03%       swapper  [kernel.kallsyms]              [k] hrtimer_get_next_event
     0.03%       swapper  [kernel.kallsyms]              [k] irq_entries_start
     0.03%           app  app                            [.] 
     0.03%           app  [kernel.kallsyms]              [k] sole_cpu_idle
     0.03%           app  app                            [.] 
     0.03%       swapper  [kernel.kallsyms]              [k] sched_clock_tick
     0.03%           app  [kernel.kallsyms]              [k] resched_best_idle
     0.03%       swapper  [kernel.kallsyms]              [k] activate_task
     0.03%           app  [kernel.kallsyms]              [k] skb_recv_datagram
     0.03%           app  [kernel.kallsyms]              [k] native_write_msr_safe
     0.02%       swapper  [kernel.kallsyms]              [k] inet_gro_receive
     0.02%           app  [kernel.kallsyms]              [k] __rwsem_do_wake
     0.02%           app  [kernel.kallsyms]              [k] acct_update_integrals
     0.02%           app  [kernel.kallsyms]              [k] __list_del_entry
     0.02%           app  app                            [.] 
     0.02%           app  [kernel.kallsyms]              [k] rwsem_down_failed_common
     0.02%       swapper  [kernel.kallsyms]              [k] resched_task
     0.02%       swapper  [kernel.kallsyms]              [k] leave_mm
     0.02%           app  app                            [.] 
     0.02%       swapper  [kernel.kallsyms]              [k] skb_clone
     0.02%       swapper  [kernel.kallsyms]              [k] timerqueue_del
     0.02%           app  [kernel.kallsyms]              [k] system_call_fastpath
     0.02%           app  [kernel.kallsyms]              [k] __do_softirq
     0.02%       swapper  [kernel.kallsyms]              [k] hrtimer_force_reprogram
     0.02%           app  app                            [.] 
     0.02%           app  [kernel.kallsyms]              [k] netif_receive_skb
     0.02%           app  [kernel.kallsyms]              [k] ns_to_timespec
     0.02%           app  [kernel.kallsyms]              [k] get_futex_key_refs
     0.02%           app  [kernel.kallsyms]              [k] page_fault
     0.02%           app  [kernel.kallsyms]              [k] napi_gro_receive
     0.02%           app  app                            [.] 
     0.02%           app  [kernel.kallsyms]              [k] perf_event_task_sched_out
     0.02%           app  app                            [.] 
     0.02%           app  [kernel.kallsyms]              [k] apic_timer_interrupt
     0.02%           app  libpthread-2.12.so             [.] __pthread_mutex_cond_lock
     0.02%           app  app                            [.] 
     0.02%           app  [kernel.kallsyms]              [k] cache_cpu_idle
     0.02%           app  [kernel.kallsyms]              [k] sock_do_ioctl.clone.2
     0.02%           app  [e1000e]                       [k] e1000_rx_checksum
     0.02%           app  [kernel.kallsyms]              [k] save_args
     0.02%           app  [kernel.kallsyms]              [k] get_page_from_freelist
     0.02%       swapper  [kernel.kallsyms]              [k] __kmalloc_node_track_caller
     0.02%           app  [kernel.kallsyms]              [k] find_vma_prev
     0.02%           app  [kernel.kallsyms]              [k] find_vma
     0.02%           app  [kernel.kallsyms]              [k] scheduler_tick
     0.02%           app  [kernel.kallsyms]              [k] eth_header_parse
     0.02%           app  [kernel.kallsyms]              [k] retint_swapgs
     0.02%       swapper  [kernel.kallsyms]              [k] hrtimer_interrupt
     0.02%           app  app                            [.] 
     0.02%           app  app                            [.] 
     0.02%       swapper  [kernel.kallsyms]              [k] resched_best_mask
     0.02%           app  app                            [.] 
     0.02%           app  [kernel.kallsyms]              [k] wake_up_state
     0.02%           app  app                            [.] 
     0.02%           app  [kernel.kallsyms]              [k] _copy_to_user
     0.02%       swapper  [kernel.kallsyms]              [k] save_args
     0.02%       swapper  [kernel.kallsyms]              [k] kfree_skb
     0.02%       swapper  [kernel.kallsyms]              [k] lock_hrtimer_base
     0.02%       swapper  [kernel.kallsyms]              [k] gart_unmap_page
     0.02%           app  [kernel.kallsyms]              [k] mprotect_fixup
     0.02%           app  [kernel.kallsyms]              [k] free_block
     0.02%       swapper  [kernel.kallsyms]              [k] sched_clock
     0.02%           app  [kernel.kallsyms]              [k] ns_to_timeval
     0.02%           app  app                            [.] 
     0.02%       swapper  [kernel.kallsyms]              [k] timekeeping_max_deferment
     0.02%           app  app                            [.] 
     0.02%       swapper  [kernel.kallsyms]              [k] select_nohz_load_balancer
     0.02%       swapper  [kernel.kallsyms]              [k] perf_event_task_sched_out
     0.02%           app  [kernel.kallsyms]              [k] skb_clone
     0.02%       swapper  [kernel.kallsyms]              [k] ret_from_intr
     0.02%           app  [kernel.kallsyms]              [k] get_rps_cpu
     0.02%           app  [kernel.kallsyms]              [k] tick_do_update_jiffies64
     0.02%           app  [kernel.kallsyms]              [k] perf_event_mmap
     0.02%       swapper  [kernel.kallsyms]              [k] skb_gro_reset_offset
     0.02%       swapper  [kernel.kallsyms]              [k] __bitmap_and
     0.02%       swapper  [kernel.kallsyms]              [k] try_to_wake_up
     0.02%           app  [kernel.kallsyms]              [k] cap_socket_recvmsg
     0.02%           app  [kernel.kallsyms]              [k] hrtimer_interrupt
     0.02%       swapper  [kernel.kallsyms]              [k] native_apic_mem_write
     0.02%       swapper  [kernel.kallsyms]              [k] account_idle_ticks
     0.02%           app  [kernel.kallsyms]              [k] ret_from_intr
     0.02%       swapper  [kernel.kallsyms]              [k] enqueue_hrtimer
     0.02%       swapper  [e1000e]                       [k] e1000_rx_checksum
     0.02%           app  [kernel.kallsyms]              [k] vma_adjust
     0.02%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] netif_receive_skb
     0.01%       swapper  [kernel.kallsyms]              [k] rb_next
     0.01%           app  [kernel.kallsyms]              [k] perf_event_task_tick
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] memmove
     0.01%           app  [kernel.kallsyms]              [k] __netdev_alloc_skb
     0.01%       swapper  [kernel.kallsyms]              [k] hrtimer_cancel
     0.01%           app  [kernel.kallsyms]              [k] native_read_cr0
     0.01%           app  [kernel.kallsyms]              [k] finish_wait
     0.01%           app  [kernel.kallsyms]              [k] run_timer_softirq
     0.01%       swapper  [kernel.kallsyms]              [k] rcu_irq_enter
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] printk_needs_cpu
     0.01%           app  [kernel.kallsyms]              [k] native_load_sp0
     0.01%           app  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.01%           app  [kernel.kallsyms]              [k] __rcu_pending
     0.01%       swapper  [kernel.kallsyms]              [k] get_rps_cpu
     0.01%           app  [kernel.kallsyms]              [k] cap_file_ioctl
     0.01%       swapper  [kernel.kallsyms]              [k] hrtimer_forward
     0.01%           app  [kernel.kallsyms]              [k] handle_pte_fault
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] transfer_objects
     0.01%           app  [kernel.kallsyms]              [k] rcu_note_context_switch
     0.01%       swapper  [kernel.kallsyms]              [k] do_timer
     0.01%           app  [kernel.kallsyms]              [k] radix_tree_lookup
     0.01%       swapper  [kernel.kallsyms]              [k] rcu_needs_cpu
     0.01%       swapper  [kernel.kallsyms]              [k] napi_gro_receive
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] tick_sched_timer
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] irq_enter
     0.01%           app  app                            [.] 
     0.01%           app  app                            [.] 
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] cap_file_permission
     0.01%       swapper  [kernel.kallsyms]              [k] _local_bh_enable
     0.01%           app  [kernel.kallsyms]              [k] do_softirq
     0.01%       swapper  [kernel.kallsyms]              [k] skb_release_head_state
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] tick_nohz_stop_idle
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] native_smp_send_reschedule
     0.01%       swapper  [kernel.kallsyms]              [k] skb_release_data
     0.01%           app  [kernel.kallsyms]              [k] security_socket_recvmsg
     0.01%       swapper  [kernel.kallsyms]              [k] __list_del_entry
     0.01%           app  [kernel.kallsyms]              [k] hrtimer_forward
     0.01%           app  [e1000e]                       [k] e1000_clean_tx_irq
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] alternate_node_alloc
     0.01%       swapper  [kernel.kallsyms]              [k] smp_reschedule_interrupt
     0.01%           app  [kernel.kallsyms]              [k] __wake_up_common
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] napi_skb_finish
     0.01%       swapper  [kernel.kallsyms]              [k] native_load_sp0
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] sched_clock_idle_wakeup_event
     0.01%           app  [kernel.kallsyms]              [k] vma_merge
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] native_apic_mem_write
     0.01%       swapper  [kernel.kallsyms]              [k] __do_softirq
     0.01%           app  [kernel.kallsyms]              [k] cache_alloc_refill
     0.01%           app  [kernel.kallsyms]              [k] skb_push
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] irq_exit
     0.01%           app  [kernel.kallsyms]              [k] do_page_fault
     0.01%           app  [e1000e]                       [k] e1000_update_itr
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] follow_page
     0.01%           app  [kernel.kallsyms]              [k] irq_exit
     0.01%           app  [kernel.kallsyms]              [k] irq_enter
     0.01%       swapper  [kernel.kallsyms]              [k] __next_cpu
     0.01%           app  [kernel.kallsyms]              [k] handle_irq_event_percpu
     0.01%       swapper  [kernel.kallsyms]              [k] enqueue_task
     0.01%           app  [kernel.kallsyms]              [k] prepare_to_wait_exclusive
     0.01%           app  app                            [.] 
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] __mod_zone_page_state
     0.01%       swapper  [kernel.kallsyms]              [k] __wake_up_common
     0.01%       swapper  [e1000e]                       [k] e1000_clean_tx_irq
     0.01%       swapper  [kernel.kallsyms]              [k] clockevents_program_event
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] security_file_ioctl
     0.01%           app  [kernel.kallsyms]              [k] do_timer
     0.01%           app  [kernel.kallsyms]              [k] x86_pmu_disable
     0.01%           app  app                            [.] 
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] __kfree_skb
     0.01%       swapper  [kernel.kallsyms]              [k] smp_apic_timer_interrupt
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] __netdev_alloc_skb
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] handle_edge_irq
     0.01%           app  [kernel.kallsyms]              [k] invalidate_interrupt0
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] __local_bh_enable
     0.01%       swapper  [kernel.kallsyms]              [k] retint_restore_args
     0.01%           app  [kernel.kallsyms]              [k] update_process_times
     0.01%       swapper  [kernel.kallsyms]              [k] cache_alloc_refill
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] __napi_schedule
     0.01%           app  [kernel.kallsyms]              [k] napi_complete
     0.01%       swapper  [kernel.kallsyms]              [k] native_load_tls
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] skb_trim
     0.01%           app  libpthread-2.12.so             [.] __pthread_mutex_unlock_usercnt
     0.01%       swapper  [kernel.kallsyms]              [k] radix_tree_lookup
     0.01%       swapper  [kernel.kallsyms]              [k] exit_idle
     0.01%           app  [kernel.kallsyms]              [k] ktime_get_real
     0.01%           app  [kernel.kallsyms]              [k] __drain_alien_cache
     0.01%           app  [kernel.kallsyms]              [k] invalidate_interrupt16
     0.01%           app  [kernel.kallsyms]              [k] ip_check_mc_rcu
     0.01%           app  [kernel.kallsyms]              [k] unmap_vmas
     0.01%           app  [kernel.kallsyms]              [k] jiffies_to_timeval
     0.01%           app  app                            [.] 
     0.01%       swapper  [e1000e]                       [k] e1000_update_itr
     0.01%           app  [kernel.kallsyms]              [k] retint_check
     0.01%       swapper  [kernel.kallsyms]              [k] eth_header_parse
     0.01%       swapper  [kernel.kallsyms]              [k] nr_iowait_cpu
     0.01%       swapper  [kernel.kallsyms]              [k] ttwu_activate
     0.01%           app  [kernel.kallsyms]              [k] munlock_vma_page
     0.01%           app  [kernel.kallsyms]              [k] sys_mprotect
     0.01%           app  [kernel.kallsyms]              [k] handle_irq
     0.01%           app  [kernel.kallsyms]              [k] do_IRQ
     0.01%           app  [kernel.kallsyms]              [k] sched_clock
     0.01%           app  [kernel.kallsyms]              [k] invalidate_interrupt2
     0.01%           app  [kernel.kallsyms]              [k] __inc_zone_state
     0.01%           app  [kernel.kallsyms]              [k] gart_mapping_error
     0.01%           app  [kernel.kallsyms]              [k] raise_softirq
     0.01%       swapper  [kernel.kallsyms]              [k] napi_skb_finish
     0.01%           app  [kernel.kallsyms]              [k] physflat_send_IPI_mask
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] mmap_region
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] __bitmap_weight
     0.01%           app  [kernel.kallsyms]              [k] exit_idle
     0.01%       swapper  [kernel.kallsyms]              [k] skb_push
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] perf_event_mmap_ctx
     0.01%           app  [kernel.kallsyms]              [k] list_del
     0.01%       swapper  [kernel.kallsyms]              [k] enter_idle
     0.01%           app  [kernel.kallsyms]              [k] idle_cpu
     0.01%       swapper  [kernel.kallsyms]              [k] tick_dev_program_event
     0.01%       swapper  [kernel.kallsyms]              [k] local_bh_disable
     0.01%       swapper  [kernel.kallsyms]              [k] __irqentry_text_start
     0.01%           app  [kernel.kallsyms]              [k] invalidate_interrupt18
     0.01%           app  [kernel.kallsyms]              [k] invalidate_interrupt3
     0.01%           app  libc-2.12.so                   [.] __GI___mprotect
     0.01%       swapper  [kernel.kallsyms]              [k] ip_check_mc_rcu
     0.01%       swapper  [kernel.kallsyms]              [k] idle_cpu
     0.01%           app  [kernel.kallsyms]              [k] invalidate_interrupt19
     0.01%           app  [kernel.kallsyms]              [k] x86_pmu_disable_all
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] ack_apic_edge
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] call_rwsem_wake
     0.01%       swapper  [kernel.kallsyms]              [k] skb_trim
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] schedule
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] invalidate_interrupt5
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] device_not_available
     0.01%       swapper  [kernel.kallsyms]              [k] restore_args
     0.01%       swapper  [kernel.kallsyms]              [k] __napi_schedule
     0.01%           app  [kernel.kallsyms]              [k] __run_hrtimer
     0.01%           app  [kernel.kallsyms]              [k] hrtimer_run_queues
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] next_zones_zonelist
     0.01%       swapper  [kernel.kallsyms]              [k] ktime_get_real
     0.01%           app  [kernel.kallsyms]              [k] smp_apic_timer_interrupt
     0.01%       swapper  [kernel.kallsyms]              [k] rcu_note_context_switch
     0.01%           app  [kernel.kallsyms]              [k] profile_tick
     0.01%       swapper  [kernel.kallsyms]              [k] do_softirq
     0.01%       swapper  [kernel.kallsyms]              [k] native_set_ldt
     0.01%           app  [kernel.kallsyms]              [k] rwsem_down_write_failed
     0.01%           app  [kernel.kallsyms]              [k] __local_bh_enable
     0.01%           app  [kernel.kallsyms]              [k] invalidate_interrupt17
     0.01%           app  [kernel.kallsyms]              [k] try_to_unmap_anon
     0.01%           app  app                            [.] 
     0.01%       swapper  [kernel.kallsyms]              [k] handle_edge_irq
     0.01%           app  [kernel.kallsyms]              [k] rcu_check_callbacks
     0.01%       swapper  [kernel.kallsyms]              [k] hrtimer_start_range_ns
     0.01%           app  [kernel.kallsyms]              [k] call_softirq
     0.01%       swapper  [kernel.kallsyms]              [k] try_preempt
     0.01%           app  app                            [.] 
     0.01%           app  [kernel.kallsyms]              [k] printk_tick
     0.01%           app  [kernel.kallsyms]              [k] invalidate_interrupt1
     0.01%       swapper  [kernel.kallsyms]              [k] sched_clock_idle_sleep_event
     0.01%           app  [kernel.kallsyms]              [k] handle_irq_event
     0.01%           app  [kernel.kallsyms]              [k] rcu_irq_enter
     0.01%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] invalidate_interrupt21
     0.00%           app  [kernel.kallsyms]              [k] isolate_lru_page
     0.00%           app  [kernel.kallsyms]              [k] rwsem_wake
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] default_send_IPI_mask_sequence_phys
     0.00%           app  [kernel.kallsyms]              [k] down_write
     0.00%           app  [kernel.kallsyms]              [k] ack_apic_edge
     0.00%       swapper  [kernel.kallsyms]              [k] lapic_next_event
     0.00%           app  [kernel.kallsyms]              [k] call_rwsem_down_write_failed
     0.00%           app  [kernel.kallsyms]              [k] native_load_tls
     0.00%       swapper  [kernel.kallsyms]              [k] __napi_complete
     0.00%           app  [kernel.kallsyms]              [k] native_read_msr_safe
     0.00%       swapper  [kernel.kallsyms]              [k] handle_irq_event_percpu
     0.00%       swapper  [kernel.kallsyms]              [k] sole_cpu_idle
     0.00%           app  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%           app  [kernel.kallsyms]              [k] rcu_irq_exit
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] handle_irq
     0.00%           app  [kernel.kallsyms]              [k] __vm_enough_memory
     0.00%           app  [kernel.kallsyms]              [k] run_local_timers
     0.00%           app  [kernel.kallsyms]              [k] irq_work_run
     0.00%           app  [kernel.kallsyms]              [k] rwsem_down_read_failed
     0.00%           app  [kernel.kallsyms]              [k] zone_statistics
     0.00%           app  [kernel.kallsyms]              [k] alloc_pages_vma
     0.00%           app  [kernel.kallsyms]              [k] invalidate_interrupt4
     0.00%           app  libc-2.12.so                   [.] memcpy
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] gart_mapping_error
     0.00%       swapper  [kernel.kallsyms]              [k] __wake_up_sync_key
     0.00%           app  [kernel.kallsyms]              [k] handle_mm_fault
     0.00%       swapper  [kernel.kallsyms]              [k] tick_check_oneshot_broadcast
     0.00%           app  [kernel.kallsyms]              [k] irq_complete_move
     0.00%           app  [kernel.kallsyms]              [k] rcu_bh_qs
     0.00%       swapper  [kernel.kallsyms]              [k] __bitmap_subset
     0.00%       swapper  [kernel.kallsyms]              [k] __bitmap_intersects
     0.00%           app  [kernel.kallsyms]              [k] get_mm_counter
     0.00%           app  [kernel.kallsyms]              [k] release_pages
     0.00%       swapper  [kernel.kallsyms]              [k] tick_program_event
     0.00%       swapper  [kernel.kallsyms]              [k] napi_complete
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] invalidate_interrupt20
     0.00%           app  [kernel.kallsyms]              [k] hrtimer_run_pending
     0.00%           app  [kernel.kallsyms]              [k] interleave_nid
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] hrtimer_start
     0.00%           app  [kernel.kallsyms]              [k] retint_restore_args
     0.00%           app  [kernel.kallsyms]              [k] do_munmap
     0.00%           app  [kernel.kallsyms]              [k] free_hot_cold_page
     0.00%           app  [kernel.kallsyms]              [k] run_posix_cpu_timers
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] flush_tlb_mm
     0.00%           app  [kernel.kallsyms]              [k] error_exit
     0.00%       swapper  [kernel.kallsyms]              [k] rcu_bh_qs
     0.00%           app  [kernel.kallsyms]              [k] dec_zone_page_state
     0.00%           app  [kernel.kallsyms]              [k] do_msgrcv
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] up_read
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] cache_cpu_idle
     0.00%           app  [kernel.kallsyms]              [k] note_interrupt
     0.00%           app  [kernel.kallsyms]              [k] inc_zone_page_state
     0.00%           app  [kernel.kallsyms]              [k] clockevents_program_event
     0.00%           app  [kernel.kallsyms]              [k] perf_pmu_disable
     0.00%       swapper  [kernel.kallsyms]              [k] note_interrupt
     0.00%           app  [kernel.kallsyms]              [k] do_device_not_available
     0.00%           app  [kernel.kallsyms]              [k] tick_dev_program_event
     0.00%           app  [kernel.kallsyms]              [k] __page_check_address
     0.00%           app  app                            [.] 
     0.00%           app  libc-2.12.so                   [.] getpagesize
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt0
     0.00%           app  [kernel.kallsyms]              [k] free_pcppages_bulk
     0.00%           app  [kernel.kallsyms]              [k] up_write
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] x86_pmu_enable_all
     0.00%           app  [kernel.kallsyms]              [k] get_pageblock_flags_group
     0.00%           app  [kernel.kallsyms]              [k] timerqueue_add
     0.00%       swapper  [kernel.kallsyms]              [k] autoremove_wake_function
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt16
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] strlen
     0.00%           app  [kernel.kallsyms]              [k] error_entry
     0.00%           app  [kernel.kallsyms]              [k] cap_vm_enough_memory
     0.00%       swapper  [kernel.kallsyms]              [k] call_softirq
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] rb_erase
     0.00%       swapper  [kernel.kallsyms]              [k] irq_complete_move
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt17
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] irq_move_irq
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] page_add_new_anon_rmap
     0.00%           app  [kernel.kallsyms]              [k] alloc_page_interleave
     0.00%           app  [kernel.kallsyms]              [k] get_vma_policy
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] autoremove_wake_function
     0.00%           app  [kernel.kallsyms]              [k] sched_clock_tick
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] add_page_to_unevictable_list
     0.00%           app  [kernel.kallsyms]              [k] lapic_next_event
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] native_flush_tlb_others
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt3
     0.00%           app  [kernel.kallsyms]              [k] do_mmap_pgoff
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt1
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] munlock_vma_pages_range
     0.00%           app  [kernel.kallsyms]              [k] __zone_watermark_ok
     0.00%       swapper  [kernel.kallsyms]              [k] handle_irq_event
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __split_vma
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt2
     0.00%       swapper  [kernel.kallsyms]              [k] resched_best_idle
     0.00%           app  app                            [.] 
     0.00%          perf  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] ____pagevec_lru_add_fn
     0.00%           app  [kernel.kallsyms]              [k] ____cache_alloc_node
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt5
     0.00%           app  [kernel.kallsyms]              [k] page_evictable
     0.00%       swapper  [kernel.kallsyms]              [k] native_smp_send_reschedule
     0.00%       swapper  [kernel.kallsyms]              [k] physflat_send_IPI_mask
     0.00%           app  [kernel.kallsyms]              [k] account_process_tick
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt18
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] security_vm_enough_memory
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __wake_up_sync_key
     0.00%       swapper  [kernel.kallsyms]              [k] __rb_rotate_right
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __remove_hrtimer
     0.00%       swapper  [kernel.kallsyms]              [k] common_interrupt
     0.00%           app  [kernel.kallsyms]              [k] vm_stat_account
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt19
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt21
     0.00%           app  [kernel.kallsyms]              [k] __switch_to
     0.00%           app  [kernel.kallsyms]              [k] down_read
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt4
     0.00%           app  [kernel.kallsyms]              [k] anon_vma_prepare
     0.00%       swapper  [kernel.kallsyms]              [k] __rb_rotate_left
     0.00%       swapper  [kernel.kallsyms]              [k] list_del
     0.00%           app  [kernel.kallsyms]              [k] __lru_cache_add
     0.00%       swapper  [kernel.kallsyms]              [k] invalidate_interrupt20
     0.00%           app  [kernel.kallsyms]              [k] __percpu_counter_add
     0.00%       swapper  [kernel.kallsyms]              [k] default_wake_function
     0.00%           app  [kernel.kallsyms]              [k] lru_add_drain
     0.00%           app  [kernel.kallsyms]              [k] __get_user_pages
     0.00%           app  [vdso]                         [.] 0x7fff4a7278d7  
     0.00%           app  [kernel.kallsyms]              [k] down_read_trylock
     0.00%           app  [kernel.kallsyms]              [k] page_waitqueue
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] anon_vma_clone
     0.00%           app  [kernel.kallsyms]              [k] __wake_up_bit
     0.00%           app  [kernel.kallsyms]              [k] __dec_zone_state
     0.00%           app  libpthread-2.12.so             [.] _L_cond_lock_902
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] math_state_restore
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] enqueue_hrtimer
     0.00%           app  [kernel.kallsyms]              [k] rb_next
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms].vsyscall_fn  [.] vread_tsc
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] irq_move_irq
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] tick_program_event
     0.00%           app  [kernel.kallsyms]              [k] zone_watermark_ok
     0.00%           app  [kernel.kallsyms]              [k] timerqueue_del
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] cap_file_mprotect
     0.00%       swapper  [kernel.kallsyms]              [k] receiver_wake_function
     0.00%           app  [kernel.kallsyms]              [k] call_rwsem_down_read_failed
     0.00%           app  [kernel.kallsyms]              [k] __page_lock_anon_vma
     0.00%           app  [kernel.kallsyms]              [k] __napi_complete
     0.00%           app  [kernel.kallsyms]              [k] __bitmap_andnot
     0.00%           app  [kernel.kallsyms]              [k] cpumask_any_but
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] restore_args
     0.00%       swapper  [kernel.kallsyms]              [k] mcount
     0.00%           app  [kernel.kallsyms]              [k] __dec_zone_page_state
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] free_pgd_range
     0.00%           app  [kernel.kallsyms]              [k] pagevec_lru_move_fn
     0.00%           app  libc-2.12.so                   [.] __GI_msgrcv
     0.00%           app  [kernel.kallsyms]              [k] get_unmapped_area
     0.00%           app  [kernel.kallsyms]              [k] unmap_region
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] wake_up_process
     0.00%           app  [kernel.kallsyms]              [k] free_pages_prepare
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] do_msgsnd
     0.00%           app  [kernel.kallsyms]              [k] interleave_nodes
     0.00%           app  [kernel.kallsyms]              [k] __rmqueue
     0.00%       swapper  [kernel.kallsyms]              [k] calc_global_load
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] vm_normal_page
     0.00%           app  [kernel.kallsyms]              [k] error_swapgs
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] cap_capable
     0.00%           app  [kernel.kallsyms]              [k] putback_lru_page
     0.00%           app  [kernel.kallsyms]              [k] common_interrupt
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] default_wake_function
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] unlock_page
     0.00%           app  [kernel.kallsyms]              [k] rb_insert_color
     0.00%           app  libc-2.12.so                   [.] __libc_disable_asynccancel
     0.00%           app  [kernel.kallsyms]              [k] irq_to_desc
     0.00%           app  [kernel.kallsyms]              [k] unlink_anon_vmas
     0.00%           app  [kernel.kallsyms]              [k] kfree
     0.00%           app  [kernel.kallsyms]              [k] PageHuge
     0.00%           app  [kernel.kallsyms]              [k] arch_vma_name
     0.00%           app  [kernel.kallsyms]              [k] store_msg
     0.00%       swapper  [kernel.kallsyms]              [k] scheduler_tick
     0.00%       swapper  [kernel.kallsyms]              [k] update_vsyscall
     0.00%           top  libc-2.12.so                   [.] _IO_vfscanf_internal
     0.00%           app  [kernel.kallsyms]              [k] lru_cache_add_lru
     0.00%           app  libc-2.12.so                   [.] __mmap
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] __current_kernel_time
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] cap_msg_queue_msgrcv
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] calc_global_load
     0.00%           app  [kernel.kallsyms]              [k] try_to_unmap_one
     0.00%       swapper  [kernel.kallsyms]              [k] exit_intr
     0.00%           app  [kernel.kallsyms]              [k] try_to_munlock
     0.00%           app  [kernel.kallsyms]              [k] arch_get_unmapped_area_topdown
     0.00%           app  [kernel.kallsyms]              [k] __pagevec_free
     0.00%       swapper  [kernel.kallsyms]              [k] run_timer_softirq
     0.00%           app  librt-2.12.so                  [.] __GI_clock_gettime
     0.00%           app  [kernel.kallsyms]              [k] is_uv_system
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] slab_node
     0.00%           app  [kernel.kallsyms]              [k] update_vsyscall
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] sys_mmap
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] vm_get_page_prot
     0.00%           app  [kernel.kallsyms]              [k] gup_pud_range
     0.00%           app  [kernel.kallsyms]              [k] receiver_wake_function
     0.00%           app  [kernel.kallsyms]              [k] put_page
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           app  [kernel.kallsyms]              [k] unlink_file_vma
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] vma_wants_writenotify
     0.00%           app  [kernel.kallsyms]              [k] capable
     0.00%           app  ld-2.12.so                     [.] do_lookup_x
     0.00%           app  [kernel.kallsyms]              [k] anon_vma_chain_link
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] free_pgtables
     0.00%           app  [kernel.kallsyms]              [k] cap_file_mmap
     0.00%       swapper  [kernel.kallsyms]              [k] irq_to_desc
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __inc_zone_page_state
     0.00%           app  [kernel.kallsyms]              [k] x86_pmu_enable
     0.00%           app  ld-2.12.so                     [.] do_lookup_x
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] sys_mmap_pgoff
     0.00%           app  [kernel.kallsyms]              [k] ipcperms
     0.00%           app  [kernel.kallsyms]              [k] mlock_vma_pages_range
     0.00%           app  [kernel.kallsyms]              [k] set_task_cpu
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __kmalloc
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __mlock_vma_pages_range
     0.00%           app  [kernel.kallsyms]              [k] __math_state_restore
     0.00%           app  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%       swapper  [kernel.kallsyms]              [k] perf_event_task_tick
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] __rcu_pending
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] ipc_lock
     0.00%           app  ld-2.12.so                     [.] strcmp
     0.00%           app  [kernel.kallsyms]              [k] security_file_mprotect
     0.00%           app  [kernel.kallsyms]              [k] __bitmap_and
     0.00%           app  [kernel.kallsyms]              [k] sched_clock_local
     0.00%           app  [kernel.kallsyms]              [k] security_capable
     0.00%           app  [kernel.kallsyms]              [k] find_first_bit
     0.00%           app  [kernel.kallsyms]              [k] retint_with_reschedule
     0.00%       swapper  [kernel.kallsyms]              [k] tick_sched_timer
     0.00%           app  ld-2.12.so                     [.] check_match.12450
     0.00%       swapper  [kernel.kallsyms]              [k] update_process_times
     0.00%           app  [kernel.kallsyms]              [k] gup_huge_pmd
     0.00%           app  [kernel.kallsyms]              [k] page_remove_rmap
     0.00%           app  [kernel.kallsyms]              [k] follow_huge_addr
     0.00%           app  libc-2.12.so                   [.] __msgsnd
     0.00%           top  [kernel.kallsyms]              [k] format_decode
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] remove_vma
     0.00%           app  [kernel.kallsyms]              [k] __list_add
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __current_kernel_time
     0.00%           app  [kernel.kallsyms]              [k] native_write_cr0
     0.00%           app  ld-2.12.so                     [.] _dl_lookup_symbol_x
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  ld-2.12.so                     [.] _dl_lookup_symbol_x
     0.00%   kworker/7:1  [e1000e]                       [k] e1000e_update_stats
     0.00%           app  [kernel.kallsyms]              [k] arch_unmap_area_topdown
     0.00%           app  ld-2.12.so                     [.] strcmp
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] free_pages
     0.00%           app  [kernel.kallsyms]              [k] __vma_link_rb
     0.00%           app  app                            [.] 
     0.00%           app  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%           app  [kernel.kallsyms]              [k] __phys_addr
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] perf_pmu_enable
     0.00%           app  [kernel.kallsyms]              [k] net_rx_action
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] idr_find
     0.00%           app  [kernel.kallsyms]              [k] dequeue_task
     0.00%       swapper  [kernel.kallsyms]              [k] profile_tick
     0.00%           app  [kernel.kallsyms]              [k] sys_msgrcv
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  libc-2.12.so                   [.] isnanf
     0.00%       swapper  [kernel.kallsyms]              [k] x86_pmu_disable_all
     0.00%           app  libc-2.12.so                   [.] __GI___isinff
     0.00%           app  [kernel.kallsyms]              [k] __bitmap_empty
     0.00%            sh  [kernel.kallsyms]              [k] copy_page_c
     0.00%           top  [kernel.kallsyms]              [k] number
     0.00%       swapper  [kernel.kallsyms]              [k] cache_grow
     0.00%           app  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.00%       swapper  [kernel.kallsyms]              [k] __run_hrtimer
     0.00%           app  [kernel.kallsyms]              [k] pc_user_time
     0.00%           app  [kernel.kallsyms]              [k] cache_grow
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] kmem_freepages
     0.00%           app  [kernel.kallsyms]              [k] rcu_start_gp
     0.00%           app  ld-2.12.so                     [.] check_match.12450
     0.00%           app  [kernel.kallsyms]              [k] ns_capable
     0.00%           app  [kernel.kallsyms]              [k] exit_intr
     0.00%           app  [kernel.kallsyms]              [k] find_extend_vma
     0.00%           app  [kernel.kallsyms]              [k] force_qs_rnp
     0.00%           app  [kernel.kallsyms]              [k] ima_file_mmap
     0.00%           app  [kernel.kallsyms]              [k] ipcperms
     0.00%           app  [kernel.kallsyms]              [k] native_set_pte_at
     0.00%       swapper  [kernel.kallsyms]              [k] x86_pmu_disable
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           app  [kernel.kallsyms]              [k] security_file_mmap
     0.00%       swapper  [kernel.kallsyms]              [k] raise_softirq
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%   kworker/4:1  [e1000e]                       [k] e1000e_update_stats
     0.00%           app  [kernel.kallsyms]              [k] memcpy
     0.00%           app  [kernel.kallsyms]              [k] load_msg
     0.00%           top  [kernel.kallsyms]              [k] do_task_stat
     0.00%           app  [kernel.kallsyms]              [k] ____pagevec_lru_add
     0.00%           app  [kernel.kallsyms]              [k] _copy_to_user
     0.00%           app  [kernel.kallsyms]              [k] sock_def_readable
     0.00%       swapper  [kernel.kallsyms]              [k] hrtimer_run_queues
     0.00%           app  [kernel.kallsyms]              [k] free_block
     0.00%  kworker/10:1  [e1000e]                       [k] e1000e_update_stats
     0.00%           app  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%           app  [kernel.kallsyms]              [k] get_gate_vma
     0.00%          tail  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           top  [kernel.kallsyms]              [k] vsnprintf
     0.00%           app  [kernel.kallsyms]              [k] idr_find
     0.00%           app  [kernel.kallsyms]              [k] find_next_bit
     0.00%           top  libc-2.12.so                   [.] __GI_vfprintf
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] _atomic_dec_and_lock
     0.00%           app  app                            [.] 
     0.00%    in.telnetd  in.telnetd                     [.] 0x37f2          
     0.00%      kthreadd  [kernel.kallsyms]              [k] drain_array
     0.00%           app  app                            [.] 
     0.00%   kworker/6:0  [e1000e]                       [k] e1000e_update_stats
     0.00%           app  [kernel.kallsyms]              [k] clear_page_c
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] ret_from_sys_call
     0.00%    in.telnetd  [kernel.kallsyms]              [k] schedule
     0.00%   kworker/1:1  [e1000e]                       [k] e1000e_update_stats
     0.00%           app  app                            [.] 
     0.00%          perf  [ext4]                         [k] ext4_da_write_begin
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] drain_array
     0.00%       swapper  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] cascade
     0.00%       swapper  [kernel.kallsyms]              [k] run_local_timers
     0.00%           app  [kernel.kallsyms]              [k] page_fault
     0.00%           app  [kernel.kallsyms]              [k] mod_zone_page_state
     0.00%           app  [kernel.kallsyms]              [k] ipc_lock_check
     0.00%           app  [kernel.kallsyms]              [k] sysret_check
     0.00%          date  libc-2.12.so                   [.] __GI__dl_addr
     0.00%        vmstat  [kernel.kallsyms]              [k] format_decode
     0.00%          perf  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%          perf  [ext4]                         [k] __ext4_get_inode_loc
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%            sh  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  [kernel.kallsyms]              [k] enqueue_task
     0.00%           app  [kernel.kallsyms]              [k] retint_careful
     0.00%           app  app                            [.] 
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] drain_array
     0.00%           app  app                            [.] 
     0.00%          date  [kernel.kallsyms]              [k] copy_page_c
     0.00%           app  [kernel.kallsyms]              [k] pud_huge
     0.00%            sh  [kernel.kallsyms]              [k] clear_page_c
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] reschedule_interrupt
     0.00%           app  [kernel.kallsyms]              [k] cap_ipc_permission
     0.00%       swapper  [kernel.kallsyms]              [k] rcu_check_callbacks
     0.00%           app  [kernel.kallsyms]              [k] ipc_lock_check
     0.00%           app  [kernel.kallsyms]              [k] iput
     0.00%           app  ld-2.12.so                     [.] _dl_relocate_object
     0.00%           app  ld-2.12.so                     [.] _dl_relocate_object
     0.00%    in.telnetd  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%   kworker/0:1  [e1000e]                       [k] e1000e_update_stats
     0.00%          date  [kernel.kallsyms]              [k] page_fault
     0.00%           top  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%          perf  [ext4]                         [k] ext4_mark_iloc_dirty
     0.00%           app  [kernel.kallsyms]              [k] filemap_fault
     0.00%            sh  bash                           [.] 0x48c2c         
     0.00%           app  [kernel.kallsyms]              [k] ktime_get
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] native_read_msr_safe
     0.00%   flush-253:8  [kernel.kallsyms]              [k] page_waitqueue
     0.00%          date  [kernel.kallsyms]              [k] clear_page_c
     0.00%         egrep  egrep                          [.] 0xb690          
     0.00%            sh  [kernel.kallsyms]              [k] copy_pte_range
     0.00%           app  [kernel.kallsyms]              [k] page_fault
     0.00%           app  [e1000e]                       [k] e1000_intr_msi
     0.00%       swapper  [kernel.kallsyms]              [k] printk_tick
     0.00%           app  [kernel.kallsyms]              [k] cap_msg_msg_free_security
     0.00%           app  libc-2.12.so                   [.] __strcmp_sse2
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] find_mergeable_anon_vma
     0.00%    in.telnetd  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           app  [kernel.kallsyms]              [k] native_write_msr_safe
     0.00%           app  [kernel.kallsyms]              [k] system_call
     0.00%           app  [kernel.kallsyms]              [k] irq_return
     0.00%       swapper  [kernel.kallsyms]              [k] hrtimer_run_pending
     0.00%           app  [kernel.kallsyms]              [k] copy_page_c
     0.00%           top  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           app  [kernel.kallsyms]              [k] pid_vnr
     0.00%   flush-253:8  [ext4]                         [k] mpage_da_submit_io
     0.00%          ntpd  [kernel.kallsyms]              [k] datagram_poll
     0.00%           app  [kernel.kallsyms]              [k] __task_pid_nr_ns
     0.00%           app  [kernel.kallsyms]              [k] dma_issue_pending_all
     0.00%           app  [kernel.kallsyms]              [k] pmd_huge
     0.00%           app  [kernel.kallsyms]              [k] get_user_pages_fast
     0.00%           app  [kernel.kallsyms]              [k] __netif_receive_skb
     0.00%       swapper  [kernel.kallsyms]              [k] perf_pmu_disable
     0.00%           app  [e1000e]                       [k] e1000_xmit_frame
     0.00%           app  [kernel.kallsyms]              [k] sys_msgsnd
     0.00%           app  libc-2.12.so                   [.] __GI_vfprintf
     0.00%       swapper  [kernel.kallsyms]              [k] rcu_start_gp
     0.00%          perf  [kernel.kallsyms]              [k] __inc_zone_state
     0.00%           app  [kernel.kallsyms]              [k] getnstimeofday
     0.00%          perf  [kernel.kallsyms]              [k] __mark_inode_dirty
     0.00%       swapper  [kernel.kallsyms]              [k] irq_work_run
     0.00%           app  [kernel.kallsyms]              [k] __rcu_process_callbacks
     0.00%           app  libc-2.12.so                   [.] isnanf
     0.00%       swapper  [kernel.kallsyms]              [k] irq_return
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           awk  [kernel.kallsyms]              [k] page_fault
     0.00%           app  [kernel.kallsyms]              [k] rcu_process_gp_end
     0.00%           app  [kernel.kallsyms]              [k] gart_map_page
     0.00%          perf  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%        vmstat  [kernel.kallsyms]              [k] find_next_bit
     0.00%           top  [kernel.kallsyms]              [k] find_next_bit
     0.00%           top  [kernel.kallsyms]              [k] __d_lookup
     0.00%           app  [kernel.kallsyms]              [k] cap_msg_msg_alloc_security
     0.00%           app  libc-2.12.so                   [.] __libc_enable_asynccancel
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] drain_array
     0.00%           app  [kernel.kallsyms]              [k] security_msg_msg_free
     0.00%           app  libc-2.12.so                   [.] __libc_enable_asynccancel
     0.00%       swapper  [kernel.kallsyms]              [k] force_qs_rnp
     0.00%       swapper  [kernel.kallsyms]              [k] run_posix_cpu_timers
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] drain_array
     0.00%           top  libtinfo.so.5.7                [.] _nc_outch
     0.00%           awk  [kernel.kallsyms]              [k] clear_page_c
     0.00%           app  app                            [.] 
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] drain_array
     0.00%           app  app                            [.] 
     0.00%         egrep  [kernel.kallsyms]              [k] clear_page_c
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_trylock
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] perf_event_task_sched_out
     0.00%           app  [kernel.kallsyms]              [k] security_ipc_permission
     0.00%          date  [kernel.kallsyms]              [k] unmap_vmas
     0.00%       swapper  [kernel.kallsyms]              [k] x86_pmu_enable_all
     0.00%           top  [kernel.kallsyms]              [k] memcpy
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] native_read_cr0
     0.00%           app  [kernel.kallsyms]              [k] free_msg
     0.00%   flush-253:8  [kernel.kallsyms]              [k] clear_page_dirty_for_io
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] sched_clock_cpu
     0.00%            ps  [kernel.kallsyms]              [k] number
     0.00%           top  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%          perf  perf                           [.] __cmd_record
     0.00%           top  top                            [.] 0x26b3          
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] drain_array
     0.00%           app  [kernel.kallsyms]              [k] sched_clock
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] filemap_fault
     0.00%          date  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           top  [kernel.kallsyms]              [k] find_pid_ns
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] drain_array
     0.00%   flush-253:8  [kernel.kallsyms]              [k] find_get_pages
     0.00%           app  [kernel.kallsyms]              [k] get_seconds
     0.00%          tail  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] _cond_resched
     0.00%           app  [kernel.kallsyms]              [k] __rb_rotate_right
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%            sh  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%         egrep  [kernel.kallsyms]              [k] page_fault
     0.00%           app  [kernel.kallsyms]              [k] unmap_vmas
     0.00%          perf  [ext4]                         [k] ext4_journal_start_sb
     0.00%          perf  [kernel.kallsyms]              [k] __memset
     0.00%           app  [kernel.kallsyms]              [k] clear_page_c
     0.00%           app  app                            [.] 
     0.00%          perf  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%         sleep  libc-2.12.so                   [.] __GI__dl_addr
     0.00%   flush-253:8  [kernel.kallsyms]              [k] find_get_pages_tag
     0.00%          perf  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%    in.telnetd  [kernel.kallsyms]              [k] do_select
     0.00%   flush-253:8  [ext4]                         [k] mpage_add_bh_to_extent
     0.00%            sh  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           app  [kernel.kallsyms]              [k] native_read_tsc
     0.00%           app  [kernel.kallsyms]              [k] __put_user_8
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%          tail  libc-2.12.so                   [.] __GI_fwrite_unlocked
     0.00%            ps  [kernel.kallsyms]              [k] format_decode
     0.00%           app  [kernel.kallsyms]              [k] security_msg_queue_msgrcv
     0.00%           app  app                            [.] 
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] _cond_resched
     0.00%         egrep  [kernel.kallsyms]              [k] unmap_vmas
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] cache_reap
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] cache_reap
     0.00%           app  [kernel.kallsyms]              [k] reusable_anon_vma
     0.00%           top  [kernel.kallsyms]              [k] __d_lookup_rcu
     0.00%            sh  [kernel.kallsyms]              [k] copy_process
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] drain_array
     0.00%        vmstat  [kernel.kallsyms]              [k] number
     0.00%           app  [kernel.kallsyms]              [k] packet_sendmsg
     0.00%           app  app                            [.] 
     0.00%          perf  [kernel.kallsyms]              [k] generic_file_buffered_write
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] drain_array
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%      kthreadd  [kernel.kallsyms]              [k] cache_reap
     0.00%         sleep  [kernel.kallsyms]              [k] clear_page_c
     0.00%           app  [kernel.kallsyms]              [k] put_compound_page
     0.00%            sh  [kernel.kallsyms]              [k] page_fault
     0.00%            sh  [kernel.kallsyms]              [k] find_vma
     0.00%          date  [kernel.kallsyms]              [k] link_path_walk
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] drain_array
     0.00%          ntpd  [kernel.kallsyms]              [k] udp_poll
     0.00%      kthreadd  [kernel.kallsyms]              [k] _cond_resched
     0.00%           app  [kernel.kallsyms]              [k] unmap_vmas
     0.00%         egrep  libc-2.12.so                   [.] __GI__dl_addr
     0.00%           app  [kernel.kallsyms]              [k] packet_rcv
     0.00%           app  app                            [.] 
     0.00%          perf  [jbd2]                         [k] jbd2_journal_stop
     0.00%           top  libc-2.12.so                   [.] _IO_default_xsputn_internal
     0.00%            sh  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%    in.telnetd  [kernel.kallsyms]              [k] n_tty_read
     0.00%           app  [kernel.kallsyms]              [k] ip_route_input_common
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%           cut  [kernel.kallsyms]              [k] pipe_wait
     0.00%           top  libc-2.12.so                   [.] ____strtoull_l_internal
     0.00%      kthreadd  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_alloc_node_trace
     0.00%           top  [kernel.kallsyms]              [k] put_dec_trunc
     0.00%           app  [kernel.kallsyms]              [k] check_for_new_grace_period
     0.00%         egrep  libc-2.12.so                   [.] _int_malloc
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] free_block
     0.00%           app  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%       swapper  [kernel.kallsyms]              [k] rcu_process_gp_end
     0.00%          perf  [kernel.kallsyms]              [k] __block_write_begin
     0.00%           app  app                            [.] 
     0.00%           top  libc-2.12.so                   [.] _IO_sputbackc
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%           app  [kernel.kallsyms]              [k] clocksource_watchdog
     0.00%            ps  libc-2.12.so                   [.] _IO_vfscanf_internal
     0.00%          perf  [kernel.kallsyms]              [k] bit_waitqueue
     0.00%       swapper  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%           top  [kernel.kallsyms]              [k] task_prio
     0.00%           awk  [kernel.kallsyms]              [k] filemap_fault
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tcp_sendmsg
     0.00%           awk  libc-2.12.so                   [.] __GI__dl_addr
     0.00%           app  [kernel.kallsyms]              [k] __virt_addr_valid
     0.00%   flush-253:8  [kernel.kallsyms]              [k] page_mkclean
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           app  [kernel.kallsyms]              [k] copy_page_c
     0.00%         egrep  [kernel.kallsyms]              [k] filemap_fault
     0.00%           app  [kernel.kallsyms]              [k] native_sched_clock
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%          tail  [kernel.kallsyms]              [k] vfs_read
     0.00%           top  [kernel.kallsyms]              [k] schedule
     0.00%       swapper  [kernel.kallsyms]              [k] pci_conf1_read
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] ip_rcv_finish
     0.00%           top  libc-2.12.so                   [.] _IO_no_init
     0.00%           app  [kernel.kallsyms]              [k] ipc_lock
     0.00%           top  [kernel.kallsyms]              [k] do_lookup
     0.00%          perf  [kernel.kallsyms]              [k] system_call
     0.00%   kworker/0:1  [e1000e]                       [k] e1000e_update_adaptive
     0.00%           app  [kernel.kallsyms]              [k] rcu_process_callbacks
     0.00%          tail  [kernel.kallsyms]              [k] sched_clock_cpu
     0.00%           app  [kernel.kallsyms]              [k] __alloc_skb
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __put_anon_vma
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%       swapper  [kernel.kallsyms]              [k] mod_zone_page_state
     0.00%           app  app                            [.] 
     0.00%        vmstat  libc-2.12.so                   [.] __memchr
     0.00%          perf  [jbd2]                         [k] jbd2__journal_start
     0.00%           app  [jbd]                          [k] start_this_handle
     0.00%   flush-253:8  [kernel.kallsyms]              [k] inc_zone_page_state
     0.00%           app  [kernel.kallsyms]              [k] dev_gro_receive
     0.00%           app  app                            [.] 
     0.00%           top  [kernel.kallsyms]              [k] link_path_walk
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] cache_reap
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] free_block
     0.00%          perf  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%          date  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           app  [kernel.kallsyms]              [k] down_read
     0.00%           app  [kernel.kallsyms]              [k] do_page_fault
     0.00%           app  libc-2.12.so                   [.] memcpy
     0.00%          date  [kernel.kallsyms]              [k] __do_fault
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] __rcu_process_callbacks
     0.00%   kworker/1:1  [e1000e]                       [k] e1000_watchdog_task
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] _cond_resched
     0.00%        vmstat  [kernel.kallsyms]              [k] vsnprintf
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] cache_reap
     0.00%           app  [kernel.kallsyms]              [k] __do_fault
     0.00%          perf  [kernel.kallsyms]              [k] __find_get_block
     0.00%           app  [kernel.kallsyms]              [k] ip_rcv
     0.00%   flush-253:8  [ext4]                         [k] ext4_bio_write_page
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] drain_array
     0.00%           awk  [kernel.kallsyms]              [k] copy_page_c
     0.00%          tail  tail                           [.] 0x3b59          
     0.00%            ps  [kernel.kallsyms]              [k] vsnprintf
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%       swapper  [mpt2sas]                      [k] mpt2sas_base_free_smid
     0.00%         sleep  [kernel.kallsyms]              [k] page_fault
     0.00%  kworker/10:1  [e1000e]                       [k] e1000_watchdog_task
     0.00%           app  libstdc++.so.6.0.13            [.] 0x64904         
     0.00%           app  app                            [.] 
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] free_block
     0.00%           app  [kernel.kallsyms]              [k] tcp_ack
     0.00%          perf  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%           app  [kernel.kallsyms]              [k] resched_task
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           app  [e1000e]                       [k] e1000_clean
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] _cond_resched
     0.00%           app  [e1000e]                       [k] e1000_alloc_rx_buffers
     0.00%           app  [kernel.kallsyms]              [k] native_read_tsc
     0.00%           app  app                            [.] 
     0.00%          date  [kernel.kallsyms]              [k] load_elf_binary
     0.00%           app  [kernel.kallsyms]              [k] kmem_getpages
     0.00%           app  ld-2.12.so                     [.] do_lookup_x
     0.00%            sh  bash                           [.] 0x37f77         
     0.00%   flush-253:8  [kernel.kallsyms]              [k] release_pages
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] activate_task
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] free_block
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] sys_nanosleep
     0.00%            sh  [kernel.kallsyms]              [k] unmap_vmas
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] cache_reap
     0.00%           app  app                            [.] 
     0.00%           app  libstdc++.so.6.0.13            [.] __dynamic_cast
     0.00%     kjournald  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  [kernel.kallsyms]              [k] skb_gro_reset_offset
     0.00%          date  libc-2.12.so                   [.] _int_malloc
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%        vmstat  libc-2.12.so                   [.] __sigprocmask
     0.00%           app  [kernel.kallsyms]              [k] __wait_on_bit_lock
     0.00%           app  [kernel.kallsyms]              [k] delayed_work_timer_fn
     0.00%   flush-253:8  [ext4]                         [k] write_cache_pages_da
     0.00%       swapper  [kernel.kallsyms]              [k] __rmqueue
     0.00%          perf  [kernel.kallsyms]              [k] do_sys_poll
     0.00%         sleep  [kernel.kallsyms]              [k] copy_page_c
     0.00%           top  [kernel.kallsyms]              [k] put_dec_full
     0.00%           app  libc-2.12.so                   [.] __GI__dl_addr
     0.00%          date  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%   flush-253:8  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           top  libc-2.12.so                   [.] _IO_putc_internal
     0.00%           app  app                            [.] 
     0.00%           awk  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           app  app                            [.] 
     0.00%            sh  bash                           [.] execute_command_internal
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] _cond_resched
     0.00%            ps  libc-2.12.so                   [.] __GI_vfprintf
     0.00%           app  bash                           [.] 0x48604         
     0.00%            sh  bash                           [.] hash_search
     0.00%    in.telnetd  [kernel.kallsyms]              [k] core_sys_select
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] free_block
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] cache_reap
     0.00%           top  [kernel.kallsyms]              [k] seq_read
     0.00%          perf  [kernel.kallsyms]              [k] grab_cache_page_write_begin
     0.00%          perf  [jbd2]                         [k] do_get_write_access
     0.00%            sh  [kernel.kallsyms]              [k] flush_tlb_page
     0.00%       swapper  [kernel.kallsyms]              [k] rcu_process_callbacks
     0.00%           app  app                            [.] 
     0.00%          date  bash                           [.] 0x22d1f         
     0.00%           app  ld-2.12.so                     [.] _dl_fixup
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tcp_write_xmit
     0.00%           app  [kernel.kallsyms]              [k] sys_msgrcv
     0.00%    in.telnetd  [kernel.kallsyms]              [k] net_rx_action
     0.00%          perf  [kernel.kallsyms]              [k] next_zones_zonelist
     0.00%           app  [kernel.kallsyms]              [k] reschedule_interrupt
     0.00%       swapper  [kernel.kallsyms]              [k] account_process_tick
     0.00%         egrep  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           top  [kernel.kallsyms]              [k] pid_revalidate
     0.00%           app  [kernel.kallsyms]              [k] error_swapgs
     0.00%   flush-253:8  [kernel.kallsyms]              [k] radix_tree_tag_clear
     0.00%           app  libc-2.12.so                   [.] __GI__dl_addr
     0.00%            sh  [kernel.kallsyms]              [k] __list_add
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] worker_thread
     0.00%          date  [kernel.kallsyms]              [k] __memset
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] _cond_resched
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] __list_del_entry
     0.00%          perf  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%           app  [kernel.kallsyms]              [k] slab_destroy
     0.00%           app  [kernel.kallsyms]              [k] iov_iter_advance
     0.00%           app  libc-2.12.so                   [.] __mpn_divrem
     0.00%          perf  [kernel.kallsyms]              [k] alloc_pages_current
     0.00%          perf  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%           app  [kernel.kallsyms]              [k] skb_put
     0.00%            sh  [kernel.kallsyms]              [k] anon_vma_clone
     0.00%           app  [kernel.kallsyms]              [k] insert_work
     0.00%          perf  [ext4]                         [k] ext4_ext_map_blocks
     0.00%            sh  libc-2.12.so                   [.] __GI___libc_malloc
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%    in.telnetd  [e1000e]                       [k] e1000_xmit_frame
     0.00%          perf  [jbd2]                         [k] start_this_handle
     0.00%            sh  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%           app  [kernel.kallsyms]              [k] native_load_tls
     0.00%          perf  [kernel.kallsyms]              [k] __list_add
     0.00%           app  [kernel.kallsyms]              [k] security_msg_msg_alloc
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] dev_hard_start_xmit
     0.00%           top  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%            sh  [kernel.kallsyms]              [k] anon_vma_fork
     0.00%          perf  [kernel.kallsyms]              [k] iov_iter_copy_from_user_atomic
     0.00%       swapper  [kernel.kallsyms]              [k] kmem_getpages
     0.00%            sh  [kernel.kallsyms]              [k] dup_mm
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           top  [kernel.kallsyms]              [k] __list_add
     0.00%         egrep  bash                           [.] 0x61947         
     0.00%            sh  [kernel.kallsyms]              [k] __rmqueue
     0.00%           app  [kernel.kallsyms]              [k] resched_closest_idle
     0.00%         egrep  [kernel.kallsyms]              [k] __do_fault
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tty_poll
     0.00%          perf  [kernel.kallsyms]              [k] file_update_time
     0.00%          ntpd  [kernel.kallsyms]              [k] fget_light
     0.00%          perf  [kernel.kallsyms]              [k] add_to_page_cache_lru
     0.00%           app  [kernel.kallsyms]              [k] up_read
     0.00%          perf  [kernel.kallsyms]              [k] radix_tree_insert
     0.00%         sleep  [kernel.kallsyms]              [k] filemap_fault
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] __list_add
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           top  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%          perf  [kernel.kallsyms]              [k] blk_flush_plug_list
     0.00%          perf  [kernel.kallsyms]              [k] schedule
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] free_block
     0.00%       swapper  [kernel.kallsyms]              [k] clocksource_watchdog
     0.00%       swapper  [kernel.kallsyms]              [k] kfree
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           app  [kernel.kallsyms]              [k] kthread_data
     0.00%           app  [kernel.kallsyms]              [k] free_pcppages_bulk
     0.00%          perf  [ext4]                         [k] __ext4_journal_get_write_access
     0.00%           top  libc-2.12.so                   [.] _IO_str_init_static_internal
     0.00%        vmstat  [kernel.kallsyms]              [k] seq_printf
     0.00%           app  [kernel.kallsyms]              [k] ihold
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] get_work_gcwq
     0.00%          perf  [kernel.kallsyms]              [k] __percpu_counter_add
     0.00%          perf  [kernel.kallsyms]              [k] __rmqueue
     0.00%           app  [kernel.kallsyms]              [k] find_vma
     0.00%            sh  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%          perf  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%           app  app                            [.] 
     0.00%          perf  [ext4]                         [k] ext4_mark_inode_dirty
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] sockfd_lookup_light
     0.00%          perf  [kernel.kallsyms]              [k] alloc_page_buffers
     0.00%   flush-253:8  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%            sh  libc-2.12.so                   [.] _int_free
     0.00%           top  [kernel.kallsyms]              [k] thread_group_cputime
     0.00%           app  app                            [.] 
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] _cond_resched
     0.00%           app  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%            sh  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%        vmstat  libc-2.12.so                   [.] __strstr_sse2
     0.00%           app  [kernel.kallsyms]              [k] sched_clock_cpu
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __bio_add_page
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%          date  [kernel.kallsyms]              [k] perf_event_mmap
     0.00%           ksh  ksh                            [.] 0x14554         
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%          perf  [ext4]                         [k] ext4_get_group_desc
     0.00%           app  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%           app  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%           app  [kernel.kallsyms]              [k] mark_buffer_dirty
     0.00%            sh  libc-2.12.so                   [.] __strcmp_sse2
     0.00%           top  libc-2.12.so                   [.] __GI_sscanf
     0.00%          date  [kernel.kallsyms]              [k] filemap_fault
     0.00%           app  [kernel.kallsyms]              [k] sock_wfree
     0.00%           app  [kernel.kallsyms]              [k] _cond_resched
     0.00%       swapper  [kernel.kallsyms]              [k] _raw_spin_trylock
     0.00%          date  [kernel.kallsyms]              [k] find_get_page
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] schedule
     0.00%   flush-253:8  [kernel.kallsyms]              [k] gart_map_sg
     0.00%           app  [kernel.kallsyms]              [k] dev_queue_xmit
     0.00%           app  [kernel.kallsyms]              [k] page_remove_rmap
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] mod_timer
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] schedule
     0.00%           top  [kernel.kallsyms]              [k] vfs_read
     0.00%           app  libc-2.12.so                   [.] __GI_vfprintf
     0.00%           app  [kernel.kallsyms]              [k] schedule
     0.00%           top  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%           top  [kernel.kallsyms]              [k] n_tty_write
     0.00%          date  ld-2.12.so                     [.] _dl_map_object_from_fd
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] find_next_bit
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] cache_grow
     0.00%           top  [kernel.kallsyms]              [k] path_lookupat
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] _cond_resched
     0.00%       swapper  [kernel.kallsyms]              [k] pci_read
     0.00%           app  libc-2.12.so                   [.] ___printf_fp
     0.00%           app  app                            [.] 
     0.00%           top  [kernel.kallsyms]              [k] proc_pid_readdir
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%          tail  [kernel.kallsyms]              [k] queue_work_on
     0.00%           app  [kernel.kallsyms]              [k] _cond_resched
     0.00%           app  [kernel.kallsyms]              [k] dev_get_by_index
     0.00%         egrep  [kernel.kallsyms]              [k] find_vma
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%           app  [kernel.kallsyms]              [k] security_ipc_permission
     0.00%          tail  libc-2.12.so                   [.] __GI___fxstat64
     0.00%           app  app                            [.] 
     0.00%           top  libc-2.12.so                   [.] __GI_bsearch
     0.00%          date  [kernel.kallsyms]              [k] __wake_up_bit
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] cache_reap
     0.00%           app  [kernel.kallsyms]              [k] internal_add_timer
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%   jbd2/dm-8-8  [dm_mod]                       [k] dm_request
     0.00%           top  [kernel.kallsyms]              [k] nameidata_to_filp
     0.00%           top  [kernel.kallsyms]              [k] nameidata_dentry_drop_rcu
     0.00%          date  [kernel.kallsyms]              [k] find_vma
     0.00%           app  [kernel.kallsyms]              [k] prio_tree_insert
     0.00%         egrep  [kernel.kallsyms]              [k] copy_page_c
     0.00%         sleep  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           awk  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  [kernel.kallsyms]              [k] retint_check
     0.00%          ntpd  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  [kernel.kallsyms]              [k] __d_lookup_rcu
     0.00%           app  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%   kworker/0:1  [e1000e]                       [k] e1000_watchdog_task
     0.00%           app  [kernel.kallsyms]              [k] find_get_page
     0.00%           app  libc-2.12.so                   [.] _IO_default_xsputn_internal
     0.00%            sh  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __wake_up_bit
     0.00%           top  [kernel.kallsyms]              [k] system_call
     0.00%           app  [vdso]                         [.] 0x7fff083ff6d1  
     0.00%           top  [kernel.kallsyms]              [k] path_init
     0.00%         sleep  [kernel.kallsyms]              [k] unmap_vmas
     0.00%           top  [kernel.kallsyms]              [k] path_openat
     0.00%            sh  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%           app  libc-2.12.so                   [.] __libc_disable_asynccancel
     0.00%   kworker/6:0  [e1000e]                       [k] e1000_watchdog_task
     0.00%           app  [kernel.kallsyms]              [k] system_call_after_swapgs
     0.00%           app  [kernel.kallsyms]              [k] release_pages
     0.00%         egrep  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%   flush-253:8  [kernel.kallsyms]              [k] find_next_bit
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] cache_reap
     0.00%           top  libproc-3.2.8.so               [.] 0x7790          
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] mod_timer
     0.00%        vmstat  libc-2.12.so                   [.] __strchr_sse2
     0.00%           app  [kernel.kallsyms]              [k] netif_receive_skb
     0.00%           top  libc-2.12.so                   [.] ___printf_fp
     0.00%            sh  bash                           [.] 0x60ef4         
     0.00%       swapper  [kernel.kallsyms]              [k] rcu_report_qs_rnp
     0.00%          date  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%          perf  [kernel.kallsyms]              [k] generic_getxattr
     0.00%           app  [e1000e]                       [k] e1000_receive_skb
     0.00%           app  [kernel.kallsyms]              [k] __do_softirq
     0.00%          date  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%          perf  [kernel.kallsyms]              [k] __find_get_block_slow
     0.00%          date  bash                           [.] 0x48ed6         
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tty_read
     0.00%          date  [kernel.kallsyms]              [k] do_page_fault
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tcp_poll
     0.00%            sh  [kernel.kallsyms]              [k] page_waitqueue
     0.00%           app  [kernel.kallsyms].vsyscall_fn  [.] vread_tsc
     0.00%           app  [kernel.kallsyms]              [k] security_msg_queue_msgsnd
     0.00%           app  ld-2.12.so                     [.] _dl_lookup_symbol_x
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           app  [kernel.kallsyms]              [k] eth_type_trans
     0.00%          ntpd  ntpd                           [.] timer
     0.00%          perf  [kernel.kallsyms]              [k] task_dirty_inc
     0.00%   flush-253:8  [dm_mod]                       [k] dm_merge_bvec
     0.00%          perf  [kernel.kallsyms]              [k] __lru_cache_add
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%           top  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%           top  [kernel.kallsyms]              [k] security_task_to_inode
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] cache_reap
     0.00%         sleep  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%           app  [kernel.kallsyms]              [k] list_del
     0.00%           app  app                            [.] 
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __lookup
     0.00%           app  [kernel.kallsyms]              [k] find_vma
     0.00%           app  [kernel.kallsyms]              [k] sock_alloc_send_pskb
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_alloc_node
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tcp_current_mss
     0.00%           app  [kernel.kallsyms]              [k] napi_skb_finish
     0.00%           app  [kernel.kallsyms]              [k] wq_worker_waking_up
     0.00%            sh  [kernel.kallsyms]              [k] wait_consider_task
     0.00%            sh  [kernel.kallsyms]              [k] schedule
     0.00%      kthreadd  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%           app  [kernel.kallsyms]              [k] tick_do_update_jiffies64
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] free_block
     0.00%           app  [kernel.kallsyms]              [k] apic_timer_interrupt
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] cache_reap
     0.00%          perf  [kernel.kallsyms]              [k] mark_page_accessed
     0.00%           top  libproc-3.2.8.so               [.] readtask
     0.00%           app  app                            [.] 
     0.00%           awk  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%    in.telnetd  [kernel.kallsyms]              [k] lock_sock_nested
     0.00%           awk  [kernel.kallsyms]              [k] __list_del_entry
     0.00%    in.telnetd  [kernel.kallsyms]              [k] sysret_check
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] worker_thread
     0.00%            ps  [kernel.kallsyms]              [k] clear_page_c
     0.00%          perf  [ext4]                         [k] ext4_da_write_end
     0.00%           app  [kernel.kallsyms]              [k] link_path_walk
     0.00%         egrep  [kernel.kallsyms]              [k] kfree
     0.00%            ps  [kernel.kallsyms]              [k] proc_pid_status
     0.00%         egrep  [kernel.kallsyms]              [k] do_page_fault
     0.00%    in.telnetd  libc-2.12.so                   [.] __GI___libc_read
     0.00%          perf  [kernel.kallsyms]              [k] create_empty_buffers
     0.00%            ps  [kernel.kallsyms]              [k] memcpy
     0.00%           app  [kernel.kallsyms]              [k] __do_fault
     0.00%         egrep  [kernel.kallsyms]              [k] schedule
     0.00%            sh  [kernel.kallsyms]              [k] do_page_fault
     0.00%           app  app                            [.] 
     0.00%        vmstat  libc-2.12.so                   [.] ____strtoull_l_internal
     0.00%   kworker/5:1  [kernel.kallsyms]              [k] schedule
     0.00%          date  [kernel.kallsyms]              [k] _cond_resched
     0.00%          perf  [kernel.kallsyms]              [k] generic_write_end
     0.00%           app  [kernel.kallsyms]              [k] cap_ipc_permission
     0.00%           top  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%          tail  [kernel.kallsyms]              [k] generic_file_aio_read
     0.00%           app  [kernel.kallsyms]              [k] fsnotify_create_event
     0.00%            sh  [kernel.kallsyms]              [k] filemap_fault
     0.00%           app  [kernel.kallsyms]              [k] __drain_alien_cache
     0.00%           awk  [kernel.kallsyms]              [k] _cond_resched
     0.00%           awk  [kernel.kallsyms]              [k] unmap_vmas
     0.00%       swapper  [kernel.kallsyms]              [k] check_for_new_grace_period
     0.00%    in.telnetd  [kernel.kallsyms]              [k] kmem_cache_alloc_node
     0.00%           app  libc-2.12.so                   [.] __tzfile_compute
     0.00%          tail  [kernel.kallsyms]              [k] find_next_bit
     0.00%           app  [vdso]                         [.] 0x7fff3bdff6d1  
     0.00%          date  [kernel.kallsyms]              [k] __rmqueue
     0.00%           app  [jbd]                          [k] do_get_write_access
     0.00%           top  [kernel.kallsyms]              [k] pid_getattr
     0.00%           app  [kernel.kallsyms]              [k] release_pages
     0.00%           top  [kernel.kallsyms]              [k] __memset
     0.00%           top  [kernel.kallsyms]              [k] fput
     0.00%          perf  [jbd2]                         [k] jbd2_journal_get_write_access
     0.00%           app  [e1000e]                       [k] e1000_update_itr
     0.00%           top  [kernel.kallsyms]              [k] mntput_no_expire
     0.00%            sh  [kernel.kallsyms]              [k] next_zones_zonelist
     0.00%          perf  [kernel.kallsyms]              [k] __pollwait
     0.00%           app  [kernel.kallsyms]              [k] save_args
     0.00%           app  [kernel.kallsyms]              [k] perf_event_mmap
     0.00%       swapper  [kernel.kallsyms]              [k] __queue_work
     0.00%           app  [kernel.kallsyms]              [k] native_load_sp0
     0.00%           app  [kernel.kallsyms]              [k] napi_gro_receive
     0.00%           app  app                            [.] 
     0.00%           top  libc-2.12.so                   [.] msort_with_tmp
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%          perf  [ext4]                         [k] ext4_da_get_block_prep
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] schedule
     0.00%          perf  [kernel.kallsyms]              [k] __block_commit_write
     0.00%          perf  [kernel.kallsyms]              [k] set_bh_page
     0.00%       swapper  [kernel.kallsyms]              [k] test_clear_page_writeback
     0.00%       swapper  [kernel.kallsyms]              [k] force_quiescent_state
     0.00%           top  libc-2.12.so                   [.] __readdir64
     0.00%            sh  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%           top  libproc-3.2.8.so               [.] readproc
     0.00%            ps  libc-2.12.so                   [.] __tzfile_compute
     0.00%      kthreadd  [kernel.kallsyms]              [k] __list_add
     0.00%          date  [kernel.kallsyms]              [k] __call_rcu
     0.00%           top  [kernel.kallsyms]              [k] _cond_resched
     0.00%          date  [kernel.kallsyms]              [k] unlock_page
     0.00%           app  [kernel.kallsyms]              [k] activate_task
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tcp_recvmsg
     0.00%           app  [kernel.kallsyms]              [k] ktime_get
     0.00%           awk  ld-2.12.so                     [.] _dl_cache_libcmp
     0.00%           app  [kernel.kallsyms]              [k] error_sti
     0.00%           app  libc-2.12.so                   [.] _int_free
     0.00%          tail  libc-2.12.so                   [.] _IO_new_do_write
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] worker_enter_idle
     0.00%          date  ld-2.12.so                     [.] memset
     0.00%            sh  bash                           [.] xmalloc
     0.00%         egrep  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           awk  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%           app  [kernel.kallsyms]              [k] do_nanosleep
     0.00%            sh  [kernel.kallsyms]              [k] up_read
     0.00%           app  app                            [.] 
     0.00%          perf  [kernel.kallsyms]              [k] ktime_get
     0.00%           app  [kernel.kallsyms]              [k] force_quiescent_state
     0.00%   flush-253:8  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%   flush-253:8  [dm_mod]                       [k] dm_table_find_target
     0.00%           app  [kernel.kallsyms]              [k] _copy_from_user
     0.00%           top  [kernel.kallsyms]              [k] kmem_cache_alloc_trace
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] __list_add
     0.00%           top  [kernel.kallsyms]              [k] kfree
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] find_next_bit
     0.00%          perf  [kernel.kallsyms]              [k] __list_del_entry
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] free_block
     0.00%           app  ld-2.12.so                     [.] match_symbol
     0.00%           app  [kernel.kallsyms]              [k] __memset
     0.00%           app  [e1000e]                       [k] e1000_maybe_stop_tx
     0.00%          tail  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%       swapper  [kernel.kallsyms]              [k] radix_tree_tag_clear
     0.00%           app  [kernel.kallsyms]              [k] store_msg
     0.00%          date  [kernel.kallsyms]              [k] find_vma_prev
     0.00%          perf  [kernel.kallsyms]              [k] reschedule_interrupt
     0.00%           app  [kernel.kallsyms]              [k] exit_idle
     0.00%           app  ld-2.12.so                     [.] _dl_name_match_p
     0.00%          perf  [kernel.kallsyms]              [k] __prop_inc_single
     0.00%           app  [kernel.kallsyms]              [k] handle_mm_fault
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%         egrep  [kernel.kallsyms]              [k] dput
     0.00%          perf  [kernel.kallsyms]              [k] __wake_up_bit
     0.00%           app  [kernel.kallsyms]              [k] __netif_receive_skb
     0.00%           app  [kernel.kallsyms]              [k] schedule
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%          date  [kernel.kallsyms]              [k] __d_lookup_rcu
     0.00%          perf  [kernel.kallsyms]              [k] do_sync_write
     0.00%           app  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%           app  [kernel.kallsyms]              [k] mcount
     0.00%           awk  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%          tail  libc-2.12.so                   [.] __GI___libc_read
     0.00%   flush-253:8  [kernel.kallsyms]              [k] unlock_page
     0.00%           app  app                            [.] 
     0.00%           top  [kernel.kallsyms]              [k] sysret_check
     0.00%           app  [kernel.kallsyms]              [k] part_round_stats
     0.00%   flush-253:8  [ext4]                         [k] ext4_num_dirty_pages
     0.00%            sh  [kernel.kallsyms]              [k] _cond_resched
     0.00%           top  [kernel.kallsyms]              [k] file_ra_state_init
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] __list_add
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] process_one_work
     0.00%           app  [kernel.kallsyms]              [k] __skb_clone
     0.00%           app  [kernel.kallsyms]              [k] ipc_lock
     0.00%           app  [kernel.kallsyms]              [k] __queue_work
     0.00%         egrep  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%      kthreadd  [kernel.kallsyms]              [k] kmem_freepages
     0.00%            sh  [kernel.kallsyms]              [k] dup_fd
     0.00%   kworker/7:1  [e1000e]                       [k] e1000_watchdog_task
     0.00%            sh  [kernel.kallsyms]              [k] cleanup_timers
     0.00%            ps  [kernel.kallsyms]              [k] proc_fill_cache
     0.00%           app  [kernel.kallsyms]              [k] free_hot_cold_page
     0.00%           app  app                            [.] 
     0.00%           top  [kernel.kallsyms]              [k] task_dumpable
     0.00%           app  libc-2.12.so                   [.] __strcmp_sse2
     0.00%         egrep  [kernel.kallsyms]              [k] page_add_new_anon_rmap
     0.00%          perf  [kernel.kallsyms]              [k] raise_softirq
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%          tail  [kernel.kallsyms]              [k] __queue_work
     0.00%           awk  [kernel.kallsyms]              [k] do_page_fault
     0.00%           app  [kernel.kallsyms]              [k] find_next_bit
     0.00%           app  [ext3]                         [k] ext3_ordered_write_end
     0.00%           app  libc-2.12.so                   [.] _itoa_word
     0.00%          date  [kernel.kallsyms]              [k] strncpy_from_user
     0.00%   flush-253:8  [kernel.kallsyms]              [k] radix_tree_tag_set
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] __list_add
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] find_first_bit
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           top  [kernel.kallsyms]              [k] proc_pid_statm
     0.00%           app  [kernel.kallsyms]              [k] __list_add
     0.00%          date  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%          perf  [kernel.kallsyms]              [k] __generic_file_aio_write
     0.00%          perf  [kernel.kallsyms]              [k] should_remove_suid
     0.00%           app  app                            [.] 
     0.00%          date  [kernel.kallsyms]              [k] __perf_event__output_id_sample
     0.00%           app  [kernel.kallsyms]              [k] move_addr_to_kernel
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] _cond_resched
     0.00%       swapper  [kernel.kallsyms]              [k] internal_add_timer
     0.00%            sh  [kernel.kallsyms]              [k] find_next_bit
     0.00%           app  [ipv6]                         [k] addrconf_verify
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           top  [kernel.kallsyms]              [k] put_dec
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] schedule
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] smp_invalidate_interrupt
     0.00%       swapper  [kernel.kallsyms]              [k] zone_statistics
     0.00%       swapper  [kernel.kallsyms]              [k] insert_work
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __blk_recalc_rq_segments
     0.00%         egrep  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%           app  [kernel.kallsyms]              [k] link_path_walk
     0.00%           app  [kernel.kallsyms]              [k] transfer_objects
     0.00%            sh  bash                           [.] find_variable_internal
     0.00%            sh  libc-2.12.so                   [.] __strlen_sse2
     0.00%           app  [kernel.kallsyms]              [k] rcu_report_qs_rnp
     0.00%           app  [kernel.kallsyms]              [k] vm_normal_page
     0.00%      kthreadd  [kernel.kallsyms]              [k] leave_mm
     0.00%   kworker/1:1  [e1000e]                       [k] e1000e_get_laa_state_82571
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tty_chars_in_buffer
     0.00%          perf  [kernel.kallsyms]              [k] fget_light
     0.00%            sh  libc-2.12.so                   [.] __GI_strcpy
     0.00%            sh  [kernel.kallsyms]              [k] __list_del_entry
     0.00%          perf  [ext4]                         [k] ext4_ext_calc_metadata_amount
     0.00%           top  [kernel.kallsyms]              [k] system_call_after_swapgs
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] __switch_to
     0.00%           app  [kernel.kallsyms]              [k] do_msgrcv
     0.00%          perf  libc-2.12.so                   [.] __GI___poll
     0.00%           app  [kernel.kallsyms]              [k] inotify_handle_event
     0.00%           cut  [kernel.kallsyms]              [k] tty_paranoia_check
     0.00%           app  app                            [.] 
     0.00%          perf  [kernel.kallsyms]              [k] radix_tree_tag_set
     0.00%           awk  bash                           [.] 0x2f73e         
     0.00%        vmstat  [kernel.kallsyms]              [k] ktime_get
     0.00%          perf  [ext4]                         [k] ext4_map_blocks
     0.00%           top  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%          tail  [kernel.kallsyms]              [k] tty_wakeup
     0.00%          date  [kernel.kallsyms]              [k] page_remove_rmap
     0.00%           app  [kernel.kallsyms]              [k] clear_page
     0.00%       swapper  [kernel.kallsyms]              [k] x86_pmu_enable
     0.00%          date  [kernel.kallsyms]              [k] __list_add
     0.00%           top  libc-2.12.so                   [.] __strchrnul
     0.00%           awk  gawk                           [.] 0x6b28          
     0.00%      kthreadd  [kernel.kallsyms]              [k] enqueue_task
     0.00%          date  libc-2.12.so                   [.] __GI_strcpy
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] free_block
     0.00%            sh  [kernel.kallsyms]              [k] __vma_link_rb
     0.00%          perf  [kernel.kallsyms]              [k] __inc_zone_page_state
     0.00%         sleep  [kernel.kallsyms]              [k] do_page_fault
     0.00%           app  [kernel.kallsyms]              [k] __list_add
     0.00%   kworker/7:1  [e1000e]                       [k] e1000e_get_laa_state_82571
     0.00%           top  libc-2.12.so                   [.] __strrchr_sse2
     0.00%        vmstat  [kernel.kallsyms]              [k] radix_tree_lookup
     0.00%          tail  [kernel.kallsyms]              [k] blk_finish_plug
     0.00%       swapper  [kernel.kallsyms]              [k] add_disk_randomness
     0.00%          date  ld-2.12.so                     [.] _dl_map_object_deps
     0.00%          perf  [kernel.kallsyms]              [k] list_del
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%            sh  [kernel.kallsyms]              [k] vfsmount_lock_global_lock_online
     0.00%          perf  [kernel.kallsyms]              [k] rw_verify_area
     0.00%           top  [kernel.kallsyms]              [k] kmem_cache_alloc_node
     0.00%           app  [kernel.kallsyms]              [k] __sigqueue_alloc
     0.00%         egrep  [kernel.kallsyms]              [k] __inc_zone_state
     0.00%           app  libc-2.12.so                   [.] __strlen_sse2
     0.00%        vmstat  libc-2.12.so                   [.] _IO_vfscanf_internal
     0.00%    in.telnetd  [kernel.kallsyms]              [k] add_wait_queue
     0.00%           app  app                            [.] 
     0.00%           awk  [kernel.kallsyms]              [k] __list_add
     0.00%          perf  [kernel.kallsyms]              [k] balance_dirty_pages_ratelimited_nr
     0.00%   flush-253:7  [kernel.kallsyms]              [k] gart_map_sg
     0.00%          ntpd  ntpd                           [.] has_full_recv_buffer
     0.00%           app  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%           app  [kernel.kallsyms]              [k] radix_tree_tag_clear
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] worker_enter_idle
     0.00%          tail  [kernel.kallsyms]              [k] tty_write_unlock
     0.00%           top  libc-2.12.so                   [.] memcpy
     0.00%          date  libc-2.12.so                   [.] __tz_convert
     0.00%          perf  [kernel.kallsyms]              [k] fsnotify
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] memmove
     0.00%           app  [kernel.kallsyms]              [k] find_next_bit
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%            ps  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%           top  libc-2.12.so                   [.] _IO_file_sync_internal
     0.00%         sleep  [kernel.kallsyms]              [k] link_path_walk
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%          date  [kernel.kallsyms]              [k] unlink_anon_vmas
     0.00%           app  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] schedule
     0.00%           app  [kernel.kallsyms]              [k] ktime_get
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] __list_del_entry
     0.00%            ps  libc-2.12.so                   [.] __GI_fwrite
     0.00%         egrep  [kernel.kallsyms]              [k] __lru_cache_add
     0.00%            sh  [kernel.kallsyms]              [k] page_add_file_rmap
     0.00%           top  [kernel.kallsyms]              [k] fsnotify
     0.00%          ntpd  [kernel.kallsyms]              [k] do_select
     0.00%         fgrep  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%          date  [kernel.kallsyms]              [k] rb_insert_color
     0.00%          date  [kernel.kallsyms]              [k] mmap_region
     0.00%           awk  [kernel.kallsyms]              [k] prio_tree_insert
     0.00%           app  [kernel.kallsyms]              [k] do_timer
     0.00%           awk  [kernel.kallsyms]              [k] strnlen_user
     0.00%           app  [kernel.kallsyms]              [k] mod_timer
     0.00%           app  [kernel.kallsyms]              [k] device_not_available
     0.00%            ps  libproc-3.2.8.so               [.] 0x3d81          
     0.00%    in.telnetd  libc-2.12.so                   [.] __GI_select
     0.00%           app  [kernel.kallsyms]              [k] ktime_get
     0.00%          date  [kernel.kallsyms]              [k] sock_def_readable
     0.00%          perf  [kernel.kallsyms]              [k] release_pages
     0.00%           app  [kernel.kallsyms]              [k] __add_bdi_stat
     0.00%           top  [kernel.kallsyms]              [k] follow_managed
     0.00%           app  [kernel.kallsyms]              [k] __free_pages
     0.00%           top  [kernel.kallsyms]              [k] ktime_get
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%           top  [kernel.kallsyms]              [k] reschedule_interrupt
     0.00%          date  [kernel.kallsyms]              [k] handle_mm_fault
     0.00%           awk  [kernel.kallsyms]              [k] kmem_cache_alloc_trace
     0.00%           app  [kernel.kallsyms]              [k] memcpy
     0.00%           app  [kernel.kallsyms]              [k] __d_lookup
     0.00%         sleep  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           app  [kernel.kallsyms]              [k] key_put
     0.00%          date  [kernel.kallsyms]              [k] page_waitqueue
     0.00%     kjournald  [kernel.kallsyms]              [k] gart_map_page
     0.00%          date  [kernel.kallsyms]              [k] generic_getxattr
     0.00%           app  app                            [.] 
     0.00%            sh  [kernel.kallsyms]              [k] arch_dup_task_struct
     0.00%           app  libc-2.12.so                   [.] __GI_msgrcv
     0.00%           app  [kernel.kallsyms]              [k] note_interrupt
     0.00%    in.telnetd  [kernel.kallsyms]              [k] list_del
     0.00%           app  [kernel.kallsyms]              [k] vma_prio_tree_remove
     0.00%    in.telnetd  [kernel.kallsyms]              [k] start_flush_work
     0.00%         fgrep  [kernel.kallsyms]              [k] page_remove_rmap
     0.00%          date  [kernel.kallsyms]              [k] fput
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] schedule
     0.00%           app  [kernel.kallsyms]              [k] ret_from_intr
     0.00%          date  ld-2.12.so                     [.] _dl_check_map_versions
     0.00%          tail  [kernel.kallsyms]              [k] tty_write
     0.00%            sh  libc-2.12.so                   [.] __GI_fflush
     0.00%          date  [kernel.kallsyms]              [k] __switch_to
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] schedule
     0.00%        vmstat  libc-2.12.so                   [.] __GI_bsearch
     0.00%           app  [kernel.kallsyms]              [k] kfree_skb
     0.00%           ksh  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%            sh  libc-2.12.so                   [.] ptmalloc_unlock_all
     0.00%          date  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] _cond_resched
     0.00%    in.telnetd  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%           app  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%       swapper  [kernel.kallsyms]              [k] perf_pmu_enable
     0.00%           top  [kernel.kallsyms]              [k] d_lookup
     0.00%          tail  [kernel.kallsyms]              [k] vfs_fstat
     0.00%            sh  libc-2.12.so                   [.] _int_malloc
     0.00%           app  [kernel.kallsyms]              [k] skb_copy_datagram_from_iovec
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] process_one_work
     0.00%           app  [kernel.kallsyms]              [k] try_to_wake_up
     0.00%           awk  [kernel.kallsyms]              [k] perf_event_mmap
     0.00%           top  [kernel.kallsyms]              [k] sys_newstat
     0.00%      kthreadd  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%          perf  [kernel.kallsyms]              [k] _raw_read_lock
     0.00%         egrep  [kernel.kallsyms]              [k] set_task_cpu
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] free_pages_prepare
     0.00%           app  [kernel.kallsyms]              [k] timerqueue_add
     0.00%           app  libstdc++.so.6.0.13            [.] std::ctype<wchar_t>::_M_initialize_ctype()
     0.00%            sh  [kernel.kallsyms]              [k] __task_pid_nr_ns
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%          perf  [kernel.kallsyms]              [k] find_lock_page
     0.00%          tail  [kernel.kallsyms]              [k] list_del
     0.00%          date  [kernel.kallsyms]              [k] net_rx_action
     0.00%          perf  [kernel.kallsyms]              [k] perf_poll
     0.00%            sh  [kernel.kallsyms]              [k] __math_state_restore
     0.00%           app  app                            [.] 
     0.00%           top  [kernel.kallsyms]              [k] acl_permission_check
     0.00%        vmstat  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%        vmstat  libc-2.12.so                   [.] _IO_sputbackc
     0.00%           app  ld-2.12.so                     [.] memcpy
     0.00%           top  [kernel.kallsyms]              [k] groups_search
     0.00%           top  [kernel.kallsyms]              [k] packet_rcv
     0.00%          perf  [kernel.kallsyms]              [k] wake_up_bit
     0.00%           top  libc-2.12.so                   [.] __mpn_divrem
     0.00%           app  [kernel.kallsyms]              [k] perf_event_mmap
     0.00%      kthreadd  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%            sh  [kernel.kallsyms]              [k] put_dec_trunc
     0.00%           app  app                            [.] 
     0.00%         egrep  [kernel.kallsyms]              [k] __switch_to
     0.00%           app  ld-2.12.so                     [.] _dl_cache_libcmp
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] _cond_resched
     0.00%         egrep  [kernel.kallsyms]              [k] generic_pipe_buf_map
     0.00%   kworker/4:1  [e1000e]                       [k] e1000_watchdog_task
     0.00%         egrep  [kernel.kallsyms]              [k] __list_add
     0.00%           app  [kernel.kallsyms]              [k] tick_program_event
     0.00%            sh  [kernel.kallsyms]              [k] alloc_pid
     0.00%         sleep  sleep                          [.] 0xf6c           
     0.00%           top  [kernel.kallsyms]              [k] jiffies_to_clock_t
     0.00%  kworker/10:1  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%           awk  [kernel.kallsyms]              [k] find_vma
     0.00%          date  ld-2.12.so                     [.] strcmp
     0.00%           top  [kernel.kallsyms]              [k] irq_entries_start
     0.00%           app  [kernel.kallsyms]              [k] skb_push
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __phys_addr
     0.00%           top  [kernel.kallsyms]              [k] __fsnotify_parent
     0.00%         egrep  [kernel.kallsyms]              [k] __d_lookup_rcu
     0.00%           top  [kernel.kallsyms]              [k] mntget
     0.00%            sh  [kernel.kallsyms]              [k] ____pagevec_lru_add_fn
     0.00%          perf  [kernel.kallsyms]              [k] kfree
     0.00%           awk  gawk                           [.] yyparse
     0.00%          perf  [jbd2]                         [k] jbd2_journal_add_journal_head
     0.00%           app  [kernel.kallsyms]              [k] net_rx_action
     0.00%           app  libc-2.12.so                   [.] __GI_getenv
     0.00%           awk  [kernel.kallsyms]              [k] __do_fault
     0.00%           app  [kernel.kallsyms]              [k] __dec_zone_page_state
     0.00%           app  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%           app  [kernel.kallsyms]              [k] __find_get_block
     0.00%           top  [kernel.kallsyms]              [k] strncpy_from_user
     0.00%           app  [kernel.kallsyms]              [k] autoremove_wake_function
     0.00%           app  [kernel.kallsyms]              [k] __rcu_pending
     0.00%           app  [jbd]                          [k] journal_add_journal_head
     0.00%          date  [kernel.kallsyms]              [k] retint_swapgs
     0.00%       swapper  [kernel.kallsyms]              [k] __inc_zone_state
     0.00%  kworker/10:1  [e1000e]                       [k] e1000e_get_laa_state_82571
     0.00%           app  [kernel.kallsyms]              [k] __lru_cache_add
     0.00%    in.telnetd  [kernel.kallsyms]              [k] rw_verify_area
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] get_work_gcwq
     0.00%          date  [kernel.kallsyms]              [k] prio_tree_insert
     0.00%           app  [kernel.kallsyms]              [k] read_tsc
     0.00%      kthreadd  [kernel.kallsyms]              [k] free_block
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] process_one_work
     0.00%           app  bash                           [.] hash_search
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] process_one_work
     0.00%           awk  [kernel.kallsyms]              [k] page_waitqueue
     0.00%            sh  [kernel.kallsyms]              [k] __dequeue_signal
     0.00%           app  libstdc++.so.6.0.13            [.] std::ctype<char>::ctype(unsigned short const*, bool, unsigned long)
     0.00%            sh  [kernel.kallsyms]              [k] anon_vma_chain_link
     0.00%         egrep  [kernel.kallsyms]              [k] strncpy_from_user
     0.00%            sh  [kernel.kallsyms]              [k] cap_d_instantiate
     0.00%           awk  [kernel.kallsyms]              [k] handle_mm_fault
     0.00%           app  [kernel.kallsyms]              [k] wake_bit_function
     0.00%       swapper  [kernel.kallsyms]              [k] second_overflow
     0.00%          perf  [kernel.kallsyms]              [k] mark_buffer_dirty
     0.00%         egrep  [kernel.kallsyms]              [k] __d_lookup
     0.00%           app  [e1000e]                       [k] e1000_rx_checksum
     0.00%          date  libc-2.12.so                   [.] _int_free
     0.00%       swapper  [kernel.kallsyms]              [k] tcp_ack
     0.00%          perf  [kernel.kallsyms]              [k] __alloc_skb
     0.00%           app  [kernel.kallsyms]              [k] __bitmap_empty
     0.00%           app  libstdc++.so.6.0.13            [.] std::locale::_Impl::_M_install_facet(std::locale::id const*, std::locale::facet const*)
     0.00%           app  [kernel.kallsyms]              [k] __lock_page
     0.00%          perf  [ext4]                         [k] ext4_claim_free_blocks
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] get_pageblock_flags_group
     0.00%           top  [kernel.kallsyms]              [k] next_pidmap
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] __round_jiffies_relative
     0.00%   kworker/7:1  [e1000e]                       [k] e1000e_update_adaptive
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] transfer_objects
     0.00%          date  [kernel.kallsyms]              [k] up_read
     0.00%           app  [kernel.kallsyms]              [k] clear_page_c
     0.00%          date  [kernel.kallsyms]              [k] sys_dup3
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%           top  [kernel.kallsyms]              [k] get_vmalloc_info
     0.00%           app  [kernel.kallsyms]              [k] sch_direct_xmit
     0.00%           awk  [kernel.kallsyms]              [k] page_remove_rmap
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%          perf  [kernel.kallsyms]              [k] __wake_up
     0.00%         egrep  [kernel.kallsyms]              [k] napi_gro_receive
     0.00%            sh  libc-2.12.so                   [.] __GI___errno_location
     0.00%           top  libc-2.12.so                   [.] __GI_____strtoll_l_internal
     0.00%           top  [kernel.kallsyms]              [k] __delayacct_blkio_ticks
     0.00%           app  [kernel.kallsyms]              [k] rcu_start_gp
     0.00%           app  libc-2.12.so                   [.] _int_free
     0.00%      kthreadd  [kernel.kallsyms]              [k] __list_del_entry
     0.00%   kworker/0:1  [e1000e]                       [k] e1000e_get_laa_state_82571
     0.00%           app  [kernel.kallsyms]              [k] hrtimer_wakeup
     0.00%           app  [kernel.kallsyms]              [k] memcpy
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%           app  app                            [.] 
     0.00%           top  libc-2.12.so                   [.] __strlen_sse2
     0.00%           app  libstdc++.so.6.0.13            [.] std::ostreambuf_iterator<char, std::char_traits<char> > std::num_put<char, std::ostreambuf_iterator<char, std::char_traits<char> > >::_M_insert_float<double>(std::ostreambuf_iterator<char, std::char_traits<char> >, std::ios_base&, char, char, double) const
     0.00%           app  [e1000e]                       [k] e1000_intr_msi
     0.00%          date  [kernel.kallsyms]              [k] ktime_get
     0.00%           top  [kernel.kallsyms]              [k] seq_printf
     0.00%       swapper  [kernel.kallsyms]              [k] __zone_watermark_ok
     0.00%           app  [kernel.kallsyms]              [k] test_clear_page_writeback
     0.00%           app  libpthread-2.12.so             [.] __libc_write
     0.00%            sh  [kernel.kallsyms]              [k] sys_rt_sigaction
     0.00%      kthreadd  [kernel.kallsyms]              [k] internal_add_timer
     0.00%            sh  [kernel.kallsyms]              [k] __zone_watermark_ok
     0.00%      kthreadd  [kernel.kallsyms]              [k] worker_thread
     0.00%           app  [kernel.kallsyms]              [k] __alloc_skb
     0.00%           top  libc-2.12.so                   [.] ___sprintf_chk
     0.00%          perf  [kernel.kallsyms]              [k] generic_file_aio_write
     0.00%            sh  [kernel.kallsyms]              [k] unlink_anon_vmas
     0.00%          date  libc-2.12.so                   [.] __tzfile_read
     0.00%           top  [kernel.kallsyms]              [k] nsec_to_clock_t
     0.00%            sh  [kernel.kallsyms]              [k] kmem_getpages
     0.00%         egrep  [kernel.kallsyms]              [k] __dec_zone_page_state
     0.00%            ps  [kernel.kallsyms]              [k] task_nice
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] try_to_wake_up
     0.00%           app  [ext3]                         [k] ext3_write_begin
     0.00%       swapper  [kernel.kallsyms]              [k] get_nohz_timer_target
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] setup_new_exec
     0.00%          date  [kernel.kallsyms]              [k] free_pages_prepare
     0.00%           app  app                            [.] 
     0.00%        vmstat  [kernel.kallsyms]              [k] hrtimer_nanosleep
     0.00%           cut  [kernel.kallsyms]              [k] kthread_data
     0.00%       swapper  [kernel.kallsyms]              [k] lock_timer_base
     0.00%           app  [kernel.kallsyms]              [k] do_msgrcv
     0.00%           app  [kernel.kallsyms]              [k] clockevents_program_event
     0.00%           app  [kernel.kallsyms]              [k] gart_unmap_page
     0.00%           app  [kernel.kallsyms]              [k] PageHuge
     0.00%           app  [kernel.kallsyms]              [k] native_apic_mem_write
     0.00%           app  bash                           [.] close_fd_bitmap
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ostream<wchar_t, std::char_traits<wchar_t> >::flush()
     0.00%   flush-253:7  [kernel.kallsyms]              [k] write_cache_pages
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] need_to_create_worker
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] cfq_init_prio_data
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_alloc_trace
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  [kernel.kallsyms]              [k] do_last
     0.00%     kjournald  [jbd]                          [k] __journal_temp_unlink_buffer
     0.00%   flush-253:8  [kernel.kallsyms]              [k] _raw_read_unlock_irqrestore
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] __find_get_block
     0.00%           app  libc-2.12.so                   [.] hack_digit.15668
     0.00%          date  ld-2.12.so                     [.] _dl_catch_error
     0.00%          tail  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%          date  libc-2.12.so                   [.] __GI_mbrtowc
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] find_last_bit
     0.00%          perf  [ext4]                         [k] ext4_get_inode_flags
     0.00%           app  [kernel.kallsyms]              [k] __call_rcu
     0.00%     kjournald  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%            sh  [kernel.kallsyms]              [k] kmem_cache_alloc_node
     0.00%          tail  [kernel.kallsyms]              [k] __wake_up_common
     0.00%      kthreadd  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           awk  [kernel.kallsyms]              [k] page_add_file_rmap
     0.00%           app  [kernel.kallsyms]              [k] rb_erase
     0.00%           app  [kernel.kallsyms]              [k] free_pcppages_bulk
     0.00%        vmstat  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%          tail  [kernel.kallsyms]              [k] tty_write_lock
     0.00%            ps  [ext4]                         [k] ext4_check_acl
     0.00%           top  [kernel.kallsyms]              [k] sched_clock_local
     0.00%           app  libstdc++.so.6.0.13            [.] bool std::has_facet<std::ctype<char> >(std::locale const&)
     0.00%           app  [kernel.kallsyms]              [k] blk_finish_plug
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] internal_add_timer
     0.00%          date  ld-2.12.so                     [.] _dl_init
     0.00%           app  [kernel.kallsyms]              [k] retint_careful
     0.00%           top  [kernel.kallsyms]              [k] put_pid
     0.00%            ps  [kernel.kallsyms]              [k] __inc_zone_state
     0.00%          date  [kernel.kallsyms]              [k] policy_zonelist
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] dev_gro_receive
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] worker_enter_idle
     0.00%           top  libc-2.12.so                   [.] _IO_vsscanf
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] sched_clock_cpu
     0.00%    in.telnetd  [kernel.kallsyms]              [k] fput
     0.00%           app  [kernel.kallsyms]              [k] irq_entries_start
     0.00%           awk  gawk                           [.] assoc_lookup
     0.00%   flush-253:8  [kernel.kallsyms]              [k] test_set_page_writeback
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] find_next_bit
     0.00%           top  [kernel.kallsyms]              [k] dput
     0.00%           awk  ld-2.12.so                     [.] _dl_new_object
     0.00%           app  [kernel.kallsyms]              [k] set_task_cpu
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tcp_transmit_skb
     0.00%        vmstat  [kernel.kallsyms]              [k] arch_irq_stat_cpu
     0.00%           top  libc-2.12.so                   [.] __GI_strnlen
     0.00%           app  app                            [.] 
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] retint_swapgs
     0.00%          date  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           app  app                            [.] 
     0.00%   flush-253:7  [kernel.kallsyms]              [k] find_get_pages_tag
     0.00%           top  [kernel.kallsyms]              [k] __task_pid_nr_ns
     0.00%          perf  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%           cut  [kernel.kallsyms]              [k] __mark_inode_dirty
     0.00%          perf  [kernel.kallsyms]              [k] page_waitqueue
     0.00%           app  app                            [.] 
     0.00%        vmstat  [kernel.kallsyms]              [k] show_stat
     0.00%         egrep  [kernel.kallsyms]              [k] mntput
     0.00%           app  app                            [.] 
     0.00%           top  [kernel.kallsyms]              [k] __queue_work
     0.00%           top  libc-2.12.so                   [.] __mpn_extract_double
     0.00%          perf  [kernel.kallsyms]              [k] _cond_resched
     0.00%           top  [kernel.kallsyms]              [k] generic_fillattr
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%          perf  [kernel.kallsyms]              [k] up_read
     0.00%           app  [kernel.kallsyms]              [k] ip_check_mc_rcu
     0.00%          date  [kernel.kallsyms]              [k] get_empty_filp
     0.00%           app  [kernel.kallsyms]              [k] __kmalloc_node_track_caller
     0.00%           awk  [kernel.kallsyms]              [k] flush_itimer_signals
     0.00%           app  app                            [.] 
     0.00%           app  libc-2.12.so                   [.] __strncpy_sse2
     0.00%           app  [kernel.kallsyms]              [k] __rb_rotate_left
     0.00%       swapper  [kernel.kallsyms]              [k] net_tx_action
     0.00%          date  bash                           [.] sh_makepath
     0.00%           app  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%          date  [kernel.kallsyms]              [k] memcpy
     0.00%         sleep  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%           app  [kernel.kallsyms]              [k] system_call
     0.00%          tail  [kernel.kallsyms]              [k] inotify_read
     0.00%           cut  [kernel.kallsyms]              [k] touch_atime
     0.00%    in.telnetd  [kernel.kallsyms]              [k] cap_file_permission
     0.00%           awk  [kernel.kallsyms]              [k] rb_insert_color
     0.00%           app  [kernel.kallsyms]              [k] mntput_no_expire
     0.00%          date  [ext4]                         [k] ext4_follow_link
     0.00%          ntpd  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%          perf  [kernel.kallsyms]              [k] sock_def_readable
     0.00%           app  [kernel.kallsyms]              [k] path_get
     0.00%           app  [kernel.kallsyms]              [k] resched_closest_idle
     0.00%           app  app                            [.] 
     0.00%          perf  [kernel.kallsyms]              [k] alloc_buffer_head
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __find_get_block_slow
     0.00%           top  libc-2.12.so                   [.] __strcmp_sse2
     0.00%         sleep  [kernel.kallsyms]              [k] find_get_page
     0.00%           awk  ld-2.12.so                     [.] strcmp
     0.00%          perf  [kernel.kallsyms]              [k] __mod_zone_page_state
     0.00%           app  [kernel.kallsyms]              [k] flush_tlb_page
     0.00%            sh  [kernel.kallsyms]              [k] __inc_zone_state
     0.00%          tail  libc-2.12.so                   [.] _IO_new_file_write
     0.00%      kthreadd  [kernel.kallsyms]              [k] find_last_bit
     0.00%           top  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%          tail  [kernel.kallsyms]              [k] security_file_permission
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] vmstat_update
     0.00%           app  [kernel.kallsyms]              [k] error_swapgs
     0.00%         sleep  [kernel.kallsyms]              [k] release_pages
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] mod_timer
     0.00%          date  [kernel.kallsyms]              [k] __mod_zone_page_state
     0.00%         egrep  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] find_get_pages_tag
     0.00%         sleep  [kernel.kallsyms]              [k] perf_event_mmap
     0.00%           app  [kernel.kallsyms]              [k] eth_header_parse
     0.00%       swapper  [kernel.kallsyms]              [k] next_zones_zonelist
     0.00%           cut  libc-2.12.so                   [.] _IO_file_underflow_internal
     0.00%   flush-253:8  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%          date  [kernel.kallsyms]              [k] cap_file_alloc_security
     0.00%          date  [kernel.kallsyms]              [k] __phys_addr
     0.00%          date  ld-2.12.so                     [.] _dl_new_object
     0.00%           top  [kernel.kallsyms]              [k] retint_careful
     0.00%        vmstat  [kernel.kallsyms]              [k] memcpy
     0.00%           app  libc-2.12.so                   [.] _getopt_internal_r
     0.00%          date  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%         sleep  ld-2.12.so                     [.] strcmp
     0.00%          tail  [kernel.kallsyms]              [k] vfs_write
     0.00%           awk  [kernel.kallsyms]              [k] find_next_bit
     0.00%           ksh  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%   flush-253:8  [kernel.kallsyms]              [k] memcpy
     0.00%           top  [kernel.kallsyms]              [k] __follow_mount_rcu
     0.00%            ps  [kernel.kallsyms]              [k] follow_page
     0.00%          date  [kernel.kallsyms]              [k] mntput_no_expire
     0.00%   ksoftirqd/4  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%          perf  [kernel.kallsyms]              [k] recalc_bh_state
     0.00%           app  [kernel.kallsyms]              [k] __switch_to
     0.00%   flush-253:8  [kernel.kallsyms]              [k] blk_rq_map_sg
     0.00%          date  [kernel.kallsyms]              [k] ret_from_sys_call
     0.00%           app  [kernel.kallsyms]              [k] generic_getxattr
     0.00%           top  libc-2.12.so                   [.] hack_digit.15668
     0.00%           app  [kernel.kallsyms]              [k] do_page_fault
     0.00%            sh  [kernel.kallsyms]              [k] sigprocmask
     0.00%           app  [kernel.kallsyms]              [k] error_entry
     0.00%          ntpd  ntpd                           [.] get_full_recv_buffer
     0.00%   kworker/1:1  [e1000e]                       [k] e1000e_update_adaptive
     0.00%           app  [kernel.kallsyms]              [k] do_lookup
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] get_pageblock_flags_group
     0.00%           app  [mpt2sas]                      [k] _base_interrupt
     0.00%           app  app                            [.] 
     0.00%   flush-253:8  [dm_mod]                       [k] dm_get_live_table
     0.00%          tail  [kernel.kallsyms]              [k] wq_worker_waking_up
     0.00%           app  [kernel.kallsyms]              [k] invalidate_interrupt1
     0.00%           app  libc-2.12.so                   [.] __GI___libc_malloc
     0.00%           app  [kernel.kallsyms]              [k] blk_start_plug
     0.00%      kthreadd  [kernel.kallsyms]              [k] memmove
     0.00%            sh  [kernel.kallsyms]              [k] native_flush_tlb
     0.00%   flush-253:8  [kernel.kallsyms]              [k] dec_zone_page_state
     0.00%           app  app                            [.] 
     0.00%           app  libstdc++.so.6.0.13            [.] call_gmon_start
     0.00%         egrep  ld-2.12.so                     [.] __mprotect
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%            sh  libc-2.12.so                   [.] __cfree
     0.00%           app  libc-2.12.so                   [.] gettimeofday
     0.00%          date  [kernel.kallsyms]              [k] page_add_new_anon_rmap
     0.00%         sleep  [kernel.kallsyms]              [k] ip_rcv_finish
     0.00%           app  libc-2.12.so                   [.] __btowc
     0.00%           top  [kernel.kallsyms]              [k] __switch_to
     0.00%           app  ld-2.12.so                     [.] _dl_cache_libcmp
     0.00%         pkill  [kernel.kallsyms]              [k] zone_watermark_ok
     0.00%           app  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.00%   kworker/4:1  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] mod_timer
     0.00%            sh  [kernel.kallsyms]              [k] alloc_inode
     0.00%          date  libc-2.12.so                   [.] sysconf
     0.00%          tail  [kernel.kallsyms]              [k] sched_clock_local
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] __drain_alien_cache
     0.00%   flush-253:7  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  [kernel.kallsyms]              [k] error_exit
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] mod_timer
     0.00%           app  libstdc++.so.6.0.13            [.] operator delete(void*)@plt
     0.00%            ps  [kernel.kallsyms]              [k] generic_permission
     0.00%    in.telnetd  [kernel.kallsyms]              [k] ip_finish_output
     0.00%           app  [kernel.kallsyms]              [k] vm_normal_page
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] io_schedule
     0.00%           app  [kernel.kallsyms]              [k] native_read_msr_safe
     0.00%           app  [kernel.kallsyms]              [k] bictcp_cong_avoid
     0.00%           cut  [kernel.kallsyms]              [k] tty_write
     0.00%          date  [kernel.kallsyms]              [k] free_block
     0.00%          date  [kernel.kallsyms]              [k] path_lookupat
     0.00%          tail  [kernel.kallsyms]              [k] vfs_getattr
     0.00%          perf  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%           app  [kernel.kallsyms]              [k] sole_cpu_idle
     0.00%            ls  [kernel.kallsyms]              [k] do_page_fault
     0.00%         egrep  [kernel.kallsyms]              [k] do_sync_read
     0.00%          date  ld-2.12.so                     [.] _dl_cache_libcmp
     0.00%           app  libstdc++.so.6.0.13            [.] __cxxabiv1::__vmi_class_type_info::__do_dyncast(long, __cxxabiv1::__class_type_info::__sub_kind, __cxxabiv1::__class_type_info const*, void const*, __cxxabiv1::__class_type_info const*, void const*, __cxxabiv1::__class_type_info::__dyncast_result&) const
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] mod_timer
     0.00%           app  libc-2.12.so                   [.] __GI_alarm
     0.00%           app  [kernel.kallsyms]              [k] fsnotify_add_notify_event
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%         egrep  [kernel.kallsyms]              [k] get_pageblock_flags_group
     0.00%   kworker/u:2  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           app  [kernel.kallsyms]              [k] smp_apic_timer_interrupt
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] queue_delayed_work_on
     0.00%           awk  [kernel.kallsyms]              [k] do_lookup
     0.00%           top  [kernel.kallsyms]              [k] blk_start_plug
     0.00%          perf  [jbd2]                         [k] __jbd2_log_space_left
     0.00%           top  [kernel.kallsyms]              [k] security_file_permission
     0.00%           app  [kernel.kallsyms]              [k] __perf_event_header__init_id
     0.00%           top  [kernel.kallsyms]              [k] cp_new_stat
     0.00%      kthreadd  [kernel.kallsyms]              [k] disk_map_sector_rcu
     0.00%          perf  [ext4]                         [k] ext4_inode_table
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] __list_add
     0.00%           awk  [kernel.kallsyms]              [k] __inc_zone_state
     0.00%           ksh  [kernel.kallsyms]              [k] copy_process
     0.00%    in.telnetd  [kernel.kallsyms]              [k] copy_from_user
     0.00%           app  [kernel.kallsyms]              [k] unlock_page
     0.00%      kthreadd  [kernel.kallsyms]              [k] scsi_request_fn
     0.00%    in.telnetd  [kernel.kallsyms]              [k] vfs_write
     0.00%           app  [kernel.kallsyms]              [k] do_softirq
     0.00%           app  [kernel.kallsyms]              [k] split_vma
     0.00%     kjournald  [kernel.kallsyms]              [k] sched_clock_local
     0.00%           app  [kernel.kallsyms]              [k] force_qs_rnp
     0.00%         egrep  libc-2.12.so                   [.] fork
     0.00%           app  [kernel.kallsyms]              [k] __memset
     0.00%          date  [kernel.kallsyms]              [k] sys_dup2
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ios<char, std::char_traits<char> >::init(std::basic_streambuf<char, std::char_traits<char> >*)
     0.00%         egrep  [kernel.kallsyms]              [k] PageHuge
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%           awk  [kernel.kallsyms]              [k] unlock_page
     0.00%          date  [kernel.kallsyms]              [k] eth_type_trans
     0.00%      kthreadd  [kernel.kallsyms]              [k] try_to_wake_up
     0.00%         sleep  libc-2.12.so                   [.] _getopt_internal_r
     0.00%          tail  [kernel.kallsyms]              [k] cap_file_permission
     0.00%            sh  [kernel.kallsyms]              [k] __bitmap_and
     0.00%           awk  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%           app  [ext3]                         [k] ext3_xattr_get
     0.00%           top  [kernel.kallsyms]              [k] wq_worker_waking_up
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ostream<char, std::char_traits<char> >::flush()
     0.00%    in.telnetd  [kernel.kallsyms]              [k] poll_freewait
     0.00%          tail  [kernel.kallsyms]              [k] blk_start_plug
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ostringstream<char, std::char_traits<char>, std::allocator<char> >::~basic_ostringstream()
     0.00%           top  [kernel.kallsyms]              [k] rcu_start_gp
     0.00%          perf  [kernel.kallsyms]              [k] ____pagevec_lru_add_fn
     0.00%           app  [kernel.kallsyms]              [k] __rmqueue
     0.00%           app  [kernel.kallsyms]              [k] __dec_zone_state
     0.00%         sleep  [kernel.kallsyms]              [k] memcpy
     0.00%           app  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%          tail  [kernel.kallsyms]              [k] system_call
     0.00%           top  [kernel.kallsyms]              [k] ip_rcv
     0.00%         sleep  [kernel.kallsyms]              [k] unlink_anon_vmas
     0.00%           app  [kernel.kallsyms]              [k] handle_irq
     0.00%           app  [kernel.kallsyms]              [k] flush_tlb_page
     0.00%          perf  [ext4]                         [k] __ext4_handle_dirty_metadata
     0.00%         egrep  [kernel.kallsyms]              [k] mntput_no_expire
     0.00%            sh  libc-2.12.so                   [.] __GI__dl_addr
     0.00%           app  [kernel.kallsyms]              [k] do_IRQ
     0.00%           app  [kernel.kallsyms]              [k] tcp_v4_rcv
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%          perf  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%          date  [kernel.kallsyms]              [k] __skb_clone
     0.00%         fgrep  [kernel.kallsyms]              [k] __do_fault
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] unlock_page
     0.00%           app  [kernel.kallsyms]              [k] __put_anon_vma
     0.00%           app  ld-2.12.so                     [.] _dl_map_object
     0.00%           top  libc-2.12.so                   [.] __GI___libc_malloc
     0.00%          tail  [kernel.kallsyms]              [k] queue_work
     0.00%         sleep  [kernel.kallsyms]              [k] __do_fault
     0.00%           app  ld-2.12.so                     [.] process_envvars
     0.00%           awk  [kernel.kallsyms]              [k] vma_merge
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] sched_clock_local
     0.00%            sh  [kernel.kallsyms]              [k] sys_close
     0.00%           top  [kernel.kallsyms]              [k] cap_file_alloc_security
     0.00%         sleep  libc-2.12.so                   [.] __GI_getenv
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] mutex_lock
     0.00%  kworker/10:1  [e1000e]                       [k] e1000_clean_tx_irq
     0.00%           app  [kernel.kallsyms]              [k] sys_sendto
     0.00%           app  [kernel.kallsyms]              [k] unlink_anon_vmas
     0.00%           top  [kernel.kallsyms]              [k] nsecs_to_jiffies
     0.00%           ksh  libresolv-2.12.so              [.] __libc_res_nsend
     0.00%           top  [kernel.kallsyms]              [k] __lock_task_sighand
     0.00%    in.telnetd  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%            sh  bash                           [.] stupidly_hack_special_variables
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] __percpu_counter_add
     0.00%           cut  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           app  [ext4]                         [k] ext4_end_bio
     0.00%           app  [e1000e]                       [k] e1000_update_itr
     0.00%    in.telnetd  [kernel.kallsyms]              [k] zero_fd_set
     0.00%         sleep  [kernel.kallsyms]              [k] mntput
     0.00%       swapper  [kernel.kallsyms]              [k] csd_unlock
     0.00%        pickup  libc-2.12.so                   [.] __GI___libc_write
     0.00%          grep  grep                           [.] 0x134d5         
     0.00%           awk  [kernel.kallsyms]              [k] hrtimer_interrupt
     0.00%            sh  [kernel.kallsyms]              [k] perf_output_begin
     0.00%           app  [ext3]                         [k] journal_dirty_data_fn
     0.00%           top  [kernel.kallsyms]              [k] mutex_unlock
     0.00%    in.telnetd  [kernel.kallsyms]              [k] sk_stream_alloc_skb
     0.00%          date  [kernel.kallsyms]              [k] sysret_check
     0.00%           app  [kernel.kallsyms]              [k] __memset
     0.00%           app  [kernel.kallsyms]              [k] n_tty_write
     0.00%           app  [kernel.kallsyms]              [k] __tcp_v4_send_check
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] __phys_addr
     0.00%            sh  bash                           [.] hash_create
     0.00%        vmstat  libc-2.12.so                   [.] __nanosleep_nocancel
     0.00%        vmstat  [kernel.kallsyms]              [k] string
     0.00%           app  [kernel.kallsyms]              [k] scheduler_tick
     0.00%          date  [kernel.kallsyms]              [k] dequeue_task
     0.00%          date  [kernel.kallsyms]              [k] do_mmap_pgoff
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] reschedule_interrupt
     0.00%          tail  [kernel.kallsyms]              [k] schedule
     0.00%           app  [kernel.kallsyms]              [k] irq_enter
     0.00%           app  [kernel.kallsyms]              [k] resched_best_mask
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] __wake_up_common
     0.00%           app  [kernel.kallsyms]              [k] fsnotify_put_event
     0.00%            sh  [kernel.kallsyms]              [k] copy_page_range
     0.00%           app  [kernel.kallsyms].vsyscall_fn  [.] vread_tsc
     0.00%        vmstat  [kernel.kallsyms]              [k] strnlen
     0.00%          perf  [kernel.kallsyms]              [k] set_task_cpu
     0.00%           app  libc-2.12.so                   [.] __offtime
     0.00%          date  [kernel.kallsyms]              [k] do_filp_open
     0.00%          date  [kernel.kallsyms]              [k] proc_exec_connector
     0.00%          date  [kernel.kallsyms]              [k] __dec_zone_state
     0.00%            ps  [kernel.kallsyms]              [k] pid_getattr
     0.00%         egrep  [kernel.kallsyms]              [k] load_elf_binary
     0.00%          date  [kernel.kallsyms]              [k] read_tsc
     0.00%           app  ld-2.12.so                     [.] index
     0.00%          perf  [ext4]                         [k] ext4_file_write
     0.00%           app  [kernel.kallsyms]              [k] current_kernel_time
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           app  [kernel.kallsyms]              [k] ____pagevec_lru_add_fn
     0.00%          perf  [kernel.kallsyms]              [k] skb_gro_reset_offset
     0.00%         sleep  [kernel.kallsyms]              [k] retint_swapgs
     0.00%           app  [kernel.kallsyms]              [k] sysret_check
     0.00%   jbd2/dm-8-8  [jbd2]                         [k] jbd2_journal_put_journal_head
     0.00%           app  [kernel.kallsyms]              [k] sock_def_write_space
     0.00%           awk  ld-2.12.so                     [.] _dl_debug_initialize
     0.00%           app  libc-2.12.so                   [.] __strlen_sse2
     0.00%           app  [kernel.kallsyms]              [k] fsnotify
     0.00%          perf  [kernel.kallsyms]              [k] security_inode_need_killpriv
     0.00%         egrep  [kernel.kallsyms]              [k] link_path_walk
     0.00%            sh  [kernel.kallsyms]              [k] memcpy
     0.00%            sh  [kernel.kallsyms]              [k] perf_event_task
     0.00%        vmstat  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%   flush-253:8  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%           top  [kernel.kallsyms]              [k] in_sched_functions
     0.00%           app  [kernel.kallsyms]              [k] skb_release_head_state
     0.00%           top  [kernel.kallsyms]              [k] path_get
     0.00%            ps  [kernel.kallsyms]              [k] follow_managed
     0.00%           top  [kernel.kallsyms]              [k] do_select
     0.00%           app  [kernel.kallsyms]              [k] sock_def_readable
     0.00%           app  [kernel.kallsyms]              [k] page_waitqueue
     0.00%          ntpd  [kernel.kallsyms]              [k] fpu_finit
     0.00%           app  [kernel.kallsyms]              [k] enqueue_task
     0.00%            ps  [kernel.kallsyms]              [k] security_inode_exec_permission
     0.00%          date  [kernel.kallsyms]              [k] reschedule_interrupt
     0.00%           app  [kernel.kallsyms]              [k] smp_invalidate_interrupt
     0.00%           app  [kernel.kallsyms]              [k] __netif_receive_skb
     0.00%         egrep  [kernel.kallsyms]              [k] tty_mode_ioctl
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] mod_timer
     0.00%          date  libc-2.12.so                   [.] _getopt_internal_r
     0.00%     kjournald  [jbd]                          [k] __journal_file_buffer
     0.00%       swapper  [kernel.kallsyms]              [k] dyntick_save_progress_counter
     0.00%           app  [kernel.kallsyms]              [k] skb_release_data
     0.00%           awk  bash                           [.] extract_colon_unit
     0.00%      kthreadd  [kernel.kallsyms]              [k] wq_worker_sleeping
     0.00%         sleep  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%     kjournald  [dm_mod]                       [k] __split_and_process_bio
     0.00%          perf  perf                           [.] perf_header__has_feat
     0.00%           app  [kernel.kallsyms]              [k] __rb_rotate_right
     0.00%          ntpd  [kernel.kallsyms]              [k] __clear_user
     0.00%          date  libc-2.12.so                   [.] _IO_file_xsgetn
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] resched_task
     0.00%           app  [kernel.kallsyms]              [k] resched_task
     0.00%           app  [kernel.kallsyms]              [k] rcu_note_context_switch
     0.00%            ps  libc-2.12.so                   [.] __strchr_sse2
     0.00%   flush-253:7  [kernel.kallsyms]              [k] find_next_bit
     0.00%            sh  bash                           [.] sh_closepipe
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           ksh  [kernel.kallsyms]              [k] tty_write
     0.00%            ps  [kernel.kallsyms]              [k] hrtimer_interrupt
     0.00%          ntpd  libc-2.12.so                   [.] __GI_select
     0.00%   jbd2/dm-8-8  [ext4]                         [k] __check_block_validity.clone.0
     0.00%           top  [kernel.kallsyms]              [k] security_dentry_open
     0.00%           app  ld-2.12.so                     [.] check_match.12450
     0.00%    in.telnetd  [kernel.kallsyms]              [k] pc_user_time
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%            sh  [kernel.kallsyms]              [k] vm_normal_page
     0.00%         sleep  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           app  [kernel.kallsyms]              [k] revert_creds
     0.00%          date  [kernel.kallsyms]              [k] rb_erase
     0.00%            sh  libc-2.12.so                   [.] __GI___libc_realloc
     0.00%            sh  [kernel.kallsyms]              [k] _copy_from_user
     0.00%         sleep  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%           app  [kernel.kallsyms]              [k] retint_careful
     0.00%        vmstat  libc-2.12.so                   [.] sleep
     0.00%         sleep  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%           app  [kernel.kallsyms]              [k] schedule
     0.00%         egrep  [kernel.kallsyms]              [k] sha_transform
     0.00%           app  ld-2.12.so                     [.] dl_main
     0.00%    in.telnetd  [kernel.kallsyms]              [k] mod_timer
     0.00%   ksoftirqd/5  [kernel.kallsyms]              [k] hrtimer_forward
     0.00%           app  [kernel.kallsyms]              [k] __block_write_begin
     0.00%           app  [kernel.kallsyms]              [k] system_call_after_swapgs
     0.00%           app  [kernel.kallsyms]              [k] do_mmap_pgoff
     0.00%            sh  libc-2.12.so                   [.] __GI_sigemptyset
     0.00%            ls  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%           awk  [kernel.kallsyms]              [k] arch_vma_name
     0.00%            sh  [kernel.kallsyms]              [k] snprintf
     0.00%         egrep  [kernel.kallsyms]              [k] vfs_read
     0.00%         pkill  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%          tail  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%           top  [kernel.kallsyms]              [k] remove_wait_queue
     0.00%            sh  [kernel.kallsyms]              [k] __phys_addr
     0.00%           cut  [kernel.kallsyms]              [k] add_wait_queue
     0.00%          date  [kernel.kallsyms]              [k] find_next_bit
     0.00%   kworker/1:1  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%           ksh  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  [kernel.kallsyms]              [k] page_add_file_rmap
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] process_one_work
     0.00%           app  libc-2.12.so                   [.] getpagesize
     0.00%         :3735  [kernel.kallsyms]              [k] schedule
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __fsnotify_parent
     0.00%           app  [kernel.kallsyms]              [k] lock_hrtimer_base
     0.00%          perf  [kernel.kallsyms]              [k] pagevec_lru_move_fn
     0.00%      kthreadd  [kernel.kallsyms]              [k] __switch_to
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%          date  [kernel.kallsyms]              [k] list_del
     0.00%          ntpd  [kernel.kallsyms]              [k] list_del
     0.00%            sh  [kernel.kallsyms]              [k] find_get_page
     0.00%           top  [kernel.kallsyms]              [k] __dentry_open
     0.00%           app  bash                           [.] builtin_address_internal
     0.00%            sh  [kernel.kallsyms]              [k] __lru_cache_add
     0.00%           top  [kernel.kallsyms]              [k] filldir
     0.00%            sh  [kernel.kallsyms]              [k] enqueue_task
     0.00%           app  ld-2.12.so                     [.] __strsep
     0.00%    in.telnetd  [kernel.kallsyms]              [k] set_fd_set
     0.00%         egrep  [kernel.kallsyms]              [k] perf_pmu_enable
     0.00%       swapper  [kernel.kallsyms]              [k] prepare_signal.clone.1
     0.00%           awk  gawk                           [.] main
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __tcp_select_window
     0.00%       swapper  [kernel.kallsyms]              [k] dev_kfree_skb_any
     0.00%         pkill  [kernel.kallsyms]              [k] page_fault
     0.00%           app  [sd_mod]                       [k] sd_done
     0.00%           app  [kernel.kallsyms]              [k] unlink_anon_vmas
     0.00%          perf  [kernel.kallsyms]              [k] internal_add_timer
     0.00%            sh  [kernel.kallsyms]              [k] pipe_read
     0.00%           app  libc-2.12.so                   [.] _IO_default_xsputn_internal
     0.00%           top  [kernel.kallsyms]              [k] gart_map_page
     0.00%       swapper  [mpt2sas]                      [k] mpt2sas_base_get_reply_virt_addr
     0.00%           app  [kernel.kallsyms]              [k] skb_release_data
     0.00%     kjournald  [kernel.kallsyms]              [k] find_next_bit
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tty_paranoia_check
     0.00%         egrep  [kernel.kallsyms]              [k] handle_mm_fault
     0.00%          perf  [kernel.kallsyms]              [k] zone_watermark_ok
     0.00%           app  [kernel.kallsyms]              [k] page_fault
     0.00%            ps  libc-2.12.so                   [.] _IO_sputbackc
     0.00%          perf  [kernel.kallsyms]              [k] mutex_unlock
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] cwq_dec_nr_in_flight
     0.00%          perf  [kernel.kallsyms]              [k] down_read
     0.00%          perf  [kernel.kallsyms]              [k] remove_wait_queue
     0.00%         egrep  libc-2.12.so                   [.] __memchr
     0.00%    in.telnetd  [kernel.kallsyms]              [k] fsnotify
     0.00%          date  [kernel.kallsyms]              [k] math_state_restore
     0.00%           app  [kernel.kallsyms]              [k] __getblk
     0.00%           top  [kernel.kallsyms]              [k] security_inode_exec_permission
     0.00%           app  [kernel.kallsyms]              [k] schedule
     0.00%          ntpd  ntpd                           [.] input_handler
     0.00%           awk  libc-2.12.so                   [.] _IO_old_init
     0.00%       swapper  [e1000e]                       [k] e1000_xmit_frame
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] memcpy
     0.00%           app  [kernel.kallsyms]              [k] rcu_irq_enter
     0.00%            sh  [kernel.kallsyms]              [k] get_pageblock_flags_group
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tty_hung_up_p
     0.00%       swapper  [kernel.kallsyms]              [k] prop_norm_percpu
     0.00%         egrep  [kernel.kallsyms]              [k] page_waitqueue
     0.00%           app  [kernel.kallsyms]              [k] perf_event_task_tick
     0.00%   kworker/u:2  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%          tail  [kernel.kallsyms]              [k] touch_atime
     0.00%         egrep  [kernel.kallsyms]              [k] up_read
     0.00%         pkill  [kernel.kallsyms]              [k] proc_pid_status
     0.00%           app  bash                           [.] copy_word_list
     0.00%    in.telnetd  [kernel.kallsyms]              [k] security_file_permission
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] blk_queue_bounce
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] __bitmap_and
     0.00%           app  [kernel.kallsyms]              [k] pci_read
     0.00%           app  libc-2.12.so                   [.] _int_free
     0.00%            ps  [kernel.kallsyms]              [k] kmem_cache_alloc_node_trace
     0.00%           app  libstdc++.so.6.0.13            [.] (anonymous namespace)::get_locale_mutex()
     0.00%            ps  [kernel.kallsyms]              [k] link_path_walk
     0.00%           app  [kernel.kallsyms]              [k] error_entry
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] process_one_work
     0.00%        vmstat  [kernel.kallsyms]              [k] enqueue_task
     0.00%           top  [kernel.kallsyms]              [k] getname
     0.00%          date  bash                           [.] mbschr
     0.00%      kthreadd  [kernel.kallsyms]              [k] schedule
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __list_add
     0.00%            ls  [kernel.kallsyms]              [k] set_task_cpu
     0.00%         fgrep  bash                           [.] builtin_address_internal
     0.00%         egrep  ld-2.12.so                     [.] strcmp
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] schedule
     0.00%         egrep  [kernel.kallsyms]              [k] enqueue_task
     0.00%           app  app                            [.] 
     0.00%            sh  [kernel.kallsyms]              [k] flush_sigqueue
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%           app  [kernel.kallsyms]              [k] dev_gro_receive
     0.00%    in.telnetd  [kernel.kallsyms]              [k] n_tty_poll
     0.00%           awk  [kernel.kallsyms]              [k] error_exit
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] gart_map_page
     0.00%            sh  bash                           [.] unwind_protect_mem
     0.00%           app  [kernel.kallsyms]              [k] __remove_shared_vm_struct
     0.00%          date  [kernel.kallsyms]              [k] up_write
     0.00%           awk  [kernel.kallsyms]              [k] clear_user
     0.00%           app  [ext4]                         [k] ext4_check_acl
     0.00%          date  [kernel.kallsyms]              [k] do_futex
     0.00%          date  [kernel.kallsyms]              [k] __do_softirq
     0.00%           app  app                            [.] 
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] queue_delayed_work_on
     0.00%           top  [kernel.kallsyms]              [k] __kmalloc_node_track_caller
     0.00%       swapper  [kernel.kallsyms]              [k] scsi_next_command
     0.00%       swapper  [kernel.kallsyms]              [k] __blk_put_request
     0.00%           app  [kernel.kallsyms]              [k] __scsi_put_command
     0.00%           app  [kernel.kallsyms]              [k] add_timer_on
     0.00%         sleep  [kernel.kallsyms]              [k] kfree
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] pc_user_time
     0.00%           app  ld-2.12.so                     [.] _dl_check_map_versions
     0.00%           top  [ext4]                         [k] ext4_check_acl
     0.00%            sh  [kernel.kallsyms]              [k] net_rx_action
     0.00%           app  [kernel.kallsyms]              [k] path_lookupat
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] __round_jiffies_relative
     0.00%            sh  [kernel.kallsyms]              [k] __wake_up_bit
     0.00%           awk  [kernel.kallsyms]              [k] path_put
     0.00%          date  [kernel.kallsyms]              [k] rcu_start_gp
     0.00%         fgrep  [kernel.kallsyms]              [k] page_fault
     0.00%           top  [kernel.kallsyms]              [k] vfs_fstatat
     0.00%      kthreadd  [kernel.kallsyms]              [k] flush_to_ldisc
     0.00%           app  [kernel.kallsyms]              [k] complete_signal
     0.00%          date  [kernel.kallsyms]              [k] _copy_to_user
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           ksh  [kernel.kallsyms]              [k] __vm_enough_memory
     0.00%           top  [kernel.kallsyms]              [k] ima_match_policy
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] pc_user_time
     0.00%           app  [kernel.kallsyms]              [k] resched_task
     0.00%            sh  bash                           [.] wait_for
     0.00%          date  [kernel.kallsyms]              [k] sys_close
     0.00%          perf  [jbd2]                         [k] jbd2_journal_cancel_revoke
     0.00%          perf  [kernel.kallsyms]              [k] cap_file_permission
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%          ntpd  [kernel.kallsyms]              [k] zone_watermark_ok
     0.00%            sh  [kernel.kallsyms]              [k] copy_fs_struct
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] transfer_objects
     0.00%           top  [kernel.kallsyms]              [k] do_last
     0.00%           app  [kernel.kallsyms]              [k] __kmalloc_node_track_caller
     0.00%           app  [kernel.kallsyms]              [k] find_next_zero_bit
     0.00%           app  app                            [.] 
     0.00%         egrep  [kernel.kallsyms]              [k] scsi_finish_command
     0.00%          date  libc-2.12.so                   [.] ptmalloc_unlock_all2
     0.00%         egrep  [kernel.kallsyms]              [k] __phys_addr
     0.00%          perf  [kernel.kallsyms]              [k] unlock_page
     0.00%     kjournald  [kernel.kallsyms]              [k] blk_rq_init
     0.00%       swapper  [kernel.kallsyms]              [k] __cfq_slice_expired
     0.00%          tail  [kernel.kallsyms]              [k] file_read_actor
     0.00%           top  libc-2.12.so                   [.] __GI___strtoull_internal
     0.00%          date  [kernel.kallsyms]              [k] next_zones_zonelist
     0.00%          tail  [kernel.kallsyms]              [k] sys_read
     0.00%         :3786  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%         egrep  [kernel.kallsyms]              [k] strlcpy
     0.00%    in.telnetd  [kernel.kallsyms]              [k] wait_for_common
     0.00%         egrep  [kernel.kallsyms]              [k] page_remove_rmap
     0.00%          perf  [kernel.kallsyms]              [k] block_write_end
     0.00%           app  ld-2.12.so                     [.] _dl_relocate_object
     0.00%     kjournald  [kernel.kallsyms]              [k] part_round_stats
     0.00%         sleep  libc-2.12.so                   [.] __GI___sbrk
     0.00%           app  libstdc++.so.6.0.13            [.] std::locale::~locale()@plt
     0.00%           app  [kernel.kallsyms]              [k] __memset
     0.00%           top  [kernel.kallsyms]              [k] __wake_up_common
     0.00%       swapper  [ipv6]                         [k] fib6_walk_continue
     0.00%       swapper  [kernel.kallsyms]              [k] gart_unmap_sg
     0.00%         egrep  libc-2.12.so                   [.] __GI_exit
     0.00%           top  [kernel.kallsyms]              [k] dequeue_task
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] __round_jiffies_relative
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] __round_jiffies_relative
     0.00%           app  [kernel.kallsyms]              [k] locks_remove_posix
     0.00%           app  [kernel.kallsyms]              [k] sys_alarm
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] ktime_get
     0.00%           app  [kernel.kallsyms]              [k] mmap_region
     0.00%          date  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%         egrep  libc-2.12.so                   [.] __ctype_get_mb_cur_max
     0.00%        vmstat  [kernel.kallsyms]              [k] mutex_unlock
     0.00%        master  [kernel.kallsyms]              [k] cap_cred_prepare
     0.00%         egrep  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%           app  [kernel.kallsyms]              [k] find_next_bit
     0.00%          date  [kernel.kallsyms]              [k] locks_remove_posix
     0.00%           top  libc-2.12.so                   [.] _IO_old_init
     0.00%          tail  [kernel.kallsyms]              [k] try_preempt
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*)
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_string<char, std::char_traits<char>, std::allocator<char> >::reserve(unsigned long)
     0.00%      kthreadd  [kernel.kallsyms]              [k] __phys_addr
     0.00%          date  libc-2.12.so                   [.] _nl_postload_ctype
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.00%           awk  [kernel.kallsyms]              [k] release_pages
     0.00%           awk  [kernel.kallsyms]              [k] call_rcu_sched
     0.00%           app  [kernel.kallsyms]              [k] prio_tree_remove
     0.00%           top  [kernel.kallsyms]              [k] __list_del_entry
     0.00%    in.telnetd  [kernel.kallsyms]              [k] kmem_cache_alloc_node_trace
     0.00%         :3583  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%          date  [kernel.kallsyms]              [k] get_vma_policy
     0.00%           app  [kernel.kallsyms]              [k] bit_waitqueue
     0.00%    in.telnetd  [kernel.kallsyms]              [k] _raw_spin_lock_bh
     0.00%       swapper  [kernel.kallsyms]              [k] pci_bus_read_config_word
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_stringbuf<char, std::char_traits<char>, std::allocator<char> >::overflow(int)
     0.00%           top  [kernel.kallsyms]              [k] sys_getdents
     0.00%          ntpd  ntpd                           [.] poll_update
     0.00%           app  [kernel.kallsyms]              [k] prio_tree_replace
     0.00%            sh  [kernel.kallsyms]              [k] ktime_get
     0.00%        vmstat  [kernel.kallsyms]              [k] fsnotify
     0.00%     kjournald  [kernel.kallsyms]              [k] __elv_add_request
     0.00%           app  ld-2.12.so                     [.] _dl_fini
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] sched_clock_local
     0.00%           app  libpthread-2.12.so             [.] 0xe4b1          
     0.00%           awk  [kernel.kallsyms]              [k] __do_softirq
     0.00%            ps  [kernel.kallsyms]              [k] __memset
     0.00%            sh  bash                           [.] fpurge
     0.00%   flush-253:8  [jbd2]                         [k] jbd2_journal_dirty_metadata
     0.00%           app  [ext3]                         [k] ext3_mark_iloc_dirty
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] resched_task
     0.00%           ksh  [kernel.kallsyms]              [k] mutex_lock_interruptible
     0.00%          date  [e1000e]                       [k] e1000_intr_msi
     0.00%           top  libc-2.12.so                   [.] strtoull
     0.00%           app  [kernel.kallsyms]              [k] tick_sched_timer
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __elv_add_request
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] internal_add_timer
     0.00%            ps  [kernel.kallsyms]              [k] proc_pid_readdir
     0.00%           ksh  [kernel.kallsyms]              [k] generic_file_aio_read
     0.00%            sh  [kernel.kallsyms]              [k] handle_mm_fault
     0.00%           app  [kernel.kallsyms]              [k] ptep_set_access_flags
     0.00%         egrep  [kernel.kallsyms]              [k] __queue_work
     0.00%           app  [kernel.kallsyms]              [k] idle_cpu
     0.00%           app  [kernel.kallsyms]              [k] __napi_complete
     0.00%          perf  [kernel.kallsyms]              [k] get_rps_cpu
     0.00%         sleep  [e1000e]                       [k] e1000_intr_msi
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] kmem_freepages
     0.00%          ntpd  [e1000e]                       [k] e1000_xmit_frame
     0.00%   flush-253:8  [ext4]                         [k] cleanup_module
     0.00%           app  [kernel.kallsyms]              [k] fget_light
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] irq_exit
     0.00%           app  libstdc++.so.6.0.13            [.] putc@plt
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] cfq_merge
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] need_to_create_worker
     0.00%           app  [kernel.kallsyms]              [k] error_entry
     0.00%           ksh  [kernel.kallsyms]              [k] perf_event_task_output
     0.00%           app  [kernel.kallsyms]              [k] ttwu_activate
     0.00%         sleep  libc-2.12.so                   [.] _int_free
     0.00%            ps  [kernel.kallsyms]              [k] put_dec_trunc
     0.00%           app  [kernel.kallsyms]              [k] file_read_actor
     0.00%           app  [ext3]                         [k] ext3_get_inode_flags
     0.00%           ksh  [kernel.kallsyms]              [k] d_set_d_op
     0.00%            sh  bash                           [.] unlink_fifo_list
     0.00%          perf  [e1000e]                       [k] e1000_update_itr
     0.00%           awk  gawk                           [.] set_RS
     0.00%        vmstat  vmstat                         [.] 0x11d0          
     0.00%           app  libstdc++.so.6.0.13            [.] global constructors keyed to bitmap_allocator.cc
     0.00%           top  [kernel.kallsyms]              [k] vfsmount_lock_local_lock
     0.00%           app  [kernel.kallsyms]              [k] file_free_rcu
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] __wake_up
     0.00%            sh  [kernel.kallsyms]              [k] format_decode
     0.00%           awk  [kernel.kallsyms]              [k] __d_free
     0.00%         sleep  [kernel.kallsyms]              [k] get_empty_filp
     0.00%    in.telnetd  [kernel.kallsyms]              [k] wake_up_process
     0.00%           app  libc-2.12.so                   [.] _IO_str_init_static_internal
     0.00%            sh  [kernel.kallsyms]              [k] retint_careful
     0.00%           app  [kernel.kallsyms]              [k] __task_pid_nr_ns
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] lock_timer_base
     0.00%         pkill  [kernel.kallsyms]              [k] vscnprintf
     0.00%           app  [kernel.kallsyms]              [k] skb_put
     0.00%          ntpd  [kernel.kallsyms]              [k] int_check_syscall_exit_work
     0.00%           top  [kernel.kallsyms]              [k] locks_release_private
     0.00%          tail  [kernel.kallsyms]              [k] path_put
     0.00%    in.telnetd  [kernel.kallsyms]              [k] get_work_gcwq
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] down_read
     0.00%           app  [kernel.kallsyms]              [k] sys_mmap_pgoff
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] __add_bdi_stat
     0.00%           top  [kernel.kallsyms]              [k] handle_irq
     0.00%           app  libc-2.12.so                   [.] _IO_padn_internal
     0.00%           top  [kernel.kallsyms]              [k] proc_fill_cache
     0.00%       swapper  [kernel.kallsyms]              [k] part_round_stats
     0.00%           app  [kernel.kallsyms]              [k] flush_tlb_mm
     0.00%           app  [kernel.kallsyms]              [k] get_io_context
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] cfq_service_tree_add
     0.00%           app  [kernel.kallsyms]              [k] reschedule_interrupt
     0.00%          perf  [ext4]                         [k] ext4_dirty_inode
     0.00%  ksoftirqd/11  [kernel.kallsyms]              [k] read_tsc
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] rpm_resume
     0.00%           top  [kernel.kallsyms]              [k] getnstimeofday
     0.00%          tail  [kernel.kallsyms]              [k] memcpy
     0.00%          date  libc-2.12.so                   [.] __strcmp_sse2
     0.00%           app  [kernel.kallsyms]              [k] list_del
     0.00%         :3913  [kernel.kallsyms]              [k] resched_task
     0.00%           app  [kernel.kallsyms]              [k] blk_flush_plug_list
     0.00%          tail  [kernel.kallsyms]              [k] enqueue_task
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] move_linked_works
     0.00%          date  [kernel.kallsyms]              [k] in_group_p
     0.00%          date  [kernel.kallsyms]              [k] arch_align_stack
     0.00%   flush-253:8  [kernel.kallsyms]              [k] elv_rq_merge_ok
     0.00%           app  app                            [.] 
     0.00%           top  libc-2.12.so                   [.] _int_malloc
     0.00%            ps  [kernel.kallsyms]              [k] do_lookup
     0.00%           app  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%         :3815  [kernel.kallsyms]              [k] native_load_tls
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           app  libstdc++.so.6.0.13            [.] bool std::has_facet<std::num_put<char, std::ostreambuf_iterator<char, std::char_traits<char> > > >(std::locale const&)@plt
     0.00%           app  [e1000e]                       [k] e1000_clean
     0.00%           app  [ext3]                         [k] ext3_get_group_desc
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] get_work_gcwq
     0.00%            sh  [kernel.kallsyms]              [k] kref_put
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)
     0.00%         sleep  [kernel.kallsyms]              [k] free_hot_cold_page
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] transfer_objects
     0.00%           app  libgcc_s.so.1                  [.] _Unwind_IteratePhdrCallback
     0.00%           app  libc-2.12.so                   [.] __strchr_sse2
     0.00%    in.telnetd  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%          date  [kernel.kallsyms]              [k] do_prlimit
     0.00%           top  [kernel.kallsyms]              [k] sys_close
     0.00%            ps  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%   flush-253:7  [kernel.kallsyms]              [k] del_timer_sync
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] sched_clock_cpu
     0.00%   flush-253:8  [kernel.kallsyms]              [k] skb_put
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] resched_task
     0.00%           app  [kernel.kallsyms]              [k] get_futex_key
     0.00%           top  [kernel.kallsyms]              [k] rcu_process_callbacks
     0.00%           app  [kernel.kallsyms]              [k] lru_add_drain
     0.00%           app  [kernel.kallsyms]              [k] second_overflow
     0.00%           top  [kernel.kallsyms]              [k] proc_root_readdir
     0.00%          ntpd  [kernel.kallsyms]              [k] set_fd_set
     0.00%           awk  [kernel.kallsyms]              [k] retint_restore_args
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] handle_edge_irq
     0.00%           top  [kernel.kallsyms]              [k] path_put
     0.00%    in.telnetd  [kernel.kallsyms]              [k] sys_select
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] leave_mm
     0.00%           awk  [kernel.kallsyms]              [k] free_hot_cold_page
     0.00%           top  [kernel.kallsyms]              [k] tty_paranoia_check
     0.00%         egrep  [kernel.kallsyms]              [k] unlock_page
     0.00%          date  [kernel.kallsyms]              [k] mark_page_accessed
     0.00%    in.telnetd  [kernel.kallsyms]              [k] gart_mapping_error
     0.00%           awk  [kernel.kallsyms]              [k] kmem_cache_alloc_node_trace
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] mod_timer
     0.00%            sh  [kernel.kallsyms]              [k] rb_insert_color
     0.00%           app  bash                           [.] sh_closepipe
     0.00%         sleep  [kernel.kallsyms]              [k] __cond_resched
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] next_online_pgdat
     0.00%        xinetd  [kernel.kallsyms]              [k] copy_page_c
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] mutex_unlock
     0.00%           top  [kernel.kallsyms]              [k] d_rehash
     0.00%           ksh  [kernel.kallsyms]              [k] wake_up_new_task
     0.00%         sleep  [kernel.kallsyms]              [k] half_md4_transform
     0.00%           top  [kernel.kallsyms]              [k] proc_single_show
     0.00%         egrep  [kernel.kallsyms]              [k] acl_permission_check
     0.00%           top  libtinfo.so.5.7                [.] tparm
     0.00%          date  [kernel.kallsyms]              [k] __get_user_8
     0.00%           app  [kernel.kallsyms]              [k] __list_add
     0.00%      kthreadd  [kernel.kallsyms]              [k] cwq_dec_nr_in_flight
     0.00%         egrep  libc-2.12.so                   [.] __bindtextdomain
     0.00%          date  [kernel.kallsyms]              [k] ip_rcv_finish
     0.00%   flush-253:8  [kernel.kallsyms]              [k] mark_page_accessed
     0.00%           top  [kernel.kallsyms]              [k] security_inode_getattr
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] set_task_cpu
     0.00%        vmstat  [kernel.kallsyms]              [k] __phys_addr
     0.00%           top  [kernel.kallsyms]              [k] single_next
     0.00%       swapper  [kernel.kallsyms]              [k] dev_hard_start_xmit
     0.00%           app  [ext3]                         [k] __ext3_journal_dirty_metadata
     0.00%          date  [kernel.kallsyms]              [k] dec_zone_page_state
     0.00%            sh  [kernel.kallsyms]              [k] detach_pid
     0.00%           app  ld-2.12.so                     [.] _dl_map_object_deps
     0.00%          perf  [kernel.kallsyms]              [k] activate_page
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] getnstimeofday
     0.00%           app  [kernel.kallsyms]              [k] tcp_event_new_data_sent
     0.00%         sleep  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%            ps  [kernel.kallsyms]              [k] schedule
     0.00%           app  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%           app  [kernel.kallsyms]              [k] alternate_node_alloc
     0.00%            sh  [kernel.kallsyms]              [k] error_exit
     0.00%         sleep  [kernel.kallsyms]              [k] pgd_alloc
     0.00%        vmstat  [kernel.kallsyms]              [k] sock_def_readable
     0.00%            sh  [kernel.kallsyms]              [k] vfs_fstatat
     0.00%   flush-253:8  [kernel.kallsyms]              [k] activate_task
     0.00%           app  [kernel.kallsyms]              [k] recalc_bh_state
     0.00%    in.telnetd  [kernel.kallsyms]              [k] flush_work
     0.00%           app  [kernel.kallsyms]              [k] radix_tree_preload
     0.00%           awk  [kernel.kallsyms]              [k] path_openat
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] memmove
     0.00%   flush-253:8  [kernel.kallsyms]              [k] get_request
     0.00%         egrep  [kernel.kallsyms]              [k] ktime_get
     0.00%           app  [kernel.kallsyms]              [k] do_setitimer
     0.00%           app  [kernel.kallsyms]              [k] rb_insert_color
     0.00%       swapper  [kernel.kallsyms]              [k] blk_flush_complete_seq
     0.00%         egrep  [kernel.kallsyms]              [k] mprotect_fixup
     0.00%           app  ld-2.12.so                     [.] __mprotect
     0.00%           cut  [kernel.kallsyms]              [k] __srcu_read_unlock
     0.00%         :3911  [kernel.kallsyms]              [k] activate_task
     0.00%          date  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%          tail  [kernel.kallsyms]              [k] fsnotify_put_event
     0.00%   kworker/7:1  [e1000e]                       [k] e1000_receive_skb
     0.00%   flush-253:8  [kernel.kallsyms]              [k] submit_bh
     0.00%           top  [kernel.kallsyms]              [k] get_work_gcwq
     0.00%           awk  [kernel.kallsyms]              [k] napi_gro_receive
     0.00%           app  ld-2.12.so                     [.] memcpy
     0.00%           awk  libc-2.12.so                   [.] _IO_default_xsputn_internal
     0.00%     kjournald  [jbd]                          [k] journal_clean_one_cp_list
     0.00%           app  [kernel.kallsyms]              [k] find_vma_prev
     0.00%       swapper  [kernel.kallsyms]              [k] mempool_free
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __wake_up_common
     0.00%   ksoftirqd/2  [kernel.kallsyms]              [k] find_next_bit
     0.00%           app  [kernel.kallsyms]              [k] ip_finish_output
     0.00%          grep  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%          perf  [e1000e]                       [k] e1000_clean
     0.00%          date  [kernel.kallsyms]              [k] xfer_secondary_pool
     0.00%           app  [kernel.kallsyms]              [k] handle_irq_event_percpu
     0.00%          date  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%           app  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%           top  [kernel.kallsyms]              [k] printk_tick
     0.00%   flush-253:7  [kernel.kallsyms]              [k] __wake_up_bit
     0.00%           awk  [kernel.kallsyms]              [k] mark_page_accessed
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __memset
     0.00%          date  [kernel.kallsyms]              [k] do_device_not_available
     0.00%         egrep  bash                           [.] list_reverse
     0.00%          date  libc-2.12.so                   [.] __GI_sigemptyset
     0.00%           app  [kernel.kallsyms]              [k] __bitmap_empty
     0.00%           app  [kernel.kallsyms]              [k] native_load_sp0
     0.00%           awk  gawk                           [.] close_io
     0.00%           awk  gawk                           [.] install
     0.00%            sh  libc-2.12.so                   [.] __GI_____strtoll_l_internal
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] move_linked_works
     0.00%          ntpd  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%            ps  [kernel.kallsyms]              [k] find_next_bit
     0.00%          date  [kernel.kallsyms]              [k] ima_file_mmap
     0.00%            sh  bash                           [.] fmtumax
     0.00%         egrep  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%           app  [kernel.kallsyms]              [k] napi_complete
     0.00%         egrep  [kernel.kallsyms]              [k] __rcu_pending
     0.00%           app  [kernel.kallsyms]              [k] tcp_transmit_skb
     0.00%           app  [kernel.kallsyms]              [k] run_posix_cpu_timers
     0.00%           app  [kernel.kallsyms]              [k] unlock_page
     0.00%           awk  [kernel.kallsyms]              [k] cap_cred_prepare
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] __pm_runtime_resume
     0.00%           app  librt-2.12.so                  [.] __cxa_finalize@plt
     0.00%            sh  [kernel.kallsyms]              [k] touch_atime
     0.00%         sleep  [kernel.kallsyms]              [k] free_pages_prepare
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] refresh_cpu_vm_stats
     0.00%           app  [kernel.kallsyms]              [k] do_last
     0.00%           app  libc-2.12.so                   [.] _IO_old_init
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] find_next_bit
     0.00%        pickup  [kernel.kallsyms]              [k] __fsnotify_parent
     0.00%         egrep  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           top  [kernel.kallsyms]              [k] cap_inode_permission
     0.00%            sh  [kernel.kallsyms]              [k] new_inode
     0.00%          ntpd  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __netif_receive_skb
     0.00%      kthreadd  [kernel.kallsyms]              [k] need_to_create_worker
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] __next_cpu
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%           app  [kernel.kallsyms]              [k] tcp_validate_incoming
     0.00%          date  ld-2.12.so                     [.] access
     0.00%           app  [kernel.kallsyms]              [k] exit_mmap
     0.00%           top  [kernel.kallsyms]              [k] inode_permission
     0.00%           awk  [kernel.kallsyms]              [k] perf_event_mmap_ctx
     0.00%          ntpd  [kernel.kallsyms]              [k] dequeue_signal
     0.00%   flush-253:8  [sd_mod]                       [k] sd_prep_fn
     0.00%            sh  bash                           [.] make_bare_word
     0.00%          date  ld-2.12.so                     [.] index
     0.00%           app  [kernel.kallsyms]              [k] kfree
     0.00%           top  [kernel.kallsyms]              [k] cap_dentry_open
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] _cond_resched
     0.00%           app  [kernel.kallsyms]              [k] rb_erase
     0.00%          tail  [kernel.kallsyms]              [k] mntput
     0.00%           app  ld-2.12.so                     [.] _dl_next_tls_modid
     0.00%           awk  [kernel.kallsyms]              [k] path_lookupat
     0.00%            sh  [kernel.kallsyms]              [k] packet_rcv
     0.00%       swapper  [kernel.kallsyms]              [k] tcp_event_data_recv
     0.00%         pkill  [kernel.kallsyms]              [k] __bio_add_page
     0.00%           app  [ext3]                         [k] ext3_xattr_security_get
     0.00%           app  [kernel.kallsyms]              [k] __remove_hrtimer
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%         egrep  [kernel.kallsyms]              [k] copy_termios
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.00%           app  [kernel.kallsyms]              [k] ns_to_timeval
     0.00%          date  [kernel.kallsyms]              [k] security_file_alloc
     0.00%           awk  [kernel.kallsyms]              [k] free_fs_struct
     0.00%           app  [dm_mod]                       [k] clone_endio
     0.00%           app  app                            [.] 
     0.00%       swapper  [kernel.kallsyms]              [k] free_thread_xstate
     0.00%    in.telnetd  [kernel.kallsyms]              [k] skb_split
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] out_of_line_wait_on_bit
     0.00%          grep  [kernel.kallsyms]              [k] PageHuge
     0.00%           app  [kernel.kallsyms]              [k] ip_route_input_common
     0.00%         egrep  [kernel.kallsyms]              [k] perf_event_mmap_ctx
     0.00%            sh  libc-2.12.so                   [.] _IO_list_lock
     0.00%           app  [kernel.kallsyms]              [k] nameidata_to_filp
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] kmem_freepages
     0.00%   flush-253:8  [kernel.kallsyms]              [k] pagevec_lookup_tag
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] native_write_msr_safe
     0.00%           app  [kernel.kallsyms]              [k] activate_task
     0.00%          date  libc-2.12.so                   [.] _IO_default_xsputn_internal
     0.00%           app  [kernel.kallsyms]              [k] gart_mapping_error
     0.00%          date  [kernel.kallsyms]              [k] error_sti
     0.00%        vmstat  libc-2.12.so                   [.] _IO_file_xsputn_internal
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.00%           app  libstdc++.so.6.0.13            [.] std::ios_base::_M_init()@plt
     0.00%           app  [kernel.kallsyms]              [k] __napi_schedule
     0.00%        pickup  [kernel.kallsyms]              [k] ep_send_events_proc
     0.00%   jbd2/dm-8-8  [jbd2]                         [k] jbd2_journal_write_revoke_records
     0.00%           awk  [kernel.kallsyms]              [k] irq_complete_move
     0.00%            sh  libc-2.12.so                   [.] __GI_memset
     0.00%           app  ld-2.12.so                     [.] _dl_load_cache_lookup
     0.00%           app  libstdc++.so.6.0.13            [.] operator new(unsigned long)
     0.00%           app  [kernel.kallsyms]              [k] default_send_IPI_mask_sequence_phys
     0.00%          perf  [kernel.kallsyms]              [k] read_tsc
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] sock_def_readable
     0.00%       swapper  [kernel.kallsyms]              [k] check_kill_permission
     0.00%         :3329  [kernel.kallsyms]              [k] zone_watermark_ok
     0.00%           app  libc-2.12.so                   [.] __newlocale
     0.00%           awk  [kernel.kallsyms]              [k] filp_close
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] put_ldisc
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] __round_jiffies_relative
     0.00%          tail  [kernel.kallsyms]              [k] dev_gro_receive
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] free_pcppages_bulk
     0.00%       swapper  [kernel.kallsyms]              [k] tcp_v4_do_rcv
     0.00%         pkill  [kernel.kallsyms]              [k] dput
     0.00%         :3982  [kernel.kallsyms]              [k] child_wait_callback
     0.00%         egrep  [kernel.kallsyms]              [k] tty_hung_up_p
     0.00%          date  libc-2.12.so                   [.] fread_unlocked
     0.00%           app  [kernel.kallsyms]              [k] fput
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] interleave_nodes
     0.00%           top  [kernel.kallsyms]              [k] find_ge_pid
     0.00%          date  [kernel.kallsyms]              [k] mprotect_fixup
     0.00%        vmstat  [kernel.kallsyms]              [k] smp_invalidate_interrupt
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] scheduler_tick
     0.00%           top  [kernel.kallsyms]              [k] proc_single_open
     0.00%          date  [e1000e]                       [k] e1000_receive_skb
     0.00%          date  [kernel.kallsyms]              [k] arch_get_unmapped_area_topdown
     0.00%           top  [kernel.kallsyms]              [k] file_sb_list_del
     0.00%           app  libstdc++.so.6.0.13            [.] std::locale::locale()
     0.00%           app  [kernel.kallsyms]              [k] inet_gro_receive
     0.00%            sh  [kernel.kallsyms]              [k] resched_task
     0.00%          tail  [kernel.kallsyms]              [k] tty_flip_buffer_push
     0.00%           app  [kernel.kallsyms]              [k] __local_bh_enable
     0.00%           top  [kernel.kallsyms]              [k] math_state_restore
     0.00%           app  [ext3]                         [k] ext3_release_file
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%         egrep  [kernel.kallsyms]              [k] rb_insert_color
     0.00%            sh  [kernel.kallsyms]              [k] vsnprintf
     0.00%           ksh  [kernel.kallsyms]              [k] n_tty_set_termios
     0.00%           app  [kernel.kallsyms]              [k] set_task_cpu
     0.00%         sleep  [kernel.kallsyms]              [k] sys_newfstat
     0.00%          date  [kernel.kallsyms]              [k] do_last
     0.00%          grep  [kernel.kallsyms]              [k] filemap_fault
     0.00%           app  [kernel.kallsyms]              [k] blk_flush_plug_list
     0.00%          tail  [kernel.kallsyms]              [k] fsnotify
     0.00%           app  [kernel.kallsyms]              [k] dma_issue_pending_all
     0.00%          date  [kernel.kallsyms]              [k] groups_search
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] resched_best_mask
     0.00%          grep  [kernel.kallsyms]              [k] ip_rcv
     0.00%         :3796  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%   ksoftirqd/5  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%   flush-253:8  [kernel.kallsyms]              [k] part_round_stats
     0.00%           app  app                            [.] 
     0.00%           top  [kernel.kallsyms]              [k] jiffies_to_timeval
     0.00%           app  [kernel.kallsyms]              [k] get_mm_counter
     0.00%   ksoftirqd/7  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%         :3635  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           top  [kernel.kallsyms]              [k] sock_def_readable
     0.00%           app  [kernel.kallsyms]              [k] packet_rcv
     0.00%            sh  libc-2.12.so                   [.] __restore_rt
     0.00%           app  [kernel.kallsyms]              [k] free_thread_xstate
     0.00%     kjournald  [kernel.kallsyms]              [k] generic_make_request
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] net_rx_action
     0.00%           awk  [kernel.kallsyms]              [k] dequeue_task
     0.00%     kjournald  [kernel.kallsyms]              [k] blk_add_timer
     0.00%         sleep  [kernel.kallsyms]              [k] hrtimer_nanosleep
     0.00%           app  [kernel.kallsyms]              [k] account
     0.00%            sh  [kernel.kallsyms]              [k] thread_group_cputime
     0.00%           awk  [kernel.kallsyms]              [k] __put_anon_vma
     0.00%          date  [kernel.kallsyms]              [k] flush_tlb_page
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] __bitmap_and
     0.00%           top  libc-2.12.so                   [.] __GI_time
     0.00%           app  libc-2.12.so                   [.] __GI___libc_write
     0.00%         egrep  [kernel.kallsyms]              [k] system_call
     0.00%          date  [kernel.kallsyms]              [k] mutex_lock
     0.00%           awk  [kernel.kallsyms]              [k] rcu_report_qs_rnp
     0.00%           app  app                            [.] 
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] add_timer
     0.00%          perf  [kernel.kallsyms]              [k] ip_rcv
     0.00%         egrep  libc-2.12.so                   [.] __GI_getenv
     0.00%         egrep  libc-2.12.so                   [.] 0x81aa0         
     0.00%          date  [kernel.kallsyms]              [k] sys_geteuid
     0.00%          tail  [kernel.kallsyms]              [k] kmem_cache_alloc_node_trace
     0.00%           top  [kernel.kallsyms]              [k] __bitmap_empty
     0.00%          date  bash                           [.] parse_and_execute
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] free_block
     0.00%          perf  libpthread-2.12.so             [.] __write_nocancel
     0.00%           app  [kernel.kallsyms]              [k] sched_clock_local
     0.00%          date  [kernel.kallsyms]              [k] alloc_pages_current
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] try_preempt
     0.00%          perf  [kernel.kallsyms]              [k] account_page_dirtied
     0.00%           app  app                            [.] 
     0.00%          tail  [kernel.kallsyms]              [k] cap_inode_getattr
     0.00%           awk  [kernel.kallsyms]              [k] __rmqueue
     0.00%           top  [kernel.kallsyms]              [k] call_rcu_sched
     0.00%          tail  [kernel.kallsyms]              [k] tty_paranoia_check
     0.00%          perf  [kernel.kallsyms]              [k] iov_iter_fault_in_readable
     0.00%           app  libstdc++.so.6.0.13            [.] __cxxabiv1::__vmi_class_type_info::__do_dyncast(long, __cxxabiv1::__class_type_info::__sub_kind, __cxxabiv1::__class_type_info const*, void const*, __cxxabiv1::__class_type_info const*, void const*, __cxxabiv1::__class_type_info::__dyncast_result&) const
     0.00%           app  [kernel.kallsyms]              [k] __mod_zone_page_state
     0.00%    in.telnetd  [kernel.kallsyms]              [k] lock_timer_base
     0.00%           app  [kernel.kallsyms]              [k] down_read_trylock
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] next_online_pgdat
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] __bitmap_empty
     0.00%          date  [kernel.kallsyms]              [k] cap_file_mmap
     0.00%           app  [kernel.kallsyms]              [k] d_path
     0.00%           app  [kernel.kallsyms]              [k] next_zones_zonelist
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] tty_ldisc_try
     0.00%    in.telnetd  [kernel.kallsyms]              [k] local_bh_enable_ip
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] n_tty_receive_buf
     0.00%           app  [kernel.kallsyms]              [k] padzero
     0.00%          perf  [kernel.kallsyms]              [k] sysret_check
     0.00%           top  [kernel.kallsyms]              [k] single_release
     0.00%            sh  [kernel.kallsyms]              [k] sock_def_readable
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] dequeue_task
     0.00%           app  [kernel.kallsyms]              [k] fsnotify
     0.00%           top  [kernel.kallsyms]              [k] get_task_comm
     0.00%         sleep  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%           app  [kernel.kallsyms]              [k] fsnotify
     0.00%           app  [kernel.kallsyms]              [k] __d_lookup_rcu
     0.00%           awk  libc-2.12.so                   [.] _int_free
     0.00%         sleep  [kernel.kallsyms]              [k] task_tgid_nr_ns
     0.00%         egrep  ld-2.12.so                     [.] _dl_map_object_from_fd
     0.00%    in.telnetd  [kernel.kallsyms]              [k] ip_output
     0.00%          date  [kernel.kallsyms]              [k] rcu_irq_exit
     0.00%         egrep  [kernel.kallsyms]              [k] pc_user_time
     0.00%        vmstat  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%    in.telnetd  [kernel.kallsyms]              [k] ip_local_out
     0.00%       swapper  [ipv6]                         [k] fib6_age
     0.00%           app  [kernel.kallsyms]              [k] block_write_end
     0.00%           app  [kernel.kallsyms]              [k] mix_pool_bytes_extract
     0.00%   kworker/5:1  [kernel.kallsyms]              [k] __bitmap_and
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] default_send_IPI_mask_sequence_phys
     0.00%            ls  ld-2.12.so                     [.] mempcpy
     0.00%           app  [kernel.kallsyms]              [k] load_misc_binary
     0.00%            ps  [kernel.kallsyms]              [k] tid_fd_revalidate
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] smp_reschedule_interrupt
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] need_to_create_worker
     0.00%            sh  [kernel.kallsyms]              [k] profile_munmap
     0.00%           awk  [kernel.kallsyms]              [k] fget
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] find_first_bit
     0.00%           app  [kernel.kallsyms]              [k] cap_file_permission
     0.00%          perf  [kernel.kallsyms]              [k] skb_put
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_stringbuf<char, std::char_traits<char>, std::allocator<char> >::_M_sync(char*, unsigned long, unsigned long)
     0.00%           app  [kernel.kallsyms]              [k] tty_wakeup
     0.00%           top  [kernel.kallsyms]              [k] __phys_addr
     0.00%         sleep  [kernel.kallsyms]              [k] __split_vma
     0.00%           awk  [kernel.kallsyms]              [k] __memset
     0.00%          perf  [kernel.kallsyms]              [k] memcpy
     0.00%         egrep  [kernel.kallsyms]              [k] get_unmapped_area
     0.00%           app  [kernel.kallsyms]              [k] prepare_signal.clone.1
     0.00%         egrep  ld-2.12.so                     [.] _dl_map_object_deps
     0.00%          perf  [kernel.kallsyms]              [k] net_rx_action
     0.00%           awk  bash                           [.] close_fd_bitmap
     0.00%            sh  [kernel.kallsyms]              [k] do_sigaction
     0.00%           app  [kernel.kallsyms]              [k] sched_clock_local
     0.00%          perf  [jbd2]                         [k] __jbd2_journal_temp_unlink_buffer
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] schedule
     0.00%           app  [kernel.kallsyms]              [k] mprotect_fixup
     0.00%           app  [kernel.kallsyms]              [k] vfs_write
     0.00%           awk  [kernel.kallsyms]              [k] __d_lookup_rcu
     0.00%           app  [kernel.kallsyms]              [k] follow_page
     0.00%           top  [kernel.kallsyms]              [k] _copy_to_user
     0.00%           app  [kernel.kallsyms]              [k] cp_new_stat
     0.00%    in.telnetd  [kernel.kallsyms]              [k] mutex_lock
     0.00%         egrep  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%         sleep  ld-2.12.so                     [.] strlen
     0.00%          tail  [kernel.kallsyms]              [k] _cond_resched
     0.00%    in.telnetd  [e1000e]                       [k] e1000_intr_msi
     0.00%           app  [kernel.kallsyms]              [k] perf_event_mmap_ctx
     0.00%           ksh  [kernel.kallsyms]              [k] vm_normal_page
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] worker_thread
     0.00%           app  libstdc++.so.6.0.13            [.] std::ios_base::_M_init()
     0.00%           app  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%         :3296  [kernel.kallsyms]              [k] perf_event_task
     0.00%         sleep  [kernel.kallsyms]              [k] mprotect_fixup
     0.00%    in.telnetd  [kernel.kallsyms]              [k] schedule_timeout
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] __list_add
     0.00%   jbd2/dm-8-8  [mpt2sas]                      [k] _scsih_qcmd
     0.00%           app  [kernel.kallsyms]              [k] gart_unmap_page
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] n_tty_set_room
     0.00%            sh  libc-2.12.so                   [.] __GI_close
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%           app  [kernel.kallsyms]              [k] net_rx_action
     0.00%       swapper  [kernel.kallsyms]              [k] tcp_v4_send_check
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] worker_thread
     0.00%    in.telnetd  [kernel.kallsyms]              [k] next_zones_zonelist
     0.00%          perf  [ext4]                         [k] ext4_init_mballoc
     0.00%           app  [kernel.kallsyms]              [k] ip_rcv
     0.00%           app  [jbd]                          [k] journal_stop
     0.00%            ps  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%          perf  [kernel.kallsyms]              [k] inode_add_rsv_space
     0.00%            sh  bash                           [.] find_variable
     0.00%           awk  [kernel.kallsyms]              [k] policy_zonelist
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] __free_pages
     0.00%           top  [kernel.kallsyms]              [k] irq_enter
     0.00%           app  libc-2.12.so                   [.] _int_malloc
     0.00%    in.telnetd  [kernel.kallsyms]              [k] memcpy
     0.00%           top  [kernel.kallsyms]              [k] enqueue_task
     0.00%           app  ld-2.12.so                     [.] _dl_sysdep_start
     0.00%           app  [kernel.kallsyms]              [k] file_remove_suid
     0.00%           app  [kernel.kallsyms]              [k] native_set_pte_at
     0.00%          perf  [kernel.kallsyms]              [k] add_to_page_cache_locked
     0.00%           app  [jbd]                          [k] journal_start
     0.00%            sh  [kernel.kallsyms]              [k] native_set_pte_at
     0.00%           app  [kernel.kallsyms]              [k] unlink_anon_vmas
     0.00%         :4080  [kernel.kallsyms]              [k] __group_send_sig_info
     0.00%           app  app                            [.] 
     0.00%   kworker/u:2  [kernel.kallsyms]              [k] round_jiffies_relative
     0.00%           awk  [kernel.kallsyms]              [k] __fsnotify_parent
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] sched_clock_local
     0.00%     kjournald  [kernel.kallsyms]              [k] transfer_objects
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __napi_schedule
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] dma_issue_pending_all
     0.00%           app  [kernel.kallsyms]              [k] __brelse
     0.00%          date  [kernel.kallsyms]              [k] sha_init
     0.00%           app  [kernel.kallsyms]              [k] sys_getuid
     0.00%           app  [kernel.kallsyms]              [k] __bitmap_and
     0.00%          tail  [kernel.kallsyms]              [k] insert_work
     0.00%           app  [kernel.kallsyms]              [k] tcp_write_timer
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] dma_issue_pending_all
     0.00%            sh  bash                           [.] stop_pipeline
     0.00%          ntpd  [kernel.kallsyms]              [k] schedule_hrtimeout_range
     0.00%      modprobe  [kernel.kallsyms]              [k] radix_tree_lookup
     0.00%            sh  [kernel.kallsyms]              [k] __d_instantiate
     0.00%     kjournald  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] resched_best_mask
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __kmalloc_node_track_caller
     0.00%           app  [kernel.kallsyms]              [k] irq_entries_start
     0.00%          date  ld-2.12.so                     [.] strlen
     0.00%           app  [kernel.kallsyms]              [k] remove_vma
     0.00%           top  libc-2.12.so                   [.] __isnan
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ios<wchar_t, std::char_traits<wchar_t> >::init(std::basic_streambuf<wchar_t, std::char_traits<wchar_t> >*)
     0.00%          tail  [kernel.kallsyms]              [k] page_cache_sync_readahead
     0.00%            ls  [kernel.kallsyms]              [k] __split_vma
     0.00%       swapper  [kernel.kallsyms]              [k] mod_timer
     0.00%           app  [kernel.kallsyms]              [k] gart_map_page
     0.00%           top  [kernel.kallsyms]              [k] handle_irq_event_percpu
     0.00%           app  [kernel.kallsyms]              [k] generic_file_buffered_write
     0.00%   flush-253:7  [kernel.kallsyms]              [k] bdi_writeback_thread
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ios<char, std::char_traits<char> >::_M_cache_locale(std::locale const&)
     0.00%         egrep  [kernel.kallsyms]              [k] __zone_watermark_ok
     0.00%           app  [kernel.kallsyms]              [k] d_path
     0.00%       swapper  [kernel.kallsyms]              [k] blk_update_request
     0.00%            sh  [kernel.kallsyms]              [k] __bitmap_intersects
     0.00%           awk  gawk                           [.] isnondecimal
     0.00%          perf  [kernel.kallsyms]              [k] __cond_resched
     0.00%         egrep  [kernel.kallsyms]              [k] path_lookupat
     0.00%           awk  [kernel.kallsyms]              [k] kfree_skb
     0.00%          perf  [kernel.kallsyms]              [k] transfer_objects
     0.00%            ps  libc-2.12.so                   [.] __strftime_internal
     0.00%           app  [kernel.kallsyms]              [k] groups_search
     0.00%           app  libc-2.12.so                   [.] __GI___errno_location
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] free_hot_cold_page
     0.00%           ksh  [kernel.kallsyms]              [k] get_write_access
     0.00%           app  [kernel.kallsyms]              [k] page_add_file_rmap
     0.00%            ps  [kernel.kallsyms]              [k] __d_lookup_rcu
     0.00%           app  [kernel.kallsyms]              [k] dequeue_task
     0.00%         egrep  [kernel.kallsyms]              [k] timespec_trunc
     0.00%         egrep  [kernel.kallsyms]              [k] xfer_secondary_pool
     0.00%         egrep  [kernel.kallsyms]              [k] sys_ioctl
     0.00%          date  [kernel.kallsyms]              [k] touch_atime
     0.00%           top  [kernel.kallsyms]              [k] mutex_lock
     0.00%           app  [kernel.kallsyms]              [k] __block_commit_write
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] scsi_prep_return
     0.00%            sh  [kernel.kallsyms]              [k] inc_zone_page_state
     0.00%        vmstat  libc-2.12.so                   [.] strtoull
     0.00%        master  [kernel.kallsyms]              [k] rb_erase
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] list_del
     0.00%           app  [kernel.kallsyms]              [k] irq_entries_start
     0.00%            sh  bash                           [.] make_child
     0.00%            sh  [kernel.kallsyms]              [k] activate_task
     0.00%           app  app                            [.] 
     0.00%          ntpd  [kernel.kallsyms]              [k] init_fpu
     0.00%         sleep  bash                           [.] default_tty_job_signals
     0.00%          date  bash                           [.] 0x51b0d         
     0.00%            sh  [kernel.kallsyms]              [k] page_add_new_anon_rmap
     0.00%            sh  [kernel.kallsyms]              [k] math_state_restore
     0.00%    in.telnetd  [kernel.kallsyms]              [k] ret_from_sys_call
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] list_del
     0.00%          perf  [kernel.kallsyms]              [k] sys_write
     0.00%         :3295  [kernel.kallsyms]              [k] flush_ptrace_hw_breakpoint
     0.00%           app  libstdc++.so.6.0.13            [.] std::ios_base::ios_base()
     0.00%           app  libc-2.12.so                   [.] __strncpy_sse2
     0.00%           awk  [kernel.kallsyms]              [k] list_del
     0.00%            sh  [kernel.kallsyms]              [k] raise_softirq
     0.00%          date  [kernel.kallsyms]              [k] resched_best_idle
     0.00%           app  libstdc++.so.6.0.13            [.] std::ios_base::Init::Init()
     0.00%           top  [kernel.kallsyms]              [k] tty_poll
     0.00%           awk  [kernel.kallsyms]              [k] sha_transform
     0.00%           app  [kernel.kallsyms]              [k] xfrm4_policy_check.clone.0
     0.00%          tail  [kernel.kallsyms]              [k] pty_write
     0.00%          date  ld-2.12.so                     [.] do_lookup_x
     0.00%           app  [kernel.kallsyms]              [k] page_add_file_rmap
     0.00%          tail  [jbd]                          [k] journal_get_write_access
     0.00%         egrep  bash                           [.] builtin_address_internal
     0.00%  ksoftirqd/11  [kernel.kallsyms]              [k] ktime_get
     0.00%          date  [kernel.kallsyms]              [k] free_pgd_range
     0.00%           app  [kernel.kallsyms]              [k] skb_release_data
     0.00%            sh  [kernel.kallsyms]              [k] sys_rt_sigprocmask
     0.00%           app  app                            [.] 
     0.00%            ps  [kernel.kallsyms]              [k] __lookup_mnt
     0.00%           app  [kernel.kallsyms]              [k] jiffies_to_usecs
     0.00%            ls  libc-2.12.so                   [.] syscall
     0.00%        pickup  pickup                         [.] myfree
     0.00%          perf  [ext4]                         [k] ext4_reserve_inode_write
     0.00%           top  libc-2.12.so                   [.] _IO_padn_internal
     0.00%     kjournald  [kernel.kallsyms]              [k] blk_peek_request
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] __pm_runtime_resume
     0.00%           app  [kernel.kallsyms]              [k] generic_pipe_buf_map
     0.00%            ps  [kernel.kallsyms]              [k] strnlen
     0.00%            ps  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%           app  [kernel.kallsyms]              [k] mix_pool_bytes_extract
     0.00%           app  [jbd]                          [k] journal_get_write_access
     0.00%       swapper  [kernel.kallsyms]              [k] __netif_schedule
     0.00%         egrep  [kernel.kallsyms]              [k] stub_execve
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] schedule
     0.00%           app  [kernel.kallsyms]              [k] __percpu_counter_add
     0.00%           app  [kernel.kallsyms]              [k] file_update_time
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] need_to_create_worker
     0.00%           top  [kernel.kallsyms]              [k] tty_write_room
     0.00%           app  libc-2.12.so                   [.] _IO_setb_internal
     0.00%            sh  libc-2.12.so                   [.] __ctype_b_loc
     0.00%           top  [kernel.kallsyms]              [k] native_read_cr0
     0.00%           app  [kernel.kallsyms]              [k] flush_signal_handlers
     0.00%            sh  [kernel.kallsyms]              [k] do_pipe_flags
     0.00%      modprobe  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] native_read_tsc
     0.00%           app  [kernel.kallsyms]              [k] strlen
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] set_task_cpu
     0.00%         sleep  [kernel.kallsyms]              [k] __memset
     0.00%       swapper  [kernel.kallsyms]              [k] scsi_setup_blk_pc_cmnd
     0.00%           awk  [kernel.kallsyms]              [k] file_ra_state_init
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] dev_gro_receive
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_string<char, std::char_traits<char>, std::allocator<char> >::swap(std::basic_string<char, std::char_traits<char>, std::allocator<char> >&)
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] next_zone
     0.00%    in.telnetd  [kernel.kallsyms]              [k] acct_update_integrals
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __pagevec_release
     0.00%           awk  bash                           [.] quote_string
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] slab_destroy
     0.00%            sh  [kernel.kallsyms]              [k] try_module_get
     0.00%       swapper  [kernel.kallsyms]              [k] free_uid
     0.00%           app  [kernel.kallsyms]              [k] policy_zonelist
     0.00%    in.telnetd  [kernel.kallsyms]              [k] rcu_note_context_switch
     0.00%      kthreadd  [kernel.kallsyms]              [k] queue_delayed_work
     0.00%   jbd2/dm-8-8  [jbd2]                         [k] __jbd2_journal_file_buffer
     0.00%            sh  [kernel.kallsyms]              [k] dma_issue_pending_all
     0.00%    in.telnetd  [kernel.kallsyms]              [k] copy_from_read_buf
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] worker_thread
     0.00%           app  [kernel.kallsyms]              [k] alloc_pages_vma
     0.00%           awk  libc-2.12.so                   [.] __GI_strcpy
     0.00%           app  [kernel.kallsyms]              [k] cap_file_permission
     0.00%           app  [kernel.kallsyms]              [k] module_put
     0.00%         egrep  [kernel.kallsyms]              [k] vm_normal_page
     0.00%          tail  [kernel.kallsyms]              [k] __srcu_read_lock
     0.00%            sh  bash                           [.] fork@plt
     0.00%         egrep  [kernel.kallsyms]              [k] free_block
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] cwq_dec_nr_in_flight
     0.00%          perf  [kernel.kallsyms]              [k] native_sched_clock
     0.00%           app  [kernel.kallsyms]              [k] mutex_unlock
     0.00%           top  [kernel.kallsyms]              [k] __percpu_counter_add
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] vmstat_update
     0.00%           ksh  [kernel.kallsyms]              [k] tty_set_termios
     0.00%           awk  [kernel.kallsyms]              [k] system_call
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tcp_v4_md5_lookup
     0.00%          tail  [kernel.kallsyms]              [k] blk_flush_plug_list
     0.00%           awk  [kernel.kallsyms]              [k] generic_getxattr
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] list_del
     0.00%            sh  [kernel.kallsyms]              [k] unlink_file_vma
     0.00%     kjournald  [kernel.kallsyms]              [k] elv_rb_find
     0.00%           app  libstdc++.so.6.0.13            [.] std::numpunct<char>::_M_initialize_numpunct(__locale_struct*)
     0.00%          tail  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%           app  [kernel.kallsyms]              [k] resched_task
     0.00%          date  bash                           [.] expand_words
     0.00%          grep  [kernel.kallsyms]              [k] n_tty_write
     0.00%          date  bash                           [.] make_bare_word
     0.00%            sh  [kernel.kallsyms]              [k] try_preempt
     0.00%           app  [kernel.kallsyms]              [k] error_exit
     0.00%          perf  [kernel.kallsyms]              [k] sched_clock
     0.00%         sleep  [kernel.kallsyms]              [k] error_exit
     0.00%           app  [kernel.kallsyms]              [k] page_add_new_anon_rmap
     0.00%           awk  bash                           [.] mbschr
     0.00%     kjournald  [kernel.kallsyms]              [k] dequeue_task
     0.00%     kjournald  [jbd]                          [k] journal_commit_transaction
     0.00%            sh  libc-2.12.so                   [.] __sigprocmask
     0.00%    in.telnetd  [kernel.kallsyms]              [k] packet_rcv
     0.00%            sh  [kernel.kallsyms]              [k] ret_from_sys_call
     0.00%         sleep  [kernel.kallsyms]              [k] __switch_to
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] __bitmap_and
     0.00%         sleep  [kernel.kallsyms]              [k] load_elf_binary
     0.00%         egrep  [kernel.kallsyms]              [k] memcpy
     0.00%           app  [kernel.kallsyms]              [k] security_msg_queue_msgrcv
     0.00%            sh  [kernel.kallsyms]              [k] do_signal
     0.00%           top  [kernel.kallsyms]              [k] tty_buffer_request_room
     0.00%           top  [kernel.kallsyms]              [k] filp_close
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_alloc_node
     0.00%           app  libstdc++.so.6.0.13            [.] std::ios_base::~ios_base()
     0.00%           top  [kernel.kallsyms]              [k] ip_rcv_finish
     0.00%  ksoftirqd/11  [kernel.kallsyms]              [k] __switch_to
     0.00%           ksh  [kernel.kallsyms]              [k] security_file_ioctl
     0.00%          tail  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           app  [kernel.kallsyms]              [k] __list_del_entry
     0.00%          date  libc-2.12.so                   [.] malloc_consolidate
     0.00%           app  [kernel.kallsyms]              [k] ___pmd_free_tlb
     0.00%    in.telnetd  [kernel.kallsyms]              [k] free_poll_entry
     0.00%          date  [kernel.kallsyms]              [k] __dentry_open
     0.00%         egrep  [kernel.kallsyms]              [k] ret_from_sys_call
     0.00%      kthreadd  [kernel.kallsyms]              [k] next_zone
     0.00%   ksoftirqd/5  [kernel.kallsyms]              [k] ktime_get
     0.00%           app  libstdc++.so.6.0.13            [.] std::__timepunct<wchar_t>::_M_initialize_timepunct(__locale_struct*)
     0.00%         :3256  [kernel.kallsyms]              [k] ptrace_put_breakpoints
     0.00%          tail  [kernel.kallsyms]              [k] tty_buffer_request_room
     0.00%           app  [kernel.kallsyms]              [k] invalidate_interrupt17
     0.00%            ps  [kernel.kallsyms]              [k] kmem_cache_alloc_trace
     0.00%           app  [kernel.kallsyms]              [k] page_remove_rmap
     0.00%   flush-253:8  [kernel.kallsyms]              [k] skb_release_head_state
     0.00%           awk  [kernel.kallsyms]              [k] _copy_to_user
     0.00%    in.telnetd  [kernel.kallsyms]              [k] poll_schedule_timeout
     0.00%          date  libc-2.12.so                   [.] __GI_timelocal
     0.00%         :3281  [kernel.kallsyms]              [k] do_exit
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] __list_add
     0.00%           app  libstdc++.so.6.0.13            [.] free@plt
     0.00%          date  [kernel.kallsyms]              [k] path_put
     0.00%           app  [kernel.kallsyms]              [k] sched_clock_local
     0.00%         egrep  libc-2.12.so                   [.] __GI___libc_read
     0.00%   kworker/u:2  [kernel.kallsyms]              [k] worker_thread
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __tcp_push_pending_frames
     0.00%           app  [kernel.kallsyms]              [k] hrtimer_start
     0.00%           app  app                            [.] 
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __list_del_entry
     0.00%            ps  libc-2.12.so                   [.] __readdir64
     0.00%           app  libc-2.12.so                   [.] _IO_flush_all_lockp
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%          date  bash                           [.] yyparse
     0.00%           app  libpthread-2.12.so             [.] __sendto
     0.00%           cut  cut                            [.] 0x195d          
     0.00%           app  libc-2.12.so                   [.] handle_amd
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] tty_buffer_free
     0.00%           awk  [kernel.kallsyms]              [k] __kfree_skb
     0.00%          date  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%        vmstat  [kernel.kallsyms]              [k] irq_to_desc
     0.00%            ps  [kernel.kallsyms]              [k] seq_printf
     0.00%           app  [jbd]                          [k] journal_dirty_metadata
     0.00%            sh  bash                           [.] mbschr
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.00%            sh  [kernel.kallsyms]              [k] __do_fault
     0.00%          date  bash                           [.] make_child
     0.00%           awk  ld-2.12.so                     [.] _dl_allocate_tls_storage
     0.00%         sleep  libc-2.12.so                   [.] _int_malloc
     0.00%           app  [kernel.kallsyms]              [k] sys_read
     0.00%         egrep  [kernel.kallsyms]              [k] native_set_pte_at
     0.00%           app  libstdc++.so.6.0.13            [.] std::__basic_file<char>::open(char const*, std::_Ios_Openmode, int)@plt
     0.00%            sh  [kernel.kallsyms]              [k] __memset
     0.00%           app  [kernel.kallsyms]              [k] ktime_get_ts
     0.00%       swapper  [kernel.kallsyms]              [k] del_timer
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] worker_enter_idle
     0.00%           app  [kernel.kallsyms]              [k] unmap_vmas
     0.00%           app  [kernel.kallsyms]              [k] vma_prio_tree_insert
     0.00%         egrep  libc-2.12.so                   [.] __strrchr_sse2
     0.00%   flush-253:8  [dm_mod]                       [k] dm_table_get
     0.00%          perf  [kernel.kallsyms]              [k] __remove_hrtimer
     0.00%     kjournald  [kernel.kallsyms]              [k] set_task_cpu
     0.00%          ntpd  [kernel.kallsyms]              [k] free_pcppages_bulk
     0.00%           app  [kernel.kallsyms]              [k] printk_tick
     0.00%          perf  [kernel.kallsyms]              [k] sys_poll
     0.00%         sleep  [kernel.kallsyms]              [k] path_get
     0.00%          ntpd  [kernel.kallsyms]              [k] free_uid
     0.00%      modprobe  [kernel.kallsyms]              [k] copy_page_c
     0.00%          date  [kernel.kallsyms]              [k] page_add_file_rmap
     0.00%           app  libstdc++.so.6.0.13            [.] __cxxabiv1::__vmi_class_type_info::__do_dyncast(long, __cxxabiv1::__class_type_info::__sub_kind, __cxxabiv1::__class_type_info const*, void const*, __cxxabiv1::__class_type_info const*, void const*, __cxxabiv1::__class_type_info::__dyncast_result&) const
     0.00%     kjournald  [dm_mod]                       [k] linear_map
     0.00%   ksoftirqd/9  [kernel.kallsyms]              [k] schedule
     0.00%          date  bash                           [.] push_stream
     0.00%       swapper  [myri10ge]                     [k] myri10ge_watchdog_timer
     0.00%           app  [kernel.kallsyms]              [k] current_fs_time
     0.00%            sh  [kernel.kallsyms]              [k] __percpu_counter_add
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] flush_to_ldisc
     0.00%          date  [kernel.kallsyms]              [k] open_exec
     0.00%           awk  [kernel.kallsyms]              [k] perf_event_comm
     0.00%           app  [kernel.kallsyms]              [k] __bitmap_and
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] need_to_create_worker
     0.00%           app  [kernel.kallsyms]              [k] __call_rcu
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tcp_options_write
     0.00%           awk  [kernel.kallsyms]              [k] free_block
     0.00%           awk  [kernel.kallsyms]              [k] pagevec_lru_move_fn
     0.00%            sh  libc-2.12.so                   [.] __GI___sigsetjmp
     0.00%            sh  [kernel.kallsyms]              [k] cpumask_any_but
     0.00%         egrep  [kernel.kallsyms]              [k] gart_map_page
     0.00%   ksoftirqd/3  [kernel.kallsyms]              [k] set_task_cpu
     0.00%           ksh  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%          date  [kernel.kallsyms]              [k] ima_match_policy
     0.00%           ksh  [kernel.kallsyms]              [k] find_next_bit
     0.00%           app  libstdc++.so.6.0.13            [.] std::locale::facet::_S_get_c_name()
     0.00%          date  [kernel.kallsyms]              [k] fsnotify
     0.00%         egrep  libc-2.12.so                   [.] _int_realloc
     0.00%           app  bash                           [.] begin_unwind_frame
     0.00%           app  [kernel.kallsyms]              [k] acct_update_integrals
     0.00%           app  [kernel.kallsyms]              [k] ____pagevec_lru_add_fn
     0.00%         sleep  [kernel.kallsyms]              [k] count.clone.0
     0.00%          date  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tty_ldisc_deref
     0.00%          date  libc-2.12.so                   [.] __cxa_atexit_internal
     0.00%         sleep  [kernel.kallsyms]              [k] next_zones_zonelist
     0.00%           app  [kernel.kallsyms]              [k] __prop_inc_percpu_max
     0.00%    in.telnetd  [kernel.kallsyms]              [k] inet_recvmsg
     0.00%           awk  [kernel.kallsyms]              [k] zone_watermark_ok
     0.00%           app  [kernel.kallsyms]              [k] vma_prio_tree_insert
     0.00%           awk  [kernel.kallsyms]              [k] sys_dup3
     0.00%         fgrep  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%          perf  [kernel.kallsyms]              [k] __zone_watermark_ok
     0.00%           awk  bash                           [.] hash_search
     0.00%            ps  [kernel.kallsyms]              [k] mutex_lock
     0.00%           app  ld-2.12.so                     [.] fillin_rpath
     0.00%            sh  [kernel.kallsyms]              [k] rcu_process_gp_end
     0.00%           awk  libc-2.12.so                   [.] __GI___mempcpy
     0.00%          tail  [kernel.kallsyms]              [k] put_ldisc
     0.00%           top  [kernel.kallsyms]              [k] meminfo_proc_show
     0.00%         sleep  bash                           [.] close_buffered_stream
     0.00%          date  libc-2.12.so                   [.] __gconv_transform_ascii_internal
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] skb_put
     0.00%           awk  gawk                           [.] format_tree
     0.00%            ps  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%          date  libc-2.12.so                   [.] __cfree
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] irq_entries_start
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%           top  [kernel.kallsyms]              [k] next_tgid
     0.00%           awk  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%           awk  [kernel.kallsyms]              [k] module_put
     0.00%           awk  [ext3]                         [k] ext3_get_acl
     0.00%         egrep  [kernel.kallsyms]              [k] prepare_binprm
     0.00%          date  [kernel.kallsyms]              [k] ip_rcv
     0.00%           app  libc-2.12.so                   [.] __strchrnul
     0.00%            ps  [kernel.kallsyms]              [k] system_call_after_swapgs
     0.00%           app  [kernel.kallsyms]              [k] ip_local_deliver
     0.00%         egrep  ld-2.12.so                     [.] _dl_allocate_tls_storage
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] mod_timer
     0.00%           app  libstdc++.so.6.0.13            [.] bool std::has_facet<std::ctype<wchar_t> >(std::locale const&)
     0.00%            sh  [kernel.kallsyms]              [k] gart_map_page
     0.00%            ps  libc-2.12.so                   [.] __GI_____strtoll_l_internal
     0.00%           top  [kernel.kallsyms]              [k] transfer_objects
     0.00%          date  ld-2.12.so                     [.] dl_main
     0.00%           awk  [kernel.kallsyms]              [k] kfree
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __remove_hrtimer
     0.00%           awk  [kernel.kallsyms]              [k] memcpy
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] idle_cpu
     0.00%           app  libc-2.12.so                   [.] wctype_l
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] memcpy
     0.00%          date  bash                           [.] make_word_list
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __alloc_skb
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] schedule_delayed_work
     0.00%   kworker/4:1  [e1000e]                       [k] e1000e_get_laa_state_82571
     0.00%            sh  bash                           [.] de_backslash
     0.00%           app  [kernel.kallsyms]              [k] alarm_setitimer
     0.00%    in.telnetd  [kernel.kallsyms]              [k] put_ldisc
     0.00%         egrep  [kernel.kallsyms]              [k] perf_event_task_tick
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] __phys_addr
     0.00%         sleep  [kernel.kallsyms]              [k] xfer_secondary_pool
     0.00%           app  [kernel.kallsyms]              [k] __follow_mount_rcu
     0.00%           awk  libc-2.12.so                   [.] __strlen_sse2
     0.00%           ksh  [kernel.kallsyms]              [k] tty_ldisc_try
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] ktime_get
     0.00%          date  [kernel.kallsyms]              [k] anon_vma_prepare
     0.00%          date  [kernel.kallsyms]              [k] perf_event_mmap_output
     0.00%           app  [kernel.kallsyms]              [k] dequeue_task
     0.00%         egrep  libc-2.12.so                   [.] __GI_setlocale
     0.00%         egrep  libc-2.12.so                   [.] __GI___sbrk
     0.00%          date  [kernel.kallsyms]              [k] ____pagevec_lru_add_fn
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] internal_add_timer
     0.00%           top  [kernel.kallsyms]              [k] ___pmd_free_tlb
     0.00%            sh  bash                           [.] delete_job
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] sched_clock_local
     0.00%            sh  bash                           [.] find_special_builtin
     0.00%           app  libc-2.12.so                   [.] __strncmp_sse2
     0.00%         sleep  [kernel.kallsyms]              [k] perf_event_mmap_ctx
     0.00%           app  [kernel.kallsyms]              [k] _copy_to_user
     0.00%            sh  [kernel.kallsyms]              [k] __pud_alloc
     0.00%           ksh  [kernel.kallsyms]              [k] gart_map_page
     0.00%           app  [kernel.kallsyms]              [k] __free_pages_ok
     0.00%           app  [kernel.kallsyms]              [k] hugetlbfs_file_mmap
     0.00%   flush-253:8  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%            sh  bash                           [.] discard_unwind_frame
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] net_rx_action
     0.00%            sh  [kernel.kallsyms]              [k] do_notify_resume
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] mutex_unlock
     0.00%      modprobe  modprobe                       [.] 0xf23b          
     0.00%           app  [kernel.kallsyms]              [k] hrtimer_try_to_cancel
     0.00%            ps  [kernel.kallsyms]              [k] __rmqueue
     0.00%           top  [kernel.kallsyms]              [k] fd_install
     0.00%        vmstat  [kernel.kallsyms]              [k] put_dec_trunc
     0.00%         egrep  [kernel.kallsyms]              [k] do_exit
     0.00%        vmstat  [kernel.kallsyms]              [k] __bitmap_empty
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] irq_entries_start
     0.00%   sync_supers  [kernel.kallsyms]              [k] sync_supers
     0.00%          date  ld-2.12.so                     [.] _dl_resolve_conflicts
     0.00%           awk  ld-2.12.so                     [.] mempcpy
     0.00%           app  [kernel.kallsyms]              [k] exit_creds
     0.00%            sh  [kernel.kallsyms]              [k] scheduler_tick
     0.00%           awk  [kernel.kallsyms]              [k] reusable_anon_vma
     0.00%           cut  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] sole_cpu_idle
     0.00%           app  [kernel.kallsyms]              [k] mprotect_fixup
     0.00%          date  [kernel.kallsyms]              [k] vma_adjust
     0.00%           app  [kernel.kallsyms]              [k] pci_bus_read_config_word
     0.00%   flush-253:8  [kernel.kallsyms]              [k] __cfq_set_active_queue
     0.00%   flush-253:8  [kernel.kallsyms]              [k] pc_user_time
     0.00%           awk  [kernel.kallsyms]              [k] __netif_receive_skb
     0.00%           app  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%            sh  [kernel.kallsyms]              [k] call_rcu_sched
     0.00%           app  libc-2.12.so                   [.] _IO_putc_internal
     0.00%            sh  [kernel.kallsyms]              [k] do_lookup
     0.00%           ksh  [kernel.kallsyms]              [k] keyctl_keyring_link
     0.00%          ntpd  ntpd                           [.] adj_host_clock
     0.00%           top  [kernel.kallsyms]              [k] user_path_at
     0.00%            ps  [kernel.kallsyms]              [k] security_task_to_inode
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] __drain_alien_cache
     0.00%            sh  [kernel.kallsyms]              [k] read_tsc
     0.00%           top  [kernel.kallsyms]              [k] __rcu_process_callbacks
     0.00%         sleep  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%           awk  ld-2.12.so                     [.] _dl_load_cache_lookup
     0.00%           app  [kernel.kallsyms]              [k] grab_cache_page_write_begin
     0.00%        vmstat  [kernel.kallsyms]              [k] sys_rt_sigprocmask
     0.00%           awk  [kernel.kallsyms]              [k] free_pgtables
     0.00%          date  date                           [.] 0x9005          
     0.00%            sh  bash                           [.] close_buffered_stream
     0.00%         egrep  ld-2.12.so                     [.] _dl_resolve_conflicts
     0.00%            sh  [kernel.kallsyms]              [k] d_instantiate
     0.00%           app  [kernel.kallsyms]              [k] hugetlb_fault
     0.00%            sh  [kernel.kallsyms]              [k] exit_mm
     0.00%          date  bash                           [.] search_for_command
     0.00%           app  ld-2.12.so                     [.] bcmp
     0.00%          date  [kernel.kallsyms]              [k] prepend
     0.00%         sleep  [kernel.kallsyms]              [k] fsnotify
     0.00%           app  [kernel.kallsyms]              [k] dma_issue_pending_all
     0.00%         sleep  ld-2.12.so                     [.] _dl_new_object
     0.00%           app  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%         sleep  [kernel.kallsyms]              [k] run_posix_cpu_timers
     0.00%          date  bash                           [.] run_pending_traps
     0.00%           app  [kernel.kallsyms]              [k] __hrtimer_start_range_ns
     0.00%           awk  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.00%           app  [kernel.kallsyms]              [k] system_call_after_swapgs
     0.00%           app  [kernel.kallsyms]              [k] ip_local_deliver_finish
     0.00%          perf  [ext4]                         [k] __ext4_journal_stop
     0.00%          date  bash                           [.] close_buffered_fd
     0.00%           app  app                            [.] 
     0.00%         egrep  [kernel.kallsyms]              [k] strnlen_user
     0.00%         sleep  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%         :4276  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           app  libpthread-2.12.so             [.] __nanosleep
     0.00%           top  [kernel.kallsyms]              [k] single_open
     0.00%          date  [kernel.kallsyms]              [k] zone_statistics
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ios<char, std::char_traits<char> >::_M_cache_locale(std::locale const&)@plt
     0.00%           app  [ext3]                         [k] ext3_mark_inode_dirty
     0.00%           app  [kernel.kallsyms]              [k] __wake_up_bit
     0.00%           top  [kernel.kallsyms]              [k] __wake_up_sync_key
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] need_to_create_worker
     0.00%   flush-253:8  [ext4]                         [k] ext4_write_inode
     0.00%         egrep  [kernel.kallsyms]              [k] napi_skb_finish
     0.00%           app  [kernel.kallsyms]              [k] native_write_cr0
     0.00%           awk  [kernel.kallsyms]              [k] copy_strings
     0.00%           awk  ld-2.12.so                     [.] _dl_resolve_conflicts
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] add_timer
     0.00%         egrep  [kernel.kallsyms]              [k] end_writeback
     0.00%           app  libc-2.12.so                   [.] __tz_convert
     0.00%          date  libc-2.12.so                   [.] __GI___mempcpy
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] __kmalloc_node_track_caller
     0.00%   flush-253:8  [kernel.kallsyms]              [k] bio_add_page
     0.00%           app  [kernel.kallsyms]              [k] blk_update_request
     0.00%          date  ld-2.12.so                     [.] __xstat64
     0.00%            sh  bash                           [.] unquoted_glob_pattern_p
     0.00%           app  ld-2.12.so                     [.] _dl_map_object_from_fd
     0.00%     kjournald  [kernel.kallsyms]              [k] generic_block_bmap
     0.00%          perf  [kernel.kallsyms]              [k] __phys_addr
     0.00%         egrep  [kernel.kallsyms]              [k] sys_read
     0.00%     kjournald  [kernel.kallsyms]              [k] __find_get_block
     0.00%   jbd2/dm-8-8  [dm_mod]                       [k] __split_and_process_bio
     0.00%            sh  [kernel.kallsyms]              [k] remove_wait_queue
     0.00%           awk  [kernel.kallsyms]              [k] native_read_tsc
     0.00%            ps  libc-2.12.so                   [.] ____strtoull_l_internal
     0.00%        vmstat  [kernel.kallsyms]              [k] ip_route_input_common
     0.00%         sleep  libc-2.12.so                   [.] __cxa_atexit_internal
     0.00%            sh  [e1000e]                       [k] e1000_intr_msi
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] cache_reap
     0.00%         :3082  [kernel.kallsyms]              [k] find_next_bit
     0.00%           app  ld-2.12.so                     [.] memset
     0.00%           app  libc-2.12.so                   [.] 0x7ffe7         
     0.00%           awk  gawk                           [.] do_print
     0.00%            sh  bash                           [.] dispose_used_env_vars
     0.00%          date  [kernel.kallsyms]              [k] futex_wait
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] native_read_tsc
     0.00%         crond  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%         sleep  [kernel.kallsyms]              [k] free_pgd_range
     0.00%          ntpd  [kernel.kallsyms]              [k] do_sigaltstack
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] __virt_addr_valid
     0.00%           app  [kernel.kallsyms]              [k] __put_task_struct
     0.00%         egrep  [kernel.kallsyms]              [k] do_last
     0.00%           app  [kernel.kallsyms]              [k] _cond_resched
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] __next_cpu
     0.00%            sh  bash                           [.] bind_variable
     0.00%  kworker/11:1  [kernel.kallsyms]              [k] worker_thread
     0.00%          ntpd  [kernel.kallsyms]              [k] do_signal
     0.00%          date  [kernel.kallsyms]              [k] free_hot_cold_page
     0.00%         sleep  [kernel.kallsyms]              [k] napi_gro_receive
     0.00%           awk  libc-2.12.so                   [.] _setjmp
     0.00%   kworker/u:3  [kernel.kallsyms]              [k] pc_user_time
     0.00%           awk  [kernel.kallsyms]              [k] next_zones_zonelist
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%         sleep  [kernel.kallsyms]              [k] hrtimer_forward
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] n_tty_receive_buf
     0.00%           app  [kernel.kallsyms]              [k] rw_verify_area
     0.00%           app  [kernel.kallsyms]              [k] find_get_page
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%           app  [kernel.kallsyms]              [k] __switch_to
     0.00%            sh  [kernel.kallsyms]              [k] thread_group_times
     0.00%           top  [kernel.kallsyms]              [k] fasync_remove_entry
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] set_task_cpu
     0.00%           awk  [kernel.kallsyms]              [k] __cond_resched
     0.00%           awk  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%            sh  [kernel.kallsyms]              [k] alloc_pages_vma
     0.00%          date  [kernel.kallsyms]              [k] unlink_file_vma
     0.00%           app  libstdc++.so.6.0.13            [.] bool std::has_facet<std::num_get<char, std::istreambuf_iterator<char, std::char_traits<char> > > >(std::locale const&)
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tty_unthrottle
     0.00%           top  [kernel.kallsyms]              [k] napi_gro_receive
     0.00%         sleep  ld-2.12.so                     [.] _dl_cache_libcmp
     0.00%         egrep  [kernel.kallsyms]              [k] pte_alloc_one
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] schedule
     0.00%        vmstat  libc-2.12.so                   [.] _IO_new_file_write
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] __list_add
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __bitmap_and
     0.00%         egrep  [kernel.kallsyms]              [k] anon_vma_clone
     0.00%            ps  [kernel.kallsyms]              [k] path_openat
     0.00%        master  [kernel.kallsyms]              [k] radix_tree_lookup_slot
     0.00%       swapper  [kernel.kallsyms]              [k] netlink_broadcast_filtered
     0.00%       swapper  [kernel.kallsyms]              [k] raise_softirq_irqoff
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] __alloc_skb
     0.00%           app  libc-2.12.so                   [.] _int_malloc
     0.00%          date  bash                           [.] phash_insert
     0.00%         sleep  [kernel.kallsyms]              [k] sha_transform
     0.00%          date  [kernel.kallsyms]              [k] release_pages
     0.00%            ps  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%           app  [kernel.kallsyms]              [k] vma_prio_tree_remove
     0.00%           app  [kernel.kallsyms]              [k] __split_vma
     0.00%     kjournald  [kernel.kallsyms]              [k] get_request_wait
     0.00%           app  [kernel.kallsyms]              [k] vfs_write
     0.00%          date  [kernel.kallsyms]              [k] pc_user_time
     0.00%         egrep  [kernel.kallsyms]              [k] __dentry_open
     0.00%    in.telnetd  [e1000e]                       [k] e1000_maybe_stop_tx
     0.00%          perf  [kernel.kallsyms]              [k] policy_zonelist
     0.00%    in.telnetd  [kernel.kallsyms]              [k] system_call
     0.00%         sleep  ld-2.12.so                     [.] _dl_sysdep_start
     0.00%         egrep  [kernel.kallsyms]              [k] __wake_up_sync_key
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] dec_zone_page_state
     0.00%           app  [kernel.kallsyms]              [k] path_get
     0.00%           awk  [kernel.kallsyms]              [k] __math_state_restore
     0.00%          perf  [kernel.kallsyms]              [k] run_timer_softirq
     0.00%          date  bash                           [.] default_tty_job_signals
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] list_del
     0.00%            sh  [kernel.kallsyms]              [k] mm_init
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] queue_delayed_work_on
     0.00%          date  libc-2.12.so                   [.] __unregister_atfork
     0.00%          perf  [kernel.kallsyms]              [k] __dquot_alloc_space
     0.00%         sleep  [kernel.kallsyms]              [k] schedule
     0.00%           app  [kernel.kallsyms]              [k] rcu_implicit_dynticks_qs
     0.00%          date  [kernel.kallsyms]              [k] prepend_path
     0.00%            sh  [kernel.kallsyms]              [k] free_block
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Rep::_M_destroy(std::allocator<char> const&)
     0.00%          date  [kernel.kallsyms]              [k] vm_stat_account
     0.00%           app  [kernel.kallsyms]              [k] retint_swapgs
     0.00%   jbd2/dm-8-8  [jbd2]                         [k] __journal_remove_journal_head
     0.00%           top  [kernel.kallsyms]              [k] __wake_up
     0.00%           app  libc-2.12.so                   [.] __GI_fflush
     0.00%            ps  [kernel.kallsyms]              [k] system_call
     0.00%           app  [kernel.kallsyms]              [k] sys_faccessat
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tick_do_update_jiffies64
     0.00%         sleep  ld-2.12.so                     [.] _dl_start
     0.00%           app  [kernel.kallsyms]              [k] __percpu_counter_add
     0.00%           app  [kernel.kallsyms]              [k] mnt_want_write_file
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] next_zone
     0.00%           app  [kernel.kallsyms]              [k] __put_user_4
     0.00%          perf  [kernel.kallsyms]              [k] acct_update_integrals
     0.00%   flush-253:8  [kernel.kallsyms]              [k] rcu_start_gp
     0.00%          perf  [kernel.kallsyms]              [k] free_hot_cold_page
     0.00%         sleep  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           top  [kernel.kallsyms]              [k] cap_task_to_inode
     0.00%            sh  [kernel.kallsyms]              [k] perf_event_fork
     0.00%           top  [kernel.kallsyms]              [k] sys_fcntl
     0.00%          date  [kernel.kallsyms]              [k] mix_pool_bytes_extract
     0.00%           top  [kernel.kallsyms]              [k] native_write_cr0
     0.00%            sh  [kernel.kallsyms]              [k] restore_i387_xstate
     0.00%           app  libc-2.12.so                   [.] __libc_start_main
     0.00%           awk  [kernel.kallsyms]              [k] hrtimer_forward
     0.00%           app  [kernel.kallsyms]              [k] exit_files
     0.00%    in.telnetd  [kernel.kallsyms]              [k] schedule_work
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] blk_rq_init
     0.00%           awk  [kernel.kallsyms]              [k] lru_add_drain
     0.00%      kthreadd  [kernel.kallsyms]              [k] queue_delayed_work_on
     0.00%           app  libstdc++.so.6.0.13            [.] std::locale::id::_M_id() const
     0.00%   flush-253:8  [dm_mod]                       [k] linear_merge
     0.00%           top  [e1000e]                       [k] e1000_receive_skb
     0.00%         :4462  [kernel.kallsyms]              [k] schedule
     0.00%   jbd2/dm-8-8  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%           app  [kernel.kallsyms]              [k] vma_adjust
     0.00%          date  [kernel.kallsyms]              [k] get_pageblock_flags_group
     0.00%            sh  [kernel.kallsyms]              [k] __call_rcu
     0.00%            ps  [kernel.kallsyms]              [k] find_vma
     0.00%          date  [kernel.kallsyms]              [k] __bitmap_weight
     0.00%         :3937  [kernel.kallsyms]              [k] switch_task_namespaces
     0.00%          date  ld-2.12.so                     [.] _dl_sysdep_start
     0.00%           app  [kernel.kallsyms]              [k] read_tsc
     0.00%         :3127  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%    in.telnetd  [kernel.kallsyms]              [k] sock_poll
     0.00%    in.telnetd  [kernel.kallsyms]              [k] ip_route_input_common
     0.00%           app  [kernel.kallsyms]              [k] __list_del_entry
     0.00%          perf  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%     kjournald  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%            ps  libc-2.12.so                   [.] _IO_default_xsputn_internal
     0.00%           awk  libc-2.12.so                   [.] handle_amd
     0.00%           awk  gawk                           [.] r_force_number
     0.00%    in.telnetd  [kernel.kallsyms]              [k] try_to_wake_up
     0.00%         egrep  [kernel.kallsyms]              [k] ____pagevec_lru_add_fn
     0.00%           awk  [kernel.kallsyms]              [k] strncpy_from_user
     0.00%            sh  bash                           [.] assignment
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] schedule_delayed_work
     0.00%     kjournald  [kernel.kallsyms]              [k] io_schedule
     0.00%           app  [kernel.kallsyms]              [k] free_task
     0.00%         egrep  libc-2.12.so                   [.] _nl_find_locale
     0.00%           app  [kernel.kallsyms]              [k] kfree
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] get_pageblock_flags_group
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] drain_freelist
     0.00%         egrep  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] lock_timer_base
     0.00%           app  ld-2.12.so                     [.] calloc
     0.00%          date  [kernel.kallsyms]              [k] perf_event_tid
     0.00%           app  bash                           [.] put_command_name_into_env
     0.00%       swapper  [kernel.kallsyms]              [k] wake_up_process
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] sched_clock_local
     0.00%    in.telnetd  [kernel.kallsyms]              [k] set_task_cpu
     0.00%         sleep  [kernel.kallsyms]              [k] ___pte_free_tlb
     0.00%            ps  [kernel.kallsyms]              [k] vfsmount_lock_local_lock
     0.00%            ps  ps                             [.] 0x7fc7          
     0.00%   flush-253:8  [kernel.kallsyms]              [k] packet_rcv
     0.00%         sleep  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           app  libc-2.12.so                   [.] __btowc
     0.00%           app  ld-2.12.so                     [.] _dl_map_object_from_fd
     0.00%           app  [kernel.kallsyms]              [k] __get_user_pages
     0.00%           top  [kernel.kallsyms]              [k] net_rx_action
     0.00%   ksoftirqd/3  [kernel.kallsyms]              [k] ktime_get
     0.00%         egrep  [kernel.kallsyms]              [k] skb_trim
     0.00%          perf  [kernel.kallsyms]              [k] __do_fault
     0.00%            sh  [kernel.kallsyms]              [k] anon_pipe_buf_release
     0.00%         sleep  ld-2.12.so                     [.] rtld_lock_default_lock_recursive
     0.00%           awk  [kernel.kallsyms]              [k] do_munmap
     0.00%          tail  [kernel.kallsyms]              [k] mntget
     0.00%           app  [kernel.kallsyms]              [k] follow_managed
     0.00%           top  libtinfo.so.5.7                [.] tputs
     0.00%         :3711  [kernel.kallsyms]              [k] memcpy
     0.00%           ksh  [kernel.kallsyms]              [k] pollwake
     0.00%           top  [kernel.kallsyms]              [k] kstat_irqs
     0.00%         sleep  [kernel.kallsyms]              [k] ktime_get
     0.00%   ksoftirqd/8  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%          date  [kernel.kallsyms]              [k] anon_vma_clone
     0.00%           top  [kernel.kallsyms]              [k] mntput
     0.00%       swapper  [kernel.kallsyms]              [k] cfq_dispatch_requests
     0.00%        vmstat  [kernel.kallsyms]              [k] vfs_read
     0.00%          perf  [kernel.kallsyms]              [k] __fsnotify_parent
     0.00%           ksh  ld-2.12.so                     [.] strcmp
     0.00%           ksh  [kernel.kallsyms]              [k] vma_prio_tree_add
     0.00%            ps  [kernel.kallsyms]              [k] alloc_pages_vma
     0.00%   flush-253:8  [kernel.kallsyms]              [k] _raw_read_lock_irqsave
     0.00%           top  [kernel.kallsyms]              [k] put_ldisc
     0.00%            sh  [kernel.kallsyms]              [k] dequeue_signal
     0.00%          perf  [kernel.kallsyms]              [k] __wake_up_common
     0.00%           awk  [kernel.kallsyms]              [k] reschedule_interrupt
     0.00%           awk  libc-2.12.so                   [.] bsd_signal
     0.00%           top  [kernel.kallsyms]              [k] ima_file_free
     0.00%           awk  [kernel.kallsyms]              [k] unlink_anon_vmas
     0.00%           app  [kernel.kallsyms]              [k] eth_type_trans
     0.00%            ps  [kernel.kallsyms]              [k] __rcu_pending
     0.00%            sh  [kernel.kallsyms]              [k] perf_event_init_task
     0.00%          date  [kernel.kallsyms]              [k] __cond_resched
     0.00%          perf  [kernel.kallsyms]              [k] zone_statistics
     0.00%           app  [ext3]                         [k] ext3_journal_start_sb
     0.00%           app  [e1000e]                       [k] e1000_alloc_rx_buffers
     0.00%           rcp  [kernel.kallsyms]              [k] __dentry_open
     0.00%        vmstat  [kernel.kallsyms]              [k] resched_best_mask
     0.00%           top  libc-2.12.so                   [.] _IO_setb_internal
     0.00%           app  libc-2.12.so                   [.] __GI_mbrtowc
     0.00%          date  [kernel.kallsyms]              [k] bprm_mm_init
     0.00%           app  [kernel.kallsyms]              [k] generic_segment_checks
     0.00%           app  bash                           [.] push_stream
     0.00%         :3697  [kernel.kallsyms]              [k] proc_exit_connector
     0.00%    in.telnetd  [kernel.kallsyms]              [k] tcp_send_mss
     0.00%          date  ld-2.12.so                     [.] _dl_important_hwcaps
     0.00%            sh  [kernel.kallsyms]              [k] copy_semundo
     0.00%          date  libc-2.12.so                   [.] _IO_new_file_fopen
     0.00%         sleep  [kernel.kallsyms]              [k] handle_mm_fault
     0.00%            ps  [kernel.kallsyms]              [k] dnotify_flush
     0.00%           app  ld-2.12.so                     [.] dl_main
     0.00%           app  [kernel.kallsyms]              [k] restore_args
     0.00%   flush-253:7  [kernel.kallsyms]              [k] kthread_should_stop
     0.00%           app  libc-2.12.so                   [.] __IO_vsprintf
     0.00%   flush-253:8  [kernel.kallsyms]              [k] radix_tree_gang_lookup_slot
     0.00%         sleep  ld-2.12.so                     [.] _dl_load_cache_lookup
     0.00%         sleep  bash                           [.] list_length
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] mod_timer
     0.00%           top  libc-2.12.so                   [.] __rawmemchr_sse2
     0.00%          tail  [kernel.kallsyms]              [k] fsnotify_remove_priv_from_event
     0.00%           top  [kernel.kallsyms]              [k] __bitmap_intersects
     0.00%           app  [kernel.kallsyms]              [k] unregister_hw_breakpoint
     0.00%       swapper  [kernel.kallsyms]              [k] fib_table_lookup
     0.00%       swapper  [kernel.kallsyms]              [k] cfq_completed_request
     0.00%          perf  [kernel.kallsyms]              [k] kmem_cache_alloc_node_trace
     0.00%          tail  [kernel.kallsyms]              [k] generic_fillattr
     0.00%         fgrep  [kernel.kallsyms]              [k] dput
     0.00%           app  [kernel.kallsyms]              [k] x86_pmu_enable_all
     0.00%            sh  [kernel.kallsyms]              [k] local_clock
     0.00%         egrep  [kernel.kallsyms]              [k] __wake_up_bit
     0.00%           awk  [kernel.kallsyms]              [k] pgd_alloc
     0.00%         :3071  [kernel.kallsyms]              [k] _raw_spin_lock_irqsave
     0.00%           app  libc-2.12.so                   [.] __GI_fflush
     0.00%       swapper  [ipv6]                         [k] find_match
     0.00%       swapper  [mpt2sas]                      [k] _scsih_io_done
     0.00%           top  [kernel.kallsyms]              [k] find_vma
     0.00%          date  [kernel.kallsyms]              [k] update_process_times
     0.00%   flush-253:8  [kernel.kallsyms]              [k] resched_best_idle
     0.00%           app  [kernel.kallsyms]              [k] strnlen_user
     0.00%            ps  [kernel.kallsyms]              [k] pid_revalidate
     0.00%          perf  [kernel.kallsyms]              [k] security_file_permission
     0.00%           app  [kernel.kallsyms]              [k] __perf_event_header__init_id
     0.00%           awk  [kernel.kallsyms]              [k] retint_swapgs
     0.00%            ps  [kernel.kallsyms]              [k] __list_add
     0.00%           app  bash                           [.] parse_and_execute
     0.00%           app  libstdc++.so.6.0.13            [.] global constructors keyed to system_error.cc
     0.00%       swapper  [kernel.kallsyms]              [k] page_waitqueue
     0.00%            sh  [kernel.kallsyms]              [k] flush_tlb_mm
     0.00%    in.telnetd  [kernel.kallsyms]              [k] netif_skb_features
     0.00%   jbd2/dm-8-8  [jbd2]                         [k] __jbd2_journal_temp_unlink_buffer
     0.00%           top  [e1000e]                       [k] e1000_intr_msi
     0.00%          tail  [ext3]                         [k] ext3_dirty_inode
     0.00%         egrep  [kernel.kallsyms]              [k] path_put
     0.00%          perf  [kernel.kallsyms]              [k] iov_iter_advance
     0.00%           ksh  xinetd                         [.] request_init@plt
     0.00%           awk  [kernel.kallsyms]              [k] find_get_page
     0.00%         sleep  ld-2.12.so                     [.] _dl_map_object_deps
     0.00%          date  libc-2.12.so                   [.] __mktime_internal
     0.00%           app  [kernel.kallsyms]              [k] do_lookup
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] __bitmap_empty
     0.00%            ps  [kernel.kallsyms]              [k] __call_rcu
     0.00%           app  [kernel.kallsyms]              [k] __bitmap_intersects
     0.00%     kjournald  [jbd]                          [k] journal_write_revoke_records
     0.00%           app  [kernel.kallsyms]              [k] rw_verify_area
     0.00%           app  [kernel.kallsyms]              [k] napi_gro_receive
     0.00%            sh  [kernel.kallsyms]              [k] free_pgd_range
     0.00%          date  [kernel.kallsyms]              [k] do_sys_open
     0.00%          date  bash                           [.] find_function
     0.00%           app  libstdc++.so.6.0.13            [.] std::ctype<char>::_M_widen_init() const
     0.00%            ps  [kernel.kallsyms]              [k] PageHuge
     0.00%    in.telnetd  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] native_sched_clock
     0.00%          perf  libpthread-2.12.so             [.] __libc_write
     0.00%            ps  libproc-3.2.8.so               [.] dev_to_tty
     0.00%         egrep  ld-2.12.so                     [.] _dl_init_paths
     0.00%       swapper  [kernel.kallsyms]              [k] raw_local_deliver
     0.00%          perf  [kernel.kallsyms]              [k] getnstimeofday
     0.00%   flush-253:7  [kernel.kallsyms]              [k] native_read_tsc
     0.00%            ps  [kernel.kallsyms]              [k] file_sb_list_del
     0.00%            sh  bash                           [.] command_substitute
     0.00%          perf  [kernel.kallsyms]              [k] cap_inode_need_killpriv
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] blk_rq_map_sg
     0.00%           awk  [kernel.kallsyms]              [k] sched_clock_cpu
     0.00%          date  [kernel.kallsyms]              [k] sys_faccessat
     0.00%          date  [kernel.kallsyms]              [k] do_munmap
     0.00%           app  app                            [.] 
     0.00%           app  libpthread-2.12.so             [.] __pthread_getspecific_internal
     0.00%            sh  bash                           [.] reset_signal_handlers
     0.00%          date  [kernel.kallsyms]              [k] security_inode_follow_link
     0.00%          tail  [kernel.kallsyms]              [k] current_fs_time
     0.00%            sh  libc-2.12.so                   [.] fileno_unlocked
     0.00%           app  [kernel.kallsyms]              [k] mutex_unlock
     0.00%            sh  [kernel.kallsyms]              [k] sys_wait4
     0.00%           awk  [e1000e]                       [k] e1000_receive_skb
     0.00%           top  libc-2.12.so                   [.] __cfree
     0.00%           app  [kernel.kallsyms]              [k] net_rx_action
     0.00%        vmstat  [kernel.kallsyms]              [k] kstat_irqs
     0.00%          tail  [kernel.kallsyms]              [k] mutex_unlock
     0.00%          date  [kernel.kallsyms]              [k] do_sync_read
     0.00%           app  [kernel.kallsyms]              [k] enqueue_task
     0.00%         egrep  libc-2.12.so                   [.] create_cd_newstate
     0.00%     kjournald  [kernel.kallsyms]              [k] cfq_dispatch_requests
     0.00%           top  libc-2.12.so                   [.] __GI___vsnprintf_chk
     0.00%           app  [kernel.kallsyms]              [k] free_uid
     0.00%           app  [kernel.kallsyms]              [k] filp_close
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%           app  [kernel.kallsyms]              [k] x86_pmu_disable
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] internal_add_timer
     0.00%           app  [kernel.kallsyms]              [k] inet_gro_receive
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] first_online_pgdat
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] __phys_addr
     0.00%   flush-253:8  [kernel.kallsyms]              [k] account_page_writeback
     0.00%         :3515  [kernel.kallsyms]              [k] __list_add
     0.00%         fgrep  [kernel.kallsyms]              [k] filemap_fault
     0.00%            sh  [kernel.kallsyms]              [k] copy_user_generic_string
     0.00%          tail  libc-2.12.so                   [.] _IO_file_xsputn_internal
     0.00%            sh  [kernel.kallsyms]              [k] ptep_set_access_flags
     0.00%       swapper  [kernel.kallsyms]              [k] rtnl_notify
     0.00%           app  [kernel.kallsyms]              [k] load_misc_binary
     0.00%           app  [kernel.kallsyms]              [k] dput
     0.00%           app  [kernel.kallsyms]              [k] futex_wake
     0.00%           top  libc-2.12.so                   [.] __mpn_mul_1
     0.00%          ntpd  [kernel.kallsyms]              [k] __dequeue_signal
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] ktime_get_ts
     0.00%            ps  [kernel.kallsyms]              [k] do_sys_open
     0.00%           top  libc-2.12.so                   [.] __GI___vsprintf_chk
     0.00%           app  [kernel.kallsyms]              [k] kmem_cache_alloc_node_trace
     0.00%         :3595  [kernel.kallsyms]              [k] do_exit
     0.00%           awk  ld-2.12.so                     [.] _dl_map_object_from_fd
     0.00%         crond  libc-2.12.so                   [.] _IO_no_init
     0.00%           awk  [kernel.kallsyms]              [k] sched_clock_local
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] schedule
     0.00%           app  app                            [.] 
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __switch_to
     0.00%            sh  libc-2.12.so                   [.] fork
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] cwq_dec_nr_in_flight
     0.00%         egrep  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%           app  [kernel.kallsyms]              [k] invalidate_interrupt2
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] __phys_addr
     0.00%          date  libc-2.12.so                   [.] __GI___sbrk
     0.00%          date  [kernel.kallsyms]              [k] napi_gro_receive
     0.00%           awk  [kernel.kallsyms]              [k] __phys_addr
     0.00%          date  [kernel.kallsyms]              [k] __netif_receive_skb
     0.00%            sh  bash                           [.] xrealloc
     0.00%          ntpd  [kernel.kallsyms]              [k] schedule
     0.00%         :4234  [kernel.kallsyms]              [k] switch_task_namespaces
     0.00%           app  libstdc++.so.6.0.13            [.] std::__num_base::_S_format_float(std::ios_base const&, char*, char)
     0.00%           awk  [kernel.kallsyms]              [k] __dec_zone_state
     0.00%        vmstat  [kernel.kallsyms]              [k] meminfo_proc_show
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] need_to_create_worker
     0.00%           app  [kernel.kallsyms]              [k] handle_mm_fault
     0.00%            sh  libc-2.12.so                   [.] __GI_mbrtowc
     0.00%         egrep  [kernel.kallsyms]              [k] generic_segment_checks
     0.00%            sh  [kernel.kallsyms]              [k] release_thread
     0.00%           awk  libc-2.12.so                   [.] __GI_vfprintf
     0.00%      modprobe  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%   kworker/1:1  [kernel.kallsyms]              [k] transfer_objects
     0.00%           cut  [kernel.kallsyms]              [k] pipe_read
     0.00%           app  [ext3]                         [k] ext3_journal_dirty_data
     0.00%           app  libc-2.12.so                   [.] sysconf
     0.00%           app  libstdc++.so.6.0.13            [.] std::locale::facet::_S_get_c_locale()
     0.00%          date  [kernel.kallsyms]              [k] acl_permission_check
     0.00%            sh  bash                           [.] list_reverse
     0.00%          date  libc-2.12.so                   [.] new_composite_name
     0.00%            ps  libc-2.12.so                   [.] __strstr_sse2
     0.00%          date  [kernel.kallsyms]              [k] __follow_mount_rcu
     0.00%          ntpd  [kernel.kallsyms]              [k] free_hot_cold_page
     0.00%       swapper  [kernel.kallsyms]              [k] complete_signal
     0.00%           app  libgcc_s.so.1                  [.] frame_dummy
     0.00%          date  [ext3]                         [k] ext3_get_acl
     0.00%           app  libc-2.12.so                   [.] _setjmp
     0.00%            sh  [kernel.kallsyms]              [k] transfer_objects
     0.00%           app  [kernel.kallsyms]              [k] hrtimer_interrupt
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] clear_page_dirty_for_io
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] add_timer
     0.00%           app  [kernel.kallsyms]              [k] up_read
     0.00%           app  [kernel.kallsyms]              [k] getnstimeofday
     0.00%           ksh  [kernel.kallsyms]              [k] cap_file_permission
     0.00%            ps  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           top  [kernel.kallsyms]              [k] ptrace_may_access
     0.00%           ksh  [kernel.kallsyms]              [k] tty_unthrottle
     0.00%           app  [kernel.kallsyms]              [k] __vma_link_file
     0.00%      modprobe  libc-2.12.so                   [.] __GI_strpbrk
     0.00%         sleep  libc-2.12.so                   [.] _IO_setb_internal
     0.00%           awk  ld-2.12.so                     [.] _dl_next_tls_modid
     0.00%         sleep  [kernel.kallsyms]              [k] resched_task
     0.00%            ps  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%    in.telnetd  [kernel.kallsyms]              [k] ttwu_activate
     0.00%       swapper  [kernel.kallsyms]              [k] call_rcu_sched
     0.00%       swapper  [kernel.kallsyms]              [k] __blk_run_queue
     0.00%          date  [kernel.kallsyms]              [k] file_ra_state_init
     0.00%         :3711  ld-2.12.so                     [.] do_lookup_x
     0.00%          perf  [kernel.kallsyms]              [k] unmap_underlying_metadata
     0.00%         sleep  libc-2.12.so                   [.] __strcmp_sse2
     0.00%         egrep  libc-2.12.so                   [.] _int_free
     0.00%           top  [kernel.kallsyms]              [k] tty_ioctl
     0.00%           ksh  [kernel.kallsyms]              [k] sys_faccessat
     0.00%           app  [kernel.kallsyms]              [k] dma_issue_pending_all
     0.00%           top  [kernel.kallsyms]              [k] __call_rcu
     0.00%           app  [kernel.kallsyms]              [k] dyntick_save_progress_counter
     0.00%         crond  [kernel.kallsyms]              [k] put_page
     0.00%            ps  [kernel.kallsyms]              [k] path_lookupat
     0.00%            sh  ld-2.12.so                     [.] do_lookup_x
     0.00%           cut  [kernel.kallsyms]              [k] __bitmap_empty
     0.00%      modprobe  [kernel.kallsyms]              [k] release_pages
     0.00%           app  [kernel.kallsyms]              [k] run_local_timers
     0.00%           app  [kernel.kallsyms]              [k] __bitmap_subset
     0.00%           ksh  ld-2.12.so                     [.] do_lookup_x
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] generic_make_request
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] memcpy
     0.00%          perf  [kernel.kallsyms]              [k] kmem_getpages
     0.00%         :3696  [kernel.kallsyms]              [k] complete_signal
     0.00%            ps  [kernel.kallsyms]              [k] fsnotify
     0.00%           awk  [kernel.kallsyms]              [k] mntget
     0.00%           app  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%            ps  [kernel.kallsyms]              [k] __follow_mount_rcu
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] __memset
     0.00%           awk  ld-2.12.so                     [.] dl_main
     0.00%          perf  [kernel.kallsyms]              [k] poll_schedule_timeout
     0.00%          date  [kernel.kallsyms]              [k] __put_anon_vma
     0.00%            sh  libc-2.12.so                   [.] memcpy
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] _raw_spin_unlock_irqrestore
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] __list_del_entry
     0.00%            sh  [kernel.kallsyms]              [k] exit_intr
     0.00%           app  [kernel.kallsyms]              [k] prepare_bprm_creds
     0.00%           app  [kernel.kallsyms]              [k] end_page_writeback
     0.00%   flush-253:8  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%           top  [kernel.kallsyms]              [k] activate_task
     0.00%           rcp  ld-2.12.so                     [.] _dl_lookup_symbol_x
     0.00%            sh  [kernel.kallsyms]              [k] unlock_page
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] tty_ldisc_ref
     0.00%         sleep  libc-2.12.so                   [.] __GI_strtod_l
     0.00%       swapper  [kernel.kallsyms]              [k] __sigqueue_alloc
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] next_online_pgdat
     0.00%           awk  [kernel.kallsyms]              [k] do_last
     0.00%         sleep  [kernel.kallsyms]              [k] mmap_region
     0.00%          tail  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%          perf  [kernel.kallsyms]              [k] blk_finish_plug
     0.00%   jbd2/dm-8-8  [jbd2]                         [k] jbd2_journal_get_descriptor_buffer
     0.00%            ps  [kernel.kallsyms]              [k] unmap_vmas
     0.00%           app  [ext3]                         [k] ext3_get_inode_loc
     0.00%           app  [kernel.kallsyms]              [k] ack_apic_edge
     0.00%           app  [kernel.kallsyms]              [k] __mark_inode_dirty
     0.00%          date  [kernel.kallsyms]              [k] find_mergeable_anon_vma
     0.00%          ntpd  [kernel.kallsyms]              [k] poll_select_copy_remaining
     0.00%           app  [ipv6]                         [k] rt6_bind_peer
     0.00%           app  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%           app  [kernel.kallsyms]              [k] exit_mm
     0.00%           app  libc-2.12.so                   [.] _IO_file_xsputn_internal
     0.00%         egrep  [kernel.kallsyms]              [k] unlink_file_vma
     0.00%     kjournald  [sd_mod]                       [k] sd_prep_fn
     0.00%    in.telnetd  [kernel.kallsyms]              [k] sched_clock_local
     0.00%          date  [kernel.kallsyms]              [k] perf_event_mmap_ctx
     0.00%          date  [kernel.kallsyms]              [k] free_fs_struct
     0.00%          ntpd  ntpd                           [.] ntpdmain
     0.00%            sh  [kernel.kallsyms]              [k] ret_from_fork
     0.00%           app  [kernel.kallsyms]              [k] mntget
     0.00%           awk  libc-2.12.so                   [.] memcpy
     0.00%            sh  [kernel.kallsyms]              [k] retint_swapgs
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] set_task_cpu
     0.00%            ps  ld-2.12.so                     [.] _dl_important_hwcaps
     0.00%         sleep  [kernel.kallsyms]              [k] __clear_user
     0.00%         sleep  [kernel.kallsyms]              [k] __lru_cache_add
     0.00%          date  [kernel.kallsyms]              [k] generic_file_aio_read
     0.00%            sh  [kernel.kallsyms]              [k] shrink_dentry_list
     0.00%          ntpd  ntpd                           [.] kod_proto
     0.00%         fgrep  bash                           [.] 0x495d6         
     0.00%           awk  [kernel.kallsyms]              [k] kmem_cache_alloc_node
     0.00%   jbd2/dm-8-8  [jbd2]                         [k] jbd2_journal_write_metadata_buffer
     0.00%         egrep  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%          date  [kernel.kallsyms]              [k] perf_event_comm_ctx
     0.00%            sh  [kernel.kallsyms]              [k] __page_cache_release
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] read_tsc
     0.00%          tail  [kernel.kallsyms]              [k] __zone_watermark_ok
     0.00%      kthreadd  [kernel.kallsyms]              [k] blk_queue_bounce
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] tty_buffer_free
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __ip_local_out
     0.00%         egrep  [kernel.kallsyms]              [k] native_sched_clock
     0.00%           app  app                            [.] 
     0.00%          date  [kernel.kallsyms]              [k] schedule
     0.00%           app  [kernel.kallsyms]              [k] try_to_wake_up
     0.00%           cut  [kernel.kallsyms]              [k] tty_ldisc_ref_wait
     0.00%   flush-253:8  [mpt2sas]                      [k] _base_add_sg_single_64
     0.00%           app  [kernel.kallsyms]              [k] cap_msg_queue_msgsnd
     0.00%           ksh  [kernel.kallsyms]              [k] xfrm_lookup
     0.00%         egrep  ld-2.12.so                     [.] strlen
     0.00%          date  [kernel.kallsyms]              [k] inet_gro_receive
     0.00%      rsyslogd  [kernel.kallsyms]              [k] cap_inode_need_killpriv
     0.00%           app  [kernel.kallsyms]              [k] handle_mm_fault
     0.00%            ps  [kernel.kallsyms]              [k] __task_pid_nr_ns
     0.00%           top  [kernel.kallsyms]              [k] in_group_p
     0.00%          tail  libc-2.12.so                   [.] __GI___mempcpy
     0.00%         egrep  [kernel.kallsyms]              [k] dec_zone_page_state
     0.00%          date  libc-2.12.so                   [.] __libc_global_ctors
     0.00%       swapper  [kernel.kallsyms]              [k] put_cred_rcu
     0.00%           app  [kernel.kallsyms]              [k] __copy_skb_header
     0.00%           app  libc-2.12.so                   [.] __cfree
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] worker_thread
     0.00%          date  libc-2.12.so                   [.] __GI_ftello
     0.00%           app  [kernel.kallsyms]              [k] system_call_fastpath
     0.00%           app  [kernel.kallsyms]              [k] account_process_tick
     0.00%   flush-253:8  [kernel.kallsyms]              [k] _cond_resched
     0.00%           app  libc-2.12.so                   [.] _IO_old_init
     0.00%         egrep  [kernel.kallsyms]              [k] ima_file_free
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] skb_push
     0.00%         sleep  libc-2.12.so                   [.] ptmalloc_unlock_all2
     0.00%          perf  [kernel.kallsyms]              [k] dequeue_task
     0.00%     kjournald  [kernel.kallsyms]              [k] elv_rb_del
     0.00%           awk  [kernel.kallsyms]              [k] __pagevec_free
     0.00%            sh  [kernel.kallsyms]              [k] resched_best_mask
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_ios<char, std::char_traits<char> >::init(std::basic_streambuf<char, std::char_traits<char> >*)
     0.00%           app  libc-2.12.so                   [.] __GI___mempcpy
     0.00%         egrep  libc-2.12.so                   [.] parse_reg_exp
     0.00%           app  [kernel.kallsyms]              [k] free_fdtable_rcu
     0.00%      kthreadd  [kernel.kallsyms]              [k] round_jiffies_relative
     0.00%           app  [kernel.kallsyms]              [k] __d_free
     0.00%           top  [kernel.kallsyms]              [k] security_file_alloc
     0.00%           awk  [kernel.kallsyms]              [k] ima_must_measure
     0.00%   kworker/6:0  [e1000e]                       [k] e1000e_get_laa_state_82571
     0.00%          date  ld-2.12.so                     [.] _dl_map_object
     0.00%   flush-253:7  [kernel.kallsyms]              [k] gart_map_page
     0.00%           app  [kernel.kallsyms]              [k] mmap_region
     0.00%           app  [kernel.kallsyms]              [k] system_call
     0.00%          ntpd  [kernel.kallsyms]              [k] _cond_resched
     0.00%           app  librt-2.12.so                  [.] frame_dummy
     0.00%           app  [kernel.kallsyms]              [k] __qdisc_run
     0.00%           app  [kernel.kallsyms]              [k] __delayacct_blkio_end
     0.00%          perf  [kernel.kallsyms]              [k] schedule_hrtimeout_range_clock
     0.00%   jbd2/dm-8-8  [jbd2]                         [k] jbd2_journal_add_journal_head
     0.00%           app  [kernel.kallsyms]              [k] __wake_up_bit
     0.00%          perf  [ext4]                         [k] ext4_xattr_get
     0.00%         sleep  ld-2.12.so                     [.] _dl_fini
     0.00%           app  [kernel.kallsyms]              [k] fput
     0.00%        vmstat  libc-2.12.so                   [.] __strlen_sse2
     0.00%       swapper  [kernel.kallsyms]              [k] key_put
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] __switch_to
     0.00%            sh  [kernel.kallsyms]              [k] strnlen_user
     0.00%           app  [ext4]                         [k] ext4_check_acl
     0.00%           ksh  [kernel.kallsyms]              [k] handle_mm_fault
     0.00%           top  [kernel.kallsyms]              [k] ns_to_timeval
     0.00%           app  [kernel.kallsyms]              [k] wake_up_worker
     0.00%           app  [kernel.kallsyms]              [k] resched_best_mask
     0.00%           app  [kernel.kallsyms]              [k] do_exit
     0.00%           app  [kernel.kallsyms]              [k] local_bh_enable_ip
     0.00%           app  app                            [.] 
     0.00%         sleep  [kernel.kallsyms]              [k] ___pud_free_tlb
     0.00%           app  libstdc++.so.6.0.13            [.] std::__use_cache<std::__numpunct_cache<char> >::operator()(std::locale const&) const
     0.00%            sh  libc-2.12.so                   [.] ptmalloc_unlock_all2
     0.00%          perf  [kernel.kallsyms]              [k] radix_tree_preload
     0.00%           app  [kernel.kallsyms]              [k] __put_anon_vma
     0.00%  kworker/10:1  [kernel.kallsyms]              [k] queue_delayed_work_on
     0.00%          date  [kernel.kallsyms]              [k] error_entry
     0.00%           top  [kernel.kallsyms]              [k] strncpy
     0.00%        vmstat  libc-2.12.so                   [.] __rawmemchr_sse2
     0.00%           app  libc-2.12.so                   [.] memcpy
     0.00%         egrep  [kernel.kallsyms]              [k] dma_issue_pending_all
     0.00%           app  [kernel.kallsyms]              [k] sys_write
     0.00%           app  libstdc++.so.6.0.13            [.] global constructors keyed to bitmap_allocator.cc
     0.00%         egrep  ld-2.12.so                     [.] _dl_load_cache_lookup
     0.00%         egrep  [kernel.kallsyms]              [k] ip_route_input_common
     0.00%         sleep  [ext4]                         [k] ext4_check_acl
     0.00%            ps  libc-2.12.so                   [.] __strftime_l
     0.00%           awk  [kernel.kallsyms]              [k] schedule
     0.00%          tail  [kernel.kallsyms]              [k] pty_write_room
     0.00%           app  libpthread-2.12.so             [.] __write_nocancel
     0.00%          perf  [kernel.kallsyms]              [k] sched_clock_local
     0.00%            ps  [kernel.kallsyms]              [k] _cond_resched
     0.00%           app  [kernel.kallsyms]              [k] update_process_times
     0.00%           app  [kernel.kallsyms]              [k] error_exit
     0.00%            ps  [kernel.kallsyms]              [k] dput
     0.00%           top  [kernel.kallsyms]              [k] sys_lseek
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] internal_add_timer
     0.00%          date  [kernel.kallsyms]              [k] native_read_tsc
     0.00%           app  libpthread-2.12.so             [.] __pthread_once_internal
     0.00%        vmstat  [kernel.kallsyms]              [k] cap_file_permission
     0.00%         :3859  [kernel.kallsyms]              [k] _raw_spin_lock_irq
     0.00%           awk  [kernel.kallsyms]              [k] cache_alloc_refill
     0.00%         egrep  [kernel.kallsyms]              [k] release_pages
     0.00%           app  [kernel.kallsyms]              [k] scsi_finish_command
     0.00%         egrep  [kernel.kallsyms]              [k] get_empty_filp
     0.00%           awk  [kernel.kallsyms]              [k] update_cpu_clock
     0.00%          date  [kernel.kallsyms]              [k] search_binary_handler
     0.00%         fgrep  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%            ps  [kernel.kallsyms]              [k] filemap_fault
     0.00%     kjournald  [kernel.kallsyms]              [k] schedule
     0.00%            sh  [kernel.kallsyms]              [k] fsnotify
     0.00%           app  [kernel.kallsyms]              [k] prio_tree_insert
     0.00%           app  librt-2.12.so                  [.] __GI_clock_gettime
     0.00%           ksh  libc-2.12.so                   [.] _int_malloc
     0.00%          perf  [kernel.kallsyms]              [k] current_fs_time
     0.00%           app  app                            [.] 
     0.00%            sh  ld-2.12.so                     [.] strlen
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] __rmqueue
     0.00%       swapper  [kernel.kallsyms]              [k] bio_free
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] page_mkclean
     0.00%         egrep  [kernel.kallsyms]              [k] perf_output_begin
     0.00%       swapper  [kernel.kallsyms]              [k] clear_bdi_congested
     0.00%         fgrep  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%           app  [kernel.kallsyms]              [k] do_mmap_pgoff
     0.00%           awk  [kernel.kallsyms]              [k] ptep_set_access_flags
     0.00%          perf  [kernel.kallsyms]              [k] get_pageblock_flags_group
     0.00%         egrep  [kernel.kallsyms]              [k] __alloc_pages_nodemask
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] __list_add
     0.00%            sh  bash                           [.] dispose_words
     0.00%          perf  [kernel.kallsyms]              [k] mutex_lock
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] resched_task
     0.00%           app  app                            [.] 
     0.00%            ps  [kernel.kallsyms]              [k] proc_pident_lookup
     0.00%        vmstat  libc-2.12.so                   [.] __strchrnul
     0.00%          date  [kernel.kallsyms]              [k] arch_setup_additional_pages
     0.00%           top  [kernel.kallsyms]              [k] mmput
     0.00%   kworker/0:1  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.00%   flush-253:8  [kernel.kallsyms]              [k] find_get_page
     0.00%          tail  [kernel.kallsyms]              [k] tty_write_room
     0.00%      kthreadd  [kernel.kallsyms]              [k] lock_timer_base
     0.00%           app  [kernel.kallsyms]              [k] timespec_trunc
     0.00%          date  [kernel.kallsyms]              [k] exit_mmap
     0.00%           top  [kernel.kallsyms]              [k] locks_wake_up_blocks
     0.00%           app  [kernel.kallsyms]              [k] wake_up_bit
     0.00%           app  [kernel.kallsyms]              [k] unlock_page
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] set_task_cpu
     0.00%          perf  [jbd2]                         [k] jbd2_journal_put_journal_head
     0.00%           app  [kernel.kallsyms]              [k] try_preempt
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] next_zone
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] sock_def_readable
     0.00%           awk  libc-2.12.so                   [.] _int_malloc
     0.00%    in.telnetd  [kernel.kallsyms]              [k] dev_hard_start_xmit
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __queue_work
     0.00%          date  libc-2.12.so                   [.] _IO_link_in_internal
     0.00%         sleep  [kernel.kallsyms]              [k] arch_vma_name
     0.00%           app  [kernel.kallsyms]              [k] groups_search
     0.00%           app  [kernel.kallsyms]              [k] pc_user_time
     0.00%          date  [kernel.kallsyms]              [k] __split_vma
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] schedule
     0.00%          date  libc-2.12.so                   [.] __GI_setlocale
     0.00%          ntpd  [kernel.kallsyms]              [k] get_page_from_freelist
     0.00%           cut  libc-2.12.so                   [.] _IO_new_file_write
     0.00%           app  [kernel.kallsyms]              [k] timespec_trunc
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] memcpy
     0.00%           app  [kernel.kallsyms]              [k] region_chg
     0.00%            ps  [kernel.kallsyms]              [k] file_ra_state_init
     0.00%           app  [kernel.kallsyms]              [k] scsi_io_completion
     0.00%           app  libc-2.12.so                   [.] __GI_____strtoll_l_internal
     0.00%            ps  [kernel.kallsyms]              [k] exit_mmap
     0.00%           ksh  [kernel.kallsyms]              [k] clear_page_c
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] __set_page_dirty_nobuffers
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] transfer_objects
     0.00%         sleep  [kernel.kallsyms]              [k] PageHuge
     0.00%           app  [kernel.kallsyms]              [k] save_i387_xstate
     0.00%         sleep  [kernel.kallsyms]              [k] load_misc_binary
     0.00%            ps  libc-2.12.so                   [.] __GI_getenv
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __pollwait
     0.00%          ntpd  libc-2.12.so                   [.] __GI_memset
     0.00%       swapper  [kernel.kallsyms]              [k] __lock_task_sighand
     0.00%          perf  [kernel.kallsyms]              [k] __bitmap_empty
     0.00%           app  libstdc++.so.6.0.13            [.] global constructors keyed to locale_inst.cc
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] list_del
     0.00%           app  ld-2.12.so                     [.] strcmp
     0.00%            ps  libc-2.12.so                   [.] __mmap
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] queue_delayed_work
     0.00%            ps  [kernel.kallsyms]              [k] get_pid_task
     0.00%   flush-253:8  [kernel.kallsyms]              [k] scsi_request_fn
     0.00%          date  libc-2.12.so                   [.] _nl_find_locale
     0.00%   kworker/4:1  [kernel.kallsyms]              [k] kmem_cache_free
     0.00%         egrep  [kernel.kallsyms]              [k] prio_tree_replace
     0.00%           app  [ext3]                         [k] ext3_dirty_inode
     0.00%    in.telnetd  [kernel.kallsyms]              [k] ip_queue_xmit
     0.00%      kthreadd  [kernel.kallsyms]              [k] __blk_recalc_rq_segments
     0.00%           app  [kernel.kallsyms]              [k] __inc_zone_state
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] __list_add
     0.00%   kworker/9:1  [kernel.kallsyms]              [k] resched_best_mask
     0.00%           app  [kernel.kallsyms]              [k] free_pages_prepare
     0.00%     kjournald  [kernel.kallsyms]              [k] __list_add
     0.00%          perf  [kernel.kallsyms]              [k] __kmalloc_node_track_caller
     0.00%         egrep  [kernel.kallsyms]              [k] device_not_available
     0.00%            sh  [kernel.kallsyms]              [k] locks_remove_posix
     0.00%         egrep  [kernel.kallsyms]              [k] unlink_anon_vmas
     0.00%   kworker/6:0  [kernel.kallsyms]              [k] sched_clock_local
     0.00%           app  [kernel.kallsyms]              [k] prepare_bprm_creds
     0.00%          ntpd  [e1000e]                       [k] e1000_maybe_stop_tx
     0.00%          ntpd  ntpd                           [.] clock_filter
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] __list_del_entry
     0.00%           app  app                            [.] 
     0.00%    in.telnetd  [kernel.kallsyms]              [k] sock_aio_write
     0.00%         fgrep  [kernel.kallsyms]              [k] alloc_fd
     0.00%   jbd2/dm-8-8  [kernel.kallsyms]              [k] __mark_inode_dirty
     0.00%   kworker/7:1  [e1000e]                       [k] e1000_clean_rx_irq
     0.00%       swapper  [kernel.kallsyms]              [k] delayed_work_timer_fn
     0.00%           app  [kernel.kallsyms]              [k] mark_page_accessed
     0.00%      kthreadd  [kernel.kallsyms]              [k] transfer_objects
     0.00%           app  app                            [.] 
     0.00%           app  [kernel.kallsyms]              [k] enqueue_hrtimer
     0.00%    in.telnetd  [kernel.kallsyms]              [k] __sk_dst_check
     0.00%         egrep  [kernel.kallsyms]              [k] do_sigaction
     0.00%           app  app                            [.] 
     0.00%           app  libstdc++.so.6.0.13            [.] std::basic_string<char, std::char_traits<char>, std::allocator<char> >::~basic_string()
     0.00%          tail  [kernel.kallsyms]              [k] __cond_resched
     0.00%          tail  [kernel.kallsyms]              [k] put_pid
     0.00%   flush-253:7  [kernel.kallsyms]              [k] kobject_get
     0.00%   flush-253:8  [kernel.kallsyms]              [k] cfq_merge
     0.00%           cut  [kernel.kallsyms]              [k] vfs_write
     0.00%      kthreadd  [kernel.kallsyms]              [k] mod_timer
     0.00%       swapper  [kernel.kallsyms]              [k] wq_worker_waking_up
     0.00%       swapper  [kernel.kallsyms]              [k] cascade
     0.00%          tail  [kernel.kallsyms]              [k] mutex_lock
     0.00%    in.telnetd  [kernel.kallsyms]              [k] insert_wq_barrier
     0.00%      kthreadd  [kernel.kallsyms]              [k] worker_enter_idle
     0.00%          perf  [kernel.kallsyms]              [k] radix_tree_lookup
     0.00%   kworker/3:1  [kernel.kallsyms]              [k] mod_timer
     0.00%            ps  [kernel.kallsyms]              [k] _raw_spin_lock
     0.00%         crond  [kernel.kallsyms]              [k] handle_pte_fault
     0.00%      kthreadd  [edac_core]                    [k] edac_pci_get_check_errors
     0.00%   kworker/7:1  [kernel.kallsyms]              [k] try_to_wake_up
     0.00%    in.telnetd  [kernel.kallsyms]              [k] pty_chars_in_buffer
     0.00%  ksoftirqd/11  [kernel.kallsyms]              [k] __do_softirq
     0.00%          tail  [kernel.kallsyms]              [k] schedule_work
     0.00%          tail  [kernel.kallsyms]              [k] n_tty_write
     0.00%   kworker/2:1  [kernel.kallsyms]              [k] lock_timer_base
     0.00%           ksh  [kernel.kallsyms]              [k] kmem_cache_alloc
     0.00%   ksoftirqd/2  [kernel.kallsyms]              [k] __perf_event_task_sched_out
     0.00%           app  app                            [.] 
     0.00%   kworker/8:1  [kernel.kallsyms]              [k] resched_task
     0.00%           app  [kernel.kallsyms]              [k] find_get_page


#
# (For a higher level overview, try: perf report --sort comm,dso)
#

--=====================_-1956235454==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="config_2.6.39.4_bfs.txt"

#
# Automatically generated make config: don't edit
# Linux/x86_64 2.6.39.4 Kernel Configuration
# Tue Oct  4 20:16:18 2011
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_GENERIC_GPIO=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
# CONFIG_KTIME_SCALAR is not set
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y

#
# General setup
#
CONFIG_SCHED_BFS=y
CONFIG_EXPERIMENTAL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_SWAP is not set
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_FHANDLE is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_HAVE_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_FANOUT=64
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_RCU_FAST_NO_HZ is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=19
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
# CONFIG_CGROUPS is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
# CONFIG_NET_NS is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_EXTRA_PASS=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_PERF_COUNTERS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=m
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_KRETPROBES=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODVERSIONS=y
CONFIG_MODULE_SRCVERSION_ALL=y
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
CONFIG_INLINE_SPIN_UNLOCK=y
# CONFIG_INLINE_SPIN_UNLOCK_BH is not set
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
# CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_READ_TRYLOCK is not set
# CONFIG_INLINE_READ_LOCK is not set
# CONFIG_INLINE_READ_LOCK_BH is not set
# CONFIG_INLINE_READ_LOCK_IRQ is not set
# CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
CONFIG_INLINE_READ_UNLOCK=y
# CONFIG_INLINE_READ_UNLOCK_BH is not set
CONFIG_INLINE_READ_UNLOCK_IRQ=y
# CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_WRITE_TRYLOCK is not set
# CONFIG_INLINE_WRITE_LOCK is not set
# CONFIG_INLINE_WRITE_LOCK_BH is not set
# CONFIG_INLINE_WRITE_LOCK_IRQ is not set
# CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
CONFIG_INLINE_WRITE_UNLOCK=y
# CONFIG_INLINE_WRITE_UNLOCK_BH is not set
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
# CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
CONFIG_X86_UV=y
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
CONFIG_PARAVIRT_GUEST=y
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PRIVILEGED_GUEST=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_MAX_DOMAIN_MEMORY=128
CONFIG_XEN_SAVE_RESTORE=y
CONFIG_XEN_DEBUG_FS=y
# CONFIG_XEN_DEBUG is not set
CONFIG_KVM_CLOCK=y
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=7
CONFIG_X86_CMPXCHG=y
CONFIG_CMPXCHG_LOCAL=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
# CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT is not set
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_STATS=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_IOMMU_API=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=4096
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_I8K=m
CONFIG_MICROCODE=m
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=1
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_EFI=y
# CONFIG_SECCOMP is not set
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_POWER_METER=m
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_SBS=m
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=m
CONFIG_CPU_FREQ_DEBUG=y
CONFIG_CPU_FREQ_STAT=m
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=m
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m

#
# CPUFreq processor drivers
#
# CONFIG_X86_PCC_CPUFREQ is not set
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_POWERNOW_K8=m
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=m

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=m
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=m

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_DMAR=y
# CONFIG_DMAR_DEFAULT_ON is not set
CONFIG_DMAR_FLOPPY_WA=y
CONFIG_INTR_REMAP=y
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=m
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIE_PME=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_STUB=y
CONFIG_XEN_PCIDEV_FRONTEND=y
CONFIG_HT_IRQ=y
CONFIG_PCI_IOV=y
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=m
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
CONFIG_PD6729=m
# CONFIG_I82092 is not set
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_FAKE=m
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=m
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=m
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_UNIX=y
CONFIG_XFRM=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=m
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_IP_MROUTE=y
# CONFIG_IP_MROUTE_MULTIPLE_TABLES is not set
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
CONFIG_INET_IPCOMP=m
CONFIG_INET_XFRM_TUNNEL=m
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=m
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
CONFIG_TCP_CONG_YEAH=m
CONFIG_TCP_CONG_ILLINOIS=m
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=m
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
CONFIG_INET6_IPCOMP=m
CONFIG_IPV6_MIP6=m
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
CONFIG_IPV6_SIT=m
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
CONFIG_IPV6_MULTIPLE_TABLES=y
# CONFIG_IPV6_SUBTREES is not set
CONFIG_IPV6_MROUTE=y
# CONFIG_IPV6_MROUTE_MULTIPLE_TABLES is not set
CONFIG_IPV6_PIMSM_V2=y
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CONNTRACK_TIMESTAMP is not set
CONFIG_NF_CT_PROTO_DCCP=m
CONFIG_NF_CT_PROTO_GRE=m
CONFIG_NF_CT_PROTO_SCTP=m
CONFIG_NF_CT_PROTO_UDPLITE=m
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_BROADCAST=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
# CONFIG_NF_CONNTRACK_SNMP is not set
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SANE=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
CONFIG_NF_CT_NETLINK=m
CONFIG_NETFILTER_TPROXY=m
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=m
CONFIG_NETFILTER_XT_CONNMARK=m

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_CHECKSUM is not set
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
# CONFIG_NETFILTER_XT_TARGET_CT is not set
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_HL=m
# CONFIG_NETFILTER_XT_TARGET_IDLETIMER is not set
CONFIG_NETFILTER_XT_TARGET_LED=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
CONFIG_NETFILTER_XT_TARGET_RATEEST=m
# CONFIG_NETFILTER_XT_TARGET_TEE is not set
CONFIG_NETFILTER_XT_TARGET_TPROXY=m
CONFIG_NETFILTER_XT_TARGET_TRACE=m
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m

#
# Xtables matches
#
# CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=m
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
# CONFIG_NETFILTER_XT_MATCH_CPU is not set
CONFIG_NETFILTER_XT_MATCH_DCCP=m
# CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
CONFIG_NETFILTER_XT_MATCH_HL=m
CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
# CONFIG_NETFILTER_XT_MATCH_IPVS is not set
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_OSF=m
CONFIG_NETFILTER_XT_MATCH_OWNER=m
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
CONFIG_NETFILTER_XT_MATCH_RATEEST=m
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_RECENT=m
CONFIG_NETFILTER_XT_MATCH_SCTP=m
CONFIG_NETFILTER_XT_MATCH_SOCKET=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
CONFIG_NETFILTER_XT_MATCH_TIME=m
CONFIG_NETFILTER_XT_MATCH_U32=m
# CONFIG_IP_SET is not set
CONFIG_IP_VS=m
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
# CONFIG_IP_VS_PROTO_SCTP is not set

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
# CONFIG_IP_VS_PE_SIP is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
CONFIG_NF_CONNTRACK_IPV4=m
# CONFIG_NF_CONNTRACK_PROC_COMPAT is not set
CONFIG_IP_NF_QUEUE=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_LOG=m
CONFIG_IP_NF_TARGET_ULOG=m
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_NF_NAT_PROTO_DCCP=m
CONFIG_NF_NAT_PROTO_GRE=m
CONFIG_NF_NAT_PROTO_UDPLITE=m
CONFIG_NF_NAT_PROTO_SCTP=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_NF_NAT_SIP=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_SECURITY=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=m
CONFIG_NF_CONNTRACK_IPV6=m
CONFIG_IP6_NF_QUEUE=m
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_AH=m
CONFIG_IP6_NF_MATCH_EUI64=m
CONFIG_IP6_NF_MATCH_FRAG=m
CONFIG_IP6_NF_MATCH_OPTS=m
CONFIG_IP6_NF_MATCH_HL=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_MATCH_MH=m
CONFIG_IP6_NF_MATCH_RT=m
CONFIG_IP6_NF_TARGET_HL=m
CONFIG_IP6_NF_TARGET_LOG=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_MANGLE=m
CONFIG_IP6_NF_RAW=m
CONFIG_IP6_NF_SECURITY=m
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_EBT_BROUTE=m
CONFIG_BRIDGE_EBT_T_FILTER=m
CONFIG_BRIDGE_EBT_T_NAT=m
CONFIG_BRIDGE_EBT_802_3=m
CONFIG_BRIDGE_EBT_AMONG=m
CONFIG_BRIDGE_EBT_ARP=m
CONFIG_BRIDGE_EBT_IP=m
CONFIG_BRIDGE_EBT_IP6=m
CONFIG_BRIDGE_EBT_LIMIT=m
CONFIG_BRIDGE_EBT_MARK=m
CONFIG_BRIDGE_EBT_PKTTYPE=m
CONFIG_BRIDGE_EBT_STP=m
CONFIG_BRIDGE_EBT_VLAN=m
CONFIG_BRIDGE_EBT_ARPREPLY=m
CONFIG_BRIDGE_EBT_DNAT=m
CONFIG_BRIDGE_EBT_MARK_T=m
CONFIG_BRIDGE_EBT_REDIRECT=m
CONFIG_BRIDGE_EBT_SNAT=m
CONFIG_BRIDGE_EBT_LOG=m
CONFIG_BRIDGE_EBT_ULOG=m
CONFIG_BRIDGE_EBT_NFLOG=m
CONFIG_IP_DCCP=m
CONFIG_INET_DCCP_DIAG=m

#
# DCCP CCIDs Configuration (EXPERIMENTAL)
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_NET_DCCPPROBE=m
CONFIG_IP_SCTP=m
# CONFIG_NET_SCTPPROBE is not set
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_HMAC_NONE is not set
# CONFIG_SCTP_HMAC_SHA1 is not set
CONFIG_SCTP_HMAC_MD5=y
CONFIG_RDS=m
CONFIG_RDS_RDMA=m
CONFIG_RDS_TCP=m
# CONFIG_RDS_DEBUG is not set
# CONFIG_TIPC is not set
CONFIG_ATM=m
CONFIG_ATM_CLIP=m
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=m
# CONFIG_ATM_MPOA is not set
CONFIG_ATM_BR2684=m
# CONFIG_ATM_BR2684_IPFILTER is not set
# CONFIG_L2TP is not set
CONFIG_STP=m
CONFIG_GARP=m
CONFIG_BRIDGE=m
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=m
CONFIG_VLAN_8021Q_GVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=m
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
CONFIG_PHONET=m
CONFIG_IEEE802154=m
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_ATM=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_MULTIQ=m
CONFIG_NET_SCH_RED=m
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
CONFIG_NET_SCH_DRR=m
# CONFIG_NET_SCH_MQPRIO is not set
# CONFIG_NET_SCH_CHOKE is not set
CONFIG_NET_SCH_INGRESS=m

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
CONFIG_NET_CLS_FLOW=m
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
CONFIG_NET_ACT_IPT=m
CONFIG_NET_ACT_NAT=m
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
CONFIG_NET_ACT_SKBEDIT=m
# CONFIG_NET_ACT_CSUM is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y

#
# Network testing
#
CONFIG_NET_PKTGEN=m
# CONFIG_NET_TCPPROBE is not set
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
CONFIG_CAN=m
CONFIG_CAN_RAW=m
CONFIG_CAN_BCM=m

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=m
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=m
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_PCH_CAN is not set
CONFIG_CAN_SJA1000=m
CONFIG_CAN_SJA1000_PLATFORM=m
CONFIG_CAN_EMS_PCI=m
CONFIG_CAN_KVASER_PCI=m
# CONFIG_CAN_PLX_PCI is not set
# CONFIG_CAN_C_CAN is not set

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=m
# CONFIG_CAN_ESD_USB2 is not set
# CONFIG_CAN_SOFTING is not set
CONFIG_CAN_DEBUG_DEVICES=y
# CONFIG_IRDA is not set
CONFIG_BT=m
# CONFIG_BT_L2CAP is not set
# CONFIG_BT_SCO is not set

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=m
CONFIG_BT_HCIBTSDIO=m
CONFIG_BT_HCIUART=m
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
# CONFIG_BT_HCIUART_ATH3K is not set
CONFIG_BT_HCIUART_LL=y
CONFIG_BT_HCIBCM203X=m
CONFIG_BT_HCIBPA10X=m
CONFIG_BT_HCIBFUSB=m
CONFIG_BT_HCIDTL1=m
CONFIG_BT_HCIBT3C=m
CONFIG_BT_HCIBLUECARD=m
CONFIG_BT_HCIBTUART=m
CONFIG_BT_HCIVHCI=m
CONFIG_BT_MRVL=m
CONFIG_BT_MRVL_SDIO=m
# CONFIG_BT_ATH3K is not set
# CONFIG_AF_RXRPC is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=m
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_REG_DEBUG is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_WEXT=y
CONFIG_WIRELESS_EXT_SYSFS=y
CONFIG_LIB80211=m
CONFIG_LIB80211_CRYPT_WEP=m
CONFIG_LIB80211_CRYPT_CCMP=m
CONFIG_LIB80211_CRYPT_TKIP=m
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=m
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
# CONFIG_MAC80211_MESH is not set
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_WIMAX=m
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
CONFIG_NET_9P=m
CONFIG_NET_9P_RDMA=m
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_SYS_HYPERVISOR=y
CONFIG_ARCH_NO_SYSDEV_OPS=y
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=y
# CONFIG_MTD_DEBUG is not set
# CONFIG_MTD_TESTS is not set
CONFIG_MTD_PARTITIONS=y
CONFIG_MTD_REDBOOT_PARTS=m
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_AR7_PARTS=m

#
# User Modules And Translation Layers
#
CONFIG_MTD_CHAR=m
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
CONFIG_MTD_BLOCK_RO=m
CONFIG_FTL=m
CONFIG_NFTL=m
CONFIG_NFTL_RW=y
CONFIG_INFTL=m
CONFIG_RFD_FTL=m
CONFIG_SSFDC=m
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=m

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
CONFIG_MTD_JEDECPROBE=m
CONFIG_MTD_GEN_PROBE=m
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=m
CONFIG_MTD_CFI_AMDSTD=m
CONFIG_MTD_CFI_STAA=m
CONFIG_MTD_CFI_UTIL=m
CONFIG_MTD_RAM=m
CONFIG_MTD_ROM=m
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
CONFIG_MTD_SC520CDP=m
CONFIG_MTD_NETSC520=m
CONFIG_MTD_TS5500=m
# CONFIG_MTD_SBC_GXX is not set
# CONFIG_MTD_AMD76XROM is not set
# CONFIG_MTD_ICHXROM is not set
CONFIG_MTD_ESB2ROM=m
CONFIG_MTD_CK804XROM=m
CONFIG_MTD_SCB2_FLASH=m
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_PCI=m
# CONFIG_MTD_PCMCIA is not set
# CONFIG_MTD_GPIO_ADDR is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=m
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTD_BLOCK2MTD=m

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOC2000 is not set
# CONFIG_MTD_DOC2001 is not set
# CONFIG_MTD_DOC2001PLUS is not set
CONFIG_MTD_NAND_ECC=m
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=m
# CONFIG_MTD_NAND_VERIFY_WRITE is not set
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_SM_COMMON is not set
# CONFIG_MTD_NAND_MUSEUM_IDS is not set
# CONFIG_MTD_NAND_DENALI is not set
CONFIG_MTD_NAND_IDS=m
# CONFIG_MTD_NAND_RICOH is not set
CONFIG_MTD_NAND_DISKONCHIP=m
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=m
# CONFIG_MTD_NAND_PLATFORM is not set
CONFIG_MTD_ALAUDA=m
# CONFIG_MTD_ONENAND is not set

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=m
CONFIG_MTD_QINFO_PROBE=m
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_RESERVE=1
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_MTD_UBI_DEBUG is not set
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=m
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=m
# CONFIG_PARIDE is not set
# CONFIG_BLK_CPQ_DA is not set
CONFIG_BLK_CPQ_CISS_DA=m
CONFIG_CISS_SCSI_TAPE=y
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_CRYPTOLOOP=m
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
CONFIG_BLK_DEV_OSD=m
CONFIG_BLK_DEV_SX8=m
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=m
CONFIG_XEN_BLKDEV_FRONTEND=m
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_MISC_DEVICES=y
# CONFIG_AD525X_DPOT is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
CONFIG_ICS932S401=m
CONFIG_ENCLOSURE_SERVICES=m
CONFIG_SGI_XP=m
# CONFIG_CS5535_MFGPT is not set
CONFIG_HP_ILO=m
CONFIG_SGI_GRU=m
# CONFIG_SGI_GRU_DEBUG is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=m
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=m
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085 is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
CONFIG_EEPROM_LEGACY=m
CONFIG_EEPROM_MAX6875=m
CONFIG_EEPROM_93CX6=m
CONFIG_CB710_CORE=m
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y
CONFIG_IWMC3200TOP=m
# CONFIG_IWMC3200TOP_DEBUG is not set
# CONFIG_IWMC3200TOP_DEBUGFS is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=m
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_FC_TGT_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_SRP_TGT_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_SCSI_CXGB3_ISCSI=m
# CONFIG_SCSI_CXGB4_ISCSI is not set
CONFIG_SCSI_BNX2_ISCSI=m
# CONFIG_SCSI_BNX2X_FCOE is not set
CONFIG_BE2ISCSI=m
CONFIG_BLK_DEV_3W_XXXX_RAID=m
# CONFIG_SCSI_HPSA is not set
CONFIG_SCSI_3W_9XXX=m
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=m
CONFIG_SCSI_AIC7XXX=m
CONFIG_AIC7XXX_CMDS_PER_DEVICE=4
CONFIG_AIC7XXX_RESET_DELAY_MS=15000
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC94XX=m
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_ARCMSR=m
CONFIG_SCSI_ARCMSR_AER=y
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=m
CONFIG_MEGARAID_MAILBOX=m
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT2SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS_LOGGING=y
CONFIG_SCSI_HPTIOP=m
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
CONFIG_FCOE=m
CONFIG_FCOE_FNIC=m
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
CONFIG_SCSI_IPS=m
CONFIG_SCSI_INITIO=m
# CONFIG_SCSI_INIA100 is not set
CONFIG_SCSI_PPA=m
CONFIG_SCSI_IMM=m
# CONFIG_SCSI_IZIP_EPP16 is not set
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
CONFIG_SCSI_STEX=m
CONFIG_SCSI_SYM53C8XX_2=m
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
CONFIG_SCSI_QLA_FC=m
CONFIG_SCSI_QLA_ISCSI=m
CONFIG_SCSI_LPFC=m
# CONFIG_SCSI_LPFC_DEBUG_FS is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
CONFIG_SCSI_DEBUG=m
CONFIG_SCSI_PMCRAID=m
# CONFIG_SCSI_PM8001 is not set
CONFIG_SCSI_SRP=m
CONFIG_SCSI_BFA_FC=m
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
# CONFIG_PCMCIA_AHA152X is not set
# CONFIG_PCMCIA_FDOMAIN is not set
# CONFIG_PCMCIA_QLOGIC is not set
# CONFIG_PCMCIA_SYM53C500 is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=m
CONFIG_SCSI_DH_HP_SW=m
CONFIG_SCSI_DH_EMC=m
CONFIG_SCSI_DH_ALUA=m
CONFIG_SCSI_OSD_INITIATOR=m
CONFIG_SCSI_OSD_ULD=m
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=m
# CONFIG_SATA_ACARD_AHCI is not set
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=m
CONFIG_SATA_SX4=m
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=m
CONFIG_SATA_MV=m
CONFIG_SATA_NV=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIS=m
CONFIG_SATA_SVW=m
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=m
CONFIG_SATA_VITESSE=m

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=m
CONFIG_PATA_AMD=m
# CONFIG_PATA_ARASAN_CF is not set
CONFIG_PATA_ARTOP=m
CONFIG_PATA_ATIIXP=m
CONFIG_PATA_ATP867X=m
CONFIG_PATA_CMD64X=m
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_PATA_HPT366=m
CONFIG_PATA_HPT37X=m
CONFIG_PATA_HPT3X2N=m
CONFIG_PATA_HPT3X3=m
# CONFIG_PATA_HPT3X3_DMA is not set
CONFIG_PATA_IT8213=m
CONFIG_PATA_IT821X=m
CONFIG_PATA_JMICRON=m
CONFIG_PATA_MARVELL=m
CONFIG_PATA_NETCELL=m
CONFIG_PATA_NINJA32=m
# CONFIG_PATA_NS87415 is not set
CONFIG_PATA_OLDPIIX=m
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=m
CONFIG_PATA_PDC_OLD=m
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=m
# CONFIG_PATA_SC1200 is not set
CONFIG_PATA_SCH=m
CONFIG_PATA_SERVERWORKS=m
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=m
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
CONFIG_PATA_VIA=m
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PCMCIA=m
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
CONFIG_PATA_ACPI=m
CONFIG_ATA_GENERIC=m
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
# CONFIG_MULTICORE_RAID456 is not set
# CONFIG_MD_MULTIPATH is not set
CONFIG_MD_FAULTY=m
CONFIG_BLK_DEV_DM=m
CONFIG_DM_DEBUG=y
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_MIRROR=m
# CONFIG_DM_RAID is not set
CONFIG_DM_LOG_USERSPACE=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
CONFIG_DM_MULTIPATH_QL=m
CONFIG_DM_MULTIPATH_ST=m
CONFIG_DM_DELAY=m
CONFIG_DM_UEVENT=y
# CONFIG_DM_FLAKEY is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
CONFIG_FUSION_FC=m
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LAN=m
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
CONFIG_FIREWIRE_OHCI=m
CONFIG_FIREWIRE_OHCI_DEBUG=y
CONFIG_FIREWIRE_SBP2=m
CONFIG_FIREWIRE_NET=m
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_IFB=m
CONFIG_DUMMY=m
CONFIG_BONDING=m
CONFIG_MACVLAN=m
# CONFIG_MACVTAP is not set
# CONFIG_EQUALIZER is not set
CONFIG_TUN=m
CONFIG_VETH=m
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
CONFIG_MII=m
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
CONFIG_MARVELL_PHY=m
CONFIG_DAVICOM_PHY=m
CONFIG_QSEMI_PHY=m
CONFIG_LXT_PHY=m
CONFIG_CICADA_PHY=m
CONFIG_VITESSE_PHY=m
CONFIG_SMSC_PHY=m
CONFIG_BROADCOM_PHY=m
# CONFIG_BCM63XX_PHY is not set
CONFIG_ICPLUS_PHY=m
CONFIG_REALTEK_PHY=m
CONFIG_NATIONAL_PHY=m
CONFIG_STE10XP=m
CONFIG_LSI_ET1011C_PHY=m
# CONFIG_MICREL_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_MDIO_BITBANG=m
# CONFIG_MDIO_GPIO is not set
CONFIG_NET_ETHERNET=y
CONFIG_HAPPYMEAL=m
CONFIG_SUNGEM=m
CONFIG_CASSINI=m
CONFIG_NET_VENDOR_3COM=y
CONFIG_VORTEX=m
CONFIG_TYPHOON=m
CONFIG_ETHOC=m
CONFIG_DNET=m
CONFIG_NET_TULIP=y
CONFIG_DE2104X=m
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=m
# CONFIG_TULIP_MWI is not set
CONFIG_TULIP_MMIO=y
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=m
CONFIG_WINBOND_840=m
CONFIG_DM9102=m
CONFIG_ULI526X=m
CONFIG_PCMCIA_XIRCOM=m
# CONFIG_HP100 is not set
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
# CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
# CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
# CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
CONFIG_NET_PCI=y
CONFIG_PCNET32=m
CONFIG_AMD8111_ETH=m
CONFIG_ADAPTEC_STARFIRE=m
# CONFIG_KSZ884X_PCI is not set
CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_FORCEDETH=m
CONFIG_E100=m
CONFIG_FEALNX=m
CONFIG_NATSEMI=m
CONFIG_NE2K_PCI=m
CONFIG_8139CP=m
CONFIG_8139TOO=m
# CONFIG_8139TOO_PIO is not set
# CONFIG_8139TOO_TUNE_TWISTER is not set
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R6040=m
CONFIG_SIS900=m
CONFIG_EPIC100=m
CONFIG_SMSC9420=m
CONFIG_SUNDANCE=m
# CONFIG_SUNDANCE_MMIO is not set
CONFIG_TLAN=m
# CONFIG_KS8842 is not set
# CONFIG_KS8851_MLL is not set
CONFIG_VIA_RHINE=m
CONFIG_VIA_RHINE_MMIO=y
CONFIG_SC92031=m
CONFIG_NET_POCKET=y
# CONFIG_ATP is not set
# CONFIG_DE600 is not set
# CONFIG_DE620 is not set
CONFIG_ATL2=m
CONFIG_NETDEV_1000=y
CONFIG_ACENIC=m
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_DL2K=m
CONFIG_E1000=m
CONFIG_E1000E=m
CONFIG_IP1000=m
CONFIG_IGB=m
CONFIG_IGB_DCA=y
CONFIG_IGBVF=m
CONFIG_NS83820=m
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_R8169=m
CONFIG_SIS190=m
CONFIG_SKGE=m
# CONFIG_SKGE_DEBUG is not set
CONFIG_SKY2=m
# CONFIG_SKY2_DEBUG is not set
CONFIG_VIA_VELOCITY=m
CONFIG_TIGON3=m
CONFIG_BNX2=m
CONFIG_CNIC=m
CONFIG_QLA3XXX=m
CONFIG_ATL1=m
CONFIG_ATL1E=m
CONFIG_ATL1C=m
CONFIG_JME=m
# CONFIG_STMMAC_ETH is not set
# CONFIG_PCH_GBE is not set
CONFIG_NETDEV_10000=y
CONFIG_MDIO=m
CONFIG_CHELSIO_T1=m
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3=m
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_ENIC=m
CONFIG_IXGBE=m
CONFIG_IXGBE_DCA=y
CONFIG_IXGBE_DCB=y
# CONFIG_IXGBEVF is not set
CONFIG_IXGB=m
CONFIG_S2IO=m
CONFIG_VXGE=m
# CONFIG_VXGE_DEBUG_TRACE_ALL is not set
CONFIG_MYRI10GE=m
CONFIG_MYRI10GE_DCA=y
CONFIG_NETXEN_NIC=m
CONFIG_NIU=m
CONFIG_MLX4_EN=m
CONFIG_MLX4_CORE=m
CONFIG_MLX4_DEBUG=y
CONFIG_TEHUTI=m
CONFIG_BNX2X=m
# CONFIG_QLCNIC is not set
CONFIG_QLGE=m
# CONFIG_BNA is not set
CONFIG_SFC=m
CONFIG_SFC_MTD=y
CONFIG_BE2NET=m
# CONFIG_TR is not set
CONFIG_WLAN=y
# CONFIG_PCMCIA_RAYCS is not set
CONFIG_LIBERTAS_THINFIRM=m
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
CONFIG_LIBERTAS_THINFIRM_USB=m
CONFIG_AIRO=m
CONFIG_ATMEL=m
CONFIG_PCI_ATMEL=m
CONFIG_PCMCIA_ATMEL=m
CONFIG_AT76C50X_USB=m
CONFIG_AIRO_CS=m
CONFIG_PCMCIA_WL3501=m
# CONFIG_PRISM54 is not set
CONFIG_USB_ZD1201=m
CONFIG_USB_NET_RNDIS_WLAN=m
CONFIG_RTL8180=m
CONFIG_RTL8187=m
CONFIG_RTL8187_LEDS=y
CONFIG_ADM8211=m
CONFIG_MAC80211_HWSIM=m
CONFIG_MWL8K=m
CONFIG_ATH_COMMON=m
# CONFIG_ATH_DEBUG is not set
CONFIG_ATH5K=m
# CONFIG_ATH5K_DEBUG is not set
# CONFIG_ATH5K_TRACER is not set
CONFIG_ATH5K_PCI=y
CONFIG_ATH9K_HW=m
CONFIG_ATH9K_COMMON=m
CONFIG_ATH9K=m
# CONFIG_ATH9K_DEBUGFS is not set
CONFIG_ATH9K_RATE_CONTROL=y
# CONFIG_ATH9K_HTC is not set
CONFIG_AR9170_USB=m
CONFIG_AR9170_LEDS=y
# CONFIG_CARL9170 is not set
CONFIG_B43=m
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_PCMCIA=y
CONFIG_B43_SDIO=y
CONFIG_B43_PIO=y
# CONFIG_B43_PHY_N is not set
CONFIG_B43_PHY_LP=y
CONFIG_B43_LEDS=y
CONFIG_B43_HWRNG=y
CONFIG_B43_DEBUG=y
# CONFIG_B43_FORCE_PIO is not set
CONFIG_B43LEGACY=m
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_HWRNG=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
CONFIG_B43LEGACY_PIO=y
CONFIG_B43LEGACY_DMA_AND_PIO_MODE=y
# CONFIG_B43LEGACY_DMA_MODE is not set
# CONFIG_B43LEGACY_PIO_MODE is not set
CONFIG_HOSTAP=m
CONFIG_HOSTAP_FIRMWARE=y
CONFIG_HOSTAP_FIRMWARE_NVRAM=y
CONFIG_HOSTAP_PLX=m
CONFIG_HOSTAP_PCI=m
CONFIG_HOSTAP_CS=m
CONFIG_IPW2100=m
CONFIG_IPW2100_MONITOR=y
# CONFIG_IPW2100_DEBUG is not set
CONFIG_IPW2200=m
CONFIG_IPW2200_MONITOR=y
CONFIG_IPW2200_RADIOTAP=y
CONFIG_IPW2200_PROMISCUOUS=y
CONFIG_IPW2200_QOS=y
# CONFIG_IPW2200_DEBUG is not set
CONFIG_LIBIPW=m
# CONFIG_LIBIPW_DEBUG is not set
CONFIG_IWLAGN=m

#
# Debugging Options
#
# CONFIG_IWLWIFI_DEBUG is not set
# CONFIG_IWLWIFI_DEVICE_TRACING is not set
# CONFIG_IWL_P2P is not set
CONFIG_IWLWIFI_LEGACY=m

#
# Debugging Options
#
# CONFIG_IWLWIFI_LEGACY_DEBUG is not set
# CONFIG_IWLWIFI_LEGACY_DEVICE_TRACING is not set
CONFIG_IWL4965=m
CONFIG_IWL3945=m
CONFIG_IWM=m
# CONFIG_IWM_DEBUG is not set
# CONFIG_IWM_TRACING is not set
CONFIG_LIBERTAS=m
CONFIG_LIBERTAS_USB=m
CONFIG_LIBERTAS_CS=m
CONFIG_LIBERTAS_SDIO=m
CONFIG_LIBERTAS_DEBUG=y
# CONFIG_LIBERTAS_MESH is not set
CONFIG_HERMES=m
# CONFIG_HERMES_PRISM is not set
CONFIG_HERMES_CACHE_FW_ON_INIT=y
CONFIG_PLX_HERMES=m
CONFIG_TMD_HERMES=m
CONFIG_NORTEL_HERMES=m
CONFIG_PCMCIA_HERMES=m
CONFIG_PCMCIA_SPECTRUM=m
# CONFIG_ORINOCO_USB is not set
CONFIG_P54_COMMON=m
CONFIG_P54_USB=m
CONFIG_P54_PCI=m
CONFIG_P54_LEDS=y
CONFIG_RT2X00=m
CONFIG_RT2400PCI=m
CONFIG_RT2500PCI=m
CONFIG_RT61PCI=m
# CONFIG_RT2800PCI is not set
CONFIG_RT2500USB=m
CONFIG_RT73USB=m
# CONFIG_RT2800USB is not set
CONFIG_RT2X00_LIB_PCI=m
CONFIG_RT2X00_LIB_USB=m
CONFIG_RT2X00_LIB=m
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
# CONFIG_RT2X00_DEBUG is not set
# CONFIG_RTL8192CE is not set
# CONFIG_RTL8192CU is not set
CONFIG_WL1251=m
CONFIG_WL1251_SDIO=m
# CONFIG_WL12XX_MENU is not set
CONFIG_WL12XX_PLATFORM_DATA=y
CONFIG_ZD1211RW=m
# CONFIG_ZD1211RW_DEBUG is not set

#
# WiMAX Wireless Broadband devices
#
CONFIG_WIMAX_I2400M=m
CONFIG_WIMAX_I2400M_USB=m
CONFIG_WIMAX_I2400M_SDIO=m
# CONFIG_WIMAX_IWMC3200_SDIO is not set
CONFIG_WIMAX_I2400M_DEBUG_LEVEL=8

#
# USB Network Adapters
#
CONFIG_USB_CATC=m
CONFIG_USB_KAWETH=m
CONFIG_USB_PEGASUS=m
CONFIG_USB_RTL8150=m
CONFIG_USB_USBNET=m
CONFIG_USB_NET_AX8817X=m
CONFIG_USB_NET_CDCETHER=m
CONFIG_USB_NET_CDC_EEM=m
CONFIG_USB_NET_CDC_NCM=m
CONFIG_USB_NET_DM9601=m
# CONFIG_USB_NET_SMSC75XX is not set
CONFIG_USB_NET_SMSC95XX=m
CONFIG_USB_NET_GL620A=m
CONFIG_USB_NET_NET1080=m
CONFIG_USB_NET_PLUSB=m
CONFIG_USB_NET_MCS7830=m
CONFIG_USB_NET_RNDIS_HOST=m
CONFIG_USB_NET_CDC_SUBSET=m
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=m
# CONFIG_USB_NET_CX82310_ETH is not set
CONFIG_USB_HSO=m
CONFIG_USB_NET_INT51X1=m
CONFIG_USB_CDC_PHONET=m
# CONFIG_USB_IPHETH is not set
# CONFIG_USB_SIERRA_NET is not set
# CONFIG_USB_VL600 is not set
CONFIG_NET_PCMCIA=y
CONFIG_PCMCIA_3C589=m
CONFIG_PCMCIA_3C574=m
CONFIG_PCMCIA_FMVJ18X=m
CONFIG_PCMCIA_PCNET=m
CONFIG_PCMCIA_NMCLAN=m
CONFIG_PCMCIA_SMC91C92=m
CONFIG_PCMCIA_XIRC2PS=m
CONFIG_PCMCIA_AXNET=m
CONFIG_WAN=y
# CONFIG_LANMEDIA is not set
CONFIG_HDLC=m
CONFIG_HDLC_RAW=m
# CONFIG_HDLC_RAW_ETH is not set
CONFIG_HDLC_CISCO=m
CONFIG_HDLC_FR=m
CONFIG_HDLC_PPP=m

#
# X.25/LAPB support is disabled
#
# CONFIG_PCI200SYN is not set
# CONFIG_WANXL is not set
# CONFIG_PC300TOO is not set
# CONFIG_FARSYNC is not set
# CONFIG_DSCC4 is not set
CONFIG_DLCI=m
CONFIG_DLCI_MAX=8
# CONFIG_SBNI is not set
CONFIG_ATM_DRIVERS=y
# CONFIG_ATM_DUMMY is not set
CONFIG_ATM_TCP=m
# CONFIG_ATM_LANAI is not set
# CONFIG_ATM_ENI is not set
# CONFIG_ATM_FIRESTREAM is not set
# CONFIG_ATM_ZATM is not set
# CONFIG_ATM_NICSTAR is not set
# CONFIG_ATM_IDT77252 is not set
# CONFIG_ATM_AMBASSADOR is not set
# CONFIG_ATM_HORIZON is not set
# CONFIG_ATM_IA is not set
# CONFIG_ATM_FORE200E is not set
# CONFIG_ATM_HE is not set
# CONFIG_ATM_SOLOS is not set
CONFIG_IEEE802154_DRIVERS=m
CONFIG_IEEE802154_FAKEHARD=m

#
# CAIF transport drivers
#
CONFIG_XEN_NETDEV_FRONTEND=m
# CONFIG_XEN_NETDEV_BACKEND is not set
CONFIG_FDDI=y
# CONFIG_DEFXX is not set
# CONFIG_SKFP is not set
# CONFIG_HIPPI is not set
# CONFIG_PLIP is not set
CONFIG_PPP=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPP_FILTER=y
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_PPP_DEFLATE=m
# CONFIG_PPP_BSDCOMP is not set
CONFIG_PPP_MPPE=m
CONFIG_PPPOE=m
CONFIG_PPPOATM=m
CONFIG_SLIP=m
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLHC=m
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set
CONFIG_NET_FC=y
CONFIG_NETCONSOLE=m
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
CONFIG_NETPOLL_TRAP=y
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_VMXNET3=m
CONFIG_ISDN=y
CONFIG_ISDN_I4L=m
CONFIG_ISDN_PPP=y
CONFIG_ISDN_PPP_VJ=y
CONFIG_ISDN_MPP=y
CONFIG_IPPP_FILTER=y
# CONFIG_ISDN_PPP_BSDCOMP is not set
CONFIG_ISDN_AUDIO=y
CONFIG_ISDN_TTY_FAX=y

#
# ISDN feature submodules
#
CONFIG_ISDN_DIVERSION=m

#
# ISDN4Linux hardware drivers
#

#
# Passive cards
#
CONFIG_ISDN_DRV_HISAX=m

#
# D-channel protocol features
#
CONFIG_HISAX_EURO=y
CONFIG_DE_AOC=y
CONFIG_HISAX_NO_SENDCOMPLETE=y
CONFIG_HISAX_NO_LLC=y
CONFIG_HISAX_NO_KEYPAD=y
CONFIG_HISAX_1TR6=y
CONFIG_HISAX_NI1=y
CONFIG_HISAX_MAX_CARDS=8

#
# HiSax supported cards
#
CONFIG_HISAX_16_3=y
CONFIG_HISAX_TELESPCI=y
CONFIG_HISAX_S0BOX=y
CONFIG_HISAX_FRITZPCI=y
CONFIG_HISAX_AVM_A1_PCMCIA=y
CONFIG_HISAX_ELSA=y
CONFIG_HISAX_DIEHLDIVA=y
CONFIG_HISAX_SEDLBAUER=y
CONFIG_HISAX_NETJET=y
CONFIG_HISAX_NETJET_U=y
CONFIG_HISAX_NICCY=y
CONFIG_HISAX_BKM_A4T=y
CONFIG_HISAX_SCT_QUADRO=y
CONFIG_HISAX_GAZEL=y
CONFIG_HISAX_HFC_PCI=y
CONFIG_HISAX_W6692=y
CONFIG_HISAX_HFC_SX=y
CONFIG_HISAX_ENTERNOW_PCI=y
# CONFIG_HISAX_DEBUG is not set

#
# HiSax PCMCIA card service modules
#
CONFIG_HISAX_SEDLBAUER_CS=m
CONFIG_HISAX_ELSA_CS=m
CONFIG_HISAX_AVM_A1_CS=m
CONFIG_HISAX_TELES_CS=m

#
# HiSax sub driver modules
#
CONFIG_HISAX_ST5481=m
# CONFIG_HISAX_HFCUSB is not set
CONFIG_HISAX_HFC4S8S=m
CONFIG_HISAX_FRITZ_PCIPNP=m

#
# Active cards
#
CONFIG_ISDN_CAPI=m
CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON=y
# CONFIG_CAPI_TRACE is not set
CONFIG_ISDN_CAPI_MIDDLEWARE=y
CONFIG_ISDN_CAPI_CAPI20=m
CONFIG_ISDN_CAPI_CAPIFS_BOOL=y
CONFIG_ISDN_CAPI_CAPIFS=m
CONFIG_ISDN_CAPI_CAPIDRV=m

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
CONFIG_ISDN_DRV_AVMB1_B1PCI=m
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
CONFIG_ISDN_DRV_AVMB1_B1PCMCIA=m
CONFIG_ISDN_DRV_AVMB1_AVM_CS=m
CONFIG_ISDN_DRV_AVMB1_T1PCI=m
CONFIG_ISDN_DRV_AVMB1_C4=m
# CONFIG_CAPI_EICON is not set
CONFIG_ISDN_DRV_GIGASET=m
# CONFIG_GIGASET_CAPI is not set
CONFIG_GIGASET_I4L=y
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_BASE=m
CONFIG_GIGASET_M105=m
CONFIG_GIGASET_M101=m
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=m
CONFIG_MISDN_DSP=m
CONFIG_MISDN_L1OIP=m

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=m
CONFIG_MISDN_HFCMULTI=m
CONFIG_MISDN_HFCUSB=m
CONFIG_MISDN_AVMFRITZ=m
CONFIG_MISDN_SPEEDFAX=m
CONFIG_MISDN_INFINEON=m
CONFIG_MISDN_W6692=m
CONFIG_MISDN_NETJET=m
CONFIG_MISDN_IPAC=m
CONFIG_MISDN_ISAR=m
CONFIG_ISDN_HDLC=m
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5588=m
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
CONFIG_KEYBOARD_MAX7359=m
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_KEYBOARD_OPENCORES=m
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=m
CONFIG_MOUSE_APPLETOUCH=m
CONFIG_MOUSE_BCM5974=m
CONFIG_MOUSE_VSXXXAA=m
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=m
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=m
CONFIG_TABLET_USB_AIPTEK=m
CONFIG_TABLET_USB_GTCO=m
# CONFIG_TABLET_USB_HANWANG is not set
CONFIG_TABLET_USB_KBTAB=m
CONFIG_TABLET_USB_WACOM=m
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_AD7879=m
CONFIG_TOUCHSCREEN_AD7879_I2C=m
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
CONFIG_TOUCHSCREEN_EETI=m
CONFIG_TOUCHSCREEN_FUJITSU=m
CONFIG_TOUCHSCREEN_GUNZE=m
CONFIG_TOUCHSCREEN_ELO=m
CONFIG_TOUCHSCREEN_WACOM_W8001=m
CONFIG_TOUCHSCREEN_MCS5000=m
CONFIG_TOUCHSCREEN_MTOUCH=m
CONFIG_TOUCHSCREEN_INEXIO=m
# CONFIG_TOUCHSCREEN_MK712 is not set
CONFIG_TOUCHSCREEN_PENMOUNT=m
CONFIG_TOUCHSCREEN_TOUCHRIGHT=m
CONFIG_TOUCHSCREEN_TOUCHWIN=m
# CONFIG_TOUCHSCREEN_WM97XX is not set
CONFIG_TOUCHSCREEN_USB_COMPOSITE=m
CONFIG_TOUCHSCREEN_USB_EGALAX=y
CONFIG_TOUCHSCREEN_USB_PANJIT=y
CONFIG_TOUCHSCREEN_USB_3M=y
CONFIG_TOUCHSCREEN_USB_ITM=y
CONFIG_TOUCHSCREEN_USB_ETURBO=y
CONFIG_TOUCHSCREEN_USB_GUNZE=y
CONFIG_TOUCHSCREEN_USB_DMC_TSC10=y
CONFIG_TOUCHSCREEN_USB_IRTOUCH=y
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
CONFIG_TOUCHSCREEN_USB_GOTOP=y
CONFIG_TOUCHSCREEN_USB_JASTEC=y
CONFIG_TOUCHSCREEN_USB_E2I=y
CONFIG_TOUCHSCREEN_USB_ZYTRONIC=y
CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=y
CONFIG_TOUCHSCREEN_USB_NEXIO=y
CONFIG_TOUCHSCREEN_TOUCHIT213=m
CONFIG_TOUCHSCREEN_TSC2007=m
# CONFIG_TOUCHSCREEN_ST1232 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
CONFIG_INPUT_PCSPKR=m
CONFIG_INPUT_APANEL=m
CONFIG_INPUT_ATLAS_BTNS=m
CONFIG_INPUT_ATI_REMOTE=m
CONFIG_INPUT_ATI_REMOTE2=m
CONFIG_INPUT_KEYSPAN_REMOTE=m
CONFIG_INPUT_POWERMATE=m
CONFIG_INPUT_YEALINK=m
CONFIG_INPUT_CM109=m
CONFIG_INPUT_UINPUT=m
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
# CONFIG_CYZ_INTR is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
CONFIG_SYNCLINK=m
CONFIG_SYNCLINKMP=m
CONFIG_SYNCLINK_GT=m
CONFIG_NOZOMI=m
# CONFIG_ISI is not set
CONFIG_N_HDLC=m
# CONFIG_N_GSM is not set
# CONFIG_DEVKMEM is not set
# CONFIG_STALDRV is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CS=m
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_CONSOLE_POLL=y
CONFIG_SERIAL_JSM=m
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_PRINTER is not set
CONFIG_PPDEV=m
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_IPMI_HANDLER=m
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
CONFIG_IPWIRELESS=m
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=8192
CONFIG_HPET=y
# CONFIG_HPET_MMAP is not set
CONFIG_HANGCHECK_TIMER=m
# CONFIG_UV_MMTIMER is not set
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
CONFIG_TCG_INFINEON=m
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
# CONFIG_RAMOOPS is not set
CONFIG_I2C=m
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=m
CONFIG_I2C_ALGOBIT=m
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=m
CONFIG_I2C_ISCH=m
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_NFORCE2_S4985=m
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
CONFIG_I2C_SCMI=m

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_INTEL_MID is not set
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=m
# CONFIG_I2C_XILINX is not set
# CONFIG_I2C_EG20T is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=m

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_STUB=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set

#
# PPS support
#
CONFIG_PPS=m
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_PARPORT is not set

#
# PPS generators support
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set

#
# Memory mapped GPIO expanders:
#
# CONFIG_GPIO_BASIC_MMIO is not set
# CONFIG_GPIO_IT8761E is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_VX855 is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_CS5535 is not set
# CONFIG_GPIO_LANGWELL is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_BQ20Z75 is not set
CONFIG_BATTERY_BQ27x00=m
CONFIG_BATTERY_BQ27X00_I2C=y
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_BATTERY_MAX17040=m
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_GPIO is not set
CONFIG_HWMON=m
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
CONFIG_SENSORS_AD7414=m
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
# CONFIG_SENSORS_ASC7621 is not set
CONFIG_SENSORS_K8TEMP=m
# CONFIG_SENSORS_K10TEMP is not set
CONFIG_SENSORS_ASB100=m
CONFIG_SENSORS_ATXP1=m
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_I5K_AMB=m
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_FSCHMD=m
CONFIG_SENSORS_G760A=m
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_CORETEMP=m
# CONFIG_SENSORS_PKGTEMP is not set
CONFIG_SENSORS_IBMAEM=m
CONFIG_SENSORS_IBMPEX=m
CONFIG_SENSORS_IT87=m
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=m
CONFIG_SENSORS_LTC4245=m
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_MAX1619=m
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_PCF8591=m
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SIS5595=m
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_DME1737=m
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_THMC50=m
# CONFIG_SENSORS_TMP102 is not set
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=m
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_APPLESMC=m

#
# ACPI drivers
#
CONFIG_SENSORS_ATK0110=m
CONFIG_THERMAL=y
CONFIG_WATCHDOG=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=m
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
# CONFIG_SC520_WDT is not set
CONFIG_SBC_FITPC2_WATCHDOG=m
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=m
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=m
CONFIG_ITCO_WDT=m
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=m
CONFIG_IT87_WDT=m
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
CONFIG_SMSC_SCH311X_WDT=m
# CONFIG_SMSC37B787_WDT is not set
CONFIG_W83627HF_WDT=m
CONFIG_W83697HF_WDT=m
CONFIG_W83697UG_WDT=m
CONFIG_W83877F_WDT=m
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
# CONFIG_XEN_WDT is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=m

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=m
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
CONFIG_SSB_BLOCKIO=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_MFD_SUPPORT=y
CONFIG_MFD_CORE=m
CONFIG_MFD_SM501=m
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_UCB1400_CORE is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_WM8400=m
# CONFIG_MFD_PCF50633 is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_LPC_SCH=m
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=m
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=m
CONFIG_REGULATOR_BQ24022=m
CONFIG_REGULATOR_MAX1586=m
# CONFIG_REGULATOR_MAX8649 is not set
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_WM8400=m
CONFIG_REGULATOR_LP3971=m
# CONFIG_REGULATOR_LP3972 is not set
CONFIG_REGULATOR_TPS65023=m
CONFIG_REGULATOR_TPS6507X=m
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2_COMMON=m
CONFIG_DVB_CORE=m
CONFIG_VIDEO_MEDIA=m

#
# Multimedia drivers
#
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m
CONFIG_RC_CORE=m
CONFIG_LIRC=m
CONFIG_RC_MAP=m
CONFIG_IR_NEC_DECODER=m
CONFIG_IR_RC5_DECODER=m
CONFIG_IR_RC6_DECODER=m
CONFIG_IR_JVC_DECODER=m
CONFIG_IR_SONY_DECODER=m
CONFIG_IR_RC5_SZ_DECODER=m
CONFIG_IR_LIRC_CODEC=m
# CONFIG_IR_ENE is not set
# CONFIG_IR_IMON is not set
# CONFIG_IR_MCEUSB is not set
# CONFIG_IR_ITE_CIR is not set
# CONFIG_IR_NUVOTON is not set
# CONFIG_IR_STREAMZAP is not set
# CONFIG_IR_WINBOND_CIR is not set
# CONFIG_RC_LOOPBACK is not set
CONFIG_MEDIA_ATTACH=y
CONFIG_MEDIA_TUNER=m
# CONFIG_MEDIA_TUNER_CUSTOMISE is not set
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2060=m
CONFIG_MEDIA_TUNER_MT2266=m
CONFIG_MEDIA_TUNER_MT2131=m
CONFIG_MEDIA_TUNER_QT1010=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_MXL5005S=m
CONFIG_MEDIA_TUNER_MXL5007T=m
CONFIG_MEDIA_TUNER_MC44S803=m
CONFIG_MEDIA_TUNER_MAX2165=m
CONFIG_MEDIA_TUNER_TDA18218=m
CONFIG_VIDEO_V4L2=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF_VMALLOC=m
CONFIG_VIDEOBUF_DVB=m
CONFIG_VIDEO_BTCX=m
CONFIG_VIDEO_TVEEPROM=m
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEO_CAPTURE_DRIVERS=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_HELPER_CHIPS_AUTO=y
CONFIG_VIDEO_IR_I2C=m

#
# Audio decoders
#
CONFIG_VIDEO_TVAUDIO=m
CONFIG_VIDEO_TDA7432=m
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS5345=m
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_M52790=m
CONFIG_VIDEO_WM8775=m
CONFIG_VIDEO_WM8739=m
CONFIG_VIDEO_VP27SMPX=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_MT9V011=m
CONFIG_VIDEO_SAA711X=m
CONFIG_VIDEO_SAA717X=m
CONFIG_VIDEO_TVP5150=m

#
# Video and audio decoders
#
CONFIG_VIDEO_CX25840=m

#
# MPEG video encoders
#
CONFIG_VIDEO_CX2341X=m

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=m

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=m
# CONFIG_VIDEO_VIVI is not set
CONFIG_VIDEO_BT848=m
CONFIG_VIDEO_BT848_DVB=y
# CONFIG_VIDEO_BWQCAM is not set
# CONFIG_VIDEO_CQCAM is not set
# CONFIG_VIDEO_W9966 is not set
# CONFIG_VIDEO_CPIA2 is not set
# CONFIG_VIDEO_ZORAN is not set
# CONFIG_VIDEO_MEYE is not set
CONFIG_VIDEO_SAA7134=m
CONFIG_VIDEO_SAA7134_ALSA=m
CONFIG_VIDEO_SAA7134_RC=y
CONFIG_VIDEO_SAA7134_DVB=m
# CONFIG_VIDEO_MXB is not set
# CONFIG_VIDEO_HEXIUM_ORION is not set
# CONFIG_VIDEO_HEXIUM_GEMINI is not set
# CONFIG_VIDEO_TIMBERDALE is not set
CONFIG_VIDEO_CX88=m
CONFIG_VIDEO_CX88_ALSA=m
CONFIG_VIDEO_CX88_BLACKBIRD=m
CONFIG_VIDEO_CX88_DVB=m
CONFIG_VIDEO_CX88_MPEG=m
CONFIG_VIDEO_CX88_VP3054=m
CONFIG_VIDEO_CX23885=m
# CONFIG_MEDIA_ALTERA_CI is not set
CONFIG_VIDEO_AU0828=m
CONFIG_VIDEO_IVTV=m
CONFIG_VIDEO_FB_IVTV=m
CONFIG_VIDEO_CX18=m
# CONFIG_VIDEO_CX18_ALSA is not set
CONFIG_VIDEO_SAA7164=m
# CONFIG_VIDEO_CAFE_CCIC is not set
# CONFIG_VIDEO_SR030PC30 is not set
# CONFIG_VIDEO_VIA_CAMERA is not set
# CONFIG_VIDEO_NOON010PC30 is not set
CONFIG_SOC_CAMERA=m
# CONFIG_SOC_CAMERA_IMX074 is not set
CONFIG_SOC_CAMERA_MT9M001=m
CONFIG_SOC_CAMERA_MT9M111=m
CONFIG_SOC_CAMERA_MT9T031=m
# CONFIG_SOC_CAMERA_MT9T112 is not set
CONFIG_SOC_CAMERA_MT9V022=m
# CONFIG_SOC_CAMERA_RJ54N1 is not set
CONFIG_SOC_CAMERA_TW9910=m
CONFIG_SOC_CAMERA_PLATFORM=m
# CONFIG_SOC_CAMERA_OV2640 is not set
# CONFIG_SOC_CAMERA_OV6650 is not set
CONFIG_SOC_CAMERA_OV772X=m
# CONFIG_SOC_CAMERA_OV9640 is not set
# CONFIG_SOC_CAMERA_OV9740 is not set
CONFIG_V4L_USB_DRIVERS=y
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m
CONFIG_USB_M5602=m
CONFIG_USB_STV06XX=m
CONFIG_USB_GL860=m
# CONFIG_USB_GSPCA_BENQ is not set
CONFIG_USB_GSPCA_CONEX=m
# CONFIG_USB_GSPCA_CPIA1 is not set
CONFIG_USB_GSPCA_ETOMS=m
CONFIG_USB_GSPCA_FINEPIX=m
CONFIG_USB_GSPCA_JEILINJ=m
# CONFIG_USB_GSPCA_KONICA is not set
CONFIG_USB_GSPCA_MARS=m
CONFIG_USB_GSPCA_MR97310A=m
# CONFIG_USB_GSPCA_NW80X is not set
CONFIG_USB_GSPCA_OV519=m
CONFIG_USB_GSPCA_OV534=m
# CONFIG_USB_GSPCA_OV534_9 is not set
CONFIG_USB_GSPCA_PAC207=m
# CONFIG_USB_GSPCA_PAC7302 is not set
CONFIG_USB_GSPCA_PAC7311=m
# CONFIG_USB_GSPCA_SN9C2028 is not set
CONFIG_USB_GSPCA_SN9C20X=m
CONFIG_USB_GSPCA_SONIXB=m
CONFIG_USB_GSPCA_SONIXJ=m
CONFIG_USB_GSPCA_SPCA500=m
CONFIG_USB_GSPCA_SPCA501=m
CONFIG_USB_GSPCA_SPCA505=m
CONFIG_USB_GSPCA_SPCA506=m
CONFIG_USB_GSPCA_SPCA508=m
CONFIG_USB_GSPCA_SPCA561=m
# CONFIG_USB_GSPCA_SPCA1528 is not set
CONFIG_USB_GSPCA_SQ905=m
CONFIG_USB_GSPCA_SQ905C=m
# CONFIG_USB_GSPCA_SQ930X is not set
CONFIG_USB_GSPCA_STK014=m
# CONFIG_USB_GSPCA_STV0680 is not set
CONFIG_USB_GSPCA_SUNPLUS=m
CONFIG_USB_GSPCA_T613=m
CONFIG_USB_GSPCA_TV8532=m
CONFIG_USB_GSPCA_VC032X=m
# CONFIG_USB_GSPCA_VICAM is not set
# CONFIG_USB_GSPCA_XIRLINK_CIT is not set
CONFIG_USB_GSPCA_ZC3XX=m
CONFIG_VIDEO_PVRUSB2=m
CONFIG_VIDEO_PVRUSB2_SYSFS=y
CONFIG_VIDEO_PVRUSB2_DVB=y
# CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
CONFIG_VIDEO_HDPVR=m
CONFIG_VIDEO_EM28XX=m
CONFIG_VIDEO_EM28XX_ALSA=m
CONFIG_VIDEO_EM28XX_DVB=m
# CONFIG_VIDEO_TLG2300 is not set
CONFIG_VIDEO_CX231XX=m
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_CX231XX_ALSA=m
CONFIG_VIDEO_CX231XX_DVB=m
CONFIG_VIDEO_USBVISION=m
# CONFIG_USB_ET61X251 is not set
# CONFIG_USB_SN9C102 is not set
# CONFIG_USB_PWC is not set
CONFIG_USB_ZR364XX=m
CONFIG_USB_STKWEBCAM=m
CONFIG_USB_S2255=m
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_RADIO_ADAPTERS is not set
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y
CONFIG_DVB_CAPTURE_DRIVERS=y

#
# Supported SAA7146 based PCI Adapters
#
CONFIG_TTPCI_EEPROM=m
CONFIG_DVB_AV7110=m
CONFIG_DVB_AV7110_OSD=y
CONFIG_DVB_BUDGET_CORE=m
CONFIG_DVB_BUDGET=m
CONFIG_DVB_BUDGET_CI=m
CONFIG_DVB_BUDGET_AV=m
CONFIG_DVB_BUDGET_PATCH=m

#
# Supported USB Adapters
#
CONFIG_DVB_USB=m
# CONFIG_DVB_USB_DEBUG is not set
CONFIG_DVB_USB_A800=m
CONFIG_DVB_USB_DIBUSB_MB=m
# CONFIG_DVB_USB_DIBUSB_MB_FAULTY is not set
CONFIG_DVB_USB_DIBUSB_MC=m
CONFIG_DVB_USB_DIB0700=m
CONFIG_DVB_USB_UMT_010=m
CONFIG_DVB_USB_CXUSB=m
CONFIG_DVB_USB_M920X=m
CONFIG_DVB_USB_GL861=m
CONFIG_DVB_USB_AU6610=m
CONFIG_DVB_USB_DIGITV=m
CONFIG_DVB_USB_VP7045=m
CONFIG_DVB_USB_VP702X=m
CONFIG_DVB_USB_GP8PSK=m
CONFIG_DVB_USB_NOVA_T_USB2=m
CONFIG_DVB_USB_TTUSB2=m
CONFIG_DVB_USB_DTT200U=m
CONFIG_DVB_USB_OPERA1=m
CONFIG_DVB_USB_AF9005=m
CONFIG_DVB_USB_AF9005_REMOTE=m
CONFIG_DVB_USB_DW2102=m
CONFIG_DVB_USB_CINERGY_T2=m
CONFIG_DVB_USB_ANYSEE=m
CONFIG_DVB_USB_DTV5100=m
CONFIG_DVB_USB_AF9015=m
CONFIG_DVB_USB_CE6230=m
CONFIG_DVB_USB_FRIIO=m
# CONFIG_DVB_USB_EC168 is not set
# CONFIG_DVB_USB_AZ6027 is not set
# CONFIG_DVB_USB_LME2510 is not set
# CONFIG_DVB_USB_TECHNISAT_USB2 is not set
CONFIG_DVB_TTUSB_BUDGET=m
CONFIG_DVB_TTUSB_DEC=m
# CONFIG_SMS_SIANO_MDTV is not set

#
# Supported FlexCopII (B2C2) Adapters
#
CONFIG_DVB_B2C2_FLEXCOP=m
CONFIG_DVB_B2C2_FLEXCOP_PCI=m
CONFIG_DVB_B2C2_FLEXCOP_USB=m
# CONFIG_DVB_B2C2_FLEXCOP_DEBUG is not set

#
# Supported BT878 Adapters
#
CONFIG_DVB_BT8XX=m

#
# Supported Pluto2 Adapters
#
CONFIG_DVB_PLUTO2=m

#
# Supported SDMC DM1105 Adapters
#
CONFIG_DVB_DM1105=m

#
# Supported FireWire (IEEE 1394) Adapters
#
# CONFIG_DVB_FIREDTV is not set

#
# Supported Earthsoft PT1 Adapters
#
CONFIG_DVB_PT1=m

#
# Supported Mantis Adapters
#
# CONFIG_MANTIS_CORE is not set

#
# Supported nGene Adapters
#
# CONFIG_DVB_NGENE is not set

#
# Supported DVB Frontends
#
# CONFIG_DVB_FE_CUSTOMISE is not set

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=m
CONFIG_DVB_STB6100=m
CONFIG_DVB_STV090x=m
CONFIG_DVB_STV6110x=m

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=m
CONFIG_DVB_CX24123=m
CONFIG_DVB_MT312=m
CONFIG_DVB_ZL10036=m
CONFIG_DVB_ZL10039=m
CONFIG_DVB_S5H1420=m
CONFIG_DVB_STV0288=m
CONFIG_DVB_STB6000=m
CONFIG_DVB_STV0299=m
CONFIG_DVB_STV6110=m
CONFIG_DVB_STV0900=m
CONFIG_DVB_TDA8083=m
CONFIG_DVB_TDA10086=m
CONFIG_DVB_TDA8261=m
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
CONFIG_DVB_TUNER_CX24113=m
CONFIG_DVB_TDA826X=m
CONFIG_DVB_TUA6100=m
CONFIG_DVB_CX24116=m
CONFIG_DVB_SI21XX=m
CONFIG_DVB_DS3000=m

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=m
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22700=m
CONFIG_DVB_CX22702=m
CONFIG_DVB_L64781=m
CONFIG_DVB_TDA1004X=m
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
CONFIG_DVB_DIB3000MB=m
CONFIG_DVB_DIB3000MC=m
CONFIG_DVB_DIB7000M=m
CONFIG_DVB_DIB7000P=m
CONFIG_DVB_TDA10048=m
CONFIG_DVB_AF9013=m
CONFIG_DVB_STV0367=m

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=m
CONFIG_DVB_TDA10021=m
CONFIG_DVB_TDA10023=m
CONFIG_DVB_STV0297=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_OR51211=m
CONFIG_DVB_OR51132=m
CONFIG_DVB_BCM3510=m
CONFIG_DVB_LGDT330X=m
CONFIG_DVB_LGDT3305=m
CONFIG_DVB_S5H1409=m
CONFIG_DVB_AU8522=m
CONFIG_DVB_S5H1411=m

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=m
CONFIG_DVB_DIB8000=m
CONFIG_DVB_MB86A20S=m

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=m
CONFIG_DVB_TUNER_DIB0070=m
CONFIG_DVB_TUNER_DIB0090=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_LNBP21=m
CONFIG_DVB_ISL6405=m
CONFIG_DVB_ISL6421=m
CONFIG_DVB_ISL6423=m
CONFIG_DVB_LGS8GXX=m
CONFIG_DVB_ATBM8830=m

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_TTM=m
# CONFIG_DRM_TDFX is not set
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_RADEON_KMS=y
# CONFIG_DRM_I810 is not set
CONFIG_DRM_I915=m
CONFIG_DRM_I915_KMS=y
CONFIG_DRM_MGA=m
CONFIG_DRM_SIS=m
CONFIG_DRM_VIA=m
CONFIG_DRM_SAVAGE=m
# CONFIG_STUB_POULSBO is not set
CONFIG_VGASTATE=m
CONFIG_VIDEO_OUTPUT_CONTROL=m
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=m
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
# CONFIG_FB_WMT_GE_ROPS is not set
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=m
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
CONFIG_FB_VGA16=m
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=m
CONFIG_FB_NVIDIA_I2C=y
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=m
# CONFIG_FB_RIVA_I2C is not set
# CONFIG_FB_RIVA_DEBUG is not set
CONFIG_FB_RIVA_BACKLIGHT=y
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=m
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=m
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=m
CONFIG_FB_ATY_CT=y
CONFIG_FB_ATY_GENERIC_LCD=y
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
# CONFIG_FB_S3 is not set
CONFIG_FB_SAVAGE=m
CONFIG_FB_SAVAGE_I2C=y
CONFIG_FB_SAVAGE_ACCEL=y
# CONFIG_FB_SIS is not set
CONFIG_FB_VIA=m
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_TMIO is not set
CONFIG_FB_SM501=m
# CONFIG_FB_UDL is not set
CONFIG_FB_VIRTUAL=m
CONFIG_XEN_FBDEV_FRONTEND=y
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
CONFIG_LCD_PLATFORM=m
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_PROGEAR=m
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set

#
# Display device support
#
CONFIG_DISPLAY_SUPPORT=m

#
# Display hardware drivers
#

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_HRTIMER=m
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_DYNAMIC_MINORS=y
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=m
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
CONFIG_SND_EMU10K1_SEQ=m
CONFIG_SND_MPU401_UART=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
CONFIG_SND_DUMMY=m
# CONFIG_SND_ALOOP is not set
CONFIG_SND_VIRMIDI=m
CONFIG_SND_MTPAV=m
# CONFIG_SND_MTS64 is not set
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=m
# CONFIG_SND_PORTMAN2X4 is not set
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=5
CONFIG_SND_SB_COMMON=m
CONFIG_SND_SB16_DSP=m
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=m
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
CONFIG_SND_ALI5451=m
# CONFIG_SND_ASIHPI is not set
CONFIG_SND_ATIIXP=m
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
CONFIG_SND_AU8820=m
CONFIG_SND_AU8830=m
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
CONFIG_SND_BT87X=m
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=m
# CONFIG_SND_CMIPCI is not set
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
# CONFIG_SND_CS4281 is not set
CONFIG_SND_CS46XX=m
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CS5530=m
CONFIG_SND_CS5535AUDIO=m
CONFIG_SND_CTXFI=m
CONFIG_SND_DARLA20=m
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=m
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
CONFIG_SND_INDIGOIOX=m
CONFIG_SND_INDIGODJX=m
CONFIG_SND_EMU10K1=m
CONFIG_SND_EMU10K1X=m
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
# CONFIG_SND_ES1938 is not set
CONFIG_SND_ES1968=m
# CONFIG_SND_ES1968_INPUT is not set
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_HWDEP=y
# CONFIG_SND_HDA_RECONFIG is not set
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
CONFIG_SND_HDA_INPUT_JACK=y
# CONFIG_SND_HDA_PATCH_LOADER is not set
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=m
CONFIG_SND_KORG1212=m
CONFIG_SND_LX6464ES=m
CONFIG_SND_MAESTRO3=m
# CONFIG_SND_MAESTRO3_INPUT is not set
CONFIG_SND_MIXART=m
# CONFIG_SND_NM256 is not set
CONFIG_SND_PCXHR=m
# CONFIG_SND_RIPTIDE is not set
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
# CONFIG_SND_SONICVIBES is not set
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
CONFIG_SND_VIRTUOSO=m
CONFIG_SND_VX222=m
# CONFIG_SND_YMFPCI is not set
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=m
# CONFIG_SND_USB_UA101 is not set
CONFIG_SND_USB_USX2Y=m
CONFIG_SND_USB_CAIAQ=m
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=m
# CONFIG_SND_USB_6FIRE is not set
CONFIG_SND_FIREWIRE=y
# CONFIG_SND_FIREWIRE_SPEAKERS is not set
CONFIG_SND_PCMCIA=y
# CONFIG_SND_VXPOCKET is not set
# CONFIG_SND_PDAUDIOCF is not set
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=m
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
CONFIG_HIDRAW=y

#
# USB Input Devices
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# Special HID drivers
#
# CONFIG_HID_3M_PCT is not set
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
CONFIG_HID_BELKIN=y
# CONFIG_HID_CANDO is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_PRODIKEYS is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
CONFIG_HID_LOGITECH=y
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWII_FF is not set
CONFIG_HID_MICROSOFT=y
# CONFIG_HID_MOSART is not set
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTRIG=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_QUANTA is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_ROCCAT_ARVO is not set
# CONFIG_HID_ROCCAT_KONE is not set
# CONFIG_HID_ROCCAT_KONEPLUS is not set
# CONFIG_HID_ROCCAT_KOVAPLUS is not set
# CONFIG_HID_ROCCAT_PYRA is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
# CONFIG_HID_STANTUM is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_DEVICE_CLASS is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_SUSPEND=y
# CONFIG_USB_OTG is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=m
CONFIG_USB_WUSB_CBAF=m
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=m
# CONFIG_USB_XHCI_HCD_DEBUGGING is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
CONFIG_USB_ISP1362_HCD=m
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=m
CONFIG_USB_SL811_HCD=m
# CONFIG_USB_SL811_CS is not set
# CONFIG_USB_R8A66597_HCD is not set
CONFIG_USB_WHCI_HCD=m
CONFIG_USB_HWA_HCD=m

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=m
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
CONFIG_USB_STORAGE_DATAFAB=m
CONFIG_USB_STORAGE_FREECOM=m
CONFIG_USB_STORAGE_ISD200=m
CONFIG_USB_STORAGE_USBAT=m
CONFIG_USB_STORAGE_SDDR09=m
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=m
CONFIG_USB_STORAGE_ALAUDA=m
CONFIG_USB_STORAGE_ONETOUCH=m
CONFIG_USB_STORAGE_KARMA=m
CONFIG_USB_STORAGE_CYPRESS_ATACB=m
# CONFIG_USB_STORAGE_ENE_UB6250 is not set
# CONFIG_USB_UAS is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USB_MICROTEK=m

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=m
CONFIG_USB_EZUSB=y
CONFIG_USB_SERIAL_GENERIC=y
CONFIG_USB_SERIAL_AIRCABLE=m
CONFIG_USB_SERIAL_ARK3116=m
CONFIG_USB_SERIAL_BELKIN=m
CONFIG_USB_SERIAL_CH341=m
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP210X=m
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_FUNSOFT=m
CONFIG_USB_SERIAL_VISOR=m
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
CONFIG_USB_SERIAL_GARMIN=m
CONFIG_USB_SERIAL_IPW=m
CONFIG_USB_SERIAL_IUU=m
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
CONFIG_USB_SERIAL_KEYSPAN=m
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
CONFIG_USB_SERIAL_MCT_U232=m
CONFIG_USB_SERIAL_MOS7720=m
# CONFIG_USB_SERIAL_MOS7715_PARPORT is not set
CONFIG_USB_SERIAL_MOS7840=m
CONFIG_USB_SERIAL_MOTOROLA=m
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=m
# CONFIG_USB_SERIAL_QCAUX is not set
CONFIG_USB_SERIAL_QUALCOMM=m
CONFIG_USB_SERIAL_SPCP8X5=m
CONFIG_USB_SERIAL_HP4X=m
CONFIG_USB_SERIAL_SAFE=m
CONFIG_USB_SERIAL_SAFE_PADDED=y
# CONFIG_USB_SERIAL_SAMBA is not set
CONFIG_USB_SERIAL_SIEMENS_MPI=m
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
CONFIG_USB_SERIAL_SYMBOL=m
CONFIG_USB_SERIAL_TI=m
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
CONFIG_USB_SERIAL_OPTICON=m
# CONFIG_USB_SERIAL_VIVOPAY_SERIAL is not set
# CONFIG_USB_SERIAL_ZIO is not set
# CONFIG_USB_SERIAL_SSU100 is not set
CONFIG_USB_SERIAL_DEBUG=m

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=m
CONFIG_USB_SEVSEG=m
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
CONFIG_USB_LED=m
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=m
CONFIG_USB_FTDI_ELAN=m
CONFIG_USB_APPLEDISPLAY=m
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=m
# CONFIG_USB_TRANCEVIBRATOR is not set
CONFIG_USB_IOWARRIOR=m
# CONFIG_USB_TEST is not set
CONFIG_USB_ISIGHTFW=m
# CONFIG_USB_YUREX is not set
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
CONFIG_USB_OTG_UTILS=y
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_NOP_USB_XCEIV=m
CONFIG_UWB=m
CONFIG_UWB_HWA=m
CONFIG_UWB_WHCI=m
CONFIG_UWB_I1480U=m
CONFIG_MMC=m
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
CONFIG_SDIO_UART=m
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=m
CONFIG_MMC_SDHCI_PCI=m
# CONFIG_MMC_RICOH_MMC is not set
CONFIG_MMC_SDHCI_PLTFM=m
# CONFIG_MMC_WBSD is not set
CONFIG_MMC_TIFM_SD=m
CONFIG_MMC_SDRICOH_CS=m
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
# CONFIG_MMC_USHC is not set
CONFIG_MEMSTICK=m
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=m

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
CONFIG_MEMSTICK_JMICRON_38X=m
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_ALIX2=m
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_CLEVO_MAIL=m
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_REGULATOR is not set
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_DELL_NETBOOKS is not set
CONFIG_LEDS_TRIGGERS=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
CONFIG_LEDS_TRIGGER_BACKLIGHT=m
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_NFC_DEVICES is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=m
CONFIG_INFINIBAND_USER_MAD=m
CONFIG_INFINIBAND_USER_ACCESS=m
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_MTHCA=m
CONFIG_INFINIBAND_MTHCA_DEBUG=y
CONFIG_INFINIBAND_IPATH=m
# CONFIG_INFINIBAND_QIB is not set
# CONFIG_INFINIBAND_AMSO1100 is not set
CONFIG_INFINIBAND_CXGB3=m
# CONFIG_INFINIBAND_CXGB3_DEBUG is not set
CONFIG_MLX4_INFINIBAND=m
CONFIG_INFINIBAND_NES=m
# CONFIG_INFINIBAND_NES_DEBUG is not set
CONFIG_INFINIBAND_IPOIB=m
CONFIG_INFINIBAND_IPOIB_CM=y
CONFIG_INFINIBAND_IPOIB_DEBUG=y
# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
CONFIG_INFINIBAND_SRP=m
CONFIG_INFINIBAND_ISER=m
CONFIG_EDAC=y

#
# Reporting subsystems
#
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=m
# CONFIG_EDAC_MCE_INJ is not set
CONFIG_EDAC_MM_EDAC=m
CONFIG_EDAC_AMD64=m
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
CONFIG_EDAC_E752X=m
CONFIG_EDAC_I82975X=m
CONFIG_EDAC_I3000=m
CONFIG_EDAC_I3200=m
CONFIG_EDAC_X38=m
CONFIG_EDAC_I5400=m
# CONFIG_EDAC_I7CORE is not set
CONFIG_EDAC_I5000=m
CONFIG_EDAC_I5100=m
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_DS1307=m
CONFIG_RTC_DRV_DS1374=m
CONFIG_RTC_DRV_DS1672=m
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_MAX6900=m
CONFIG_RTC_DRV_RS5C372=m
CONFIG_RTC_DRV_ISL1208=m
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PCF8563=m
CONFIG_RTC_DRV_PCF8583=m
CONFIG_RTC_DRV_M41T80=m
CONFIG_RTC_DRV_M41T80_WDT=y
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=m
CONFIG_RTC_DRV_RX8581=m
CONFIG_RTC_DRV_RX8025=m

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=m
CONFIG_RTC_DRV_DS1511=m
CONFIG_RTC_DRV_DS1553=m
CONFIG_RTC_DRV_DS1742=m
CONFIG_RTC_DRV_STK17TA8=m
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=m
CONFIG_RTC_DRV_M48T59=m
# CONFIG_RTC_DRV_MSM6242 is not set
CONFIG_RTC_DRV_BQ4802=m
# CONFIG_RTC_DRV_RP5C01 is not set
CONFIG_RTC_DRV_V3020=m

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=m
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set
CONFIG_DCA=m
CONFIG_AUXDISPLAY=y
CONFIG_KS0108=m
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
CONFIG_CFAG12864B=m
CONFIG_CFAG12864B_RATE=20
CONFIG_UIO=m
CONFIG_UIO_CIF=m
CONFIG_UIO_PDRV=m
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
# CONFIG_UIO_NETX is not set

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
CONFIG_XEN_SCRUB_PAGES=y
CONFIG_XEN_DEV_EVTCHN=m
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=m
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=m
CONFIG_XEN_GRANT_DEV_ALLOC=m
CONFIG_XEN_PLATFORM_PCI=m
CONFIG_SWIOTLB_XEN=y
CONFIG_STAGING=y
# CONFIG_STAGING_EXCLUDE_BUILD is not set
# CONFIG_DIGIEPCA is not set
# CONFIG_RISCOM8 is not set
# CONFIG_SPECIALIX is not set
# CONFIG_COMPUTONE is not set
# CONFIG_ET131X is not set
# CONFIG_SLICOSS is not set
# CONFIG_VIDEO_GO7007 is not set
# CONFIG_VIDEO_CX25821 is not set
# CONFIG_VIDEO_TM6000 is not set
# CONFIG_USB_IP_COMMON is not set
# CONFIG_W35UND is not set
# CONFIG_PRISM2_USB is not set
# CONFIG_ECHO is not set
# CONFIG_BRCM80211 is not set
# CONFIG_RT2860 is not set
# CONFIG_RT2870 is not set
# CONFIG_COMEDI is not set
# CONFIG_ASUS_OLED is not set
# CONFIG_PANEL is not set
# CONFIG_R8187SE is not set
# CONFIG_RTL8192U is not set
# CONFIG_RTL8192E is not set
# CONFIG_R8712U is not set
# CONFIG_RTS_PSTOR is not set
# CONFIG_TRANZPORT is not set
# CONFIG_POHMELFS is not set
# CONFIG_IDE_PHISON is not set
# CONFIG_LINE6_USB is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_NOUVEAU is not set

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_USB_SERIAL_QUATECH2 is not set
# CONFIG_USB_SERIAL_QUATECH_USB2 is not set
# CONFIG_VT6655 is not set
# CONFIG_VT6656 is not set
# CONFIG_HYPERV is not set
# CONFIG_VME_BUS is not set
# CONFIG_DX_SEP is not set
# CONFIG_IIO is not set
# CONFIG_XVMALLOC is not set
# CONFIG_ZRAM is not set
# CONFIG_WLAGS49_H2 is not set
# CONFIG_WLAGS49_H25 is not set
# CONFIG_FB_SM7XX is not set
# CONFIG_VIDEO_DT3155 is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_CXT1E1 is not set
# CONFIG_FB_XGI is not set
# CONFIG_LIRC_STAGING is not set
# CONFIG_EASYCAP is not set
# CONFIG_SOLO6X10 is not set
# CONFIG_ACPI_QUICKSTART is not set
CONFIG_MACH_NO_WESTBRIDGE=y
# CONFIG_SBE_2T3E3 is not set
# CONFIG_ATH6K_LEGACY is not set
# CONFIG_USB_ENESTORAGE is not set
# CONFIG_BCM_WIMAX is not set
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
# CONFIG_DRM_PSB is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=m
CONFIG_ASUS_LAPTOP=m
CONFIG_DELL_LAPTOP=m
CONFIG_DELL_WMI=m
# CONFIG_DELL_WMI_AIO is not set
CONFIG_FUJITSU_LAPTOP=m
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
# CONFIG_HP_ACCEL is not set
CONFIG_HP_WMI=m
CONFIG_MSI_LAPTOP=m
CONFIG_PANASONIC_LAPTOP=m
CONFIG_COMPAL_LAPTOP=m
CONFIG_SONY_LAPTOP=m
CONFIG_SONYPI_COMPAT=y
# CONFIG_IDEAPAD_LAPTOP is not set
CONFIG_THINKPAD_ACPI=m
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=m
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ASUS_WMI is not set
CONFIG_ACPI_WMI=m
# CONFIG_MSI_WMI is not set
# CONFIG_ACPI_ASUS is not set
CONFIG_TOPSTAR_LAPTOP=m
CONFIG_ACPI_TOSHIBA=m
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_EFI_VARS=y
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=m
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=m
# CONFIG_SIGMA is not set

#
# File systems
#
CONFIG_EXT2_FS=m
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
CONFIG_EXT2_FS_XIP=y
CONFIG_EXT3_FS=m
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=m
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_FS_XIP=y
CONFIG_JBD=m
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=m
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=m
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=m
CONFIG_GFS2_FS_LOCKING_DLM=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=m
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=m
CONFIG_FUSE_FS=m
CONFIG_CUSE=m
CONFIG_GENERIC_ACL=y

#
# Caches
#
CONFIG_FSCACHE=m
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=m
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
CONFIG_ECRYPT_FS=m
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
CONFIG_JFFS2_FS=m
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
# CONFIG_JFFS2_FS_WBUF_VERIFY is not set
CONFIG_JFFS2_SUMMARY=y
CONFIG_JFFS2_FS_XATTR=y
CONFIG_JFFS2_FS_POSIX_ACL=y
CONFIG_JFFS2_FS_SECURITY=y
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
CONFIG_UBIFS_FS=m
CONFIG_UBIFS_FS_XATTR=y
# CONFIG_UBIFS_FS_ADVANCED_COMPR is not set
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
# CONFIG_UBIFS_FS_DEBUG is not set
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=m
CONFIG_SQUASHFS=m
# CONFIG_SQUASHFS_XATTR is not set
# CONFIG_SQUASHFS_LZO is not set
# CONFIG_SQUASHFS_XZ is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_PSTORE is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_EXOFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
CONFIG_NFS_V4_1=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_NFS_FSCACHE=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFS_USE_NEW_IDMAPPER is not set
CONFIG_NFSD=m
CONFIG_NFSD_DEPRECATED=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_XPRT_RDMA=m
CONFIG_RPCSEC_GSS_KRB5=m
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=m
CONFIG_CIFS_STATS=y
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CIFS_ACL is not set
CONFIG_CIFS_EXPERIMENTAL=y
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
# CONFIG_9P_FS is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_HARDLOCKUP_DETECTOR is not set
CONFIG_DETECT_HUNG_TASK=y
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_DEBUG_SLAB is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_INFO_REDUCED is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_LIST=y
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_RCU_CPU_STALL_DETECTOR is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
# CONFIG_LKDTM is not set
# CONFIG_CPU_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
# CONFIG_SYSCTL_SYSCALL_CHECK is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FTRACE_NMI_ENTER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_RING_BUFFER=y
CONFIG_FTRACE_NMI_ENTER=y
CONFIG_EVENT_TRACING=y
CONFIG_EVENT_POWER_TRACING_DEPRECATED=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_RING_BUFFER_BENCHMARK=m
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set
CONFIG_BUILD_DOCSRC=y
CONFIG_DYNAMIC_DEBUG=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_ASYNC_RAID6_TEST=m
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_KGDB=y
CONFIG_KGDB_SERIAL_CONSOLE=y
CONFIG_KGDB_TESTS=y
# CONFIG_KGDB_TESTS_ON_BOOT is not set
# CONFIG_KGDB_LOW_LEVEL_TRAP is not set
# CONFIG_KGDB_KDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_TEST_KSTRTOX is not set
CONFIG_STRICT_DEVMEM=y
# CONFIG_X86_VERBOSE_BOOTUP is not set
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
CONFIG_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_SET_MODULE_RONX is not set
CONFIG_DEBUG_NX_TEST=m
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
# CONFIG_SECURITY_PATH is not set
# CONFIG_INTEL_TXT is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_AUDIT=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=m
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=m
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=m
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=m
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=m
CONFIG_CRYPTO_NULL=m
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=m
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=m
CONFIG_CRYPTO_SEQIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
CONFIG_CRYPTO_CTR=m
CONFIG_CRYPTO_CTS=m
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_LRW=m
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=m
CONFIG_CRYPTO_FPU=m

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_GHASH=m
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_RMD128=m
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=m
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_SHA512=m
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=m
CONFIG_CRYPTO_AES_X86_64=m
CONFIG_CRYPTO_AES_NI_INTEL=m
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_X86_64=m
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_TEA=m
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
CONFIG_CRYPTO_ZLIB=m
CONFIG_CRYPTO_LZO=m

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=m
CONFIG_CRYPTO_DEV_PADLOCK_AES=m
CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
CONFIG_CRYPTO_DEV_HIFN_795X=m
CONFIG_CRYPTO_DEV_HIFN_795X_RNG=y
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_GENERIC_FIND_LAST_BIT=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=m
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
CONFIG_CRC7=m
CONFIG_LIBCRC32C=m
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=m
CONFIG_LZO_COMPRESS=m
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_NLATTR=y
CONFIG_AVERAGE=y

--=====================_-1956235454==_--
