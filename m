From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [linux-next] sk->sk_dst_lock inconsistent lock state
Date: Mon, 16 Dec 2013 12:04:12 +0300
Message-ID: <20131216090412.GA2230@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

3.13.0-rc4-next-20131216

[  114.923321] =================================
[  114.923324] [ INFO: inconsistent lock state ]
[  114.923330] 3.13.0-rc4-next-20131216-dbg-dirty #59 Not tainted
[  114.923333] ---------------------------------
[  114.923337] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[  114.923342] swapper/0/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
[  114.923346]  (&(&sk->sk_dst_lock)->rlock){+.?...}, at: [<ffffffff813a50db>] __udp4_lib_rcv+0x537/0x765
[  114.923363] {SOFTIRQ-ON-W} state was registered at:
[  114.923367]   [<ffffffff81077272>] __lock_acquire+0xa49/0x1b03
[  114.923376]   [<ffffffff81078aa0>] lock_acquire+0x6f/0x8e
[  114.923381]   [<ffffffff813eba9b>] _raw_spin_lock+0x33/0x3f
[  114.923390]   [<ffffffff813ad834>] inet_bind+0x18b/0x216
[  114.923397]   [<ffffffff8133509e>] SyS_bind+0x7d/0xaa
[  114.923405]   [<ffffffff813ed266>] tracesys+0xd4/0xd9
[  114.923412] irq event stamp: 1386010
[  114.923415] hardirqs last  enabled at (1386010): [<ffffffff810f5cf0>] kmem_cache_free+0xf0/0x17d
[  114.923424] hardirqs last disabled at (1386009): [<ffffffff810f5cc4>] kmem_cache_free+0xc4/0x17d
[  114.923431] softirqs last  enabled at (1385998): [<ffffffff81041672>] _local_bh_enable+0x3e/0x40
[  114.923440] softirqs last disabled at (1385999): [<ffffffff810420f2>] irq_exit+0x52/0xe2
[  114.923446] 
other info that might help us debug this:
[  114.923450]  Possible unsafe locking scenario:

[  114.923454]        CPU0
[  114.923456]        ----
[  114.923459]   lock(&(&sk->sk_dst_lock)->rlock);
[  114.923464]   <Interrupt>
[  114.923467]     lock(&(&sk->sk_dst_lock)->rlock);
[  114.923472] 
 *** DEADLOCK ***

[  114.923478] 2 locks held by swapper/0/0:
[  114.923480]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff81348a50>] __netif_receive_skb_core+0x1c1/0x9b0
[  114.923494]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff81379c83>] ip_local_deliver+0x54/0x34b
[  114.923509] 
stack backtrace:
[  114.923516] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0-rc4-next-20131216-dbg-dirty #59
[  114.923520] Hardware name: Acer             Aspire 5741G    /Aspire 5741G    , BIOS V1.20 02/08/2011
[  114.923524]  0000000000000000 ffff880157c03a58 ffffffff813e57ff ffffffff81612490
[  114.923533]  ffff880157c03aa8 ffffffff813e2e0c 0000000000000001 ffff880100000001
[  114.923542]  ffffffff00000000 ffffffff81612b70 0000000000000004 0000000000000006
[  114.923551] Call Trace:
[  114.923554]  <IRQ>  [<ffffffff813e57ff>] dump_stack+0x4e/0x7a
[  114.923566]  [<ffffffff813e2e0c>] print_usage_bug+0x2b1/0x31c
[  114.923574]  [<ffffffff81075203>] ? print_irq_inversion_bug+0x234/0x234
[  114.923580]  [<ffffffff81075e9e>] mark_lock+0x341/0x698
[  114.923586]  [<ffffffff81077200>] __lock_acquire+0x9d7/0x1b03
[  114.923594]  [<ffffffff813b9597>] ? check_leaf.isra.10+0x20d/0x20d
[  114.923601]  [<ffffffff81078aa0>] lock_acquire+0x6f/0x8e
[  114.923608]  [<ffffffff813a50db>] ? __udp4_lib_rcv+0x537/0x765
[  114.923614]  [<ffffffff813eba9b>] _raw_spin_lock+0x33/0x3f
[  114.923620]  [<ffffffff813a50db>] ? __udp4_lib_rcv+0x537/0x765
[  114.923627]  [<ffffffff813a50db>] __udp4_lib_rcv+0x537/0x765
[  114.923633]  [<ffffffff813a58f5>] udp_rcv+0x15/0x17
[  114.923640]  [<ffffffff81379e03>] ip_local_deliver+0x1d4/0x34b
[  114.923646]  [<ffffffff81379c83>] ? ip_local_deliver+0x54/0x34b
[  114.923653]  [<ffffffff8137a58d>] ip_rcv+0x613/0x6a3
[  114.923659]  [<ffffffff8134919f>] __netif_receive_skb_core+0x910/0x9b0
[  114.923665]  [<ffffffff81348a50>] ? __netif_receive_skb_core+0x1c1/0x9b0
[  114.923674]  [<ffffffff81009275>] ? read_tsc+0x9/0x1b
[  114.923680]  [<ffffffff81349252>] __netif_receive_skb+0x13/0x55
[  114.923686]  [<ffffffff81349369>] netif_receive_skb+0xd5/0x1b8
[  114.923693]  [<ffffffff81349c9a>] napi_gro_receive+0x26/0x66
[  114.923705]  [<ffffffffa0177027>] tg3_poll_work+0x878/0xc80 [tg3]
[  114.923716]  [<ffffffffa0177719>] tg3_poll+0x19f/0x352 [tg3]
[  114.923723]  [<ffffffff8134a3fd>] net_rx_action+0xec/0x1c0
[  114.923729]  [<ffffffff81041c86>] __do_softirq+0xfe/0x254
[  114.923735]  [<ffffffff810420f2>] irq_exit+0x52/0xe2
[  114.923743]  [<ffffffff810041c1>] do_IRQ+0x97/0xae
[  114.923751]  [<ffffffff813ec7b2>] common_interrupt+0x72/0x72
[  114.923754]  <EOI>  [<ffffffff8132005d>] ? cpuidle_enter_state+0x54/0xb0
[  114.923767]  [<ffffffff8132018c>] cpuidle_idle_call+0xd3/0x11c
[  114.923774]  [<ffffffff8100aab1>] arch_cpu_idle+0x9/0x23
[  114.923781]  [<ffffffff8108508f>] cpu_startup_entry+0xdf/0x164
[  114.923788]  [<ffffffff813ddfe9>] rest_init+0x12d/0x131
[  114.923794]  [<ffffffff813ddebc>] ? csum_partial_copy_generic+0x16c/0x16c
[  114.923802]  [<ffffffff81685d64>] start_kernel+0x3e2/0x3ee
[  114.923808]  [<ffffffff81685790>] ? repair_env_string+0x58/0x58
[  114.923816]  [<ffffffff81685120>] ? early_idt_handlers+0x120/0x120
[  114.923823]  [<ffffffff81685498>] x86_64_start_reservations+0x2a/0x2c
[  114.923830]  [<ffffffff81685588>] x86_64_start_kernel+0xee/0xfb


	-ss
