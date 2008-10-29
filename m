From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 13:17:59 -0700
Message-ID: <20081029201759.GF6732@linux.vnet.ibm.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>
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
Received: from e3.ny.us.ibm.com ([32.97.182.143]:52710 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431AbYJ2USB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 16:18:01 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9TKI0BR015951
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 16:18:00 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9TKI0K2131956
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 16:18:00 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9TKHw1N002892
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 16:18:00 -0400
Content-Disposition: inline
In-Reply-To: <4908C0CD.5050406@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 09:00:13PM +0100, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
>> On Wed, Oct 29, 2008 at 01:28:15PM -0500, Corey Minyard wrote:
>>> Eric Dumazet wrote:
>>>> Corey Minyard a =E9crit :
>>>>> Paul E. McKenney wrote:
>>>>>> On Wed, Oct 29, 2008 at 05:09:53PM +0100, Eric Dumazet wrote:
>>>>>> =20
>>>>>>> Corey Minyard a =E9crit :
>>>>>>>  =20
>>>>>>>> Eric Dumazet wrote:
>>>>>>>>    =20
>>>>>>>>> Corey Minyard found a race added in commit=20
>>>>>>>>> 271b72c7fa82c2c7a795bc16896149933110672d
>>>>>>>>> (udp: RCU handling for Unicast packets.)
>>>>>>>>>
>>>>>>>>> "If the socket is moved from one list to another list in-betw=
een=20
>>>>>>>>> the time  the hash is calculated and the next field is access=
ed,=20
>>>>>>>>> and the socket  has moved to the end of the new list, the tra=
versal=20
>>>>>>>>> will not complete  properly on the list it should have, since=
 the=20
>>>>>>>>> socket will be on the end  of the new list and there's not a =
way to=20
>>>>>>>>> tell it's on a new list and  restart the list traversal.  I t=
hink=20
>>>>>>>>> that this can be solved by  pre-fetching the "next" field (wi=
th=20
>>>>>>>>> proper barriers) before checking the  hash."
>>>>>>>>>
>>>>>>>>> This patch corrects this problem, introducing a new=20
>>>>>>>>> sk_for_each_rcu_safenext()
>>>>>>>>> macro.
>>>>>>>>>        =20
>>>>>>>> You also need the appropriate smp_wmb() in udp_lib_get_port() =
after=20
>>>>>>>> sk_hash is set, I think, so the next field is guaranteed to be=
=20
>>>>>>>> changed after the hash value is changed.
>>>>>>>>      =20
>>>>>>> Not sure about this one Corey.
>>>>>>>
>>>>>>> If a reader catches previous value of item->sk_hash, two cases =
are to=20
>>>>>>> be taken into :
>>>>>>>
>>>>>>> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begi=
n :=20
>>>>>>> Reader will redo its scan
>>>>>>>
>>>>>>> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>>>>>>>  -> next pointer is good enough : it points to next item in sam=
e hash=20
>>>>>>> chain.
>>>>>>>     No need to rescan the chain at this point.
>>>>>>>     Yes we could miss the fact that a new port was bound and th=
is UDP=20
>>>>>>> message could be lost.
>>>>>>>    =20
>>>>>> 3) its udp_hashfn(net, sk-sk_hash) is =3D=3D hash, but only beca=
use it was
>>>>>> removed, freed, reallocated, and then readded with the same hash=
=20
>>>>>> value,
>>>>>> possibly carrying the reader to a new position in the same list.
>>>>>>  =20
>>>>> If I understand this, without the smp_wmb(), it is possible that =
the=20
>>>>> next field can be written to main memory before the hash value is=
=20
>>>>> written.  If that happens, the following can occur:
>>>>>
>>>>>  CPU1                    CPU2
>>>>>  next is set to NULL (end of new list)
>>>> Well, if this item is injected to the same chain, next wont be set=
 to=20
>>>> NULL.
>>>>
>>>> That would mean previous writers deleted all items from the chain.
>>> I put my comment in the wrong place, I wasn't talking about being=20
>>> injected into the same chain.
>>>
>>>> In this case, readers can see NULL, it is not a problem at all.
>>>> List is/was empty.
>>>> An application cannot complain a packet is not
>>>> handled if its bind() syscall is not yet completed :)
>>>>
>>>> If item is injected on another chain, we will detect hash mismatch=
 and=20
>>>> redo full scan.
>>> If the item is injected onto the end of another chain, the next fie=
ld=20
>>> will be NULL and you won't detect a hash mismatch.  It's basically =
the=20
>>> same issue as the previous race, though a lot more subtle and unlik=
ely. =20
>>> If you get (from the previous socket) an old value of "sk_hash" and=
 (from=20
>>> the new socket) a new value of "next" that is NULL, you will termin=
ate=20
>>> the loop when you should have restarted it.  I'm pretty sure that c=
an=20
>>> occur without the write barrier.
>> One way of dealing with this is to keep a tail pointer.  Then, if th=
e
>> element containing the NULL pointer doesn't match the tail pointer s=
een
>> at the start of the search, or if the tail pointer has changed,
>> restart the search.  Memory barriers will be needed.  ;-)
>
> Hum... Another way of handling all those cases and avoid memory barri=
ers
> would be to have different "NULL" pointers.
>
> Each hash chain should have a unique "NULL" pointer (in the case of U=
DP, it
> can be the 128 values : [ (void*)0 .. (void *)127 ]
>
> Then, when performing a lookup, a reader should check the "NULL" poin=
ter
> it get at the end of its lookup has is the "hash" value of its chain.
>
> If not -> restart the loop, aka "goto begin;" :)
>
> We could avoid memory barriers then.
>
> In the two cases Corey mentioned, this trick could let us avoid memor=
y=20
> barriers.
> (existing one in sk_add_node_rcu(sk, &hslot->head); should be enough)
>
> What do you think ?

Kinky!!!  ;-)

Then the rcu_dereference() would be supplying the needed memory barrier=
s.

Hmmm...  I guess that the only confusion would be if the element got
removed and then added to the same list.  But then if its pointer was
pseudo-NULL, then that would mean that all subsequent elements had been
removed, and all preceding ones added after the scan started.

Which might well be harmless, but I must defer to you on this one at
the moment.

If you need a larger hash table, another approach would be to set the
pointer's low-order bit, allowing the upper bits to be a full-sized
index -- or even a pointer to the list header.  Just make very sure
to clear the pointer when freeing, or an element on the freelist
could end up looking like a legitimate end of list...  Which again
might well be safe, but why inflict this on oneself?

							Thanx, Paul
