From: Andi Kleen <andi@firstfloor.org>
Subject: lockdep possible recursive lock in slab parent->list->rlock in rc2
Date: Sun, 27 Dec 2009 13:06:22 +0100
Message-ID: <20091227120622.GA480@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	penberg@cs.helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46919 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbZL0MG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2009 07:06:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Get this on a NFS root system while booting
This must be a recent change in the last week, 
I didn't see it in a post rc1 git* from last week
(I haven't done a exact bisect)

It's triggered by the r8169 driver close function, 
but looks more like a slab problem?

I haven't checked it in detail if the locks are 
really different or just lockdep not knowing 
enough classes.

-Andi

=============================================
[ INFO: possible recursive locking detected ]
2.6.33-rc2 #19
---------------------------------------------
swapper/1 is trying to acquire lock:
 (&(&parent->list_lock)->rlock){-.-...}, at: [<ffffffff810cc93a>] cache_flusharray+0x55/0x10a

but task is already holding lock:
 (&(&parent->list_lock)->rlock){-.-...}, at: [<ffffffff810cc93a>] cache_flusharray+0x55/0x10a

other info that might help us debug this:
2 locks held by swapper/1:
 #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff813e24d6>] rtnl_lock+0x12/0x14
 #1:  (&(&parent->list_lock)->rlock){-.-...}, at: [<ffffffff810cc93a>] cache_flusharray+0x55/0x10a

stack backtrace:
Pid: 1, comm: swapper Not tainted 2.6.33-rc2-MCE6 #19
Call Trace:
 [<ffffffff810687da>] __lock_acquire+0xf94/0x1771
 [<ffffffff81066402>] ? mark_held_locks+0x4d/0x6b
 [<ffffffff81066663>] ? trace_hardirqs_on_caller+0x10b/0x12f
 [<ffffffff8105b061>] ? sched_clock_local+0x1c/0x80
 [<ffffffff8105b061>] ? sched_clock_local+0x1c/0x80
 [<ffffffff81069073>] lock_acquire+0xbc/0xd9
 [<ffffffff810cc93a>] ? cache_flusharray+0x55/0x10a
 [<ffffffff8149639d>] _raw_spin_lock+0x31/0x66
 [<ffffffff810cc93a>] ? cache_flusharray+0x55/0x10a
 [<ffffffff810cbbf8>] ? kfree_debugcheck+0x11/0x2d
 [<ffffffff810cc93a>] cache_flusharray+0x55/0x10a
 [<ffffffff81066d67>] ? debug_check_no_locks_freed+0x119/0x12f
 [<ffffffff810cc387>] kmem_cache_free+0x18f/0x1f2
 [<ffffffff810cc515>] slab_destroy+0x12b/0x138
 [<ffffffff810cc683>] free_block+0x161/0x1a2
 [<ffffffff810cc982>] cache_flusharray+0x9d/0x10a
 [<ffffffff81066d67>] ? debug_check_no_locks_freed+0x119/0x12f
 [<ffffffff810ccbf3>] kfree+0x204/0x23b
 [<ffffffff81066694>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff813d002a>] skb_release_data+0xc6/0xcb
 [<ffffffff813cfd19>] __kfree_skb+0x19/0x86
 [<ffffffff813cfdb1>] consume_skb+0x2b/0x2d
 [<ffffffff8133929a>] rtl8169_rx_clear+0x7f/0xbb
 [<ffffffff8133ada2>] rtl8169_down+0x12c/0x13b
 [<ffffffff8133b58a>] rtl8169_close+0x30/0x131
 [<ffffffff813e8d98>] ? dev_deactivate+0x168/0x198
 [<ffffffff813d94d6>] dev_close+0x8c/0xae
 [<ffffffff813d8e62>] dev_change_flags+0xba/0x180
 [<ffffffff81a87e63>] ic_close_devs+0x2e/0x48
 [<ffffffff81a88a5b>] ip_auto_config+0x914/0xe1e
 [<ffffffff8105b061>] ? sched_clock_local+0x1c/0x80
 [<ffffffff810649a1>] ? trace_hardirqs_off+0xd/0xf
 [<ffffffff8105b1c0>] ? cpu_clock+0x2d/0x3f
 [<ffffffff810649c7>] ? lock_release_holdtime+0x24/0x181
 [<ffffffff81a86967>] ? tcp_congestion_default+0x0/0x12
 [<ffffffff81496c60>] ? _raw_spin_unlock+0x26/0x2b
 [<ffffffff81a86967>] ? tcp_congestion_default+0x0/0x12
 [<ffffffff81a88147>] ? ip_auto_config+0x0/0xe1e
 [<ffffffff810001f0>] do_one_initcall+0x5a/0x14f
 [<ffffffff81a5364c>] kernel_init+0x141/0x197
 [<ffffffff81003794>] kernel_thread_helper+0x4/0x10
 [<ffffffff81496efc>] ? restore_args+0x0/0x30
 [<ffffffff81a5350b>] ? kernel_init+0x0/0x197
 [<ffffffff81003790>] ? kernel_thread_helper+0x0/0x10
IP-Config: Retrying forever (NFS root)...
r8169: eth0: link up

-- 
ak@linux.intel.com -- Speaking for myself only.
