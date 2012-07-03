From: =?UTF-8?B?QWxleCBWaWxsYWPDrXMgTGFzc28=?= <a_villacis@palosanto.com>
Subject: BISECTED: Re: REGRESSION: 3.4.0->3.5.0-rc2 kernel WARNING on cable
 plug on Acer Aspire One, no network
Date: Mon, 02 Jul 2012 21:33:41 -0500
Message-ID: <4FF25A05.7050007@palosanto.com>
References: <4FD4F28B.4070003@palosanto.com> <20120610195906.GA15641@electric-eye.fr.zoreil.com> <4FD504DA.3000500@palosanto.com> <20120611213815.GA8517@electric-eye.fr.zoreil.com> <4FF05597.3040206@palosanto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([201.234.196.171]:48884 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab2GCCdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 22:33:54 -0400
In-Reply-To: <4FF05597.3040206@palosanto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 01/07/12 08:50, Alex Villac=C3=ADs Lasso escribi=C3=B3:
> El 11/06/12 16:38, Francois Romieu escribi=C3=B3:
>> Alex Villac=C3=ADs Lasso <a_villacis@palosanto.com> :
>> [...]
>>> $ grep XID dmesg-3.5.0-rc2.txt
>>> [   15.873858] r8169 0000:02:00.0: eth0: RTL8102e at 0xf7c0e000,
>>> 00:1e:68:e5:5d:b1, XID 04a00000 IRQ 44
>> The 8102e has not been touched by that many suspect patches but I do
>> not see where the problem is :o(
>>
>> Can you peel off the r8169 patches between 3.4.0 and 3.5-rc ?
>>
> Still present in 3.5-rc5. Bisection still in progress.
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
My full bisection points to this commit:

commit 0a2b9a6ea93650b8a00f9fd5ee8fdd25671e2df6
Author: Marek Szyprowski <m.szyprowski@samsung.com>
Date:   Thu Dec 29 13:09:51 2011 +0100

     X86: integrate CMA with DMA-mapping subsystem

     This patch adds support for CMA to dma-mapping subsystem for x86
     architecture that uses common pci-dma/pci-nommu implementation. Th=
is
     allows to test CMA on KVM/QEMU and a lot of common x86 boxes.

     Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
     Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
     CC: Michal Nazarewicz <mina86@mina86.com>
     Acked-by: Arnd Bergmann <arnd@arndb.de>

Is this commit somehow messing with the network card DMA?

My full bisection log follows:
git bisect start
# good: [76e10d158efb6d4516018846f60c2ab5501900bc] Linux 3.4
git bisect good 76e10d158efb6d4516018846f60c2ab5501900bc
# bad: [cfaf025112d3856637ff34a767ef785ef5cf2ca9] Linux 3.5-rc2
git bisect bad cfaf025112d3856637ff34a767ef785ef5cf2ca9
# good: [3813d4024a75562baf77d3907fb6afbf8f9c8232] Merge tag=20
'ia64-3.5-merge' of git://git.kernel.org/pub/scm/linux/kernel/git/aegl/=
linux
git bisect good 3813d4024a75562baf77d3907fb6afbf8f9c8232
# bad: [5723aa993d83803157c22327e90cd59e3dcbe879] x86: use the new=20
generic strnlen_user() function
git bisect bad 5723aa993d83803157c22327e90cd59e3dcbe879
# good: [654443e20dfc0617231f28a07c96a979ee1a0239] Merge branch=20
'perf-uprobes-for-linus' of=20
git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 654443e20dfc0617231f28a07c96a979ee1a0239
# good: [8c914028f5ddaa417b7d0f4b7fdc24caceaa8043] Merge branch=20
'drm-nouveau-next' of=20
git://anongit.freedesktop.org/git/nouveau/linux-2.6 into drm-core-next
git bisect good 8c914028f5ddaa417b7d0f4b7fdc24caceaa8043
# good: [0708500d49e8439d9fe5529795bdc1485f0f46c3] Merge tag=20
'devicetree-for-linus' of git://git.secretlab.ca/git/linux-2.6
git bisect good 0708500d49e8439d9fe5529795bdc1485f0f46c3
# good: [07acfc2a9349a8ce45b236c2624dad452001966b] Merge branch 'next'=20
of git://git.kernel.org/pub/scm/virt/kvm/kvm
git bisect good 07acfc2a9349a8ce45b236c2624dad452001966b
# good: [58823de9d2f1265030d0d06cb03cc2a551994398] Merge tag=20
'hda-switcheroo' of=20
git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect good 58823de9d2f1265030d0d06cb03cc2a551994398
# bad: [0f51596bd39a5c928307ffcffc9ba07f90f42a8b] Merge branch=20
'for-next-arm-dma' into for-linus
git bisect bad 0f51596bd39a5c928307ffcffc9ba07f90f42a8b
# bad: [0a2b9a6ea93650b8a00f9fd5ee8fdd25671e2df6] X86: integrate CMA=20
with DMA-mapping subsystem
git bisect bad 0a2b9a6ea93650b8a00f9fd5ee8fdd25671e2df6
# good: [6d4a49160de2c684fb59fa627bce80e200224331] mm: page_alloc:=20
change fallbacks array handling
git bisect good 6d4a49160de2c684fb59fa627bce80e200224331
# good: [cfd3da1e49bb95c355c01c0f502d657deb3d34a4] mm: Serialize access=
=20
to min_free_kbytes
git bisect good cfd3da1e49bb95c355c01c0f502d657deb3d34a4
# good: [49f223a9cd96c7293d7258ff88c2bdf83065f69c] mm: trigger page=20
reclaim in alloc_contig_range() to stabilise watermarks
git bisect good 49f223a9cd96c7293d7258ff88c2bdf83065f69c
# good: [c64be2bb1c6eb43c838b2c6d57b074078be208dd] drivers: add=20
Contiguous Memory Allocator
git bisect good c64be2bb1c6eb43c838b2c6d57b074078be208dd
