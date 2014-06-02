From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 3.14-stable] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Mon, 2 Jun 2014 21:53:34 +0800
Message-ID: <20140602135334.GA28523@richard>
References: <1401607475-8367-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20140601073853.GA8635@richard>
 <538AF2CB.20603@mellanox.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:35171 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161AbaFBNxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 09:53:43 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 2 Jun 2014 19:23:40 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id C30F9394004E
	for <netdev@vger.kernel.org>; Mon,  2 Jun 2014 19:23:38 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s52Drn9454657222
	for <netdev@vger.kernel.org>; Mon, 2 Jun 2014 19:23:49 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s52Dra4V014388
	for <netdev@vger.kernel.org>; Mon, 2 Jun 2014 19:23:37 +0530
Content-Disposition: inline
In-Reply-To: <538AF2CB.20603@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 01, 2014 at 12:30:51PM +0300, Or Gerlitz wrote:
>On 01/06/2014 10:38, Wei Yang wrote:
>>David, Following are the backport of this patch to 3.14, 3.10, 3.4 and 3.2 stable tree.
>
>
>Wait,
>
>I recently noticed that on 3.15-rcX if the host is rebooted when the
>mlx4_core driver is loaded in SRIOV mode, we crash like that,
>looking on this now, I think there's chance we can relate it to your
>upstream change befdf89 "net/mlx4_core: Preserve pci_dev_data after
>__mlx4_remove_one()"
>
>Or.

Or,

Thanks for your notification, I saw your patch to fix this issue.
Sorry for bringing a bug in the driver and thanks for your test :-)
Hmm... actually I don't understand how you trigger this crash?

The mlx4_priv is released when mlx4_remove_one() is called. In my mind, when
this function is called, this means the driver for this device should be
released, including the mlx4_priv. And next time, when mlx4 driver want to
attach to the device, mlx4_init_one() will be called to create the mlx4_priv.
So I don't come out a case when the driver is detached and next time without
attaching it will be released again? Sounds I haved missed some point, if you
could let me understand this special case, I would appreciate it very much.

Last but not the least, based on the fix you have submitted, the porting here
is correct. My suggestion is after your fix is merged, you could do the
porting to those version too.

>
>
>[  152.121286] mlx4_core 0000:06:00.0: Received reset from slave:2
>[  152.128031] mlx4_core 0000:06:00.0: Have more references for index
>0,no need to modify mac table
>[  152.209248] mlx4_core 0000:06:00.0: Received reset from slave:1
>[  152.215889] mlx4_core 0000:06:00.0: Have more references for index
>0,no need to modify mac table
>[  152.216305] sd 1:0:1:0: [sdd] Synchronizing SCSI cache
>[  152.221714] sd 1:0:0:0: [sdc] Synchronizing SCSI cache
>[  152.227108] sd 0:0:1:0: [sdb] Synchronizing SCSI cache
>[  152.232494] sd 0:0:0:0: [sda] Synchronizing SCSI cache
>[  152.271991] mlx4_en 0000:06:00.0: removed PHC
>[  152.281611] mlx4_core 0000:06:00.0: Have more references for index
>0,no need to modify mac table
>[  152.318395] mlx4_core 0000:06:00.0: Disabling SR-IOV
>[  152.323513] BUG: unable to handle kernel NULL pointer dereference
>at 0000000000000378
>[  152.331523] IP: [<ffffffffa01668e0>] __mlx4_remove_one+0x20/0x370
>[mlx4_core]
>[  152.338778] PGD 0
>[  152.340908] Oops: 0000 [#1] PREEMPT SMP
>[  152.345058] Modules linked in: netconsole nfsv3 nfs_acl
>auth_rpcgss oid_registry nfsv4 nfs lockd autofs4 8021q sunrpc
>cpufreq_ondemand bridge stp llc ext4 jbd2 cr
>c16 raid0 dm_mirror dm_region_hash dm_log vhost_net macvtap macvlan
>vhost tun kvm_intel kvm dm_mod ixgbevf microcode pcspkr joydev
>i2c_i801 sg ehci_pci ehci_hcd mlx4
>_ib mlx4_en ioatdma ib_sa ib_mad ib_core ib_addr vxlan ipv6 mlx4_core
>ixgbe mdio igb dca ptp pps_core hwmon button ext3 jbd sd_mod ata_piix
>libata scsi_mod uhci_hcd
>[  152.392161] CPU: 8 PID: 4557 Comm: reboot Not tainted 3.15.0-rc6+ #149
>[  152.398760] Hardware name: Supermicro X8DTU/X8DTU, BIOS 2.1c
>08/03/2012
>[  152.405954] task: ffff880331fca490 ti: ffff8800bb1a6000 task.ti:
>ffff8800bb1a6000
>[  152.413507] RIP: 0010:[<ffffffffa01668e0>] [<ffffffffa01668e0>]
>__mlx4_remove_one+0x20/0x370 [mlx4_core]
>[  152.423220] RSP: 0018:ffff8800bb1a7b98  EFLAGS: 00010286
>[  152.428598] RAX: 0000000000000000 RBX: ffff880630a78098 RCX:
>0000000000000000
>[  152.435793] RDX: 0000000000000000 RSI: 0000000000000202 RDI:
>ffff880630a78098
>[  152.442987] RBP: ffff8800bb1a7bc8 R08: 0000000000000000 R09:
>ffffffff81584556
>[  152.450181] R10: ffffea000cc42e18 R11: ffffffff811ab129 R12:
>ffff880630a78000
>[  152.457374] R13: ffff880630a78000 R14: 0000000000000000 R15:
>ffff8800bb1a7cc8
>[  152.464568] FS:  00007f60f21f6700(0000) GS:ffff88063fc80000(0000)
>knlGS:0000000000000000
>[  152.472731] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>[  152.478538] CR2: 0000000000000378 CR3: 00000000bcdf0000 CR4:
>00000000000007e0
>[  152.485734] Stack:
>[  152.487805]  0000000000000000 ffff880630a78098 ffff880630a78000
>0000000000000000
>[  152.495534]  0000000000000000 ffff8800bb1a7cc8 ffff8800bb1a7bf8
>ffffffffa0166c91
>[  152.503264]  ffff880630a78098 ffff880630a78098 ffffffffa0181640
>ffff880630a78000
>[  152.510978] Call Trace:
>[  152.513492]  [<ffffffffa0166c91>] mlx4_remove_one+0x31/0x60 [mlx4_core]
>[  152.520172]  [<ffffffff81231da1>] pci_device_remove+0x41/0xc0
>[  152.525987]  [<ffffffff812ef30a>] __device_release_driver+0x7a/0xe0
>[  152.532320]  [<ffffffff812ef468>] device_release_driver+0x28/0x40
>[  152.538475]  [<ffffffff8122bd6c>] pci_stop_bus_device+0x9c/0xb0
>[  152.544461]  [<ffffffff8122bfa1>]
>pci_stop_and_remove_bus_device+0x11/0x20
>[  152.551399]  [<ffffffff8124576d>] virtfn_remove.clone.0+0xdd/0x140
>[  152.557645]  [<ffffffff812ed30e>] ? dev_warn+0x4e/0x50
>[  152.562841]  [<ffffffff8124582f>] pci_disable_sriov+0x5f/0xf0
>[  152.568655]  [<ffffffffa0166bf4>] __mlx4_remove_one+0x334/0x370
>[mlx4_core]
>[  152.575685]  [<ffffffffa0166c91>] mlx4_remove_one+0x31/0x60 [mlx4_core]
>[  152.582364]  [<ffffffff81231b1c>] pci_device_shutdown+0x3c/0x90
>[  152.588343]  [<ffffffff812ed105>] device_shutdown+0x15/0x180
>[  152.594065]  [<ffffffff81085891>] kernel_restart_prepare+0x31/0x40
>[  152.600304]  [<ffffffff81085a51>] kernel_restart+0x11/0x60
>[  152.605851]  [<ffffffff81085c60>] SyS_reboot+0x1b0/0x200
>[  152.611226]  [<ffffffff81159c83>] ? mntput_no_expire+0x33/0x180
>[  152.617204]  [<ffffffff81159dec>] ? mntput+0x1c/0x30
>[  152.622232]  [<ffffffff8113c804>] ? __fput+0x144/0x1f0
>[  152.627432]  [<ffffffff8113c949>] ? ____fput+0x9/0x10
>[  152.632545]  [<ffffffff8107d07c>] ? task_work_run+0x8c/0xe0
>[  152.638180]  [<ffffffff81002a64>] ? do_notify_resume+0x74/0x80
>[  152.644075]  [<ffffffff810cd6f6>] ? __audit_syscall_exit+0x236/0x2e0
>[  152.650490]  [<ffffffff81476d72>] ? int_signal+0x12/0x17
>[  152.655869]  [<ffffffff81476ab9>] system_call_fastpath+0x16/0x1b
>[  152.661935] Code: 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 41
>57 41 56 41 55 49 89 fd 48 8d bf 98 00 00 00 41 54 53 48 83 ec 08 e8
>60 86 18 e1 <8b> 90 78 03 00 00 48 89 c3 85 d2 0f 85 30 02 00 00 f6
>40 08 04
>[  152.684806] RIP  [<ffffffffa01668e0>] __mlx4_remove_one+0x20/0x370
>[mlx4_core]
>[  152.692170]  RSP <ffff8800bb1a7b98>
>[  152.695723] CR2: 0000000000000378
>[  152.699163] ---[ end trace 9c36c3b85b765771 ]---
>
>
>
>>
>>On 3.14, only this patch is backported.
>>On 3.10, a previous related one "pass pci_device_id.driver_data to
>>          __mlx4_init_one during reset" is backported too.
>>On 3.4,  "pass pci_device_id.driver_data to __mlx4_init_one during reset" is
>>          not backported, since the slot_reset handler is not presented.
>>	 While another one, "Stash PCI ID driver_data in mlx4_priv structure"
>>	 is backported to make this patch valid on this version.
>>On 3.2,  The same as 3.4.
>>
>>All version are compiled successfully. 3.14 and 3.10 are verified, while 3.4
>>and 3.2 are not.
>>
>>I am not sure how to make them all in one big patch set, so send them
>>seperatedly. Each version is contained in one patch set. If there is a better
>>way for you to merge them, please let me know.
>>
>>At last, Happy Children's Day for all :-)
>>

-- 
Richard Yang
Help you, Help me
