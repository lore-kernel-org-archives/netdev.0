From: Thomas Zeitlhofer <thomas.zeitlhofer@nt.tuwien.ac.at>
Subject: tuntap regression in v3.9.8 and v3.10
Date: Tue, 2 Jul 2013 21:59:10 +0200
Message-ID: <20130702195910.GA20271@toau.bambla>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit "tuntap: set SOCK_ZEROCOPY flag during open" introduces a
regression which is observed with live migration of qemu/kvm based
virtual machines that are connected to an openvswitch bridge.

Reverting this commit (b26c93c46a3dec25ed236d4ba6107eb4ed5d9401 in
v3.9.8 and accordingly 19a6afb23e5d323e1245baa4e62755492b2f1200 in
v3.10) fixes the following problem:

Trying to live migrate a virtual machine _off_ a host machine running
v3.9.8 or v3.10 immediately leads to a kernel panic on that host
machine, e.g.:

general protection fault: 0000 [#1] PREEMPT SMP 
Modules linked in: pci_stub vhost_net macvtap macvlan drbd lru_cache libcrc32c fuse ebtable_filter ebtabld
CPU 0 
Pid: 0, comm: swapper/0 Not tainted 3.9.8-kvm-00181-ge2a2068 #1 MSI MS-7798/B75MA-P45 (MS-7798)
RIP: 0010:[<ffffffff81101734>]  [<ffffffff81101734>] kmem_cache_alloc+0x54/0x150
RSP: 0018:ffff88041e203288  EFLAGS: 00010286
RAX: 0000000000000000 RBX: 0000000000000001 RCX: 00000000005069a8
RDX: 00000000005069a0 RSI: 0000000000000020 RDI: ffff88040c401700
RBP: ffff88041e2032b8 R08: 0000000000014720 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000580 R12: f9052081a105964d
R13: ffff88040c401700 R14: 0000000000000020 R15: ffffffff814a12f5
FS:  0000000000000000(0000) GS:ffff88041e200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffffffff600400 CR3: 0000000406305000 CR4: 00000000001427e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper/0 (pid: 0, threadinfo ffffffff81800000, task ffffffff81811440)
Stack:
 ffff88041e203298 0000000000000001 0000000000000001 ffff880407c26098
 0000000000000001 ffff880407b6c128 ffff88041e2032c8 ffffffff814a12f5
 ffff88041e203348 ffffffff8149dcc3 ffff88039cfa5ac0 00000003728740ba
Call Trace:
 <IRQ> 
 [<ffffffff814a12f5>] alloc_iova_mem+0x15/0x20
 [<ffffffff8149dcc3>] alloc_iova+0x23/0x240
 [<ffffffff814a0ddb>] ? __domain_mapping+0x1bb/0x410
 [<ffffffff8149fd24>] intel_alloc_iova+0x74/0xe0
 [<ffffffff81047220>] ? irq_exit+0x70/0xa0
 [<ffffffff814a279a>] __intel_map_single+0x9a/0x1c0
 [<ffffffff814a28ee>] intel_map_page+0x2e/0x30
 [<ffffffffa004b0a2>] rtl8169_start_xmit+0x1b2/0x820 [r8169]
 [<ffffffff814b5094>] ? skb_checksum+0x54/0x320
 [<ffffffff814c58c6>] dev_hard_start_xmit+0x226/0x480
 [<ffffffff814ddeee>] sch_direct_xmit+0xfe/0x1d0
 [<ffffffff814c5d1e>] dev_queue_xmit+0x1fe/0x470
 [<ffffffffa0548a2e>] netdev_send+0x4e/0xd0 [openvswitch]
 [<ffffffffa054838a>] ovs_vport_send+0x1a/0x50 [openvswitch]
 [<ffffffffa05422a9>] do_output+0x29/0x50 [openvswitch]
 [<ffffffffa054295f>] do_execute_actions+0x62f/0x890 [openvswitch]
 [<ffffffff815ae03e>] ? _raw_spin_lock+0x1e/0x30
 [<ffffffffa0542bde>] ovs_execute_actions+0x1e/0x20 [openvswitch]
 [<ffffffffa05453ed>] ovs_dp_process_received_packet+0x8d/0x100 [openvswitch]
 [<ffffffffa0548354>] ovs_vport_receive+0x44/0x60 [openvswitch]
 [<ffffffffa05488ab>] internal_dev_xmit+0x2b/0x40 [openvswitch]
 [<ffffffff814c57e1>] dev_hard_start_xmit+0x141/0x480
 [<ffffffffa0426602>] ? ipv6_confirm+0x62/0x140 [nf_conntrack_ipv6]
 [<ffffffff814c5e2c>] dev_queue_xmit+0x30c/0x470
 [<ffffffffa037403d>] ip6_finish_output2+0x1bd/0x470 [ipv6]
 [<ffffffffa0376030>] ? ip6_fragment+0xa80/0xa80 [ipv6]
 [<ffffffffa03760c0>] ip6_finish_output+0x90/0xb0 [ipv6]
 [<ffffffffa037611c>] ip6_output+0x3c/0xb0 [ipv6]
 [<ffffffffa037469c>] ip6_xmit+0x1dc/0x410 [ipv6]
 [<ffffffff814b0d47>] ? sk_setup_caps+0x27/0xd0
 [<ffffffffa039f9a9>] inet6_csk_xmit+0x79/0xc0 [ipv6]
 [<ffffffff81518a9d>] tcp_transmit_skb+0x3cd/0x910
 [<ffffffff81519295>] tcp_write_xmit+0x205/0xab0
 [<ffffffff814b6df2>] ? __kfree_skb+0x42/0xa0
 [<ffffffff81519b9d>] __tcp_push_pending_frames+0x2d/0x90
 [<ffffffff815158cc>] tcp_rcv_established+0x13c/0x5b0
 [<ffffffffa039a6a4>] tcp_v6_do_rcv+0x1a4/0x500 [ipv6]
 [<ffffffffa039b82a>] tcp_v6_rcv+0x77a/0x900 [ipv6]
 [<ffffffffa0376190>] ? ip6_output+0xb0/0xb0 [ipv6]
 [<ffffffffa03762f9>] ip6_input_finish+0x169/0x430 [ipv6]
 [<ffffffffa0376a7d>] ip6_input+0x1d/0x60 [ipv6]
 [<ffffffffa0376640>] ip6_rcv_finish+0x80/0x90 [ipv6]
 [<ffffffffa03768e6>] ipv6_rcv+0x296/0x410 [ipv6]
 [<ffffffff814c32dc>] ? __netif_receive_skb+0x1c/0x70
 [<ffffffff814c30b2>] __netif_receive_skb_core+0x532/0x740
 [<ffffffff814c32dc>] __netif_receive_skb+0x1c/0x70
 [<ffffffff814c33da>] process_backlog+0xaa/0x190
 [<ffffffff814c37ad>] net_rx_action+0xad/0x1b0
 [<ffffffff8104701a>] __do_softirq+0xca/0x1a0
 [<ffffffff81484fe0>] ? intel_pstate_set_policy+0x150/0x150
 [<ffffffff81047236>] irq_exit+0x86/0xa0
 [<ffffffff810044de>] do_IRQ+0x5e/0xd0
 [<ffffffff815ae6ea>] common_interrupt+0x6a/0x6a
 <EOI> 
 [<ffffffff814858ae>] ? cpuidle_wrap_enter+0x4e/0x90
 [<ffffffff814858a4>] ? cpuidle_wrap_enter+0x44/0x90
 [<ffffffff81485010>] cpuidle_enter_tk+0x10/0x20
 [<ffffffff8148564c>] cpuidle_idle_call+0x7c/0x110
 [<ffffffff8100bc4f>] cpu_idle+0x6f/0xf0
 [<ffffffff81591676>] rest_init+0x76/0x80
 [<ffffffff8188ee67>] start_kernel+0x39e/0x3ab
 [<ffffffff8188e8c8>] ? repair_env_string+0x5e/0x5e
 [<ffffffff8188e5c0>] x86_64_start_reservations+0x2a/0x2c
 [<ffffffff8188e6b3>] x86_64_start_kernel+0xf1/0x100
Code: 00 00 49 8b 45 00 65 48 03 04 25 28 cd 00 00 48 8b 50 08 4c 8b 20 4d 85 e4 0f 84 b2 00 00 00 49 63  
RIP  [<ffffffff81101734>] kmem_cache_alloc+0x54/0x150
 RSP <ffff88041e203288>
general protection fault: 0000 [#2] ---[ end trace d2fe019886582529 ]---
Kernel panic - not syncing: Fatal exception in interrupt
PREEMPT SMP 
Modules linked in: pci_stub vhost_net macvtap macvlan drbd lru_cache libcrc32c fuse ebtable_filter ebtabld
CPU 3 
Pid: 0, comm: swapper/3 Tainted: G      D      3.9.8-kvm-00181-ge2a2068 #1 MSI MS-7798/B75MA-P45 (MS-7798)
RIP: 0010:[<ffffffff812e1623>]  [<ffffffff812e1623>] rb_erase+0x1a3/0x370
RSP: 0018:ffff88041e383dc8  EFLAGS: 00010046
RAX: ffff880300000000 RBX: ffff880407b6c128 RCX: 0000000000000000
RDX: ff88039cfa5ac0ff RSI: ffff880407b6c130 RDI: ffff88039cfa5ac0
RBP: ffff88041e383dc8 R08: 0000000000000000 R09: ffff88040c405d00
R10: 0000000000000040 R11: 0000000200000025 R12: ffff88039cfa5ac0
R13: 0000000000000082 R14: 0000000000000000 R15: ffff88039cfa5ac0
FS:  0000000000000000(0000) GS:ffff88041e380000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f750b185000 CR3: 000000000180c000 CR4: 00000000001427e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper/3 (pid: 0, threadinfo ffff880408208000, task ffff8804087cd550)
Stack:
 ffff88041e383df8 ffffffff8149dfb2 0000000000000fa8 0000000000000001
 0000000000000fa8 ffff8804087af0c0 ffff88041e383e48 ffffffff8149f03e
 ffff88041e383e18 000000018102fa39 ffff88041e383e48 0000000000000286
Call Trace:
 <IRQ> 
 [<ffffffff8149dfb2>] __free_iova+0x42/0xa0
 [<ffffffff8149f03e>] flush_unmaps+0xbe/0x170
 [<ffffffff8149f0f0>] ? flush_unmaps+0x170/0x170
 [<ffffffff8149f10d>] flush_unmaps_timeout+0x1d/0x40
 [<ffffffff8104d33d>] call_timer_fn.isra.31+0x2d/0x90
 [<ffffffff8149f0f0>] ? flush_unmaps+0x170/0x170
 [<ffffffff8104d520>] run_timer_softirq+0x180/0x210
 [<ffffffff8104701a>] __do_softirq+0xca/0x1a0
 [<ffffffff81484fe0>] ? intel_pstate_set_policy+0x150/0x150
 [<ffffffff81047236>] irq_exit+0x86/0xa0
 [<ffffffff81025b28>] smp_apic_timer_interrupt+0x68/0xa0
 [<ffffffff815afb0a>] apic_timer_interrupt+0x6a/0x70
 <EOI> 
 [<ffffffff814858ae>] ? cpuidle_wrap_enter+0x4e/0x90
 [<ffffffff814858a4>] ? cpuidle_wrap_enter+0x44/0x90
 [<ffffffff81485010>] cpuidle_enter_tk+0x10/0x20
 [<ffffffff8148564c>] cpuidle_idle_call+0x7c/0x110
 [<ffffffff8100bc4f>] cpu_idle+0x6f/0xf0
 [<ffffffff8159b33e>] start_secondary+0x1b3/0x1b7
Code: 10 f6 c2 01 0f 84 4e 01 00 00 48 83 e2 fc 0f 84 10 ff ff ff 48 89 c1 48 89 d0 48 8b 50 08 48 39 ca  
RIP  [<ffffffff812e1623>] rb_erase+0x1a3/0x370
 RSP <ffff88041e383dc8>
---[ end trace d2fe01988658252a ]---
