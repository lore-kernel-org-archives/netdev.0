From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [BUG] RTNL assert fail via addrconf_join_solicit
Date: Sat, 15 Mar 2014 17:04:13 +0100
Message-ID: <20140315160413.GB12291@order.stressinduktion.org>
References: <20140314184214.34ae9bfb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38056 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754318AbaCOQEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 12:04:14 -0400
Content-Disposition: inline
In-Reply-To: <20140314184214.34ae9bfb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 06:42:14PM -0700, Stephen Hemminger wrote:
> When doing VRRP which uses macvlan and multicast, we see the following
> kernel assertion error.  This is on 3.10.33 but looks like no changes
> in this area in recent kernels.
> 
> 
> [  541.030090] RTNL: assertion failed at net/core/dev.c (4496)
> [  541.031143] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O 3.10.33-1-amd64-vyatta #1
> [  541.031145] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [  541.031146]  ffffffff8148a9f0 000000000000002f ffffffff813c98c1 ffff88007c4451f8
> [  541.031148]  0000000000000000 0000000000000000 ffffffff813d3540 ffff88007fc03d18
> [  541.031150]  0000880000000006 ffff88007c445000 ffffffffa0194160 0000000000000000
> [  541.031152] Call Trace:
> [  541.031153]  <IRQ>  [<ffffffff8148a9f0>] ? dump_stack+0xd/0x17
> [  541.031180]  [<ffffffff813c98c1>] ? __dev_set_promiscuity+0x101/0x180
> [  541.031183]  [<ffffffff813d3540>] ? __hw_addr_create_ex+0x60/0xc0
> [  541.031185]  [<ffffffff813cfe1a>] ? __dev_set_rx_mode+0xaa/0xc0
> [  541.031189]  [<ffffffff813d3a81>] ? __dev_mc_add+0x61/0x90
> [  541.031198]  [<ffffffffa01dcf9c>] ? igmp6_group_added+0xfc/0x1a0 [ipv6]
> [  541.031208]  [<ffffffff8111237b>] ? kmem_cache_alloc+0xcb/0xd0
> [  541.031212]  [<ffffffffa01ddcd7>] ? ipv6_dev_mc_inc+0x267/0x300 [ipv6]
> [  541.031216]  [<ffffffffa01c2fae>] ? addrconf_join_solict+0x2e/0x40 [ipv6]
> [  541.031219]  [<ffffffffa01ba2e9>] ? ipv6_dev_ac_inc+0x159/0x1f0 [ipv6]
> [  541.031223]  [<ffffffffa01c0772>] ? addrconf_join_anycast+0x92/0xa0 [ipv6]
> [  541.031226]  [<ffffffffa01c311e>] ? __ipv6_ifa_notify+0x11e/0x1e0 [ipv6]
> [  541.031229]  [<ffffffffa01c3213>] ? ipv6_ifa_notify+0x33/0x50 [ipv6]
> [  541.031233]  [<ffffffffa01c36c8>] ? addrconf_dad_completed+0x28/0x100 [ipv6]
> [  541.031241]  [<ffffffff81075c1d>] ? task_cputime+0x2d/0x50
> [  541.031244]  [<ffffffffa01c38d6>] ? addrconf_dad_timer+0x136/0x150 [ipv6]
> [  541.031247]  [<ffffffffa01c37a0>] ? addrconf_dad_completed+0x100/0x100 [ipv6]
> [  541.031255]  [<ffffffff8105313a>] ? call_timer_fn.isra.22+0x2a/0x90
> [  541.031258]  [<ffffffffa01c37a0>] ? addrconf_dad_completed+0x100/0x100 [ipv6]
> [  541.031261]  [<ffffffff81053531>] ? run_timer_softirq+0x1a1/0x260
> [  541.031267]  [<ffffffff810350cf>] ? kvm_clock_read+0x1f/0x30
> [  541.031272]  [<ffffffff810132a5>] ? sched_clock+0x5/0x10
> [  541.031274]  [<ffffffff81074bd5>] ? sched_clock_local+0x15/0x80
> [  541.031276]  [<ffffffff8104d586>] ? __do_softirq+0xd6/0x1b0
> [  541.031282]  [<ffffffff8149109c>] ? call_softirq+0x1c/0x30
> [  541.031284]  [<ffffffff8100d835>] ? do_softirq+0x75/0xb0
> [  541.031286]  [<ffffffff8104d7ed>] ? irq_exit+0xbd/0xc0
> 
> 
> Also it looks like ipv6 anycast has same potential issue of changing
> unicast filters without holding rtnl_lock.
>  ipv6_ac_inc -> addrconf_join_solict ->  ipv6_dev_mc_inc

Hmm, that's quite difficult to resolve, I think.

Either we make the code paths not depend on RTNL lock or we need to
defer the action somehow and issue those commands down to the hardware
befor unlocking rtnl mutex (like netdev_run_todo).
