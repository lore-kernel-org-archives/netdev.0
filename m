From: Bradley Peterson <despite@gmail.com>
Subject: list_debug WARNINGs followed by BUG in inetpeer.c
Date: Tue, 29 Nov 2011 10:35:20 -0600
Message-ID: <CAJuWrdt0+N+pU7uTNLRqD-q_haOCUa2rGeY_-L4Q3ueNLJ9aBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:46111 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545Ab1K2QfV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 11:35:21 -0500
Received: by vbbfc26 with SMTP id fc26so4908658vbb.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 08:35:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have been seeing an issue where servers will report a series of
list_debug WARNINGs, usually lasting about 10 minutes, followed by a
BUG in inetpeer.c and a kernel panic. =A0This is across a variety of
hardware. =A0The kernels are 2.6.38.8 modified with some fixes in the
pptp, gre, and l2tp modules. =A0The server load is mostly bulk network
traffic, but they also act as VPN endpoints.

Here is an example.  In this case, it looks like the initial WARNING
was for a GRE packet, but that is not always the case.  I can provide
other examples, if needed.

The first two list_debug warnings:
[1029266.080589] ------------[ cut here ]------------
[1029266.085408] WARNING: at lib/list_debug.c:56 __list_del_entry+0x8d/=
0x98()
[1029266.092302] Hardware name: HDAMA
[1029266.095726]9266.277510] =A0[<ffffffff8141111d>] ip_defrag+0xce/0x9=
be
[1029266.282840] =A0[<ffffffffa026a9df>] ? pptp_rcv+0xaf/0xc3 [pptp]
[1029266.288775] =A0[<ffffffffa02640a3>] ? gre_rcv+0x62/0x75 [gre]
[1029266.294538] =A0[<ffffffff814498f5>] ipv4_conntrack_defrag+0xf6/0x1=
25
[1029266.300907] =A0[<ffffffff81400e80>] nf_iterate+0x48/0x83
[1029266.306237] =A0[<ffffffff8141029f>] ? ip_rcv_finish+0x0/0x33e
[1029266.311999] =A0[<ffffffff81400f25>] nf_hook_slow+0x6a/0xe9
[1029266.317525] =A0[<ffffffff8141029f>] ? ip_rcv_finish+0x0/0x33e
[1029266.323279] =A0[<ffffffff8141029f>] ? ip_rcv_finish+0x0/0x33e
[1029266.329041] =A0[<ffffffff8141083b>] NF_HOOK.clone.7+0x46/0x58
[1029266.334795] =A0[<ffffffff81410bb5>] ip_rcv+0x21b/0x246
[1029266.339944] =A0[<ffffffff813dd584>] __netif_receive_skb+0x426/0x45=
c
[1029266.346224] =A0[<ffffffff813e002e>] ? dev_hard_start_xmit+0x3dc/0x=
4d8
[1029266.352688] =A0[<ffffffff813dd641>] process_backlog+0x87/0x15d
[1029266.358530] =A0[<ffffffff813de528>] net_rx_action+0xac/0x1b1
[1029266.364214] =A0[<ffffffff8105efaa>] __do_softirq+0xd2/0x19e
[1029266.369795] =A0[<ffffffff81078a95>] ? sched_clock_tick+0x70/0x75
[1029266.375818] =A0[<ffffffff8100bb5c>] call_softirq+0x1c/0x30
[1029266.381319] =A0[<ffffffff8100d287>] do_softirq+0x46/0x83
[1029266.386646] =A0[<ffffffff8105f132>] irq_exit+0x49/0x8b
[1029266.391796] =A0[<ffffffff81022b66>]
smp_call_function_single_interrupt+0x25/0x27
[1029266.399204] =A0[<ffffffff8100b7b3>] call_function_single_interrupt=
+0x13/0x20
[1029266.406264] =A0<EOI>
[1029266.408378] ---[ end trace 44734be3fa460007 ]---
[1029266.413380] ------------[ cut here ]------------
[1029266.418196] WARNING: at lib/list_debug.c:30 __list_add+0x68/0x80()
[1029266.424554] Hardware name: HDAMA
[1029266.427967] list_add corruption. prev->next should be next
(ffffffff81a7be60), but was ffff8801735f8428. (prev=3Dffff8801735f8428)=
=2E
[1029266.439800] Modules linked in: authenc esp4 xfrm4_mode_transport
arc4 ppp_mppe tcp_diag inet_diag xt_NOTRACK iptable_raw pptp gre
l2tp_ppp pppox ppp_generic slhc l2tp_netlin
k l2tp_core tunrcv+0x21b/0x246
[1029266.638169] =A0[<ffffffff813dd584>] __netif_receive_skb+0x426/0x45=
c
[1029266.644440] =A0[<ffffffff81085756>] ? __smp_call_function_single+0=
xa9/0xb2
[1029266.651321] =A0[<ffffffff813dd641>] process_backlog+0x87/0x15d
[1029266.657161] =A0[<ffffffff8100b7b3>] ?
call_function_single_interrupt+0x13/0x20
[1029266.664388] =A0[<ffffffff813de528>] net_rx_action+0xac/0x1b1
[1029266.670064] =A0[<ffffffff8105efaa>] __do_softirq+0xd2/0x19e
[1029266.675644] =A0[<ffffffff810245cf>] ? ack_APIC_irq+0x15/0x17
[1029266.681309] =A0[<ffffffff8100bb5c>] call_softirq+0x1c/0x30
[1029266.686804] =A0[<ffffffff8100d287>] do_softirq+0x46/0x83
[1029266.692132] =A0[<ffffffff8105f132>] irq_exit+0x49/0x8b
[1029266.697283] =A0[<ffffffff8148ff5e>] do_IRQ+0x8e/0xa5
[1029266.702256] =A0[<ffffffff81489d93>] ret_from_intr+0x0/0x15
[1029266.707778] =A0<EOI> =A0[<ffffffff810b8394>] ? rcu_needs_cpu+0x10e=
/0x1bf
[1029266.714413] =A0[<ffffffff8102c61d>] ? native_safe_halt+0xb/0xd
[1029266.720270] =A0[<ffffffff81011fac>] ? need_resched+0x23/0x2d
[1029266.725937] =A0[<ffffffff810120fa>] default_idle+0x4e/0x86
[1029266.731430] =A0[<ffffffff8100932a>] cpu_idle+0xaa/0xcc
[1029266.736577] =A0[<ffffffff81471cce>] rest_init+0x72/0x74
[1029266.741821] =A0[<ffffffff81b58c44>] start_kernel+0x3f3/0x3fe
[1029266.747487] =A0[<ffffffff81b582cb>] x86_64_start_reservations+0xb6=
/0xba
[1029266.754106] =A0[<ffffffff81b583d5>] x86_64_start_kernel+0x106/0x11=
5
[1029266.760388] ---[ end trace 44734be3fa460008 ]---

These continue with different traces, and different list functions,
until a BUG in inetpeer.c causes a panic:

[1029996.182197] ------------[ cut here ]------------
[1029996.187042] kernel BUG at net/ipv4/inetpeer.c:386!
[1029996.19200, threadinfo ffffffff81a00000, task ffffffff81a0b020)
[1029996.378121] Stack:
[1029996.380314]  ffff880172da9010 ffffffff81a7be98 ffff8800efc03cb0
000000013d5fe800
[1029996.387982]  00000000000927c0 ffff8800efc03ce0 ffff8800efc03ea0
ffffffff81a01fd8
[1029996.395644]  ffff8800efc03e40 ffffffff8140ff27 ffffffff81a7be90
0000000000000086
[1029996.403312] Call Trace:
[1029996.405946]  <IRQ>
[1029996.408253]  [<ffffffff8140ff27>] peer_check_expire+0x88/0x110
[1029996.414267]  [<ffffffff813de8e1>] ? __napi_schedule+0x48/0x4f
[1029996.420195]  [<ffffffff8123d047>] ? radix_tree_lookup+0xb/0xd
[1029996.426120]  [<ffffffff812e6be5>] ? add_interrupt_randomness+0x29/=
0x2e
[1029996.432830]  [<ffffffff810245b8>] ? apic_write+0x16/0x18
[1029996.438322]  [<ffffffff810245cf>] ? ack_APIC_irq+0x15/0x17
[1029996.443988]  [<ffffffff81025fb7>] ? ack_apic_level+0x61/0xf7
[1029996.449829]  [<ffffffff810b5951>] ? handle_fasteoi_irq+0xc9/0xd9
[1029996.456021]  [<ffffffff8106521c>] ? internal_add_timer+0xcf/0xd1
[1029996.462202]  [<ffffffff810652e5>] ? cascade+0x65/0x7f
[1029996.467436]  [<ffffffff810654c8>] run_timer_softirq+0x1c9/0x294
[1029996.473536]  [<ffffffff81489d93>] ? ret_from_intr+0x0/0x15
[1029996.479207]  [<ffffffff8140fe9f>] ? peer_check_expire+0x0/0x110
[1029996.485307]  [<ffffffff8105efaa>] __do_softirq+0xd2/0x19e
[1029996.490887]  [<ffffffff8107ff34>] ? tick_program_event+0x1f/0x21
[1029996.497072]  [<ffffffff8100bb5c>] call_softirq+0x1c/0x30
[1029996.502563]  [<ffffffff8100d287>] do_softirq+0x46/0x83
[1029996.507885]  [<ffffffff8105f132>] irq_exit+0x49/0x8b
[1029996.513043]  [<ffffffff8148fff3>] smp_apic_timer_interrupt+0x7e/0x=
8c
[1029996.519575]  [<ffffffff8100b613>] apic_timer_interrupt+0x13/0x20
[1029996.525758]  <EOI>
[1029996.528065]  [<ffffffff810b8394>] ? rcu_needs_cpu+0x10e/0x1bf
[1029996.533993]  [<ffffffff8102c61d>] ? native_safe_halt+0xb/0xd
[1029996.539834]  [<ffffffff81011fac>] ? need_resched+0x23/0x2d
[1029996.545498]  [<ffffffff810120fa>] default_idle+0x4e/0x86
[1029996.550994]  [<ffffffff8100932a>] cpu_idle+0xaa/0xcc
[1029996.556140]  [<ffffffff81471cce>] rest_init+0x72/0x74
[1029996.561377]  [<ffffffff81b58c44>] start_kernel+0x3f3/0x3fe
[1029996.567042]  [<ffffffff81b582cb>] x86_64_start_reservations+0xb6/0=
xba
[1029996.573663]  [<ffffffff81b583d5>] x86_64_start_kernel+0x106/0x115
[1029996.579935] Code: fd ff ff 85 c0 74 1f 49 8d 54 24 08 ff c0 49 0f
44 d4 49 89 55 00 4c 8b 22 49 83 c5 08 49 81 fc 70 dc 66 81 75 cf 49
39 dc 74 02 <0f> 0b 48 81 3b 70 dc 66
81 49 8d 75 f8 75 0d 49 8b 45 f8 48 8b
[1029996.600244] RIP  [<ffffffff8140fdca>] cleanup_once+0x117/0x1ec
[1029996.606284]  RSP <ffff8800efc03c90>
[1029996.610416] ---[ end trace 44734be3fa46001d ]---
[1029996.615210] Kernel panic - not syncing: Fatal exception in interru=
pt
[1029996.621746] Pid: 0, comm: swapper Tainted: G      D W
2.6.38.8-32.3.fix.fc14.x86_64 #1
[1029996.630013] Call Trace:
[1029996.632644]  <IRQ>  [<ffffffff81487898>] panic+0x91/0x1a4
[1029996.638251]  [<ffffffff8148ab64>] oops_end+0xb7/0xc7
[1029996.643401]  [<ffffffff8100e5f0>] die+0x5a/0x66
[1029996.648114]  [<ffffffff8148a448>] do_trap+0x121/0x130
[1029996.653347]  [<ffffffff8100bfed>] do_invalid_op+0x98/0xa1
[1029996.658927]  [<ffffffff8140fdca>] ? cleanup_once+0x117/0x1ec
[1029996.664768]  [<ffffffff81487a13>] ? printk+0x68/0x6d
[1029996.669914]  [<ffffffff8100e576>] ? show_trace+0x15/0x17
[1029996.675409]  [<ffffffff81b583d5>] ? x86_64_start_kernel+0x106/0x11=
5
[1029996.681859]  [<ffffffff8100b8db>] invalid_op+0x1b/0x20
[1029996.687176]  [<ffffffff81410634>] ? ip_local_deliver_finish+0x0/0x=
1c1
[1029996.693798]  [<ffffffff8140fdca>] ? cleanup_once+0x117/0x1ec
[1029996.699636]  [<ffffffff8140ff27>] peer_check_expire+0x88/0x110
[1029996.705671]  [<ffffffff813de8e1>] ? __napi_schedule+0x48/0x4f
[1029996.711594]  [<ffffffff8123d047>] ? radix_tree_lookup+0xb/0xd
[1029996.717520]  [<ffffffff812e6be5>] ? add_interrupt_randomness+0x29/=
0x2e
[1029996.724230]  [<ffffffff810245b8>] ? apic_write+0x16/0x18
[1029996.729720]  [<ffffffff810245cf>] ? ack_APIC_irq+0x15/0x17
[1029996.735388]  [<ffffffff81025fb7>] ? ack_apic_level+0x61/0xf7
[1029996.741228]  [<ffffffff810b5951>] ? handle_fasteoi_irq+0xc9/0xd9
[1029996.747417]  [<ffffffff8106521c>] ? internal_add_timer+0xcf/0xd1
[1029996.753603]  [<ffffffff810652e5>] ? cascade+0x65/0x7f
[1029996.758837]  [<ffffffff810654c8>] run_timer_softirq+0x1c9/0x294
[1029996.764937]  [<ffffffff81489d93>] ? ret_from_intr+0x0/0x15
[1029996.770604]  [<ffffffff8140fe9f>] ? peer_check_expire+0x0/0x110
[1029996.776707]  [<ffffffff8105efaa>] __do_softirq+0xd2/0x19e
[1029996.782285]  [<ffffffff8107ff34>] ? tick_program_event+0x1f/0x21
[1029996.788478]  [<ffffffff8100bb5c>] call_softirq+0x1c/0x30
[1029996.793974]  [<ffffffff8100d287>] do_softirq+0x46/0x83
[1029996.799294]  [<ffffffff8105f132>] irq_exit+0x49/0x8b
[1029996.804442]  [<ffffffff8148fff3>] smp_apic_timer_interrupt+0x7e/0x=
8c
[1029996.810976]  [<ffffffff8100b613>] apic_timer_interrupt+0x13/0x20
[1029996.817159]  <EOI>  [<ffffffff810b8394>] ? rcu_needs_cpu+0x10e/0x1=
bf
[1029996.823721]  [<ffffffff8102c61d>] ? native_safe_halt+0xb/0xd
[1029996.829560]  [<ffffffff81011fac>] ? need_resched+0x23/0x2d
[1029996.835228]  [<ffffffff810120fa>] default_idle+0x4e/0x86
[1029996.840721]  [<ffffffff8100932a>] cpu_idle+0xaa/0xcc
[1029996.845868]  [<ffffffff81471cce>] rest_init+0x72/0x74
[1029996.851102]  [<ffffffff81b58c44>] start_kernel+0x3f3/0x3fe
[1029996.856771]  [<ffffffff81b582cb>] x86_64_start_reservations+0xb6/0=
xba
[1029996.863390]  [<ffffffff81b583d5>] x86_64_start_kernel+0x106/0x115

Any ideas how to troubleshoot this?

Thanks,
Bradley Peterson
