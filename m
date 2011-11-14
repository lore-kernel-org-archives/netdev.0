From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net-next V8] net: introduce ethernet teaming device
Date: Mon, 14 Nov 2011 12:18:40 -0500
Message-ID: <20111114171840.GD20605@gospo.rdu.redhat.com>
References: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	fbl@redhat.com, benjamin.poirier@gmail.com, jzupka@redhat.com,
	ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751719Ab1KNRT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 12:19:26 -0500
Content-Disposition: inline
In-Reply-To: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 12, 2011 at 09:16:48AM +0100, Jiri Pirko wrote:
> This patch introduces new network device called team. It supposes to be
> very fast, simple, userspace-driven alternative to existing bonding
> driver.
> 
> Userspace library called libteam with couple of demo apps is available
> here:
> https://github.com/jpirko/libteam
> Note it's still in its dipers atm.
> 
> team<->libteam use generic netlink for communication. That and rtnl
> suppose to be the only way to configure team device, no sysfs etc.
> 
> Python binding of libteam was recently introduced.
> Daemon providing arpmon/miimon active-backup functionality will be
> introduced shortly. All what's necessary is already implemented in
> kernel team driver.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> v7->v8:
> 	- check ndo_ndo_vlan_rx_[add/kill]_vid functions before calling
> 	  them.
> 	- use dev_kfree_skb_any() instead of dev_kfree_skb()
> 
> v6->v7:
> 	- transmit and receive functions are not checked in hot paths.
> 	  That also resolves memory leak on transmit when no port is
> 	  present
> 
> v5->v6:
> 	- changed couple of _rcu calls to non _rcu ones in non-readers
> 
> v4->v5:
> 	- team_change_mtu() uses team->lock while travesing though port
> 	  list
> 	- mac address changes are moved completely to jurisdiction of
> 	  userspace daemon. This way the daemon can do FOM1, FOM2 and
> 	  possibly other weird things with mac addresses.
> 	  Only round-robin mode sets up all ports to bond's address then
> 	  enslaved.
> 	- Extended Kconfig text
> 
> v3->v4:
> 	- remove redundant synchronize_rcu from __team_change_mode()
> 	- revert "set and clear of mode_ops happens per pointer, not per
> 	  byte"
> 	- extend comment of function __team_change_mode()
> 
> v2->v3:
> 	- team_change_mtu() uses rcu version of list traversal to unwind
> 	- set and clear of mode_ops happens per pointer, not per byte
> 	- port hashlist changed to be embedded into team structure
> 	- error branch in team_port_enter() does cleanup now
> 	- fixed rtln->rtnl
> 
> v1->v2:
> 	- modes are made as modules. Makes team more modular and
> 	  extendable.
> 	- several commenters' nitpicks found on v1 were fixed
> 	- several other bugs were fixed.
> 	- note I ignored Eric's comment about roundrobin port selector
> 	  as Eric's way may be easily implemented as another mode (mode
> 	  "random") in future.

You better get ready for v9.

Running the command:

# team_manual_control team0 set mode roundrobin

on a system with team0 running in roundrobin mode produces this:

[ 2127.785321] BUG: unable to handle kernel NULL pointer dereference at           (null)
[ 2127.788079] IP: [<ffffffffa0196edd>] team_nl_fill_options_get_changed+0xc5/0x240 [team]
[ 2127.790847] PGD 13eecf067 PUD 13f758067 PMD 0 
[ 2127.793603] Oops: 0000 [#1] SMP 
[ 2127.796352] CPU 7 
[ 2127.796370] Modules linked in: team_mode_roundrobin(O) team(O) fcoe libfcoe libfc scsi_transport_fc scsi_tgt 8021q garp stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables xt_state nf_conntrack snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device i2c_i801 joydev microcode shpchp snd_pcm snd_timer snd soundcore snd_page_alloc bnx2 iTCO_wdt iTCO_vendor_support e1000e uinput firewire_ohci firewire_core crc_itu_t i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: nf_defrag_ipv4]
[ 2127.808223] 
[ 2127.811261] Pid: 7085, comm: team_manual_con Tainted: G           O 3.2.0-rc1+ #1 Intel Corporation 2012 Client Platform/LosLunas CRB
[ 2127.814421] RIP: 0010:[<ffffffffa0196edd>]  [<ffffffffa0196edd>] team_nl_fill_options_get_changed+0xc5/0x240 [team]
[ 2127.817597] RSP: 0018:ffff88012ec3d968  EFLAGS: 00010286
[ 2127.820758] RAX: 0000000000000000 RBX: ffff8801397bb600 RCX: ffffffffffffffff
[ 2127.823947] RDX: ffff88013f4ba048 RSI: 0000000000000000 RDI: 0000000000000000
[ 2127.827154] RBP: ffff88012ec3d9c8 R08: ffff88013f4ba048 R09: 0000000000000004
[ 2127.830365] R10: 0000000000001bad R11: 0000000000000000 R12: ffff880143a8b740
[ 2127.833599] R13: ffff880143aca7e8 R14: ffff88013f4ba014 R15: ffff88013f4ba048
[ 2127.836838] FS:  00007fd65cdc8700(0000) GS:ffff88014e2e0000(0000) knlGS:0000000000000000
[ 2127.840102] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2127.843386] CR2: 0000000000000000 CR3: 0000000128531000 CR4: 00000000001406e0
[ 2127.846688] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2127.849987] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2127.853278] Process team_manual_con (pid: 7085, threadinfo ffff88012ec3c000, task ffff88013e842e40)
[ 2127.856605] Stack:
[ 2127.859898]  0000000000000000 ffff880143a8b7e8 0000000000000000 ffff88013f4ba01c
[ 2127.863261]  ffffffffa0019140 0000000500000000 0000000000000000 ffff8801397bb600
[ 2127.866623]  ffff88012ec3da58 ffffffffa0197058 ffff880143a8b740 00000000fffffff4
[ 2127.869993] Call Trace:
[ 2127.873344]  [<ffffffffa0197058>] ? team_nl_fill_options_get_changed+0x240/0x240 [team]
[ 2127.876750]  [<ffffffffa0197078>] team_nl_fill_options_get+0x20/0x22 [team]
[ 2127.880152]  [<ffffffffa019763c>] team_nl_send_generic+0x41/0x85 [team]
[ 2127.880156]  [<ffffffffa01976f5>] team_nl_cmd_options_get+0x36/0x3f [team]
[ 2127.880162]  [<ffffffff813fbdce>] genl_rcv_msg+0x1d8/0x203
[ 2127.880165]  [<ffffffff813fbbf6>] ? genl_rcv+0x2d/0x2d
[ 2127.880169]  [<ffffffff813fb7b2>] netlink_rcv_skb+0x42/0x8d
[ 2127.880172]  [<ffffffff813fbbef>] genl_rcv+0x26/0x2d
[ 2127.880174]  [<ffffffff813fb341>] netlink_unicast+0xec/0x156
[ 2127.880178]  [<ffffffff813fb5a6>] netlink_sendmsg+0x1fb/0x233
[ 2127.880182]  [<ffffffff813ca577>] sock_sendmsg+0xe6/0x109
[ 2127.880188]  [<ffffffff81120c76>] ? __mem_cgroup_commit_charge+0x9d/0xa9
[ 2127.880192]  [<ffffffff8112333b>] ? mem_cgroup_charge_common+0xb1/0xc3
[ 2127.880197]  [<ffffffff81043ff5>] ? should_resched+0xe/0x2d
[ 2127.880203]  [<ffffffff814b6208>] ? _cond_resched+0xe/0x22
[ 2127.880206]  [<ffffffff81043ff5>] ? should_resched+0xe/0x2d
[ 2127.880209]  [<ffffffff813d4433>] ? copy_from_user+0x2f/0x31
[ 2127.880212]  [<ffffffff813d481e>] ? verify_iovec+0x52/0xa4
[ 2127.880215]  [<ffffffff813ca85c>] __sys_sendmsg+0x213/0x2ba
[ 2127.880220]  [<ffffffff810fb1eb>] ? handle_mm_fault+0x1c8/0x1db
[ 2127.880224]  [<ffffffff814bab67>] ? do_page_fault+0x30c/0x37e
[ 2127.880228]  [<ffffffff814b7914>] ? _raw_spin_unlock_irqrestore+0x17/0x19
[ 2127.880232]  [<ffffffff81045079>] ? __wake_up+0x44/0x4d
[ 2127.880235]  [<ffffffff813cc459>] sys_sendmsg+0x42/0x60
[ 2127.880239]  [<ffffffff814be042>] system_call_fastpath+0x16/0x1b
[ 2127.880241] Code: e9 24 01 00 00 be 01 00 00 00 48 89 df e8 aa f3 ff ff 48 85 c0 49 89 c7 0f 84 4b 01 00 00 49 8b 75 10 31 c0 48 83 c9 ff 48 89 f7 <f2> ae 48 89 df 89 ca 48 89 f1 be 01 00 00 00 f7 d2 e8 2f 4c 0a 
[ 2127.880263] RIP  [<ffffffffa0196edd>] team_nl_fill_options_get_changed+0xc5/0x240 [team]
[ 2127.880268]  RSP <ffff88012ec3d968>
[ 2127.880269] CR2: 0000000000000000
[ 2127.880287] ---[ end trace 3e104c6acd231d26 ]---

Can you provide a detailed report of the testing you have done on the
team device?  It seems proper testing would have found something like
this.
