From: Patrick Schaaf <kernelorg@bof.de>
Subject: Kernel 4.1 hang, apparently in __inet_lookup_established
Date: Wed, 23 Sep 2015 10:25:17 +0200
Message-ID: <5726932.6r4XOZ2Km2@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: NETDEV <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear kernel developers,

I recently started to upgrade my production hosts and VMs from the 3.14 series 
to 4.1 kernels, starting with 4.1.6. Yesterday, for the second time after I 
started these upgrades, I experienced one of our webserver VMs hanging.

The first time this happened, the VM hung completely, all 5 virtual cores 
spinning at 100%, ping still worked, but nothing else, including no virsh 
console reaction - I had to destroy and restart that VM. No messages were to 
be found.

Yesterday, when it happened the second time, I found the VM spinning on a 
single core only, and could still connect to it via ssh - but it stopped 
accepting apache connections. The core it spun on showed 100% time used in 
"si", with top, and it produced the messages appended below. The VM did not 
shutdown properly when told to, and had to be destroyed again.

If I read that dmesg output correctly it spins in __inet_lookup_established, 
which indeed reads like it has infinite spin potential. But that code itself 
did not change relative to the 3.14 series we've been running for a long time 
without the issues - so the root cause would be something else.

For our production systems I'll revert to the 3.14 series, but maybe this 
report may help somebody understand what's going on.

best regards
  Patrick

dmesg of the hang:

[449302.540017] INFO: rcu_sched self-detected stall on CPU { 4}  (t=6000 
jiffies g=22900108 c=22900107 q=22617)
[449302.540017] Task dump for CPU 4:
[449302.540017] swapper/4       R  running task        0     0      1 
0x00000008
[449302.540017]  ffffffff81831140 ffff88081f403950 ffffffff810ead0e 
0000000000000004
[449302.540017]  ffffffff81831140 ffff88081f403970 ffffffff810ed288 
0000000000000083
[449302.540017]  0000000000000005 ffff88081f4039a0 ffffffff81105cc0 
ffff88081f414d00
[449302.540017] Call Trace:
[449302.540017]  <IRQ>  [<ffffffff810ead0e>] sched_show_task+0xae/0x120
[449302.540017]  [<ffffffff810ed288>] dump_cpu_task+0x38/0x40
[449302.540017]  [<ffffffff81105cc0>] rcu_dump_cpu_stacks+0x90/0xd0
[449302.540017]  [<ffffffff81108cfb>] rcu_check_callbacks+0x3eb/0x6e0
[449302.540017]  [<ffffffff810ee22c>] ? account_process_tick+0x5c/0x180
[449302.540017]  [<ffffffff81119170>] ? tick_sched_handle.isra.18+0x40/0x40
[449302.540017]  [<ffffffff8110ae04>] update_process_times+0x34/0x60
[449302.540017]  [<ffffffff81119161>] tick_sched_handle.isra.18+0x31/0x40
[449302.540017]  [<ffffffff811191ac>] tick_sched_timer+0x3c/0x70
[449302.540017]  [<ffffffff8110b27a>] __run_hrtimer.isra.34+0x4a/0xf0
[449302.540017]  [<ffffffff8110bbfd>] hrtimer_interrupt+0xcd/0x1f0
[449302.540017]  [<ffffffff810296b4>] local_apic_timer_interrupt+0x34/0x60
[449302.540017]  [<ffffffff810299ec>] smp_apic_timer_interrupt+0x3c/0x60
[449302.540017]  [<ffffffff8149e98b>] apic_timer_interrupt+0x6b/0x70
[449302.540017]  [<ffffffff8141eee8>] ? __inet_lookup_established+0x68/0x130
[449302.540017]  [<ffffffff8141eec1>] ? __inet_lookup_established+0x41/0x130
[449302.540017]  [<ffffffff81438466>] tcp_v4_early_demux+0x96/0x150
[449302.540017]  [<ffffffff814150c8>] ip_rcv_finish+0xb8/0x360
[449302.540017]  [<ffffffff814157e4>] ip_rcv+0x294/0x3f0
[449302.540017]  [<ffffffff81415010>] ? ip_local_deliver_finish+0x140/0x140
[449302.540017]  [<ffffffff81398edb>] __netif_receive_skb_core+0x52b/0x760
[449302.540017]  [<ffffffff81399123>] __netif_receive_skb+0x13/0x60
[449302.540017]  [<ffffffff8139918e>] netif_receive_skb_internal+0x1e/0x90
[449302.540017]  [<ffffffff8139c8ec>] netif_receive_skb_sk+0xc/0x10
[449302.540017]  [<ffffffff81370e51>] virtnet_receive+0x221/0x7a0
[449302.540017]  [<ffffffff813714cc>] virtnet_poll+0x1c/0x80
[449302.540017]  [<ffffffff8139cfca>] net_rx_action+0xea/0x2b0
[449302.540017]  [<ffffffff810ccd8a>] __do_softirq+0xda/0x1f0
[449302.540017]  [<ffffffff810cd0dd>] irq_exit+0x9d/0xb0
[449302.540017]  [<ffffffff81003f95>] do_IRQ+0x55/0xf0
[449302.540017]  [<ffffffff8149e6eb>] common_interrupt+0x6b/0x6b
[449302.540017]  <EOI>  [<ffffffff810edb88>] ? sched_clock_cpu+0x98/0xc0
[449302.540017]  [<ffffffff81030b06>] ? native_safe_halt+0x6/0x10
[449302.540017]  [<ffffffff8100a9a9>] default_idle+0x9/0x10
[449302.540017]  [<ffffffff8100b3da>] arch_cpu_idle+0xa/0x10
[449302.540017]  [<ffffffff810f8d08>] cpu_startup_entry+0x258/0x310
[449302.540017]  [<ffffffff81028063>] start_secondary+0x123/0x130
[449482.570137] INFO: rcu_sched self-detected stall on CPU { 4}  (t=24004 
jiffies g=22900108 c=22900107 q=97787)
[449482.570148] Task dump for CPU 4:
[449482.570151] swapper/4       R  running task        0     0      1 
0x00000008
[449482.570156]  ffffffff81831140 ffff88081f403950 ffffffff810ead0e 
0000000000000004
[449482.570165]  ffffffff81831140 ffff88081f403970 ffffffff810ed288 
0000000000000083
[449482.570167]  0000000000000005 ffff88081f4039a0 ffffffff81105cc0 
ffff88081f414d00
[449482.570169] Call Trace:
[449482.570171]  <IRQ>  [<ffffffff810ead0e>] sched_show_task+0xae/0x120
[449482.570183]  [<ffffffff810ed288>] dump_cpu_task+0x38/0x40
[449482.570188]  [<ffffffff81105cc0>] rcu_dump_cpu_stacks+0x90/0xd0
[449482.570191]  [<ffffffff81108cfb>] rcu_check_callbacks+0x3eb/0x6e0
[449482.570194]  [<ffffffff810ee22c>] ? account_process_tick+0x5c/0x180
[449482.570199]  [<ffffffff81119170>] ? tick_sched_handle.isra.18+0x40/0x40
[449482.570202]  [<ffffffff8110ae04>] update_process_times+0x34/0x60
[449482.570203]  [<ffffffff81119161>] tick_sched_handle.isra.18+0x31/0x40
[449482.570205]  [<ffffffff811191ac>] tick_sched_timer+0x3c/0x70
[449482.570207]  [<ffffffff8110b27a>] __run_hrtimer.isra.34+0x4a/0xf0
[449482.570209]  [<ffffffff8110bbfd>] hrtimer_interrupt+0xcd/0x1f0
[449482.570220]  [<ffffffff810296b4>] local_apic_timer_interrupt+0x34/0x60
[449482.570222]  [<ffffffff810299ec>] smp_apic_timer_interrupt+0x3c/0x60
[449482.570226]  [<ffffffff8149e98b>] apic_timer_interrupt+0x6b/0x70
[449482.570230]  [<ffffffff8141eee0>] ? __inet_lookup_established+0x60/0x130
[449482.570232]  [<ffffffff8141eec1>] ? __inet_lookup_established+0x41/0x130
[449482.570235]  [<ffffffff81438466>] tcp_v4_early_demux+0x96/0x150
[449482.570238]  [<ffffffff814150c8>] ip_rcv_finish+0xb8/0x360
[449482.570239]  [<ffffffff814157e4>] ip_rcv+0x294/0x3f0
[449482.570241]  [<ffffffff81415010>] ? ip_local_deliver_finish+0x140/0x140
[449482.570246]  [<ffffffff81398edb>] __netif_receive_skb_core+0x52b/0x760
[449482.570247]  [<ffffffff81399123>] __netif_receive_skb+0x13/0x60
[449482.570249]  [<ffffffff8139918e>] netif_receive_skb_internal+0x1e/0x90
[449482.570252]  [<ffffffff8139c8ec>] netif_receive_skb_sk+0xc/0x10
[449482.570255]  [<ffffffff81370e51>] virtnet_receive+0x221/0x7a0
[449482.570257]  [<ffffffff813714cc>] virtnet_poll+0x1c/0x80
[449482.570259]  [<ffffffff8139cfca>] net_rx_action+0xea/0x2b0
[449482.570260]  [<ffffffff810ccd8a>] __do_softirq+0xda/0x1f0
[449482.570260]  [<ffffffff810cd0dd>] irq_exit+0x9d/0xb0
[449482.570260]  [<ffffffff81003f95>] do_IRQ+0x55/0xf0
[449482.570260]  [<ffffffff8149e6eb>] common_interrupt+0x6b/0x6b
[449482.570260]  <EOI>  [<ffffffff810edb88>] ? sched_clock_cpu+0x98/0xc0
[449482.570260]  [<ffffffff81030b06>] ? native_safe_halt+0x6/0x10
[449482.570260]  [<ffffffff8100a9a9>] default_idle+0x9/0x10
[449482.570260]  [<ffffffff8100b3da>] arch_cpu_idle+0xa/0x10
[449482.570260]  [<ffffffff810f8d08>] cpu_startup_entry+0x258/0x310
[449482.570260]  [<ffffffff81028063>] start_secondary+0x123/0x130
[449662.610077] INFO: rcu_sched self-detected stall on CPU { 4}  (t=42008 
jiffies g=22900108 c=22900107 q=140789)
[449662.610077] Task dump for CPU 4:
[449662.610077] swapper/4       R  running task        0     0      1 
0x00000008
[449662.610077]  ffffffff81831140 ffff88081f403950 ffffffff810ead0e 
0000000000000004
[449662.610077]  ffffffff81831140 ffff88081f403970 ffffffff810ed288 
0000000000000083
[449662.610077]  0000000000000005 ffff88081f4039a0 ffffffff81105cc0 
ffff88081f414d00
[449662.610077] Call Trace:
[449662.610077]  <IRQ>  [<ffffffff810ead0e>] sched_show_task+0xae/0x120
[449662.610077]  [<ffffffff810ed288>] dump_cpu_task+0x38/0x40
[449662.610077]  [<ffffffff81105cc0>] rcu_dump_cpu_stacks+0x90/0xd0
[449662.610077]  [<ffffffff81108cfb>] rcu_check_callbacks+0x3eb/0x6e0
[449662.610077]  [<ffffffff810ee22c>] ? account_process_tick+0x5c/0x180
[449662.610077]  [<ffffffff81119170>] ? tick_sched_handle.isra.18+0x40/0x40
[449662.610077]  [<ffffffff8110ae04>] update_process_times+0x34/0x60
[449662.610077]  [<ffffffff81119161>] tick_sched_handle.isra.18+0x31/0x40
[449662.610077]  [<ffffffff811191ac>] tick_sched_timer+0x3c/0x70
[449662.610077]  [<ffffffff8110b27a>] __run_hrtimer.isra.34+0x4a/0xf0
[449662.610077]  [<ffffffff8110bbfd>] hrtimer_interrupt+0xcd/0x1f0
[449662.610077]  [<ffffffff810296b4>] local_apic_timer_interrupt+0x34/0x60
[449662.610077]  [<ffffffff810299ec>] smp_apic_timer_interrupt+0x3c/0x60
[449662.610077]  [<ffffffff8149e98b>] apic_timer_interrupt+0x6b/0x70
[449662.610077]  [<ffffffff8141eee8>] ? __inet_lookup_established+0x68/0x130
[449662.610077]  [<ffffffff8141eec1>] ? __inet_lookup_established+0x41/0x130
[449662.610077]  [<ffffffff81438466>] tcp_v4_early_demux+0x96/0x150
[449662.610077]  [<ffffffff814150c8>] ip_rcv_finish+0xb8/0x360
[449662.610077]  [<ffffffff814157e4>] ip_rcv+0x294/0x3f0
[449662.610077]  [<ffffffff81415010>] ? ip_local_deliver_finish+0x140/0x140
[449662.610077]  [<ffffffff81398edb>] __netif_receive_skb_core+0x52b/0x760
[449662.610077]  [<ffffffff81399123>] __netif_receive_skb+0x13/0x60
[449662.610077]  [<ffffffff8139918e>] netif_receive_skb_internal+0x1e/0x90
[449662.610077]  [<ffffffff8139c8ec>] netif_receive_skb_sk+0xc/0x10
[449662.610077]  [<ffffffff81370e51>] virtnet_receive+0x221/0x7a0
[449662.610077]  [<ffffffff813714cc>] virtnet_poll+0x1c/0x80
[449662.610077]  [<ffffffff8139cfca>] net_rx_action+0xea/0x2b0
[449662.610077]  [<ffffffff810ccd8a>] __do_softirq+0xda/0x1f0
[449662.610077]  [<ffffffff810cd0dd>] irq_exit+0x9d/0xb0
[449662.610077]  [<ffffffff81003f95>] do_IRQ+0x55/0xf0
[449662.610077]  [<ffffffff8149e6eb>] common_interrupt+0x6b/0x6b
[449662.610077]  <EOI>  [<ffffffff810edb88>] ? sched_clock_cpu+0x98/0xc0
[449662.610077]  [<ffffffff81030b06>] ? native_safe_halt+0x6/0x10
[449662.610077]  [<ffffffff8100a9a9>] default_idle+0x9/0x10
[449662.610077]  [<ffffffff8100b3da>] arch_cpu_idle+0xa/0x10
[449662.610077]  [<ffffffff810f8d08>] cpu_startup_entry+0x258/0x310
[449662.610077]  [<ffffffff81028063>] start_secondary+0x123/0x130
[449842.650014] INFO: rcu_sched self-detected stall on CPU { 4}  (t=60011 
jiffies g=22900108 c=22900107 q=206408)
[449842.650014] Task dump for CPU 4:
[449842.650014] swapper/4       R  running task        0     0      1 
0x00000008
[449842.650014]  ffffffff81831140 ffff88081f403950 ffffffff810ead0e 
0000000000000004
[449842.650014]  ffffffff81831140 ffff88081f403970 ffffffff810ed288 
0000000000000083
[449842.650014]  0000000000000005 ffff88081f4039a0 ffffffff81105cc0 
ffff88081f414d00
[449842.650014] Call Trace:
[449842.650014]  <IRQ>  [<ffffffff810ead0e>] sched_show_task+0xae/0x120
[449842.650014]  [<ffffffff810ed288>] dump_cpu_task+0x38/0x40
[449842.650014]  [<ffffffff81105cc0>] rcu_dump_cpu_stacks+0x90/0xd0
[449842.650014]  [<ffffffff81108cfb>] rcu_check_callbacks+0x3eb/0x6e0
[449842.650014]  [<ffffffff810ee22c>] ? account_process_tick+0x5c/0x180
[449842.650014]  [<ffffffff81119170>] ? tick_sched_handle.isra.18+0x40/0x40
[449842.650014]  [<ffffffff8110ae04>] update_process_times+0x34/0x60
[449842.650014]  [<ffffffff81119161>] tick_sched_handle.isra.18+0x31/0x40
[449842.650014]  [<ffffffff811191ac>] tick_sched_timer+0x3c/0x70
[449842.650014]  [<ffffffff8110b27a>] __run_hrtimer.isra.34+0x4a/0xf0
[449842.650014]  [<ffffffff8110bbfd>] hrtimer_interrupt+0xcd/0x1f0
[449842.650014]  [<ffffffff810296b4>] local_apic_timer_interrupt+0x34/0x60
[449842.650014]  [<ffffffff810299ec>] smp_apic_timer_interrupt+0x3c/0x60
[449842.650014]  [<ffffffff8149e98b>] apic_timer_interrupt+0x6b/0x70
[449842.650014]  [<ffffffff8141ef58>] ? __inet_lookup_established+0xd8/0x130
[449842.650014]  [<ffffffff8141eec1>] ? __inet_lookup_established+0x41/0x130
[449842.650014]  [<ffffffff81438466>] tcp_v4_early_demux+0x96/0x150
[449842.650014]  [<ffffffff814150c8>] ip_rcv_finish+0xb8/0x360
[449842.650014]  [<ffffffff814157e4>] ip_rcv+0x294/0x3f0
[449842.650014]  [<ffffffff81415010>] ? ip_local_deliver_finish+0x140/0x140
[449842.650014]  [<ffffffff81398edb>] __netif_receive_skb_core+0x52b/0x760
[449842.650014]  [<ffffffff81399123>] __netif_receive_skb+0x13/0x60
[449842.650014]  [<ffffffff8139918e>] netif_receive_skb_internal+0x1e/0x90
[449842.650014]  [<ffffffff8139c8ec>] netif_receive_skb_sk+0xc/0x10
[449842.650014]  [<ffffffff81370e51>] virtnet_receive+0x221/0x7a0
[449842.650014]  [<ffffffff813714cc>] virtnet_poll+0x1c/0x80
[449842.650014]  [<ffffffff8139cfca>] net_rx_action+0xea/0x2b0
[449842.650014]  [<ffffffff810ccd8a>] __do_softirq+0xda/0x1f0
[449842.650014]  [<ffffffff810cd0dd>] irq_exit+0x9d/0xb0
[449842.650014]  [<ffffffff81003f95>] do_IRQ+0x55/0xf0
[449842.650014]  [<ffffffff8149e6eb>] common_interrupt+0x6b/0x6b
[449842.650014]  <EOI>  [<ffffffff810edb88>] ? sched_clock_cpu+0x98/0xc0
[449842.650014]  [<ffffffff81030b06>] ? native_safe_halt+0x6/0x10
[449842.650014]  [<ffffffff8100a9a9>] default_idle+0x9/0x10
[449842.650014]  [<ffffffff8100b3da>] arch_cpu_idle+0xa/0x10
[449842.650014]  [<ffffffff810f8d08>] cpu_startup_entry+0x258/0x310
[449842.650014]  [<ffffffff81028063>] start_secondary+0x123/0x130
