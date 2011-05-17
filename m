From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: WARNING, net/core/dev.c, =?UTF-8?Q?skb=5Fgso=5Fsegment=2C=20=32?=  =?UTF-8?Q?=2E=36=2E=33=39-rc=37-git=31=31=20inclusive?=
Date: Tue, 17 May 2011 15:52:33 +0300
Message-ID: <75df1ebd245faa29f6d9c067bad94e8e@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:45288 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754129Ab1EQMwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 08:52:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi

 Just tried some non-standard pedit rules to modify tcp data, and got 
 WARNING almost instantly.
 Maybe it is just invalid pedit, but probably will be interesting. My 
 idea was to modify outgoing tcp window size,
 rules was not complete by mistake, but got that warning.

 Rules
 tc qdisc del dev eth1 root
 tc qdisc add dev eth1 root handle 1: htb default 1
 tc class add dev eth1 parent 1: classid 1:1 htb rate 900Mbit ceil 
 900Mbit burst 10000 cburst 10000 quantum 60000
 tc qdisc add dev eth1 parent 1:1 handle 11 pfifo limit 10000

 tc filter add dev eth1 prio 1 protocol ip parent 1: \
   u32 match ip protocol 0x06 0xff match ip dport 80 0x2000 flowid 1:1 \
   match u16 0x0000 0xffff at 34 action gact ok

 tc filter add dev eth1 prio 1 protocol ip parent 1: \
   u32 match ip protocol 0x06 0xff match ip dport 80 0x2000 flowid 1:1 \
     action pedit munge offset 34 u16 set 0x2000 \
       pipe csum ip and tcp

 Warning:


  2298.298075] GACT probability on
 [ 2298.369166] ------------[ cut here ]------------
 [ 2298.369175] WARNING: at net/core/dev.c:1876 
 skb_gso_segment+0x156/0x2b8()
 [ 2298.369178] Hardware name: RS700-E6/ERS4
 [ 2298.369181] igb: caps=(0x21143b3, 0x0) len=11636 data_len=0 
 ip_summed=0
 [ 2298.369184] Modules linked in: act_gact act_csum act_pedit cls_u32 
 sch_htb ipv6 i2c_i801 i7core_edac i2c_core edac_core rtc_cmos igb e1000e 
 rtc_core rtc_lib iTCO_wdt ghes hed button
 [ 2298.369200] Pid: 0, comm: swapper Not tainted 2.6.39-rc7-insat #1
 [ 2298.369203] Call Trace:
 [ 2298.369205]  <IRQ>  [<ffffffff810338cf>] 
 warn_slowpath_common+0x80/0x98
 [ 2298.369218]  [<ffffffff8103397b>] warn_slowpath_fmt+0x41/0x43
 [ 2298.369222]  [<ffffffff8132a10d>] skb_gso_segment+0x156/0x2b8
 [ 2298.369227]  [<ffffffff8132a700>] dev_hard_start_xmit+0x37c/0x522
 [ 2298.369233]  [<ffffffff81341135>] sch_direct_xmit+0x67/0x18d
 [ 2298.369237]  [<ffffffff81341365>] __qdisc_run+0x10a/0x126
 [ 2298.369241]  [<ffffffff8132ac39>] dev_queue_xmit+0x393/0x4c3
 [ 2298.369247]  [<ffffffff81332a8a>] neigh_resolve_output+0x28f/0x2ed
 [ 2298.369250]  [<ffffffff8134b8da>] ? nf_hook_slow+0x6d/0x108
 [ 2298.369253]  [<ffffffff81357ec4>] ? ip_options_build+0x143/0x143
 [ 2298.369255]  [<ffffffff8135a964>] ip_finish_output+0x260/0x2a3
 [ 2298.369257]  [<ffffffff8135aa4d>] ip_output+0xa6/0xad
 [ 2298.369258]  [<ffffffff81359d79>] ? __ip_local_out+0x9c/0x9e
 [ 2298.369260]  [<ffffffff81359d9f>] ip_local_out+0x24/0x28
 [ 2298.369262]  [<ffffffff8135a31c>] ip_queue_xmit+0x2dd/0x328
 [ 2298.369265]  [<ffffffff8131fcd5>] ? __skb_clone+0x29/0xf2
 [ 2298.369268]  [<ffffffff8136bbd4>] tcp_transmit_skb+0x74d/0x78b
 [ 2298.369270]  [<ffffffff8136e389>] tcp_write_xmit+0x806/0x8f5
 [ 2298.369272]  [<ffffffff8136b04f>] ? 
 tcp_established_options+0x2e/0xa9
 [ 2298.369274]  [<ffffffff8136e4c9>] 
 __tcp_push_pending_frames+0x20/0x7c
 [ 2298.369276]  [<ffffffff8136a685>] tcp_rcv_established+0x104/0x60f
 [ 2298.369278]  [<ffffffff81371696>] tcp_v4_do_rcv+0x1ba/0x377
 [ 2298.369283]  [<ffffffff81173e9f>] ? security_sock_rcv_skb+0x11/0x13
 [ 2298.369284]  [<ffffffff81371d6f>] tcp_v4_rcv+0x51c/0x869
 [ 2298.369287]  [<ffffffff81355b34>] ? ip_rcv+0x28a/0x28a
 [ 2298.369289]  [<ffffffff81355b34>] ? ip_rcv+0x28a/0x28a
 [ 2298.369291]  [<ffffffff81355cac>] 
 ip_local_deliver_finish+0x178/0x235
 [ 2298.369293]  [<ffffffff81355ddb>] ip_local_deliver+0x72/0x79
 [ 2298.369295]  [<ffffffff81355880>] ip_rcv_finish+0x2dc/0x306
 [ 2298.369297]  [<ffffffff81355b06>] ip_rcv+0x25c/0x28a
 [ 2298.369299]  [<ffffffff81329536>] __netif_receive_skb+0x4b8/0x4ea
 [ 2298.369301]  [<ffffffff81329778>] netif_receive_skb+0x67/0x6e
 [ 2298.369303]  [<ffffffff81329861>] napi_skb_finish+0x24/0x3b
 [ 2298.369305]  [<ffffffff81329d44>] napi_gro_receive+0xa8/0xad
 [ 2298.369309]  [<ffffffffa003668f>] igb_poll+0x783/0xaaa [igb]
 [ 2298.369314]  [<ffffffff81213d16>] ? put_device+0x12/0x14
 [ 2298.369317]  [<ffffffff81226e3d>] ? scsi_next_command+0x3e/0x46
 [ 2298.369319]  [<ffffffff81329e79>] net_rx_action+0xa3/0x1bb
 [ 2298.369322]  [<ffffffff81038537>] __do_softirq+0x83/0x114
 [ 2298.369324]  [<ffffffff813babcc>] call_softirq+0x1c/0x30
 [ 2298.369328]  [<ffffffff81003e0f>] do_softirq+0x33/0x68
 [ 2298.369329]  [<ffffffff810383d4>] irq_exit+0x3f/0x88
 [ 2298.369331]  [<ffffffff810036f6>] do_IRQ+0x98/0xaf
 [ 2298.369334]  [<ffffffff813b9453>] common_interrupt+0x13/0x13
 [ 2298.369335]  <EOI>  [<ffffffff8104d2d7>] ? 
 __hrtimer_start_range_ns+0x2a3/0x2b5
 [ 2298.369343]  [<ffffffff811c05a9>] ? intel_idle+0xc3/0xe9
 [ 2298.369345]  [<ffffffff811c058c>] ? intel_idle+0xa6/0xe9
 [ 2298.369348]  [<ffffffff813097cb>] cpuidle_idle_call+0x94/0xcd
 [ 2298.369350]  [<ffffffff81001c47>] cpu_idle+0x5a/0x91
 [ 2298.369353]  [<ffffffff813a5564>] rest_init+0x68/0x6a
 [ 2298.369356]  [<ffffffff8160d930>] start_kernel+0x2f3/0x2fe
 [ 2298.369358]  [<ffffffff8160d085>] 
 x86_64_start_reservations+0x82/0x86
 [ 2298.369360]  [<ffffffff8160d172>] x86_64_start_kernel+0xe9/0xf0
 [ 2298.369361] ---[ end trace 408f79c72c45f490 ]---
 [ 2298.369807] ------------[ cut here ]------------
 [ 2298.369809] WARNING: at net/core/dev.c:1876 
 skb_gso_segment+0x156/0x2b8()
 [ 2298.369810] Hardware name: RS700-E6/ERS4
 [ 2298.369811] igb: caps=(0x21143b3, 0x0) len=2948 data_len=0 
 ip_summed=0
 [ 2298.369812] Modules linked in: act_gact act_csum act_pedit cls_u32 
 sch_htb ipv6 i2c_i801 i7core_edac i2c_core edac_core rtc_cmos igb e1000e 
 rtc_core rtc_lib iTCO_wdt ghes hed button
 [ 2298.369818] Pid: 5867, comm: syslog-ng Tainted: G        W   
 2.6.39-rc7-insat #1
 [ 2298.369819] Call Trace:
 [ 2298.369820]  <IRQ>  [<ffffffff810338cf>] 
 warn_slowpath_common+0x80/0x98
 [ 2298.369824]  [<ffffffff8103397b>] warn_slowpath_fmt+0x41/0x43
 [ 2298.369826]  [<ffffffff8132a10d>] skb_gso_segment+0x156/0x2b8
 [ 2298.369828]  [<ffffffff8132a700>] dev_hard_start_xmit+0x37c/0x522
 [ 2298.369830]  [<ffffffff81341135>] sch_direct_xmit+0x67/0x18d
 [ 2298.369831]  [<ffffffff81341365>] __qdisc_run+0x10a/0x126
 [ 2298.369833]  [<ffffffff8132ac39>] dev_queue_xmit+0x393/0x4c3
 [ 2298.369835]  [<ffffffff81332a8a>] neigh_resolve_output+0x28f/0x2ed
 [ 2298.369837]  [<ffffffff8134b8da>] ? nf_hook_slow+0x6d/0x108
 [ 2298.369838]  [<ffffffff81357ec4>] ? ip_options_build+0x143/0x143
 [ 2298.369840]  [<ffffffff8135a964>] ip_finish_output+0x260/0x2a3
 [ 2298.369841]  [<ffffffff8135aa4d>] ip_output+0xa6/0xad
 [ 2298.369843]  [<ffffffff81359d79>] ? __ip_local_out+0x9c/0x9e
 [ 2298.369844]  [<ffffffff81359d9f>] ip_local_out+0x24/0x28
 [ 2298.369846]  [<ffffffff8135a31c>] ip_queue_xmit+0x2dd/0x328
 [ 2298.369848]  [<ffffffff8131fcd5>] ? __skb_clone+0x29/0xf2
 [ 2298.369850]  [<ffffffff8136bbd4>] tcp_transmit_skb+0x74d/0x78b
 [ 2298.369852]  [<ffffffff8136e389>] tcp_write_xmit+0x806/0x8f5
 [ 2298.369854]  [<ffffffff8136b04f>] ? 
 tcp_established_options+0x2e/0xa9
 [ 2298.369856]  [<ffffffff8136e4c9>] 
 __tcp_push_pending_frames+0x20/0x7c
 [ 2298.369857]  [<ffffffff8136a685>] tcp_rcv_established+0x104/0x60f
 [ 2298.369859]  [<ffffffff81371696>] tcp_v4_do_rcv+0x1ba/0x377
 [ 2298.369861]  [<ffffffff81173e9f>] ? security_sock_rcv_skb+0x11/0x13
 [ 2298.369863]  [<ffffffff81371d6f>] tcp_v4_rcv+0x51c/0x869
 [ 2298.369865]  [<ffffffff81355b34>] ? ip_rcv+0x28a/0x28a
 [ 2298.369867]  [<ffffffff81355b34>] ? ip_rcv+0x28a/0x28a
 [ 2298.369869]  [<ffffffff81355cac>] 
 ip_local_deliver_finish+0x178/0x235
 [ 2298.369870]  [<ffffffff81355ddb>] ip_local_deliver+0x72/0x79
 [ 2298.369872]  [<ffffffff81355880>] ip_rcv_finish+0x2dc/0x306
 [ 2298.369874]  [<ffffffff81355b06>] ip_rcv+0x25c/0x28a
 [ 2298.369876]  [<ffffffff81329536>] __netif_receive_skb+0x4b8/0x4ea
 [ 2298.369878]  [<ffffffff81329778>] netif_receive_skb+0x67/0x6e
 [ 2298.369879]  [<ffffffff81329861>] napi_skb_finish+0x24/0x3b
 [ 2298.369881]  [<ffffffff81329d44>] napi_gro_receive+0xa8/0xad
 [ 2298.369884]  [<ffffffffa003668f>] igb_poll+0x783/0xaaa [igb]
 [ 2298.369886]  [<ffffffff8100e0d3>] ? x86_pmu_enable+0x1fc/0x263
 [ 2298.369889]  [<ffffffff810794cb>] ? perf_ctx_adjust_freq+0x29/0x10a
 [ 2298.369890]  [<ffffffff81329e79>] net_rx_action+0xa3/0x1bb
 [ 2298.369893]  [<ffffffff8106f3d4>] ? 
 __rcu_process_callbacks+0x75/0x265
 [ 2298.369895]  [<ffffffff81038537>] __do_softirq+0x83/0x114
 [ 2298.369897]  [<ffffffff813babcc>] call_softirq+0x1c/0x30
 [ 2298.369899]  [<ffffffff81003e0f>] do_softirq+0x33/0x68
 [ 2298.369900]  [<ffffffff810383d4>] irq_exit+0x3f/0x88
 [ 2298.369902]  [<ffffffff810036f6>] do_IRQ+0x98/0xaf
 [ 2298.369904]  [<ffffffff813b9453>] common_interrupt+0x13/0x13
 [ 2298.369905]  <EOI>  [<ffffffff8104dc74>] ? 
 atomic_notifier_call_chain+0x13/0x15
 [ 2298.369910]  [<ffffffff81202714>] ? do_con_write+0x57b/0x1db7
 [ 2298.369912]  [<ffffffff812025eb>] ? do_con_write+0x452/0x1db7
 [ 2298.369913]  [<ffffffff810340da>] ? console_unlock+0x170/0x19a
 [ 2298.369915]  [<ffffffff811ff9b0>] ? con_flush_chars+0x3e/0x43
 [ 2298.369917]  [<ffffffff8104daa8>] ? up+0x34/0x39
 [ 2298.369918]  [<ffffffff81203f97>] con_write+0x11/0x26
 [ 2298.369920]  [<ffffffff8104a0c5>] ? add_wait_queue+0x3f/0x46
 [ 2298.369923]  [<ffffffff811f3896>] n_tty_write+0x239/0x35a
 [ 2298.369925]  [<ffffffff8102f2a9>] ? try_to_wake_up+0x240/0x240
 [ 2298.369926]  [<ffffffff811f0b13>] tty_write+0x19d/0x22f
 [ 2298.369928]  [<ffffffff811f365d>] ? n_tty_ioctl+0xab/0xab
 [ 2298.369931]  [<ffffffff810b3e82>] vfs_write+0xae/0x133
 [ 2298.369933]  [<ffffffff810b3fc0>] sys_write+0x45/0x6c
 [ 2298.369935]  [<ffffffff813b9a7b>] system_call_fastpath+0x16/0x1b
 [ 2298.369936] ---[ end trace 408f79c72c45f491 ]---

