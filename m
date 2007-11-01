From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Thu, 01 Nov 2007 19:00:13 +0100
Message-ID: <472A142D.4040305@cosmosbay.com>
References: <4729A774.9030409@cosmosbay.com> <4729F96B.8000802@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <ak@suse.de>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39311 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbXKASAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 14:00:43 -0400
In-Reply-To: <4729F96B.8000802@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski a =E9crit :
> Hi,
>=20
> A few doubts below:=20
>=20
>> =20
>> +#if defined(CONFIG_SMP) || defined(CONFIG_PROVE_LOCKING)
>=20
> Probably "|| defined(CONFIG_DEBUG_SPINLOCK)" is needed here.

Not sure, because DEBUG_SPINLOCK only applies to spinlocks.
Here we deal with rwlocks.

>=20
>> +/*
>> + * Instead of using one rwlock for each inet_ehash_bucket, we use a=
 table of locks
>> + * The size of this table is a power of two and depends on the numb=
er of CPUS.
>> + */
>> +# if defined(CONFIG_DEBUG_LOCK_ALLOC)
>> +#  define EHASH_LOCK_SZ 256
>> +# elif NR_CPUS >=3D 32
>> +#  define EHASH_LOCK_SZ	4096
>> +# elif NR_CPUS >=3D 16
>> +#  define EHASH_LOCK_SZ	2048
>> +# elif NR_CPUS >=3D 8
>> +#  define EHASH_LOCK_SZ	1024
>> +# elif NR_CPUS >=3D 4
>> +#  define EHASH_LOCK_SZ	512
>> +# else
>> +#  define EHASH_LOCK_SZ	256
>> +# endif
>> +#else
>> +# define EHASH_LOCK_SZ 0
>> +#endif
>> +
>=20
> Looks hackish: usually DEBUG code checks "real" environment, and here=
 it's
> a special case. But omitting locks if no SMP or DEBUG is strange. IMH=
O,
> there should be 1 instead of 0.

It is 0 so that no alloc is done. (see your next questions)


>=20
>>  struct inet_hashinfo {
>>  	/* This is for sockets with full identity only.  Sockets here will
>>  	 * always be without wildcards and will have the following invaria=
nt:
>> @@ -100,6 +121,7 @@ struct inet_hashinfo {
>>  	 * TIME_WAIT sockets use a separate chain (twchain).
>>  	 */
>>  	struct inet_ehash_bucket	*ehash;
>> +	rwlock_t			*ehash_locks;
>> =20
>>  	/* Ok, let's try this, I give up, we do need a local binding
>>  	 * TCP hash as well as the others for fast bind/connect.
>> @@ -134,6 +156,13 @@ static inline struct inet_ehash_bucket *inet_eh=
ash_bucket(
>>  	return &hashinfo->ehash[hash & (hashinfo->ehash_size - 1)];
>>  }
>> =20
>> +static inline rwlock_t *inet_ehash_lockp(
>> +	struct inet_hashinfo *hashinfo,
>> +	unsigned int hash)
>> +{
>> +	return &hashinfo->ehash_locks[hash & (EHASH_LOCK_SZ - 1)];
>> +}
>> +
>=20
> Is it OK for EHASH_LOCK_SZ =3D=3D 0?

At least, compiled tested and booted on UP ;)

>=20
> ...
>> diff --git a/net/dccp/proto.c b/net/dccp/proto.c
>> index d849739..3b5f97a 100644
>> --- a/net/dccp/proto.c
>> +++ b/net/dccp/proto.c
>> @@ -1072,11 +1072,18 @@ static int __init dccp_init(void)
>>  	}
>> =20
>>  	for (i =3D 0; i < dccp_hashinfo.ehash_size; i++) {
>> -		rwlock_init(&dccp_hashinfo.ehash[i].lock);
>>  		INIT_HLIST_HEAD(&dccp_hashinfo.ehash[i].chain);
>>  		INIT_HLIST_HEAD(&dccp_hashinfo.ehash[i].twchain);
>>  	}
>> -
>> +	if (EHASH_LOCK_SZ) {
>=20
> Why not #ifdef then? But, IMHO, rwlock_init() should be done at least
> once here. (Similarly later for tcp.)

well, #ifdef are not so nice :)

>=20
>> +		dccp_hashinfo.ehash_locks =3D
>> +			kmalloc(EHASH_LOCK_SZ * sizeof(rwlock_t),
>> +				GFP_KERNEL);
>> +		if (!dccp_hashinfo.ehash_locks)
>> +			goto out_free_dccp_ehash;
>> +		for (i =3D 0; i < EHASH_LOCK_SZ; i++)
>> +			rwlock_init(&dccp_hashinfo.ehash_locks[i]);
>> +	}
>>  	bhash_order =3D ehash_order;
>> =20
>>  	do {
>> @@ -1091,7 +1098,7 @@ static int __init dccp_init(void)
>> =20
>>  	if (!dccp_hashinfo.bhash) {
>>  		DCCP_CRIT("Failed to allocate DCCP bind hash table");
>> -		goto out_free_dccp_ehash;
>> +		goto out_free_dccp_locks;
>>  	}
>> =20
>>  	for (i =3D 0; i < dccp_hashinfo.bhash_size; i++) {
>> @@ -1121,6 +1128,9 @@ out_free_dccp_mib:
>>  out_free_dccp_bhash:
>>  	free_pages((unsigned long)dccp_hashinfo.bhash, bhash_order);
>>  	dccp_hashinfo.bhash =3D NULL;
>> +out_free_dccp_locks:
>> +	kfree(dccp_hashinfo.ehash_locks);
>> +	dccp_hashinfo.ehash_locks =3D NULL;
>>  out_free_dccp_ehash:
>>  	free_pages((unsigned long)dccp_hashinfo.ehash, ehash_order);
>>  	dccp_hashinfo.ehash =3D NULL;
>=20
> Isn't such kfree(dccp_hashinfo.ehash_locks) needed in dccp_fini()?
>=20

Probably ! Thank you for reviewing !

Eric
