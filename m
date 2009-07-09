From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
Date: Thu, 09 Jul 2009 22:50:00 +0200
Message-ID: <4A5657F8.5090205@gmail.com>
References: <4A537469.3040207@gmail.com> <EA929A9653AAE14F841771FB1DE5A1365F8ACEBEE9@rrsmsx501.amr.corp.intel.com> <4A53CD39.7080407@gmail.com> <20090707.191424.167842005.davem@davemloft.net> <4A5441A0.3050504@gmail.com> <4A5581C5.5070409@gmail.com> <20090709171328.GB6723@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, emil.s.tantilov@intel.com,
	emils.tantilov@gmail.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	jolsa@redhat.com, Patrick McHardy <kaber@trash.net>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48652 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125AbZGIUuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 16:50:35 -0400
In-Reply-To: <20090709171328.GB6723@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Thu, Jul 09, 2009 at 07:36:05AM +0200, Eric Dumazet wrote:
>> Eric Dumazet a =E9crit :
>>> David Miller a =E9crit :
>>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>>> Date: Wed, 08 Jul 2009 00:33:29 +0200
>>>>
>>>>> [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
>>>>>
>>>>> Some sockets use SLAB_DESTROY_BY_RCU, and our RCU code rely that =
some
>>>>> fields should not be blindly overwritten, even with null.
>>>>>
>>>>> These fields are sk->sk_refcnt and sk->sk_nulls_node.next
>>>>>
>>>>> Current sk_prot_alloc() implementation doesnt respect this hypoth=
esis,
>>>>> calling kmem_cache_alloc() with __GFP_ZERO and setting sk_refcnt =
to 1
>>>>> instead of atomically increment it.
>>>>>
>>>>> Reported-by: Emil S Tantilov <emils.tantilov@gmail.com>
>>>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>>> I've applied this but will wait for some more testing before
>>>> I push it out for real to kernel.org
>>> Thanks David
>>>
>>> I forgot to CC Paul and Patrick, so I'll ask them to look at this p=
atch.
>>>
>>> Patrick, a similar fix is needed in conntrack as well, we currently
>>> uses "ct =3D kmem_cache_zalloc(nf_conntrack_cachep, gfp);" and thus
>>>  overwrite struct hlist_nulls_node hnnode; contained
>>> in "struct nf_conntrack_tuple_hash", while lockless readers still
>>> potentialy need them. Setting hnnode.next to NULL is dangerous
>>> since last bit is not set (not a nulls value), a reader could
>>> try to dereference this NULL pointer and trap.
>>>
>>>
>>> Here is the patch again so that Paul & Patrick can comment on it.
>>>
>>> I am not sure about the refcnt thing (blindly setting it to 0 again
>>> should be OK in fact, since no reader should/can to the=20
>>> atomic_inc_if_not_zero on it), but the nulls.next thing is problema=
tic.
>> Here is an updated and much simpler patch, taking care of sk_node.ne=
xt being not set to 0
>>
>> This patch applies to >=3D 2.6.29 kernels
>=20
> Does this one also need the rearrangement of struct elements in the
> earlier patch?  (And apologies about being slow to get to that one.)
>=20

No, because only one field (sk_node.next) needs special attention, I fe=
lt
it was not really necessary to reorder fields. First memset
is inlined because of constant size, so small cost.

Thanks

> 						Thanx, Paul
>=20
>> [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
>>
>> Some sockets use SLAB_DESTROY_BY_RCU, and our RCU code correctness
>> depends on sk->sk_nulls_node.next being always valid. A NULL
>> value is not allowed as it might fault a lockless reader.
>>
>> Current sk_prot_alloc() implementation doesnt respect this hypothesi=
s,
>> calling kmem_cache_alloc() with __GFP_ZERO. Just call memset() aroun=
d
>> the forbidden field.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index b0ba569..7b87ec0 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -939,8 +939,23 @@ static struct sock *sk_prot_alloc(struct proto =
*prot, gfp_t priority,
>>  	struct kmem_cache *slab;
>>
>>  	slab =3D prot->slab;
>> -	if (slab !=3D NULL)
>> -		sk =3D kmem_cache_alloc(slab, priority);
>> +	if (slab !=3D NULL) {
>> +		sk =3D kmem_cache_alloc(slab, priority & ~__GFP_ZERO);
>> +		if (!sk)
>> +			return sk;
>> +		if (priority & __GFP_ZERO) {
>> +			/*
>> +			 * caches using SLAB_DESTROY_BY_RCU should let
>> +			 * sk_node.next un-modified. Special care is taken
>> +			 * when initializing object to zero.
>> +			 */
>> +			if (offsetof(struct sock, sk_node.next) !=3D 0)
>> +				memset(sk, 0, offsetof(struct sock, sk_node.next));
>> +			memset(&sk->sk_node.pprev, 0,
>> +			       prot->obj_size - offsetof(struct sock,
>> +							 sk_node.pprev));
>> +		}
>> +	}
>>  	else
>>  		sk =3D kmalloc(prot->obj_size, priority);
>>

