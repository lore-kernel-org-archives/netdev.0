From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 4/4] udp: memory accounting in IPv4
Date: Sat, 01 Dec 2007 14:08:31 +0100
Message-ID: <47515CCF.3030009@cosmosbay.com>
References: <474DB80E.5070403@redhat.com> <474DB930.5080409@redhat.com> <20071201122120.GB14368@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hideo AOKI <haoki@redhat.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:36696 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbXLANMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 08:12:46 -0500
In-Reply-To: <20071201122120.GB14368@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> On Wed, Nov 28, 2007 at 01:53:36PM -0500, Hideo AOKI wrote:
>> +/**
>> + *	__skb_queue_purge_and_sub_memory_allocated
>> + *		- empty a list and subtruct memory allocation counter
>> + *	@sk:   sk
>> + *	@list: list to empty
>> + *	Delete all buffers on an &sk_buff list and subtruct the
>> + *	truesize of the sk_buff for memory accounting. Each buffer
>> + *	is removed from the list and one reference dropped. This
>> + *	function does not take the list lock and the caller must
>> + *	hold the relevant locks to use it.
>> + */
>> +static inline void __skb_queue_purge_and_sub_memory_allocated(struc=
t sock *sk,
>> +					struct sk_buff_head *list)
>> +{
>> +	struct sk_buff *skb;
>> +	int purged_skb_size =3D 0;
>> +	while ((skb =3D __skb_dequeue(list)) !=3D NULL) {
>> +		purged_skb_size +=3D sk_datagram_pages(skb->truesize);
>> +		kfree_skb(skb);
>> +	}
>> +	atomic_sub(purged_skb_size, sk->sk_prot->memory_allocated);
>> +}
>=20
> Thanks, this is a lot better than before!
>=20
> However, I'm still a little concerned about the effect of two more
> atomic op's per packet that we're adding here.  Hang on a sec, that
> should've been Dave's line since atomic ops are cheap on x86 :)
>=20
> But seriously, it's not so much that we have two more atomic op's
> per packet, but we have two more writes to a single global counter
> for each packet.  This is going to really suck on SMP.
>=20
> So what I'd like to see is a scheme that's similar to sk_forward_allo=
c.
> The idea is that each socket allocates memory using mem_schedule and
> then stores it in sk_forward_alloc.  Each packet then only has to
> add to/subtract from sk_forward_alloc.
>=20
> There is one big problem with this though, UDP is not serialised like
> TCP.  So you can't just use sk_forward_alloc since it's not an atomic=
_t.
>=20
> We'll need to think about this one a bit more.

I agree adding yet another atomics ops is a big problem.

Another idea, coupled with recent work on percpu storage done by Christ=
oph=20
Lameter, would be to use kind of a percpu_counter :

We dont really need strong and precise memory accounting (UDP , but TCP=
 as=20
well), just some kind of limit to avoid memory to be too much used.

That is, updating a percpu variable, and doing some updates to a global=
=20
counter only when this percpu variable escapes from a given range.

Lot of contended cache lines could benefit from this relaxing (count of=
=20
sockets...)

I would wait first that Christoph work is done, so that we dont need at=
omic=20
ops on local cpu storage (and no need to disable preemption too).

