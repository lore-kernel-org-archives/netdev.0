From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: post 2.6.24-rc7 regression: unregister_netdevice: waiting for eth1 to become free
Date: Mon, 21 Jan 2008 01:09:41 +0100
Message-ID: <200801210109.42153.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_GL+kHrFl3Y3IsQ7"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.ambsoft.pl ([212.109.144.130]:43562 "EHLO
	orion.ambsoft.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764AbYAUARI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 19:17:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_GL+kHrFl3Y3IsQ7
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

	I found that on current Linus tree unplugging my pcmcia wifi
card (Cabletron RoamAbout) causes part of the system to hang. I.e. mouse works
but keyboard is frozen until reboot. Actually only sysrq works but I can not
type in any terminal.

Syslog shows:

kernel: pccard: card ejected from slot 1
kernel: hermes @ 00010100: Card removed while issuing command 0x0002.
kernel: eth1: Error -19 disabling MAC port
kernel: unregister_netdevice: waiting for eth1 to become free. Usage count = 1
last message repeated 2 times

sysrq-d:

Showing all locks held in the system:
3 locks held by events/0/5:
 #0:  (events){--..}, at: [<c0126956>] run_workqueue+0xd2/0x1c9
 #1:  ((linkwatch_work).work){--..}, at: [<c012697c>] run_workqueue+0xf8/0x1c9
 #2:  (net_todo_run_mutex){--..}, at: [<c02d6c7a>] netdev_run_todo+0x15/0x23f
2 locks held by pccardd/1189:
 #0:  (&socket->skt_mutex){--..}, at: [<c0286918>] pccardd+0x129/0x227
 #1:  (net_todo_run_mutex){--..}, at: [<c02d6c7a>] netdev_run_todo+0x15/0x23f
1 lock held by agetty/5204:
 #0:  (&tty->atomic_read_lock){--..}, at: [<c022bb0f>] read_chan+0x3da/0x5bb
1 lock held by agetty/5206:
 #0:  (&tty->atomic_read_lock){--..}, at: [<c022bb0f>] read_chan+0x3da/0x5bb
1 lock held by agetty/5207:
 #0:  (&tty->atomic_read_lock){--..}, at: [<c022bb0f>] read_chan+0x3da/0x5bb
1 lock held by agetty/5208:
 #0:  (&tty->atomic_read_lock){--..}, at: [<c022bb0f>] read_chan+0x3da/0x5bb
1 lock held by agetty/5209:
 #0:  (&tty->atomic_read_lock){--..}, at: [<c022bb0f>] read_chan+0x3da/0x5bb
1 lock held by ifconfig/5581:
 #0:  (net_todo_run_mutex){--..}, at: [<c02d6c7a>] netdev_run_todo+0x15/0x23f

sysrq-w:

SysRq : Show Blocked State
  task                PC stack   pid father
events/0      D dcd62780     0     5      2
       dd834ee0 00000096 c033f2e0 dcd62780 00000000 c043f500 00000246 dd846000 
       dd834f28 c033547a 00000000 00000002 c02d6c7a dd834f0c c043f538 c043f524 
       c02d6c7a 00000000 dcfa5e54 c043f524 dd846000 c043f500 dd834f08 c043f744 
Call Trace:
 [<c033547a>] mutex_lock_nested+0xe6/0x306
 [<c02d6c7a>] netdev_run_todo+0x15/0x23f
 [<c02de559>] rtnl_unlock+0x12/0x14
 [<c02df907>] linkwatch_event+0x25/0x27
 [<c01269a4>] run_workqueue+0x120/0x1c9
 [<c01272f6>] worker_thread+0x71/0xab
 [<c0129dbd>] kthread+0x36/0x58
 [<c0103507>] kernel_thread_helper+0x7/0x10
 =======================
pccardd       D dccaaa00     0  1189      2
       dce33e00 00000096 c033f260 dccaaa00 00000282 dce33e10 ffff4f93 ffff4f53 
       dce33e30 c0334b38 c043f6c0 dce33e30 c04dc740 c04dc740 ffff4f93 c01202e9 
       dce16000 c04dc280 dcc09060 ffff4811 dce33e38 c0334bab dce33e40 c01207ae 
Call Trace:
 [<c0334b38>] schedule_timeout+0x43/0xa2
 [<c0334bab>] schedule_timeout_uninterruptible+0x14/0x16
 [<c01207ae>] msleep+0x12/0x18
 [<c02d6d2e>] netdev_run_todo+0xc9/0x23f
 [<c02de559>] rtnl_unlock+0x12/0x14
 [<c02d54ad>] unregister_netdev+0x17/0x1b
 [<ded1c111>] orinoco_cs_detach+0x1b/0x2d [orinoco_cs]
 [<ded0873b>] pcmcia_device_remove+0x37/0xc6 [pcmcia]
 [<c0258080>] __device_release_driver+0x6a/0x92
 [<c0258493>] device_release_driver+0x2f/0x45
 [<c025798f>] bus_remove_device+0x53/0x75
 [<c0256194>] device_del+0x146/0x257
 [<c02562b0>] device_unregister+0xb/0x15
 [<ded08683>] pcmcia_card_remove+0x71/0x87 [pcmcia]
 [<ded091ec>] ds_event+0x54/0x99 [pcmcia]
 [<c0285f5a>] send_event+0x78/0xa4
 [<c0286175>] socket_remove_drivers+0x12/0x14
 [<c0286185>] socket_shutdown+0xe/0xc7
 [<c0286264>] socket_remove+0x26/0x2c
 [<c02869e7>] pccardd+0x1f8/0x227
 [<c0129dbd>] kthread+0x36/0x58
 [<c0103507>] kernel_thread_helper+0x7/0x10
 =======================
ifconfig      D ddb5ea00     0  5581   5580
       dcfa5e2c 00000096 c033f2e0 ddb5ea00 00000000 c043f500 00000246 dce94000 
       dcfa5e74 c033547a 00000000 00000002 c02d6c7a dce9456c c043f538 c043f524 
       c02d6c7a 00000000 c043f524 dd834f08 dce94000 c043f500 dcfa5e54 00000000 
Call Trace:
 [<c033547a>] mutex_lock_nested+0xe6/0x306
 [<c02d6c7a>] netdev_run_todo+0x15/0x23f
 [<c02de559>] rtnl_unlock+0x12/0x14
 [<c02d614c>] dev_ioctl+0x165/0x4f5
 [<c02c9967>] sock_ioctl+0xe2/0x211
 [<c016e3c2>] do_ioctl+0x22/0x71
 [<c016e466>] vfs_ioctl+0x55/0x28a
 [<c016e6ce>] sys_ioctl+0x33/0x51
 [<c01028ca>] sysenter_past_esp+0x5f/0xa5
 =======================

I run bisection three times but it doesn't give a clear answer which commit is the culprit.
First bisection: current Linus bad - v2.6.23 good. First bad commit:

ecd2ebdea350c40e73c00d400d74c8a09c072082 is first bad commit
commit ecd2ebdea350c40e73c00d400d74c8a09c072082
Author: Jarek Poplawski <jarkao2@gmail.com>
Date:   Thu Jan 10 21:21:20 2008 -0800

    [AX25] af_ax25: Possible circular locking.

Which is bogus because I don't even have ax25 compiled into the kernel.
Next two (to be sure) times I run bisection: current Linus bad - v2.6.24-rc7 good.
Two times I got the same result, first bad commit:

9cd40029423701c376391da59d2c6469672b4bed is first bad commit
commit 9cd40029423701c376391da59d2c6469672b4bed
Author: Pavel Emelyanov <xemul@openvz.org>
Date:   Thu Jan 10 03:48:38 2008 -0800

    [NEIGH]: Fix race between neigh_parms_release and neightbl_fill_parms

But this also seems wrong. When I apply this patch the problem doesn't show.
Good thing is that both commits are very close to each other so I guess the culprit
is somewhere there near to them. All I can say for sure now is that v2.6.24-rc7 is good
and current Linus is bad.

Box is x86 32bit. Config is attached. If I can provide you with any more info just let me know.

My plan is to apply patches, one at a time, starting from 9cd4002942 and see what happens
unless someone knows already which one is bad.

Regards,

	Mariusz

This is the last bisection log:

git-bisect start
# bad: [a7da60f41551abb3c520b03d42ec05dd7decfc7f] Remove bogus duplicate CONFIG_LGUEST_GUEST entry.
git-bisect bad a7da60f41551abb3c520b03d42ec05dd7decfc7f
# good: [3ce54450461bad18bbe1f9f5aa3ecd2f8e8d1235] Linux 2.6.24-rc7
git-bisect good 3ce54450461bad18bbe1f9f5aa3ecd2f8e8d1235
# good: [d72ec9e20e4de995aa957f171cf84b136689e4c0] Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6
git-bisect good d72ec9e20e4de995aa957f171cf84b136689e4c0
# bad: [0938e7586440ac97cedc0f5528a8684ebfa4ce43] Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/libata-dev
git-bisect bad 0938e7586440ac97cedc0f5528a8684ebfa4ce43
# good: [d8cf5389bd9d1f0ac9fea51796c274ba64b83d80] libata: relocate sdev->manage_start_stop configuration
git-bisect good d8cf5389bd9d1f0ac9fea51796c274ba64b83d80
# bad: [1b310fca30ac9851f79337ca72b1cf6a0f58064a] [TOKENRING]: rif_timer not initialized properly
git-bisect bad 1b310fca30ac9851f79337ca72b1cf6a0f58064a
# bad: [5c5482266537fdb24d6b8462540d8f65a6007a97] [BLUETOOTH]: Always send explicit hci_ll wake-up acks.
git-bisect bad 5c5482266537fdb24d6b8462540d8f65a6007a97
# bad: [0bcceadceb0907094ba4e40bf9a7cd9b080f13fb] [IPV4] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
git-bisect bad 0bcceadceb0907094ba4e40bf9a7cd9b080f13fb
# bad: [9cd40029423701c376391da59d2c6469672b4bed] [NEIGH]: Fix race between neigh_parms_release and neightbl_fill_parms
git-bisect bad 9cd40029423701c376391da59d2c6469672b4bed
# good: [b0de8e402dc5d3ee04f4d0f669ae492a3e569933] [NIU]: Support for Marvell PHY
git-bisect good b0de8e402dc5d3ee04f4d0f669ae492a3e569933

--Boundary-00=_GL+kHrFl3Y3IsQ7
Content-Type: application/x-gzip;
  name="config.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="config.gz"

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
krx1nKcljVTNIa2NdvR/EJVShBifAAA=

--Boundary-00=_GL+kHrFl3Y3IsQ7--
