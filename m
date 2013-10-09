From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [BUG Linux 3.11] Bonding : possible circular locking dependency
 detected
Date: Wed, 9 Oct 2013 14:50:37 +0200
Message-ID: <20131009125037.GA22494@redhat.com>
References: <52554F10.9000904@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev <netdev@vger.kernel.org>
To: leroy christophe <christophe.leroy@c-s.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20357 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756322Ab3JIMwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Oct 2013 08:52:39 -0400
Content-Disposition: inline
In-Reply-To: <52554F10.9000904@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 09, 2013 at 02:41:52PM +0200, leroy christophe wrote:
>When configuring bonding in mode 1 with mii_status polling, I get the 
>following warning
>
>
>[  841.582838] ======================================================
>[  841.588946] [ INFO: possible circular locking dependency detected ]
>[  841.595168] 3.11.0-draft-drv-999-svn5204~_knld-999-svn5212 #220 
>Tainted: G        W
>[  841.602975] -------------------------------------------------------
>[  841.609184] kworker/0:2/747 is trying to acquire lock:
>[  841.614246]  (&bond->curr_slave_lock){++.+..}, at: [<c02654e4>] 
>bond_set_rx_mode+0xb4/0x10c

It should go away in fresh kernels. One patch that for sure fixes it:

b32418 bonding: RCUify bond_set_rx_mode()

However it might have been fixed even before that.

>[  841.622511]
>[  841.622511] but task is already holding lock:
>[  841.628274]  (&bonding_netdev_addr_lock_key){+.....}, at: 
>[<c02d9eb8>] __dev_mc_add+0x3c/0x90
>[  841.636711]
>[  841.636711] which lock already depends on the new lock.
>[  841.636711]
>[  841.644799]
>[  841.644799] the existing dependency chain (in reverse order) is:
>[  841.652201]
>-> #1 (&bonding_netdev_addr_lock_key){+.....}:
>[  841.657792]        [<c006fb38>] __lock_acquire+0x394/0xb8c
>[  841.663216]        [<c00703e4>] lock_acquire+0xb4/0x16c
>[  841.668379]        [<c0404dcc>] _raw_spin_lock_bh+0x54/0x70
>[  841.673886]        [<c02674fc>] bond_change_active_slave+0x278/0x5d0
>[  841.680169]        [<c02678f8>] bond_select_active_slave+0xa4/0x1c4
>[  841.686365]        [<c0267ebc>] bond_mii_monitor+0x4a4/0x6e0
>[  841.691960]        [<c0039acc>] process_one_work+0x204/0x5ac
>[  841.697554]        [<c0039fcc>] worker_thread+0x158/0x43c
>[  841.702889]        [<c0043310>] kthread+0xc8/0xcc
>[  841.707536]        [<c000ea18>] ret_from_kernel_thread+0x5c/0x64
>[  841.713483]
>-> #0 (&bond->curr_slave_lock){++.+..}:
>[  841.718463]        [<c006f5f4>] validate_chain+0xec4/0x1074
>[  841.723974]        [<c006fb38>] __lock_acquire+0x394/0xb8c
>[  841.729396]        [<c00703e4>] lock_acquire+0xb4/0x16c
>[  841.734560]        [<c040540c>] _raw_read_lock+0x50/0x6c
>[  841.739809]        [<c02654e4>] bond_set_rx_mode+0xb4/0x10c
>[  841.745318]        [<c02ce428>] __dev_set_rx_mode+0x80/0xd0
>[  841.750825]        [<c02d9ee4>] __dev_mc_add+0x68/0x90
>[  841.755902]        [<c02d9f5c>] dev_mc_add+0x20/0x30
>[  841.760808]        [<c03ac1d4>] igmp6_group_added+0x108/0x1e4
>[  841.766488]        [<c03ac2f4>] ipv6_mc_up+0x44/0x70
>[  841.771393]        [<c038e0cc>] ipv6_find_idev+0x58/0xb0
>[  841.776643]        [<c038e15c>] addrconf_add_dev+0x38/0xc0
>[  841.782065]        [<c0390ec0>] addrconf_notify+0x2b8/0x978
>[  841.787572]        [<c004a974>] notifier_call_chain+0x78/0xdc
>[  841.793252]        [<c004ab08>] raw_notifier_call_chain+0x24/0x34
>[  841.799277]        [<c02d2430>] call_netdevice_notifiers_info+0x74/0x90
>[  841.805818]        [<c02d246c>] call_netdevice_notifiers+0x20/0x30
>[  841.811928]        [<c02d380c>] netdev_state_change+0x38/0x5c
>[  841.817608]        [<c02e6804>] linkwatch_do_dev+0x64/0xa8
>[  841.823031]        [<c02e6c7c>] __linkwatch_run_queue+0x10c/0x214
>[  841.829054]        [<c02e6dbc>] linkwatch_event+0x38/0x4c
>[  841.834390]        [<c0039acc>] process_one_work+0x204/0x5ac
>[  841.839984]        [<c0039fcc>] worker_thread+0x158/0x43c
>[  841.845320]        [<c0043310>] kthread+0xc8/0xcc
>[  841.849966]        [<c000ea18>] ret_from_kernel_thread+0x5c/0x64
>[  841.855908]
>[  841.855908] other info that might help us debug this:
>[  841.855908]
>[  841.863824]  Possible unsafe locking scenario:
>[  841.863824]
>[  841.869674]        CPU0                    CPU1
>[  841.874149]        ----                    ----
>[  841.878620]   lock(&bonding_netdev_addr_lock_key);
>[  841.883352] lock(&bond->curr_slave_lock);
>[  841.889979] lock(&bonding_netdev_addr_lock_key);
>[  841.897206]   lock(&bond->curr_slave_lock);
>[  841.901340]
>[  841.901340]  *** DEADLOCK ***
>[  841.901340]
>[  841.907217] 7 locks held by kworker/0:2/747:
>[  841.911416]  #0:  (events){.+.+..}, at: [<c0039a44>] 
>process_one_work+0x17c/0x5ac
>[  841.918822]  #1:  ((linkwatch_work).work){+.+...}, at: 
>[<c0039a44>] process_one_work+0x17c/0x5ac
>[  841.927515]  #2:  (rtnl_mutex){+.+.+.}, at: [<c02e4ae0>] 
>rtnl_lock+0x28/0x38
>[  841.934486]  #3:  (&ndev->lock){++--..}, at: [<c03ac2e0>] 
>ipv6_mc_up+0x30/0x70
>[  841.941627]  #4: (&(&mc->mca_lock)->rlock){+.-...}, at: 
>[<c03ac120>] igmp6_group_added+0x54/0x1e4
>[  841.950492]  #5:  (&bonding_netdev_addr_lock_key){+.....}, at: 
>[<c02d9eb8>] __dev_mc_add+0x3c/0x90
>[  841.959356]  #6:  (&bond->lock){++.?..}, at: [<c0265470>] 
>bond_set_rx_mode+0x40/0x10c
>[  841.967097]
>[  841.967097] stack backtrace:
>[  841.971448] CPU: 0 PID: 747 Comm: kworker/0:2 Tainted: G W    
>3.11.0-draft-drv-999-svn5204~_knld-999-svn5212 #220
>[  841.982222] Workqueue: events linkwatch_event
>[  841.986457] Call Trace:
>[  841.988931] [c7b71a00] [c0007198] show_stack+0xa8/0x238 (unreliable)
>[  841.995210] [c7b71a50] [c0405e8c] dump_stack+0x24/0x198
>[  842.000390] [c7b71a60] [c006dec8] print_circular_bug+0x1f8/0x320
>[  842.006313] [c7b71a90] [c006f5f4] validate_chain+0xec4/0x1074
>[  842.011993] [c7b71b20] [c006fb38] __lock_acquire+0x394/0xb8c
>[  842.017585] [c7b71b80] [c00703e4] lock_acquire+0xb4/0x16c
>[  842.022916] [c7b71bc0] [c040540c] _raw_read_lock+0x50/0x6c
>[  842.028352] [c7b71be0] [c02654e4] bond_set_rx_mode+0xb4/0x10c
>[  842.034029] [c7b71c00] [c02ce428] __dev_set_rx_mode+0x80/0xd0
>[  842.039698] [c7b71c20] [c02d9ee4] __dev_mc_add+0x68/0x90
>[  842.044945] [c7b71c40] [c02d9f5c] dev_mc_add+0x20/0x30
>[  842.050031] [c7b71c50] [c03ac1d4] igmp6_group_added+0x108/0x1e4
>[  842.055872] [c7b71c90] [c03ac2f4] ipv6_mc_up+0x44/0x70
>[  842.060958] [c7b71ca0] [c038e0cc] ipv6_find_idev+0x58/0xb0
>[  842.066373] [c7b71cb0] [c038e15c] addrconf_add_dev+0x38/0xc0
>[  842.071970] [c7b71cc0] [c0390ec0] addrconf_notify+0x2b8/0x978
>[  842.077652] [c7b71d60] [c004a974] notifier_call_chain+0x78/0xdc
>[  842.083501] [c7b71d90] [c004ab08] raw_notifier_call_chain+0x24/0x34
>[  842.089716] [c7b71da0] [c02d2430] call_netdevice_notifiers_info+0x74/0x90
>[  842.096416] [c7b71dc0] [c02d246c] call_netdevice_notifiers+0x20/0x30
>[  842.102699] [c7b71de0] [c02d380c] netdev_state_change+0x38/0x5c
>[  842.108567] [c7b71df0] [c02e6804] linkwatch_do_dev+0x64/0xa8
>[  842.114148] [c7b71e00] [c02e6c7c] __linkwatch_run_queue+0x10c/0x214
>[  842.120342] [c7b71e30] [c02e6dbc] linkwatch_event+0x38/0x4c
>[  842.125858] [c7b71e40] [c0039acc] process_one_work+0x204/0x5ac
>[  842.131611] [c7b71e80] [c0039fcc] worker_thread+0x158/0x43c
>[  842.137117] [c7b71eb0] [c0043310] kthread+0xc8/0xcc
>[  842.141943] [c7b71f40] [c000ea18] ret_from_kernel_thread+0x5c/0x64
>
>Christophe
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
