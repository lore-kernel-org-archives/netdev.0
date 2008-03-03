From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [rfc][patch 3/3] use SLAB_ALIGN_SMP
Date: Mon, 03 Mar 2008 14:00:51 +0100
Message-ID: <47CBF683.10201@cosmosbay.com>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093624.GC15091@wotan.suse.de> <47CBCAB0.2040604@cosmosbay.com> <20080303124142.GB13138@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Christoph Lameter <clameter@engr.sgi.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.30]:9508 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740AbYCCNA7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 08:00:59 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2339.orange.fr (SMTP Server) with ESMTP id 6C4B11C0009A
	for <netdev@vger.kernel.org>; Mon,  3 Mar 2008 14:00:57 +0100 (CET)
In-Reply-To: <20080303124142.GB13138@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nick Piggin a =E9crit :
> On Mon, Mar 03, 2008 at 10:53:52AM +0100, Eric Dumazet wrote:
>  =20
>> Nick Piggin a =E9crit :
>>    =20
>>> Use SLAB_SMP_ALIGN in a few places.
>>>
>>> =20
>>>      =20
>> I dont understand why you added SLAB_SMP_ALIGN, without removing=20
>> SLAB_HWCACHE_ALIGN on these places.
>>    =20
>
> Because I thought that in most of the cases, we also want some cachel=
ine
> alignment on UP systems as well because we care about the layout of t=
he
> structure WRT the cachelines for the mandatory/capacity miss cases, a=
s
> well as wanting to avoid false sharing misses on SMP.
>
> Actually I didn't think _too_ hard about them, possibly some could be
> removed. But the problem is that these things do require careful
> thought so I should not change them unless I have done that ;)
>
> I guess there are some basic guidelines -- if size is a problem (ie i=
f
> there can be lots of these structures), then that is going to be a
> factor; if the total pool of objects is likely to be fairly densely
> resident in cache, then it will start to favour dense packing rather
> than good alignment.
>
>  =20
Well, if a kmem_cache_create() is used, this is probably because number=
=20
of objects can be large, so kmalloc() power-of-two granularity could=20
waste lot of ram.

But yes, you are right that SLAB_SMP_ALIGN doesnt imply SLAB_HWCACHE_AL=
IGN

- SMP_ALIGN is a hint about false sharing (when object contains a refcn=
t=20
for example), that is a concern only if

num_possible_cpus() > 1

While HWCACHE_ALIGN might be a hint saying :
- The writer carefully designed the structure so that max performance i=
s=20
obtained when all objects starts on a cache line boundary, even on=20
Uniprocessor.

But I suspect some uses of HWCACHE_ALIGN are not a hint but a strong=20
requirement.

Maybe we need to use three flags to separate the meanings ?


SLAB_HINT_SMP_ALIGN
SLAB_HINT_HWCACHE_ALIGN
SLAB_HWCACHE_ALIGN /* strong requirement that two objects dont share a=20
cache line */





