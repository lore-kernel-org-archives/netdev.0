From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Thu, 19 Oct 2006 08:34:53 +0200
Message-ID: <45371C8D.20603@cosmosbay.com>
References: <200610171458.37636.dada1@cosmosbay.com>
 <20061018.203109.63997999.davem@davemloft.net>
 <4537095A.9010705@cosmosbay.com> <20061018.231218.74744257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604001mt.neufgp.fr ([84.96.92.60]:54932 "EHLO Smtp.neuf.fr")
	by vger.kernel.org with ESMTP id S1161337AbWJSGey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 02:34:54 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604001mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7D003NIEA4S4V0@sp604001mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Thu, 19 Oct 2006 08:34:52 +0200 (CEST)
In-reply-to: <20061018.231218.74744257.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 19 Oct 2006 07:12:58 +0200
>=20
>> A 66 MHz 486 can perform 1.000.000 divisions per second. Is it a 'sl=
ow' cpu ?
>=20
> Sparc and some other embedded chips have no division/modulus integer
> instruction and do it in software.

How many times this division will be done ? As I said, tcp session esta=
blishment.

Are you aware a division is done in slab code when you kfree() one netw=
ork=20
frames ? That is much more problematic than SYN packets.

>=20
>> So... what do you prefer :
>>
>> 1) Keep the modulus
>> 2) allocate two blocks of ram (powser-of -two hash size, but one ext=
ra=20
>> indirection)
>> 3) waste near half of ram because one block allocated, and power-of-=
two hash size.
>=20
> I thought the problem was that you use a modulus and non-power-of-2
> hash table size because rounding up to the next power of 2 wastes
> a lot of space?  Given that, my suggestion is simply to not round
> up to the next power-of-2, or only do so when we are very very close
> to that next power-of-2.

My main problem is being able to use a large hash table on big servers.

With power-of two constraint, plus kmalloc max size constraint, we can =
use=20
half the size we could.

Are you suggesting something like :

Allocation time:
----------------
if (cpu is very_very_slow or hash size small_enough) {
   ptr->size =3D power_of_too;
   ptr->size_mask =3D (power_of_two - 1);
} else {
   ptr->size =3D somevalue;
   ptr->size_mask =3D ~0;
}

Lookup time :
---------------
if (ptr->size_mask !=3D ~0)
     slot =3D hash & ptr->size_mask;
else
     slot =3D hash % ptr->size;

The extra conditional branch may be more expensive than just doing divi=
sion on=20
99% of cpus...

