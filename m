From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: bonding / 2.6.24-rc1 issues
Date: Wed, 07 Nov 2007 15:51:26 +0200
Message-ID: <4731C2DE.4000701@voltaire.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050608090303090702020405"
Cc: Roland Dreier <rolandd@cisco.com>, netdev@vger.kernel.org,
	Moni Levy <monil@voltaire.com>
To: Jay Vosburgh <fubar@us.ibm.com>, Moni Shoua <monis@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:54645 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754033AbXKGOHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 09:07:48 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050608090303090702020405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jay, Moni

I did some tests with 2.6.24-rc1 and the first patch to bonding that Jay 
sent last night to netdev. Basic operation and fail over work fine. 
However, I see some crashes which are somehow related to destroying the 
bond when the slaves are ipoib ones, I don't see similar crashes when 
enslaving ethernet devices (Broadcom Corporation NetXtreme BCM5704 
Gigabit Ethernet (rev 03)), my compressed dot config is attached.

The first type of oops is when I just do modprobe -r bonding after 
enslavement of the ipoib devices:

> Ethernet Channel Bonding Driver: v3.2.1 (October 15, 2007)
> bonding: MII link monitoring set to 100 ms
> bonding: bond0: setting mode to active-backup (1).
> bonding: bond0: Setting MII monitoring interval to 100.
> NET: Registered protocol family 10
> ADDRCONF(NETDEV_UP): bond0: link is not ready
> bonding: bond0: doing slave updates when interface is down.
> bonding: bond0: Adding slave ib0.
> bonding bond0: master_dev is not up in bond_enslave
> bonding: bond0: Warning: enslaved VLAN challenged slave ib0. Adding VLANs will be blocked as long as ib0 is part of bond bond0
> bonding: bond0: enslaving ib0 as a backup interface with a down link.
> bonding: bond0: doing slave updates when interface is down.
> bonding: bond0: Adding slave ib1.
> bonding bond0: master_dev is not up in bond_enslave
> bonding: bond0: Warning: enslaved VLAN challenged slave ib1. Adding VLANs will be blocked as long as ib1 is part of bond bond0
> bonding: bond0: enslaving ib1 as a backup interface with a down link.
> ADDRCONF(NETDEV_UP): bond0: link is not ready
> bonding: bond0: link status definitely up for interface ib0.
> bonding: bond0: link status definitely up for interface ib1.
> bonding: bond0: making interface ib0 the new active one.
> bonding: bond0: first active interface up!
> ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
> eth0: no IPv6 routers present
> bond0: no IPv6 routers present
> bonding: bond0: released all slaves
> Unable to handle kernel paging request at ffffffff880a07ce RIP: 
>  [<ffffffff880a07ce>]
> PGD 203067 PUD 207063 PMD 2060f067 PTE 0
> Oops: 0010 [1] SMP 
> CPU 0 
> Modules linked in: ib_ipoib ib_cm ib_sa ipv6 sg st sd_mod sr_mod scsi_mod e100 ib_mthca ib_mad ib_core i2c_amd8111 i2c_core
> Pid: 14604, comm: bond0 Not tainted 2.6.24-rc1 #1
> RIP: 0010:[<ffffffff880a07ce>]  [<ffffffff880a07ce>]
> RSP: 0018:ffff810008439e98  EFLAGS: 00010247
> RAX: ffff810004da20c0 RBX: ffff810004da20c0 RCX: ffff81000315aa68
> RDX: ffff810004da20c8 RSI: ffff810008439ef0 RDI: ffff81000315aa60
> RBP: ffffffff880a07ce R08: ffff810008438000 R09: ffff81000152d0d8
> R10: ffff810004da20c0 R11: ffff810009574000 R12: 00000000fffffffc
> R13: ffffffffffffffff R14: ffffffff8063b820 R15: 0000000000000000
> FS:  00002af0c528b0a0(0000) GS:ffffffff805d4000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> CR2: ffffffff880a07ce CR3: 000000002852f000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process bond0 (pid: 14604, threadinfo ffff810008438000, task ffff8100024970c0)
> Stack:  ffffffff802445c6 ffff810008439f08 ffff810004da20c0 ffffffff80244652
>  ffffffff8024473f 0000000000000000 ffff8100024970c0 ffffffff80248320
>  ffff810008439f08 ffff810008439f08 0000000000000000 0000000000000000
> Call Trace:
>  [<ffffffff802445c6>] run_workqueue+0x83/0x10f
>  [<ffffffff80244652>] worker_thread+0x0/0xf7
>  [<ffffffff8024473f>] worker_thread+0xed/0xf7
>  [<ffffffff80248320>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff80248320>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff80247fe6>] kthread+0x3d/0x63
>  [<ffffffff8020c4a8>] child_rip+0xa/0x12
>  [<ffffffff80247fa9>] kthread+0x0/0x63
>  [<ffffffff8020c49e>] child_rip+0x0/0x12
> 
> 
> Code:  Bad RIP value.
> RIP  [<ffffffff880a07ce>]
>  RSP <ffff810008439e98>
> CR2: ffffffff880a07ce

the second type of oops is when I modprobe -r ib_ipoib after 
enslavement. I was not able to test this one with ethernet as the tg3 
code is built into my kernel

> Nov  7 14:31:56 dill kernel: bonding: bond0: Setting MII monitoring interval to 100.
> Nov  7 14:31:56 dill kernel: bonding: bond0: Adding slave ib0.
> Nov  7 14:31:56 dill kernel: bonding: bond0: Warning: enslaved VLAN challenged slave ib0. Adding VLANs will be blocked as long as ib0 is part of bond bond0
> Nov  7 14:31:56 dill kernel: bonding: bond0: Warning: The first slave device specified does not support setting the MAC address. Enabling the fail_over_mac option.<6>bonding: bond0: enslaving ib0 as a backup interface with a down link.
> Nov  7 14:31:56 dill kernel: bonding: bond0: Adding slave ib1.
> Nov  7 14:31:56 dill kernel: bonding: bond0: Warning: enslaved VLAN challenged slave ib1. Adding VLANs will be blocked as long as ib1 is part of bond bond0
> Nov  7 14:31:56 dill kernel: bonding: bond0: enslaving ib1 as a backup interface with a down link.
> Nov  7 14:31:56 dill kernel: bonding: bond0: link status definitely up for interface ib0.
> Nov  7 14:31:56 dill kernel: bonding: bond0: making interface ib0 the new active one.
> Nov  7 14:31:56 dill kernel: bonding: bond0: first active interface up!
> Nov  7 14:31:56 dill kernel: ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
> Nov  7 14:31:56 dill kernel: ib0: multicast join failed for 0001:ffff:ffff:0a0a:0081:ffff:c0bb:0a0a, status -22
> Nov  7 14:31:56 dill kernel: bonding: bond0: link status definitely up for interface ib1.
> Nov  7 14:31:58 dill kernel: ib0: multicast join failed for 0001:ffff:ffff:0a0a:0081:ffff:c0bb:0a0a, status -22
> Nov  7 14:32:02 dill kernel: ib0: multicast join failed for 0001:ffff:ffff:0a0a:0081:ffff:c0bb:0a0a, status -22
> Nov  7 14:32:07 dill kernel: bond0: no IPv6 routers present
> Nov  7 14:32:10 dill kernel: ib0: multicast join failed for 0001:ffff:ffff:0a0a:0081:ffff:c0bb:0a0a, status -22
> Nov  7 14:32:12 dill ypbind[14475]: broadcast: RPC: Timed out.
> Nov  7 14:32:18 dill kernel: ib0: cm send completion event with wrid 1073741823 (> 64)
> Nov  7 14:32:23 dill kernel: ib0: RX drain timing out
> Nov  7 14:32:23 dill kernel: bonding: bond0: Warning: the permanent HWaddr of ib0 - 80:06:04:04:fe:80 - is still in use by bond0. Set the HWaddr of ib0 to a different address to avoid conflicts.
> Nov  7 14:32:23 dill kernel: bonding: bond0: releasing active interface ib0
> Nov  7 14:32:23 dill kernel: bonding: bond0: making interface ib1 the new active one.
> Nov  7 14:32:23 dill kernel: ib1: multicast join failed for 0001:0000:ffff:0000:0000:0000:0070:5229, status -22
> Nov  7 14:32:23 dill kernel: bonding: bond0: releasing active interface ib1
> Nov  7 14:32:23 dill kernel: bonding: bond0: destroying bond bond0.
> Nov  7 14:32:23 dill kernel: __dev_addr_discard: address leakage! da_users=1
> Nov  7 14:32:23 dill kernel: Unable to handle kernel NULL pointer dereference at 0000000000000028 RIP: 
> Nov  7 14:32:23 dill kernel:  [<ffffffff802be76f>] sysfs_find_dirent+0x7/0x36
> Nov  7 14:32:23 dill kernel: PGD 250a067 PUD 40a4067 PMD 0 
> Nov  7 14:32:23 dill kernel: Oops: 0000 [1] SMP 
> Nov  7 14:32:23 dill kernel: CPU 1 
> Nov  7 14:32:23 dill kernel: Modules linked in: ib_ipoib ib_cm ib_sa bonding e100 ipv6 sg st sd_mod sr_mod scsi_mod ib_mthca ib_mad ib_core i2c_amd756 i2c_amd8111 i2c_core
> Nov  7 14:32:23 dill kernel: Pid: 18870, comm: modprobe Not tainted 2.6.24-rc1 #1
> Nov  7 14:32:23 dill kernel: RIP: 0010:[<ffffffff802be76f>]  [<ffffffff802be76f>] sysfs_find_dirent+0x7/0x36
> Nov  7 14:32:23 dill kernel: RSP: 0018:ffff8100264e3da8  EFLAGS: 00010246
> Nov  7 14:32:23 dill kernel: RAX: 0000000000000000 RBX: ffffffff88111959 RCX: 000000000000000a
> Nov  7 14:32:23 dill kernel: RDX: ffff8100264e3fd8 RSI: ffffffff88111959 RDI: 0000000000000000
> Nov  7 14:32:23 dill kernel: RBP: ffffffff88111959 R08: ffff810020705d70 R09: ffff810020012ae8
> Nov  7 14:32:23 dill kernel: R10: 0000000000000000 R11: 0000000000000286 R12: 0000000000000000
> Nov  7 14:32:23 dill kernel: R13: ffff810028d9e000 R14: 0000000000000006 R15: 0000000000515ab0
> Nov  7 14:32:23 dill kernel: FS:  00002adaba330720(0000) GS:ffff81002053dac0(0000) knlGS:0000000000000000
> Nov  7 14:32:23 dill kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Nov  7 14:32:23 dill kernel: CR2: 0000000000000028 CR3: 0000000001cca000 CR4: 00000000000006e0
> Nov  7 14:32:23 dill kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Nov  7 14:32:23 dill kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Nov  7 14:32:23 dill kernel: Process modprobe (pid: 18870, threadinfo ffff8100264e2000, task ffff8100264ed790)
> Nov  7 14:32:23 dill kernel: Stack:  0000000000000000 ffffffff88111959 ffffffff88117680 ffffffff802be87b
> Nov  7 14:32:23 dill kernel:  0000000000000006 0000000000000000 ffff810006578700 ffffffff802bfb83
> Nov  7 14:32:23 dill kernel:  ffff810020705d70 ffff810006578000 0000000000000000 ffffffff88107bd6
> Nov  7 14:32:24 dill kernel: Call Trace:
> Nov  7 14:32:24 dill kernel:  [<ffffffff802be87b>] sysfs_get_dirent+0x21/0x6c
> Nov  7 14:32:24 dill kernel:  [<ffffffff802bfb83>] sysfs_remove_group+0x1b/0x92
> Nov  7 14:32:24 dill kernel:  [<ffffffff88107bd6>] :bonding:bond_release_and_destroy+0x3d/0x44
> Nov  7 14:32:24 dill kernel:  [<ffffffff88107c92>] :bonding:bond_netdev_event+0xb5/0xca
> Nov  7 14:32:24 dill kernel:  [<ffffffff8046e55e>] notifier_call_chain+0x30/0x54
> Nov  7 14:32:24 dill kernel:  [<ffffffff8041845d>] unregister_netdevice+0xc3/0x15a
> Nov  7 14:32:24 dill kernel:  [<ffffffff80418505>] unregister_netdev+0x11/0x17
> Nov  7 14:32:24 dill kernel:  [<ffffffff880f2be4>] :ib_ipoib:ipoib_remove_one+0x64/0xa5
> Nov  7 14:32:24 dill kernel:  [<ffffffff88015069>] :ib_core:ib_unregister_client+0x43/0xfe
> Nov  7 14:32:24 dill kernel:  [<ffffffff880fb071>] :ib_ipoib:ipoib_cleanup_module+0xd/0x2b
> Nov  7 14:32:24 dill kernel:  [<ffffffff802557b1>] sys_delete_module+0x1b1/0x1e2
> Nov  7 14:32:24 dill kernel:  [<ffffffff80329b00>] __downgrade_write+0x5f/0xb1
> Nov  7 14:32:24 dill kernel:  [<ffffffff8026eb2e>] sys_munmap+0x4a/0x56
> Nov  7 14:32:24 dill kernel:  [<ffffffff8020b68e>] system_call+0x7e/0x83
> Nov  7 14:32:24 dill kernel: 
> Nov  7 14:32:24 dill kernel: 
> Nov  7 14:32:24 dill kernel: Code: 48 8b 5f 28 48 85 db 74 1c 48 8b 7b 18 48 89 ee e8 f6 b6 06 
> Nov  7 14:32:24 dill kernel: RIP  [<ffffffff802be76f>] sysfs_find_dirent+0x7/0x36
> Nov  7 14:32:24 dill kernel:  RSP <ffff8100264e3da8>
> Nov  7 14:32:24 dill kernel: CR2: 0000000000000028

the third type of oops is when I did some fail overs, then removed both 
slaves from the bond using
echo -$slave > /sys/class/net/bond0/bonding/slaves

> Ethernet Channel Bonding Driver: v3.2.1 (October 15, 2007)
> bonding: MII link monitoring set to 100 ms
> bonding: bond0: setting mode to active-backup (1).
> bonding: bond0: Setting MII monitoring interval to 100.
> ADDRCONF(NETDEV_UP): bond0: link is not ready
> bonding: bond0: doing slave updates when interface is down.
> bonding: bond0: Adding slave ib0.
> bonding bond0: master_dev is not up in bond_enslave
> bonding: bond0: Warning: enslaved VLAN challenged slave ib0. Adding VLANs will be blocked as long as ib0 is part of bond bond0
> bonding: bond0: enslaving ib0 as a backup interface with a down link.
> bonding: bond0: doing slave updates when interface is down.
> bonding: bond0: Adding slave ib1.
> bonding bond0: master_dev is not up in bond_enslave
> bonding: bond0: Warning: enslaved VLAN challenged slave ib1. Adding VLANs will be blocked as long as ib1 is part of bond bond0
> bonding: bond0: enslaving ib1 as a backup interface with a down link.
> ADDRCONF(NETDEV_UP): bond0: link is not ready
> bonding: bond0: link status definitely up for interface ib0.
> bonding: bond0: link status definitely up for interface ib1.
> bonding: bond0: making interface ib0 the new active one.
> bonding: bond0: first active interface up!
> ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
> bond0: no IPv6 routers present
> bonding: bond0: link status definitely down for interface ib0, disabling it
> bonding: bond0: making interface ib1 the new active one.
> bonding: bond0: link status definitely up for interface ib0.
> bonding: bond0: link status definitely down for interface ib1, disabling it
> bonding: bond0: making interface ib0 the new active one.
> bonding: bond0: Removing slave ib0
> bonding: bond0: Warning: the permanent HWaddr of ib0 - 80:08:04:04:fe:80 - is still in use by bond0. Set the HWaddr of ib0 to a different address to avoid conflicts.
> bonding: bond0: releasing active interface ib0
> bonding: bond0: Removing slave ib1
> bonding: bond0: releasing backup interface ib1
> bonding: bond0: destroying bond bond0.
> Unable to handle kernel NULL pointer dereference at 0000000000000028 RIP: 
>  [<ffffffff802be76f>] sysfs_find_dirent+0x7/0x36
> PGD 48a0067 PUD 285f067 PMD 0 
> Oops: 0000 [1] SMP 
> CPU 1 
> Modules linked in: ib_ipoib ib_cm ib_sa bonding ipv6 sg st sd_mod sr_mod scsi_mod e100 ib_mthca ib_mad ib_core i2c_amd756 i2c_amd8111 i2c_core
> Pid: 16811, comm: bash Not tainted 2.6.24-rc1 #1
> RIP: 0010:[<ffffffff802be76f>]  [<ffffffff802be76f>] sysfs_find_dirent+0x7/0x36
> RSP: 0018:ffff8100049a5dd8  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffffffff880ae959 RCX: 0000000000000002
> RDX: ffff8100049a5fd8 RSI: ffffffff880ae959 RDI: 0000000000000000
> RBP: ffffffff880ae959 R08: ffff8100205f5d70 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000202 R12: 0000000000000000
> R13: 0000000000000000 R14: ffff8100300c7000 R15: ffff8100049a5e69
> FS:  00002afe4e9870a0(0000) GS:ffff81002053dac0(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000028 CR3: 000000000248f000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process bash (pid: 16811, threadinfo ffff8100049a4000, task ffff810001d91750)
> Stack:  0000000000000000 ffffffff880ae959 ffffffff880b4680 ffffffff802be87b
>  0000000000000006 0000000000000000 ffff81000e081700 ffffffff802bfb83
>  ffff8100205f5d70 ffff81000e081000 0000000000000000 ffffffff880a4bd6
> Call Trace:
>  [<ffffffff802be87b>] sysfs_get_dirent+0x21/0x6c
>  [<ffffffff802bfb83>] sysfs_remove_group+0x1b/0x92
>  [<ffffffff880a4bd6>] :bonding:bond_release_and_destroy+0x3d/0x44
>  [<ffffffff880aa685>] :bonding:bonding_store_slaves+0x29a/0x352
>  [<ffffffff8038a0c7>] dev_attr_store+0x1c/0x1e
>  [<ffffffff802be03d>] sysfs_write_file+0xca/0xfc
>  [<ffffffff802832fa>] vfs_write+0xae/0x130
>  [<ffffffff8028343b>] sys_write+0x45/0x6e
>  [<ffffffff8020b68e>] system_call+0x7e/0x83
> 
> 
> Code: 48 8b 5f 28 48 85 db 74 1c 48 8b 7b 18 48 89 ee e8 f6 b6 06 
> RIP  [<ffffffff802be76f>] sysfs_find_dirent+0x7/0x36
>  RSP <ffff8100049a5dd8>
> CR2: 0000000000000028


here's the script I use to set the bond  & do the enslavement
> #!/bin/bash
> 
> SLAVE_A=ib0
> SLAVE_B=ib1
> ADDR=192.168.10.118
> 
> #SLAVE_A=eth0
> #SLAVE_B=eth1
> #ADDR=172.30.10.6
> 
> /sbin/modprobe bonding
> 
> echo 1 > /sys/class/net/bond0/bonding/mode
> echo 100 > /sys/class/net/bond0/bonding/miimon
> 
> /sbin/modprobe ib_ipoib
> 
> echo +$SLAVE_A > /sys/class/net/bond0/bonding/slaves
> echo +$SLAVE_B > /sys/class/net/bond0/bonding/slaves
> 
> ifconfig bond0 $ADDR

Or.


--------------050608090303090702020405
Content-Type: application/octet-stream;
 name="config-2.6.24-rc1.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="config-2.6.24-rc1.bz2"

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
--------------050608090303090702020405--

