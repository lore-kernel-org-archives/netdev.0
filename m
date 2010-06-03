From: Narendra K <Narendra_K@dell.com>
Subject: Re: Call trace related to bonding seen in 2.6.34
Date: Thu, 3 Jun 2010 04:58:08 -0500
Message-ID: <20100603095808.GA15044@auslistsprd01.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE6128C6@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:49223 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758925Ab0FCKHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:07:40 -0400
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE6128C6@blrx3m08.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hello,
> 
> Call trace related to bond_mii_monitor  as described in this thread -
> http://patchwork.ozlabs.org/patch/41288/ was seen on 2.6.34 kernel.
> (Trace is similar to what is described in the post dated 2009-12-17
> 21:31:36.) The trace is seen when the network service is stopped. The
> issue occurs when the network service is started and stopped in quick
> succession. 
> 
> Bonding device configuration parameters are as below -
> 
> Bonding driver version:3.6.0
> Mode: balance-alb (issue is also seen with active-backup mode)
> Miimon=100
> 3 slaves with link up and one slave with link down.
> 
> Though this requires more thought and investigation, I thought this
> could be a good data point. The below change to the bonding driver
> seemed to make the issue go away -
> 
> drivers/net/bonding/bond_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c
> b/drivers/net/bonding/bond_main.c
> index 0075514..f280aaf 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2408,7 +2408,7 @@ void bond_mii_monitor(struct work_struct *work)
>         }
> 
>  re_arm:
> -       if (bond->params.miimon)
> +       if (bond->params.miimon && !bond->kill_timers)
>                 queue_delayed_work(bond->wq, &bond->mii_work,
>  
> msecs_to_jiffies(bond->params.miimon));
>  out:
> 
> Any thoughts ?

Sorry, i missed attaching the trace here. Please find the trace below -

[  270.811391] bonding: bond0: Removing slave eth0
[  270.815934] bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:22:19:5b:8b:97 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
[  270.831913] bonding: bond0: releasing active interface eth0
[  270.831919] device eth0 left promiscuous mode
[  270.831953] bonding: bond0: making interface eth1 the new active one.
[  270.904113] ------------[ cut here ]------------
[  270.908076] kernel BUG at kernel/workqueue.c:354!
[  270.908076] invalid opcode: 0000 [#1] SMP 
[  270.908076] last sysfs file: /sys/devices/virtual/net/bond0/bonding/slaves
[  270.908076] CPU 0 
[  270.908076] Modules linked in: af_packet bonding ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq microcode fuse loop dm_mod joydev sg iTCO_wdt usbhid rtc_cmos rtc_core mptctl iTCO_vendor_support pcspkr hid tpm_tis ioatdma tpm dca bnx2 rtc_lib power_meter serio_raw sr_mod dcdbas tpm_bios cdrom button uhci_hcd ehci_hcd sd_mod crc_t10dif usbcore edd ext3 mbcache jbd fan processor ide_pci_generic ide_core ata_generic ata_piix libata mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[  270.908076] 
[  270.908076] Pid: 14690, comm: bond0 Not tainted 2.6.34-upstream #1 0K399H/PowerEdge R610
[  270.908076] RIP: 0010:[<ffffffff81062366>]  [<ffffffff81062366>] queue_delayed_work_on+0x106/0x110
[  270.908076] RSP: 0018:ffff880423b1ddc0  EFLAGS: 00010282
[  270.908076] RAX: 0000000000000000 RBX: ffff880423a289f0 RCX: 0000000000000019
[  270.908076] RDX: 0000000000000000 RSI: ffff880417871a00 RDI: 00000000ffffffff
[  270.908076] RBP: ffff880423b1ddf0 R08: 0000000000000018 R09: 0000000000000001
[  270.908076] R10: 0000000000000000 R11: 0000000000000003 R12: ffff880423a286c0
[  270.908076] R13: ffff880417871a00 R14: 00000000ffffffff R15: 0000000000000019
[  270.908076] FS:  0000000000000000(0000) GS:ffff880237200000(0000) knlGS:0000000000000000
[  270.908076] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  270.908076] CR2: 00007f6b162da980 CR3: 0000000001604000 CR4: 00000000000006f0
[  270.908076] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  270.908076] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  270.908076] Process bond0 (pid: 14690, threadinfo ffff880423b1c000, task ffff880423980100)
[  270.908076] Stack:
[  270.908076]  ffff880423980100 ffff8802261b1a00 ffff880423a286c0 0000000000000003
[  270.908076] <0> ffff880423a289f0 0000000000000000 ffff880423b1de00 ffffffff810623ac
[  270.908076] <0> ffff880423b1de50 ffffffffa030c331 ffffffff8160c020 ffff880423a286f0
[  270.908076] Call Trace:
[  270.908076]  [<ffffffff810623ac>] queue_delayed_work+0x1c/0x30
[  270.908076]  [<ffffffffa030c331>] bond_mii_monitor+0x371/0x600 [bonding]
[  270.908076]  [<ffffffffa030bfc0>] ? bond_mii_monitor+0x0/0x600 [bonding]
[  270.908076]  [<ffffffff81061523>] worker_thread+0x133/0x200
[  270.908076]  [<ffffffff81065af0>] ? autoremove_wake_function+0x0/0x40
[  270.908076]  [<ffffffff810613f0>] ? worker_thread+0x0/0x200
[  270.908076]  [<ffffffff81065546>] kthread+0x96/0xa0
[  270.908076]  [<ffffffff81003d04>] kernel_thread_helper+0x4/0x10
[  270.908076]  [<ffffffff810654b0>] ? kthread+0x0/0xa0
[  270.908076]  [<ffffffff81003d00>] ? kernel_thread_helper+0x0/0x10
[  270.908076] Code: ff 48 8b 75 08 4c 89 e7 e8 c8 79 ff ff e9 7c ff ff ff 44 89 f6 4c 89 e7 e8 68 7b ff ff ba 01 00 00 00 e9 28 ff ff ff 0f 0b eb fe <0f> 0b eb fe 66 0f 1f 44 00 00 55 48 89 f0 48 8b 35 65 18 76 00 
[  270.908076] RIP  [<ffffffff81062366>] queue_delayed_work_on+0x106/0x110
[  270.908076]  RSP <ffff880423b1ddc0>
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu

With regards,
Narendra K
