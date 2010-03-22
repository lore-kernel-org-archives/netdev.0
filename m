From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RCU problems in fib_table_insert
Date: Sun, 21 Mar 2010 23:51:33 -0700
Message-ID: <20100322065133.GG2517@linux.vnet.ibm.com>
References: <20100321202525.GA966@basil.fritz.box>
 <19367.3002.324694.563877@gargle.gargle.HOWL>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Robert Olsson <robert@herjulf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:47384 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753796Ab0CVGvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 02:51:37 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2M6bCts014723
	for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 02:37:12 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2M6pZNd1618106
	for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 02:51:36 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2M6pZkv005932
	for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 02:51:35 -0400
Content-Disposition: inline
In-Reply-To: <19367.3002.324694.563877@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 22, 2010 at 07:18:34AM +0100, Robert Olsson wrote:
> 
> Seems like Paul and Eric fixed this problem... We use fib_trie with 
> major infrastructure but always disable preempt. It was unsafe w.
> preempt at least before Jareks P. patches about a year ago. I havn't
> tested w. preempt after that but maybe someone else have...

Well, if some code path fails either to do rcu_read_lock() or
to acquire RTNL, we will see lockdep splats.

Though I must admit that I would be surprised if there wasn't
more adjustment required in net/ipv4/fib_trie.c -- lots of
rcu_dereference()s in there.

						Thanx, Paul

> Cheers
> 					--ro
> 
> Andi Kleen writes:
>  > Hi,
>  > 
>  > I got the following warning at boot with a 2.6.34-rc2ish git kernel
>  > with RCU debugging and preemption enabled.
>  > 
>  > It seems the problem is that not all callers of fib_find_node
>  > call it with rcu_read_lock() to stabilize access to the fib. 
>  > 
>  > I tried to fix it, but especially for fib_table_insert() that's rather 
>  > tricky: it does a lot of memory allocations and also route flushing and 
>  > other blocking operations while assuming the original fa is RCU stable.
>  > 
>  > I first tried to move some allocations to the beginning and keep
>  > preemption disabled in the rest, but it's difficult with all of them.
>  > No patch because of that.
>  > 
>  > Does the fa need an additional reference count for this problem?
>  > Or perhaps some optimistic locking?
>  > 
>  > -Andi
>  > 
>  > 
>  > ==================================================
>  > [ INFO: suspicious rcu_dereference_check() usage. ]
>  > ---------------------------------------------------
>  > /home/lsrc/git/linux-2.6/net/ipv4/fib_trie.c:964 invoked rcu_dereference_check() without protection!
>  > 
>  > other info that might help us debug this:
>  > 
>  > 
>  > rcu_scheduler_active = 1, debug_locks = 0
>  > 2 locks held by ip/4521:
>  >  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff816466af>] rtnetlink_rcv+0x1f/0x40
>  >  #1:  ((inetaddr_chain).rwsem){.+.+.+}, at: [<ffffffff8107cde7>] __blocking_notifier_call_chain+0x47/0x90
>  > 
>  > stack backtrace:
>  > Pid: 4521, comm: ip Not tainted 2.6.34-rc2 #5
>  > Call Trace:
>  >  [<ffffffff8108b7e9>] lockdep_rcu_dereference+0xb9/0xc0
>  >  [<ffffffff81696a05>] fib_find_node+0x185/0x1b0
>  >  [<ffffffff8101155f>] ? save_stack_trace+0x2f/0x50
>  >  [<ffffffff81699b1c>] fib_table_insert+0xdc/0xa90
>  >  [<ffffffff8107cde7>] ? __blocking_notifier_call_chain+0x47/0x90
>  >  [<ffffffff8108edb5>] ? __lock_acquire+0x1485/0x1d50
>  >  [<ffffffff816926b0>] fib_magic+0xc0/0xd0
>  >  [<ffffffff81692738>] fib_add_ifaddr+0x78/0x1a0
>  >  [<ffffffff81692e60>] fib_inetaddr_event+0x50/0x2a0
>  >  [<ffffffff8173152d>] notifier_call_chain+0x6d/0xb0
>  >  [<ffffffff8107cdfd>] __blocking_notifier_call_chain+0x5d/0x90
>  >  [<ffffffff8107ce46>] blocking_notifier_call_chain+0x16/0x20
>  >  [<ffffffff81688c0a>] __inet_insert_ifa+0xea/0x180
>  >  [<ffffffff8168971d>] inetdev_event+0x43d/0x490
>  >  [<ffffffff8173152d>] notifier_call_chain+0x6d/0xb0
>  >  [<ffffffff8107cb06>] raw_notifier_call_chain+0x16/0x20
>  >  [<ffffffff81639f00>] __dev_notify_flags+0x40/0xa0
>  >  [<ffffffff81639fa5>] dev_change_flags+0x45/0x70
>  >  [<ffffffff81645c2c>] do_setlink+0x2fc/0x4a0
>  >  [<ffffffff81294176>] ? nla_parse+0x36/0x110
>  >  [<ffffffff81646d54>] rtnl_newlink+0x444/0x540
>  >  [<ffffffff8108c44d>] ? mark_held_locks+0x6d/0x90
>  >  [<ffffffff8172b8c5>] ? mutex_lock_nested+0x335/0x3c0
>  >  [<ffffffff8164685e>] rtnetlink_rcv_msg+0x18e/0x240
>  >  [<ffffffff816466d0>] ? rtnetlink_rcv_msg+0x0/0x240
>  >  [<ffffffff816520b9>] netlink_rcv_skb+0x89/0xb0
>  >  [<ffffffff816466be>] rtnetlink_rcv+0x2e/0x40
>  >  [<ffffffff81651b6b>] ? netlink_unicast+0x11b/0x2f0
>  >  [<ffffffff81651d2c>] netlink_unicast+0x2dc/0x2f0
>  >  [<ffffffff81630a3c>] ? memcpy_fromiovec+0x7c/0xa0
>  >  [<ffffffff81652643>] netlink_sendmsg+0x1d3/0x2e0
>  >  [<ffffffff81624e20>] sock_sendmsg+0xc0/0xf0
>  >  [<ffffffff8108f9cd>] ? lock_release_non_nested+0x9d/0x340
>  >  [<ffffffff810fa33b>] ? might_fault+0x7b/0xd0
>  >  [<ffffffff810fa33b>] ? might_fault+0x7b/0xd0
>  >  [<ffffffff810fa386>] ? might_fault+0xc6/0xd0
>  >  [<ffffffff810fa33b>] ? might_fault+0x7b/0xd0
>  >  [<ffffffff81630bfc>] ? verify_iovec+0x4c/0xe0
>  >  [<ffffffff81625c3e>] sys_sendmsg+0x1ae/0x360
>  >  [<ffffffff810fadf9>] ? __do_fault+0x3f9/0x550
>  >  [<ffffffff810fd143>] ? handle_mm_fault+0x1a3/0x790
>  >  [<ffffffff8112cc77>] ? fget_light+0xe7/0x2f0
>  >  [<ffffffff8108c735>] ? trace_hardirqs_on_caller+0x135/0x180
>  >  [<ffffffff8172ccc2>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>  >  [<ffffffff810030db>] system_call_fastpath+0x16/0x1b
>  > 
>  > 
>  > 
>  > 
>  > 
>  > -- 
>  > ak@linux.intel.com -- Speaking for myself only.
