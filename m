From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
Date: Fri, 22 Feb 2008 00:19:19 +0100
Message-ID: <47BE06F7.5080305@cosmosbay.com>
References: <47BDC848.50607@cosmosbay.com> <47BDDBB5.1050603@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:48469
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755925AbYBUXTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 18:19:32 -0500
In-Reply-To: <47BDDBB5.1050603@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano a =E9crit :
> Eric Dumazet wrote:
>> Hi David
>>
>> This is an RFC, based on net-2.6 for convenience only.
>>
>> Thank you
>>
>> [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx(=
)
>>
>> Loopback transmit function loopback_xmit() actually calls netif_rx()=
=20
>> to queue
>> a skb to the softnet queue, and arms a softirq so that this skb can =
be=20
>> handled later.
>>
>> This has a cost on SMP, because we need to hold a reference on the=20
>> device, and free this
>> reference when softirq dequeues packet.
>>
>> Following patch directly calls netif_receive_skb() and avoids lot of=
=20
>> atomic operations.
>> (atomic_inc(&dev->refcnt), set_and_set_bit(NAPI_STATE_SCHED,=20
>> &n->state), ...
>>  atomic_dec(&dev->refcnt)...), cache line ping-pongs on device refcn=
t,=20
>> but also softirq overhead.
>>
>> This gives a nice boost on tbench for example (5 % on my machine)
>=20
> I understand this is interesting for the loopback when there is no=20
> multiple instances of it and it can't be unregistered. But now with t=
he=20
> network namespaces, we can have multiple instances of the loopback an=
d=20
> it can to be unregistered. Shouldn't we still use netif_rx ?
> Perhaps we can do something like:
>=20
>     if (dev->nd_net =3D=3D &init_net)
>         netif_receive_skb(skb);
>     else
>         netif_rx(skb);

or

#ifdef CONFIG_NET_NS
	if (dev->nd_net !=3D &init_net)
		netif_rx(skb);
	else
#endif
		netif_receive_skb(skb);

>=20
> Or we create:
>     init_loopback_xmit() calling netif_receive_skb(skb);
>     and setup this function when creating the loopback for init_net,
>     otherwise we setup the usual loopback_xmit.
>=20
> We are still safe for multiple network namespaces and we have the=20
> improvement for init_net loopback.
>=20

I dont understand how my patch could degrade loopbackdev unregister log=
ic. It=20
should only help it, by avoiding a queue of 'pending packets' per cpu.

When we want to unregister a network device, stack makes sure that no m=
ore=20
calls to dev->hard_start_xmit() can occur.

If no more loopback_xmit() calls are done on this device, it doesnt mat=
ter if=20
it internally uses netif_rx() or netif_receive_skb(skb)

loopback device has no queue, its really unfortunate to use the 'softir=
q'=20
internal queue.
