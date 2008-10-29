From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 11:11:14 -0700
Message-ID: <20081029181114.GC6732@linux.vnet.ibm.com>
References: <490795FB.2000201@cosmosbay.com> <20081028.220536.183082966.davem@davemloft.net> <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com> <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089E2D.8030907@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:50866 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475AbYJ2SLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 14:11:17 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9TI7nec018396
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 14:07:49 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9TIBGYe125794
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 14:11:16 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9TIBEuT024465
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 14:11:16 -0400
Content-Disposition: inline
In-Reply-To: <49089E2D.8030907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 06:32:29PM +0100, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
>> On Wed, Oct 29, 2008 at 05:09:53PM +0100, Eric Dumazet wrote:
>>> Corey Minyard a =E9crit :
>>>> Eric Dumazet wrote:
>>>>> Corey Minyard found a race added in commit=20
>>>>> 271b72c7fa82c2c7a795bc16896149933110672d
>>>>> (udp: RCU handling for Unicast packets.)
>>>>>
>>>>> "If the socket is moved from one list to another list in-between =
the=20
>>>>> time  the hash is calculated and the next field is accessed, and =
the=20
>>>>> socket  has moved to the end of the new list, the traversal will =
not=20
>>>>> complete  properly on the list it should have, since the socket w=
ill be=20
>>>>> on the end  of the new list and there's not a way to tell it's on=
 a new=20
>>>>> list and  restart the list traversal.  I think that this can be s=
olved=20
>>>>> by  pre-fetching the "next" field (with proper barriers) before=20
>>>>> checking the  hash."
>>>>>
>>>>> This patch corrects this problem, introducing a new=20
>>>>> sk_for_each_rcu_safenext()
>>>>> macro.
>>>> You also need the appropriate smp_wmb() in udp_lib_get_port() afte=
r=20
>>>> sk_hash is set, I think, so the next field is guaranteed to be cha=
nged=20
>>>> after the hash value is changed.
>>> Not sure about this one Corey.
>>>
>>> If a reader catches previous value of item->sk_hash, two cases are =
to be=20
>>> taken into :
>>>
>>> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begin : =
Reader=20
>>> will redo its scan
>>>
>>> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>>>  -> next pointer is good enough : it points to next item in same ha=
sh=20
>>> chain.
>>>     No need to rescan the chain at this point.
>>>     Yes we could miss the fact that a new port was bound and this U=
DP=20
>>> message could be lost.
>> 3) its udp_hashfn(net, sk-sk_hash) is =3D=3D hash, but only because =
it was
>> removed, freed, reallocated, and then readded with the same hash val=
ue,
>> possibly carrying the reader to a new position in the same list.
>
> yes, but 'new position' is 'before any not yet examined objects', sin=
ce
> we insert objects only at chain head.

OK.  However, this reasoning assumes that a socket with a given
udp_hashfn() value will appear on one and only one list.  There are no
side lists for sockets in other states?  (listen, &c)

>> You might well cover this (will examine your code in detail on my pl=
ane
>> flight starting about 20 hours from now), but thought I should point=
 it
>> out.  ;-)
>
> Yes, I'll double check too, this seems tricky :)

;-)

> About SLAB_DESTROY_BY_RCU effect, we now have two different kmem_cach=
e for=20
> "UDP-Lite"
> and "UDP".
>
> This is expected, but we could avoid that and alias these caches, sin=
ce
> these objects have the same *type* . (The fields used for the RCU loo=
kups,
> deletes and inserts are the same)
>
> Maybe a hack in net/ipv4/udplite.c before calling proto_register(), t=
o
> copy the kmem_cache from UDP.

As long as this preserves the aforementioned assumption that a socket
with a given hash can appear on one and only one list.  ;-)

							Thanx, Paul
