From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: oops during unregister_netdevice interface enslaved to bond -
	regression
Date: Fri, 15 Apr 2011 10:53:57 +0200
Message-ID: <20110415085357.GA7711@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	opurdila@ixiacom.com, davem@davemloft.net, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:44670 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923Ab1DOIyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 04:54:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Octavian,

your commit 443457242beb6716b43db4d62fe148eab5515505 introduced this regression.
I have reviewed the net device unregister code but did not understand it very well.
I have seen the problem only in combination with bonding. Can you give me some help
how to go on with this problem. I can reproduced it very easy on a single CPU
machine.

Frank

The test is:
1) enslave netdevice to a bond
2) close the netdevice
3) hot unplug the netdevice

    <1>[27649.970474] Unable to handle kernel pointer dereference at virtual kernel address           (null)
    <4>[27649.970477] Oops: 0004 [#1] SMP
    <4>[27649.970479] Modules linked in: bonding sunrpc qeth_l2 qeth_l3 binfmt_misc dm_multipath scsi_dh dm_mod ipv6 lcs qeth c
cwgroup [last unloaded: scsi_wait_scan]
    <4>[27649.970488] CPU: 0 Tainted: G        W   2.6.39-rc2.48.x.20110407-s390xgit #1
    <4>[27649.970490] Process kworker/u:1 (pid: 25, task: 000000007ec4c838, ksp: 000000007ec535a8)
    <4>[27649.970493] Krnl PSW : 0704100180000000 000000000055444e (klist_put+0x46/0xd4)
    <4>[27649.970498]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:1 PM:0 EA:3
    <4>[27649.970501] Krnl GPRS: 0000000000000410 07000000ffffffff 0000000000000000 0000000000000001
    <4>[27649.970504]            00000000003e57c6 0000000000000001 000000007bac3d30 000000007bad5005
    <4>[27649.970507]            000000007a2bb000 0000000000000000 0000000000000001 0000000000000000
    <4>[27649.970509]            000000007d3f2c28 00000000005c1230 000000007ec53a98 000000007ec53a58
    <4>[27649.970518] Krnl Code: 0000000000554440: 5710d000             x       %r1,0(%r13)
    <4>[27649.970521]            0000000000554444: e3b090200004 lg      %r11,32(%r9)
    <4>[27649.970524]            000000000055444a: a7280000             lhi     %r2,0
    <4>[27649.970528]           >000000000055444e: ba219000             cs      %r2,%r1,0(%r9)
    <4>[27649.970531]            0000000000554452: 1222         ltr     %r2,%r2
    <4>[27649.970534]            0000000000554454: a774003c             brc     7,5544cc
    <4>[27649.970537]            0000000000554458: b90200aa             ltgr    %r10,%r10
    <4>[27649.970540]            000000000055445c: a784000e             brc     8,554478
    <4>[27649.970542] Call Trace:
    <4>[27649.970543] ([<000000000058a848>] bin_vm_ops+0x28/0xe8)
    <4>[27649.970548]  [<00000000003e57de>] device_del+0x7e/0x1d0
    <4>[27649.970551]  [<00000000004af858>] rollback_registered_many+0x1ac/0x268
    <4>[27649.970554]  [<00000000004af9f2>] rollback_registered+0x52/0x74
    <4>[27649.970556]  [<00000000004afa9e>] unregister_netdevice_queue+0x8a/0xe0
    <4>[27649.970559]  [<00000000004afc40>] unregister_netdev+0x34/0x40
    <4>[27649.970562]  [<000003c001a74cfc>] qeth_l2_remove_device+0xf8/0x120 [qeth_l2]
    <4>[27649.970566]  [<000003c003d87040>] qeth_core_remove_device+0x94/0x180 [qeth]
    <4>[27649.970572]  [<000003c00124c83e>] ccwgroup_remove+0x66/0x74 [ccwgroup]
    <4>[27649.970575]  [<00000000003e8d24>] __device_release_driver+0x7c/0xec
    <4>[27649.970578]  [<00000000003e8dcc>] device_release_driver+0x38/0x48
    <4>[27649.970581]  [<00000000003e87ee>] bus_remove_device+0xca/0xf4
    <4>[27649.970584]  [<00000000003e58b0>] device_del+0x150/0x1d0
    <4>[27649.970587]  [<00000000003e5956>] device_unregister+0x26/0x38
    <4>[27649.970589]  [<000003c00124c7bc>] ccwgroup_ungroup_callback+0x5c/0x78 [ccwgroup]
    <4>[27649.970592]  [<00000000002a3ca0>] sysfs_schedule_callback_work+0x38/0xa8
    <4>[27649.970595]  [<000000000015d1c6>] process_one_work+0x176/0x428
    <4>[27649.970598]  [<0000000000160ec2>] worker_thread+0x17a/0x398
    <4>[27649.970601]  [<0000000000166e2a>] kthread+0xa6/0xb0
    <4>[27649.970603]  [<00000000005614de>] kernel_thread_starter+0x6/0xc
    <4>[27649.970606]  [<00000000005614d8>] kernel_thread_starter+0x0/0xc
    <4>[27649.970609] Last Breaking-Event-Address:
    <4>[27649.970610]  [<0000000000554538>] klist_del+0x4/0xc
    <4>[27649.970613]
    <0>[27649.970614] Kernel panic - not syncing: Fatal exception: panic_on_oops
    <4>[27649.970617] CPU: 0 Tainted: G      D W   2.6.39-rc2.48.x.20110407-s390xgit #1
    <4>[27649.970619] Process kworker/u:1 (pid: 25, task: 000000007ec4c838, ksp: 000000007ec535a8)
    <4>[27649.970622] 000000007ec53700 000000007ec53680 0000000000000002 0000000000000000
    <4>[27649.970625]        000000007ec53720 000000007ec53698 000000007ec53698 000000000055ddae
    <4>[27649.970629]        0000000000000001 0000000000000000 000000007bad5005 0000000000100ebe
    <4>[27649.970632]        000000000000000d 000000000000000c 000000007ec536e8 0000000000000000
    <4>[27649.970636]        0000000000000000 0000000000100a00 000000007ec53680 000000007ec536c0
    <4>[27649.970640] Call Trace:
    <4>[27649.970641] ([<0000000000882408>] die_lock+0x0/0x4)

I bisect the problem down to 2.6.38 development. Commit introduced the problem is:

commit 443457242beb6716b43db4d62fe148eab5515505
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Mon Dec 13 12:44:07 2010 +0000

    net: factorize sync-rcu call in unregister_netdevice_many

    Add dev_close_many and dev_deactivate_many to factorize another
    sync-rcu operation on the netdevice unregister path.

    $ modprobe dummy numdummies=10000
    $ ip link set dev dummy* up
    $ time rmmod dummy

    Without the patch           With the patch

    real    0m 24.63s           real    0m 5.15s
    user    0m 0.00s            user    0m 0.00s
    sys     0m 6.05s            sys     0m 5.14s

I don't know if this commit is bad or if it exposes a problem in the bonding code.

