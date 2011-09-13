From: Murali raja Muniraju <murali.rajam@gmail.com>
Subject: Query on a lockdep issue in neigh_lookup
Date: Tue, 13 Sep 2011 16:11:14 -0700
Message-ID: <CAByGWUHkt=6AjW_GFsGd1EnbMC=pjhtxRu8ez0sw6rZNvA_nxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60537 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932988Ab1IMXLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 19:11:16 -0400
Received: by eyx24 with SMTP id 24so714497eyx.19
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 16:11:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
   I see a potential deadlock situation on the kernel 2.6.34. Has this
been fixed in the later version of the kernel.

I see that one after holding the neigh_lookup, one can acquire the
lock for rt_hash_locks

But there is a situation while freed skb's in dst_release while
holding the rt_hash_locks, neigh_lookup can be called which tries to
acquire its lock.

This seems to be a deadlock candidate.

Thanks,
Murali

Below if the scenario found by lockdep on a debug kernel during the
kernel bootup.

    [   92.245713] =======================================================
 [   92.246640] [ INFO: possible circular locking dependency detected ]
 [   92.246640] 2.6.34-dbg-2011082906 #1
 [   92.246640] -------------------------------------------------------
 [   92.246640] swapper/0 is trying to acquire lock:
 [   92.246640]  (&tbl->lock){++--..}, at: [<ffffffff81553a22>]
neigh_lookup+0x42/0xd0
 [   92.246640]
 [   92.246640] but task is already holding lock:
 [   92.246640]  (&(&rt_hash_locks[i])->rlock){+.-...}, at:
[<ffffffff815798e0>] rt_intern_hash+0xd0/0x880
 [   92.246640]
 [   92.246640] which lock already depends on the new lock.
 [   92.246640]
 [   92.246640]
 [   92.246640] the existing dependency chain (in reverse order) is:
 [   92.246640]
 [   92.246640] -> #2 (&(&rt_hash_locks[i])->rlock){+.-...}:
 [   92.246640]        [<ffffffff810e7700>] __lock_acquire+0xe30/0x1190
 [   92.246640]        [<ffffffff810e7af3>] lock_acquire+0x93/0x120
 [   92.246640]        [<ffffffff815ed266>] _raw_spin_lock_bh+0x36/0x50
 [   92.246640]        [<ffffffff81576a26>] rt_dst_release+0x66/0xc0
 [   92.246640]        [<ffffffff8155194c>] dst_release+0x5c/0x90
 [   92.246640]        [<ffffffff8153aef5>] skb_release_head_state+0x95/0xd0
 [   92.246640]        [<ffffffff8153ad06>] __kfree_skb+0x16/0xa0
 [   92.246640]        [<ffffffff8153ae12>] kfree_skb+0x42/0x90
 [   92.246640]        [<ffffffff81552fae>] __neigh_event_send+0x11e/0x1d0
 [   92.246640]        [<ffffffff81553193>] neigh_resolve_output+0x133/0x2f0
 [   92.246640]        [<ffffffff81584742>] ip_output+0x2c2/0x3a0
 [   92.246640]        [<ffffffff8158291d>] ip_local_out+0xad/0xc0
 [   92.246640]        [<ffffffff81582cc0>] ip_send_reply+0x290/0x340
 [   92.246640]        [<ffffffff815a3ba1>] tcp_v4_send_reset+0x1a1/0x310
 [   92.246640]        [<ffffffff815a7b04>] tcp_v4_rcv+0x314/0x9b0
 [   92.246640]        [<ffffffff8157e344>] ip_local_deliver_finish+0xf4/0x200
 [   92.246640]        [<ffffffff8157e4e0>] ip_local_deliver+0x90/0xa0
 [   92.246640]        [<ffffffff8157dbf1>] ip_rcv_finish+0x111/0x460
 [   92.246640]        [<ffffffff8157e17d>] ip_rcv+0x23d/0x310
 [   92.246640]        [<ffffffff81549144>] __netif_receive_skb+0x2d4/0x570
 [   92.246640]        [<ffffffff81549620>] netif_receive_skb+0xb0/0xc0
 [   92.246640]        [<ffffffff81549d28>] napi_gro_receive+0x148/0x180
 [   92.246640]        [<ffffffffa0066aba>]
e1000_clean_rx_irq+0x2ba/0x470 [e1000e]
 [   92.246640]        [<ffffffffa006567f>] e1000_clean+0x7f/0x280 [e1000e]
 [   92.246640]        [<ffffffff8154b200>] net_rx_action+0x170/0x4f0
 [   92.246640]        [<ffffffff810a8ec7>] __do_softirq+0x127/0x2b0
 [   92.246640]        [<ffffffff8104514c>] call_softirq+0x1c/0x50
 [   92.246640]        [<ffffffff810472dd>] do_softirq+0x7d/0xb0
 [   92.246640]        [<ffffffff810a8cd5>] irq_exit+0xa5/0xb0
 [   92.246640]        [<ffffffff815f5555>] do_IRQ+0x75/0xf0
 [   92.246640]        [<ffffffff815edb13>] ret_from_intr+0x0/0xf
 [   92.510442]        [<ffffffff815ed7d3>] _raw_spin_unlock+0x23/0x40
 [   92.510442]        [<ffffffff811b1d03>] sys_close+0xc3/0x160
 [   92.510442]        [<ffffffff8107d0e7>] sysenter_dispatch+0x7/0x2c
 [   92.510442]
 [   92.510442] -> #1 (&n->lock){++--..}:
 [   92.510442]        [<ffffffff810e7700>] __lock_acquire+0xe30/0x1190
 [   92.510442]        [<ffffffff810e7af3>] lock_acquire+0x93/0x120
 [   92.510442]        [<ffffffff815ed3b1>] _raw_write_lock+0x31/0x40
 [   92.510442]        [<ffffffff81556b90>] neigh_periodic_work+0xa0/0x4a0
 [   92.510442]        [<ffffffff810c274c>] worker_thread+0x1cc/0x330
 [   92.510442]        [<ffffffff810c7de6>] kthread+0x96/0xa0
 [   92.510442]        [<ffffffff81045054>] kernel_thread_helper+0x4/0x10
 [   92.510442]
 [   92.510442] -> #0 (&tbl->lock){++--..}:
 [   92.510442]        [<ffffffff810e7a5e>] __lock_acquire+0x118e/0x1190
 [   92.510442]        [<ffffffff810e7af3>] lock_acquire+0x93/0x120
 [   92.510442]        [<ffffffff815ed569>] _raw_read_lock_bh+0x39/0x50
 [   92.510442]        [<ffffffff81553a22>] neigh_lookup+0x42/0xd0
 [   92.510442]        [<ffffffff815b1ce9>] arp_bind_neighbour+0x79/0xb0
 [   92.510442]        [<ffffffff815799a2>] rt_intern_hash+0x192/0x880
 [   92.510442]        [<ffffffff8157bb3c>] ip_route_output_slow+0x47c/0xa50
 [   92.510442]        [<ffffffff8157c53f>] __ip_route_output_key+0x5f/0x250
 [   92.510442]        [<ffffffff8157c7c1>] ip_route_output_key+0x21/0x70
 [   92.510442]        [<ffffffff815b3a28>] arp_process+0x7f8/0x970
 [   92.510442]        [<ffffffff815b3cb1>] arp_rcv+0x111/0x140
 [   92.510442]        [<ffffffff81549144>] __netif_receive_skb+0x2d4/0x570
 [   92.510442]        [<ffffffff81549620>] netif_receive_skb+0xb0/0xc0
 [   92.510442]        [<ffffffff81549d28>] napi_gro_receive+0x148/0x180
 [   92.510442]        [<ffffffffa0066aba>]
e1000_clean_rx_irq+0x2ba/0x470 [e1000e]
 [   92.510442]        [<ffffffffa006567f>] e1000_clean+0x7f/0x280 [e1000e]
 [   92.510442]        [<ffffffff8154b200>] net_rx_action+0x170/0x4f0
 [   92.510442]        [<ffffffff810a8ec7>] __do_softirq+0x127/0x2b0
 [   92.510442]        [<ffffffff8104514c>] call_softirq+0x1c/0x50
 [   92.510442]        [<ffffffff810472dd>] do_softirq+0x7d/0xb0
 [   92.510442]        [<ffffffff810a8cd5>] irq_exit+0xa5/0xb0
 [   92.510442]        [<ffffffff815f5555>] do_IRQ+0x75/0xf0
 [   92.510442]        [<ffffffff815edb13>] ret_from_intr+0x0/0xf
 [   92.510442]        [<ffffffff81043125>] cpu_idle+0x95/0x150
 [   92.510442]        [<ffffffff81b924e1>] start_secondary+0x1d1/0x1d5
 [   92.510442]
 [   92.510442] other info that might help us debug this:
 [   92.510442]
 [   92.742983] 4 locks held by swapper/0:
 [   92.742983]  #0:  (rcu_read_lock){.+.+.+}, at:
[<ffffffff8154b17e>] net_rx_action+0xee/0x4f0
 [   92.742983]  #1:  (&(&napi->poll_lock)->rlock){+.-...}, at:
[<ffffffff8154b1d6>] net_rx_action+0x146/0x4f0
 [   92.742983]  #2:  (rcu_read_lock){.+.+.+}, at:
[<ffffffff81548ff0>] __netif_receive_skb+0x180/0x570
 [   92.742983]  #3:  (&(&rt_hash_locks[i])->rlock){+.-...}, at:
[<ffffffff815798e0>] rt_intern_hash+0xd0/0x880
 [   92.742983]
 [   92.742983] stack backtrace:
 [   92.742983] Pid: 0, comm: swapper Not tainted 2.6.34-dbg-2011082906 #1
 [   92.742983] Call Trace:
 [   92.742983]  <IRQ>  [<ffffffff810e40b9>] print_circular_bug+0xe9/0xf0
 [   92.742983]  [<ffffffff810e7a5e>] __lock_acquire+0x118e/0x1190
 [   92.742983]  [<ffffffff810e7af3>] lock_acquire+0x93/0x120
 [   92.742983]  [<ffffffff81553a22>] ? neigh_lookup+0x42/0xd0
 [   92.742983]  [<ffffffff815ed569>] _raw_read_lock_bh+0x39/0x50
 [   92.742983]  [<ffffffff81553a22>] ? neigh_lookup+0x42/0xd0
 [   92.742983]  [<ffffffff81553a22>] neigh_lookup+0x42/0xd0
 [   92.742983]  [<ffffffff815b1ce9>] arp_bind_neighbour+0x79/0xb0
 [   92.742983]  [<ffffffff815798e0>] ? rt_intern_hash+0xd0/0x880
 [   92.742983]  [<ffffffff815799a2>] rt_intern_hash+0x192/0x880
 [   92.742983]  [<ffffffff8157bb3c>] ip_route_output_slow+0x47c/0xa50
 [   92.742983]  [<ffffffff8157b961>] ? ip_route_output_slow+0x2a1/0xa50
 [   92.742983]  [<ffffffff8157c53f>] __ip_route_output_key+0x5f/0x250
 [   92.742983]  [<ffffffff8157c560>] ? __ip_route_output_key+0x80/0x250
 [   92.742983]  [<ffffffff8157c7c1>] ip_route_output_key+0x21/0x70
 [   92.742983]  [<ffffffff815b3a28>] arp_process+0x7f8/0x970
 [   92.742983]  [<ffffffff815b3230>] ? arp_process+0x0/0x970
 [   92.742983]  [<ffffffff815b3cb1>] arp_rcv+0x111/0x140
 [   92.742983]  [<ffffffff81549144>] __netif_receive_skb+0x2d4/0x570
 [   92.742983]  [<ffffffff81548ff0>] ? __netif_receive_skb+0x180/0x570
 [   92.742983]  [<ffffffff811ab25d>] ? __kmalloc_node_track_caller+0x7d/0x100
 [   92.742983]  [<ffffffff811a88d0>] ? kmem_cache_alloc_node+0x0/0x280
 [   92.742983]  [<ffffffff81549620>] netif_receive_skb+0xb0/0xc0
 [   92.742983]  [<ffffffff81549570>] ? netif_receive_skb+0x0/0xc0
 [   92.742983]  [<ffffffff8153981f>] ? __alloc_skb+0x8f/0x1a0
 [   92.742983]  [<ffffffff81549d28>] napi_gro_receive+0x148/0x180
 [   92.742983]  [<ffffffffa0066aba>] e1000_clean_rx_irq+0x2ba/0x470 [e1000e]
 [   92.742983]  [<ffffffffa006567f>] e1000_clean+0x7f/0x280 [e1000e]
 [   92.742983]  [<ffffffff8154b200>] net_rx_action+0x170/0x4f0
 [   92.742983]  [<ffffffff8154b17e>] ? net_rx_action+0xee/0x4f0
 [   92.742983]  [<ffffffff810a8e71>] ? __do_softirq+0xd1/0x2b0
 [   92.742983]  [<ffffffff810a8ec7>] __do_softirq+0x127/0x2b0
 [   92.742983]  [<ffffffff8104514c>] call_softirq+0x1c/0x50
 [   92.742983]  [<ffffffff810472dd>] do_softirq+0x7d/0xb0
 [   92.742983]  [<ffffffff810a8cd5>] irq_exit+0xa5/0xb0
 [   92.742983]  [<ffffffff815f5555>] do_IRQ+0x75/0xf0
 [   93.005851]  [<ffffffff815edb13>] ret_from_intr+0x0/0xf
 [   93.005851]  <EOI>  [<ffffffff8104d737>] ? mwait_idle+0x77/0xd0
 [   93.005851]  [<ffffffff8104d72e>] ? mwait_idle+0x6e/0xd0
 [   93.005851]  [<ffffffff81043125>] cpu_idle+0x95/0x150
 [   93.005851]  [<ffffffff81b924e1>] start_secondary+0x1d1/0x1d5

-- 
__MURALI__
