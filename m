From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: + ppp_generic-fix-lockdep-warning.patch added to -mm tree
Date: Wed, 11 Apr 2007 00:09:32 -0700
Message-ID: <20070411000932.1f00f395.akpm@linux-foundation.org>
References: <200703282353.l2SNr2iL023119@shell0.pdx.osdl.net>
	<01ef01c77bfe$4cdfe640$0202fea9@Jura>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <jarkao2@o2.pl>, <paulus@samba.org>, netdev@vger.kernel.org
To: "Yuriy N. Shkandybin" <jura@netams.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34587 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712AbXDKHJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 03:09:49 -0400
In-Reply-To: <01ef01c77bfe$4cdfe640$0202fea9@Jura>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(added netdev)

On Wed, 11 Apr 2007 09:57:33 +0400 "Yuriy N. Shkandybin" <jura@netams.com> wrote:

> I've tested  2.6.21-rc6-mm1
> Linux vpn1 2.6.21-rc6-mm1 #4 SMP Wed Apr 11 03:34:26 MSD 2007 x86_64 
> Intel(R) Pentium(R) D CPU 2.80GHz GenuineIntel GNU/Linux
> 
> warn appeares upon first pppoe connection to rp-pppoe server in kernel mode
> 
> result:
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.21-rc6-mm1 #4
> -------------------------------------------------------
> pppd/14305 is trying to acquire lock:
>  (&vlan_netdev_xmit_lock_key){-...}, at: [<ffffffff8022f90b>] 
> dev_queue_xmit+0x26b/0x300
> 
> but task is already holding lock:
>  (&pch->downl#2){-+..}, at: [<ffffffff80388d3c>] ppp_push+0x5f/0xa7
> 
> which lock already depends on the new lock.
> 
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #3 (&pch->downl#2){-+..}:
>        [<ffffffff80290c5f>] __lock_acquire+0xedf/0x1048
>        [<ffffffff80290e17>] lock_acquire+0x4f/0x78
>        [<ffffffff80388d3c>] ppp_push+0x5f/0xa7
>        [<ffffffff80263434>] _spin_lock_bh+0x2a/0x39
>        [<ffffffff80388d3c>] ppp_push+0x5f/0xa7
>        [<ffffffff8038967d>] ppp_xmit_process+0x3d/0x590
>        [<ffffffff8038b915>] ppp_write+0x105/0x140
>        [<ffffffff802163f3>] vfs_write+0xa3/0xf0
>        [<ffffffff80216e04>] sys_write+0x47/0x75
>        [<ffffffff8025d11e>] system_call+0x7e/0x83
>        [<ffffffffffffffff>] 0xffffffffffffffff
> 
> -> #2 (&ppp->wlock){-+..}:
>        [<ffffffff80290c5f>] __lock_acquire+0xedf/0x1048
>        [<ffffffff80290e17>] lock_acquire+0x4f/0x78
>        [<ffffffff80389667>] ppp_xmit_process+0x27/0x590
>        [<ffffffff80263434>] _spin_lock_bh+0x2a/0x39
>        [<ffffffff80389667>] ppp_xmit_process+0x27/0x590
>        [<ffffffff8038b78c>] ppp_start_xmit+0x1cc/0x250
>        [<ffffffff803c1bff>] dev_hard_start_xmit+0x22f/0x290
>        [<ffffffff803ccbf1>] __qdisc_run+0xd1/0x1f8
>        [<ffffffff8022f928>] dev_queue_xmit+0x288/0x300
>        [<ffffffff80239b72>] ip_mc_output+0x292/0x3f0
>        [<ffffffff803eb991>] raw_sendmsg+0x511/0x7c3
>        [<ffffffff80245a25>] inet_sendmsg+0x35/0x55
>        [<ffffffff80254da7>] sock_sendmsg+0xdf/0x102
>        [<ffffffff8028f826>] trace_hardirqs_on+0xc6/0x160
>        [<ffffffff802885da>] autoremove_wake_function+0x0/0x46
>        [<ffffffff80263324>] _spin_unlock_bh+0x2f/0x36
>        [<ffffffff80230ec8>] release_sock+0xcd/0xd6
>        [<ffffffff803dbcc2>] ip_setsockopt+0x142/0xbb3
>        [<ffffffff803bf33c>] verify_iovec+0x3c/0xc2
>        [<ffffffff803b8e9d>] sys_sendmsg+0x133/0x248
>        [<ffffffff8028f826>] trace_hardirqs_on+0xc6/0x160
>        [<ffffffff80282028>] getrusage+0x1b8/0x1d9
>        [<ffffffff8028f826>] trace_hardirqs_on+0xc6/0x160
>        [<ffffffff80262e27>] trace_hardirqs_on_thunk+0x35/0x37
>        [<ffffffff8025d11e>] system_call+0x7e/0x83
>        [<ffffffffffffffff>] 0xffffffffffffffff
> 
> -> #1 (&dev->_xmit_lock){-+..}:
>        [<ffffffff80290c5f>] __lock_acquire+0xedf/0x1048
>        [<ffffffff80290e17>] lock_acquire+0x4f/0x78
>        [<ffffffff803c4f59>] dev_mc_add+0x40/0x169
>        [<ffffffff80263434>] _spin_lock_bh+0x2a/0x39
>        [<ffffffff803c4f59>] dev_mc_add+0x40/0x169
>        [<ffffffff80403457>] vlan_dev_set_multicast_list+0xa7/0x2b8
>        [<ffffffff803c4c64>] __dev_mc_upload+0x24/0x26
>        [<ffffffff803c4ff7>] dev_mc_add+0xde/0x169
>        [<ffffffff803f47d7>] igmp_group_added+0x56/0x5f
>        [<ffffffff8026322b>] _write_unlock_bh+0x2f/0x36
>        [<ffffffff803f4965>] ip_mc_inc_group+0x105/0x17a
>        [<ffffffff803f49fc>] ip_mc_up+0x22/0x69
>        [<ffffffff803f1b48>] inetdev_event+0x1b8/0x2f0
>        [<ffffffff80281d69>] notifier_call_chain+0x49/0x6b
>        [<ffffffff80281dcc>] __raw_notifier_call_chain+0x9/0xb
>        [<ffffffff80281ddf>] raw_notifier_call_chain+0x11/0x13
>        [<ffffffff803c335d>] dev_open+0x7d/0x80
>        [<ffffffff803c1527>] dev_change_flags+0x107/0x138
>        [<ffffffff803f290c>] devinet_ioctl+0x5cc/0x720
>        [<ffffffff803c2fec>] dev_ioctl+0x1fc/0x31b
>        [<ffffffff8022104f>] __up_read+0x3f/0x9d
>        [<ffffffff803f2d5d>] inet_ioctl+0x5d/0x77
>        [<ffffffff803b854f>] sock_ioctl+0x4f/0x215
>        [<ffffffff80241aca>] do_ioctl+0x2a/0x83
>        [<ffffffff8022fe92>] vfs_ioctl+0x62/0x2b0
>        [<ffffffff8028f826>] trace_hardirqs_on+0xc6/0x160
>        [<ffffffff8024cef0>] sys_ioctl+0x41/0x65
>        [<ffffffff8025d11e>] system_call+0x7e/0x83
>        [<ffffffffffffffff>] 0xffffffffffffffff
> 
> -> #0 (&vlan_netdev_xmit_lock_key){-...}:
>        [<ffffffff8028ded0>] print_circular_bug_entry+0x49/0x59
>        [<ffffffff80290ad3>] __lock_acquire+0xd53/0x1048
>        [<ffffffff8020a5d5>] kmem_cache_alloc+0x1a5/0x5e0
>        [<ffffffff8028f7ea>] trace_hardirqs_on+0x8a/0x160
>        [<ffffffff80290e17>] lock_acquire+0x4f/0x78
>        [<ffffffff8022f90b>] dev_queue_xmit+0x26b/0x300
>        [<ffffffff802633fb>] _spin_lock+0x25/0x34
>        [<ffffffff8022f90b>] dev_queue_xmit+0x26b/0x300
>        [<ffffffff8038d753>] __pppoe_xmit+0x1e8/0x265
>        [<ffffffff8038d7dc>] pppoe_xmit+0xc/0xe
>        [<ffffffff80388d51>] ppp_push+0x74/0xa7
>        [<ffffffff8038967d>] ppp_xmit_process+0x3d/0x590
>        [<ffffffff8038b915>] ppp_write+0x105/0x140
>        [<ffffffff802163f3>] vfs_write+0xa3/0xf0
>        [<ffffffff80216e04>] sys_write+0x47/0x75
>        [<ffffffff8025d11e>] system_call+0x7e/0x83
>        [<ffffffffffffffff>] 0xffffffffffffffff
> 
> other info that might help us debug this:
> 
> 2 locks held by pppd/14305:
>  #0:  (&ppp->wlock){-+..}, at: [<ffffffff80389667>] 
> ppp_xmit_process+0x27/0x590
>  #1:  (&pch->downl#2){-+..}, at: [<ffffffff80388d3c>] ppp_push+0x5f/0xa7
> 
> stack backtrace:
> 
> Call Trace:
>  [<ffffffff8028e95b>] print_circular_bug_tail+0x7c/0x91
>  [<ffffffff8028ded0>] print_circular_bug_entry+0x49/0x59
>  [<ffffffff80290ad3>] __lock_acquire+0xd53/0x1048
>  [<ffffffff8020a5d5>] kmem_cache_alloc+0x1a5/0x5e0
>  [<ffffffff8028f7ea>] trace_hardirqs_on+0x8a/0x160
>  [<ffffffff80290e17>] lock_acquire+0x4f/0x78
>  [<ffffffff8022f90b>] dev_queue_xmit+0x26b/0x300
>  [<ffffffff802633fb>] _spin_lock+0x25/0x34
>  [<ffffffff8022f90b>] dev_queue_xmit+0x26b/0x300
>  [<ffffffff8038d753>] __pppoe_xmit+0x1e8/0x265
>  [<ffffffff8038d7dc>] pppoe_xmit+0xc/0xe
>  [<ffffffff80388d51>] ppp_push+0x74/0xa7
>  [<ffffffff8038967d>] ppp_xmit_process+0x3d/0x590
>  [<ffffffff8038b915>] ppp_write+0x105/0x140
>  [<ffffffff802163f3>] vfs_write+0xa3/0xf0
>  [<ffffffff80216e04>] sys_write+0x47/0x75
>  [<ffffffff8025d11e>] system_call+0x7e/0x83
> 
> INFO: lockdep is turned off.

Thanks.  So you're saying that
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.21-rc6/2.6.21-rc6-mm1/broken-out/ppp_generic-fix-lockdep-warning.patch
did not fix anything?

