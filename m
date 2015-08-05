From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [PATCH v2 4/8] xen: Use the correctly the Xen memory
 terminologies
Date: Wed, 5 Aug 2015 11:08:55 +0100
Message-ID: <alpine.DEB.2.02.1508051108100.11337@kaball.uk.xensource.com>
References: <1438711972-18752-1-git-send-email-julien.grall@citrix.com>
 <1438711972-18752-5-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="1342847746-225244385-1438769344=:11337"
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	"Russell King" <linux@arm.linux.org.uk>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Ingo Molnar" <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	<x86@kernel.org>,
	=?UTF-8?Q?Roger_Pau_Monn=C3=A9?= <roger.pau@citrix.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Wei Liu <wei.liu2@citrix.com>, Juergen Gross <jgross@suse.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Jiri Slaby" <jslaby@suse.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	<linux-input@vger.kernel.org>, <netdev@vger.kernel.org>,
To: Julien Grall <julien.grall@citrix.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1438711972-18752-5-git-send-email-julien.grall@citrix.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--1342847746-225244385-1438769344=:11337
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT

On Tue, 4 Aug 2015, Julien Grall wrote:
> Based on include/xen/mm.h [1], Linux is mistakenly using MFN when GFN
> is meant, I suspect this is because the first support for Xen was for
> PV. This resulted in some misimplementation of helpers on ARM and
> confused developers about the expected behavior.
> 
> For instance, with pfn_to_mfn, we expect to get an MFN based on the name.
> Although, if we look at the implementation on x86, it's returning a GFN.
> 
> For clarity and avoid new confusion, replace any reference to mfn with
> gfn in any helpers used by PV drivers. The x86 code will still keep some
> reference of pfn_to_mfn but exclusively for PV (a BUG_ON has been added
> to ensure this). No changes as been made in the hypercall field, even
> though they may be invalid, in order to keep the same as the defintion
> in xen repo.
> 
> Take also the opportunity to simplify simple construction such
> as pfn_to_mfn(page_to_pfn(page)) into page_to_gfn. More complex clean up
> will come in follow-up patches.
> 
> [1] http://xenbits.xen.org/gitweb/?p=xen.git;a=commitdiff;h=e758ed14f390342513405dd766e874934573e6cb
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Cc: "Roger Pau Monné" <roger.pau@citrix.com>
> Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: "James E.J. Bottomley" <JBottomley@odin.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Jiri Slaby <jslaby@suse.com>
> Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
> Cc: Tomi Valkeinen <tomi.valkeinen@ti.com>
> Cc: linux-input@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: linux-scsi@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-fbdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org

Aside from the x86 bits:

Reviewed-by: Stefano Stabellini <stefano.stabellini@eu.citrix.com>


>     Note that I've re-introduced mfn_to_pfn & co only for x86 PV code.
>     The helpers contain a BUG_ON to ensure that it's never called for
>     auto-translated guests. I did as best as my can to determine whether
>     mfn or gfn helpers should be used. Although, I haven't tried to boot
>     it.
> 
>     It may be possible to do further cleanup in the mmu.c where I found
>     some check to auto-translated. I'm not sure why given that the pvmmu
>     callback are only used for non-auto translated guest.
> 
>     Finally, given those changes, I didn't retain the Reviewed-by/Acked-by.
> 
>     Changes in v2:
>         - Give directly the URL to the commit rather than the commit ID
>         - xenstored_local_init: keep the cast to void *
>         - Typoes
>         - Keep pfn_to_mfn for x86 and PV-only. The *mfn* helpers are
>         used in arch/x86/xen for enlighten.c, mmu.c, p2m.c, setup.c,
>         smp.c and mm.c
> ---
>  arch/arm/include/asm/xen/page.h         | 13 +++++++------
>  arch/x86/include/asm/xen/page.h         | 33 ++++++++++++++++++++++++++-------
>  arch/x86/xen/smp.c                      |  2 +-
>  drivers/block/xen-blkfront.c            |  6 +++---
>  drivers/input/misc/xen-kbdfront.c       |  4 ++--
>  drivers/net/xen-netback/netback.c       |  4 ++--
>  drivers/net/xen-netfront.c              |  8 ++++----
>  drivers/scsi/xen-scsifront.c            |  8 +++-----
>  drivers/tty/hvc/hvc_xen.c               |  5 +++--
>  drivers/video/fbdev/xen-fbfront.c       |  4 ++--
>  drivers/xen/balloon.c                   |  2 +-
>  drivers/xen/events/events_base.c        |  2 +-
>  drivers/xen/events/events_fifo.c        |  4 ++--
>  drivers/xen/gntalloc.c                  |  3 ++-
>  drivers/xen/manage.c                    |  2 +-
>  drivers/xen/tmem.c                      |  4 ++--
>  drivers/xen/xenbus/xenbus_client.c      |  2 +-
>  drivers/xen/xenbus/xenbus_dev_backend.c |  2 +-
>  drivers/xen/xenbus/xenbus_probe.c       |  8 +++-----
>  include/xen/page.h                      |  4 ++--
>  20 files changed, 69 insertions(+), 51 deletions(-)
> 
> diff --git a/arch/arm/include/asm/xen/page.h b/arch/arm/include/asm/xen/page.h
> index 087d86e..51e5bf1 100644
> --- a/arch/arm/include/asm/xen/page.h
> +++ b/arch/arm/include/asm/xen/page.h
> @@ -34,14 +34,15 @@ typedef struct xpaddr {
>  unsigned long __pfn_to_mfn(unsigned long pfn);
>  extern struct rb_root phys_to_mach;
>  
> -static inline unsigned long pfn_to_mfn(unsigned long pfn)
> +/* Pseudo-physical <-> Guest conversion */
> +static inline unsigned long pfn_to_gfn(unsigned long pfn)
>  {
>  	return pfn;
>  }
>  
> -static inline unsigned long mfn_to_pfn(unsigned long mfn)
> +static inline unsigned long gfn_to_pfn(unsigned long gfn)
>  {
> -	return mfn;
> +	return gfn;
>  }
>  
>  /* Pseudo-physical <-> BUS conversion */
> @@ -65,9 +66,9 @@ static inline unsigned long bfn_to_pfn(unsigned long bfn)
>  
>  #define bfn_to_local_pfn(bfn)	bfn_to_pfn(bfn)
>  
> -/* VIRT <-> MACHINE conversion */
> -#define virt_to_mfn(v)		(pfn_to_mfn(virt_to_pfn(v)))
> -#define mfn_to_virt(m)		(__va(mfn_to_pfn(m) << PAGE_SHIFT))
> +/* VIRT <-> GUEST conversion */
> +#define virt_to_gfn(v)		(pfn_to_gfn(virt_to_pfn(v)))
> +#define gfn_to_virt(m)		(__va(gfn_to_pfn(m) << PAGE_SHIFT))
>  
>  /* Only used in PV code. But ARM guests are always HVM. */
>  static inline xmaddr_t arbitrary_virt_to_machine(void *vaddr)
> diff --git a/arch/x86/include/asm/xen/page.h b/arch/x86/include/asm/xen/page.h
> index 8ba04b8..c2da42f 100644
> --- a/arch/x86/include/asm/xen/page.h
> +++ b/arch/x86/include/asm/xen/page.h
> @@ -103,8 +103,7 @@ static inline unsigned long pfn_to_mfn(unsigned long pfn)
>  {
>  	unsigned long mfn;
>  
> -	if (xen_feature(XENFEAT_auto_translated_physmap))
> -		return pfn;
> +	BUG_ON(xen_feature(XENFEAT_auto_translated_physmap));
>  
>  	mfn = __pfn_to_mfn(pfn);
>  
> @@ -149,8 +148,7 @@ static inline unsigned long mfn_to_pfn(unsigned long mfn)
>  {
>  	unsigned long pfn;
>  
> -	if (xen_feature(XENFEAT_auto_translated_physmap))
> -		return mfn;
> +	BUG_ON(xen_feature(XENFEAT_auto_translated_physmap));
>  
>  	pfn = mfn_to_pfn_no_overrides(mfn);
>  	if (__pfn_to_mfn(pfn) != mfn)
> @@ -178,9 +176,26 @@ static inline xpaddr_t machine_to_phys(xmaddr_t machine)
>  	return XPADDR(PFN_PHYS(mfn_to_pfn(PFN_DOWN(machine.maddr))) | offset);
>  }
>  
> +/* Pseudo-physical <-> Guest conversion */
> +static inline unsigned long pfn_to_gfn(unsigned long pfn)
> +{
> +	if (xen_feature(XENFEAT_auto_translated_physmap))
> +		return pfn;
> +	else
> +		return pfn_to_mfn(pfn);
> +}
> +
> +static inline unsigned long gfn_to_pfn(unsigned long gfn)
> +{
> +	if (xen_feature(XENFEAT_auto_translated_physmap))
> +		return gfn;
> +	else
> +		return mfn_to_pfn(gfn);
> +}
> +
>  /* Pseudo-physical <-> Bus conversion */
> -#define pfn_to_bfn(pfn)		pfn_to_mfn(pfn)
> -#define bfn_to_pfn(bfn)		mfn_to_pfn(bfn)
> +#define pfn_to_bfn(pfn)		pfn_to_gfn(pfn)
> +#define bfn_to_pfn(bfn)		gfn_to_pfn(bfn)
>  
>  /*
>   * We detect special mappings in one of two ways:
> @@ -217,9 +232,13 @@ static inline unsigned long bfn_to_local_pfn(unsigned long mfn)
>  
>  /* VIRT <-> MACHINE conversion */
>  #define virt_to_machine(v)	(phys_to_machine(XPADDR(__pa(v))))
> -#define virt_to_pfn(v)          (PFN_DOWN(__pa(v)))
>  #define virt_to_mfn(v)		(pfn_to_mfn(virt_to_pfn(v)))
>  #define mfn_to_virt(m)		(__va(mfn_to_pfn(m) << PAGE_SHIFT))
> +#define virt_to_pfn(v)          (PFN_DOWN(__pa(v)))
> +
> +/* VIRT <-> GUEST conversion */
> +#define virt_to_gfn(v)		(pfn_to_gfn(virt_to_pfn(v)))
> +#define gfn_to_virt(g)		(__va(gfn_to_pfn(g) << PAGE_SHIFT))
>  
>  static inline unsigned long pte_mfn(pte_t pte)
>  {
> diff --git a/arch/x86/xen/smp.c b/arch/x86/xen/smp.c
> index 8648438..1e0931b 100644
> --- a/arch/x86/xen/smp.c
> +++ b/arch/x86/xen/smp.c
> @@ -429,7 +429,7 @@ cpu_initialize_context(unsigned int cpu, struct task_struct *idle)
>  	}
>  #endif
>  	ctxt->user_regs.esp = idle->thread.sp0 - sizeof(struct pt_regs);
> -	ctxt->ctrlreg[3] = xen_pfn_to_cr3(virt_to_mfn(swapper_pg_dir));
> +	ctxt->ctrlreg[3] = xen_pfn_to_cr3(virt_to_gfn(swapper_pg_dir));
>  	if (HYPERVISOR_vcpu_op(VCPUOP_initialise, cpu, ctxt))
>  		BUG();
>  
> diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
> index 6d89ed3..2e541a4 100644
> --- a/drivers/block/xen-blkfront.c
> +++ b/drivers/block/xen-blkfront.c
> @@ -247,7 +247,7 @@ static struct grant *get_grant(grant_ref_t *gref_head,
>                                 struct blkfront_info *info)
>  {
>  	struct grant *gnt_list_entry;
> -	unsigned long buffer_mfn;
> +	unsigned long buffer_gfn;
>  
>  	BUG_ON(list_empty(&info->grants));
>  	gnt_list_entry = list_first_entry(&info->grants, struct grant,
> @@ -266,10 +266,10 @@ static struct grant *get_grant(grant_ref_t *gref_head,
>  		BUG_ON(!pfn);
>  		gnt_list_entry->pfn = pfn;
>  	}
> -	buffer_mfn = pfn_to_mfn(gnt_list_entry->pfn);
> +	buffer_gfn = pfn_to_gfn(gnt_list_entry->pfn);
>  	gnttab_grant_foreign_access_ref(gnt_list_entry->gref,
>  	                                info->xbdev->otherend_id,
> -	                                buffer_mfn, 0);
> +	                                buffer_gfn, 0);
>  	return gnt_list_entry;
>  }
>  
> diff --git a/drivers/input/misc/xen-kbdfront.c b/drivers/input/misc/xen-kbdfront.c
> index 95599e4..23d0549 100644
> --- a/drivers/input/misc/xen-kbdfront.c
> +++ b/drivers/input/misc/xen-kbdfront.c
> @@ -232,7 +232,7 @@ static int xenkbd_connect_backend(struct xenbus_device *dev,
>  	struct xenbus_transaction xbt;
>  
>  	ret = gnttab_grant_foreign_access(dev->otherend_id,
> -	                                  virt_to_mfn(info->page), 0);
> +	                                  virt_to_gfn(info->page), 0);
>  	if (ret < 0)
>  		return ret;
>  	info->gref = ret;
> @@ -255,7 +255,7 @@ static int xenkbd_connect_backend(struct xenbus_device *dev,
>  		goto error_irqh;
>  	}
>  	ret = xenbus_printf(xbt, dev->nodename, "page-ref", "%lu",
> -			    virt_to_mfn(info->page));
> +			    virt_to_gfn(info->page));
>  	if (ret)
>  		goto error_xenbus;
>  	ret = xenbus_printf(xbt, dev->nodename, "page-gref", "%u", info->gref);
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 7d50711..3b7b7c3 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -314,7 +314,7 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
>  		} else {
>  			copy_gop->source.domid = DOMID_SELF;
>  			copy_gop->source.u.gmfn =
> -				virt_to_mfn(page_address(page));
> +				virt_to_gfn(page_address(page));
>  		}
>  		copy_gop->source.offset = offset;
>  
> @@ -1284,7 +1284,7 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
>  		queue->tx_copy_ops[*copy_ops].source.offset = txreq.offset;
>  
>  		queue->tx_copy_ops[*copy_ops].dest.u.gmfn =
> -			virt_to_mfn(skb->data);
> +			virt_to_gfn(skb->data);
>  		queue->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
>  		queue->tx_copy_ops[*copy_ops].dest.offset =
>  			offset_in_page(skb->data);
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index f948c46..5cdab73 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -291,7 +291,7 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
>  		struct sk_buff *skb;
>  		unsigned short id;
>  		grant_ref_t ref;
> -		unsigned long pfn;
> +		unsigned long gfn;
>  		struct xen_netif_rx_request *req;
>  
>  		skb = xennet_alloc_one_rx_buffer(queue);
> @@ -307,12 +307,12 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
>  		BUG_ON((signed short)ref < 0);
>  		queue->grant_rx_ref[id] = ref;
>  
> -		pfn = page_to_pfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
> +		gfn = page_to_gfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
>  
>  		req = RING_GET_REQUEST(&queue->rx, req_prod);
>  		gnttab_grant_foreign_access_ref(ref,
>  						queue->info->xbdev->otherend_id,
> -						pfn_to_mfn(pfn),
> +						gfn,
>  						0);
>  
>  		req->id = id;
> @@ -431,7 +431,7 @@ static struct xen_netif_tx_request *xennet_make_one_txreq(
>  	BUG_ON((signed short)ref < 0);
>  
>  	gnttab_grant_foreign_access_ref(ref, queue->info->xbdev->otherend_id,
> -					page_to_mfn(page), GNTMAP_readonly);
> +					page_to_gfn(page), GNTMAP_readonly);
>  
>  	queue->tx_skbs[id].skb = skb;
>  	queue->grant_tx_page[id] = page;
> diff --git a/drivers/scsi/xen-scsifront.c b/drivers/scsi/xen-scsifront.c
> index fad22ca..cdf00d1 100644
> --- a/drivers/scsi/xen-scsifront.c
> +++ b/drivers/scsi/xen-scsifront.c
> @@ -377,7 +377,6 @@ static int map_data_for_request(struct vscsifrnt_info *info,
>  	unsigned int data_len = scsi_bufflen(sc);
>  	unsigned int data_grants = 0, seg_grants = 0;
>  	struct scatterlist *sg;
> -	unsigned long mfn;
>  	struct scsiif_request_segment *seg;
>  
>  	ring_req->nr_segments = 0;
> @@ -420,9 +419,8 @@ static int map_data_for_request(struct vscsifrnt_info *info,
>  			ref = gnttab_claim_grant_reference(&gref_head);
>  			BUG_ON(ref == -ENOSPC);
>  
> -			mfn = pfn_to_mfn(page_to_pfn(page));
>  			gnttab_grant_foreign_access_ref(ref,
> -				info->dev->otherend_id, mfn, 1);
> +				info->dev->otherend_id, page_to_gfn(page), 1);
>  			shadow->gref[ref_cnt] = ref;
>  			ring_req->seg[ref_cnt].gref   = ref;
>  			ring_req->seg[ref_cnt].offset = (uint16_t)off;
> @@ -454,9 +452,9 @@ static int map_data_for_request(struct vscsifrnt_info *info,
>  			ref = gnttab_claim_grant_reference(&gref_head);
>  			BUG_ON(ref == -ENOSPC);
>  
> -			mfn = pfn_to_mfn(page_to_pfn(page));
>  			gnttab_grant_foreign_access_ref(ref,
> -				info->dev->otherend_id, mfn, grant_ro);
> +				info->dev->otherend_id, page_to_gfn(page),
> +				grant_ro);
>  
>  			shadow->gref[ref_cnt] = ref;
>  			seg->gref   = ref;
> diff --git a/drivers/tty/hvc/hvc_xen.c b/drivers/tty/hvc/hvc_xen.c
> index a9d837f..efe5124 100644
> --- a/drivers/tty/hvc/hvc_xen.c
> +++ b/drivers/tty/hvc/hvc_xen.c
> @@ -265,7 +265,8 @@ static int xen_pv_console_init(void)
>  		return 0;
>  	}
>  	info->evtchn = xen_start_info->console.domU.evtchn;
> -	info->intf = mfn_to_virt(xen_start_info->console.domU.mfn);
> +	/* GFN == MFN for PV guest */
> +	info->intf = gfn_to_virt(xen_start_info->console.domU.mfn);
>  	info->vtermno = HVC_COOKIE;
>  
>  	spin_lock(&xencons_lock);
> @@ -390,7 +391,7 @@ static int xencons_connect_backend(struct xenbus_device *dev,
>  	if (IS_ERR(info->hvc))
>  		return PTR_ERR(info->hvc);
>  	if (xen_pv_domain())
> -		mfn = virt_to_mfn(info->intf);
> +		mfn = virt_to_gfn(info->intf);
>  	else
>  		mfn = __pa(info->intf) >> PAGE_SHIFT;
>  	ret = gnttab_alloc_grant_references(1, &gref_head);
> diff --git a/drivers/video/fbdev/xen-fbfront.c b/drivers/video/fbdev/xen-fbfront.c
> index 09dc447..25e3cce 100644
> --- a/drivers/video/fbdev/xen-fbfront.c
> +++ b/drivers/video/fbdev/xen-fbfront.c
> @@ -539,7 +539,7 @@ static int xenfb_remove(struct xenbus_device *dev)
>  
>  static unsigned long vmalloc_to_mfn(void *address)
>  {
> -	return pfn_to_mfn(vmalloc_to_pfn(address));
> +	return pfn_to_gfn(vmalloc_to_pfn(address));
>  }
>  
>  static void xenfb_init_shared_page(struct xenfb_info *info,
> @@ -586,7 +586,7 @@ static int xenfb_connect_backend(struct xenbus_device *dev,
>  		goto unbind_irq;
>  	}
>  	ret = xenbus_printf(xbt, dev->nodename, "page-ref", "%lu",
> -			    virt_to_mfn(info->page));
> +			    virt_to_gfn(info->page));
>  	if (ret)
>  		goto error_xenbus;
>  	ret = xenbus_printf(xbt, dev->nodename, "event-channel", "%u",
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index bf4a23c..5df28cd 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -441,7 +441,7 @@ static enum bp_state decrease_reservation(unsigned long nr_pages, gfp_t gfp)
>  	/* Update direct mapping, invalidate P2M, and add to balloon. */
>  	for (i = 0; i < nr_pages; i++) {
>  		pfn = frame_list[i];
> -		frame_list[i] = pfn_to_mfn(pfn);
> +		frame_list[i] = pfn_to_gfn(pfn);
>  		page = pfn_to_page(pfn);
>  
>  #ifdef CONFIG_XEN_HAVE_PVMMU
> diff --git a/drivers/xen/events/events_base.c b/drivers/xen/events/events_base.c
> index 1495ecc..10fd9c6 100644
> --- a/drivers/xen/events/events_base.c
> +++ b/drivers/xen/events/events_base.c
> @@ -1694,7 +1694,7 @@ void __init xen_init_IRQ(void)
>  		struct physdev_pirq_eoi_gmfn eoi_gmfn;
>  
>  		pirq_eoi_map = (void *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
> -		eoi_gmfn.gmfn = virt_to_mfn(pirq_eoi_map);
> +		eoi_gmfn.gmfn = virt_to_gfn(pirq_eoi_map);
>  		rc = HYPERVISOR_physdev_op(PHYSDEVOP_pirq_eoi_gmfn_v2, &eoi_gmfn);
>  		/* TODO: No PVH support for PIRQ EOI */
>  		if (rc != 0) {
> diff --git a/drivers/xen/events/events_fifo.c b/drivers/xen/events/events_fifo.c
> index 6df8aac..2e55e90 100644
> --- a/drivers/xen/events/events_fifo.c
> +++ b/drivers/xen/events/events_fifo.c
> @@ -111,7 +111,7 @@ static int init_control_block(int cpu,
>  	for (i = 0; i < EVTCHN_FIFO_MAX_QUEUES; i++)
>  		q->head[i] = 0;
>  
> -	init_control.control_gfn = virt_to_mfn(control_block);
> +	init_control.control_gfn = virt_to_gfn(control_block);
>  	init_control.offset      = 0;
>  	init_control.vcpu        = cpu;
>  
> @@ -167,7 +167,7 @@ static int evtchn_fifo_setup(struct irq_info *info)
>  		/* Mask all events in this page before adding it. */
>  		init_array_page(array_page);
>  
> -		expand_array.array_gfn = virt_to_mfn(array_page);
> +		expand_array.array_gfn = virt_to_gfn(array_page);
>  
>  		ret = HYPERVISOR_event_channel_op(EVTCHNOP_expand_array, &expand_array);
>  		if (ret < 0)
> diff --git a/drivers/xen/gntalloc.c b/drivers/xen/gntalloc.c
> index e53fe19..13e1458 100644
> --- a/drivers/xen/gntalloc.c
> +++ b/drivers/xen/gntalloc.c
> @@ -142,7 +142,8 @@ static int add_grefs(struct ioctl_gntalloc_alloc_gref *op,
>  
>  		/* Grant foreign access to the page. */
>  		rc = gnttab_grant_foreign_access(op->domid,
> -			pfn_to_mfn(page_to_pfn(gref->page)), readonly);
> +						 page_to_gfn(gref->page),
> +						 readonly);
>  		if (rc < 0)
>  			goto undo;
>  		gref_ids[i] = gref->gref_id = rc;
> diff --git a/drivers/xen/manage.c b/drivers/xen/manage.c
> index d10effe..e12bd36 100644
> --- a/drivers/xen/manage.c
> +++ b/drivers/xen/manage.c
> @@ -80,7 +80,7 @@ static int xen_suspend(void *data)
>  	 * is resuming in a new domain.
>  	 */
>  	si->cancelled = HYPERVISOR_suspend(xen_pv_domain()
> -                                           ? virt_to_mfn(xen_start_info)
> +                                           ? virt_to_gfn(xen_start_info)
>                                             : 0);
>  
>  	xen_arch_post_suspend(si->cancelled);
> diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
> index 239738f..28c97ff 100644
> --- a/drivers/xen/tmem.c
> +++ b/drivers/xen/tmem.c
> @@ -131,7 +131,7 @@ static int xen_tmem_new_pool(struct tmem_pool_uuid uuid,
>  static int xen_tmem_put_page(u32 pool_id, struct tmem_oid oid,
>  			     u32 index, unsigned long pfn)
>  {
> -	unsigned long gmfn = xen_pv_domain() ? pfn_to_mfn(pfn) : pfn;
> +	unsigned long gmfn = pfn_to_gfn(pfn);
>  
>  	return xen_tmem_op(TMEM_PUT_PAGE, pool_id, oid, index,
>  		gmfn, 0, 0, 0);
> @@ -140,7 +140,7 @@ static int xen_tmem_put_page(u32 pool_id, struct tmem_oid oid,
>  static int xen_tmem_get_page(u32 pool_id, struct tmem_oid oid,
>  			     u32 index, unsigned long pfn)
>  {
> -	unsigned long gmfn = xen_pv_domain() ? pfn_to_mfn(pfn) : pfn;
> +	unsigned long gmfn = pfn_to_gfn(pfn);
>  
>  	return xen_tmem_op(TMEM_GET_PAGE, pool_id, oid, index,
>  		gmfn, 0, 0, 0);
> diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
> index 9ad3272..daa267a 100644
> --- a/drivers/xen/xenbus/xenbus_client.c
> +++ b/drivers/xen/xenbus/xenbus_client.c
> @@ -380,7 +380,7 @@ int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
>  
>  	for (i = 0; i < nr_pages; i++) {
>  		err = gnttab_grant_foreign_access(dev->otherend_id,
> -						  virt_to_mfn(vaddr), 0);
> +						  virt_to_gfn(vaddr), 0);
>  		if (err < 0) {
>  			xenbus_dev_fatal(dev, err,
>  					 "granting access to ring page");
> diff --git a/drivers/xen/xenbus/xenbus_dev_backend.c b/drivers/xen/xenbus/xenbus_dev_backend.c
> index b17707e..ee6d9ef 100644
> --- a/drivers/xen/xenbus/xenbus_dev_backend.c
> +++ b/drivers/xen/xenbus/xenbus_dev_backend.c
> @@ -49,7 +49,7 @@ static long xenbus_alloc(domid_t domid)
>  		goto out_err;
>  
>  	gnttab_grant_foreign_access_ref(GNTTAB_RESERVED_XENSTORE, domid,
> -			virt_to_mfn(xen_store_interface), 0 /* writable */);
> +			virt_to_gfn(xen_store_interface), 0 /* writable */);
>  
>  	arg.dom = DOMID_SELF;
>  	arg.remote_dom = domid;
> diff --git a/drivers/xen/xenbus/xenbus_probe.c b/drivers/xen/xenbus/xenbus_probe.c
> index 4308fb3..b3870f4 100644
> --- a/drivers/xen/xenbus/xenbus_probe.c
> +++ b/drivers/xen/xenbus/xenbus_probe.c
> @@ -711,9 +711,7 @@ static int __init xenstored_local_init(void)
>  	if (!page)
>  		goto out_err;
>  
> -	xen_store_mfn = xen_start_info->store_mfn =
> -		pfn_to_mfn(virt_to_phys((void *)page) >>
> -			   PAGE_SHIFT);
> +	xen_store_mfn = xen_start_info->store_mfn = virt_to_gfn((void *)page);
>  
>  	/* Next allocate a local port which xenstored can bind to */
>  	alloc_unbound.dom        = DOMID_SELF;
> @@ -787,12 +785,12 @@ static int __init xenbus_init(void)
>  		err = xenstored_local_init();
>  		if (err)
>  			goto out_error;
> -		xen_store_interface = mfn_to_virt(xen_store_mfn);
> +		xen_store_interface = gfn_to_virt(xen_store_mfn);
>  		break;
>  	case XS_PV:
>  		xen_store_evtchn = xen_start_info->store_evtchn;
>  		xen_store_mfn = xen_start_info->store_mfn;
> -		xen_store_interface = mfn_to_virt(xen_store_mfn);
> +		xen_store_interface = gfn_to_virt(xen_store_mfn);
>  		break;
>  	case XS_HVM:
>  		err = hvm_get_parameter(HVM_PARAM_STORE_EVTCHN, &v);
> diff --git a/include/xen/page.h b/include/xen/page.h
> index c5ed20b..e7e1425 100644
> --- a/include/xen/page.h
> +++ b/include/xen/page.h
> @@ -3,9 +3,9 @@
>  
>  #include <asm/xen/page.h>
>  
> -static inline unsigned long page_to_mfn(struct page *page)
> +static inline unsigned long page_to_gfn(struct page *page)
>  {
> -	return pfn_to_mfn(page_to_pfn(page));
> +	return pfn_to_gfn(page_to_pfn(page));
>  }
>  
>  struct xen_memory_region {
> -- 
> 2.1.4
> 
--1342847746-225244385-1438769344=:11337--
