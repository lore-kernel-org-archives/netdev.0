From: Johannes Stezenbach <js@sig21.net>
Subject: 4.7.0: RCU stall in nf_conntrack
Date: Tue, 9 Aug 2016 19:33:26 +0200
Message-ID: <20160809173326.l2gw45dam6bp2k6u@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I just experienced network hangup with 4.7.0, it happened shortly
after resume from hibernate:

[201988.443552] INFO: rcu_preempt detected stalls on CPUs/tasks:
[201988.443556]         Tasks blocked on level-0 rcu_node (CPUs 0-3): P14563
[201988.443557]         (detected by 3, t=18002 jiffies, g=7365154, c=7365153, q=15274)
[201988.443560] client_socket_t R  running task        0 14563      1 0x00000000
[201988.443563]  ffff8800c427a900 00000000e1b77832 ffff880217603da0 ffffffff810bf66a
[201988.443565]  ffffffff810bf5d1 ffff8800c427a900 ffffffff81e566c0 ffff880217603dd0
[201988.443567]  ffffffff8119a3cf ffff8802177d80c0 ffffffff81e566c0 ffffffff81f89ae0
[201988.443569] Call Trace:
[201988.443571]  <IRQ>  [<ffffffff810bf66a>] sched_show_task+0xfa/0x160
[201988.443585]  [<ffffffff810bf5d1>] ? sched_show_task+0x61/0x160
[201988.443587]  [<ffffffff8119a3cf>] rcu_print_detail_task_stall_rnp+0x52/0x76
[201988.443590]  [<ffffffff81103176>] rcu_check_callbacks+0x866/0x9e0
[201988.443592]  [<ffffffff81108e79>] update_process_times+0x39/0x60
[201988.443594]  [<ffffffff8111a831>] tick_sched_handle.isra.5+0x21/0x60
[201988.443596]  [<ffffffff8111a8b2>] tick_sched_timer+0x42/0x70
[201988.443598]  [<ffffffff81109860>] __hrtimer_run_queues+0x140/0x3c0
[201988.443599]  [<ffffffff8111a870>] ? tick_sched_handle.isra.5+0x60/0x60
[201988.443601]  [<ffffffff8110a233>] hrtimer_interrupt+0xb3/0x1c0
[201988.443603]  [<ffffffff8103b896>] local_apic_timer_interrupt+0x36/0x60
[201988.443606]  [<ffffffff819ad06d>] smp_apic_timer_interrupt+0x3d/0x50
[201988.443607]  [<ffffffff819ab53c>] apic_timer_interrupt+0x8c/0xa0
[201988.443608]  <EOI>  [<ffffffff8183b425>] ? __nf_conntrack_find_get+0x285/0x420
[201988.443611]  [<ffffffff8183d291>] ? nf_conntrack_in+0x1d1/0x8d0
[201988.443612]  [<ffffffff8183d291>] nf_conntrack_in+0x1d1/0x8d0
[201988.443615]  [<ffffffff818fb835>] ipv4_conntrack_local+0x45/0x50
[201988.443616]  [<ffffffff818350b2>] nf_iterate+0x62/0x80
[201988.443618]  [<ffffffff81835170>] nf_hook_slow+0xa0/0x110
[201988.443620]  [<ffffffff818350d5>] ? nf_hook_slow+0x5/0x110
[201988.443622]  [<ffffffff818aa408>] __ip_local_out+0xd8/0x120
[201988.443624]  [<ffffffff818a8240>] ? ip_forward_options+0x1f0/0x1f0
[201988.443625]  [<ffffffff818aa46c>] ip_local_out+0x1c/0x70
[201988.443627]  [<ffffffff818aa84f>] ip_queue_xmit+0x18f/0x450
[201988.443628]  [<ffffffff818aa6c5>] ? ip_queue_xmit+0x5/0x450
[201988.443630]  [<ffffffff818c307b>] tcp_transmit_skb+0x48b/0x8e0
[201988.443632]  [<ffffffff818c4dd9>] tcp_connect+0x629/0x830
[201988.443634]  [<ffffffff817f56ff>] ? secure_tcp_sequence_number+0x7f/0xe0
[201988.443636]  [<ffffffff818c7f49>] tcp_v4_connect+0x2b9/0x460
[201988.443638]  [<ffffffff818e2012>] __inet_stream_connect+0xb2/0x310
[201988.443640]  [<ffffffff810b9051>] ? preempt_count_sub+0xa1/0x100
[201988.443642]  [<ffffffff817e5061>] ? lock_sock_nested+0x31/0x90
[201988.443644]  [<ffffffff8109583f>] ? __local_bh_enable_ip+0x6f/0xd0
[201988.443646]  [<ffffffff818e22a8>] inet_stream_connect+0x38/0x50
[201988.443647]  [<ffffffff817e241b>] SyS_connect+0x7b/0xf0
[201988.443649]  [<ffffffff817df485>] ? sock_alloc_file+0xa5/0x140
[201988.443651]  [<ffffffff8100111a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[201988.443652]  [<ffffffff819aa8bc>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[201988.443654] client_socket_t R  running task        0 14563      1 0x00000000
[201988.443656]  ffff8800c427a900 00000000e1b77832 ffff880217603da0 ffffffff810bf66a
[201988.443658]  ffffffff810bf5d1 ffff8800c427a900 ffffffff81e566c0 ffff880217603dd0
[201988.443660]  ffffffff8119a3cf ffff8802177d80c0 ffffffff81e566c0 ffffffff81f89ae0
[201988.443662] Call Trace:
[201988.443663]  <IRQ>  [<ffffffff810bf66a>] sched_show_task+0xfa/0x160
[201988.443665]  [<ffffffff810bf5d1>] ? sched_show_task+0x61/0x160
[201988.443666]  [<ffffffff8119a3cf>] rcu_print_detail_task_stall_rnp+0x52/0x76
[201988.443668]  [<ffffffff811031af>] rcu_check_callbacks+0x89f/0x9e0
[201988.443669]  [<ffffffff81108e79>] update_process_times+0x39/0x60
[201988.443671]  [<ffffffff8111a831>] tick_sched_handle.isra.5+0x21/0x60
[201988.443672]  [<ffffffff8111a8b2>] tick_sched_timer+0x42/0x70
[201988.443674]  [<ffffffff81109860>] __hrtimer_run_queues+0x140/0x3c0
[201988.443675]  [<ffffffff8111a870>] ? tick_sched_handle.isra.5+0x60/0x60
[201988.443677]  [<ffffffff8110a233>] hrtimer_interrupt+0xb3/0x1c0
[201988.443679]  [<ffffffff8103b896>] local_apic_timer_interrupt+0x36/0x60
[201988.443680]  [<ffffffff819ad06d>] smp_apic_timer_interrupt+0x3d/0x50
[201988.443682]  [<ffffffff819ab53c>] apic_timer_interrupt+0x8c/0xa0
[201988.443682]  <EOI>  [<ffffffff8183b425>] ? __nf_conntrack_find_get+0x285/0x420
[201988.443685]  [<ffffffff8183d291>] ? nf_conntrack_in+0x1d1/0x8d0
[201988.443686]  [<ffffffff8183d291>] nf_conntrack_in+0x1d1/0x8d0
[201988.443688]  [<ffffffff818fb835>] ipv4_conntrack_local+0x45/0x50
[201988.443689]  [<ffffffff818350b2>] nf_iterate+0x62/0x80
[201988.443691]  [<ffffffff81835170>] nf_hook_slow+0xa0/0x110
[201988.443692]  [<ffffffff818350d5>] ? nf_hook_slow+0x5/0x110
[201988.443694]  [<ffffffff818aa408>] __ip_local_out+0xd8/0x120
[201988.443696]  [<ffffffff818a8240>] ? ip_forward_options+0x1f0/0x1f0
[201988.443697]  [<ffffffff818aa46c>] ip_local_out+0x1c/0x70
[201988.443699]  [<ffffffff818aa84f>] ip_queue_xmit+0x18f/0x450
[201988.443700]  [<ffffffff818aa6c5>] ? ip_queue_xmit+0x5/0x450
[201988.443702]  [<ffffffff818c307b>] tcp_transmit_skb+0x48b/0x8e0
[201988.443703]  [<ffffffff818c4dd9>] tcp_connect+0x629/0x830
[201988.443705]  [<ffffffff817f56ff>] ? secure_tcp_sequence_number+0x7f/0xe0
[201988.443706]  [<ffffffff818c7f49>] tcp_v4_connect+0x2b9/0x460
[201988.443708]  [<ffffffff818e2012>] __inet_stream_connect+0xb2/0x310
[201988.443710]  [<ffffffff810b9051>] ? preempt_count_sub+0xa1/0x100
[201988.443711]  [<ffffffff817e5061>] ? lock_sock_nested+0x31/0x90
[201988.443713]  [<ffffffff8109583f>] ? __local_bh_enable_ip+0x6f/0xd0
[201988.443715]  [<ffffffff818e22a8>] inet_stream_connect+0x38/0x50
[201988.443716]  [<ffffffff817e241b>] SyS_connect+0x7b/0xf0
[201988.443718]  [<ffffffff817df485>] ? sock_alloc_file+0xa5/0x140
[201988.443719]  [<ffffffff8100111a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[201988.443720]  [<ffffffff819aa8bc>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[202168.442569] INFO: rcu_preempt detected stalls on CPUs/tasks:
[202168.442572]         Tasks blocked on level-0 rcu_node (CPUs 0-3): P14563
[202168.442574]         (detected by 3, t=72007 jiffies, g=7365154, c=7365153, q=34376)
[202168.442577] client_socket_t R  running task        0 14563      1 0x00000000
[202168.442579]  ffff8800c427a900 00000000e1b77832 ffff880217603da0 ffffffff810bf66a
[202168.442581]  ffffffff810bf5d1 ffff8800c427a900 ffffffff81e566c0 ffff880217603dd0
[202168.442583]  ffffffff8119a3cf ffff8802177d80c0 ffffffff81e566c0 ffffffff81f89ae0
[202168.442586] Call Trace:
[202168.442587]  <IRQ>  [<ffffffff810bf66a>] sched_show_task+0xfa/0x160
[202168.442604]  [<ffffffff810bf5d1>] ? sched_show_task+0x61/0x160
[202168.442606]  [<ffffffff8119a3cf>] rcu_print_detail_task_stall_rnp+0x52/0x76
[202168.442609]  [<ffffffff81103176>] rcu_check_callbacks+0x866/0x9e0
[202168.442611]  [<ffffffff81108e79>] update_process_times+0x39/0x60
[202168.442613]  [<ffffffff8111a831>] tick_sched_handle.isra.5+0x21/0x60
[202168.442615]  [<ffffffff8111a8b2>] tick_sched_timer+0x42/0x70
[202168.442617]  [<ffffffff81109860>] __hrtimer_run_queues+0x140/0x3c0
[202168.442618]  [<ffffffff8111a870>] ? tick_sched_handle.isra.5+0x60/0x60
[202168.442620]  [<ffffffff8110a233>] hrtimer_interrupt+0xb3/0x1c0
[202168.442622]  [<ffffffff8103b896>] local_apic_timer_interrupt+0x36/0x60
[202168.442625]  [<ffffffff819ad06d>] smp_apic_timer_interrupt+0x3d/0x50
[202168.442626]  [<ffffffff819ab53c>] apic_timer_interrupt+0x8c/0xa0
[202168.442627]  <EOI>  [<ffffffff8183b425>] ? __nf_conntrack_find_get+0x285/0x420
[202168.442630]  [<ffffffff8183d291>] ? nf_conntrack_in+0x1d1/0x8d0
[202168.442631]  [<ffffffff8183d291>] nf_conntrack_in+0x1d1/0x8d0
[202168.442633]  [<ffffffff818fb835>] ipv4_conntrack_local+0x45/0x50
[202168.442635]  [<ffffffff818350b2>] nf_iterate+0x62/0x80
[202168.442637]  [<ffffffff81835170>] nf_hook_slow+0xa0/0x110
[202168.442639]  [<ffffffff818350d5>] ? nf_hook_slow+0x5/0x110
[202168.442641]  [<ffffffff818aa408>] __ip_local_out+0xd8/0x120
[202168.442643]  [<ffffffff818a8240>] ? ip_forward_options+0x1f0/0x1f0
[202168.442644]  [<ffffffff818aa46c>] ip_local_out+0x1c/0x70
[202168.442646]  [<ffffffff818aa84f>] ip_queue_xmit+0x18f/0x450
[202168.442647]  [<ffffffff818aa6c5>] ? ip_queue_xmit+0x5/0x450
[202168.442649]  [<ffffffff818c307b>] tcp_transmit_skb+0x48b/0x8e0
[202168.442651]  [<ffffffff818c4dd9>] tcp_connect+0x629/0x830
[202168.442653]  [<ffffffff817f56ff>] ? secure_tcp_sequence_number+0x7f/0xe0
[202168.442655]  [<ffffffff818c7f49>] tcp_v4_connect+0x2b9/0x460
[202168.442657]  [<ffffffff818e2012>] __inet_stream_connect+0xb2/0x310
[202168.442659]  [<ffffffff810b9051>] ? preempt_count_sub+0xa1/0x100
[202168.442661]  [<ffffffff817e5061>] ? lock_sock_nested+0x31/0x90
[202168.442663]  [<ffffffff8109583f>] ? __local_bh_enable_ip+0x6f/0xd0
[202168.442665]  [<ffffffff818e22a8>] inet_stream_connect+0x38/0x50
[202168.442666]  [<ffffffff817e241b>] SyS_connect+0x7b/0xf0
[202168.442668]  [<ffffffff817df485>] ? sock_alloc_file+0xa5/0x140
[202168.442670]  [<ffffffff8100111a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[202168.442671]  [<ffffffff819aa8bc>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[202168.442673] client_socket_t R  running task        0 14563      1 0x00000000
[202168.442674]  ffff8800c427a900 00000000e1b77832 ffff880217603da0 ffffffff810bf66a
[202168.442677]  ffffffff810bf5d1 ffff8800c427a900 ffffffff81e566c0 ffff880217603dd0
[202168.442678]  ffffffff8119a3cf ffff8802177d80c0 ffffffff81e566c0 ffffffff81f89ae0
[202168.442680] Call Trace:
[202168.442681]  <IRQ>  [<ffffffff810bf66a>] sched_show_task+0xfa/0x160
[202168.442683]  [<ffffffff810bf5d1>] ? sched_show_task+0x61/0x160
[202168.442685]  [<ffffffff8119a3cf>] rcu_print_detail_task_stall_rnp+0x52/0x76
[202168.442686]  [<ffffffff811031af>] rcu_check_callbacks+0x89f/0x9e0
[202168.442688]  [<ffffffff81108e79>] update_process_times+0x39/0x60
[202168.442690]  [<ffffffff8111a831>] tick_sched_handle.isra.5+0x21/0x60
[202168.442691]  [<ffffffff8111a8b2>] tick_sched_timer+0x42/0x70
[202168.442692]  [<ffffffff81109860>] __hrtimer_run_queues+0x140/0x3c0
[202168.442694]  [<ffffffff8111a870>] ? tick_sched_handle.isra.5+0x60/0x60
[202168.442695]  [<ffffffff8110a233>] hrtimer_interrupt+0xb3/0x1c0
[202168.442697]  [<ffffffff8103b896>] local_apic_timer_interrupt+0x36/0x60
[202168.442699]  [<ffffffff819ad06d>] smp_apic_timer_interrupt+0x3d/0x50
[202168.442700]  [<ffffffff819ab53c>] apic_timer_interrupt+0x8c/0xa0
[202168.442701]  <EOI>  [<ffffffff8183b425>] ? __nf_conntrack_find_get+0x285/0x420
[202168.442703]  [<ffffffff8183d291>] ? nf_conntrack_in+0x1d1/0x8d0
[202168.442704]  [<ffffffff8183d291>] nf_conntrack_in+0x1d1/0x8d0
[202168.442706]  [<ffffffff818fb835>] ipv4_conntrack_local+0x45/0x50
[202168.442708]  [<ffffffff818350b2>] nf_iterate+0x62/0x80
[202168.442709]  [<ffffffff81835170>] nf_hook_slow+0xa0/0x110
[202168.442711]  [<ffffffff818350d5>] ? nf_hook_slow+0x5/0x110
[202168.442712]  [<ffffffff818aa408>] __ip_local_out+0xd8/0x120
[202168.442714]  [<ffffffff818a8240>] ? ip_forward_options+0x1f0/0x1f0
[202168.442715]  [<ffffffff818aa46c>] ip_local_out+0x1c/0x70
[202168.442717]  [<ffffffff818aa84f>] ip_queue_xmit+0x18f/0x450
[202168.442718]  [<ffffffff818aa6c5>] ? ip_queue_xmit+0x5/0x450
[202168.442720]  [<ffffffff818c307b>] tcp_transmit_skb+0x48b/0x8e0
[202168.442721]  [<ffffffff818c4dd9>] tcp_connect+0x629/0x830
[202168.442723]  [<ffffffff817f56ff>] ? secure_tcp_sequence_number+0x7f/0xe0
[202168.442725]  [<ffffffff818c7f49>] tcp_v4_connect+0x2b9/0x460
[202168.442726]  [<ffffffff818e2012>] __inet_stream_connect+0xb2/0x310
[202168.442728]  [<ffffffff810b9051>] ? preempt_count_sub+0xa1/0x100
[202168.442730]  [<ffffffff817e5061>] ? lock_sock_nested+0x31/0x90
[202168.442731]  [<ffffffff8109583f>] ? __local_bh_enable_ip+0x6f/0xd0
[202168.442733]  [<ffffffff818e22a8>] inet_stream_connect+0x38/0x50
[202168.442734]  [<ffffffff817e241b>] SyS_connect+0x7b/0xf0
[202168.442736]  [<ffffffff817df485>] ? sock_alloc_file+0xa5/0x140
[202168.442737]  [<ffffffff8100111a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[202168.442739]  [<ffffffff819aa8bc>] entry_SYSCALL_64_fastpath+0x1f/0xbd


Johannes
