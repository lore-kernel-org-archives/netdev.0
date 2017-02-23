From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: VXLAN RCU error
Date: Wed, 22 Feb 2017 20:30:31 -0800
Message-ID: <20170222203031.45513e4c@cakuba.netronome.com>
References: <20170222142745.31c5f75e@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34218 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752034AbdBWEaf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 23:30:35 -0500
Received: by mail-pg0-f41.google.com with SMTP id 1so10069242pgi.1
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 20:30:34 -0800 (PST)
In-Reply-To: <20170222142745.31c5f75e@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Feb 2017 14:27:45 -0800, Jakub Kicinski wrote:
> Hi Roopa!

Ah, sorry, it seems like this splat may be coming all the way from
c6fcc4fc5f8b ("vxlan: avoid using stale vxlan socket.").

> I get this RCU error on net 12d656af4e3d2781b9b9f52538593e1717e7c979:
> 
> [ 1571.067134] ===============================
> [ 1571.071842] [ ERR: suspicious RCU usage.  ]
> [ 1571.076546] 4.10.0-debug-03232-g12d656af4e3d #1 Tainted: G        W  O   
> [ 1571.084166] -------------------------------
> [ 1571.088867] ../drivers/net/vxlan.c:2111 suspicious rcu_dereference_check() usage!
> [ 1571.097286] 
> [ 1571.097286] other info that might help us debug this:
> [ 1571.097286] 
> [ 1571.106305] 
> [ 1571.106305] rcu_scheduler_active = 2, debug_locks = 1
> [ 1571.113654] 3 locks held by ping/13826:
> [ 1571.117968]  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffffa1cd4972>] raw_sendmsg+0x14e2/0x2e40
> [ 1571.127758]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffffa1be9594>] ip_finish_output2+0x274/0x1390
> [ 1571.138135]  #2:  (rcu_read_lock_bh){......}, at: [<ffffffffa1a9b63c>] __dev_queue_xmit+0x1ec/0x2750
> [ 1571.148408] 
> [ 1571.148408] stack backtrace:
> [ 1571.153326] CPU: 10 PID: 13826 Comm: ping Tainted: G        W  O    4.10.0-debug-03232-g12d656af4e3d #1
> [ 1571.163877] Hardware name: Dell Inc. PowerEdge R730/072T6D, BIOS 2.3.4 11/08/2016
> [ 1571.172290] Call Trace:
> [ 1571.175053]  dump_stack+0xcd/0x134
> [ 1571.178881]  ? _atomic_dec_and_lock+0xcc/0xcc
> [ 1571.183782]  ? print_lock+0xb2/0xb5
> [ 1571.187711]  lockdep_rcu_suspicious+0x123/0x170
> [ 1571.192807]  vxlan_xmit_one+0x1931/0x4270 [vxlan]
> [ 1571.198126]  ? encap_bypass_if_local+0x380/0x380 [vxlan]
> [ 1571.204109]  ? sched_clock+0x9/0x10
> [ 1571.208034]  ? sched_clock_cpu+0x20/0x2c0
> [ 1571.212541]  ? unwind_get_return_address+0x1b8/0x2b0
> [ 1571.218132]  ? __lock_acquire+0x6d6/0x3160
> [ 1571.222740]  vxlan_xmit+0x756/0x4f90 [vxlan]
> [ 1571.227541]  ? vxlan_xmit_one+0x4270/0x4270 [vxlan]
> [ 1571.233014]  ? netif_skb_features+0x2be/0xba0
> [ 1571.237919]  dev_hard_start_xmit+0x1ab/0xa70
> [ 1571.242724]  __dev_queue_xmit+0x137b/0x2750
> [ 1571.247425]  ? __dev_queue_xmit+0x1ec/0x2750
> [ 1571.252228]  ? netdev_pick_tx+0x330/0x330
> [ 1571.256735]  ? debug_smp_processor_id+0x17/0x20
> [ 1571.261826]  ? get_lock_stats+0x1d/0x160
> [ 1571.266241]  ? mark_held_locks+0x105/0x280
> [ 1571.270850]  ? memcpy+0x45/0x50
> [ 1571.274391]  dev_queue_xmit+0x10/0x20
> [ 1571.278511]  neigh_resolve_output+0x43e/0x7f0
> [ 1571.283405]  ? ip_finish_output2+0x69d/0x1390
> [ 1571.288308]  ip_finish_output2+0x69d/0x1390
> [ 1571.293008]  ? ip_finish_output2+0x274/0x1390
> [ 1571.297909]  ? ip_copy_metadata+0x7e0/0x7e0
> [ 1571.302610]  ? get_lock_stats+0x1d/0x160
> [ 1571.307027]  ip_finish_output+0x598/0xc50
> [ 1571.311537]  ip_output+0x371/0x630
> [ 1571.315362]  ? ip_output+0x1dc/0x630
> [ 1571.319383]  ? ip_mc_output+0xe70/0xe70
> [ 1571.323694]  ? kfree+0x372/0x5a0
> [ 1571.327325]  ? mark_held_locks+0x105/0x280
> [ 1571.331933]  ? __ip_make_skb+0xdd1/0x2200
> [ 1571.336457]  ip_local_out+0x8f/0x180
> [ 1571.340480]  ip_send_skb+0x44/0xf0
> [ 1571.344306]  ip_push_pending_frames+0x5a/0x80
> [ 1571.349203]  raw_sendmsg+0x164d/0x2e40
> [ 1571.353422]  ? debug_check_no_locks_freed+0x350/0x350
> [ 1571.359099]  ? dst_output+0x1b0/0x1b0
> [ 1571.363217]  ? get_lock_stats+0x1d/0x160
> [ 1571.367640]  ? __might_fault+0x199/0x230
> [ 1571.372052]  ? kasan_check_write+0x14/0x20
> [ 1571.382002]  ? _copy_from_user+0xb9/0x130
> [ 1571.386513]  ? rw_copy_check_uvector+0x8d/0x490
> [ 1571.391609]  ? import_iovec+0xae/0x5d0
> [ 1571.395826]  ? push_pipe+0xd00/0xd00
> [ 1571.399847]  ? kasan_check_write+0x14/0x20
> [ 1571.404450]  ? _copy_from_user+0xb9/0x130
> [ 1571.408960]  inet_sendmsg+0x19f/0x5f0
> [ 1571.413071]  ? inet_recvmsg+0x980/0x980
> [ 1571.417386]  sock_sendmsg+0xe2/0x170
> [ 1571.421408]  ___sys_sendmsg+0x66e/0x960
> [ 1571.425726]  ? mem_cgroup_commit_charge+0x144/0x2720
> [ 1571.431303]  ? copy_msghdr_from_user+0x610/0x610
> [ 1571.436495]  ? debug_smp_processor_id+0x17/0x20
> [ 1571.441584]  ? get_lock_stats+0x1d/0x160
> [ 1571.445995]  ? mem_cgroup_uncharge_swap+0x250/0x250
> [ 1571.451474]  ? page_add_new_anon_rmap+0x173/0x3a0
> [ 1571.456762]  ? handle_mm_fault+0x1589/0x3820
> [ 1571.461566]  ? handle_mm_fault+0x1589/0x3820
> [ 1571.466362]  ? handle_mm_fault+0x191/0x3820
> [ 1571.471070]  ? __fdget+0x13/0x20
> [ 1571.474702]  ? get_lock_stats+0x1d/0x160
> [ 1571.479116]  __sys_sendmsg+0xc6/0x150
> [ 1571.483234]  ? SyS_shutdown+0x1b0/0x1b0
> [ 1571.487551]  ? __do_page_fault+0x556/0xe50
> [ 1571.492158]  ? trace_hardirqs_on_thunk+0x1a/0x1c
> [ 1571.497340]  SyS_sendmsg+0x12/0x20
> [ 1571.501166]  entry_SYSCALL_64_fastpath+0x23/0xc6
> [ 1571.506354] RIP: 0033:0x7fca2d0384a0
> [ 1571.510374] RSP: 002b:00007ffd18d7fe88 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
> [ 1571.518886] RAX: ffffffffffffffda RBX: 0000000000000040 RCX: 00007fca2d0384a0
> [ 1571.526889] RDX: 0000000000000000 RSI: 000000000060a300 RDI: 0000000000000003
> [ 1571.534892] RBP: 0000000000000046 R08: 0000000000000020 R09: 000000000000003e
> [ 1571.542897] R10: 00007ffd18d7fc50 R11: 0000000000000246 R12: 00000000000000c0
> [ 1571.550900] R13: 0000000000000004 R14: 00007ffd18d81608 R15: 00007ffd18d810b0

Judging from the splat do we just need to use defereference_bh() on the
TX path?

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 4e27c5b09600..8aa3e837cd6c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2109,7 +2109,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
                                     vxlan->cfg.port_max, true);
 
        if (dst->sa.sa_family == AF_INET) {
-               struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
+               struct vxlan_sock *sock4 = rcu_dereference_bh(vxlan->vn4_sock);
                struct rtable *rt;
                __be16 df = 0;
 
@@ -2148,7 +2148,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
                                    src_port, dst_port, xnet, !udp_sum);
 #if IS_ENABLED(CONFIG_IPV6)
        } else {
-               struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
+               struct vxlan_sock *sock6 = rcu_dereference_bh(vxlan->vn6_sock);
 
                ndst = vxlan6_get_route(vxlan, dev, sock6, skb,
                                        rdst ? rdst->remote_ifindex : 0, tos,


> Some of Netronome's VXLAN tests are also failing but I need to dig a
> bit to see what's wrong there...

Test failures turned out to be unrelated.
