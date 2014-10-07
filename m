From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 1/2] pgtable: Add API to query if write
 combining is available
Date: Tue, 07 Oct 2014 15:44:25 -0400 (EDT)
Message-ID: <20141007.154425.2156753440391523455.davem@davemloft.net>
References: <1412497342-12451-1-git-send-email-ogerlitz@mellanox.com>
	<1412497342-12451-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, moshel@mellanox.com, talal@mellanox.com,
	yevgenyp@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755349AbaJGTo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 15:44:28 -0400
In-Reply-To: <1412497342-12451-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  5 Oct 2014 11:22:21 +0300

> From: Moshe Lazer <moshel@mellanox.com>
> 
> Currently the kernel write-combining interface provides a best effort
> mechanism in which the caller simply invokes pgprot_writecombine().
> 
> If write combining is available, the region is mapped for it, otherwise
> the region is (silently) mapped as non-cached.
> 
> In some cases, however, the calling driver must know if write combining
> is available, so a silent best effort mechanism is not sufficient.
> 
> Add writecombine_available(), which returns true if the system
> supports write combining and false if it doesn't.
> 
> Signed-off-by: Moshe Lazer <moshel@mellanox.com>
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

This needs some ACKs from MM developers.

But also the situation is more complicated than a simple boolean test.

On some platforms you have to test first whether the range you are
trying to write combine can legally be marked in that way.  The DRM
layer has all of these per-arch tests to do this properly.

#if defined(__i386__) || defined(__x86_64__)
	if (map->type == _DRM_REGISTERS && !(map->flags & _DRM_WRITE_COMBINING))
		tmp = pgprot_noncached(tmp);
	else
		tmp = pgprot_writecombine(tmp);
#elif defined(__powerpc__)
	pgprot_val(tmp) |= _PAGE_NO_CACHE;
	if (map->type == _DRM_REGISTERS)
		pgprot_val(tmp) |= _PAGE_GUARDED;
#elif defined(__ia64__)
	if (efi_range_is_wc(vma->vm_start, vma->vm_end -
				    vma->vm_start))
		tmp = pgprot_writecombine(tmp);
	else
		tmp = pgprot_noncached(tmp);
#elif defined(__sparc__) || defined(__arm__) || defined(__mips__)
	tmp = pgprot_noncached(tmp);
#endif
