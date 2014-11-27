From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH V1 net-next 1/2] pgtable: Add API to query if write
 combining is available
Date: Thu, 27 Nov 2014 08:48:24 +0200
Message-ID: <CAJ3xEMgufPhyeKHC_wWhw+khEhMAgG6yKuN8TLH0-xXH5Fq8Bw@mail.gmail.com>
References: <20141007.154425.2156753440391523455.davem@davemloft.net>
	<925ad10b2ec44e228e69bf0cbe6c0a0e@AMSPR05MB002.eurprd05.prod.outlook.com>
	<5434F989.2040101@dev.mellanox.co.il>
	<20141008.122450.1919301744382855426.davem@davemloft.net>
	<543A4FE4.7010807@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>, moshel@mellanox.com
To: Moshe Lazer <moshel@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:35704 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbaK0GsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 01:48:24 -0500
Received: by mail-oi0-f42.google.com with SMTP id v63so3121330oia.1
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 22:48:24 -0800 (PST)
In-Reply-To: <543A4FE4.7010807@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 12, 2014 at 11:54 AM, Moshe Lazer <moshel@dev.mellanox.co.il> wrote:
>
> On 10/8/2014 7:24 PM, David Miller wrote:
>>
>> From: Moshe Lazer <moshel@dev.mellanox.co.il>
>> Date: Wed, 08 Oct 2014 11:44:57 +0300
>>
>>>> #if defined(__i386__) || defined(__x86_64__)
>>>>         if (map->type == _DRM_REGISTERS && !(map->flags &
>>>> _DRM_WRITE_COMBINING))
>>>>                 tmp = pgprot_noncached(tmp);
>>>>         else
>>>>                 tmp = pgprot_writecombine(tmp);
>>>> #elif defined(__powerpc__)
>>>>         pgprot_val(tmp) |= _PAGE_NO_CACHE;
>>>>         if (map->type == _DRM_REGISTERS)
>>>>                 pgprot_val(tmp) |= _PAGE_GUARDED;
>>>> #elif defined(__ia64__)
>>>>         if (efi_range_is_wc(vma->vm_start, vma->vm_end -
>>>>                                     vma->vm_start))
>>>>                 tmp = pgprot_writecombine(tmp);
>>>>         else
>>>>                 tmp = pgprot_noncached(tmp);
>>>> #elif defined(__sparc__) || defined(__arm__) || defined(__mips__)
>>>>         tmp = pgprot_noncached(tmp);
>>>> #endif
>>>
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
>
> Thanks David, I'll try to clarify my point.
> For me the writecombine_available() is a way to know if the
> pgprot_writecombine() is effective or just cover call to the
> pgprot_noncached().
> I want to use the writecombine_available() regardless to the mapping
> address.
> For example in mlx4 query_device I want to indicate that blue-flame is not
> supported if  `writecombine_available() ==  false`.
> In this case we don't have the mapping address yet.
>
> Later on if an arch has write-combining (writecombine_available() ==  true)
> when we try to map the blue-flame registers (in mlx4_ib_mmap):
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
> The address checks that you mentioned should be part of io_remap_pfn_range,
> this function should fail if the vma->vm_start is not compatible to the
> vma->vm_page_prot.
> Please let me know if I misunderstood something.


Hi Dave,

Pinging you... could you respond on Moshe's email which hopefully
addresses your comments?

Or.
