From: Moshe Lazer <moshel@dev.mellanox.co.il>
Subject: Re: [PATCH V1 net-next 1/2] pgtable: Add API to query if write combining
 is available
Date: Sun, 26 Oct 2014 17:00:25 +0200
Message-ID: <544D0C89.2020303@dev.mellanox.co.il>
References: <20141007.154425.2156753440391523455.davem@davemloft.net>	<925ad10b2ec44e228e69bf0cbe6c0a0e@AMSPR05MB002.eurprd05.prod.outlook.com>	<5434F989.2040101@dev.mellanox.co.il> <20141008.122450.1919301744382855426.davem@davemloft.net> <543A4FE4.7010807@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	talal@mellanox.com, yevgenyp@mellanox.com, netdev@vger.kernel.org,
	amirv@mellanox.com, moshel@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:43057 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbaJZPAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 11:00:30 -0400
Received: by mail-wg0-f49.google.com with SMTP id x13so287625wgg.32
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2014 08:00:29 -0700 (PDT)
In-Reply-To: <543A4FE4.7010807@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/12/2014 12:54 PM, Moshe Lazer wrote:
>
> On 10/8/2014 7:24 PM, David Miller wrote:
>> From: Moshe Lazer <moshel@dev.mellanox.co.il>
>> Date: Wed, 08 Oct 2014 11:44:57 +0300
>>
>>>> #if defined(__i386__) || defined(__x86_64__)
>>>>     if (map->type == _DRM_REGISTERS && !(map->flags & 
>>>> _DRM_WRITE_COMBINING))
>>>>         tmp = pgprot_noncached(tmp);
>>>>     else
>>>>         tmp = pgprot_writecombine(tmp);
>>>> #elif defined(__powerpc__)
>>>>     pgprot_val(tmp) |= _PAGE_NO_CACHE;
>>>>     if (map->type == _DRM_REGISTERS)
>>>>         pgprot_val(tmp) |= _PAGE_GUARDED;
>>>> #elif defined(__ia64__)
>>>>     if (efi_range_is_wc(vma->vm_start, vma->vm_end -
>>>>                     vma->vm_start))
>>>>         tmp = pgprot_writecombine(tmp);
>>>>     else
>>>>         tmp = pgprot_noncached(tmp);
>>>> #elif defined(__sparc__) || defined(__arm__) || defined(__mips__)
>>>>     tmp = pgprot_noncached(tmp);
>>>> #endif
>>> The idea was to provide an indication as for whether the arch supports
>>> write-combining in general.
>>> If we want to benefit from blue flame operations, we need to map the
>>> blue flame registers as write combining - otherwise there is no
>>> benefit. So we would like to know if write combining is supported by
>>> the system or not.
>>>
>> You completely miss my point.  On a given architectuire it might be
>> _illegal_ to map certain address ranges as write-combining without
>> checks like the ones above that ia64 needs.
>>
>> Therefore your proposed interface is by definition insufficient.
> Thanks Dave, I'll try to clarify my point.
> For me the writecombine_available() is a way to know if the 
> pgprot_writecombine() is effective or just cover call to the 
> pgprot_noncached().
> I want to use the writecombine_available() regardless to the mapping 
> address.
> For example in mlx4 query_device I want to indicate that blue-flame is 
> not supported if  `writecombine_available() == false`.
> In this case we don't have the mapping address yet.
>
> Later on if an arch has write-combining (writecombine_available() ==  
> true) when we try to map the blue-flame registers (in mlx4_ib_mmap):
>
>     vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
>
>     if (io_remap_pfn_range(vma, vma->vm_start,
>         to_mucontext(context)->uar.pfn +
>         dev->dev->caps.num_uars,
>         PAGE_SIZE, vma->vm_page_prot))
>             return -EAGAIN;
>
> I can be sure that pgprot_writecombine() is not a cover for 
> pgprot_noncached().
> The address checks that you mentioned should be part of 
> io_remap_pfn_range, this function should fail if the vma->vm_start is 
> not compatible to the vma->vm_page_prot.
> Please let me know if I misunderstood something.
>
Dave, is this clears my point or I still missing something?
