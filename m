From: David Miller <davem@davemloft.net>
Subject: Re: RCU error in networking
Date: Thu, 29 Apr 2010 16:04:01 -0700 (PDT)
Message-ID: <20100429.160401.186323856.davem@davemloft.net>
References: <20100420.190127.66303903.davem@davemloft.net>
	<Pine.LNX.4.64.1004210915220.11040@hs20-bc2-1.build.redhat.com>
	<Pine.LNX.4.64.1004291811420.26080@hs20-bc2-1.build.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35623
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933005Ab0D3RSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:18:35 -0400
In-Reply-To: <Pine.LNX.4.64.1004291811420.26080@hs20-bc2-1.build.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Thu, 29 Apr 2010 18:14:11 -0400 (EDT)

> BTW. when I enabled lockdep, I got this (2.6.34-rc5; the machine is no 
> longer bridging, it has just a single interface):
> 

Fixed in Linus's tree for more than a week:

commit 05d17608a69b3ae653ea5c9857283bef3439c733
Author: David Howells <dhowells@redhat.com>
Date:   Tue Apr 20 00:25:58 2010 +0000

    net: Fix an RCU warning in dev_pick_tx()
    
    Fix the following RCU warning in dev_pick_tx():
    
    ===================================================
    [ INFO: suspicious rcu_dereference_check() usage. ]
    ---------------------------------------------------
    net/core/dev.c:1993 invoked rcu_dereference_check() without protection!
    
    other info that might help us debug this:
    
    rcu_scheduler_active = 1, debug_locks = 0
    2 locks held by swapper/0:
     #0:  (&idev->mc_ifc_timer){+.-...}, at: [<ffffffff81039e65>] run_timer_softirq+0x17b/0x278
     #1:  (rcu_read_lock_bh){.+....}, at: [<ffffffff812ea3eb>] dev_queue_xmit+0x14e/0x4dc
    
    stack backtrace:
    Pid: 0, comm: swapper Not tainted 2.6.34-rc5-cachefs #4
    Call Trace:
     <IRQ>  [<ffffffff810516c4>] lockdep_rcu_dereference+0xaa/0xb2
     [<ffffffff812ea4f6>] dev_queue_xmit+0x259/0x4dc
     [<ffffffff812ea3eb>] ? dev_queue_xmit+0x14e/0x4dc
     [<ffffffff81052324>] ? trace_hardirqs_on+0xd/0xf
     [<ffffffff81035362>] ? local_bh_enable_ip+0xbc/0xc1
     [<ffffffff812f0954>] neigh_resolve_output+0x24b/0x27c
     [<ffffffff8134f673>] ip6_output_finish+0x7c/0xb4
     [<ffffffff81350c34>] ip6_output2+0x256/0x261
     [<ffffffff81052324>] ? trace_hardirqs_on+0xd/0xf
     [<ffffffff813517fb>] ip6_output+0xbbc/0xbcb
     [<ffffffff8135bc5d>] ? fib6_force_start_gc+0x2b/0x2d
     [<ffffffff81368acb>] mld_sendpack+0x273/0x39d
     [<ffffffff81368858>] ? mld_sendpack+0x0/0x39d
     [<ffffffff81052099>] ? mark_held_locks+0x52/0x70
     [<ffffffff813692fc>] mld_ifc_timer_expire+0x24f/0x288
     [<ffffffff81039ed6>] run_timer_softirq+0x1ec/0x278
     [<ffffffff81039e65>] ? run_timer_softirq+0x17b/0x278
     [<ffffffff813690ad>] ? mld_ifc_timer_expire+0x0/0x288
     [<ffffffff81035531>] ? __do_softirq+0x69/0x140
     [<ffffffff8103556a>] __do_softirq+0xa2/0x140
     [<ffffffff81002e0c>] call_softirq+0x1c/0x28
     [<ffffffff81004b54>] do_softirq+0x38/0x80
     [<ffffffff81034f06>] irq_exit+0x45/0x47
     [<ffffffff810177c3>] smp_apic_timer_interrupt+0x88/0x96
     [<ffffffff810028d3>] apic_timer_interrupt+0x13/0x20
     <EOI>  [<ffffffff810488dd>] ? __atomic_notifier_call_chain+0x0/0x86
     [<ffffffff810096bf>] ? mwait_idle+0x6e/0x78
     [<ffffffff810096b6>] ? mwait_idle+0x65/0x78
     [<ffffffff810011cb>] cpu_idle+0x4d/0x83
     [<ffffffff81380b05>] rest_init+0xb9/0xc0
     [<ffffffff81380a4c>] ? rest_init+0x0/0xc0
     [<ffffffff8168dcf0>] start_kernel+0x392/0x39d
     [<ffffffff8168d2a3>] x86_64_start_reservations+0xb3/0xb7
     [<ffffffff8168d38b>] x86_64_start_kernel+0xe4/0xeb
    
    An rcu_dereference() should be an rcu_dereference_bh().
    
    Signed-off-by: David Howells <dhowells@redhat.com>
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 92584bf..f769098 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1990,7 +1990,7 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 				queue_index = skb_tx_hash(dev, skb);
 
 			if (sk) {
-				struct dst_entry *dst = rcu_dereference(sk->sk_dst_cache);
+				struct dst_entry *dst = rcu_dereference_bh(sk->sk_dst_cache);
 
 				if (dst && skb_dst(skb) == dst)
 					sk_tx_queue_set(sk, queue_index);
