From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 10/13]: net: Implement simple sw TX hashing.
Date: Tue, 15 Jul 2008 08:49:32 +0200
Message-ID: <487C487C.5030403@cosmosbay.com>
References: <4877C76B.6010504@cosmosbay.com>	<E1KIMIg-0007MB-00@gondolin.me.apana.org.au> <20080714.045806.213105998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.orange.fr ([80.12.242.96]:34110 "EHLO smtp27.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbYGOGuJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 02:50:09 -0400
In-Reply-To: <20080714.045806.213105998.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 14 Jul 2008 19:33:02 +0800
>=20
>> Eric Dumazet <dada1@cosmosbay.com> wrote:
>>>> +     return hash % dev->real_num_tx_queues;
>>> simple but expensive... but could be changed to use reciprocal_divi=
de() if necessary...
>> For the common cases it should be a power of 2 too.
>=20
> Unfortunately it is not enforcable for it to be a power of 2
> and I fear it will in fact not be very often for several
> chips that will use this stuff.
>=20
> BTW, how can reciprocal_divide() be used to compute a modulus?  Are
> you going to do the reciprocal divide, re-multiply, then subtract?
> :-)
>=20

reciprocal divide is the name of the following
tranformation of a divide to one multiply.

f1(X) =3D X / N; =20
->g1(X) ((u64)X * R) >> 32;

So you are right I was wrong to name the following=20
transformation a reciprocal divide.

f2(X) =3D X % N ;
->g2(X) =3D ((u64)X * N) >> 32;

But g2() is quite similar to g1() :)

f2() & g2() functions are different of course, but should give=20
same hash spreading if X has an uniform distribution in 32bits space.

simple_tx_hash() in its current form may not have this property, thats =
hard
to say.

=46or example, hash_dst() in net/netfilter/xt_hashlimit.c is using the =
following code :

static u_int32_t
hash_dst(const struct xt_hashlimit_htable *ht, const struct dsthash_dst=
 *dst)
{
        u_int32_t hash =3D jhash2((const u32 *)dst,
                                sizeof(*dst)/sizeof(u32),
                                ht->rnd);
        /*
         * Instead of returning hash % ht->cfg.size (implying a divide)
         * we return the high 32 bits of the (hash * ht->cfg.size) that=
 will
         * give results between [0 and cfg.size-1] and same hash distri=
bution,
         * but using a multiply, less expensive than a divide
         */
        return ((u64)hash * ht->cfg.size) >> 32;
}




