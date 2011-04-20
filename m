From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH] bnx2x: dont dereference tcp header on non tcp
 frames
Date: Wed, 20 Apr 2011 18:08:18 +0300
Message-ID: <1303312098.1813.29.camel@lb-tlvb-dmitry>
References: <1303229503.3480.386.camel@edumazet-laptop>
 <1303284713.3186.13.camel@edumazet-laptop>
 <20110420.014657.232735224.davem@davemloft.net>
 <1303292410.1813.23.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1854 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280Ab1DTPJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 11:09:36 -0400
In-Reply-To: <1303292410.1813.23.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-20 at 02:40 -0700, Dmitry Kravkov wrote:

> Following patch fixes udp checksum offload flow and also addresses
> issues raised by Eric. We are testing it now.

It passed local regression, i was also unable to reproduce kmemcheck
warning.

I hit this one (on net-2.6 from today) not sure if it's related:


INFO: rcu_sched_state detected stall on CPU 0 (t=60000 jiffies)
sending NMI to all CPUs:
NMI backtrace for cpu 0
CPU 0 
Modules linked in: bnx2x nfs fscache nfsd nfs_acl auth_rpcgss autofs4
bluetooth rfkill lockd sunrpc ipv6 loop dm_mirror dm_multipath scsi_dh
video sbs sbshc power_meter battery acpi_memhotplug ac parport_pc lp
parport ide_cd_mod cdrom serio_raw option usb_wwan usbserial button b
nx2 tpm_tis tpm tpm_bios ipmi_si ipmi_msghandler hpilo mdio rtc_cmos
pcspkr rtc_core i5k_amb hwmon i5000_edac edac_core rtc_lib
dm_region_hash dm_log dm_mod ata_piix libata shpchp cciss sd_mod
scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: bnx2x]

Pid: 3441, comm: kworker/0:3 Not tainted 2.6.39-rc2test+ #2 HP ProLiant
DL380 G5
RIP: 0010:[<ffffffff811cbf65>]  [<ffffffff811cbf65>] delay_tsc+0x15/0x60
RSP: 0018:ffff88023fc03e78  EFLAGS: 00000803
RAX: 00000000ddf79987 RBX: 0000000000000001 RCX: ffffffff817894e0
RDX: 00000000000001aa RSI: 00000000000000ff RDI: 00000000002dc788
RBP: ffff88023fc03e78 R08: 0000000000000003 R09: 0000000000000000
R10: 0000000000000000 R11: 000000000000000a R12: ffff88023fc0e5e0
R13: ffff88023497cf60 R14: ffffffff81729900 R15: ffffffff81729a00
FS:  0000000000000000(0000) GS:ffff88023fc00000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f24456760a0 CR3: 0000000001713000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
Process kworker/0:3 (pid: 3441, threadinfo ffff88021fe74000, task
ffff88023497cf60)
Stack:
 ffff88023fc03e88 ffffffff811cbf1a ffff88023fc03e98 ffffffff811cbf47
 ffff88023fc03eb8 ffffffff8101d155 0000000000000000 ffffffff81729900
 ffff88023fc03ef8 ffffffff81092b9c 000000004daf0bb9 0000000000000000
Call Trace:
 <IRQ> 
 [<ffffffff811cbf1a>] __delay+0xa/0x10
 [<ffffffff811cbf47>] __const_udelay+0x27/0x30
 [<ffffffff8101d155>] arch_trigger_all_cpu_backtrace+0x75/0xb0
 [<ffffffff81092b9c>] __rcu_pending+0x9c/0x370
 [<ffffffff81092efd>] rcu_check_callbacks+0x8d/0xd0
 [<ffffffff810530c1>] update_process_times+0x41/0x80
 [<ffffffff81070c07>] tick_periodic+0x27/0x70
 [<ffffffff81070c71>] tick_handle_periodic+0x21/0x80
 [<ffffffff8101cbd6>] smp_apic_timer_interrupt+0x66/0xa0
 [<ffffffff813c1993>] apic_timer_interrupt+0x13/0x20
 <EOI> 
 [<ffffffff811b1964>] ? blk_delay_work+0x34/0x40
 [<ffffffff8105d449>] process_one_work+0xf9/0x390
 [<ffffffff811b1930>] ? submit_bio+0xd0/0xd0
 [<ffffffff8105fa45>] worker_thread+0xe5/0x270
 [<ffffffff8105f960>] ? gcwq_mayday_timeout+0x80/0x80
 [<ffffffff810638e6>] kthread+0x96/0xa0
 [<ffffffff813c20d4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81063850>] ? kthread_stop+0xd0/0xd0
 [<ffffffff813c20d0>] ? gs_change+0xb/0xb
Code: 89 e5 f7 e2 48 8d 7a 01 e8 c9 ff ff ff c9 c3 0f 1f 80 00 00 00 00
55 65 44 8b 0c 25 68 c5 00 00 48 89 e5 66 66 90 0f ae e8 0f 31 
 89 c0 44 89 ce eb 11 0f 1f 00 f3 90 65 8b 0c 25 68 c5 00 00 
Call Trace:
 <IRQ>  [<ffffffff811cbf1a>] __delay+0xa/0x10
 [<ffffffff811cbf47>] __const_udelay+0x27/0x30
 [<ffffffff8101d155>] arch_trigger_all_cpu_backtrace+0x75/0xb0
 [<ffffffff81092b9c>] __rcu_pending+0x9c/0x370
 [<ffffffff81092efd>] rcu_check_callbacks+0x8d/0xd0
 [<ffffffff810530c1>] update_process_times+0x41/0x80
 [<ffffffff81070c07>] tick_periodic+0x27/0x70
 [<ffffffff81070c71>] tick_handle_periodic+0x21/0x80
 [<ffffffff8101cbd6>] smp_apic_timer_interrupt+0x66/0xa0
 [<ffffffff813c1993>] apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff811b1964>] ? blk_delay_work+0x34/0x40
 [<ffffffff8105d449>] process_one_work+0xf9/0x390
 [<ffffffff811b1930>] ? submit_bio+0xd0/0xd0
 [<ffffffff8105fa45>] worker_thread+0xe5/0x270
 [<ffffffff8105f960>] ? gcwq_mayday_timeout+0x80/0x80
 [<ffffffff810638e6>] kthread+0x96/0xa0
 [<ffffffff813c20d4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81063850>] ? kthread_stop+0xd0/0xd0
 [<ffffffff813c20d0>] ? gs_change+0xb/0xb



