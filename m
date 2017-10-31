From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next: del_timer_sync(): possible circular locking
 dependency detected
Date: Tue, 31 Oct 2017 05:38:08 -0700
Message-ID: <1509453488.3828.18.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CANaxB-zFCh8wKtZF+xtP=hf+Ze3UXfAkqOmFxX2_h=-QpZc9CQ@mail.gmail.com>
         <1508479673.30291.6.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171031100427.GF1972@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrei Vagin <avagin@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:43612 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdJaMiK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 08:38:10 -0400
Received: by mail-pg0-f67.google.com with SMTP id s75so14556856pgs.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 05:38:10 -0700 (PDT)
In-Reply-To: <20171031100427.GF1972@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 11:04 +0100, Jiri Pirko wrote:
> Fri, Oct 20, 2017 at 08:07:53AM CEST, eric.dumazet@gmail.com wrote:
> >On Thu, 2017-10-19 at 22:06 -0700, Andrei Vagin wrote:
> >> Hi,
> >> 
> >> We run criu tests on net-next/master regularly, and today tests
> >> triggered this warning:
> >> 
> >> v4.14-rc4-1168-g7a0947e
> >> 
> >> [   23.922640] ======================================================
> >> [   23.922735] WARNING: possible circular locking dependency detected
> >> [   23.922823] 4.14.0-rc4+ #1 Not tainted
> >> [   23.922910] ------------------------------------------------------
> >> [   23.922995] criu/1679 is trying to acquire lock:
> >> [   23.923081]  ((timer)){+.-.}, at: [<ffffffff8e12b5d5>]
> >> del_timer_sync+0x5/0xc0
> >> [   23.923186]
> >> [   23.923186] but task is already holding lock:
> >> [   23.923280]  (slock-AF_INET){+.-.}, at: [<ffffffff8e93131f>]
> >> sk_clone_lock+0x1af/0x580
> >> [   23.923380]
> >> [   23.923380] which lock already depends on the new lock.
> >> [   23.923380]
> >> [   23.923482]
> >> [   23.923482] the existing dependency chain (in reverse order) is:
> >> [   23.923576]
> >> [   23.923576] -> #1 (slock-AF_INET){+.-.}:
> >> [   23.923678]        __lock_acquire+0x10fc/0x11a0
> >> [   23.923775]        lock_acquire+0xed/0x1e0
> >> [   23.923865]        _raw_spin_lock+0x2f/0x40
> >> [   23.923955]        tcp_write_timer+0x29/0xd0
> >> [   23.924042]        call_timer_fn+0x9b/0x330
> >> [   23.924131]        run_timer_softirq+0x235/0x5f0
> >> [   23.924217]        __do_softirq+0xd1/0x4a8
> >> [   23.924311]        irq_exit+0xd4/0xe0
> >> [   23.924400]        smp_apic_timer_interrupt+0xa1/0x2c0
> >> [   23.924491]        apic_timer_interrupt+0x9d/0xb0
> >> [   23.924582]        native_safe_halt+0x6/0x10
> >> [   23.924672]        default_idle+0x23/0x1b0
> >> [   23.924768]        arch_cpu_idle+0xf/0x20
> >> [   23.924858]        default_idle_call+0x23/0x40
> >> [   23.924950]        do_idle+0x177/0x200
> >> [   23.925040]        cpu_startup_entry+0x1d/0x20
> >> [   23.925130]        rest_init+0xc3/0xd0
> >> [   23.925222]        start_kernel+0x43b/0x448
> >> [   23.925312]        x86_64_start_reservations+0x24/0x26
> >> [   23.925403]        x86_64_start_kernel+0x6f/0x72
> >> [   23.925493]        verify_cpu+0x0/0xfb
> >> [   23.925582]
> >> [   23.925582] -> #0 ((timer)){+.-.}:
> >> [   23.925687]        check_prev_add+0x401/0x800
> >> [   23.925782]        __lock_acquire+0x10fc/0x11a0
> >> [   23.925874]        lock_acquire+0xed/0x1e0
> >> [   23.925965]        del_timer_sync+0x47/0xc0
> >> [   23.926055]        inet_csk_reqsk_queue_drop+0xcc/0x1e0
> >> [   23.926146]        inet_csk_complete_hashdance+0x23/0x80
> >> [   23.926237]        tcp_check_req+0x3ec/0x510
> >> [   23.926326]        tcp_v4_rcv+0x8ec/0xc20
> >> [   23.926425]        ip_local_deliver_finish+0xdc/0x380
> >> [   23.926517]        ip_local_deliver+0x66/0x200
> >> [   23.926605]        ip_rcv_finish+0x1b7/0x530
> >> [   23.926688]        ip_rcv+0x26c/0x4c0
> >> [   23.926779]        __netif_receive_skb_core+0x74d/0xcc0
> >> [   23.926874]        __netif_receive_skb+0x18/0x60
> >> [   23.926962]        process_backlog+0x72/0x240
> >> [   23.927045]        net_rx_action+0x1cb/0x3e0
> >> [   23.927125]        __do_softirq+0xd1/0x4a8
> >> [   23.927207]        do_softirq_own_stack+0x2a/0x40
> >> [   23.927288]        do_softirq.part.16+0x46/0x70
> >> [   23.927370]        __local_bh_enable_ip+0x9a/0xa0
> >> [   23.927452]        ip_finish_output2+0x263/0x630
> >> [   23.927534]        ip_finish_output+0x1ba/0x2e0
> >> [   23.927615]        ip_output+0x73/0x240
> >> [   23.927705]        ip_local_out+0x39/0x60
> >> [   23.927795]        ip_queue_xmit+0x1ea/0x5c0
> >> [   23.927887]        tcp_transmit_skb+0x551/0xaa0
> >> [   23.927979]        tcp_send_ack+0xc8/0x130
> >> [   23.928071]        tcp_rcv_state_process+0xe3d/0xe90
> >> [   23.928162]        tcp_v4_do_rcv+0xbd/0x1d0
> >> [   23.928254]        __release_sock+0x6d/0x110
> >> [   23.928346]        release_sock+0x30/0xb0
> >> [   23.928438]        __inet_stream_connect+0x187/0x320
> >> [   23.928531]        inet_stream_connect+0x3b/0x60
> >> [   23.928620]        SYSC_connect+0xbe/0xf0
> >> [   23.928712]        SyS_connect+0xe/0x10
> >> [   23.928799]        entry_SYSCALL_64_fastpath+0x23/0xc2
> >> [   23.928886]
> >> [   23.928886] other info that might help us debug this:
> >> [   23.928886]
> >> [   23.928988]  Possible unsafe locking scenario:
> >> [   23.928988]
> >> [   23.929080]        CPU0                    CPU1
> >> [   23.929166]        ----                    ----
> >> [   23.929252]   lock(slock-AF_INET);
> >> [   23.929342]                                lock((timer));
> >> [   23.929430]                                lock(slock-AF_INET);
> >> [   23.929517]   lock((timer));
> >> [   23.929604]
> >> [   23.929604]  *** DEADLOCK ***
> >> [   23.929604]
> >> [   23.929711] 5 locks held by criu/1679:
> >> [   23.929796]  #0:  (sk_lock-AF_INET){+.+.}, at: [<ffffffff8ea04627>]
> >> inet_stream_connect+0x27/0x60
> >> [   23.929900]  #1:  (rcu_read_lock){....}, at: [<ffffffff8e9c4065>]
> >> ip_queue_xmit+0x5/0x5c0
> >> [   23.930000]  #2:  (rcu_read_lock){....}, at: [<ffffffff8e94e464>]
> >> process_backlog+0xd4/0x240
> >> [   23.930098]  #3:  (rcu_read_lock){....}, at: [<ffffffff8e9bd4ff>]
> >> ip_local_deliver_finish+0x2f/0x380
> >> [   23.930200]  #4:  (slock-AF_INET){+.-.}, at: [<ffffffff8e93131f>]
> >> sk_clone_lock+0x1af/0x580
> >> [   23.930297]
> >> [   23.930297] stack backtrace:
> >> [   23.930396] CPU: 1 PID: 1679 Comm: criu Not tainted 4.14.0-rc4+ #1
> >> [   23.930483] Hardware name: Google Google Compute Engine/Google
> >> Compute Engine, BIOS Google 01/01/2011
> >> [   23.930581] Call Trace:
> >> [   23.930667]  <IRQ>
> >> [   23.930766]  dump_stack+0x85/0xc7
> >> [   23.930855]  print_circular_bug+0x226/0x330
> >> [   23.930943]  ? copy_trace+0xb0/0xb0
> >> [   23.931033]  check_prev_add+0x401/0x800
> >> [   23.931122]  ? tcp_v4_rcv+0x8ec/0xc20
> >> [   23.931212]  __lock_acquire+0x10fc/0x11a0
> >> [   23.931294]  ? __lock_acquire+0x10fc/0x11a0
> >> [   23.931381]  ? copy_trace+0xb0/0xb0
> >> [   23.931468]  ? inet_ehash_insert+0x14f/0x1d0
> >> [   23.931558]  lock_acquire+0xed/0x1e0
> >> [   23.931648]  ? del_timer_sync+0x5/0xc0
> >> [   23.931743]  del_timer_sync+0x47/0xc0
> >> [   23.931829]  ? del_timer_sync+0x5/0xc0
> >> [   23.931917]  inet_csk_reqsk_queue_drop+0xcc/0x1e0
> >> [   23.932005]  inet_csk_complete_hashdance+0x23/0x80
> >> [   23.932095]  tcp_check_req+0x3ec/0x510
> >> [   23.932185]  tcp_v4_rcv+0x8ec/0xc20
> >> [   23.932275]  ip_local_deliver_finish+0xdc/0x380
> >> [   23.932366]  ip_local_deliver+0x66/0x200
> >> [   23.932457]  ? inet_del_offload+0x40/0x40
> >> [   23.932546]  ip_rcv_finish+0x1b7/0x530
> >> [   23.932633]  ip_rcv+0x26c/0x4c0
> >> [   23.932726]  ? ip_local_deliver_finish+0x380/0x380
> >> [   23.932813]  __netif_receive_skb_core+0x74d/0xcc0
> >> [   23.932899]  __netif_receive_skb+0x18/0x60
> >> [   23.932985]  ? __netif_receive_skb+0x18/0x60
> >> [   23.933070]  process_backlog+0x72/0x240
> >> [   23.933157]  net_rx_action+0x1cb/0x3e0
> >> [   23.933244]  ? mark_held_locks+0x72/0xa0
> >> [   23.933333]  __do_softirq+0xd1/0x4a8
> >> [   23.933418]  ? ip_finish_output2+0x23a/0x630
> >> [   23.933503]  do_softirq_own_stack+0x2a/0x40
> >> [   23.933585]  </IRQ>
> >> [   23.933670]  do_softirq.part.16+0x46/0x70
> >> [   23.933757]  __local_bh_enable_ip+0x9a/0xa0
> >> [   23.933839]  ip_finish_output2+0x263/0x630
> >> [   23.933926]  ip_finish_output+0x1ba/0x2e0
> >> [   23.934014]  ? ip_finish_output+0x1ba/0x2e0
> >> [   23.934101]  ip_output+0x73/0x240
> >> [   23.934192]  ? ip_fragment.constprop.54+0x80/0x80
> >> [   23.934284]  ip_local_out+0x39/0x60
> >> [   23.934373]  ip_queue_xmit+0x1ea/0x5c0
> >> [   23.934461]  ? tcp_v4_md5_lookup+0x13/0x20
> >> [   23.934550]  tcp_transmit_skb+0x551/0xaa0
> >> [   23.934639]  tcp_send_ack+0xc8/0x130
> >> [   23.934735]  tcp_rcv_state_process+0xe3d/0xe90
> >> [   23.934826]  ? __local_bh_enable_ip+0x70/0xa0
> >> [   23.934911]  tcp_v4_do_rcv+0xbd/0x1d0
> >> [   23.935000]  ? tcp_v4_do_rcv+0xbd/0x1d0
> >> [   23.935089]  __release_sock+0x6d/0x110
> >> [   23.935200]  release_sock+0x30/0xb0
> >> [   23.935288]  __inet_stream_connect+0x187/0x320
> >> [   23.935377]  ? do_wait_intr_irq+0xc0/0xc0
> >> [   23.935464]  inet_stream_connect+0x3b/0x60
> >> [   23.935557]  SYSC_connect+0xbe/0xf0
> >> [   23.935642]  ? sock_alloc_file+0x97/0x110
> >> [   23.935733]  ? trace_hardirqs_on_caller+0x11f/0x190
> >> [   23.935821]  ? trace_hardirqs_on_thunk+0x1a/0x1c
> >> [   23.935911]  SyS_connect+0xe/0x10
> >> [   23.935999]  entry_SYSCALL_64_fastpath+0x23/0xc2
> >> [   23.936086] RIP: 0033:0x7fb80b838720
> >> [   23.936170] RSP: 002b:00007ffc277dac88 EFLAGS: 00000246 ORIG_RAX:
> >> 000000000000002a
> >> [   23.936266] RAX: ffffffffffffffda RBX: 00007ffc277dac18 RCX: 00007fb80b838720
> >> [   23.936353] RDX: 0000000000000010 RSI: 00007ffc277daca0 RDI: 0000000000000005
> >> [   23.936442] RBP: 00007ffc277dabf0 R08: 00007ffc277dac43 R09: 0000000000000004
> >> [   23.936528] R10: 00007ffc277daa50 R11: 0000000000000246 R12: 00007fb80bc52bc0
> >> [   23.936613] R13: 0000000000000001 R14: 0000000000000000 R15: 00007fb80bc6b1c8
> >> 
> >> Here are all logs https://travis-ci.org/avagin/linux/jobs/290283691
> >
> >
> >Hi Andrey
> >
> >Kees posted a patch for this issue, thanks for the report.
> >
> >https://patchwork.ozlabs.org/patch/828333/
> 
> I'm still getting the warning on current net-next kernel. Looks like the
> fix never went in :/

For some reason, it is not in David Miller tree, but fix will be there
eventually via another tree.

https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=timers/core&id=52f737c2da40259ac9962170ce608b6fb1b55ee4

Yes, it is a real pain, because it means LOCKDEP is not useful for us
developers until this bug is fully resolved in David Miller tree.

I wish Kees would not send more timer patches, because I fail to see how
we can fully test them.
