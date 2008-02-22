From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
Date: Fri, 22 Feb 2008 11:19:22 +0100
Message-ID: <47BEA1AA.3000500@fr.ibm.com>
References: <47BDC848.50607@cosmosbay.com> <47BDDBB5.1050603@fr.ibm.com> <47BE06F7.5080305@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:14747 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbYBVK2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 05:28:43 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m1MASg7W054248
	for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 10:28:42 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1MASgL51339462
	for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 10:28:42 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1MASf8J012076
	for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 10:28:42 GMT
In-Reply-To: <47BE06F7.5080305@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Daniel Lezcano a =E9crit :
>> Eric Dumazet wrote:
>>> Hi David
>>>
>>> This is an RFC, based on net-2.6 for convenience only.
>>>
>>> Thank you
>>>
>>> [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx=
()
>>>
>>> Loopback transmit function loopback_xmit() actually calls netif_rx(=
)=20
>>> to queue
>>> a skb to the softnet queue, and arms a softirq so that this skb can=
=20
>>> be handled later.
>>>
>>> This has a cost on SMP, because we need to hold a reference on the=20
>>> device, and free this
>>> reference when softirq dequeues packet.
>>>
>>> Following patch directly calls netif_receive_skb() and avoids lot o=
f=20
>>> atomic operations.
>>> (atomic_inc(&dev->refcnt), set_and_set_bit(NAPI_STATE_SCHED,=20
>>> &n->state), ...
>>>  atomic_dec(&dev->refcnt)...), cache line ping-pongs on device=20
>>> refcnt, but also softirq overhead.
>>>
>>> This gives a nice boost on tbench for example (5 % on my machine)
>>
>> I understand this is interesting for the loopback when there is no=20
>> multiple instances of it and it can't be unregistered. But now with=20
>> the network namespaces, we can have multiple instances of the loopba=
ck=20
>> and it can to be unregistered. Shouldn't we still use netif_rx ?
>> Perhaps we can do something like:
>>
>>     if (dev->nd_net =3D=3D &init_net)
>>         netif_receive_skb(skb);
>>     else
>>         netif_rx(skb);
>=20
> or
>=20
> #ifdef CONFIG_NET_NS
>     if (dev->nd_net !=3D &init_net)
>         netif_rx(skb);
>     else
> #endif
>         netif_receive_skb(skb);
>=20
>>
>> Or we create:
>>     init_loopback_xmit() calling netif_receive_skb(skb);
>>     and setup this function when creating the loopback for init_net,
>>     otherwise we setup the usual loopback_xmit.
>>
>> We are still safe for multiple network namespaces and we have the=20
>> improvement for init_net loopback.
>>
>=20
> I dont understand how my patch could degrade loopbackdev unregister=20
> logic. It should only help it, by avoiding a queue of 'pending packet=
s'=20
> per cpu.
>=20
> When we want to unregister a network device, stack makes sure that no=
=20
> more calls to dev->hard_start_xmit() can occur.
>=20
> If no more loopback_xmit() calls are done on this device, it doesnt=20
> matter if it internally uses netif_rx() or netif_receive_skb(skb)
>=20
> loopback device has no queue, its really unfortunate to use the=20
> 'softirq' internal queue.

=46air enough :)

