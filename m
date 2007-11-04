From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Sun, 04 Nov 2007 18:58:47 +0100
Message-ID: <472E0857.4080405@o2.pl>
References: <4729A774.9030409@cosmosbay.com>	<200711040018.15027.ak@suse.de> <20071103.162337.83099185.davem@davemloft.net> <472DAD90.4050709@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ak@suse.de,
	netdev@vger.kernel.org, acme@redhat.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:48934 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752237AbXKDRvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 12:51:25 -0500
In-Reply-To: <472DAD90.4050709@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote, On 11/04/2007 12:31 PM:

> David Miller a =E9crit :
>> From: Andi Kleen <ak@suse.de>
>> Date: Sun, 4 Nov 2007 00:18:14 +0100
>>
>>> On Thursday 01 November 2007 11:16:20 Eric Dumazet wrote:

=2E..

>>> Also the EHASH_LOCK_SZ =3D=3D 0 special case is a little strange. W=
hy did
>>> you add that?
>> He explained this in another reply, because ifdefs are ugly.


But I hope he was only joking, didn't he?

Let's make it clear: ifdefs are in K&R, so they are very nice! Just lik=
e
all C! (K, &, and R as well.)

You know, I can even imagine, there are people, who have K&R around the=
ir
beds, instead of some other book, so they could be serious about such=20
things. (But, don't worry, it's not me - happily I'm not serious!)

This patch looks OK now, but a bit of grumbling shouldn't harm?:

=2E..

> [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
>=20
> As done two years ago on IP route cache table (commit=20
> 22c047ccbc68fa8f3fa57f0e8f906479a062c426) , we can avoid using one lo=
ck per=20
> hash bucket for the huge TCP/DCCP hash tables.
>=20
> On a typical x86_64 platform, this saves about 2MB or 4MB of ram, for=
 litle

- litle
+ little

=2E..=20

> +static inline int inet_ehash_locks_alloc(struct inet_hashinfo *hashi=
nfo)
> +{
> +	unsigned int i, size =3D 256;
> +#if defined(CONFIG_PROVE_LOCKING)
> +	unsigned int nr_pcpus =3D 2;
> +#else
> +	unsigned int nr_pcpus =3D num_possible_cpus();
> +#endif
> +	if (nr_pcpus >=3D 4)
> +		size =3D 512;
> +	if (nr_pcpus >=3D 8)
> +		size =3D 1024;
> +	if (nr_pcpus >=3D 16)
> +		size =3D 2048;
> +	if (nr_pcpus >=3D 32)
> +		size =3D 4096;


It seems, maybe in the future this could look a bit nicer with some log
type shifting.

> +	if (sizeof(rwlock_t) !=3D 0) {
> +#ifdef CONFIG_NUMA
> +		if (size * sizeof(rwlock_t) > PAGE_SIZE)
> +			hashinfo->ehash_locks =3D vmalloc(size * sizeof(rwlock_t));
> +		else
> +#endif
> +		hashinfo->ehash_locks =3D	kmalloc(size * sizeof(rwlock_t),
> +						GFP_KERNEL);
> +		if (!hashinfo->ehash_locks)
> +			return ENOMEM;


Probably doesn't matter now, but maybe more common?:
			return -ENOMEM;

> +		for (i =3D 0; i < size; i++)
> +			rwlock_init(&hashinfo->ehash_locks[i]);


This looks better now, but still is doubtful to me: even if it's safe w=
ith
current rwlock implementation, can't we imagine some new debugging or
statistical code added, which would be called from rwlock_init() withou=
t
using rwlock_t structure? IMHO, if read_lock() etc. are called in such =
a
case, rwlock_init() should be done as well.

Regards,
Jarek P.
