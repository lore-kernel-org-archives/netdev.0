From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [net-next,02/13] tg3: Cleanup transmit error path
Date: Thu, 02 Jun 2011 16:18:35 -0600
Message-ID: <1307053115.3656.19.camel@x201>
References: <1305843176-32358-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752459Ab1FBWTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 18:19:10 -0400
In-Reply-To: <1305843176-32358-3-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-19 at 12:12 +0000, Matt Carlson wrote:
> This patch consolidates the skb cleanup code into a function named
> tg3_skb_error_unmap().  The modification addresses a long-standing bug
> where pci_unmap_single() was incorrectly being called instead of
> pci_unmap_page() in tigon3_dma_hwbug_workaround().

This patch doesn't behave well when an iommu (VT-d) is involved.
Booting an X58 chipset based system with intel_iommu=on with 3.0.0-rc1
results in the warning below.  Looks like the driver is trying to unmap
0x0.  Eventually something worse happens and the system reports a few
iommu faults from the device before panicing.  Neither problem is
observed if 432aa7ed is reverted.  tg3 device in use is a BCM5755.
Thanks,

Alex

WARNING: at drivers/pci/intel-iommu.c:2888 intel_unmap_page+0x15c/0x180()
Hardware name: 4157CTO
Driver unmaps unmatched page at PFN 0
Modules linked in: nfs lockd auth_rpcgss nfs_acl ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf bridge stp llc ipv6 dm_mirror dm_region_hash dm_log kvm_intel kvm sg microcode serio_raw wmi i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support tg3 ext4 mbcache jbd2 raid1 raid456 async_pq async_xor xor async_memcpy async_raid6_recov raid6_pq async_tx sr_mod cdrom sd_mod crc_t10dif floppy dm_mod [last unloaded: scsi_wait_scan]
Pid: 2604, comm: libvirtd Not tainted 3.0.0-rc1+ #184
Call Trace:
 [<ffffffff8105c7df>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff8105c8d6>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff81245b8b>] ? find_iova+0x5b/0xa0
 [<ffffffff8124a60c>] intel_unmap_page+0x15c/0x180
 [<ffffffffa0128d48>] tg3_skb_error_unmap+0xb8/0x130 [tg3]
 [<ffffffffa0136041>] tg3_start_xmit+0x661/0xde0 [tg3]
 [<ffffffffa01363dd>] ? tg3_start_xmit+0x9fd/0xde0 [tg3]
 [<ffffffff8138d7fe>] dev_hard_start_xmit+0x31e/0x6c0
 [<ffffffff813a9f5f>] sch_direct_xmit+0xef/0x1c0
 [<ffffffff8138dd38>] dev_queue_xmit+0x198/0x5f0
 [<ffffffffa028d2ac>] br_dev_queue_push_xmit+0x6c/0xa0 [bridge]
 [<ffffffffa028d478>] br_forward_finish+0x58/0x60 [bridge]
 [<ffffffffa028d4f8>] __br_deliver+0x78/0xf0 [bridge]
 [<ffffffff814367a9>] ? packet_rcv+0x59/0x450
 [<ffffffffa028d5a5>] br_deliver+0x35/0x40 [bridge]
 [<ffffffffa028b8c4>] br_dev_xmit+0x114/0x180 [bridge]
 [<ffffffff8138d7fe>] dev_hard_start_xmit+0x31e/0x6c0
 [<ffffffff8138df95>] dev_queue_xmit+0x3f5/0x5f0
 [<ffffffff813d0c2e>] ip_finish_output+0x16e/0x340
 [<ffffffff813d1110>] ip_output+0xb0/0xc0
 [<ffffffff813cfdc3>] ? __ip_local_out+0xa3/0xb0
 [<ffffffff813d0129>] ip_local_out+0x29/0x30
 [<ffffffff813d0604>] ip_queue_xmit+0x164/0x410
 [<ffffffff813e5e5c>] tcp_transmit_skb+0x41c/0x910
 [<ffffffff813e86f7>] tcp_write_xmit+0x1e7/0x9d0
 [<ffffffff813e8f46>] __tcp_push_pending_frames+0x26/0xc0
 [<ffffffff813d77be>] tcp_push+0x6e/0x90
 [<ffffffff813db4f9>] tcp_sendmsg+0x759/0xc00
 [<ffffffff813fdaa8>] inet_sendmsg+0x48/0xb0
 [<ffffffff811cd7f3>] ? selinux_socket_sendmsg+0x23/0x30
 [<ffffffff81377e52>] sock_sendmsg+0xe2/0x120
 [<ffffffff8100a7e4>] ? __switch_to+0x194/0x320
 [<ffffffff81377ed1>] kernel_sendmsg+0x41/0x60


