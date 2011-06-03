From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [net-next,02/13] tg3: Cleanup transmit error path
Date: Thu, 02 Jun 2011 19:18:34 -0600
Message-ID: <1307063914.3656.22.camel@x201>
References: <1305843176-32358-3-git-send-email-mcarlson@broadcom.com>
	 <1307053115.3656.19.camel@x201>
	 <20110602230139.GD5068@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38643 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754061Ab1FCBSh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 21:18:37 -0400
In-Reply-To: <20110602230139.GD5068@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-02 at 16:01 -0700, Matt Carlson wrote:
> On Thu, Jun 02, 2011 at 03:18:35PM -0700, Alex Williamson wrote:
> > On Thu, 2011-05-19 at 12:12 +0000, Matt Carlson wrote:
> > > This patch consolidates the skb cleanup code into a function named
> > > tg3_skb_error_unmap().  The modification addresses a long-standing bug
> > > where pci_unmap_single() was incorrectly being called instead of
> > > pci_unmap_page() in tigon3_dma_hwbug_workaround().
> > 
> > This patch doesn't behave well when an iommu (VT-d) is involved.
> > Booting an X58 chipset based system with intel_iommu=on with 3.0.0-rc1
> > results in the warning below.  Looks like the driver is trying to unmap
> > 0x0.  Eventually something worse happens and the system reports a few
> > iommu faults from the device before panicing.  Neither problem is
> > observed if 432aa7ed is reverted.  tg3 device in use is a BCM5755.
> > Thanks,
> > 
> > Alex
> > 
> > WARNING: at drivers/pci/intel-iommu.c:2888 intel_unmap_page+0x15c/0x180()
> > Hardware name: 4157CTO
> > Driver unmaps unmatched page at PFN 0
> > Modules linked in: nfs lockd auth_rpcgss nfs_acl ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf bridge stp llc ipv6 dm_mirror dm_region_hash dm_log kvm_intel kvm sg microcode serio_raw wmi i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support tg3 ext4 mbcache jbd2 raid1 raid456 async_pq async_xor xor async_memcpy async_raid6_recov raid6_pq async_tx sr_mod cdrom sd_mod crc_t10dif floppy dm_mod [last unloaded: scsi_wait_scan]
> > Pid: 2604, comm: libvirtd Not tainted 3.0.0-rc1+ #184
> > Call Trace:
> >  [<ffffffff8105c7df>] warn_slowpath_common+0x7f/0xc0
> >  [<ffffffff8105c8d6>] warn_slowpath_fmt+0x46/0x50
> >  [<ffffffff81245b8b>] ? find_iova+0x5b/0xa0
> >  [<ffffffff8124a60c>] intel_unmap_page+0x15c/0x180
> >  [<ffffffffa0128d48>] tg3_skb_error_unmap+0xb8/0x130 [tg3]

> Does this patch fix the problem?

Yes it does, probably explains the subsequent iommu faults if that off
by one unmapping sometimes finds a non-zero address to unmap.  Thanks,

Alex

Tested-by: Alex Williamson <alex.williamson@redhat.com>

> Subject: [PATCH] tg3: Fix tg3_skb_error_unmap()
> 
> This function attempts to free one fragment beyond the number of
> fragments that were actually mapped.  This patch brings back the limit
> to the correct spot.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> ---
>  drivers/net/tg3.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 8ece39b..3d239ab 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -5771,7 +5771,7 @@ static void tg3_skb_error_unmap(struct tg3_napi *tnapi,
>  			 dma_unmap_addr(txb, mapping),
>  			 skb_headlen(skb),
>  			 PCI_DMA_TODEVICE);
> -	for (i = 0; i <= last; i++) {
> +	for (i = 0; i < last; i++) {
>  		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
>  
>  		entry = NEXT_TX(entry);
> -- 
> 1.7.3.4
> 
> 



