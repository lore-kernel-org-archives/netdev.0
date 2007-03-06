From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 06 Mar 2007 08:58:45 +0100
Message-ID: <45ED1F35.4070600@cosmosbay.com>
References: <20070305.202632.74752497.davem@davemloft.net>	<45ED14E6.7090109@cosmosbay.com> <20070305.232329.95506510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, robert.olsson@its.uu.se, npiggin@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:57569 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933996AbXCFH7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 02:59:00 -0500
In-Reply-To: <20070305.232329.95506510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 06 Mar 2007 08:14:46 +0100
>=20
>> I wonder... are you sure this has no relation with the size of rt_ha=
sh_locks /=20
>> RT_HASH_LOCK_SZ ?
>> One entry must have the same lock in the two tables when resizing is=
 in flight.
>> #define MIN_RTHASH_SHIFT LOG2(RT_HASH_LOCK_SZ)
>=20
> Good point.
>=20
>>> +static struct rt_hash_bucket *rthash_alloc(unsigned int sz)
>>> +{
>>> +	struct rt_hash_bucket *n;
>>> +
>>> +	if (sz <=3D PAGE_SIZE)
>>> +		n =3D kmalloc(sz, GFP_KERNEL);
>>> +	else if (hashdist)
>>> +		n =3D __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
>>> +	else
>>> +		n =3D (struct rt_hash_bucket *)
>>> +			__get_free_pages(GFP_KERNEL, get_order(sz));
>> I dont feel well with this.
>> Maybe we could try a __get_free_pages(), and in case of failure, fal=
lback to=20
>> vmalloc(). Then keep a flag to be able to free memory correctly. Any=
way, if=20
>> (get_order(sz)>=3DMAX_ORDER) we know __get_free_pages() will fail.
>=20
> We have to use vmalloc() for the hashdist case so that the pages
> are spread out properly on NUMA systems.  That's exactly what the
> large system hash allocator is going to do on bootup anyways.

Yes, but on bootup you have an appropriate NUMA active policy. (Well...=
 we=20
hope so, but it broke several time in the past)
I am not sure what kind of mm policy is active for scheduled works.

Anyway I have some XX GB machines, non NUMA, and I would love to be abl=
e to=20
have a 2^20 slots hash table, without having to increase MAX_ORDER.

>=20
> Look, either both are right or both are wrong.  I'm just following
> protocol above and you'll note the PRECISE same logic exists in other
> dynamically growing hash table implementations such as
> net/xfrm/xfrm_hash.c
>=20


Yes, they are both wrong/dumb :)

Can we be smarter, or do we have to stay dumb ? :)

struct rt_hash_bucket *n =3D NULL;

	if (sz <=3D PAGE_SIZE) {
		n =3D kmalloc(sz, GFP_KERNEL);
		*kind =3D allocated_by_kmalloc;
	}
	else if (!hashdist) {
		n =3D (struct rt_hash_bucket *)
			__get_free_pages(GFP_KERNEL, get_order(sz));
		*kind =3D allocated_by_get_free_pages;
	}
	if (!n) {
		n =3D __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
		*kind =3D allocated_by_vmalloc;
	}

