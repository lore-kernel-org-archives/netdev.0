From: Andi Kleen <andi@firstfloor.org>
Subject: RCU problems in fib_table_insert
Date: Sun, 21 Mar 2010 21:25:25 +0100
Message-ID: <20100321202525.GA966@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com
To: robert.olsson@its.uu.se, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54678 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261Ab0CUUZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 16:25:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I got the following warning at boot with a 2.6.34-rc2ish git kernel
with RCU debugging and preemption enabled.

It seems the problem is that not all callers of fib_find_node
call it with rcu_read_lock() to stabilize access to the fib. 

I tried to fix it, but especially for fib_table_insert() that's rather 
tricky: it does a lot of memory allocations and also route flushing and 
other blocking operations while assuming the original fa is RCU stable.

I first tried to move some allocations to the beginning and keep
preemption disabled in the rest, but it's difficult with all of them.
No patch because of that.

Does the fa need an additional reference count for this problem?
Or perhaps some optimistic locking?

-Andi


==================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
/home/lsrc/git/linux-2.6/net/ipv4/fib_trie.c:964 invoked rcu_dereference_check() without protection!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 0
2 locks held by ip/4521:
 #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff816466af>] rtnetlink_rcv+0x1f/0x40
 #1:  ((inetaddr_chain).rwsem){.+.+.+}, at: [<ffffffff8107cde7>] __blocking_notifier_call_chain+0x47/0x90

stack backtrace:
Pid: 4521, comm: ip Not tainted 2.6.34-rc2 #5
Call Trace:
 [<ffffffff8108b7e9>] lockdep_rcu_dereference+0xb9/0xc0
 [<ffffffff81696a05>] fib_find_node+0x185/0x1b0
 [<ffffffff8101155f>] ? save_stack_trace+0x2f/0x50
 [<ffffffff81699b1c>] fib_table_insert+0xdc/0xa90
 [<ffffffff8107cde7>] ? __blocking_notifier_call_chain+0x47/0x90
 [<ffffffff8108edb5>] ? __lock_acquire+0x1485/0x1d50
 [<ffffffff816926b0>] fib_magic+0xc0/0xd0
 [<ffffffff81692738>] fib_add_ifaddr+0x78/0x1a0
 [<ffffffff81692e60>] fib_inetaddr_event+0x50/0x2a0
 [<ffffffff8173152d>] notifier_call_chain+0x6d/0xb0
 [<ffffffff8107cdfd>] __blocking_notifier_call_chain+0x5d/0x90
 [<ffffffff8107ce46>] blocking_notifier_call_chain+0x16/0x20
 [<ffffffff81688c0a>] __inet_insert_ifa+0xea/0x180
 [<ffffffff8168971d>] inetdev_event+0x43d/0x490
 [<ffffffff8173152d>] notifier_call_chain+0x6d/0xb0
 [<ffffffff8107cb06>] raw_notifier_call_chain+0x16/0x20
 [<ffffffff81639f00>] __dev_notify_flags+0x40/0xa0
 [<ffffffff81639fa5>] dev_change_flags+0x45/0x70
 [<ffffffff81645c2c>] do_setlink+0x2fc/0x4a0
 [<ffffffff81294176>] ? nla_parse+0x36/0x110
 [<ffffffff81646d54>] rtnl_newlink+0x444/0x540
 [<ffffffff8108c44d>] ? mark_held_locks+0x6d/0x90
 [<ffffffff8172b8c5>] ? mutex_lock_nested+0x335/0x3c0
 [<ffffffff8164685e>] rtnetlink_rcv_msg+0x18e/0x240
 [<ffffffff816466d0>] ? rtnetlink_rcv_msg+0x0/0x240
 [<ffffffff816520b9>] netlink_rcv_skb+0x89/0xb0
 [<ffffffff816466be>] rtnetlink_rcv+0x2e/0x40
 [<ffffffff81651b6b>] ? netlink_unicast+0x11b/0x2f0
 [<ffffffff81651d2c>] netlink_unicast+0x2dc/0x2f0
 [<ffffffff81630a3c>] ? memcpy_fromiovec+0x7c/0xa0
 [<ffffffff81652643>] netlink_sendmsg+0x1d3/0x2e0
 [<ffffffff81624e20>] sock_sendmsg+0xc0/0xf0
 [<ffffffff8108f9cd>] ? lock_release_non_nested+0x9d/0x340
 [<ffffffff810fa33b>] ? might_fault+0x7b/0xd0
 [<ffffffff810fa33b>] ? might_fault+0x7b/0xd0
 [<ffffffff810fa386>] ? might_fault+0xc6/0xd0
 [<ffffffff810fa33b>] ? might_fault+0x7b/0xd0
 [<ffffffff81630bfc>] ? verify_iovec+0x4c/0xe0
 [<ffffffff81625c3e>] sys_sendmsg+0x1ae/0x360
 [<ffffffff810fadf9>] ? __do_fault+0x3f9/0x550
 [<ffffffff810fd143>] ? handle_mm_fault+0x1a3/0x790
 [<ffffffff8112cc77>] ? fget_light+0xe7/0x2f0
 [<ffffffff8108c735>] ? trace_hardirqs_on_caller+0x135/0x180
 [<ffffffff8172ccc2>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff810030db>] system_call_fastpath+0x16/0x1b





-- 
ak@linux.intel.com -- Speaking for myself only.
