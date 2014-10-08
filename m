From: Moshe Lazer <moshel@dev.mellanox.co.il>
Subject: Re: FW: [PATCH V1 net-next 1/2] pgtable: Add API to query if write
 combining is available
Date: Wed, 08 Oct 2014 11:44:57 +0300
Message-ID: <5434F989.2040101@dev.mellanox.co.il>
References: <1412497342-12451-1-git-send-email-ogerlitz@mellanox.com>	<1412497342-12451-2-git-send-email-ogerlitz@mellanox.com> <20141007.154425.2156753440391523455.davem@davemloft.net> <925ad10b2ec44e228e69bf0cbe6c0a0e@AMSPR05MB002.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:42080 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbaJHIpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 04:45:05 -0400
Received: by mail-wg0-f45.google.com with SMTP id m15so10973722wgh.4
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 01:45:02 -0700 (PDT)
In-Reply-To: <925ad10b2ec44e228e69bf0cbe6c0a0e@AMSPR05MB002.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, October 07, 2014 10:44 PM
> To: Or Gerlitz
> Cc: netdev@vger.kernel.org; Amir Vadai; jackm@dev.mellanox.co.il; Moshe Lazer; Tal Alon; Yevgeny Petrilin
> Subject: Re: [PATCH V1 net-next 1/2] pgtable: Add API to query if write combining is available
>
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Sun,  5 Oct 2014 11:22:21 +0300
>
>> From: Moshe Lazer <moshel@mellanox.com>
>>
>> Currently the kernel write-combining interface provides a best effort
>> mechanism in which the caller simply invokes pgprot_writecombine().
>>
>> If write combining is available, the region is mapped for it,
>> otherwise the region is (silently) mapped as non-cached.
>>
>> In some cases, however, the calling driver must know if write
>> combining is available, so a silent best effort mechanism is not sufficient.
>>
>> Add writecombine_available(), which returns true if the system
>> supports write combining and false if it doesn't.
>>
>> Signed-off-by: Moshe Lazer <moshel@mellanox.com>
>> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> This needs some ACKs from MM developers.
>
> But also the situation is more complicated than a simple boolean test.
>
> On some platforms you have to test first whether the range you are trying to write combine can legally be marked in that way.  The DRM layer has all of these per-arch tests to do this properly.
>
> #if defined(__i386__) || defined(__x86_64__)
> 	if (map->type == _DRM_REGISTERS && !(map->flags & _DRM_WRITE_COMBINING))
> 		tmp = pgprot_noncached(tmp);
> 	else
> 		tmp = pgprot_writecombine(tmp);
> #elif defined(__powerpc__)
> 	pgprot_val(tmp) |= _PAGE_NO_CACHE;
> 	if (map->type == _DRM_REGISTERS)
> 		pgprot_val(tmp) |= _PAGE_GUARDED;
> #elif defined(__ia64__)
> 	if (efi_range_is_wc(vma->vm_start, vma->vm_end -
> 				    vma->vm_start))
> 		tmp = pgprot_writecombine(tmp);
> 	else
> 		tmp = pgprot_noncached(tmp);
> #elif defined(__sparc__) || defined(__arm__) || defined(__mips__)
> 	tmp = pgprot_noncached(tmp);
> #endif
The idea was to provide an indication as for whether the arch supports 
write-combining in general.
If we want to benefit from blue flame operations, we need to map the 
blue flame registers as write combining - otherwise there is no benefit. 
So we would like to know if write combining is supported by the system 
or not.
