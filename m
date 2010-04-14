From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [BUG net-next-2.6] fib: Some rcu warning
Date: Wed, 14 Apr 2010 13:33:42 -0700
Message-ID: <20100414203342.GB24414@linux.vnet.ibm.com>
References: <1271274844.16881.1743.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:59864 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755910Ab0DNUdo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Apr 2010 16:33:44 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3EKSobG005432
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 16:28:50 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3EKXh3F2003170
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 16:33:43 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3EKXhES023514
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 16:33:43 -0400
Content-Disposition: inline
In-Reply-To: <1271274844.16881.1743.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 14, 2010 at 09:54:04PM +0200, Eric Dumazet wrote:
> [   27.756998] IPv4 FIB: Using LC-trie version 0.409
> [   27.757121] 
> [   27.757121] ===================================================
> [   27.757228] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   27.757285] ---------------------------------------------------
> [   27.757342] net/ipv4/fib_trie.c:212 invoked rcu_dereference_check()
> without protection!

Looks like this needs to allow for RTNL.  Please see below for a
patch.  Other places in this file might also need this.

							Thanx, Paul

> [   27.757417] 
> [   27.757417] other info that might help us debug this:
> [   27.757418] 
> [   27.757569] 
> [   27.757570] rcu_scheduler_active = 1, debug_locks = 0
> [   27.757674] 2 locks held by ip/5686:
> [   27.757727]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8134d247>]
> rtnl_lock+0x17/0x20
> [   27.757936]  #1:  ((inetaddr_chain).rwsem){.+.+.+}, at:
> [<ffffffff810654a7>] __blocking_notifier_call_chain+0x47/0x90
> [   27.758148] 
> [   27.758149] stack backtrace:
> [   27.758249] Pid: 5686, comm: ip Not tainted
> 2.6.34-rc3-03164-gb4bf665-dirty #10
> [   27.758323] Call Trace:
> [   27.758377]  [<ffffffff81071b4f>] lockdep_rcu_dereference+0xaf/0xc0
> [   27.758437]  [<ffffffff813ae32c>] fib_find_node+0x19c/0x220
> [   27.758495]  [<ffffffff813b0bdc>] fib_table_insert+0xac/0x760
> [   27.758552]  [<ffffffff813aa121>] ? fib_get_table+0x91/0xd0
> [   27.758609]  [<ffffffff813aa0b8>] ? fib_get_table+0x28/0xd0
> [   27.758667]  [<ffffffff813aa561>] fib_magic+0x111/0x120
> [   27.758723]  [<ffffffff813aa6a0>] fib_add_ifaddr+0x130/0x170
> [   27.758780]  [<ffffffff813aad3c>] fib_inetaddr_event+0x5c/0x290
> [   27.758838]  [<ffffffff810650d8>] notifier_call_chain+0x58/0x80
> [   27.758896]  [<ffffffff810654bd>] __blocking_notifier_call_chain
> +0x5d/0x90
> [   27.758956]  [<ffffffff81065506>] blocking_notifier_call_chain
> +0x16/0x20
> [   27.759016]  [<ffffffff813a0c44>] __inet_insert_ifa+0xd4/0x170
> [   27.759089]  [<ffffffff813a0cf2>] inet_insert_ifa+0x12/0x20
> [   27.759146]  [<ffffffff813a2140>] inetdev_event+0x400/0x430
> [   27.759204]  [<ffffffff81362472>] ? netlink_broadcast+0x262/0x3f0
> [   27.759263]  [<ffffffff81351391>] ? fib_rules_event+0x21/0x180
> [   27.759320]  [<ffffffff810650d8>] notifier_call_chain+0x58/0x80
> [   27.759378]  [<ffffffff8106512e>] __raw_notifier_call_chain+0xe/0x10
> [   27.759436]  [<ffffffff81065146>] raw_notifier_call_chain+0x16/0x20
> [   27.761102]  [<ffffffff8133fc1b>] call_netdevice_notifiers+0x1b/0x20
> [   27.761161]  [<ffffffff8133ffad>] __dev_notify_flags+0x7d/0x90
> [   27.761219]  [<ffffffff81340005>] dev_change_flags+0x45/0x70
> [   27.761278]  [<ffffffff813a2e79>] devinet_ioctl+0x5e9/0x770
> [   27.761336]  [<ffffffff813a36b1>] inet_ioctl+0x61/0x80
> [   27.761392]  [<ffffffff8132c532>] sock_do_ioctl+0x32/0x60
> [   27.761449]  [<ffffffff8132d06c>] compat_sock_ioctl+0x89c/0xb60
> [   27.761507]  [<ffffffff81075816>] ? __lock_acquire+0x486/0xaf0
> [   27.761567]  [<ffffffff810cbfeb>] ? __do_fault+0x12b/0x480
> [   27.761624]  [<ffffffff810b4a93>] ? filemap_fault+0xd3/0x3d0
> [   27.761683]  [<ffffffff810f7104>] ? fget_light+0x174/0x360
> [   27.761740]  [<ffffffff810cc1f9>] ? __do_fault+0x339/0x480
> [   27.761798]  [<ffffffff811370e3>] compat_sys_ioctl+0xd3/0x1900
> [   27.761856]  [<ffffffff810ce28a>] ? handle_mm_fault+0x19a/0x780
> [   27.761915]  [<ffffffff81023832>] ? do_page_fault+0xe2/0x3b0
> [   27.761972]  [<ffffffff81064703>] ? up_read+0x23/0x40
> [   27.762028]  [<ffffffff810238f5>] ? do_page_fault+0x1a5/0x3b0
> [   27.762087]  [<ffffffff813f36cb>] ? _raw_spin_unlock+0x2b/0x40
> [   27.762145]  [<ffffffff810f3508>] ? fd_install+0xa8/0xe0
> [   27.762202]  [<ffffffff8132eced>] ? sock_map_fd+0x2d/0x40
> [   27.762259]  [<ffffffff813f3a69>] ? retint_swapgs+0xe/0x13
> [   27.762331]  [<ffffffff8107292d>] ? trace_hardirqs_on_caller
> +0x10d/0x190
> [   27.762391]  [<ffffffff813f2d21>] ? trace_hardirqs_off_thunk
> +0x3a/0x3c
> [   27.762450]  [<ffffffff81028b64>] sysenter_dispatch+0x7/0x30
> [   27.762507]  [<ffffffff813f2ce2>] ? trace_hardirqs_on_thunk+0x3a/0x3f

commit 3f69d3dbdd2468f13591b676ca36b3d61d1a1294
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Wed Apr 14 13:30:13 2010 -0700

    net: fix RCU lockdep splat in tnode_get_child_rcu()
    
    Located-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index af5d897..45bda1f 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -208,7 +208,8 @@ static inline struct node *tnode_get_child_rcu(struct tnode *tn, unsigned int i)
 {
 	struct node *ret = tnode_get_child(tn, i);
 
-	return rcu_dereference(ret);
+	return rcu_dereference_check(ret,
+				     rcu_read_lock_held() || rtnl_is_locked());
 }
 
 static inline int tnode_child_length(const struct tnode *tn)
