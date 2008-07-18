From: Dave Chinner <david@fromorbit.com>
Subject: [BUG, NET] deadlock tearing down a bridged interface
Date: Fri, 18 Jul 2008 17:37:24 +1000
Message-ID: <20080718073724.GA5802@disturbed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail01.adl6.internode.on.net ([203.16.214.146]:58857 "EHLO
	ipmail01.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752346AbYGRHhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 03:37:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

I just deadlocked networking on a 2.6.24 kernel. Basically I
was trying to restart the bridge interface I use for UML sessions
because it wasn't passing packets. This happens occasionally
when I leave a UML session too long in gdb, so I bounced the
bridge to get it working again.

Unfortunately, a UML session (2.6.25-rc9) was halting at the same
time, and instead of giving me a 'device busy' error, the
UML session stopped at:

Asking all remaining processes to terminate...done.
All processes ended within 1 seconds....done.
Saving random seed...done.
Deconfiguring network interfaces...

It appears to be stuck closing the tunnel interface it was using:

uml-linux     D ffffffff804297c0     0  7437   7428
 ffff8100798efe70 0000000000000086 0000000000000000 ffff81005348b400
 ffff81003d820800 ffff81007df9a800 ffff81003d820a50 0000000100000000
 00000000ffffffff ffff81003d820800 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8024a85d>] lock_hrtimer_base+0x1b/0x3c
 [<ffffffff804145f2>] __mutex_lock_slowpath+0x68/0xa3
 [<ffffffff80414458>] mutex_lock+0xa/0xb
 [<ffffffff803adcfe>] netdev_run_todo+0x14/0x21a
 [<ffffffff885901dd>] :tun:tun_chr_close+0x70/0x76
 [<ffffffff802990c7>] __fput+0xa1/0x16c
 [<ffffffff802968f3>] filp_close+0x5d/0x65
 [<ffffffff80297aca>] sys_close+0x8d/0xca
 [<ffffffff8020be2e>] system_call+0x7e/0x83

At the same time that this command was running:

brctl delbr br0

dmesg showed:

unregister_netdevice: waiting for br0 to become free. Usage count = 7
unregister_netdevice: waiting for br0 to become free. Usage count = 7
unregister_netdevice: waiting for br0 to become free. Usage count = 7
unregister_netdevice: waiting for br0 to become free. Usage count = 7
unregister_netdevice: waiting for br0 to become free. Usage count = 7
unregister_netdevice: waiting for br0 to become free. Usage count = 7
....

brctl is stuck here:

brctl         D ffffffff804297c0     0  8457   8448
 ffff81004d8a3d98 0000000000000082 0000000000000286 ffffffff8023e0ea
 ffff81000f941800 ffff81007d531000 ffff81000f941a50 000000014d8a3da8
 000000012f98b3a2 000000012f98bbea 0000000000000286 ffffffff8023e280
Call Trace:
 [<ffffffff8023e0ea>] lock_timer_base+0x26/0x4c
 [<ffffffff8023e280>] __mod_timer+0xc3/0xd1
 [<ffffffff8041423d>] schedule_timeout+0x8a/0xad
 [<ffffffff8023ddde>] process_timeout+0x0/0x5
 [<ffffffff80414238>] schedule_timeout+0x85/0xad
 [<ffffffff8023e2a2>] msleep+0x14/0x1e
 [<ffffffff803ade06>] netdev_run_todo+0x11c/0x21a
 [<ffffffff88580599>] :bridge:br_del_bridge+0x4c/0x50
 [<ffffffff88581281>] :bridge:br_ioctl_deviceless_stub+0x177/0x1e2
 [<ffffffff80223598>] do_page_fault+0x352/0x6ca
 [<ffffffff803a0ab6>] sock_ioctl+0x12c/0x200
 [<ffffffff802a3849>] do_ioctl+0x21/0x6b
 [<ffffffff802a3ad6>] vfs_ioctl+0x243/0x25c
 [<ffffffff80296861>] fd_install+0x25/0x5a
 [<ffffffff802a3b40>] sys_ioctl+0x51/0x71
 [<ffffffff8020be2e>] system_call+0x7e/0x83

This is as much as I could get before sufficient stuff locked
up and I had to reboot.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
