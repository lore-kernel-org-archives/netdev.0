From: David Miller <davem@davemloft.net>
Subject: Re: mutex WARNING while running ip from iproute2 package
Date: Wed, 23 Apr 2008 19:41:25 -0700 (PDT)
Message-ID: <20080423.194125.202757521.davem@davemloft.net>
References: <200804201757.09938.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34363
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751812AbYDXClX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 22:41:23 -0400
In-Reply-To: <200804201757.09938.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryshchenko <denys@visp.net.lb>
Date: Sun, 20 Apr 2008 17:57:09 +0300

> Just noticed warning while upgrading and loading 2.6.25.
> Configuration a bit complicated, so it is difficult to tell which command trigger it.
> If it is required, i can spend time and will try to find it.
> 
> It is QEMU machine, non-smp.

Thanks for your report.

Patrick, it looks pretty simple, if you bring up a macvlan device using
rtnetlink, we take the RTNL lock recursively via the call to
dev_unicast_add() performed by the macvlan open method.

Can you have a look?

Thanks!

> [    8.665310] ------------[ cut here ]------------
> [    8.666254] WARNING: at kernel/mutex.c:353 mutex_trylock+0x3c/0xef()
> [    8.667254] Modules linked in: macvlan ifb e1000e em_nbyte cls_tcindex act_gact cls_rsvp sch_htb cls_fw act_mirred em_u32 sch_red sch_sfq sch_tbf sch_teql cls_basic act_police sch_gred act_pedit sch_hfsc cls_rsvp6 sch_ingress em_meta em_text act_ipt sch_dsmark sch_prio sch_netem act_simple cls_u32 em_cmp sch_cbq cls_route xt_TCPMSS iptable_nat ipt_LOG ipt_MASQUERADE ipt_REDIRECT nf_nat nf_conntrack_ipv4 nf_conntrack nfnetlink iptable_filter ip_tables x_tables 8021q tun tulip r8169 sky2 via_velocity via_rhine sis900 ne2k_pci 8390 skge tg3 8139too e1000 e100 mtdblock mtd_blkdevs aic79xx mptsas scsi_transport_sas mptspi scsi_transport_spi mptscsih mptbase sata_via sata_uli sata_svw sata_sis sata_sil24 sata_sil sata_mv ahci pata_via pata_sis pata_serverworks pata_oldpiix pata_mpiix pata_m
 arvell pata_ali ata_generic ata_piix libata dock usbhid uhci_hcd ehci_hcd ohci_hcd usbcore
> [    8.693251] Pid: 1350, comm: ip Not tainted 2.6.25-build-0028 #14
> [    8.694253]  [<c0120360>] warn_on_slowpath+0x41/0x51
> [    8.696262]  [<c012ea2a>] ? __kernel_text_address+0x1b/0x27
> [    8.698252]  [<c010484a>] ? dump_trace+0xce/0xda
> [    8.699249]  [<c0109d9e>] ? save_stack_address+0x0/0x2c
> [    8.700724]  [<c013a4b4>] ? mark_held_locks+0x41/0x5c
> [    8.701901]  [<c015ca59>] ? kmem_cache_alloc+0x69/0xa1
> [    8.703251]  [<c013a619>] ? trace_hardirqs_on+0xcb/0x102
> [    8.704251]  [<c02a21b6>] mutex_trylock+0x3c/0xef
> [    8.705251]  [<c0257122>] rtnl_trylock+0xd/0xf
> [    8.706250]  [<c024d510>] __dev_set_promiscuity+0x15/0xa9
> [    8.707251]  [<c024d5df>] __dev_set_rx_mode+0x3b/0x75
> [    8.709250]  [<c0250b60>] dev_unicast_add+0x79/0x94
> [    8.711251]  [<e0a69682>] macvlan_open+0x2c/0x73 [macvlan]
> [    8.712251]  [<c0250076>] dev_open+0x42/0x74
> [    8.714250]  [<c024ecf4>] dev_change_flags+0x9f/0x14f
> [    8.716250]  [<c0256526>] do_setlink+0x248/0x2fd
> [    8.717257]  [<c0257837>] rtnl_newlink+0x24a/0x399
> [    8.719264]  [<c02a279c>] ? mutex_lock_nested+0x1ea/0x1fc
> [    8.721250]  [<c02575ed>] ? rtnl_newlink+0x0/0x399
> [    8.723249]  [<c025730a>] rtnetlink_rcv_msg+0x193/0x1ad
> [    8.724249]  [<c0257156>] ? rtnl_lock+0xf/0x11
> [    8.726250]  [<c0257177>] ? rtnetlink_rcv_msg+0x0/0x1ad
> [    8.728248]  [<c026194a>] netlink_rcv_skb+0x30/0x82
> [    8.730249]  [<c025716f>] rtnetlink_rcv+0x17/0x1f
> [    8.732248]  [<c026172a>] netlink_unicast+0x1bb/0x220
> [    8.733250]  [<c0261ee2>] netlink_sendmsg+0x243/0x250
> [    8.735252]  [<c0244edc>] sock_sendmsg+0xca/0xe1
> [    8.737253]  [<c0130472>] ? autoremove_wake_function+0x0/0x33
> [    8.739248]  [<c0130472>] ? autoremove_wake_function+0x0/0x33
> [    8.741253]  [<c0130472>] ? autoremove_wake_function+0x0/0x33
> [    8.743250]  [<c01d5072>] ? copy_from_user+0x2c/0x4f
> [    8.744248]  [<c024b411>] ? verify_iovec+0x40/0x73
> [    8.746248]  [<c0245042>] sys_sendmsg+0x14f/0x1aa
> [    8.748248]  [<c024581b>] ? sys_recvmsg+0x117/0x17f
> [    8.750261]  [<c02a376c>] ? _spin_unlock+0x1d/0x20
> [    8.752249]  [<c0245ce2>] sys_socketcall+0x14e/0x166
> [    8.753248]  [<c01038a7>] ? restore_nocheck+0x12/0x15
> [    8.755248]  [<c0103846>] syscall_call+0x7/0xb
> [    8.756250]  =======================
> [    8.757241] ---[ end trace 45294fe3d9e9f489 ]---
> 
> -- 
> ------
> Technical Manager
> Virtual ISP S.A.L.
> Lebanon
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
