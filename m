From: Stephen Hemminger <shemminger@vyatta.com>
Subject: net-next: unitialized lock
Date: Fri, 18 Jul 2008 20:19:45 -0700
Message-ID: <20080718201945.669917ab@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:58927 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750704AbYGSDTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 23:19:54 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 5962F4F425A
	for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 20:19:53 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Njq9GkoApgK5 for <netdev@vger.kernel.org>;
	Fri, 18 Jul 2008 20:19:49 -0700 (PDT)
Received: from extreme (pool-71-245-98-107.ptldor.fios.verizon.net [71.245.98.107])
	by mail.vyatta.com (Postfix) with ESMTP id D80BD4F4248
	for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 20:19:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like locks on qdisc aren't initialized properly after
Dave's conversion to MQ.

# brctl addbr br0
# ifconfig br0 10.1.1.1
# ifconfig br0 down
------------------

[  146.937241] br0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM feature.
[  253.874538] BUG: spinlock bad magic on CPU#2, ifconfig/7861
[  253.874548]  lock: ffffffff806c0558, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
[  253.874552] Pid: 7861, comm: ifconfig Not tainted 2.6.26 #12
[  253.874557] 
[  253.874557] Call Trace:
[  253.874566]  [<ffffffff803884cf>] spin_bug+0xef/0x100
[  253.874571]  [<ffffffff803886ff>] _raw_spin_lock+0x9f/0x190
[  253.874579]  [<ffffffff8050a822>] _spin_lock_bh+0x32/0x40
[  253.874584]  [<ffffffff8048f197>] dev_deactivate_queue+0x37/0x70
[  253.874591]  [<ffffffff8048ee10>] dev_deactivate+0x40/0x150
[  253.874596]  [<ffffffff8047c18a>] dev_close+0x4a/0xa0
[  253.874602]  [<ffffffff8047bdb1>] dev_change_flags+0xa1/0x1d0
[  253.874609]  [<ffffffff804cba73>] devinet_ioctl+0x5b3/0x760
[  253.874619]  [<ffffffff804cc5fd>] inet_ioctl+0x6d/0x90
[  253.874624]  [<ffffffff8046f446>] sock_ioctl+0x56/0x240
[  253.874630]  [<ffffffff802cbc91>] vfs_ioctl+0x31/0x90
[  253.874635]  [<ffffffff802cbf5b>] do_vfs_ioctl+0x26b/0x2d0
[  253.874640]  [<ffffffff8050a391>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  253.874646]  [<ffffffff802cc042>] sys_ioctl+0x82/0xa0
[  253.874653]  [<ffffffff8020c518>] system_call_after_swapgs+0x88/0x8d
[  253.874660] 
