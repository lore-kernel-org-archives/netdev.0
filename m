From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Mon, 03 Mar 2008 08:48:30 +0100
Message-ID: <47CBAD4E.7080901@cosmosbay.com>
References: <47BDBC23.10605@cosmosbay.com> <200802232023.52352.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0802271140470.1790@schroedinger.engr.sgi.com> <200803031414.43076.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <clameter@sgi.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:33678
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751267AbYCCHsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 02:48:51 -0500
In-Reply-To: <200803031414.43076.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nick Piggin a =E9crit :
> On Thursday 28 February 2008 06:44, Christoph Lameter wrote:
>> On Sat, 23 Feb 2008, Nick Piggin wrote:
>>> What I don't understand is why the slab allocators have something l=
ike
>>> this in it:
>>>
>>>         if ((flags & SLAB_HWCACHE_ALIGN) &&
>>>                         size > cache_line_size() / 2)
>>>                 return max_t(unsigned long, align, cache_line_size(=
));
>>>
>>> If you ask for HWCACHE_ALIGN, then you should get it. I don't
>>> understand, why do they think they knows better than the caller?
>> Tradition.... Its irks me as well.
>>
>>> Things like this are just going to lead to very difficult to track
>>> performance problems. Possibly correctness problems in rare cases.
>>>
>>> There could be another flag for "maybe align".
>> SLAB_HWCACHE_ALIGN *is* effectively a maybe align flag given the abo=
ve
>> code.
>>
>> If we all agree then we could change this to have must have semantic=
s? It
>> has the potential of enlarging objects for small caches.
>>
>> SLAB_HWCACHE_ALIGN has an effect that varies according to the alignm=
ent
>> requirements of the architecture that the kernel is build on. We may=
 be in
>> for some surprises if we change this.
>=20
> I think so. If we ask for HWCACHE_ALIGN, it must be for a good reason=
=2E
> If some structures get too bloated for no good reason, then the probl=
em
> is not with the slab allocator but with the caller asking for
> HWCACHE_ALIGN.
>=20

HWCACHE_ALIGN is commonly used, even for large structures, because the=20
processor cache line on x86 is not known at compile time (can go from 3=
2 bytes=20
to 128 bytes).

The problem that above code is trying to address is about small objects=
=2E

Because at the time code using HWCACHE_ALIGN was written, cache line si=
ze was=20
32 bytes. Now we have CPU with 128 bytes cache lines, we would waste sp=
ace if=20
SLAB_HWCACHE_ALIGN was honored for small objects.

Some occurences of SLAB_HWCACHE_ALIGN are certainly not usefull, we sho=
uld zap=20
them. Last one I removed was the one for "struct flow_cache_entry"  (co=
mmit=20
dd5a1843d566911dbb077c4022c4936697495af6 : [IPSEC] flow: reorder "struc=
t=20
flow_cache_entry" and remove SLAB_HWCACHE_ALIGN)

