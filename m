From: Neil Jones <neiljay@gmail.com>
Subject: Re: rndis gadget: Inconsistent locking
Date: Mon, 10 Jan 2011 11:32:16 +0000
Message-ID: <AANLkTikkkit_L3qHgoyfVUwDYwahbFDJdF8eosH+woAz@mail.gmail.com>
References: <AANLkTi=OS+jernOe8y1fbMbx5Rf+JRcvzqGY4Z2LKqsH@mail.gmail.com>
	<113676.26138.qm@web180310.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>,
	=?UTF-8?Q?Micha=C5=82_Nazarewicz?= <m.nazarewicz@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45247 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608Ab1AJLcR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 06:32:17 -0500
In-Reply-To: <113676.26138.qm@web180310.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Michal, can you update and resubmit, so I can
> at least ack your fix and xpedite its merge?

I have just retested Michals patch but I have found another lockdep fai=
lure.

It looks like rndis_msg_parser() can call dev_get_stats too:

------------[ cut here ]------------
WARNING: at kernel/softirq.c:98 ___local_bh_disable+0xc4/0xd0()
Modules linked in: g_ether [last unloaded: g_zero]

Call trace:
[<40003d78>] _show_stack+0x68/0x7c
[<40003da0>] _dump_stack+0x14/0x28
[<40016d68>] _warn_slowpath_common+0x5c/0x7c
[<40016da0>] _warn_slowpath_null+0x18/0x2c
[<4001e330>] ___local_bh_disable+0xc0/0xd0
[<4001e354>] _local_bh_disable+0x14/0x28
[<402bd9e0>] __raw_spin_lock_bh+0x18/0x54
[<4023010c>] _dev_txq_stats_fold+0x7c/0x13c
[<40230284>] _dev_get_stats+0xb8/0xc0
[<78056eac>] _rndis_msg_parser+0x288/0xa04 [g_ether]
[<7805764c>] _rndis_command_complete+0x24/0x70 [g_ether]
[<401c39b8>] _dwc_otg_request_done+0xd4/0x210
[<401c6b48>] _ep0_complete_request+0x1dc/0x220
[<401c6cac>] _handle_ep0+0x120/0x850
[<401c79a4>] _dwc_otg_pcd_handle_in_ep_intr+0x188/0x780
[<401c8200>] _dwc_otg_pcd_handle_intr+0x264/0x294
[<401c36d4>] _dwc_otg_pcd_irq+0x10/0x30
[<4005a60c>] _handle_IRQ_event+0x4c/0x184
[<4005d464>] _handle_level_irq+0xac/0x15c
[<4000c154>] _metag_soc_irq_demux+0xac/0xb4
[<40002f54>] _do_IRQ+0x4c/0x78
[<40004180>] _trigger_handler+0x38/0xac
[<40000c98>] ___TBIBoingVec+0xc/0x10
[<40003708>] _cpu_idle+0x54/0x78

no locks held by swapper/0.
---[ end trace 74bf431fcc326847 ]---
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ INFO: inconsistent lock state ]
2.6.37-rc7+ #1833
---------------------------------
inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
swapper/0 [HC1[1]:SC0[2]:HE0:SE0] takes:
 (_xmit_ETHER){?.....}, at: [<40230110>] _dev_txq_stats_fold+0x80/0x13c
{HARDIRQ-ON-W} state was registered at:
  [<4004ddd0>] _lock_acquire+0x98/0xc0
  [<402bda00>] __raw_spin_lock_bh+0x38/0x54
  [<4023010c>] _dev_txq_stats_fold+0x7c/0x13c
  [<40230284>] _dev_get_stats+0xb8/0xc0
  [<4024461c>] _rtnl_fill_ifinfo+0x330/0x708
  [<40245b38>] _rtmsg_ifinfo+0x68/0xf4
  [<402342b8>] _register_netdevice+0x3f8/0x498
  [<40234398>] _register_netdev+0x40/0x60
  [<78056358>] _gether_setup+0x1d0/0x264 [g_ether]
  [<7806042c>] 0x7806042c
  [<78059c00>] _composite_bind+0x110/0x380 [g_ether]
  [<401c27f0>] _usb_gadget_probe_driver+0x9c/0xcc
  [<78057c90>] _usb_composite_probe+0x98/0xbc [g_ether]
  [<78060380>] 0x78060380
  [<4000210c>] _do_one_initcall+0x178/0x1d0
  [<40057ecc>] _sys_init_module+0xd8/0x208
  [<40004860>] _switch_handler+0x110/0x170
  [<40000c98>] ___TBIBoingVec+0xc/0x10
irq event stamp: 476219
hardirqs last  enabled at (476215): [<40003ec4>] _tail_end+0x110/0x1f8
hardirqs last disabled at (476216): [<40004178>] _trigger_handler+0x30/=
0xac
softirqs last  enabled at (476218): [<4001e790>] __local_bh_enable+0x14=
/0x24
softirqs last disabled at (476219): [<402bd9e4>] __raw_spin_lock_bh+0x1=
c/0x54

other info that might help us debug this:
no locks held by swapper/0.
--------------------------------------------------------------

So the patch may need some more work,

Neil.

On Fri, Jan 7, 2011 at 11:20 AM, David Brownell <david-b@pacbell.net> w=
rote:
>
>
>> Yes Michal Nazarewicz has seen this on a S3C UDC,
>
> Good to confirm that. =C2=A0As I mentioned, other folk have seen much=
 the same bug on other hardware; we
> know it's neither a new nor a HW-specific issue.
>
> Correction to an earlier comment of mine:
>
> https://patchwork.kernel.org/patch/195562/
> does correctly identify the commit which
> caused this bug in multiple drivers.
>
> However, that patch won't apply to the latest
> tree from Linus.
>
> Michal, can you update and resubmit, so I can
> at least ack your fix and xpedite its merge?
>
> It'd be good =C2=A0to have RNDIS work again, a fair
> number of folk rely on it, and this seems to be
> the main obstacle to continuing to do that.
>
>
> - Dave
>
>
>
>
>
>
