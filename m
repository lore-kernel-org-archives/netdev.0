From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Fri, 28 May 2010 17:42:29 -0300
Message-ID: <20100528204229.GD2345@sysclose.org>
References: <20100505081514.5157.83783.sendpatchset@localhost.localdomain>
 <20100527180545.GA2345@sysclose.org>
 <4BFF7BE2.6020503@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcahe.dreamhost.com ([208.97.132.74]:44834 "EHLO
	homiemail-a13.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756766Ab0E1Umj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 16:42:39 -0400
Content-Disposition: inline
In-Reply-To: <4BFF7BE2.6020503@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 28, 2010 at 04:16:34PM +0800, Cong Wang wrote:
> On 05/28/10 02:05, Flavio Leitner wrote:
> >
> >Hi guys!
> >
> >I finally could test this to see if an old problem reported on bugzilla[1] was
> >fixed now, but unfortunately it is still there.
> >
> >The ticket is private I guess, but basically the problem happens when bonding
> >driver tries to print something after it had taken the write_lock (monitor
> >functions, enslave/de-enslave), so the printk() will pass through netpoll, then
> >on bonding again which no matter what mode you use, it will try to read_lock()
> >the lock again. The result is a deadlock and the entire system hangs.
> >
> 
> Does the attached patch fix this hang?

I got another issue now:

[   89.523062] bonding: bond0: enslaving eth0 as a backup interface with a down link.
[   89.580746] bonding: bond0: enslaving eth2 as a backup interface with a down link.
[   91.198527] e1000: eth2 NIC Link is Up 100 Mbps Half Duplex, Flow Control: None
[   91.238245] bonding: bond0: link status definitely up for interface eth2.

[   91.245381] BUG: scheduling while atomic: bond0/2716/0x10000100
[   91.251565] 5 locks held by bond0/2716:
[   91.255663]  #0:  ((bond_dev->name)){+.+.+.}, at: [<ffffffff81045fb4>] worker_thread+0x19a/0x2e2
[   91.265179]  #1:  ((&(&bond->mii_work)->work)){+.+.+.}, at: [<ffffffff81045fb4>] worker_thread+0x19a/0x2e2
[   91.275554]  #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff812daf38>] rtnl_lock+0x12/0x14
[   91.284018]  #3:  (&bond->lock){++.+.+}, at: [<ffffffffa029e06a>] bond_mii_monitor+0x2a2/0x4ed [bonding]
[   91.294230]  #4:  (&bond->curr_slave_lock){+...+.}, at: [<ffffffffa029e239>] bond_mii_monitor+0x471/0x4ed [bonding]
[   91.305387] Modules linked in: bonding sunrpc ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 dm_mirror dm_region_hash dm_log dm_multipath uinput snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ppdev parport_pc parport rtc_cmos snd_timer tg3 snd ide_cd_mod i5000_edac i2c_i801 libphy rtc_core rtc_lib edac_core pcspkr e1000 dcdbas uhci_hcd tulip shpchp i2c_core cdrom serio_raw soundcore sg snd_page_alloc raid0 sd_mod button [last unloaded: mperf]
[   91.357735] Pid: 2716, comm: bond0 Not tainted 2.6.34-04700-gd938a70-dirty #36
[   91.371112] Call Trace:
[   91.373825]  [<ffffffff81056002>] ? __debug_show_held_locks+0x22/0x24
[   91.380530]  [<ffffffff8102e4a2>] __schedule_bug+0x6d/0x72
[   91.386284]  [<ffffffff81363f6e>] schedule+0xc9/0x791
[   91.391600]  [<ffffffff81032540>] __cond_resched+0x25/0x30
[   91.397350]  [<ffffffff81364757>] _cond_resched+0x27/0x32
[   91.403013]  [<ffffffff810ab243>] kmem_cache_alloc+0x2b/0xac
[   91.408936]  [<ffffffff812c61fd>] skb_clone+0x42/0x5d
[   91.414253]  [<ffffffff812ec696>] netlink_broadcast+0x192/0x369
[   91.420436]  [<ffffffff812ecdc3>] nlmsg_notify+0x43/0x89
[   91.426012]  [<ffffffff812dabc7>] rtnl_notify+0x2b/0x2d
[   91.431501]  [<ffffffff812dacbc>] rtmsg_ifinfo+0xf3/0x118
[   91.437165]  [<ffffffff812dad0c>] rtnetlink_event+0x2b/0x2f
[   91.443003]  [<ffffffff81369fe4>] notifier_call_chain+0x32/0x5e
[   91.449188]  [<ffffffff8104d618>] raw_notifier_call_chain+0xf/0x11
[   91.455634]  [<ffffffff812cfc73>] call_netdevice_notifiers+0x45/0x4a
[   91.462253]  [<ffffffff812d04f7>] netdev_bonding_change+0x12/0x14
[   91.468614]  [<ffffffffa029d589>] bond_select_active_slave+0xe8/0x123 [bonding]
[   91.476408]  [<ffffffffa029e241>] bond_mii_monitor+0x479/0x4ed [bonding]
[   91.483375]  [<ffffffff81046009>] worker_thread+0x1ef/0x2e2
[   91.489212]  [<ffffffff81045fb4>] ? worker_thread+0x19a/0x2e2
[   91.495227]  [<ffffffffa029ddc8>] ? bond_mii_monitor+0x0/0x4ed [bonding]
[   91.502192]  [<ffffffff81049c71>] ? autoremove_wake_function+0x0/0x34
[   91.508897]  [<ffffffff81045e1a>] ? worker_thread+0x0/0x2e2
[   91.514734]  [<ffffffff810498bb>] kthread+0x7a/0x82
[   91.519878]  [<ffffffff81003714>] kernel_thread_helper+0x4/0x10
[   91.526060]  [<ffffffff81366ffc>] ? restore_args+0x0/0x30
[   91.531723]  [<ffffffff81049841>] ? kthread+0x0/0x82
[   91.536953]  [<ffffffff81003710>] ? kernel_thread_helper+0x0/0x10
[   91.543343] bonding: bond0: making interface eth2 the new active one.
[   91.550554] bonding: bond0: first active interface up!
[   91.556859] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready


No other patch applied. Just started netconsole over bonding, so no need
to pull the cable from slaves. Reproduced twice, one I got the
backtrace above, and on the other one the system hangs completely 
after the BUG: scheduling message.

fbl


> 
> Thanks!
> 
> ----------------------->
> 
> We should notify netconsole that bond is changing its slaves
> when we use active-backup mode.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> 
> ----
> 

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 5e12462..9494c02 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1199,6 +1199,7 @@ void bond_select_active_slave(struct bonding *bond)
>  
>  	best_slave = bond_find_best_slave(bond);
>  	if (best_slave != bond->curr_active_slave) {
> +		netdev_bonding_change(bond->dev, NETDEV_BONDING_DESLAVE);
>  		bond_change_active_slave(bond, best_slave);
>  		rv = bond_set_carrier(bond);
>  		if (!rv)
> @@ -2154,6 +2155,7 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
>  	    (old_active) &&
>  	    (new_active->link == BOND_LINK_UP) &&
>  	    IS_UP(new_active->dev)) {
> +		netdev_bonding_change(bond->dev, NETDEV_BONDING_DESLAVE);
>  		write_lock_bh(&bond->curr_slave_lock);
>  		bond_change_active_slave(bond, new_active);
>  		write_unlock_bh(&bond->curr_slave_lock);


-- 
Flavio
