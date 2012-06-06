From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Deadlock, L2TP over IP are not working, 3.4.1
Date: Wed, 06 Jun 2012 12:54:56 +0300
Message-ID: <7ed49f446365ac625437702d92946add@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems l2tp are not working, at least for me, due some bug

Script i uses, to reproduce:
SERVER=192.168.11.2
LOCALIP=`curl http://${SERVER}:8080/myip`
ID=`curl http://${SERVER}:8080/tunid` # It will generate some number, 
let's say 2
echo ID: ${ID}
modprobe l2tp_ip
modprobe l2tp_eth
ip l2tp add tunnel remote ${SERVER} local ${LOCALIP} tunnel_id ${ID} 
peer_tunnel_id ${ID} encap ip
ip l2tp add session name tun100 tunnel_id ${ID} session_id 1 
peer_session_id 1
ip link set dev tun100 up
ip addr add dev tun100 10.0.6.${ID}/24

Here is report for latest stable kernel. I can reproduce it on multiple 
pc's.
It is new setup, so i am not sure it was working on old kernels or not 
(regression or not).

[ 8683.927442] ======================================================
[ 8683.927555] [ INFO: possible circular locking dependency detected ]
[ 8683.927672] 3.4.1-build-0061 #14 Not tainted
[ 8683.927782] -------------------------------------------------------
[ 8683.927895] swapper/0/0 is trying to acquire lock:
[ 8683.928007]  (slock-AF_INET){+.-...}, at: [<e0fc73ec>] 
l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[ 8683.928121]
[ 8683.928121] but task is already holding lock:
[ 8683.928121]  (_xmit_ETHER#2){+.-...}, at: [<c02f062d>] 
sch_direct_xmit+0x36/0x119
[ 8683.928121]
[ 8683.928121] which lock already depends on the new lock.
[ 8683.928121]
[ 8683.928121]
[ 8683.928121] the existing dependency chain (in reverse order) is:
[ 8683.928121]
[ 8683.928121] -> #1 (_xmit_ETHER#2){+.-...}:
[ 8683.928121]        [<c015a561>] lock_acquire+0x71/0x85
[ 8683.928121]        [<c034da2d>] _raw_spin_lock+0x33/0x40
[ 8683.928121]        [<c0304e0c>] ip_send_reply+0xf2/0x1ce
[ 8683.928121]        [<c0317dbc>] tcp_v4_send_reset+0x153/0x16f
[ 8683.928121]        [<c0317f4a>] tcp_v4_do_rcv+0x172/0x194
[ 8683.928121]        [<c031929b>] tcp_v4_rcv+0x387/0x5a0
[ 8683.928121]        [<c03001d0>] ip_local_deliver_finish+0x13a/0x1e9
[ 8683.928121]        [<c0300645>] NF_HOOK.clone.11+0x46/0x4d
[ 8683.928121]        [<c030075b>] ip_local_deliver+0x41/0x45
[ 8683.928121]        [<c03005dd>] ip_rcv_finish+0x31a/0x33c
[ 8683.928121]        [<c0300645>] NF_HOOK.clone.11+0x46/0x4d
[ 8683.928121]        [<c0300960>] ip_rcv+0x201/0x23d
[ 8683.928121]        [<c02de91b>] __netif_receive_skb+0x329/0x378
[ 8683.928121]        [<c02deae8>] netif_receive_skb+0x4e/0x7d
[ 8683.928121]        [<e08d5ef3>] rtl8139_poll+0x243/0x33d [8139too]
[ 8683.928121]        [<c02df103>] net_rx_action+0x90/0x15d
[ 8683.928121]        [<c012b2b5>] __do_softirq+0x7b/0x118
[ 8683.928121]
[ 8683.928121] -> #0 (slock-AF_INET){+.-...}:
[ 8683.928121]        [<c0159f1b>] __lock_acquire+0x9a3/0xc27
[ 8683.928121]        [<c015a561>] lock_acquire+0x71/0x85
[ 8683.928121]        [<c034da2d>] _raw_spin_lock+0x33/0x40
[ 8683.928121]        [<e0fc73ec>] l2tp_xmit_skb+0x173/0x47e 
[l2tp_core]
[ 8683.928121]        [<e0fe31fb>] l2tp_eth_dev_xmit+0x1a/0x2f 
[l2tp_eth]
[ 8683.928121]        [<c02e01e7>] dev_hard_start_xmit+0x333/0x3f2
[ 8683.928121]        [<c02f064c>] sch_direct_xmit+0x55/0x119
[ 8683.928121]        [<c02e0528>] dev_queue_xmit+0x282/0x418
[ 8683.928121]        [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[ 8683.928121]        [<c031f524>] arp_xmit+0x22/0x24
[ 8683.928121]        [<c031f567>] arp_send+0x41/0x48
[ 8683.928121]        [<c031fa7d>] arp_process+0x289/0x491
[ 8683.928121]        [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[ 8683.928121]        [<c031f7a0>] arp_rcv+0xb1/0xc3
[ 8683.928121]        [<c02de91b>] __netif_receive_skb+0x329/0x378
[ 8683.928121]        [<c02de9d3>] process_backlog+0x69/0x130
[ 8683.928121]        [<c02df103>] net_rx_action+0x90/0x15d
[ 8683.928121]        [<c012b2b5>] __do_softirq+0x7b/0x118
[ 8683.928121]
[ 8683.928121] other info that might help us debug this:
[ 8683.928121]
[ 8683.928121]  Possible unsafe locking scenario:
[ 8683.928121]
[ 8683.928121]        CPU0                    CPU1
[ 8683.928121]        ----                    ----
[ 8683.928121]   lock(_xmit_ETHER#2);
[ 8683.928121]                                lock(slock-AF_INET);
[ 8683.928121]                                lock(_xmit_ETHER#2);
[ 8683.928121]   lock(slock-AF_INET);
[ 8683.928121]
[ 8683.928121]  *** DEADLOCK ***
[ 8683.928121]
[ 8683.928121] 3 locks held by swapper/0/0:
[ 8683.928121]  #0:  (rcu_read_lock){.+.+..}, at: [<c02dbc10>] 
rcu_lock_acquire+0x0/0x30
[ 8683.928121]  #1:  (rcu_read_lock_bh){.+....}, at: [<c02dbc10>] 
rcu_lock_acquire+0x0/0x30
[ 8683.928121]  #2:  (_xmit_ETHER#2){+.-...}, at: [<c02f062d>] 
sch_direct_xmit+0x36/0x119
[ 8683.928121]
[ 8683.928121] stack backtrace:
[ 8683.928121] Pid: 0, comm: swapper/0 Not tainted 3.4.1-build-0061 #14
[ 8683.928121] Call Trace:
[ 8683.928121]  [<c034bdd2>] ? printk+0x18/0x1a
[ 8683.928121]  [<c0158904>] print_circular_bug+0x1ac/0x1b6
[ 8683.928121]  [<c0159f1b>] __lock_acquire+0x9a3/0xc27
[ 8683.928121]  [<c015a561>] lock_acquire+0x71/0x85
[ 8683.928121]  [<e0fc73ec>] ? l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[ 8683.928121]  [<c034da2d>] _raw_spin_lock+0x33/0x40
[ 8683.928121]  [<e0fc73ec>] ? l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[ 8683.928121]  [<e0fc73ec>] l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[ 8683.928121]  [<e0fe31fb>] l2tp_eth_dev_xmit+0x1a/0x2f [l2tp_eth]
[ 8683.928121]  [<c02e01e7>] dev_hard_start_xmit+0x333/0x3f2
[ 8683.928121]  [<c02f064c>] sch_direct_xmit+0x55/0x119
[ 8683.928121]  [<c02e0528>] dev_queue_xmit+0x282/0x418
[ 8683.928121]  [<c02e02a6>] ? dev_hard_start_xmit+0x3f2/0x3f2
[ 8683.928121]  [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[ 8683.928121]  [<c031f524>] arp_xmit+0x22/0x24
[ 8683.928121]  [<c02e02a6>] ? dev_hard_start_xmit+0x3f2/0x3f2
[ 8683.928121]  [<c031f567>] arp_send+0x41/0x48
[ 8683.928121]  [<c031fa7d>] arp_process+0x289/0x491
[ 8683.928121]  [<c031f7f4>] ? __neigh_lookup.clone.20+0x42/0x42
[ 8683.928121]  [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[ 8683.928121]  [<c031f7a0>] arp_rcv+0xb1/0xc3
[ 8683.928121]  [<c031f7f4>] ? __neigh_lookup.clone.20+0x42/0x42
[ 8683.928121]  [<c02de91b>] __netif_receive_skb+0x329/0x378
[ 8683.928121]  [<c02de9d3>] process_backlog+0x69/0x130
[ 8683.928121]  [<c02df103>] net_rx_action+0x90/0x15d
[ 8683.928121]  [<c012b2b5>] __do_softirq+0x7b/0x118
[ 8683.928121]  [<c012b23a>] ? local_bh_enable+0xd/0xd
[ 8683.928121]  <IRQ>  [<c012b4d0>] ? irq_exit+0x41/0x91
[ 8683.928121]  [<c0103c6f>] ? do_IRQ+0x79/0x8d
[ 8683.928121]  [<c0157ea1>] ? trace_hardirqs_off_caller+0x2e/0x86
[ 8683.928121]  [<c034ef6e>] ? common_interrupt+0x2e/0x34
[ 8683.928121]  [<c0108a33>] ? default_idle+0x23/0x38
[ 8683.928121]  [<c01091a8>] ? cpu_idle+0x55/0x6f
[ 8683.928121]  [<c033df25>] ? rest_init+0xa1/0xa7
[ 8683.928121]  [<c033de84>] ? __read_lock_failed+0x14/0x14
[ 8683.928121]  [<c0498745>] ? start_kernel+0x303/0x30a
[ 8683.928121]  [<c0498209>] ? repair_env_string+0x51/0x51
[ 8683.928121]  [<c04980a8>] ? i386_start_kernel+0xa8/0xaf


[158595.436934]
[158595.437018] ======================================================
[158595.437111] [ INFO: possible circular locking dependency detected ]
[158595.437198] 3.4.0-build-0061 #12 Tainted: G        W
[158595.437281] -------------------------------------------------------
[158595.437365] swapper/0/0 is trying to acquire lock:
[158595.437447]  (slock-AF_INET){+.-...}, at: [<f86453ec>] 
l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[158595.437613]
[158595.437613] but task is already holding lock:
[158595.437763]  (_xmit_ETHER#2){+.-...}, at: [<c02f09b9>] 
sch_direct_xmit+0x36/0x119
[158595.437837]
[158595.437837] which lock already depends on the new lock.
[158595.437837]
[158595.437837]
[158595.437837] the existing dependency chain (in reverse order) is:
[158595.437837]
[158595.437837] -> #1 (_xmit_ETHER#2){+.-...}:
[158595.437837]        [<c015a6d1>] lock_acquire+0x71/0x85
[158595.437837]        [<c034de94>] _raw_spin_lock_irqsave+0x40/0x50
[158595.437837]        [<c017c1f2>] get_page_from_freelist+0x227/0x398
[158595.437837]        [<c017c5a7>] __alloc_pages_nodemask+0xef/0x5f9
[158595.437837]        [<c019c34f>] alloc_slab_page+0x1d/0x21
[158595.437837]        [<c019c39f>] new_slab+0x4c/0x164
[158595.437837]        [<c019d259>] 
__slab_alloc.clone.59.clone.64+0x247/0x2de
[158595.437837]        [<c019dd21>] __kmalloc_track_caller+0x55/0xa4
[158595.437837]        [<c02d56fb>] __alloc_skb+0x51/0x100
[158595.437837]        [<c02d2cfa>] sock_alloc_send_pskb+0x9e/0x263
[158595.437837]        [<c02d2ed7>] sock_alloc_send_skb+0x18/0x1d
[158595.437837]        [<c0303e04>] 
__ip_append_data.clone.52+0x302/0x6dc
[158595.437837]        [<c030494c>] ip_append_data+0x80/0x88
[158595.437837]        [<c03209dd>] icmp_push_reply+0x5c/0x101
[158595.437837]        [<c0321555>] icmp_send+0x31d/0x342
[158595.437837]        [<f862b05c>] send_unreach+0x19/0x1b [ipt_REJECT]
[158595.437837]        [<f862b0f5>] reject_tg+0x53/0x2de [ipt_REJECT]
[158595.437837]        [<c033359a>] ipt_do_table+0x3ad/0x410
[158595.437837]        [<f856c0c4>] iptable_filter_hook+0x56/0x5e 
[iptable_filter]
[158595.437837]        [<c02f9941>] nf_iterate+0x36/0x5c
[158595.437837]        [<c02f99bf>] nf_hook_slow+0x58/0xf1
[158595.437837]        [<c0301f33>] ip_forward+0x295/0x2a2
[158595.437837]        [<c0300969>] ip_rcv_finish+0x31a/0x33c
[158595.437837]        [<c03009d1>] NF_HOOK.clone.11+0x46/0x4d
[158595.437837]        [<c0300cec>] ip_rcv+0x201/0x23d
[158595.437837]        [<c02deca7>] __netif_receive_skb+0x329/0x378
[158595.437837]        [<c02dee74>] netif_receive_skb+0x4e/0x7d
[158595.437837]        [<c02def60>] napi_skb_finish+0x1e/0x34
[158595.437837]        [<c02df389>] napi_gro_receive+0x20/0x24
[158595.437837]        [<f850e213>] rtl8169_poll+0x2e6/0x52c [r8169]
[158595.437837]        [<c02df48f>] net_rx_action+0x90/0x15d
[158595.437837]        [<c012b42d>] __do_softirq+0x7b/0x118
[158595.437837]
[158595.437837] -> #0 (slock-AF_INET){+.-...}:
[158595.437837]        [<c015a08b>] __lock_acquire+0x9a3/0xc27
[158595.437837]        [<c015a6d1>] lock_acquire+0x71/0x85
[158595.437837]        [<c034ddad>] _raw_spin_lock+0x33/0x40
[158595.437837]        [<f86453ec>] l2tp_xmit_skb+0x173/0x47e 
[l2tp_core]
[158595.437837]        [<f86591fb>] l2tp_eth_dev_xmit+0x1a/0x2f 
[l2tp_eth]
[158595.437837]        [<c02e0573>] dev_hard_start_xmit+0x333/0x3f2
[158595.437837]        [<c02f09d8>] sch_direct_xmit+0x55/0x119
[158595.437837]        [<c02e08b4>] dev_queue_xmit+0x282/0x418
[158595.437837]        [<c031f887>] NF_HOOK.clone.19+0x45/0x4c
[158595.437837]        [<c031f8b0>] arp_xmit+0x22/0x24
[158595.437837]        [<c031f8f3>] arp_send+0x41/0x48
[158595.437837]        [<c031fe09>] arp_process+0x289/0x491
[158595.437837]        [<c031f887>] NF_HOOK.clone.19+0x45/0x4c
[158595.437837]        [<c031fb2c>] arp_rcv+0xb1/0xc3
[158595.437837]        [<c02deca7>] __netif_receive_skb+0x329/0x378
[158595.437837]        [<c02ded5f>] process_backlog+0x69/0x130
[158595.437837]        [<c02df48f>] net_rx_action+0x90/0x15d
[158595.437837]        [<c012b42d>] __do_softirq+0x7b/0x118
[158595.437837]
[158595.437837] other info that might help us debug this:
[158595.437837]
[158595.437837]  Possible unsafe locking scenario:
[158595.437837]
[158595.437837]        CPU0                    CPU1
[158595.437837]        ----                    ----
[158595.437837]   lock(_xmit_ETHER#2);
[158595.437837]                                lock(slock-AF_INET);
[158595.437837]                                lock(_xmit_ETHER#2);
[158595.437837]   lock(slock-AF_INET);
[158595.437837]
[158595.437837]  *** DEADLOCK ***
[158595.437837]
[158595.437837] 3 locks held by swapper/0/0:
[158595.437837]  #0:  (rcu_read_lock){.+.+..}, at: [<c02dbf9c>] 
rcu_lock_acquire+0x0/0x30
[158595.437837]  #1:  (rcu_read_lock_bh){.+....}, at: [<c02dbf9c>] 
rcu_lock_acquire+0x0/0x30
[158595.437837]  #2:  (_xmit_ETHER#2){+.-...}, at: [<c02f09b9>] 
sch_direct_xmit+0x36/0x119
[158595.437837]
[158595.437837] stack backtrace:
[158595.437837] Pid: 0, comm: swapper/0 Tainted: G        W    
3.4.0-build-0061 #12
[158595.437837] Call Trace:
[158595.437837]  [<c034c156>] ? printk+0x18/0x1a
[158595.437837]  [<c0158a74>] print_circular_bug+0x1ac/0x1b6
[158595.437837]  [<c015a08b>] __lock_acquire+0x9a3/0xc27
[158595.437837]  [<c015a6d1>] lock_acquire+0x71/0x85
[158595.437837]  [<f86453ec>] ? l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[158595.437837]  [<c034ddad>] _raw_spin_lock+0x33/0x40
[158595.437837]  [<f86453ec>] ? l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[158595.437837]  [<f86453ec>] l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[158595.437837]  [<f86591fb>] l2tp_eth_dev_xmit+0x1a/0x2f [l2tp_eth]
[158595.437837]  [<c02e0573>] dev_hard_start_xmit+0x333/0x3f2
[158595.437837]  [<c02f09d8>] sch_direct_xmit+0x55/0x119
[158595.437837]  [<c02e08b4>] dev_queue_xmit+0x282/0x418
[158595.437837]  [<c02e0632>] ? dev_hard_start_xmit+0x3f2/0x3f2
[158595.437837]  [<c031f887>] NF_HOOK.clone.19+0x45/0x4c
[158595.437837]  [<c031f8b0>] arp_xmit+0x22/0x24
[158595.437837]  [<c02e0632>] ? dev_hard_start_xmit+0x3f2/0x3f2
[158595.437837]  [<c031f8f3>] arp_send+0x41/0x48
[158595.437837]  [<c031fe09>] arp_process+0x289/0x491
[158595.437837]  [<c031fb80>] ? __neigh_lookup.clone.20+0x42/0x42
[158595.437837]  [<c031f887>] NF_HOOK.clone.19+0x45/0x4c
[158595.437837]  [<c031fb2c>] arp_rcv+0xb1/0xc3
[158595.437837]  [<c031fb80>] ? __neigh_lookup.clone.20+0x42/0x42
[158595.437837]  [<c02deca7>] __netif_receive_skb+0x329/0x378
[158595.437837]  [<c02ded5f>] process_backlog+0x69/0x130
[158595.437837]  [<c02df48f>] net_rx_action+0x90/0x15d
[158595.437837]  [<c012b42d>] __do_softirq+0x7b/0x118
[158595.437837]  [<c013236e>] ? do_send_specific+0xb/0x8f
[158595.437837]  [<c012b3b2>] ? local_bh_enable+0xd/0xd
[158595.437837]  <IRQ>  [<c012b648>] ? irq_exit+0x41/0x91
[158595.437837]  [<c0103c73>] ? do_IRQ+0x79/0x8d
[158595.437837]  [<c0158011>] ? trace_hardirqs_off_caller+0x2e/0x86
[158595.437837]  [<c034f2ee>] ? common_interrupt+0x2e/0x34
[158595.437837]  [<c015007b>] ? ktime_get_ts+0x8f/0x9b
[158595.437837]  [<c0108a0a>] ? mwait_idle+0x50/0x5a
[158595.437837]  [<c01091ac>] ? cpu_idle+0x55/0x6f
[158595.437837]  [<c033e2b1>] ? rest_init+0xa1/0xa7
[158595.437837]  [<c033e210>] ? __read_lock_failed+0x14/0x14
[158595.437837]  [<c049874f>] ? start_kernel+0x30d/0x314
[158595.437837]  [<c0498209>] ? repair_env_string+0x51/0x51
[158595.437837]  [<c04980a8>] ? i386_start_kernel+0xa8/0xaf

[63546.808787]
[63546.809025] ======================================================
[63546.809259] [ INFO: possible circular locking dependency detected ]
[63546.809494] 3.4.1-build-0061 #14 Not tainted
[63546.809685] -------------------------------------------------------
[63546.809685] swapper/0/0 is trying to acquire lock:
[63546.809685]  (slock-AF_INET){+.-...}, at: [<f8c593ec>] 
l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[63546.809685]
[63546.809685] but task is already holding lock:
[63546.809685]  (_xmit_ETHER#2){+.-...}, at: [<c02f062d>] 
sch_direct_xmit+0x36/0x119
[63546.809685]
[63546.809685] which lock already depends on the new lock.
[63546.809685]
[63546.809685]
[63546.809685] the existing dependency chain (in reverse order) is:
[63546.809685]
[63546.809685] -> #1 (_xmit_ETHER#2){+.-...}:
[63546.809685]        [<c015a561>] lock_acquire+0x71/0x85
[63546.809685]        [<c034dc06>] _raw_spin_lock_bh+0x38/0x45
[63546.809685]        [<c02a4e8a>] ppp_push+0x59/0x4b3
[63546.809685]        [<c02a66b9>] ppp_xmit_process+0x41b/0x4be
[63546.809685]        [<c02a69b9>] ppp_write+0x90/0xa1
[63546.809685]        [<c01a2e8c>] vfs_write+0x7e/0xab
[63546.809685]        [<c01a2ffc>] sys_write+0x3d/0x5e
[63546.809685]        [<c034e191>] syscall_call+0x7/0xb
[63546.809685]
[63546.809685] -> #0 (slock-AF_INET){+.-...}:
[63546.809685]        [<c0159f1b>] __lock_acquire+0x9a3/0xc27
[63546.809685]        [<c015a561>] lock_acquire+0x71/0x85
[63546.809685]        [<c034da2d>] _raw_spin_lock+0x33/0x40
[63546.809685]        [<f8c593ec>] l2tp_xmit_skb+0x173/0x47e 
[l2tp_core]
[63546.809685]        [<f8c751fb>] l2tp_eth_dev_xmit+0x1a/0x2f 
[l2tp_eth]
[63546.809685]        [<c02e01e7>] dev_hard_start_xmit+0x333/0x3f2
[63546.809685]        [<c02f064c>] sch_direct_xmit+0x55/0x119
[63546.809685]        [<c02e0528>] dev_queue_xmit+0x282/0x418
[63546.809685]        [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[63546.809685]        [<c031f524>] arp_xmit+0x22/0x24
[63546.809685]        [<c031f567>] arp_send+0x41/0x48
[63546.809685]        [<c031fa7d>] arp_process+0x289/0x491
[63546.809685]        [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[63546.809685]        [<c031f7a0>] arp_rcv+0xb1/0xc3
[63546.809685]        [<c02de91b>] __netif_receive_skb+0x329/0x378
[63546.809685]        [<c02de9d3>] process_backlog+0x69/0x130
[63546.809685]        [<c02df103>] net_rx_action+0x90/0x15d
[63546.809685]        [<c012b2b5>] __do_softirq+0x7b/0x118
[63546.809685]
[63546.809685] other info that might help us debug this:
[63546.809685]
[63546.809685]  Possible unsafe locking scenario:
[63546.809685]
[63546.809685]        CPU0                    CPU1
[63546.809685]        ----                    ----
[63546.809685]   lock(_xmit_ETHER#2);
[63546.809685]                                lock(slock-AF_INET);
[63546.809685]                                lock(_xmit_ETHER#2);
[63546.809685]   lock(slock-AF_INET);
[63546.809685]
[63546.809685]  *** DEADLOCK ***
[63546.809685]
[63546.809685] 3 locks held by swapper/0/0:
[63546.809685]  #0:  (rcu_read_lock){.+.+..}, at: [<c02dbc10>] 
rcu_lock_acquire+0x0/0x30
[63546.809685]  #1:  (rcu_read_lock_bh){.+....}, at: [<c02dbc10>] 
rcu_lock_acquire+0x0/0x30
[63546.809685]  #2:  (_xmit_ETHER#2){+.-...}, at: [<c02f062d>] 
sch_direct_xmit+0x36/0x119
[63546.809685]
[63546.809685] stack backtrace:
[63546.809685] Pid: 0, comm: swapper/0 Not tainted 3.4.1-build-0061 #14
[63546.809685] Call Trace:
[63546.809685]  [<c034bdd2>] ? printk+0x18/0x1a
[63546.809685]  [<c0158904>] print_circular_bug+0x1ac/0x1b6
[63546.809685]  [<c0159f1b>] __lock_acquire+0x9a3/0xc27
[63546.809685]  [<c015a561>] lock_acquire+0x71/0x85
[63546.809685]  [<f8c593ec>] ? l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[63546.809685]  [<c034da2d>] _raw_spin_lock+0x33/0x40
[63546.809685]  [<f8c593ec>] ? l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[63546.809685]  [<f8c593ec>] l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[63546.809685]  [<f8c751fb>] l2tp_eth_dev_xmit+0x1a/0x2f [l2tp_eth]
[63546.809685]  [<c02e01e7>] dev_hard_start_xmit+0x333/0x3f2
[63546.809685]  [<c02f064c>] sch_direct_xmit+0x55/0x119
[63546.809685]  [<c02e0528>] dev_queue_xmit+0x282/0x418
[63546.809685]  [<c02e02a6>] ? dev_hard_start_xmit+0x3f2/0x3f2
[63546.809685]  [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[63546.809685]  [<c031f524>] arp_xmit+0x22/0x24
[63546.809685]  [<c02e02a6>] ? dev_hard_start_xmit+0x3f2/0x3f2
[63546.809685]  [<c031f567>] arp_send+0x41/0x48
[63546.809685]  [<c031fa7d>] arp_process+0x289/0x491
[63546.809685]  [<c031f7f4>] ? __neigh_lookup.clone.20+0x42/0x42
[63546.809685]  [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[63546.809685]  [<c031f7a0>] arp_rcv+0xb1/0xc3
[63546.809685]  [<c031f7f4>] ? __neigh_lookup.clone.20+0x42/0x42
[63546.809685]  [<c02de91b>] __netif_receive_skb+0x329/0x378
[63546.809685]  [<c02de9d3>] process_backlog+0x69/0x130
[63546.809685]  [<c02df103>] net_rx_action+0x90/0x15d
[63546.809685]  [<c012b2b5>] __do_softirq+0x7b/0x118
[63546.809685]  [<c012b23a>] ? local_bh_enable+0xd/0xd
[63546.809685]  [<c012b23a>] ? local_bh_enable+0xd/0xd
[63546.809685]  <IRQ>  [<c012b4d0>] ? irq_exit+0x41/0x91
[63546.809685]  [<c0103c6f>] ? do_IRQ+0x79/0x8d
[63546.809685]  [<c0157ea1>] ? trace_hardirqs_off_caller+0x2e/0x86
[63546.809685]  [<c034ef6e>] ? common_interrupt+0x2e/0x34
[63546.809685]  [<c015007b>] ? do_gettimeofday+0x20/0x29
[63546.809685]  [<c0108a06>] ? mwait_idle+0x50/0x5a
[63546.809685]  [<c01091a8>] ? cpu_idle+0x55/0x6f
[63546.809685]  [<c033df25>] ? rest_init+0xa1/0xa7
[63546.809685]  [<c033de84>] ? __read_lock_failed+0x14/0x14
[63546.809685]  [<c0498745>] ? start_kernel+0x303/0x30a
[63546.809685]  [<c0498209>] ? repair_env_string+0x51/0x51
[63546.809685]  [<c04980a8>] ? i386_start_kernel+0xa8/0xaf

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
