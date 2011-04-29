From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bnx2: cancel timer on device removal
Date: Fri, 29 Apr 2011 15:09:23 -0400
Message-ID: <20110429190923.GC22387@hmsreliant.think-freely.org>
References: <1303849811-29025-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51232 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932940Ab1D2TJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 15:09:44 -0400
Content-Disposition: inline
In-Reply-To: <1303849811-29025-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 04:30:11PM -0400, Neil Horman wrote:
> This oops was recently reported to me:
> 
> invalid opcode: 0000 [#1] SMP
> last sysfs file:
> /sys/devices/pci0000:00/0000:00:01.0/0000:01:0d.0/0000:02:05.0/device
> CPU 1
> Modules linked in: bnx2(+) sunrpc ipv6 dm_mirror dm_region_hash dm_log sg
> microcode serio_raw amd64_edac_mod edac_core edac_mce_amd k8temp i2c_piix4
> shpchp ext4 mbcache jbd2 sd_mod crc_t10dif mptsas mptscsih mptbase
> scsi_transport_sas radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core
> dm_mod [last unloaded: bnx2]
> 
> Modules linked in: bnx2(+) sunrpc ipv6 dm_mirror dm_region_hash dm_log sg
> microcode serio_raw amd64_edac_mod edac_core edac_mce_amd k8temp i2c_piix4
> shpchp ext4 mbcache jbd2 sd_mod crc_t10dif mptsas mptscsih mptbase
> scsi_transport_sas radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core
> dm_mod [last unloaded: bnx2]
> Pid: 23900, comm: pidof Not tainted 2.6.32-130.el6.x86_64 #1 BladeCenter LS21
> -[797251Z]-
> RIP: 0010:[<ffffffffa058b270>]  [<ffffffffa058b270>] 0xffffffffa058b270
> RSP: 0018:ffff880002083e48  EFLAGS: 00010246
> RAX: ffff880002083e90 RBX: ffff88007ccd4000 RCX: 0000000000000000
> RDX: 0000000000000100 RSI: dead000000200200 RDI: ffff8800007b8700
> RBP: ffff880002083ed0 R08: ffff88000208db40 R09: 0000022d191d27c8
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800007b9bc8
> R13: ffff880002083e90 R14: ffff8800007b8700 R15: ffffffffa058b270
> FS:  00007fbb3bcf7700(0000) GS:ffff880002080000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000001664a98 CR3: 0000000060395000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process pidof (pid: 23900, threadinfo ffff8800007e8000, task ffff8800091c0040)
> Stack:
>  ffffffff81079f77 ffffffff8109e010 ffff88007ccd5c20 ffff88007ccd5820
> <0> ffff88007ccd5420 ffff8800007e9fd8 ffff8800007e9fd8 0000010000000000
> <0> ffff88007ccd5020 ffff880002083e90 ffff880002083e90 ffffffff8102a00d
> Call Trace:
>  <IRQ>
>  [<ffffffff81079f77>] ? run_timer_softirq+0x197/0x340
>  [<ffffffff8109e010>] ? tick_sched_timer+0x0/0xc0
>  [<ffffffff8102a00d>] ? lapic_next_event+0x1d/0x30
>  [<ffffffff8106f737>] __do_softirq+0xb7/0x1e0
>  [<ffffffff81092cc0>] ? hrtimer_interrupt+0x140/0x250
>  [<ffffffff81185f90>] ? filldir+0x0/0xe0
>  [<ffffffff8100c2cc>] call_softirq+0x1c/0x30
>  [<ffffffff8100df05>] do_softirq+0x65/0xa0
>  [<ffffffff8106f525>] irq_exit+0x85/0x90
>  [<ffffffff814e3340>] smp_apic_timer_interrupt+0x70/0x9b
>  [<ffffffff8100bc93>] apic_timer_interrupt+0x13/0x20
>  <EOI>
>  [<ffffffff81211ba5>] ? selinux_file_permission+0x45/0x150
>  [<ffffffff81262a75>] ? _atomic_dec_and_lock+0x55/0x80
>  [<ffffffff812050c6>] security_file_permission+0x16/0x20
>  [<ffffffff811861c1>] vfs_readdir+0x71/0xe0
>  [<ffffffff81186399>] sys_getdents+0x89/0xf0
>  [<ffffffff8100b172>] system_call_fastpath+0x16/0x1b
> 
> It occured during some stress testing, in which the reporter was repeatedly
> removing and modprobing the bnx2 module while doing various other random
> operations on the bnx2 registered net device.  Noting that this error occured on
> a serdes based device, we noted that there were a few ethtool operations (most
> notably self_test and set_phys_id) that have execution paths that lead into
> bnx2_setup_serdes_phy.  This function is notable because it executes a mod_timer
> call, which starts the bp->timer running.  Currently bnx2 is setup to assume
> that this timer only nees to be stopped when bnx2_close or bnx2_suspend is
> called.  Since the above ethtool operations are not gated on the net device
> having been opened however, that assumption is incorrect, and can lead to the
> timer still running after the module has been removed, leading to the oops above
> (as well as other simmilar oopses).
> 
> Fix the problem by ensuring that the timer is stopped when pci_device_unregister
> is called.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Hushan Jia <hjia@redhat.com>
> CC: Michael Chan <mchan@broadcom.com>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>  drivers/net/bnx2.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index bf729ee..7f76d4c 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -8358,6 +8358,8 @@ bnx2_remove_one(struct pci_dev *pdev)
>  
>  	unregister_netdev(dev);
>  
> +	del_timer_sync(&bp->timer);
> +
>  	if (bp->mips_firmware)
>  		release_firmware(bp->mips_firmware);
>  	if (bp->rv2p_firmware)
> -- 
> 1.7.4.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Ping, Michael?
Neil

