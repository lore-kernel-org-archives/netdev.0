From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: lockdep report from bonding.
Date: Wed, 3 Oct 2007 16:50:25 -0400
Message-ID: <20071003205024.GG9140@gospo.rdu.redhat.com>
References: <20071003170514.GA32239@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754130AbXJCUu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 16:50:26 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id l93KoQwc028074
	for <netdev@vger.kernel.org>; Wed, 3 Oct 2007 16:50:26 -0400
Content-Disposition: inline
In-Reply-To: <20071003170514.GA32239@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 03, 2007 at 01:05:14PM -0400, Dave Jones wrote:
> Reported by a Fedora user this morning.
> 
> Ethernet Channel Bonding Driver: v3.1.3 (June 13, 2007)
> bonding: MII link monitoring set to 100 ms
> ADDRCONF(NETDEV_UP): bond0: link is not ready
> bonding: bond0: Adding slave eth0.
> e100: eth0: e100_watchdog: link up, 100Mbps, full-duplex
> bonding: bond0: making interface eth0 the new active one.
> bonding: bond0: enslaving eth0 as an active interface with an up link.
> 
> =================================
> [ INFO: inconsistent lock state ]
> 2.6.23-0.214.rc8.git2.fc8 #1
> ---------------------------------
> inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> events/1/10 [HC0[0]:SC1[1]:HE1:SE0] takes:
>  (&(bond_info->tx_hashtbl_lock)){-+..}, at: [<f8ad154c>] tlb_clear_slave+0x1d/0x9a [bonding]
> {softirq-on-W} state was registered at:
>   [<c0449fb0>] __lock_acquire+0x4ff/0xc67
>   [<c044ab92>] lock_acquire+0x7b/0x9e
>   [<c0633050>] _spin_lock+0x2e/0x58
>   [<f8ad293a>] bond_alb_initialize+0x64/0x18e [bonding]
>   [<f8acf25f>] bond_open+0x33/0x178 [bonding]
>   [<c05ceb36>] dev_open+0x31/0x6c
>   [<c05ccc8d>] dev_change_flags+0xa3/0x156
>   [<c060d579>] devinet_ioctl+0x207/0x50e
>   [<c060dc27>] inet_ioctl+0x86/0xa4
>   [<c05c2e62>] sock_ioctl+0x1ac/0x1c9
>   [<c04942a2>] do_ioctl+0x22/0x68
>   [<c0494531>] vfs_ioctl+0x249/0x25c
>   [<c049458d>] sys_ioctl+0x49/0x64
>   [<c040522e>] syscall_call+0x7/0xb
>   [<ffffffff>] 0xffffffff
> irq event stamp: 40878
> hardirqs last  enabled at (40878): [<c0633474>] _spin_unlock_irq+0x22/0x2f
> hardirqs last disabled at (40877): [<c063339d>] _spin_lock_irq+0x19/0x67
> softirqs last  enabled at (40872): [<c05e6fcf>] rt_run_flush+0x6e/0x97
> softirqs last disabled at (40873): [<c04075d4>] do_softirq+0x74/0xf7
> 
> other info that might help us debug this:
> 3 locks held by events/1/10:
>  #0:  (rtnl_mutex){--..}, at: [<c0631c31>] mutex_lock+0x21/0x24
>  #1:  (&bond->lock){-.-+}, at: [<f8ad25ed>] bond_alb_monitor+0x16/0x26e [bonding]
>  #2:  (&bond->curr_slave_lock){..-+}, at: [<f8ad2680>] bond_alb_monitor+0xa9/0x26e [bonding]
> 
> stack backtrace:
>  [<c0406463>] show_trace_log_lvl+0x1a/0x2f
>  [<c0406e4d>] show_trace+0x12/0x14
>  [<c0406e65>] dump_stack+0x16/0x18
>  [<c0448856>] print_usage_bug+0x141/0x14b
>  [<c04490dc>] mark_lock+0x12f/0x472
>  [<c0449f38>] __lock_acquire+0x487/0xc67
>  [<c044ab92>] lock_acquire+0x7b/0x9e
>  [<c0633050>] _spin_lock+0x2e/0x58
>  [<f8ad154c>] tlb_clear_slave+0x1d/0x9a [bonding]
>  [<f8ad269a>] bond_alb_monitor+0xc3/0x26e [bonding]
>  [<c043541b>] run_timer_softirq+0x127/0x18f
>  [<c0432a21>] __do_softirq+0x78/0xff
>  [<c04075d4>] do_softirq+0x74/0xf7
>  =======================
> ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
> bonding: bond0: Adding slave eth1.
> 


This isn't surprising and rears it's head every once in a while.  It
probably becomes more apparent on faster, multiprocessor systems.  The
big bonding-workqueue conversion patch that Jay and I have been testing
for a while should resolve this one too (since it moves the monitoring
out of softirq context *and* it switches the hashtbl locks to _bh ones
along with a bunch of other changes).



