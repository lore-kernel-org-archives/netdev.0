From: Dave Jones <davej@codemonkey.org.uk>
Subject: [net-next] tcp_delack_timer circular locking dependancy
Date: Mon, 30 Oct 2017 15:20:53 -0400
Message-ID: <20171030192053.mwc3tqp3kuukbhwv@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:56688 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932723AbdJ3TUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 15:20:54 -0400
Received: from [2601:196:4600:5b90:ae9e:17ff:feb7:72ca] (helo=wopr.kernelslacker.org)
        by scorn.kernelslacker.org with esmtp (Exim 4.89)
        (envelope-from <davej@codemonkey.org.uk>)
        id 1e9FcD-000196-NV
        for netdev@vger.kernel.org; Mon, 30 Oct 2017 15:20:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[  105.316650] ======================================================
[  105.316818] WARNING: possible circular locking dependency detected
[  105.316986] 4.14.0-rc7-think+ #1 Not tainted
[  105.317108] ------------------------------------------------------
[  105.317273] swapper/2/0 is trying to acquire lock:
[  105.317407]  (
[  105.317476] slock-AF_INET6
[  105.317564] ){+.-.}
[  105.317642] , at: [<ffffffff8214d306>] tcp_delack_timer+0x26/0x130
[  105.317807] 
               but task is already holding lock:
[  105.317961]  (
[  105.318024] (timer)
[  105.318097] #5
[  105.318168] ){+.-.}
[  105.318241] , at: [<ffffffff811cdbc5>] call_timer_fn+0x5/0x5e0
[  105.318393] 
               which lock already depends on the new lock.

[  105.318594] 
               the existing dependency chain (in reverse order) is:
[  105.318781] 
               -> #1
[  105.318879]  (
[  105.318939] (timer)
[  105.319009] #5
[  105.319068] ){+.-.}
[  105.319137] :
[  105.319195]        del_timer_sync+0x3c/0xb0
[  105.319313]        inet_csk_reqsk_queue_drop+0x26c/0x4e0
[  105.319459]        inet_csk_complete_hashdance+0x1e/0x90
[  105.319598]        tcp_check_req+0x787/0x9a0
[  105.319716]        tcp_v6_rcv+0x914/0x1060
[  105.319828]        ip6_input_finish+0x291/0xba0
[  105.319950]        ip6_input+0xb2/0x380
[  105.320059]        ip6_rcv_finish+0x103/0x350
[  105.320180]        ipv6_rcv+0x93f/0xff0
[  105.320291]        __netif_receive_skb_core+0x13ef/0x1900
[  105.320436]        netif_receive_skb_internal+0xea/0x4c0
[  105.320579]        napi_gro_receive+0x28e/0x320
[  105.320705]        e1000_clean_rx_irq+0x3e9/0x6f0
[  105.320838]        e1000e_poll+0x14e/0x570
[  105.320954]        net_rx_action+0x4db/0xc80
[  105.321075]        __do_softirq+0x1ca/0x7bf
[  105.321194]        irq_exit+0x104/0x110
[  105.321303]        do_IRQ+0xb2/0x130
[  105.321407]        ret_from_intr+0x0/0x19
[  105.321523]        cpuidle_enter_state+0x223/0x5b0
[  105.321655]        do_idle+0x110/0x1b0
[  105.321766]        cpu_startup_entry+0xdb/0xe0
[  105.321891]        start_secondary+0x2e9/0x360
[  105.322014]        verify_cpu+0x0/0xf1
[  105.322121] 
               -> #0
[  105.322215]  (
[  105.322276] slock-AF_INET6
[  105.322359] ){+.-.}
[  105.322428] :
[  105.322487]        lock_acquire+0x12e/0x350
[  105.322602]        _raw_spin_lock+0x30/0x70
[  105.322722]        tcp_delack_timer+0x26/0x130
[  105.322846]        call_timer_fn+0x188/0x5e0
[  105.322966]        __run_timers+0x54d/0x670
[  105.323084]        run_timer_softirq+0x2a/0x50
[  105.323208]        __do_softirq+0x1ca/0x7bf
[  105.323325]        irq_exit+0x104/0x110
[  105.323435]        smp_apic_timer_interrupt+0x14b/0x510
[  105.323576]        apic_timer_interrupt+0x9a/0xa0
[  105.323705]        cpuidle_enter_state+0x223/0x5b0
[  105.323836]        do_idle+0x110/0x1b0
[  105.323944]        cpu_startup_entry+0xdb/0xe0
[  105.324067]        start_secondary+0x2e9/0x360
[  105.324189]        verify_cpu+0x0/0xf1
[  105.324295] 
               other info that might help us debug this:

[  105.324489]  Possible unsafe locking scenario:

[  105.324644]        CPU0                    CPU1
[  105.324767]        ----                    ----
[  105.324890]   lock(
[  105.324963] (timer)
[  105.325033] #5
[  105.325093] );
[  105.325152]                                lock(
[  105.325278] slock-AF_INET6
[  105.325360] );
[  105.325419]                                lock(
[  105.325544] (timer)
[  105.325612] #5
[  105.325670] );
[  105.325729]   lock(
[  105.325797] slock-AF_INET6
[  105.325879] );
[  105.325938] 
                *** DEADLOCK ***

[  105.326086] 1 lock held by swapper/2/0:
[  105.326193]  #0: 
[  105.326257]  (
[  105.331697] (timer)
[  105.337038] #5
[  105.342339] ){+.-.}
[  105.347620] , at: [<ffffffff811cdbc5>] call_timer_fn+0x5/0x5e0
[  105.353021] 
               stack backtrace:
[  105.363515] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.14.0-rc7-think+ #1
[  105.368886] Hardware name: LENOVO ThinkServer TS140/ThinkServer TS140, BIOS FBKTB3AUS 06/16/2015
[  105.374330] Call Trace:
[  105.379697]  <IRQ>
[  105.384997]  dump_stack+0xbc/0x145
[  105.390339]  ? dma_virt_map_sg+0xfb/0xfb
[  105.395733]  ? call_timer_fn+0x5/0x5e0
[  105.401076]  ? print_lock+0x54/0x68
[  105.406344]  print_circular_bug.isra.42+0x283/0x2bc
[  105.411695]  ? print_circular_bug_header+0xda/0xda
[  105.417054]  ? graph_lock+0x8d/0x100
[  105.422419]  ? check_noncircular+0x20/0x20
[  105.427857]  ? sched_clock_cpu+0x14/0xf0
[  105.433309]  __lock_acquire+0x1f4a/0x2050
[  105.438725]  ? debug_check_no_locks_freed+0x1a0/0x1a0
[  105.444160]  ? __lock_acquire+0x6b3/0x2050
[  105.449580]  ? debug_check_no_locks_freed+0x1a0/0x1a0
[  105.455015]  ? sched_clock_cpu+0x14/0xf0
[  105.460514]  ? __lock_acquire+0x6b3/0x2050
[  105.465984]  ? cyc2ns_read_end+0x10/0x10
[  105.471395]  ? debug_check_no_locks_freed+0x1a0/0x1a0
[  105.476934]  ? mark_lock+0x16f/0x9b0
[  105.482507]  ? print_irqtrace_events+0x110/0x110
[  105.488150]  ? native_sched_clock+0xf9/0x1a0
[  105.493856]  ? cyc2ns_read_end+0x10/0x10
[  105.499606]  ? sched_clock_cpu+0x14/0xf0
[  105.505339]  ? native_sched_clock+0xf9/0x1a0
[  105.511118]  ? cyc2ns_read_end+0x10/0x10
[  105.516878]  ? match_held_lock+0x93/0x400
[  105.522601]  ? lock_acquire+0x12e/0x350
[  105.528317]  lock_acquire+0x12e/0x350
[  105.534048]  ? tcp_delack_timer+0x26/0x130
[  105.539782]  ? lock_release+0x890/0x890
[  105.545550]  ? lock_release+0x890/0x890
[  105.551286]  ? save_trace+0x1c0/0x1c0
[  105.556991]  ? tcp_delack_timer_handler+0x370/0x370
[  105.562732]  _raw_spin_lock+0x30/0x70
[  105.568464]  ? tcp_delack_timer+0x26/0x130
[  105.574180]  tcp_delack_timer+0x26/0x130
[  105.579914]  ? tcp_delack_timer_handler+0x370/0x370
[  105.585689]  call_timer_fn+0x188/0x5e0
[  105.591470]  ? __next_timer_interrupt+0xd0/0xd0
[  105.597304]  ? sched_clock_cpu+0x14/0xf0
[  105.603140]  ? lock_downgrade+0x310/0x310
[  105.608971]  ? _raw_spin_unlock_irqrestore+0x45/0x50
[  105.614875]  ? debug_object_deactivate+0x263/0x2a0
[  105.620766]  ? do_raw_spin_unlock+0x147/0x220
[  105.626680]  ? do_raw_spin_trylock+0x100/0x100
[  105.632584]  ? debug_stats_show+0xd0/0xd0
[  105.638464]  ? mark_held_locks+0x1b/0xa0
[  105.644359]  ? _raw_spin_unlock_irq+0x29/0x40
[  105.650277]  ? tcp_delack_timer_handler+0x370/0x370
[  105.656254]  __run_timers+0x54d/0x670
[  105.662301]  ? timer_fixup_init+0x30/0x30
[  105.668379]  ? native_sched_clock+0xf9/0x1a0
[  105.674469]  ? find_held_lock+0x74/0xd0
[  105.680620]  ? cyc2ns_read_end+0x10/0x10
[  105.686773]  ? sched_clock_cpu+0x14/0xf0
[  105.692911]  ? sched_clock_cpu+0x14/0xf0
[  105.699014]  ? lock_downgrade+0x310/0x310
[  105.705084]  ? lock_release+0x890/0x890
[  105.711167]  ? hrtimer_fixup_init+0x40/0x40
[  105.717263]  ? rcu_is_watching+0x88/0xd0
[  105.723337]  ? __lock_is_held+0x2e/0xd0
[  105.729426]  run_timer_softirq+0x2a/0x50
[  105.735507]  __do_softirq+0x1ca/0x7bf
[  105.741560]  ? __irqentry_text_end+0x3/0x3
[  105.747631]  ? lock_release+0x890/0x890
[  105.753696]  ? do_raw_spin_unlock+0x147/0x220
[  105.759778]  ? do_raw_spin_trylock+0x100/0x100
[  105.765854]  ? do_raw_spin_lock+0x110/0x110
[  105.771898]  ? clockevents_program_event+0xf7/0x130
[  105.778005]  ? rcu_is_watching+0x88/0xd0
[  105.784091]  ? __lock_is_held+0x2e/0xd0
[  105.790146]  irq_exit+0x104/0x110
[  105.796218]  smp_apic_timer_interrupt+0x14b/0x510
[  105.802323]  ? smp_call_function_single_interrupt+0x4b0/0x4b0
[  105.808518]  ? rcu_irq_exit+0x27f/0x330
[  105.814750]  ? rcu_idle_enter+0xb0/0xb0
[  105.820986]  ? handle_irq_event+0x73/0x90
[  105.827277]  ? _raw_spin_unlock+0x24/0x30
[  105.833591]  ? trace_hardirqs_off_caller+0xb5/0x100
[  105.839981]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  105.846399]  apic_timer_interrupt+0x9a/0xa0
[  105.852845]  </IRQ>
[  105.859257] RIP: 0010:cpuidle_enter_state+0x223/0x5b0
[  105.865826] RSP: 0018:ffff880465e27cd0 EFLAGS: 00000206
[  105.872418]  ORIG_RAX: ffffffffffffff10
[  105.879060] RAX: 0000000000000000 RBX: ffffe8ffffa0f9a8 RCX: ffffffff8117b82a
[  105.885906] RDX: 0000000000000007 RSI: dffffc0000000000 RDI: ffff880465eb8964
[  105.892780] RBP: 1ffff1008cbc4f9f R08: fffffbfff0643a14 R09: 0000000000000000
[  105.899743] R10: 0000000000000000 R11: 0000000000000000 R12: 000000000265b22b
[  105.906730] R13: 0000000000000005 R14: 0000000000000005 R15: ffffffff82f11de0
[  105.913790]  ? trace_hardirqs_on_caller+0x17a/0x250
[  105.920872]  ? cpuidle_find_deepest_state+0xb0/0xb0
[  105.928015]  ? retint_kernel+0x10/0x10
[  105.935150]  ? tsc_verify_tsc_adjust+0xcb/0x1f0
[  105.942313]  ? native_write_msr.constprop.0+0x30/0x30
[  105.949587]  ? trace_hardirqs_on_caller+0x17a/0x250
[  105.956880]  do_idle+0x110/0x1b0
[  105.964211]  cpu_startup_entry+0xdb/0xe0
[  105.971584]  ? cpu_in_idle+0x20/0x20
[  105.978918]  ? clockevents_config.part.8+0xc0/0xd0
[  105.986257]  start_secondary+0x2e9/0x360
[  105.993611]  ? set_cpu_sibling_map+0x8e0/0x8e0
[  106.000938]  secondary_startup_64+0xa5/0xa5
