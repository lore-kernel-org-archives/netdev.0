From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [BUG] Lockdep splat in usb network gadget
Date: Wed, 23 Jul 2014 15:17:39 +0800
Message-ID: <CAJFZqHys3KUxBBaV18Gb3h-R7tQQpZJyh92dR1tyNizgoT5=UQ@mail.gmail.com>
References: <alpine.DEB.2.10.1407181542290.24854@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	jeff.westfahl@ni.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:60773 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533AbaGWHRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 03:17:40 -0400
In-Reply-To: <alpine.DEB.2.10.1407181542290.24854@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit introduced this bug

commit a9232076374334ca2bc2a448dfde96d38a54349a
Author: Jeff Westfahl <jeff.westfahl@ni.com>
Date:   Thu May 29 09:49:41 2014 +0300

    usb: gadget: u_ether: synchronize with transmit when stopping queue

    When disconnecting, it's possible that another thread has already made it
    into eth_start_xmit before we call netif_stop_queue. This can lead to a
    crash as eth_start_xmit tries to use resources that gether_disconnect is
    freeing. Use netif_tx_lock/unlock around netif_stop_queue to ensure no
    threads are executing during the remainder of gether_disconnect.

    Signed-off-by: Jeff Westfahl <jeff.westfahl@ni.com>
    Tested-by: Jaeden Amero <jaeden.amero@ni.com>
    Signed-off-by: Felipe Balbi <balbi@ti.com>

diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 3d78a88..97b0277 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -1120,7 +1120,10 @@ void gether_disconnect(struct gether *link)

        DBG(dev, "%s\n", __func__);

+       netif_tx_lock(dev->net);
        netif_stop_queue(dev->net);
+       netif_tx_unlock(dev->net);
+
        netif_carrier_off(dev->net);

On Fri, Jul 18, 2014 at 10:04 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On a Intel E660/EG20T system I can observe the following lockdep splats:
>
> [   10.154920] =================================
> [   10.156026] [ INFO: inconsistent lock state ]
> [   10.156026] 3.16.0-rc5+ #13 Not tainted
> [   10.156026] ---------------------------------
> [   10.156026] inconsistent {IN-HARDIRQ-W} -> {HARDIRQ-ON-W} usage.
> [   10.156026] swapper/1/0 [HC0[0]:SC1[5]:HE1:SE0] takes:
> [   10.156026]  (_xmit_ETHER){?.-...}, at: [<80948b6a>] sch_direct_xmit+0x7a/0x250
> [   10.156026] {IN-HARDIRQ-W} state was registered at:
> [   10.156026]   [<804811f0>] __lock_acquire+0x800/0x17a0
> [   10.156026]   [<804828ba>] lock_acquire+0x6a/0xf0
> [   10.156026]   [<809ed477>] _raw_spin_lock+0x27/0x40
> [   10.156026]   [<8088d508>] gether_disconnect+0x68/0x280
> [   10.156026]   [<8088e777>] eem_set_alt+0x37/0xc0
> [   10.156026]   [<808847ce>] composite_setup+0x30e/0x1240
> [   10.156026]   [<8088b8ae>] pch_udc_isr+0xa6e/0xf50
> [   10.156026]   [<8048abe8>] handle_irq_event_percpu+0x38/0x1e0
> [   10.156026]   [<8048adc1>] handle_irq_event+0x31/0x50
> [   10.156026]   [<8048d94b>] handle_fasteoi_irq+0x6b/0x140
> [   10.156026]   [<804040a5>] handle_irq+0x65/0x80
> [   10.156026]   [<80403cfc>] do_IRQ+0x3c/0xc0
> [   10.156026]   [<809ee6ae>] common_interrupt+0x2e/0x34
> [   10.156026]   [<804668c5>] finish_task_switch+0x65/0xd0
> [   10.156026]   [<809e89df>] __schedule+0x20f/0x7d0
> [   10.156026]   [<809e94aa>] schedule_preempt_disabled+0x2a/0x70
> [   10.156026]   [<8047bf03>] cpu_startup_entry+0x143/0x410
> [   10.156026]   [<809e2e61>] rest_init+0xa1/0xb0
> [   10.156026]   [<80ce2a3b>] start_kernel+0x336/0x33b
> [   10.156026]   [<80ce22ab>] i386_start_kernel+0x79/0x7d
> [   10.156026] irq event stamp: 52070
> [   10.156026] hardirqs last  enabled at (52070): [<809375de>] neigh_resolve_output+0xee/0x2a0
> [   10.156026] hardirqs last disabled at (52069): [<809375a8>] neigh_resolve_output+0xb8/0x2a0
> [   10.156026] softirqs last  enabled at (52020): [<8044401f>] _local_bh_enable+0x1f/0x50
> [   10.156026] softirqs last disabled at (52021): [<80404036>] do_softirq_own_stack+0x26/0x30
> [   10.156026]
> [   10.156026] other info that might help us debug this:
> [   10.156026]  Possible unsafe locking scenario:
> [   10.156026]
> [   10.156026]        CPU0
> [   10.156026]        ----
> [   10.156026]   lock(_xmit_ETHER);
> [   10.156026]   <Interrupt>
> [   10.156026]     lock(_xmit_ETHER);
> [   10.156026]
> [   10.156026]  *** DEADLOCK ***
> [   10.156026]
> [   10.156026] 4 locks held by swapper/1/0:
> [   10.156026]  #0:  (((&idev->mc_ifc_timer))){+.-...}, at: [<8044b100>] call_timer_fn+0x0/0x190
> [   10.156026]  #1:  (rcu_read_lock){......}, at: [<a0577c40>] mld_sendpack+0x0/0x590 [ipv6]
> [   10.156026]  #2:  (rcu_read_lock_bh){......}, at: [<a055680c>] ip6_finish_output2+0x4c/0x7f0 [ipv6]
> [   10.156026]  #3:  (rcu_read_lock_bh){......}, at: [<8092e510>] __dev_queue_xmit+0x0/0x5f0
> [   10.156026]
> [   10.156026] stack backtrace:
> [   10.156026] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.16.0-rc5+ #13
> [   10.156026]  811dbb10 00000000 9e919d10 809e6785 9e8b8000 9e919d3c 809e561e 80b95511
> [   10.156026]  80b9545a 80b9543d 80b95450 80b95441 80b957e4 9e8b84e0 00000002 8047f7b0
> [   10.156026]  9e919d5c 8048043b 00000002 00000000 9e8b8000 00000001 00000004 9e8b8000
> [   10.156026] Call Trace:
> [   10.156026]  [<809e6785>] dump_stack+0x48/0x69
> [   10.156026]  [<809e561e>] print_usage_bug+0x18f/0x19c
> [   10.156026]  [<8047f7b0>] ? print_shortest_lock_dependencies+0x170/0x170
> [   10.156026]  [<8048043b>] mark_lock+0x53b/0x5f0
> [   10.156026]  [<804810cf>] __lock_acquire+0x6df/0x17a0
> [   10.156026]  [<804828ba>] lock_acquire+0x6a/0xf0
> [   10.156026]  [<80948b6a>] ? sch_direct_xmit+0x7a/0x250
> [   10.156026]  [<809ed477>] _raw_spin_lock+0x27/0x40
> [   10.156026]  [<80948b6a>] ? sch_direct_xmit+0x7a/0x250
> [   10.156026]  [<80948b6a>] sch_direct_xmit+0x7a/0x250
> [   10.156026]  [<8092e6bf>] __dev_queue_xmit+0x1af/0x5f0
> [   10.156026]  [<80947fc0>] ? ether_setup+0x80/0x80
> [   10.156026]  [<8092eb0f>] dev_queue_xmit+0xf/0x20
> [   10.156026]  [<8093764c>] neigh_resolve_output+0x15c/0x2a0
> [   10.156026]  [<a0556927>] ip6_finish_output2+0x167/0x7f0 [ipv6]
> [   10.156026]  [<a0559b05>] ip6_finish_output+0x85/0x1c0 [ipv6]
> [   10.156026]  [<a0559cb7>] ip6_output+0x77/0x240 [ipv6]
> [   10.156026]  [<a0578163>] mld_sendpack+0x523/0x590 [ipv6]
> [   10.156026]  [<80480501>] ? mark_held_locks+0x11/0x90
> [   10.156026]  [<a057947d>] mld_ifc_timer_expire+0x15d/0x280 [ipv6]
> [   10.156026]  [<8044b168>] call_timer_fn+0x68/0x190
> [   10.156026]  [<a0579320>] ? igmp6_group_added+0x150/0x150 [ipv6]
> [   10.156026]  [<8044b3fa>] run_timer_softirq+0x16a/0x240
> [   10.156026]  [<a0579320>] ? igmp6_group_added+0x150/0x150 [ipv6]
> [   10.156026]  [<80444984>] __do_softirq+0xd4/0x2f0
> [   10.156026]  [<804448b0>] ? tasklet_action+0x100/0x100
> [   10.156026]  [<80404036>] do_softirq_own_stack+0x26/0x30
> [   10.156026]  <IRQ>  [<80444d05>] irq_exit+0x65/0x70
> [   10.156026]  [<8042d758>] smp_apic_timer_interrupt+0x38/0x50
> [   10.156026]  [<809ee91f>] apic_timer_interrupt+0x2f/0x34
> [   10.156026]  [<8048007b>] ? mark_lock+0x17b/0x5f0
> [   10.156026]  [<8040a912>] ? default_idle+0x22/0xf0
> [   10.156026]  [<8040b13e>] arch_cpu_idle+0xe/0x10
> [   10.156026]  [<8047bfc6>] cpu_startup_entry+0x206/0x410
> [   10.156026]  [<8042bfbd>] start_secondary+0x19d/0x1e0
>
> Next try results in a different one:
>
> [   23.899317] g_ether gadget: high-speed config #1: CDC Ethernet (EEM)
> [   23.900918] IPv6: ADDRCONF(NETDEV_CHANGE): usb0: link becomes ready
> [   23.901573]
> [   23.903097] =================================
> [   23.904613] [ INFO: inconsistent lock state ]
> [   23.904613] 3.16.0-rc5+ #13 Not tainted
> [   23.904613] ---------------------------------
> [   23.904613] inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
> [   23.904613] kworker/0:1/29 [HC1[1]:SC0[2]:HE0:SE0] takes:
> [   23.904613]  (&(&dev->tx_global_lock)->rlock){?.-...}, at: [<8088d4d4>] gether_disconnect+0x34/0x280
> [   23.904613] {HARDIRQ-ON-W} state was registered at:
> [   23.904613]   [<804810cf>] __lock_acquire+0x6df/0x17a0
> [   23.904613]   [<804828ba>] lock_acquire+0x6a/0xf0
> [   23.904613]   [<809ed477>] _raw_spin_lock+0x27/0x40
> [   23.904613]   [<809486ce>] dev_watchdog+0x1e/0x210
> [   23.904613]   [<8044b168>] call_timer_fn+0x68/0x190
> [   23.904613]   [<8044b3fa>] run_timer_softirq+0x16a/0x240
> [   23.904613]   [<80444984>] __do_softirq+0xd4/0x2f0
> [   23.904613]   [<80404036>] do_softirq_own_stack+0x26/0x30
> [   23.904613]   [<80444d05>] irq_exit+0x65/0x70
> [   23.904613]   [<8042d758>] smp_apic_timer_interrupt+0x38/0x50
> [   23.904613]   [<809ee91f>] apic_timer_interrupt+0x2f/0x34
> [   23.904613]   [<8040b13e>] arch_cpu_idle+0xe/0x10
> [   23.904613]   [<8047bfc6>] cpu_startup_entry+0x206/0x410
> [   23.904613]   [<8042bfbd>] start_secondary+0x19d/0x1e0
> [   23.904613] irq event stamp: 5255
> [   23.904613] hardirqs last  enabled at (5254): [<809ed6e5>] _raw_spin_unlock_irqrestore+0x45/0x60
> [   23.904613] hardirqs last disabled at (5255): [<809ee6a7>] common_interrupt+0x27/0x34
> [   23.904613] softirqs last  enabled at (5248): [<a05636f5>] ipv6_mc_up+0x35/0x40 [ipv6]
> [   23.904613] softirqs last disabled at (5250): [<a054e48e>] ip6_route_add+0x2ce/0x820 [ipv6]
> [   23.904613]
> [   23.904613] other info that might help us debug this:
> [   23.904613]  Possible unsafe locking scenario:
> [   23.904613]
> [   23.904613]        CPU0
> [   23.904613]        ----
> [   23.904613]   lock(&(&dev->tx_global_lock)->rlock);
> [   23.904613]   <Interrupt>
> [   23.904613]     lock(&(&dev->tx_global_lock)->rlock);
> [   23.904613]
> [   23.904613]  *** DEADLOCK ***
> [   23.904613]
> [   23.904613] 5 locks held by kworker/0:1/29:
> [   23.904613]  #0:  ("events"){.+.+..}, at: [<804585a0>] process_one_work+0x100/0x4e0
> [   23.904613]  #1:  ((linkwatch_work).work){+.+...}, at: [<804585a0>] process_one_work+0x100/0x4e0
> [   23.904613]  #2:  (rtnl_mutex){+.+.+.}, at: [<809395d4>] rtnl_lock+0x14/0x20
> [   23.904613]  #3:  (&tb->tb6_lock){++....}, at: [<a054e48e>] ip6_route_add+0x2ce/0x820 [ipv6]
> [   23.904613]  #4:  (rcu_read_lock){......}, at: [<8091b2b0>] sock_def_readable+0x0/0xa0
> [   23.904613]
> [   23.904613] stack backtrace:
> [   23.904613] CPU: 0 PID: 29 Comm: kworker/0:1 Not tainted 3.16.0-rc5+ #13
> [   23.904613] Workqueue: events linkwatch_event
> [   23.904613]  811f3220 00000000 9e80bde8 809e6785 9e923340 9e80be14 809e561e 80b95511
> [   23.904613]  80b9545a 80b9543d 80b95450 80b95441 80b957fe 9e923838 00000000 8047f8b0
> [   23.904613]  9e80be34 8048043b 00000000 00000002 9e923340 00000001 0000000c 9e923340
> [   23.904613] Call Trace:
> [   23.904613]  [<809e6785>] dump_stack+0x48/0x69
> [   23.904613]  [<809e561e>] print_usage_bug+0x18f/0x19c
> [   23.904613]  [<8047f8b0>] ? check_usage_backwards+0x100/0x100
> [   23.904613]  [<8048043b>] mark_lock+0x53b/0x5f0
> [   23.904613]  [<804811f0>] __lock_acquire+0x800/0x17a0
> [   23.904613]  [<804828ba>] lock_acquire+0x6a/0xf0
> [   23.904613]  [<8088d4d4>] ? gether_disconnect+0x34/0x280
> [   23.904613]  [<809ed477>] _raw_spin_lock+0x27/0x40
> [   23.904613]  [<8088d4d4>] ? gether_disconnect+0x34/0x280
> [   23.904613]  [<8088d4d4>] gether_disconnect+0x34/0x280
> [   23.904613]  [<8088e777>] eem_set_alt+0x37/0xc0
> [   23.904613]  [<8088e740>] ? eem_disable+0x20/0x20
> [   23.904613]  [<808847ce>] composite_setup+0x30e/0x1240
> [   23.904613]  [<8088ae5e>] ? pch_udc_isr+0x1e/0xf50
> [   23.904613]  [<8088b8ae>] pch_udc_isr+0xa6e/0xf50
> [   23.904613]  [<8048abe8>] handle_irq_event_percpu+0x38/0x1e0
> [   23.904613]  [<8048adc1>] handle_irq_event+0x31/0x50
> [   23.904613]  [<8048d2d0>] ? handle_simple_irq+0x80/0x80
> [   23.904613]  [<8048d32d>] handle_edge_irq+0x5d/0x110
> [   23.904613]  [<804040a5>] handle_irq+0x65/0x80
> [   23.904613]  <IRQ>  [<80403cfc>] do_IRQ+0x3c/0xc0
> [   23.904613]  [<809ee6ae>] common_interrupt+0x2e/0x34
> [   23.904613]  [<8048007b>] ? mark_lock+0x17b/0x5f0
> [   23.904613]  [<809ed6e7>] ? _raw_spin_unlock_irqrestore+0x47/0x60
> [   23.904613]  [<8047ba01>] __wake_up_sync_key+0x41/0x50
> [   23.904613]  [<8091b307>] sock_def_readable+0x57/0xa0
> [   23.904613]  [<8094ab4e>] __netlink_sendskb+0x2e/0x40
> [   23.904613]  [<8094b529>] netlink_broadcast_filtered+0x149/0x2f0
> [   23.904613]  [<8094d3b4>] nlmsg_notify+0xb4/0xd0
> [   23.904613]  [<80939972>] rtnl_notify+0x32/0x50
> [   23.904613]  [<a0550218>] inet6_rt_notify+0xa8/0x110 [ipv6]
> [   23.904613]  [<a0551e1b>] fib6_add+0x34b/0x7c0 [ipv6]
> [   23.904613]  [<a054e4a4>] ip6_route_add+0x2e4/0x820 [ipv6]
> [   23.904613]  [<a0543ff8>] addrconf_add_mroute.isra.38+0x58/0x60 [ipv6]
> [   23.904613]  [<a05465b3>] addrconf_add_dev+0x53/0x90 [ipv6]
> [   23.904613]  [<a054a3ee>] addrconf_notify+0x4ce/0x6a0 [ipv6]
> [   23.904613]  [<809c36e0>] ? packet_notifier+0xb0/0x1e0
> [   23.904613]  [<80462a39>] notifier_call_chain+0x49/0x70
> [   23.904613]  [<80462b11>] raw_notifier_call_chain+0x11/0x20
> [   23.904613]  [<80927fda>] call_netdevice_notifiers_info+0x2a/0x60
> [   23.904613]  [<80929cfd>] netdev_state_change+0x2d/0x50
> [   23.904613]  [<8093e3d3>] linkwatch_do_dev+0x33/0x50
> [   23.904613]  [<8093e6a9>] __linkwatch_run_queue+0x109/0x130
> [   23.904613]  [<8093e6f0>] linkwatch_event+0x20/0x30
> [   23.904613]  [<804585fb>] process_one_work+0x15b/0x4e0
> [   23.904613]  [<80458db1>] worker_thread+0x41/0x4c0
> [   23.904613]  [<8048073b>] ? trace_hardirqs_on+0xb/0x10
> [   23.904613]  [<80458d70>] ? create_and_start_worker+0x50/0x50
> [   23.904613]  [<8045e3d8>] kthread+0xa8/0xc0
> [   23.904613]  [<809edf81>] ret_from_kernel_thread+0x21/0x30
> [   23.904613]  [<8045e330>] ? kthread_create_on_node+0x150/0x150
>
> Aside of that something in that driver is really flakey and timing
> sensitive, but before digging into that I'd like to figure out how to
> fix the splats above.
>
> Thanks,
>
>         tglx
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
