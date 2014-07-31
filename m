From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: be2net crash on next-20140730 ("Driver probe function
 unexpectedly returned 1966082")
Date: Thu, 31 Jul 2014 10:05:04 +0000
Message-ID: <a878bff1-40f2-4f8c-af6a-78ccb5d0b1ac@CMEXHTCAS2.ad.emulex.com>
References: <20140731044427.GA5543@thinpad.lan.raisama.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"'Ivan Vecera (ivecera@redhat.com)'" <ivecera@redhat.com>
To: Eduardo Habkost <ehabkost@redhat.com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140731044427.GA5543@thinpad.lan.raisama.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Eduardo Habkost [mailto:ehabkost@redhat.com]
> 
> Hi,
> 
> When running next-20140730 form linux-next, I get the following on dmesg:
> 
> be2net 0000:02:00.0: PCIe error reporting enabled
> be2net 0000:02:00.0: adapter not in advanced mode
> be2net 0000:02:00.0: Emulex OneConnect(be3) initialization failed
> be2net 0000:02:00.0: Driver probe function unexpectedly returned 1966082
> be2net 0000:02:00.1: PCIe error reporting enabled
> be2net 0000:02:00.1: adapter not in advanced mode
> be2net 0000:02:00.1: Emulex OneConnect(be3) initialization failed
> be2net 0000:02:00.1: Driver probe function unexpectedly returned 1966082
> 
> Some debugging revealed that be_get_config() is returning 1966082.
> 
> Machine is a HP ProLiant BL460c G7.
Hi, looks like this issue is occurring on adapters with old FW versions (< v4.2)
after the recent net-next commit bec84e6b ("create optimal number of queues on SR-IOV config")

We're cooking a fix; I'll post a patch for this as soon  as it's ready.
Thanks for reporting this issue!

-Sathya

> 
> It causes the following crash, on module unload:
> 
> BUG: unable to handle kernel NULL pointer dereference at
> 000000000000003e
> IP: [<ffffffffa02198e4>] be_roce_dev_remove+0x14/0xa0 [be2net]
> PGD 205429067 PUD 2004ea067
> PMD 0
> Oops: 0000 [#1] SMP
> Modules linked in: ip6_tables ebtable_nat ebtables nf_conntrack_ipv4
> nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM
> iptable_mangle iptable_filter ip_tables bridge stp llc autofs4 sunrpc cpuf
> net macvtap macvlan vhost tun kvm_intel kvm iTCO_wdt
> iTCO_vendor_support microcode serio_raw hpilo hpwdt lpc_ich mfd_core
> i7core_edac edac_core ses enclosure sg be2iscsi iscsi_boot_sysfs libiscsi
> scsi_tr
> (E) mbcache(E) sd_mod(E) hpsa(E) lpfc(E) scsi_transport_fc(E) crc_t10dif(E)
> dm_mirror(E) dm_region_hash(E) dm_log(E) dm_mod(E)
> CPU: 14 PID: 3010 Comm: rmmod Tainted: G            E  3.16.0-rc7-next-
> 20140730+ #2
> Hardware name: HP ProLiant BL460c G7, BIOS I27 05/05/2011
> task: ffff880206328f20 ti: ffff8802004f0000 task.ti: ffff8802004f0000
> RIP: 0010:[<ffffffffa02198e4>]  [<ffffffffa02198e4>]
> be_roce_dev_remove+0x14/0xa0 [be2net]
> RSP: 0018:ffff8802004f3d78  EFLAGS: 00010296
> RAX: 0000000000000000 RBX: ffff880204600880 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000206 RDI: ffff880204600880
> RBP: ffff8802004f3d88 R08: 0000000000000000 R09: ffffffff81839f5c
> R10: ffff880107a9a858 R11: 0000000000000001 R12: ffff880206fd3000
> R13: ffff880206fd3000 R14: ffffffffa021cc80 R15: 0000000000000001
> FS:  00007f10627f6700(0000) GS:ffff88020bae0000(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 000000000000003e CR3: 000000020642e000 CR4: 00000000000007e0
> Stack:
> ffff8802004f3da8 ffff880204600880 ffff8802004f3dd8 ffffffffa020db1c
> 0000000000000004 0000000000000206 ffff8802004f3dd8 ffff880206fd3098
> ffffffffa021cc80 ffff880206fd3000 ffffffffa021cc80 0000000000000001
> Call Trace:
> [<ffffffffa020db1c>] be_remove+0x3c/0x130 [be2net]
> [<ffffffff812d0f26>] pci_device_remove+0x46/0xc0
> [<ffffffff8139502f>] __device_release_driver+0x7f/0xf0
> [<ffffffff81395158>] driver_detach+0xb8/0xc0
> [<ffffffff81393e99>] bus_remove_driver+0x59/0xd0
> [<ffffffff81395f10>] driver_unregister+0x30/0x70
> [<ffffffff810cd260>] ? show_refcnt+0x40/0x40
> [<ffffffff812d1093>] pci_unregister_driver+0x23/0x80
> [<ffffffffa0219a34>] be_exit_module+0x10/0x12 [be2net]
> [<ffffffff810ce211>] SyS_delete_module+0x181/0x1e0
> [<ffffffff8158c992>] system_call_fastpath+0x16/0x1b
> Code: c9 c3 48 c7 c7 a0 cd 21 a0 e8 a9 04 37 e1 b8 ea ff ff ff eb e6 66 90 55 48 89
> e5 53 48 83 ec 08 66 66 66 66 90 48 8b 07 48 89 fb <0f> b7 40 3e 66 3d 28 07 75
> 72 f6 83 d0 5c 14 00 04 75 09 48 83
> RIP  [<ffffffffa02198e4>] be_roce_dev_remove+0x14/0xa0 [be2net]
> RSP <ffff8802004f3d78>
> CR2: 000000000000003e
> ---[ end trace 7ac7af37404c6862 ]---
> 
> 
> And the following, on shutdown:
> 
> kvm: exiting hardware virtualization
> BUG: unable to handle kernel paging request at 0000000000010004
> IP: [<ffffffff8158c381>] _raw_spin_lock_irqsave+0x11/0x30
> PGD 0
> Oops: 0002 [#1] SMP
> Modules linked in: ip6_tables ebtable_nat ebtables nf_conntrack_ipv4
> nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM
> iptable_mangle iptable_filter ip_tables bridge stp llc autofs4 sunrpc
> pcc_cpufreq ipv6 vhost_net macvtap macvlan vhost tun kvm_intel kvm
> iTCO_wdt iTCO_vendor_support microcode serio_raw hpilo hpwdt lpc_ich
> mfd_core i7core_edac edac_core ses enclosure sg be2iscsi iscsi_boot_sysfs
> libiscsi scsi_transport_iscsi be2net ext4(E) jbd2(E) mbcache(E) sd_mod(E)
> hpsa(E) lpfc(E) scsi_transport_fc(E) crc_t10dif(E) dm_mirror(E)
> dm_region_hash(E) dm_log(E) dm_mod(E) [last unloaded:
> cpufreq_ondemand]
> CPU: 0 PID: 7147 Comm: reboot Tainted: G            E  3.16.0-rc7-next-20140730+
> #2
> Hardware name: HP ProLiant BL460c G7, BIOS I27 05/05/2011
> task: ffff8800e5258de0 ti: ffff8800ee5c0000 task.ti: ffff8800ee5c0000
> RIP: 0010:[<ffffffff8158c381>]  [<ffffffff8158c381>]
> _raw_spin_lock_irqsave+0x11/0x30
> RSP: 0018:ffff8800ee5c3c68  EFLAGS: 00010002
> RAX: 0000000000000002 RBX: 0000000000010004 RCX: 0000000000000000
> RDX: 0000000000010000 RSI: ffff8800ee5c3cb0 RDI: 0000000000010004
> RBP: ffff8800ee5c3c68 R08: ffff880206fd50b0 R09: 0000000000000001
> R10: 0002000100004420 R11: 0000442000004411 R12: ffff8800ecd46400
> R13: ffff8800ee5c3cb0 R14: 0000000000010006 R15: ffffffff81a45ac0
> FS:  00007fa9e4c1a700(0000) GS:ffff88020ba00000(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000010004 CR3: 00000000ee7e3000 CR4: 00000000000007f0
> Stack:
>  ffff8800ee5c3c98 ffffffff810b2a0c ffff8800ecd46400 ffff8800ee5c3d30
>  0000000000000000 00007fffbcaa0910 ffff8800ee5c3cd8 ffffffff810b3776
>  ffff8800ee5c3cb8 ffffffff81031b05 ffff8800ee5c3cc8 ffff8800ecd463e0
> Call Trace:
>  [<ffffffff810b2a0c>] lock_timer_base+0x3c/0x70
>  [<ffffffff810b3776>] del_timer+0x36/0x70
>  [<ffffffff81031b05>] ? acpi_unregister_gsi_ioapic+0x35/0x40
>  [<ffffffff8106c3e9>] try_to_grab_pending+0xf9/0x160
>  [<ffffffff8106cac6>] __cancel_work_timer+0x36/0x110
>  [<ffffffff8106cbb3>] cancel_delayed_work_sync+0x13/0x20
>  [<ffffffffa0209531>] be_shutdown+0x31/0x70 [be2net]
>  [<ffffffff812d0a91>] pci_device_shutdown+0x41/0x90
>  [<ffffffff81391f3d>] device_shutdown+0x1d/0x170
>  [<ffffffff81074086>] kernel_restart_prepare+0x36/0x40
>  [<ffffffff81074256>] kernel_restart+0x16/0x60
>  [<ffffffff8107446d>] SYSC_reboot+0x1ad/0x230
>  [<ffffffff811b2fc1>] ? __dentry_kill+0x161/0x1e0
>  [<ffffffff811b35bd>] ? dput+0xcd/0x1a0
>  [<ffffffff811ba273>] ? mntput+0x23/0x40
>  [<ffffffff8119cf30>] ? __fput+0x170/0x250
>  [<ffffffff8119d0be>] ? ____fput+0xe/0x10
>  [<ffffffff8106ffc4>] ? task_work_run+0x94/0xf0
>  [<ffffffff81003be4>] ? do_notify_resume+0x84/0x90
>  [<ffffffff810744fe>] SyS_reboot+0xe/0x10
>  [<ffffffff8158c992>] system_call_fastpath+0x16/0x1b
> Code: c9 c3 e8 03 b8 b0 ff c9 66 90 c3 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00
> 55 48 89 e5 66 66 66 66 90 9c 58 fa ba 00 00 01 00 <f0> 0f c1 17 89 d1 c1 e9 10 66
> 39 d1 75 04 c9 c3 f3 90 0f b7 17
> RIP  [<ffffffff8158c381>] _raw_spin_lock_irqsave+0x11/0x30
>  RSP <ffff8800ee5c3c68>
> CR2: 0000000000010004
> ---[ end trace d4f1cf5b9b2d2971 ]---
> 
> 
> --
> Eduardo
