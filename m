From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH v4] xen/grant-table: Avoid m2p_override during
 mapping
Date: Wed, 22 Jan 2014 18:36:39 +0000
Message-ID: <52E00FB7.3040508@citrix.com>
References: <1390335755-29328-1-git-send-email-zoltan.kiss@citrix.com> <alpine.DEB.2.02.1401221618340.21510@kaball.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1401221618340.21510@kaball.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/01/14 16:39, Stefano Stabellini wrote:
> On Tue, 21 Jan 2014, Zoltan Kiss wrote:
>> @@ -121,7 +125,7 @@ static inline unsigned long mfn_to_pfn(unsigned long mfn)
>>   		pfn = m2p_find_override_pfn(mfn, ~0);
>>   	}
>>
>> -	/*
>> +	/*
>
> Spurious change?
It removes a stray space from the original code. Not necessary, but if 
it's there, I think we can keep it.

>> diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
>> index 2ae8699..0060178 100644
>> --- a/arch/x86/xen/p2m.c
>> +++ b/arch/x86/xen/p2m.c
>> @@ -872,15 +872,13 @@ static unsigned long mfn_hash(unsigned long mfn)
>>
>>   /* Add an MFN override for a particular page */
>>   int m2p_add_override(unsigned long mfn, struct page *page,
>> -		struct gnttab_map_grant_ref *kmap_op)
>> +		struct gnttab_map_grant_ref *kmap_op, unsigned long pfn)
>
> Do we really need to add another additional parameter to
> m2p_add_override?
> I would just let m2p_add_override and m2p_remove_override call
> page_to_pfn again. It is not that expensive.
Yes, because that page_to_pfn can return something different. That's why 
the v2 patches failed.

>> @@ -933,20 +924,15 @@ int m2p_add_override(unsigned long mfn, struct page *page,
>>   }
>>   EXPORT_SYMBOL_GPL(m2p_add_override);
>>   int m2p_remove_override(struct page *page,
>> -		struct gnttab_map_grant_ref *kmap_op)
>> +			struct gnttab_map_grant_ref *kmap_op,
>> +			unsigned long pfn,
>> +			unsigned long mfn)
>
> Same here
Same as above.

>> @@ -927,8 +931,18 @@ int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>>   		} else {
>>   			mfn = PFN_DOWN(map_ops[i].dev_bus_addr);
>>   		}
>> -		ret = m2p_add_override(mfn, pages[i], kmap_ops ?
>> -				       &kmap_ops[i] : NULL);
>> +		pfn = page_to_pfn(pages[i]);
>> +
>> +		WARN_ON(PagePrivate(pages[i]));
>> +		SetPagePrivate(pages[i]);
>> +		set_page_private(pages[i], mfn);
>> +
>> +		pages[i]->index = pfn_to_mfn(pfn);
>> +		if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn))))
>> +			return -ENOMEM;
>
> goto out
And ret = -ENOMEM
>
>
>> +		if (m2p_override)
>> +			ret = m2p_add_override(mfn, pages[i], kmap_ops ?
>> +					       &kmap_ops[i] : NULL, pfn);
>>   		if (ret)
>>   			goto out;
>>   	}
>> @@ -937,17 +951,34 @@ int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>>   	if (lazy)
>>   		arch_leave_lazy_mmu_mode();
>>
>> -	return ret;
>> +	return 0;
>
> We are loosing the error code possibly returned by m2p_add_override and
> the previous check.
I'll fix that. Also in unmap.

		return ret;
>> @@ -958,17 +989,32 @@ int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
>>   			set_phys_to_machine(unmap_ops[i].host_addr >> PAGE_SHIFT,
>>   					INVALID_P2M_ENTRY);
>>   		}
>> -		return ret;
>> +		return 0;
>>   	}
>>
>> -	if (!in_interrupt() && paravirt_get_lazy_mode() == PARAVIRT_LAZY_NONE) {
>> +	if (m2p_override &&
>> +	    !in_interrupt() &&
>> +	    paravirt_get_lazy_mode() == PARAVIRT_LAZY_NONE) {
>>   		arch_enter_lazy_mmu_mode();
>>   		lazy = true;
>>   	}
>>
>>   	for (i = 0; i < count; i++) {
>> -		ret = m2p_remove_override(pages[i], kmap_ops ?
>> -				       &kmap_ops[i] : NULL);
>> +		pfn = page_to_pfn(pages[i]);
>> +		mfn = get_phys_to_machine(pfn);
>> +		if (mfn == INVALID_P2M_ENTRY || !(mfn & FOREIGN_FRAME_BIT))
>> +			return -EINVAL;
>
> goto out
And ret = -EINVAL

The above are the the result of the fact that I've based this originally 
on 3.10, where the out label haven't existed. I'll send the next version 
when the tests pass.

Zoli
