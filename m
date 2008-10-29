From: Corey Minyard <minyard@acm.org>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 13:28:15 -0500
Message-ID: <4908AB3F.1060003@acm.org>
References: <20081008.114527.189056050.davem@davemloft.net>
 <49077918.4050706@cosmosbay.com> <490795FB.2000201@cosmosbay.com>
 <20081028.220536.183082966.davem@davemloft.net>
 <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com>
 <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
 <4908A134.4040705@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173007pub.verizon.net ([206.46.173.7]:48247 "EHLO
	vms173007pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbYJ2T3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 15:29:47 -0400
Received: from wf-rch.minyard.local ([96.226.138.225])
 by vms173007.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0K9I00FH0J9PHDH1@vms173007.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 29 Oct 2008 13:27:26 -0500 (CDT)
In-reply-to: <4908A134.4040705@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Corey Minyard a =E9crit :
>> Paul E. McKenney wrote:
>>> On Wed, Oct 29, 2008 at 05:09:53PM +0100, Eric Dumazet wrote:
>>> =20
>>>> Corey Minyard a =E9crit :
>>>>  =20
>>>>> Eric Dumazet wrote:
>>>>>    =20
>>>>>> Corey Minyard found a race added in commit=20
>>>>>> 271b72c7fa82c2c7a795bc16896149933110672d
>>>>>> (udp: RCU handling for Unicast packets.)
>>>>>>
>>>>>> "If the socket is moved from one list to another list in-between=
=20
>>>>>> the time  the hash is calculated and the next field is accessed,=
=20
>>>>>> and the socket  has moved to the end of the new list, the=20
>>>>>> traversal will not complete  properly on the list it should have=
,=20
>>>>>> since the socket will be on the end  of the new list and there's=
=20
>>>>>> not a way to tell it's on a new list and  restart the list=20
>>>>>> traversal.  I think that this can be solved by  pre-fetching the=
=20
>>>>>> "next" field (with proper barriers) before checking the  hash."
>>>>>>
>>>>>> This patch corrects this problem, introducing a new=20
>>>>>> sk_for_each_rcu_safenext()
>>>>>> macro.
>>>>>>        =20
>>>>> You also need the appropriate smp_wmb() in udp_lib_get_port()=20
>>>>> after sk_hash is set, I think, so the next field is guaranteed to=
=20
>>>>> be changed after the hash value is changed.
>>>>>      =20
>>>> Not sure about this one Corey.
>>>>
>>>> If a reader catches previous value of item->sk_hash, two cases are=
=20
>>>> to be taken into :
>>>>
>>>> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begin :=
=20
>>>> Reader will redo its scan
>>>>
>>>> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>>>>  -> next pointer is good enough : it points to next item in same=20
>>>> hash chain.
>>>>     No need to rescan the chain at this point.
>>>>     Yes we could miss the fact that a new port was bound and this=20
>>>> UDP message could be lost.
>>>>    =20
>>>
>>> 3) its udp_hashfn(net, sk-sk_hash) is =3D=3D hash, but only because=
 it was
>>> removed, freed, reallocated, and then readded with the same hash va=
lue,
>>> possibly carrying the reader to a new position in the same list.
>>>  =20
>> If I understand this, without the smp_wmb(), it is possible that the=
=20
>> next field can be written to main memory before the hash value is=20
>> written.  If that happens, the following can occur:
>>
>>  CPU1                    CPU2
>>  next is set to NULL (end of new list)
>
> Well, if this item is injected to the same chain, next wont be set to=
=20
> NULL.
>
> That would mean previous writers deleted all items from the chain.
I put my comment in the wrong place, I wasn't talking about being=20
injected into the same chain.

>
> In this case, readers can see NULL, it is not a problem at all.
> List is/was empty.
> An application cannot complain a packet is not
> handled if its bind() syscall is not yet completed :)
>
> If item is injected on another chain, we will detect hash mismatch an=
d=20
> redo full scan.
If the item is injected onto the end of another chain, the next field=20
will be NULL and you won't detect a hash mismatch.  It's basically the=20
same issue as the previous race, though a lot more subtle and unlikely.=
 =20
If you get (from the previous socket) an old value of "sk_hash" and=20
(from the new socket) a new value of "next" that is NULL, you will=20
terminate the loop when you should have restarted it.  I'm pretty sure=20
that can occur without the write barrier.

>
>>                          fetch next
>>                          calculate hash and compare to sk_hash
>>  sk_hash is set to new value
>>
>> So I think in the above cases, your case #2 is not necessarily valid=
=20
>> without the barrier.
>>
>> And another possible issue.  If sk_hash is written before next, and=20
>> CPU1 is interrupted before CPU2, CPU2 will continually spin on the=20
>> list until CPU1 comes back and moves it to the new list.  Note sure=20
>> if that is an issue.
>
> Probably not. Previously, readers were spining on read_lock(), when a=
=20
> writer was inside its critical section (write_lock()/write_unlock()).
> So instead of spining inside read_unlock(), issuing stupid memory=20
> transactions, the readers can now spin reading hash chain and populat=
e
> cpu cache :)
Yes, I thought about that and thought I would point it out, but I agree=
,=20
what you have is certainly better than spinning on a lock :).


-corey
