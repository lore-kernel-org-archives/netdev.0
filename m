From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [BUG] bonding : LOCKDEP warning
Date: Sat, 22 Oct 2011 01:43:07 -0700
Message-ID: <m14nz1l8mc.fsf@fess.ebiederm.org>
References: <1319268987.6180.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:55615 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112Ab1JVIme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 04:42:34 -0400
In-Reply-To: <1319268987.6180.21.camel@edumazet-laptop> (Eric Dumazet's
	message of "Sat, 22 Oct 2011 09:36:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet <eric.dumazet@gmail.com> writes:

> On latest net-next I got following splat

Eric it is going to be a little bit before I can test this but I believe
we just need the one fix in the patch below.  Can you verify this fixes
your lockdep issue.

Thanks,

Eric


>From 60aeafd8976a1117e118574ada44a79b69c75e70 Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Sat, 22 Oct 2011 01:36:18 -0700
Subject: [PATCH] bonding:  Add a forgetten sysfs_attr_init on class_attr_bonding_masters

When I made class_attr_bonding_matters per network namespace and dynamically
allocated I overlooked the need for calling sysfs_attr_init.  Oops.

This fixes the following lockdep splat:

[    5.749651] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[    5.749655] bonding: MII link monitoring set to 100 ms
[    5.749676] BUG: key f49a831c not in .data!
[    5.749677] ------------[ cut here ]------------
[    5.749752] WARNING: at kernel/lockdep.c:2897 lockdep_init_map+0x1c3/0x460()
[    5.749809] Hardware name: ProLiant BL460c G1
[    5.749862] Modules linked in: bonding(+)
[    5.749978] Pid: 3177, comm: modprobe Not tainted 3.1.0-rc9-02177-gf2d1a4e-dirty #1157
[    5.750066] Call Trace:
[    5.750120]  [<c1352c2f>] ? printk+0x18/0x21
[    5.750176]  [<c103112d>] warn_slowpath_common+0x6d/0xa0
[    5.750231]  [<c1060133>] ? lockdep_init_map+0x1c3/0x460
[    5.750287]  [<c1060133>] ? lockdep_init_map+0x1c3/0x460
[    5.750342]  [<c103117d>] warn_slowpath_null+0x1d/0x20
[    5.750398]  [<c1060133>] lockdep_init_map+0x1c3/0x460
[    5.750453]  [<c1355ddd>] ? _raw_spin_unlock+0x1d/0x20
[    5.750510]  [<c11255c8>] ? sysfs_new_dirent+0x68/0x110
[    5.750565]  [<c1124d4b>] sysfs_add_file_mode+0x8b/0xe0
[    5.750621]  [<c1124db3>] sysfs_add_file+0x13/0x20
[    5.750675]  [<c1124e7c>] sysfs_create_file+0x1c/0x20
[    5.750737]  [<c1208f09>] class_create_file+0x19/0x20
[    5.750794]  [<c12c186f>] netdev_class_create_file+0xf/0x20
[    5.750853]  [<f85deaf4>] bond_create_sysfs+0x44/0x90 [bonding]
[    5.750911]  [<f8410947>] ? bond_create_proc_dir+0x1e/0x3e [bonding]
[    5.750970]  [<f841007e>] bond_net_init+0x7e/0x87 [bonding]
[    5.751026]  [<f8410000>] ? 0xf840ffff
[    5.751080]  [<c12abc7a>] ops_init.clone.4+0xba/0x100
[    5.751135]  [<c12abdb2>] ? register_pernet_subsys+0x12/0x30
[    5.751191]  [<c12abd03>] register_pernet_operations.clone.3+0x43/0x80
[    5.751249]  [<c12abdb9>] register_pernet_subsys+0x19/0x30
[    5.751306]  [<f84108b9>] bonding_init+0x832/0x8a2 [bonding]
[    5.751363]  [<c10011f0>] do_one_initcall+0x30/0x160
[    5.751420]  [<f8410087>] ? bond_net_init+0x87/0x87 [bonding]
[    5.751477]  [<c106d5cf>] sys_init_module+0xef/0x1890
[    5.751533]  [<c1356490>] sysenter_do_call+0x12/0x36
[    5.751588] ---[ end trace 89f492d83a7f5006 ]---

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/bonding/bond_sysfs.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 6044ff8..5a20804 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1675,6 +1675,7 @@ int bond_create_sysfs(struct bond_net *bn)
 	int ret;
 
 	bn->class_attr_bonding_masters = class_attr_bonding_masters;
+	sysfs_attr_init(&bn->class_attr_bonding_masters.attr);
 
 	ret = netdev_class_create_file(&bn->class_attr_bonding_masters);
 	/*
-- 
1.7.2.5
