From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 11:52:00 -0700
Message-ID: <20081029185200.GE6732@linux.vnet.ibm.com>
References: <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com> <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Corey Minyard <minyard@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:39502 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753491AbYJ2SwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 14:52:03 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9TIq2aB008039
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 14:52:02 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9TIq2BB125904
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 14:52:02 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9TIq0uk029753
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 14:52:02 -0400
Content-Disposition: inline
In-Reply-To: <4908AB3F.1060003@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 01:28:15PM -0500, Corey Minyard wrote:
> Eric Dumazet wrote:
>> Corey Minyard a =E9crit :
>>> Paul E. McKenney wrote:
>>>> On Wed, Oct 29, 2008 at 05:09:53PM +0100, Eric Dumazet wrote:
>>>> =20
>>>>> Corey Minyard a =E9crit :
>>>>>  =20
>>>>>> Eric Dumazet wrote:
>>>>>>    =20
>>>>>>> Corey Minyard found a race added in commit=20
>>>>>>> 271b72c7fa82c2c7a795bc16896149933110672d
>>>>>>> (udp: RCU handling for Unicast packets.)
>>>>>>>
>>>>>>> "If the socket is moved from one list to another list in-betwee=
n the=20
>>>>>>> time  the hash is calculated and the next field is accessed, an=
d the=20
>>>>>>> socket  has moved to the end of the new list, the traversal wil=
l not=20
>>>>>>> complete  properly on the list it should have, since the socket=
 will=20
>>>>>>> be on the end  of the new list and there's not a way to tell it=
's on=20
>>>>>>> a new list and  restart the list traversal.  I think that this =
can be=20
>>>>>>> solved by  pre-fetching the "next" field (with proper barriers)=
=20
>>>>>>> before checking the  hash."
>>>>>>>
>>>>>>> This patch corrects this problem, introducing a new=20
>>>>>>> sk_for_each_rcu_safenext()
>>>>>>> macro.
>>>>>>>        =20
>>>>>> You also need the appropriate smp_wmb() in udp_lib_get_port() af=
ter=20
>>>>>> sk_hash is set, I think, so the next field is guaranteed to be c=
hanged=20
>>>>>> after the hash value is changed.
>>>>>>      =20
>>>>> Not sure about this one Corey.
>>>>>
>>>>> If a reader catches previous value of item->sk_hash, two cases ar=
e to=20
>>>>> be taken into :
>>>>>
>>>>> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begin =
: Reader=20
>>>>> will redo its scan
>>>>>
>>>>> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>>>>>  -> next pointer is good enough : it points to next item in same =
hash=20
>>>>> chain.
>>>>>     No need to rescan the chain at this point.
>>>>>     Yes we could miss the fact that a new port was bound and this=
 UDP=20
>>>>> message could be lost.
>>>>>    =20
>>>>
>>>> 3) its udp_hashfn(net, sk-sk_hash) is =3D=3D hash, but only becaus=
e it was
>>>> removed, freed, reallocated, and then readded with the same hash v=
alue,
>>>> possibly carrying the reader to a new position in the same list.
>>>>  =20
>>> If I understand this, without the smp_wmb(), it is possible that th=
e next=20
>>> field can be written to main memory before the hash value is writte=
n.  If=20
>>> that happens, the following can occur:
>>>
>>>  CPU1                    CPU2
>>>  next is set to NULL (end of new list)
>>
>> Well, if this item is injected to the same chain, next wont be set t=
o=20
>> NULL.
>>
>> That would mean previous writers deleted all items from the chain.
> I put my comment in the wrong place, I wasn't talking about being inj=
ected=20
> into the same chain.
>
>>
>> In this case, readers can see NULL, it is not a problem at all.
>> List is/was empty.
>> An application cannot complain a packet is not
>> handled if its bind() syscall is not yet completed :)
>>
>> If item is injected on another chain, we will detect hash mismatch a=
nd=20
>> redo full scan.
> If the item is injected onto the end of another chain, the next field=
 will=20
> be NULL and you won't detect a hash mismatch.  It's basically the sam=
e=20
> issue as the previous race, though a lot more subtle and unlikely.  I=
f you=20
> get (from the previous socket) an old value of "sk_hash" and (from th=
e new=20
> socket) a new value of "next" that is NULL, you will terminate the lo=
op=20
> when you should have restarted it.  I'm pretty sure that can occur wi=
thout=20
> the write barrier.

One way of dealing with this is to keep a tail pointer.  Then, if the
element containing the NULL pointer doesn't match the tail pointer seen
at the start of the search, or if the tail pointer has changed,
restart the search.  Memory barriers will be needed.  ;-)

							Thanx, Paul

>>>                          fetch next
>>>                          calculate hash and compare to sk_hash
>>>  sk_hash is set to new value
>>>
>>> So I think in the above cases, your case #2 is not necessarily vali=
d=20
>>> without the barrier.
>>>
>>> And another possible issue.  If sk_hash is written before next, and=
 CPU1=20
>>> is interrupted before CPU2, CPU2 will continually spin on the list =
until=20
>>> CPU1 comes back and moves it to the new list.  Note sure if that is=
 an=20
>>> issue.
>>
>> Probably not. Previously, readers were spining on read_lock(), when =
a=20
>> writer was inside its critical section (write_lock()/write_unlock())=
=2E
>> So instead of spining inside read_unlock(), issuing stupid memory=20
>> transactions, the readers can now spin reading hash chain and popula=
te
>> cpu cache :)
> Yes, I thought about that and thought I would point it out, but I agr=
ee,=20
> what you have is certainly better than spinning on a lock :).
>
>
> -corey
