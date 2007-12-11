From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 9542] BUG: bad unlock balance detected!
Date: Tue, 11 Dec 2007 14:06:14 -0800
Message-ID: <20071211140614.7c1738a5.akpm@linux-foundation.org>
References: <bug-9542-27@http.bugzilla.kernel.org/>
	<20071211150313.EF4D210806E@picon.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	olel@ans.pl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33624 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751283AbXLKWGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 17:06:33 -0500
In-Reply-To: <20071211150313.EF4D210806E@picon.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switching to email - please respond via emailed reply-to-all, not via the
bugzilla web interface)

On Tue, 11 Dec 2007 07:03:13 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9542
> 
> 
> 
> 
> 
> ------- Comment #2 from olel@ans.pl  2007-12-11 07:03 -------
> Still wrong.

So this appears to be a separate bug in either bonding or ipv6.

> =========================================================
> [ INFO: possible irq lock inversion dependency detected ]
> 2.6.24-rc4-git7 #1
> ---------------------------------------------------------
> events/0/9 just changed the state of lock:
>  (&mc->mca_lock){-+..}, at: [<c0412602>] mld_ifc_timer_expire+0x130/0x1fb
> but this lock took another, soft-read-irq-unsafe lock in the past:
>  (&bond->lock){-.--}
> 
> and interrupts could create inverse lock ordering between them.
> 
> 
> other info that might help us debug this:
> 4 locks held by events/0/9:
>  #0:  (events){--..}, at: [<c0133c8b>] run_workqueue+0x87/0x1b6
>  #1:  ((linkwatch_work).work){--..}, at: [<c0133c8b>] run_workqueue+0x87/0x1b6
>  #2:  (rtnl_mutex){--..}, at: [<c03ac6d4>] linkwatch_event+0x5/0x22
>  #3:  (&ndev->lock){-.-+}, at: [<c04124e9>] mld_ifc_timer_expire+0x17/0x1fb
> 
> the first lock's dependencies:
> -> (&mc->mca_lock){-+..} ops: 10 {
>    initial-use  at:
>                         [<c0104ee2>] dump_trace+0x83/0x8d
>                         [<c01428d0>] __lock_acquire+0x4ba/0xc07
>                         [<c0109eee>] save_stack_trace+0x20/0x3a
>                         [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                         [<c0412dda>] ipv6_dev_mc_inc+0x24d/0x31c
>                         [<c0143096>] lock_acquire+0x79/0x93
>                         [<c0412a5e>] igmp6_group_added+0x18/0x11d
>                         [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                         [<c0412a5e>] igmp6_group_added+0x18/0x11d
>                         [<c0412a5e>] igmp6_group_added+0x18/0x11d
>                         [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                         [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>                         [<c0412dda>] ipv6_dev_mc_inc+0x24d/0x31c
>                         [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>                         [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>                         [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>                         [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>                         [<c05c5b4d>] addrconf_init+0x13/0x193
>                         [<c019a95f>] proc_net_fops_create+0x10/0x21
>                         [<c041a4c0>] ip6_flowlabel_init+0x1e/0x20
>                         [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>                         [<c05a9499>] kernel_init+0x150/0x2b7
>                         [<c05a9349>] kernel_init+0x0/0x2b7
>                         [<c05a9349>] kernel_init+0x0/0x2b7
>                         [<c0104baf>] kernel_thread_helper+0x7/0x10
>                         [<ffffffff>] 0xffffffff
>    in-softirq-W at:
>                         [<c0142856>] __lock_acquire+0x440/0xc07
>                         [<c0143096>] lock_acquire+0x79/0x93
>                         [<c0412602>] mld_ifc_timer_expire+0x130/0x1fb
>                         [<c04124d2>] mld_ifc_timer_expire+0x0/0x1fb
>                         [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                         [<c0412602>] mld_ifc_timer_expire+0x130/0x1fb
>                         [<c0412602>] mld_ifc_timer_expire+0x130/0x1fb
>                         [<c04124d2>] mld_ifc_timer_expire+0x0/0x1fb
>                         [<c0141fbd>] trace_hardirqs_on+0x10c/0x14c
>                         [<c04124d2>] mld_ifc_timer_expire+0x0/0x1fb
>                         [<c012df86>] run_timer_softirq+0xfa/0x15d
>                         [<c012a8da>] __do_softirq+0x56/0xdb
>                         [<c0141fbd>] trace_hardirqs_on+0x10c/0x14c
>                         [<c012a8ec>] __do_softirq+0x68/0xdb
>                         [<c012a995>] do_softirq+0x36/0x51
>                         [<c012ab3b>] irq_exit+0x43/0x4e
>                         [<c011411e>] smp_apic_timer_interrupt+0x74/0x80
>                         [<c012a8da>] __do_softirq+0x56/0xdb
>                         [<c0104a01>] apic_timer_interrupt+0x29/0x38
>                         [<c0104a0b>] apic_timer_interrupt+0x33/0x38
>                         [<c03b007b>] nl_pid_hash_rehash+0xc1/0x13f
>                         [<c03b00d8>] nl_pid_hash_rehash+0x11e/0x13f
>                         [<c012aea0>] local_bh_enable_ip+0xcf/0xed
>                         [<c03bfa8b>] rt_run_flush+0x64/0x8b
>                         [<c03e9c1e>] fib_netdev_event+0x61/0x65
>                         [<c013ac54>] notifier_call_chain+0x2a/0x52
>                         [<c013ac9e>] raw_notifier_call_chain+0x17/0x1a
>                         [<c03a3469>] netdev_state_change+0x18/0x29
>                         [<c03ac6a1>] __linkwatch_run_queue+0x150/0x17e
>                         [<c03ac6ec>] linkwatch_event+0x1d/0x22
>                         [<c0133cdf>] run_workqueue+0xdb/0x1b6
>                         [<c0133c8b>] run_workqueue+0x87/0x1b6
>                         [<c03ac6cf>] linkwatch_event+0x0/0x22
>                         [<c01346ff>] worker_thread+0x0/0x85
>                         [<c0134778>] worker_thread+0x79/0x85
>                         [<c01371ad>] autoremove_wake_function+0x0/0x35
>                         [<c01370f6>] kthread+0x38/0x5e
>                         [<c01370be>] kthread+0x0/0x5e
>                         [<c0104baf>] kernel_thread_helper+0x7/0x10
>                         [<ffffffff>] 0xffffffff
>    hardirq-on-W at:
>                         [<c0141822>] find_usage_backwards+0xbb/0xe2
>                         [<c0104ee2>] dump_trace+0x83/0x8d
>                         [<c014289e>] __lock_acquire+0x488/0xc07
>                         [<c0109eee>] save_stack_trace+0x20/0x3a
>                         [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                         [<c0412dda>] ipv6_dev_mc_inc+0x24d/0x31c
>                         [<c0143096>] lock_acquire+0x79/0x93
>                         [<c0412a5e>] igmp6_group_added+0x18/0x11d
>                         [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                         [<c0412a5e>] igmp6_group_added+0x18/0x11d
>                         [<c0412a5e>] igmp6_group_added+0x18/0x11d
>                         [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                         [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>                         [<c0412dda>] ipv6_dev_mc_inc+0x24d/0x31c
>                         [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>                         [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>                         [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>                         [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>                         [<c05c5b4d>] addrconf_init+0x13/0x193
>                         [<c019a95f>] proc_net_fops_create+0x10/0x21
>                         [<c041a4c0>] ip6_flowlabel_init+0x1e/0x20
>                         [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>                         [<c05a9499>] kernel_init+0x150/0x2b7
>                         [<c05a9349>] kernel_init+0x0/0x2b7
>                         [<c05a9349>] kernel_init+0x0/0x2b7
>                         [<c0104baf>] kernel_thread_helper+0x7/0x10
>                         [<ffffffff>] 0xffffffff
>  }
>  ... key      at: [<c087e2d8>] __key.30799+0x0/0x8
>  -> (_xmit_ETHER){-...} ops: 8 {
>     initial-use  at:
>                           [<c01428d0>] __lock_acquire+0x4ba/0xc07
>                           [<c0143096>] lock_acquire+0x79/0x93
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c0412a9c>] igmp6_group_added+0x56/0x11d
>                           [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>                           [<c0410100>] icmpv6_rcv+0x630/0x828
>                           [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>                           [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>                           [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>                           [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>                           [<c040279f>] addrconf_notify+0x60/0x7b7
>                           [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                           [<c0141de0>] mark_held_locks+0x39/0x53
>                           [<c04399ee>] mutex_lock_nested+0x286/0x2ac
>                           [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                           [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a490c>] register_netdevice_notifier+0x49/0x126
>                           [<c05c5be7>] addrconf_init+0xad/0x193
>                           [<c05c5b55>] addrconf_init+0x1b/0x193
>                           [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>                           [<c05a9499>] kernel_init+0x150/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c0104baf>] kernel_thread_helper+0x7/0x10
>                           [<ffffffff>] 0xffffffff
>     hardirq-on-W at:
>                           [<c01419ba>] mark_lock+0x64/0x451
>                           [<c014289e>] __lock_acquire+0x488/0xc07
>                           [<c0143096>] lock_acquire+0x79/0x93
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c0412a9c>] igmp6_group_added+0x56/0x11d
>                           [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>                           [<c0410100>] icmpv6_rcv+0x630/0x828
>                           [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>                           [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>                           [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>                           [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>                           [<c040279f>] addrconf_notify+0x60/0x7b7
>                           [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                           [<c0141de0>] mark_held_locks+0x39/0x53
>                           [<c04399ee>] mutex_lock_nested+0x286/0x2ac
>                           [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                           [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a490c>] register_netdevice_notifier+0x49/0x126
>                           [<c05c5be7>] addrconf_init+0xad/0x193
>                           [<c05c5b55>] addrconf_init+0x1b/0x193
>                           [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>                           [<c05a9499>] kernel_init+0x150/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c0104baf>] kernel_thread_helper+0x7/0x10
>                           [<ffffffff>] 0xffffffff
>   }
>   ... key      at: [<c087adc8>] netdev_xmit_lock_key+0x8/0x1c0
>  ... acquired at:
>    [<c0142e33>] __lock_acquire+0xa1d/0xc07
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c0143096>] lock_acquire+0x79/0x93
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c0412a9c>] igmp6_group_added+0x56/0x11d
>    [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>    [<c0410100>] icmpv6_rcv+0x630/0x828
>    [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>    [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>    [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>    [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>    [<c040279f>] addrconf_notify+0x60/0x7b7
>    [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>    [<c0141de0>] mark_held_locks+0x39/0x53
>    [<c04399ee>] mutex_lock_nested+0x286/0x2ac
>    [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>    [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>    [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>    [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>    [<c03a490c>] register_netdevice_notifier+0x49/0x126
>    [<c05c5be7>] addrconf_init+0xad/0x193
>    [<c05c5b55>] addrconf_init+0x1b/0x193
>    [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>    [<c05a9499>] kernel_init+0x150/0x2b7
>    [<c05a9349>] kernel_init+0x0/0x2b7
>    [<c05a9349>] kernel_init+0x0/0x2b7
>    [<c0104baf>] kernel_thread_helper+0x7/0x10
>    [<ffffffff>] 0xffffffff
> 
>  -> (&bonding_netdev_xmit_lock_key){-...} ops: 6 {
>     initial-use  at:
>                           [<c01428d0>] __lock_acquire+0x4ba/0xc07
>                           [<c0143096>] lock_acquire+0x79/0x93
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c0412a9c>] igmp6_group_added+0x56/0x11d
>                           [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>                           [<c0410100>] icmpv6_rcv+0x630/0x828
>                           [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>                           [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>                           [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>                           [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>                           [<c040279f>] addrconf_notify+0x60/0x7b7
>                           [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                           [<c0141de0>] mark_held_locks+0x39/0x53
>                           [<c04399ee>] mutex_lock_nested+0x286/0x2ac
>                           [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                           [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a490c>] register_netdevice_notifier+0x49/0x126
>                           [<c05c5be7>] addrconf_init+0xad/0x193
>                           [<c05c5b55>] addrconf_init+0x1b/0x193
>                           [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>                           [<c05a9499>] kernel_init+0x150/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c0104baf>] kernel_thread_helper+0x7/0x10
>                           [<ffffffff>] 0xffffffff
>     hardirq-on-W at:
>                           [<c01419ba>] mark_lock+0x64/0x451
>                           [<c014289e>] __lock_acquire+0x488/0xc07
>                           [<c0143096>] lock_acquire+0x79/0x93
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c0412a9c>] igmp6_group_added+0x56/0x11d
>                           [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>                           [<c0410100>] icmpv6_rcv+0x630/0x828
>                           [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>                           [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>                           [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>                           [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>                           [<c040279f>] addrconf_notify+0x60/0x7b7
>                           [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                           [<c0141de0>] mark_held_locks+0x39/0x53
>                           [<c04399ee>] mutex_lock_nested+0x286/0x2ac
>                           [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                           [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a490c>] register_netdevice_notifier+0x49/0x126
>                           [<c05c5be7>] addrconf_init+0xad/0x193
>                           [<c05c5b55>] addrconf_init+0x1b/0x193
>                           [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>                           [<c05a9499>] kernel_init+0x150/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c0104baf>] kernel_thread_helper+0x7/0x10
>                           [<ffffffff>] 0xffffffff
>   }
>   ... key      at: [<c0877804>] bonding_netdev_xmit_lock_key+0x0/0x8
>   -> (&bond->lock){-.--} ops: 103 {
>      initial-use  at:
>                             [<c013fe69>] put_lock_stats+0xa/0x1e
>                             [<c01428d0>] __lock_acquire+0x4ba/0xc07
>                             [<c0141de0>] mark_held_locks+0x39/0x53
>                             [<c043ad4d>] _spin_unlock_irqrestore+0x40/0x58
>                             [<c0143096>] lock_acquire+0x79/0x93
>                             [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                             [<c043a876>] _read_lock_bh+0x3b/0x64
>                             [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                             [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                             [<c03aad6b>] rtnl_fill_ifinfo+0x2bf/0x563
>                             [<c03ab2e9>] rtmsg_ifinfo+0x5d/0xdf
>                             [<c03ab3aa>] rtnetlink_event+0x3f/0x42
>                             [<c013ac54>] notifier_call_chain+0x2a/0x52
>                             [<c013ac9e>] raw_notifier_call_chain+0x17/0x1a
>                             [<c03a3b62>] register_netdevice+0x2a7/0x2e7
>                             [<c02ee292>] bond_create+0x1f2/0x26a
>                             [<c05bedda>] bonding_init+0x761/0x7ea
>                             [<c05be642>] e1000_init_module+0x45/0x7c
>                             [<c05a9499>] kernel_init+0x150/0x2b7
>                             [<c05a9349>] kernel_init+0x0/0x2b7
>                             [<c05a9349>] kernel_init+0x0/0x2b7
>                             [<c0104baf>] kernel_thread_helper+0x7/0x10
>                             [<ffffffff>] 0xffffffff
>      hardirq-on-W at:
>                             [<c014289e>] __lock_acquire+0x488/0xc07
>                             [<c0141de0>] mark_held_locks+0x39/0x53
>                             [<c043ad85>] _spin_unlock_irq+0x20/0x41
>                             [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                             [<c043ad90>] _spin_unlock_irq+0x2b/0x41
>                             [<c012208a>] finish_task_switch+0x50/0x8c
>                             [<c0143096>] lock_acquire+0x79/0x93
>                             [<c02ee4a5>] bond_set_multicast_list+0x1d/0x241
>                             [<c043a7ad>] _write_lock_bh+0x3b/0x64
>                             [<c02ee4a5>] bond_set_multicast_list+0x1d/0x241
>                             [<c02ee4a5>] bond_set_multicast_list+0x1d/0x241
>                             [<c013fe69>] put_lock_stats+0xa/0x1e
>                             [<c03a1e5f>] __dev_set_rx_mode+0x7b/0x7d
>                             [<c03a1ff9>] dev_set_rx_mode+0x23/0x36
>                             [<c03a46d4>] dev_open+0x5e/0x77
>                             [<c03a33a3>] dev_change_flags+0x9d/0x14b
>                             [<c03a21a7>] __dev_get_by_name+0x68/0x73
>                             [<c03e41d8>] devinet_ioctl+0x22b/0x536
>                             [<c03a44c9>] dev_ioctl+0x46f/0x5b7
>                             [<c039a5fc>] sock_ioctl+0x167/0x18b
>                             [<c039a495>] sock_ioctl+0x0/0x18b
>                             [<c0172f97>] do_ioctl+0x1f/0x62
>                             [<c0173207>] vfs_ioctl+0x22d/0x23f
>                             [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                             [<c017324c>] sys_ioctl+0x33/0x4b
>                             [<c0103e92>] sysenter_past_esp+0x5f/0xa5
>                             [<ffffffff>] 0xffffffff
>      softirq-on-R at:
>                             [<c01419ba>] mark_lock+0x64/0x451
>                             [<c0135792>] __kernel_text_address+0x5/0xe
>                             [<c0104ee2>] dump_trace+0x83/0x8d
>                             [<c01428bd>] __lock_acquire+0x4a7/0xc07
>                             [<c013fcaa>] save_trace+0x37/0x89
>                             [<c0133c8b>] run_workqueue+0x87/0x1b6
>                             [<c0143096>] lock_acquire+0x79/0x93
>                             [<c02ef88d>] bond_mii_monitor+0x19/0x85
>                             [<c043a8d5>] _read_lock+0x36/0x5f
>                             [<c02ef88d>] bond_mii_monitor+0x19/0x85
>                             [<c02ef88d>] bond_mii_monitor+0x19/0x85
>                             [<c0133cdf>] run_workqueue+0xdb/0x1b6
>                             [<c0133c8b>] run_workqueue+0x87/0x1b6
>                             [<c02ef874>] bond_mii_monitor+0x0/0x85
>                             [<c01346ff>] worker_thread+0x0/0x85
>                             [<c0134778>] worker_thread+0x79/0x85
>                             [<c01371ad>] autoremove_wake_function+0x0/0x35
>                             [<c01370f6>] kthread+0x38/0x5e
>                             [<c01370be>] kthread+0x0/0x5e
>                             [<c0104baf>] kernel_thread_helper+0x7/0x10
>                             [<ffffffff>] 0xffffffff
>      hardirq-on-R at:
>                             [<c013fe3e>] get_lock_stats+0xd/0x2e
>                             [<c013fe69>] put_lock_stats+0xa/0x1e
>                             [<c0142878>] __lock_acquire+0x462/0xc07
>                             [<c0141de0>] mark_held_locks+0x39/0x53
>                             [<c043ad4d>] _spin_unlock_irqrestore+0x40/0x58
>                             [<c0143096>] lock_acquire+0x79/0x93
>                             [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                             [<c043a876>] _read_lock_bh+0x3b/0x64
>                             [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                             [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                             [<c03aad6b>] rtnl_fill_ifinfo+0x2bf/0x563
>                             [<c03ab2e9>] rtmsg_ifinfo+0x5d/0xdf
>                             [<c03ab3aa>] rtnetlink_event+0x3f/0x42
>                             [<c013ac54>] notifier_call_chain+0x2a/0x52
>                             [<c013ac9e>] raw_notifier_call_chain+0x17/0x1a
>                             [<c03a3b62>] register_netdevice+0x2a7/0x2e7
>                             [<c02ee292>] bond_create+0x1f2/0x26a
>                             [<c05bedda>] bonding_init+0x761/0x7ea
>                             [<c05be642>] e1000_init_module+0x45/0x7c
>                             [<c05a9499>] kernel_init+0x150/0x2b7
>                             [<c05a9349>] kernel_init+0x0/0x2b7
>                             [<c05a9349>] kernel_init+0x0/0x2b7
>                             [<c0104baf>] kernel_thread_helper+0x7/0x10
>                             [<ffffffff>] 0xffffffff
>    }
>    ... key      at: [<c08777d0>] __key.32970+0x0/0x8
>    -> (_xmit_ETHER){-...} ops: 8 {
>       initial-use  at:
>                               [<c01428d0>] __lock_acquire+0x4ba/0xc07
>                               [<c0143096>] lock_acquire+0x79/0x93
>                               [<c03a6425>] dev_mc_add+0x1a/0x6a
>                               [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                               [<c03a6425>] dev_mc_add+0x1a/0x6a
>                               [<c03a6425>] dev_mc_add+0x1a/0x6a
>                               [<c0412a9c>] igmp6_group_added+0x56/0x11d
>                               [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>                               [<c0410100>] icmpv6_rcv+0x630/0x828
>                               [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>                               [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>                               [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>                               [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>                               [<c040279f>] addrconf_notify+0x60/0x7b7
>                               [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                               [<c0141de0>] mark_held_locks+0x39/0x53
>                               [<c04399ee>] mutex_lock_nested+0x286/0x2ac
>                               [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                               [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>                               [<c03a48d1>]
> register_netdevice_notifier+0xe/0x126
>                               [<c03a48d1>]
> register_netdevice_notifier+0xe/0x126
>                               [<c03a490c>]
> register_netdevice_notifier+0x49/0x126
>                               [<c05c5be7>] addrconf_init+0xad/0x193
>                               [<c05c5b55>] addrconf_init+0x1b/0x193
>                               [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>                               [<c05a9499>] kernel_init+0x150/0x2b7
>                               [<c05a9349>] kernel_init+0x0/0x2b7
>                               [<c05a9349>] kernel_init+0x0/0x2b7
>                               [<c0104baf>] kernel_thread_helper+0x7/0x10
>                               [<ffffffff>] 0xffffffff
>       hardirq-on-W at:
>                               [<c01419ba>] mark_lock+0x64/0x451
>                               [<c014289e>] __lock_acquire+0x488/0xc07
>                               [<c0143096>] lock_acquire+0x79/0x93
>                               [<c03a6425>] dev_mc_add+0x1a/0x6a
>                               [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                               [<c03a6425>] dev_mc_add+0x1a/0x6a
>                               [<c03a6425>] dev_mc_add+0x1a/0x6a
>                               [<c0412a9c>] igmp6_group_added+0x56/0x11d
>                               [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>                               [<c0410100>] icmpv6_rcv+0x630/0x828
>                               [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>                               [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>                               [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>                               [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>                               [<c040279f>] addrconf_notify+0x60/0x7b7
>                               [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                               [<c0141de0>] mark_held_locks+0x39/0x53
>                               [<c04399ee>] mutex_lock_nested+0x286/0x2ac
>                               [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                               [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>                               [<c03a48d1>]
> register_netdevice_notifier+0xe/0x126
>                               [<c03a48d1>]
> register_netdevice_notifier+0xe/0x126
>                               [<c03a490c>]
> register_netdevice_notifier+0x49/0x126
>                               [<c05c5be7>] addrconf_init+0xad/0x193
>                               [<c05c5b55>] addrconf_init+0x1b/0x193
>                               [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>                               [<c05a9499>] kernel_init+0x150/0x2b7
>                               [<c05a9349>] kernel_init+0x0/0x2b7
>                               [<c05a9349>] kernel_init+0x0/0x2b7
>                               [<c0104baf>] kernel_thread_helper+0x7/0x10
>                               [<ffffffff>] 0xffffffff
>     }
>     ... key      at: [<c087adc8>] netdev_xmit_lock_key+0x8/0x1c0
>    ... acquired at:
>    [<c0142e33>] __lock_acquire+0xa1d/0xc07
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c043ad4d>] _spin_unlock_irqrestore+0x40/0x58
>    [<c0109eee>] save_stack_trace+0x20/0x3a
>    [<c0143096>] lock_acquire+0x79/0x93
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c02eeec2>] bond_change_active_slave+0x1a9/0x3bf
>    [<c02ed1f3>] bond_update_speed_duplex+0x26/0x65
>    [<c02ef3df>] bond_select_active_slave+0x95/0xcd
>    [<c02edc5b>] bond_compute_features+0x45/0x84
>    [<c02f03ee>] bond_enslave+0x6a7/0x884
>    [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>    [<c02f6b98>] bonding_store_slaves+0x1ae/0x2fb
>    [<c02f69ea>] bonding_store_slaves+0x0/0x2fb
>    [<c02cf307>] dev_attr_store+0x27/0x2c
>    [<c019c6b5>] sysfs_write_file+0xad/0xe0
>    [<c019c608>] sysfs_write_file+0x0/0xe0
>    [<c0169770>] vfs_write+0x8a/0x10c
>    [<c0118566>] do_page_fault+0x0/0x54a
>    [<c0169cf5>] sys_write+0x41/0x67
>    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
>    [<ffffffff>] 0xffffffff
> 
>    -> (lweventlist_lock){.+..} ops: 10 {
>       initial-use  at:
>                               [<c01419ba>] mark_lock+0x64/0x451
>                               [<c01428d0>] __lock_acquire+0x4ba/0xc07
>                               [<c02e408c>] e1000_read_phy_reg+0x1c7/0x1d3
>                               [<c02e3ebb>] e1000_write_phy_reg+0xb9/0xc3
>                               [<c024b1de>] delay_tsc+0x25/0x3b
>                               [<c0143096>] lock_acquire+0x79/0x93
>                               [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                               [<c043aa07>] _spin_lock_irqsave+0x3f/0x6c
>                               [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                               [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                               [<c03ac53f>] linkwatch_fire_event+0x25/0x37
>                               [<c02e2673>] e1000_probe+0xad1/0xbe8
>                               [<c025893f>] pci_device_probe+0x36/0x57
>                               [<c02d188f>] driver_probe_device+0xe1/0x15f
>                               [<c043ac81>] _spin_unlock+0x25/0x3b
>                               [<c0437f3a>] klist_next+0x58/0x6d
>                               [<c02d199f>] __driver_attach+0x0/0x7f
>                               [<c02d19e8>] __driver_attach+0x49/0x7f
>                               [<c02d0e33>] bus_for_each_dev+0x36/0x58
>                               [<c02d16e7>] driver_attach+0x16/0x18
>                               [<c02d199f>] __driver_attach+0x0/0x7f
>                               [<c02d112a>] bus_add_driver+0x6d/0x18d
>                               [<c0258a89>] __pci_register_driver+0x53/0x7f
>                               [<c05be642>] e1000_init_module+0x45/0x7c
>                               [<c05a9499>] kernel_init+0x150/0x2b7
>                               [<c05a9349>] kernel_init+0x0/0x2b7
>                               [<c05a9349>] kernel_init+0x0/0x2b7
>                               [<c0104baf>] kernel_thread_helper+0x7/0x10
>                               [<ffffffff>] 0xffffffff
>       in-softirq-W at:
>                               [<c011d20a>] __wake_up_common+0x32/0x5c
>                               [<c0142856>] __lock_acquire+0x440/0xc07
>                               [<c043ad4d>] _spin_unlock_irqrestore+0x40/0x58
>                               [<c0143096>] lock_acquire+0x79/0x93
>                               [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                               [<c02e0931>] e1000_watchdog+0x0/0x5c9
>                               [<c043aa07>] _spin_lock_irqsave+0x3f/0x6c
>                               [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                               [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                               [<c03ac53f>] linkwatch_fire_event+0x25/0x37
>                               [<c03af4c6>] netif_carrier_on+0x16/0x27
>                               [<c02e0b86>] e1000_watchdog+0x255/0x5c9
>                               [<c02e0931>] e1000_watchdog+0x0/0x5c9
>                               [<c012df86>] run_timer_softirq+0xfa/0x15d
>                               [<c012a8da>] __do_softirq+0x56/0xdb
>                               [<c0141fbd>] trace_hardirqs_on+0x10c/0x14c
>                               [<c012a8ec>] __do_softirq+0x68/0xdb
>                               [<c012a995>] do_softirq+0x36/0x51
>                               [<c012ae7e>] local_bh_enable_ip+0xad/0xed
>                               [<c03bfa8b>] rt_run_flush+0x64/0x8b
>                               [<c03e82d4>] ip_mc_inc_group+0x184/0x1c1
>                               [<c03e8352>] ip_mc_up+0x41/0x59
>                               [<c03e3c8c>] inetdev_event+0x257/0x465
>                               [<c03ab286>] rtnl_notify+0x3a/0x40
>                               [<c03ab343>] rtmsg_ifinfo+0xb7/0xdf
>                               [<c013ac54>] notifier_call_chain+0x2a/0x52
>                               [<c013ac9e>] raw_notifier_call_chain+0x17/0x1a
>                               [<c03a46e7>] dev_open+0x71/0x77
>                               [<c02f0056>] bond_enslave+0x30f/0x884
>                               [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>                               [<c02f6b8c>] bonding_store_slaves+0x1a2/0x2fb
>                               [<c02f6b98>] bonding_store_slaves+0x1ae/0x2fb
>                               [<c02f69ea>] bonding_store_slaves+0x0/0x2fb
>                               [<c02cf307>] dev_attr_store+0x27/0x2c
>                               [<c019c6b5>] sysfs_write_file+0xad/0xe0
>                               [<c019c608>] sysfs_write_file+0x0/0xe0
>                               [<c0169770>] vfs_write+0x8a/0x10c
>                               [<c0118566>] do_page_fault+0x0/0x54a
>                               [<c0169cf5>] sys_write+0x41/0x67
>                               [<c0103e92>] sysenter_past_esp+0x5f/0xa5
>                               [<ffffffff>] 0xffffffff
>     }
>     ... key      at: [<c058a214>] lweventlist_lock+0x14/0x40
>    ... acquired at:
>    [<c0142e33>] __lock_acquire+0xa1d/0xc07
>    [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>    [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>    [<c0143096>] lock_acquire+0x79/0x93
>    [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>    [<c043aa07>] _spin_lock_irqsave+0x3f/0x6c
>    [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>    [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>    [<c03ac53f>] linkwatch_fire_event+0x25/0x37
>    [<c03af4c6>] netif_carrier_on+0x16/0x27
>    [<c02ee85c>] bond_set_carrier+0x31/0x55
>    [<c02ef3e6>] bond_select_active_slave+0x9c/0xcd
>    [<c02edc5b>] bond_compute_features+0x45/0x84
>    [<c02f03ee>] bond_enslave+0x6a7/0x884
>    [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>    [<c02f6b98>] bonding_store_slaves+0x1ae/0x2fb
>    [<c02f69ea>] bonding_store_slaves+0x0/0x2fb
>    [<c02cf307>] dev_attr_store+0x27/0x2c
>    [<c019c6b5>] sysfs_write_file+0xad/0xe0
>    [<c019c608>] sysfs_write_file+0x0/0xe0
>    [<c0169770>] vfs_write+0x8a/0x10c
>    [<c0118566>] do_page_fault+0x0/0x54a
>    [<c0169cf5>] sys_write+0x41/0x67
>    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
>    [<ffffffff>] 0xffffffff
> 
>   ... acquired at:
>    [<c0142e33>] __lock_acquire+0xa1d/0xc07
>    [<c02ee4a5>] bond_set_multicast_list+0x1d/0x241
>    [<c0141de0>] mark_held_locks+0x39/0x53
>    [<c0143096>] lock_acquire+0x79/0x93
>    [<c02ee4a5>] bond_set_multicast_list+0x1d/0x241
>    [<c043a7ad>] _write_lock_bh+0x3b/0x64
>    [<c02ee4a5>] bond_set_multicast_list+0x1d/0x241
>    [<c02ee4a5>] bond_set_multicast_list+0x1d/0x241
>    [<c013fe69>] put_lock_stats+0xa/0x1e
>    [<c03a1e5f>] __dev_set_rx_mode+0x7b/0x7d
>    [<c03a1ff9>] dev_set_rx_mode+0x23/0x36
>    [<c03a46d4>] dev_open+0x5e/0x77
>    [<c03a33a3>] dev_change_flags+0x9d/0x14b
>    [<c03a21a7>] __dev_get_by_name+0x68/0x73
>    [<c03e41d8>] devinet_ioctl+0x22b/0x536
>    [<c03a44c9>] dev_ioctl+0x46f/0x5b7
>    [<c039a5fc>] sock_ioctl+0x167/0x18b
>    [<c039a495>] sock_ioctl+0x0/0x18b
>    [<c0172f97>] do_ioctl+0x1f/0x62
>    [<c0173207>] vfs_ioctl+0x22d/0x23f
>    [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>    [<c017324c>] sys_ioctl+0x33/0x4b
>    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
>    [<ffffffff>] 0xffffffff
> 
>  ... acquired at:
>    [<c0142e33>] __lock_acquire+0xa1d/0xc07
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c0143096>] lock_acquire+0x79/0x93
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c0412a9c>] igmp6_group_added+0x56/0x11d
>    [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>    [<c0410100>] icmpv6_rcv+0x630/0x828
>    [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>    [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>    [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>    [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>    [<c040279f>] addrconf_notify+0x60/0x7b7
>    [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>    [<c0141de0>] mark_held_locks+0x39/0x53
>    [<c04399ee>] mutex_lock_nested+0x286/0x2ac
>    [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>    [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>    [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>    [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>    [<c03a490c>] register_netdevice_notifier+0x49/0x126
>    [<c05c5be7>] addrconf_init+0xad/0x193
>    [<c05c5b55>] addrconf_init+0x1b/0x193
>    [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>    [<c05a9499>] kernel_init+0x150/0x2b7
>    [<c05a9349>] kernel_init+0x0/0x2b7
>    [<c05a9349>] kernel_init+0x0/0x2b7
>    [<c0104baf>] kernel_thread_helper+0x7/0x10
>    [<ffffffff>] 0xffffffff
> 
> 
> the second lock's dependencies:
> -> (&bond->lock){-.--} ops: 103 {
>    initial-use  at:
>                         [<c013fe69>] put_lock_stats+0xa/0x1e
>                         [<c01428d0>] __lock_acquire+0x4ba/0xc07
>                         [<c0141de0>] mark_held_locks+0x39/0x53
>                         [<c043ad4d>] _spin_unlock_irqrestore+0x40/0x58
>                         [<c0143096>] lock_acquire+0x79/0x93
>                         [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                         [<c043a876>] _read_lock_bh+0x3b/0x64
>                         [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                         [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                         [<c03aad6b>] rtnl_fill_ifinfo+0x2bf/0x563
>                         [<c03ab2e9>] rtmsg_ifinfo+0x5d/0xdf
>                         [<c03ab3aa>] rtnetlink_event+0x3f/0x42
>                         [<c013ac54>] notifier_call_chain+0x2a/0x52
>                         [<c013ac9e>] raw_notifier_call_chain+0x17/0x1a
>                         [<c03a3b62>] register_netdevice+0x2a7/0x2e7
>                         [<c02ee292>] bond_create+0x1f2/0x26a
>                         [<c05bedda>] bonding_init+0x761/0x7ea
>                         [<c05be642>] e1000_init_module+0x45/0x7c
>                         [<c05a9499>] kernel_init+0x150/0x2b7
>                         [<c05a9349>] kernel_init+0x0/0x2b7
>                         [<c05a9349>] kernel_init+0x0/0x2b7
>                         [<c0104baf>] kernel_thread_helper+0x7/0x10
>                         [<ffffffff>] 0xffffffff
>    hardirq-on-W at:
>                         [<c014289e>] __lock_acquire+0x488/0xc07
>                         [<c0141de0>] mark_held_locks+0x39/0x53
>                         [<c043ad85>] _spin_unlock_irq+0x20/0x41
>                         [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                         [<c043ad90>] _spin_unlock_irq+0x2b/0x41
>                         [<c012208a>] finish_task_switch+0x50/0x8c
>                         [<c0143096>] lock_acquire+0x79/0x93
>                         [<c02ee4a5>] bond_set_multicast_list+0x1d/0x241
>                         [<c043a7ad>] _write_lock_bh+0x3b/0x64
>                         [<c02ee4a5>] bond_set_multicast_list+0x1d/0x241
>                         [<c02ee4a5>] bond_set_multicast_list+0x1d/0x241
>                         [<c013fe69>] put_lock_stats+0xa/0x1e
>                         [<c03a1e5f>] __dev_set_rx_mode+0x7b/0x7d
>                         [<c03a1ff9>] dev_set_rx_mode+0x23/0x36
>                         [<c03a46d4>] dev_open+0x5e/0x77
>                         [<c03a33a3>] dev_change_flags+0x9d/0x14b
>                         [<c03a21a7>] __dev_get_by_name+0x68/0x73
>                         [<c03e41d8>] devinet_ioctl+0x22b/0x536
>                         [<c03a44c9>] dev_ioctl+0x46f/0x5b7
>                         [<c039a5fc>] sock_ioctl+0x167/0x18b
>                         [<c039a495>] sock_ioctl+0x0/0x18b
>                         [<c0172f97>] do_ioctl+0x1f/0x62
>                         [<c0173207>] vfs_ioctl+0x22d/0x23f
>                         [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                         [<c017324c>] sys_ioctl+0x33/0x4b
>                         [<c0103e92>] sysenter_past_esp+0x5f/0xa5
>                         [<ffffffff>] 0xffffffff
>    softirq-on-R at:
>                         [<c01419ba>] mark_lock+0x64/0x451
>                         [<c0135792>] __kernel_text_address+0x5/0xe
>                         [<c0104ee2>] dump_trace+0x83/0x8d
>                         [<c01428bd>] __lock_acquire+0x4a7/0xc07
>                         [<c013fcaa>] save_trace+0x37/0x89
>                         [<c0133c8b>] run_workqueue+0x87/0x1b6
>                         [<c0143096>] lock_acquire+0x79/0x93
>                         [<c02ef88d>] bond_mii_monitor+0x19/0x85
>                         [<c043a8d5>] _read_lock+0x36/0x5f
>                         [<c02ef88d>] bond_mii_monitor+0x19/0x85
>                         [<c02ef88d>] bond_mii_monitor+0x19/0x85
>                         [<c0133cdf>] run_workqueue+0xdb/0x1b6
>                         [<c0133c8b>] run_workqueue+0x87/0x1b6
>                         [<c02ef874>] bond_mii_monitor+0x0/0x85
>                         [<c01346ff>] worker_thread+0x0/0x85
>                         [<c0134778>] worker_thread+0x79/0x85
>                         [<c01371ad>] autoremove_wake_function+0x0/0x35
>                         [<c01370f6>] kthread+0x38/0x5e
>                         [<c01370be>] kthread+0x0/0x5e
>                         [<c0104baf>] kernel_thread_helper+0x7/0x10
>                         [<ffffffff>] 0xffffffff
>    hardirq-on-R at:
>                         [<c013fe3e>] get_lock_stats+0xd/0x2e
>                         [<c013fe69>] put_lock_stats+0xa/0x1e
>                         [<c0142878>] __lock_acquire+0x462/0xc07
>                         [<c0141de0>] mark_held_locks+0x39/0x53
>                         [<c043ad4d>] _spin_unlock_irqrestore+0x40/0x58
>                         [<c0143096>] lock_acquire+0x79/0x93
>                         [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                         [<c043a876>] _read_lock_bh+0x3b/0x64
>                         [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                         [<c02ee6f1>] bond_get_stats+0x28/0xd0
>                         [<c03aad6b>] rtnl_fill_ifinfo+0x2bf/0x563
>                         [<c03ab2e9>] rtmsg_ifinfo+0x5d/0xdf
>                         [<c03ab3aa>] rtnetlink_event+0x3f/0x42
>                         [<c013ac54>] notifier_call_chain+0x2a/0x52
>                         [<c013ac9e>] raw_notifier_call_chain+0x17/0x1a
>                         [<c03a3b62>] register_netdevice+0x2a7/0x2e7
>                         [<c02ee292>] bond_create+0x1f2/0x26a
>                         [<c05bedda>] bonding_init+0x761/0x7ea
>                         [<c05be642>] e1000_init_module+0x45/0x7c
>                         [<c05a9499>] kernel_init+0x150/0x2b7
>                         [<c05a9349>] kernel_init+0x0/0x2b7
>                         [<c05a9349>] kernel_init+0x0/0x2b7
>                         [<c0104baf>] kernel_thread_helper+0x7/0x10
>                         [<ffffffff>] 0xffffffff
>  }
>  ... key      at: [<c08777d0>] __key.32970+0x0/0x8
>  -> (_xmit_ETHER){-...} ops: 8 {
>     initial-use  at:
>                           [<c01428d0>] __lock_acquire+0x4ba/0xc07
>                           [<c0143096>] lock_acquire+0x79/0x93
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c0412a9c>] igmp6_group_added+0x56/0x11d
>                           [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>                           [<c0410100>] icmpv6_rcv+0x630/0x828
>                           [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>                           [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>                           [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>                           [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>                           [<c040279f>] addrconf_notify+0x60/0x7b7
>                           [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                           [<c0141de0>] mark_held_locks+0x39/0x53
>                           [<c04399ee>] mutex_lock_nested+0x286/0x2ac
>                           [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                           [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a490c>] register_netdevice_notifier+0x49/0x126
>                           [<c05c5be7>] addrconf_init+0xad/0x193
>                           [<c05c5b55>] addrconf_init+0x1b/0x193
>                           [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>                           [<c05a9499>] kernel_init+0x150/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c0104baf>] kernel_thread_helper+0x7/0x10
>                           [<ffffffff>] 0xffffffff
>     hardirq-on-W at:
>                           [<c01419ba>] mark_lock+0x64/0x451
>                           [<c014289e>] __lock_acquire+0x488/0xc07
>                           [<c0143096>] lock_acquire+0x79/0x93
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c03a6425>] dev_mc_add+0x1a/0x6a
>                           [<c0412a9c>] igmp6_group_added+0x56/0x11d
>                           [<c0412e30>] ipv6_dev_mc_inc+0x2a3/0x31c
>                           [<c0410100>] icmpv6_rcv+0x630/0x828
>                           [<c0412e65>] ipv6_dev_mc_inc+0x2d8/0x31c
>                           [<c0412b8d>] ipv6_dev_mc_inc+0x0/0x31c
>                           [<c04021bc>] ipv6_add_dev+0x21c/0x24b
>                           [<c040ba05>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
>                           [<c040279f>] addrconf_notify+0x60/0x7b7
>                           [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>                           [<c0141de0>] mark_held_locks+0x39/0x53
>                           [<c04399ee>] mutex_lock_nested+0x286/0x2ac
>                           [<c0141fd3>] trace_hardirqs_on+0x122/0x14c
>                           [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a48d1>] register_netdevice_notifier+0xe/0x126
>                           [<c03a490c>] register_netdevice_notifier+0x49/0x126
>                           [<c05c5be7>] addrconf_init+0xad/0x193
>                           [<c05c5b55>] addrconf_init+0x1b/0x193
>                           [<c05c5a2d>] inet6_init+0x1f0/0x2ad
>                           [<c05a9499>] kernel_init+0x150/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c0104baf>] kernel_thread_helper+0x7/0x10
>                           [<ffffffff>] 0xffffffff
>   }
>   ... key      at: [<c087adc8>] netdev_xmit_lock_key+0x8/0x1c0
>  ... acquired at:
>    [<c0142e33>] __lock_acquire+0xa1d/0xc07
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c043ad4d>] _spin_unlock_irqrestore+0x40/0x58
>    [<c0109eee>] save_stack_trace+0x20/0x3a
>    [<c0143096>] lock_acquire+0x79/0x93
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c03a6425>] dev_mc_add+0x1a/0x6a
>    [<c02eeec2>] bond_change_active_slave+0x1a9/0x3bf
>    [<c02ed1f3>] bond_update_speed_duplex+0x26/0x65
>    [<c02ef3df>] bond_select_active_slave+0x95/0xcd
>    [<c02edc5b>] bond_compute_features+0x45/0x84
>    [<c02f03ee>] bond_enslave+0x6a7/0x884
>    [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>    [<c02f6b98>] bonding_store_slaves+0x1ae/0x2fb
>    [<c02f69ea>] bonding_store_slaves+0x0/0x2fb
>    [<c02cf307>] dev_attr_store+0x27/0x2c
>    [<c019c6b5>] sysfs_write_file+0xad/0xe0
>    [<c019c608>] sysfs_write_file+0x0/0xe0
>    [<c0169770>] vfs_write+0x8a/0x10c
>    [<c0118566>] do_page_fault+0x0/0x54a
>    [<c0169cf5>] sys_write+0x41/0x67
>    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
>    [<ffffffff>] 0xffffffff
> 
>  -> (lweventlist_lock){.+..} ops: 10 {
>     initial-use  at:
>                           [<c01419ba>] mark_lock+0x64/0x451
>                           [<c01428d0>] __lock_acquire+0x4ba/0xc07
>                           [<c02e408c>] e1000_read_phy_reg+0x1c7/0x1d3
>                           [<c02e3ebb>] e1000_write_phy_reg+0xb9/0xc3
>                           [<c024b1de>] delay_tsc+0x25/0x3b
>                           [<c0143096>] lock_acquire+0x79/0x93
>                           [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                           [<c043aa07>] _spin_lock_irqsave+0x3f/0x6c
>                           [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                           [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                           [<c03ac53f>] linkwatch_fire_event+0x25/0x37
>                           [<c02e2673>] e1000_probe+0xad1/0xbe8
>                           [<c025893f>] pci_device_probe+0x36/0x57
>                           [<c02d188f>] driver_probe_device+0xe1/0x15f
>                           [<c043ac81>] _spin_unlock+0x25/0x3b
>                           [<c0437f3a>] klist_next+0x58/0x6d
>                           [<c02d199f>] __driver_attach+0x0/0x7f
>                           [<c02d19e8>] __driver_attach+0x49/0x7f
>                           [<c02d0e33>] bus_for_each_dev+0x36/0x58
>                           [<c02d16e7>] driver_attach+0x16/0x18
>                           [<c02d199f>] __driver_attach+0x0/0x7f
>                           [<c02d112a>] bus_add_driver+0x6d/0x18d
>                           [<c0258a89>] __pci_register_driver+0x53/0x7f
>                           [<c05be642>] e1000_init_module+0x45/0x7c
>                           [<c05a9499>] kernel_init+0x150/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c05a9349>] kernel_init+0x0/0x2b7
>                           [<c0104baf>] kernel_thread_helper+0x7/0x10
>                           [<ffffffff>] 0xffffffff
>     in-softirq-W at:
>                           [<c011d20a>] __wake_up_common+0x32/0x5c
>                           [<c0142856>] __lock_acquire+0x440/0xc07
>                           [<c043ad4d>] _spin_unlock_irqrestore+0x40/0x58
>                           [<c0143096>] lock_acquire+0x79/0x93
>                           [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                           [<c02e0931>] e1000_watchdog+0x0/0x5c9
>                           [<c043aa07>] _spin_lock_irqsave+0x3f/0x6c
>                           [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                           [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>                           [<c03ac53f>] linkwatch_fire_event+0x25/0x37
>                           [<c03af4c6>] netif_carrier_on+0x16/0x27
>                           [<c02e0b86>] e1000_watchdog+0x255/0x5c9
>                           [<c02e0931>] e1000_watchdog+0x0/0x5c9
>                           [<c012df86>] run_timer_softirq+0xfa/0x15d
>                           [<c012a8da>] __do_softirq+0x56/0xdb
>                           [<c0141fbd>] trace_hardirqs_on+0x10c/0x14c
>                           [<c012a8ec>] __do_softirq+0x68/0xdb
>                           [<c012a995>] do_softirq+0x36/0x51
>                           [<c012ae7e>] local_bh_enable_ip+0xad/0xed
>                           [<c03bfa8b>] rt_run_flush+0x64/0x8b
>                           [<c03e82d4>] ip_mc_inc_group+0x184/0x1c1
>                           [<c03e8352>] ip_mc_up+0x41/0x59
>                           [<c03e3c8c>] inetdev_event+0x257/0x465
>                           [<c03ab286>] rtnl_notify+0x3a/0x40
>                           [<c03ab343>] rtmsg_ifinfo+0xb7/0xdf
>                           [<c013ac54>] notifier_call_chain+0x2a/0x52
>                           [<c013ac9e>] raw_notifier_call_chain+0x17/0x1a
>                           [<c03a46e7>] dev_open+0x71/0x77
>                           [<c02f0056>] bond_enslave+0x30f/0x884
>                           [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>                           [<c02f6b8c>] bonding_store_slaves+0x1a2/0x2fb
>                           [<c02f6b98>] bonding_store_slaves+0x1ae/0x2fb
>                           [<c02f69ea>] bonding_store_slaves+0x0/0x2fb
>                           [<c02cf307>] dev_attr_store+0x27/0x2c
>                           [<c019c6b5>] sysfs_write_file+0xad/0xe0
>                           [<c019c608>] sysfs_write_file+0x0/0xe0
>                           [<c0169770>] vfs_write+0x8a/0x10c
>                           [<c0118566>] do_page_fault+0x0/0x54a
>                           [<c0169cf5>] sys_write+0x41/0x67
>                           [<c0103e92>] sysenter_past_esp+0x5f/0xa5
>                           [<ffffffff>] 0xffffffff
>   }
>   ... key      at: [<c058a214>] lweventlist_lock+0x14/0x40
>  ... acquired at:
>    [<c0142e33>] __lock_acquire+0xa1d/0xc07
>    [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>    [<c0142fd5>] __lock_acquire+0xbbf/0xc07
>    [<c0143096>] lock_acquire+0x79/0x93
>    [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>    [<c043aa07>] _spin_lock_irqsave+0x3f/0x6c
>    [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>    [<c03ac47b>] linkwatch_add_event+0xd/0x2c
>    [<c03ac53f>] linkwatch_fire_event+0x25/0x37
>    [<c03af4c6>] netif_carrier_on+0x16/0x27
>    [<c02ee85c>] bond_set_carrier+0x31/0x55
>    [<c02ef3e6>] bond_select_active_slave+0x9c/0xcd
>    [<c02edc5b>] bond_compute_features+0x45/0x84
>    [<c02f03ee>] bond_enslave+0x6a7/0x884
>    [<c0439a0c>] mutex_lock_nested+0x2a4/0x2ac
>    [<c02f6b98>] bonding_store_slaves+0x1ae/0x2fb
>    [<c02f69ea>] bonding_store_slaves+0x0/0x2fb
>    [<c02cf307>] dev_attr_store+0x27/0x2c
>    [<c019c6b5>] sysfs_write_file+0xad/0xe0
>    [<c019c608>] sysfs_write_file+0x0/0xe0
>    [<c0169770>] vfs_write+0x8a/0x10c
>    [<c0118566>] do_page_fault+0x0/0x54a
>    [<c0169cf5>] sys_write+0x41/0x67
>    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
>    [<ffffffff>] 0xffffffff
> 
> 
> stack backtrace:
> Pid: 9, comm: events/0 Not tainted 2.6.24-rc4-git7 #1
>  [<c0140b6c>] print_irq_inversion_bug+0x108/0x112
>  [<c0141951>] check_usage_forwards+0x3c/0x41
>  [<c0141b3d>] mark_lock+0x1e7/0x451
>  [<c0142856>] __lock_acquire+0x440/0xc07
>  [<c0143096>] lock_acquire+0x79/0x93
>  [<c0412602>] mld_ifc_timer_expire+0x130/0x1fb
>  [<c04124d2>] mld_ifc_timer_expire+0x0/0x1fb
>  [<c043a6ea>] _spin_lock_bh+0x3b/0x64
>  [<c0412602>] mld_ifc_timer_expire+0x130/0x1fb
>  [<c0412602>] mld_ifc_timer_expire+0x130/0x1fb
>  [<c04124d2>] mld_ifc_timer_expire+0x0/0x1fb
>  [<c0141fbd>] trace_hardirqs_on+0x10c/0x14c
>  [<c04124d2>] mld_ifc_timer_expire+0x0/0x1fb
>  [<c012df86>] run_timer_softirq+0xfa/0x15d
>  [<c012a8da>] __do_softirq+0x56/0xdb
>  [<c0141fbd>] trace_hardirqs_on+0x10c/0x14c
>  [<c012a8ec>] __do_softirq+0x68/0xdb
>  [<c012a995>] do_softirq+0x36/0x51
>  [<c012ab3b>] irq_exit+0x43/0x4e
>  [<c011411e>] smp_apic_timer_interrupt+0x74/0x80
>  [<c012a8da>] __do_softirq+0x56/0xdb
>  [<c0104a01>] apic_timer_interrupt+0x29/0x38
>  [<c0104a0b>] apic_timer_interrupt+0x33/0x38
>  [<c03b007b>] nl_pid_hash_rehash+0xc1/0x13f
>  [<c03b00d8>] nl_pid_hash_rehash+0x11e/0x13f
>  [<c012aea0>] local_bh_enable_ip+0xcf/0xed
>  [<c03bfa8b>] rt_run_flush+0x64/0x8b
>  [<c03e9c1e>] fib_netdev_event+0x61/0x65
>  [<c013ac54>] notifier_call_chain+0x2a/0x52
>  [<c013ac9e>] raw_notifier_call_chain+0x17/0x1a
>  [<c03a3469>] netdev_state_change+0x18/0x29
>  [<c03ac6a1>] __linkwatch_run_queue+0x150/0x17e
>  [<c03ac6ec>] linkwatch_event+0x1d/0x22
>  [<c0133cdf>] run_workqueue+0xdb/0x1b6
>  [<c0133c8b>] run_workqueue+0x87/0x1b6
>  [<c03ac6cf>] linkwatch_event+0x0/0x22
>  [<c01346ff>] worker_thread+0x0/0x85
>  [<c0134778>] worker_thread+0x79/0x85
>  [<c01371ad>] autoremove_wake_function+0x0/0x35
>  [<c01370f6>] kthread+0x38/0x5e
>  [<c01370be>] kthread+0x0/0x5e
>  [<c0104baf>] kernel_thread_helper+0x7/0x10
>  =======================
> bonding: bond0: enslaving eth1 as a backup interface with a down link.
> bonding: bond0: Setting eth0 as primary slave.
> bond0: no IPv6 routers present
> 


