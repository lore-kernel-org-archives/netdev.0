From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: kernel 3.4.0, pppoe NAS, possible circular locking
Date: Thu, 24 May 2012 11:44:39 +0300
Message-ID: <129d6bda29e08e61f8a219333357bc49@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:53659 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857Ab2EXIor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 04:44:47 -0400
Received: from webmail.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 2950C1A452B
	for <netdev@vger.kernel.org>; Thu, 24 May 2012 11:44:39 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, upgraded one of NAS servers and got this:

[  177.597130] ======================================================
[  177.597234] [ INFO: possible circular locking dependency detected ]
[  177.597339] 3.4.0-build-0061 #10 Not tainted
[  177.597438] -------------------------------------------------------
[  177.597543] swapper/0/0 is trying to acquire lock:
[  177.597642]  (_xmit_PPP#2){+.-...}, at: [<c02f09b9>] 
sch_direct_xmit+0x36/0x119
[  177.597892]
[  177.597892] but task is already holding lock:
[  177.597892]  (&(&sch->busylock)->rlock){+.-...}, at: [<c02e0808>] 
dev_queue_xmit+0x1d6/0x418
[  177.597892]
[  177.597892] which lock already depends on the new lock.
[  177.597892]
[  177.597892]
[  177.597892] the existing dependency chain (in reverse order) is:
[  177.597892]
[  177.597892] -> #3 (&(&sch->busylock)->rlock){+.-...}:
[  177.597892]        [<c015a6d1>] lock_acquire+0x71/0x85
[  177.597892]        [<c034de94>] _raw_spin_lock_irqsave+0x40/0x50
[  177.597892]        [<c017c1f2>] get_page_from_freelist+0x227/0x398
[  177.597892]        [<c017c5a7>] __alloc_pages_nodemask+0xef/0x5f9
[  177.597892]        [<c019c34f>] alloc_slab_page+0x1d/0x21
[  177.597892]        [<c019c39f>] new_slab+0x4c/0x164
[  177.597892]        [<c019d259>] 
__slab_alloc.clone.59.clone.64+0x247/0x2de
[  177.597892]        [<c019d6ee>] __kmalloc+0x55/0xa3
[  177.597892]        [<c02d70ce>] pskb_expand_head+0xbe/0x200
[  177.597892]        [<c02a8e91>] __pppoe_xmit+0xb0/0x145
[  177.597892]        [<c02a8f30>] pppoe_xmit+0xa/0xc
[  177.597892]        [<c02a6c71>] ppp_channel_push+0x3d/0x94
[  177.597892]        [<c02a6d72>] ppp_write+0x99/0xa1
[  177.597892]        [<c01a32b4>] vfs_write+0x7e/0xab
[  177.597892]        [<c01a3424>] sys_write+0x3d/0x5e
[  177.597892]        [<c034e511>] syscall_call+0x7/0xb
[  177.597892]
[  177.597892] -> #2 (&(&pch->downl)->rlock){+.-...}:
[  177.597892]        [<c015a6d1>] lock_acquire+0x71/0x85
[  177.597892]        [<c034df86>] _raw_spin_lock_bh+0x38/0x45
[  177.597892]        [<c02a523a>] ppp_push+0x59/0x4b3
[  177.597892]        [<c02a6a69>] ppp_xmit_process+0x41b/0x4be
[  177.597892]        [<c02a6d69>] ppp_write+0x90/0xa1
[  177.597892]        [<c01a32b4>] vfs_write+0x7e/0xab
[  177.597892]        [<c01a3424>] sys_write+0x3d/0x5e
[  177.597892]        [<c034e511>] syscall_call+0x7/0xb
[  177.597892]
[  177.597892] -> #1 (&(&ppp->wlock)->rlock){+.-...}:
[  177.597892]        [<c015a6d1>] lock_acquire+0x71/0x85
[  177.597892]        [<c034df86>] _raw_spin_lock_bh+0x38/0x45
[  177.597892]        [<c02a6667>] ppp_xmit_process+0x19/0x4be
[  177.597892]        [<c02a6c19>] ppp_start_xmit+0x10d/0x128
[  177.597892]        [<c02e0573>] dev_hard_start_xmit+0x333/0x3f2
[  177.597892]        [<c02f09d8>] sch_direct_xmit+0x55/0x119
[  177.597892]        [<c02e08b4>] dev_queue_xmit+0x282/0x418
[  177.597892]        [<c02e65c6>] neigh_direct_output+0xa/0xc
[  177.597892]        [<c03039e0>] ip_finish_output2+0x1e1/0x21c
[  177.597892]        [<c0303a50>] ip_finish_output+0x35/0x39
[  177.597892]        [<c03048c7>] ip_output+0x87/0x8c
[  177.597892]        [<c0301c9a>] ip_forward_finish+0x56/0x5a
[  177.597892]        [<c0301e9e>] ip_forward+0x200/0x2a2
[  177.597892]        [<c0300969>] ip_rcv_finish+0x31a/0x33c
[  177.597892]        [<c03009d1>] NF_HOOK.clone.11+0x46/0x4d
[  177.597892]        [<c0300cec>] ip_rcv+0x201/0x23d
[  177.597892]        [<c02deca7>] __netif_receive_skb+0x329/0x378
[  177.597892]        [<c02dee74>] netif_receive_skb+0x4e/0x7d
[  177.597892]        [<f846fef3>] rtl8139_poll+0x243/0x33d [8139too]
[  177.597892]        [<c02df48f>] net_rx_action+0x90/0x15d
[  177.597892]        [<c012b42d>] __do_softirq+0x7b/0x118
[  177.597892]
[  177.597892] -> #0 (_xmit_PPP#2){+.-...}:
[  177.597892]        [<c015a08b>] __lock_acquire+0x9a3/0xc27
[  177.597892]        [<c015a6d1>] lock_acquire+0x71/0x85
[  177.597892]        [<c034ddad>] _raw_spin_lock+0x33/0x40
[  177.597892]        [<c02f09b9>] sch_direct_xmit+0x36/0x119
[  177.597892]        [<c02e08b4>] dev_queue_xmit+0x282/0x418
[  177.597892]        [<c02e65c6>] neigh_direct_output+0xa/0xc
[  177.597892]        [<c03039e0>] ip_finish_output2+0x1e1/0x21c
[  177.597892]        [<c0303a50>] ip_finish_output+0x35/0x39
[  177.597892]        [<c03048c7>] ip_output+0x87/0x8c
[  177.597892]        [<c03030c6>] dst_output+0x15/0x18
[  177.597892]        [<c03042d7>] ip_local_out+0x17/0x1a
[  177.597892]        [<c0304f59>] ip_send_skb+0x12/0x5c
[  177.597892]        [<c0304fcd>] ip_push_pending_frames+0x2a/0x2e
[  177.597892]        [<c0320a7a>] icmp_push_reply+0xf9/0x101
[  177.597892]        [<c0320f1c>] icmp_reply+0x10e/0x12d
[  177.597892]        [<c0321050>] icmp_echo+0x59/0x5f
[  177.597892]        [<c032169f>] icmp_rcv+0xfd/0x11a
[  177.597892]        [<c030055c>] ip_local_deliver_finish+0x13a/0x1e9
[  177.597892]        [<c03009d1>] NF_HOOK.clone.11+0x46/0x4d
[  177.597892]        [<c0300ae7>] ip_local_deliver+0x41/0x45
[  177.597892]        [<c0300969>] ip_rcv_finish+0x31a/0x33c
[  177.597892]        [<c03009d1>] NF_HOOK.clone.11+0x46/0x4d
[  177.597892]        [<c0300cec>] ip_rcv+0x201/0x23d
[  177.597892]        [<c02deca7>] __netif_receive_skb+0x329/0x378
[  177.597892]        [<c02ded5f>] process_backlog+0x69/0x130
[  177.597892]        [<c02df48f>] net_rx_action+0x90/0x15d
[  177.597892]        [<c012b42d>] __do_softirq+0x7b/0x118
[  177.597892]
[  177.597892] other info that might help us debug this:
[  177.597892]
[  177.597892] Chain exists of:
[  177.597892]   _xmit_PPP#2 --> &(&pch->downl)->rlock --> 
&(&sch->busylock)->rlock
[  177.597892]
[  177.597892]  Possible unsafe locking scenario:
[  177.597892]
[  177.597892]        CPU0                    CPU1
[  177.597892]        ----                    ----
[  177.597892]   lock(&(&sch->busylock)->rlock);
[  177.597892]                                
lock(&(&pch->downl)->rlock);
[  177.597892]                                
lock(&(&sch->busylock)->rlock);
[  177.597892]   lock(_xmit_PPP#2);
[  177.597892]
[  177.597892]  *** DEADLOCK ***
[  177.597892]
[  177.597892] 6 locks held by swapper/0/0:
[  177.597892]  #0:  (rcu_read_lock){.+.+..}, at: [<c02dbf9c>] 
rcu_lock_acquire+0x0/0x30
[  177.597892]  #1:  (rcu_read_lock){.+.+..}, at: [<c0300453>] 
ip_local_deliver_finish+0x31/0x1e9
[  177.597892]  #2:  (slock-AF_INET){+.-...}, at: [<c0320c40>] 
icmp_xmit_lock.clone.19+0x1f/0x2f
[  177.597892]  #3:  (rcu_read_lock){.+.+..}, at: [<c0302fad>] 
rcu_read_lock+0x0/0x35
[  177.597892]  #4:  (rcu_read_lock_bh){.+....}, at: [<c02dbf9c>] 
rcu_lock_acquire+0x0/0x30
[  177.597892]  #5:  (&(&sch->busylock)->rlock){+.-...}, at: 
[<c02e0808>] dev_queue_xmit+0x1d6/0x418
[  177.597892]
[  177.597892] stack backtrace:
[  177.597892] Pid: 0, comm: swapper/0 Not tainted 3.4.0-build-0061 #10
[  177.597892] Call Trace:
[  177.597892]  [<c034c156>] ? printk+0x18/0x1a
[  177.597892]  [<c0158a74>] print_circular_bug+0x1ac/0x1b6
[  177.597892]  [<c015a08b>] __lock_acquire+0x9a3/0xc27
[  177.597892]  [<c0159256>] ? check_irq_usage+0x76/0x86
[  177.597892]  [<c015a6d1>] lock_acquire+0x71/0x85
[  177.597892]  [<c02f09b9>] ? sch_direct_xmit+0x36/0x119
[  177.597892]  [<c034ddad>] _raw_spin_lock+0x33/0x40
[  177.597892]  [<c02f09b9>] ? sch_direct_xmit+0x36/0x119
[  177.597892]  [<c02f09b9>] sch_direct_xmit+0x36/0x119
[  177.597892]  [<c02e08b4>] dev_queue_xmit+0x282/0x418
[  177.597892]  [<c0302fad>] ? ip_generic_getfrag+0x6e/0x6e
[  177.597892]  [<c02e65c6>] neigh_direct_output+0xa/0xc
[  177.597892]  [<c03039e0>] ip_finish_output2+0x1e1/0x21c
[  177.597892]  [<c02fcce6>] ? ipv4_mtu+0x36/0x65
[  177.597892]  [<c0303a50>] ip_finish_output+0x35/0x39
[  177.597892]  [<c03048c7>] ip_output+0x87/0x8c
[  177.597892]  [<c0303a1b>] ? ip_finish_output2+0x21c/0x21c
[  177.597892]  [<c03030c6>] dst_output+0x15/0x18
[  177.597892]  [<c03042d7>] ip_local_out+0x17/0x1a
[  177.597892]  [<c0304f59>] ip_send_skb+0x12/0x5c
[  177.597892]  [<c0304fcd>] ip_push_pending_frames+0x2a/0x2e
[  177.597892]  [<c0320a7a>] icmp_push_reply+0xf9/0x101
[  177.597892]  [<c0320f1c>] icmp_reply+0x10e/0x12d
[  177.597892]  [<c0321050>] icmp_echo+0x59/0x5f
[  177.597892]  [<f85af28d>] ? nf_nat_fn+0x121/0x12d [iptable_nat]
[  177.597892]  [<c0320cdb>] ? skb_dst.clone.21+0x1e/0x44
[  177.597892]  [<c032169f>] icmp_rcv+0xfd/0x11a
[  177.597892]  [<c030055c>] ip_local_deliver_finish+0x13a/0x1e9
[  177.597892]  [<c0300453>] ? ip_local_deliver_finish+0x31/0x1e9
[  177.597892]  [<c0300422>] ? pskb_may_pull+0x30/0x30
[  177.597892]  [<c03009d1>] NF_HOOK.clone.11+0x46/0x4d
[  177.597892]  [<c0300422>] ? pskb_may_pull+0x30/0x30
[  177.597892]  [<c0300ae7>] ip_local_deliver+0x41/0x45
[  177.597892]  [<c0300422>] ? pskb_may_pull+0x30/0x30
[  177.597892]  [<c0300969>] ip_rcv_finish+0x31a/0x33c
[  177.597892]  [<c030064f>] ? skb_dst.clone.10+0x44/0x44
[  177.597892]  [<c03009d1>] NF_HOOK.clone.11+0x46/0x4d
[  177.597892]  [<c030064f>] ? skb_dst.clone.10+0x44/0x44
[  177.597892]  [<c0300cec>] ip_rcv+0x201/0x23d
[  177.597892]  [<c030064f>] ? skb_dst.clone.10+0x44/0x44
[  177.597892]  [<c02deca7>] __netif_receive_skb+0x329/0x378
[  177.597892]  [<c02ded5f>] process_backlog+0x69/0x130
[  177.597892]  [<c02df48f>] net_rx_action+0x90/0x15d
[  177.597892]  [<c012b42d>] __do_softirq+0x7b/0x118
[  177.597892]  [<c013236e>] ? do_send_specific+0xb/0x8f
[  177.597892]  [<c012b3b2>] ? local_bh_enable+0xd/0xd
[  177.597892]  <IRQ>  [<c012b648>] ? irq_exit+0x41/0x91
[  177.597892]  [<c0103c73>] ? do_IRQ+0x79/0x8d
[  177.597892]  [<c0158011>] ? trace_hardirqs_off_caller+0x2e/0x86
[  177.597892]  [<c034f2ee>] ? common_interrupt+0x2e/0x34
[  177.597892]  [<c015007b>] ? ktime_get_ts+0x8f/0x9b
[  177.597892]  [<c0108a0a>] ? mwait_idle+0x50/0x5a
[  177.597892]  [<c01091ac>] ? cpu_idle+0x55/0x6f
[  177.597892]  [<c033e2b1>] ? rest_init+0xa1/0xa7
[  177.597892]  [<c033e210>] ? __read_lock_failed+0x14/0x14
[  177.597892]  [<c049874f>] ? start_kernel+0x30d/0x314
[  177.597892]  [<c0498209>] ? repair_env_string+0x51/0x51
[  177.597892]  [<c04980a8>] ? i386_start_kernel+0xa8/0xaf

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
