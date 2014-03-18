From: Olaf Hering <olaf@aepfle.de>
Subject: hv_netvsc calls RTM_NEWLINK with eth%d
Date: Tue, 18 Mar 2014 19:52:18 +0100
Message-ID: <20140318185218.GA28692@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Haiyang Zhang <haiyangz@microsoft.com>, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.221]:65202 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757410AbaCRS6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 14:58:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For some reason 'modprobe -r hv_netvsc;modprobe hv_netvsc' causes a
RTM_NEWLINK message with ifname "eth%d". This confuses applications
reacting to RTM_NEWLINK messages. At the time they actually get to
processing the message eth%d is already renamed to eth0 (I think).

I added lots of debug to trace RTM_NEWLINK calls, and it turned out that
the event is issued before register_netdevice calls dev_get_valid_name.

Is there a chance to rearrange the calls in netvsc_probe, so that
RTM_NEWLINK messages with ifname "eth%d" do not happen anymore?

Olaf


....
[   93.145217] hv_vmbus: unregistering driver hv_netvsc
[   93.145624] OLH dev_close_many(1377) bash[1539]->modprobe[1590] RTM_NEWLINK
[   93.167734] hv_netvsc vmbus_0_15: net device safe to remove
[   93.258263] OLH inet6_dump_ifinfo(4450) systemd[1]->wickedd[670] RTM_NEWLINK
[  101.227705] hv_vmbus: registering driver hv_netvsc
[  101.229406] hv_netvsc: hv_netvsc channel opened successfully
[  102.068861] OLH rtnetlink_event(2846) kthreadd[2]->kworker/1:1[23] RTM_NEWLINK eth%d
[  102.068868] ------------[ cut here ]------------
[  102.068882] WARNING: CPU: 1 PID: 23 at /home/abuild/rpmbuild/BUILD/kernel-default-3.12.14/linux-3.12/net/core/rtnetlink.c:2847 rtnetlink_event+0x87/0xa0()
[  102.068885] Modules linked in: hv_netvsc(FX+) fuse(F) iscsi_ibft(F) iscsi_boot_sysfs(F) af_packet(F) crct10dif_pclmul(F) crc32_pclmul(F) crc32c_intel(F) ghash_clmulni_intel(FX) joydev(F) aesni_intel(F) aes_x86_64(F) lrw(F) gf128mul(F) glue_helper(F) ablk_helper(F) cryptd(F) hv_balloon(FX) hv_utils(FX) hyperv_keyboard(FX) processor(F) hyperv_fb(FX) serio_raw(F) i2c_piix4(F) pcspkr(F) button(F) dm_mod(F) xfs(F) libcrc32c(F) hid_generic(F) sd_mod(F) hid_hyperv(FX) hv_storvsc(FX) sr_mod(F) cdrom(F) ata_generic(F) ata_piix(F) ahci(F) libahci(F) libata(F) hv_vmbus(FX) floppy(F) sg(F) scsi_mod(F) autofs4(F) [last unloaded: hv_netvsc]
[  102.068946] Supported: No, Unsupported modules are loaded
[  102.068952] CPU: 1 PID: 23 Comm: kworker/1:1 Tainted: GF       W    X 3.12.14-1395166319-default #1
[  102.068956] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[  102.068965] Workqueue: events netvsc_send_garp [hv_netvsc]
[  102.068969]  0000000000000009 ffffffff814e2068 0000000000000000 ffffffff81051ea2
[  102.068976]  ffff88004fa9a000 ffffffff81acc4c0 0000000000000000 0000000000000013
[  102.068982]  ffff88003cf67e30 ffffffff81411967 0000000000000017 ffff88004fa9a000
[  102.068988] Call Trace:
[  102.069009]  [<ffffffff81004478>] dump_trace+0x78/0x2c0
[  102.069019]  [<ffffffff8100474f>] show_stack_log_lvl+0x8f/0x170
[  102.069027]  [<ffffffff81005a2c>] show_stack+0x1c/0x50
[  102.069038]  [<ffffffff814e2068>] dump_stack+0x41/0x51
[  102.069051]  [<ffffffff81051ea2>] warn_slowpath_common+0x72/0x90
[  102.069061]  [<ffffffff81411967>] rtnetlink_event+0x87/0xa0
[  102.069073]  [<ffffffff814eb7f4>] notifier_call_chain+0x44/0x70
[  102.069084]  [<ffffffff813fd25d>] netdev_notify_peers+0x1d/0x30
[  102.069094]  [<ffffffff8106badd>] process_one_work+0x16d/0x420
[  102.069104]  [<ffffffff8106c6d6>] worker_thread+0x116/0x3b0
[  102.069112]  [<ffffffff81072c5f>] kthread+0xaf/0xc0
[  102.069121]  [<ffffffff814ef64c>] ret_from_fork+0x7c/0xb0
[  102.069129] ---[ end trace 1a582338def2e1f5 ]---
[  102.069473] hv_netvsc vmbus_0_15: Device MAC 00:15:5d:08:66:11 link state up
[  102.069783] OLH register_netdevice(5748) bash[1539]->modprobe[1639] RTM_NEWLINK eth0
[  102.069787] ------------[ cut here ]------------
[  102.069798] WARNING: CPU: 1 PID: 1639 at /home/abuild/rpmbuild/BUILD/kernel-default-3.12.14/linux-3.12/net/core/dev.c:5749 register_netdevice+0x370/0x3e0()
[  102.069801] Modules linked in: hv_netvsc(FX+) fuse(F) iscsi_ibft(F) iscsi_boot_sysfs(F) af_packet(F) crct10dif_pclmul(F) crc32_pclmul(F) crc32c_intel(F) ghash_clmulni_intel(FX) joydev(F) aesni_intel(F) aes_x86_64(F) lrw(F) gf128mul(F) glue_helper(F) ablk_helper(F) cryptd(F) hv_balloon(FX) hv_utils(FX) hyperv_keyboard(FX) processor(F) hyperv_fb(FX) serio_raw(F) i2c_piix4(F) pcspkr(F) button(F) dm_mod(F) xfs(F) libcrc32c(F) hid_generic(F) sd_mod(F) hid_hyperv(FX) hv_storvsc(FX) sr_mod(F) cdrom(F) ata_generic(F) ata_piix(F) ahci(F) libahci(F) libata(F) hv_vmbus(FX) floppy(F) sg(F) scsi_mod(F) autofs4(F) [last unloaded: hv_netvsc]
[  102.069854] Supported: No, Unsupported modules are loaded
[  102.069860] CPU: 1 PID: 1639 Comm: modprobe Tainted: GF       W    X 3.12.14-1395166319-default #1
[  102.069863] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[  102.069866]  0000000000000009 ffffffff814e2068 0000000000000000 ffffffff81051ea2
[  102.069873]  ffff88004fa9a000 0000000000000000 ffffffff81ac9cc0 0000000000000000
[  102.069878]  0000000000000001 ffffffff81404e20 ffffffff00000667 ffff88004fa9a000
[  102.069884] Call Trace:
[  102.069903]  [<ffffffff81004478>] dump_trace+0x78/0x2c0
[  102.069912]  [<ffffffff8100474f>] show_stack_log_lvl+0x8f/0x170
[  102.069920]  [<ffffffff81005a2c>] show_stack+0x1c/0x50
[  102.069929]  [<ffffffff814e2068>] dump_stack+0x41/0x51
[  102.069939]  [<ffffffff81051ea2>] warn_slowpath_common+0x72/0x90
[  102.069950]  [<ffffffff81404e20>] register_netdevice+0x370/0x3e0
[  102.069962]  [<ffffffff81404ea1>] register_netdev+0x11/0x20
[  102.069974]  [<ffffffffa031c33a>] netvsc_probe+0x14a/0x1d0 [hv_netvsc]
[  102.069996]  [<ffffffffa0077bef>] vmbus_probe+0x2f/0x90 [hv_vmbus]
[  102.070012]  [<ffffffff81378025>] driver_probe_device+0x115/0x3a0
[  102.070023]  [<ffffffff8137836b>] __driver_attach+0x7b/0x80
[  102.070035]  [<ffffffff81375fe3>] bus_for_each_dev+0x53/0x90
[  102.070045]  [<ffffffff813775b8>] bus_add_driver+0x1e8/0x2b0
[  102.070057]  [<ffffffff81378936>] driver_register+0x56/0xd0
[  102.070068]  [<ffffffff810002c2>] do_one_initcall+0xf2/0x1a0
[  102.070080]  [<ffffffff810bfb6a>] load_module+0x123a/0x1c50
[  102.070092]  [<ffffffff810c06d5>] SYSC_finit_module+0x75/0xa0
[  102.070102]  [<ffffffff814ef6f9>] system_call_fastpath+0x16/0x1b
[  102.070112]  [<00007fe8a85b6739>] 0x7fe8a85b6738
[  102.070116] ---[ end trace 1a582338def2e1f6 ]---
[  102.144513] OLH inet6_dump_ifinfo(4450) systemd[1]->wickedd[670] RTM_NEWLINK
...
