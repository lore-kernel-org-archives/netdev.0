From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Fwd: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Fri, 6 Jul 2007 08:20:51 +0200
Message-ID: <20070706062051.GB1846@ff.dom.local>
References: <20070706061420.GA1846@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ranko Zivojnovic <ranko@spidernet.net>, akpm@linux-foundation.org,
	kaber@trash.net, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:36898 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758909AbXGFGMW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 02:12:22 -0400
Content-Disposition: inline
In-Reply-To: <20070706061420.GA1846@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Forwarded message from Ranko Zivojnovic <ranko@spidernet.net> -----

> Date: Thu, 05 Jul 2007 18:59:25 +0300
> From: Ranko Zivojnovic <ranko@spidernet.net>
> Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
> 	to -mm tree
> To: Jarek Poplawski <jarkao2@o2.pl>
> Cc: akpm@linux-foundation.org, kaber@trash.net
> X-Original-To: info
> Delivered-To: info@dom.local
> In-Reply-To: <1183646029.4069.11.camel@ranko-fc2.spidernet.net>
> Organization: SpiderNet Services Public Ltd.
> X-Mailer: Evolution 2.8.3 (2.8.3-2.fc6) 
> X-o2-Trust: 2, 43
> 
> On Thu, 2007-07-05 at 17:34 +0300, Ranko Zivojnovic wrote:
> > Anyhow - I am currently running 2.6.22-rc6-mm1 + sch_htb patch and
> > running a test script that always managed to reproduce the problem
> > within half hour - so far it looks good, but I will leave it hammering
> > until tomorrow and will let you know.
> > 
> 
> Ahm...it managed to get stuck:
> 
> Relevant piece of the process table ('tc' stays stuck):
>  9608 pts/0    S+     0:00 /bin/bash ./tc-crash.sh
>  9609 pts/0    D+     0:00 tc qdisc del dev lo root
> 
> There was no soft lockup kernel warning however sysreq 'w' & 'q' dump
> the following:
> 
> ---cut---
> SysRq : Show Blocked State
> 
>                          free                        sibling
>   task             PC    stack   pid father child younger older
> kjournald     D 00000531     0   337      2 (L-TLB)
>        c3083e9c 00000046 c4ef3383 00000531 c3083e84 00000000 c292f7fc c3082000
>        00000000 00000000 c2903388 c29031d0 c2903388 c150a000 00000000 c03b5d80
>        c29d9480 c2949080 c03ff080 c03ff080 c289e7fc 00000000 c03ff080 0054b8e6
> Call Trace:
>  [<c02e9e1b>] io_schedule+0x1e/0x28
>  [<c0184915>] sync_buffer+0x34/0x37
>  [<c02ea416>] __wait_on_bit+0x42/0x5e
>  [<c01848e1>] sync_buffer+0x0/0x37
>  [<c01848e1>] sync_buffer+0x0/0x37
>  [<c02ea495>] out_of_line_wait_on_bit+0x63/0x6b
>  [<c01320a2>] wake_bit_function+0x0/0x3c
>  [<c0184873>] __wait_on_buffer+0x24/0x29
>  [<e083392e>] journal_commit_transaction+0x63d/0x10df [jbd]
>  [<c02eb265>] _spin_unlock_irq+0x5/0x7
>  [<c02e9713>] schedule+0x323/0x867
>  [<c02eb277>] _spin_lock_irqsave+0x9/0xd
>  [<c0128dfa>] lock_timer_base+0x19/0x35
>  [<c0128e5d>] try_to_del_timer_sync+0x47/0x4f
>  [<e0837899>] kjournald+0xac/0x1f4 [jbd]
>  [<c013206b>] autoremove_wake_function+0x0/0x37
>  [<e08377ed>] kjournald+0x0/0x1f4 [jbd]
>  [<c0131e26>] kthread+0x34/0x56
>  [<c0131df2>] kthread+0x0/0x56
>  [<c0104023>] kernel_thread_helper+0x7/0x14
>  =======================
> syslogd       D 00000531     0  1414      1 (NOTLB)
>        c3045e84 00200082 c4e83c2f 00000531 c1506a80 00000002 00000000 c3044000
>        1d5003ae 00000552 c29de888 c29de6d0 c29de888 c150a000 00000000 00000003
>        00200082 c2949080 c03ff080 c03ff080 c2ac46b0 00000000 c03ff080 0054b8e6
> Call Trace:
>  [<e0836bdb>] log_wait_commit+0xaf/0x116 [jbd]
>  [<c013206b>] autoremove_wake_function+0x0/0x37
>  [<e08316b1>] journal_stop+0x158/0x1f7 [jbd]
>  [<c0180046>] __writeback_single_inode+0x267/0x329
>  [<c014bcd7>] generic_writepages+0x20/0x29
>  [<c0180121>] sync_inode+0x19/0x2a
>  [<e086c4f4>] ext3_sync_file+0xbc/0xc8 [ext3]
>  [<c0182d89>] do_fsync+0x55/0x8a
>  [<c0182ddb>] __do_fsync+0x1d/0x2b
>  [<c01033d2>] sysenter_past_esp+0x5f/0x85
>  =======================
> irqbalance    D 0000040E     0  1428      1 (NOTLB)
>        c304becc 00200082 f5b6412a 0000040e c304beb4 00000000 c34e0000 c304a000
>        00000001 c2a754c4 c22a2848 c22a2690 c22a2848 c1513000 00000001 c03b5d80
>        0000000a c286e480 c03ff080 c03ff080 c03631be c18667e4 c03ff080 003fd3f2
> Call Trace:
>  [<c02ea650>] __mutex_lock_slowpath+0x54/0x8d
>  [<c02ea50e>] mutex_lock+0x21/0x26
>  [<c027d0ef>] sock_ioctl+0x0/0x1c6
>  [<c027d0ef>] sock_ioctl+0x0/0x1c6
>  [<c02895a2>] dev_ioctl+0x20c/0x309
>  [<c018d4d1>] inotify_d_instantiate+0x1b/0x80
>  [<c0175858>] d_instantiate+0x56/0x8a
>  [<c027d12f>] sock_ioctl+0x40/0x1c6
>  [<c027d0ef>] sock_ioctl+0x0/0x1c6
>  [<c017046f>] do_ioctl+0x1f/0x6d
>  [<c027e39f>] sys_socket+0x29/0x44
>  [<c017050d>] vfs_ioctl+0x50/0x26b
>  [<c0170785>] sys_ioctl+0x5d/0x6c
>  [<c01033d2>] sysenter_past_esp+0x5f/0x85
>  =======================
> tc            D 00000409     0  9609   9608 (NOTLB)
>        c37a7be8 00200086 ee308e07 00000409 c1506a80 00000002 00000000 c37a6000
>        3e416208 00000414 c29021e8 c2902030 c29021e8 c150a000 00000000 c321c4c4
>        c37a7bd0 c19d36c0 c03ff080 c03ff080 c0134d71 00200286 c03ff080 003fe1ed
> Call Trace:
>  [<c0134d71>] lock_hrtimer_base+0x15/0x2f
>  [<c02e9d49>] wait_for_completion+0x9e/0xb7
>  [<c011b805>] default_wake_function+0x0/0xc
>  [<c0130122>] synchronize_rcu+0x2a/0x2f
>  [<c012fddb>] wakeme_after_rcu+0x0/0x8
>  [<c0295ba5>] dev_deactivate+0x8a/0xa3
>  [<c0296f12>] dev_graft_qdisc+0x81/0xa4
>  [<c0296f5d>] qdisc_graft+0x28/0x88
>  [<c0297709>] tc_get_qdisc+0x15d/0x1e9
>  [<c02975ac>] tc_get_qdisc+0x0/0x1e9
>  [<c02904f9>] rtnetlink_rcv_msg+0x1c2/0x1f5
>  [<c029b0a0>] netlink_run_queue+0xa7/0x10e
>  [<c0290337>] rtnetlink_rcv_msg+0x0/0x1f5
>  [<c02902e9>] rtnetlink_rcv+0x26/0x42
>  [<c029b5c9>] netlink_data_ready+0x12/0x54
>  [<c029a244>] netlink_sendskb+0x1f/0x53
>  [<c029b4d8>] netlink_sendmsg+0x1f5/0x2d4
>  [<c027dae6>] sock_sendmsg+0xe2/0xfd
>  [<c013206b>] autoremove_wake_function+0x0/0x37
>  [<c013206b>] autoremove_wake_function+0x0/0x37
>  [<c027dae6>] sock_sendmsg+0xe2/0xfd
>  [<c01d9ec3>] copy_from_user+0x2d/0x59
>  [<c027dc2e>] sys_sendmsg+0x12d/0x243
>  [<c014805a>] filemap_fault+0x125/0x42d
>  [<c0151be7>] __do_fault+0x18f/0x37d
>  [<c014afb4>] __alloc_pages+0x4f/0x358
>  [<c0147f35>] filemap_fault+0x0/0x42d
>  [<c0153059>] __handle_mm_fault+0x114/0x662
>  [<c0155717>] acct_stack_growth+0x86/0x9a
>  [<c027ee6d>] sys_socketcall+0x24f/0x271
>  [<c011632c>] do_page_fault+0x0/0x6b4
>  [<c01033d2>] sysenter_past_esp+0x5f/0x85
>  =======================
> Sched Debug Version: v0.03, cfs-v18, 2.6.22-rc6-mm1.SNET.Thors.htbpatch.2 #2
> now at 5852817390013 nsecs
> 
> cpu#0, 2992.428 MHz
>   .nr_running                    : 0
>   .load                          : 0
>   .ls.delta_fair                 : 0
>   .ls.delta_exec                 : 0
>   .nr_switches                   : 339295
>   .nr_load_updates               : 5726868
>   .nr_uninterruptible            : 4294967087
>   .jiffies                       : 5552844
>   .next_balance                  : 5552847
>   .curr->pid                     : 0
>   .clock                         : 5711615883107
>   .prev_clock_raw                : 5850635770741
>   .clock_warps                   : 1
>   .clock_overflows               : 12712
>   .clock_unstable_events         : 0
>   .clock_max_delta               : 1999660
>   .cfs.fair_clock                : 1406994636435
>   .cfs.exec_clock                : 1106293764887
>   .cfs.wait_runtime              : -700502353213
>   .cfs.wait_runtime_overruns     : 36267
>   .cfs.wait_runtime_underruns    : 1329
>   .cpu_load[0]                   : 0
>   .cpu_load[1]                   : 0
>   .cpu_load[2]                   : 0
>   .cpu_load[3]                   : 0
>   .cpu_load[4]                   : 0
>   .wait_runtime_rq_sum           : 0
> 
> runnable tasks:
>             task   PID        tree-key         delta       waiting  switches  prio        sum-exec        sum-wait       sum-sleep    wait-overrun   wait-underrun
> ------------------------------------------------------------------------------------------------------------------------------------------------------------------
> 
> cpu#1, 2992.428 MHz
>   .nr_running                    : 1
>   .load                          : 1024
>   .ls.delta_fair                 : 536356056422
>   .ls.delta_exec                 : 8760209027
>   .nr_switches                   : 401913
>   .nr_load_updates               : 4460569
>   .nr_uninterruptible            : 213
>   .jiffies                       : 5552969
>   .next_balance                  : 4183026
>   .curr->pid                     : 4536
>   .clock                         : 4465134326215
>   .prev_clock_raw                : 5850235012355
>   .clock_warps                   : 0
>   .clock_overflows               : 6100
>   .clock_unstable_events         : 0
>   .clock_max_delta               : 1999533
>   .cfs.fair_clock                : 1265459395930
>   .cfs.exec_clock                : 1019469215716
>   .cfs.wait_runtime              : -866196108791
>   .cfs.wait_runtime_overruns     : 35706
>   .cfs.wait_runtime_underruns    : 4327
>   .cpu_load[0]                   : 2302
>   .cpu_load[1]                   : 2514
>   .cpu_load[2]                   : 1966
>   .cpu_load[3]                   : 1532
>   .cpu_load[4]                   : 1292
>   .wait_runtime_rq_sum           : 15731878
> 
> runnable tasks:
>             task   PID        tree-key         delta       waiting  switches  prio        sum-exec        sum-wait       sum-sleep    wait-overrun   wait-underrun
> ------------------------------------------------------------------------------------------------------------------------------------------------------------------
> R           bash  4536   1265443664052     -15731878      15731878       192   120       144540956       410343770   2862976805398              19               0
> 
> 
> SysRq : Show Pending Timers
> Timer List Version: v0.3
> HRTIMER_MAX_CLOCK_BASES: 2
> now at 6550224915183 nsecs
> 
> cpu: 0
>  clock 0:
>   .index:      0
>   .resolution: 1 nsecs
>   .get_time:   ktime_get_real
>   .offset:     1183655045226773151 nsecs
> active timers:
>  clock 1:
>   .index:      1
>   .resolution: 1 nsecs
>   .get_time:   ktime_get
>   .offset:     0 nsecs
> active timers:
>  #0: <3>BUG: sleeping function called from invalid context at kernel/mutex.c:86
> in_atomic():0, irqs_disabled():1
>  [<c02ea502>] mutex_lock+0x15/0x26
>  [<c021f810>] vt_console_print+0x0/0x287
>  [<c013ff72>] lookup_module_symbol_name+0x14/0xbb
>  [<c01379fc>] print_name_offset+0x1a/0x8e
>  [<c01214c4>] release_console_sem+0x1ae/0x1c9
>  [<c0117f03>] __wake_up_common+0x39/0x59
>  [<c0136787>] getnstimeofday+0x30/0xc9
>  [<c0135116>] ktime_get_ts+0x16/0x44
>  [<c0138389>] timer_list_show+0x65c/0xa5d
>  [<c0139a24>] tick_sched_timer+0x0/0x178
>  [<c0223e93>] __handle_sysrq+0x7a/0x115
>  [<c01a0078>] write_sysrq_trigger+0x0/0x2d
>  [<c01a00a3>] write_sysrq_trigger+0x2b/0x2d
>  [<c019a7f7>] proc_reg_write+0x58/0x79
>  [<c0165a1a>] vfs_write+0xa6/0x13e
>  [<c019a79f>] proc_reg_write+0x0/0x79
>  [<c016600a>] sys_write+0x41/0x6a
>  [<c01033d2>] sysenter_past_esp+0x5f/0x85
>  =======================
> <c34dbef0>, tick_sched_timer, S:01
>  # expires at 6550223000000 nsecs [in 18446744073707636433 nsecs]
>  #1: <c34dbef0>, hrtimer_wakeup, S:01
>  # expires at 6560773230863 nsecs [in 10548315680 nsecs]
>  #2: <c34dbef0>, it_real_fn, S:01
>  # expires at 7238128506303 nsecs [in 687903591120 nsecs]
>  #3: <c34dbef0>, it_real_fn, S:01
>  # expires at 7238392105656 nsecs [in 688167190473 nsecs]
>   .expires_next   : 6550223000000 nsecs
>   .hres_active    : 1
>   .nr_events      : 6409367
>   .nohz_mode      : 0
>   .idle_tick      : 0 nsecs
>   .tick_stopped   : 0
>   .idle_jiffies   : 0
>   .idle_calls     : 0
>   .idle_sleeps    : 0
>   .idle_entrytime : 0 nsecs
>   .idle_sleeptime : 0 nsecs
>   .last_jiffies   : 0
>   .next_jiffies   : 0
>   .idle_expires   : 0 nsecs
> jiffies: 6250223
> 
> cpu: 1
>  clock 0:
>   .index:      0
>   .resolution: 1 nsecs
>   .get_time:   ktime_get_real
>   .offset:     1183655045226773151 nsecs
> active timers:
>  clock 1:
>   .index:      1
>   .resolution: 1 nsecs
>   .get_time:   ktime_get
>   .offset:     0 nsecs
> active timers:
>  #0: <c34dbef0>, hrtimer_wakeup, S:01
>  # expires at 6550773229533 nsecs [in 548314350 nsecs]
>  #1: <c34dbef0>, tick_sched_timer, S:01
>  # expires at 8881205015625 nsecs [in 2330980100442 nsecs]
>  #2: <c34dbef0>, hrtimer_wakeup, S:01
>  # expires at 8894203449198 nsecs [in 2343978534015 nsecs]
>  #3: <c34dbef0>, it_real_fn, S:01
>  # expires at 8911201851655 nsecs [in 2360976936472 nsecs]
>  #4: <c34dbef0>, hrtimer_wakeup, S:01
>  # expires at 9181203252434 nsecs [in 2630978337251 nsecs]
>  #5: <c34dbef0>, hrtimer_wakeup, S:01
>  # expires at 9841202403256 nsecs [in 3290977488073 nsecs]
>   .expires_next   : 6550773229533 nsecs
>   .hres_active    : 1
>   .nr_events      : 4475068
>   .nohz_mode      : 0
>   .idle_tick      : 0 nsecs
>   .tick_stopped   : 0
>   .idle_jiffies   : 0
>   .idle_calls     : 0
>   .idle_sleeps    : 0
>   .idle_entrytime : 0 nsecs
>   .idle_sleeptime : 0 nsecs
>   .last_jiffies   : 0
>   .next_jiffies   : 0
>   .idle_expires   : 0 nsecs
> jiffies: 6250223
> 
> 
> Tick Device: mode:     1
> Clock Event Device: pit
>  max_delta_ns:   27461866
>  min_delta_ns:   12571
>  mult:           5124677
>  shift:          32
>  mode:           3
>  next_event:     9223372036854775807 nsecs
>  set_next_event: pit_next_event
>  set_mode:       init_pit_timer
>  event_handler:  tick_handle_oneshot_broadcast
> tick_broadcast_mask: 00000000
> tick_broadcast_oneshot_mask: 00000000
> 
> 
> Tick Device: mode:     1
> Clock Event Device: lapic
>  max_delta_ns:   2037624802
>  min_delta_ns:   3643
>  mult:           17681760
>  shift:          32
>  mode:           3
>  next_event:     6550223000000 nsecs
>  set_next_event: lapic_next_event
>  set_mode:       lapic_timer_setup
>  event_handler:  hrtimer_interrupt
> 
> Tick Device: mode:     1
> Clock Event Device: lapic
>  max_delta_ns:   2037624802
>  min_delta_ns:   3643
>  mult:           17681760
>  shift:          32
>  mode:           3
>  next_event:     6550773229533 nsecs
>  set_next_event: lapic_next_event
>  set_mode:       lapic_timer_setup
>  event_handler:  hrtimer_interrupt
> 
> 
> ---cut---
> 
> R.
> 
> 

----- End forwarded message -----
