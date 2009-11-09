From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/8] udp: add a counter into udp_hslot
Date: Mon, 09 Nov 2009 12:42:56 +0100
Message-ID: <4AF80040.6060501@gmail.com>
References: <4AF72741.5070405@gmail.com> <87fx8o56eq.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49988 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbZKILnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 06:43:01 -0500
In-Reply-To: <87fx8o56eq.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>> =20
>> +/**
>> + *	struct udp_hslot - UDP hash slot
>> + *
>> + *	@head:	head of list of sockets
>> + *	@count:	number of sockets in 'head' list
>> + *	@lock:	spinlock protecting changes to head/count
>> + */
>>  struct udp_hslot {
>>  	struct hlist_nulls_head	head;
>> +	int			count;
>=20
> Do you really need an int? On 64bit it's free due to the alignment,=20
> but on 32bit x86 it's costly and you blow up the table considerably,
> increasing cache misses.

Even a short (16 bits) might be too small for IXIACOM :)

On 32bit x86, size of hash table is 512 slots max.
(one slot per 2MB of LOWMEM, rounded to power of two)

You are speaking of <=3D 4096 bytes overhead :)

> =20
> Again it would be nicer if that was a separate smaller table together
> with the spinlock.

Nice for space, not nice for fast path, because this means additional
cache miss to get the spinlock (multicast rx still needs to take spinlo=
ck),
and some guys want really fast (low latency) multicast rx.

>=20
> In theory could also put a short counter into the low level alignment
> bits of the pointer and perhaps convert the spinlock to a bitlock?
> Then all could collapse into a single pointer.
>=20

Not enough bits in low level alignment unfortunatly. We only could give=
 a
hint (one bit is enough) of possibly long chain, but not allowing preci=
se=20
choice of shortest chain.

Once multicast is converted to RCU, then we wont need one spinlock per =
slot
(it wont be used in fast path, only at bind()/close() time)
and yes, we can use a separate small array to contain hashed spinlocks,
or even a single spinlock for CONFIG_BASE_SMALL :)



