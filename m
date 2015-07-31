From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [PATCH 4/8] xen: Use the correctly the Xen memory
 terminologies
Date: Fri, 31 Jul 2015 12:02:57 +0100
Message-ID: <alpine.DEB.2.02.1507311202350.11337@kaball.uk.xensource.com>
References: <1438095769-2560-1-git-send-email-julien.grall@citrix.com>
 <1438095769-2560-5-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
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
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1438095769-2560-5-git-send-email-julien.grall@citrix.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Jul 2015, Julien Grall wrote:
> Based on include/xen/mm.h [1], Linux is mistakenly using MFN when GFN
> is meant, I suspect this is because the first support for Xen was for
> PV. This brough some misimplementation of helpers on ARM and make the
> developper confused the expected behavior.
> 
> For instance, with pfn_to_mfn, we expect to get an MFN based on the name.
> Although, if we look at the implementation on x86, it's returning a GFN.
> 
> For clarity and avoid new confusion, replace any reference of mfn into
> gnf in any helpers used by PV drivers.
> 
> Take also the opportunity to simplify simple construction such
> as pfn_to_mfn(page_to_pfn(page)) into page_to_gfn. More complex clean up
> will come in follow-up patches.
> 
> I think it may be possible to do further clean up in the x86 code to
> ensure that helpers returning machine address (such as virt_address) is
> not used by no auto-translated guests. I will let x86 xen expert doing
> it.
> 
> [1] Xen tree: e758ed14f390342513405dd766e874934573e6cb
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>

Aside from the many typos

Reviewed-by: Stefano Stabellini <stefano.stabellini@eu.citrix.com>


>  arch/arm/include/asm/xen/page.h         | 13 +++++++------
>  arch/x86/include/asm/xen/page.h         | 30 ++++++++++++++++--------------
>  arch/x86/xen/enlighten.c                |  4 ++--
>  arch/x86/xen/mmu.c                      | 16 ++++++++--------
>  arch/x86/xen/p2m.c                      | 32 ++++++++++++++++----------------
>  arch/x86/xen/setup.c                    | 12 ++++++------
>  arch/x86/xen/smp.c                      |  4 ++--
>  arch/x86/xen/suspend.c                  |  8 ++++----
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
>  25 files changed, 96 insertions(+), 95 deletions(-)
> 
> diff --git a/arch/arm/include/asm/xen/page.h b/arch/arm/include/asm/xen/page.h
> index 493471f..f542f68 100644
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
>  /* Pseudo-physical <-> DMA conversion */
> @@ -65,9 +66,9 @@ static inline unsigned long dfn_to_pfn(unsigned long dfn)
>  
>  #define dfn_to_local_pfn(dfn)	dfn_to_pfn(dfn)
>  
> -/* VIRT <-> MACHINE conversion */
> -#define virt_to_mfn(v)		(pfn_to_mfn(virt_to_pfn(v)))
> -#define mfn_to_virt(m)		(__va(mfn_to_pfn(m) << PAGE_SHIFT))
> +/* VIRT <-> GUEST conversion */
> +#define virt_to_gfn(v)		(pfn_to_gfn(virt_to_pfn(v)))
> +#define gfn_to_virt(m)		(__va(gfn_to_pfn(m) << PAGE_SHIFT))
>  
>  /* Only used in PV code. However ARM guest is always assimilated as HVM. */
>  static inline xmaddr_t arbitrary_virt_to_machine(void *vaddr)
> diff --git a/arch/x86/include/asm/xen/page.h b/arch/x86/include/asm/xen/page.h
> index 046e91a..72d9f15 100644
> --- a/arch/x86/include/asm/xen/page.h
> +++ b/arch/x86/include/asm/xen/page.h
> @@ -99,7 +99,7 @@ static inline unsigned long __pfn_to_mfn(unsigned long pfn)
>  	return mfn;
>  }
>  
> -static inline unsigned long pfn_to_mfn(unsigned long pfn)
> +static inline unsigned long pfn_to_gfn(unsigned long pfn)
>  {
>  	unsigned long mfn;
>  
> @@ -145,23 +145,23 @@ static inline unsigned long mfn_to_pfn_no_overrides(unsigned long mfn)
>  	return pfn;
>  }
>  
> -static inline unsigned long mfn_to_pfn(unsigned long mfn)
> +static inline unsigned long gfn_to_pfn(unsigned long gfn)
>  {
>  	unsigned long pfn;
>  
>  	if (xen_feature(XENFEAT_auto_translated_physmap))
> -		return mfn;
> +		return gfn;
>  
> -	pfn = mfn_to_pfn_no_overrides(mfn);
> -	if (__pfn_to_mfn(pfn) != mfn)
> +	pfn = mfn_to_pfn_no_overrides(gfn);
> +	if (__pfn_to_mfn(pfn) != gfn)
>  		pfn = ~0;
>  
>  	/*
>  	 * pfn is ~0 if there are no entries in the m2p for mfn or the
>  	 * entry doesn't map back to the mfn.
>  	 */
> -	if (pfn == ~0 && __pfn_to_mfn(mfn) == IDENTITY_FRAME(mfn))
> -		pfn = mfn;
> +	if (pfn == ~0 && __pfn_to_mfn(gfn) == IDENTITY_FRAME(gfn))
> +		pfn = gfn;
>  
>  	return pfn;
>  }
> @@ -169,18 +169,18 @@ static inline unsigned long mfn_to_pfn(unsigned long mfn)
>  static inline xmaddr_t phys_to_machine(xpaddr_t phys)
>  {
>  	unsigned offset = phys.paddr & ~PAGE_MASK;
> -	return XMADDR(PFN_PHYS(pfn_to_mfn(PFN_DOWN(phys.paddr))) | offset);
> +	return XMADDR(PFN_PHYS(pfn_to_gfn(PFN_DOWN(phys.paddr))) | offset);
>  }
>  
>  static inline xpaddr_t machine_to_phys(xmaddr_t machine)
>  {
>  	unsigned offset = machine.maddr & ~PAGE_MASK;
> -	return XPADDR(PFN_PHYS(mfn_to_pfn(PFN_DOWN(machine.maddr))) | offset);
> +	return XPADDR(PFN_PHYS(gfn_to_pfn(PFN_DOWN(machine.maddr))) | offset);
>  }
>  
>  /* Pseudo-physical <-> DMA conversion */
> -#define pfn_to_dfn(pfn)		pfn_to_mfn(pfn)
> -#define dfn_to_pfn(dfn)		mfn_to_pfn(dfn)
> +#define pfn_to_dfn(pfn)		pfn_to_gfn(pfn)
> +#define dfn_to_pfn(dfn)		gfn_to_pfn(dfn)
>  
>  /*
>   * We detect special mappings in one of two ways:
> @@ -209,7 +209,7 @@ static inline unsigned long dfn_to_local_pfn(unsigned long mfn)
>  	if (xen_feature(XENFEAT_auto_translated_physmap))
>  		return mfn;
>  
> -	pfn = mfn_to_pfn(mfn);
> +	pfn = gfn_to_pfn(mfn);
>  	if (__pfn_to_mfn(pfn) != mfn)
>  		return -1; /* force !pfn_valid() */
>  	return pfn;
> @@ -218,8 +218,10 @@ static inline unsigned long dfn_to_local_pfn(unsigned long mfn)
>  /* VIRT <-> MACHINE conversion */
>  #define virt_to_machine(v)	(phys_to_machine(XPADDR(__pa(v))))
>  #define virt_to_pfn(v)          (PFN_DOWN(__pa(v)))
> -#define virt_to_mfn(v)		(pfn_to_mfn(virt_to_pfn(v)))
> -#define mfn_to_virt(m)		(__va(mfn_to_pfn(m) << PAGE_SHIFT))
> +
> +/* VIRT <-> GUEST conversion */
> +#define virt_to_gfn(v)		(pfn_to_gfn(virt_to_pfn(v)))
> +#define gfn_to_virt(m)		(__va(gfn_to_pfn(m) << PAGE_SHIFT))
>  
>  static inline unsigned long pte_mfn(pte_t pte)
>  {
> diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
> index 0b95c9b..a519b1b 100644
> --- a/arch/x86/xen/enlighten.c
> +++ b/arch/x86/xen/enlighten.c
> @@ -573,7 +573,7 @@ static void xen_load_gdt(const struct desc_ptr *dtr)
>  		BUG_ON(ptep == NULL);
>  
>  		pfn = pte_pfn(*ptep);
> -		mfn = pfn_to_mfn(pfn);
> +		mfn = pfn_to_gfn(pfn);
>  		virt = __va(PFN_PHYS(pfn));
>  
>  		frames[f] = mfn;
> @@ -610,7 +610,7 @@ static void __init xen_load_gdt_boot(const struct desc_ptr *dtr)
>  		unsigned long pfn, mfn;
>  
>  		pfn = virt_to_pfn(va);
> -		mfn = pfn_to_mfn(pfn);
> +		mfn = pfn_to_gfn(pfn);
>  
>  		pte = pfn_pte(pfn, PAGE_KERNEL_RO);
>  
> diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
> index dd151b2..742b8d2 100644
> --- a/arch/x86/xen/mmu.c
> +++ b/arch/x86/xen/mmu.c
> @@ -367,7 +367,7 @@ static pteval_t pte_mfn_to_pfn(pteval_t val)
>  {
>  	if (val & _PAGE_PRESENT) {
>  		unsigned long mfn = (val & PTE_PFN_MASK) >> PAGE_SHIFT;
> -		unsigned long pfn = mfn_to_pfn(mfn);
> +		unsigned long pfn = gfn_to_pfn(mfn);
>  
>  		pteval_t flags = val & PTE_FLAGS_MASK;
>  		if (unlikely(pfn == ~0))
> @@ -730,7 +730,7 @@ static void xen_do_pin(unsigned level, unsigned long pfn)
>  	struct mmuext_op op;
>  
>  	op.cmd = level;
> -	op.arg1.mfn = pfn_to_mfn(pfn);
> +	op.arg1.mfn = pfn_to_gfn(pfn);
>  
>  	xen_extend_mmuext_op(&op);
>  }
> @@ -1323,7 +1323,7 @@ static void __xen_write_cr3(bool kernel, unsigned long cr3)
>  	trace_xen_mmu_write_cr3(kernel, cr3);
>  
>  	if (cr3)
> -		mfn = pfn_to_mfn(PFN_DOWN(cr3));
> +		mfn = pfn_to_gfn(PFN_DOWN(cr3));
>  	else
>  		mfn = 0;
>  
> @@ -1493,7 +1493,7 @@ static void __init pin_pagetable_pfn(unsigned cmd, unsigned long pfn)
>  {
>  	struct mmuext_op op;
>  	op.cmd = cmd;
> -	op.arg1.mfn = pfn_to_mfn(pfn);
> +	op.arg1.mfn = pfn_to_gfn(pfn);
>  	if (HYPERVISOR_mmuext_op(&op, 1, NULL, DOMID_SELF))
>  		BUG();
>  }
> @@ -1539,7 +1539,7 @@ static inline void __pin_pagetable_pfn(unsigned cmd, unsigned long pfn)
>  	mcs = __xen_mc_entry(sizeof(*op));
>  	op = mcs.args;
>  	op->cmd = cmd;
> -	op->arg1.mfn = pfn_to_mfn(pfn);
> +	op->arg1.mfn = pfn_to_gfn(pfn);
>  
>  	MULTI_mmuext_op(mcs.mc, mcs.args, 1, NULL, DOMID_SELF);
>  }
> @@ -1672,7 +1672,7 @@ static unsigned long __init m2p(phys_addr_t maddr)
>  	phys_addr_t paddr;
>  
>  	maddr &= PTE_PFN_MASK;
> -	paddr = mfn_to_pfn(maddr >> PAGE_SHIFT) << PAGE_SHIFT;
> +	paddr = gfn_to_pfn(maddr >> PAGE_SHIFT) << PAGE_SHIFT;
>  
>  	return paddr;
>  }
> @@ -2178,7 +2178,7 @@ static void xen_zap_pfn_range(unsigned long vaddr, unsigned int order,
>  		mcs = __xen_mc_entry(0);
>  
>  		if (in_frames)
> -			in_frames[i] = virt_to_mfn(vaddr);
> +			in_frames[i] = virt_to_gfn(vaddr);
>  
>  		MULTI_update_va_mapping(mcs.mc, vaddr, VOID_PTE, 0);
>  		__set_phys_to_machine(virt_to_pfn(vaddr), INVALID_P2M_ENTRY);
> @@ -2343,7 +2343,7 @@ void xen_destroy_contiguous_region(phys_addr_t pstart, unsigned int order)
>  	spin_lock_irqsave(&xen_reservation_lock, flags);
>  
>  	/* 1. Find start MFN of contiguous extent. */
> -	in_frame = virt_to_mfn(vstart);
> +	in_frame = virt_to_gfn(vstart);
>  
>  	/* 2. Zap current PTEs. */
>  	xen_zap_pfn_range(vstart, order, NULL, out_frames);
> diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
> index 8b7f18e..9d23992d 100644
> --- a/arch/x86/xen/p2m.c
> +++ b/arch/x86/xen/p2m.c
> @@ -30,14 +30,14 @@
>   * However not all entries are filled with MFNs. Specifically for all other
>   * leaf entries, or for the top  root, or middle one, for which there is a void
>   * entry, we assume it is  "missing". So (for example)
> - *  pfn_to_mfn(0x90909090)=INVALID_P2M_ENTRY.
> + *  pfn_to_gfn(0x90909090)=INVALID_P2M_ENTRY.
>   * We have a dedicated page p2m_missing with all entries being
>   * INVALID_P2M_ENTRY. This page may be referenced multiple times in the p2m
>   * list/tree in case there are multiple areas with P2M_PER_PAGE invalid pfns.
>   *
>   * We also have the possibility of setting 1-1 mappings on certain regions, so
>   * that:
> - *  pfn_to_mfn(0xc0000)=0xc0000
> + *  pfn_to_gfn(0xc0000)=0xc0000
>   *
>   * The benefit of this is, that we can assume for non-RAM regions (think
>   * PCI BARs, or ACPI spaces), we can create mappings easily because we
> @@ -51,10 +51,10 @@
>   * identity value instead of dereferencing and returning INVALID_P2M_ENTRY.
>   * If the entry points to an allocated page, we just proceed as before and
>   * return the PFN. If the PFN has IDENTITY_FRAME_BIT set we unmask that in
> - * appropriate functions (pfn_to_mfn).
> + * appropriate functions (pfn_to_gfn).
>   *
>   * The reason for having the IDENTITY_FRAME_BIT instead of just returning the
> - * PFN is that we could find ourselves where pfn_to_mfn(pfn)==pfn for a
> + * PFN is that we could find ourselves where pfn_to_gfn(pfn)==pfn for a
>   * non-identity pfn. To protect ourselves against we elect to set (and get) the
>   * IDENTITY_FRAME_BIT on all identity mapped PFNs.
>   */
> @@ -129,7 +129,7 @@ static void p2m_top_mfn_init(unsigned long *top)
>  	unsigned i;
>  
>  	for (i = 0; i < P2M_TOP_PER_PAGE; i++)
> -		top[i] = virt_to_mfn(p2m_mid_missing_mfn);
> +		top[i] = virt_to_gfn(p2m_mid_missing_mfn);
>  }
>  
>  static void p2m_top_mfn_p_init(unsigned long **top)
> @@ -145,7 +145,7 @@ static void p2m_mid_mfn_init(unsigned long *mid, unsigned long *leaf)
>  	unsigned i;
>  
>  	for (i = 0; i < P2M_MID_PER_PAGE; i++)
> -		mid[i] = virt_to_mfn(leaf);
> +		mid[i] = virt_to_gfn(leaf);
>  }
>  
>  static void p2m_init(unsigned long *p2m)
> @@ -236,7 +236,7 @@ void __ref xen_build_mfn_list_list(void)
>  		if (ptep == p2m_missing_pte || ptep == p2m_identity_pte) {
>  			BUG_ON(mididx);
>  			BUG_ON(mid_mfn_p != p2m_mid_missing_mfn);
> -			p2m_top_mfn[topidx] = virt_to_mfn(p2m_mid_missing_mfn);
> +			p2m_top_mfn[topidx] = virt_to_gfn(p2m_mid_missing_mfn);
>  			pfn += (P2M_MID_PER_PAGE - 1) * P2M_PER_PAGE;
>  			continue;
>  		}
> @@ -248,7 +248,7 @@ void __ref xen_build_mfn_list_list(void)
>  			p2m_top_mfn_p[topidx] = mid_mfn_p;
>  		}
>  
> -		p2m_top_mfn[topidx] = virt_to_mfn(mid_mfn_p);
> +		p2m_top_mfn[topidx] = virt_to_gfn(mid_mfn_p);
>  		mid_mfn_p[mididx] = mfn;
>  	}
>  }
> @@ -261,7 +261,7 @@ void xen_setup_mfn_list_list(void)
>  	BUG_ON(HYPERVISOR_shared_info == &xen_dummy_shared_info);
>  
>  	HYPERVISOR_shared_info->arch.pfn_to_mfn_frame_list_list =
> -		virt_to_mfn(p2m_top_mfn);
> +		virt_to_gfn(p2m_top_mfn);
>  	HYPERVISOR_shared_info->arch.max_pfn = xen_max_p2m_pfn;
>  }
>  
> @@ -531,7 +531,7 @@ static bool alloc_p2m(unsigned long pfn)
>  		top_mfn_p = &p2m_top_mfn[topidx];
>  		mid_mfn = ACCESS_ONCE(p2m_top_mfn_p[topidx]);
>  
> -		BUG_ON(virt_to_mfn(mid_mfn) != *top_mfn_p);
> +		BUG_ON(virt_to_gfn(mid_mfn) != *top_mfn_p);
>  
>  		if (mid_mfn == p2m_mid_missing_mfn) {
>  			/* Separately check the mid mfn level */
> @@ -545,12 +545,12 @@ static bool alloc_p2m(unsigned long pfn)
>  
>  			p2m_mid_mfn_init(mid_mfn, p2m_missing);
>  
> -			missing_mfn = virt_to_mfn(p2m_mid_missing_mfn);
> -			mid_mfn_mfn = virt_to_mfn(mid_mfn);
> +			missing_mfn = virt_to_gfn(p2m_mid_missing_mfn);
> +			mid_mfn_mfn = virt_to_gfn(mid_mfn);
>  			old_mfn = cmpxchg(top_mfn_p, missing_mfn, mid_mfn_mfn);
>  			if (old_mfn != missing_mfn) {
>  				free_p2m_page(mid_mfn);
> -				mid_mfn = mfn_to_virt(old_mfn);
> +				mid_mfn = gfn_to_virt(old_mfn);
>  			} else {
>  				p2m_top_mfn_p[topidx] = mid_mfn;
>  			}
> @@ -580,7 +580,7 @@ static bool alloc_p2m(unsigned long pfn)
>  			set_pte(ptep,
>  				pfn_pte(PFN_DOWN(__pa(p2m)), PAGE_KERNEL));
>  			if (mid_mfn)
> -				mid_mfn[mididx] = virt_to_mfn(p2m);
> +				mid_mfn[mididx] = virt_to_gfn(p2m);
>  			p2m = NULL;
>  		}
>  
> @@ -682,7 +682,7 @@ int set_foreign_p2m_mapping(struct gnttab_map_grant_ref *map_ops,
>  			continue;
>  
>  		if (map_ops[i].flags & GNTMAP_contains_pte) {
> -			pte = (pte_t *)(mfn_to_virt(PFN_DOWN(map_ops[i].host_addr)) +
> +			pte = (pte_t *)(gfn_to_virt(PFN_DOWN(map_ops[i].host_addr)) +
>  				(map_ops[i].host_addr & ~PAGE_MASK));
>  			mfn = pte_mfn(*pte);
>  		} else {
> @@ -690,7 +690,7 @@ int set_foreign_p2m_mapping(struct gnttab_map_grant_ref *map_ops,
>  		}
>  		pfn = page_to_pfn(pages[i]);
>  
> -		WARN(pfn_to_mfn(pfn) != INVALID_P2M_ENTRY, "page must be ballooned");
> +		WARN(pfn_to_gfn(pfn) != INVALID_P2M_ENTRY, "page must be ballooned");
>  
>  		if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn)))) {
>  			ret = -ENOMEM;
> diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
> index 55f388e..4c2e91d 100644
> --- a/arch/x86/xen/setup.c
> +++ b/arch/x86/xen/setup.c
> @@ -231,10 +231,10 @@ static void __init xen_set_identity_and_release_chunk(unsigned long start_pfn,
>  	/* Release pages first. */
>  	end = min(end_pfn, nr_pages);
>  	for (pfn = start_pfn; pfn < end; pfn++) {
> -		unsigned long mfn = pfn_to_mfn(pfn);
> +		unsigned long mfn = pfn_to_gfn(pfn);
>  
>  		/* Make sure pfn exists to start with */
> -		if (mfn == INVALID_P2M_ENTRY || mfn_to_pfn(mfn) != pfn)
> +		if (mfn == INVALID_P2M_ENTRY || gfn_to_pfn(mfn) != pfn)
>  			continue;
>  
>  		ret = xen_free_mfn(mfn);
> @@ -313,7 +313,7 @@ static void __init xen_do_set_identity_and_remap_chunk(
>  
>  	BUG_ON(xen_feature(XENFEAT_auto_translated_physmap));
>  
> -	mfn_save = virt_to_mfn(buf);
> +	mfn_save = virt_to_gfn(buf);
>  
>  	for (ident_pfn_iter = start_pfn, remap_pfn_iter = remap_pfn;
>  	     ident_pfn_iter < ident_end_pfn;
> @@ -321,7 +321,7 @@ static void __init xen_do_set_identity_and_remap_chunk(
>  		chunk = (left < REMAP_SIZE) ? left : REMAP_SIZE;
>  
>  		/* Map first pfn to xen_remap_buf */
> -		mfn = pfn_to_mfn(ident_pfn_iter);
> +		mfn = pfn_to_gfn(ident_pfn_iter);
>  		set_pte_mfn(buf, mfn, PAGE_KERNEL);
>  
>  		/* Save mapping information in page */
> @@ -329,7 +329,7 @@ static void __init xen_do_set_identity_and_remap_chunk(
>  		xen_remap_buf.target_pfn = remap_pfn_iter;
>  		xen_remap_buf.size = chunk;
>  		for (i = 0; i < chunk; i++)
> -			xen_remap_buf.mfns[i] = pfn_to_mfn(ident_pfn_iter + i);
> +			xen_remap_buf.mfns[i] = pfn_to_gfn(ident_pfn_iter + i);
>  
>  		/* Put remap buf into list. */
>  		xen_remap_mfn = mfn;
> @@ -473,7 +473,7 @@ void __init xen_remap_memory(void)
>  	unsigned long pfn_s = ~0UL;
>  	unsigned long len = 0;
>  
> -	mfn_save = virt_to_mfn(buf);
> +	mfn_save = virt_to_gfn(buf);
>  
>  	while (xen_remap_mfn != INVALID_P2M_ENTRY) {
>  		/* Map the remap information */
> diff --git a/arch/x86/xen/smp.c b/arch/x86/xen/smp.c
> index 8648438..680f281 100644
> --- a/arch/x86/xen/smp.c
> +++ b/arch/x86/xen/smp.c
> @@ -395,7 +395,7 @@ cpu_initialize_context(unsigned int cpu, struct task_struct *idle)
>  
>  		gdt_mfn = arbitrary_virt_to_mfn(gdt);
>  		make_lowmem_page_readonly(gdt);
> -		make_lowmem_page_readonly(mfn_to_virt(gdt_mfn));
> +		make_lowmem_page_readonly(gfn_to_virt(gdt_mfn));
>  
>  		ctxt->gdt_frames[0] = gdt_mfn;
>  		ctxt->gdt_ents      = GDT_ENTRIES;
> @@ -429,7 +429,7 @@ cpu_initialize_context(unsigned int cpu, struct task_struct *idle)
>  	}
>  #endif
>  	ctxt->user_regs.esp = idle->thread.sp0 - sizeof(struct pt_regs);
> -	ctxt->ctrlreg[3] = xen_pfn_to_cr3(virt_to_mfn(swapper_pg_dir));
> +	ctxt->ctrlreg[3] = xen_pfn_to_cr3(virt_to_gfn(swapper_pg_dir));
>  	if (HYPERVISOR_vcpu_op(VCPUOP_initialise, cpu, ctxt))
>  		BUG();
>  
> diff --git a/arch/x86/xen/suspend.c b/arch/x86/xen/suspend.c
> index 53b4c08..60624e7 100644
> --- a/arch/x86/xen/suspend.c
> +++ b/arch/x86/xen/suspend.c
> @@ -16,9 +16,9 @@ static void xen_pv_pre_suspend(void)
>  {
>  	xen_mm_pin_all();
>  
> -	xen_start_info->store_mfn = mfn_to_pfn(xen_start_info->store_mfn);
> +	xen_start_info->store_mfn = gfn_to_pfn(xen_start_info->store_mfn);
>  	xen_start_info->console.domU.mfn =
> -		mfn_to_pfn(xen_start_info->console.domU.mfn);
> +		gfn_to_pfn(xen_start_info->console.domU.mfn);
>  
>  	BUG_ON(!irqs_disabled());
>  
> @@ -51,9 +51,9 @@ static void xen_pv_post_suspend(int suspend_cancelled)
>  
>  	if (suspend_cancelled) {
>  		xen_start_info->store_mfn =
> -			pfn_to_mfn(xen_start_info->store_mfn);
> +			pfn_to_gfn(xen_start_info->store_mfn);
>  		xen_start_info->console.domU.mfn =
> -			pfn_to_mfn(xen_start_info->console.domU.mfn);
> +			pfn_to_gfn(xen_start_info->console.domU.mfn);
>  	} else {
>  #ifdef CONFIG_SMP
>  		BUG_ON(xen_cpu_initialized_map == NULL);
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
> index fd93369..9734649 100644
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
> index 96093ae..95a4fdb 100644
> --- a/drivers/xen/events/events_base.c
> +++ b/drivers/xen/events/events_base.c
> @@ -1692,7 +1692,7 @@ void __init xen_init_IRQ(void)
>  		struct physdev_pirq_eoi_gmfn eoi_gmfn;
>  
>  		pirq_eoi_map = (void *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
> -		eoi_gmfn.gmfn = virt_to_mfn(pirq_eoi_map);
> +		eoi_gmfn.gmfn = virt_to_gfn(pirq_eoi_map);
>  		rc = HYPERVISOR_physdev_op(PHYSDEVOP_pirq_eoi_gmfn_v2, &eoi_gmfn);
>  		/* TODO: No PVH support for PIRQ EOI */
>  		if (rc != 0) {
> diff --git a/drivers/xen/events/events_fifo.c b/drivers/xen/events/events_fifo.c
> index ed673e1..1d4baf5 100644
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
> index 4308fb3..31836897 100644
> --- a/drivers/xen/xenbus/xenbus_probe.c
> +++ b/drivers/xen/xenbus/xenbus_probe.c
> @@ -711,9 +711,7 @@ static int __init xenstored_local_init(void)
>  	if (!page)
>  		goto out_err;
>  
> -	xen_store_mfn = xen_start_info->store_mfn =
> -		pfn_to_mfn(virt_to_phys((void *)page) >>
> -			   PAGE_SHIFT);
> +	xen_store_mfn = xen_start_info->store_mfn = virt_to_gfn(page);
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
