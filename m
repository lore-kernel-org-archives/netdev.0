From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 21:00:13 +0100
Message-ID: <4908C0CD.5050406@cosmosbay.com>
References: <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com> <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:49261 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbYJ2UBH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 16:01:07 -0400
In-Reply-To: <20081029185200.GE6732@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Wed, Oct 29, 2008 at 01:28:15PM -0500, Corey Minyard wrote:
>> Eric Dumazet wrote:
>>> Corey Minyard a =E9crit :
>>>> Paul E. McKenney wrote:
>>>>> On Wed, Oct 29, 2008 at 05:09:53PM +0100, Eric Dumazet wrote:
>>>>> =20
>>>>>> Corey Minyard a =E9crit :
>>>>>>  =20
>>>>>>> Eric Dumazet wrote:
>>>>>>>    =20
>>>>>>>> Corey Minyard found a race added in commit=20
>>>>>>>> 271b72c7fa82c2c7a795bc16896149933110672d
>>>>>>>> (udp: RCU handling for Unicast packets.)
>>>>>>>>
>>>>>>>> "If the socket is moved from one list to another list in-betwe=
en the=20
>>>>>>>> time  the hash is calculated and the next field is accessed, a=
nd the=20
>>>>>>>> socket  has moved to the end of the new list, the traversal wi=
ll not=20
>>>>>>>> complete  properly on the list it should have, since the socke=
t will=20
>>>>>>>> be on the end  of the new list and there's not a way to tell i=
t's on=20
>>>>>>>> a new list and  restart the list traversal.  I think that this=
 can be=20
>>>>>>>> solved by  pre-fetching the "next" field (with proper barriers=
)=20
>>>>>>>> before checking the  hash."
>>>>>>>>
>>>>>>>> This patch corrects this problem, introducing a new=20
>>>>>>>> sk_for_each_rcu_safenext()
>>>>>>>> macro.
>>>>>>>>        =20
>>>>>>> You also need the appropriate smp_wmb() in udp_lib_get_port() a=
fter=20
>>>>>>> sk_hash is set, I think, so the next field is guaranteed to be =
changed=20
>>>>>>> after the hash value is changed.
>>>>>>>      =20
>>>>>> Not sure about this one Corey.
>>>>>>
>>>>>> If a reader catches previous value of item->sk_hash, two cases a=
re to=20
>>>>>> be taken into :
>>>>>>
>>>>>> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begin=
 : Reader=20
>>>>>> will redo its scan
>>>>>>
>>>>>> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>>>>>>  -> next pointer is good enough : it points to next item in same=
 hash=20
>>>>>> chain.
>>>>>>     No need to rescan the chain at this point.
>>>>>>     Yes we could miss the fact that a new port was bound and thi=
s UDP=20
>>>>>> message could be lost.
>>>>>>    =20
>>>>> 3) its udp_hashfn(net, sk-sk_hash) is =3D=3D hash, but only becau=
se it was
>>>>> removed, freed, reallocated, and then readded with the same hash =
value,
>>>>> possibly carrying the reader to a new position in the same list.
>>>>>  =20
>>>> If I understand this, without the smp_wmb(), it is possible that t=
he next=20
>>>> field can be written to main memory before the hash value is writt=
en.  If=20
>>>> that happens, the following can occur:
>>>>
>>>>  CPU1                    CPU2
>>>>  next is set to NULL (end of new list)
>>> Well, if this item is injected to the same chain, next wont be set =
to=20
>>> NULL.
>>>
>>> That would mean previous writers deleted all items from the chain.
>> I put my comment in the wrong place, I wasn't talking about being in=
jected=20
>> into the same chain.
>>
>>> In this case, readers can see NULL, it is not a problem at all.
>>> List is/was empty.
>>> An application cannot complain a packet is not
>>> handled if its bind() syscall is not yet completed :)
>>>
>>> If item is injected on another chain, we will detect hash mismatch =
and=20
>>> redo full scan.
>> If the item is injected onto the end of another chain, the next fiel=
d will=20
>> be NULL and you won't detect a hash mismatch.  It's basically the sa=
me=20
>> issue as the previous race, though a lot more subtle and unlikely.  =
If you=20
>> get (from the previous socket) an old value of "sk_hash" and (from t=
he new=20
>> socket) a new value of "next" that is NULL, you will terminate the l=
oop=20
>> when you should have restarted it.  I'm pretty sure that can occur w=
ithout=20
>> the write barrier.
>=20
> One way of dealing with this is to keep a tail pointer.  Then, if the
> element containing the NULL pointer doesn't match the tail pointer se=
en
> at the start of the search, or if the tail pointer has changed,
> restart the search.  Memory barriers will be needed.  ;-)
>=20

Hum... Another way of handling all those cases and avoid memory barrier=
s
would be to have different "NULL" pointers.

Each hash chain should have a unique "NULL" pointer (in the case of UDP=
, it
can be the 128 values : [ (void*)0 .. (void *)127 ]

Then, when performing a lookup, a reader should check the "NULL" pointe=
r
it get at the end of its lookup has is the "hash" value of its chain.

If not -> restart the loop, aka "goto begin;" :)

We could avoid memory barriers then.

In the two cases Corey mentioned, this trick could let us avoid memory =
barriers.
(existing one in sk_add_node_rcu(sk, &hslot->head); should be enough)

What do you think ?


