From: Julien Grall <julien.grall@linaro.org>
Subject: Re: [Xen-devel] [PATCH v6] xen/grant-table: Avoid m2p_override during
 mapping
Date: Sun, 02 Feb 2014 10:29:58 +0000
Message-ID: <52EE1E26.2040308@linaro.org>
References: <1390512224-27296-1-git-send-email-zoltan.kiss@citrix.com> <alpine.DEB.2.02.1401232333280.15917@kaball.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jonathan.davies@citrix.com, wei.liu2@citrix.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1401232333280.15917@kaball.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 23/01/14 23:34, Stefano Stabellini wrote:
> On Thu, 23 Jan 2014, Zoltan Kiss wrote:
>> The grant mapping API does m2p_override unnecessarily: only gntdev n=
eeds it,
>> for blkback and future netback patches it just cause a lock contenti=
on, as
>> those pages never go to userspace. Therefore this series does the fo=
llowing:
>> - the original functions were renamed to __gnttab_[un]map_refs, with=
 a new
>>    parameter m2p_override
>> - based on m2p_override either they follow the original behaviour, o=
r just set
>>    the private flag and call set_phys_to_machine
>> - gnttab_[un]map_refs are now a wrapper to call __gnttab_[un]map_ref=
s with
>>    m2p_override false
>> - a new function gnttab_[un]map_refs_userspace provides the old beha=
viour
>>
>> It also removes a stray space from page.h and change ret to 0 if
>> XENFEAT_auto_translated_physmap, as that is the only possible return=
 value
>> there.
>>
>> v2:
>> - move the storing of the old mfn in page->index to gnttab_map_refs
>> - move the function header update to a separate patch
>>
>> v3:
>> - a new approach to retain old behaviour where it needed
>> - squash the patches into one
>>
>> v4:
>> - move out the common bits from m2p* functions, and pass pfn/mfn as =
parameter
>> - clear page->private before doing anything with the page, so m2p_fi=
nd_override
>>    won't race with this
>>
>> v5:
>> - change return value handling in __gnttab_[un]map_refs
>> - remove a stray space in page.h
>> - add detail why ret =3D 0 now at some places
>>
>> v6:
>> - don't pass pfn to m2p* functions, just get it locally
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> Suggested-by: David Vrabel <david.vrabel@citrix.com>
>=20
> Reviewed-by: Stefano Stabellini <stefano.stabellini@eu.citrix.com>

Hello,

This patch is breaking Linux compilation on ARM:

drivers/xen/grant-table.c: In function =91__gnttab_map_refs=92:
drivers/xen/grant-table.c:989:3: error: implicit declaration of functio=
n =91FOREIGN_FRAME=92 [-Werror=3Dimplicit-function-declaration]
   if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn)))) {
   ^
drivers/xen/grant-table.c: In function =91__gnttab_unmap_refs=92:
drivers/xen/grant-table.c:1054:3: error: implicit declaration of functi=
on =91get_phys_to_machine=92 [-Werror=3Dimplicit-function-declaration]
   mfn =3D get_phys_to_machine(pfn);
   ^
drivers/xen/grant-table.c:1055:43: error: =91FOREIGN_FRAME_BIT=92 undec=
lared (first use in this function)
   if (mfn =3D=3D INVALID_P2M_ENTRY || !(mfn & FOREIGN_FRAME_BIT)) {
                                           ^
drivers/xen/grant-table.c:1055:43: note: each undeclared identifier is =
reported only once for each function it appears in
drivers/xen/grant-table.c:1068:9: error: too many arguments to function=
 =91m2p_remove_override=92
         mfn);
         ^
In file included from include/xen/page.h:4:0,
                 from drivers/xen/grant-table.c:48:
/local/home/julien/works/midway/linux/arch/arm/include/asm/xen/page.h:1=
06:19: note: declared here
 static inline int m2p_remove_override(struct page *page, bool clear_pt=
e)
                   ^
cc1: some warnings being treated as errors

>=20
>=20
>=20
>>   arch/x86/include/asm/xen/page.h     |    5 +-
>>   arch/x86/xen/p2m.c                  |   17 +------
>>   drivers/block/xen-blkback/blkback.c |   15 +++---
>>   drivers/xen/gntdev.c                |   13 +++--
>>   drivers/xen/grant-table.c           |   89 +++++++++++++++++++++++=
+++++++-----
>>   include/xen/grant_table.h           |    8 +++-
>>   6 files changed, 101 insertions(+), 46 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/xen/page.h b/arch/x86/include/asm/=
xen/page.h
>> index b913915..ce47243 100644
>> --- a/arch/x86/include/asm/xen/page.h
>> +++ b/arch/x86/include/asm/xen/page.h
>> @@ -52,7 +52,8 @@ extern unsigned long set_phys_range_identity(unsig=
ned long pfn_s,
>>   extern int m2p_add_override(unsigned long mfn, struct page *page,
>>   			    struct gnttab_map_grant_ref *kmap_op);
>>   extern int m2p_remove_override(struct page *page,
>> -				struct gnttab_map_grant_ref *kmap_op);
>> +			       struct gnttab_map_grant_ref *kmap_op,
>> +			       unsigned long mfn);
>>   extern struct page *m2p_find_override(unsigned long mfn);
>>   extern unsigned long m2p_find_override_pfn(unsigned long mfn, unsi=
gned long pfn);
>>  =20
>> @@ -121,7 +122,7 @@ static inline unsigned long mfn_to_pfn(unsigned =
long mfn)
>>   		pfn =3D m2p_find_override_pfn(mfn, ~0);
>>   	}
>>  =20
>> -	/*
>> +	/*
>>   	 * pfn is ~0 if there are no entries in the m2p for mfn or if the
>>   	 * entry doesn't map back to the mfn and m2p_override doesn't hav=
e a
>>   	 * valid entry for it.
>> diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
>> index 2ae8699..bd4724b 100644
>> --- a/arch/x86/xen/p2m.c
>> +++ b/arch/x86/xen/p2m.c
>> @@ -888,13 +888,6 @@ int m2p_add_override(unsigned long mfn, struct =
page *page,
>>   					"m2p_add_override: pfn %lx not mapped", pfn))
>>   			return -EINVAL;
>>   	}
>> -	WARN_ON(PagePrivate(page));
>> -	SetPagePrivate(page);
>> -	set_page_private(page, mfn);
>> -	page->index =3D pfn_to_mfn(pfn);
>> -
>> -	if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn))))
>> -		return -ENOMEM;
>>  =20
>>   	if (kmap_op !=3D NULL) {
>>   		if (!PageHighMem(page)) {
>> @@ -933,19 +926,16 @@ int m2p_add_override(unsigned long mfn, struct=
 page *page,
>>   }
>>   EXPORT_SYMBOL_GPL(m2p_add_override);
>>   int m2p_remove_override(struct page *page,
>> -		struct gnttab_map_grant_ref *kmap_op)
>> +			struct gnttab_map_grant_ref *kmap_op,
>> +			unsigned long mfn)
>>   {
>>   	unsigned long flags;
>> -	unsigned long mfn;
>>   	unsigned long pfn;
>>   	unsigned long uninitialized_var(address);
>>   	unsigned level;
>>   	pte_t *ptep =3D NULL;
>>  =20
>>   	pfn =3D page_to_pfn(page);
>> -	mfn =3D get_phys_to_machine(pfn);
>> -	if (mfn =3D=3D INVALID_P2M_ENTRY || !(mfn & FOREIGN_FRAME_BIT))
>> -		return -EINVAL;
>>  =20
>>   	if (!PageHighMem(page)) {
>>   		address =3D (unsigned long)__va(pfn << PAGE_SHIFT);
>> @@ -959,10 +949,7 @@ int m2p_remove_override(struct page *page,
>>   	spin_lock_irqsave(&m2p_override_lock, flags);
>>   	list_del(&page->lru);
>>   	spin_unlock_irqrestore(&m2p_override_lock, flags);
>> -	WARN_ON(!PagePrivate(page));
>> -	ClearPagePrivate(page);
>>  =20
>> -	set_phys_to_machine(pfn, page->index);
>>   	if (kmap_op !=3D NULL) {
>>   		if (!PageHighMem(page)) {
>>   			struct multicall_space mcs;
>> diff --git a/drivers/block/xen-blkback/blkback.c b/drivers/block/xen=
-blkback/blkback.c
>> index 6620b73..875025f 100644
>> --- a/drivers/block/xen-blkback/blkback.c
>> +++ b/drivers/block/xen-blkback/blkback.c
>> @@ -285,8 +285,7 @@ static void free_persistent_gnts(struct xen_blki=
f *blkif, struct rb_root *root,
>>  =20
>>   		if (++segs_to_unmap =3D=3D BLKIF_MAX_SEGMENTS_PER_REQUEST ||
>>   			!rb_next(&persistent_gnt->node)) {
>> -			ret =3D gnttab_unmap_refs(unmap, NULL, pages,
>> -				segs_to_unmap);
>> +			ret =3D gnttab_unmap_refs(unmap, pages, segs_to_unmap);
>>   			BUG_ON(ret);
>>   			put_free_pages(blkif, pages, segs_to_unmap);
>>   			segs_to_unmap =3D 0;
>> @@ -321,8 +320,7 @@ static void unmap_purged_grants(struct work_stru=
ct *work)
>>   		pages[segs_to_unmap] =3D persistent_gnt->page;
>>  =20
>>   		if (++segs_to_unmap =3D=3D BLKIF_MAX_SEGMENTS_PER_REQUEST) {
>> -			ret =3D gnttab_unmap_refs(unmap, NULL, pages,
>> -				segs_to_unmap);
>> +			ret =3D gnttab_unmap_refs(unmap, pages, segs_to_unmap);
>>   			BUG_ON(ret);
>>   			put_free_pages(blkif, pages, segs_to_unmap);
>>   			segs_to_unmap =3D 0;
>> @@ -330,7 +328,7 @@ static void unmap_purged_grants(struct work_stru=
ct *work)
>>   		kfree(persistent_gnt);
>>   	}
>>   	if (segs_to_unmap > 0) {
>> -		ret =3D gnttab_unmap_refs(unmap, NULL, pages, segs_to_unmap);
>> +		ret =3D gnttab_unmap_refs(unmap, pages, segs_to_unmap);
>>   		BUG_ON(ret);
>>   		put_free_pages(blkif, pages, segs_to_unmap);
>>   	}
>> @@ -670,15 +668,14 @@ static void xen_blkbk_unmap(struct xen_blkif *=
blkif,
>>   				    GNTMAP_host_map, pages[i]->handle);
>>   		pages[i]->handle =3D BLKBACK_INVALID_HANDLE;
>>   		if (++invcount =3D=3D BLKIF_MAX_SEGMENTS_PER_REQUEST) {
>> -			ret =3D gnttab_unmap_refs(unmap, NULL, unmap_pages,
>> -			                        invcount);
>> +			ret =3D gnttab_unmap_refs(unmap, unmap_pages, invcount);
>>   			BUG_ON(ret);
>>   			put_free_pages(blkif, unmap_pages, invcount);
>>   			invcount =3D 0;
>>   		}
>>   	}
>>   	if (invcount) {
>> -		ret =3D gnttab_unmap_refs(unmap, NULL, unmap_pages, invcount);
>> +		ret =3D gnttab_unmap_refs(unmap, unmap_pages, invcount);
>>   		BUG_ON(ret);
>>   		put_free_pages(blkif, unmap_pages, invcount);
>>   	}
>> @@ -740,7 +737,7 @@ again:
>>   	}
>>  =20
>>   	if (segs_to_map) {
>> -		ret =3D gnttab_map_refs(map, NULL, pages_to_gnt, segs_to_map);
>> +		ret =3D gnttab_map_refs(map, pages_to_gnt, segs_to_map);
>>   		BUG_ON(ret);
>>   	}
>>  =20
>> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
>> index e41c79c..e652c0e 100644
>> --- a/drivers/xen/gntdev.c
>> +++ b/drivers/xen/gntdev.c
>> @@ -284,8 +284,10 @@ static int map_grant_pages(struct grant_map *ma=
p)
>>   	}
>>  =20
>>   	pr_debug("map %d+%d\n", map->index, map->count);
>> -	err =3D gnttab_map_refs(map->map_ops, use_ptemod ? map->kmap_ops :=
 NULL,
>> -			map->pages, map->count);
>> +	err =3D gnttab_map_refs_userspace(map->map_ops,
>> +					use_ptemod ? map->kmap_ops : NULL,
>> +					map->pages,
>> +					map->count);
>>   	if (err)
>>   		return err;
>>  =20
>> @@ -315,9 +317,10 @@ static int __unmap_grant_pages(struct grant_map=
 *map, int offset, int pages)
>>   		}
>>   	}
>>  =20
>> -	err =3D gnttab_unmap_refs(map->unmap_ops + offset,
>> -			use_ptemod ? map->kmap_ops + offset : NULL, map->pages + offset,
>> -			pages);
>> +	err =3D gnttab_unmap_refs_userspace(map->unmap_ops + offset,
>> +					  use_ptemod ? map->kmap_ops + offset : NULL,
>> +					  map->pages + offset,
>> +					  pages);
>>   	if (err)
>>   		return err;
>>  =20
>> diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
>> index aa846a4..e4ddfeb 100644
>> --- a/drivers/xen/grant-table.c
>> +++ b/drivers/xen/grant-table.c
>> @@ -880,15 +880,17 @@ void gnttab_batch_copy(struct gnttab_copy *bat=
ch, unsigned count)
>>   }
>>   EXPORT_SYMBOL_GPL(gnttab_batch_copy);
>>  =20
>> -int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>> +int __gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>>   		    struct gnttab_map_grant_ref *kmap_ops,
>> -		    struct page **pages, unsigned int count)
>> +		    struct page **pages, unsigned int count,
>> +		    bool m2p_override)
>>   {
>>   	int i, ret;
>>   	bool lazy =3D false;
>>   	pte_t *pte;
>> -	unsigned long mfn;
>> +	unsigned long mfn, pfn;
>>  =20
>> +	BUG_ON(kmap_ops && !m2p_override);
>>   	ret =3D HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, map_ops=
, count);
>>   	if (ret)
>>   		return ret;
>> @@ -907,10 +909,12 @@ int gnttab_map_refs(struct gnttab_map_grant_re=
f *map_ops,
>>   			set_phys_to_machine(map_ops[i].host_addr >> PAGE_SHIFT,
>>   					map_ops[i].dev_bus_addr >> PAGE_SHIFT);
>>   		}
>> -		return ret;
>> +		return 0;
>>   	}
>>  =20
>> -	if (!in_interrupt() && paravirt_get_lazy_mode() =3D=3D PARAVIRT_LA=
ZY_NONE) {
>> +	if (m2p_override &&
>> +	    !in_interrupt() &&
>> +	    paravirt_get_lazy_mode() =3D=3D PARAVIRT_LAZY_NONE) {
>>   		arch_enter_lazy_mmu_mode();
>>   		lazy =3D true;
>>   	}
>> @@ -927,8 +931,20 @@ int gnttab_map_refs(struct gnttab_map_grant_ref=
 *map_ops,
>>   		} else {
>>   			mfn =3D PFN_DOWN(map_ops[i].dev_bus_addr);
>>   		}
>> -		ret =3D m2p_add_override(mfn, pages[i], kmap_ops ?
>> -				       &kmap_ops[i] : NULL);
>> +		pfn =3D page_to_pfn(pages[i]);
>> +
>> +		WARN_ON(PagePrivate(pages[i]));
>> +		SetPagePrivate(pages[i]);
>> +		set_page_private(pages[i], mfn);
>> +
>> +		pages[i]->index =3D pfn_to_mfn(pfn);
>> +		if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn)))) {
>> +			ret =3D -ENOMEM;
>> +			goto out;
>> +		}
>> +		if (m2p_override)
>> +			ret =3D m2p_add_override(mfn, pages[i], kmap_ops ?
>> +					       &kmap_ops[i] : NULL);
>>   		if (ret)
>>   			goto out;
>>   	}
>> @@ -939,15 +955,32 @@ int gnttab_map_refs(struct gnttab_map_grant_re=
f *map_ops,
>>  =20
>>   	return ret;
>>   }
>> +
>> +int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>> +		    struct page **pages, unsigned int count)
>> +{
>> +	return __gnttab_map_refs(map_ops, NULL, pages, count, false);
>> +}
>>   EXPORT_SYMBOL_GPL(gnttab_map_refs);
>>  =20
>> -int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
>> +int gnttab_map_refs_userspace(struct gnttab_map_grant_ref *map_ops,
>> +			      struct gnttab_map_grant_ref *kmap_ops,
>> +			      struct page **pages, unsigned int count)
>> +{
>> +	return __gnttab_map_refs(map_ops, kmap_ops, pages, count, true);
>> +}
>> +EXPORT_SYMBOL_GPL(gnttab_map_refs_userspace);
>> +
>> +int __gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
>>   		      struct gnttab_map_grant_ref *kmap_ops,
>> -		      struct page **pages, unsigned int count)
>> +		      struct page **pages, unsigned int count,
>> +		      bool m2p_override)
>>   {
>>   	int i, ret;
>>   	bool lazy =3D false;
>> +	unsigned long pfn, mfn;
>>  =20
>> +	BUG_ON(kmap_ops && !m2p_override);
>>   	ret =3D HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, unmap=
_ops, count);
>>   	if (ret)
>>   		return ret;
>> @@ -958,17 +991,33 @@ int gnttab_unmap_refs(struct gnttab_unmap_gran=
t_ref *unmap_ops,
>>   			set_phys_to_machine(unmap_ops[i].host_addr >> PAGE_SHIFT,
>>   					INVALID_P2M_ENTRY);
>>   		}
>> -		return ret;
>> +		return 0;
>>   	}
>>  =20
>> -	if (!in_interrupt() && paravirt_get_lazy_mode() =3D=3D PARAVIRT_LA=
ZY_NONE) {
>> +	if (m2p_override &&
>> +	    !in_interrupt() &&
>> +	    paravirt_get_lazy_mode() =3D=3D PARAVIRT_LAZY_NONE) {
>>   		arch_enter_lazy_mmu_mode();
>>   		lazy =3D true;
>>   	}
>>  =20
>>   	for (i =3D 0; i < count; i++) {
>> -		ret =3D m2p_remove_override(pages[i], kmap_ops ?
>> -				       &kmap_ops[i] : NULL);
>> +		pfn =3D page_to_pfn(pages[i]);
>> +		mfn =3D get_phys_to_machine(pfn);
>> +		if (mfn =3D=3D INVALID_P2M_ENTRY || !(mfn & FOREIGN_FRAME_BIT)) {
>> +			ret =3D -EINVAL;
>> +			goto out;
>> +		}
>> +
>> +		set_page_private(pages[i], INVALID_P2M_ENTRY);
>> +		WARN_ON(!PagePrivate(pages[i]));
>> +		ClearPagePrivate(pages[i]);
>> +		set_phys_to_machine(pfn, pages[i]->index);
>> +		if (m2p_override)
>> +			ret =3D m2p_remove_override(pages[i],
>> +						  kmap_ops ?
>> +						   &kmap_ops[i] : NULL,
>> +						  mfn);
>>   		if (ret)
>>   			goto out;
>>   	}
>> @@ -979,8 +1028,22 @@ int gnttab_unmap_refs(struct gnttab_unmap_gran=
t_ref *unmap_ops,
>>  =20
>>   	return ret;
>>   }
>> +
>> +int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *map_ops,
>> +		    struct page **pages, unsigned int count)
>> +{
>> +	return __gnttab_unmap_refs(map_ops, NULL, pages, count, false);
>> +}
>>   EXPORT_SYMBOL_GPL(gnttab_unmap_refs);
>>  =20
>> +int gnttab_unmap_refs_userspace(struct gnttab_unmap_grant_ref *map_=
ops,
>> +				struct gnttab_map_grant_ref *kmap_ops,
>> +				struct page **pages, unsigned int count)
>> +{
>> +	return __gnttab_unmap_refs(map_ops, kmap_ops, pages, count, true);
>> +}
>> +EXPORT_SYMBOL_GPL(gnttab_unmap_refs_userspace);
>> +
>>   static unsigned nr_status_frames(unsigned nr_grant_frames)
>>   {
>>   	BUG_ON(grefs_per_grant_frame =3D=3D 0);
>> diff --git a/include/xen/grant_table.h b/include/xen/grant_table.h
>> index 694dcaf..9a919b1 100644
>> --- a/include/xen/grant_table.h
>> +++ b/include/xen/grant_table.h
>> @@ -184,11 +184,15 @@ unsigned int gnttab_max_grant_frames(void);
>>   #define gnttab_map_vaddr(map) ((void *)(map.host_virt_addr))
>>  =20
>>   int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>> -		    struct gnttab_map_grant_ref *kmap_ops,
>>   		    struct page **pages, unsigned int count);
>> +int gnttab_map_refs_userspace(struct gnttab_map_grant_ref *map_ops,
>> +			      struct gnttab_map_grant_ref *kmap_ops,
>> +			      struct page **pages, unsigned int count);
>>   int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
>> -		      struct gnttab_map_grant_ref *kunmap_ops,
>>   		      struct page **pages, unsigned int count);
>> +int gnttab_unmap_refs_userspace(struct gnttab_unmap_grant_ref *unma=
p_ops,
>> +				struct gnttab_map_grant_ref *kunmap_ops,
>> +				struct page **pages, unsigned int count);
>>  =20
>>   /* Perform a batch of grant map/copy operations. Retry every batch=
 slot
>>    * for which the hypervisor returns GNTST_eagain. This is typicall=
y due
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kern=
el" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
>=20
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
>=20

--=20
Julien Grall
